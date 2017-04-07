local TreasureHuntNoticePanel=class("TreasureHuntNoticePanel",UILayer)

function TreasureHuntNoticePanel:ctor()
    self:init("ui/ui_treasure_hunt_notice.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:initScrollInfo()
end

function TreasureHuntNoticePanel:initScrollInfo()
    local drawNum = 6
    for key,var in pairs(gTreasureHunt.noticeList) do
        local noticeItem = TreasureHuntNoticeItem.new()
        if drawNum > 0 then
            drawNum = drawNum - 1
            noticeItem:setData(var,key)
        else
            noticeItem:setLazyData(var,key)
        end
        self:getNode("scroll"):addItem(noticeItem)
    end
    self:getNode("scroll"):layout(false)
end

function TreasureHuntNoticePanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_up" then
        
    elseif target.touchName=="btn_speaker" then

    end
end

function TreasureHuntNoticePanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    
    Scene.clearLazyFunc("treasureHuntNoticeItem")
end

function TreasureHuntNoticePanel:events()
    return {
        EVENT_ID_TREASURE_HUNT_NOTICE_OPER,
    }
end

function TreasureHuntNoticePanel:dealEvent(event, param)
    if event == EVENT_ID_TREASURE_HUNT_NOTICE_OPER then
        if param > 0 then
            self:getNode("scroll"):removeItemByIndex(param - 1)
            self:getNode("scroll"):layout(false)
        elseif param == 0 then
            local noticeItem = TreasureHuntNoticeItem.new()
            local size  = #gTreasureHunt.noticeList
            noticeItem:setData(gTreasureHunt.noticeList[size],size)
            self:getNode("scroll"):addItem(noticeItem)
            self:getNode("scroll"):layout(false)
            self:getNode("scroll"):moveItemByIndex(self:getNode("scroll"):getSize() - 1)
        end
    end
end

return TreasureHuntNoticePanel