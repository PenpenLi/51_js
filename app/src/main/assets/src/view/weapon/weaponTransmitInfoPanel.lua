local WeaponTransmitInfoPanel=class("WeaponTransmitInfoPanel",UILayer)
 

function WeaponTransmitInfoPanel:ctor(type,data)

    self:init("ui/ui_weapon.map")
 
end
 

function WeaponTransmitInfoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())     
    end
end

return WeaponTransmitInfoPanel