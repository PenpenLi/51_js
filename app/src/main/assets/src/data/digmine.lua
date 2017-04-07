gDigMine = {}
gDigMine.data = {}
gDigMine.XYRangeTable = DB.getClientParamToTable("MINING_X_Y")
gDigMine.xOriRange = toint(gDigMine.XYRangeTable[1])
gDigMine.yOriRange = toint(gDigMine.XYRangeTable[2])
gDigMine.xRange = gDigMine.xOriRange + 10     -- 500左右拖动的延伸距离
gDigMine.yRange = gDigMine.yOriRange + 2 + 3  -- 向下拖动的延伸距离
gDigMine.maxX   = gDigMine.xRange / 2
gDigMine.minX   = -gDigMine.xRange / 2 + 1
gDigMine.maxY   = gDigMine.yRange
gDigMine.minY   = -3
gDigMine.hasInit = false
gDigMine.retime  = 0   --重置矿区的倒计时时间(秒)
gDigMine.lv      = 0   --矿区等级
gDigMine.hasFinProj = false --是否有完成的工程
gDigMine.digingOrUngetInfo = {} --正在挖掘的数据或是未领取的资源
gDigMine.blockOpen = {false, false, false, false, false} --地形地图分为六个区域，区域是否开启
gDigMine.mpt = 0 --矿区点数
gDigMine.mptTime = 0 --下一个矿镐恢复的时间数
gDigMine.projList = {} --工程列表信息
gDigMine.districtScale = 0.7 --矿区默认缩放大小
gDigMine.userMineItems = {} --玩家矿石资源信息
gDigMine.statusFightPos = {} --攻击的雕像位置
gDigMine.statusPosInfo = {} --矿区中存在的雕像位置
gDigMine.statusLv = 0 --雕像等级
gDigMine.explodeReword = {}
gDigMine.miningProjSetting = {} --新建工程设置相关信息，默认加载
gDigMine.maxLightY = 0
gDigMine.minLightXForY = 0
gDigMine.maxLightXForY = 0
gDigMine.minLightX = 0
gDigMine.maxLightX = 0
gDigMine.exInfoList = {}
gDigMine.exAllInfo = {}
gDigMine.exAllStatus = 0
gDigMine.exRetime = 0
gDigMine.resetFlag = false
gDigMine.mptRecoverTime = 0 --客户端记录矿镐点恢复时间
gDigMine.isSendMiningGet = false --是否已经发了获取矿石的消息
gDigMine.sendMiningGetTime = 0 --发送获取矿石消息的时间
gDigMine.mermaidBuyLeftTime = 0 --美人鱼物品出售结束时间
gDigMine.blackMarketLeftTime = 0 --黑市交易结束时间
gDigMine.torpedoExploderMines = {} --鱼雷爆炸影响到矿区
gDigMine.eventRewards = {} --随机事件获取物品奖励
gDigMine.eventTerrainPos = {} --随机事件地形位置
gDigMine.luckyWheelTurnNums = 0 --大转盘转动次数
gDigMine.event2ExtraInfo = {} --美人鱼事件2额外信息
gDigMine.luckyWheelItems  = {} --海底转盘物品
gDigMine.luckyWheelDisruptItems = {} --海底转盘的乱序
gDigMine.luckyWheelDisruptItemsIdx = {}
gDigMine.luckyWheelLeftTime = 0 --大转盘的剩余时间
gDigMine.luckyWheelTurnIdx  = 0 --大转盘抽中索引
gDigMine.torpedoLightMines  = {} --鱼雷爆炸点亮的矿区
gDigMine.blackTradeID       = 0  --黑市交易选中的物品id
gDigMine.mermaidBuyItems    = {} --美人鱼事件2奖励物品
gDigMine.event9ExchangeList = {} --事件9已兑换的道具id
gDigMine.pickaxSupplementStall = 1 --事件4电钻充能的档位
gDigMine.pickaxSupplementNums  = 0 --事件4已充次数
gDigMine.mineEvent2PosInfo = {} --事件2位置信息
gDigMine.mineEvent3PosInfo = {} --事件2位置信息
gDigMine.mineEvent9PosInfo = {} --事件2位置信息
gDigMine.miner = 1  --矿工数，初始为1
gDigMine.digingOrUngetInfoList = {} --正在挖掘的矿石列表
gDigMine.critPoses = {} --暴击的位置信息
gDigMine.busyMiner = 0 --空闲的矿工数



MINE_TWINKLE0 = 0 --矿石不闪
MINE_TWINKLE1 = 1 --矿石闪烁
MINE_TWINKLE2 = 2 --矿石闪烁+1

MINE_EX_BOX_STATUS1 = 0 --兑换宝箱未到条件
MINE_EX_BOX_STATUS2 = 1 --兑换宝箱可领取
MINE_EX_BOX_STATUS3 = 2 --兑换宝箱已领取

MINE_DISTRICT_MIN_SCALE = 0.5 --矿区最大，最小缩放比例
MINE_DISTRICT_MAX_SCALE = 1.0

