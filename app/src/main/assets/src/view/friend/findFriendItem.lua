local FindFriendItem=class("FindFriendItem",UILayer)

function FindFriendItem:ctor(type)
 --    self:init("ui/ui_friend_find_item.map")
    self.type = type;
    self:setContentSize(cc.size(660,104));
    self.inited = false;
end
function FindFriendItem:initPanel()
    if(self.inited==true)then
        return
    end
    self:init("ui/ui_friend_find_item.map")
    self.inited = true;
    -- self.type = type;

    self:getNode("layer_btn_app"):setVisible(false);
    self:getNode("layer_my_friend"):setVisible(false);
    self:getNode("btn_invite"):setVisible(false);
    self:getNode("btn_unblack"):setVisible(false);
    if self.type == 1 then
        self:getNode("btn_invite"):setVisible(true);
    elseif self.type == 2 then
        self:getNode("layer_btn_app"):setVisible(true);
    elseif self.type == 3 then
        self:getNode("btn_unblack"):setVisible(true);   
    elseif self.type == 4 then
        self:getNode("layer_my_friend"):setVisible(true);
    end
    self:hideCloseModule();
end
function FindFriendItem:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("bg_vip"):setVisible(false)
end
function FindFriendItem:setData(data) 
    self:initPanel();
    self.curData=data
    Icon.setHeadIcon(self:getNode("icon"),data.icon)
    self:setLabelString("txt_name",data.name) 
    self:setLabelString("txt_level",getLvReviewName("Lv:")..data.level)
    self:setLabelAtlas("txt_vip",data.vip);
    gShowLoginTime(self,"lab_time",gServerTime-data.login);

    if self.type == 4 then
	    self:refreshGet();
	    self:refreshSend();
    end
    self:refreshInvite();
end
function FindFriendItem:setLazyData(data,lazyKey)
    self.curData = data;
    if(lazyKey == nil) then
        lazyKey = "friendItem";
    end
    Scene.addLazyFunc(self,self.setLazyDataCalled,lazyKey)
end
function FindFriendItem:setLazyDataCalled()
    self:setData(self.curData);
end

function FindFriendItem:refreshInvite()
    if(self.curData.invite)then
    	self:setLabelString("txt_btn_invite",gGetWords("btnWords.plist","invited"));
    end
end

function FindFriendItem:refreshGet()
    if(self.inited == false)then
        return;
    end 
    self:getNode("btn_get"):setVisible(self.curData.giveme);
end

function FindFriendItem:refreshSend()
    if(self.inited == false)then
        return;
    end 
    self:getNode("btn_send"):setVisible(not self.curData.give);
    self:getNode("flag_sended"):setVisible(self.curData.give);
end

function FindFriendItem:onTouchEnded(target)

    if(target.touchName=="btn_invite")then 
        -- local words=gGetWords("labelWords.plist","invite_defalt_words")
        Net.sendBuddyInvite( self.curData.uid,"")  
    elseif(target.touchName=="btn_agree")then
        if(NetErr.BuddyAccept())then
            Net.sendBuddyAccept( self.curData.uid)
        end
    elseif(target.touchName=="btn_disagree")then
        Net.sendBuddyRefuse( self.curData.uid)
    elseif(target.touchName == "btn_unblack") then
    	Net.sendBuddyDelBlack(self.curData.uid)  
    elseif(target.touchName=="btn_send")then
        Net.sendBuddyGive(self.curData.uid)
    elseif(target.touchName=="btn_get")then
        Net.sendBuddyReveive(self.curData.uid)
    elseif(target.touchName=="touch_node")then
        if self.type == 4 then
            local menu = Panel.popUpVisible(PANEL_FRIEND_INFO,self.curData);
            menu:addBtn("btn_formation");           
            menu:addBtn("btn_fight");           
            menu:addBtn("btn_chat");           
            menu:addBtn("btn_mail");            
            menu:addBtn("btn_black");            
            menu:addBtn("btn_del");	  
        end	    
    end

end

return FindFriendItem