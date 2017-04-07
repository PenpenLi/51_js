
function Net.parseMineEvent3(obj)
    if obj == nil then
        return
    end

    local e3info = tolua.cast(obj:getObj("e3info"), "MediaObj")
    gDigMine.setLuckyWheelLeftTime(e3info:getInt("etime"))
    gDigMine.clearLuckyWheelItems()
    gDigMine.clearLuckyWheelDisruptItems()
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id1"),num=e3info:getInt("num1")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id2"),num=e3info:getInt("num2")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id3"),num=e3info:getInt("num3")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id4"),num=e3info:getInt("num4")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id5"),num=e3info:getInt("num5")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id6"),num=e3info:getInt("num6")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id7"),num=e3info:getInt("num7")})
    gDigMine.addLuckyWheelItem({id=e3info:getInt("id8"),num=e3info:getInt("num8")})
    gDigMine.setLuckyWheelTurnNums(e3info:getInt("cnum"))
    gDigMine.disruptLuckyWheelItems()
end

function Net.parseMineEvent9ExchangeList(obj)
    if obj == nil then
        return
    end

    gDigMine.clearEvent9ExchangeList()
    local event9ExchangeList = tolua.cast(obj, "MediaArray")
    for i = 0, event9ExchangeList:count()-1 do
        local exchangeObj = tolua.cast(event9ExchangeList:getObj(i), "MediaObj")
        if nil ~= exchangeObj then
            gDigMine.addEvent9ExchangeItem({id=exchangeObj:getInt("id"),num=exchangeObj:getInt("num")})
        end
    end
end

function Net.parseDigingOrUngetInfoList(obj)
    gDigMine.digingOrUngetInfoList = {}
    local lobjList = obj:getArray("lobjlist")
    if nil ~= lobjList then
        lobjList = tolua.cast(lobjList, "MediaArray")
        for i = 0, lobjList:count()-1 do
            local lobj = tolua.cast(lobjList:getObj(i), "MediaObj")
            if nil ~= lobj then
                local _x = lobj:getInt("x") - gDigMine.xOriRange / 2 + 1
                local _y  =lobj:getInt("y")
                local key = string.format("%d_%d",_x,_y)
                gDigMine.digingOrUngetInfoList[key] = {}
                gDigMine.digingOrUngetInfoList[key].lefttime = lobj:getInt("lefttime")
                gDigMine.digingOrUngetInfoList[key].itemid = lobj:getByte("itemid")
            end
        end
    end
end
--[[
mining.info 矿区信息
发送参数:
  |-(byte)type 类型,0:只发送点亮区域,1:发送所有的
  |-(boolean)first 是否首次,true:下发矿区数据
接收参数:
  |-(byte)ret 返回码
  |-(byteArray)info 资源列表(byte[],first为true时下发)
    |-(short) ylenght(有多少组)
      |-(short)xlength x长度
          |-(short)x x坐标
          |-(byte)id 图形id
  |-(int)retime 重置矿区的倒计时时间(秒)
  |-(int)lv 矿区等级
  |-(boolean)finish 是否有完成的工程
  |-(ISFSObject)lobj 表示有挖掘的数据，或是未领取的资源(可能为空)
    |-(int) x 对应的x坐标
    |-(int) y 对应的y坐标
    |-(int) lefttime 正在挖掘的剩余时间
    |-(int) itemid 资源id
]]
CMD_MINING_INFO = "mining.info"
function Net.sendMiningInfo(infoType, first)
  local obj = MediaObj:create()
  obj:setByte("type",infoType)
  obj:setBool("first",first)
  Net.sendExtensionMessage(obj, CMD_MINING_INFO)
end