function gDigMine.ClearMineData()
    gDigMine.data = {}
    gDigMine.digingOrUngetInfo = {}
    gDigMine.statusFightPos = {}
    gDigMine.statusLv = 0
    gDigMine.statusPosInfo = {}
    gDigMine.explodeReword = {}
    gDigMine.maxLightY = 0
    gDigMine.minLightXForY = 0
    gDigMine.maxLightXForY = 0
    gDigMine.minLightX = 0
    gDigMine.maxLightX = 0
    gDigMine.isSendMiningGet = false
    gDigMine.sendMiningGetTime = 0
    gDigMine.mermaidBuyLeftTime = 0
    gDigMine.blackMarketLeftTime = 0
    gDigMine.torpedoExploderMines = {}
    gDigMine.eventRewards = {}
    gDigMine.eventTerrainPos = {}
    gDigMine.luckyWheelTurnNums = 0
    gDigMine.event2ExtraInfo = {}
    gDigMine.luckyWheelItems  = {}
    gDigMine.luckyWheelDisruptItems = {}
    gDigMine.luckyWheelDisruptItemsIdx = {}
    gDigMine.luckyWheelLeftTime = 0
    gDigMine.luckyWheelTurnIdx  = 0
    gDigMine.torpedoLightMines  = {}
    gDigMine.blackTradeID = 0
    gDigMine.mermaidBuyItems    = {}
    gDigMine.event9ExchangeList = {}
    gDigMine.mineEvent2PosInfo = {}
    gDigMine.mineEvent3PosInfo = {}
    gDigMine.mineEvent9PosInfo = {}
    gDigMine.ClearMineAtals()
    gDigMine.miner = 1
    gDigMine.digingOrUngetInfoList = {}
    gDigMine.critPoses = {}
    gDigMine.busyMiner = 0
end

function gDigMine.createMineData(_x, _y, _mineType)
    return {x = _x, y = _y, mineType = _mineType,}
end

function gDigMine.addMineData(_x, _y, _mineType)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.data[key] = _mineType
    -- table.insert(gDigMine.data, {x = _x, y = _y, mineType = _mineType,})
end

function gDigMine.getMiningXY()
    -- local xyTable = DB.getClientParamToTable
end

function gDigMine.initRange(xRange, yRange)
    --TODO
    gDigMine.xRange = xRange
    gDigMine.yRange = yRange + 2
    gDigMine.maxXPos = xRange / 2
    gDigMine.minXPos = -xRange / 2 + 1
    gDigMine.maxYPos = yRange - 1
    gDigMine.minYPos = -2
end

function gDigMine.clear()
    gDigMine.data = {}
    gDigMine.hasInit = false
    gDigMine.retime  = 0
    gDigMine.lv      = 0
    gDigMine.hasFinProj = false
    gDigMine.digingOrUngetInfo = {}
    gDigMine.blockOpen = {false, false, false, false, false}
    gDigMine.projList  = {}
    gDigMine.districtScale = 0.7
    gDigMine.userMineItems = {}
    gDigMine.statusFightPos = {}
    gDigMine.statusLv = 0
    gDigMine.statusPosInfo = {}
    gDigMine.explodeReword = {}
    gDigMine.maxLightY = 0
    gDigMine.minLightXForY = 0
    gDigMine.maxLightXForY = 0
    gDigMine.minLightX = 0
    gDigMine.maxLightX = 0
    gDigMine.exInfoList = {}
    gDigMine.exAllInfo = {}
    gDigMine.exAllStatus = 0
    gDigMine.exRetime = 0
    gDigMine.resetFlag = false
    gDigMine.mptRecoverTime = 0
    gDigMine.isSendMiningGet = false
    gDigMine.sendMiningGetTime = 0
    gDigMine.mermaidBuyLeftTime = 0
    gDigMine.blackMarketLeftTime = 0
    gDigMine.torpedoExploderMines = {}
    gDigMine.eventRewards = {}
    gDigMine.eventTerrainPos = {}
    gDigMine.luckyWheelTurnNums = 0
    gDigMine.event2ExtraInfo = {}
    gDigMine.luckyWheelItems  = {}
    gDigMine.luckyWheelDisruptItems = {}
    gDigMine.luckyWheelDisruptItemsIdx = {}
    gDigMine.luckyWheelLeftTime = 0
    gDigMine.luckyWheelTurnIdx  = 0
    gDigMine.torpedoLightMines  = {}
    gDigMine.blackTradeID = 0
    gDigMine.mermaidBuyItems = {}
    gDigMine.event9ExchangeList = {}
    gDigMine.pickaxSupplementStall = 1
    gDigMine.pickaxSupplementNums  = 0
    gDigMine.mineEvent2PosInfo = {}
    gDigMine.mineEvent3PosInfo = {}
    gDigMine.mineEvent9PosInfo = {}
    gDigMine.miner = 1
    gDigMine.digingOrUngetInfoList = {}
    gDigMine.critPoses = {}
    gDigMine.busyMiner = 0
end

function gDigMine.setInit(flag)
    gDigMine.hasInit = flag
end

function gDigMine.getInit()
    return gDigMine.hasInit
end

function gDigMine.setRetime(retime)
    gDigMine.retime = retime
end

function gDigMine.getRetime()
    return gDigMine.retime
end

function gDigMine.setLv(lv)
    gDigMine.lv = lv
end

function gDigMine.getLv()
    return gDigMine.lv
end

function gDigMine.setHasFinProj(flag)
    gDigMine.hasFinProj = flag
end

function gDigMine.getHasFinProj()
    return gDigMine.hasFinProj
end

function gDigMine.setDigingOrUnGetInfo(x,y,leftTime, itemid)
   gDigMine.digingOrUngetInfo = {}
   gDigMine.digingOrUngetInfo.x = x
   gDigMine.digingOrUngetInfo.y = y
   gDigMine.digingOrUngetInfo.lefttime = leftTime
   gDigMine.digingOrUngetInfo.itemid = itemid
end

function gDigMine.getDigingOrUnGetInfo()
    return gDigMine.digingOrUngetInfo
end

function gDigMine.setBlockOpenOrNot(idx,flag)
    gDigMine.blockOpen[idx] = flag
end

