local ChatPanel=class("ChatPanel",UILayer)

function ChatPanel:ctor(chatType,data)

    print ("ChatPanel:ctor:" .. chatType)

    if chatType == 1 then
        --首页左侧移出
        self.appearType = 2
        self:init("ui/ui_talk.map",false,false)
        self.isBlackBgVisible = false
        self.bgVisible =false
        self:getNode("btn_close1"):setVisible(false);
        self.byPassTouch = true;
    elseif chatType == 2 then
        --浮动聊天居中弹出
        self.appearType = 1
        self.adaptiveEnable = false;
        self:init("ui/ui_talk.map");
        self:getNode("btn_close1"):setVisible(true);
        self:getNode("btn_close"):setVisible(false);
        self:getNode("bg_title"):setVisible(false);
    end

    if (gFamilyInfo == nil or gFamilyInfo.familyId == nil or gFamilyInfo.familyId == 0) then
        self:getNode("btn_family"):setVisible(false)
        self:resetLayOut()
    end

    self.messageType = 1 -- 1文字聊天 2语音聊天
    self.sendingVoice = false; -- 语音发送中
    self.skipStop = false; -- 跳过发送
    self.voiceStartTime = 0; -- 语音录制时间
    self.touchEndedTime = 0;
    self:getNode("btn_switch"):setVisible(youmeIsOpen() and (not gSysVoiceClose))
    self:getNode("btn_voice"):setVisible(false)
    self:getNode("layer_voice"):setVisible(false)

    -- DB.getClientParam("CHAT_WORLD_LENGTH");
    self:getNode("txt_input"):setPlaceHolder(gGetWords("noticeWords.plist","talk_input",DB.getClientParam("CHAT_WORLD_LENGTH")));
    print ("familyId:" .. gFamilyInfo.familyId)
    self:initFacePanel()
    self.isMainLayerGoldShow = false
    self.pScrollWorld = self:getNode("scroll")
    self.pScrollWorld.breakTouch = true

    local curType = data.curType;
    local uid = data.uid;

    if curType == nil then
        curType = 1;
    end
    

    if(curType == 1) then
        self:selectBtn("btn_world")
    elseif(curType == 2)then
        self.curUid = uid;
        self:selectBtn("btn_friend")
        self:initRecentRole()
    elseif(curType == 3) then
        self:selectBtn("btn_family")
    end
    self.curType = curType
    self.onAppearedCallback = function()
        self:initChat()
    end

    self:loadWorldChat()
    youmeReset();
    if(youmeIsOpen() and (not gSysVoiceClose))then
        self:loadWorldChatVoice()
    end

    local function onEditCallback(name, sender)
            -- if(name=="changed")then
            --     self:textChanged()
            -- end
        print ("editCallback:" .. name)
        if (name == "began") then
            self.pScrollWorld:setAllItemTouchEnable(false)
            self:getNode("btn_world").touchEnable = false
            self:getNode("btn_friend").touchEnable = false
            self:getNode("btn_family").touchEnable = false
            self:getNode("btn_system").touchEnable = false
        elseif (name == "ended") then
            gCallFuncDelay(0.5, self, self.onEditEnd)
        end
    end
    self:getCurInput():registerScriptEditBoxHandler(onEditCallback)

    self:setCloseCallBack(self.onCloseCallBack);


    local function updateTime()
        if(self.sendingVoice and os.time() - self.voiceStartTime > 30) then
            self:stopAudio(DataEDCode:encode(gAccount:getCurServer().name),tostring(Data.getCurUserId()));
            self.touchEndedTime = socket.gettime();
        end
    end

    self:scheduleUpdate(updateTime,1)
end

function ChatPanel:loadWorldChat()
    local datas = Data.getWorldChats()
    local count = table.getn(datas)
    self:getNode("scroll"):setVisible(true)
    self:getNode("scroll2"):setVisible(false)
    self:getNode("friend_scroll"):setVisible(false)
    self:getNode("friend_bg"):setVisible(false)
    if (count > 8) then 
        latest = {}
        i = 7
        while (i >= 0) do 
            table.insert(latest, datas[count - i])
            i = i-1
        end
        self:refreshWorldChat(latest)
    end
