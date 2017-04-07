local TipTouchTreasureHuntSpeaker=class("TipTouchTreasureHuntSpeaker",UILayer)

function TipTouchTreasureHuntSpeaker:ctor()
    self:init("ui/tip_touch_treasure_hunt_speaker.map")
    local size = #gTreasureHunt.speakerInfos
    if size == 0 then
        return
    end

    for i = 1,size do
        local item1 = RTFLayer.new(self:getNode("scroll"):getContentSize().width-5)
        item1:setAnchorPoint(cc.p(0,1))
        item1:setDefaultConfig(gFont,20,cc.c3b(0,255,255))
        local txtPre = string.format("%s(%s):",gTreasureHunt.speakerInfos[i].name, gTreasureHunt.speakerInfos[i].severName)
        item1:setString(txtPre)
        item1:layout()
        self:getNode("scroll"):addItem(item1)

        local item2 = RTFLayer.new(self:getNode("scroll"):getContentSize().width-5)
        item2:setAnchorPoint(cc.p(0,1))
        item2:setDefaultConfig(gFont,20,cc.c3b(255,245,140))
        item2:setString(gTreasureHunt.speakerInfos[i].str)
        item2:layout()
        self:getNode("scroll"):addItem(item2)
    end
    self:getNode("scroll"):layout(false)
    self:getNode("scroll"):moveItemByIndex(self:getNode("scroll"):getSize() - 1)
end



function TipTouchTreasureHuntSpeaker:showSpeakerInfo()

end
 
return TipTouchTreasureHuntSpeaker