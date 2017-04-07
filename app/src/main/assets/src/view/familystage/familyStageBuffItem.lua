local FamilyStageBuffItem=class("FamilyStageBuffItem",UILayer)

function FamilyStageBuffItem:ctor(buffid, idx)
    self:init("ui/ui_family_stage_buff_item.map")
    self.chooseFlag = false
    self.idx = idx
    local buff = DB.getBuffById(buffid)
    self:setLabelString("txt_buff_desc", gGetBuffDesc(buff,1))
end


function FamilyStageBuffItem:onTouchEnded(target, touch, event)
    if target.touchName=="icon_choose" then
        self.chooseFlag = not self.chooseFlag
        self:changeTexByChoose(self.chooseFlag)
        gDispatchEvt(EVENT_ID_FAMILY_STAGE_CHOOSE_BUFF, {self.idx, self.chooseFlag})
    end
end

function FamilyStageBuffItem:changeTexByChoose(isChoose)
    self.chooseFlag = isChoose
    if isChoose then
        self:changeTexture("icon_choose", "images/ui_public1/gou_1.png")
    else
        self:changeTexture("icon_choose", "images/ui_public1/gou_2.png")
    end
end


return FamilyStageBuffItem