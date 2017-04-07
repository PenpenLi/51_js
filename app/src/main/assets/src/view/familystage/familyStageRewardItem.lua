local FamilyStageRewardItem=class("FamilyStageRewardItem",UILayer)

function FamilyStageRewardItem:ctor(rewardInfo)
    self:init("ui/ui_family_stage_reward_item.map")
    self:changeTexture("icon","images/ui_word/family_p"..(rewardInfo.post)..".png")
    local rewardItems = cjson.decode(rewardInfo.reward)

    for i = 1, 4 do
        if rewardItems[i] ~= nil then
            self:getNode("icon"..i):setVisible(true)
            Icon.setDropItem(self:getNode("icon"..i),rewardItems[i].id,rewardItems[i].num)
        else
            self:getNode("icon"..i):setVisible(false)
        end
    end

    self:getNode("layout_items"):layout()
end

return FamilyStageRewardItem