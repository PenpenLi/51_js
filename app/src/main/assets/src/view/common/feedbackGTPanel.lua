local FeedbackGTPanel=class("FeedbackGTPanel",UILayer)
function FeedbackGTPanel:ctor()
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_feedback_gt.map")
end


function FeedbackGTPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
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



return FeedbackGTPanel