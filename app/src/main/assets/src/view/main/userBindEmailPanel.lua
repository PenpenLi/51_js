local UserBindEmailPanel=class("UserBindEmailPanel",UILayer)

function UserBindEmailPanel:ctor()
    self._panelTop = true;
    self:init("ui/ui_user_Email.map")
    -- self.isBlackBgVisible=false  
end

function UserBindEmailPanel:events()
    return {EVENT_ID_REFRESH_EAMIL};
end

function UserBindEmailPanel:dealEvent(event,param)
    if(event == EVENT_ID_REFRESH_EAMIL)then
        Panel.popBack(self:getTag());
    end
end

function UserBindEmailPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_bind" then
        local email = self:getNode("txt_input"):getText();
        if(email == "")then
            gShowNotice(gGetWords("setWord.plist","10"));
            return;
        end
        Net.sendSystemBindEmail(email);
    end
end

return UserBindEmailPanel