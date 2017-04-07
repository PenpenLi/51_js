local PetTowerBoxInfoPanel=class("PetTowerBoxInfoPanel",UILayer)

function PetTowerBoxInfoPanel:ctor(panel)

    self:init("ui/ui_pet_tower_box_info.map")

    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll").offsetY=0
    self:getNode("scroll").offsetX=20
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local boxids={ BOX_KEY_ID1,BOX_KEY_ID2,BOX_KEY_ID3}
    for i=1, 3 do 
        local item=PetTowerBoxInfoItem.new()
        item:setData(boxids[i]) 
        self:getNode("scroll"):addItem(item)  
    end
    
    self:getNode("scroll"):layout()

end


function PetTowerBoxInfoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    end
end

return PetTowerBoxInfoPanel