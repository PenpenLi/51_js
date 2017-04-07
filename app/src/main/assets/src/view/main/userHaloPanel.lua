local UserHaloPanel=class("UserHaloPanel",UILayer)

function UserHaloPanel:ctor(data)
    -- self._panelTop = true;
    self.appearType = 1;
    self:init("ui/ui_halo.map")
    -- self.isMainLayerGoldShow = false;
    self.isMainLayerMenuShow = false;
    -- self:createSkillList();
    -- gUserInfo.halo = 0

    self.playAni = false
    self.pIndex = 1
    -- --判断是否开启军团图腾
    -- self.m_iMenuIndex = 0
    -- self:setStatus()
    -- self:createSkillList()
    local index = 0;
    if(Guide.isInGuiding(GUIDE_ID_ENTER_HALO1) or Guide.isInGuiding(GUIDE_ID_ENTER_HALO2))then
        index = 1;
    end
    self:setMenuIndex(index);
    -- self.m_iMenuIndex = 0
    -- self:setStatus()
    -- self:createSkillList()

    self:setPrice()
    self:setRole()
end

function UserHaloPanel:setMenuIndex(index)
    self.m_iMenuIndex = index
    self:setStatus()
    if(index == 0)then
        self:createSkillList()    
    elseif(index == 1)then
        Unlock.setSysUnlock(SYS_HALO);
        Unlock.checkFirstEnter(SYS_HALO);
        self:createHaloList();
    end
end

function UserHaloPanel:setRole()
	-- gUserInfo.halo = 1
	gCreateRoleFla(Data.getCurIcon(),self:getNode("role_bg"),0.7,nil,nil,Data.getCurWeapon(),Data.getCurAwake(),Data.getCurHalo());

 --    local name = gGetWords("labelWords.plist","348")
 --    if (Data.getCurHalo()>0) then
 --    	name = name.." +"..Data.getCurHalo()
 --    end
	-- self:setLabelString("lab_name",name);

	loadFlaXml("shouhujingling")
    local name = "shjl_a"
    local star_lv = 3
    if (Data.getCurHalo()>=3 and Data.getCurHalo()<6) then
        name = "shjl_b"
        star_lv = 6
    elseif (Data.getCurHalo()>=6) then
        name = "shjl_c"
        star_lv = 9
    end
    local fla=gCreateFla(name,1)
    if (fla) then
    	self:getNode("halo_bg"):removeAllChildren()
        gAddCenter(fla,self:getNode("halo_bg"))
        if (star_lv==9) then
           fla:setPositionY(15)
        end
    end

    self:getNode("lab_max"):setVisible(false)
    self:getNode("lab_up"):setVisible(false)
    self:getNode("btn_lab_max"):setVisible(false)
    self:getNode("btn_lab"):setVisible(true)
    self:getNode("btn_gold_bg"):setVisible(true)
    self:getNode("btn_lab_max2"):setVisible(false)
    self:getNode("btn_lab2"):setVisible(true)
    self:getNode("btn_gold_bg2"):setVisible(true)
    local size = #Data.halo_price
	if (Data.getCurHalo()>=size) then
		self:getNode("lab_max"):setVisible(true)
        self:getNode("btn_lab_max"):setVisible(true)
        self:getNode("btn_lab"):setVisible(false)
        self:getNode("btn_gold_bg"):setVisible(false)
        self:getNode("btn_lab_max2"):setVisible(true)
        self:getNode("btn_lab2"):setVisible(false)
        self:getNode("btn_gold_bg2"):setVisible(false)
        self:setTouchEnable("btn_buy",false,true)
        self:setTouchEnable("btn_buy2",false,true)
	else
		self:getNode("lab_up"):setVisible(true)
		self:replaceRtfString("lab_up",star_lv,star_lv/3)
	end
end

function UserHaloPanel:setPrice()
	-- self:getNode("lab_gold")
	local size = #Data.halo_price
	self.pIndex = math.min(size-1,Data.getCurHalo()) + 1
	-- self:replaceRtfString("lab_gold",Data.halo_price[index])
	-- self:getNode("layout_price"):layout();

    self:setLabelString("num_gold",Data.halo_price[self.pIndex]);
    for key, var in pairs(iap_db) do
        if var.iapid==self.pIndex+8 then
            self:setLabelString("num_gold2",var.money..gGetWords("labelWords.plist","money_symbol"));
        end
    end
	-- self:getNode("layout_price2"):layout();
end

function UserHaloPanel:createHaloList()
	local size = #Data.halo_price
	self.halos = {};
	for key,var in pairs(Data.halo_price) do
		local halo = {};
		halo.price = var;
		halo.buffid = Data.halo_buffid[key];
		halo.buffid2 = Data.halo_buffid2[key];
		halo.buffattr = ""
		halo.buffattr2 = ""
		local buff = DB.getBuffById(halo.buffid)
		if (buff) then
			halo.buffattr = buff.des
		end
		if (halo.buffid2>0) then
			local buff = DB.getBuffById(halo.buffid2)
			if (buff) then
				halo.buffattr2 = buff.des
			end
		end
		table.insert(self.halos,halo);
	end

    self:getNode("scroll_halo"):clear()
	for key,var in pairs(self.halos) do
		local item = UserHaloItem.new(var,key);
		self:getNode("scroll_halo"):addItem(item);
	end
	self:getNode("scroll_halo"):layout();

	-- print("-------------="..self:getNode("scroll_halo").container:getPositionY())
end

