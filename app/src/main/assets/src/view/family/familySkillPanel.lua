local FamilySkillPanel=class("FamilySkillPanel",UILayer)

function FamilySkillPanel:ctor(data)
    -- self._panelTop = true;
    loadFlaXml("ui_family_xuexi");
    self:init("ui/ui_family_draw.map")
    self.isMainLayerGoldShow = false;
    self.isMainLayerMenuShow = false;
    gCreateBtnBack(self);
    Net.sendFamilySkillInfo();
    -- self:createSkillList();
    self:selectBtn("btn_1");
    -- self:initInfo();
    self:refreshMoney();
end


function FamilySkillPanel:resetBtnTexture()
    local btns={
        "btn_1",
        "btn_2",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function FamilySkillPanel:selectBtn(name)
    -- print("name = "..name);
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
    if(name == "btn_1")then
    	self:selectSkill(0);
	elseif(name == "btn_2")then
		self:selectSkill(1);
	end
end

function FamilySkillPanel:selectSkill(type)
	if(self.selectSkillType and type == self.selectSkillType)then
		return;
	end
	self.selectSkillType = type;
	self:createSkillList();

	if(self.skilllist)then
		self:refreshSkillList(self.skilllist);
	end
end

function FamilySkillPanel:initInfo()
	self:getNode("bg_skill_upgrade"):setVisible(Data.isFamilyManager());
	self:resetLayOut();
end

function FamilySkillPanel:createSkillList()
	self.skills = {};
	for key,var in pairs(familyskill_db) do
		-- if Data.getCurFamilyLv() >= var.unlocklv then
		if toint(var.type) == self.selectSkillType then
			local skill = {};
			skill.unlocklv = var.unlocklv;
			skill.userskilllv = 0;
			skill.skilllv = 1;
			if(self.selectSkillType==1)then
				skill.skilllv = Data.getFamilySpecialSkilllv();
			end
			skill.des = var.des;
			skill.buff = DB.getBuffById(var.id);
			skill.buffattr = DB.getFamilyBuff(var.id,skill.userskilllv);
			skill.nextbuffattr = DB.getFamilyBuff(var.id,skill.userskilllv+1);
			local tempData = DB.getFamilyBuff(var.id,skill.skilllv);
			skill.skillexp = tempData.fexp;
			table.insert(self.skills,skill);
		end
		-- end
	end

	self:getNode("scroll"):clear();
	for key,var in pairs(self.skills) do
		local item = FamilySkillItem.new(var,key);
		self:getNode("scroll"):addItem(item);
		item.onSelected = function(data,index)
			self:onSelecteSkill(data,index);
		end
	end
	self:getNode("scroll"):layout();

	if(self.selectSkillType == 0)then
		self:setLabelString("name1",DB.getItemName(ITEM_FAMILY_SKILL_UPGRADE)..":");
		Icon.changeItemIcon(self:getNode("icon1"),ITEM_FAMILY_SKILL_UPGRADE);
		-- self:getNode("layout_research"):setVisible(true);
		self:getNode("bg_skill_upgrade"):setVisible(Data.isFamilyManager());
	elseif(self.selectSkillType == 1)then
		self:setLabelString("name1",DB.getItemName(ITEM_FAMILY_SKILL_BUTIAN_STONE)..":");
		Icon.changeItemIcon(self:getNode("icon1"),ITEM_FAMILY_SKILL_BUTIAN_STONE);
		-- self:getNode("layout_research"):setVisible(false);
		self:getNode("bg_skill_upgrade"):setVisible(false);
	end
	self:resetLayOut();

	self:onSelecteSkill(self.skills[1],1);
end

function FamilySkillPanel:refreshSkillList(list)
	for k,v in pairs(list) do
		for key,var in pairs(self.skills) do
			if(var.buff.buffid == v.id)then
				if(v.skilllv)then
					var.skilllv = v.skilllv;
				end
				if(v.userskilllv)then
					var.userskilllv = v.userskilllv;
				end

				var.buffattr = DB.getFamilyBuff(var.buff.buffid,var.userskilllv);
				var.nextbuffattr = DB.getFamilyBuff(var.buff.buffid,var.userskilllv+1);
				local tempData = DB.getFamilyBuff(var.buff.buffid,var.skilllv);
				var.skillexp = tempData.fexp;
			
				break;
			end
		end
	end

	local items = self:getNode("scroll"):getAllItem();
	for key,item in pairs(items) do
		item:refreshUI();
	end
	self:refreshCurSkillInfo(self.curData);
	self:refreshMoney();
end

function FamilySkillPanel:refreshSkill(data)
	local list = {};
	table.insert(list,data);
	self:refreshSkillList(list);

	local items = self:getNode("scroll"):getAllItem();
	for key,item in pairs(items) do
		if(item.curData.buff.buffid == data.id)then
			item:effectForLearn();
			break;
		end
	end
end

function FamilySkillPanel:onSelecteSkill(data,index)

	local items = self:getNode("scroll"):getAllItem();
	for key,item in pairs(items) do
		if(index == key)then
			item:selected();
		else
			item:unselected();
		end
	end

	self:refreshCurSkillInfo(data);
end

function FamilySkillPanel:refreshCurSkillInfo(data)
	self.curData = data;
	-- print_lua_table(data);
	self:setLabelString("txt_name",data.buff.name);
	self:setLabelString("txt_des",data.des);
	local curLvData = Data.getFamilyLvData(Data.getCurFamilyLv());
	if(self.selectSkillType == 0)then
		self:replaceRtfString("txt_research",data.skilllv,curLvData.skilllv);
	elseif(self.selectSkillType == 1)then
		self:setRTFString("txt_research",gGetWords("familyMenuWord.plist","spe_skill_limit",curLvData.skilllvspecial));
		-- self:replaceRtfString("txt_research",data.skilllv,curLvData.skilllv);
	end
	-- self:setLabelString("txt_skill_lv",data.skilllv);
	self:setLabelString("txt_user_skill_lv",data.userskilllv);
	-- self:replaceLabelString("txt_lv3",curLvData.skilllv);
	-- self:setLabelString("txt_dec",gGetBuffDesc(self.curData.buff,self.curData.buffattr.val));
	
	-- self:replaceRtfString("txt_cur_des1",gGetBuffDesc(data.buff,data.buffattr.val));
	-- local cur_des_node = self:getNode("txt_cur_des1"):getNode(2);
	-- cur_des_node:setColor(self:getNode("txt_cur_des1").color);

	if(data.userskilllv <= 0)then
		local word = gGetMapWords("ui_family_draw.plist","6","\\w{c=ff0000}"..gGetWords("familyMenuWord.plist","no_skill"));
		self:setRTFString("txt_cur_des1",word);
		-- self:replaceRtfString("txt_cur_des1",gGetMapWords("familyMenuWord.plist","no_skill"));
	else
		local word = gGetMapWords("ui_family_draw.plist","6",gGetBuffDesc(data.buff,data.buffattr.val,data.buffattr.val1));
		self:setRTFString("txt_cur_des1",word);
	end
	self:replaceRtfString("txt_next_des1",gGetBuffDesc(data.buff,data.nextbuffattr.val,data.nextbuffattr.val1));
	-- self:setLabelString("txt_next_des1",gGetBuffDesc(data.buff,data.nextbuffattr.val));

	self:getNode("bg_cost0"):setVisible(data.nextbuffattr.itemnum > 0);
	self:setLabelString("txt_num1",data.nextbuffattr.itemnum);
	self:setLabelString("txt_num2",data.nextbuffattr.userfexp);
	self:setLabelString("txt_num3",data.skillexp);

	self:setTouchEnable("btn_user_skill_upgrade",true,Data.getCurFamilyLv() < data.unlocklv);
	self:setTouchEnable("btn_skill_upgrade",true,Data.getCurFamilyLv() < data.unlocklv);
	self:resetLayOut();
end

function FamilySkillPanel:refreshMoney()
	if(self.selectSkillType == 0)then
		Icon.changeItemIcon(self:getNode("btn_gold"),ITEM_FAMILY_SKILL_UPGRADE);
		self:setLabelString("txt_cur_num1",Data.getItemNum(ITEM_FAMILY_SKILL_UPGRADE));
	elseif(self.selectSkillType == 1)then
		Icon.changeItemIcon(self:getNode("btn_gold"),ITEM_FAMILY_SKILL_BUTIAN_STONE);
		self:setLabelString("txt_cur_num1",Data.getItemNum(ITEM_FAMILY_SKILL_BUTIAN_STONE));
	end
	self:setLabelString("txt_cur_num2",gFamilyInfo.curFExp);
	self:setLabelString("txt_cur_num3",Data.getCurFamilyExp());
end

function FamilySkillPanel:events()
	return {EVENT_ID_FAMILY_SKILL,EVENT_ID_FAMILY_SKILL_LEARN,EVENT_ID_FAMILY_SKILL_RESEARCH}
end

function FamilySkillPanel:dealEvent(event,param)
	if(event == EVENT_ID_FAMILY_SKILL)then
		self.skilllist = param;
		-- print(">>>>>>>>");
		-- print_lua_table(param);
		self:refreshSkillList(param);
	elseif(event == EVENT_ID_FAMILY_SKILL_RESEARCH)then
		table.insert(self.skilllist,param);
		self:refreshSkillList(self.skilllist);	
	elseif(event == EVENT_ID_FAMILY_SKILL_LEARN)then	

		for k,var in pairs(self.skilllist) do
			if(var.id == param.id)then
				-- print("xxxx");
				var.userskilllv = param.userskilllv;
				break;
			end
		end

		self:refreshSkill(param);
	end
end

function FamilySkillPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_user_skill_upgrade" then
    	if(gFamilyInfo.isTempMember)then
    		gShowCmdNotice("family.userskillupgrade",11);
    		return;
    	end
    	if(Data.getCurFamilyLv() < self.curData.unlocklv)then
	    	gShowNotice(gGetWords("familyMenuWord.plist","unlock_skill_tip",self.curData.unlocklv));
    		return;
    	end
    	if(self.curData.userskilllv >= self.curData.skilllv)then
	    	gShowCmdNotice("family.userskillupgrade",14);
    		return;
	    end
    	if(Data.getCurFamilyExp() < self.curData.nextbuffattr.userfexp)then
	    	gShowCmdNotice("family.userskillupgrade",33);
    		return;
	    end
	    if(self.selectSkillType == 0)then
	    	if(Data.getItemNum(ITEM_FAMILY_SKILL_UPGRADE) < self.curData.nextbuffattr.itemnum)then
		    	gShowCmdNotice("family.userskillupgrade",34);
	    		return;
		    end
	    elseif(self.selectSkillType == 1)then
	    	if(Data.getItemNum(ITEM_FAMILY_SKILL_BUTIAN_STONE) < self.curData.nextbuffattr.itemnum)then
		    	gShowCmdNotice("family.userskillupgrade",34);
	    		return;
		    end
	    end
	    print("xxxxx");
    	Net.sendFamilyUserSkillUpgrade(self.curData.buff.buffid);
    elseif target.touchName == "btn_skill_upgrade" then
    	if(Data.getCurFamilyLv() < self.curData.unlocklv)then
	    	gShowNotice(gGetWords("familyMenuWord.plist","unlock_skill_tip",self.curData.unlocklv));
    		return;
    	end

    	if(gFamilyInfo.curFExp < self.curData.skillexp)then
    		gShowCmdNotice("family.skillupgrade",33);
    		return;
    	end
    	Net.sendFamilySkillUpgrade(self.curData.buff.buffid);
    elseif target.touchName == "btn_rule" then
    	gShowRulePanel(SYS_FAMILY_SKILL);	
	elseif target.touchName == "btn_1" then
        self:selectBtn(target.touchName);
	elseif target.touchName == "btn_2" then
        self:selectBtn(target.touchName);
    end

end


return FamilySkillPanel