local PetAwakePreviewPanel=class("PetAwakePreviewPanel",UILayer)

function PetAwakePreviewPanel:ctor( petId)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self.isWindow = true;
    self._panelTop = true;

    self:init("ui/ui_petawake_preview.map")
    local pet = Data.getUserPetById(petId)
    local awakeLv = 0
    if(pet == nil)then
        pet = DB.getCardById(petId)
        -- card.weaponLv = 0;
        -- card.awakeLv = 0;
        showTip = true
    else
        showTip = pet.grade < 5
        awakeLv = pet.grade - 5
        if awakeLv < 0 then
            awakeLv = 0
        end
    end
    self:getNode("tip"):setVisible(showTip)

    if not showTip then
        local petInfo = DB.getPetById(petId)
        local infos = gGetMapWords("ui_petawake_preview.plist","2",petInfo.wakeup_sklillvmax)
        self:setLabelString("txt_awake1", infos)
        infos = gGetMapWords("ui_petawake_preview.plist","4",petInfo.wakeup_bufflvmax)
        self:setLabelString("txt_awake2", infos)
        infos = gGetMapWords("ui_petawake_preview.plist","5",petInfo.wakeup_attrpercent)
        self:setLabelString("txt_awake3", infos)
    end
    self:getNode("layer_awake"):setVisible(not showTip)

    for i=1, 2 do
        local item=PetAwakePreviewItem.new(petId,i-1)
        item:setPositionY(item:getContentSize().height)
        self:getNode("pos"..i):addChild(item)
    end
    self:resetLayOut()
end


function PetAwakePreviewPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return PetAwakePreviewPanel

 