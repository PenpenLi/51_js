
-- 聊天类型
ChatType_Unknow = 0;
ChatType_PrivateChat = 1;
ChatType_RoomChat = 2;
ChatType_GroupChat = 3;

-- 消息类型
MessageBodyType_Unknow = 0;
MessageBodyType_TXT = 1;
MessageBodyType_CustomMesssage = 2;
MessageBodyType_Emoji = 3;
MessageBodyType_Image = 4;
MessageBodyType_Voice = 5;
MessageBodyType_Video = 6;
MessageBodyType_File = 7;

-- 发送文件类型
FileType_Other = 0;
FileType_Audio = 1;
FileType_Image = 2;
FileType_Video = 3;

-- 对外的错误码 -----------------------------
-- 这上面是服务器的，要和服务器的一致，如果这里没有的话，会强制转换成一个数字
YouMeIMErrorcode_Success = 0;
YouMeIMErrorcode_EngineNotInit = 1;
YouMeIMErrorcode_NotLogin = 2;
YouMeIMErrorcode_ParamInvalid = 3;
YouMeIMErrorcode_TimeOut = 4;
YouMeIMErrorcode_StatusError = 5;
YouMeIMErrorcode_SDKInvalid = 6;
YouMeIMErrorcode_AlreadyLogin = 7;
YouMeIMErrorcode_ServerError = 8;
YouMeIMErrorcode_NetError = 9;
YouMeIMErrorcode_LoginSessionError = 10;
YouMeIMErrorcode_NotStartUp = 11;
YouMeIMErrorcode_FileNotExist = 12;
YouMeIMErrorcode_SendFileError = 13;
YouMeIMErrorcode_UploadFailed = 14;

-- 服务器的错误码
YouMeIMErrorcode_ALREADYFRIENDS = 1000;
YouMeIMErrorcode_LoginInvalid = 1001;

-- 语音部分错误码
YouMeIMErrorcode_PTT_Start = 2000;
YouMeIMErrorcode_PTT_Fail = 2001;
YouMeIMErrorcode_PTT_DownloadFail = 2002;
YouMeIMErrorcode_PTT_GetUploadTokenFail = 2003;
YouMeIMErrorcode_PTT_UploadFail = 2004;
YouMeIMErrorcode_PTT_NotSpeech = 2005;
YouMeIMErrorcode_Fail = 10000;
-- 对外的错误码 -----------------------------

youme = {}
youme.data = {};
youme.datafilename = ""
youme.isNeedLogin = false;
youme.isNeedInit = true;
youme.isLogin = false;
youme.eventdata = {};
youme.playing = false;
youme.playtime = 0;
youme.playMessage = {};
youme.playEffectId = nil;
youme.playChatVoiceItem = nil;
youme.lastSendTime = 0;
youme.recordStartTime = 0;
youme.m_requestID = 0; --消息ID
youme.m_iChatType = ""; --聊天类型
youme.m_strRecvID = ""; --接收者ID
youme.m_param = {}; --附加参数
youme.youmeaudioPath = ""; --语音路径

--创建一个实例
local yimInstance = nil;

if(cc.YIM)then
    yimInstance = cc.YIM:create();
else
    yimInstance = {};
end

yimInstance.OnLogin = function (errorcode,youmeID)
    print("OnLogin errorcode:" .. errorcode .. " youmeID:" .. youmeID)
    -- yimInstance:sendAudioMessage("winnie",1)
    -- yimInstance:joinChatRoom("1111")
    if(errorcode == YouMeIMErrorcode_Success)then
        youme.isLogin = true;
        youmeJoinChatRoom(DataEDCode:encode(gAccount:getCurServer().name));
        if (gFamilyInfo ~= nil and gFamilyInfo.familyId ~= nil and gFamilyInfo.familyId ~= 0) then
            youmeJoinChatRoom(tostring(gFamilyInfo.familyId));
        end
    else
        youmeLogout();
        youmeLogin(tostring(Data.getCurUserId()),tostring(Data.getCurUserId()),"");
    end
end

yimInstance.OnLogout = function ()
    print("11: OnLogout")
end

