local AtlasCrusadeSweepItem=class("AtlasCrusadeSweepItem",UILayer)
local vipLimit = 4
local actAtlasDoubleRate  = DB.getClientParamToTable("ACT_ATLAS_DOUBLE_REWARD_RATE_SHOW")

function AtlasCrusadeSweepItem:ctor()
    self:init("ui/battle_resule_shilian_2_item.map")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist")
end


function AtlasCrusadeSweepItem:onTouchEnded(target)

    if target.touchName=="btn_gold_double" then
        Net.sendActAtlasActdourewok(Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid,self.sweepIndex)
    end

end

function AtlasCrusadeSweepItem:setData(reward,dnum,parent)

	local data={}
	data.rewardItems={}
    data.gold=0
    data.dnum=dnum

    data.battleType= Data.getBattleType(Net.sendAtlasEnterParam.type)
    --data.value=hp
    data.cardExpItem=0
    data.equSoul=0
    if(reward.items)then
        data.rewardItems=reward.items
        for key, item in pairs(data.rewardItems) do
            if item.id == OPEN_BOX_PET_SOUL then
                data.soulItem = item.num
                break
            elseif item.id == OPEN_BOX_EQUIP_SOUL then
                data.equSoul = item.num
                break
            elseif item.id == ITEM_AWAKE then
                data.itemAwake = item.num
                break
            end
        end
    end
    if(reward.exp)then
        data.exp=reward.exp
    end
    if(reward.cardExp)then
        data.cardExp=reward.cardExp
    end
    if(reward.gold)then
        data.gold=reward.gold
    end
    if(reward.cardExpItem)then
        data.cardExpItem=reward.cardExpItem
    end
    self.curData=data
    self.parent=parent
    self.double=1
    self.sweepIndex = 1
    self.doubleFlag=true
    self:setLabelString("txt_hurt_value",reward.dmg)
    self:setControlShow()
    self:showDouble()
    --self:showItemReward()

end


function AtlasCrusadeSweepItem:dealEvent(event,param)
    if(event==EVENT_ID_ACT_FINAL_SWEEP_DOUBLE)then
    	if param[3] ~= self.sweepIndex then
    		return
    	end
        self.curData.dnum = param[2]
        if (param[1]==true)then
            self.double= self.double * 2
        else
            self:setTouchEnable("btn_gold_double",false,true)
            self.double = self.double * (1 + toint(DB.getClientParam("ACT_ATLAS_DOUBLE_FAILED_PERCENT"))/100)
            self.doubleFlag=false
        end
        self:showDouble()
    end
end


function AtlasCrusadeSweepItem:setNum(index)
	self.sweepIndex = index
	self:replaceLabelString("txt_sweep",index)
end


function AtlasCrusadeSweepItem:updateDoubleGetTip()

	local stageData = DB.getActStageInfoById(Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid)
	self.actAtlasDoublePrice = string.split(stageData.doubleprice,";")

	local index = self.curData.dnum + 1
	if index <= #actAtlasDoubleRate and self.doubleFlag then
	    local rate = actAtlasDoubleRate[self.curData.dnum + 1] .. "%"
	    self:setLabelString("txt_double_rate", rate)
	    local price = self.actAtlasDoublePrice[self.curData.dnum + 1]
	    self.double_price = price
	    self:setLabelString("txt_double_price", price)
	end
end


function AtlasCrusadeSweepItem:setControlShow()
    if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
        self:changeIconType("icon_gold_reward",OPEN_BOX_GOLD)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_ITEMAWAKE then
        self:changeIconType("icon_gold_reward",OPEN_BOX_ITEMAWAKE)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
        self:changeIconType("icon_gold_reward",OPEN_BOX_CARDEXP_ITEM)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_PET then
        self:changeIconType("icon_gold_reward",OPEN_BOX_PET_SOUL)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_EQUSOUL then
        self:changeIconType("icon_gold_reward",OPEN_BOX_EQUIP_SOUL)
    end

end

function AtlasCrusadeSweepItem:showDouble()

    if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
        local goldRewardTxt = self:getNode("txt_gold_reward")
        self:setLabelString("txt_gold_reward", math.floor(self.curData.gold * self.double))
        if self.double ~= 1 then
            self:createDoubleEffect(math.floor(self.curData.gold * self.double), self.doubleFlag)
        end
        -- self:createDoubleEffect(math.floor(self.curData.gold * self.double), false)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_ITEMAWAKE then
        local goldRewardTxt = self:getNode("txt_gold_reward")
        self:setLabelString("txt_gold_reward", math.floor(self.curData.itemAwake * self.double))
        if self.double ~= 1 then
            self:createDoubleEffect(math.floor(self.curData.itemAwake * self.double), self.doubleFlag)
        end
        -- self:createDoubleEffect(math.floor(self.curData.gold * self.double), false)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
        local cardExpItemTxt = self:getNode("txt_gold_reward")
        self:setLabelString("txt_gold_reward", math.floor(self.curData.cardExpItem * self.double))
        if self.double ~= 1 then
            self:createDoubleEffect(math.floor(self.curData.cardExpItem * self.double), self.doubleFlag)
        end
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_PET then
        local soulItemTxt = self:getNode("txt_gold_reward")
        self:setLabelString("txt_gold_reward", math.floor(self.curData.soulItem * self.double))
        if self.double ~= 1 then
            self:createDoubleEffect(math.floor(self.curData.soulItem * self.double), self.doubleFlag)
        end
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_EQUSOUL then
        local soulItemTxt = self:getNode("txt_gold_reward")
        self:setLabelString("txt_gold_reward", math.floor(self.curData.equSoul * self.double))
        if self.double ~= 1 then
            self:createDoubleEffect(math.floor(self.curData.equSoul * self.double), self.doubleFlag)
        end
    end
    
    vipLimit = Data.getCanBuyTimesVip(VIP_DOUBLE);
    -- print("vipLimit = "..vipLimit.."  gUserInfo.vip = "..gUserInfo.vip);
    if Data.getCurVip() < vipLimit or isBanshuReview() then
        self:getNode("btn_gold_double"):setVisible(false)
        self:getNode("bg_rate"):setVisible(false)
        self:getNode("bg_price"):setVisible(false)
    else
        self:getNode("btn_gold_double"):setVisible(true)
        self:getNode("bg_rate"):setVisible(true)
        self:getNode("bg_price"):setVisible(true)
    end

    self:updateDoubleGetTip()
