local MineBlackMarketPanel=class("MineBlackMarketPanel",UILayer)
local minBuyTimes = 0

function MineBlackMarketPanel:ctor(_x,_y)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_mine_black_market.map")
    self.chooseMinesPrice = 0
    self.hasReachTotalValue = false
    self.totoalValue = 0
    self.supplementDia = 0
    self.chooseAllFlags = {false, false, false}
    self.clickSupplement = false
    self:initMyResource()
    self:initTradeScroll()
    self:initSchedule()
    self.onAppearedCallback = function()
        gDispatchEvt(EVENT_ID_MINING_REFRESH_EXPLODER, {x = _x,y = _y})
    end
end

function MineBlackMarketPanel:initTradeScroll()
    self:getNode("scroll_trade"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:getNode("scroll_trade").itemScale = 0.7
    --写死
    for i = 1,13 do
        local item = DropItem.new()
        -- item:setScale(0.7)
        item.idx = i - 1
        if i == 1 then
            item:setData(ITEM_STATUE)
        else
            item:setData(ITEM_DIAMOND + i - 2)
        end
        self:refreshExchangeNum(item)
        item.selectItemCallback = function (data,idx)
            self:chooseTradeItem(idx)
        end
        self:getNode("scroll_trade"):addItem(item)
    end

    self:getNode("scroll_trade"):layout()
    if(self:getNode("scroll_trade"):getSize() ~= 0) then
        self:chooseTradeItem(0)
    else
        self:getNode("choose_icon"):setVisible(false)
    end
    self:initBuyTimes()
    self:refreshTradeInfo(self.buyTimes)
    self.supplementDia = 0
    self:refreshSupplement(self.supplementDia)
end

function MineBlackMarketPanel:chooseTradeItem(idx)
    self.curChooseTradIdx = idx
    local node = self:getNode("scroll_trade"):getItem(idx)
    if node == nil then
        return
    end
    gDigMine.setBlackTradeID(node.curData)
    local posx,posy = node:getPosition()
    posx = posx + self:getNode("scroll_trade").itemWidth / 2
    posy = posy - self:getNode("scroll_trade").itemHeight / 2
    self:getNode("choose_icon"):setVisible(true)
    self:getNode("choose_icon"):setPosition(cc.p(posx,posy))
    self:resetMineTradeItem()
    self:initBuyTimes()
    self:refreshMineItemDisplay()
    self:refreshTradeInfo(self.buyTimes)
end

function MineBlackMarketPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        gDispatchEvt(EVENT_ID_MINING_ICON_REFRESH, MINE_EVENT9)
        self:onClose()
    elseif target.touchName == "btn_sub1" then
        self:setBuyTimes(-10)
    elseif target.touchName == "btn_sub" then
        self:setBuyTimes(-1)
    elseif target.touchName == "btn_add" then
        self:setBuyTimes(1)
    elseif target.touchName == "btn_add1" then
        self:setBuyTimes(10)
    elseif target.touchName == "btn_choose_all1" then
        self:chooseAllItems(1)
    elseif target.touchName == "btn_choose_all2" then
        self:chooseAllItems(2)
    elseif target.touchName == "btn_choose_all3" then
        self:chooseAllItems(3)
    elseif target.touchName == "btn_turnover" then
        self:turnOver()
    elseif target.touchName == "btn_supplement" then
        self:supplement()
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_MINE_BLACKMARKET)
    end
end

function MineBlackMarketPanel:setBuyTimes(times)
    if times < 0 then
        self:resetMineTradeItem()
    end

    if times > 0 and self:isMaxTradeTimesLimit() then
        return
    end

    if times > 0 then
        self:initChooseAllFlags()
        self:initClickSupplement()
    end
    
    local chooseItem = self:getNode("scroll_trade"):getItem(self.curChooseTradIdx)
    if nil ~= chooseItem then
        self.buyTimes = self.buyTimes + times
        local maxBuyTimes = DB.getMaxMineEventTradeNum(chooseItem.curData)
        local exchangeTimes = gDigMine.getEvent9ExchangeItemNum(chooseItem.curData)
        if (self.buyTimes + exchangeTimes) > maxBuyTimes then
            self.buyTimes = maxBuyTimes - exchangeTimes
        elseif exchangeTimes < maxBuyTimes and self.buyTimes == 0 then
            self.buyTimes = 1
        elseif self.buyTimes < minBuyTimes then
            self.buyTimes = minBuyTimes
        end
        self:refreshTradeInfo(self.buyTimes)
    end
