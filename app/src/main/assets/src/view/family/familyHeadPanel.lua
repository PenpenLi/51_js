
local FamilyHeadPanel=class("FamilyHeadPanel",UILayer)

function FamilyHeadPanel:ctor(type)
    self:init("ui/ui_family_create_head.map")

    for i = 1,10 do
        local icon = cc.Sprite:create("images/ui_family/bp_icon_"..i..".png");
        gAddChildInCenterPos(self:getNode("btn"..i),icon);
    end
end


function FamilyHeadPanel:onTouchEnded(target)

    local pos = string.find(target.touchName,"btn");
    -- print("pos = "..pos);
    if pos > 0 then
        local index = string.sub(target.touchName,pos+3);
        self.onChooseIcon(toint(index));
        self:onClose();
    end

end

return FamilyHeadPanel