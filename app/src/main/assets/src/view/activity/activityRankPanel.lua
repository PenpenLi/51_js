local ActivityRankPanel=class("ActivityRankPanel",UILayer)

function ActivityRankPanel:ctor(data)
    self:init("ui/ui_hd_rank.map") 
    self.curData=data
    self:getNode("title_word"):setVisible(false)
    self:getNode("txt_rank"):setVisible(false)
    self:getNode("layout_time"):setVisible(false)
    Net.sendActivityRank(data.actId,true)
end

function ActivityRankPanel:events( ... )
    return {
        EVENT_ID_GET_ACTIVITY_10,
        EVENT_ID_GET_ACTIVITY_10_REC,
    }
end

function ActivityRankPanel:dealEvent(event, param)
    if event == EVENT_ID_GET_ACTIVITY_10 then
        self:setData(param)
    elseif event == EVENT_ID_GET_ACTIVITY_10_REC then
        self:refreshData(param)
    end      
end

function ActivityRankPanel:setData(param)
    self:setRTFString("lab_help", param.desc)

    self:getNode("scroll"):clear()
    for key, value in pairs(param.list) do -- Data.activityExchangeData
        local item=ActivityRankItem.new(self.curData, param.myrank)
        item:setEndTime(param.updatetime)
        item:setData(key,value)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    self.myrank = param.myrank
    local isOver = param.updatetime <= gGetCurServerTime()
    self:setRankLabelShow(isOver)
    self:getNode("txt_rank"):setVisible(true)
    self:showUpdateTime(param.updatetime)

    self:setTitleWord()
end

function ActivityRankPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do
        if item.curActData.actId == param.actId and item.curData.idx == param.detId then
            item:setGotStatus()
            break
        end
    end
end

function ActivityRankPanel:onUILayerExit()
    self:unscheduleUpdateEx()
end

function ActivityRankPanel:showUpdateTime(endTime)
    self:getNode("layout_time"):setSortByPosFlag(false)
    self.endTime = endTime

    self.leftDay = 0
    self.reLayout = true
    self.preTimeStatue = 0
    self.preLeftDay = 0
    if(self.endTime > gGetCurServerTime())then
        local function updateTime()
            self.leftDay = gGetDayByLeftTime(self.endTime - gGetCurServerTime())
            -- print("self.leftDay = "..self.leftDay)
            if(self.leftDay > 0)then
                if(self.leftDay ~= self.preLeftDay)then
                    self.preLeftDay = self.leftDay
                    self:replaceLabelString("txt_day",self.leftDay)
                    self:getNode("txt_day"):setVisible(true)
                end
                self.preTimeStatue = 1
            else
                self:getNode("txt_day"):setVisible(false)
                if(self.preTimeStatue ~= 2)then
                    self.reLayout = true
                end
                self.preTimeStatue = 2
            end
            if(self.endTime>=gGetCurServerTime())then
                self:setLabelString("txt_refresh_time2", gParserHourTime(self.endTime - gGetCurServerTime() - self.leftDay*24*60*60))
                local time = math.max(self.endTime-gGetCurServerTime(),0)
                if (time==0) then
                    self.endTime = 0
                    self:setOverTime()
                    self.reLayout = true
                end
            end
            if(self.reLayout)then
                self.reLayout = false
                self:getNode("layout_time"):layout()
            end
        end
        self:scheduleUpdate(updateTime,1)
        self:getNode("layout_time"):layout()
        self:getNode("layout_time"):setVisible(true)
        self:resetAdaptNode()
    else
        self:setOverTime()
    end
end

function ActivityRankPanel:setOverTime()
    self:setRankLabelShow(true)
    self:getNode("txt_over_time"):setVisible(true)
    self:getNode("layout_time"):setVisible(false)
    for key, item in pairs(self:getNode("scroll").items) do
        item:refreshStatus()
    end
end

function ActivityRankPanel:onTouchEnded(target)
    if target.touchName=="btn_rank"then
        self:popRankPanel() 
    elseif target.touchName=="btn_go"then
        self:gotoMap() 
    end
end

function ActivityRankPanel:popRankPanel()
    if self.curData.type == ACT_TYPE_11 then
        Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_LEVEL)
    elseif self.curData.type == ACT_TYPE_13 then
        Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_ARENA)
    elseif self.curData.type == ACT_TYPE_27 then
        Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_PET)
    elseif self.curData.type == ACT_TYPE_12 then
        Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_FAMILY)
    end
end

function ActivityRankPanel:gotoMap()
    if self.curData.type == ACT_TYPE_11 then
        Panel.popUp(PANEL_ATLAS)
    elseif self.curData.type == ACT_TYPE_13 then
        if Unlock.isUnlock(SYS_ARENA) then
             gEnterArena()
        end
    elseif self.curData.type == ACT_TYPE_27 then
        if Unlock.isUnlock(SYS_PET_TOWER) then
            Net.sendPetAtlasInfo()
        end
    elseif self.curData.type == ACT_TYPE_12 then
        if Unlock.isUnlock(SYS_FAMILY) then
            if gMainBgLayer ~= nil then
                gMainBgLayer:onFamily()
            end
        end
    end
end

function ActivityRankPanel:setTitleWord()
    self:getNode("title_word"):setVisible(true)
    if self.curData.type == ACT_TYPE_11 then
        self:changeTexture("title_word", "images/ui_word/congji.png")
    elseif self.curData.type == ACT_TYPE_13 then
        self:changeTexture("title_word", "images/ui_word/c-wudao.png")
    elseif self.curData.type == ACT_TYPE_27 then
        self:changeTexture("title_word", "images/ui_word/c-dixia.png")
    elseif self.curData.type == ACT_TYPE_12 then
        self:changeTexture("title_word", "images/ui_word/c-qxzl.png")
    end
end

function ActivityRankPanel:setRankLabelShow(isOver)
    local plistFile = ""
    local key = ""
    if not isOver then
        if self.curData.type ~= ACT_TYPE_12 then
            plistFile = "arenaWords.plist"
            key = "12"
        else
            plistFile = "familyWords.plist"
            key = "txt_rank_family"
        end
        if(self.myrank<=0)then
            self:setLabelString("txt_rank", gGetWords(plistFile, key, gGetWords("arenaWords.plist","lab_no")))
        else
            self:setLabelString("txt_rank", gGetWords(plistFile, key, self.myrank))
        end
    else
        local isMapWords = false
        if self.curData.type ~= ACT_TYPE_12 then
            isMapWords = true
            plistFile = "ui_hd_rank.plist"
            key = "7"
        else
            plistFile = "familyWords.plist"
            key = "txt_fin_rank_family"
        end

        if(self.myrank<=0)then
            if isMapWords then
                self:setLabelString("txt_rank", gGetMapWords(plistFile, key, gGetWords("arenaWords.plist","lab_no")))
            else
                self:setLabelString("txt_rank", gGetWords(plistFile, key, gGetWords("arenaWords.plist","lab_no")))
            end
        else
            if isMapWords then
                self:setLabelString("txt_rank", gGetMapWords(plistFile, key, self.myrank))
            else
                self:setLabelString("txt_rank", gGetWords(plistFile, key, self.myrank))
            end
        end
    end
end


return ActivityRankPanel