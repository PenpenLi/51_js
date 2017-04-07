local MineLuckyWheelPanel=class("MineLuckyWheelPanel",UILayer)

local luckyWheelCount = 8
-- local itemArray = {{id=60,num=10}, {id=61,num=5}, {id=62,num=8},{id=63,num=10},
--                    {id=64,num=10}, {id=65,num=5}, {id=66,num=8},{id=67,num=10}}
function MineLuckyWheelPanel:ctor()
    self.appearType = 1
    self:init("ui/ui_mine_lucky_wheel.map")
    self:getNode("panel_left_time"):setVisible(false)
    self:getNode("panel_left_count"):setVisible(false)
    self.isMainLayerMenuShow = false
    self.onAppearedCallback = function()
        self:getNode("panel_left_time"):setVisible(true)
        self:getNode("panel_left_count"):setVisible(true)
    end
    self:initPanel()
    self.isTurning = false  --是否正在大转盘
    self:initSchedule()
    self.turn_cost = 0
    self:resetLayOut();
end

function MineLuckyWheelPanel:initPanel()
    self:setLabelInfo()
    self:initWheelItems()
end

function MineLuckyWheelPanel:initSchedule()

    if gDigMine.getLuckyWheelLeftTime() > 0 then
        local function update()
            if gDigMine.getLuckyWheelLeftTime() > gGetCurServerTime() then
                local minTime = gParserMinTimeEx(gDigMine.getLuckyWheelLeftTime() - gGetCurServerTime())
                self:setLabelString("txt_left_time", minTime)
                self:getNode("layout_left_time"):layout()
            else
                gDigMine.setLuckyWheelLeftTime(0)
                self:setLabelString("txt_left_time", "00:00")
                self:getNode("layout_left_time"):layout()
                self:unscheduleUpdateEx()
            end
        end
        self:scheduleUpdate(update, 1)
    else
        self:setLabelString("txt_left_time", "00:00")
        self:getNode("layout_left_time"):layout()
    end
end

function MineLuckyWheelPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

function MineLuckyWheelPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_turn" then
        if not self.isTurning then
            if gDigMine.getLuckyWheelLeftTime() > gGetCurServerTime() then
                if not self:isTurningLimit() then
                    Net.sendMiningEvent3Turn()
                end
            else
                gShowNotice(gGetCmdCodeWord(CMD_MINING_EVENT_3_TURN ,5))
            end
        end
    elseif target.touchName == "btn_close" then
        if not self.isTurning then
            gDispatchEvt(EVENT_ID_MINING_ICON_REFRESH, MINE_EVENT3)
            self:getNode("panel_left_time"):setVisible(false)
            self:getNode("panel_left_count"):setVisible(false)
            self:onClose()
        end
    end
end

function MineLuckyWheelPanel:turnWheel()
    self.isTurning = true
    local idx = gDigMine.getLuckyWheelTurnIdx()
    if idx == 0 then
        self.isTurning = false
        return
    end
    local selectItem = nil
    local selectIdx  = -1
    for i = 1,luckyWheelCount do
        if self.luckyWheelItems[i].idx == idx then
            selectItem = self.luckyWheelItems[i]
            selectIdx = i
        end
    end

    if nil == selectItem then
        self.isTurning = false
        return
    end

    local angle = -selectItem:getRotation()
    angle = angle - math.mod(self:getNode("container"):getRotation(), 360)
    local lapCount = math.random(5,12)
    while  angle < 360 * (lapCount - 1) do
        angle = angle + 360
    end

    while angle >= 360 * lapCount do
        angle = angle - 360
    end

    local action1 = cc.RotateBy:create(angle / 500, angle)
    local action2 = cc.EaseElasticOut:create(action1, math.random(3,10))
    local callback = cc.CallFunc:create(function()
        local item = {}
        item.id = gDigMine.luckyWheelDisruptItems[selectIdx].id
        item.num = gDigMine.luckyWheelDisruptItems[selectIdx].num
        gShowItemPoolLayer:pushOneItem(item)
        loadFlaXml("ui_zhuanpan")
        local getFla = FlashAni.new()
        getFla:playAction("ui_zhuanpan_huode",function ()
            -- getFla:removeFromParent()
            if nil ~= self.luckyWheelItems[selectIdx] then
                self.luckyWheelItems[selectIdx]:removeChildByTag(99)
            end
            self.isTurning = false
        end,nil,1)
        local quality  = DB.getItemQuality(item.id)
        if quality >= 5 then
            quality = 5
        end
        local quaIcon = cc.Sprite:create("images/ui_public1/ka_d"..(quality+1)..".png")
        getFla:replaceBoneWithNode({"wupin","kuang"},quaIcon)
        local itemIcon = self:createFlaReplaceItem(item.id)
        getFla:replaceBoneWithNode({"wupin","icon"},itemIcon)
        if nil ~= self.luckyWheelItems[selectIdx] then
            self.luckyWheelItems[selectIdx]:getChildByTag(99):replaceNode("icon",getFla)
            self.luckyWheelItems[selectIdx]:getChildByTag(99):setNum(0)
        else
            self.isTurning = false
        end
        -- gDigMine.resetLuckyWheelItem(idx)
        gDigMine.resetLuckyWheelDisruptItem(selectIdx)
        self:setLabelInfo()
        if gDigMine.getLuckyWheelTurnNums() >= DB.getMaxLuckWheelNums() then
            self:setTouchEnableGray("btn_turn", false)
            gDigMine.setLuckyWheelLeftTime(0)
            self:getNode("layout_dia"):setVisible(false)
            gDispatchEvt(EVENT_ID_MINING_ICON_REFRESH, MINE_EVENT3)
        end
    end)
    self:getNode("container"):runAction(cc.Sequence:create(action2, callback))
