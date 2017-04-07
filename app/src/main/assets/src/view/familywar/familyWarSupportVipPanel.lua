
local FamilyWarSupportVipPanel=class("FamilyWarSupportVipPanel",UILayer)

function FamilyWarSupportVipPanel:ctor(type)
    self:init("ui/ui_family_search.map")  
 
end
 

function FamilyWarSupportVipPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then 
    
    end
end
 

return FamilyWarSupportVipPanel