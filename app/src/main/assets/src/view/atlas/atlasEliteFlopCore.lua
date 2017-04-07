--精英副本翻牌奖励 - 逻辑端
CoreAtlas = {}
EliteFlop = {}
CoreAtlas.EliteFlop = EliteFlop

gEliteFlopTab = {
	-- 精英副本翻牌信息列表
    -- mid(int)
    -- sid(int)
	-- num(int) 翻牌次数
	-- endtime(int) 结束时间
	-- list(vector) 已翻牌的索引 (1~5 对应 表中的道具1~5)
} 

EliteFlop.bShowEliteFlop = false --首次三星通过
EliteFlop.bNeedEliteFlop = false
EliteFlop.bWaitLevelUp = false -- 翻牌完成后是否升级
EliteFlop.mid = 0
EliteFlop.sid = 0

function Net.sendAtlasFlop(mid,sid)
    EliteFlop.mid = mid
    EliteFlop.sid = sid

 	local media=MediaObj:create()
    media:setByte("mid", mid)
    media:setInt("sid", sid)
    Net.sendExtensionMessage(media, CMD_ATLAS_FLOP)
end 

function Net.rec_atlas_flop(evt)
	local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    EliteFlop.updateFlopTabByObj(obj:getObj("flopobj"))
    gDispatchEvt(EVENT_ID_REC_ELITE_FLOP)
end

-- 初始化每个关卡的翻牌信息
function EliteFlop.initFlopTab(data)
    if Module.isClose(SWITCH_ELITE_FLOP) == true then
        return
    end

	gEliteFlopTab = {}
	data=tolua.cast(data,"MediaObj")
	local starList=data:getArray("star")
	if(starList)then
        starList=tolua.cast(starList,"MediaArray")
        for i=0, starList:count()-1 do
        	local starObj=tolua.cast(starList:getObj(i),"MediaObj")
            local flopObj = starObj:getObj("flopobj")

            if flopObj then
            	local item = {}
                item.mid=starObj:getByte("cid")
                item.sid=starObj:getInt("sid")
            	item.num = flopObj:getInt("fnum")
            	item.endtime = flopObj:getInt("endtime")
            	item.list = flopObj:getIntArray("fidlist")
            	table.insert(gEliteFlopTab,item)
                --print("初始化翻牌信息 "..item.mid.."-"..item.sid..":"..item.endtime)
            end
        end
    end
    
end

-- 更新关卡的翻牌信息
-- data {mid,sid,num,endtime,list}
function EliteFlop.updateFlopTab(data)
    for k,v in pairs(gEliteFlopTab) do
        if v.mid == data.mid and v.sid == data.sid then
            v.num = data.num
            v.list = data.list
            return
        end
    end

    table.insert(gEliteFlopTab,data)
end

function EliteFlop.updateFlopTabByObj(obj)
    local item = {}
    item.mid = EliteFlop.mid
    item.sid =  EliteFlop.sid
    item.num = obj:getInt("fnum")
    item.endtime = obj:getInt("endtime")
    item.list = obj:getIntArray("fidlist")
    EliteFlop.updateFlopTab(item)
end

-- 战斗完是否显示首次三星翻牌
function EliteFlop.setBattleFlop(obj)
    if Module.isClose(SWITCH_ELITE_FLOP) == true then
        return
    end
    -- type = 1 精英副本
    if Net.sendAtlasEnterParam.type ~= 1 then
        EliteFlop.bNeedEliteFlop = false
        return
    end

    EliteFlop.bNeedEliteFlop = obj:containsKey("flopinfo")
    local flopObj = obj:getObj("flopinfo")

    -- 过后再升级
    EliteFlop.bWaitLevelUp = false

    if EliteFlop.bNeedEliteFlop == true
        and Scene.needLevelup == true 
        and Scene.showLevelUp == true then
        Scene.needLevelup = false
        Scene.showLevelUp = false
        EliteFlop.bWaitLevelUp = true
    end

    if EliteFlop.bNeedEliteFlop == true 
        and flopObj then
        EliteFlop.mid = Net.sendAtlasEnterParam.mapid
        EliteFlop.sid = Net.sendAtlasEnterParam.stageid
        EliteFlop.updateFlopTabByObj(flopObj)
    end

    EliteFlop.checkShowFlop()
    
