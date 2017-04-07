---好友模块
function Net.sendBuddyList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_BUDDY_LIST)
end

function Net.recBuddyList(evt)
    print("Net.recBuddyList~")
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFriend.myFriendsInited=true
    gFriend.myFriends = {};
    gFriend.myFriends = Net.parseBuddyList(obj:getArray("list"))
    gFriend.giveLeftTime = obj:getByte("num");
    gDispatchEvt(EVENT_ID_REC_MY_FRIEND_LIST)
    gLogEvent("buddy.list")
    -- print_lua_table(gFriend.myFriends, 4)
end

function Net.sendBuddyFind(sName)
    local obj = MediaObj:create()
    obj:setString("name",sName)
    Net.sendExtensionMessage(obj,CMD_BUDDY_FIND)
end

function Net.recBuddyFind(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFriend.findFriends = Net.parseBuddyList(obj:getArray("list"))
    gDispatchEvt(EVENT_ID_REC_FIND_FRIEND_LIST)
end

function Net.sendBuddyMessage(uid,sMsg)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    obj:setString("msg",sMsg)
    Net.sendExtensionMessage(obj,CMD_BUDDY_MESSAGE)
end

function Net.rec_buddy_message(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDispatchEvt(EVENT_ID_FRIEND_MAIL_SEND);
end

function Net.sendBuddyMailList(time)
    local obj = MediaObj:create()
    obj:setInt("time",time)
    Net.sendExtensionMessage(obj, CMD_BUDDY_MAILLIST);
end

function Net.rec_buddy_maillist(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local list=obj:getArray("list")
    if(list == nil) then
        return;
    end

    local list = obj:getArray("list")
    for i=0, list:count()-1 do
        local obj1=tolua.cast(list:getObj(i),"MediaObj")
        local info = {};
        info.eId = obj1:getLong("id");
        info.name = obj1:getString("name");
        info.title = info.name;
        -- info.title = obj1:getString("title");
        info.content = obj1:getString("cnt");
        info.time = obj1:getInt("time");
        info.bolRead = obj1:getBool("read");
        info.userId = obj1:getLong("uid");
        if(not Data.isInBlackList(info.userId))then
            table.insert(Data.friend.maillist,info)
        end
    end

    if(table.getn(Data.friend.maillist) > 0) then
        Data.friend.gettime = gGetCurServerTime();
    end

    Net.friend_mail_sort()
    Net.dealRedDot_BuddyMail()
    gDispatchEvt(EVENT_ID_FRIEND_MAIL_LIST);
end


function Net.friend_mail_sort()
    local function sort(a, b)
        if a.bolRead == b.bolRead then
            return a.time > b.time
        elseif b.bolRead then
            return true
        else
            return false
        end
    end
    table.sort(Data.friend.maillist, sort)
end

function Net.sendBuddyReadMail(mId)
    local obj = MediaObj:create()
    obj:setLong("id", mId);
    Net.sendExtensionMessage(obj, CMD_BUDDY_READMAIL);
end

function Net.rec_buddy_readmail(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local eId = obj:getLong("id");
    local userId = obj:getLong("uid");
    local strContent = obj:getString("content");

    for key, var in pairs(Data.friend.maillist) do
        if (var.eId == eId) then
            var.userId = userId;
            var.content = strContent;
            var.bolRead = true;
            -- gDispatchEvt(EVENT_ID_FRIEND_MAIL_LIST,var);
            break;
        end
    end
    Net.dealRedDot_BuddyMail()
end

function Net.sendBuddyDelMsg(mid)
    local obj = MediaObj:create()
    obj:setLong("id", mid);
    Net.sendExtensionMessage(obj, CMD_BUDDY_DELMSG);
end

function Net.rec_buddy_delmsg(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local eId = obj:getLong("id");
    for key, var in pairs(Data.friend.maillist) do
        if (var.eId == eId) then
            table.remove(Data.friend.maillist,key);
            gDispatchEvt(EVENT_ID_FRIEND_MAIL_DEL,var);
            break;
        end
    end
    Net.dealRedDot_BuddyMail()
end

function Net.dealRedDot_BuddyMail()
    for key, var in pairs(Data.friend.maillist) do
        if(not var.bolRead)then
            Data.redpos.bolBuddyMail = true
            return
        end
    end
    Data.redpos.bolBuddyMail = false;
    -- EventListener::sharedEventListener()->handleEvent(c_event_redDot_Email);
end

function Net.sendBuddyInvite(uid,sMsg)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    obj:setString("msg",sMsg)
    Net.sendExtensionMessage(obj,CMD_BUDDY_INVITE)
end

function Net.recBuddyInvite(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("uid")

    if(gFriend.findFriends)then
        for key, friend in pairs(gFriend.findFriends) do
            if(friend.uid == uid) then
                friend.invite = true;
                break;
            end
        end
    end

    gDispatchEvt(EVENT_ID_REC_INVITE_FRIEND,uid)

end

---#####切磋
function Net.sendBuddyFight(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_FIGHT)
end

function Net.recBuddyFight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA_LOG)
    gLogEvent("buddy.fight")
end
---#####切磋

---#####删除好友
function Net.sendBuddyDel(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_DEL)
end


function Net.recBuddyDel(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("uid")
    Data.removeMyFriend(uid)
    gDispatchEvt(EVENT_ID_FRIEND_DEL,uid);
    gLogEvent("buddy.del")
end

function Net.recReveiveBuddyDel(evt)
    Net.recBuddyDel(evt)
end
---#####删除好友



---#####赠送体力
function Net.sendBuddyGive(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_GIVE)
end

function Net.recBuddyGive(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("uid")
    if uid == 0 then
        Data.revMyFriendGiveAll();
        gDispatchEvt(EVENT_ID_REC_FRIEDN_SEND_ALL);
    else
        Data.revMyFriendGive(uid)
        gDispatchEvt(EVENT_ID_FRIEND_HP_SEND,uid);
    end
    gLogEvent("buddy.give")
end



---#####赠送体力

---#####申请列表
function Net.sendBuddyApplyList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_BUDDY_APPLYLIST)
end

function Net.recBuddyApplyList(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local list = obj:getArray("list")
    gFriend.inviteList = {}
    for i=0,list:count()-1 do
        local applyObj = list:getObj(i)
        applyObj = tolua.cast(applyObj,"MediaObj")
        local uid = applyObj:getLong("uid")
        local name = applyObj:getString("name")
        local msg = applyObj:getString("msg")
        local vip = applyObj:getByte("vip")
        local icon = applyObj:getInt("icon");
        local login = applyObj:getInt("lgtime");
        local level= applyObj:getShort("lv")
        table.insert(gFriend.inviteList,{uid = uid,name = name,msg = msg,vip=vip,icon=icon,login=login,level=level})
    end

    gDispatchEvt(EVENT_ID_REC_INVITE_FRIEND_LIST)

end
---#####申请列表

---#####拒绝
function Net.sendBuddyRefuse(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_REFUSE)
end

function Net.recBuddyRefuse(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("uid")
    if uid == 0 then
        gFriend.inviteList = {};
        gDispatchEvt(EVENT_ID_REC_INVITE_FRIEND_LIST)
    else
        Data.removeFriendInvite(uid)
        gDispatchEvt(EVENT_ID_FRIEND_REFUSE,uid);
    end


end
---#####拒绝

---#####接受
function Net.sendBuddyAccept(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    FriendPanelData.sendUid = uid;
    Net.sendExtensionMessage(obj,CMD_BUDDY_ACCEPT)
end

function Net.recBuddyAccept(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if(ret~=0)then
        --好友已满
        if(ret == 8)then
            Net.sendBuddyRefuse(FriendPanelData.sendUid);
        end
        return
    end
    if obj:containsKey("user")then
        local buddytable = Net.parseBuddyObj(obj:getObj("user"))
        if buddytable ~= nil then
            Data.removeFriendInvite(buddytable.uid)
            Data.addMyFriend(buddytable)
            gDispatchEvt(EVENT_ID_REC_INVITE_FRIEND_LIST)
            gDispatchEvt(EVENT_ID_FRIEND_AGREE,buddytable.uid);
            gDispatchEvt(EVENT_ID_FRIEND_ADDONE,buddytable);
        end
    end
end
---#####接受
--
--
-----#####领取体力列表
-- function Net.sendBuddyGivelist()
--     local obj = MediaObj:create()
--     Net.sendExtensionMessage(obj,CMD_BUDDY_GIVELIST)
-- end

-- function Net.recBuddyGivelist(evt)
--     local obj = evt.params:getObj("params")
--     if(obj:getByte("ret")~=0)then
--         return
--     end
--     gFriend.giveLeftTime = obj:getByte("num") 
--     if obj:containsKey("list") then
--         gFriend.gives= Net.getBuddyGiveList(obj:getArray("list"))
--     end
--     gDispatchEvt(EVENT_ID_REC_FRIEDN_GIVE) 
-- end

---#####领取体力列表

-----#####领取体力
function Net.sendBuddyReveive(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_RECEIVE)
end

function Net.recBuddyReveive(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFriend.giveLeftTime = obj:getByte("num")
    -- if gFriend.giveLeftTime <= 0 then
    --     Data.redpos.bolBuddyHp = false;
    -- end
    local uid = obj:getLong("uid")
    Data.removeMyFriendGive(uid)
    Net.updateReward(obj:getObj("reward"),2) 
    gDispatchEvt(EVENT_ID_REC_FRIEDN_GIVE,uid) 

end
---#####领取体力
--
-------#####领取全部体力
function Net.sendBuddyReveiveAll()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_BUDDY_RECEIVE_ALL)
end

function Net.recBuddyReveiveAll(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFriend.giveLeftTime = obj:getByte("num"); 
    Data.redpos.bolBuddyHp = false;
    -- if gFriend.giveLeftTime <= 0 then
    --     Data.redpos.bolBuddyHp = false;
    -- end
    Net.updateReward(obj:getObj("reward"),2);
    Data.removeMyFriendGiveAll();
    gDispatchEvt(EVENT_ID_REC_FRIEDN_GIVE_ALL);
end
---#####领取全部体力

---#####添加黑名单
function Net.sendBuddyBlack(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_BLACK)
end



function Net.recBuddyBlack(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("uid")
    local buddytable = Net.parseBuddyObj(obj:getObj("black"))
    Data.addBlackFriend(buddytable)
    Data.removeMyFriend(buddytable.uid);
    -- gDispatchEvt(EVENT_ID_REC_BLACK_FRIEND_LIST)
    gDispatchEvt(EVENT_ID_FRIEND_DEL,buddytable.uid);
    gLogEvent("buddy.black")

end




function Net.recBuddyInitBlack(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFriend.blackList = Net.parseBuddyList(obj:getArray("black"))
    gDispatchEvt(EVENT_ID_REC_BLACK_FRIEND_LIST)

end

---#####添加黑名单
-------#####黑名单
function Net.sendBuddyBlackList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_BUDDY_BLACKLIST)
end

function Net.recBuddyBlackList(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFriend.blackList = Net.parseBuddyList(obj:getArray("list"))
    gDispatchEvt(EVENT_ID_REC_BLACK_FRIEND_LIST)
end
---#####黑名单

-------#####删除黑名单
function Net.sendBuddyDelBlack(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_BUDDY_DEL_BLACK)
end

function Net.recBuddyDelBlack(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("uid")
    Data.removeBlackFriend(uid)
    gDispatchEvt(EVENT_ID_FRIEND_BLACK_DEL,uid)


end
---#####删除黑名单

-------#####服务端主动下发接受邀请的好友
function Net.recReceiveBuddyAccept(evt)
    --A 邀请 B， B同意，服务端主动下发给A，A添加B为好友
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    if obj:containsKey("user")then
        local buddytable = Net.parseBuddyObj(obj:getObj("user"))
        Data.addMyFriend(buddytable)
        gDispatchEvt(EVENT_ID_FRIEND_ADDONE,buddytable);
    end
end


--- 好友阵容

function Net.sendBuddyTeam(uid,type,event)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    if(type)then 
        obj:setByte("type",type)
    end
    Net.sendBuddyTeamType=type
    Net.sendBuddyTeamParam=event
    Net.sendExtensionMessage(obj,CMD_BUDDY_TEAM)
end


function Net.recBuddyTeam(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = Net.parseFormationObj(obj);
    if(Net.sendBuddyTeamParam)then
        gDispatchEvt(Net.sendBuddyTeamParam,ret)
        Net.sendBuddyTeamParam=nil
        return
    end
    if (Data.gChatQuery == true) then
        -- print_lua_table(ret, 4)
        local menu = Panel.popUpVisible(PANEL_FRIEND_INFO,ret,nil,true);
        if(table.count(ret.team) > 0)then
            menu:addBtn("btn_formation");           
        end
        --menu:addBtn("btn_fight");           
        menu:addBtn("btn_chat");           
        --menu:addBtn("btn_mail");            
        menu:addBtn("btn_add");            
        menu:addBtn("btn_black");         
        Data.gChatQuery = false
    else
        Panel.popUpVisible(PANEL_FORMATION,ret);
    end
    gLogEvent("buddy.team")
    -- ret={}
    -- ret.name=obj:getString("name")
    -- ret.exp=obj:getInt("exp")
    -- ret.price=obj:getInt("price")
    -- ret.level=obj:getInt("lv")
    -- ret.id=obj:getInt("id")

    -- ret.cards={}
    -- local cardList=obj:getArray("flist")
    -- if(cardList)then
    --     cardList=tolua.cast(cardList,"MediaArray")
    --     for i=0, cardList:count()-1 do
    --         table.insert(ret.cards,i,Net.parseFriendCard(cardList:getObj(i)))
    --     end
    -- end


    -- Panel.popUp(TIP_PANEL_FRIEND_INFO,ret)


end

