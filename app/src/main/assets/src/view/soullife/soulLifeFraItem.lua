local SoulLifeFraItem=class("SoulLifeFraItem",UILayer)

function SoulLifeFraItem:ctor(type, attr)
    self.attr = attr
    self.type = type
end

function SoulLifeFraItem:initPanel(type, attr)
    --设置Icon
    if type == SPIRIT_TYPE.EXP then
        --动画
        Icon.setSpiritExpIcon(self:getNode("icon_bg"),0.6)
        --名字
        self:setLabelString("txt_name", gGetWords("spiritWord.plist","spirit_exp"))
        self:getNode("txt_lv"):setVisible(false)
        self:getNode("panel_exp"):setVisible(true)
        self:getNode("layout_attr"):setVisible(false)
        self:getNode("panel_item_spirit_buy"):setVisible(false)
        self:getNode("layout_fra"):setVisible(true)
        self:getNode("layout_dia"):setVisible(false)
        self:getNode("layout_spirit_buy"):setVisible(false)
        local num,addExp = DB.getSoulLifeFraToExpParam()
        self:setLabelString("txt_exp_value", string.format("+%d", addExp))
        self:refreshNum()
    elseif type == SPIRIT_TYPE.DOUBLE_ATTR then
        self:getNode("panel_exp"):setVisible(false)
        self:initAttrLayoutByDoubleOrNot(true)
        self:getNode("panel_item_spirit_buy"):setVisible(false)
        self:getNode("layout_fra"):setVisible(true)
        self:getNode("layout_dia"):setVisible(false)
        self:refreshSpiritBuyItemNum()
        self:getNode("layout_spirit_buy"):setVisible(true)
        self:initSpiritAttrShow(type,attr)
        Icon.setSpiritIcon(type, self:getNode("icon_bg"))
        self:getNode("txt_lv"):setString("1")
        self:refreshNum()
    elseif type == ITEM_SPIRIT_BUY then
        local ret=cc.Sprite:create("images/icon/item/130.png")
        ret:setScale(0.7)
        gAddCenter(ret, self:getNode("icon_bg"))
        local itemDB = DB.getItemData(ITEM_SPIRIT_BUY)
        self:setLabelString("txt_name", itemDB.name)
        self:getNode("panel_exp"):setVisible(false)
        self:getNode("layout_attr"):setVisible(false)
        self:refreshSpiritBuyNum()
        self:getNode("panel_item_spirit_buy"):setVisible(true)
        self:getNode("layout_fra"):setVisible(false)
        self:refreshBuyItemPrice()
        self:getNode("layout_dia"):setVisible(true)
        self:getNode("layout_spirit_buy"):setVisible(false)
        self:getNode("txt_lv"):setString("1")
        self:setLabelString("txt_exchange", gGetWords("btnWords.plist","btn_buy"))
    else
        self:getNode("panel_exp"):setVisible(false)
        self:getNode("panel_item_spirit_buy"):setVisible(false)
        self:initAttrLayoutByDoubleOrNot(false)
        self:getNode("layout_spirit_buy"):setVisible(false)
        self:getNode("layout_dia"):setVisible(false)
        Icon.setSpiritIcon(type, self:getNode("icon_bg"))
        self:getNode("txt_lv"):setString("1")
        self:initSpiritAttrShow(type, attr)
        self:refreshNum()
    end
end

function SoulLifeFraItem:onTouchEnded(target,touch, event)
    if target.touchName=="btn_exchange" then
        if self.type == SPIRIT_TYPE.EXP then
            if self:fraIsEnough() then
                Net.sendSpiritExchangeExp()
            end
        elseif self.type == ITEM_SPIRIT_BUY then
            if SpiritInfo.getSpiritItemBuyNumsOfDay() >= DB.getSpiritDayBuyNum() then
                gShowNotice(gGetWords("spiritWord.plist", "spirit_buy_item_exhausted"))
            elseif Data.getCurDia() < DB.getSpiritBuyItemPrice() then
                NetErr.noEnoughDia()
            else
                Net.sendSpiritBuyItem()
                gLogPurchase("spirit_buy_token", 1, DB.getSpiritBuyItemPrice())
            end
        else
            if self:fraIsEnough() then
                Net.sendSpiritExchange(self.attr,self.attr2)
            end
        end
    end
end

function SoulLifeFraItem:refreshNum()
    local numInfo = ""
    local fraEnough = false
    if self.type == SPIRIT_TYPE.EXP then
        local num,addExp = DB.getSoulLifeFraToExpParam()
        numInfo =  string.format("%d/%d", SpiritInfo.getFraCount(),num)
        fraEnough = SpiritInfo.getFraCount() >= num
    else 
        numInfo =  string.format("%d/%d", SpiritInfo.getFraCount(), DB.getSpiritExchangeCount())
        fraEnough = SpiritInfo.getFraCount() >= DB.getSpiritExchangeCount()
    end

    self:getNode("txt_fra_num"):setString(numInfo)
    if fraEnough then
        self:getNode("txt_fra_num"):setColor(cc.c3b(0,255,0))
    else
        self:getNode("txt_fra_num"):setColor(cc.c3b(255,0,0))
    end
