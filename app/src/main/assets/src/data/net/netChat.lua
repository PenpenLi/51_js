
----聊天初始化
function Net.sendChatInit()

    --print ("sendChatInit~")
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_CHAT_INIT)
end


function Net.recChatInit(evt)
    --print ("recChatInit>>")
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    --print ("recChatInt2")
    if obj:containsKey("list") then
        local list = obj:getArray("list");
        Data.clearWorldChat()
        for i=0,list:count()-1 do
            local msgObj = list:getObj(i);
            msgObj = tolua.cast(msgObj,"MediaObj")
            local uid = msgObj:getLong("uid")
            local name = msgObj:getString("name")
            local type = msgObj:getByte("type")
            local msg = msgObj:getString("msg")
            local icon = msgObj:getInt("icon")
            local time = msgObj:getInt("time")
            local ctype = msgObj:getByte("ctype")
            local param = msgObj:getInt("param")
            -- print ("  msg:" .. tostring(msg))
            -- print ("  uid:" .. tostring(uid))
            -- print ("  name:" .. tostring(name))
            -- print ("  icon:" .. tostring(icon))
            -- print ("  time:" .. tostring(time))
            -- print ("  vip:" .. tostring(vip))
            -- print ("  param:" .. tostring(param))
            -- print ("  ctype:" .. tostring(ctype))
            Data.addWorldChat({ctype=ctype,uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time })
        end
    end
    print("dispatchEvent:EVENT_ID_INIT_CHAT")
    gChats.worldInited = true
    gDispatchEvt(EVENT_ID_INIT_CHAT,{type=1})
    gDispatchEvt(EVENT_ID_NEW_CHAT);
end



function Net.sendFamilyChatInit()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_FAMILY_CHAT_INIT)
end