end 

function ChatPanel:loadWorldChatVoice()
    if (youme.data ~= nil)then
        local count = table.getn(youme.data)
        local index = count;
        local latest = {}
        local insertCount = 0;
        if(count > 0)then
            while(insertCount < 8 and index > 0) do
                local data = youme.data[index]
                if(data.receiveID == DataEDCode:encode(gAccount:getCurServer().name))then
                    table.insert(latest, 1, data)
                    insertCount = insertCount + 1;
                end
                index = index - 1;
            end
            for key,var in pairs(latest) do
                if(youmeCheckMessage(var))then
                    self:addWorldChatVoiceItem(var)
                end
            end
        end
    end
end

function ChatPanel:onCloseCallBack()
    -- gMsgWinLayer:show();
end

function ChatPanel:onEditEnd()
    print ("ChatPanel:onEditEnd~")
    self.pScrollWorld:setAllItemTouchEnable(true)
    self:getNode("btn_world").touchEnable = true
    self:getNode("btn_friend").touchEnable = true
    self:getNode("btn_family").touchEnable = true
    self:getNode("btn_system").touchEnable = true
end
function  ChatPanel:events()
    print ("ChatPanel:events~")
    return {EVENT_ID_REC_CHAT, 
            EVENT_ID_REC_CHAT_VOICE,
            EVENT_ID_WORLD_CHAT_BAN,
            EVENT_ID_INIT_CHAT, 
            EVENT_ID_INIT_FAMILY_CHAT,
            EVENT_ID_FAMILY_SEVEN_INFO, 
            EVENT_ID_FAMILY_SPRING_INIT}
end


function ChatPanel:getCurInput()
    return self:getNode("txt_input")
end

function ChatPanel:dealEvent(event,param)
    print ("ChatPanel:dealEvent~:" .. event)
    if(event==EVENT_ID_REC_CHAT)then
        -- print ("dealEvent: EVENT_ID_REC_CHAT")
        local type=param.type
        -- print_lua_table(param, 4)
        if (param.name == gUserInfo.name) then
            self:getCurInput():setText("")
        end
        -- if(type~=self.curType)then
        --     return
        -- end
        if (((type==1 or type==3) and self.curType==1) or (type==4 and self.curType==3) or (type==5 and self.curType==4)) then
            self:addWorldChatItem(param)
        elseif(type==2 and param.uid==self.curUid)then
            self:addFriendChatItem(param)
        end
    elseif(event==EVENT_ID_REC_CHAT_VOICE) then
        self:addWorldChatVoiceItem(param)
    elseif(event==EVENT_ID_INIT_CHAT) then
        print ("dealEvent: EVENT_ID_INIT_CHAT")
        self:initChat(1)
    elseif(event==EVENT_ID_INIT_FAMILY_CHAT) then
        print ("dealEvent: EVENT_ID_INIT_FAMILY_CHAT")
        self:initChat(3)
    elseif(event==EVENT_ID_FAMILY_SEVEN_INFO) then
        Panel.popBack(self:getTag())
        Panel.popUp(PANEL_FAMILY_SEVEN)
    elseif(event==EVENT_ID_WORLD_CHAT_BAN) then
        --local fakeData = {}
        local uid = Data.getCurUserId()
        local name =Data.getCurName()
        local time = os.time()
        local icon = Data.getCurIconFrame()
        --fakeData.vip = Data.getCurVip()
        local msg = string.filter(self:getCurInput():getText())
        Data.addWorldChat({type=1,uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time }) 
        self:addWorldChatItem({type=1,uid=uid,tuid=0,name=name,msg=msg,icon=icon,time=time})
        self:getCurInput():setText("")
    end

end


function ChatPanel:refreshRecentRole()
    for key, item in pairs(self:getNode("friend_scroll").items) do
        if(item.curData.uid==self.curUid)then
            item:getNode("bg"):setVisible(true)
            item:getNode("txt_name"):setColor(cc.c3b(82,28,4))
        else
            item:getNode("bg"):setVisible(false)
            item:getNode("txt_name"):setColor(cc.c3b(255,204,0))
        end
    end

