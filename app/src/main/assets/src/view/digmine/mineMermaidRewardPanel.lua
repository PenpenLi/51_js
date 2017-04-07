local MineMermaidRewardPanel=class("MineMermaidRewardPanel",UILayer)

function MineMermaidRewardPanel:ctor(_x,_y)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_mine_mermaid_reward.map")
    -- self.__tip = true
    self:initPanel()
    self.onAppearedCallback = function()
        gDispatchEvt(EVENT_ID_MINING_REFRESH_EXPLODER, {x = _x,y = _y})
    end
end

function MineMermaidRewardPanel:onTouchEnded(target, touch, event)
    if gDigMine.eventRewards.items == nil or #gDigMine.eventRewards.items == 0 then
        return
    end

    self:getRewards()
end

function MineMermaidRewardPanel:initPanel()
    if gDigMine.eventRewards.items == nil or #gDigMine.eventRewards.items == 0 then
        self:onClose()
        return
    end

    local count = #gDigMine.eventRewards.items
    if count == 1 then
        self:getNode("icon2"):setVisible(false)
        self:getNode("icon_bg2"):setVisible(false)
    end
    self.noGetNums = 0
    for i = 1, count do
        self:showRewardItem(i)
        self.noGetNums = self.noGetNums + 1
    end

    self:initLabelInfo()
end

function MineMermaidRewardPanel:createFlaReplaceItem(id)
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

function MineMermaidRewardPanel:showRewardItem(idx)
    local item = gDigMine.eventRewards.items[idx] --{id = 60, num = 10}
    local itemName = DB.getItemName(item.id)
    local node=DropItem.new()
    node:setData(item.id) 
    node:setNum(item.num)
    node:setTag(99)
    node:setPositionY(node:getContentSize().height)
    gAddMapCenter(node, self:getNode("icon"..idx))
--    node.preSelectItemCallback = function()
--         loadFlaXml("ui_zhuanpan")
--         if gDigMine.eventRewards.items ~= nil and #gDigMine.eventRewards.items > 0 then
--             local getFla = FlashAni.new()
--             getFla:playAction("ui_zhuanpan_huode",function ()
--                 getFla:removeFromParent()
-- --                self:getNode("icon_bg"..idx):setVisible(false)
--                 self.noGetNums = self.noGetNums - 1
--                 if self.noGetNums == 0 then
--                     gDigMine.eventRewards = {}
--                     self:onClose()
--                 end
--             end,nil,1)

--             local quality  = DB.getItemQuality(gDigMine.eventRewards.items[idx].id)
--             local quaIcon = cc.Sprite:create("images/ui_public1/ka_d"..(quality+1)..".png")
--             getFla:replaceBoneWithNode({"wupin","kuang"},quaIcon)
--             local itemIcon = self:createFlaReplaceItem(gDigMine.eventRewards.items[idx].id)
--             getFla:replaceBoneWithNode({"wupin","icon"},itemIcon)
--             getFla:setScale(0.8)
--             self:replaceNode("icon"..idx,getFla)
--             -- self:getNode("icon"):getChildByTag(99):replaceNode("icon",getFla)
--             -- self:getNode("icon"):getChildByTag(99):setNum(0)
--         end
--    end

    local moveBy = cc.MoveBy:create(0.6,cc.p(0,10))
    local moveByBack = moveBy:reverse()
    local actRepeat =cc.RepeatForever:create(cc.Sequence:create(moveBy,moveByBack))
    self:getNode("icon"..idx):runAction(actRepeat)
end

function MineMermaidRewardPanel:initLabelInfo()
    local itemInfo = ""
    for i = 1, #gDigMine.eventRewards.items do
        if i ~= 1 then
            itemInfo = itemInfo .. "," 
        end
        local item = gDigMine.eventRewards.items[i]
        local itemName = string.format("%sx%d", DB.getItemName(item.id), item.num)
        itemInfo = itemInfo ..itemName 
     end 
    self:setLabelString("txt_notice", gGetWords("noticeWords.plist","touch_get_item",itemInfo))
    self:getNode("txt_notice"):layout()
end

function MineMermaidRewardPanel:getRewards()
    loadFlaXml("ui_zhuanpan")

    for idx = 1,  #gDigMine.eventRewards.items do
        local getFla = FlashAni.new()
        getFla:playAction("ui_zhuanpan_huode",function ()
            getFla:removeFromParent()
--                self:getNode("icon_bg"..idx):setVisible(false)
            self.noGetNums = self.noGetNums - 1
            if self.noGetNums == 0 then
                self:onClose()
            end
        end,nil,1)

        local quality  = DB.getItemQuality(gDigMine.eventRewards.items[idx].id)
        local quaIcon = cc.Sprite:create("images/ui_public1/ka_d"..(quality+1)..".png")
        getFla:replaceBoneWithNode({"wupin","kuang"},quaIcon)
        local itemIcon = self:createFlaReplaceItem(gDigMine.eventRewards.items[idx].id)
        getFla:replaceBoneWithNode({"wupin","icon"},itemIcon)
        getFla:setScale(0.8)
        self:replaceNode("icon"..idx,getFla)
    end

    gDigMine.eventRewards = {}
end

-- function MineMermaidRewardPanel:onPopback()
--     gShowItemPoolLayer:pushOneItem(gDigMine.eventRewards.items[1])
--     gDigMine.eventRewards = {}
-- end

return MineMermaidRewardPanel