local DragonLayer=class("DragonLayer", function()
    return cc.Node:create()
end)

function DragonLayer:ctor() 
    
    local dragon3D=Dragon3D.new() 
    self:addChild(dragon3D)
    dragon3D:initScene("fightScript/drawCardScene.plist") 
    dragon3D:inited()
    dragon3D:playWait()
    self.dragon3D=dragon3D
    local winSize = cc.Director:getInstance():getWinSize()  
    self.dragon3D:setPosition(cc.p( winSize.width /2, winSize.height/2))
    
    self.dragonUi=DragonUI.new()
    self.dragonUi.dragon3D=dragon3D
    self:addChild(self.dragonUi) 
end

function DragonLayer:setItems(items,type,cidArray)
    if(items==nil)then
        return
    end
    local itemCount=table.getn(items)
    self.dragonUi:setItems(items,type,cidArray) 
    if(itemCount==10)then
        self.dragon3D:playBuyTen()
    else
        self.dragon3D:playBuyOne()
    end
end

function DragonLayer:events()
    if(self.dragonUi)then
        return self.dragonUi:events();
    end
    return {};
end

function DragonLayer:dealEvent(event,param)
    if(self.dragonUi)then
        self.dragonUi:dealEvent(event,param);
    end
end


return DragonLayer