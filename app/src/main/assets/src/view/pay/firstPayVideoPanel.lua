local FirstPayVideoPanel=class("FirstPayVideoPanel",UILayer)

function FirstPayVideoPanel:ctor(type)
	self.appearType = 1;
	self._panelTop = true;
    self:init("ui/ui_first_pay_video.map")

    local function callback()
        self:getNode("video").curAction=""
        self:getNode("video"):playAction("r10013_video",callback)
    end
    self:getNode("video"):playAction("r10013_video",callback)
end

function FirstPayVideoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    end
end
return FirstPayVideoPanel