end

function ChatPanel:initRecentRole()
    print ("initRecentRole()~~")
    local scrollFriend = self:getNode("friend_scroll")
    scrollFriend.breakTouch = true;
    scrollFriend:clear()
    if (gChats.recent ~= nil) then 
        for key, var in pairs(gChats.recent) do
            local item=ChatFriendItem.new()
            item:setData(var)
        
            if(self.curUid==nil)then
                self.curUid=var.uid
            end
            item.selectItemCallback=function (data,idx)
                print("selectItemCallback:" .. var.uid)
                self.curUid=var.uid
                
                self:refreshRecentRole()
                if(Data.redpos.bolChatFriendItem ~= nil) then
                    Data.redpos.bolChatFriendItem[item.curData.uid] = false
                end
                self:initChat(2)
            end
            scrollFriend:addItem(item)
            self:refreshRecentRole()
        end
    end

    -- for key, friend in pairs(gFriend.myFriends) do
    --     if(gChats.recent == nil or gChats.recent[friend.uid] == nil) then 
    --         local item = ChatFriendItem.new()
    --         item:setData(friend)
    --         --item:layout()
    --         scrollFriend:addItem(item)

    --         if(self.curUid==nil)then
    --             self.curUid=friend.uid
    --         end
    --         item.selectItemCallback=function (data,idx)
    --             self.curUid=friend.uid
    --             self:refreshRecentRole()
    --         end
    --     end
    -- end
    scrollFriend:layout()
end

function ChatPanel:refreshWorldChat(datas)
    print ("refreshWorldChat")
    --print_lua_table(datas, indent)
    Scene.clearLazyFunc("chatItem")
    self.pScrollWorld:clear()
    --print("add chatItem~")
    local count = table.getn(self.pScrollWorld:getAllItem());
    --print_lua_table(datas, 4)
    
    if (datas == nil) then 
        return
    end 

    local allCount = table.getn(datas);
    for key, var in pairs(datas) do
        local item=ChatItem.new("world")
        if (var.uid == Data.getCurUserId()) then
            item = ChatItem.new("world_me")
        elseif (var.uid == 0) then 
            item = ChatItem.new("gm")
        end

        --print ("??????")
        if key >= allCount - 8 then
            item:setData(var, self.curType)
        else
            item:setLazyData(var, self.curType)
        end
        --print (".........")
        item:layout()
        self.pScrollWorld:addItem(item)
    end
    Scene.setAllLazyFuncDone(self,self.scrollLayout)
    self:scrollLayout();
end

function ChatPanel:scrollLayout()
    self.pScrollWorld:layout(count==0)
    self.pScrollWorld.container:setPositionY(0)    
end

function ChatPanel:onPopback()
    Scene.clearLazyFunc("chatItem")
end

function ChatPanel:addWorldChatItem(data)
    print("addWorldChatItem...")
    local item = nil
    if (data.uid == Data.getCurUserId()) then 
        item = ChatItem.new("world_me")
    elseif (data.uid == 0) then
        item = ChatItem.new("gm")
    else
        item = ChatItem.new("world")
    end

    item:setData(data, self.curType)
        --print (".........")
    item:layout()
    self.pScrollWorld:addItem(item)
    self.pScrollWorld:layout(count==0)
    if(self.pScrollWorld.container:getPositionY()>-200) or (data.uid == Data.getCurUserId()) then
        self.pScrollWorld.container:setPositionY(0)
    end
end

function ChatPanel:addWorldChatVoiceItem(data)
    local item = nil
    if (data.senderID == tostring(Data.getCurUserId())) then 
        item = ChatVoiceItem.new("world_me")
    elseif (data.senderID == "0") then
        item = ChatVoiceItem.new("gm")
    else
        item = ChatVoiceItem.new("world")
    end

    item:setData(data, self.curType)

    item:layout()
    self.pScrollWorld:addItem(item)
    self.pScrollWorld:layout(count==0)
    if(self.pScrollWorld.container:getPositionY()>-200) or (data.uid == Data.getCurUserId()) then
        self.pScrollWorld.container:setPositionY(0)
    end
end