end

function SoulLifeFraItem:fraIsEnough()
    local fraEnough = false
    local spiritBuyItemEnough = true
    if self.type == SPIRIT_TYPE.EXP then
        local num,addExp = DB.getSoulLifeFraToExpParam()
        fraEnough = SpiritInfo.getFraCount() >= num
    elseif self.type == SPIRIT_TYPE.DOUBLE_ATTR then
        fraEnough = SpiritInfo.getFraCount() >= DB.getSpiritExchangeCount()
        spiritBuyItemEnough = Data.getItemNum(ITEM_SPIRIT_BUY) >= DB.getSpiritExchangeItemCount()
    else
        fraEnough = SpiritInfo.getFraCount() >= DB.getSpiritExchangeCount()
    end

    if not fraEnough then
        gShowNotice(gGetWords("spiritWord.plist", "soullife_fra_no_enough"))
        return false
    end

    if not spiritBuyItemEnough then
        gShowNotice(gGetWords("spiritWord.plist", "spirit_buy_item_enough"))
        return false
    end

    return true
end

function SoulLifeFraItem:setItem()
    self:init("ui/ui_soullife_fra_item.map")
    self:initPanel(self.type, self.attr)
end

function SoulLifeFraItem:setLazyFunc()
    Scene.addLazyFunc(self,self.setItem, "soullifefratem")
end

function SoulLifeFraItem:initAttrLayoutByDoubleOrNot(isDoubleSpirit)
    self:getNode("panel_attr2"):setVisible(isDoubleSpirit)
    self:getNode("layout_attr"):layout()
    self:getNode("layout_attr"):setVisible(true)
    self:getNode("layout_fra"):setVisible(true)
    self:getNode("layout_dia"):setVisible(false)
end

function SoulLifeFraItem:initSpiritAttrShow(spiritType, attrType)
    local name = gGetSpiritAttrNameByType(spiritType, attrType)
    self:getNode("txt_name"):setString(name)
    self:getNode("txt_lv"):setString("1")
    local spiritAttrs = DB.getSpiritAttr(spiritType, 1, attrType)
    local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttrs.attr,spiritAttrs.value)
    self:getNode("txt_attr1"):setString(attrName)
    self:getNode("txt_attr1_value"):setString(attrValue)
    self:getNode("layout_attr1"):layout()
    if spiritAttrs.attr2 ~= 0 then
        attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttrs.attr2,spiritAttrs.value2)
        self:getNode("txt_attr2"):setString(attrName)
        self:getNode("txt_attr2_value"):setString(attrValue)
        self.attr2 = spiritAttrs.attr2
        self:getNode("layout_attr2"):layout()
    end
    self:getNode("layout_attr"):layout()
    self:getNode("layout_attr"):setVisible(true)
end

function SoulLifeFraItem:refreshSpiritBuyItemNum()
    local spiritBuyItemNums = Data.getItemNum(ITEM_SPIRIT_BUY)
    local needNums = DB.getSpiritExchangeItemCount()
    self:getNode("txt_spirit_buy_num"):setString(string.format("%d/%d",spiritBuyItemNums,needNums))
    if spiritBuyItemNums < needNums then
        self:getNode("txt_spirit_buy_num"):setColor(cc.c3b(255,0,0))
    else
        self:getNode("txt_spirit_buy_num"):setColor(cc.c3b(0,255,0))
    end
    self:getNode("layout_spirit_buy"):layout()
end

function SoulLifeFraItem:refreshSpiritBuyNum()
    local dayNumsLimit = DB.getSpiritDayBuyNum()
    local alreadyBuyNums = SpiritInfo.getSpiritItemBuyNumsOfDay()
    self:setTouchEnableGray("btn_exchange", alreadyBuyNums < dayNumsLimit)
    self:setLabelString("txt_buy_item_num", string.format("%d/%d",dayNumsLimit - alreadyBuyNums,dayNumsLimit))
end

function SoulLifeFraItem:refreshBuyItemPrice()
    local spiritBuyItemPrice = DB.getSpiritBuyItemPrice()
    self:setLabelString("txt_dia_num", string.format("%d",spiritBuyItemPrice))
    self:getNode("layout_dia"):layout()
    if Data.getCurDia() >= spiritBuyItemPrice  then
        self:getNode("txt_dia_num"):setColor(cc.c3b(0,255,0))
    else
        self:getNode("txt_dia_num"):setColor(cc.c3b(255,0,0))
    end
end

return SoulLifeFraItem