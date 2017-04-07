local FamilyWarSupportItem=class("FamilyWarSupportItem",UILayer)

function FamilyWarSupportItem:ctor()
    self:init("ui/ui_family_war_support_item.map");

end

function FamilyWarSupportItem:onTouchEnded(target)
 
    if(target.touchName=="btn_support1")then 
    
    elseif(target.touchName=="btn_support2")then 
    
    end  
end

function FamilyWarSupportItem:setData(data,index)  
    self.idx = index;
    self.curData=data;


    self:setLabelString("txt_name1",data.name1);
    self:setLabelString("txt_name2",data.name2);
  
end

 

return FamilyWarSupportItem