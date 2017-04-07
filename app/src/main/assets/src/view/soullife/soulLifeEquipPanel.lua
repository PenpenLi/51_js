local SoulLifeEquipPanel=class("SoulLifeEquipPanel",UILayer)

function SoulLifeEquipPanel:ctor(bagType,exchangeSoulLife)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_soullife_equip.map")
    self.bagType=bagType
    self.exchangeSoulLife=exchangeSoulLife
    self.combineSoulLifeTable = {}
    self.hideEquiped = SpiritInfo.getHideEquiped()
    Scene.clearLazyFunc("soullifeequiptem")
    self:initPanel()
end

function SoulLifeEquipPanel:initPanel()
    self:initTitle()
    self.scrollLayer = self:getNode("scroll_equip_items")
    self.scrollLayer.eachLineNum=2
    self.scrollLayer.offsetX=10
    self.scrollLayer.offsetY=5
    self.scrollLayer:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    local drawNum = 6

    table.add(self.combineSoulLifeTable, SpiritInfo.vBagSpiritList)

    if SOULLIFE_BAG_TYPE.UPGRADE == self.bagType then
        table.add(self.combineSoulLifeTable, SpiritInfo.vSpiritList)
        self:sortUpgradeItems()
        self:getNode("panel_hide_equiped"):setVisible(false)
        self:getNode("layout_pos_equip"):setVisible(false)
        for i = 1, #self.combineSoulLifeTable do
            local spirit = self.combineSoulLifeTable[i]
            if nil ~= spirit then
                local equipItem = SoulLifeEquipItem.new(spirit, self.bagType)
                if nil ~= equipItem then
                    if drawNum > 0 then
                        equipItem:setItem()
                        drawNum = drawNum - 1
                    else
                        equipItem:setLazyFunc()
                    end
                    self.scrollLayer:addItem(equipItem)
                end
            end
        end
        self.scrollLayer:layout()
    else
        if nil ~= self.exchangeSoulLife then
            local equipedSoulLife = nil
            for i = 1, #SpiritInfo.vSpiritList do
                equipedSoulLife = SpiritInfo.vSpiritList[i]
                if nil ~= equipedSoulLife and equipedSoulLife.iID ~= self.exchangeSoulLife.iID then
                    table.insert(self.combineSoulLifeTable, equipedSoulLife)
                end
            end
        else
            table.add(self.combineSoulLifeTable, SpiritInfo.vSpiritList)
        end

        self:sortEquItems()
        self:getNode("panel_hide_equiped"):setVisible(true)
        self:getNode("layout_pos_equip"):setVisible(true)
        local targetPos = SpiritInfo.getCurEquSpiritPos()
        self:setLabelString("txt_pos_for_equip", gGetPosNameOfSpirit(targetPos))
        self:getNode("icon_choose"):setVisible(false)
        -- self:chooseHideEquiped(self.hideEquiped)
        self:getNode("icon_choose"):setVisible(self.hideEquiped)
        self:processHideEquiped(self.hideEquiped)
    end
end

function SoulLifeEquipPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="icon_choose_bg" then
        self:chooseHideEquiped(not self.hideEquiped)
    end
end

function SoulLifeEquipPanel:onPopback()
    Scene.clearLazyFunc("soullifeequiptem")
end

function SoulLifeEquipPanel:initTitle()
    local title = self:getNode("txt_soullife_title")
    if SOULLIFE_BAG_TYPE.UPGRADE == self.bagType then
        title:setString(gGetWords("spiritWord.plist", "soullife_equip_panel_title2"))
    else
        title:setString(gGetWords("spiritWord.plist", "soullife_equip_panel_title1"))
    end
end

function SoulLifeEquipPanel:sortEquItems()
    if #self.combineSoulLifeTable == 0 then
        return
    end

    local targetPos = SpiritInfo.getCurEquSpiritPos()
    table.sort(self.combineSoulLifeTable, function (lSpirit, rSpirit)
            local canBeEquedL = SpiritInfo.spiritCanBeEqued(lSpirit, targetPos)
            local canBeEquedR = SpiritInfo.spiritCanBeEqued(rSpirit, targetPos)
            if canBeEquedL ~= canBeEquedR then
                return canBeEquedL
            elseif lSpirit.iType ~= rSpirit.iType then
                return lSpirit.iType > rSpirit.iType
            else
                if lSpirit.iLV ~= rSpirit.iLV then
                    return lSpirit.iLV > rSpirit.iLV
                else
                    return lSpirit.iAttr > rSpirit.iAttr
                end
            end
    end)
end

function SoulLifeEquipPanel:sortUpgradeItems()
    if #self.combineSoulLifeTable == 0 then
        return
    end

    table.sort(self.combineSoulLifeTable, function (lSpirit, rSpirit)
        if lSpirit.iType ~= rSpirit.iType then
            return lSpirit.iType > rSpirit.iType
        else
            if lSpirit.iLV ~= rSpirit.iLV then
                return lSpirit.iLV > rSpirit.iLV
            else
                return lSpirit.iAttr > rSpirit.iAttr
            end
        end
    end)
end

function SoulLifeEquipPanel:chooseHideEquiped(hide)
    if self.hideEquiped == hide then
        return
    end
    self.hideEquiped = hide
    SpiritInfo.setHideEquiped(self.hideEquiped)
    self:getNode("icon_choose"):setVisible(self.hideEquiped)
    self:processHideEquiped(hide)
end

function SoulLifeEquipPanel:processHideEquiped(hide)
    Scene.clearLazyFunc("soullifeequiptem")
    self.combineSoulLifeTable = {}
    self.scrollLayer:clear()
    local drawNum = 6
    table.add(self.combineSoulLifeTable, SpiritInfo.vBagSpiritList)

    if not hide then
        if nil ~= self.exchangeSoulLife then
            local equipedSoulLife = nil
            for i = 1, #SpiritInfo.vSpiritList do
                equipedSoulLife = SpiritInfo.vSpiritList[i]
                if nil ~= equipedSoulLife and equipedSoulLife.iID ~= self.exchangeSoulLife.iID then
                    table.insert(self.combineSoulLifeTable, equipedSoulLife)
                end
            end
        else
            table.add(self.combineSoulLifeTable, SpiritInfo.vSpiritList)
        end
    end

    self:sortEquItems()

    for i = 1, #self.combineSoulLifeTable do
        local spirit = self.combineSoulLifeTable[i]
        if nil ~= spirit then
            local equipItem = SoulLifeEquipItem.new(spirit, self.bagType)
            if nil ~= equipItem then
                if drawNum > 0 then
                    equipItem:setItem()
                    drawNum = drawNum - 1
                else
                    equipItem:setLazyFunc()
                end
                self.scrollLayer:addItem(equipItem)
            end
        end
    end
    self.scrollLayer:layout()
end

return SoulLifeEquipPanel