function ChatPanel:refreshFriendChat(datas)
    local friendChat = self:getNode("scroll2")
    local scrollHeight = friendChat:getContentSize().height

    friendChat:clear()
    --print("add chatItem~")
    local count = table.getn(friendChat:getAllItem());
    --print_lua_table(datas, 4)
    print ("myId is:" .. Data.getCurUserId())

    for key, var in pairs(datas) do
        local item=ChatItem2.new("friend1")
        if (var.fuid == Data.getCurUserId()) then
            item = ChatItem2.new("friend1_me")
        end

        item:setData(var, self.curType)
        item:layout()
        friendChat:addItem(item)
        --allItemHeights = allItemHeights + item:getContentSize().height
    end
    friendChat:layout(count==0)

    if(friendChat.container:getContentSize().height > scrollHeight - 30) then
        friendChat.container:setPositionY(0)
    end
end

function ChatPanel:addFriendChatItem(data) 
    local friendChat = self:getNode("scroll2")
    local scrollHeight = friendChat:getContentSize().height
    local item=ChatItem2.new("friend1")
    if (data.fuid == Data.getCurUserId()) then
        item = ChatItem2.new("friend1_me")
    end

    item:setData(data, self.curType)
    item:layout()
    friendChat:addItem(item)
    friendChat:layout(count==0)
    if(friendChat.container:getContentSize().height > scrollHeight - 30) then
        friendChat.container:setPositionY(0)
    end
end
function ChatPanel:initChat(type)
    if (type == nil) then
        type = self.curType
    end
    self.curType=type
    local datas={}
    --scroll:clear()
    local btns={
        "btn_world",
        "btn_friend",
        "btn_family",
        "btn_system"
    }
    self:selectBtn(btns[self.curType])

    if(self.curType==1)then
        self:getNode("scroll"):setVisible(true)
        self:getNode("scroll2"):setVisible(false)
        self:getNode("friend_scroll"):setVisible(false)
        self:getNode("friend_bg"):setVisible(false)
        if(gChats.worldInited~=true)then
            Net.sendChatInit()
            return
        else
            datas=Data.getWorldChats()
        end
        --self.curUid=nil
    elseif(self.curType == 2) then
        self:getNode("scroll"):setVisible(false)
        self:getNode("scroll2"):setVisible(true)
        self:getNode("friend_scroll"):setVisible(true) 
        self:getNode("friend_bg"):setVisible(true)
        --print ("curUid is: " .. self.curUid)
        --self:initRecentRole()
        if( self.curUid == nil or gChats.friend == nil or gChats.friend[self.curUid] ==nil)then
            print("Net.sendBuddyList()")
            -- Net.sendBuddyList()
            --return
        else
            --print_lua_table(gFriend.myFriends, 4)
            print ("curUid is: " .. self.curUid)
            datas=gChats.friend[self.curUid]
        end
    elseif(self.curType == 3) then
        self:getNode("scroll"):setVisible(true)
        self:getNode("scroll2"):setVisible(false)
        self:getNode("friend_scroll"):setVisible(false)
        self:getNode("friend_bg"):setVisible(false)
        if(gChats.familyInited~=true)then
            Net.sendFamilyChatInit()
            return
        else
            datas=Data.getFamilyChats()
            print ("get family chat data:")
            --print_lua_table(datas, 4)
        end
    elseif(self.curType == 4) then
        self:getNode("scroll"):setVisible(true)
        self:getNode("scroll2"):setVisible(false)
        self:getNode("friend_scroll"):setVisible(false)
        self:getNode("friend_bg"):setVisible(false)
        datas=Data.getSystemChats()
        print ("get system chat data:")
            --print_lua_table(datas, 4)
    end
    -- if(datas==nil)then
    --     return
    -- end

    if (self.curType == 2) then
        self:refreshFriendChat(datas)
    else 
        self:refreshWorldChat(datas)
        if(youmeIsOpen() and (not gSysVoiceClose))then
            self:loadWorldChatVoice()
        end
    end
    self.dirty=true
    --self:layout()
end


