local PetTowerBoxInfoItem=class("PetTowerBoxInfoItem",UILayer)

function PetTowerBoxInfoItem:ctor(panel)

    self:init("ui/ui_pet_tower_box_info_item.map")
     
end


function PetTowerBoxInfoItem:setData(id)
    local box=DB.getItemById(id)
    if(box)then
        self:setLabelString("txt_desc1",box.des)
        self:setLabelString("txt_desc2",box.detail)
        Icon.setIcon(id,self:getNode("icon"))
    end
end

return PetTowerBoxInfoItem