local AtlasFormationItem=class("AtlasFormationItem",UILayer)

function AtlasFormationItem:ctor(type)
    self.itemType=type
end

function AtlasFormationItem:initPanel() 
    if(self.inited==true)then
        return 
    end 
    self.inited=true
    self:init("ui/ui_formation_item.map")
    self:getNode("icon_selected"):setVisible(false)
    self.starContainerX= self:getNode("star_container"):getPositionX()
    self:getNode("touch_node").__touchend=true
end


function AtlasFormationItem:onTouchBegan(target,touch, event)

    self.preLocation = touch:getLocation()

end

function  AtlasFormationItem:createDrag(touch)
    if(self:getNode("icon_selected"):isVisible()==true)then
        return
    end

    if(self.selectItemCallback==nil)then
        return
    end

    if(gDragLayer:getChildrenCount()==1  )then
        return
    end
    gDragLayer:removeAllChildren()
    local node=cc.Node:create()
    node:setTag(1)
    if(self.cardDb)then
        gCreateRoleFla(self.cardDb.cardid,node,0.8,false,"r"..self.cardDb.cardid.."_wait",self.curCard.weaponLv,self.curCard.awakeLv);  
    elseif(self.petDb)then
        gCreateRoleFla(self.petDb.petid,node,0.8,false,"r"..self.petDb.petid.."_wait",nil,Pet.getPetAwakeLv(self.petDb.petid))
    end
 
    gDragLayer:addChild(node)
    local location = touch:getLocation()
    node:setPosition(location.x,location.y)

end

function  AtlasFormationItem:setDataLazyCalled()
    self:setData(self.lazyData)
end

function  AtlasFormationItem:setLazyData(data)
    self.lazyData=data 
    self.curCard=data
    Scene.addLazyFunc(self,self.setDataLazyCalled,"formation")
end



function   AtlasFormationItem:setData(card)
    self:initPanel()
    self.curCard=card
    
    if(self.lazySelect)then
        self:setSelected(self.lazySelect)
    end

    if(self.curCard.petid)then

        self.petDb=DB.getPetById(self.curCard.petid)
        if(self.petDb==nil)then
            return
        end
        self:setLabelString("txt_level",self.petDb.level)
        self:showStar(self.curCard.grade,self.curCard.awakeLv)
        Icon.setIcon(self.curCard.petid,self:getNode("icon"),DB.getItemQuality(self.curCard.petid), card.awakeLv)
        self:getNode("icon_card_type"):setVisible(false)


    else
        self.cardDb=DB.getCardById(self.curCard.cardid)
        if(self.cardDb==nil)then
            return
        end
        self:setLabelString("txt_level",self.curCard.level)
        self:showStar(self.curCard.grade,self.curCard.awakeLv)
        Icon.setIcon(self.cardDb.cardid,self:getNode("icon"),card.quality,card.awakeLv)
        self:changeTexture("icon_card_type","images/ui_public1/card_type_"..self.cardDb.type..".png")

    end


end

function AtlasFormationItem:setSelected(value)
    if( self.inited~=true)then
        self.lazySelect=value
        return
    end
    if(value)then
        self:getNode("icon_selected"):setVisible(true)
    else
        self:getNode("icon_selected"):setVisible(false)

    end
end


function AtlasFormationItem:onTouchMoved(target,touch, event)

    local location = touch:getLocation()
    local size=cc.Director:getInstance():getWinSize()
    if(location.x>size.width/2-150 or location.x-self.preLocation.x>80)then
        self:createDrag(touch)
    end


    local node=  gDragLayer:getChildByTag(1)
    if(node)then
        target._hasScrollParent=false
        node:setPosition(location.x,location.y)
    end
    if(self.moveItemCallback)then
        if(self.curCard.petid)then
            self.moveItemCallback(location,self.curCard.petid)
        elseif(self.curCard.cardid)then 
            self.moveItemCallback(location,self.curCard.cardid)
        end
    end
end


function AtlasFormationItem:onTouchEnded(target,touch, event)
    if(self:getNode("icon_selected"):isVisible()==true)then
        return
    end
    local location = touch:getLocation()
    if(self.selectItemCallback)then
        if(self.curCard.petid)then
            self.selectItemCallback(location,self.curCard.petid)
        elseif(self.curCard.cardid)then 
            self.selectItemCallback(location,self.curCard.cardid)
        end
    end
    
    local parent=target:getParent()
    while(parent~=nil)do
        if(parent.__cname=="ScrollLayer")then
            parent:onTouchEnded(touch,event)
            break
        end
        parent=parent:getParent()
    end
    self.hasDrag=false
end




function AtlasFormationItem:showStar(num,awakeLv)
    CardPro:showStar(self,num,awakeLv,-10)
end



return AtlasFormationItem