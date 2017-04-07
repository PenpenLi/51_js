local AppStoreConfirmPanel=class("AppStoreConfirmPanel",UILayer)

function AppStoreConfirmPanel:ctor(type)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_appstore_confirm.map")
    -- self.__tip = true
    self.ignoreGuide = true
    self.panelType = type
    self:initPanel()
end

function AppStoreConfirmPanel:initPanel()
    self:setLabelString("lab_title", gGetWords("labelWords.plist","lab_apps_title"..self.panelType))
    self.bg_content = self:getNode("bg_content")
    self.min_width = self.bg_content:getContentSize().width
    self.max_width = self.min_width + 200
    local lab_content = gCreateWordLabelTTF(gGetWords("labelWords.plist","lab_apps_info"..self.panelType),gCustomFont,20,cc.c3b(0,0,0),cc.size(self.min_width,0))
    gAddChildInCenterPos(self.bg_content,lab_content)
    self:setLabelString("txt_cancel", gGetWords("labelWords.plist","lab_apps_txt"..self.panelType.."_1"))
    self:setLabelString("txt_confirm", gGetWords("labelWords.plist","lab_apps_txt"..self.panelType.."_2"))
end

function AppStoreConfirmPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" or target.touchName == "btn_cancel" then
        self:onClose()
    elseif target.touchName == "btn_confirm" then
        Data.openAppStoreCommentURL()
        Net.sendAchiFapp()
        self:onClose()
    end
end

return AppStoreConfirmPanel
