local LoginPanel=class("LoginPanel",UILayer)

function LoginPanel:ctor()
    self:init("ui/ui_login.map")


    self:setLabelString("input_name",gAccount:lastAccount())
    self:setLabelString("input_psw",gAccount:lastPassword())
    self:getNode("input_psw"):setInputFlag(0)

    if(gAccount:lastAccount()~="" and
        gAccount:lastPassword()~="")then
        self:onTouchEnded({touchName="btn_login"})
    end

    setInputBgTxt(self:getNode("input_name"))
    setInputBgTxt(self:getNode("input_psw"))
    
end


function LoginPanel:onTouchEnded(target)


    local account= (self:getNode("input_name"):getText())
    local psw= (self:getNode("input_psw"):getText())



    local function onLoginCallback()
        Scene.hideWaiting()
        Panel.popBackAll()
        gEnterLayer:updateAccount()
        --[[
        local curServer=gAccount:getCurServer()
        gAccount:saveServer(curServer.id)
        Net.connectToServer(curServer.ip,curServer.port)

        ]]
    end


    local function onRegisterCallback()
        gAccount:loginLastAccount(onLoginCallback)
    end

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif target.touchName=="btn_register" then
        gAccount:registerAccount(account,psw,psw,onRegisterCallback)

    elseif  target.touchName=="btn_login" then
        gAccount:loginAccount(account,psw,onLoginCallback)
    end

end






return LoginPanel