local ChatVoiceItem=class("ChatVoiceItem",UILayer)

function ChatVoiceItem:ctor(t)
    print("ChatVoiceItem:ctor~" .. t)
    self.type=t
    -- self:init("ui/ui_talk_" .. t .. "_item.map")
    -- self.bgWidth = self:getNode("bg"):getContentSize().width;
    -- self.bgHeight = self:getNode("bg"):getContentSize().height;
    -- print("bgWidth:" .. self.bgWidth)
    -- print("bgHeight:" .. self.bgHeight)
    -- self.lines = 0
    if string.find(self.type,"world") then
        self:setContentSize(cc.size(664,88));
    else
        self:setContentSize(cc.size(410,60));
    end
    local btn_go = self:getNode("btn_go")
    if (btn_go) then
        btn_go:setVisible(false)
    end
    -- self.playing = false;
    -- self.playtime = 0;
    -- self.preSound = "";

    -- local function updateTime()
    --     if(self.playing and os.time() - self.playtime > toint(self.curData.audioTime))then
    --         self.playing = false;
    --         if(self.preSound == self.curData.audioPath)then
    --             self.playing = false;
    --             self.playtime = 0;
    --             self.preSound = "";
    --             gStopEffect(self.preSound)
    --             AudioEngine.resumeMusic();
    --         end
    --     end
    -- end

    -- self:scheduleUpdate(updateTime,1)
end

function ChatVoiceItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_talk_" .. self.type .. "_item.map");

    self.bgWidth = self:getNode("bg"):getContentSize().width;
    self.bgHeight = self:getNode("bg"):getContentSize().height;
    -- print("bgWidth:" .. self.bgWidth)
    -- print("bgHeight:" .. self.bgHeight)
    self.lines = 0
    if(self:getNode("layer_voice"))then
        self:getNode("layer_voice"):setVisible(true)
        self:getNode("txt_info"):setVisible(false)
    end
    self.fla=FlashAni.new()
    gAddCenter(self.fla,self:getNode("voice_bg"))
    loadFlaXml("ui_yuyin")
    self.fla:playAction("ui_yuyin2");
    self.fla:stopAni();
    self.fla:setVisible(false);
    if(self.type ~= "world_me")then
        self.fla:setScale(-1)
    end
    -- self.fla = gCreateFla("ui_yuyin2",1);
    -- gAddChildInCenterPos(self:getNode("voice_bg"),self.fla)
    -- self.fla:stopAni();
end

function ChatVoiceItem:stopVoice()
    self.fla:stopAni();
    self.fla:setVisible(false);
    self:getNode("voice_ation"):setVisible(true);
end

function ChatVoiceItem:onTouchEnded(target,touch,event)
    print ("onTouchEnded:" .. target.touchName)
    print ("ctype:"..tostring(self.curData.ctype))
    if (self.type == "world_me") then 
        --return
    end
    if(target.touchName=="icon" or target.touchName=="txt_name")then
        -- print("uid = "..self.curData.uid);
        -- print("Data.getCurUserId() = "..Data.getCurUserId());
        if(tostring(self.curData.uid) ~= tostring(Data.getCurUserId()))then
            Data.gChatQuery = true
            Net.sendBuddyTeam(toint(self.curData.uid))
        end
        return
    elseif(target.touchName=="voice_bg")then
        local isPlay = youmePlayAudio(self.curData,self);
        if(isPlay)then
            -- print("voice_ation playact")
            -- self:getNode("voice_ation"):playAct("ui_yuyin2",false,1)
            -- self:getNode("voice_ation"):playAction("ui_yuyin2")
            -- self.fla:playAction("ui_yuyin2");
            self.fla:resume();
            self.fla:setVisible(true);
            self:getNode("voice_ation"):setVisible(false);
        else
            self.fla:stopAni();
            self.fla:setVisible(false);
            self:getNode("voice_ation"):setVisible(true);
        end
        -- if(not self.playing)then
        --     self.playtime = os.time();
        -- elseif(self.preSound == self.curData.audioPath)then
        --     self.playing = false;
        --     self.playtime = 0;
        --     self.preSound = "";
        --     gStopEffect(self.preSound)
        --     AudioEngine.resumeMusic();
        -- end
    end
    -- if (target.touchName == "txt_info") then
    --     if(self.curData.ctype == 1) then
    --         self:enterFamilySeven()
    --         return
    --     elseif(self.curData.ctype == 5) then
    --         local stagePhase, lefttime = Data.getFamilyStagePhase()
    --         if stagePhase == FAMILY_STAGE_NONE then
    --             gShowNotice(gGetWords("noticeWords.plist","no_family_stage_fight_time"))
    --             return
    --         end
    --         Net.sendFamilyGetInfo(function()
    --             Net.sendFamilyStageInfo()
    --         end)
    --         return
    --     elseif(self.curData.type == 4 and self.curData.ctype == 0) then
    --         Net.sendFamilySpringInfo()
    --         return
    --     elseif(self.type=="world" or self.type=="world_me") then 
    --         if (self.curData.ctype == 2 and self.curData.vid) then
    --             print ("send vid:" .. tostring(self.curData.vid))
    --             Net.sendArenaVideo(self.curData.vid)
    --             return
    --         end
    --     end
    -- end
    -- if (target.touchName == "btn_go") then
    --     if (self.curData.param ~=nil) then
    --         Panel.popBackTopPanelByType(PANEL_CHAT)
    --         if (self.curData.param == 1) then
    --             Net.sendBathGetInfo()
    --         elseif (self.curData.param == 2) then
    --             Net.sendDrinkGetinfo()
    --         elseif (self.curData.param == 3) then
    --             gEnterArena()
    --         end
    --     elseif (self.curData.ctype == 6) then
    --         if (Data.hasFamily()) then
    --             local function  callback()
    --                 Net.sendFamilyMatchInfo()
    --             end
    --             Net.sendFamilyGetInfo(callback)
    --         else
    --             gShowNotice(gGetWords("noticeWords.plist","no_family"))
    --         end
    --     end
    -- end
