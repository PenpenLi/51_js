local ChatItem=class("ChatItem",UILayer)

function ChatItem:ctor(t)
    print("ChatItem:ctor~" .. t)
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
end

function ChatItem:initPanel()
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
        self:getNode("layer_voice"):setVisible(false)
    end
end


function ChatItem:onTouchEnded(target,touch,event)
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
            Net.sendBuddyTeam(self.curData.uid)
        end
        return
    end
    if (target.touchName == "txt_info") then
        if(self.curData.ctype == 1) then
            self:enterFamilySeven()
            return
        elseif(self.curData.ctype == 5) then
            local stagePhase, lefttime = Data.getFamilyStagePhase()
            if stagePhase == FAMILY_STAGE_NONE then
                gShowNotice(gGetWords("noticeWords.plist","no_family_stage_fight_time"))
                return
            end
            Net.sendFamilyGetInfo(function()
                Net.sendFamilyStageInfo()
            end)
            return
        elseif(self.curData.type == 4 and self.curData.ctype == 0) then
            Net.sendFamilySpringInfo()
            return
        elseif(self.type=="world" or self.type=="world_me") then 
            if (self.curData.ctype == 2 and self.curData.vid) then
                print ("send vid:" .. tostring(self.curData.vid))
                Net.sendArenaVideo(self.curData.vid)
                return
            end
        end
    end
    if (target.touchName == "btn_go") then
        if (self.curData.param ~=nil) then
            Panel.popBackTopPanelByType(PANEL_CHAT)
            if (self.curData.param == 1) then
                Net.sendBathGetInfo()
            elseif (self.curData.param == 2) then
                Net.sendDrinkGetinfo()
            elseif (self.curData.param == 3) then
                gEnterArena()
            end
        elseif (self.curData.ctype == 6) then
            if (Data.hasFamily()) then
                local function  callback()
                    Net.sendFamilyMatchInfo()
                end
                Net.sendFamilyGetInfo(callback)
            else
                gShowNotice(gGetWords("noticeWords.plist","no_family"))
            end
        end
    end
end

function ChatItem:layout()
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

function ChatItem:_getContentSize()
    print (" ChatItem:_getContentSize")
    local chatItemSize=self:getContentSize()

    if(self.lines > 0) then
        chatItemSize.height = chatItemSize.height + 25 * self.lines
        --print ("item height:" .. chatItemSize.height)
    end
    return chatItemSize
end


function ChatItem:setLazyData(data,tagType)  
    if(self.inited==true)then
        return
    end
    self.curData=data
    self.tagType = tagType;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"chatItem")
end
function ChatItem:setLazyDataCalled()
    self:setData(self.curData,self.tagType);
end

function  ChatItem:setData(data,tagType)
    -- print("ChatItem:setData")
    -- print_lua_table(data, 4)
    self:initPanel();
    self.curData=data
    if (data.uid ~= 0) then 
        self:setLabelString("txt_name",data.name)
        Icon.setHeadIcon(self:getNode("icon"), data.icon)
    end
    if(self.type == "world_me") then
        self:getNode("icon"):setScaleX(-0.65)
    end
    local strTime = gGetDate('%H:%M:%S', data.time)
    self:setLabelString("txt_time", strTime)
    --local msgs = "\\"
    -- print ("data.msg:" .. data.msg)
    local msgs = gParserMsgTxt(data.msg)
    local msgs = gParseChatEmoj(msgs)

    -- print (msgs)

    if (data.ctype == 2) then
        if(string.find(msgs,"#"))then
            local t=string.split(msgs,"#")
            msgs = t[1] .. "\r\n\\w{c=00e4ff}【 \\w{c=7fff02}" .. t[2] .. "\\ \\w{c=00e4ff}VS \\w{c=7fff02}" ..t[3] .."\\w{c=00e4ff} 】"
            if (t[4]) then
                self.curData.vid = tonumber(t[4])
            end
        end
    end
    if (Data.hasFamily()) then
        if (self.curData.param ~=nil or self.curData.ctype == 6) then
            local btn_go = self:getNode("btn_go")
            if (btn_go) then
                btn_go:setVisible(true)
            end
        end 
    end
    -- local orginWidth = 518--self:getNode("txt_info"):getContentSize().width;
    self:setRTFString("txt_info", msgs)
    local width = self:getNode("txt_info"):getContentSize().width
    local height = self:getNode("txt_info"):getContentSize().height + self.bgHeight - 22
    -- self.lines = math.floor(height/20) - 1
    if height > self.bgHeight --[[and width >= orginWidth]] then
        print ("adjust item size>>>>")
        local offH = (height) - self.bgHeight;
        self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height+offH));
        self:getNode("bg"):setContentSize(cc.size(self.bgWidth, height));
    end


end

function ChatItem:enterFamilySeven()
    Net.sendFamilySevenInfo();
end


return ChatItem