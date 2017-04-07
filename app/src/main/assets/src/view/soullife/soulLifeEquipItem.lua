local SoulLifeEquipItem=class("SoulLifeEquipItem",UILayer)

function SoulLifeEquipItem:ctor(spirit, bagType)
    self.spirit  = spirit
    self.bagType = bagType
end

function SoulLifeEquipItem:initPanel()
    --设置Icon
    Icon.setSpiritIcon(self.spirit.iType, self:getNode("icon_bg"))
    local name =  gGetSpiritAttrNameByType(self.spirit.iType, self.spirit.iAttr)
    self:getNode("txt_name"):setString(name)
    self:getNode("txt_name"):setColor(gCreateSpiritNameColor(self.spirit.iType))
    local addLv = 0
    if self.spirit.iPos ~= 0 then
        addLv = DB.getSpiritAddLevByPos(self.spirit.iPos % 10)
    end
    self:getNode("txt_lv"):setString(getLvReviewName("Lv") .. self.spirit.iLV)
    if addLv ~= 0 then
        self:getNode("txt_add_lv"):setString("+" .. addLv)
        self:getNode("txt_add_lv"):setVisible(true)
    end
    self:getNode("layout_lv"):layout()

    local spiritAttr  = DB.getSpiritAttr(self.spirit.iType, self.spirit.iLV + addLv, self.spirit.iAttr)
    local attrName, attrValue= gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)
    self:getNode("txt_attr"):setString(attrName)
    self:getNode("txt_value"):setString(attrValue)
    self:getNode("layout_attr"):layout()
    if spiritAttr.attr2 ~= 0 then
        local attrName2,attrValue2 = gGetSpiritAttrNameAndValue(spiritAttr.attr2, spiritAttr.value2)
        self:getNode("txt_attr2"):setString(attrName2)
        self:getNode("txt_value2"):setString(attrValue2)
        self:getNode("layout_attr2"):layout()
        self:getNode("layout_attr2"):setVisible(true)
    end

    if SOULLIFE_BAG_TYPE.EQU == self.bagType then
        if self.spirit.iPos ~= 0 then
            self:setLabelString("txt_equip_detail", gGetWords("spiritWord.plist","spirit_detail_exchange"))
        else
            self:setLabelString("txt_equip_detail", gGetWords("spiritWord.plist","spirit_equip_item_txt"))
        end
        if SpiritInfo.spiritCanBeEqued(self.spirit, SpiritInfo.getCurEquSpiritPos()) then
            self:setTouchEnable("btn_equip", true, false)
        else
            self:setTouchEnable("btn_equip", false, true)    
        end
        self:getNode("btn_equip"):setVisible(true)
        self:getNode("btn_upgrade"):setVisible(false)
    else
        self:getNode("btn_equip"):setVisible(false)
        self:getNode("btn_upgrade"):setVisible(true)
    end

    if self.spirit.iPos ~= 0 then
        local info = gGetWords("spiritWord.plist", "soullife_alread_equ", gGetPosNameOfSpirit(self.spirit.iPos))
        self:getNode("txt_equiped"):setString(info)
        self:getNode("txt_equiped"):setVisible(true)
    else
        self:getNode("txt_equiped"):setVisible(false)
    end
end

function SoulLifeEquipItem:onTouchEnded(target,touch, event)
    if target.touchName=="btn_equip" then
        Panel.getPanelByType(PANEL_SOULLIFE_EQUIP):onClose()
        -- print("getCurEquSpiritPos is:",SpiritInfo.getCurEquSpiritPos())
        if self.spirit.iPos ~= 0 then
            -- print("getCurEquSpiritPos is step1")
            Net.sendSpiritChangePos(SpiritInfo.getCurEquSpiritPos(), self.spirit.iPos)
        else
            -- print("getCurEquSpiritPos is step2")
            Net.sendSpiritEqu(SpiritInfo.getCurEquSpiritPos(), self.spirit.iID)
        end
    elseif target.touchName=="btn_upgrade" then
        Panel.getPanelByType(PANEL_SOULLIFE_EQUIP).onDisappear=nil
        local upgradeSpirit = self.spirit
        Panel.getPanelByType(PANEL_SOULLIFE_EQUIP):onClose()
        -- Panel.popUpVisible(PANEL_SOULLIFE_UPGRADE,upgradeSpirit,SOULLIFE_UPGRADE_TYPE.SOULLIFE,true)
        Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, upgradeSpirit, nil, true)
    end
end

function SoulLifeEquipItem:setItem()
    self:init("ui/ui_soullife_equip_item.map")
    self:initPanel()
end

function SoulLifeEquipItem:setLazyFunc()
    Scene.addLazyFunc(self,self.setItem, "soullifeequiptem")
end

return SoulLifeEquipItem