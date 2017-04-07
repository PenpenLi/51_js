local SoulLifeFraExchangePanel=class("SoulLifeFraExchangePanel",UILayer)
local tianAttrTable = DB.getSpiritAttrTable(SPIRIT_TYPE.TIAN, 1)
local doubleAttrTable = DB.getSpiritAttrTable(SPIRIT_TYPE.DOUBLE_ATTR, 1)

function SoulLifeFraExchangePanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_soullife_fra_exchange.map")
    self:initPanel()
end

function SoulLifeFraExchangePanel:initPanel()
    --设置滚动层
    self.scrollLayer = self:getNode("scroll_items")
    Scene.clearLazyFunc("soullifefratem")
    --第一项默认为命魂经验池
    if not Module.isClose(SWITCH_DOUBLE_ATTR_SPIRIT) then
        local expPoolItem = SoulLifeFraItem.new(ITEM_SPIRIT_BUY,0)
        expPoolItem:setItem()
        self.scrollLayer:addItem(expPoolItem)
    end

    --第二项默认为命魂经验池
    local expPoolItem = SoulLifeFraItem.new(SPIRIT_TYPE.EXP,0)
    expPoolItem:setItem()
    self.scrollLayer:addItem(expPoolItem)
    --设置Item
    local drawNum = 3
    --双属性命魂
    if not Module.isClose(SWITCH_DOUBLE_ATTR_SPIRIT) then
        for i = 1, #doubleAttrTable do
            local spiritAttr = doubleAttrTable[i]
            local exchangeItem = SoulLifeFraItem.new(toint(spiritAttr.type), toint(spiritAttr.attr))
            if drawNum > 0 then
                exchangeItem:setItem()
                drawNum = drawNum - 1
            else
                exchangeItem:setLazyFunc()
            end
            self.scrollLayer:addItem(exchangeItem)
        end
    end
    --橙色命魂
    for i = 1, #tianAttrTable do
        local spiritAttr = tianAttrTable[i]
        local exchangeItem = SoulLifeFraItem.new(toint(spiritAttr.type), toint(spiritAttr.attr))
        if drawNum > 0 then
            exchangeItem:setItem()
            drawNum = drawNum - 1
        else
            exchangeItem:setLazyFunc()
        end
        self.scrollLayer:addItem(exchangeItem)
    end
    self.scrollLayer:layout()
end

function SoulLifeFraExchangePanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    end
end

function SoulLifeFraExchangePanel:events()
    return { EVENT_ID_SPIRIT_CHIP_REFRESH,EVENT_ID_SPIRIT_BUY_ITEM_REFRESH}
end

function SoulLifeFraExchangePanel:dealEvent(event, param)
    if event == EVENT_ID_SPIRIT_CHIP_REFRESH then
        local beginIdx = 2
        if Module.isClose(SWITCH_DOUBLE_ATTR_SPIRIT) then
            beginIdx = 1
        end
        for i = beginIdx, self.scrollLayer:getSize() do
            local item = self.scrollLayer:getItem(i - 1)
            if nil ~= item then
                item:refreshNum()
                if item:getNode("layout_spirit_buy"):isVisible() then
                    item:refreshSpiritBuyItemNum()
                end
            end
        end
    elseif event == EVENT_ID_SPIRIT_BUY_ITEM_REFRESH then
        local spiritBuyItem = self.scrollLayer:getItem(0)
        if nil ~= spiritBuyItem then
             spiritBuyItem:refreshSpiritBuyNum()
        end

        for i=2, self.scrollLayer:getSize() do
            local item = self.scrollLayer:getItem(i - 1)
            if nil ~= item then
                if item:getNode("layout_spirit_buy"):isVisible() then
                    item:refreshSpiritBuyItemNum()
                end
            end
        end
    end
end

function SoulLifeFraExchangePanel:onPopback()
    Scene.clearLazyFunc("soullifefratem")
end

function SoulLifeFraExchangePanel:updateMainMoneyInfo()
    if nil ~= gMainMoneyLayer then
        gMainMoneyLayer:refreshBtnEnergy()
    end
end

return SoulLifeFraExchangePanel