end

function EliteFlop.checkShowFlop()
    -- body
    if EliteFlop.bNeedEliteFlop == true then
        EliteFlop.bNeedEliteFlop = false
        EliteFlop.bShowEliteFlop = true
        return true
    end

    return false
end

-- 战斗完首次三星显示翻牌奖励
function EliteFlop.showFlopPanel()
    if EliteFlop.bShowEliteFlop == false then
        return false
    end

    EliteFlop.bShowEliteFlop = false

    local mid = EliteFlop.mid
    local sid = EliteFlop.sid

    local info = EliteFlop.getFlopInfo(mid,sid)
    if info == nil then
        return
    end

    --弹出翻牌奖励 map
    Panel.popUpUnVisible(PANEL_ATLAS_ELITE_FLOP,nil,nil,true)

    return true
end

function EliteFlop.closeFlopPanel() 
    if EliteFlop.bWaitLevelUp == true then
        EliteFlop.bWaitLevelUp = false
        Scene.needLevelup = true
        Scene.showLevelUp = true
    end

    -- 副本入口 倒计时
    local layer = Panel.getPanelByType(PANEL_ATLAS_ENTER)
    if layer then
        EliteFlop.showFlopInAtlasInfoLayer(layer)
    end

    -- 战斗结算 倒计时
    layer = Panel.getPanelByType(PANEL_ATLAS_FINAL)
    if layer then
        EliteFlop.showTimeLeftInFinal(layer)
    end

    -- 三星翻牌副本列表 刷新item获取状态
    layer = Panel.getPanelByType(PANEL_ATLAS_ELITE_FLOP_TAB)
    if layer then
        local mid = EliteFlop.mid
        local sid = EliteFlop.sid
        layer:refreshAtlasStatus(mid,sid)
    end
end

function EliteFlop.getFlopInfo(mid,sid)
    -- body
    for k,v in pairs(gEliteFlopTab) do
        if v.mid == mid and v.sid == sid then
            return v
        end
    end

    return nil
end

function EliteFlop.getFlopEndTime(mid,sid)
    -- 获取翻牌剩余时间
    local data = EliteFlop.getFlopInfo(mid,sid)
    if data 
        and data.endtime > 0
        and data.endtime > gGetCurServerTime()
        and data.num < 5 then
            return data.endtime
    end

    return 0
end

function EliteFlop.createTimeLeftLayer(layer,timeLayerName,endtime)
    -- 创建剩余时间倒计时
    local time_layer = layer:getNode(timeLayerName)
    if time_layer then
        if Module.isClose(SWITCH_ELITE_FLOP) == true then
            time_layer:setVisible(false)
            return
        end
        if endtime > 0 then
            time_layer:setVisible(true)
        else
            time_layer:setVisible(false)
        end

        if endtime > 0 then
            local function updateTime() 
                local time = endtime - gGetCurServerTime()
                if time < 0 then
                    time = 0

                    layer:unscheduleUpdateEx()
                    time_layer:setVisible(false)
                end
                layer:setLabelString("txt_flop_time",gParserHourTime(time))
            end

            layer:scheduleUpdate(updateTime,1)
        else 
            layer:unscheduleUpdateEx()
        end
    end
end

function EliteFlop.showFlopInAtlasInfoLayer(atlasInfoLayer)
    -- 在副本入口显示翻牌倒计时
    if atlasInfoLayer.type ~= 1 then
        return
    end

    local mid = atlasInfoLayer.mapid
    local sid = atlasInfoLayer.stageid
    CoreAtlas.EliteFlop.mid = mid
    CoreAtlas.EliteFlop.sid = sid
    local endtime = EliteFlop.getFlopEndTime(mid,sid)
    EliteFlop.createTimeLeftLayer(atlasInfoLayer,"elite_flop_layer",endtime)