--可能不要设置，性能
function gDigMine.setBlockInfo(x, y)
    if gDigMine.blockOpen[1] and gDigMine.blockOpen[2] and gDigMine.blockOpen[3] 
        and gDigMine.blockOpen[4] and gDigMine.blockOpen[5] and gDigMine.blockOpen[6] then
        return 
    end
    if not gDigMine.blockOpen[1] then
        if x >= 0 and x < 100 and y >= 0 and y < 150 then
            gDigMine.blockOpen[1] = true
        end
    end
    if not gDigMine.blockOpen[2] then
        if x >= 100 and x < 200 and y >= 0 and y < 150 then
            gDigMine.blockOpen[2] = true
        end
    end

    if not gDigMine.blockOpen[3] then
        if x >= 200 and x < 300 and y >= 0 and y < 150 then
            gDigMine.blockOpen[3] = true
        end
    end

    if not gDigMine.blockOpen[4] then
        if x >= 0 and x < 100 and y >= 150 and y < 300 then
            gDigMine.blockOpen[4] = true
        end
    end

    if not gDigMine.blockOpen[5] then
        if x >= 100 and x < 200 and y >= 150 and y < 300 then
            gDigMine.blockOpen[5] = true
        end
    end

    if not gDigMine.blockOpen[6] then
        if x >= 200 and x < 300 and y >= 150 and y < 300 then
            gDigMine.blockOpen[6] = true
        end
    end
end

function gDigMine.canReset(resetType)
    if resetType == MINE_RESET_BY_HAND then
        if gDigMine.retime == 0 then
            return true
        elseif gDigMine.retime - gGetCurServerTime() <= 0 then
            return true
        end
        return false
    elseif resetType == MINE_RESET_BY_ITEM then
    end
    return true
end

function gDigMine.getMineTypeByPos(posX,posY)
    local key = string.format("%d_%d",posX,posY)
    return gDigMine.data[key]
end

function gDigMine.canDigMine(x, y)
    if x == nil or y == nil then
        return false
    end
    --是否有点亮
    local key = string.format("%d_%d", x, y)
    if gDigMine.data[key] == nil then
        -- gShowNotice(gGetCmdCodeWord(CMD_MINING_DIG,5))
        return false
    end
    -- --是否有未领取的资源
    -- if gDigMine.digingOrUngetInfo.itemid ~= nil and gDigMine.digingOrUngetInfo.itemid ~= MINE_TERRAIN_TYPE0 then
    --     gShowNotice(gGetWords("labelWords.plist","lab_mine_unget_pos",gDigMine.digingOrUngetInfo.x,gDigMine.digingOrUngetInfo.y))
    --     -- gShowNotice(gGetCmdCodeWord(CMD_MINING_DIG,9))
    --     print("canDigMine step1")
    --     return false
    -- end
    --是否有空地或是不可挖掘的地表
    if gDigMine.data[key] == MINE_TERRAIN_TYPE0 or gDigMine.data[key] == MINE_TERRAIN_TYPE5 then
        gShowNotice(gGetCmdCodeWord(CMD_MINING_DIG,11))
        return false
    end
    --是否挖掘点数足够
    if gDigMine.mpt < gDigMine.getStatueCount() + 1 then
        gConfirmCancel(gGetWords("labelWords.plist","lab_pickax_num_limit"), function()
            Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
        end)
        return false
    end

    return true
end
--是否可以获取矿石
function gDigMine.canGetMine(x,y)
    if x == nil or y == nil then
        return false
    end
    --TODO CHANGE
    --坐标是否合理
    local oriX = x + gDigMine.xOriRange / 2 - 1
    if oriX < 0 or x > gDigMine.xOriRange - 1 or y < 0 or y > gDigMine.yOriRange - 1 then
        return false
    end

    --是否点亮
    local key = string.format("%d_%d", x, y)
    if  gDigMine.data[key] == nil then
        return false
    end

    return gDigMine.hasUngetMineInList(x, y)
    -- else
    --     --坐标是否是与UngetInfo中的x,y相同
    --     if gDigMine.digingOrUngetInfo.x + gDigMine.xOriRange / 2 - 1 ~= oriX or gDigMine.digingOrUngetInfo.y ~= y then
    --         -- gShowNotice(gGetCmdCodeWord(CMD_MINING_DIG,9))
    --         gShowNotice(gGetWords("labelWords.plist","lab_mine_unget_pos",gDigMine.digingOrUngetInfo.x,gDigMine.digingOrUngetInfo.y))
    --         return false
    --     end

    --     --剩余时间是否已经到
    --     if gDigMine.digingOrUngetInfo.lefttime ~= nil and gDigMine.digingOrUngetInfo.lefttime > gGetCurServerTime() then
    --         return false
    --     end
    -- end
    
    -- return true
end

function gDigMine.resetDigingOrUngetInfo()
    -- print("coming gDigMine.resetDigingOrUngetInfo")
    gDigMine.digingOrUngetInfo = {}
    -- gDigMine.digingOrUngetInfo.lefttime = nil
    -- gDigMine.digingOrUngetInfo.itemid = nil
end

function gDigMine.hasDigingMine(showNotice)
    local hasDiging = false
    for key,var in pairs(gDigMine.digingOrUngetInfoList) do
        if var.lefttime - gGetCurServerTime() > 0 then
            hasDiging = true
            break
        end
    end
    return hasDiging
    -- else
    --     if gDigMine.digingOrUngetInfo.itemid ~= nil and gDigMine.digingOrUngetInfo.lefttime ~= nil and 
    --         gDigMine.digingOrUngetInfo.lefttime - gGetCurServerTime() > 0 then
    --         if showNotice then
    --             -- gShowNotice(gGetCmdCodeWord(CMD_MINING_DIG,15))
    --             gShowNotice(gGetWords("labelWords.plist","lab_mine_diging_pos",gDigMine.digingOrUngetInfo.x,gDigMine.digingOrUngetInfo.y))
    --         end
    --         return true
    --     end

    --     return false
    -- end
end

