local FamilyOtherFamilyInfoPanel=class("FamilyOtherFamilyInfoPanel",UILayer)

function FamilyOtherFamilyInfoPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_family_other_info.map")

    self:setLabelString("txt_name",data.sName);
    self:setLabelString("txt_name_lead",data.sMasName);
    self:setLabelString("txt_count","("..data.iMemNum.."/"..Data.getFamilyMaxMem(data.iLevel)..")");
    self:setLabelString("txt_level",getLvReviewName("Lv.")..data.iLevel);
    -- self:changeTexture("icon","images/ui_family/bp_icon_"..data.icon..".png");
    Icon.setFamilyIcon(self:getNode("icon"),data.icon,data.id);
    self:setLabelAtlas("txt_rank",data.iRank);
    self:setLabelString("txt_des",data.sDec);
    self:setLabelString("txt_total_fexp",data.totalFExp);
end


function FamilyOtherFamilyInfoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    end
end


return FamilyOtherFamilyInfoPanel