end

function EliteFlop.showTimeLeftInFinal(layer)
    -- 在战斗结果页面显示翻牌倒计时
    if Net.sendAtlasEnterParam.type ~= 1 then
        return
    end
    local mid = CoreAtlas.EliteFlop.mid
    local sid = CoreAtlas.EliteFlop.sid
    local endtime = EliteFlop.getFlopEndTime(mid,sid)
    EliteFlop.createTimeLeftLayer(layer,"elite_flop_layer",endtime)
end

function EliteFlop.getDataItems(mid,sid)
    for key, var in pairs(stageflop_db) do
        if(var.map_id== mid and var.stage_id == sid)then
            local items = {}
            table.insert(items,{itemid = var.item1,num = var.num1})
            table.insert(items,{itemid = var.item2,num = var.num2})
            table.insert(items,{itemid = var.item3,num = var.num3})
            table.insert(items,{itemid = var.item4,num = var.num4})
            table.insert(items,{itemid = var.item5,num = var.num5})
            return items
        end
    end
    return nil
end

function EliteFlop.atlasSortFunc(tab_source,tab_target,sortfunc)
    -- 副本排序插入
    if table.getn(tab_source) > 1 then
        table.sort(tab_source,sortfunc)
    end

    for i = 1,table.getn(tab_source) do
        local item = tab_source[i]
        table.insert(tab_target,item)
    end
end

function EliteFlop.sortFlopAtlasTab()
    if Module.isClose(SWITCH_ELITE_FLOP) == true then
        return {}
    end
    -- 翻牌副本排序：三星未翻牌－没全部翻完－可以进入未获得三星(type:1-2-3)
    local type = 1 -- 精英副本
    local maxMapid=gAtlas["maxMap"..type]
    local maxStageid=gAtlas["maxStage"..type]
    --print("已通过的最大副本 :"..maxMapid.."-"..maxStageid)
    -- 可进入，未获得三星的副本
    local pass_unflop_tab = {} --三星未翻牌
    local pass_flop_tab = {} --没全部翻完
    local unpass_tab = {} --可以进入未获得三星
    for mid=1,maxMapid do
        -- 获取每章最大关卡
        local maxSId = 0
        local chapter = DB.getChapterById(mid,1)
        if chapter then
            maxSId = chapter.stagenum
        end
        if mid == maxMapid then
            maxSId = maxStageid
        end
        for sid=1,maxSId do
            if EliteFlop.getFlopInfo(mid,sid) == nil then
                local item = {mid = mid,sid = sid,endtime = 0,num = 0}
                table.insert(unpass_tab,item)
            end
        end
    end

    for k,v in pairs(gEliteFlopTab) do
        --print("endtime:"..v.endtime.." servertime:"..gGetCurServerTime())
        if v.endtime > gGetCurServerTime() then
            local item = {mid = v.mid,sid = v.sid,endtime = v.endtime,num = v.num,list = v.list}
            if v.num == 0 then
                table.insert(pass_unflop_tab,item)
            elseif v.num < 5 then
                table.insert(pass_flop_tab,item)
            end
        end
    end

    -- 副本按照从大到小排序
    local sortfunc = function(item1,item2)
        if item1.mid < item2.mid then
            return true;
        elseif item1.mid == item2.mid then
            return item1.sid < item2.sid
        end
        return false;
    end

    local tab = {}
    EliteFlop.atlasSortFunc(pass_unflop_tab,tab,sortfunc)
    EliteFlop.atlasSortFunc(pass_flop_tab,tab,sortfunc)
    EliteFlop.atlasSortFunc(unpass_tab,tab,sortfunc)

    return tab
end