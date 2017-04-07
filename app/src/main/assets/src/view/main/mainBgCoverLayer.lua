local MainBgCoverLayer=class("MainBgCoverLayer",UILayer)

function MainBgCoverLayer:ctor()
    self:init("ui/ui_main_cover.map")


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

     

end

function MainBgCoverLayer:changeNight()
    if(self.isNight==true)then
        return
    end
    self.isNight=true
    self:changeTexture("bg","images/ui_huodong/bg_night.png")
end


function MainBgCoverLayer:changeMoring()
    if(self.isNight==false)then
        return
    end
    self.isNight=false
    self:changeTexture("bg","images/ui_huodong/bg.png")

end

return MainBgCoverLayer