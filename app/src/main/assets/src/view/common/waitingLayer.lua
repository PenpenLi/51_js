local WaitingLayer=class("WaitingLayer",UILayer)

function WaitingLayer:ctor()
    self:init("ui/ui_loading_s.map")


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    local function onNodeEvent(event)
        if event == "enter" then
            self:getNode("icon").curAction=""
            self:getNode("icon"):playAction("loading_4")
        elseif event == "exit" then
            self:getNode("icon"):pause()
        end
    end
    self:registerScriptHandler(onNodeEvent);
end



return WaitingLayer