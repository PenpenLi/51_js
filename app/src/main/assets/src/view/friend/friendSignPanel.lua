local FriendSignPanel=class("FriendSignPanel",UILayer)

function FriendSignPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_friend_modify_sign.map")
    self.input = self:getNode("txt_input");
    self.input:setText(gFriend.sign);
    self.input:setMaxLength(Data.friend.maxSignCount);
    self:textChanged();

    local function onEditCallback(name, sender)
        if(name=="changed")then
            self:textChanged()
        end
    end
    self.input:registerScriptEditBoxHandler(onEditCallback)
end

function FriendSignPanel:textChanged()
    gRefreshLeftCount(self:getNode("lab_limit"),Data.friend.maxSignCount,string.filter(self.input:getText()));
end

function FriendSignPanel:events()
    return {
        EVENT_ID_FRIEND_MODIFY_SIGN
    }
end

function FriendSignPanel:dealEvent(event,param)
    if( event==EVENT_ID_FRIEND_MODIFY_SIGN)then
        self.refreshSign();
        Panel.popBack(self:getTag())
    end
end

function FriendSignPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_send")then
        Net.sendSystemChangeSign(string.filter(self.input:getText()));
    end
     
end

return FriendSignPanel