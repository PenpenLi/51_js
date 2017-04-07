local PetTalentReplaceItem=class("PetTalentReplaceItem",UILayer)

function PetTalentReplaceItem:ctor()
    self:init("ui/ui_lingshou_tianfutihuan_item.map")
    self:setSel(false)
end


function PetTalentReplaceItem:setData(data)
    self.curData=data
    local stvar=DB.getSpecialTalentById(data.itemid)
    self:setLabelString("txt_name",stvar.name)
    Icon.setPetTalentSkillIcon(data.itemid,self:getNode("icon"))
end

function PetTalentReplaceItem:setSel(sel)
    self:getNode("sel_btn"):setVisible(sel)
end

function PetTalentReplaceItem:showActivityFla()
    local talent_light = gCreateFla("ui_lingshou_icon_guangdian");
    if talent_light then
        talent_light:setLocalZOrder(1111)
        talent_light:setTag(1111);
        gAddCenter(talent_light, self:getNode("icon"))
    end
end


function PetTalentReplaceItem:onTouchEnded(target)
    if self.selCallBack then
        self.selCallBack(self.curData)
    end
end

return PetTalentReplaceItem