end

-- function MineBlackMarketPanel:setLabelInfo()
--     self:setLabelString("txt_total_value", "0/0")
--     self:setLabelString("txt_supplement", string.format("%d/%d",0,Data.getCurDia()))
-- end

function MineBlackMarketPanel:chooseAllItems(idx)
    if self:isMaxTradeTimesLimit() then
        return
    end

    if self:isTradeItemEmpty() then
        return
    end

    if not self.chooseAllFlags[idx] and self:isReachTotoalValue() then
        gShowNotice(gGetWords("labelWords.plist","lab_mine_max_trade_value"))
        return
    end

    self.chooseAllFlags[idx] = not self.chooseAllFlags[idx]
    if self.chooseAllFlags[idx] then
        self:changeTexture("btn_choose_all"..idx, "images/ui_public1/n-di-gou2.png")
    else
        self:changeTexture("btn_choose_all"..idx, "images/ui_public1/n-di-gou1.png")
    end

    if not self.chooseAllFlags[idx] then
        self:unchooseAllItems(idx)
        return
    end

    local hasReachTotalValue = false
    local iconName = "icon_pri"
    if idx == 2 then
        iconName = "icon_mid"
    elseif idx == 3 then
        iconName = "icon_hig"
    end
    for i = 1, 6 do
        if hasReachTotalValue then
            break
        end

        local item = self:getNode(iconName..i):getChildByTag(1)
        if nil ~= item then
            local sprice = DB.getMineBlackSPrice(item.curData.itemid)
            local curSelectNum = item.curSelectNum
            if item.curSelectNum < item.curData.num then
                if self.chooseMinesPrice + (item.curData.num - curSelectNum) * sprice <= self.totoalValue then
                    item:changeSelectNum(item.curData.num - curSelectNum)
                    item:refreshSelect()
                else
                    local num = math.ceil((self.totoalValue - self.chooseMinesPrice) / sprice)
                    item:changeSelectNum(num)
                    item:refreshSelect()
                    hasReachTotalValue = true
                end
            end
        end
    end

    self:refreshTradeInfo(self.buyTimes)
end

function MineBlackMarketPanel:initMyResource()
    --TODO
    for i = 1, 6 do
        local item1 = nil
        if i ~= 6 then
            self:createTradeItem(ITEM_COPPER + i - 1, self:getNode("icon_pri"..i))
        else
            self:createTradeItem(ITEM_STATUE, self:getNode("icon_pri"..i)) --雕像id最大
        end
        self:createTradeItem(ITEM_DIAMOND + i - 1, self:getNode("icon_mid"..i))
        self:createTradeItem(ITEM_RED_CRYSTAL + i - 1, self:getNode("icon_hig"..i)) 
    end
    self:getNode("layout_pri"):layout()
    self:getNode("layout_mid"):layout()
    self:getNode("layout_hig"):layout()
end

function MineBlackMarketPanel:createTradeItem(itemid,node)
    local item = MineTradeItem.new()
    local var = {itemid=itemid,num=Data.getItemNum(itemid)}
    item:setScale(0.7)
    item:setData(var)
    item:setTag(1)
    item.selectItemCallback=function ()
        if self:isMaxTradeTimesLimit() then
            return
        end

        if self:isTradeItemEmpty() then
            return
        end

        local sprice = DB.getMineBlackSPrice(item.curData.itemid)
        self.chooseMinesPrice = self.chooseMinesPrice + sprice * item.deltaNum
        self:refreshTradeInfo(self.buyTimes)
    end
    item:setAnchorPoint(cc.p(0,-0.88))
    node:addChild(item)