function UserHaloPanel:createSkillList()
	self.skills = {};
    -- for key,var in pairs(gUserFamilyBuff) do
    --     local skill = {};
    --     skill.userskilllv = var.userskilllv;
    --     skill.buff = DB.getBuffById(var.id);
    --     skill.buffattr = DB.getFamilyBuff(var.id,skill.userskilllv);
    --     table.insert(self.skills,skill);
    -- end
	for key,var in pairs(familyskill_db) do
		local skill = {};
        skill.unlocklv = var.unlocklv;
        skill.userskilllv = self:getUserSkillLv(var.id);
        skill.skilllv = 1;
		skill.buff = DB.getBuffById(var.id);
		skill.buffattr = DB.getFamilyBuff(var.id,skill.userskilllv);
		table.insert(self.skills,skill);
	end

    self:getNode("scroll"):clear()
	for key,var in pairs(self.skills) do
		local item = UserHaloItem2.new(var);
		self:getNode("scroll"):addItem(item);
	end
	self:getNode("scroll"):layout();

end

function UserHaloPanel:getUserSkillLv(skillid)

    for key,var in pairs(gUserFamilyBuff) do
        if(toint(var.id) == toint(skillid))then
            return var.userskilllv;
        end
    end
    return 0;
end

function UserHaloPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif (target.touchName=="btn_junt") then
    	if (self.playAni) then return end
        self:setMenuIndex(0);
    	-- self.m_iMenuIndex = 0
    	-- self:setStatus()
    	-- self:createSkillList()
    elseif (target.touchName=="btn_huanl") then
    	if (self.playAni) then return end
        self:setMenuIndex(1);
    	-- self.m_iMenuIndex = 1
    	-- self:setStatus()
    	-- self:createHaloList()
    elseif (target.touchName=="btn_buy") then
    	if (self.playAni) then return end
    	-- gUserInfo.halo = gUserInfo.halo + 1
    	-- gDispatchEvt(EVENT_ID_BUY_HALO);
        local price = Data.halo_price[self.pIndex]
        if NetErr.isDiamondEnough(price) then
    	   Net.sendSystemBuyHalo()
           gLogPurchase("sys.buyhalo", 1, price)
           local td_param = {}
           td_param["price"] = tostring(price)
           gLogEvent("sys.buyhalo", td_param)
        end
    elseif (target.touchName=="btn_buy2") then
        if (self.playAni) then return end
        for key, var in pairs(iap_db) do
            if var.iapid==self.pIndex+8 then
                PayItem.IapBuy(var)
                break
            end
        end
    end
end

function UserHaloPanel:setScrollPox()
    self.playAni = true
	local particle =  cc.ParticleSystemQuad:create("particle/qp_lizi.plist");
    self:addChild(particle);
    -- print("self.addattrIndex = "..self.addattrIndex);
    local srcNode = self:getNode("num_gold");
    if(srcNode)then
        local pos = gGetPositionByAnchorInDesNode(self,srcNode,cc.p(0.5,-0.5));
        particle:setPosition(pos);
    end

    --让对应的空星 显示出来
    local index = Data.getCurHalo()
    local tmpIndex = math.max(index-4,0)
    local oneItemHeight = self:getNode("scroll_halo").items[index]:getContentSize().height
    local itemHeight=self:getNode("scroll_halo").container:getContentSize().height
    -- print("oneItemHeight="..oneItemHeight)
    -- print("tmpIndex="..tmpIndex)
    self:getNode("scroll_halo").container:setPositionY(-itemHeight/2+oneItemHeight*tmpIndex)
    -- print("1-------------="..self:getNode("scroll_halo").container:getPositionY())
    -- self:getNode("scroll_halo"):layout();
    -- print("2-------------="..self:getNode("scroll_halo").container:getPositionY())
    self:getNode("scroll_halo"):setCheckChildrenVisible(true)

    local desNode = nil;
    if (index>0) then
        desNode = self:getNode("scroll_halo").items[index]:getNode("icon_star")
    end

    if(desNode)then
        local desPos = gGetPositionByAnchorInDesNode(self,desNode,cc.p(0.5,0.5));
        local callback = function()
            --粒子击中
            local hit = gCreateFla("qp_kapai_lizi_b");
            hit:setPosition(gGetPositionByAnchorInDesNode(self,desNode,cc.p(0.5,0.5)));
            -- gAddChildInCenterPos(desNode:getParent(),hit);
            self:addChild(hit);
            --刷新已加成属性
            -- self:refreshNewAddAttr();
            CardPro.setAllCardAttr()
            self:setPrice()
    	    self:setRole()
            self:refreshData()
            self.playAni = false;
        end
        particle:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.5,desPos),
                cc.CallFunc:create(callback),
                cc.RemoveSelf:create()
            ));
    end
end

function UserHaloPanel:events()
    return {EVENT_ID_BUY_HALO}
end

function UserHaloPanel:dealEvent(event,param)
    if(event==EVENT_ID_BUY_HALO)then
    	self:setScrollPox()
    	-- self:refreshData(param)
    end
end

function UserHaloPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll_halo").items) do 
        item:refreshData(param)
    end
end

function UserHaloPanel:setStatus()
	self:getNode("layer_junt"):setVisible(self.m_iMenuIndex==0)
	self:getNode("layer_halo"):setVisible(self.m_iMenuIndex==1)
	local image = "images/ui_public1/button_s2.png"
	local image1 = "images/ui_public1/button_s2-1.png"
	self:changeTexture("btn_junt",self.m_iMenuIndex==0 and image1 or image);
	self:changeTexture("btn_huanl",self.m_iMenuIndex==1 and image1 or image);

    if (not Data.bolTencent()) then
        self:getNode("btn_huanl"):setVisible(false)
    end
end


return UserHaloPanel