local WXBindPanel=class("WXBindPanel",UILayer)

function WXBindPanel:ctor()
    self:init("ui/ui_weixin_bind.map")
    self._panelTop = true

    -- self:setLabelString("input_name",gAccount:lastAccount())
    -- self:setLabelString("input_psw",gAccount:lastPassword())
     self:getNode("layer_bind"):setVisible(true)
     self:getNode("layer_newacount"):setVisible(false)
     self:getNode("layer_check"):setVisible(false)
     self:getNode("input_newpass"):setInputFlag(0)
     self:getNode("input_renewpass"):setInputFlag(0)
     self:getNode("input_password"):setInputFlag(0)
end


function WXBindPanel:onTouchEnded(target)


    local function onBindCallback(ret)
        if ret.ret==0 then
            local function onReEnter()
                local function callback()
                    Scene.reEnter()
                end
                Net.disConnect(callback)
            end
            gConfirm(gGetWords("noticeWords.plist", "bind_successful"),onReEnter)
        end
    end

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_bind" then
        self:getNode("layer_bind"):setVisible(false)
        self:getNode("layer_newacount"):setVisible(false)
        self:getNode("layer_check"):setVisible(true)
    elseif target.touchName=="btn_newbind" then
        self:getNode("layer_bind"):setVisible(false)
        self:getNode("layer_newacount"):setVisible(true)
        self:getNode("layer_check"):setVisible(false)
    elseif target.touchName=="btn_register" then
        local account = (self:getNode("input_newaccount"):getText())
        local psw = (self:getNode("input_newpass"):getText())
        local repsw = (self:getNode("input_renewpass"):getText())
        local function onRegisterCallback(ret) 
            if ret and ret.ret==0 then
                gAccount:bindRole(account,psw,onBindCallback)
            end
        end
        gAccount:registerBindAccount(account,psw,repsw,onRegisterCallback)

    elseif  target.touchName=="btn_check" then
        local account= (self:getNode("input_account"):getText())
        local psw= (self:getNode("input_password"):getText())
        gAccount:bindRole(account,psw,onBindCallback)
    end

end


return WXBindPanel
