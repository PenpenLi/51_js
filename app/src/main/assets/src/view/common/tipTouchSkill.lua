local TipTouchSkill=class("TipTouchSkill",UILayer)

function TipTouchSkill:ctor(data,level)
    self:init("ui/tip_touch_skill.map")

    self:setLabelString("txt_name",data.name) 
    self:getNode("txt_extr_add"):setVisible(false)
    if(data.skillid)then
        self:setLabelString("txt_info",gGetSkillDesc(data,level))   
    else
        self:setLabelString("txt_info",gGetBuffDesc(data,level))   
    end
    if level==-1 then
        self:getNode("txt_limit"):setVisible(false)
    end
     self:resetLayOut()
     
     local size=self:getNode("layout"):getContentSize()
     size.width= self:getNode("tip_bg"):getContentSize().width
     size.height=size.height+30
     self:getNode("tip_bg"):setContentSize(size)
     self:setContentSize(size);
end


 
return TipTouchSkill