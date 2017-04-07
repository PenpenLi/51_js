local MineAtlasSweepPanel=class("MineAtlasSweepPanel",UILayer)

function MineAtlasSweepPanel:ctor()
    self:init("ui/ui_digmine_win.map")
    self.isBlackBgVisible=false
    self.isMainLayerGoldShow=false
    self.isMainLayerMenuShow=false
    local data={}
    data.win=Battle.win
    data.win=Battle.win
    data.gold=0
    data.cardExp=0
    data.exp=0
    data.star=3
    data.rewardItems={}
    data.battleType = Battle.battleType

    if nil ~= Battle.reward.starNum then
        data.star= Battle.reward.starNum
    end

    if(Battle.reward.shows)then
        if(Battle.reward.shows.items)then
            data.rewardItems=Battle.reward.shows.items
        end

        if(Battle.reward.shows.exp)then
            data.exp=Battle.reward.shows.exp
        end

        if(Battle.reward.shows.cardExp)then
            data.cardExp=Battle.reward.shows.cardExp
        end

        if(Battle.reward.shows.gold)then
            data.gold=Battle.reward.shows.gold
        end
    end
    --TOCHECK
    data.formation={}

    if(Battle.reward.formation)then
        data.formation=Battle.reward.formation
    end

    self.curData = data
    self.showStarTime = 0
    self.showRewardTime = 0

    self:setWinShow()
end

function MineAtlasSweepPanel:setWinShow()
    self:getNode("panel_win"):setVisible(true)
    self:getNode("scroll_win_items"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:showStar()
    self:showWinRewards()
    AudioEngine.setMusicVolume(0.4)
    gPlayEffect("sound/bg/bgm_Win.mp3")
end

function MineAtlasSweepPanel:showStar()
    for i=1, 3 do
        local star=self:getNode("star_up"..i)
        if(i<=self.curData.star)then
            local function playStar()
                local effect = gCreateFla("ui-win-xingxing", -1)
                effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                star:addChild(effect)
            end
            star:runAction( cc.Sequence:create(cc.DelayTime:create(i*0.3), cc.CallFunc:create(playStar)) )
            self.showStarTime = i * 0.3
        end
    end    
end

function MineAtlasSweepPanel:showWinRewards()
    self:setLabelString("txt_win_gold","+"..self.curData.gold)
    self:setLabelString("txt_win_exp","+"..self.curData.exp)
    if nil ~= gUserInfo.level then
        self:setLabelString("txt_win_lv",getLvReviewName("Lv")..gUserInfo.level)
    end

    if nil ~= gUserInfo.exp and nil ~= gUserInfo.level then
        local expData= DB.getUserExpByLevel(gUserInfo.level)
        self:setBarPer("bar_win_exp",gUserInfo.exp/expData.exp)
    end

    local idx=1
    local scrollWinItems = self:getNode("scroll_win_items")
    scrollWinItems.itemScale = 0.75
    local offsetX = nil
    local offsetY = nil
    for _, item in pairs(self.curData.rewardItems) do
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

        if nil == offsetY then
            offsetY = node:getContentSize().height / 2
        end
    end

    if nil ~= offsetX and nil ~= offsetY then
        scrollWinItems:setPaddingXY(offsetX * scrollWinItems.itemScale , -offsetY * scrollWinItems.itemScale)
    end
    scrollWinItems:layout()

    local itemBeginShowTime = 0.5 + self.showStarTime
    local itemIntervalTime  = 0.2
    local winItemIndex      = 1
    local winItems          = self:getNode("scroll_win_items").items
    local winItemsCount     = table.count(winItems)
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

    local maxWinItemIndex = #winItems
    if maxWinItemIndex > 0 then
        self.showRewardTime = itemBeginShowTime + itemIntervalTime * (maxWinItemIndex + 1/2)
    end
end

function MineAtlasSweepPanel:showStar()
    for i=1, 3 do
        local star=self:getNode("star_up"..i)
        if(i<=self.curData.star)then
            local function playStar()
                local effect = gCreateFla("ui-win-xingxing", -1)
                effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                star:addChild(effect)
            end
            star:runAction( cc.Sequence:create(cc.DelayTime:create(i*0.3), cc.CallFunc:create(playStar)) )
            self.showStarTime = i * 0.3
        end
    end    
end


function MineAtlasSweepPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_win_exit" then
        self:onClose()
    end
end


return MineAtlasSweepPanel
