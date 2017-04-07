local HuntItem=class("HuntItem",UILayer)

local huntMonsterItem = 1
local huntTreasureItem = 2
local huntLootFoodItem = 3
local huntItemMax = 99

local itemWaitNone = 0
local itemWaitOpen = 1
local itemOpenCountDown = 2
local itemDoingCountDown =3 

function HuntItem:ctor(itemInfo,idx,parentPanel)
    self:init("ui/ui_team_enter_item.map")
    self.parentPanel = parentPanel
    self:initPanel(itemInfo)
end

function HuntItem:initPanel(itemInfo)
    self.type = itemInfo.huntId
    self:changeTexture("icon", string.format("images/ui_team/enter_%d.png", self.type))

    if not self:initUnlockStatus() then
        self:getNode("layout_info"):setVisible(false)
        return
    end

    if itemInfo.interval < 0 then
        self.state = itemDoingCountDown
    elseif itemInfo.interval - 30 * 60 < 0 then
        self.state = itemOpenCountDown
    else
        self.state = itemWaitOpen
    end
--self.state = itemWaitOpen
    if self.state == itemWaitNone then
        self:getNode("layout_info"):setVisible(false)
    elseif self.state == itemWaitOpen then
        self:getNode("fla_fighting"):setVisible(false)
        self:getNode("fla_time"):setVisible(false)
        self:setLabelString("txt_info",self:getOpenDaysFomateStrByType())
        self:getNode("layout_info"):layout()
        self:getNode("layout_info"):setVisible(true)
    elseif self.state == itemOpenCountDown then
        self.endTime = itemInfo.interval + gGetCurServerTime()
        self:initSchedule()
        self:getNode("fla_fighting"):setVisible(false)
        self:getNode("fla_time"):setVisible(true)
        self:setLabelString("txt_info",gGetWords("labelWords.plist", "lab_open_quick_time", gParserHourTime(self.endTime - gGetCurServerTime()))) 
        self:getNode("layout_info"):layout()
        self:getNode("layout_info"):setVisible(true)
    elseif self.state == itemDoingCountDown then
        if self.type == huntMonsterItem and Data.worldBossInfo.status == 0 then
            self:getNode("fla_fighting"):setVisible(false)
            self:getNode("fla_time"):setVisible(false)
            self:setLabelString("txt_info",self:getOpenDaysFomateStrByType())
            self:getNode("layout_info"):layout()
            self:getNode("layout_info"):setVisible(true)
        else
            self.endTime = itemInfo.interval + itemInfo.duration + gGetCurServerTime()
            self:initSchedule()
            self:getNode("fla_fighting"):setVisible(true)
            self:getNode("fla_time"):setVisible(false)
            self:setLabelString("txt_info",gGetWords("labelWords.plist", "lab_end_lefttime", gParserHourTime(self.endTime - gGetCurServerTime())))
            self:getNode("layout_info"):layout()
            self:getNode("layout_info"):setVisible(true)
        end
    end
end

function HuntItem:initSchedule()
    self:scheduleUpdate(function(dt)
        if self.endTime > gGetCurServerTime() then
            if self.state == itemDoingCountDown then
                self:setLabelString("txt_info",gGetWords("labelWords.plist", "lab_end_lefttime", gParserHourTime(self.endTime - gGetCurServerTime())))
            elseif self.state == itemOpenCountDown then
                self:setLabelString("txt_info",gGetWords("labelWords.plist", "lab_open_quick_time", gParserHourTime(self.endTime - gGetCurServerTime())))
            end
        else
            if self.state == itemDoingCountDown then
                self:unscheduleUpdateEx()
                self:getNode("fla_fighting"):setVisible(false)
                self:getNode("fla_time"):setVisible(false)
                self:setLabelString("txt_info",self:getOpenDaysFomateStrByType())
                self:getNode("layout_info"):layout()


            elseif self.state == itemOpenCountDown then
                self.state = itemDoingCountDown
                local duration = self:getItemDuration()
                self.endTime = duration + gGetCurServerTime()
                self:getNode("fla_fighting"):setVisible(true)
                self:getNode("fla_time"):setVisible(false)
                self:setLabelString("txt_info",gGetWords("labelWords.plist", "lab_end_lefttime", gParserHourTime(self.endTime - gGetCurServerTime())))
                self:getNode("layout_info"):layout()
            end
        end
    end, 1)
