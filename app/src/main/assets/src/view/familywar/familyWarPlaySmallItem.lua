local FamilyWarPlaySmallItem=class("FamilyWarPlaySmallItem",UILayer)

function FamilyWarPlaySmallItem:ctor()
    self:init("ui/ui_family_war_play_small_item.map");  
end

 



function FamilyWarPlaySmallItem:setData(data)
    self.idx = index;
    self.curData=data; 
    self:setLabelString("txt_name", data.name);  
    Icon.setHeadIcon(self:getNode("icon"),data.icon);
    self:getNode("icon_die"):setVisible(false)
    self.isDie=false
end

function FamilyWarPlaySmallItem:showDie() 
    self:getNode("icon_die"):setVisible(true)
    self.isDie=true
    DisplayUtil.setGray(self:getNode("icon"),true)
end

return FamilyWarPlaySmallItem