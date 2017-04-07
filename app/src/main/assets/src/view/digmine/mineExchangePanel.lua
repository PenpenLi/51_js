local MineExchangePanel=class("MineExchangePanel",UILayer)

function MineExchangePanel:ctor(isOpen)
    -- self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_mine_duihuan.map")
    self.curShopType = SHOP_TYPE_MINE;
    self.scrollLayer = self:getNode("scroll")
    self.scrollLayer:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    if isOpen then
        Net.sendMiningExInfo(isOpen)
    else
        self:initExInfo()
        self:initRetimeInfo()
        self:setBoxBtn()
    end

    self:getNode("btn_pre"):setVisible(gGetUnlockShopCount() > 1);
    self:getNode("btn_next"):setVisible(gGetUnlockShopCount() > 1);
end

function MineExchangePanel:events()
    return {
            EVENT_ID_MINING_EXCHANGE,
            EVENT_ID_MINING_EX_CHANGE_ALL,
            EVENT_ID_MINING_EX_INFO
        }
end

function MineExchangePanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_EXCHANGE then
        if gDigMine.exItemIdx ~= nil then
            local sendItem = self.scrollLayer:getItem(gDigMine.exItemIdx - 1)
            sendItem:addNumOne()
            local size = self.scrollLayer:getSize()
            for i = 1, size do
                local item = self.scrollLayer:getItem(i - 1)
                if nil ~= item then
                    item:refreshData()
                end
            end

            self:setBoxBtn()
        end
    elseif event == EVENT_ID_MINING_EX_CHANGE_ALL then
        self:setBoxBtn()
    elseif event == EVENT_ID_MINING_EX_INFO then
        self:initExInfo()
        self:initRetimeInfo()
        self:setBoxBtn()
    end
end

function MineExchangePanel:initExInfo()
    self.scrollLayer:clear()
    for key, value in pairs(gDigMine.exInfoList) do
        local item = MineExchangeItem.new()
        item:setData(key,value)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
end

function MineExchangePanel:initRetimeInfo()
    self:unscheduleUpdateEx()
    self:getNode("txt_refresh_time"):setVisible(true)
    self:scheduleUpdate(function ()
        if 0 == gDigMine.exRetime then
            self:unscheduleUpdateEx()
            return
        end

        if gDigMine.exRetime - gGetCurServerTime() > 0 then
            self:setLabelString("txt_refresh_time", gParserHourTime(gDigMine.exRetime - gGetCurServerTime()))
        else
            if gDigMine.exRetime ~= 0 then
                self:getNode("txt_refresh_time"):setVisible(false)
                gDigMine.exRetime = 0
                self:unscheduleUpdateEx()
                Net.sendMiningExInfo(true)
            end
        end
    end, 1)
end

function MineExchangePanel:onUILayerExit()
    if nil ~= self.super then
        self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

function MineExchangePanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_box" then
        Panel.popUpVisible(PANLE_MINE_EXCHANGE_BOX,nil,nil,true)
    elseif target.touchName == "btn_pre" then
        gPreShop(self.curShopType,self:getTag());
    elseif target.touchName == "btn_next" then
        gNextShop(self.curShopType,self:getTag());
    end
end

function MineExchangePanel:setBoxBtn()
    local status = gDigMine.getExchangeBoxStatus()
    if status == MINE_EX_BOX_STATUS1 then
        self:getNode("btn_box"):playAction("ui_atlas_box_1")
    elseif status == MINE_EX_BOX_STATUS2 then
        self:getNode("btn_box"):playAction("ui_atlas_box_2")
    elseif status == MINE_EX_BOX_STATUS3 then
        self:getNode("btn_box"):playAction("ui_atlas_box_3")
    end
end

return MineExchangePanel