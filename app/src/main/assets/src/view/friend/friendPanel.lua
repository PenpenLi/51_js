local FriendPanel=class("FriendPanel",UILayer)
FriendPanelData = {};
function FriendPanel:ctor()
    self:init("ui/ui_friend.map")

    self.btns={
        "btn_my_friend",
        "btn_black",
    }

    self:getNode("scroll").offsetY=5
    self:showType(1)

    self:getNode("btn_invite"):setVisible(not Module.isClose(SWITCH_INVITE));
end


function FriendPanel:onPopback()
    Scene.clearLazyFunc("friendItem");
end

function FriendPanel:events()
    return {
        EVENT_ID_REC_MY_FRIEND_LIST,
        EVENT_ID_REC_BLACK_FRIEND_LIST,
        EVENT_ID_FRIEND_ADDONE,
        EVENT_ID_REC_FRIEDN_GIVE,
        EVENT_ID_FRIEND_HP_SEND,
        EVENT_ID_REC_FRIEDN_GIVE_ALL,
        EVENT_ID_REC_FRIEDN_SEND_ALL,
        EVENT_ID_FRIEND_DEL,
        EVENT_ID_FRIEND_BLACK_DEL,

         }
end

function FriendPanel:showType(type)
    self.curShowType=type
    if(type==1)then
        self:initMyFriend()
    elseif(type==2)then
        self:initBlackFriend()
    -- elseif(type==5)then
    --     self:initEnergyFriend()
    end

end

function FriendPanel:refreshSign()
    -- print("sign = "..gFriend.sign);
    self:setLabelString("txt_sign",gFriend.sign);
end

function FriendPanel:refreshGetHpCount()
    self:setLabelString("txt_gethp_count",gFriend.giveLeftTime);

    local isCanGetHp = false;
    for key,var in pairs(gFriend.myFriends) do
        if var.giveme then
            isCanGetHp = true;
            break;
        end
    end

    if isCanGetHp == false or gFriend.giveLeftTime <= 0 then
        Data.redpos.bolBuddyHp = false;
    end
    -- self:setTouchEnable("btn_rec_all",Data.redpos.bolBuddyHp,not Data.redpos.bolBuddyHp);
end

function FriendPanel:dealEvent(event,param)
    print("event = "..event);
    if( event==EVENT_ID_REC_MY_FRIEND_LIST)then
        self:createFriendList()
    elseif( event==EVENT_ID_REC_BLACK_FRIEND_LIST)then
        self:createBlackFriendList()
    elseif(event == EVENT_ID_FRIEND_ADDONE)then
        self:addMyFriendItem(param);    
    elseif( event==EVENT_ID_REC_FRIEDN_GIVE)then
        local item = self:myFriendItemById(param);
        if item then
            item:refreshGet();
        end
        self:refreshGetHpCount();
    elseif(event == EVENT_ID_FRIEND_HP_SEND)then
        local item = self:myFriendItemById(param);
        if item then
            item:refreshSend();
        end
    elseif(event == EVENT_ID_REC_FRIEDN_GIVE_ALL)then
        if self.curShowType == 1 then
            for key, item in pairs(self:getNode("scroll").items) do
                item:refreshGet();
            end
        end
        self:refreshGetHpCount();
    elseif(event == EVENT_ID_REC_FRIEDN_SEND_ALL)then
        if self.curShowType == 1 then
            for key, item in pairs(self:getNode("scroll").items) do
                item:refreshSend();
            end
        end
    elseif(event == EVENT_ID_FRIEND_DEL)then
        local item = self:myFriendItemById(param);
        if item then
            self:getNode("scroll"):removeItem(item);
        end
        self:refreshFriendCount();
    elseif(event == EVENT_ID_FRIEND_BLACK_DEL)then
        local item = self:myFriendItemById(param);
        if item then
            self:getNode("scroll"):removeItem(item);
        end
        self:refreshBalckFriendCount();    
    end
end

function FriendPanel:myFriendItemById(uid)
    -- if self.curShowType == 1 then
        for key, item in pairs(self:getNode("scroll").items) do
            if(item.curData.uid==uid)then
                return item
            end
        end
    -- end
    return nil    
end

-- function  FriendPanel:initGive()
--     for key, item in pairs(self:getNode("scroll").items) do 
--         if(item and item:getNode("btn_rec"))then
--             item:getNode("btn_rec"):setVisible(false)
--         end
--     end
    
--     for key, give in pairs(gFriend.gives) do
--         local item=self:findItemById(give.uid)
--         if(item and item:getNode("btn_rec"))then
--             item:getNode("btn_rec"):setVisible(true)
--         end
--     end
-- end


function FriendPanel:initMyFriend()
    self:selectBtn("btn_my_friend")
    self:getNode("layer_btns"):setVisible(true);
    self:getNode("tip_black"):setVisible(false);
    if( gFriend.myFriendsInited~=true)then
        gFriend.myFriendsInited=true
        Net.sendBuddyList()
        return
    end
    self:createFriendList();

end

