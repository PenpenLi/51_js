local TipTouchPetTalentSkill=class("TipTouchPetTalentSkill",UILayer)

function TipTouchPetTalentSkill:ctor(data)
    self:init("ui/tip_touch_skill.map")

    self:getNode("txt_limit"):setVisible(false)
    self:getNode("txt_info"):setVisible(false)
    self:getNode("txt_rtf_info"):setVisible(true)

    self:setLabelString("txt_name",data.name) 
    self:getNode("txt_extr_add"):setVisible(data.petid>0)

    local param1 = ""
    local param2 = ""
    local buffbd1 = DB.getBuffById(data.bufid1)
    local buffbd2 = DB.getBuffById(data.bufid2)
    if buffbd1 then
        if buffbd1.rate>0 then
            param1=buffbd1.rate.."%"
        else
            param1=CardPro.getAttrValue(buffbd1.attr_id0,buffbd1.attr_value0)
            if buffbd1.type==45 then
                param1=param1.."%"
            elseif buffbd1.type==48 then
                param1=buffbd1.attr_value1.."%"
            end
        end
    end
    if buffbd2 then
        if buffbd2.rate>0 then
            param2=buffbd2.rate.."%"
        else
            param2=CardPro.getAttrValue(buffbd2.attr_id0,buffbd2.attr_value0)
            if buffbd2.type==45 then
                param2=param2.."%"
            elseif buffbd2.type==48 then
                param2=buffbd2.attr_value1.."%"
            end
        end
    end
    self:setRTFString("txt_rtf_info", gReplaceParam(data.des,param1,param2))
    self:resetLayOut()
     
     local size=self:getNode("layout"):getContentSize()
     size.width= self:getNode("tip_bg"):getContentSize().width
     size.height=size.height+30
     self:getNode("tip_bg"):setContentSize(size)
     self:setContentSize(size);
end


 
return TipTouchPetTalentSkill