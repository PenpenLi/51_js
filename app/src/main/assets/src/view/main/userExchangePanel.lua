local UserExchangePanel=class("UserExchangePanel",UILayer)

function UserExchangePanel:ctor(type)
    self:init("ui/ui_user_exchange.map")
    -- self.isBlackBgVisible=false  
    self._panelTop=true
    self.bgVisible = false;

    self.input = self:getNode("txt_input");
    self.input:setText("");
    self.input:setMaxLength(20);
    -- self:textChanged();

    -- local function onEditCallback(name, sender)
    --     if(name=="changed")then
    --         self:textChanged()
    --     end
    -- end
    -- self.input:registerScriptEditBoxHandler(onEditCallback)
end

-- function UserExchangePanel:textChanged()
--     gRefreshLeftCount(self:getNode("lab_limit"),12,string.filter(self.input:getText()));
-- end

-- function  UserExchangePanel:events()
--     return {EVENT_ID_ITEM_EXGIFT,}
-- end

-- function UserExchangePanel:dealEvent(event,param)
--     if(event == EVENT_ID_ITEM_EXGIFT) then

--     end
-- end

function UserExchangePanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_ok"then
        self:dealOk();
    elseif  target.touchName=="btn_cancel"then
        Panel.popBack(self:getTag())
    end
end

function UserExchangePanel:dealOk()
    local content = string.filter(self.input:getText())
    if(string.len(string.trim(content))==0)then
        local sWord = gGetWords("noticeWords.plist","intput_empty");
        gShowNotice(sWord);
        return
    end
    Panel.popBack(self:getTag())
    Net.sendItemExGift(content);
end

return UserExchangePanel