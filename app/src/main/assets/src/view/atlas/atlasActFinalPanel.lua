local AtlasActFinalPanel=class("AtlasActFinalPanel",UILayer)
local vipLimit = 4
local actAtlasDoubleRate  = DB.getClientParamToTable("ACT_ATLAS_DOUBLE_REWARD_RATE_SHOW")

function AtlasActFinalPanel:ctor(hp,dnum)
    self:init("ui/battle_resule_shilian.map")
    self.isBlackBgVisible=false  
    local data={}
    data.win=Battle.win 
    data.rewardItems={}
    data.gold=0
    data.dnum=dnum
    data.battleType=Battle.battleType
    data.value=hp
    data.cardExpItem=0
    data.equSoul=0
    
    if(Battle.reward.shows)then
        if(Battle.reward.shows.items)then
            data.rewardItems=Battle.reward.shows.items
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


        if(Battle.reward.shows.exp)then
            data.exp=Battle.reward.shows.exp
        end

        if(Battle.reward.shows.cardExp)then
            data.cardExp=Battle.reward.shows.cardExp
        end
        if(Battle.reward.shows.gold)then
            data.gold=Battle.reward.shows.gold
        end

        if(Battle.reward.shows.cardExpItem)then
            data.cardExpItem=Battle.reward.shows.cardExpItem
        end
    end

    self.curData=data
    self.double=1
    self.doubleFlag=true
    self.showRewardTime=0.9
    self.isProcessShowLevUp=false
    local stageData = DB.getActStageInfoById(Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid)
    self.actAtlasDoublePrice = string.split(stageData.doubleprice,";")

    if 1 == Battle.win then
        self:normalDisplay()
        gPlayEffect("sound/bg/bgm_Win.mp3")
    else
        self:roundFinishDisplay()
        gPlayEffect("sound/bg/bgm_Lose.mp3")
    end
    AudioEngine.setMusicVolume(0.4)
end

function  AtlasActFinalPanel:events()
    return {EVENT_ID_ACT_FINAL_DOUBLE}
end


function AtlasActFinalPanel:dealEvent(event,param)
    if(event==EVENT_ID_ACT_FINAL_DOUBLE)then
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

function AtlasActFinalPanel:onTouchEnded(target)

    if target.touchName=="btn_get" or target.touchName == "btn_vip_get" then
        if (not self.isProcessShowLevUp) and Scene.needLevelup  then
            self.isProcessShowLevUp = true
            self:getNode("ctr_show_levup"):runAction(cc.CallFunc:create(function()
                Scene.showLevelUp = true
            end))
            return
        end
        self:showItemReward()
        Scene.enterMainScene()
        
    elseif target.touchName=="btn_data" then
        Panel.popUp(PANEL_BATTLE_DATA)
        
    elseif target.touchName=="btn_gold_double"then
        if gIsVipExperTimeOver(VIP_DOUBLE) then
            return
        end
        Data.vip.activitydouble.setUsedTimes(self.curData.dnum); 
        local callback = function()
            Net.sendGetActAtlasReward();
            if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
                if (TDGAItem) then
                    gLogPurchase("buy_double_gold",1,self.double_price)
                end
            elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
                if (TDGAItem) then
                    gLogPurchase("buy_double_exp",1,self.double_price)
                end
            elseif self.curData.battleType == BATTLE_TYPE_ATLAS_PET then
                if (TDGAItem) then
                    gLogPurchase("buy_double_pet",1,self.double_price)
                end
            elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EQUSOUL then
                if (TDGAItem) then
                    gLogPurchase("buy_double_equsoul",1,self.double_price)
                end
            end
        end
        Data.canBuyTimes(VIP_DOUBLE,true,callback);
        
    elseif target.touchName == "btn_data" then

    end

end

function AtlasActFinalPanel:updateDoubleGetTip()
    if self:getNode("panel_gold_double"):isVisible() then
        local index = self.curData.dnum + 1
        if index <= #actAtlasDoubleRate and self.doubleFlag then
            local rate = actAtlasDoubleRate[self.curData.dnum + 1] .. "%"
            self:setLabelString("txt_double_rate", rate)
            local price = self.actAtlasDoublePrice[self.curData.dnum + 1]
            self.double_price = price
            self:setLabelString("txt_double_price", price)
        end
    end
end