end

function AtlasCrusadeSweepItem:createDoubleEffect(value, sucess)
    loadFlaXml("ui_shilianfanbei")
    local doubleFla = FlashAni.new()
    doubleFla:playAction("ui_shilian_fanbei", function()
        doubleFla:removeFromParent()
    end, nil, 1)

    --replace bg
    if not sucess then
        local failBg1 = cc.Sprite:create("images/ui_shilian/fanpai_2.png")
        doubleFla:replaceBoneWithNode({"1","1"}, failBg1)
        local failBg2 = cc.Sprite:create("images/ui_shilian/fanpai_2.png")
        failBg2:setCascadeOpacityEnabled(true)
        doubleFla:replaceBoneWithNode({"1","2"}, failBg2)
    end
    --replace icon
    local iconNode = DropItem.new()
    iconNode:getNode("txt_num"):setVisible(false)
    iconNode:setAllChildCascadeOpacityEnabled(true)
    if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
        iconNode:setData(OPEN_BOX_GOLD)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_ITEMAWAKE then
        iconNode:setData(OPEN_BOX_ITEMAWAKE)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
        iconNode:setData(OPEN_BOX_CARDEXP_ITEM)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EQUSOUL then
        iconNode:setData(OPEN_BOX_EQUIP_SOUL)
    else
        iconNode:setData(OPEN_BOX_PET_SOUL)
    end
    iconNode:setAnchorPoint(cc.p(0.5,-0.5))
    doubleFla:replaceBoneWithNode({"icon","icon2"},iconNode)

    --replace value label
    local ttfConfig = {}
    ttfConfig.fontFilePath = gCustomFont
    ttfConfig.fontSize = 24
    local goldValue = gCreateWordLabelTTF(tostring(value),gCustomFont,24,cc.c3b(0,0,0)) --cc.Label:createWithTTF(ttfConfig, tostring(value))
    -- goldValue:setColor(cc.c3b(0, 0, 0))
    doubleFla:replaceBoneWithNode({"zi"},goldValue)

    --replace double label
    local doubleValue = self:createDoubleEffectNum(sucess)
    doubleFla:replaceBoneWithNode({"X"},doubleValue)
    doubleFla:setAnchorPoint(cc.p(0.5,0.5))

    self.parent:addChild(doubleFla, 2)
    doubleFla:setPositionY(-self.parent:getContentSize().height/2)
    doubleFla:setPositionX(self.parent:getContentSize().width/2)

    --添加翻倍成功或翻倍失败效果
    local delay    = cc.DelayTime:create(0.6)
    local callFunc = cc.CallFunc:create(function ()
        local flaName = ""
        if sucess then
            flaName = "ui_shilian_zi_win"
        else
            flaName = "ui_shilian_zi_lose"
        end
        local flagFra = gCreateFla(flaName, 0)
        self.parent:addChild(flagFra, 3)
        flagFra:setPositionY(-self.parent:getContentSize().height * 0.3)
        flagFra:setPositionX(self.parent:getContentSize().width/2)
    end)
    self.parent:runAction(cc.Sequence:create(delay, callFunc))
end

function AtlasCrusadeSweepItem:createDoubleEffectNum(sucess)
    local layout = LayOutLayer.new(LAYOUT_TYPE_HORIZONTAL,-10)
    local num = gCreateBattleWord("images/fonts/font_img/red_num/x.png")
    layout:addNode(num)

    if sucess then
        num = gCreateBattleWord("images/fonts/font_img/red_num/2.png")
        layout:addNode(num)
    else
        --暂时不判断是否有小数点和位数
        local failRate = toint(DB.getClientParam("ACT_ATLAS_DOUBLE_FAILED_PERCENT"))/100 * 10
        num = gCreateBattleWord("images/fonts/font_img/red_num/1.png")
        layout:addNode(num)
        num = gCreateBattleWord("images/fonts/font_img/red_num/point.png")
        layout:addNode(num)
        num = gCreateBattleWord("images/fonts/font_img/red_num/" .. failRate .. ".png")
        layout:addNode(num)
    end
    layout:layout()
    layout:setScale(0.8)
    return layout
end

return AtlasCrusadeSweepItem