end

function MineBlackMarketPanel:refreshTradeInfo(tradeNum)
    self:setLabelAtlas("txt_buy_times",tradeNum)
    local item = self:getNode("scroll_trade"):getItem(self.curChooseTradIdx)
    if nil ~= item then
        local cprice = DB.getMineBlackCPrice(item.curData)
        if cprice ~= -1 then
            self.totoalValue = tradeNum * cprice
            self:setLabelString("txt_total_value", string.format("%d/%d", self.chooseMinesPrice, self.totoalValue))
            self:refreshReachTotalValue(self.totoalValue)
        end
    end
end

function MineBlackMarketPanel:refreshMineItemDisplay()
    if gDigMine.getBlackTradeID() == ITEM_STATUE then
        for i = 1, 6 do
            self:setTouchEnableGray("icon_mid"..i, false)
            self:setTouchEnableGray("icon_hig"..i, false)
        end
        self:setTouchEnableGray("btn_choose_all2", false)
        self:setTouchEnableGray("btn_choose_all3", false)
        return
    end

    for i = 1, 6 do
        self:setTouchEnableGray("icon_mid"..i, true)
    end
    self:setTouchEnableGray("btn_choose_all2", true)

    if gDigMine.getBlackTradeID() >= ITEM_DIAMOND and gDigMine.getBlackTradeID() <= ITEM_YELLOW_GEM then
        for i = 1, 6 do
            self:setTouchEnableGray("icon_hig"..i, false)
        end
        self:setTouchEnableGray("btn_choose_all3", false)
        return
    end

    for i = 1, 6 do
        self:setTouchEnableGray("icon_hig"..i, true)
    end
    self:setTouchEnableGray("btn_choose_all3", true)
end

function MineBlackMarketPanel:resetMineTradeItem()
    for i = 1, 6 do
        local tradeItem1 = self:getNode("icon_pri"..i):getChildByTag(1)
        if nil ~= tradeItem1 then 
            tradeItem1:resetDataNum(Data.getItemNum(tradeItem1.curData.itemid))
            tradeItem1:setUnSelect()
        end
        local tradeItem2 = self:getNode("icon_mid"..i):getChildByTag(1)
        if nil ~= tradeItem2 then
            tradeItem2:resetDataNum(Data.getItemNum(tradeItem2.curData.itemid))
            tradeItem2:setUnSelect()
        end
        local tradeItem3 = self:getNode("icon_hig"..i):getChildByTag(1)
        if nil ~= tradeItem3 then
            tradeItem3:resetDataNum(Data.getItemNum(tradeItem3.curData.itemid))
            tradeItem3:setUnSelect()
        end
    end
    self.chooseMinesPrice = 0
    self.hasReachTotalValue = false
    self.supplementDia = 0
    self:initChooseAllFlags()
    self:initClickSupplement()
    self:refreshSupplement(self.supplementDia)
end

function MineBlackMarketPanel:getTotoalValue()
    local cprice = DB.getMineBlackCPrice(gDigMine.getBlackTradeID())
    if cprice ~= -1 then
        return self.buyTimes * cprice
    else
        return 0
    end 
end

function MineBlackMarketPanel:getTotoalTradeValue()
    return self.chooseMinesPrice
end

function MineBlackMarketPanel:isReachTotoalValue()
    return self.hasReachTotalValue
end

function MineBlackMarketPanel:refreshReachTotalValue(totalValue)
    if self.chooseMinesPrice >= totalValue then
        self.hasReachTotalValue = true
    else
        self.hasReachTotalValue = false
    end
end

