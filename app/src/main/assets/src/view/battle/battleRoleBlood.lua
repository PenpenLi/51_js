local BattleRoleBlood=class("BattleRoleBlood",UILayer)

--start 17
--end 53

function BattleRoleBlood:ctor()
    local node=cc.Node:create()
    self:addChild(node)
    node:setScaleY(0.5)  
    
    self.container=node
    
    local bg=cc.Sprite:create("images/battle/blood_bg.png")
    node:addChild(bg)
    
    local redBar=cc.ProgressTimer:create(cc.Sprite:create("images/battle/red_bar.png"))  
    node:addChild(redBar)
    

    local blueBar=cc.ProgressTimer:create(cc.Sprite:create("images/battle/blue_bar.png")) 
    node:addChild(blueBar)


    local buffContainer=cc.Node:create()
    node:addChild(buffContainer)
    self.buffContainer=buffContainer
    self.buffContainer:setScaleY(2)  
    
    self.blueBar=blueBar
    self.redBar=redBar
    
    self.emptyBlood=nil
end
 

 
function BattleRoleBlood:hideEmptyNotice()
    if( self.emptyBlood==nil)then
        return 
    end
    self.emptyBlood:removeFromParent()
    self.emptyBlood=nil 
end

function BattleRoleBlood:showEmptyNotice()
    if( self.emptyBlood)then
        return 
    end
    self.emptyBlood =FlashAni.new() 
    self.container:addChild(self.emptyBlood ,-1)
    self.emptyBlood :playAction("battle_blood_empty")
end

function BattleRoleBlood:resetBlue(motion) 
    self:setCurBlue(0,motion,0)
end

function BattleRoleBlood:setMaxRed(num)
    self.maxRed=num
end

function BattleRoleBlood:setMaxBlue(num) 
    self.maxBlue=num
end

function BattleRoleBlood:reduceBlue(num,motion) 
    self:setCurBlue(self.curBlue-num,motion,self.curBlue)
end
function BattleRoleBlood:addBlue(num,motion) 
    self:setCurBlue(self.curBlue+num,motion,self.curBlue)
end

function BattleRoleBlood:reduceRed(num,motion) 
    self:setCurRed(self.curRed-num,motion,self.curRed) 
end
function BattleRoleBlood:addRed(num,motion) 
    self:setCurRed(self.curRed+num,motion,self.curRed)
end

function BattleRoleBlood:setCurRed(num,motion,lastRed)
    self.curRed=num
    
    if(lastRed==nil)then
        lastRed=0
    end

    if(self.curRed<0) then
        self.curRed=0
    end
    

    if(self.curRed>self.maxRed) then
        self.curRed=self.maxRed
    end
    
    if(self.curRed*100/self.maxRed<50)then
        self:showEmptyNotice()
    else 
        self:hideEmptyNotice()
    end
    self:setPercentage(self.redBar,lastRed*100/self.maxRed,self.curRed*100/self.maxRed,motion)
   
end

function BattleRoleBlood:showSelected()
    if( self.selectedIcon)then
        return 
    end
    self.selectedIcon =FlashAni.new() 
    self.container:addChild(self.selectedIcon ,-1)
    self.selectedIcon:playAction("battle_selected_icon")
end

function BattleRoleBlood:showUnSelected()
    if( self.selectedIcon==nil)then
        return 
    end
    self.selectedIcon:removeFromParent()
    self.selectedIcon=nil 
end




function BattleRoleBlood:showSetSelectMode(same,fla)
    if( self.selectedIcon)then
        return 
    end
    self.selectedIcon =FlashAni.new() 
    self.container:addChild(self.selectedIcon ,-1)
    if(fla)then
        self.selectedIcon:playAction(fla)
        self.selectedIcon:setScaleY(2)  
    else
        if(same)then 
            self.selectedIcon:playAction("battle_blood_green_select")
        else
            self.selectedIcon:playAction("battle_blood_red_select")
        end
    end
  
end

function BattleRoleBlood:showUnSetSelectMode()
    if( self.selectedIcon==nil)then
        return 
    end
    self.selectedIcon:removeFromParent()
    self.selectedIcon=nil 
end



function BattleRoleBlood:setPercentage(bar,from ,to ,motion)
    
    local fromPer=(from/100)*(53-17)+17
    local toPer=(to/100)*(53-17)+17
     
    if(motion) then
        bar:stopAllActions()
        local progressTo=cc.ProgressFromTo:create(0.2,fromPer,toPer) 
        bar:runAction( progressTo) 
    else  
        bar:setPercentage( toPer)
    end
end

function BattleRoleBlood:setCurBlue(num,motion,lastBlue)
    self.curBlue=num
    
    if(lastBlue==nil)then
        lastBlue=0
    end
    
    if(self.curBlue<0) then
        self.curBlue=0
    end
     
    if(self.curBlue>self.maxBlue) then
        self.curBlue=self.maxBlue
    end
    self:setPercentage(self.blueBar,lastBlue*100/self.maxBlue,self.curBlue*100/self.maxBlue,motion)
  
end

return BattleRoleBlood