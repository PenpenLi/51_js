local PetNoticePanel=class("PetNoticePanel",UILayer)

function PetNoticePanel:ctor(table_data)
    self:init("ui/ui_pet_notice.map")

    local bg = self:getNode("bg");
    local layout = self:getNode("layout");
    local layout2 = self:getNode("layout2");
    local tex3 = self:getNode("txt3")

    self:setLabelString("txt1",gGetWords("petWords.plist","lab_up_add_all_attr2"))

    if table_data.attr~=nil then
        local attrName = gGetWords("cardAttrWords.plist", "attr" .. table_data.attr) 
        self:setLabelString("txt2",attrName)
        self:setLabelString("txt3",table_data.value)
        if table_data.add ~= 0 then
            self:setLabelString("txt4","+"..table_data.add)
        else
            self:setLabelString("txt4","")
        end
        self:setRTFString("txt10","")
    else
        self:setLabelString("txt4","")
        self:setLabelString("txt3","")
        self:setLabelString("txt2","")
        self:setLabelString("txt_add","")
        local formatValue = ""
        for i=1,3 do
            local attrType = table_data["attr"..i]
            if attrType then
                local attrName = CardPro.getAttrName(attrType)
                local attrValue = CardPro.getAttrValue(attrType,table_data["value"..i])
                formatValue = formatValue .. string.format("%s  \\w{c=ffffff}+%s\\  ", attrName,attrValue)
            end
        end
        self:setRTFString("txt10",formatValue)
    end
    
    if table_data.exAttr ~= nil then
        if table_data.exAttr.type == 1 then
            local exAttrTitle = gGetWords("constellationWords.plist", "notice_active_group")
            self:setLabelString("txt_ex_title", exAttrTitle)
            self:setLabelString("txt_ex_value", string.format("+%d", table_data.exAttr.value))
        end
        self:getNode("layout_ex_attr"):setVisible(true)
    else
        self:getNode("layout_ex_attr"):setVisible(false)
    end
    self:resetLayOut()

    local function removeSelfCallback()
        self:runAction(cc.RemoveSelf:create())
    end
    local function changeCallback()
        local time1 = 0.5;
        -- layout2:setScale(1);
        layout2:runAction(cc.ScaleTo:create(0.3,1));
        bg:runAction(cc.Sequence:create(
                cc.DelayTime:create(time1),
                cc.Spawn:create(
                    cc.MoveBy:create(time1,cc.p(0,70)),
                    cc.FadeTo:create(time1,0)),
                cc.CallFunc:create(removeSelfCallback)
            ));
        layout:runAction(cc.Sequence:create(
                cc.DelayTime:create(time1),
                cc.Spawn:create(
                    cc.MoveBy:create(time1,cc.p(0,70)),
                    cc.FadeTo:create(time1,0))
            ));
        if self:getNode("layout_ex_attr"):isVisible() then
            self:getNode("layout_ex_attr"):runAction(cc.Sequence:create(
                    cc.DelayTime:create(time1),
                    cc.Spawn:create(
                        cc.MoveBy:create(time1,cc.p(0,70)),
                        cc.FadeTo:create(time1,0))
                ));
        end
    end
    local function callback1()
        -- layout2:setScale(2);
        layout2:runAction(cc.ScaleTo:create(0.3,2));
        if table_data.value then
            self:updateLabelChange("txt3",table_data.value,table_data.value+table_data.add,changeCallback)
        else
            changeCallback()
        end
    end
    local function callback2()
        local time1 = 0.5;
        local tex4 = self:getNode("txt4")
        tex4:runAction(cc.Spawn:create(
                cc.MoveBy:create(time1,cc.p(-60,0)),
                cc.FadeTo:create(time1,0)))
    end
    bg:setAllChildCascadeOpacityEnabled(true);
    bg:setOpacity(0);
    bg:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeTo:create(0.1,255)
                -- cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1))
                ),
            cc.CallFunc:create(callback2),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(callback1)
        ));
end

return PetNoticePanel