function MineBlackMarketPanel:supplement()
    if self:isMaxTradeTimesLimit() then
        return
    end

    if self:isTradeItemEmpty() then
        return
    end

    local needDia = self.totoalValue  - self.chooseMinesPrice

    if not self.clickSupplement and needDia <= 0 then
        gShowNotice(gGetWords("labelWords.plist","lab_mine_max_trade_value"))
        return
    end

    self.clickSupplement = not self.clickSupplement
    if self.clickSupplement then
        self:setLabelString("txt_btn_supplement", gGetWords("btnWords.plist","btn_cancel"))
        if needDia > 0 then
            if Data.getCurDia() > needDia then
                self.chooseMinesPrice = self.chooseMinesPrice + needDia
                self.supplementDia = self.supplementDia + needDia
            else
                local costDia = Data.getCurDia() - self.supplementDia
                self.chooseMinesPrice = self.chooseMinesPrice + costDia
                self.supplementDia = self.supplementDia + costDia
            end
            self:refreshSupplement(self.supplementDia)
            self:setLabelString("txt_total_value", string.format("%d/%d", self.chooseMinesPrice, self.totoalValue))
            self:refreshReachTotalValue(self.totoalValue)        
        end
    else
        self:setLabelString("txt_btn_supplement", gGetWords("btnWords.plist","btn_supplement"))
        self.chooseMinesPrice = self.chooseMinesPrice - self.supplementDia
        self.supplementDia = 0
        self:refreshSupplement(self.supplementDia)
        self:setLabelString("txt_total_value", string.format("%d/%d", self.chooseMinesPrice, self.totoalValue))
        self:refreshReachTotalValue(self.totoalValue) 
    end 
end

function MineBlackMarketPanel:refreshSupplement(costDia)
    self:setLabelString("txt_supplement", string.format("%d / %d",costDia, Data.getCurDia()))
    self:getNode("layout_supplement"):layout()
end

function MineBlackMarketPanel:events()
    return { EVENT_ID_MINING_BLACK_MARKET }
end

function MineBlackMarketPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_BLACK_MARKET then
        self:resetMineTradeItem()
        self:initBuyTimes()
        self:refreshTradeInfo(self.buyTimes)
        self:refreshTradeItem()
    end
end

function MineBlackMarketPanel:turnOver()
    if not self:checkCondition() then
        return
    end
    local dstIds  = {}
    local dstNums = {}
    local oriIds  = {}
    local oriNums  = {}

    local node = self:getNode("scroll_trade"):getItem(self.curChooseTradIdx)
    table.insert(dstIds, node.curData)
    table.insert(dstNums, self.buyTimes)

    for i = 1, 6 do
        local tradeItem1 = self:getNode("icon_pri"..i):getChildByTag(1)
        if tradeItem1.curSelectNum ~= 0 then
            table.insert(oriIds, tradeItem1.curData.itemid)
            table.insert(oriNums, tradeItem1.curSelectNum)
        end
    end

    for i = 1, 6 do
        local tradeItem2 = self:getNode("icon_mid"..i):getChildByTag(1)
        if tradeItem2.curSelectNum ~= 0 then
            table.insert(oriIds, tradeItem2.curData.itemid)
            table.insert(oriNums, tradeItem2.curSelectNum)
        end
    end

    for i = 1, 6 do
        local tradeItem3 = self:getNode("icon_hig"..i):getChildByTag(1)
        if tradeItem3.curSelectNum ~= 0 then
            table.insert(oriIds, tradeItem3.curData.itemid)
            table.insert(oriNums, tradeItem3.curSelectNum)
        end
    end

    Net.sendMiningEvent9Deal(dstIds, dstNums, oriIds,oriNums)
end

function MineBlackMarketPanel:checkCondition()
    if self:isMaxTradeTimesLimit() then
        return false
    end

    if self.chooseMinesPrice < self.totoalValue then
        gShowNotice(gGetWords("labelWords.plist","lab_mine_value_no_enough"))
        return false
    end

    if gDigMine.getBlackMarketLeftTime() <= gGetCurServerTime() then
        gShowNotice(gGetWords("labelWords.plist","lab_blackmarket_buy_timeout"))
        return false
    end

    return true
end

function MineBlackMarketPanel:refreshTradeItem()
    local size = self:getNode("scroll_trade"):getSize()
    for i = 1, size do
        self:refreshExchangeNum(self:getNode("scroll_trade"):getItem(i - 1))
    end
