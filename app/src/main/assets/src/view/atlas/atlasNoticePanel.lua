local AtlasNoticePanel=class("AtlasNoticePanel",UILayer)

function AtlasNoticePanel:ctor()
    self.appearType = 1;
    self:init("ui/ui_atlas_notice.map")
    self._panelTop = true;
    self:addFullScreenTouchToClose();
-- gCreateTouchScreenTip(self,cc.c3b(255,255,255));
end

function AtlasNoticePanel:onTouchEnded(target)
 
    if  target.touchName=="full_close" or target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_confirm" then
        Panel.popBack(self:getTag());
        Guide.clearGuide()
        Panel.popUp(PANEL_CARD)
        GuideStepData.atlasNotice.findSweepWeapon()
    end
end


return AtlasNoticePanel