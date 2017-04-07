local DynamicMenuPanel=class("DynamicMenuPanel",UILayer)

function DynamicMenuPanel:ctor(data)
  self.appearType = 1;
  self:init("ui/ui_family_mem_menu.map"); 
  self.data = data;
  self._panelTop = true;
  self.oneLineNum = 2;
  self:setLabelString("lab_name",data.name);
  self:setLabelString("lab_lv",getLvReviewName("Lv.")..data.lv);
  self:setLabelAtlas("lab_vip",data.vip);

  if(data.familyType) then
    self:setLabelString("lab_mem",gGetWords("familyMenuWord.plist","title"..data.familyType));
  end
  if(data.loginTime) then
    if data.loginTime == 0 then
      self:setLabelString("lab_time",gGetWords("familyMenuWord.plist","menu_mem5"));
      self:getNode("lab_time"):setColor(cc.c3b(174,251,52));
    else
      local word = getTimeDiff(data.loginTime);
      word = word .. gGetWords("familyMenuWord.plist","login");
      self:setLabelString("lab_time",word);
      self:getNode("lab_time"):setColor(cc.c3b(160,140,128));
    end
  end
  if(data.coat)then
    gCreateRoleFla(Data.convertToIcon(data.coat), self:getNode("bg_role"),0.7,nil,nil,data.show.wlv,data.show.wkn);
  end

  self.pBg = self:getNode("bg");
  -- self.pLabName = self:getNode("lab_name");
  -- self:setNameStatue(false);
  self.btnOffW = 250;
  self.btnOffH = 80;
  self.btnX = self:getContentSize().width/2 - (self.oneLineNum-1)*(self.btnOffW/2);
  self.btnY = -205;
  self.btnXSave = self.btnX;
  self.btnIndex = 0;
 
  -- self:setCallFuncWithTouchNode(self:getNodeByVar("btn_close"),self,self.onClose);
  self:hideCloseModule();
end

function DynamicMenuPanel:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("bg_vip"):setVisible(false)
end

function DynamicMenuPanel:onTouchEnded(target)

  if(target.touchName == "btn_close")then
    self:onClose();
  elseif(target.touchName == "btn_exit")then
    self.onExit();   
  elseif(target.touchName == "btn_app")then
    self.onApp(self.data);   
  elseif(target.touchName == "btn_expel")then
    self.onExpel(self.data);   
  elseif(target.touchName == "btn_add_friend")then
    -- self.onAddFriend(self.data);   
    local words=gGetWords("labelWords.plist","invite_defalt_words")
    Net.sendBuddyInvite( self.data.uid,words)
  elseif(target.touchName == "btn_fight")then
    self.onFight(self.data);   
    -- sendFamilyFight(self.data.uid);
  elseif(target.touchName == "btn_formation")then
    self.onFormation(self.data);   
  elseif(target.touchName == "btn_app_type1")then
    self.onAppointToType1(self.data);   
  elseif(target.touchName == "btn_app_type2")then
    self.onAppointToType2(self.data);   
  elseif(target.touchName == "btn_app_type9")then
    self.onAppointToType9(self.data);   
  end

end

function DynamicMenuPanel:onClose()
  if(self.parentMenu ~= nil) then
    self.parentMenu:setVisible(true);
  end
  Panel.popBack(self:getTag());
  -- self:removeFromParent();
end

-- function DynamicMenuPanel:setNameStatue(isShow)
--   self.pLabName:setVisible(isShow);
-- end

-- function DynamicMenuPanel:setName(name)
--   self.pLabName:setString(name);
--   self:setNameStatue(true);
-- end

function DynamicMenuPanel:addBtn(btnName,btn_var)

    print("btnName = "..btnName);
    local btn = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"images/ui_public1/button_gold2.png");
    btn:setContentSize(cc.size(220,63));

    -- local btn_bg = cc.Sprite:create("images/ui_public1/button_red_1.png");
    -- local btn = cc.Sprite:create("images/ui_public1/button_red_1.png");
    local btnWord = gCreateWordLabelTTF(btnName,gCustomFont,24,cc.c3b(74,34,0));
    gAddChildInCenterPos(btn,btnWord);
    
    self:addTouchNode(btn,btn_var,"1");
    
    btn:setPosition(self.btnX,self.btnY);
    self:addChild(btn);
    
    if(self.btnIndex % self.oneLineNum == 0) then
      local contentSize = self.pBg:getContentSize();
      contentSize.height = contentSize.height + self.btnOffH;
      -- print("contentSize.height = "..contentSize.height);
      self.pBg:setPreferredSize(contentSize);
      self:setContentSize(contentSize);
      -- local winSize = cc.Director:getInstance():getWinSize();
      -- self:setPosition(cc.p((winSize.width - contentSize.width)/2,winSize.height - (winSize.height - contentSize.height)/2));
  --    self:refreshTouchRect();
    end

    self.btnIndex = self.btnIndex + 1;
    -- print("btnIndex = "..self.btnIndex);
    if(self.btnIndex % self.oneLineNum == 0) then
      self.btnX = self.btnXSave;
      self.btnY = self.btnY - self.btnOffH;else
      self.btnX = self.btnX + self.btnOffW;
    end

    return btn;
end

function DynamicMenuPanel:setParentMenu(parentMenu)
  self.parentMenu = parentMenu;
  self.parentMenu:setVisible(false);
end

return DynamicMenuPanel