function Net.rec_mining_info(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    -- local curTime = socket.gettime();
    local firstInit = false
    if obj:containsKey("info") then
        gDigMine.ClearMineData()
        local byteArr = obj:getByteArray("info")
        if nil ~= byteArr then
            byteArr:resetPos()
            local yLength = byteArr:getShort()
            --记录点亮最深的y值
            gDigMine.maxLightY = yLength - 1
            gDigMine.minLightXForY = gDigMine.xOriRange / 2
            gDigMine.maxLightXForY = -gDigMine.xOriRange / 2 + 1
            gDigMine.minLightX = gDigMine.xOriRange / 2
            gDigMine.maxLightX = -gDigMine.xOriRange / 2 + 1
            for j = 1, yLength do
                local posY = j - 1
                local debugInfo = ""
                local xLength = byteArr:getShort()
                for i = 1,  xLength do
                    local posX = byteArr:getShort()
                    local realPosX = posX - gDigMine.xOriRange / 2 + 1
                    local id   = byteArr:getByte()
                    -- print("X is ",realPosX, "Y is ", posY, "id is ",id)
                    -- debugInfo = debugInfo..id.." "
                    gDigMine.addMineData(realPosX, posY, id)
                    if id == MINE_STATUE then
                        gDigMine.addStatusPosInfo(realPosX, posY)
                    elseif id == MINE_EVENT2 then
                        gDigMine.addMineEvent2PosInfo(realPosX, posY)
                    elseif id == MINE_EVENT3 then
                        gDigMine.addMineEvent3PosInfo(realPosX, posY)
                    elseif id == MINE_EVENT9 then
                        gDigMine.addMineEvent9PosInfo(realPosX, posY)
                    end
                    if j == yLength then
                        if realPosX > gDigMine.maxLightXForY then
                            gDigMine.maxLightXForY = realPosX
                        end

                        if realPosX < gDigMine.minLightXForY then
                            gDigMine.minLightXForY = realPosX
                        end
                    end
                    gDigMine.setMinAndMaxLightX(realPosX)
                end
                -- print("y is ",posY, "value is ",debugInfo)
            end
        end
        firstInit = true
        gDigMine.setInit(true)
    end

    if obj:containsKey("vipbn") then
        local vipbnObjec = tolua.cast(obj:getObj("vipbn"), "MediaObj")
        Data.setUsedTimes(VIP_MINE_BAG,vipbnObjec:getInt("mb"))
        Data.setUsedTimes(VIP_MINE_BAG_LEV1,vipbnObjec:getInt("mblv1"))
        Data.setUsedTimes(VIP_MINE_BAG_LEV2,vipbnObjec:getInt("mblv2"))
        Data.setUsedTimes(VIP_MINE_BAG_LEV3,vipbnObjec:getInt("mblv3"))
        Data.setUsedTimes(VIP_DETONATOR,vipbnObjec:getInt("me"))
    end

    if obj:containsKey("exlist") then 
        Net.parseMineEvent9ExchangeList(obj:getArray("exlist"))
    end
    -- print("elapse time is ", socket.gettime() - curTime)
    gDigMine.setRetime(obj:getInt("retime"))
    gDigMine.setLv(obj:getInt("lv"))
    gDigMine.setHasFinProj(obj:getBool("finish"))
    gDigMine.setStatueLv(obj:getInt("statue"))

    if obj:containsKey("lobj") then
        local digr = tolua.cast(obj:getObj("lobj"), "MediaObj")
        gDigMine.setDigingOrUnGetInfo(digr:getInt("x") - gDigMine.xOriRange / 2 + 1,digr:getInt("y"),digr:getInt("lefttime"),digr:getInt("itemid"))
    end

    if obj:containsKey("lobjlist") then
        Net.parseDigingOrUngetInfoList(obj)
        gDigMine.setBusyMiners(table.count(gDigMine.digingOrUngetInfoList))
    end

    if obj:containsKey("e2info") then
        local e2info = tolua.cast(obj:getObj("e2info"), "MediaObj")
        gDigMine.setMermaidBuyLeftTime(e2info:getInt("etime"))
        gDigMine.mermaidBuyItems = {}
        table.insert(gDigMine.mermaidBuyItems, {id=e2info:getInt("id1"),num=e2info:getInt("num1")})
        table.insert(gDigMine.mermaidBuyItems, {id=e2info:getInt("id2"),num=e2info:getInt("num2")})
        table.insert(gDigMine.mermaidBuyItems, {id=e2info:getInt("id3"),num=e2info:getInt("num3")})
        gDigMine.setEvent2ExtraInfo(e2info:getInt("op"), e2info:getInt("fp"))
    end

    if obj:containsKey("e3info") then
        Net.parseMineEvent3(obj)
    end

    if obj:containsKey("e9info") then
        local e9info = tolua.cast(obj:getObj("e9info"), "MediaObj")
        gDigMine.setBlackMarketLeftTime(e9info:getInt("etime"))
    end

    if obj:containsKey("mastery") then
        gDigMine.mastery = obj:getInt("mastery")
    end

    if obj:containsKey("miner") then
        gDigMine.miner = obj:getInt("miner")
    end

    if nil ~= Net.mineAtlasCallback then
        Net.mineAtlasCallback()
        Net.mineAtlasCallback = nil
    end
    
    if Panel.isOpenPanel(PANEL_DIG_MINE) and (gDigMine.resetFlag or firstInit) then
        gDispatchEvt(EVENT_ID_MINING_INIT)
    elseif firstInit then
        Panel.popUp(PANEL_DIG_MINE,true)
    else
        Panel.popUp(PANEL_DIG_MINE,false)
    end   
    gDigMine.resetFlag = false
    -- if firstInit then
    --     gDispatchEvt(EVENT_ID_MINING_INIT)
    -- else
    --     gDispatchEvt(EVENT_ID_MINING_UPDATE)
    -- end
end


--[[
mining.reset 矿区重置
发送参数:
  |-(byte)type 类型,0:默认重置,1:道具重置
接收参数:
  |-(byte)ret 接口编码
  |-(ISFSObject)reward 道具数据(神秘之石减少数量)
  
]]
CMD_MINING_RESET = "mining.reset"
function Net.sendMiningReset(type)
  local obj = MediaObj:create()
  obj:setByte("type",type)
  Net.sendExtensionMessage(obj, CMD_MINING_RESET)
  if (TalkingDataGA) then
    gLogEvent("mining.reset")
  end
end


function Net.rec_mining_reset(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    Net.updateReward(obj:getObj("reward"),0)
    gDigMine.ClearMineData()
    gDigMine.resetFlag = true
    Net.sendMiningInfo(0, true)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end

--[[
mining.dig 挖矿
发送参数:
  |-(int)x x坐标
  |-(int)y y坐标
接收参数:
  |-(byte)ret 接口编码
  |-(ISFSarry)light 被点亮的区域数据
    |-(int)x  x坐标
    |-(int)y  y坐标
    |-(byte)id 资源id
  |-(ISFSObject)digr 挖矿数据
    |-(int)x  对应的x数据
    |-(int)y  对应的y数据
    |-(int)lefttime 正在挖掘的剩余时间(为零表示对应的道具资源)
    |-(itemid)id 资源id 
]]
CMD_MINING_DIG = "mining.dig"
function Net.sendMiningDig(x, y)
  local obj = MediaObj:create()
  local realX = x + gDigMine.xOriRange / 2 - 1
  if Net.digPosSend ~= nil and Net.digPosSend.x == x and
     Net.digPosSend.y == y then
     return
  end
  Net.digPosSend = {}
  Net.digPosSend.x = x
  Net.digPosSend.y = y
  obj:setInt("x",realX)
  obj:setInt("y",y)
  Net.sendExtensionMessage(obj, CMD_MINING_DIG)
  if (TalkingDataGA) then
    local param = {}
    param["x"] = tostring(realX)
    param["y"] = tostring(y)
    gLogEvent("mining.dig",param)
  end
end

function Net.rec_mining_dig(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        if  obj:getByte("ret") == 11 then
            local x = obj:getInt("x")
            local realX = x + gDigMine.xOriRange / 2 - 1
            local y = obj:getInt("y")
            local key = string.format("%d_%d",realX,y)
            if gDigMine.data[key] ~= MINE_TERRAIN_TYPE0 then
                Net.sendMiningInfo(0,true)
                Net.sendRefreshData()
            end
        end 
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    local lightMine = Net.parseLightMine(obj)
    local posX, posY = nil, nil
    if obj:containsKey("digr") then
        local digr = tolua.cast(obj:getObj("digr"), "MediaObj")
        gDigMine.setDigingOrUnGetInfo(digr:getInt("x") - gDigMine.xOriRange / 2 + 1,digr:getInt("y"),digr:getInt("lefttime"),digr:getInt("itemid"))
    elseif obj:containsKey("digrobj") then
        local digr = tolua.cast(obj:getObj("digrobj"), "MediaObj")
        posX = digr:getInt("x") - gDigMine.xOriRange / 2 + 1
        posY = digr:getInt("y")
        local key = string.format("%d_%d",posX,posY)
        if digr:getInt("itemid") == MINE_TERRAIN_TYPE0 then
            local lefttime = gGetCurServerTime() + DB.getDigingTimeForMine(gDigMine.data[key])
            gDigMine.setDigingOrUngetInfoList(posX, posY, lefttime, digr:getInt("itemid"))
        else
            gDigMine.setDigingOrUngetInfoList(posX, posY, digr:getInt("lefttime"),digr:getInt("itemid"))
        end
    else
        gDigMine.setDigingNormalLand()
    end
    gDispatchEvt(EVENT_ID_MINING_DIG,{lightMine, {x=posX,y=posY}})
end


--[[
mining.exploder 挖矿
发送参数:
  |-(int)x x坐标
  |-(int)y y坐标
接收参数:
  |-(byte)ret 接口编码
  |-(ISFSObject)reward(得到物品和消耗雷管)
  |-(ISFSObject)digr 挖矿数据
    |-(int)x  对应的x数据
    |-(int)y  对应的y数据
    |-(int)lefttime 正在挖掘的剩余时间(为零表示对应的道具资源)
    |-(itemid)id 资源id 
]]
CMD_MINING_EXPLODER = "mining.exploder"
function Net.sendMiningExploder(x, y)
    local obj = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    obj:setInt("x",realX)
    obj:setInt("y",y)
    Net.sendExtensionMessage(obj, CMD_MINING_EXPLODER)
end

function Net.rec_mining_exploder(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    gDigMine.explodeReword = Net.updateReward(obj:getObj("reward"), 0)
    local posX = 0
    local posY = 0
    --TODO
    if obj:containsKey("digr") then
        local digr = tolua.cast(obj:getObj("digr"), "MediaObj")
        gDigMine.setDigingOrUnGetInfo(digr:getInt("x")- gDigMine.xOriRange / 2 + 1,digr:getInt("y"),digr:getInt("lefttime"),digr:getInt("itemid"))
    elseif obj:containsKey("digrobj") then
        local digr = tolua.cast(obj:getObj("digrobj"), "MediaObj")
        posX = digr:getInt("x") - gDigMine.xOriRange / 2 + 1
        posY = digr:getInt("y")
        local key = string.format("%d_%d",posX,posY)
        if digr:getInt("itemid") == MINE_TERRAIN_TYPE0 then
            local lefttime = gGetCurServerTime() + DB.getDigingTimeForMine(gDigMine.data[key])
            gDigMine.setDigingOrUngetInfoList(posX, posY, lefttime, digr:getInt("itemid"))
        else
            gDigMine.setDigingOrUngetInfoList(posX, posY, digr:getInt("lefttime"),digr:getInt("itemid"))
        end
    else
        gDigMine.setDigingNormalLand()
    end
    local lightMine = Net.parseLightMine(obj)
    gDispatchEvt(EVENT_ID_MINING_EXPLODER,{lightMine,{x=posX,y=posY}})
end


--[[
mining.get 获取资源
发送参数:
  |-(int)x x坐标
  |-(int)y y坐标
接收参数:
  |-(byte)ret 接口编码
  |-(ISFSObject)reward(得到物品和消耗雷管)
]]
CMD_MINING_GET = "mining.get"
function Net.sendMiningGet(x, y)
    local obj = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    if  Net.posOfGetMining ~= nil and 
        Net.posOfGetMining.x == x and 
        Net.posOfGetMining.y == y then
        return
    end
    Net.posOfGetMining = {}
    Net.posOfGetMining.x = x
    Net.posOfGetMining.y = y
    obj:setInt("x",realX)
    obj:setInt("y",y)
    Net.sendExtensionMessage(obj, CMD_MINING_GET)
end

function Net.rec_mining_get(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        if ret == 9 then
            gDispatchEvt(EVENT_ID_MINING_GET,Net.posOfGetMining)
        end
        return
    end
    local key = string.format("%d_%d", Net.posOfGetMining.x,  Net.posOfGetMining.y)
    -- 改为暴击倍数
    gDigMine.critPoses[key] = obj:getInt("critNum")

    Net.updateReward(obj:getObj("reward"),2)

    gDispatchEvt(EVENT_ID_MINING_GET,Net.posOfGetMining)
end


--[[
mining.projinfo 工程详细
发送参数:

接收参数:
  |-(byte)ret 接口编码
  |-(ISFSarry)list 工程列表
    |-(int)depth(深度)
    |-(int)time(结束时间)
    |-(byte)status(状态 0:空闲 1:完成,2:进行中,3:等待 4:加锁)
]]
CMD_MINING_PROJ_INFO = "mining.projinfo"
function Net.sendMiningProjInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_MINING_PROJ_INFO)
end

function Net.rec_mining_projinfo(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    --TODO 工程详细信息
    gDigMine.initProList()
    local projList = obj:getArray("list")
    if nil ~= projList then
        projList = tolua.cast(projList, "MediaArray")
        local hasFinProj = false
        -- print("projList:count is:",projList:count())
        for i = 0, projList:count()-1 do
            local projInfo = tolua.cast(projList:getObj(i), "MediaObj")
            if nil ~= projInfo then
                local depth = projInfo:getInt("depth")
                local needtime  = projInfo:getInt("needtime")
                local endtime  = projInfo:getInt("endtime")
                local status = projInfo:getByte("status")
                if status == MINE_PROJ_STATUS_FINSIH then
                    hasFinProj = true
                end
                gDigMine.addProjInfo(depth, needtime, endtime, status)
            end
        end
        gDigMine.sortProjInfo()
        gDigMine.setHasFinProj(hasFinProj)
    end
    if Panel.isOpenPanel(PANEL_MINE_WORKSHOP) then
        gDispatchEvt(EVENT_ID_MINING_PROJINFO)
    else
        Panel.popUpVisible(PANEL_MINE_WORKSHOP,nil,nil,true)
    end
end

--[[
mining.newp 新工程
发送参数:
  |-(int)depth 深度
  |-(int)time 挖掘所需时间
接收参数:
  |-(byte)ret 接口编码
  |—(int) depth 深度
  |-(int) needtime 需要时间
  |-(int) endtime  结束时间
  |-(byte) status 状态 1:完成,2:进行中,3:等待 4:空闲,5:加锁
]]
CMD_MINING_NEW_PROJ= "mining.newp"
function Net.sendMiningNewProj(depth,time)
    local obj = MediaObj:create()
    obj:setInt("depth",depth)
    obj:setInt("time",time)
    Net.sendExtensionMessage(obj, CMD_MINING_NEW_PROJ)
    if (TalkingDataGA) then
      local param = {}
      -- table.insert(param, {id=tostring(self.curActData)})
      param["depth"] = tostring(depth)
      param["time"] = tostring(time)
      gLogEvent("mining.newp",param)
    end
end

function Net.rec_mining_newp(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    --新工程信息
    Net.updateReward(obj:getObj("reward"),0)
    gDigMine.updateNewProj(obj:getInt("depth"), obj:getInt("needtime"), obj:getInt("endtime"), obj:getByte("status"))
    gDigMine.sortProjInfo()
    gDispatchEvt(EVENT_ID_MINING_NEW_PROJ)
end

--[[
mining.finishp 完成工程
发送参数:
  |-(int)depth 深度
  |-(int)endTime 结束时间
接收参数:
  |-(byte)ret 接口编码
  |—(int) depth 深度
  |-(int) needtime 需要时间
  |-(int) endtime  结束时间
  |-(byte) status 状态 1:完成,2:进行中,3:等待 4:空闲,5:加锁
]]
CMD_MINING_FINISH_PROJ= "mining.finishp"
function Net.sendMiningFinishProj(depth,endTime)
    local obj = MediaObj:create()
    obj:setInt("depth",depth)
    obj:setInt("etime",endTime)
    Net.sendExtensionMessage(obj, CMD_MINING_FINISH_PROJ)
end

function Net.rec_mining_finishp(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    --重新发初始化信息
    Net.sendMiningProjInfo()
    Net.updateReward(obj:getObj("reward"),1)
end

--[[
mining.openb 开矿工包
发送参数:
  |-(int) id 道具id
  |—(int) num 数量
接收参数:
  |-(byte)ret 接口编码
  |-(ISFSObject)reward 得到的物品和扣除的道具
]]
CMD_MINING_OPEN_BOX= "mining.openb"
function Net.sendMiningOpenBox(id, num)
    local obj = MediaObj:create()
    obj:setInt("id",id)
    obj:setInt("num",num)
    Net.sendExtensionMessage(obj, CMD_MINING_OPEN_BOX)
end

function Net.rec_mining_openb(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    local itemid = obj:getInt("id")
    if itemid == ITEM_MINE_BAG then
        Net.updateReward(obj:getObj("reward"),2)
    else
        Net.updateReward(obj:getObj("reward"),1)
    end
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end

--[[
mining.buyb 购买矿工包
发送参数:
  |-(int) id 道具id
  |—(int) num 数量
接收参数:
  |-(byte)ret 接口编码
  |-(int)id 道具id
  |-(ISFSObject)reward 得到的物品和扣除的道具
]]
CMD_MINING_BUY_BOX= "mining.buyb"
function Net.sendMiningBuyBox(id, num)
    local obj = MediaObj:create()
    obj:setInt("id",id)
    obj:setInt("num",num)
    Net.sendExtensionMessage(obj, CMD_MINING_BUY_BOX)
end

function Net.rec_mining_buyb(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    local itemid = obj:getInt("id")
    if obj:containsKey("vipbn") then
        local vipbnObjec = tolua.cast(obj:getObj("vipbn"), "MediaObj")
        Data.setUsedTimes(VIP_MINE_BAG,vipbnObjec:getInt("mb"))
        Data.setUsedTimes(VIP_MINE_BAG_LEV1,vipbnObjec:getInt("mblv1"))
        Data.setUsedTimes(VIP_MINE_BAG_LEV2,vipbnObjec:getInt("mblv2"))
        Data.setUsedTimes(VIP_MINE_BAG_LEV3,vipbnObjec:getInt("mblv3"))
        Data.setUsedTimes(VIP_DETONATOR,vipbnObjec:getInt("me"))
    end
    Net.updateReward(obj:getObj("reward"),1)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end

--[[
mining.enter 进入巨魔石像副本
发送参数:
  |-(int) x x坐标
  |—(int) y y坐标
接收参数:
  |-(byte)ret 接口编码
  |-(int)country 阵营id
  |-(int)teampower 我方战力
  |-(int)stagepower 副本需求战力
  |-(ISFSObject)pobj 玩家自身playercard的集合
  |----p0
  |----p1
  |----p2
  |----p3
  |----p4
  |----p5
  |----p6
  |----pet
  |—(ISFSArray)mlist 战斗的怪物
  |-(ISFSObject)mobj 怪物playercard的集合
  |----m0
  |----m1
  |----m2
  |----m3
  |----m4
  |----m5
  |----m6
]]
CMD_MINING_ENTER = "mining.enter"
function Net.sendMiningEnter()
    local media=MediaObj:create()
    local realX = gDigMine.statusFightPos.x + gDigMine.xOriRange / 2 - 1
    media:setInt("x", realX)
    media:setInt("y", gDigMine.statusFightPos.y)
    --地图id
    -- Net.sendAtlasEnterParam={mapid=mapid}
    Net.sendAtlasEnterParam = {}
    Net.sendExtensionMessage(media, CMD_MINING_ENTER)
end

function Net.rec_mining_enter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)
    Battle.setDropNum(obj:getInt("item"),table.getn(enemyFormations))
    Net.updateReward(obj:getObj("reward"))
    Battle.battleType=BATTLE_TYPE_MINING_STATUS

    local maxRound=DB.getAtlasRound()
--    local data= DB.getActStageInfoById( Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid)
--    if(data)then
--        maxRound=data.batparam
--    end
    local stage = DB.getMineStageById(gDigMine.statusLv)
    Net.sendMonsterSize(enemyFormations,stage)
    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,"b007",power)
end

--[[
mining.fight 进入巨魔石像副本
发送参数:
  |-(int) x x坐标
  |—(int) y y坐标
  |-(ISFSArray)blist 战斗录像集合
接收参数:
  |-(byte)ret 接口编码
  |-(boolean)win 战斗是胜利
  |-(ISFSObject)reward 掉落，战斗胜利才下发此字段
]]
CMD_MINING_FIGHT = "mining.fight"
function Net.sendMiningFight()
    local media=MediaObj:create()
    
    local realX = gDigMine.statusFightPos.x + gDigMine.xOriRange / 2 - 1
    media:setInt("x", realX)
    media:setInt("y", gDigMine.statusFightPos.y)
    media:setObjArray("blist",Battle.getLogData())
    Net.sendExtensionMessage(media, CMD_MINING_FIGHT,true)
    gLogEvent("mining.fight")
end

function Net.rec_mining_fight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Battle.reward={}
    Battle.reward.formation={}
    local rewardObj=obj:getObj("reward")



    if(obj:containsKey("uvobj"))then
        Net.parseUserInfo(obj:getObj("uvobj"))
    end

    Battle.reward.shows= Net.updateReward(rewardObj,0)
    if(obj:containsKey("statue"))then
        gDigMine.setStatueLv(obj:getInt("statue"))
    end

    gDigMine.statueLightMine = {}
    if obj:containsKey("light") then
        local light = obj:getArray("light")
        if nil ~= light then
            light = tolua.cast(light, "MediaArray")
            for i = 0, light:count()-1 do
                local lightObj = tolua.cast(light:getObj(i), "MediaObj")
                if nil ~= lightObj then
                      local posX = lightObj:getInt("x")
                      local realPosX = posX - gDigMine.xOriRange / 2 + 1
                      local posY = lightObj:getInt("y")
                      local id   = lightObj:getByte("id")
                      gDigMine.addMineData(realPosX, posY, id)
                      if id == MINE_STATUE then
                          gDigMine.addStatusPosInfo(realPosX, posY)
                      end
                      gDigMine.statueLightMine[#gDigMine.statueLightMine + 1] = {realPosX, posY, id}
                      gDigMine.setMaxLightY(posY)
                      gDigMine.setMinAndMaxLightX(realPosX)
                end
            end
        end
    end
    -- Scene.showLevelUp = false
    Panel.popUp(PANEL_ATLAS_FINAL)
end

--[[
mining.exinfo 兑换界面详细
发送参数:

接收参数:
  |-(byte)ret 接口编码
  |-(int)retime 下次刷新时间
  |-(ISFSarry)list 兑换列表
    |-(int)id 对应数据id
    |-(int)idx 对应数据索引
    |-(int)item1 用来兑换物品1id
    |-(int)num1 用来兑换物品1数量
    |-(int)item2 用来兑换物品2id
    |-(int)num2 用来兑换物品2数量
    |-(int)item3 用来兑换物品3id
    |-(int)num3 用来兑换物品3数量
    |-(int)exitem 兑换得到的物品id
    |-(int)exnum 兑换得到的物品数量
    |-(int)num 已兑换次数
    |-(int)maxnum 可兑换次数
]]
CMD_MINING_EXCHANGE_INFO = "mining.exinfo"

function Net.sendMiningExInfo(isOpen)
    local media=MediaObj:create()
    Net.isMiningExPanelOpen = isOpen
    Net.sendExtensionMessage(media, CMD_MINING_EXCHANGE_INFO)
end

function Net.rec_mining_exinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDigMine.exRetime   = obj:getInt("retime")--gGetCurServerTime() + 60
    gDigMine.exAllStatus = obj:getByte("status")
    gDigMine.exInfoList = {}
    --TODO,parse
    if obj:containsKey("list") then
        local exInfoList = obj:getArray("list")
        if nil ~= exInfoList then
            exInfoList = tolua.cast(exInfoList, "MediaArray")
            for i = 0, exInfoList:count()-1 do
                local exObj = tolua.cast(exInfoList:getObj(i), "MediaObj")
                if nil ~= exObj then
                    local exInfo = {}
                    exInfo.id = exObj:getInt("id")
                    exInfo.idx = exObj:getInt("idx")
                    exInfo.itemInfo = {}
                    if exObj:containsKey("item1") then
                        local item = {}
                        item.id = exObj:getInt("item1")
                        item.num = exObj:getInt("num1")
                        table.insert(exInfo.itemInfo,item)
                    end

                    if exObj:containsKey("item2") then
                        local item = {}
                        item.id = exObj:getInt("item2")
                        item.num = exObj:getInt("num2")
                        table.insert(exInfo.itemInfo,item)
                    end

                    if exObj:containsKey("item3") then
                        local item = {}
                        item.id = exObj:getInt("item3")
                        item.num = exObj:getInt("num3")
                        table.insert(exInfo.itemInfo,item)
                    end

                    exInfo.exitemInfo = {}
                    exInfo.exitemInfo.id = exObj:getInt("exitem")
                    exInfo.exitemInfo.num = exObj:getInt("exnum")
                    exInfo.num  = exObj:getInt("num")
                    exInfo.maxnum  = exObj:getInt("maxnum")
                    gDigMine.addExInfo(exInfo.idx,exInfo)
                end
            end
        end
    end

    gDispatchEvt(EVENT_ID_MINING_EX_INFO)
    Net.isMiningExPanelOpen = false
end

--[[
mining.exchange 兑换
发送参数:
  |-(int)id 对应数据id
  |—(int)idx 对应数据索引
接收参数:
  |-(byte)ret 接口编码
  |-(int)id 用来兑换物品1id
  |-(ISFSObject)reward 删除和得到的数据
]]
CMD_MINING_EXCHANGE = "mining.exchange"

function Net.sendMiningExchange(id,idx)
    local media=MediaObj:create()
    media:setInt("id",id)
    media:setInt("idx",idx)
    Net.sendExtensionMessage(media, CMD_MINING_EXCHANGE)
end

function Net.rec_mining_exchange(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_MINING_EXCHANGE)
end

--[[
mining.exallinfo 完成所有兑换详细
发送参数:

接收参数:
  |-(byte)ret 接口编码
  |-(ISFSArray)list 奖励列表
    |--(int) item 奖品id
    |--(num) int 奖品数量
  |-(byte) status 0:未到条件,1:可领取,2:已领取
]]
CMD_MINING_EXCHANGE_ALL_INFO = "mining.exallinfo"
function Net.sendMiningExAllInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MINING_EXCHANGE_ALL_INFO)
end

function Net.rec_mining_exallinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    if obj:containsKey("list") then
        local exAllInfo = obj:getArray("list")
        if nil ~= exAllInfo then
            exAllInfo = tolua.cast(exAllInfo, "MediaArray")
            for i = 0, exAllInfo:count()-1 do
                local exObj = tolua.cast(exAllInfo:getObj(i), "MediaObj")
                if nil ~= exObj then
                    local id = exObj:getInt("item")
                    local num = exObj:getInt("num")
                    gDigMine.addExAllInfo(id,num)
                end
            end
        end
    end

    gDigMine.exAllStatus = obj:getByte("status")
    gDispatchEvt(EVENT_ID_MINING_EX_ALL_INFO)
end

--[[
mining.exchangeall 兑换所有奖励
发送参数:

接收参数:
  |-(byte)ret 接口编码
  |-(ISFSObject)reward 删除和得到的数据
    |--(int) item 奖品id
    |--(num) int 奖品数量
  |-(boolean) status 是否可领取
]]
CMD_MINING_EXCHANGE_ALL = "mining.exchangeall"

function Net.sendMiningExchangeAll()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MINING_EXCHANGE_ALL)
end

function Net.rec_mining_exchangeall(evt)
   local obj = evt.params:getObj("params")
   if(obj:getByte("ret")~=0)then
       return
   end
   Net.updateReward(obj:getObj("reward"),2)
   gDigMine.exAllStatus = MINE_EX_BOX_STATUS3
   gDispatchEvt(EVENT_ID_MINING_EX_CHANGE_ALL)
end

CMD_MINING_CANCEL_PROJ = "mining.cancelp"
function Net.sendMiningCancelPro(endTime,needTime)
    local media=MediaObj:create()
    media:setInt("etime",endTime)
    -- media:setInt("ntime",needTime)
    Net.sendExtensionMessage(media, CMD_MINING_CANCEL_PROJ)
end

function Net.rec_mining_cancelp(evt)
  local obj = evt.params:getObj("params")
  if(obj:getByte("ret")~=0)then
      return
  end

  --TODO,更新雷管数量
  Net.updateReward(obj:getObj("reward"),2)

  gDigMine.initProList()
  local projList = obj:getArray("list")
  if nil ~= projList then
      projList = tolua.cast(projList, "MediaArray")
      local hasFinProj = false
      for i = 0, projList:count()-1 do
          local projInfo = tolua.cast(projList:getObj(i), "MediaObj")
          if nil ~= projInfo then
              local depth = projInfo:getInt("depth")
              local needtime  = projInfo:getInt("needtime")
              local endtime  = projInfo:getInt("endtime")
              local status = projInfo:getByte("status")
              if status == MINE_PROJ_STATUS_FINSIH then
                  hasFinProj = true
              end
              gDigMine.addProjInfo(depth, needtime, endtime, status)
          end
      end
      gDigMine.sortProjInfo()
      gDigMine.setHasFinProj(hasFinProj)
  end

  gDispatchEvt(EVENT_ID_MINING_CANCELPRO)
  gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end


-- 
local function checkMinigEventDigPos(x,y)
    if  Net.miningEventDigPos ~= nil and Net.miningEventDigPos.x == x and
        Net.miningEventDigPos.y == y then
        return false
    end
    return true
end

local function setMiningEventDigPos(x,y)
    Net.miningEventDigPos = Net.miningEventDigPos or {}
    Net.miningEventDigPos.x = x
    Net.miningEventDigPos.y = y
end

CMD_MINING_EVENT_1 = "mining.e1"
function Net.sendMiningEvent1(x, y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_1)
    gLogEvent("mining.e1")
end

function Net.rec_mining_e1(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    gDigMine.eventRewards = Net.updateReward(obj:getObj("reward"),0)
    local lightMine = Net.parseLightMine(obj)
    gDispatchEvt(EVENT_ID_MINING_EVENT,lightMine)
end

CMD_MINING_EVENT_2 = "mining.e2"
function Net.sendMiningEvent2(x, y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_2)
    gLogEvent("mining.e2")
end

function Net.rec_mining_e2(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    local lightMine = Net.parseLightMine(obj)

    local e2info = tolua.cast(obj:getObj("e2info"), "MediaObj")
    gDigMine.setMermaidBuyLeftTime(e2info:getInt("etime"))
    gDigMine.mermaidBuyItems = {}
    table.insert(gDigMine.mermaidBuyItems, {id=e2info:getInt("id1"),num=e2info:getInt("num1")})
    table.insert(gDigMine.mermaidBuyItems, {id=e2info:getInt("id2"),num=e2info:getInt("num2")})
    table.insert(gDigMine.mermaidBuyItems, {id=e2info:getInt("id3"),num=e2info:getInt("num3")})
    gDigMine.setEvent2ExtraInfo(e2info:getInt("op"), e2info:getInt("fp"))

    gDispatchEvt(EVENT_ID_MINING_EVENT,lightMine)
end

CMD_MINING_EVENT_2_BUY = "mining.e2buy"
function Net.sendMiningEvent2Buy()
    local media = MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_2_BUY)
end

function Net.rec_mining_e2buy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    gDigMine.setMermaidBuyLeftTime(0)
    gDispatchEvt(EVENT_ID_MINING_MERMAIDBUY_SUC)
end

CMD_MINING_EVENT_3 = "mining.e3"
function Net.sendMiningEvent3(x,y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_3)
    gLogEvent("mining.e3")
end

function Net.rec_mining_e3(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    local lightMine = Net.parseLightMine(obj)
    if obj:containsKey("e3info") then
        Net.parseMineEvent3(obj)
    end

    gDispatchEvt(EVENT_ID_MINING_EVENT,lightMine)
end


CMD_MINING_EVENT_3_TURN = "mining.e3turn"
function Net.sendMiningEvent3Turn()
    local media = MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_3_TURN)
end

function Net.rec_mining_e3turn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.setLuckyWheelTurnIdx(obj:getByte("pos"))
    Net.updateReward(obj:getObj("reward"),0)
    gDigMine.setLuckyWheelTurnNums(gDigMine.getLuckyWheelTurnNums() + 1)
    gDispatchEvt(EVENT_ID_MINING_TURN)
end

CMD_MINING_EVENT_5 = "mining.e5"
function Net.sendMiningEvent5(x,y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_5)
    gLogEvent("mining.e5")
end

function Net.rec_mining_e5(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    gDigMine.eventRewards = {}
    gDigMine.eventRewards = Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_MINING_EVENT,Net.parseLightMine(obj))
end

CMD_MINING_EVENT_6_7 = "mining.e67"
function Net.sendMiningEvent67(x,y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_6_7)
    gLogEvent("mining.e67")
end

function Net.rec_mining_e67(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    gDigMine.eventRewards = {}
    gDigMine.eventRewards = Net.updateReward(obj:getObj("reward"),0)
    gDigMine.torpedoExploderMines = {}
    local effList = obj:getArray("efflist")
    if nil ~= effList then
        effList = tolua.cast(effList, "MediaArray")
        for i = 0, effList:count() - 1 do
            local effObj = tolua.cast(effList:getObj(i), "MediaObj")
            if nil ~= effObj then
                local x = effObj:getInt("x")
                local y = effObj:getInt("y")
                local mineType = effObj:getByte("type")
                local id = effObj:getInt("itemid")
                local num = effObj:getInt("num")
                gDigMine.addTorpedoExploderMine(x, y, mineType, id, num)
            end
        end
    end

    gDigMine.torpedoLightMines = Net.parseLightMine(obj)
    gDispatchEvt(EVENT_ID_MINING_EVENT)
end

CMD_MINING_EVENT_8 = "mining.e8"
function Net.sendMiningEvent8(x,y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_8)
    gLogEvent("mining.e8")
end

function Net.rec_mining_e8(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    local effList = obj:getArray("efflist")
    local effMines = {}
    if nil ~= effList then
        effList = tolua.cast(effList, "MediaArray")
        for i = 0, effList:count() - 1 do
            local effObj = tolua.cast(effList:getObj(i), "MediaObj")
            if nil ~= effObj then
                local x = effObj:getInt("x") - gDigMine.xOriRange / 2 + 1
                local y = effObj:getInt("y")
                local mineType = effObj:getByte("type")
                gDigMine.addMineData(x, y, mineType)
                if mineType == MINE_STATUE then
                    gDigMine.addStatusPosInfo(x, y)
                end
                effMines[#effMines + 1] = {x, y, mineType}
                gDigMine.setMaxLightY(y)
                gDigMine.setMinAndMaxLightX(x)
            end
        end
    end

    gDispatchEvt(EVENT_ID_MINING_EVENT,effMines)
end

CMD_MINING_EVENT_9 = "mining.e9"
function Net.sendMiningEvent9(x,y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_9)
    gLogEvent("mining.e9")
end

function Net.rec_mining_e9(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDigMine.mpt = obj:getInt("mp")
    local lightMine = Net.parseLightMine(obj)
    if obj:containsKey("e9info") then
        local e9info = tolua.cast(obj:getObj("e9info"), "MediaObj")
        gDigMine.setBlackMarketLeftTime(e9info:getInt("etime"))
    end

    if obj:containsKey("exlist") then 
        Net.parseMineEvent9ExchangeList(obj:getArray("exlist"))
    end
    gDispatchEvt(EVENT_ID_MINING_EVENT,lightMine)
end

CMD_MINING_EVENT_9_DEAL = "mining.e9deal"
function Net.sendMiningEvent9Deal(dstIds, dstNums, oriIds,oriNums)
    local media = MediaObj:create()

    local dstIdsArray = vector_int_:new_local()
    for i = 1, #dstIds do 
        dstIdsArray:push_back(dstIds[i])
    end
    media:setIntArray("eid",dstIdsArray)

    local dstNumsArray = vector_int_:new_local()
    for i = 1, #dstNums do 
        dstNumsArray:push_back(dstNums[i])
    end
    media:setIntArray("enum",dstNumsArray)

    local oriIdsArray = vector_int_:new_local()
    for i = 1, #oriIds do 
        oriIdsArray:push_back(oriIds[i])
    end 
    media:setIntArray("sid",oriIdsArray)

    local oriNumsArray = vector_int_:new_local()
    for i = 1, #oriNums do 
        oriNumsArray:push_back(oriNums[i])
    end 
    media:setIntArray("snum",oriNumsArray)

    Net.sendExtensionMessage(media, CMD_MINING_EVENT_9_DEAL)
end

function Net.rec_mining_e9deal(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    if obj:containsKey("exlist") then 
        Net.parseMineEvent9ExchangeList(obj:getArray("exlist"))
    end
    gDispatchEvt(EVENT_ID_MINING_BLACK_MARKET)
end

function Net.parseLightMine(obj)
    if obj  == nil then
        return
    end

    local light = obj:getArray("light")
    local lightMine = {}
    if nil ~= light then
        light = tolua.cast(light, "MediaArray")
        for i = 0, light:count()-1 do
            local lightObj = tolua.cast(light:getObj(i), "MediaObj")
            if nil ~= lightObj then
                  local posX = lightObj:getInt("x")
                  local realPosX = posX - gDigMine.xOriRange / 2 + 1
                  local posY = lightObj:getInt("y")
                  local id   = lightObj:getByte("id")
                  gDigMine.addMineData(realPosX, posY, id)
                  if id == MINE_STATUE then
                      gDigMine.addStatusPosInfo(realPosX, posY)
                  elseif id == MINE_EVENT2 then
                      gDigMine.addMineEvent2PosInfo(realPosX, posY)
                  elseif id == MINE_EVENT3 then
                      gDigMine.addMineEvent3PosInfo(realPosX, posY)
                  elseif id == MINE_EVENT9 then
                      gDigMine.addMineEvent9PosInfo(realPosX, posY)
                  end
                  lightMine[#lightMine + 1] = {realPosX, posY, id}
                  gDigMine.setMaxLightY(posY)
                  gDigMine.setMinAndMaxLightX(realPosX)
            end
        end
        gLogEvent("light_mine")
    end
    return lightMine
end

CMD_MINING_EVENT_4 = "mining.e4"
function Net.sendMiningEvent4(x,y)
    if not checkMinigEventDigPos(x,y) then
        return
    end
    local media = MediaObj:create()
    local realX = x + gDigMine.xOriRange / 2 - 1
    media:setInt("x",realX)
    media:setInt("y",y)
    setMiningEventDigPos(x,y)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_4)
end

function Net.rec_mining_e4(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mpt = obj:getInt("mp")
    gDigMine.eventRewards = Net.updateReward(obj:getObj("reward"),0)
    local lightMine = Net.parseLightMine(obj)

    gDispatchEvt(EVENT_ID_MINING_EVENT,lightMine)
end

CMD_MINING_EVENT_4_ELEC = "mining.e4elec"
function Net.sendMiningEvent4Elec(stall)
    local media = MediaObj:create()
    media:setByte("stall",stall)
    Net.sendExtensionMessage(media, CMD_MINING_EVENT_4_ELEC)
end

function Net.rec_mining_e4elec(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.setPickaxSupplementStall(obj:getByte("stall"))
    gDigMine.eventRewards = {}
    gDigMine.eventRewards = Net.updateReward(obj:getObj("reward"),0)
    gDigMine.setPickaxSupplementNums(gDigMine.getPickaxSupplementNums() + 1)
    gDispatchEvt(EVENT_ID_MINING_PICKAX_SUPPLEMENT)
end

CMD_MINING_MINER_INFO = "mining.minerinfo" --矿工界面
function Net.sendMiningMinerInfo(queryType)
    local media = MediaObj:create()
    Net.queryMinerType = queryType
    Net.sendExtensionMessage(media, CMD_MINING_MINER_INFO)
end

function Net.rec_mining_minerinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mastery = obj:getInt("mastery")
    if Net.queryMinerType == 1 then
        Panel.popUpVisible(PANEL_MINE_BUY_MINER)
    end
end

CMD_MINING_IM_FINISH_PROJECT="mining.imfinp"
function Net.sendMiningImFinishPro(endTime)
    local media=MediaObj:create()
    media:setInt("etime",endTime)
    Net.sendExtensionMessage(media, CMD_MINING_IM_FINISH_PROJECT)
end

function Net.rec_mining_imfinp(evt)
  local obj = evt.params:getObj("params")
  if(obj:getByte("ret")~=0)then
      return
  end

  Net.updateReward(obj:getObj("reward"),0)

  gDigMine.initProList()
  local projList = obj:getArray("list")
  if nil ~= projList then
      projList = tolua.cast(projList, "MediaArray")
      local hasFinProj = false
      for i = 0, projList:count()-1 do
          local projInfo = tolua.cast(projList:getObj(i), "MediaObj")
          if nil ~= projInfo then
              local depth = projInfo:getInt("depth")
              local needtime  = projInfo:getInt("needtime")
              local endtime  = projInfo:getInt("endtime")
              local status = projInfo:getByte("status")
              if status == MINE_PROJ_STATUS_FINSIH then
                  hasFinProj = true
              end
              gDigMine.addProjInfo(depth, needtime, endtime, status)
          end
      end
      gDigMine.sortProjInfo()
      gDigMine.setHasFinProj(hasFinProj)
  end

  gDispatchEvt(EVENT_ID_MINING_CANCELPRO)
  gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end



