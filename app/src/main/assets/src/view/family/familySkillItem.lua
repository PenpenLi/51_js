local FamilySkillItem=class("FamilySkillItem",UILayer)

function FamilySkillItem:ctor(data,index)
    self:init("ui/ui_family_draw_item1.map");
    self:getNode("arrow"):setVisible(false);
    self.bgPos = cc.p(self:getNode("bg"):getPosition());
    self.bgNamePos = cc.p(self:getNode("bg_name"):getPosition());
    self:setData(data,index);
end

function FamilySkillItem:setData(data,index)
	self.curData = data;
	self.index = index;
	self:refreshUI();
end

function FamilySkillItem:refreshUI()
	self:replaceLabelString("txt_lv",self.curData.userskilllv,self.curData.skilllv);
	self:setLabelString("txt_name",self.curData.buff.name);
	-- Icon.setBuffIcon(self.curData.buff.buffid,self:getNode("icon"))
	self:changeTexture("icon","images/icon/skill/"..self.curData.buff.icon..".png");
	self:getNode("flag_unlock"):setVisible(Data.getCurFamilyLv() < self.curData.unlocklv);
end

function FamilySkillItem:selected()
    self:getNode("arrow"):setVisible(true);
	self:changeTexture("bg","images/ui_family/draw_2.png");
	self:getNode("bg"):stopAllActions();
	self:getNode("bg"):runAction(cc.Spawn:create(
			cc.ScaleTo:create(0.1,1.1),
			cc.MoveTo:create(0.1,cc.p(self.bgPos.x,self.bgPos.y-20))
		));
	self:getNode("bg_name"):stopAllActions();
	self:getNode("bg_name"):runAction(
			cc.MoveTo:create(0.1,cc.p(self.bgNamePos.x,self.bgNamePos.y-25))
		);

	-- self:effectForLearn();
end

function FamilySkillItem:unselected()
    self:getNode("arrow"):setVisible(false);
    self:getNode("bg"):setScale(1.0);
    self:changeTexture("bg","images/ui_family/draw_1.png");
    -- self:getNode("bg"):setPosition(self.bgPos);
    -- self:getNode("bg_name"):setPosition(self.bgNamePos);
    self:getNode("bg"):stopAllActions();
    self:getNode("bg"):runAction(cc.Spawn:create(
			cc.ScaleTo:create(0.1,1.0),
			cc.MoveTo:create(0.1,cc.p(self.bgPos.x,self.bgPos.y))
		));
    self:getNode("bg_name"):stopAllActions();
	self:getNode("bg_name"):runAction(
			cc.MoveTo:create(0.1,cc.p(self.bgNamePos.x,self.bgNamePos.y))
		);
end

function FamilySkillItem:effectForLearn()
	local fla = gCreateFla("ui_xuexi_guangxiao_ka");
	gAddChildInCenterPos(self:getNode("bg"),fla);

	local fla1 = gCreateFla("ui_family_xuexi_guangxiao");
	fla1:setLocalZOrder(2);
	gAddChildInCenterPos(self:getNode("bg"),fla1);
end

function FamilySkillItem:onTouchEnded(target)
    if  target.touchName=="bg"then
    	if(self.onSelected) then
    		self.onSelected(self.curData,self.index);
    	end
    end

end


return FamilySkillItem