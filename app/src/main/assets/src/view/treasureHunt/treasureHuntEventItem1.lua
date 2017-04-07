local TreasureHuntEventItem1=class("TreasureHuntEventItem1",UILayer)

function TreasureHuntEventItem1:ctor(eventWord, eventInfo)
    self:init("ui/ui_treasure_hunt_event_item1.map")
    self:getNode("txt_info"):setString(eventWord)
    self:getNode("txt_info"):layout()
    local txtInfoContentSize = self:getNode("txt_info"):getContentSize()
    local bgContentSize = self:getNode("bg"):getContentSize()
    local itemContentSize = self:getContentSize()
    bgContentSize.height = txtInfoContentSize.height + 4
    self:getNode("bg"):setContentSize(bgContentSize)
    itemContentSize.height = bgContentSize.height + 4
    self:setContentSize(itemContentSize)
    self:getNode("bg"):setPosition(itemContentSize.width / 2, itemContentSize.height / 2)
    self:getNode("txt_info"):setPosition(5, bgContentSize.height / 2)
    self.eventInfo = eventInfo
end


function TreasureHuntEventItem1:onTouchEnded(target,touch, event)
    if target.touchName == "bg" then
        if self.eventInfo.lurkid ~= 0 then
            Net.sendCrotreFrecInfo(self.eventInfo.id)
        end
    end
end

return TreasureHuntEventItem1