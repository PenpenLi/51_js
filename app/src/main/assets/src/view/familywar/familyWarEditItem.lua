local FamilyWarEditItem=class("FamilyWarEditItem",UILayer)

function FamilyWarEditItem:ctor()
    self:init("ui/ui_family_war_edit_item.map"); 
    self:getNode("arrow"):setVisible(false)
    self:getNode("icon"):setVisible(false)
    self:setLabelString("txt_name","")
    self:getNode("bg"):setVisible(false)
    self:getNode("touch_node").__touchend=true 
    self.canMoveH=false
end


function FamilyWarEditItem:onTouchEnded(target,touch)
  
    if( self.isCreateDrag and self.isEditMode==true)then
        self.preLocation = touch:getLocation()

        if(self.dragCallback)then
            self.dragCallback(self,self.preLocation)
        end
        return
    end
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData,self.idx)
    end
end


function FamilyWarEditItem:showPutIn()  
    self:getNode("icon"):setScale(1.4)
    self:getNode("icon"):runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.EaseBackOut:create(cc.ScaleTo:create(0.2,0.9))))
end
function FamilyWarEditItem:setEditMode(mode) 
    if(self.curData==nil)then
        return
    end
    self.isEditMode=mode 
    self:getNode("container"):setRotation(0)
    if(self.isEditMode)then
        self:getNode("container"):stopAllActions()

        local rotaion1 = cc.RotateBy:create(0.05, 3)
        local rotaion2 = rotaion1:reverse()
        local rotaion3 = cc.RotateBy:create(0.05 ,-3)
        local rotaion4 = rotaion2:reverse()
        self:getNode("arrow"):setVisible(false)
        self:getNode("container"):runAction(cc.RepeatForever:create(cc.Sequence:create(rotaion1,rotaion2,rotaion3,rotaion4)))
    else 
        self:getNode("arrow"):setVisible(false)
        self:getNode("container"):stopAllActions() 
    end
end

function FamilyWarEditItem:onTouchBegan(target,touch, event) 
    if(self.isEditMode~=true )then
        return false
    end
    
    
    self.isCreateDrag=false
    self.preLocation = touch:getLocation()
    gDragLayer:removeAllChildren()

end

function  FamilyWarEditItem:createDrag(touch)

    if(gDragLayer:getChildrenCount()==1  )then
        return
    end
    local node=cc.Node:create()
    node:setTag(1)

    local item=FamilyWarEditItem.new()
    item:setData(self.curData)
    gDragLayer:addChild(node) 
    node:addChild(item)
    node:setScale(1.4)
    item:setAnchorPoint(cc.p(0.5,-0.5));
    local location = touch:getLocation()
    node:setPosition(location.x,location.y)
    self.isCreateDrag=true
end


function FamilyWarEditItem:onTouchMoved(target,touch, event)
    if(self.isEditMode~=true)then
        return false
    end
    local location = touch:getLocation()
    local size=cc.Director:getInstance():getWinSize()
    
    if( self.canMoveH==true)then
        if(location.y -self.preLocation.y>100)then
            self:createDrag(touch)
        end
    else
        self:createDrag(touch) 
    end


    local node=  gDragLayer:getChildByTag(1)
    if(node)then
        node:setPosition(location.x,location.y)
    end
end


function FamilyWarEditItem:setIndex(index) 
    if(index==-1)then 
        self:setLabelString("txt_num","")
    else
        self:setLabelString("txt_num",index)
    
    end

end

function FamilyWarEditItem:setData(data,index)
    self.idx = index;
    self.curData=data;
    self:getNode("icon"):setVisible(true)
    self:getNode("bg"):setVisible(true)
    
    if(data.uid==gUserInfo.id)then
        local item=cc.Sprite:create("images/ui_family/ME_2.png")
        item:setPositionX(90)
        item:setPositionY(-20)
        self:addChild(item,100)
    end

    self:setLabelString("txt_name",data.sName); 
    local width=self:getNode("txt_name"):getContentSize().width
    if(width>105)then
        self:getNode("txt_name"):setSystemFontSize(14)
    end
    Icon.setHeadIcon(self:getNode("icon"),data.iCoat);
end


return FamilyWarEditItem