end

function MineLuckyWheelPanel:initWheelItems()
    if #gDigMine.luckyWheelDisruptItems == 0 then
        return
    end

    self.luckyWheelItems = {}
    local radius = 180
    for i = 1, luckyWheelCount do
        local luckItem = gDigMine.luckyWheelDisruptItems[i]
        if luckItem.id == 0 then
            self.luckyWheelItems[i] = cc.Sprite:create("images/ui_digmine/luckywheel_0.png")
        else
            local quality  = DB.getItemQuality(luckItem.id)
            if quality >= 5 then
                quality = 5
            end
            self.luckyWheelItems[i] = cc.Sprite:create("images/ui_digmine/luckywheel_"..quality..".png")
        end
        self.luckyWheelItems[i].idx = gDigMine.luckyWheelDisruptItemsIdx[i]
        local angle = 360 / luckyWheelCount * (i - 1)
        self.luckyWheelItems[i]:setRotation(90 - angle)
        self.luckyWheelItems[i]:setAnchorPoint(cc.p(0.5,0.5))
        local x = math.cos(math.rad(angle)) * radius
        local y = math.sin(math.rad(angle)) * radius
        gAddChildByAnchorPos(self:getNode("container"), self.luckyWheelItems[i], cc.p(0.5, 0.5), cc.p(x,y))

        
        if gDigMine.luckyWheelDisruptItems[i].id ~= 0 then
            local node = DropItem.new()
            node:setData(gDigMine.luckyWheelDisruptItems[i].id)
            node:setNum(gDigMine.luckyWheelDisruptItems[i].num) 
            node:setScale(0.7)
            node:setAnchorPoint(cc.p(0.5,-0.5))
            node:setTag(99)
            gAddChildByAnchorPos(self.luckyWheelItems[i], node, cc.p(0.5, 0.5), cc.p(0, 0))
        end
    end
end

function MineLuckyWheelPanel:isTurningLimit()
    if gDigMine.getLuckyWheelTurnNums() >= DB.getMaxLuckWheelNums() then
        return true
    end
    -- --已抽次数已超过免费次数，检查元宝
    -- local nums = gDigMine.getLuckyWheelTurnNums()
    -- if nums >= DB.getFreeLuckWheelNums() and 
    --    Data.getCurDia() < DB.getLuckWheelCost(nums + 1) then
    --    return true
    -- end

    return false
end

function MineLuckyWheelPanel:events()
    return { EVENT_ID_MINING_TURN }
end

function MineLuckyWheelPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_TURN then
        if(self.turn_cost > 0) then
            gLogPurchase("mine_wheel", 1, tostring(self.turn_cost))
        end
        self:turnWheel()
    end
end

function MineLuckyWheelPanel:setLabelInfo()
    local nums  = gDigMine.getLuckyWheelTurnNums()
    if nums >= DB.getFreeLuckWheelNums() then
        self:getNode("layout_dia"):setVisible(true)
        self:getNode("txt_free"):setVisible(false)
        self:setLabelString("txt_dia", DB.getLuckWheelCost(nums + 1))
        self.turn_cost = toint(DB.getLuckWheelCost(nums + 1))
    else
        self:getNode("layout_dia"):setVisible(false)
        self:getNode("txt_free"):setVisible(true)
    end


    self:setLabelString("txt_left_count", string.format("%d/%d",DB.getMaxLuckWheelNums() - nums,DB.getMaxLuckWheelNums()))
end

function MineLuckyWheelPanel:createFlaReplaceItem(id)
    local  ret = nil
    if id == OPEN_BOX_GOLD then
        ret = cc.Sprite:create("images/ui_public1/coin.png")
    elseif id == OPEN_BOX_PET_SOUL then
        ret = cc.Sprite:create("images/icon/sep_item/"..id..".png")
    else
        ret = cc.Sprite:create("images/icon/mine/"..id..".png")
    end

    return ret
end

return MineLuckyWheelPanel