yimInstance.OnDownload = function (serial,errorcode,strSavepath)
    print("OnDownload：" .. serial .. " errorcode:" .. errorcode .. " path:" .. strSavepath)

    local data =  {}
    data.messageID = serial;
    data.audioPath = strSavepath;
    
    local extra=gAccount:tableToString(data)
    youmeRespone("youmeOnDownload",extra)
end


--消息回掉. 普通消息发送回掉接口
yimInstance.OnSendMessageStatus = function(serial,errorcode)

    print("OnSendMessageStatus" .. serial .. " errorcode:" .. errorcode)
end

yimInstance.OnSendAudioMessageStatus = function(serial,errorcode,content,localpath,duration)

    print("OnSendAudioMessageStatus" .. serial .. " errorcode:" .. errorcode .. " content:" .. content .. " localpath:" .. localpath .. " duration:" .. duration)

    local data={}
    data.messageID = serial
    data.messageType = tostring(MessageBodyType_Voice)
    data.text = content
    data.audioTime = tostring(duration)
    data.audioPath = localpath
    data.errorcode = tostring(errorcode)
    data.groupID=youme.m_param.groupID
    data.senderID=youme.m_param.senderID
    data.timestamp=youme.m_param.timestamp
    data.name=youme.m_param.name
    data.icon=youme.m_param.icon
    data.chatType=youme.m_iChatType
    data.receiveID=youme.m_strRecvID

    local extra=gAccount:tableToString(data)
    youmeRespone("youmeOnSendAudioMessageStatus",extra)
end

yimInstance.OnRecvMessage = function(bodytype,chattype, serial,recvid,senderid,content,params,duration)

    print("OnRecvMessage" .. bodytype .. " chattype:" .. chattype .. " serial:" .. serial .. " recvid:" .. recvid .. " senderid:" .. senderid .. " content:" .. content .. " param:" .. params .. " duration: " .. duration)
  

    local data =  json.decode(params)
    data.messageID = serial;
    data.chatType = tostring(chattype);
    data.audioTime = tostring(duration);
    data.messageType = tostring(bodytype);
    data.receiveID = recvid;
    data.groupID = "";
    data.senderID = senderid;
    data.text = content;
    
    local extra=gAccount:tableToString(data)
    youmeRespone("youmeOnRecvMessage",extra)

    if bodytype == 5 then
        -- 音频文件可以下载
        yimInstance:downloadAudioFile(serial,youme.youmeaudioPath.."/"..serial..".wav")
    
    end
end

yimInstance.OnJoinChatroom = function(chatroomid ,errorcode)

    print("OnJoinChatroom id：" .. chatroomid .. "errorcode:" .. errorcode)
end

function youmeReset()
    youme.playing = false;
    youme.playtime = 0;
    youme.playMessage = {};
    youme.playEffectId = nil;
    youme.playChatVoiceItem = nil;
end

function youmeInit()
    print("youmeInit ...")
    -- if YouMeImEngineImp then
        cc.Director:getInstance():getScheduler():scheduleScriptFunc(youmeUpdate,1,false)
    -- end
    if(youmeIsOpen())then
        -- yimInstance = cc.YIM:create()
        yimInstance.registerScriptHandler(yimInstance,yimInstance.OnLogin,yimInstance.OnLogout,yimInstance.OnDownload,yimInstance.OnSendMessageStatus,yimInstance.OnSendAudioMessageStatus,yimInstance.OnRecvMessage,yimInstance.OnJoinChatroom);
        local ierrorcode = yimInstance:init("YOUMEE56FD77848779EDF1B79525EFF4FF4AC0508A617","tKzWacB2aYRe851Ro1AUgUx2E1KzLmGsLiuKdelpUbyBKHkcxE94la4n3ugy3xPPTgEYVkZJWxQohMWIXIHqr/WDpnsyjTMwnwtv8Mcq7dN8Y8wviGD8zqjmTfDPwITQ0ytvvNqFUuuGE0e9Kp+1Cz8HaDKuM+rj7+ghHFhHpYsBAAE=")
        print("初始化状态:" .. ierrorcode)
        youme.youmeaudioPath = getWritePath().."/youmeaudio";
        cc.FileUtils:getInstance():createDirectory(youme.youmeaudioPath)
        yimInstance:setAudioCacheDir(youme.youmeaudioPath)
        print("设置语音缓存目录")
    end
end

