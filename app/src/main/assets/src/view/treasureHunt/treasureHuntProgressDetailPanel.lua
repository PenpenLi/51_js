local TreasureHuntProgressDetailPanel=class("TreasureHuntProgressDetailPanel",UILayer)
local panelTypeEnter  = 1
local panelTypeRecord = 2
function TreasureHuntProgressDetailPanel:ctor(panelType,curStage)
	-- self.appearType = 1
	self.hideMainLayerInfo = true
    self:init("ui/ui_treasure_hunt_progress_detail.map")
    self.panelType = panelType
    self:initPanel(curStage)
end

function TreasureHuntProgressDetailPanel:onTouchEnded(target)
    if target.touchName=="btn_close"then
    	self:onClose()
    end
end
  
function TreasureHuntProgressDetailPanel:initPanel(curStage)
    self:getNode("scroll"):clear()
    self:getNode("scroll"):setCheckChildrenVisibleEnable(false)
    if self.panelType == panelTypeEnter then
        for _,eventInfo in ipairs(gTreasureHunt.detailMapInfo.createEventInfos) do
            local eventWord = gTreasureHunt.getTerrainEventInfo(eventInfo)
            local item = TreasureHuntEventItem1.new(eventWord, eventInfo)
            item:setAnchorPoint(cc.p(0,1))
            self:getNode("scroll"):addItem(item)
        end

        for i = 0, curStage do
            local eventInfos = gTreasureHunt.detailMapInfo.eventInfos[i + 1]
            for j = 1, #eventInfos do
                local eventWord = gTreasureHunt.getTerrainEventInfo(eventInfos[j])
                local item = TreasureHuntEventItem1.new(eventWord, eventInfos[j])
                item:setAnchorPoint(cc.p(0,1))
                self:getNode("scroll"):addItem(item)
            end
        end

        self:getNode("scroll"):layout(false)
        self:getNode("scroll"):moveItemByIndex(self:getNode("scroll"):getSize() - 1)
    elseif self.panelType == panelTypeRecord then
        if gTreasureHunt.detailRecordInfo.eventInfos == nil then
            return
        end

        for _,eventInfo in ipairs(gTreasureHunt.detailRecordInfo.createEventInfos) do
            local eventWord = gTreasureHunt.getTerrainEventInfo(eventInfo)
            local item = TreasureHuntEventItem1.new(eventWord, eventInfo)
            item:setAnchorPoint(cc.p(0,1))
            self:getNode("scroll"):addItem(item)
        end

        for _,var in pairs(gTreasureHunt.detailRecordInfo.eventInfos) do
            for _,eventInfo in ipairs(var) do
                local eventWord = gTreasureHunt.getTerrainEventInfo(eventInfo)
                local item = TreasureHuntEventItem1.new(eventWord, eventInfo)
                item:setAnchorPoint(cc.p(0,1))
                self:getNode("scroll"):addItem(item)
            end
        end
        self:getNode("scroll"):layout(false)
        self:getNode("scroll"):moveItemByIndex(self:getNode("scroll"):getSize() - 1)
    end
end

function TreasureHuntProgressDetailPanel:events()
    return {
        EVENT_ID_TREASURE_HUNT_FIGHT_RET,
    }
end

function TreasureHuntProgressDetailPanel:dealEvent(event, data)
    if event == EVENT_ID_TREASURE_HUNT_FIGHT_RET then
        Panel.popUp(PANEL_TREASURE_HUNT_STAGE_RECORD)
    end
end

return TreasureHuntProgressDetailPanel