function AtlasActFinalPanel:setControlShow()
    if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
        self:changeIconType("icon_gold_reward",OPEN_BOX_GOLD)
        self:getNode("icon_gold_reward"):setVisible(true)
        self:getNode("txt_gold_reward"):setVisible(true)
        self:getNode("panel_exp_reward"):setVisible(false)
        self:getNode("icon_pet_soul"):setVisible(false)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
        self:changeIconType("icon_gold_reward",OPEN_BOX_CARDEXP_ITEM)
        self:getNode("icon_gold_reward"):setVisible(true)
        self:getNode("txt_gold_reward"):setVisible(true)
        self:getNode("panel_exp_reward"):setVisible(false)
        self:getNode("icon_pet_soul"):setVisible(false)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_PET then
        self:changeIconType("icon_gold_reward",OPEN_BOX_PET_SOUL)
        self:getNode("icon_gold_reward"):setVisible(true)
        self:getNode("txt_gold_reward"):setVisible(true)
        self:getNode("panel_exp_reward"):setVisible(false)
        self:getNode("icon_pet_soul"):setVisible(false)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_EQUSOUL then
        self:changeIconType("icon_gold_reward",OPEN_BOX_EQUIP_SOUL)
        self:getNode("icon_gold_reward"):setVisible(true)
        self:getNode("txt_gold_reward"):setVisible(true)
        self:getNode("panel_exp_reward"):setVisible(false)
        self:getNode("icon_pet_soul"):setVisible(false)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_ITEMAWAKE then
        self:changeIconType("icon_gold_reward",OPEN_BOX_ITEMAWAKE)
        self:getNode("icon_gold_reward"):setVisible(true)
        self:getNode("txt_gold_reward"):setVisible(true)
        self:getNode("panel_exp_reward"):setVisible(false)
        self:getNode("icon_pet_soul"):setVisible(false)
    end

    vipLimit = Data.getCanBuyTimesVip(VIP_DOUBLE);
    -- print("vipLimit = "..vipLimit.."  gUserInfo.vip = "..gUserInfo.vip);
    if Data.getCurVip() < vipLimit or isBanshuUser() then
        self:getNode("panel_gold_double"):setVisible(false)
        self:getNode("panel_vip_get"):setVisible(false)
        self:getNode("panel_get"):setVisible(true)
    else
        self:getNode("panel_gold_double"):setVisible(true)
        self:getNode("panel_vip_get"):setVisible(true)
        self:getNode("panel_get"):setVisible(false)
    end
end

function AtlasActFinalPanel:showBasicInfo()
    self:setLabelString("txt_user_lv",getLvReviewName("Lv")..gUserInfo.level)
    
    self:setLabelString("txt_user_exp","+"..self.curData.exp)
    local expData= DB.getUserExpByLevel(gUserInfo.level)
    self:setBarPer("bar_user_exp",gUserInfo.exp/expData.exp)
    local txtInfo = ""
    if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_hurt_title")
        self:setLabelString("txt_hurt_title", txtInfo)
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_gold_reward_title")
        self:setLabelString("txt_rewards_title", txtInfo)
        self:setLabelString("txt_hurt_value", self.curData.value)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_ITEMAWAKE then
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_hurt_title")
        self:setLabelString("txt_hurt_title", txtInfo)
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_itemawake_reward_title")
        self:setLabelString("txt_rewards_title", txtInfo)
        self:setLabelString("txt_hurt_value", self.curData.value)
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_hurt_title")
        self:setLabelString("txt_hurt_title", txtInfo)
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_exp_reward_title")
        self:setLabelString("txt_rewards_title", txtInfo)
        self:setLabelString("txt_hurt_value", self.curData.value)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_PET then
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_kill_title")
        self:setLabelString("txt_hurt_title", txtInfo)
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_pet_soul_title")
        self:setLabelString("txt_rewards_title", txtInfo)
        self:setLabelString("txt_hurt_value", self.curData.value)
    elseif self.curData.battleType ==  BATTLE_TYPE_ATLAS_EQUSOUL then
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_kill_title")
        self:setLabelString("txt_hurt_title", txtInfo)
        txtInfo = gGetWords("labelWords.plist","lab_actatlas_equ_soul_title")
        self:setLabelString("txt_rewards_title", txtInfo)
        self:setLabelString("txt_hurt_value", self.curData.value)
    end
end

function AtlasActFinalPanel:showDouble()
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

    self:updateDoubleGetTip()
end