function youmeUnInit()
    print("youmeUnInit ...")
    if(youmeIsOpen())then
        yimInstance:unInit()
    end
end

function youmeUpdate(dt)
    if(youme.playing and os.time() - youme.playtime > toint(youme.playMessage.audioTime))then
        youme.playing = false;
        AudioEngine.resumeMusic();
        if(youme.playChatVoiceItem ~= nil)then
            youme.playChatVoiceItem:stopVoice();
            youme.playChatVoiceItem = nil;
        end
    end
end

function youmeIsOpen()
    if(gIsWindows() or gIsMac())then
        return false
    end
    if cc.YIM and (not Module.isClose(SWITCH_YOUME_VOICE)) then
        return true
    end
    return false
end

function youmeLogin(strYouMeID,strPasswd,strOldPasswd)
    if (not gSysVoiceClose) and youmeIsOpen() then
        -- YouMeImEngineImp:getInstance():login(strYouMeID,strPasswd,strOldPasswd)
        local ierrorcode = yimInstance:login(strYouMeID,strPasswd);
        print("登陆:" .. ierrorcode)  
        youme.datafilename = getWritePath().."/youmeaudio/"..Data.getCurUserId().."youmedata.xml";
        youmeReadData();
        youme.eventdata = {};
    end
end

function youmeLogout()
    if (not gSysVoiceClose) and youmeIsOpen() and youme.isLogin == true then
        -- YouMeImEngineImp:getInstance():logout()
        yimInstance:logout()
        youmeSaveData();
        youme.isNeedLogin = true;
        youme.isLogin = false;
        youme.eventdata = {};
    end
end

function youmeJoinChatRoom(strGroupID)
    if (not gSysVoiceClose) and youmeIsOpen() then
        -- YouMeImEngineImp:getInstance():joinChatRoom(strGroupID)
        yimInstance:joinChatRoom(strGroupID)
    end
end

function youmeLeaveChatRoom(strGroupID)
    if (not gSysVoiceClose) and youmeIsOpen() then
        -- YouMeImEngineImp:getInstance():leaveChatRoom(strGroupID)
        yimInstance:leaveChatRoom(strGroupID)
    end
end

function youmeSendAudioMessage(strRecvID,chatType)
    if(youme.playing)then
        youme.playing = false;
        gStopEffect(youme.playEffectId)
        if(youme.playChatVoiceItem ~= nil)then
            youme.playChatVoiceItem:stopVoice();
        end
    end
    if (not gSysVoiceClose) and youmeIsOpen() then
        if(youme.recordStartTime == 0)then
            AudioEngine.pauseMusic()
            -- YouMeImEngineImp:getInstance():sendAudioMessage(strRecvID,chatType)
            -- yimInstance:sendAudioMessage(strRecvID,chatType)
            yimInstance:sendOnlyAudioMessage(strRecvID,chatType)
            print("strRecvID = "..strRecvID)
            print("strRecvID = "..chatType)
            youme.m_iChatType = tostring(chatType); --聊天类型
            youme.m_strRecvID = strRecvID; --接收者ID
            youme.recordStartTime = socket.gettime()--os.clock()
            return true;
        else
            -- gShowNotice(gGetWords("youmeWords.plist","tooOften"))
            youmeCancleAudioMessage();
            return false;
        end
    end
end

function youmeCancleAudioMessage()
    if (not gSysVoiceClose) and youmeIsOpen() then
        -- YouMeImEngineImp:getInstance():cancleAudioMessage()
        yimInstance:cancleAudioMessage()
        AudioEngine.resumeMusic();
        youme.recordStartTime = 0;
    end
end

function youmeStopAudioMessage(groupID,senderID)
    if (not gSysVoiceClose) and youmeIsOpen() then
        -- print("socket.gettime() = "..socket.gettime())
        -- print("youme.recordStartTime = "..youme.recordStartTime)
        if(socket.gettime() - youme.recordStartTime >= 0.5) then
            local data={}
            data.groupID=groupID
            data.senderID=senderID
            data.timestamp=gGetCurServerTime()
            data.name=Data.getCurName()
            data.icon=tostring(Data.getCurIcon())
            local extra=gAccount:tableToString(data)
            youme.m_param = data;
            -- YouMeImEngineImp:getInstance():stopAudioMessage(extra)
            local ierrorcode = yimInstance:stopAudioMessage(extra)
            print("param = "..extra)
            AudioEngine.resumeMusic();
            youme.lastSendTime = gGetCurServerTime();
            youme.recordStartTime = 0;
        else
            gShowNotice(gGetWords("youmeWords.plist","tooShore"))
            youmeCancleAudioMessage()
            youme.recordStartTime = 0;
        end
    end
