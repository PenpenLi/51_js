local TipTouchSoullifeAttrPanel=class("TipTouchSoullifeAttrPanel",UILayer)
local TIP_TOUCH_ATTR_SOULLIFE = 1
local TIP_TOUCH_ATTR_CIRCLE = 2

function TipTouchSoullifeAttrPanel:ctor(chooseIdx,attrInfo)
    self:init("ui/tip_touch_soullife_attr.map")

    if attrInfo == nil then
        self.panelType = TIP_TOUCH_ATTR_SOULLIFE
        self:showSoullifeAttr(chooseIdx)
    elseif type(attrInfo) == "table" then
        if attrInfo.type == TIP_TOUCH_ATTR_CIRCLE then
            self.panelType = TIP_TOUCH_ATTR_CIRCLE
            self:showCircleAttr(attrInfo.attr)
        end
    end
end

function TipTouchSoullifeAttrPanel:showSoullifeAttr(chooseIdx)
    local zhenName = gGetWords("spiritWord.plist", "spirit_pos_name" ..chooseIdx)
    local txtIntroTitle = gGetWords("spiritWord.plist", "attr_zhen_add", zhenName)
    self:getNode("txt_soullife_intro_title"):setString(txtIntroTitle)

    local idx = 1
    local maxAttrShow = 12
    local soulLifesNum   = #DB.getSpiritStartLev()
    -- print("TipTouchSoullifeAttrPanel soulLifesNum is:",soulLifesNum)
    for i = 1, soulLifesNum do
        local spiritPos = chooseIdx * 10 + i
        local spirit    = SpiritInfo.getSpiritWithPos(spiritPos)
        if nil ~= spirit and idx <= maxAttrShow then
            local txtTitle  = self:getNode("attr_title"..idx)
            local txtValue  = self:getNode("attr_value"..idx)
            local addLv = DB.getSpiritAddLevByPos(i)
            local spiritAttr  = DB.getSpiritAttr(spirit.iType, spirit.iLV + addLv, spirit.iAttr)
            local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)
            txtTitle:setString(attrName)
            txtValue:setString(attrValue)
            self:getNode("layout_attr"..idx):layout()
            self:getNode("layout_attr"..idx):setVisible(true)
            -- print("TipTouchSoullifeAttrPanel idx is:",idx)
            idx = idx + 1
            if spiritAttr.attr2 ~= 0 then
                attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr2, spiritAttr.value2)
                txtTitle  = self:getNode("attr_title"..idx)
                txtValue  = self:getNode("attr_value"..idx)
                txtTitle:setString(attrName)
                txtValue:setString(attrValue)
                self:getNode("layout_attr"..idx):layout()
                self:getNode("layout_attr"..idx):setVisible(true)
                -- print("TipTouchSoullifeAttrPanel idx is:",idx)
                idx = idx + 1
            end
        end
    end

    for j = idx, maxAttrShow do
        self:getNode("layout_attr"..j):setVisible(false)
    end

    if idx - 1 <= 8 then
        local contentSize = self:getNode("layout_attr"..(idx - 1)):getContentSize()
        local postX, posY = self:getNode("layout_attr"..(idx - 1)):getPosition()
        contentSize.width=self:getNode("tip_bg"):getContentSize().width
        contentSize.height = math.abs(posY - contentSize.height / 2 - 32)
        self:getNode("tip_bg"):setContentSize(contentSize)
        self:setContentSize(contentSize);
    end
end

function TipTouchSoullifeAttrPanel:showCircleAttr(attrMap)
    local title =   gGetMapWords("ui_constellation_main.plist", "4")
    self:setLabelString("txt_soullife_intro_title", title)

    local idx = 1
    local maxAttrShow = 12
    local attrCount   = table.count(attr)

    for attr, value in pairs(attrMap) do
        local txtTitle  = self:getNode("attr_title"..idx)
        local txtValue  = self:getNode("attr_value"..idx)

        local attrTitle = gGetWords("cardAttrWords.plist", "attr" .. attr)
        local formatValue = ""
        if CardPro.isFloatAttr(attr) then
            formatValue = string.format("+%0.1f%%", value)
        else
            formatValue = string.format("+%d", value)
        end
        txtTitle:setString(attrTitle)
        txtValue:setString(formatValue)
        self:getNode("layout_attr"..idx):layout()
        self:getNode("layout_attr"..idx):setVisible(true)
        idx = idx + 1
    end

    for j = idx, maxAttrShow do
        self:getNode("layout_attr"..j):setVisible(false)
    end

    if idx - 1 <= 8 then
        local contentSize = self:getNode("layout_attr"..(idx - 1)):getContentSize()
        local postX, posY = self:getNode("layout_attr"..(idx - 1)):getPosition()
        contentSize.width=self:getNode("tip_bg"):getContentSize().width
        contentSize.height = math.abs(posY - contentSize.height / 2 - 32)
        self:getNode("tip_bg"):setContentSize(contentSize)
        self:setContentSize(contentSize);
    end
end

return TipTouchSoullifeAttrPanel