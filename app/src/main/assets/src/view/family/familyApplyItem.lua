local FamilyApplyItem=class("FamilyApplyItem",UILayer)

function FamilyApplyItem:ctor()
   
end

function FamilyApplyItem:initPanel() 
    self:init("ui/ui_family_apply_item.map");
    self:getNode("bg_vip"):setVisible(false)
end

function FamilyApplyItem:onTouchEnded(target)

	print("target name = "..target.touchName);

    if  target.touchName=="btn_agree"then
        self.onAgree(self.curData);
        -- Net.sendFamilyPass(self.curData.uid);
    elseif  target.touchName=="btn_refuse"then
        self.onRefuse(self.curData);
        -- Net.sendFamilyRefuse(self.curData.uid);
    elseif target.touchName == "icon_bg" then
        Net.sendBuddyTeam(self.curData.uid)
    end

end

function FamilyApplyItem:setData(data) 
    self:initPanel();
    self.curData=data;

    self:setLabelString("txt_name",data.sName);
    self:setLabelString("txt_lv",getLvReviewName("Lv.")..data.iLevel);
    Icon.setHeadIcon(self:getNode("icon_bg"),data.iCoat);
    self:setLabelAtlas("txt_vip",data.iVip);
    self:replaceLabelString("txt_pw",data.iPower)
    
end


return FamilyApplyItem