function AtlasActFinalPanel:rewardItemAction(parent, child, first, index, itemBeginShowTime, itemIntervalTime)
    if first then
        parent:setVisible(false)
        parent:setScale(0.9)
        local delay   = cc.DelayTime:create(itemBeginShowTime + itemIntervalTime * (index-1)) 
        local visible = cc.Show:create()
        local fadeIn  = cc.FadeIn:create(itemIntervalTime)
        local scaleTo = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime,0.5))
        local effectCallback = cc.CallFunc:create(function ()
            local effect=gCreateFla("ui_win_kuang_guang")
            effect:setAnchorPoint(cc.p(0.5, 0.5))
            local contentSize = parent:getContentSize()
            effect:setPosition(contentSize.width  / 2, contentSize.height / 2)
            parent:addChild(effect , 100)
        end)
        parent:runAction(cc.Sequence:create(delay, visible, effectCallback, cc.Spawn:create(fadeIn,scaleTo)))
    else
        parent:setVisible(true)
        local numLabel = child:getNode("txt_num")
        numLabel:setVisible(false)
        numLabel:setScale(6.0)
        local delay   = cc.DelayTime:create(itemBeginShowTime + itemIntervalTime * (index - 1)) 
        local visible = cc.Show:create()
        local easeBack = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime * 2,1.0))
        numLabel:runAction(cc.Sequence:create(delay, visible, easeBack))
    end
end

function AtlasActFinalPanel:processShowLevUp()
    if Scene.needLevelup then
        local delay   = cc.DelayTime:create(self.showRewardTime)
        self:getNode("ctr_show_levup"):runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
            if not self.isProcessShowLevUp then
                Scene.showLevelUp = true
            end
        end))) 
    end 
end

function AtlasActFinalPanel:normalDisplay()
    local blackBg=FlashAni.new()
    local size=self:getContentSize()
    blackBg:playAction("ui_common_cover_purple")
    blackBg:setAnchorPoint(cc.p(0.5, 0.5))
    blackBg:setPosition(cc.p(size.width/2, -size.height/2))
    self:addChild(blackBg, -1)

    self:getNode("panel_final"):setVisible(true)
    self:setNodeAppear("panel_final")
    self:setControlShow()
    self:showBasicInfo()
    self:showDouble()
    self:processShowLevUp()
end

function AtlasActFinalPanel:showItemReward()
    if self.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
        local rewardGold = math.floor(self.curData.gold * self.double)
        gShowItemPoolLayer:pushOneItem({id = OPEN_BOX_GOLD,num = rewardGold})
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_ITEMAWAKE then
        local rewardAwake = math.floor(self.curData.itemAwake * self.double)
        gShowItemPoolLayer:pushOneItem({id = OPEN_BOX_ITEMAWAKE,num = rewardAwake})
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
        local cardExpItem = math.floor(self.curData.cardExpItem * self.double)
        gShowItemPoolLayer:pushOneItem({id = OPEN_BOX_CARDEXP_ITEM,num = cardExpItem})
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_PET then
        local soulItem = math.floor(self.curData.soulItem * self.double)
        gShowItemPoolLayer:pushOneItem({id = OPEN_BOX_PET_SOUL,num = soulItem})
    elseif self.curData.battleType == BATTLE_TYPE_ATLAS_EQUSOUL then
        local equItem = math.floor(self.curData.equSoul * self.double)
        gShowItemPoolLayer:pushOneItem({id = OPEN_BOX_EQUIP_SOUL,num = equItem})
    end
end

function AtlasActFinalPanel:roundFinishDisplay()
    loadFlaXml("ui_huihejieshu")
    self:getNode("panel_final"):setVisible(false)
    local huihejieshu_a = FlashAni.new()
    local durTime_a = huihejieshu_a:playAction("ui_huihejieshu_a", nil ,nil, 0)
    self:getNode("panel_huihe_finish"):addChild(huihejieshu_a)
    local huihejieshu_b_refer = FlashAni.new()
    local durTime_refer = huihejieshu_b_refer:playAction("ui_huihejieshu_b", nil ,nil, 0)
    local durTime_b     = 0
    local showPanel = false
    gCallFuncDelay(durTime_a, self, function ()
            if nil ~= huihejieshu_a then
                  huihejieshu_a:removeFromParent()
            end

            local huihejieshu_b = FlashAni.new()
            huihejieshu_b:playAction("ui_huihejieshu_b", function()
                durTime_b = durTime_b + durTime_refer
                if (durTime_b > 20 * durTime_refer)  and (not showPanel) then
                    showPanel = true
                    self:normalDisplay()
                end
                end, nil, 1)
            self:getNode("panel_huihe_finish"):addChild(huihejieshu_b)
    end)
end

function AtlasActFinalPanel:createDoubleEffect(value, sucess)
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

    self:addChild(doubleFla, 2)
    doubleFla:setPositionY(-self:getContentSize().height/2)
    doubleFla:setPositionX(self:getContentSize().width/2)

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
        self:addChild(flagFra, 3)
        flagFra:setPositionY(-self:getContentSize().height * 0.3)
        flagFra:setPositionX(self:getContentSize().width/2)
    end)
    self:runAction(cc.Sequence:create(delay, callFunc))
end

function AtlasActFinalPanel:createDoubleEffectNum(sucess)
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

return AtlasActFinalPanel