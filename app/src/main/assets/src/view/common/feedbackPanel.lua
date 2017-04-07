local FeedbackPanel=class("FeedbackPanel",UILayer)
Data.feedback = {};
Data.feedback.maxFbCount = 80;--最大字数
function FeedbackPanel:ctor()
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_feedback.map")
    self.input = self:getNode("txt_input");
    self.input:setText("");
    self.input:setMaxLength(Data.feedback.maxFbCount);
    self:textChanged();
    setInputBgTxt(self.input);

    local function onEditCallback(name, sender)
        if(name=="changed")then
            self:textChanged()
        end
    end
    self.input:registerScriptEditBoxHandler(onEditCallback)

    if(self:getNode("txt_qq"))then
        self:setLabelString("txt_qq",DB.getClientParam("CUSTOMER_SERVICE_QQ"))
    end
    self:dealGetFeedback();

    local show = false
    if(gCurLanguage == LANGUAGE_ZHS and not gIsMultiLanguage())then
        show = not Module.isClose(SWITCH_FEEDBACK) 
    end
    if (not show) then
        if(self:getNode("info_bg"))then
            self:getNode("info_bg"):setVisible(false)
        end
        self:getNode("scroll"):setPositionY(self:getNode("scroll"):getPositionY()+20)
    end
    local platform = gGetCurPlatform();
    if  platform == CHANNEL_IOS_IDN or platform == CHANNEL_ANDROID_IDN then
        self:getNode("info_tieba"):setVisible(false)
        self:getNode("info_qq"):setVisible(false)
        self:resetLayOut();
    end
end

function FeedbackPanel:textChanged()
    gRefreshLeftCount(self:getNode("lab_limit"),Data.feedback.maxFbCount,string.filter(self.input:getText()));
end

function FeedbackPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_send")then
        self:dealSend();
    elseif(target.touchName=="btn_fans")then
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("fans_url","")
        end
    elseif(target.touchName=="btn_baha")then
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("baha_url","")
        end
    elseif(target.touchName=="btn_official")then
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("official_url","")
        end
    elseif(target.touchName=="btn_service")then
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("service_url","")
        end
    end
     
end

function FeedbackPanel:createList(data)
    -- print_lua_table(data);
    if nil ~= data then
        self:getNode("scroll"):clear()
        for key,var in pairs(data) do
            local item = FeedbackItemPanel.new(var,key);
            self:getNode("scroll"):addItem(item);
            item.click = function(index)
                self:onClick(index);
            end
        end
        self:getNode("scroll"):layout();
    end
end

function FeedbackPanel:onClick(index)
end

function FeedbackPanel:dealGetFeedback()
    local function callback(data)
        -- print_lua_table(data);
        if data.ret == 0 then
            self:createList(data.rolelist);
            self.input:setText("");
            self:textChanged()
        end
        Scene.hideWaiting()
    end
    gAccount:getFeedbackList(callback);
end

function FeedbackPanel:dealSend()
    local function callback(data)
        -- print_lua_table(data);
        if data.ret == 0 then
            self:dealGetFeedback();
        end
        Scene.hideWaiting()
    end
    gAccount:sendFeedback(string.filter(self.input:getText()),callback)
end

return FeedbackPanel