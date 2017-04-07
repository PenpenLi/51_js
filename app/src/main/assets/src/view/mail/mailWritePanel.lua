local MailWritePanel=class("MailWritePanel",UILayer)

function MailWritePanel:ctor()
    self.appearType = 1;
    self:init("ui/ui_mail_send.map")
    self._panelTop=true

    self:setData(0,"")
    self.input = self:getNode("txt_input");
    self.input:setMaxLength(Data.friend.maillength)
    self:textChanged();

    local function update()
    	self:setLabelString("lab_time", gParserDay(gGetCurServerTime()))
    end
    self:scheduleUpdate(update,60)

    local function onEditCallback(name, sender)
        if(name=="changed")then
        	self:textChanged()
        end
    end
    self.input:registerScriptEditBoxHandler(onEditCallback)
end

function MailWritePanel:onUILayerExit()
  self:unscheduleUpdateEx();
end

function MailWritePanel:onPopup()
    if(FriendListPanel.data.friend.uid ~= 0)then
        self:setData(FriendListPanel.data.friend.uid,FriendListPanel.data.friend.name)
    end
end

function MailWritePanel:events()
    return {
      EVENT_ID_REC_MY_FRIEND_LIST,
      EVENT_ID_FRIEND_MAIL_SEND,
    }
end


function MailWritePanel:dealEvent(event,param)
    if(event == EVENT_ID_REC_MY_FRIEND_LIST)then
        self:entenrFriendList()
    elseif(event == EVENT_ID_FRIEND_MAIL_SEND)then
        Panel.popBack(self:getTag())
    end
end

function MailWritePanel:onTouchEnded(target)
    if target.touchName=="btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_sel_ferind" then
  	    if(gFriend.myFriendsInited)then
            Panel.popUp(PANEL_FRIEND_LIST)
  	    else
  	        gFriend.myFriendsInited=true
  	        Net.sendBuddyList()
  	    end
    elseif target.touchName=="btn_send" then
    	self:onSend()
    end
end

function MailWritePanel:setData(toId,toName)
    self.toId = toId
    self.toName = toName

    self:setLabelString("lab_to",self.toName)
end

function MailWritePanel:textChanged()
    gRefreshLeftCount(self:getNode("lab_limit"),Data.friend.maillength,string.filter(self.input:getText()));
end

function MailWritePanel:onSend()
  local sText = string.trim(string.filter(self.input:getText()));
  local len = string.len(sText);

  if len==0 then
    local sWord = gGetWords("noticeWords.plist","intput_empty");
    gShowNotice(sWord);
    return;
  elseif(self.toId == 0) then
    local sWord = gGetWords("noticeWords.plist","addressee_empty");
    gShowNotice(sWord);
  	return;
  end

  Net.sendBuddyMessage(self.toId,sText)
end

function MailWritePanel:entenrFriendList()
    Panel.popUp(PANEL_FRIEND_LIST)
end

return MailWritePanel