local ChatItem2=class("ChatItem2",UILayer)

function ChatItem2:ctor(t)
    self.type=t
    self:init("ui/ui_talk_" .. t .. "_item.map")
    self.lines = 0
    self.bgWidth = self:getNode("bg"):getContentSize().width;
    self.bgHeight = self:getNode("bg"):getContentSize().height;
    if(self:getNode("layer_voice"))then
        self:getNode("layer_voice"):setVisible(false)
    end
end




-- function ChatItem2:onTouchEnded(target,touch,event)
--     -- if(target.touchName=="icon" or target.touchName=="txt_name"  )then
--     --     Data.gChatQuery = true
--     --     Net.sendBuddyTeam(self.curData.uid)
--     -- end
-- end


function ChatItem2:layout()
    if(self.curAlign==2)then
        if(self.richText)then
           
        else
            local width=self:getNode("txt_info"):getBoundingBox()
            --local posx=  self.mapW-100- width
          --  self:getNode("txt_info"):setPositionX(posx)
          print("123")
        end
    end
end

function ChatItem2:_getContentSize()
    print (" ChatItem2:_getContentSize")
    local chatItemSize=self:getContentSize()

    if(self.lines > 0) then
        chatItemSize.height = chatItemSize.height + 20 * self.lines
        print ("item height:" .. chatItemSize.height)
    end
    return chatItemSize
end


function   ChatItem2:setData(data,tagType)
    self.curData=data
    local msgs = gParseChatEmoj(data.msg)
    self:setRTFString("txt_info", msgs)
    local width = self:getNode("txt_info"):getContentSize().width
    local height = self:getNode("txt_info"):getContentSize().height + self.bgHeight - 21
    print ("height:" .. height)
    if height > self.bgHeight --[[and width >= orginWidth]] then
        print ("adjust item size>>>>")
        local offH = (height) - self.bgHeight;
        self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height+offH));
        self:getNode("bg"):setContentSize(cc.size(self.bgWidth, height));
    end
end




return ChatItem2