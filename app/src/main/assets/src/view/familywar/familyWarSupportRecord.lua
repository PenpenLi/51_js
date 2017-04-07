local FamilyWarSupportRecord=class("FamilyWarSupportRecord",UILayer)

function FamilyWarSupportRecord:ctor()
    self:init("ui/ui_family_war_support_record.map");

end

function FamilyWarSupportRecord:onTouchEnded(target)
 
    if(target.touchName=="btn_view")then
        Net.sendFamilyTeamInfo(self.curData.id)
    end  
end

function FamilyWarSupportRecord:setData(data,index)  
    self.idx = index;
    self.curData=data;


    self:setLabelString("txt_name",data.sName);
    self:setLabelString("txt_rank",data.iRank);
    -- self:setLabelString("txt_tip",data.sDec);
    self:replaceLabelString("txt_exp",data.iExp);
    self:replaceLabelString("txt_power",data.iPower);
    self:setLabelString("txt_mas_name",data.sMasName);
    self:setLabelString("txt_level",getLvReviewName("Lv.")..data.iLevel);
    -- self:changeTexture("icon","images/ui_family/bp_icon_"..data.icon..".png");
    Icon.setFamilyIcon(self:getNode("icon"),data.icon,data.id);
 
    self:getNode("me_panel"):setVisible(gFamilyInfo.familyId==data.id)
end

 

return FamilyWarSupportRecord