function gDigMine.hasUngetMine()
    local hasUngetMine = false
    for key, var in pairs(gDigMine.digingOrUngetInfoList) do
        if var.lefttime - gGetCurServerTime() <= 0 then
            hasUngetMine = true
            break
        end
    end
    return hasUngetMine
    -- else
    --     if gDigMine.digingOrUngetInfo.itemid == nil or gDigMine.digingOrUngetInfo.itemid == MINE_TERRAIN_TYPE0 then
    --         return false
    --     end

    --     if gDigMine.digingOrUngetInfo.lefttime ~= nil and gDigMine.digingOrUngetInfo.lefttime - gGetCurServerTime() > 0 then
    --         return false
    --     end

    --     return true
    -- end
end

function gDigMine.setDigingPos(x,y)
    gDigMine.clientDigingX = x
    gDigMine.clientDigingY = y
end

function gDigMine.setDigingNormalLand()
   -- gDigMine.digingOrUngetInfo = {}
   -- gDigMine.digingOrUngetInfo.x = gDigMine.clientDigingX
   -- gDigMine.digingOrUngetInfo.y = gDigMine.clientDigingY
   -- --TODO,1以后需要读配制表
   -- local key = string.format("%d_%d",gDigMine.clientDigingX,gDigMine.clientDigingY)
   -- local digingTime = DB.getDigingTimeForMine(gDigMine.data[key])
   -- gDigMine.digingOrUngetInfo.lefttime = gGetCurServerTime() + digingTime
   -- gDigMine.digingOrUngetInfo.itemid = MINE_TERRAIN_TYPE0
   local key = string.format("%d_%d",gDigMine.clientDigingX,gDigMine.clientDigingY)
   local lefttime = gGetCurServerTime() + DB.getDigingTimeForMine(gDigMine.data[key])
   gDigMine.setDigingOrUngetInfoList(gDigMine.clientDigingX,gDigMine.clientDigingY,lefttime,MINE_TERRAIN_TYPE0)
end

function gDigMine.isNeedDetonatorForDiging(x,y)
    local key = string.format("%d_%d",x,y)
    if gDigMine.data[key] == nil then
        return false
    end

    local dTime = DB.getDigingTimeForMine(gDigMine.data[key])
    local bNum  = DB.getDetonatorCostByMine(gDigMine.data[key])
    --紫金岩需要用雷管才能挖掘
    if dTime == 0 and bNum > 0 then
        return true
    end
    
    return false
end

function gDigMine.getMptFractionStr()
    return string.format("%d/%d",gDigMine.mpt,DB.getMaxMiningPoint(Data.getCurVip()))
end

function gDigMine.getMineDigingOrUnget(x,y)
    local key = string.format("%d_%d",x,y)
    local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
    if digingOrUngetInfo == nil then
        return 0
    end

    if digingOrUngetInfo.lefttime > gGetCurServerTime() then 
        -- print("coming the status 1")
        return 1 --正在挖掘
    else
        -- print("coming the status 2")
        return 2 --已完成
    end


    return 0
end

--工程操作相关
--添加一个工程的信息
function gDigMine.initProList()
    gDigMine.projList = {}
