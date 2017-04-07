local TreasureHuntEnterPanel=class("TreasureHuntEnterPanel",UILayer)
--TODO,持续时间,走配制
local durationTime = 30 * 60
local maxRightHuntStage = 8
local maxLeftHuntStage = 12
local STAGE_INTERVAL_TIME = 15
local MAX_STAGE_ID = 7
local HunterStageStep = {
    step1 = 0,
    step2 = 1,
    step3 = 2,
    step4 = 3,
    step5 = 4,
    step6 = 5,
    step7 = 6,
    step8 = 7,
    step9 = 8,
    step10 = 9,
    step11 = 10,
}

function TreasureHuntEnterPanel:ctor(isCreate)
    self:init("ui/ui_team_room_enter.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:initTopHeadInfo()
    self.isSelfMap = (gTreasureHunt.detailMapInfo.member1.id == Data.getCurUserId()) or 
                      (gTreasureHunt.detailMapInfo.member2.id == Data.getCurUserId())
    self:getNode("event_scroll"):clear()
    self:getNode("event_scroll"):setCheckChildrenVisibleEnable(false)
    self:initState()
    self:initTerrainInfo()
    if isCreate then
        self:showCreateEventInfo()
    end
end

function TreasureHuntEnterPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif string.find(target.touchName, "icon_ambush") ~= nil then
        local iconIdx = toint(string.sub(target.touchName, string.len("icon_ambush") + 1))
        self:onChooseTerrain(iconIdx)
    elseif string.find(target.touchName, "icon_terrain") ~= nil then
        local iconIdx = toint(string.sub(target.touchName, string.len("icon_terrain") + 1))
        self:onChooseTerrain(iconIdx)
    elseif target.touchName == "btn_left_choose" then
        if gTreasureHunt.detailMapInfo.captainId ~= Data.getCurUserId() then
            gShowNotice(gGetWords("treasureHuntWord.plist", "choose_path_limit"))
            return
        end
        Net.sendCrotreCroad(gTreasureHunt.detailMapInfo.groupId, gTreasureHunt.detailMapInfo.roomId, TerrainRoadType.left)
    elseif target.touchName == "btn_right_choose" then
        if gTreasureHunt.detailMapInfo.captainId ~= Data.getCurUserId() then
            gShowNotice(gGetWords("treasureHuntWord.plist", "choose_path_limit"))
            return
        end
        Net.sendCrotreCroad(gTreasureHunt.detailMapInfo.groupId, gTreasureHunt.detailMapInfo.roomId, TerrainRoadType.right)
    elseif target.touchName == "btn_event_detail" then
        Panel.popUp(PANEL_TREASURE_HUNT_PROGRESS_DETAIL,1, self.curStage)
    end
end

function TreasureHuntEnterPanel:initState()
    self:setHuntFightTimeAndSteps()
    self:initStageInfo()
    self:hideRoadStagePos(gTreasureHunt.detailMapInfo.road)
    if (gTreasureHunt.detailMapInfo.createTime + DB.getTreasureHuntFightTime1() > gGetCurServerTime() or
        gTreasureHunt.detailMapInfo.road == TerrainRoadType.none) then
        self.panelState = TreasureTeamStatus.wait_choose_path
        -- print("TreasureHuntEnterPanel:initState waitStarTime is:",DB.getTreasureHuntFightTime1())
        
        if self.isSelfMap then
            self:setLabelString("txt_choose_lefttime", gParserMinTime(DB.getTreasureHuntFightTime1() + gTreasureHunt.detailMapInfo.createTime - gGetCurServerTime()))
            self:getNode("layout_time"):layout()
            if gTreasureHunt.detailMapInfo.road == 0 then
                self:getNode("btn_left_choose"):setVisible(true)
                self:getNode("btn_right_choose"):setVisible(true)
                self:getNode("txt_choose_lefttime_other"):setVisible(false)
                self:getNode("txt_choose_lefttime"):setVisible(true)
                if gTreasureHunt.detailMapInfo.captainId == Data.getCurUserId() then
                    self:getNode("title_choose_tip1"):setVisible(true)
                    self:getNode("title_choose_tip2"):setVisible(false)
                    self:getNode("title_choose_tip3"):setVisible(false)
                else
                    self:getNode("title_choose_tip1"):setVisible(false)
                    -- local tipPre = gGetWords("treasureHuntWord.plist", "tip_choose_road_tip2_1")
                    -- self:setLabelString("title_choose_tip2", gGetMapWords("ui_team_room_enter.plist","4",tipPre))
                    self:getNode("title_choose_tip2"):setVisible(true)
                    self:getNode("title_choose_tip3"):setVisible(false)
                end
                self:getNode("layout_choose"):layout()
            else
                self:getNode("btn_left_choose"):setVisible(true)
                self:getNode("btn_right_choose"):setVisible(true)
                self:changeChooseBtnTexture()
                self:getNode("txt_choose_lefttime_other"):setVisible(false)
                self:getNode("txt_choose_lefttime"):setVisible(true)
                self:getNode("title_choose_tip1"):setVisible(false)
                local tipPre = gGetWords("treasureHuntWord.plist", "tip_choose_road_tip2_2",gTreasureHunt.detailMapInfo.road)
                -- self:setLabelString("title_choose_tip2", gGetMapWords("ui_team_room_enter.plist","4",tipPre))
                self:getNode("title_choose_tip2"):setVisible(true)
                self:getNode("title_choose_tip3"):setVisible(false)
                self:getNode("layout_choose"):layout()
            end
            self:getNode("layer_choose_tip"):setVisible(true)
        else
            -- self:setLabelString("txt_choose_lefttime_other", gGetMapWords("ui_team_room_enter.plist","6", gParserMinTime(DB.getTreasureHuntFightTime1() + gTreasureHunt.detailMapInfo.createTime - gGetCurServerTime())))
            self:getNode("btn_left_choose"):setVisible(false)
            self:getNode("btn_right_choose"):setVisible(false)
            self:getNode("txt_choose_lefttime_other"):setVisible(true)
            self:getNode("txt_choose_lefttime"):setVisible(true)
            self:getNode("title_choose_tip1"):setVisible(false)
            self:getNode("title_choose_tip2"):setVisible(false)
            self:getNode("title_choose_tip3"):setVisible(false)
            self:getNode("layout_choose"):layout()
            self:getNode("layer_choose_tip"):setVisible(true)
        end
        self:initWaitChooseScheduler()
        self:getNode("icon_pos0"):setVisible(true)
        self:changeTexture("icon_map1", string.format("images/icon/item/%d.png", gTreasureHunt.detailMapInfo.member1.treasureMap))
        self:changeTexture("icon_map2", string.format("images/icon/item/%d.png", gTreasureHunt.detailMapInfo.member2.treasureMap))
    else 
        self:getNode("btn_left_choose"):setVisible(false)
        self:getNode("btn_right_choose"):setVisible(false)
        self:getNode("layer_choose_tip"):setVisible(false)
        self:getNode("icon_pos0"):setVisible(false)
        self.panelState = TreasureTeamStatus.finding
        if self.curStage >= 0 then
            self:initPassedEventInfo()
        end
        self:initHuntFightScheduler()
    end
end

function TreasureHuntEnterPanel:initTopHeadInfo()
    for i = 1, 2 do
        local memberInfo = gTreasureHunt.detailMapInfo["member"..i]
        self:setLabelString("txt_medal"..i, memberInfo.safelv)
        self:getNode("layout_medal"..i):layout()
        self:getNode("icon_captain"..i):setVisible(memberInfo.isCaptain)
        self:setLabelString("txt_name"..i, memberInfo.name)
        self:setLabelString("txt_power"..i, memberInfo.power)
        Icon.setHeadIcon(self:getNode("icon_head"..i), memberInfo.icon)
    end
end

function TreasureHuntEnterPanel:initTerrainInfo()
    for i = 1, MAX_TREASURE_STAGE do
        local terrrainInfo = gTreasureHunt.detailMapInfo.terrainInfos[i]
        self:setTerrainImage(terrrainInfo.type, i)
        self:setTerrainWeather(terrrainInfo.weather, i)
        self:setTerrainTime(terrrainInfo.time, i)
        self:setTerrainAmbushId(terrrainInfo.ambushId, terrrainInfo.ambushIcon, terrrainInfo.ambushName, i)
    end
end

function TreasureHuntEnterPanel:setTerrainImage(type, idx)
    local imagePath = string.format("images/ui_team/dx_%d.png",type)
    self:changeTexture("icon_terrain"..idx, imagePath)
end

function TreasureHuntEnterPanel:setTerrainWeather(type, idx)
    loadFlaXml("ui_tianqi")
    local flaWeather = nil
    if type==TerrainWeatherType.sunshine then
        self:getNode("icon_weather"..idx):setVisible(false)
        return
    elseif type==TerrainWeatherType.rain then
        flaWeather = gCreateFla("ui_tianqi_xiayu",1)
    elseif type==TerrainWeatherType.snowstorm then
        flaWeather = gCreateFla("ui_tianqi_xiaxue",1)
    elseif type==TerrainWeatherType.lightning then
        flaWeather = gCreateFla("ui_tianqi_shandian",1)
    elseif type==TerrainWeatherType.sand then
        flaWeather = gCreateFla("ui_tianqi_fengsha",1)
    end
    self:replaceNode("icon_weather"..idx,flaWeather)

    local imagePath = string.format("images/ui_team/weather_%d.png",type)
    self:changeTexture("icon_weather"..idx, imagePath)
end

function TreasureHuntEnterPanel:setTerrainTime(type, idx)
    local imagePath = string.format("images/ui_team/daytime_%d.png",type)
    self:changeTexture("icon_time"..idx, imagePath)
end

function TreasureHuntEnterPanel:setTerrainAmbushId(id,icon,name,idx)
    if icon == 0 then
        self:getNode("icon_ambush"..idx):removeChildByTag(1)
        self:getNode("icon_ambush"..idx):removeChildByTag(99)
        self:getNode("icon_ambush"..idx):removeChildByTag(100)
        self:getNode("icon_ambush"..idx):setTexture("images/ui_public1/ka_d1.png")
        self:getNode("txt_ambush_name"..idx):setVisible(false)
    else
        Icon.setHeadIcon(self:getNode("icon_ambush"..idx), icon)
        if id == Data.getCurUserId() then
            local me = cc.Sprite:create("images/ui_family/ME.png")
            me:setTag(99)
            local contentSize = self:getNode("icon_ambush"..idx):getContentSize()
            local meContentSize = me:getContentSize()
            gAddChildByAnchorPos(self:getNode("icon_ambush"..idx), me, cc.p(0,0), cc.p(meContentSize.width / 2, contentSize.height - meContentSize.height / 2))
        else
            self:getNode("icon_ambush"..idx):removeChildByTag(99)
        end
        self:setLabelString("txt_ambush_name"..idx, name)
        self:getNode("txt_ambush_name"..idx):setVisible(true)
    end
end

function TreasureHuntEnterPanel:onUILayerExit()
    self:unscheduleUpdateEx()
end
-- TODO,需要统一结束时间？
function TreasureHuntEnterPanel:setStageStepsByTime(elapseTime)
    local step = math.floor(elapseTime / STAGE_INTERVAL_TIME)
    local posName = ""
    local prePosName = ""
    if gTreasureHunt.detailMapInfo.road == TerrainRoadType.right then
        if step >= 0 and step <= maxRightHuntStage then
            posName = string.format("icon_pos1_%d",step)
        end
        
        if step > 0 and step <= maxRightHuntStage+1 then
           prePosName = string.format("icon_pos1_%d",step - 1)
        end
    elseif gTreasureHunt.detailMapInfo.road == TerrainRoadType.left then
        if step >= 0 and step <= maxLeftHuntStage then
            posName = string.format("icon_pos2_%d",step)
        end
        
        if step > 0 and step <= maxLeftHuntStage+1 then
           prePosName = string.format("icon_pos2_%d",step - 1)
        end
    end

    if posName ~= "" then
        self:getNode(posName):setVisible(true)    
    end
    
    if prePosName ~= "" then
        self:getNode(prePosName):setVisible(false)
    end
end

function TreasureHuntEnterPanel:hideRoadStagePos(path)
    for i = 0, self.totalRightSteps - 1 do
        self:getNode(string.format("icon_pos1_%d",i)):setVisible(false)
    end

    for i = 0, self.totalLeftSteps - 1 do
        self:getNode(string.format("icon_pos2_%d",i)):setVisible(false)
    end
    -- if path == TerrainRoadType.none then
    --     for i = 0, self.totalRightSteps - 1 do
    --         self:getNode(string.format("icon_pos1_%d",i)):setVisible(false)
    --     end

    --     for i = 0, self.totalLefttSteps - 1 do
    --         self:getNode(string.format("icon_pos2_%d",i)):setVisible(false)
    --     end
    -- elseif path == TerrainRoadType.right then
    --     for i = 0, self.totalRightSteps - 1 do
    --         self:getNode(string.format("icon_pos1_%d",i)):setVisible(false)
    --     end 
    -- elseif path == TerrainRoadType.left then
    --     for i = 0, self.totalLefttSteps - 1 do
    --         self:getNode(string.format("icon_pos2_%d",i)):setVisible(false)
    --     end
    -- end
end

function TreasureHuntEnterPanel:onChooseTerrain(idx)
    if idx <= 0 or idx > MAX_STAGE_ID then
        return
    end

    local terrainInfo = gTreasureHunt.detailMapInfo.terrainInfos[idx]
    if nil == terrainInfo then
        return
    end

    local isSelfMap = (gTreasureHunt.detailMapInfo.member1.id == Data.getCurUserId()) or 
                      (gTreasureHunt.detailMapInfo.member2.id == Data.getCurUserId())

    Panel.popUp(PANEL_TREASURE_HUNT_AMBUSH_DETAIL, terrainInfo, isSelfMap)
end

function TreasureHuntEnterPanel:events()
    return {
        EVENT_ID_TREASURE_HUNT_BEGIN_FIGHT,
        EVENT_ID_TREASURE_HUNT_CHECK_STAGE,
        EVENT_ID_TREASURE_HUNT_CHOOSE_ROAD,
        EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH,
        EVENT_ID_TREASURE_HUNT_FIGHT_RET,
    }
end

function TreasureHuntEnterPanel:dealEvent(event, param)
    if event == EVENT_ID_TREASURE_HUNT_BEGIN_FIGHT then
        self:setBeginFight()
    elseif event == EVENT_ID_TREASURE_HUNT_CHECK_STAGE then
        self:updateStageNeedCheck()
    elseif event == EVENT_ID_TREASURE_HUNT_CHOOSE_ROAD then
        self:refreshByChooseRoad()
    elseif event == EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH then
        self:refreshAmbushInfo(param)
    elseif event == EVENT_ID_TREASURE_HUNT_FIGHT_RET then
        Panel.popUp(PANEL_TREASURE_HUNT_STAGE_RECORD)
    end
end

function TreasureHuntEnterPanel:setBeginFight()
    self:getNode("btn_left_choose"):setVisible(false)
    self:getNode("btn_right_choose"):setVisible(false)
    self:getNode("layer_choose_tip"):setVisible(false)
    self:getNode("icon_pos0"):setVisible(false)
    local elapseTime = gGetCurServerTime() - gTreasureHunt.detailMapInfo.createTime - DB.getTreasureHuntFightTime1()
    self:setStageStepsByTime(elapseTime)
    self.panelState = TreasureTeamStatus.finding
    self:setHuntFightTimeAndSteps()
    self:initHuntFightScheduler()
end

function TreasureHuntEnterPanel:initWaitChooseScheduler()
    self:unscheduleUpdateEx()
    self:scheduleUpdate(function (dt)
        if gTreasureHunt.detailMapInfo.createTime + DB.getTreasureHuntFightTime1() > gGetCurServerTime() then
            -- if self.isSelfMap then
            self:setLabelString("txt_choose_lefttime", gParserMinTime(DB.getTreasureHuntFightTime1() + gTreasureHunt.detailMapInfo.createTime - gGetCurServerTime()))
            self:getNode("layout_time"):layout()
            -- else
            --     self:setLabelString("txt_choose_lefttime_other", gGetMapWords("ui_team_room_enter.plist","6", gParserMinTime(DB.getTreasureHuntFightTime1() + gTreasureHunt.detailMapInfo.createTime - gGetCurServerTime())))
            -- end
        else
            if self.panelState == TreasureTeamStatus.wait_choose_path then
                local groupId = gTreasureHunt.detailMapInfo.groupId
                local roomId = gTreasureHunt.detailMapInfo.roomId
                Net.sendCrossTreasureFightResult(groupId,roomId)
                self:unscheduleUpdateEx()
            end
        end
    end, 1) 
end

function TreasureHuntEnterPanel:initHuntFightScheduler()
    self:unscheduleUpdateEx()
    self:scheduleUpdate(function (dt)
        local leftTime = gTreasureHunt.detailMapInfo.endTime - gGetCurServerTime()
        if leftTime <= 0 then
            self:unscheduleUpdateEx()
        else
            self:setFightStage(leftTime)
        end
    end, 1)
end

function TreasureHuntEnterPanel:setHuntFightTimeAndSteps()
    local road = gTreasureHunt.detailMapInfo.road
    self.totalRightSteps = maxRightHuntStage
    self.totalLeftSteps = maxLeftHuntStage
    self.totalCostTime = 0
    self.totalFightTime = 0
    local time2 = DB.getTreasureHuntFightTime2()
    local time3 = DB.getTreasureHuntFightTime3()
    if road == TerrainRoadType.right then
        self.totalFightTime = 3 * time2
        self.totalCostTime = self.totalFightTime + time3
        self.totalSteps = maxRightHuntStage
    elseif road == TerrainRoadType.left then
        self.totalFightTime = 5 * time2
        self.totalCostTime = self.totalFightTime + time3
        self.totalSteps = maxLeftHuntStage
    end
end

function TreasureHuntEnterPanel:setFightStage(leftTime)
    local time3 = DB.getTreasureHuntFightTime3()
    local time2 = DB.getTreasureHuntFightTime2()
    local elapseTime = self.totalCostTime - leftTime
    if elapseTime < 0 then
        elapseTime = 0
    end
    local posName = ""
    local prePosName = ""
    local road = gTreasureHunt.detailMapInfo.road
    local stageLeftTime = 0
    if leftTime <= time3 then
        if leftTime <= time3 / 2 then
            self.oldStage = self.curStage
            self.curStage = self.totalSteps - 1
            prePosName = string.format("icon_pos%d_%d",road, self.totalSteps - 2)
            posName = string.format("icon_pos%d_%d",road, self.totalSteps - 1)
            stageLeftTime = leftTime
        else
            self.oldStage = self.curStage
            self.curStage = self.totalSteps - 2
            prePosName = string.format("icon_pos%d_%d",road, self.totalSteps - 3)
            posName = string.format("icon_pos%d_%d",road, self.totalSteps - 2)
            stageLeftTime = leftTime - time3 / 2
        end
    else
        self.oldStage = self.curStage
        self.curStage = math.floor(elapseTime * 2 / time2)
        -- print("setFightStage stage is:",stage, " checkStage is:",self.fightCheckStage)
        posName = string.format("icon_pos%d_%d",road, self.curStage)
        if self.curStage > 0 then
            prePosName = string.format("icon_pos%d_%d",road, self.curStage - 1)
        end
        stageLeftTime = time2 / 2 - (elapseTime - self.curStage * time2 / 2)
        print("TreasureHuntEnterPanel:setFightStage stagetLeftTime is:", stageLeftTime)
    end

    local hasRollback = false --是否由于条件不满足回滚
    if self.curStage > self.stageNeedCheck then
        self.curStage = self.stageNeedCheck
        posName = string.format("icon_pos%d_%d",road, self.curStage)
        prePosName = string.format("icon_pos%d_%d",road, self.curStage - 1)
        hasRollback = true
    end

    if self.curStage ~= self.oldStage then
        self:showEventInfoById(road, self.curStage+1)
        if  leftTime <= time3 / 2 and leftTime > 0 then
            if self.isSelfMap then
                gConfirm(gGetWords("treasureHuntWord.plist","txt_finish_hunt"))
            end
        end
    end

    if posName ~= "" then
        self:getNode(posName):setVisible(true)
        if self.curStage % 2 == 0 then
            self:setLabelString(string.format("wait_lefttime%d_%d",road, self.curStage), gParserMinTime(stageLeftTime))
        end 
    end
    
    if prePosName ~= "" then
        self:getNode(prePosName):setVisible(false)
    end
    --发消息查询
    if self.curStage % 2 == 1 and (stageLeftTime <= 1 or hasRollback) then
        Net.sendCrotreFrCheck(gTreasureHunt.detailMapInfo.groupId,gTreasureHunt.detailMapInfo.roomId)
    end
end

function TreasureHuntEnterPanel:initStageInfo()
    if (gTreasureHunt.detailMapInfo.createTime + DB.getTreasureHuntFightTime1() > gGetCurServerTime() or
        gTreasureHunt.detailMapInfo.road == TerrainRoadType.none) then
        self.curStage = -1
        self.oldStage = -1
        self.stageNeedCheck = 1
    else
        local leftTime = gTreasureHunt.detailMapInfo.endTime - gGetCurServerTime()
        local time3 = DB.getTreasureHuntFightTime3()
        local time2 = DB.getTreasureHuntFightTime2()
        local elapseTime = self.totalCostTime - leftTime
        if elapseTime < 0 then
            elapseTime = 0
        end

        local stage = 0
        local stageLeftTime = 0
        if leftTime <= time3 then
            if leftTime <= time3 / 2 then
                self.curStage = self.totalSteps - 1
                self.oldStage = self.totalSteps - 1
            else
                self.curStage = self.totalSteps - 2
                self.oldStage = self.totalSteps - 2
            end
            self.stageNeedCheck = self.totalSteps - 1
        else
            self.curStage = math.floor(elapseTime * 2 / time2)
            self.oldStage = self.curStage
            if self.curStage % 2 == 1 then
                self.stageNeedCheck = self.curStage
            else
                self.stageNeedCheck = self.curStage + 1
            end
        end
    end
end

function TreasureHuntEnterPanel:updateStageNeedCheck()
    if (gTreasureHunt.detailMapInfo.createTime + DB.getTreasureHuntFightTime1() > gGetCurServerTime() or
        gTreasureHunt.detailMapInfo.road == TerrainRoadType.none) then
        self.stageNeedCheck = 1
    else
        self.stageNeedCheck = self.stageNeedCheck + 2
    end
end

function TreasureHuntEnterPanel:showEventInfoById(road, stage)
    local eventInfos = gTreasureHunt.detailMapInfo.eventInfos[stage]
    if nil == eventInfos then
        cc.log(string.format("stage %d has no eventInfo"+stage))
        return
    end
    local hasFight = false
    for i = 1, #eventInfos do
        local eventWord = gTreasureHunt.getTerrainEventInfo(eventInfos[i])
        local item = TreasureHuntEventItem.new(eventWord, eventInfos[i])
        item:setAnchorPoint(cc.p(0,1))
        self:getNode("event_scroll"):addItem(item)
        if eventInfos[i].lurkid ~= 0 then
            hasFight = true
        end
    end
    self:getNode("event_scroll"):layout(false)
    self:getNode("event_scroll"):moveItemByIndex(self:getNode("event_scroll"):getSize() - 1)

    local flaPosName = string.format("fla_pos%d_%d",road, stage - 1)
    if self:getNode(flaPosName) ~= nil then
        self:getNode(flaPosName):setVisible(hasFight)
    end
end

function TreasureHuntEnterPanel:refreshByChooseRoad()
    -- print("TreasureHuntEnterPanel:refreshByChooseRoad")
    if self.isSelfMap then
        if gTreasureHunt.detailMapInfo.captainId == Data.getCurUserId() then
            self:getNode("title_choose_tip1"):setVisible(false)
            self:getNode("title_choose_tip2"):setVisible(false)
            self:getNode("title_choose_tip3"):setVisible(true)
        end

        self:getNode("layout_choose"):layout()
    end
    self:changeChooseBtnTexture()
end

function TreasureHuntEnterPanel:refreshAmbushInfo(param)
    if  gTreasureHunt.detailMapInfo.groupId == param.groupId and
        gTreasureHunt.detailMapInfo.roomId  == param.roomId and
        param.ambushStage ~= 0 then
        self:setTerrainAmbushId(param.ambushId,param.ambushIcon,param.ambushName,param.ambushStage)
    end
end

function TreasureHuntEnterPanel:showCreateEventInfo()
    local count = #gTreasureHunt.detailMapInfo.createEventInfos
    if  count == 0 then
        return
    end

    for key, eventInfo in ipairs(gTreasureHunt.detailMapInfo.createEventInfos) do
        local eventWord = gTreasureHunt.getTerrainEventInfo(eventInfo)
        local item = TreasureHuntEventItem.new(eventWord, eventInfo)
        item:setAnchorPoint(cc.p(0,1))
        self:getNode("event_scroll"):addItem(item)
    end
    self:getNode("event_scroll"):layout(false)
    self:getNode("event_scroll"):moveItemByIndex(count-1)
end

function TreasureHuntEnterPanel:initPassedEventInfo()
    self:showCreateEventInfo()
    for i = 0, self.curStage do
        self:showEventInfoById(gTreasureHunt.detailMapInfo.road, i + 1)
    end
end

function TreasureHuntEnterPanel:changeChooseBtnTexture()
    if gTreasureHunt.detailMapInfo.road == TerrainRoadType.right then
        -- 选中
        self:changeTexture("btn_right_choose", "images/ui_team/jt2.png")
        self:changeTexture("btn_left_choose", "images/ui_team/jt.png")
    elseif gTreasureHunt.detailMapInfo.road == TerrainRoadType.left then
        self:changeTexture("btn_right_choose", "images/ui_team/jt.png")
        self:changeTexture("btn_left_choose", "images/ui_team/jt2.png")
    end
end

return TreasureHuntEnterPanel