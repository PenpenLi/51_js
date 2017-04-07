local FriendAddPanel=class("FriendAddPanel",UILayer)

function FriendAddPanel:ctor()
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_friend_add.map")
    self.inited = false;
    self.inviteListInited = false;
    self.isMainLayerGoldShow=false
    self.btns={
        "btn_find",
        "btn_app",
    }
    self:getNode("scroll_find").offsetY=5
    self:getNode("scroll_app").offsetY=5

    self:showType(1)
    self:setTouchEnable("btn_refuse_all",false,true);

    setInputBgTxt(self:getNode("txt_input"))
end

function FriendAddPanel:onPopback()
    Scene.clearLazyFunc("friendAddItem");
end

function FriendAddPanel:events()
    return {
        EVENT_ID_REC_FIND_FRIEND_LIST,
        EVENT_ID_REC_INVITE_FRIEND,
        EVENT_ID_REC_INVITE_FRIEND_LIST,
        EVENT_ID_FRIEND_REFUSE,
        EVENT_ID_FRIEND_AGREE
    }
end

function FriendAddPanel:showType(type)
    self.curShowType=type
    if(type==1)then
        self:showFindLayer()
    elseif(type==2)then
        self:showAppLayer()
    end

end

function FriendAddPanel:resetBtnTexture()
    for key, btn in pairs(self.btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function FriendAddPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function FriendAddPanel:showFindLayer()
    self:selectBtn("btn_find");
    self:getNode("layer_find"):setVisible(true);
    self:getNode("layer_app"):setVisible(false);
    self:initFindFriend();
end

function FriendAddPanel:initFindFriend()
    if( self.inited~=true)then
        self.inited=true
        Net.sendBuddyFind("")
        return
    end
    self:createFindList();
end

function FriendAddPanel:createFindList()
    Scene.clearLazyFunc("friendAddItem")
    self:getNode("scroll_find"):clear()
    for key, friend in pairs(gFriend.findFriends) do

        local item=FindFriendItem.new(1)
        if key < 4 then
            item:setData(friend)
        else
            item:setLazyData(friend,"friendAddItem");
        end
        self:getNode("scroll_find"):addItem(item)
    end
    self:getNode("scroll_find"):layout()
end

function FriendAddPanel:showAppLayer()
    self:selectBtn("btn_app");
    self:getNode("layer_find"):setVisible(false);
    self:getNode("layer_app"):setVisible(true);
    self:initInviteFriend();
end


function FriendAddPanel:initInviteFriend()

    if( self.inviteListInited~=true)then
        self.inviteListInited=true
        Net.sendBuddyApplyList()
        return
    end
    self:createApplyList();
end

function FriendAddPanel:createApplyList()
    Scene.clearLazyFunc("friendAddItem")
    self:getNode("scroll_app"):clear()
    for key, friend in pairs(gFriend.inviteList) do

        local item=FindFriendItem.new(2)
        if key < 4 then
            item:setData(friend)
        else
            item:setLazyData(friend,"friendAddItem");
        end
        self:getNode("scroll_app"):addItem(item)
    end
    self:getNode("scroll_app"):layout()
    self:refreshAppCount();
end

function FriendAddPanel:refreshAppCount()
    local count = table.getn(gFriend.inviteList);
    self:setLabelString("txt_app_count",count);
    self:setTouchEnable("btn_refuse_all",count > 0,count <= 0);

    --列表空,删除红点
    if count <= 0 or count >= Data.friend.maxFriendCount then
        Data.redpos.bolBuddyApply = false;
    end
end

function FriendAddPanel:dealEvent(event,param)
    if( event==EVENT_ID_REC_FIND_FRIEND_LIST)then
        self:initFindFriend()
    elseif( event==EVENT_ID_REC_INVITE_FRIEND)then

        -- local sort_invite = function(item1,item2)
        --     if(item1.invite or item2.invite)then
        --         return true;
        --     end
        --     return false;
        -- end
        -- self:getNode("scroll_find").sortItems(sort_invite);
        -- self:getNode("scroll_find").layout();
        local item=self:findItemById(param,"scroll_find")
        if(item)then
            item:refreshInvite();
        end
    elseif( event==EVENT_ID_REC_INVITE_FRIEND_LIST)then
        self:initInviteFriend()
    elseif( event == EVENT_ID_FRIEND_REFUSE or event == EVENT_ID_FRIEND_AGREE )then
        local item=self:findItemById(param,"scroll_app");
        if(item) then
            self:getNode("scroll_app"):removeItem(item);
        end
        self:refreshAppCount();
    end
end

function  FriendAddPanel:findItemById(uid,var)
    for key, item in pairs(self:getNode(var).items) do
        if(item.curData.uid==uid)then
            return item
        end
    end
    return nil
end


function FriendAddPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_search"then
        Net.sendBuddyFind(string.filter(self:getNode("txt_input"):getText()))
    elseif target.touchName=="btn_find"then
        self:showType(1)
    elseif target.touchName=="btn_app"then
        self:showType(2)
    elseif target.touchName == "btn_refresh" then
        Net.sendBuddyFind("");    
    elseif target.touchName=="btn_rec_all"then
        Net.sendBuddyReveiveAll()
    elseif target.touchName=="btn_give_all"then
        -- Net.sendBuddyReveiveAll()
    elseif target.touchName == "btn_refuse_all" then
        Net.sendBuddyRefuse(0);   
    -- elseif(target.touchName=="touch_node")then
    --     Panel.popUpVisible(PANEL_FRIEND_INFO,self.curData);       
    end
    
     
end

return FriendAddPanel