function FriendPanel:createFriendList()

    Scene.clearLazyFunc("friendItem")

    self:getNode("scroll"):clear()
    local friendCount = table.count(gFriend.myFriends);
    self:getNode("txt_friend_tip"):setVisible(true);
    if friendCount > 0 then
        for key, friend in pairs(gFriend.myFriends) do
            local item=FindFriendItem.new(4)
            if key < 4 then
                item:setData(friend)
            else
                item:setLazyData(friend);
            end    
            self:getNode("scroll"):addItem(item)
        end
        self:getNode("scroll"):layout()
    end

    self:refreshFriendCount();
    self:refreshSign();
    self:refreshGetHpCount();
end

function FriendPanel:refreshFriendCount()
    local count = table.count(gFriend.myFriends);
    self:setLabelString("txt_count",gGetWords("friendWords.plist","5"));
    self:setLabelString("txt_friend_count",count.."/"..Data.friend.maxFriendCount);
    self:getNode("layer_null"):setVisible(count<=0);
end


function FriendPanel:addMyFriendItem(data)
  -- body
    local item=FindFriendItem.new(4)
    item:setData(data)
    self:getNode("scroll"):addItem(item)
    self:getNode("scroll"):layout()
    self:refreshFriendCount();

    local sWord = gGetWords("friendWords.plist","warning2",data.name);
    gShowNotice(sWord);
end

function FriendPanel:initBlackFriend()

    self:selectBtn("btn_black")
    self:getNode("layer_btns"):setVisible(false);
    self:getNode("tip_black"):setVisible(true);

    if( gFriend.blackListInited~=true)then
        gFriend.blackListInited=true
        Net.sendBuddyBlackList()
        return
    end
    self:createBlackFriendList();
    -- for key, friend in pairs(gFriend.blackList) do

    --     local item=BlackFriendItem.new()
    --     item:setData(friend)
    --     self:getNode("scroll"):addItem(item)
    -- end
    -- self:getNode("scroll"):layout()

end

function FriendPanel:createBlackFriendList()
    Scene.clearLazyFunc("friendItem")
    self:getNode("scroll"):clear()
    local count = table.count(gFriend.blackList);
    self:getNode("txt_friend_tip"):setVisible(false);
    if count > 0 then
        for key, friend in pairs(gFriend.blackList) do
            local item=FindFriendItem.new(3)
            if key < 4 then
                item:setData(friend);
            else
                item:setLazyData(friend);
            end
            self:getNode("scroll"):addItem(item)
        end
        self:getNode("scroll"):layout()
    end
    self:refreshBalckFriendCount();
end

function FriendPanel:refreshBalckFriendCount()
    local count = table.count(gFriend.blackList);
    self:setLabelString("txt_count",gGetWords("friendWords.plist","6"));
    self:setLabelString("txt_friend_count",count.."/"..Data.friend.maxFriendCount);
    self:getNode("layer_null"):setVisible(count<=0);
end


-- function FriendPanel:initInviteFriend()


--     self:selectBtn("btn_invite")

--     self:getNode("scroll"):clear()
--     self:getNode("scroll"):setVisible(true)
--     if( gFriend.inviteListInited~=true)then
--         gFriend.inviteListInited=true
--         Net.sendBuddyApplyList()
--         return
--     end

--     for key, friend in pairs(gFriend.inviteList) do

--         local item=InviteFriendItem.new()
--         item:setData(friend)
--         self:getNode("scroll"):addItem(item)
--     end
--     self:getNode("scroll"):layout()

-- end



function FriendPanel:initEnergyFriend()


    self:selectBtn("btn_energy")
end




function FriendPanel:resetBtnTexture()
    for key, btn in pairs(self.btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function FriendPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function FriendPanel:onSign()
    local panel = Panel.popUpVisible(PANEL_FRIEND_SIGN);
    panel.refreshSign = function()
        self:refreshSign();
    end
end

function FriendPanel:onAddFriend()
    Panel.popUpVisible(PANEL_FRIEND_ADD);
end

function FriendPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_search"then
        Net.sendBuddyFind(string.filter(self:getNode("txt_input"):getText()))
    elseif target.touchName=="btn_my_friend"then
        self:showType(1)
    elseif target.touchName=="btn_black"then
        self:showType(2)
    elseif target.touchName == "btn_sign" then
        self:onSign();
    elseif target.touchName == "btn_add" then
        self:onAddFriend();
    elseif target.touchName=="btn_refresh"then
        Net.sendBuddyList()
    elseif target.touchName=="btn_rec_all"then
        Net.sendBuddyReveiveAll()
    elseif target.touchName=="btn_give_all"then
        Net.sendBuddyGive(0);
    elseif target.touchName=="btn_invite"then 
        local data={}
        data.serverName= gAccount:getCurServer().name
        data.roleId = Data.getCurUserId()
        data.serverId = gAccount:getCurRole().serverid
        data.roleLevel = Data.getCurLevel()
        data.roleName = Data.getCurName()
        local extra=gAccount:tableToString(data)
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("facebook_invite",extra)
        end
    end
end

return FriendPanel