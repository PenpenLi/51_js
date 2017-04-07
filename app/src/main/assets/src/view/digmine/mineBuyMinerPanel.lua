local MineBuyMinerPanel=class("MineBuyMinerPanel",UILayer)

function MineBuyMinerPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_mine_buy_miner.map")
    self:initPanel()
end

function MineBuyMinerPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_buy" then
        Net.sendMiningBuyMiner()
    end
end

function MineBuyMinerPanel:initPanel()
    self:setLabelString("txt_mastery", gDigMine.mastery)
    self:getNode("layout_mastery"):layout()

    self:setLabelString("txt_miner_num", gDigMine.miner)
    self:getNode("layout_miner_num"):layout()

    if gDigMine.miner >= DB.getMaxMiners() then
        self:getNode("layout_need_mastery"):setVisible(false)
        self:getNode("layout_gold"):setVisible(false)
        self:getNode("txt_miner_reach_max"):setVisible(true)
        self:setTouchEnable("btn_buy", false, true)
    else
        self:getNode("layout_need_mastery"):setVisible(true)
        self:getNode("layout_gold"):setVisible(true)
        self:getNode("txt_miner_reach_max"):setVisible(false)
        local needMastery = DB.getMasteryLimToBuyMiner(gDigMine.miner)
        self:setLabelString("txt_need_mastery", needMastery)
        self:getNode("layout_need_mastery"):layout()
        if needMastery > gDigMine.mastery then
            self:setTouchEnable("btn_buy", false, true)
        else
            self:setTouchEnable("btn_buy", true, false)
        end
        local needDia = DB.getPriceToBuyMiner(gDigMine.miner)
        self:setLabelString("txt_gold", needDia)
        self:getNode("layout_gold"):layout()
    end
end

function MineBuyMinerPanel:events()
    return { EVENT_ID_MINING_BUY_MINERS }
end

function MineBuyMinerPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_BUY_MINERS then
        self:initPanel()
    end
end

return MineBuyMinerPanel