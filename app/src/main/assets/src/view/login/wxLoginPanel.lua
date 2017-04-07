local WXLoginPanel=class("WXLoginPanel",UILayer)

gAutoLogin=true
function WXLoginPanel:ctor()
    self:init("ui/ui_weixin_login.map")

     local appAccount,appPsw = gAccount:getAppstoreAccount()
     self:getNode("input_password"):setInputFlag(0)
     self:getNode("input_newpassword"):setInputFlag(0)
     self:getNode("input_repassword"):setInputFlag(0)
     self:getNode("layer_login"):setVisible(true)
     self:getNode("layer_regist"):setVisible(false)
     self:setLabelString("input_account",appAccount)
     self:setLabelString("input_password",appPsw)
     if gIsInReview() then
        self:getNode("btn_find_pwd"):setVisible(false)
        self:getNode("btn_change_pwd"):setVisible(false)
     else
        self:setBtnPwdShow()
     end
    if(gAutoLogin and gGetCurPlatform() == CHANNEL_MOTU)then
        if(appAccount~="" and appPsw~="")then
            self:onTouchEnded({touchName="btn_login"})
        end
    end 
    gAutoLogin = false
end


function WXLoginPanel:onTouchEnded(target)

    local function onLoginCallback(ret)
        if ret ~= nil then
            if ret == 20 then
                gAccount:saveAppstoreAccount(self:getNode("input_account"):getText(),"")
                self:setLabelString("input_password", "")
                return
            elseif ret == 21 then
                gAccount:saveAppstoreAccount("","")
                self:setLabelString("input_account", "")
                self:setLabelString("input_password", "")
                return
            end
        end
        local curServer=gAccount:getCurServer()
        gAccount:saveServer(curServer.id)
        Panel.popBackAll()
        gEnterLayer:enterLayer()
    end
    

    local function onRegisterCallback() 
        --gAccount:loginLastAccount(onLoginCallback)
        Panel.popBack(self:getTag())
        gEnterLayer:enterLayer()
    end
    
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_getaccount" then
        self:getNode("layer_login"):setVisible(false)
        self:getNode("layer_regist"):setVisible(true)
    elseif target.touchName=="btn_accounted" then
        self:getNode("layer_login"):setVisible(true)
        self:getNode("layer_regist"):setVisible(false)
    elseif target.touchName=="btn_regist" then

        local account= (self:getNode("input_newaccount"):getText())
        local psw= (self:getNode("input_newpassword"):getText())
        local repsw= (self:getNode("input_repassword"):getText())
        
        gAccount:registerAccount(account,psw,repsw,onRegisterCallback) 
        gAccount:saveAppstoreAccount(account,psw)
    elseif  target.touchName=="btn_login" then
        local account= (self:getNode("input_account"):getText())
        local psw= (self:getNode("input_password"):getText())
        gAccount:loginAccount(account,psw,onLoginCallback)
        gAccount:saveAppstoreAccount(account,psw)
    elseif target.touchName == "btn_find_pwd" then
        -- local url = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1049602254&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
        local url = gAccount.getaccountUrl;
        print("url = "..url);
        PlatformFunc:sharedPlatformFunc():openURL(url)
    elseif target.touchName == "btn_change_pwd" then
        Panel.popUpVisible(PANEL_WX_LOGIN_PASSWORD,1,nil,true)
    end

end

function WXLoginPanel:setBtnPwdShow()
    local account = self:getNode("input_account"):getText()
    local psw  = self:getNode("input_password"):getText()
    if account == "" or psw == "" then
        self:getNode("btn_find_pwd"):setVisible(true)
        self:getNode("btn_change_pwd"):setVisible(false)
    else
        self:getNode("btn_find_pwd"):setVisible(false)
        self:getNode("btn_change_pwd"):setVisible(true)
    end
end

function WXLoginPanel:refreshAccountAndPsd()
    local appAccount,appPsw = gAccount:getAppstoreAccount()
    self:setLabelString("input_account",appAccount)
    self:setLabelString("input_password",appPsw)
end


return WXLoginPanel