-- function ChatPanel:layout()
--     print ("ChatPanel:layout～")
--     local scroll = nil
--     if(self.curType == 1) then 
--         scroll = self:getNode("scroll")
--         --self:layoutScroll(scroll, true)
--     elseif(self.curType == 2) then
--         scroll = self:getNode("scroll2")
--         --self:layoutScroll(scroll, false)
--     end
    
-- end

function ChatPanel:resetBtnTexture()
    local btns={
        "btn_world",
        "btn_friend",
        "btn_family",
        "btn_system"
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function ChatPanel:selectBtn(name)
    self.selectedBtn = name
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end


function ChatPanel:initFacePanel()
    local size=self:getNode("face_container"):getContentSize()
    local scale=0.72
    local width=90*scale
    local height=90*scale
    for i=1, 20 do
        local id=i
        if(id<10)then
            id="0"..i
        end
        local sprite=cc.Sprite:create("images/biaoqing/"..id..".png")
        local bg = cc.Sprite:create("images/ui_9gong/di-9gong-talk2.png")
        self:getNode("face_container"):addChild(bg)
        self:getNode("face_container"):addChild(sprite)
        bg:setScale(scale)
        sprite:setScale(scale)
        bg:setPositionX(((i-1)%10)*width+width/2)
        sprite:setPositionX(((i-1)%10)*width+width/2)
        bg:setPositionY(size.height-math.floor((i-1)/10)*height-height/10 - 25)
        sprite:setPositionY(size.height-math.floor((i-1)/10)*height-height/10 - 25)
        self:addTouchNode(sprite,"btn_face"..id,"1")
    end
end

function ChatPanel:onTouchBegan(target,touch)
    print("ChatPanel:onTouchBegan")
    print("socket.gettime() = "..socket.gettime())
    print("self.touchEndedTime = "..self.touchEndedTime)
    if(target.touchName == nil)then
        return;
    end
    self.preLocation = touch:getLocation()
    if target.touchName=="btn_voice"then
        if Unlock.isUnlock(SYS_CHAT) == false or self.sendingVoice or socket.gettime() - self.touchEndedTime < 0.5 then
            self.skipStop = true;
            return
        end 
        if(gGetCurServerTime() - youme.lastSendTime < 3)then
            self.skipStop = true;
            gShowNotice(gGetWords("youmeWords.plist","tooOften"))
            return
        end
        local isSend = youmeSendAudioMessage(DataEDCode:encode(gAccount:getCurServer().name),ChatType_RoomChat);
        if(isSend)then
            self.sendingVoice = true;
            self:getNode("layer_voice"):setVisible(true)
            self.voiceStartTime = os.time();
        else
            self.skipStop = true;
        end
    end
end

function ChatPanel:onTouchMoved(target,touch)
    print("ChatPanel:onTouchMoved")
    if(self.sendingVoice)then
        local location = touch:getLocation() -- 取消发送
        if(math.abs(location.y-self.preLocation.y)>20 or math.abs(location.x-self.preLocation.x)>20)then
            self:cancleAudio();
            return;
        end
    end
end

function ChatPanel:onTouchEnded(target,touch)
    print("ChatPanel:onTouchEnded")
    if(self.sendingVoice)then
        local location = touch:getLocation() -- 取消发送
        if(math.abs(location.y-self.preLocation.y)>20 or math.abs(location.x-self.preLocation.x)>20)then
            self:cancleAudio();
            return;
        end
    end
    if(target.touchName == nil)then
        return;
    end
    -- print ("onTouchEnded:" .. target.touchName)
    if  target.touchName=="btn_close" or target.touchName=="btn_close1" then
        print ("touch:btn_close")
        Panel.popBack(self:getTag())
        youmeReset();
        -- gMsgWinLayer:setVisible(false)
    elseif  target.touchName=="btn_world"then
        if (self.curType == 1) then
            return
        end
        Scene.clearLazyFunc("chatItem")
        self:initChat(1)
        self:selectBtn(target.touchName)
        Data.redpos.bolChatWorld = false;
    elseif target.touchName=="btn_face"then
        self:getNode("face_panel"):setVisible(not self:getNode("face_panel"):isVisible())
        self:getNode("face_tail"):setVisible(not self:getNode("face_tail"):isVisible())
        if(self.initedFace~=true)then
            self.initedFace=true
            self:initFacePanel()
        end
    elseif  target.touchName=="btn_friend"then
        if (self.curType == 2) then
            return
        end
        Scene.clearLazyFunc("chatItem")
        self:initRecentRole()
        self:initChat(2)
        self:selectBtn(target.touchName)
        Data.redpos.bolChatFriend = false;
    elseif  target.touchName=="btn_family"then
        if (self.curType == 3) then
            return
        end
        Scene.clearLazyFunc("chatItem")
        self:initChat(3)
        self:selectBtn(target.touchName)
        Data.redpos.bolChatFamily = false
    elseif  target.touchName=="btn_system"then
        if (self.curType == 4) then
            return
        end
        Scene.clearLazyFunc("chatItem")
        self:initChat(4)
        self:selectBtn(target.touchName)
        Data.redpos.bolChatSystem = false;
    elseif target.touchName=="btn_send"then
        if Unlock.isUnlock(SYS_CHAT) == false then
            return
        end 
        if (string.filter(self:getCurInput():getText()) == "") then
            return
        end
        if (string.filter(self:getCurInput():getText()) == "sharesdk") then
            print ("share Content~")
            gShareText(23,"你好你好你好")
            return
        end

        if(self.curType==2)then
            if(self.curUid ~= nil) then
                Net.sendPrivateChat(self.curUid,"",string.filter(self:getCurInput():getText()))
            end
        elseif (self.curType == 1) then
            Net.sendWorldChat(string.filter(self:getCurInput():getText()))
        elseif (self.curType == 3) then
            Net.sendFamilyChat(string.filter(self:getCurInput():getText()))
            if (string.filter(self:getCurInput():getText()) == "testseven") then
                Net.sendFamilySevenInvite()
            end
        end 
        self:getNode("face_panel"):setVisible(false)
        self:getNode("face_tail"):setVisible(false)
        
    elseif  string.find( target.touchName,"btn_face")   then
        local pos= (string.sub(target.touchName,9,string.len(target.touchName)))
        print ("pos:" .. pos)
        self:getNode("face_panel"):setVisible(false)
        self:getNode("face_tail"):setVisible(false)
        self:getCurInput():setText( string.filter(self:getCurInput():getText()).."["..pos.."]")
        local param = {}
        param['id'] = tostring(pos)
        gLogEvent("chat.emoicon", param)
        --self:setRTFString("txt_input", string.filter(self:getCurInput():getText()).."++"..pos.."++")
    elseif target.touchName=="btn_voice"then
        -- youmeStopAudioMessage(DataEDCode:encode(gAccount:getCurServer().name),tostring(Data.getCurUserId()))
        if(self.skipStop)then
            self.skipStop = false;
            return
        end
        if(self.sendingVoice)then
            self:stopAudio(DataEDCode:encode(gAccount:getCurServer().name),tostring(Data.getCurUserId()));
            self.touchEndedTime = socket.gettime();
        end
    elseif target.touchName=="btn_switch"then
        self:switchMessageType();
    end
end

function ChatPanel:stopAudio(groupID,senderID)
    self.sendingVoice = false;
    self:getNode("layer_voice"):setVisible(false)
    self.voiceStartTime = 0;
    youmeStopAudioMessage(groupID,senderID)
end

function ChatPanel:cancleAudio()
    self.sendingVoice = false;
    self:getNode("layer_voice"):setVisible(false)
    self.voiceStartTime = 0;
    youmeCancleAudioMessage();
end

function ChatPanel:switchMessageType()
    if(self.messageType == 1)then
        self.messageType = 2;
        self:getNode("chat_text"):setVisible(false);
        self:getNode("btn_voice"):setVisible(true);
        self:changeTexture("icon_swtich","images/voice/button_voice.png")
    elseif(self.messageType == 2)then
        self.messageType = 1;
        self:getNode("chat_text"):setVisible(true);
        self:getNode("btn_voice"):setVisible(false);
        self:changeTexture("icon_swtich","images/voice/button_word.png")
    end
end

return ChatPanel