local AtlasFormationRole=class("AtlasFormationRole",UILayer)

function AtlasFormationRole:ctor(type)
    self:init("ui/ui_formation_role.map")
    self.itemType=type 
    self:getNode("touch_node").__touchend=true
end 


function AtlasFormationRole:onTouchBegan(target,touch, event)
   
    
    if(self.selectItemCallback==nil)then
        return 
    end
     
    gDragLayer:removeAllChildren()
    local node=cc.Node:create()
    node:setTag(1)
    local awakeLv = self.curCard.awakeLv
    if self:getTag()==PET_POS then
        awakeLv = Pet.getPetAwakeLv(self.curId)
    end
    gCreateRoleFla(self.curId, node,0.8,false,"r"..self.curId.."_wait",self.curCard.weaponLv,awakeLv);  
    gDragLayer:addChild(node)
    local location = touch:getLocation()
    node:setPosition(location.x,location.y)
    
    
    
end


 

function AtlasFormationRole:onTouchMoved(target,touch, event)
    local node=  gDragLayer:getChildByTag(1)
    if(node==nil)then
        return
    end

    local location = touch:getLocation()
    node:setPosition(location.x,location.y)
    if(self.moveItemCallback)then
        self.moveItemCallback(location,self.curId)
    end
end


function AtlasFormationRole:onTouchEnded(target,touch, event)
    

    local location = touch:getLocation()
    if(self.selectItemCallback)then
        self.selectItemCallback(location,self.curId)
    end
end


function   AtlasFormationRole:setData(card) 
    self.curCard=card
    if(self:getTag()==PET_POS)then
        self.curId=self.curCard.petid
    else
        self.curId=self.curCard.cardid
    end

    local awakeLv = card.awakeLv
    if self:getTag()==PET_POS then
        awakeLv = Pet.getPetAwakeLv(self.curId)
    end
    gCreateRoleFla(self.curId, self:getNode("role_container"),0.6,false,"r"..self.curId.."_wait",card.weaponLv,awakeLv); 
    Scene.addFlaTextureCache("r"..self.curId.."_wait",card.weaponLv,awakeLv);
end

 


return AtlasFormationRole