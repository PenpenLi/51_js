local FriendInfoPanel=class("FriendInfoPanel",UILayer)

function FriendInfoPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_friend_info.map")  
    self.bgVisible =false
    self.curData = data;
    self:setLabelString("lab_name",data.name);
    self:setLabelString("lab_lv",getLvReviewName("Lv.")..data.level);
    self:setLabelString("txt_power",data.power);
    self:setLabelString("txt_rank",data.rank);
    self:setLabelAtlas("txt_vip",data.vip);
    gCreateRoleFla(Data.convertToIcon(data.icon), self:getNode("bg_role"),0.7,nil,nil,data.show.wlv,data.show.wkn);
    self:setRTFString("txt_sign",gGetWords("friendWords.plist","10",data.sign));

    if(data.show.hlv)then
        self:getNode("layer_honor"):setVisible(data.show.hlv > 0);
        if(data.show.hlv > 0)then
            Icon.changeHonorIcon(self:getNode("honor_icon"),data.show.hlv);
            Icon.changeHonorWord(self:getNode("honor_word"),data.show.hlv);
        end
    end
    self:resetLayOut();

    self.oneLineNum = 2;
    self.pBg = self:getNode("bg");
    self.btnOffW = 250;
    self.btnOffH = 80;
    self.btnX = self:getContentSize().width/2 - (self.oneLineNum-1)*(self.btnOffW/2);
    self.btnY = -285;
    self.btnXSave = self.btnX;
    self.btnIndex = 0;


    --记录哪个面板弹出菜单
    self.parentPanel = Panel.getTopPanel(Panel.popPanels);
    self:hideCloseModule();
end
function FriendInfoPanel:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("bg_vip"):setVisible(false);
end

function FriendInfoPanel:addBtn(btn_var,btnName)
    
    if btnName == nil or btnName == "" then
        if btn_var == "btn_fight" then
            btnName = gGetWords("friendWords.plist","14");
        elseif btn_var == "btn_chat" then
            btnName = gGetWords("friendWords.plist","15");
        elseif btn_var == "btn_formation" then
            btnName = gGetWords("friendWords.plist","13");
        elseif btn_var == "btn_mail" then
            btnName = gGetWords("friendWords.plist","16");
        elseif btn_var == "btn_black" then
            btnName = gGetWords("friendWords.plist","17");
        elseif btn_var == "btn_del" then
            btnName = gGetWords("friendWords.plist","18");
        elseif btn_var == "btn_add" then
            btnName = gGetWords("friendWords.plist","19");
        end
    end

    if Unlock.isUnlock(SYS_FRIEND,false) == false then
        if btn_var == "btn_mail" or btn_var == "btn_black" 
            or btn_var == "btn_del" or btn_var == "btn_add" then
            return;
        end
    end

    if (Module.isClose(SWITCH_CHAT)) then
        if (btn_var == "btn_chat") then
            return;
        end
    end

    -- print("btnName = "..btnName);
    -- local btn = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"images/ui_public1/button_yellow_1.png");
    local btn = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"images/ui_public1/button_gold2.png");
    btn:setContentSize(cc.size(220,63));

    local btnWord = gCreateWordLabelTTF(btnName,gCustomFont,24,cc.c3b(74,34,0));
    gAddChildInCenterPos(btn,btnWord);
    
    self:addTouchNode(btn,btn_var,"1");
    
    btn:setPosition(self.btnX,self.btnY);
    self:addChild(btn);
    
    if(self.btnIndex % self.oneLineNum == 0) then
      local contentSize = self.pBg:getContentSize();
      contentSize.height = contentSize.height + self.btnOffH;
      self.pBg:setPreferredSize(contentSize);
      self:setContentSize(contentSize);
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


function FriendInfoPanel:events()
    return {
    }
end

function FriendInfoPanel:dealEvent(event,param)
    if( event==EVENT_ID_REC_FIND_FRIEND_LIST)then
        self:initFindFriend()
    end
end

function FriendInfoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_fight")then
        if( NetErr.checkPkLevel(self.curData) ==false)then
            return
        end 
        Panel.pushRePopupPanel(PANEL_FRIEND) 
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_BUDDY_FIGHT,self.curData.uid)

    elseif(target.touchName=="btn_chat")then
        print("aaaa");
        Data.addRecentChatRole(self.curData.uid,self.curData.name,self.curData.icon,self.curData.vip)
        local uid = self.curData.uid;
        local parentPanel = self.parentPanel;
        -- Panel.popBack(self:getTag());

        --判断是不是从聊天那边弹出来的
        if parentPanel and parentPanel.__panelType == PANEL_CHAT then
            parentPanel.curUid = uid;
            parentPanel:initRecentRole()
            parentPanel:initChat(2);
            Panel.popBack(self:getTag());
        else
            Panel.popUpVisible(PANEL_CHAT,2,{curType = 2,uid = uid},true)
        end
    elseif(target.touchName=="btn_formation")then 
        Net.sendBuddyTeam(self.curData.uid)
    elseif(target.touchName=="btn_mail")then 
        FriendListPanel.data.friend.uid = self.curData.uid;
        FriendListPanel.data.friend.name = self.curData.name;
        Panel.popUp(PANEL_MAIL_WRITE)
    elseif(target.touchName=="btn_black")then 
        Net.sendBuddyBlack(self.curData.uid)
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_del")then 
        Net.sendBuddyDel(self.curData.uid)
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_add")then
        Net.sendBuddyInvite( self.curData.uid,"");    
    end
     
end

return FriendInfoPanel