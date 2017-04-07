
local FamilyExpRankItem=class("FamilyExpRankItem",UILayer)

function FamilyExpRankItem:ctor(data)
    self:init("ui/ui_family_exprank_item.map");

    Icon.setHeadIcon(self:getNode("icon_bg"),data.icon)
    self:setLabelString("txt_name",data.uname);
    self:replaceLabelString("txt_lv",data.level);
    self:setLabelString("txt_title",gGetWords("familyMenuWord.plist","title"..data.type));
    self:setLabelString("txt_power",data.power);
    self:setLabelAtlas("txt_value",data.data);
    -- self:setLabelString("txt_value",data.data);
    local iType = data.type;
    if(iType == 1 or iType == 2 or iType == 3)then
      self:getNode("txt_title"):setColor(cc.c3b(255,0,0));
    elseif(iType == 10)then
      self:getNode("txt_title"):setColor(cc.c3b(73,85,198));
    else  
      self:getNode("txt_title"):setColor(cc.c3b(161,70,63));
    end

end

return FamilyExpRankItem
