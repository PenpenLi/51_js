local FamilyUserSkillPanel=class("FamilyUserSkillPanel",UILayer)

function FamilyUserSkillPanel:ctor(data)
    -- self._panelTop = true;
    self.appearType = 1;
    self:init("ui/ui_family_draw2.map")
    self.isMainLayerGoldShow = false;
    self.isMainLayerMenuShow = false;
    self:createSkillList();
end

function FamilyUserSkillPanel:createSkillList()
	self.skills = {};
	for key,var in pairs(gUserFamilyBuff) do
		local skill = {};
		skill.userskilllv = var.userskilllv;
		skill.buff = DB.getBuffById(var.id);
		skill.buffattr = DB.getFamilyBuff(var.id,skill.userskilllv);
		table.insert(self.skills,skill);
	end

	for key,var in pairs(self.skills) do
		local item = FamilyUserSkillItem.new(var);
		self:getNode("scroll"):addItem(item);
	end
	self:getNode("scroll"):layout();

end

function FamilyUserSkillPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end

end


return FamilyUserSkillPanel