end
function gDigMine.addProjInfo(_depth, _needTime, _endTime, _status)
    gDigMine.projList[#gDigMine.projList + 1] = {depth = _depth, needTime = _needTime, endTime= _endTime, status = _status }
end

--工程列表排序，完成 > 进行中 > 等待 > 空闲 > 加锁
function gDigMine.sortProjInfo()
    if nil == gDigMine.projList then
        return
    end

    table.sort(gDigMine.projList, function(lProj,rProj)
        if lProj.status == MINE_PROJ_STATUS_WAIT and lProj.status == rProj.status then
            return lProj.endTime < rProj.endTime
        else
            return lProj.status < rProj.status
        end
    end)
end

function gDigMine.updateNewProj(_depth, _needTime, _endTime, _status)
    if #gDigMine.projList == 0 then
        return
    end

    for i = 1, #gDigMine.projList do
        --找一个空闲的更新
       if gDigMine.projList[i].status == MINE_PROJ_STATUS_FREE then
            gDigMine.projList[i].depth = _depth
            gDigMine.projList[i].needTime = _needTime
            gDigMine.projList[i].endTime = _endTime
            gDigMine.projList[i].status = _status
            break
       end
    end
end

function gDigMine.canNewProj(depth,needTime)
    if depth > gDigMine.maxLightY then
        gShowNotice(gGetCmdCodeWord(CMD_MINING_NEW_PROJ,6))
        return false
    end
    local data = gDigMine.getProjTimeInfoByDepth(depth,needTime)

    if nil ~= data then
        if data.dnum > gDigMine.mpt then
            gConfirmCancel(gGetWords("labelWords.plist","lab_new_proj_pickax_limit",data.dnum,gDigMine.mpt), function()
                Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
            end)
            return false
        elseif data.bnum > Data.getItemNum(ITEM_DETONATOR) then
            gConfirmCancel(gGetWords("labelWords.plist","lab_new_proj_detonator_limit",data.bnum,Data.getItemNum(ITEM_DETONATOR)), function()
                Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
            end)
            return false
        end
    end

    return true
end
--是否可以开矿工包
function gDigMine.canOpenToolItem(id, num)
    if Data.getItemNum(id) < num then
        gShowNotice(gGetCmdCodeWord(CMD_MINING_OPEN_BOX,34))
        return false
    end
    return true
end

--获取需要解锁的工程索引
function gDigMine.getUnlockProjIdx()
    local nums = 0
    for i = 1, #gDigMine.projList do
        if gDigMine.projList[i].status ~= MINE_PROJ_STATUS_LOCK then
            nums = nums + 1
        end
    end
    return nums + 1
end

function gDigMine.getMineItemNum(itemid)
    for key,var in pairs(gDigMine.userMineItems) do
        if var.itemid == itemid then
            return var.num
        end
    end

    return 0
end

function gDigMine.reduceItemNum(id,num)
    for key, var in pairs(gDigMine.userMineItems) do
        if(var.itemid==id)then
            if(var.num < num)then
                gDigMine.userMineItems[key]=nil
            else
                var.num=var.num-num
            end
            return
        end
    end
end

function gDigMine.getMineTwinkleLv(mineType)
    if mineType == MINE_COPPER_INTACT or mineType == MINE_IRON_INTACT or mineType == MINE_SILVER_INTACT or
        mineType == MINE_TIN_INTACT or mineType == MINE_GOLD_INTACT or mineType == MINE_DIAMON_FLASH or
        mineType == MINE_XUANTIE_FLASH or mineType == MINE_RED_GEM_FLASH or mineType == MINE_PURPLE_GEM_FLASH or 
        mineType == MINE_GREEN_GEM_FLASH or mineType == MINE_YELLOW_GEM_FLASH then
        return MINE_TWINKLE1
    elseif mineType == MINE_COPPER_FLASH or mineType == MINE_IRON_FLASH or mineType == MINE_SILVER_FLASH or
        mineType == MINE_TIN_FLASH or mineType == MINE_GOLD_FLASH then
        return MINE_TWINKLE2
    else
        return MINE_TWINKLE0
    end
end

function gDigMine.setstatusFightPos(x, y)
    gDigMine.statusFightPos.x = x
    gDigMine.statusFightPos.y = y
end

function gDigMine.setStatueLv(lv)
    gDigMine.statusLv = lv
end

function gDigMine.addStatusPosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.statusPosInfo[key] = 1
end

function gDigMine.removeStatusPosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.statusPosInfo[key] = nil
end

function gDigMine.getStatueCount()
    return table.count(gDigMine.statusPosInfo)
end

function gDigMine.getAStatueInfo()
    for key,value in pairs(gDigMine.statusPosInfo) do
        return key
    end
end

function gDigMine.initMiningProSetting()
    gDigMine.miningProjSetting = {}
    for _,value in pairs(miningproject_db) do
        local id = value.id
        gDigMine.miningProjSetting[id] = {}
        gDigMine.miningProjSetting[id].depth = value.depth
        gDigMine.miningProjSetting[id].rewardItems = string.split(value.rids ,";")
        local timeTable = string.split(value.time ,";")
        local minTable  = string.split(value.min ,";")
        local maxTable  = string.split(value.max ,";")
        local dnumTable = string.split(value.dnum ,";")
        local bnumTable = string.split(value.bnum ,";")
        for idx, timeValue in pairs(timeTable) do
            local timeInt = toint(timeValue)
            gDigMine.miningProjSetting[id][idx] = {}
            gDigMine.miningProjSetting[id][idx].time = toint(timeValue)
            gDigMine.miningProjSetting[id][idx].min = toint(minTable[idx])
            gDigMine.miningProjSetting[id][idx].max = toint(maxTable[idx])
            gDigMine.miningProjSetting[id][idx].dnum = toint(dnumTable[idx])
            gDigMine.miningProjSetting[id][idx].bnum = toint(bnumTable[idx])
        end
    end
end
--TODO 
gDigMine.initMiningProSetting()

function gDigMine.getMiningProDepth(depthIdx)
    local settingInfo = gDigMine.miningProjSetting[depthIdx]
    if  settingInfo == nil then
        return nil
    end

    return settingInfo.depth
end

function gDigMine.getMiningProRewards(depthIdx)
    local settingInfo = gDigMine.miningProjSetting[depthIdx]
    if  settingInfo == nil then
        return nil
    end

    return settingInfo.rewardItems
end

function gDigMine.getMiningProSetting(depthIdx,timeIdx)
    local settingInfo = gDigMine.miningProjSetting[depthIdx]
    if  settingInfo == nil then
        return nil
    end

    return settingInfo[timeIdx]
end

function gDigMine.getProjTimeInfoByDepth(depth,needTime)
    for key,value in pairs(gDigMine.miningProjSetting) do
        if value.depth == depth then
            for timeKey,timeInfo in pairs(value) do
                if timeInfo.time == needTime then
                    return timeInfo,toint(key),toint(timeKey)
                end
            end
        end
    end
    return nil,nil,nil
end

function gDigMine.createMineSprite(texPath)
    local sprite = nil
    if cc.SpriteFrameCache:getInstance():getSpriteFrame(texPath) ~= nil then
       sprite = cc.Sprite:createWithSpriteFrameName(texPath)
    else
       sprite = cc.Sprite:create(texPath)
    end
    return sprite
end

function gDigMine.setMinAndMaxLightX(x)
    if x > gDigMine.maxLightX then
        gDigMine.maxLightX = x
    end

    if x < gDigMine.minLightX then
        gDigMine.minLightX = x
    end
end

function gDigMine.setMaxLightY(y)
    if y > gDigMine.maxLightY then
        gDigMine.maxLightY = y
    end
end

function gDigMine.checkEmpty(x, y)
    local key1 = string.format("%d_%d",x - 1,y)
    local key2 = string.format("%d_%d",x + 1,y)
    local key3 = string.format("%d_%d",x, y - 1)
    local key4 = string.format("%d_%d",x, y + 1)

    if (nil ~= gDigMine.data[key1] and gDigMine.data[key1] == MINE_TERRAIN_TYPE0) or
       (nil ~= gDigMine.data[key2] and gDigMine.data[key2] == MINE_TERRAIN_TYPE0) or 
       (nil ~= gDigMine.data[key3] and gDigMine.data[key3] == MINE_TERRAIN_TYPE0) or 
       (nil ~= gDigMine.data[key4] and gDigMine.data[key4] == MINE_TERRAIN_TYPE0) then
        return true
    end

    return false
end

function gDigMine.addExInfo(idx,exInfo)
    gDigMine.exInfoList[idx] = exInfo
end

function gDigMine.addExAllInfo(_id,_num)
    table.insert(gDigMine.exAllInfo, {id=_id,num=_num})
end

function gDigMine.getExchangeBoxStatus()
    if gDigMine.exAllStatus == MINE_EX_BOX_STATUS3 then --已开
        return MINE_EX_BOX_STATUS3
    end

    local finish = true
    for key,value in pairs(gDigMine.exInfoList) do
        if value.num < value.maxnum then
            finish = false
        end
    end

    if finish then
        return MINE_EX_BOX_STATUS2
    else
        return MINE_EX_BOX_STATUS1
    end
end

function gDigMine.setMptTime(mptTime)
    gDigMine.mptTime = mptTime
    if gDigMine.mptRecoverTime == 0 then
        if gDigMine.mpt < DB.getMaxMiningPoint(Data.getCurVip()) then
            -- print("mptTime is:",(DB.getMiningPointCheckTime() - (gGetCurServerTime() - gDigMine.mptTime)))
            gDigMine.mptRecoverTime = DB.getMiningPointCheckTime() + gDigMine.mptTime
            -- print("mptTime is:",gGetCurServerTime() - gDigMine.mptTime)
            Data.mptTime = gDigMine.mptTime
        else
            gDigMine.mptRecoverTime = 0
        end
    elseif gDigMine.mptRecoverTime ~= 0 then
        --有更新value
        if (gDigMine.oldMpt ~= gDigMine.mpt) or (gDigMine.oldMpt == gDigMine.mpt and gDigMine.mpt < DB.getMaxMiningPoint(Data.getCurVip())) then
            --如果矿镐耐久还没有满
            if gDigMine.mpt < DB.getMaxMiningPoint(Data.getCurVip()) then
                gDigMine.mptRecoverTime = DB.getMiningPointCheckTime() + gDigMine.mptTime
                Data.mptTime = gDigMine.mptTime
            else
                gDigMine.mptRecoverTime = 0
            end
        else
            gDigMine.mptRecoverTime = 0
        end
        gDispatchEvt(EVENT_ID_MINING_RETIME)
    end
end

function gDigMine.setMptRecoverTime(recoverTime)
    gDigMine.mptRecoverTime = recoverTime
end

function gDigMine.getMptRecoverTime()
    return gDigMine.mptRecoverTime
end

function gDigMine.setMptByReTime(mpt)
    gDigMine.oldMpt = gDigMine.mpt
    gDigMine.mpt = mpt
end

function gDigMine.processSendInitMsg(mineAtlasCallback)
    Data.mptTime = gGetCurServerTime()
    Net.sendSystemRetime(2)
    Net.mineAtlasCallback = mineAtlasCallback
    if gDigMine.getInit() then
        Net.sendMiningInfo(0,false)
    else
        Net.sendMiningInfo(0,true)
    end
end

function gDigMine.getMiningProSettingByValue(depth,time)

    for key,value in pairs(gDigMine.miningProjSetting) do
        if value.depth == depth then
            for _,timeValue in pairs(gDigMine.miningProjSetting[key]) do
                if timeValue.time == time then
                    return timeValue
                end
            end
        end
    end

    return nil
end

function gDigMine.setMermaidBuyLeftTime(lefttime)
    gDigMine.mermaidBuyLeftTime = lefttime
end

function gDigMine.getMermaidBuyLeftTime()
    return gDigMine.mermaidBuyLeftTime
end

function gDigMine.setBlackMarketLeftTime(lefttime)
    gDigMine.blackMarketLeftTime = lefttime
end

function gDigMine.getBlackMarketLeftTime()
    return gDigMine.blackMarketLeftTime
end

function gDigMine.addTorpedoExploderMine(_x, _y, _mineType, _id, _num)
    -- print("gDigMine.addTorpedoExploderMine id is:",_id," mineType is:",_mineType)
    local effMine = { x=_x, y=_y, mineType=_mineType, id=_id, num=_num }
    table.insert(gDigMine.torpedoExploderMines,effMine)
end


function gDigMine.ClearTorpedoExploderMine()
    gDigMine.torpedoExploderMines = {}
end

function gDigMine.setTorpedoExploderMines()
    -- gDigMine.torpedoExploderMines
    gDigMine.torpedoExploderMines = {{x=1,y=20,itemid=0}, {x=1,y=19,itemid=60},  {x=1,y=18,itemid=60}, {x=1,y=17,itemid=0},
                                     {x=-1,y=20,itemid=0}, {x=-1,y=19,itemid=0},  {x=-1,y=18,itemid=0}, {x=-1,y=17,itemid=0}}
end

function gDigMine.getTorpedoExploderMineID(x,y)
    local mineInfo = nil
    for i = 1, #gDigMine.torpedoExploderMines do
        mineInfo = gDigMine.torpedoExploderMines[i]
        if mineInfo.x  == x + gDigMine.xOriRange / 2 - 1 and mineInfo.y == y then
            return mineInfo.id
        end
    end
    return 0
end

function gDigMine.isEventTerrain(x ,y)
    local terrainType = gDigMine.getMineTypeByPos(x,y)
    
    if terrainType == nil then
        return false
    end

    if terrainType >= MINE_EVENT1 and terrainType <= MINE_EVENT9 then
        return true
    end

    return false
end

function gDigMine.setEventTerrainPos(x, y)
    gDigMine.eventTerrainPos.x = x
    gDigMine.eventTerrainPos.y = y
end

function gDigMine.setLuckyWheelTurnNums(nums)
    gDigMine.luckyWheelTurnNums = nums
end

function gDigMine.getLuckyWheelTurnNums()
    return gDigMine.luckyWheelTurnNums
end

function gDigMine.setEvent2ExtraInfo(oriPrice,disPrice)
    gDigMine.event2ExtraInfo.oriPrice = oriPrice
    gDigMine.event2ExtraInfo.disPrice = disPrice
end

function gDigMine.addLuckyWheelItem(item)
    table.insert(gDigMine.luckyWheelItems, item)
end

function gDigMine.getLuckyWheelIdxByID(id)
    for key,item in pairs(gDigMine.luckyWheelItems) do
        if item.id == id then
            return key
        end 
    end

    return -1
end

function gDigMine.clearLuckyWheelItems()
    gDigMine.luckyWheelItems = {}
end

function gDigMine.clearLuckyWheelDisruptItems()
    gDigMine.luckyWheelDisruptItems = {}
    gDigMine.luckyWheelDisruptItemsIdx = {}
end

function gDigMine.resetLuckyWheelItem(idx)
    gDigMine.luckyWheelItems[idx].id = 0
    gDigMine.luckyWheelItems[idx].num = 0
end

function gDigMine.setLuckyWheelLeftTime(time)
    gDigMine.luckyWheelLeftTime = time
end

function gDigMine.getLuckyWheelLeftTime()
    return gDigMine.luckyWheelLeftTime
end

function gDigMine.setLuckyWheelTurnIdx(idx)
    gDigMine.luckyWheelTurnIdx = idx
end

function gDigMine.getLuckyWheelTurnIdx()
    return gDigMine.luckyWheelTurnIdx
end

function gDigMine.noEffectedByTorpedo(mineType)
    if mineType >= MINE_STATUE or mineType == MINE_TERRAIN_TYPE4 
        or mineType == MINE_TERRAIN_TYPE5 then
        return true
    end

    return false
end

function gDigMine.setBlackTradeID(id)
    gDigMine.blackTradeID = id
end

function gDigMine.getBlackTradeID()
    return gDigMine.blackTradeID
end

function gDigMine.canTradeForTarget(oriID,dstID)
    if dstID >= ITEM_DIAMOND and dstID <= ITEM_YELLOW_GEM and oriID >= ITEM_RED_CRYSTAL and oriID ~= ITEM_STATUE then
        return false
    end

    return true
end

function gDigMine.disruptLuckyWheelItems()
    gDigMine.luckyWheelDisruptItems,gDigMine.luckyWheelDisruptItemsIdx = math.disruptTable(gDigMine.luckyWheelItems)
end

function gDigMine.resetLuckyWheelDisruptItem(idx)
    gDigMine.luckyWheelDisruptItems[idx].id = 0
    gDigMine.luckyWheelDisruptItems[idx].num = 0
end

function gDigMine.clearEvent9ExchangeList()
    gDigMine.event9ExchangeList = {}
end

function gDigMine.addEvent9ExchangeItem(item)
    table.insert(gDigMine.event9ExchangeList, item)
end

function gDigMine.getEvent9ExchangeItemNum(itemid)
    for _, item in pairs(gDigMine.event9ExchangeList) do
        if item.id == itemid then
            return item.num
        end
    end
    return 0
end

function gDigMine.setPickaxSupplementStall(stall)
    gDigMine.pickaxSupplementStall = stall
end

function gDigMine.getPickaxSupplementStall()
    return gDigMine.pickaxSupplementStall
end

function gDigMine.setPickaxSupplementNums(nums)
    gDigMine.pickaxSupplementNums = nums
end

function gDigMine.getPickaxSupplementNums()
    return gDigMine.pickaxSupplementNums
end

function gDigMine.addMineEvent2PosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.mineEvent2PosInfo[key] = 1
end

function gDigMine.removeMineEvent2PosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.mineEvent2PosInfo[key] = nil
end

function gDigMine.getMineEvent2Count()
    return table.count(gDigMine.mineEvent2PosInfo)
end

function gDigMine.getAMineEvent2Info()
    for key,value in pairs(gDigMine.mineEvent2PosInfo) do
        return key
    end
end

function gDigMine.addMineEvent3PosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.mineEvent3PosInfo[key] = 1
end

function gDigMine.removeMineEvent3PosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.mineEvent3PosInfo[key] = nil
end

function gDigMine.getMineEvent3Count()
    return table.count(gDigMine.mineEvent3PosInfo)
end

function gDigMine.getAMineEvent3Info()
    for key,value in pairs(gDigMine.mineEvent3PosInfo) do
        return key
    end
end

function gDigMine.addMineEvent9PosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.mineEvent9PosInfo[key] = 1
end

function gDigMine.removeMineEvent9PosInfo(_x,_y)
    local key = string.format("%d_%d",_x, _y)
    gDigMine.mineEvent9PosInfo[key] = nil
end

function gDigMine.getMineEvent9Count()
    return table.count(gDigMine.mineEvent9PosInfo)
end

function gDigMine.getAMineEvent9Info()
    for key,value in pairs(gDigMine.mineEvent9PosInfo) do
        return key
    end
end

function gDigMine.getMineEventCount(event)
    if event == MINE_EVENT2 then
        return table.count(gDigMine.mineEvent2PosInfo)
    elseif event == MINE_EVENT3 then
        return table.count(gDigMine.mineEvent3PosInfo)
    elseif event == MINE_EVENT9 then
        return table.count(gDigMine.mineEvent9PosInfo)
    else
        return 0
    end
end

function gDigMine.getMineEventInfo(event)
    if event == MINE_EVENT2 then
        return gDigMine.getAMineEvent2Info()
    elseif event == MINE_EVENT3 then
        return gDigMine.getAMineEvent3Info()
    elseif event == MINE_EVENT9 then
        return gDigMine.getAMineEvent9Info()
    else
        return nil
    end
end


function gDigMine.hasUngetMineInList(x, y)
    local oriX = x + gDigMine.xOriRange / 2 - 1
    local key = string.format("%d_%d", x, y)
    local value = gDigMine.digingOrUngetInfoList[key]
    if value ~= nil then
        if value.lefttime <= gGetCurServerTime() then
            return true
        end
    end
    -- gShowNotice(gGetWords("mineWords.plist","txt_no_unget_mine"))
    return false
end

function gDigMine.removeUngetMineInList(x, y)
    local posKey = string.format("%d_%d",x,y)
    for key,var in pairs(gDigMine.digingOrUngetInfoList ) do
        if key == posKey then
           gDigMine.digingOrUngetInfoList[key] = nil
        end
    end
    gDigMine.refreshBusyMiners()
end

function gDigMine.hasUngetMineInPos(x,y)
    local posKey = string.format("%d_%d",x,y)
    for key, var in pairs(gDigMine.digingOrUngetInfoList) do
        if key == posKey and var.lefttime <= gGetCurServerTime() and var.itemid ~= MINE_TERRAIN_TYPE0 then
            return true
        end
    end
    return false
end

function gDigMine.getDigingOrUngetMineCount()
    return table.count(gDigMine.digingOrUngetInfoList)
end

function gDigMine.isMinersLimit()
    local count = table.count(gDigMine.digingOrUngetInfoList)
    if gDigMine.miner > count then
        return false
    else
        return true
    end

    -- if gDigMine.digingOrUngetInfo.itemid ~= nil and gDigMine.digingOrUngetInfo.itemid ~= MINE_TERRAIN_TYPE0 and
    --    gDigMine.digingOrUngetInfo.lefttime ~= nil then
    --     return true
    -- end
    -- return false
end

function gDigMine.getOneDigingOrUngetMine()
    local canGetKey = ""
    local digingKey = ""
    for key, var in pairs(gDigMine.digingOrUngetInfoList) do
        if var.itemid ~= MINE_TERRAIN_TYPE0 then
            if var.lefttime <= gGetCurServerTime() then
                canGetKey = key
            else
                digingKey = key
            end
        end
    end

    if canGetKey ~= "" then
        return canGetKey
    else
        return digingKey
    end
end

function gDigMine.hasDigingOrUngetInPos(posKey)
    if gDigMine.digingOrUngetInfoList[posKey] ~= nil then
        return true
    end

    return false
end

function gDigMine.isExistPosTable(x,y,digingOrUngetPosTable)
    for _,var in pairs(digingOrUngetPosTable) do
        if var.x == x and var.y == y then
            return true
        end
    end

    return false
end

function gDigMine.setDigingOrUngetInfoList(_x,_y,_lefttime,_itemid)
    local key = string.format("%d_%d",_x,_y)
    gDigMine.digingOrUngetInfoList[key] = {lefttime=_lefttime, itemid=_itemid}
end

function gDigMine.isLimitToDig(x,y)
    if table.count(gDigMine.digingOrUngetInfoList) == 0 then
        return false
    end
    if gDigMine.isMinersLimit() then
        local hasUnget = false
        local hasTolerant = false
        for key,var in pairs(gDigMine.digingOrUngetInfoList) do
            if var.lefttime ~= -1 and var.lefttime < gGetCurServerTime() and var.itemid ~= MINE_TERRAIN_TYPE0 then
                hasUnget = true
            elseif (math.abs(var.lefttime - gGetCurServerTime()) <= 1 and var.itemid == MINE_TERRAIN_TYPE0) or
                ((var.lefttime == -1 or math.abs(var.lefttime - gGetCurServerTime()) <= 1) and var.itemid ~= MINE_TERRAIN_TYPE0) then
                hasTolerant = true
            end
        end

        if hasTolerant then
            return true
        end

        if hasUnget then
            -- local idx = 1
            -- local logStr = ""
            -- for key,var in pairs(gDigMine.digingOrUngetInfoList) do
            --     logStr = "gDigMine.isLimitToDig"..idx.."is:"..key.."itemid is:"..var.itemid.."lefttime is:"..var.lefttime.."curServerTime is:"..gGetCurServerTime()
            --     gAccount:sendLuaError(logStr,function()
            --     end)
            --     idx=idx+1
            -- end
            gShowNotice(gGetWords("mineWords.plist","txt_has_unget_mine"))
        else
            -- local idx = 1
            -- local logStr = ""
            -- for key,var in pairs(gDigMine.digingOrUngetInfoList) do
            --     logStr = "gDigMine.isLimitToDig"..idx.."is:"..key.."itemid is:"..var.itemid.."lefttime is:"..var.lefttime.."curServerTime is:"..gGetCurServerTime()
            --     gAccount:sendLuaError(logStr,function()
            --     end)
            --     idx=idx+1
            -- end
            gShowNotice(gGetWords("mineWords.plist","txt_has_not_free_miner"))
        end
        return true
    end

    return false
end

function gDigMine.setBusyMiners(busyMiner)
    gDigMine.busyMiner = busyMiner
end

function gDigMine.getBusyMiners()
    return gDigMine.busyMiner
end

function gDigMine.refreshBusyMiners()
    gDigMine.setBusyMiners(table.count(gDigMine.digingOrUngetInfoList))
    gDispatchEvt(EVENT_ID_MINING_BUY_MINERS)
end

function gDigMine.hasDigingMineInPos(x, y)
    local posKey = string.format("%d_%d",x,y)
    for key, var in pairs(gDigMine.digingOrUngetInfoList) do
        if key == posKey and var.lefttime > gGetCurServerTime() then
            return true
        end
    end
    return false
end
