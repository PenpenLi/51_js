local MsgWinLayer=class("MsgWinLayer",UILayer)

function MsgWinLayer:ctor(type)
    self:init("ui/ui_msg_win.map") 
    
    if gMsgPos == nil then
        gMsgPos = {}
    end
    self.curType = type
    
    if (self.curType == nil) then 
        self.curType = 1
    end

    if(gMsgPos["txt1"] == nil) then
        gMsgPos["txt1"] = self:getNode("txt1"):getPositionY()
        gMsgPos["txt2"] = self:getNode("txt2"):getPositionY()
        gMsgPos["txt3"] = self:getNode("txt3"):getPositionY()
    end
    
    self:checkNewMsg()
end


function MsgWinLayer:checkNewMsg()
    local data = Data.getWorldChats()
    if (self.curType == 2) then
        data = Data.getFamilyChats()
    end
    --local data = {}
    if (data == nil) then
        data = {}
    end
    local size = table.getn(data)

    -- print("size = "..size)
    if (size > 0) then 
        self:createOneMsg("txt3",data[size])
    else
        self:createOneMsg("txt3",{name="",msg= ""})
    end
    if (size > 1) then 
        self:createOneMsg("txt2",data[size-1])
    else
        self:createOneMsg("txt2",{name="",msg=""})
    end
    if (size > 2) then
        self:createOneMsg("txt1",data[size-2])
    else
        self:createOneMsg("txt1",{name="",msg=""})
    end
end

function MsgWinLayer:createOneMsg(lab, data)
    -- print ("createOneMsg:" .. data.msg)
    local sysMsg = false
    local name = data.name
    if (name == nil or name == "") then
        name = gGetWords("mailWords.plist","xiaoluan");
        sysMsg = true
    end
    local msgs = "\\"
    local input_msg = data.msg
    if input_msg == nil then
        input_msg = ""
    end
    if (data.ctype == 2) then
        if(string.find(input_msg,"#"))then
            local w=string.split(input_msg,"#")
            input_msg = w[1]
        end
    end
    input_msg = gParserMsgTxt(input_msg)
    local msgs = gParseChatEmoj(input_msg)
    
    local msg = "\\w{c=fd50ff}" 
    if (sysMsg) then
        msg = "\\w{c=00fcff}"
    end
    if (input_msg == "") then
        msg = " "
    else
        msg = msg .. name .. "\\"..":".."\\w{c=fec825}"..msgs.."\\"
    end
    local rtf = self:getNode(lab);
    rtf:clear();
    local isCut = rtf:setStringForCutWidth(msg,380);
    if(isCut)then
        rtf:addWord("...");
    end
    rtf:layout();

end



function MsgWinLayer:dealEvent(event,param)
    -- print("MsgWinLayer:dealEvent");
    if(event == EVENT_ID_NEW_CHAT)then
        self:checkNewMsg();
    end
end


function MsgWinLayer:show()
    self:setVisible(true)
end

function MsgWinLayer:hide()
    self:setVisible(false)   
end

function MsgWinLayer:update()
    self:checkNewMsg();
end

return MsgWinLayer