end

function HuntItem:onUILayerExit()
    self:unscheduleUpdateEx()
end

function HuntItem:onTouchMoved(target, touch, event)
    if self.parentPanel.isMove then
        return
    end

    local offsetX=touch:getDelta().x
    if math.abs(offsetX) > 5 and not self.parentPanel.isMove then
        self.parentPanel.isMove = true
        local isRight = offsetX > 0
        self.parentPanel:scrollItem(isRight)
    end
end

function HuntItem:onTouchEnded(target,touch, event)
    if self.parentPanel.isMove then
        return
    end

    if target.touchName=="icon" then
        if self.type == huntMonsterItem then
            if Unlock.isUnlock(SYS_WORLD_BOSS) then
                Net.sendWorldBossInfo(0)
            end
        elseif self.type == huntTreasureItem then
            if Unlock.isUnlock(SYS_TREASURE_HUNT) then
                if DB.getTreasureHuntOpenLv() <= Data.getCurLevel() then
                    Net.sendCroTreHallInfo()
                else
                    gShowNotice(gGetCmdCodeWord(CMD_CROSS_TREASURE_HALL_INFO,13))
                end
            end
        elseif self.type == huntLootFoodItem then
            if Unlock.isUnlock(SYS_LOOT_FOOD) then
                Panel.popUp(PANEL_FOODFIGHT_MAIN)
            end
        end
    end
end

function HuntItem:getOpenDaysFomateStrByType()
    if self.type == huntMonsterItem then
        local sWord = gGetWords("worldBossWords.plist","open_time")
        --gGetOpenDaysFormateStr(DB.getOpenDayOfWorldBoss(),DB.getOpenTimeOfWorldBoss())
        --sWord = sWord.." "..gGetOpenDaysFormateStr(DB.getClientParam("WORLD_BOSS_NEW_DAY"),DB.getClientParam("WORLD_BOSS_NEW_TIME"))
        --return gGetOpenDaysFormateStr(DB.getOpenDayOfWorldBoss(),DB.getOpenTimeOfWorldBoss())
        return sWord
    elseif self.type == huntTreasureItem then
        return gGetOpenDaysFormateStr(DB.getOpenDayOfTreasureHunt(),DB.getOpenTimeOfTreasureHunt())
    elseif self.type == huntLootFoodItem then
        return gGetOpenDaysFormateStr(gLootfoodBeginDay,gLootfoodBeginHour)
    end

    return ""
end

function HuntItem:getItemDuration()
    if self.type == huntMonsterItem then
        local data = nil
        if isNewBossCurDay() then
            data = string.split(DB.getClientParam("WORLD_BOSS_NEW_TIME"),";")
        else
            data = string.split(DB.getOpenTimeOfWorldBoss(),";")
        end
        return toint(data[3])
    elseif self.type == huntTreasureItem then
        local data = string.split(DB.getOpenTimeOfTreasureHunt(),";")
        return toint(data[3])
    elseif self.type == huntLootFoodItem then
        local detailTime = gGetWeekOneTimeByCur(gLootfoodBeginDay,gLootfoodBeginHour)
        local endtime = gGetWeekOneTimeByCur(gLootfoodEndDay,gLootfoodEndHour)
        return endtime-detailTime
    end

    return 0
end

function HuntItem:initUnlockStatus()
    local contentSize = self:getNode("icon"):getContentSize()
    local unLock = true
    if self.type == huntMonsterItem and not Unlock.isUnlock(SYS_WORLD_BOSS,false) then
        unLock = false
    elseif self.type == huntTreasureItem and not Unlock.isUnlock(SYS_TREASURE_HUNT,false) then
        unLock = false
    elseif self.type == huntLootFoodItem and not Unlock.isUnlock(SYS_LOOT_FOOD,false) then
        unLock = false
    end

    if not unLock then
        self:getNode("layout_rock"):setVisible(true)
    else
        self:getNode("layout_rock"):setVisible(false)
    end

    return unLock
end

function HuntItem:refreshItemInfo(itemInfo)
    self:initPanel(itemInfo)
end

return HuntItem