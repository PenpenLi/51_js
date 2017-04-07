
local FamilyHDEnterPanel=class("FamilyHDEnterPanel",UILayer)

function FamilyHDEnterPanel:ctor(type)
    self:init("ui/ui_family_huodong_bg.map")

    for i=1,4 do
        local item = FamilyHDItem.new(i);
        self:getNode("scroll"):addItem(item);
    end
    self:getNode("scroll"):layout();
end

function FamilyHDEnterPanel:onPopup()
	local items = self:getNode("scroll"):getAllItem();
	for key,item in pairs(items) do
		item:initTip();
	end
end

function FamilyHDEnterPanel:getItem(index)
	return self:getNode("scroll"):getItem(index);
end

function FamilyHDEnterPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    end

end

return FamilyHDEnterPanel