end
function MineBlackMarketPanel:refreshExchangeNum(item)
    if item == nil then
        return
    end

    local maxBuyTimes = DB.getMaxMineEventTradeNum(item.curData)
    local exchangeTimes = gDigMine.getEvent9ExchangeItemNum(item.curData)
    item:setLabelString("txt_num", string.format("%d/%d",exchangeTimes,maxBuyTimes))
end

function MineBlackMarketPanel:isTradeItemEmpty()
    if self.buyTimes == 0 then
        gShowNotice(gGetWords("labelWords.plist","lab_mine_trade_empty"))
        return true
    end
    return false
end

function MineBlackMarketPanel:isMaxTradeTimesLimit(showNotice)
    local chooseItem = self:getNode("scroll_trade"):getItem(self.curChooseTradIdx)
    if chooseItem ~= nil then
        local maxBuyTimes = DB.getMaxMineEventTradeNum(chooseItem.curData)
        local exchangeTimes = gDigMine.getEvent9ExchangeItemNum(chooseItem.curData)
        if exchangeTimes >= maxBuyTimes then
            if showNotice == nil or showNotice == true then
                gShowCmdNotice(CMD_MINING_EVENT_9_DEAL,14)
            end
            return true
        end
    end
    return false
end

function MineBlackMarketPanel:initBuyTimes()
    if self.curChooseTradIdx == nil then
        self.buyTimes = 0
        return
    end

    local node = self:getNode("scroll_trade"):getItem(self.curChooseTradIdx)
    if node == nil then
        self.buyTimes = 0
        return 
    end

    local maxBuyTimes = DB.getMaxMineEventTradeNum(node.curData)
    local exchangeTimes = gDigMine.getEvent9ExchangeItemNum(node.curData)
    if exchangeTimes >= maxBuyTimes then
        self.buyTimes = 0
    else
        self.buyTimes = 1
    end
end

function MineBlackMarketPanel:unchooseAllItems(idx)

    local iconName = "icon_pri"
    if idx == 2 then
        iconName = "icon_mid"
    elseif idx == 3 then
        iconName = "icon_hig"
    end
    for i = 1, 6 do
        local tradeItem = self:getNode(iconName..i):getChildByTag(1)
        if nil ~= tradeItem then
            tradeItem:setUnSelect()
            if(tradeItem.selectItemCallback)then
                tradeItem.selectItemCallback()
            end
            -- tradeItem:resetDataNum(Data.getItemNum(tradeItem.curData.itemid))
        end
    end
    self:refreshTradeInfo(self.buyTimes)
end

function MineBlackMarketPanel:initChooseAllFlags()
    self.chooseAllFlags = {false, false, false}
    for i = 1, 3 do
        self:changeTexture("btn_choose_all"..i, "images/ui_public1/n-di-gou1.png")
    end
end

function MineBlackMarketPanel:initClickSupplement()
    self.clickSupplement = false
    self:setLabelString("txt_btn_supplement", gGetWords("btnWords.plist","btn_supplement"))
end

function MineBlackMarketPanel:initSchedule()
    if gDigMine.getBlackMarketLeftTime() > 0 then
        local function update()
            if gDigMine.getBlackMarketLeftTime() > gGetCurServerTime() then
                local minTime = gParserMinTimeEx(gDigMine.getBlackMarketLeftTime() - gGetCurServerTime())
                self:setLabelString("txt_lefttime_value", minTime)
                self:getNode("layout_lefttime"):layout()
            else
                gDigMine.setBlackMarketLeftTime(0)
                self:setLabelString("txt_lefttime_value", "00:00")
                self:getNode("layout_lefttime"):layout()
                self:unscheduleUpdateEx()
            end
        end
        self:scheduleUpdate(update, 1)
    else
        self:setLabelString("txt_lefttime_value", "00:00")
        self:getNode("layout_lefttime"):layout()
    end
end

function MineBlackMarketPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

return MineBlackMarketPanel