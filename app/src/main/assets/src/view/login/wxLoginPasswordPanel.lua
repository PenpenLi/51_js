local WXLoginPasswordPanel=class("WXLoginPasswordPanel",UILayer)

local FROM_LOGIN = 1
local FROM_USER_INFO = 2
function WXLoginPasswordPanel:ctor(from)
    self:init("ui/ui_login_password.map")

    local appAccount = gAccount:getAppstoreAccount()
    self:setLabelString("input_account",appAccount)
    self:setLabelString("input_password","")
    if from == FROM_USER_INFO then
        -- self:getNode("input_account"):setVisible(false)
        self:getNode("input_account"):setEnabled(false)
        self:getNode("input_account"):setFontColor(cc.c4b(166,166,166,255))
    end

    self:getNode("input_password"):setInputFlag(0)
    self:getNode("input_newpassword"):setInputFlag(0)
    self:getNode("input_repassword"):setInputFlag(0)
end


function WXLoginPasswordPanel:onTouchEnded(target)
    
    if  target.touchName=="btn_close"then
        self:onClose()
    elseif target.touchName=="btn_ok" then
        local account = self:getNode("input_account"):getText()
        local psw = self:getNode("input_password"):getText()
        local newPsw = self:getNode("input_newpassword"):getText()
        local rePsw = self:getNode("input_repassword"):getText()
        if account == "" or psw == "" or newPsw == "" or rePsw == "" then
            gShowNotice(gGetWords("noticeWords.plist","change_psw_empty"))
            return
        end

        if newPsw ~= rePsw then
            gShowNotice(gGetWords("noticeWords.plist","new_re_psw_no_equal"))
            return
        end

        if newPsw == psw then
            gShowNotice(gGetWords("noticeWords.plist","new_old_psw_equal"))
            return
        end

        gAccount:pwdModify(account ,psw,newPsw,rePsw,function()
            self:onClose()
            local wxLoginPanel = Panel.getOpenPanel(PANEL_WX_LOGIN)
            if wxLoginPanel ~= nil then
                if account == gAccount:getAppstoreAccount() then
                    wxLoginPanel:refreshAccountAndPsd()
                end
            end
        end)
    end
end

return WXLoginPasswordPanel
