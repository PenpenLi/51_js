
local FamilyContrbutionItem=class("FamilyContrbutionItem",UILayer)

function FamilyContrbutionItem:ctor(type)
  
end

function FamilyContrbutionItem:initPanel() 
    self:init("ui/ui_family_contribution_item.map");
    self:refreshBtn();
end

function FamilyContrbutionItem:onTouchEnded(target)

  print("target name = "..target.touchName);

  if(target.touchName == "btn")then
    self.onClick(self.curData);
  end

end

function FamilyContrbutionItem:refreshBtn()
  if(gFamilyInfo.iWoodNum<=0)then
    self:setTouchEnable("btn",false,true);
  end
end

function FamilyContrbutionItem:setData(data) 

    self:initPanel();
    self.curData=data;

    -- self:setLabelString("num_wood",data.wood);
    self:setLabelString("num_fexp",data.getExp);

      self:getNode("icon_gold"):setVisible(false);
      self:getNode("icon_dia"):setVisible(false); 
   if data.constItemId == OPEN_BOX_GOLD then
      self:getNode("icon_gold"):setVisible(true);
   elseif data.constItemId == OPEN_BOX_DIAMOND then
      self:getNode("icon_dia"):setVisible(true);   
   end

   self:setLabelString("txt_num",data.costItemNum);
   -- self:getNode("txt_num");
end

function  FamilyContrbutionItem:events()
    return {EVENT_ID_FAMILY_CUT}
end

function FamilyContrbutionItem:dealEvent(event,param)

    if(event == EVENT_ID_FAMILY_CUT) then
      self:refreshBtn();
    end

end


return FamilyContrbutionItem