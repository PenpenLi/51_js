local FamilyStageLastRankItem=class("FamilyStageLastRankItem",UILayer)

function FamilyStageLastRankItem:ctor(idx, info)
    self:init("ui/ui_family_stage_last_rank_item.map")
    self:setLabelString("txt_rank", idx)
    Icon.setHeadIcon(self:getNode("icon"),info.icon)
    self:setLabelString("txt_name",info.name)
    self:setLabelString("txt_post", gGetWords("familyMenuWord.plist","title"..info.post))
    self:setLabelString("txt_reward", info.num)
end

return FamilyStageLastRankItem