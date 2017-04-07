local UserInfoPanel=class("UserInfoPanel",UILayer)
UserInfoPanelData = {};
function UserInfoPanel:ctor(type)
    self.appearType = 1;
    self:init("ui/ui_user_info.map")
    -- self.isBlackBgVisible=false  
    self._panelTop=true
    self.bgVisible = true;

    self:initMailInfo();

    if(Module.isClose(SWITCH_SWITCH))then
        self:getNode("exchange_panel"):setVisible(false)
        self:getNode("set_panel"):setPosition(self:getNode("exchange_panel"):getPosition())
    end
    if APPSTOREMODE == GUESTMODE and not Module.isClose(SWITCH_VIP) then
         self:getNode("btn_bind"):setVisible(true)
    else
        self:getNode("btn_bind"):setVisible(false)
    end

    if(gGetCurPlatform() == CHANNEL_APPSTORE or gGetCurPlatform() == CHANNEL_IOS_JIURU or gGetCurPlatform() == CHANNEL_IOS_JITUO or gGetCurPlatform() == CHANNEL_MOTU)then
        Net.sendSystemGetemail();
    end 
    self:hideCloseModule();

    self:getNode("layer_testbat"):setVisible(gShowMapName)
    self:getNode("txt_batid"):setVisible(gShowMapName)

end

function UserInfoPanel:hideCloseModule()
    self:getNode("layout_accoutid"):setVisible(not Module.isClose(SWITCH_ACCOUTID));
end

function UserInfoPanel:onPopup()
    self:setLabelString("txt_name",gUserInfo.name)
    self:setLabelString("txt_id",gUserInfo.id)
    if isBanshuReview() then
        self:setLabelString("txt_level",gUserInfo.level)
        self:setLabelString("txt_max_level",gUserInfo.level)
    else
        gShowRoleLv(self,"txt_level",gUserInfo.level);
        gShowRoleLv(self,"txt_max_level",gUserInfo.level);
    end
    
    -- self:setLabelString("txt_level","Lv"..gUserInfo.level)
    -- self:setLabelString("txt_max_level","Lv"..gUserInfo.level)
    -- Icon.setIcon(Data.getCurIcon(),self:getNode("icon"))
    self:refreshIcon();

    local expData= DB.getUserExpByLevel(gUserInfo.level)
    if(expData)then
        local per= gUserInfo.exp/expData.exp
        self:setBarPer("bar",per)
        self:setLabelString("txt_exp",gUserInfo.exp.."/"..expData.exp)
    end

    if(gUserInfo.email ~= nil and (gGetCurPlatform() == CHANNEL_APPSTORE or gGetCurPlatform() == CHANNEL_IOS_JIURU or gGetCurPlatform() == CHANNEL_IOS_JITUO or gGetCurPlatform() == CHANNEL_MOTU))then
        self:refreshMailInfo();
    end 
end

function UserInfoPanel:initMailInfo()
    self:getNode("layer_mail"):setVisible(false);
    self:getNode("btn_bind_mail"):setVisible(false);
    self:getNode("btn_change_psd"):setVisible(false);
end

function UserInfoPanel:refreshMailInfo()

    if(Module.isClose(SWITCH_VIP))then
        return;
    end

    local hasMail = false;
    local showBindEmail = false;
    if(gUserInfo.email and gUserInfo.email ~= "")then
        hasMail = true;
    end
    if(hasMail == false and APPSTOREMODE == MOTUMODE)then
        showBindEmail = true;
    end

    self:getNode("layer_mail"):setVisible(hasMail);
    self:getNode("btn_bind_mail"):setVisible(showBindEmail);
    if(hasMail)then
        self:replaceLabelString("txt_mail",gUserInfo.email);
    end
    
    self:getNode("btn_change_psd"):setVisible(APPSTOREMODE == MOTUMODE);
end

function UserInfoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_testbat"then
        -- Panel.popUp(PANEL_CARD_UP_QUALITY,10012)
        local batid= (self:getNode("txt_batid"):getText())
        if batid and toint(batid) >0  then
            Net.sendGetBattle(batid)
            Panel.popBack(self:getTag())
        end
    elseif  target.touchName=="btn_setting"then
        -- Panel.popUp(PANEL_CARD_UP_QUALITY,10012)
        Panel.popUpUnVisible(PANEL_USER_SET,nil,nil,true);
    elseif  target.touchName=="btn_exchange"then
        Panel.popUpUnVisible(PANEL_USER_EXCHANGE,nil,nil,true);

    elseif  target.touchName=="btn_change_name"then
        Panel.popUpUnVisible(PANEL_SET_NAME,nil,nil,true)
    elseif  target.touchName=="btn_change_icon"then
        Panel.popUpUnVisible(PANEL_USER_CHANGEICON,nil,nil,true)
       -- Net.sendGetBattle(1000000008892)
    elseif target.touchName=="btn_bind"  then
        Panel.popUpUnVisible(PANEL_WX_BIND,nil,nil,true)
    elseif target.touchName=="btn_bind_mail"  then
        Panel.popUp(PANEL_USER_BINDEMAIL);
    elseif target.touchName=="btn_change_psd" then
        Panel.popUpVisible(PANEL_WX_LOGIN_PASSWORD,2,nil,true)
    elseif  target.touchName=="btn_logout"then
        gAccount:doLogOut()
    end
end

function UserInfoPanel:refreshIcon() 
    Icon.setHeadIcon(self:getNode("icon"),Data.getCurIconFrame());
    -- Icon.setIcon(Data.getCurIcon(),self:getNode("icon"));  
    -- self:changeTexture("icon","images/icon/head/frame"..Data.getCurIconFrame()..".png"); 
end

function UserInfoPanel:events()
    return {EVENT_ID_ICON_CHANGE,EVENT_ID_REFRESH_EAMIL}
end

function UserInfoPanel:dealEvent(event,param)
    if event == EVENT_ID_ICON_CHANGE then
        self:refreshIcon();
    elseif event == EVENT_ID_REFRESH_EAMIL then
        self:refreshMailInfo();
    end
end

return UserInfoPanel