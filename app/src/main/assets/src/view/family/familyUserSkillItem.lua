local FamilyUserSkillItem=class("FamilyUserSkillItem",UILayer)

function FamilyUserSkillItem:ctor(data,index)
    self:init("ui/ui_family_draw_item2.map");
    self:setData(data,index);
end

function FamilyUserSkillItem:setData(data)
	self.curData = data;
	self:refreshUI();
end

function FamilyUserSkillItem:refreshUI()
	print_lua_table(self.curData);
	self:replaceLabelString("txt_lv",self.curData.userskilllv);
	self:setLabelString("txt_name",self.curData.buff.name);
	self:setLabelString("txt_dec",gGetBuffDesc(self.curData.buff,self.curData.buffattr.val));
	-- self:setLabelString("txt_value",self.curData.buff.name);
	-- Icon.setBuffIcon(self.curData.buff.buffid,self:getNode("icon"))
	self:changeTexture("icon","images/icon/skill/"..self.curData.buff.icon..".png");
end


return FamilyUserSkillItem