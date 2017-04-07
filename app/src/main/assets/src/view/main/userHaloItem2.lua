local UserHaloItem2=class("UserHaloItem2",UILayer)

function UserHaloItem2:ctor(data,index)
    self:init("ui/ui_halo_item.map");
    self:setData(data,index);
end

function UserHaloItem2:setData(data)
	self.curData = data;
	self:refreshUI();
end

function UserHaloItem2:refreshUI()
	print_lua_table(self.curData);
	self:getNode("btn_go"):setVisible(false);
	self:getNode("txt_tip1"):setVisible(false);
	self:getNode("layout_tip"):setVisible(false);
	if(not Data.hasFamily())then
		self:getNode("txt_tip1"):setVisible(true);
	elseif(Data.getCurFamilyLv() < self.curData.unlocklv)then
		self:getNode("layout_tip"):setVisible(true);
		self:replaceLabelString("txt_family_lv",self.curData.unlocklv);
	else
		self:getNode("btn_go"):setVisible(true);	
	end
	self:replaceLabelString("txt_lv",self.curData.userskilllv);
	self:setLabelString("txt_name",self.curData.buff.name);
	self:setLabelString("txt_dec",gGetBuffDesc(self.curData.buff,self.curData.buffattr.val,self.curData.buffattr.val1));
	-- self:setLabelString("txt_value",self.curData.buff.name);
	-- Icon.setBuffIcon(self.curData.buff.buffid,self:getNode("icon"))
	self:changeTexture("icon","images/icon/skill/"..self.curData.buff.icon..".png");

	self:resetLayOut();
end

function UserHaloItem2:onTouchEnded(target)
    if  target.touchName=="btn_go"then
        if Unlock.isUnlock(SYS_FAMILY) then
		    if gFamilyInfo.familyId == 0 then
		        Panel.popUpUnVisible(PANEL_FAMILY_BG);
		        Panel.popUpVisible(PANEL_FAMILY_SEARCH,1);
		    else
		        Net.sendFamilyGetInfo(nil,PANEL_FAMILY_SKILL);
		    end
        end
    end
end

return UserHaloItem2