local AtlasWorldBossRewardlPanel=class("AtlasWorldBossRewardlPanel",UILayer)

function AtlasWorldBossRewardlPanel:ctor(callback)
    self:init("ui/battle_resule_sjboss.map")
    self.isBlackBgVisible=false
    self.callback = callback
    self.curData={}
    self.curData.rewardItems =  Data.worldBossInfo.lkreward.items

    self:getNode("scroll_win_items"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    self:showWinRewards()
end

function  AtlasWorldBossRewardlPanel:showWinRewards()

    local idx=1
    local scrollWinItems = self:getNode("scroll_win_items")
    scrollWinItems.itemScale = 0.75
    local offsetX = nil
    local offsetY = nil
    for key, item in pairs(self.curData.rewardItems) do
        if not Data.isRewardItemShouldBeSkipped(self.__cname, item.id) then
            local node = DropItem.new()
            node:setData(item.id)
            node:setNum(item.num)
            node:setOpacity(0)
            gSetCascadeOpacityEnabled(node,true)
            node:setAnchorPoint(cc.p(0.5, -0.5))
            scrollWinItems:addItem(node)
            if nil == offsetX then
                offsetX = node:getContentSize().width / 2
            end  
            local type=DB.getItemType(item.id)
             if(item.num==2  )then
                if( type==ITEMTYPE_EQU or type==ITEMTYPE_EQU_SHARED or type==ITEMTYPE_CARD_SOUL)then

                    local  double=cc.Sprite:create("images/ui_public1/x2.png")
                    double:setPositionX(double:getContentSize().width/2)
                    double:setPositionY(-double:getContentSize().height/2)
                    node:addChild(double,100)
                end

            end

            if nil == offsetY then
                offsetY = node:getContentSize().height / 2
            end

        end
    end

    if nil ~= offsetX and nil ~= offsetY then
        scrollWinItems:setPaddingXY(offsetX * scrollWinItems.itemScale , -offsetY * scrollWinItems.itemScale)
    end
    scrollWinItems:layout()

    local itemBeginShowTime = 0.5
    local itemIntervalTime  = 0.2
    local winItemIndex      = 1
    local winItems          = self:getNode("scroll_win_items").items
    local winItemsCount        = table.count(winItems)
    for key, item in pairs(winItems) do
        item:setScale(0.6)
        local delay   = cc.DelayTime:create(itemBeginShowTime + itemIntervalTime * (key-1))
        local fadeIn  = cc.FadeIn:create(itemIntervalTime)
        local scaleTo1 = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime,0.85))
        local scaleTo2 = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime/2,0.75))
        local effectCallback = cc.CallFunc:create(function ()
            local effect=gCreateFla("ui_win_kuang_guang")
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            local contentSize = item:getContentSize()
            effect:setPosition(contentSize.width  / 2, - contentSize.height / 2)
            item:addChild(effect , 100)
        end)
        item:runAction(cc.Sequence:create(delay,effectCallback, cc.Spawn:create(fadeIn,scaleTo1), scaleTo2 ))
    end

end

function AtlasWorldBossRewardlPanel:onTouchEnded(target)

    if target.touchName=="btn_get" then
        if self.callback then
            Panel.popBack(self:getTag())
            self.callback()
        else
            Panel.popBack(self:getTag())
        end
    end

end

return AtlasWorldBossRewardlPanel