function Net.recFamilyChatInit(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    if obj:containsKey("list") then
        local list = obj:getArray("list");
        Data.clearFamilyChat()
        for i=0,list:count()-1 do
            local msgObj = list:getObj(i);
            msgObj = tolua.cast(msgObj,"MediaObj")

            local uid = msgObj:getLong("uid")
            local name = msgObj:getString("name")
            local vip = msgObj:getByte("vip")
            local arena = msgObj:getInt("arena")
            local gm = msgObj:getBool("gm")
            local ctype = msgObj:getByte("ctype")
            local msg = msgObj:getString("msg")
            local icon = msgObj:getInt("icon")
            local time = msgObj:getInt("time")

            Data.addFamilyChat({uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time,ctype=ctype })
        end
    end
    gChats.familyInited = true
    gDispatchEvt(EVENT_ID_INIT_FAMILY_CHAT,{type=1})

end

function Net.recChatWorld(evt)
    local obj = evt.params:getObj("params")
    print ("Net.recChatWorld:".. tostring(obj:getByte("ret")))
    if(obj:getByte("ret")==0) then
        return
    end
    if (obj:getByte("ret") == 22) then
        gDispatchEvt(EVENT_ID_WORLD_CHAT_BAN)
    end 
end
function Net.recChatMessage(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local type=obj:getByte("type")
    local msg=obj:getString("msg")
    local uid=obj:getLong("uid")
    local name=obj:getString("name")
    local icon = obj:getInt("icon")
    local time = obj:getInt("time")
    local vip = obj:getByte("vip")
    local param = obj:getInt("param")
    local ctype = obj:getByte("ctype")
    print("recChatMessage type:" .. type)

           -- print ("  type:" .. tostring(type))
        print ("  msg:" .. tostring(msg))
        print ("  uid:" .. tostring(uid))
        print ("  name:" .. tostring(name))
        print ("  icon:" .. tostring(icon))
        print ("  time:" .. tostring(time))
        print ("  vip:" .. tostring(vip))
        print ("  param:" .. tostring(param))
        print (" ctype:" .. tostring(ctype))

    if(type~=4 and Data.isInBlackList(uid))then
        return;
    end

    if (type==1 or type==3)then
        Data.addWorldChat({ctype=ctype,uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time }) 
        gDispatchEvt(EVENT_ID_NEW_CHAT)
        if (type==3) then 
            Data.redpos.bolChatWorld = true
        end
        gDispatchEvt(EVENT_ID_REC_CHAT,{type=type, ctype=ctype, uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time })
    elseif type==4 then  --军团聊天
        Data.redpos.bolChatFamily = true;
        Data.addFamilyChat({uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time }) 
        gDispatchEvt(EVENT_ID_REC_CHAT,{type=type, uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time })
        gDispatchEvt(EVENT_ID_NEW_CHAT);
    elseif type==2 then
        Data.addRecentChatRole( uid,name,icon,vip )
        Data.addFriendChat( {uid=uid,fuid=uid,name=name,msg=msg ,}) 
        Data.redpos.bolChatFriend = true;
        if (Data.redpos.bolFriendItem == nil) then 
            Data.redpos.bolChatFriendItem = {}
        end
        Data.redpos.bolChatFriendItem[uid] = true
        gDispatchEvt(EVENT_ID_REC_CHAT,{type=type,uid=uid,fuid=uid,name=name,msg=msg})
    elseif type==5 then
        --Data.addWorldChat({uid=0,tuid=0,name="",msg=msg ,}) 
        print ("system message:")

        Data.redpos.bolChatSystem = true
        Data.addSystemChat({type=type,uid=0,tuid=0,name=name,msg=msg,icon=icon,param=param,time=time})
        gDispatchEvt(EVENT_ID_REC_CHAT,{type=type,uid=0,tuid=0,name=name,msg=msg,icon=icon,param=param,time=time})
    end

end

function Net.sendPrivateChat(uid,name,msg)
    local obj = MediaObj:create()
    obj:setLong("uid", uid)
    obj:setString("name", name)
    obj:setString("msg", msg)
    Net.sendPrivateChatParam={msg=msg,name=name}
    Net.sendExtensionMessage(obj, CMD_CHAT_PRIVATE)
    gLogEventBI("chat.private",{chat_id=tostring(uid),msg=msg})
end

function Net.recPrivateChatMessage(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid=obj:getLong("uid")
    local name=obj:getString("name")
    local icon = obj:getInt("icon")
    local vip = obj:getByte("vip")
    print ("icon:" .. icon)
    print ("vip:" .. vip)
    if(uid==0)then
        return
    end

    local lastMsg=Net.sendPrivateChatParam.msg
    --Data.addRecentChatRole( uid,name,icon,vip)
    Data.addFriendChat({uid=uid,fuid=gUserInfo.id,name=gUserInfo.name,msg=lastMsg ,})
    Net.sendPrivateChatParam=nil
    gDispatchEvt(EVENT_ID_REC_CHAT,{type=2,uid=uid, fuid=gUserInfo.id,name=gUserInfo.name,msg=lastMsg })
end

---聊天信息
function Net.sendWorldChat(msg)
    local obj = MediaObj:create()
    obj:setString("msg", msg)
    Net.sendExtensionMessage(obj, CMD_CHAT_WORLD,nil,nil,true)
    gLogEventBI("chat.world",{msg=msg})
end

function Net.sendFamilyChat(msg,ctype)
    local obj = MediaObj:create()
    obj:setString("msg", msg)
    if (ctype ~= nil) then
        obj:setByte("ctype", ctype)
    end
    Net.sendExtensionMessage(obj, CMD_CHAT_FAMILY)
    gLogEventBI("chat.family",{msg=msg})
end

function Net.sendFamilySevenInvite()
    --local msg = "邀请您加入[\\w{c=ff0000;}封魔台\\]"
    local s1 = gGetWords("familyWords.plist","seven_invite1");
    local s2 = gGetWords("familyWords.plist","seven_invite2");
    local msg = Data.getCurName() .. s1 .. "[\\w{c=ff0000;}" .. s2 .. "\\]"
    --print(msg)
    Net.sendFamilyChat(msg, 1)
end

function Net.sendFamilyStageTip(name)
    local msg = string.format(gGetWords("familyWords.plist","txt_family_stage_act_tip", Data.getCurName(), name))
    Net.sendFamilyChat(msg, 5)
end

function Net.sendArenaBrief(txt, player1, player2, vid)
    print ("Net.sendArenaBrief>>>")
    local msg = txt .."#" .. player1 .."#"..player2 .. "#" .. vid
    local obj = MediaObj:create()
    obj:setString("msg", msg)
    obj:setByte("ctype", 2)
    Net.sendExtensionMessage(obj, CMD_CHAT_WORLD,nil,nil,true)
end