local FamilyModuleItem=class("FamilyModuleItem",UILayer)

function FamilyModuleItem:ctor()
   
end

function FamilyModuleItem:initPanel() 
    self:init("ui/ui_family_module_item.map");
end

function FamilyModuleItem:onTouchEnded(target)

	-- print("target name = "..target.touchName);

  if(target.touchName == "bg")then
    self.onClick(self.curData);
  end

end


function FamilyModuleItem:setData(data) 
    self:initPanel();
    self.curData=data;

    self:changeTexture("bg","images/ui_family/icon_"..data.id..".png");
    -- self:setLabelString("txt_name",gGetWords("familyWords.plist","name"..data.id));
   
end

return FamilyModuleItem