end

function ChatVoiceItem:layout()
    if(self.curAlign==2)then
        if(self.richText)then
           
        else
            local width=self:getNode("txt_info"):getBoundingBox()
            --local posx=  self.mapW-100- width
          --  self:getNode("txt_info"):setPositionX(posx)
          --print("123")
        end
    end
end

function ChatVoiceItem:_getContentSize()
    print (" ChatItem:_getContentSize")
    local chatItemSize=self:getContentSize()

    if(self.lines > 0) then
        chatItemSize.height = chatItemSize.height + 25 * self.lines
        --print ("item height:" .. chatItemSize.height)
    end
    return chatItemSize
end


function ChatVoiceItem:setLazyData(data,tagType)  
    if(self.inited==true)then
        return
    end
    self.curData=data
    self.tagType = tagType;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"chatItem")
end
function ChatVoiceItem:setLazyDataCalled()
    self:setData(self.curData,self.tagType);
end

function  ChatVoiceItem:setData(data,tagType)
    print_lua_table(data)
    self:initPanel();
    self.curData=data
    if (data.senderID ~= "0" and data.senderID ~= "" ) then 
        self:setLabelString("txt_name",data.name)
        Icon.setHeadIcon(self:getNode("icon"), toint(data.icon))
    end
    if(self.type == "world_me") then
        self:getNode("icon"):setScaleX(-0.65)
    end
    local strTime = gGetDate('%H:%M:%S', toint(data.timestamp))
    self:setLabelString("txt_time", strTime)

    self:setLabelString("voice_time", data.audioTime)
    if(toint(data.audioTime) > 1)then
        self:getNode("voice_bg"):setContentSize(cc.size(50+toint(data.audioTime)*5, 32));
        if(self.type == "world_me") then
            self.fla:setPositionX(50+toint(data.audioTime)*5-25)
            self:getNode("voice_ation"):setPositionX(50+toint(data.audioTime)*5-20)
        end
        self:getNode("layer_voice"):layout()
    end
    --local msgs = "\\"
    -- print ("data.msg:" .. data.msg)
    -- local msgs = gParserMsgTxt(data.msg)
    -- local msgs = gParseChatEmoj(msgs)

    -- -- print (msgs)

    -- if (data.ctype == 2) then
    --     if(string.find(msgs,"#"))then
    --         local t=string.split(msgs,"#")
    --         msgs = t[1] .. "\r\n\\w{c=00e4ff}【 \\w{c=7fff02}" .. t[2] .. "\\ \\w{c=00e4ff}VS \\w{c=7fff02}" ..t[3] .."\\w{c=00e4ff} 】"
    --         if (t[4]) then
    --             self.curData.vid = tonumber(t[4])
    --         end
    --     end
    -- end
    -- if (Data.hasFamily()) then
    --     if (self.curData.param ~=nil or self.curData.ctype == 6) then
    --         local btn_go = self:getNode("btn_go")
    --         if (btn_go) then
    --             btn_go:setVisible(true)
    --         end
    --     end 
    -- end
    -- -- local orginWidth = 518--self:getNode("txt_info"):getContentSize().width;
    -- self:setRTFString("txt_info", msgs)
    -- local width = self:getNode("txt_info"):getContentSize().width
    -- local height = self:getNode("txt_info"):getContentSize().height + self.bgHeight - 22
    -- -- self.lines = math.floor(height/20) - 1
    -- if height > self.bgHeight --[[and width >= orginWidth]] then
    --     print ("adjust item size>>>>")
    --     local offH = (height) - self.bgHeight;
    --     self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height+offH));
    --     self:getNode("bg"):setContentSize(cc.size(self.bgWidth, height));
    -- end


end

-- function ChatVoiceItem:enterFamilySeven()
--     Net.sendFamilySevenInfo();
-- end


return ChatVoiceItem