end


function youmeRespone(param1,param2)
    local message = nil;
    message = youmeUpdateData(param2)
    local parseTable =  json.decode(param2)
    if (parseTable ~= nil)then
        if(message ~= nil)then
            local strmessage = json.encode(message)
            print("strmessage = "..strmessage);
        end
        if(param1 == "youmeStopAudioMessage")then
        elseif(param1 == "youmeOnRecvMessage")then
        elseif(param1 == "youmeOnSendAudioMessageStatus")then
            print("youmeOnSendAudioMessageStatus messageID ="..parseTable.messageID)
            if(message ~= nil and message.id ~= "")then
                if(youmeCheckMessage(message))then
                    gDispatchEvt(EVENT_ID_REC_CHAT_VOICE,message)
                else
                    gShowNotice(gGetWords("youmeWords.plist","formatError"))
                end
                -- local event = {}
                -- event.eventID = EVENT_ID_REC_CHAT_VOICE;
                -- event.messageID = message.messageID;
                -- table.insert(youme.eventdata,event)
            end
        elseif(param1 == "youmeOnDownload")then
            if(message ~= nil and message.id ~= "")then
                if(youmeCheckMessage(message))then
                    gDispatchEvt(EVENT_ID_REC_CHAT_VOICE,message)
                else
                    gShowNotice(gGetWords("youmeWords.plist","formatError"))
                end
                -- local event = {}
                -- event.eventID = EVENT_ID_REC_CHAT_VOICE;
                -- event.messageID = message.messageID;
                -- table.insert(youme.eventdata,event)
            end
        elseif(param1 == "youmeOnLogin")then
            if(parseTable.errorcode ~= nil)then
                local code = toint(parseTable.errorcode);
                if(code == YouMeIMErrorcode_Success)then
                    youme.isLogin = true;
                    youmeJoinChatRoom(DataEDCode:encode(gAccount:getCurServer().name));
                    if (gFamilyInfo ~= nil and gFamilyInfo.familyId ~= nil and gFamilyInfo.familyId ~= 0) then
                        youmeJoinChatRoom(tostring(gFamilyInfo.familyId));
                    end
                    -- local event = {}
                    -- event.eventID = EVENT_ID_YOUME_JOIN_CHAT_ROOM;
                    -- table.insert(youme.eventdata,event)
                else
                    youmeLogout();
                    youmeLogin(tostring(Data.getCurUserId()),tostring(Data.getCurUserId()),"");
                    -- local event = {}
                    -- event.eventID = EVENT_ID_YOUME_LOGIN;
                    -- table.insert(youme.eventdata,event)
                    -- youmeLogout()
                end
            end
        end
    end
end

function youmePlayAudio(message,chatVoiceItem)
    if(message ~= nil and message.audioPath ~= nil)then
        print("youmePlayAudio audioPath ="..message.audioPath)
        if(youme.playing)then
            if(youme.playMessage.messageID == message.messageID)then
                youme.playing = false;
                gStopEffect(youme.playEffectId)
                return false;
            else
                gStopEffect(youme.playEffectId)
                AudioEngine.pauseMusic()
                -- gDispatchEvt(EVENT_ID_VOICE_STOP_FLA,youme.playMessage)
                if(youme.playChatVoiceItem ~= nil)then
                    youme.playChatVoiceItem:stopVoice();
                end
                youme.playEffectId = AudioEngine.playEffect(message.audioPath);
                youme.playMessage = message;
                youme.playChatVoiceItem = chatVoiceItem;
                youme.playtime = os.time();
                youme.playing = true;
                return true;
            end
        else
            AudioEngine.pauseMusic()
            if(youme.playChatVoiceItem ~= nil)then
                youme.playChatVoiceItem:stopVoice();
            end
            youme.playEffectId = AudioEngine.playEffect(message.audioPath);
            youme.playMessage = message;
            youme.playChatVoiceItem = chatVoiceItem;
            youme.playtime = os.time();
            youme.playing = true;
            return true;
        end
    end
    return false;
