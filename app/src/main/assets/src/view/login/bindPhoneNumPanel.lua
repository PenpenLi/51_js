local BindPhoneNumPanel=class("BindPhoneNumPanel",UILayer)

function BindPhoneNumPanel:ctor()
    self:init("ui/ui_yanzhengma.map")
    self._panelTop = true

    self:getNode("txt_second"):setVisible(false)
    local bindPhone = cc.UserDefault:getInstance():getStringForKey("bindPhone")
    if bindPhone~="" then
        self:getNode("txt_inputphone"):setText(bindPhone)
    end
    self:getNode("txt_inputphone"):setInputMode(3)
    self:scheduleUpdatePhone()
    Net.sendIphoneGift()
end

function BindPhoneNumPanel:events()
    return{EVENT_ID_BIND_PHONE_GETGIF}
end

function BindPhoneNumPanel:onPopBackFromStack()
    self:unscheduleUpdateEx()
end


function BindPhoneNumPanel:dealEvent(event,param,param2)
    if(event == EVENT_ID_BIND_PHONE_GETGIF)then
        local index = 1
        for k,data in pairs(param) do
            local node=DropItem.new() 
            node:setData(data.itemid)
            node:setNum(data.num)  
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node,self:getNode("icon_"..index)) 
            index = index+1
        end
        for i=index,6 do
            if self:getNode("icon_"..i) then
                 self:getNode("icon_"..i):setVisible(false)
            end
        end
        self:resetLayOut()
    end
end

function BindPhoneNumPanel:scheduleUpdatePhone(time)
    self.secondTime = math.rint(gPhoneSecond)
    if time~=nil then
        self.secondTime=time
    end
    if self.secondTime>2 then 
        self:setTouchEnableGray("btn_sendcode", false)
        self:getNode("txt_second"):setVisible(true)
        self:replaceLabelString("txt_second",self.secondTime)
        function _callback()
            self.secondTime=self.secondTime-1
            self:replaceLabelString("txt_second",self.secondTime)
            if self.secondTime<=0 then
                self:setTouchEnableGray("btn_sendcode", true)
                self:getNode("txt_second"):setVisible(false)
            end
        end
        self:scheduleUpdate(_callback,1, 0, self.secondTime-1,false)
    end
   
end

function BindPhoneNumPanel:onTouchEnded(target)


    if  target.touchName=="btn_close"then
        gPhoneSecond=self.secondTime
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_sendcode" then
        local phone= self:getNode("txt_inputphone"):getText()
        function phoneCallback()
            cc.UserDefault:getInstance():setStringForKey("bindPhone",phone)
            self:scheduleUpdatePhone(60)
        end
        gAccount:bindPhone(phone,phoneCallback)
    elseif target.touchName=="btn_checkcode" then

    elseif target.touchName=="btn_get" then
        local phone= self:getNode("txt_inputphone"):getText()
        local code= self:getNode("txt_inputcode"):getText()
        Net.sendGetIphoneGift(toint(phone),toint(code))
    end

end

return BindPhoneNumPanel
