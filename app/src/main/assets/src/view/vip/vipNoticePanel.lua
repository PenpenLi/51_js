local VipNoticePanel=class("VipNoticePanel",UILayer)

function VipNoticePanel:ctor(isRefresh)
    self.appearType = 1;
    self:init("ui/ui_viptime_notice.map")
    self._panelTop = true;
    if(isRefresh)then
        self:setLabelString("txt_content",gGetWords("vipWords.plist","maxRefresh"));
    end
    self:addFullScreenTouchToClose();
    -- gCreateTouchScreenTip(self,cc.c3b(255,255,255));
end

function VipNoticePanel:onTouchEnded(target)

    if  target.touchName=="full_close" or target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_confirm" then
        Panel.popBack(self:getTag());
        Panel.popUp(PANEL_VIP);
    end
end

return VipNoticePanel