end

function youmeUpdateData(param2)
    print("youmeUpdateData start")
    local parseTable =  json.decode(param2)
    if (parseTable ~= nil and parseTable.messageID ~= nil)then
        local message = youmeGetMessage(parseTable.messageID);
        print("youmeUpdateData messageID = "..parseTable.messageID)
        if(message == nil)then
            message = {};
            table.insert(youme.data,message)
            -- print("youmeUpdateData table.insert len = "..table.getn(youme.data))
        end
        if(parseTable.messageID ~= nil)then
            message.messageID = parseTable.messageID;
        end
        if(parseTable.chatType ~= nil)then
            message.chatType = parseTable.chatType;
        end
        if(parseTable.messageType ~= nil)then
            message.messageType = parseTable.messageType;
        end
        if(parseTable.receiveID ~= nil)then
            message.receiveID = parseTable.receiveID;
        end
        if(parseTable.groupID ~= nil)then
            message.groupID = parseTable.groupID;
        end
        if(parseTable.senderID ~= nil)then
            message.senderID = parseTable.senderID;
        end
        if(parseTable.timestamp ~= nil)then
            message.timestamp = parseTable.timestamp;
        end
        if(parseTable.audioTime ~= nil)then
            message.audioTime = parseTable.audioTime;
        end
        if(parseTable.audioPath ~= nil)then
            message.audioPath = parseTable.audioPath;
        end
        if(parseTable.text ~= nil)then
            message.text = parseTable.text;
        end
        if(parseTable.name ~= nil)then
            message.name = parseTable.name;
        end
        if(parseTable.icon ~= nil)then
            message.icon = parseTable.icon;
        end
        -- for key,var in pairs(youme.data) do
        --     print("data time ="..var.timestamp)
        -- end
        return message;
    end
    -- if(youme.data)then
    --     print("youme.data len = "..table.getn(youme.data))
    -- end
    print("youmeUpdateData end")
    return nil
end

function youmeCheckMessage(message)
    if(message.messageID == nil)then
        return false;
    end
    if(message.chatType == nil)then
        return false;
    end
    if(message.messageType == nil)then
        return false;
    end
    if(message.receiveID == nil)then
        return false;
    end
    if(message.groupID == nil)then
        return false;
    end
    if(message.senderID == nil)then
        return false;
    end
    if(message.timestamp == nil)then
        return false;
    end
    if(message.audioTime == nil)then
        return false;
    end
    -- if(message.audioPath == nil)then
    --     return false;
    -- end
    -- if(message.text == nil)then
    --     return false;
    -- end
    if(message.name == nil)then
        return false;
    end
    if(message.icon == nil)then
        return false;
    end
    return true;
end

function youmeGetMessage(messageID)
    if (youme.data ~= nil)then
        for key,var in pairs(youme.data) do
            if var.messageID == messageID then
                return var;
            end
        end
    end
    return nil;
end



function youmeReadData()
    -- youme.data = cc.FileUtils:getInstance():getValueMapFromFile(youme.datafilename)
    -- if(youme.data == nil)then
    --     youme.data = {};
    -- end
    local str = io.readfile(youme.datafilename)
    if(str == nil or str == "")then
        youme.data = {};
        return;
    end
    youme.data = json.decode(str)
    if(youme.data == nil)then
        youme.data = {};
    end

    -- 排序
    if(table.getn(youme.data) > 1)then
        local function sortWithTime(message1,message2)
          local time1 = message1.timestamp;
          local time2 = message2.timestamp;
          if(toint(time2) > toint(time1)) then
            return true;
          end
          return false;
        end
        table.sort(youme.data,sortWithTime);
        -- for key,var in pairs(youme.data) do
        --     print("data time ="..var.timestamp)
        -- end
    end
    
end


function youmeSaveData()
    -- local ret = json.encode(youme.data)
    -- cc.FileUtils:getInstance():writeToFile(youme.data,youme.datafilename)
    local str = json.encode(youme.data)
    io.writefile(youme.datafilename,str)
end
function youmeCleanData()
    youme.data = {};
    youmeSaveData();
end
    