local SoulLifeFormationPanel=class("SoulLifeFormationPanel",UILayer)

local soulLifePanelType =
{
    zhen = 0,
    xunxian = 1,
}

local SoulLifeRoleStatus =
{
    no_choosed = 1,
    choosed = 2,
    choosing = 3,
}

local xunXianSwitchFlaTag = 999

function SoulLifeFormationPanel:ctor(panelType)
    self:init("ui/ui_soul_1.map")
    self.oldChooseIdx = -1
    self.chooseIdx = -1
    self.soulLifesNum   = #DB.getSpiritStartLev()
    self.equipSoulLifes = {}
    self.panelType = panelType--soulLifePanelType.zhen
    self.spiritType = SPIRIT_TYPE.GUI
    self.oldSpiritType = SPIRIT_TYPE.GUI
    self.typeFindActionTime = 0
    self.isFindingOrCalling = false
    -- 一键寻仙相关，自动升级的列表以及要升级的命魂
    self.quickXunXian = false
    self.isStopQuicking = false
    self.quickChooseType = SPIRIT_TYPE.GUI
    self.autoUpgradeList = {}
    self.autoUpgradeTarget = nil
    self.hasManySpiritsInFinding = false
    loadFlaXml("ui_soullife")
    self:initPanel()
    self:initDiscount()
    self:initPanelAttr()
    -- self:initSoulLifeIcon()
    self:initRoleChoosingActTime()
    self:chooseCardPos(0, true)
    -- self:setEquipSoulLifesByPos(0)
    -- Net.sendSpiritInit()
    self:initScrollSoulLifes()
    --是否要初始化命魂滚动条
    -- self.shouldInitScroll = true
    Scene.clearLazyFunc("soullifeitem")
    local function nodeEvent(event)
        if event == "exit" then
            self:onExit()
        end
    end

    self:registerScriptHandler(nodeEvent)
    self:hideCloseModule();
    self:initChildrenPanel()
    self:setScrollSoulLifes()
    self:initSoulLifesType()
    self:updateSoulLifeFragValue(SpiritInfo.iFra)

    Unlock.checkFirstEnter(SYS_XUNXIAN);

    --一键寻仙或多交寻仙时，出现碎片或橙色命魂时的索引
    self.findBreakIdx = 0
    self.findBreak = false
    self.findBreakType = 0
    self:getNode("panel_break_bg"):setVisible(false)
    self:setNodeTouchRectOffset("btn_detail_attr", 16,16)
    --暴力寻仙
    self.doingBaoLi = false

    self:initSoulLifeCallback()

    self:resetLayOut();
end

function SoulLifeFormationPanel:hideCloseModule()
    self:getNode("btn_quick_xunxian"):setVisible(not Module.isClose(SWITCH_VIP));
    if isBanshuUser() then
        self:getNode("btn_xunxian"):setVisible(false);
    end
end

function  SoulLifeFormationPanel:events()
    return { EVENT_ID_SPIRIT_INIT,
             EVENT_ID_SPIRIT_CHIP_REFRESH, 
             EVENT_ID_SPIRIT_UPDATE_BAG,
             EVENT_ID_SPIRIT_FIND,
             EVENT_ID_SPIRIT_UPGRADE,
             EVENT_ID_SPIRIT_BREAK_UP,
             EVENT_ID_SPIRIT_FIND_TYPE,
             EVENT_ID_SPIRIT_CALL_MORE,
             EVENT_ID_SPIRIT_EQU,
             EVENT_ID_SPIRIT_QUICK_CHOOSE,
             EVENT_ID_SPIRIT_NET_ERROR,
             EVENT_ID_SPIRIT_CHANGE_POS,
             EVENT_ID_SPIRIT_CH_EXP,
             EVENT_ID_SPIRIT_UPDATE_QUICK,
             EVENT_ID_SPIRIT_UPGRADE_BY_EXP,
             EVENT_ID_SPIRIT_BAO_LI,
             EVENT_ID_SPIRIT_OPEN_REFRESH,
             EVENT_ID_SPIRIT_UNLOAD,
             EVENT_ID_SPIRIT_EXCHANGE_POS,
           }
end

function SoulLifeFormationPanel:setEquipSoulLifesByPos(pos)
    self.equipSoulLifes = {}
    local addLvs = DB.getSpiritAddLevs()
    for i = 1, #self.posUnlock do
        if self.posUnlock[i] then
            local spiritPos = pos * 10 + i
            local spirit = SpiritInfo.getSpiritWithPos(spiritPos)
            self:getNode("icon_lock" .. i):setVisible(false)
            if nil ~= spirit then
                self.equipSoulLifes[i] = spirit
                Icon.setSpiritIcon(spirit.iType, self:getNode("icon_soullife"..i))
                self:setZhenIconLv(spirit.iLV,addLvs[i],i)
                -- self:getNode("lab_lv"..i):setVisible(true)
                self:getNode("layout_lv"..i):setVisible(true)
                self:getNode("layer_spirit_name"..i):setVisible(true)
                self:getNode("spirit_name"..i):setString(gGetSpiritAttrNameByType(spirit.iType, spirit.iAttr))
                self:getNode("spirit_name"..i):setColor(gCreateSpiritNameColor(spirit.iType))
                self:getNode("spirit_name"..i):setVisible(true)
            else
                self:getNode("icon_soullife"..i):removeChildByTag(1)
                -- self:getNode("lab_lv"..i):setVisible(false)
                self:getNode("layout_lv"..i):setVisible(false)
                self:getNode("layer_spirit_name"..i):setVisible(false)
                self:getNode("spirit_name"..i):setVisible(false)
            end
        else
            self:getNode("icon_soullife"..i):removeChildByTag(1)
            self.equipSoulLifes[i] = nil
        end
    end

    self:checkUnlockPosEqu()
end


function SoulLifeFormationPanel:dealEvent(event,param)
    if event == EVENT_ID_SPIRIT_INIT then
        self:setSoulLifeIcon()
        self:setEquipSoulLifesByPos(self.chooseIdx)
        self:setScrollSoulLifes()
        self:initSoulLifesType()
        self:updateSoulLifeFragValue(SpiritInfo.iFra)
    elseif event == EVENT_ID_SPIRIT_FIND then
        self:processFindOrCallMoreAction()
    elseif event == EVENT_ID_SPIRIT_UPGRADE then
        if self.quickXunXian then
            self:autoUpgrade()
        end
    elseif event == EVENT_ID_SPIRIT_CHIP_REFRESH then
        self:setScrollSoulLifes()
        self:updateBagNum()
        self:updateSoulLifeFragValue(SpiritInfo.iFra)
        self.scrollLayer:getItem(0):updateExpLab()
    elseif event == EVENT_ID_SPIRIT_BREAK_UP then
        local itemIdx = self:getScrollItemIdx(param)
        if -1 ~= itemIdx then
            self.scrollLayer:removeItemByIndex(itemIdx - 1)
        end
        self:updateBagNum()
        self:updateSoulLifeFragValue(SpiritInfo.iFra)
    elseif event == EVENT_ID_SPIRIT_FIND_TYPE then
        self:updateFindType()
        if not Data.isGoldEnough(SpiritInfo.getNeedGoldForSpirit(self.spiritType)) then
            NetErr.noEnoughGold();
            return
        end

        if SpiritInfo.isFindLimited(1) then
            return
        end
        
        Net.sendSpiritFind(false)
    elseif event ==  EVENT_ID_SPIRIT_CALL_MORE then
        self:processFindOrCallMoreAction()
    elseif event == EVENT_ID_SPIRIT_EQU then
        self:switchEquSoulLife(param)
    gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    elseif event == EVENT_ID_SPIRIT_QUICK_CHOOSE then
        self:getNode("txt_quick_xunxian"):setString(gGetWords("spiritWord.plist", "spirit_find_quick_stop"))
        self.quickXunXian = true
        self.quickChooseType = param[1]
        SpiritInfo.quickCostGold = param[2]
        self:updateQuickCost(param[2])
        self:quickXunXianCircleAction(true)
        Net.sendSpiritFindNew(SpiritInfo.quickCostGold )
    elseif event == EVENT_ID_SPIRIT_NET_ERROR then
        if self.quickXunXian then
            self:stopingQuickXunXian()
            self:processStopQuickXunXian()
        end
    elseif event == EVENT_ID_SPIRIT_CHANGE_POS then
        self:switchEquSoulLifePos(param)
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    elseif event == EVENT_ID_SPIRIT_CH_EXP then
        self:updateChExp()
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    elseif event == EVENT_ID_SPIRIT_UPGRADE_BY_EXP then
        self:updateChExp()
        self:updateUpgradeSpiritInfo(param)
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
        self:showSpiritAttr()
    elseif event == EVENT_ID_SPIRIT_UPDATE_QUICK then
        SpiritInfo.quickCostGold = param
        self:updateQuickCost(SpiritInfo.quickCostGold)
        self:processFindOrCallMoreAction()
    elseif event == EVENT_ID_SPIRIT_BAO_LI then
        self:processBaoLiEx(param)
    elseif event == EVENT_ID_SPIRIT_OPEN_REFRESH then
        self:refreshOpenFlag(param)
    elseif event == EVENT_ID_SPIRIT_UNLOAD then
        self:uploadEquSoulLifePos(param)
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    elseif event == EVENT_ID_SPIRIT_EXCHANGE_POS then
        self:exchangeEquSoulLifePos(param)
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)        
    end
end

function SoulLifeFormationPanel:showSpiritAttr()
    local zhenName = gGetWords("spiritWord.plist", "spirit_pos_name" .. self.chooseIdx)
    local txtIntroTitle = gGetWords("spiritWord.plist", "attr_zhen_add", zhenName)
    self:getNode("txt_soullife_intro_title"):setString(txtIntroTitle)

    local idx = 1
    -- 面板上最多显示6条属性
    local maxAttrShow = 6
    local maxAttrNum = 12
    local hasMoreAttr = false
    for i = 1, self.soulLifesNum do
        local spiritPos = self.chooseIdx * 10 + i
        local spirit    = SpiritInfo.getSpiritWithPos(spiritPos)
        if nil ~= spirit and idx <= maxAttrNum then
            if idx > maxAttrShow then
                hasMoreAttr = true
                break
            end
            local txtTitle  = self:getNode("attr_title"..idx)
            local txtValue  = self:getNode("attr_value"..idx)
            local addLv = DB.getSpiritAddLevByPos(i)
            local spiritAttr  = DB.getSpiritAttr(spirit.iType, spirit.iLV + addLv, spirit.iAttr)
            local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)
            txtTitle:setString(attrName)
            txtValue:setString(attrValue)
            self:getNode("layout_attr"..idx):layout()
            self:getNode("layout_attr"..idx):setVisible(true)
            idx = idx + 1
            if spiritAttr.attr2 ~= 0 then
                if idx > maxAttrShow then
                    hasMoreAttr = true
                    break
                end
                attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr2, spiritAttr.value2)
                txtTitle  = self:getNode("attr_title"..idx)
                txtValue  = self:getNode("attr_value"..idx)
                txtTitle:setString(attrName)
                txtValue:setString(attrValue)
                self:getNode("layout_attr"..idx):layout()
                self:getNode("layout_attr"..idx):setVisible(true)
                idx = idx + 1
            end
        end
    end

    for j = idx, maxAttrShow do
        self:getNode("layout_attr"..j):setVisible(false)
    end

    if hasMoreAttr then
        self:getNode("btn_detail_attr"):setVisible(true)
    else
        self:getNode("btn_detail_attr"):setVisible(false)
    end
end

function SoulLifeFormationPanel:initPanel()    
    if nil ~= gMainMoneyLayer then
        gMainMoneyLayer:refreshBtnEnergy()
        gMainMoneyLayer:refreshSpiritBuyItem()
    end
    -- self:showSpiritAttr()
end

function SoulLifeFormationPanel:updateSoulLifeFragValue(value)
    if nil ~= gMainMoneyLayer then
        gMainMoneyLayer:refreshBtnEnergy()
        gMainMoneyLayer:refreshSpiritBuyItem()
    end
end

function SoulLifeFormationPanel:createDrag(touch)
    if gDragLayer == nil then
        return
    end

    if(gDragLayer:getChildrenCount()==1  )then
        return
    end

    gDragLayer:removeAllChildren()

    local node=cc.Node:create()
    node:setTag(1)
    local spiritFla = gCreateSpiritFla(self.soullifeChoosed.iType)
    if nil ~= spiritFla then
        gAddChildInCenterPos(node, spiritFla)
    end
    gDragLayer:addChild(node)
    local location = touch:getLocation()
    node:setPosition(location.x,location.y)
end

function SoulLifeFormationPanel:onTouchMoved(target,touch, event)
    self.endAttrPos = touch:getLocation()
    local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
    if dis > gMovedDis then
        Panel.clearTouchTip()
    end

    if self.soullifeChoosed ~= nil then
        self:createDrag(touch)
    end

    local node=  gDragLayer:getChildByTag(1)
    local location = touch:getLocation()
    if(node)then
        node:setPosition(location.x,location.y)
    end
end
function SoulLifeFormationPanel:onTouchBegan(target,touch, event)
    self.soullifeChoosed = nil
    if self.isFindingOrCalling or self.doingBaoLi then
        return
    end
    if target.touchName == "btn_detail_attr" then
        Panel.popTouchTip(self:getNode("btn_detail_attr"),TIP_TOUCH_SOULLIFE_ATTR,self.chooseIdx)
    elseif string.find(target.touchName,"icon_soullife") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_soullife") + 1))
        if (Module.isClose(SWITCH_SPIRIT_EXTRA) and pos > 6) or
        (not self.posUnlock[pos]) then
            return
        end

        local soullife = self.equipSoulLifes[pos]
        if nil ~= soullife then
            self.soullifeChoosed = soullife
        end
    end

    self.beganAttrPos = touch:getLocation()
end

function SoulLifeFormationPanel:onTouchEnded(target,touch, event)
    print("SoulLifeFormationPanel:onTouchEnded",target.touchName)
    if self.isFindingOrCalling then
        if self.findBreak then
            self:getNode("panel_break_bg"):setVisible(false)
            local child = self:getNode("panel_break_bg"):getChildByTag(999)
            if child ~= nil then
                child:stopAllActions()
                child:removeFromParent()
                self.findBreak = false
                self:continueFindAction()
            end
            return
        elseif target.touchName ~= "btn_quick_xunxian" then
            return
        end
    end

    if self.doingBaoLi then
        return
    end

    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_xunxian" then
        self:switchPanel()
    elseif nil ~= target.touchName and string.find(target.touchName,"card_pos") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("card_pos") + 1))
        self:chooseCardPos(pos)
    elseif nil ~= target.touchName and string.find(target.touchName,"icon_soullife") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_soullife") + 1))
        local location = touch:getLocation()
        local curPos=  self:getPosItem(location)
        if self.soullifeChoosed ~= nil and 
            self:getNode(target.touchName).selectItemCallback ~= nil then
            if self:getNode(target.touchName).selectItemCallback(location,pos)then
                self.soullifeChoosed = nil
                return
            end
        end

        if pos ~= curPos then
            return
        end

        if Module.isClose(SWITCH_SPIRIT_EXTRA) and pos > 6 then
            return
        end
        
        if self.posUnlock[pos] then
            self:chooseSoulLife(pos)
        else
            local equSoulLifeStartLev = DB.getSpiritStartLev()
            local equSoulLifeStartVip = DB.getSpiritStartVip()
            local openLev = equSoulLifeStartLev[pos]
            local openVip = equSoulLifeStartVip[pos]

            if not Module.isClose(SWITCH_VIP) then
                if (Data.getCurLevel() >= openLev) or (openVip ~= 0 and Data.getCurVip() >= openVip) then
                    local price = DB.getSpiritStartPrice()[pos]
                    if price ~= 0 then
                        gConfirmCancel(gGetWords("spiritWord.plist","spirit_open_soul_pos",price), function()
                            if Data.getCurLevel() < openLev and openVip ~= 0 and Data.getCurVip() < openVip then
                                local txt = gGetCmdCodeWord("act.getreward88",27)
                                txt = txt..","..gGetWords("activityNameWords.plist","act_timeover")
                                gShowNotice(txt)
                                return
                            end
                            if Data.getCurDia() < price then
                                NetErr.noEnoughDia();
                                return
                            end
                            Net.sendSpiritOpen(self.chooseIdx * 10 + pos)
                        end)
                        return
                    end
                end
            end
        end
    elseif target.touchName == "btn_find_one" then
        if (not self:canClickFindOrCall()) then
            return
        end
        self:initDiscount()
        if self.baoLiFlag then
            local lvLimit = DB.getClientParam("SPIRIT_BAOLI_OPEN_LV")
            if (Data.getCurLevel() < lvLimit and gIsVipExperTimeOver(VIP_SPIRIT_VIOLENCE)) then
                return
            end
            
            local costBaoLi = DB.getBaoLiSpiritCost()
            if Data.activeSoullifeSaleoff.val ~= nil then
                costBaoLi = math.floor(costBaoLi * Data.activeSoullifeSaleoff.val / 100)
            end
            if not Data.isGoldEnough(costBaoLi) then
                NetErr.noEnoughGold();
                return
            end

            if SpiritInfo.getBagSpiritSize() >= DB.getSpiritBagMax() then
                gShowNotice(gGetWords("spiritWord.plist", "bag_maxcount_limit"))
                return
            end

            Net.sendSpiritBaoLi()
        else
            if not Data.isGoldEnough(SpiritInfo.getNeedGoldForSpirit(self.spiritType)) then
                NetErr.noEnoughGold();
                return
            end

            if SpiritInfo.isFindLimited(1) then
                return
            end
            
            Net.sendSpiritFind(false)
        end
    elseif target.touchName == "btn_fra_exchange" then
        if not self:canClickFindOrCall() then
            return
        end
        Net.sendSpiritShopInfo()
    elseif target.touchName == "btn_find_ten" then
        if not self:canClickFindOrCall() then
            return
        end
        if not Data.isGoldEnough(SpiritInfo.getNeedGoldForSpirit(self.spiritType)) then
            NetErr.noEnoughGold();
            return
        end

        if SpiritInfo.isFindLimited(10) then
            return
        end

        self:initDiscount()

        Net.sendSpiritFind(true)
    elseif target.touchName == "btn_call" then
        if not self:canClickFindOrCall() then
            return
        end
        Panel.popUpVisible(PANEL_SOULLIFE_CALL_SHEN_PANEL,nil,nil,true)
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_XUNXIAN)
    elseif target.touchName == "btn_quick_xunxian" then
        if self.isFindingOrCalling and not self.quickXunXian then
            return
        end
        self:initDiscount()
        if self.quickXunXian then
            self:stopingQuickXunXian()

        else
            self.isStopQuicking = false
            if Unlock.isUnlock(SYS_SPIRIT_QUICK,true) then
                Panel.popUpVisible(PANEL_SPIRIT_QUICK,nil,nil,true)
            end
        end
    elseif target.touchName == "btn_intro" then
        Panel.popUpVisible(PANEL_SPIRIT_INTRO,nil,nil,true)
    elseif target.touchName == "btn_my_soullife" then
        Panel.popUpVisible(PANEL_SOULLIFE_EQUIP, SOULLIFE_BAG_TYPE.UPGRADE,nil,true)
    elseif target.touchName == "check_baoli" then
        if self.baoLiFlag then
            self:changeTexture("check_baoli", "images/ui_public1/n-di-gou1.png")
            self.baoLiFlag = false
            self:updateXunXianCost()
        else
            local lvLimit = DB.getClientParam("SPIRIT_BAOLI_OPEN_LV")
            if (Data.getCurLevel() < lvLimit and gIsVipExperTimeOver(VIP_SPIRIT_VIOLENCE)) then
                return
            end
            
            local baoLiTime = cc.UserDefault:getInstance():getIntegerForKey(Data.getCurUserId().."baoli_choosed_time",0)
            if (RedPoint.isToday(toint(baoLiTime)) == false) then--没有记录或者不是当天
                --记录并弹框
                local costValue = DB.getBaoLiSpiritCost()
                if Data.activeSoullifeSaleoff.time ~= nil then
                   costValue = math.floor(costValue * Data.activeSoullifeSaleoff.val / 100)
                end
                local strCostValue = string.format("%d",costValue)
                if costValue > 10000 then
                    strCostValue = string.format("%dW",math.floor(costValue / 10000))
                end
                gConfirmCancel(gGetWords("spiritWord.plist","spirit_baoli_tip",strCostValue), function()
                    local lvLimit = DB.getClientParam("SPIRIT_BAOLI_OPEN_LV")
                    if Data.getCurLevel() < lvLimit and gIsVipExperTimeOver(VIP_SPIRIT_VIOLENCE) then
                        return
                    end
                    cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."baoli_choosed_time", gGetCurServerTime())
                    self:changeTexture("check_baoli", "images/ui_public1/n-di-gou2.png")
                    self.baoLiFlag = true
                    self:updateXunXianCost()
                end)
            else
                self:changeTexture("check_baoli", "images/ui_public1/n-di-gou2.png")
                self.baoLiFlag = true
                self:updateXunXianCost()
            end
        end
    elseif(target.touchName=="btn_detail_attr")then
        Panel.clearTouchTip()
    end
    
end

function SoulLifeFormationPanel:chooseCardPos(pos, init)
    if pos == self.chooseIdx then
        return
    end
    self.oldChooseIdx = self.chooseIdx 
    self.chooseIdx = pos
    self:showPosChoose(init)
end

function SoulLifeFormationPanel:showPosChoose(init)
    self:playPosChooseFla(self.chooseIdx)
    --箭头表现
    if not init then
        self:playJianTouFla()
        self:playZhenTitleAct(self.chooseIdx)
    end
    self:processZhenDetailFla(self.chooseIdx,init)
    self:showSpiritAttr()
    self:setSoulLifeIcon()
    self:setEquipSoulLifesByPos(self.chooseIdx)
end

function SoulLifeFormationPanel:updateSoullifeItem()
    -- body
end

function SoulLifeFormationPanel:chooseSoulLife(pos)
    SpiritInfo.setCurEquSpiritPos(self.chooseIdx * 10 + pos)
    local spirit = self.equipSoulLifes[pos]
    if nil ~= spirit then
        Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.FORMATION, true)
    else
        Panel.popUpVisible(PANEL_SOULLIFE_EQUIP, SOULLIFE_BAG_TYPE.EQU,nil, true)
    end
end

function SoulLifeFormationPanel:initSoulLifeIcon()
    local equSoulLifeStartLev = DB.getSpiritStartLev()
    local equSoulLifeStartVip = DB.getSpiritStartVip()
    
    self.posUnlock = {}
    for i = 1, self.soulLifesNum do
        self.posUnlock[i] = false
        local openLev = equSoulLifeStartLev[i]
        local openVip = equSoulLifeStartVip[i]
        if Data.getCurLevel() >= openLev and ((openLev ~= 0 and Data.getCurVip() >= openVip) or openLev == 0) then
            self.posUnlock[i] = true
        end

        if not self.posUnlock[i] then
            -- self:getNode("lab_lv" .. i):setVisible(false)
            self:getNode("layout_lv"..i):setVisible(false)
            self:getNode("icon_lock" .. i):setVisible(true)
            self:getNode("spirit_name" .. i):setVisible(false)
            self:getNode("layer_spirit_name"..i):setVisible(false)
            local txtOpenLv = self:getNode("txt_open_lv" .. i)
            if openVip == 0 then
                txtOpenLv:setString(gGetWords("spiritWord.plist", "zhen_pos_open_lev", openLev))
            else
                txtOpenLv:setString(gGetWords("spiritWord.plist", "zhen_pos_open_lev_and_vip", openVip, openLev))
            end
            
            txtOpenLv:setVisible(true)
        else
            self:getNode("txt_open_lv" .. i):setVisible(false)
        end
    end
end

function SoulLifeFormationPanel:switchPanel()
    if self.panelType == soulLifePanelType.zhen then
        self:processZhenAction(false)
        self:processZhenAttrAction(false)
        self:processPosDetail(false)
        self:processXunXianTypeAction(true)
        self:processXunXianBtnAction(true)
        self:processSoulLifeAction(true)
        self.panelType = soulLifePanelType.xunxian
        self:playSwitchFla("ui_soullife_qiehuan1",false)
    else
        self:processZhenAction(true)
        self:processZhenAttrAction(true)
        self:processPosDetail(true)
        self:processXunXianTypeAction(false)
        self:processXunXianBtnAction(false)
        self:processSoulLifeAction(false)
        self.panelType = soulLifePanelType.zhen
        self:playSwitchFla("ui_soullife_qiehuan2",false)
    end
end

function SoulLifeFormationPanel:processZhenAction(appear)
    local panelZhen = self:getNode("panel_zhen")
    if appear then
        local moveBy = cc.MoveBy:create(0.1,cc.p(-200, 0))
        local callFunc = cc.CallFunc:create(function ()
            panelZhen:setOpacity(0)
            panelZhen:setVisible(true)
        end)
        local spawn  = cc.Spawn:create(cc.MoveBy:create(0.1,cc.p(100, 0)),cc.FadeTo:create(0.2,255))
        local sequence = cc.Sequence:create(cc.DelayTime:create(0.2), moveBy, callFunc, spawn)
        panelZhen:runAction(sequence)
    else
        local spawn   = cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(100, 0)),cc.FadeTo:create(0.5,0))
        local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function ()
            panelZhen:setVisible(false)
        end))
        panelZhen:runAction(sequence)
    end
end

function SoulLifeFormationPanel:processZhenAttrAction(appear)
    local panelZhenAttr = self:getNode("panel_zhen_attr")
    if appear then
        local callFunc = cc.CallFunc:create(function ()
            panelZhenAttr:setOpacity(0)
            panelZhenAttr:setVisible(true)
        end)
        local spawn  = cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0, 100)),cc.FadeTo:create(0.2,255))
        local sequence  = cc.Sequence:create(cc.DelayTime:create(0.2), callFunc, spawn)
        panelZhenAttr:runAction(sequence)
    else
        local spawn    = cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0, -100)),cc.FadeTo:create(0.2,0))
        local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function ()
            panelZhenAttr:setVisible(false)
        end))
        panelZhenAttr:runAction(sequence)
    end
end

function SoulLifeFormationPanel:processPosDetail(appear)
    local panelPosDetail = self:getNode("panel_pos_detail")
    if appear then
        sequence  = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                panelPosDetail:setVisible(true)
            end))
        panelPosDetail:runAction(sequence)
        for i = 1, 8 do
            local detailNode = self:getNode("icon_soullife" .. i)
            local rotateBy = cc.RotateBy:create(0.2, cc.vec3(0, -90, 0))
            local spawn    = cc.Spawn:create(rotateBy, cc.FadeTo:create(0.2,255))
            detailNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), spawn))
        end

        local zhenDetailContainer = self:getNode("zhen_detail_container")
        zhenDetailContainer:runAction(cc.FadeIn:create(0.8))
    else
        for i = 1, 8 do
            local detailNode = self:getNode("icon_soullife" .. i)
            local rotateBy = cc.RotateBy:create(0.2, cc.vec3(0, 90, 0))
            local spawn    = cc.Spawn:create(rotateBy, cc.FadeTo:create(0.2,0))
            detailNode:runAction(spawn)
        end

        local zhenDetailContainer = self:getNode("zhen_detail_container")
        zhenDetailContainer:runAction(cc.FadeOut:create(0.2))

        local sequence = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function ()
            panelPosDetail:setVisible(false)
        end))
        panelPosDetail:runAction(sequence)
    end
end

function SoulLifeFormationPanel:processXunXianTypeAction(appear)
    local panelXunXianType = self:getNode("panel_xunxian_type")
    if appear then
        local moveBy = cc.MoveBy:create(0.1,cc.p(-150, 0))
        local callFunc = cc.CallFunc:create(function ()
            panelXunXianType:setOpacity(0)
            panelXunXianType:setVisible(true)
        end)
        local spawn  = cc.Spawn:create(cc.MoveBy:create(0.1,cc.p(150, 0)),cc.FadeTo:create(0.1,255))
        local sequence  = cc.Sequence:create(cc.DelayTime:create(0.1), moveBy, callFunc, spawn)
        panelXunXianType:runAction(sequence)
    else
        local spawn   = cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(150, 0)),cc.FadeTo:create(0.2,0))
        local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function ()
            panelXunXianType:setVisible(false)
        end),cc.MoveBy:create(0.1,cc.p(-150, 0)))
        panelXunXianType:runAction(sequence)
    end
end

function SoulLifeFormationPanel:processXunXianBtnAction(appear)
    local panelXunXianBtn = self:getNode("panel_xunxian_btn")
    if appear then
        local moveBy = cc.MoveBy:create(0.2,cc.p(0, -100))
        local callFunc = cc.CallFunc:create(function ()
            panelXunXianBtn:setOpacity(0)
            panelXunXianBtn:setVisible(true)
            self:quickXunXianCircleAction(false)
        end)
        local spawn  = cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0, 100)),cc.FadeTo:create(0.2,255))
        local sequence  = cc.Sequence:create(moveBy, callFunc, spawn)
        panelXunXianBtn:runAction(sequence)
    else
        local spawn    = cc.Spawn:create(cc.MoveBy:create(0.2,cc.p(0, -100)),cc.FadeTo:create(0.2,0))
        local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function ()
            panelXunXianBtn:setVisible(false)
        end), cc.MoveBy:create(0.2,cc.p(0, 100)))
        panelXunXianBtn:runAction(sequence)
    end
end

function SoulLifeFormationPanel:processSoulLifeAction(appear)
    local panelSoulLife = self:getNode("panel_soullife")
    if appear then
        panelSoulLife:setOpacity(0)
        panelSoulLife:setVisible(true)
        local sequence = cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeIn:create(0.2))
        panelSoulLife:runAction(sequence)
    else
        -- panelSoulLife:setOpacity(255)
        local sequence = cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeOut:create(0.2),cc.CallFunc:create(function()
            panelSoulLife:setVisible(false)
        end ))
        panelSoulLife:runAction(sequence)
    end
end

function SoulLifeFormationPanel:initScrollSoulLifes()
    self.scrollLayer = self:getNode("scroll_soullifes")
    self.scrollLayer.eachLineNum = 5
    self.scrollLayer.offsetX = 7
    self.scrollLayer:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
end
function SoulLifeFormationPanel:setScrollSoulLifes()
    if nil ~= self.scrollLayer then
        self.scrollLayer:clear()
        Scene.clearLazyFunc("soullifeitem")
        local expItem = self:initExpItem()
        self.scrollLayer:addItem(expItem)

        local drawNum = 19
        local size = SpiritInfo.getBagSpiritSize()
        local realIdx = 2
        for i = 1, size do
            local spirit = SpiritInfo.getBagSpiritByIdx(i)
            if nil ~= spirit then
                local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, realIdx, true)
                if nil ~= spiritItem then
                    spiritItem.onChoosed = function(item)
                        if not self.isFindingOrCalling then
                            Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                        end
                    end

                    if drawNum > 0 then
                        drawNum = drawNum - 1
                        spiritItem:setItem()
                    else
                        spiritItem:setLazyFunc("soullifeitem") 
                    end
                    self.scrollLayer:addItem(spiritItem)
                    realIdx = realIdx + 1
                end
            end
        end
        self.scrollLayer:layout(true)
    end
end

function SoulLifeFormationPanel:initSoulLifesType()
    self.oledSpiritType = self.spiritType
    self.spiritType = SpiritInfo.getiType()
    for i = 0, 4 do
        self:getNode("soullife_type_name".. i):setString(gGetWords("spiritWord.plist", "spirit_zhen_type"..(i+1)))
        if i ~= self.spiritType  then
            self:createSoulLifeRoleFla(i, SoulLifeRoleStatus.no_choosed)
        else
            self:createSoulLifeRoleFla(i, SoulLifeRoleStatus.choosed)
        end         
    end
    self:updateXunXianCost()
    self:enableBtnCallOrNot()
    self:updateBagNum()
end

function SoulLifeFormationPanel:updateXunXianCost()
    --Type从0开始，table索引从1开始
    local txtColor = cc.c3b(255, 255, 255)
    if self.baoLiFlag then
        local costBaoLi = DB.getBaoLiSpiritCost()
        if Data.activeSoullifeSaleoff.time ~= nil then
           costBaoLi = math.floor(costBaoLi * Data.activeSoullifeSaleoff.val / 100)
           txtColor = cc.c3b(102, 255, 0) 
        end 
        local strCost = costBaoLi
        if costBaoLi >= 10000 then
            strCost = string.format("%dW",math.floor(costBaoLi / 10000))
        end
        self:getNode("txt_cost"):setString(strCost)
    else
        local costValue  = DB.getNeedGoldForSpirit(self.spiritType + 1)
        if Data.activeSoullifeSaleoff.time ~= nil then
            costValue = math.floor(costValue * Data.activeSoullifeSaleoff.val / 100)
            txtColor = cc.c3b(102, 255, 0)
        end
        self:getNode("txt_cost"):setString(tostring(costValue))
    end
    self:getNode("txt_cost"):setColor(txtColor)
end

function SoulLifeFormationPanel:updateBagNum()
    self:setLabelString("txt_bag_num", string.format("%d/%d", SpiritInfo.getBagSpiritSize(), DB.getSpiritBagMax()))
end

function SoulLifeFormationPanel.processTypeFindAction(node,paramTable)
    if paramTable[2].iFType <= SPIRIT_TYPE.TIAN then
        paramTable[1].oldSpiritType = paramTable[1].spiritType
        paramTable[1].spiritType = paramTable[2].iFType
        if paramTable[1].oldSpiritType ~= paramTable[1].spiritType then
            paramTable[1]:createSoulLifeRoleFla(paramTable[1].oldSpiritType , SoulLifeRoleStatus.no_choosed)
        end
        local fla = FlashAni.new()
        if paramTable[1].spiritType == SPIRIT_TYPE.TIAN then
            fla:playAction(string.format("xian_npc%d_%d",paramTable[1].spiritType + 1, SoulLifeRoleStatus.choosing),function ()
                paramTable[1]:createSoulLifeRoleFla(paramTable[1].spiritType, SoulLifeRoleStatus.choosed)
            end,nil, 1)
        else
            fla:playAction(string.format("xian_npc%d_%d",paramTable[1].spiritType + 1, SoulLifeRoleStatus.choosing),function ()
                paramTable[1]:createSoulLifeRoleFla(paramTable[1].spiritType, SoulLifeRoleStatus.choosed)
            end,nil, 1)
            -- if paramTable[1].spiritType  ~= SPIRIT_TYPE.GUI then
            --     fla:replaceBone({"shell0"},string.format("images/ui_soullife/xian_npc%d_1.png", paramTable[1].spiritType + 1))
            --     fla:replaceBone({"head0"},string.format("images/ui_soullife/xian_npc%d_2.png", paramTable[1].spiritType + 1))
            --     fla:replaceBone({"foot_32"},string.format("images/ui_soullife/xian_npc%d_3.png", paramTable[1].spiritType + 1))
            --     fla:replaceBone({"foot_33"},string.format("images/ui_soullife/xian_npc%d_3.png", paramTable[1].spiritType + 1))
            --     fla:replaceBone({"foot_34"},string.format("images/ui_soullife/xian_npc%d_3.png", paramTable[1].spiritType + 1))
            -- end
        end
        if paramTable[1].hasManySpiritsInFinding then
            fla:setSpeedScale(2)
        end
        paramTable[1]:getNode("soullife_type_role" .. paramTable[2].iFType):removeAllChildren()
        gAddChildInCenterPos(paramTable[1]:getNode("soullife_type_role" .. paramTable[2].iFType), fla)
    end
end

function SoulLifeFormationPanel:switchTypeChoose()
    if self.oldSpiritType == self.spiritType then
        return
    end

    self:createSoulLifeRoleFla(self.oldSpiritType , SoulLifeRoleStatus.no_choosed)
    self:createSoulLifeRoleFla(self.spiritType , SoulLifeRoleStatus.choosed)
    -- DisplayUtil.setGray(self:getNode("soullife_type_bottom"..self.oldSpiritType), true)
    -- DisplayUtil.setGray(self:getNode("soullife_type_role"..self.oldSpiritType), true)
    -- DisplayUtil.setGray(self:getNode("soullife_type_bottom"..self.spiritType), false)
    -- DisplayUtil.setGray(self:getNode("soullife_type_role"..self.spiritType), false)
    self:enableBtnCallOrNot()
end

function SoulLifeFormationPanel:enableBtnCallOrNot()
    if self.spiritType < SPIRIT_TYPE.SHEN then
        self:setTouchEnable("btn_call", true, false)
    else
        self:setTouchEnable("btn_call", false, true)  
    end
end

function SoulLifeFormationPanel.processSpiritAction(node, paramTable)
    local self = paramTable[1]
    local spirit = paramTable[2]
    local delayTime = 0
    -- if idx == 1 then
    --     --爆炸action
    --     -- delayTime = delayTime + 0.5 
    -- end
    --金币
    if spirit.iType == SPIRIT_TYPE.GOLD then
        -- delayTime = delayTime + 0.2
        -- local item={}
        -- item.id  = OPEN_BOX_GOLD
        -- item.num = spirit.iValue
        -- gShowItemPoolLayer:pushItems({item})
        -- delayTime = delayTime + 1
        local flyTime = 0.2 --图标飞的时间
        self.scrollLayer:moveItemByIndex(0)
        local spiritIcon = cc.Sprite:create(string.format("images/ui_soullife/soul_%d.png", SPIRIT_TYPE.EXP))
        spiritIcon:setScale(1.2)
        spiritIcon:setAnchorPoint(cc.p(0.5, 0.5))
        spiritIcon:setVisible(false)
        local spiritTypePos = self:getNode("soullife_type_role"..self.spiritType)
        local worldPos = self:getNode("panel_xunxian_type"):convertToWorldSpace(cc.p(spiritTypePos:getPosition()))
        local nodePos   = self:convertToNodeSpace(worldPos)
        spiritIcon:setPosition(nodePos)
        self:addChild(spiritIcon,99)

        local itemBg = self.scrollLayer:getItem(0):getNode("icon_bg")
        local moveToWorldPos = self.scrollLayer:getItem(0):convertToWorldSpace(cc.p(itemBg:getPosition()))
        local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
        local moveTo = cc.MoveTo:create(flyTime, moveToNodPos)
        spiritIcon:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Show:create(), moveTo, cc.CallFunc:create(function ()
            spiritIcon:removeFromParent()
            local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
            local expItem   = self.scrollLayer:getItem(0)
            SpiritInfo.exp = SpiritInfo.exp + spirit.iValue
            expItem:updateExpLab()
        end)))

    elseif spirit.iType == SPIRIT_TYPE.CHIP then -- 碎片
        -- delayTime = delayTime + 0.2
        -- local item={}
        -- item.id  = ID_SPIRIT_FRAGMENT
        -- item.num = 1
        -- gShowItemPoolLayer:pushItems({item})
        -- delayTime = delayTime + 1.0
        -- SpiritInfo.addFra(1)
        -- --更新碎片数量
        -- self:updateSoulLifeFragValue(SpiritInfo.getFraCount())

        self:getNode("panel_break_bg"):setVisible(true)
        local ret = self:createFindFraOrTianFla(SPIRIT_TYPE.CHIP) --cc.Sprite:create("images/ui_soullife/soul_fra.png")
        local delayTime = cc.DelayTime:create(1)
        ret:runAction(cc.Sequence:create(delayTime,cc.CallFunc:create(function ()
            ret:removeFromParent()
            self:getNode("panel_break_bg"):setVisible(false)
            self.findBreak = false
            self:continueFindAction()
        end)))
    elseif spirit.iType == SPIRIT_TYPE.TIAN then --橙色命魂
        self:getNode("panel_break_bg"):setVisible(true)
        local tianSpirit = self:createFindFraOrTianFla(SPIRIT_TYPE.TIAN)
        local delayTime = cc.DelayTime:create(1)
        tianSpirit:runAction(cc.Sequence:create(delayTime,cc.CallFunc:create(function ()
            tianSpirit:removeFromParent()
            self:getNode("panel_break_bg"):setVisible(false)
            self.findBreak = false
            self:continueFindAction()
        end)))
    elseif spirit.iID == ITEM_SPIRIT_BUY then ----仙令
        self:getNode("panel_break_bg"):setVisible(true)
        local spiritBuyItem = self:createFindFraOrTianFla(ITEM_SPIRIT_BUY)
        local delayTime = cc.DelayTime:create(1)
        spiritBuyItem:runAction(cc.Sequence:create(delayTime,cc.CallFunc:create(function ()
            spiritBuyItem:removeFromParent()
            self:getNode("panel_break_bg"):setVisible(false)
            self.findBreak = false
            self:continueFindAction()
        end)))

    else --命魂
        local flyTime = 0.2 --图标飞的时间
        local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, self.scrollLayer:getSize(), true)
        if nil ~= spiritItem then
            spiritItem.onChoosed = function(item)
                if not self.isFindingOrCalling then
                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                end
            end
            spiritItem:setItem()
            self.scrollLayer:addItem(spiritItem)
            self.scrollLayer:layout()
            spiritItem:setOpacity(0)
            self.scrollLayer:moveItemByIndex(self.scrollLayer:getSize() - 1)
            spiritItem:runAction(cc.Sequence:create(cc.DelayTime:create(flyTime + delayTime), cc.FadeIn:create(0.5)))
        end

        --图标飞
--        local particle =  cc.ParticleSystemQuad:create("particle/ui_soullife_lizi.plist")
--        particle:setAnchorPoint(cc.p(0.5, 0.5))
--        particle:setVisible(false)
--        local spiritTypePos = self:getNode("soullife_type_role"..self.spiritType)
--        local worldPos = self:getNode("panel_xunxian_type"):convertToWorldSpace(cc.p(spiritTypePos:getPosition()))
--        local nodePos   = self:convertToNodeSpace(worldPos)
--        particle:setPosition(nodePos)
--        self:addChild(particle)

        local spiritIcon = cc.Sprite:create(string.format("images/ui_soullife/soul_%d.png", spirit.iType + 1))
        spiritIcon:setScale(1.2)
        spiritIcon:setAnchorPoint(cc.p(0.5, 0.5))
        spiritIcon:setVisible(false)
        local spiritTypePos = self:getNode("soullife_type_role"..self.spiritType)
        local worldPos = self:getNode("panel_xunxian_type"):convertToWorldSpace(cc.p(spiritTypePos:getPosition()))
        local nodePos   = self:convertToNodeSpace(worldPos)
        spiritIcon:setPosition(nodePos)
        self:addChild(spiritIcon,99)

        local itemBg = spiritItem:getNode("icon_bg")
        local moveToWorldPos = spiritItem:convertToWorldSpace(cc.p(itemBg:getPosition()))
        local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
        local moveTo = cc.MoveTo:create(flyTime, moveToNodPos)
        spiritIcon:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Show:create(), moveTo, cc.CallFunc:create(function ()
            spiritIcon:removeFromParent()
        end)))
    end
end

function SoulLifeFormationPanel:updateFindType()
    if self.quickXunXian then
        self:againQuickXunXian()
    else
        self.isFindingOrCalling = false
        self.scrollLayer:setTouchEnable(true)
        self:setMainLayerTouchEnable(true)
    end

    -- self:removeChildByTag(1999)
    self:setTouchEnable("btn_find_ten", true)
    --更新背包数量
    self:updateBagNum()
    --更新类型
    self.oldSpiritType = self.spiritType
    self.spiritType = SpiritInfo.getiType()
    self:switchTypeChoose()
    --更新寻仙价
    self:updateXunXianCost()
    --更新召唤按钮
    self:enableBtnCallOrNot()
end

function SoulLifeFormationPanel:getScrollItemIdx(ID)
    for i = 1, self.scrollLayer:getSize() do
        local item = self.scrollLayer:getItem(i - 1)
        if item._ID == ID then
            return i
        end
    end
    return -1
end

function SoulLifeFormationPanel:updateEquSpiritByUpgrade()
    -- SpiritInfo.sortSpiritBagList()
    self:setScrollSoulLifes()

    local ID = SpiritInfo.getUpgradeSpiritID()
    --更新装备的命魂
    local spirit = SpiritInfo.getSpiritByID(ID)
    if nil ~= spirit then
        local pos = spirit.iPos % 10
        if nil ~= self.equipSoulLifes[pos] and 
            self.equipSoulLifes[pos].iID == ID then
            self.equipSoulLifes[pos] = spirit
            local addLv = DB.getSpiritAddLevByPos(pos)
            self:setZhenIconLv(spirit.iLV, addLv, pos)
        end
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    end
    --更新背包里面的命魂
    local idx = SpiritInfo.getBagSpiritIdxByID(ID)
    if -1 ~= idx then
        ---第一项为经验池，所以对应的物品索引得加1
        local spiritItem = self.scrollLayer:getItem(idx)
        if nil ~= spiritItem then
            spiritItem:updateItem(SpiritInfo.getBagSpiritByIdx(idx))
        end
    end

    self:showSpiritAttr()
end

function SoulLifeFormationPanel:processFindOrCallMoreAction()
    local size = SpiritInfo.getFindSpiritSize()
    if size > 0 then
        self.isFindingOrCalling = true
        self.scrollLayer:setTouchEnable(false)
        self:setMainLayerTouchEnable(false)
        local showFindDelay = 0
        self.scrollLayer:moveItemByIndex(self.scrollLayer:getSize())
        self.hasManySpiritsInFinding  = SpiritInfo.hasManySpiritInFindSpirit()
        local roleActTime = 0
        if self.quickXunXian then
            self:setQuickFindRoleStatus()
        else
            for i = 1, size do
                local spirit = SpiritInfo.getFindSpiritByIdx(i)
                if nil ~= spirit then
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay), cc.CallFunc:create(self.processTypeFindAction, {self, spirit})))
                    roleActTime = self:getRealRoleChoosingActTime(spirit.iFType)
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay + roleActTime), cc.CallFunc:create(self.processSpiritAction, {self, spirit})))
                    
                    if spirit.iType == SPIRIT_TYPE.CHIP or spirit.iType == SPIRIT_TYPE.TIAN or 
                        spirit.iID == ITEM_SPIRIT_BUY then
                        self.findBreak = true
                        self.findBreakIdx = i
                        print("processFindOrCallMoreAction self.findBreakIdx is:",self.findBreakIdx)
                        if spirit.iID == ITEM_SPIRIT_BUY then
                            self.findBreakType = ITEM_SPIRIT_BUY
                        else
                            self.findBreakType = spirit.iType
                        end
                        break
                    end

                    if i == 1 then
                        -- 爆炸特效
                        -- showFindDelay = showFindDelay + 0.5
                    end
                    showFindDelay = showFindDelay + 0.2 + roleActTime
                    --最后一个
                    if i == size then
                        self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay) , cc.CallFunc:create(function()
                            self:updateFindType()
                        end)))
                    end
                end
                -- --抽卡效果
                -- if nil ~= spirit then
                --     if spirit.iType == SPIRIT_TYPE.COLD then
                --     elseif spirit.iType == SPIRIT_TYPE.CHIP then
                --     else
                --         local spiritItem = XunXianItem.new()
                --         if nil ~= spiritItem then
                --             spiritItem:initLayer(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, i, true)
                --             self.scrollLayer:addItem(spiritItem)
                --         end
                --     end
                -- end
            end
        end
    end
end

function SoulLifeFormationPanel:switchEquSoulLife(param)
    local spirit = SpiritInfo.getSpiritWithPos(param.pos)
    if nil ~= spirit then
        local soulLifePos = param.pos % 10
        self.equipSoulLifes[soulLifePos] = spirit
        Icon.setSpiritIcon(spirit.iType, self:getNode("icon_soullife".. soulLifePos))
        local addLv = DB.getSpiritAddLevByPos(soulLifePos)
        self:setZhenIconLv(spirit.iLV,addLv,soulLifePos)
        -- self:getNode("lab_lv"..soulLifePos):setVisible(true)
        self:getNode("layout_lv"..soulLifePos):setVisible(true)
        self:getNode("layer_spirit_name"..soulLifePos):setVisible(true)
        self:getNode("spirit_name".. soulLifePos):setString(gGetSpiritAttrNameByType(spirit.iType, spirit.iAttr))
        self:getNode("spirit_name".. soulLifePos):setColor(gCreateSpiritNameColor(spirit.iType))
        self:getNode("spirit_name".. soulLifePos):setVisible(true)
        self:showSpiritAttr()
    end

    --更新背包显示
    -- pos = iPos, add = addSpirit, remove = removeSpirit}
    if param.remove ~= nil then
        local idx = self:getScrollItemIdx(param.remove.iID)
        if -1 ~= idx then
            self.scrollLayer:removeItemByIndex(idx - 1)
        end
    end

    if param.add ~= nil then
        local spiritItem = XunXianItem.new(param.add, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, self.scrollLayer:getSize() + 1, true)
        if nil ~= spiritItem then
            spiritItem.onChoosed = function(item)
                if not self.isFindingOrCalling then
                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, param.add, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                end
            end
            spiritItem:setItem()
            self.scrollLayer:addItem(spiritItem)
        end 
    end
    self.scrollLayer:layout(false)
    self:updateBagNum()
    self:checkUnlockPosEqu()
end

function SoulLifeFormationPanel:againQuickXunXian()
    if not self.quickXunXian then
        return
    end

    --自动升级操作
    self:autoChExp()
    -- self:autoUpgradeSoulLife()
end

function SoulLifeFormationPanel:autoUpgradeSoulLife()
    self:chooseAutoUpgradeListByType(self.quickChooseType)
    self:sendAutoUpgradeMsg()
end

function SoulLifeFormationPanel:chooseAutoUpgradeListByType(quickChooseType)
    self.autoUpgradeList = {}
    self.autoUpgradeTarget = nil
    local size = SpiritInfo.getBagSpiritSize()
    for i = 1, size do
        local spirit = SpiritInfo.getBagSpiritByIdx(i)
        if nil ~= spirit and spirit.iPos == 0 and (((spirit.iLV < DB.getSpiritMaxLev()) and  (spirit.iType == quickChooseType)) or 
                                                   (spirit.iType < quickChooseType)) then
            table.insert(self.autoUpgradeList, spirit)
        end
    end

    if #self.autoUpgradeList > 0 then
        self:chooseTargetAutoUpgrade(quickChooseType)
    end
end

function SoulLifeFormationPanel:chooseTargetAutoUpgrade(quickChooseType)
    local notFound = true
    while notFound do
        local size = #self.autoUpgradeList
        if size == 0 then
            break
        end
        local idx  = 1
        local target = nil
        for i = 1, size do
            local spirit = self.autoUpgradeList[i]
            if nil == target then
                target = spirit
                idx = i
            elseif target.iType < spirit.iType then
                target = spirit
                idx = i
            elseif target.iType == spirit.iType then
                if target.iLV < spirit.iLV then
                    target = spirit
                    idx = i
                elseif target.iExp < spirit.iExp then
                    target = spirit
                    idx = i
                end
            end
        end

        if target.iLV >= DB.getSpiritMaxLev() then
            table.remove(self.autoUpgradeList, idx)
        else
            self.autoUpgradeTarget = target
            notFound = false
        end
    end
end

function SoulLifeFormationPanel:sendAutoUpgradeMsg()
    local hasAutoUpgradeSpirit = false
    local choosedIds = {}
    for i = 1, #self.autoUpgradeList do
        local spirit = self.autoUpgradeList[i]
        if not gIsTheSameSpirit(self.autoUpgradeTarget,spirit) then
            table.insert(choosedIds, spirit.iID)
        end
    end

    if #choosedIds ~= 0 then
        Net.sendSpiritUpgrade(self.autoUpgradeTarget.iID, self.autoUpgradeTarget.iPos, choosedIds)
    else
        self.autoUpgradeTarget = nil
        if self.isStopQuicking then
            self:processStopQuickXunXian()
        else
            if not SpiritInfo.isFindLimited(10) then
                Net.sendSpiritFind(true)
            else
                if self.quickXunXian then
                    self:stopingQuickXunXian()
                    self:processStopQuickXunXian()
                end
            end
        end
    end
end

function SoulLifeFormationPanel:autoUpgrade()
    for i = 1, #self.autoUpgradeList do
        local spirit = self.autoUpgradeList[i]
        if not gIsTheSameSpirit(self.autoUpgradeTarget,spirit) then
            self.autoUpgradeTarget.iExp = self.autoUpgradeTarget.iExp + spirit.iExp + toint(DB.getSpiritBaseExp(spirit.iType + 1))
            SpiritInfo.removeBagSpiritByID(spirit.iID)
        end
    end
    -- print("SpiritInfo bagSize is ", SpiritInfo.getBagSpiritSize())
    self.autoUpgradeTarget.iLV =  DB.getSpiritLevel(self.autoUpgradeTarget.iType, self.autoUpgradeTarget.iExp)
    SpiritInfo.clearFindSpiritList()

    self:sortScrollLayer()
    -- print("self.scrollLayer sortScrollLayer size is ", self.scrollLayer:getSize())
    local idx,targetIdx = self:getTheLastIdxOfType(self.autoUpgradeTarget)
    -- print("getTheLastIdxOfType ", idx, targetIdx, self.autoUpgradeTarget.iType, self.autoUpgradeTarget.iLV, self.autoUpgradeTarget.iAttr)
    if idx == -1 then
        self.scrollLayer:clear()
    else
        self.scrollLayer:moveItemByIndex(idx - 1)
        for i = self.scrollLayer:getSize(), idx + 1 , -1 do
            self.scrollLayer:removeItemByIndex(i - 1)
        end
    end

    if targetIdx == -1 or targetIdx > idx then
        local spiritItem = XunXianItem.new(self.autoUpgradeTarget, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, idx + 1, true)
        if nil ~= spiritItem then
            spiritItem.onChoosed = function(item)
                if not self.isFindingOrCalling then
                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, self.autoUpgradeTarget, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                end
            end
            spiritItem:setItem()
            self.scrollLayer:addItem(spiritItem)
            self.scrollLayer:layout(false) 
        end        
    else
        -- print("target idx is ", targetIdx - 1)
        local spiritItem = self.scrollLayer:getItem(targetIdx - 1)
        if nil ~= spiritItem then
            spiritItem:updateItem(self.autoUpgradeTarget)
        end
    end
    -- print("self.scrollLayer size is ", self.scrollLayer:getSize())
    self:updateBagNum()
    if self.isStopQuicking then
        self:processStopQuickXunXian()
    else
        if not SpiritInfo.isFindLimited(10) then
            Net.sendSpiritFind(true)
        else
            if self.quickXunXian then
                self:stopingQuickXunXian()
                self:processStopQuickXunXian()
            end
        end
    end
end

function SoulLifeFormationPanel:stopingQuickXunXian()
    self:getNode("txt_quick_xunxian"):setString(gGetWords("spiritWord.plist", "spirit_find_quick"))
    self:getNode("layout_quick_cost"):setVisible(false)
    -- self.quickXunXian = false
    self.isStopQuicking = true
    self:quickXunXianCircleAction(false)
    if (TDGAMission) then 
        gLogMissionCompleted("quick_sprit_find")
    end
end

function SoulLifeFormationPanel:processStopQuickXunXian()
    self.quickXunXian = false
    self.isFindingOrCalling = false
    self.scrollLayer:setTouchEnable(true)
    self:setMainLayerTouchEnable(true)
    self:resetRoleStatusAfterQuick()
end

function SoulLifeFormationPanel:onExit()
    Scene.clearLazyFunc("soullifeitem")
    cc.UserDefault:getInstance():setBoolForKey(Data.getCurUserId().."isBaoLi", self.baoLiFlag)
    Panel.clearTouchTip()
end

function SoulLifeFormationPanel:playSwitchFla(ani, init)
    self:getNode("btn_xunxian"):removeChildByTag(xunXianSwitchFlaTag)
    local fla = gCreateFla(ani, -1)
    if init then
        fla:stopAni()
    end
    fla:setTag(xunXianSwitchFlaTag)
    gAddChildInCenterPos(self:getNode("btn_xunxian"), fla)
end

function SoulLifeFormationPanel:playPosChooseFla(pos)
    self:getNode("panel_zhen"):removeChildByTag(99)
    local chooseFla = gCreateFla("ui_soullife_kapian", -1)
    chooseFla:replaceBone({"ka1"},"images/ui_soullife/di_zhen_choose1-".. pos ..".png")
    chooseFla:replaceBone({"ka2"},"images/ui_soullife/di_zhen_choose1-".. pos ..".png")
    chooseFla:replaceBone({"ka3","kadong"},"images/ui_soullife/di_zhen_choose1-".. pos ..".png")
    chooseFla:setTag(99)
    -- local worldPos = self:getNode("panel_zhen"):convertToWorldSpace(cc.p(self:getNode("choose_icon" .. pos):getPosition()))
    -- local nodePos  = self:convertToNodeSpace(worldPos)
    chooseFla:setPosition(self:getNode("choose_icon" .. pos):getPosition())
    self:getNode("panel_zhen"):addChild(chooseFla,1)
end

function SoulLifeFormationPanel:playJianTouFla()
    local jianTouFla = gCreateFla("ui_soullife_jiantou", -1)
    self:replaceNode("icon_jiantou", jianTouFla)
end

function SoulLifeFormationPanel:playZhenTitleAct(pos)
    local fadeOut = cc.FadeOut:create(0.2)
    local changeTex = cc.CallFunc:create(function ()
        self:changeTexture("icon_zhen_title", "images/ui_word/soul_zhen" .. pos ..".png")
    end)
    local fadeIn  = cc.FadeIn:create(0.2)
    self:getNode("icon_zhen_title"):runAction(cc.Sequence:create(fadeOut,changeTex,fadeIn))
end

function SoulLifeFormationPanel:processZhenDetailFla(pos, init)
    if init then
        local newFla = gCreateFlaDislpay("ui_soullife_xingzuo_"..pos,1)
        newFla:setAnchorPoint(cc.p(0.5,0.5))
        newFla:setTag(99)
        self:getNode("zhen_detail_container"):addChild(newFla)
    else
        local fadeOutZhen = cc.FadeOut:create(0.2)
        local replaceCall = cc.CallFunc:create(function ()
            self:getNode("zhen_detail_container"):removeChildByTag(99)
            local newFla = gCreateFlaDislpay("ui_soullife_xingzuo_"..pos,1)
            local boudingBox = newFla:getBoundingBox()
            -- print("boudingBox is ", boudingBox.x, boudingBox.y, boudingBox.width,boudingBox.height)
            -- newFla:setAnchorPoint(cc.p(0.5,0.5))
            newFla:setTag(99)
            self:getNode("zhen_detail_container"):addChild(newFla)
        end)
        local fadeInZhen = cc.FadeIn:create(0.2)
        self:getNode("zhen_detail_container"):runAction(cc.Sequence:create(fadeOutZhen,replaceCall,fadeInZhen))
    end
end

function SoulLifeFormationPanel:initPanelAttr()
    local panelZhen = self:getNode("panel_zhen")
    panelZhen:setCascadeOpacityEnabled(true)
    panelZhen:setAllChildCascadeOpacityEnabled(true)

    local panelZhenAttr = self:getNode("panel_zhen_attr")
    panelZhenAttr:setCascadeOpacityEnabled(true)
    panelZhenAttr:setAllChildCascadeOpacityEnabled(true)

    local panelPosDetail = self:getNode("panel_pos_detail")
    panelPosDetail:setCascadeOpacityEnabled(true)
    panelPosDetail:setAllChildCascadeOpacityEnabled(true)

    local panelXunXianType = self:getNode("panel_xunxian_type")
    panelXunXianType:setCascadeOpacityEnabled(true)
    panelXunXianType:setAllChildCascadeOpacityEnabled(true)

    local panelXunXianBtn = self:getNode("panel_xunxian_btn")
    self:getNode("layout_quick_cost"):setVisible(false)
    panelXunXianBtn:setCascadeOpacityEnabled(true)
    panelXunXianBtn:setAllChildCascadeOpacityEnabled(true)

    local panelSoulLife = self:getNode("panel_soullife")
    panelSoulLife:setCascadeOpacityEnabled(true)
    panelSoulLife:setAllChildCascadeOpacityEnabled(true)

    local vipLimit = Data.getCanBuyTimesVip(VIP_SPIRIT_VIOLENCE)
    local lvLimit = DB.getClientParam("SPIRIT_BAOLI_OPEN_LV")
    if (Data.getCurVip() >= vipLimit) or (Data.getCurLevel() >= lvLimit) then
        local choosed = cc.UserDefault:getInstance():getBoolForKey(Data.getCurUserId().."isBaoLi", false)
        if choosed then
            self:changeTexture("check_baoli", "images/ui_public1/n-di-gou2.png")
            self.baoLiFlag = true
            self:updateXunXianCost()
        else
            self:changeTexture("check_baoli", "images/ui_public1/n-di-gou1.png")
            self.baoLiFlag = false
        end
        self:getNode("layer_baoli"):setVisible(true)
    else
        self:getNode("layer_baoli"):setVisible(false)
    end
end

function SoulLifeFormationPanel:canClickFindOrCall()
    if self.isFindingOrCalling or self.quickXunXian then
        return false
    end

    return true
end

function SoulLifeFormationPanel:sortScrollLayer()
    self.scrollLayer:sortItems(function (lItem, rItem)
        if lItem._spirit.iType ~= rItem._spirit.iType then
            return lItem._spirit.iType > rItem._spirit.iType
        else
            if lItem._spirit.iLV ~= rItem._spirit.iLV then
                return lItem._spirit.iLV > rItem._spirit.iLV
            else
                return lItem._spirit.iAttr > rItem._spirit.iAttr
            end
        end
    end)

    self.scrollLayer:layout(false)
end

function SoulLifeFormationPanel:getTheLastIdxOfType(targetSpirit)
    local size = self.scrollLayer:getSize() 
    if size == 0 then
        return -1,-1
    end
    local lastIdx = -1
    local targetIdx = -1
    for i = 1, size do
        local spiritItem = self.scrollLayer:getItem(i - 1)
        if nil ~= spiritItem then
            if spiritItem._spirit.iType > targetSpirit.iType then
                lastIdx = i
            elseif spiritItem._spirit.iType == targetSpirit.iType then
                if spiritItem._spirit.iLV >= DB.getSpiritMaxLev() and  spiritItem._spirit.iID ~= targetSpirit.iID then
                    lastIdx = i
                elseif spiritItem._spirit.iID == targetSpirit.iID then
                    targetIdx = i
                end
            end
        end
    end

    return lastIdx,targetIdx
end

function SoulLifeFormationPanel:switchEquSoulLifePos(param)
    -- {equPos1=pos1,equPos2=pos2, spiritObj=spirit}
    -- 更新已装备的合魂信息
    local changeIdx= SpiritInfo.getSpiritIndexWithPos(param.equPos2)
    local changeSpirit = SpiritInfo.getSpiritByIdx(changeIdx)
    local beRepaceIdx = SpiritInfo.getSpiritIndexWithPos(param.equPos1)
    changeSpirit.iPos = param.equPos1
    if -1 ~= beRepaceIdx then
        local beRepaceSpirit = SpiritInfo.getSpiritByIdx(beRepaceIdx)
        beRepaceSpirit.iPos = 0
        SpiritInfo.setSpiritItemByIdx(beRepaceIdx, changeSpirit)
    else
        SpiritInfo.addSpiritItem(changeSpirit)
    end
    SpiritInfo.removeSpiritByIdx(changeIdx)

    if nil ~= changeSpirit then
        local soulLifePos = changeSpirit.iPos % 10
        self.equipSoulLifes[soulLifePos] = changeSpirit
        Icon.setSpiritIcon(changeSpirit.iType, self:getNode("icon_soullife".. soulLifePos))
        local addLv = DB.getSpiritAddLevByPos(soulLifePos)
        self:setZhenIconLv(changeSpirit.iLV,addLv,soulLifePos)
        -- self:getNode("lab_lv"..soulLifePos):setVisible(true)
        self:getNode("layout_lv"..soulLifePos):setVisible(true)
        self:getNode("layer_spirit_name"..soulLifePos):setVisible(true)
        self:getNode("spirit_name".. soulLifePos):setString(gGetSpiritAttrNameByType(changeSpirit.iType, changeSpirit.iAttr))
        self:getNode("spirit_name".. soulLifePos):setColor(gCreateSpiritNameColor(changeSpirit.iType))
        self:getNode("spirit_name".. soulLifePos):setVisible(true)
        
        --同一个阵位
        if math.floor(param.equPos1 / 10) == math.floor(param.equPos2 / 10) then
            local emptyPos = param.equPos2 % 10
            self.equipSoulLifes[emptyPos] = nil
            -- self:getNode("lab_lv"..emptyPos):setVisible(false)
            self:getNode("layout_lv"..emptyPos):setVisible(false)
            self:getNode("layer_spirit_name"..emptyPos):setVisible(false)
            self:getNode("icon_soullife"..emptyPos):removeChildByTag(1)
        end

        self:showSpiritAttr()
    end

    --更新背包及显示
    if nil ~= param.spiritObj then
        SpiritInfo.addBagSpiritItem(param.spiritObj)
        local spiritItem = XunXianItem.new(param.spiritObj, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, self.scrollLayer:getSize() + 1, true)
        if nil ~= spiritItem then
            spiritItem.onChoosed = function(item)
                if not self.isFindingOrCalling then
                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, param.spiritObj, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                end
            end
        end
        spiritItem:setItem()
        self.scrollLayer:addItem(spiritItem)
        self.scrollLayer:layout(false)
        self:updateBagNum()
    end
    self:checkUnlockPosEqu()
end

function SoulLifeFormationPanel:quickXunXianCircleAction(doing)
    if doing then
        self:getNode("icon_circle"):resume()
    else
        self:getNode("icon_circle"):pause()
    end
end

function SoulLifeFormationPanel:createSoulLifeRoleFla(pos, status)
    local npcPos = self:getNode("soullife_type_role" .. pos)
    if nil ~= npcPos then
        npcPos:removeAllChildren()
        if pos == SPIRIT_TYPE.TIAN then
            local aniName = string.format("xian_npc%d_%d", pos + 1, status)
            local fla = gCreateFla(aniName, 1)
            gAddChildInCenterPos(npcPos, fla)
        else
            local aniName = string.format("xian_npc%d_%d", 1, status)
            local fla = gCreateFla(aniName, 1)
            if pos ~= SPIRIT_TYPE.GUI then
                if status == SoulLifeRoleStatus.no_choosed then
                    fla:replaceBone({"shell"}, string.format("images/ui_soullife/xian_npc%d_1.png", pos + 1))
                elseif status == SoulLifeRoleStatus.choosed then
                    fla:replaceBone({"shell"},string.format("images/ui_soullife/xian_npc%d_1.png", pos + 1))
                    fla:replaceBone({"head"},string.format("images/ui_soullife/xian_npc%d_2.png", pos + 1))
                    fla:replaceBone({"foot_3"},string.format("images/ui_soullife/xian_npc%d_3.png", pos + 1))
                    fla:replaceBone({"foot_30"},string.format("images/ui_soullife/xian_npc%d_3.png", pos + 1))
                    fla:replaceBone({"foot_31"},string.format("images/ui_soullife/xian_npc%d_3.png", pos + 1))
                end
            end
            gAddChildInCenterPos(npcPos, fla)
        end
    end
end

function SoulLifeFormationPanel:initRoleChoosingActTime()
    local tianRoleFla = FlashAni.new()
    self.tianRoleChoosingActTime = tianRoleFla:playAction(string.format("xian_npc%d_%d", SPIRIT_TYPE.TIAN + 1, SoulLifeRoleStatus.choosing))
    local otherRoleFla = FlashAni.new()
    self.otherRoleChoosingActTime = otherRoleFla:playAction(string.format("xian_npc%d_%d", 1, SoulLifeRoleStatus.choosing))
end

function SoulLifeFormationPanel:getRealRoleChoosingActTime(spiritType)
    local roleChoosingActTime = 0
    if spiritType ~= SPIRIT_TYPE.TIAN then
        roleChoosingActTime = self.otherRoleChoosingActTime
    else
        roleChoosingActTime = self.tianRoleChoosingActTime 
    end

    if not self.hasManySpiritsInFinding then
        roleChoosingActTime = roleChoosingActTime * 0.5
    elseif self.quickXunXian then
        roleChoosingActTime = roleChoosingActTime * 0.1
    else
        roleChoosingActTime = roleChoosingActTime * 0.3
    end 

    return roleChoosingActTime
end
--检查是否有空位没有装配命魂
function SoulLifeFormationPanel:checkUnlockPosEqu()
    local hasEmpty = false
    local posUnlock = false
    local openLev = 0
    local openVip = 0
    local curPos = 0
    local isOpen = false
    local equSoulLifeStartLev = DB.getSpiritStartLev()
    local equSoulLifeStartVip = DB.getSpiritStartVip()
    for i = 1, 6 do
        if hasEmpty then
            break
        end
        for j = 1, self.soulLifesNum do
            --没有锁住，并且没有放入命魂
            posUnlock = false
            openLev = equSoulLifeStartLev[j]
            openVip = equSoulLifeStartVip[j]
            curPos = (i-1) * 10 + j
            isOpen  = SpiritInfo.isPosOpen(curPos)
            
            if Data.getCurLevel() >= openLev or 
                ((openVip ~= 0 and Data.getCurVip() >= openVip)) then
                posUnlock = true
            end

            if j > 6 then
                posUnlock = isOpen
            end

            if posUnlock then
                local spirit = SpiritInfo.getSpiritWithPos(curPos)
                if nil == spirit then
                    hasEmpty = true
                    break
                end
            end
        end
    end

    if hasEmpty then
        Data.redpos.spirit = true
    else
        Data.redpos.spirit = false
    end
end

function SoulLifeFormationPanel:initChildrenPanel()
    if self.panelType == soulLifePanelType.xunxian then
        local panelZhen = self:getNode("panel_zhen")
        local x,y = panelZhen:getPosition()
        panelZhen:setVisible(false)
        panelZhen:setPosition(x+100,y)
        local panelZhenAttr = self:getNode("panel_zhen_attr")
        x,y = panelZhenAttr:getPosition()
        panelZhenAttr:setPosition(x,y - 100)
        panelZhenAttr:setVisible(false)
        local panelPosDetail = self:getNode("panel_pos_detail")
        for i = 1, 8 do
            local detailNode = self:getNode("icon_soullife" .. i)
            local rotationPos = detailNode:getRotation3D()
            rotationPos.y = rotationPos.y + 90
            detailNode:setRotation3D(rotationPos)
        end

        panelPosDetail:setVisible(false)
        local panelXunXianType = self:getNode("panel_xunxian_type")
        panelXunXianType:setVisible(true)
        local panelXunXianBtn = self:getNode("panel_xunxian_btn")
        panelXunXianBtn:setVisible(true)
        local panelSoulLife = self:getNode("panel_soullife")
        panelSoulLife:setVisible(true)
        self:playSwitchFla("ui_soullife_qiehuan2", true)
    else
        self:playSwitchFla("ui_soullife_qiehuan1", true)
    end
end

function SoulLifeFormationPanel:setQuickFindRoleStatus()
    for i = 0, 4 do
        self:createSoulLifeRoleFla(i,SoulLifeRoleStatus.choosed)        
    end

    local size = SpiritInfo.getFindSpiritSize()
    if size > 0 then
        self.isFindingOrCalling = true
        self.scrollLayer:setTouchEnable(false)
        self:setMainLayerTouchEnable(false)
        local showFindDelay = 0
        -- self.scrollLayer:moveItemByIndex(self.scrollLayer:getSize())
        self.scrollLayer:moveItemByIndex(0)
        self.hasManySpiritsInFinding  = SpiritInfo.hasManySpiritInFindSpirit()
        local roleActTime = 0
        for i = 1, size do
            local spirit = SpiritInfo.getFindSpiritByIdx(i)
            if nil ~= spirit then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay), cc.CallFunc:create(self.processQuickTypeFindAction, {self, spirit})))
                roleActTime = self:getRealRoleChoosingActTime(spirit.iFType)
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay + roleActTime), cc.CallFunc:create(self.processQuickSpiritAction, {self, spirit})))
                showFindDelay = showFindDelay + 0.1 + roleActTime

                if spirit.iType == SPIRIT_TYPE.CHIP or spirit.iType == SPIRIT_TYPE.TIAN then
                    self.findBreak = true
                    self.findBreakIdx = i
                    self.findBreakType = spirit.iType
                    break
                end

                --最后一个
                if i == size then
                    self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay) , cc.CallFunc:create(function()
                        self:updateFindType()
                    end)))
                end
            end
        end
    end
end

function SoulLifeFormationPanel.processQuickTypeFindAction(node,paramTable)
    if paramTable[2].iFType <= SPIRIT_TYPE.TIAN then
        paramTable[1].oldSpiritType = paramTable[1].spiritType
        paramTable[1].spiritType = paramTable[2].iFType
        if paramTable[1].oldSpiritType ~= paramTable[1].spiritType then
            paramTable[1]:createSoulLifeRoleFla(paramTable[1].oldSpiritType , SoulLifeRoleStatus.choosed)
        end
        local fla = FlashAni.new()
        if paramTable[1].spiritType == SPIRIT_TYPE.TIAN then
            fla:playAction(string.format("xian_npc%d_%d",paramTable[1].spiritType + 1, SoulLifeRoleStatus.choosing),function ()
                paramTable[1]:createSoulLifeRoleFla(paramTable[1].spiritType, SoulLifeRoleStatus.choosed)
            end,nil, 1)
        else
            fla:playAction(string.format("xian_npc%d_%d",paramTable[1].spiritType + 1, SoulLifeRoleStatus.choosing),function ()
                paramTable[1]:createSoulLifeRoleFla(paramTable[1].spiritType, SoulLifeRoleStatus.choosed)
            end,nil, 1)
        end
        fla:setSpeedScale(5)
        paramTable[1]:getNode("soullife_type_role" .. paramTable[2].iFType):removeAllChildren()
        gAddChildInCenterPos(paramTable[1]:getNode("soullife_type_role" .. paramTable[2].iFType), fla)
    end
end

function SoulLifeFormationPanel.processQuickSpiritAction(node, paramTable)
    local self = paramTable[1]
    local spirit = paramTable[2]
    local delayTime = 0
    if spirit.iType == SPIRIT_TYPE.GOLD then
        -- delayTime = delayTime + 0.1
        -- local item={}
        -- item.id  = OPEN_BOX_GOLD
        -- item.num = spirit.iValue
        -- gShowItemPoolLayer:pushItems({item})
        -- delayTime = delayTime + 1
        local flyTime = 0.1 --图标飞的时间
        self.scrollLayer:moveItemByIndex(0)
        local spiritIcon = cc.Sprite:create(string.format("images/ui_soullife/soul_%d.png", SPIRIT_TYPE.EXP))
        spiritIcon:setScale(1.2)
        spiritIcon:setAnchorPoint(cc.p(0.5, 0.5))
        spiritIcon:setVisible(false)
        local spiritTypePos = self:getNode("soullife_type_role"..self.spiritType)
        local worldPos = self:getNode("panel_xunxian_type"):convertToWorldSpace(cc.p(spiritTypePos:getPosition()))
        local nodePos   = self:convertToNodeSpace(worldPos)
        spiritIcon:setPosition(nodePos)
        self:addChild(spiritIcon,99)

        local itemBg = self.scrollLayer:getItem(0):getNode("icon_bg")
        local moveToWorldPos = self.scrollLayer:getItem(0):convertToWorldSpace(cc.p(itemBg:getPosition()))
        local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
        local moveTo = cc.MoveTo:create(flyTime, moveToNodPos)
        spiritIcon:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Show:create(), moveTo, cc.CallFunc:create(function ()
            spiritIcon:removeFromParent()
            local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
            local expItem   = self.scrollLayer:getItem(0)
            SpiritInfo.exp = SpiritInfo.exp + spirit.iValue
            expItem:updateExpLab()
        end)))

    elseif spirit.iType == SPIRIT_TYPE.CHIP then -- 碎片
        -- delayTime = delayTime + 0.1
        -- local item={}
        -- item.id  = ID_SPIRIT_FRAGMENT
        -- item.num = 1
        -- gShowItemPoolLayer:pushItems({item})
        -- delayTime = delayTime + 1.0
        -- SpiritInfo.addFra(1)
        -- --更新碎片数量
        -- self:updateSoulLifeFragValue(SpiritInfo.getFraCount())
        self:getNode("panel_break_bg"):setVisible(true)
        local ret = self:createFindFraOrTianFla(SPIRIT_TYPE.CHIP)
        local delayTime = cc.DelayTime:create(1)
        ret:runAction(cc.Sequence:create(delayTime,cc.CallFunc:create(function ()
            ret:removeFromParent()
            self:getNode("panel_break_bg"):setVisible(false)
            self.findBreak = false
            self:continueFindAction()
        end)))
    else --命魂
        local flyTime = 0.1 --图标飞的时间
        --飞到第一个
        if spirit.iType <= self.quickChooseType then
            self.scrollLayer:moveItemByIndex(0)
            local spiritIcon = cc.Sprite:create(string.format("images/ui_soullife/soul_%d.png", spirit.iType + 1))
            spiritIcon:setScale(1.2)
            spiritIcon:setAnchorPoint(cc.p(0.5, 0.5))
            spiritIcon:setVisible(false)
            local spiritTypePos = self:getNode("soullife_type_role"..self.spiritType)
            local worldPos = self:getNode("panel_xunxian_type"):convertToWorldSpace(cc.p(spiritTypePos:getPosition()))
            local nodePos   = self:convertToNodeSpace(worldPos)
            spiritIcon:setPosition(nodePos)
            self:addChild(spiritIcon,99)

            local itemBg = self.scrollLayer:getItem(0):getNode("icon_bg")
            local moveToWorldPos = self.scrollLayer:getItem(0):convertToWorldSpace(cc.p(itemBg:getPosition()))
            local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
            local moveTo = cc.MoveTo:create(flyTime, moveToNodPos)
            spiritIcon:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Show:create(), moveTo, cc.CallFunc:create(function ()
                spiritIcon:removeFromParent()
                local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
                local expItem   = self.scrollLayer:getItem(0)
                SpiritInfo.exp = SpiritInfo.exp + spirit.iExp + baseExp
                expItem:updateExpLab()
            end)))
        elseif spirit.iType == SPIRIT_TYPE.TIAN then
            self:getNode("panel_break_bg"):setVisible(true)
            local tianSpirit = self:createFindFraOrTianFla(SPIRIT_TYPE.TIAN)
            local delayTime = cc.DelayTime:create(1)
            tianSpirit:runAction(cc.Sequence:create(delayTime,cc.CallFunc:create(function ()
                tianSpirit:removeFromParent()
                self:getNode("panel_break_bg"):setVisible(false)
                self.findBreak = false
                self:continueFindAction()
            end)))
        else
            self.scrollLayer:moveItemByIndex(0)
            local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, 2, true)
            if nil ~= spiritItem then
                spiritItem.onChoosed = function(item)
                    if not self.isFindingOrCalling then
                        Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                    end
                end
                spiritItem:setItem()
                self.scrollLayer:addItem(spiritItem,1)
                self.scrollLayer:layout()
                spiritItem:setOpacity(0)
                -- self.scrollLayer:moveItemByIndex(self.scrollLayer:getSize() - 1)
                spiritItem:runAction(cc.Sequence:create(cc.DelayTime:create(flyTime + delayTime), cc.FadeIn:create(0.5)))
            end

            local spiritIcon = cc.Sprite:create(string.format("images/ui_soullife/soul_%d.png", spirit.iType + 1))
            spiritIcon:setScale(1.2)
            spiritIcon:setAnchorPoint(cc.p(0.5, 0.5))
            spiritIcon:setVisible(false)
            local spiritTypePos = self:getNode("soullife_type_role"..self.spiritType)
            local worldPos = self:getNode("panel_xunxian_type"):convertToWorldSpace(cc.p(spiritTypePos:getPosition()))
            local nodePos   = self:convertToNodeSpace(worldPos)
            spiritIcon:setPosition(nodePos)
            self:addChild(spiritIcon,99)

            local itemBg = spiritItem:getNode("icon_bg")
            local moveToWorldPos = spiritItem:convertToWorldSpace(cc.p(itemBg:getPosition()))
            local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
            local moveTo = cc.MoveTo:create(flyTime, moveToNodPos)
            spiritIcon:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.Show:create(), moveTo, cc.CallFunc:create(function ()
                spiritIcon:removeFromParent()
            end)))
        end
    end
end

function SoulLifeFormationPanel:initExpItem()

    local spirit = gCreateSpirit(0, SPIRIT_TYPE.EXP, 0, 0, 0, 0, 0, 0)
    local expItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, 1, false)
    if nil ~= expItem then
        expItem.onChoosed = function(item)
            if not self.isFindingOrCalling then
                Panel.popUpVisible(PANEL_SOULLIFE_UPGRADE, nil, SOULLIFE_UPGRADE_TYPE.POOL, true)
            end
        end
        expItem:setItem()
        return expItem
    end

    return nil  
end

function SoulLifeFormationPanel:updateChExp()
    local expItem = self.scrollLayer:getItem(0)
    if nil ~= expItem then
        --TODO,更新动画表现
        expItem:updateExpLab()
    end
    self:removeAutoChExpSpirit()
    SpiritInfo.clearFindSpiritList()
    self:updateBagNum()
    if self.isStopQuicking then
        self:processStopQuickXunXian()
    elseif self:isQuickCostEnough() then
        if self.quickXunXian then
            Net.sendSpiritFindNew()
        end
    end
end

function SoulLifeFormationPanel:autoChExp()
    local size = SpiritInfo.getFindSpiritSize()
    self.autoChExpList = {}
    for i = 1, size do
        local spirit = SpiritInfo.getFindSpiritByIdx(i)
        if nil ~= spirit and spirit.iPos == 0 and spirit.iType <= self.quickChooseType then
            table.insert(self.autoChExpList, spirit.iID)
        end
    end

    if #self.autoChExpList > 0 then
        Net.sendSpiritChExp(self.autoChExpList)
    elseif self.isStopQuicking then
        self:processStopQuickXunXian()
    elseif self:isQuickCostEnough() then
        if self.quickXunXian then
            Net.sendSpiritFindNew()
        end 
    end
end

function SoulLifeFormationPanel:removeAutoChExpSpirit()
    if nil == self.autoChExpList or #self.autoChExpList == 0 then
        return
    end

    for i = 1, #self.autoChExpList do
        SpiritInfo.removeBagSpiritByID(self.autoChExpList[i])
    end

    self.autoChExpList = {}
end

function SoulLifeFormationPanel:updateQuickCost(quickCost)
    self:setLabelString("txt_quick_cost", quickCost)
    self:getNode("layout_quick_cost"):layout()
    self:getNode("layout_quick_cost"):setVisible(true)
end

function SoulLifeFormationPanel:isQuickCostEnough()
    if SpiritInfo.quickCostGold <= 0 or SpiritInfo.checkSpiritExpFull() or 
        (Data.getCurLevel() < DB.getSpiritOneKeyLev() and gIsVipExperTimeOver(VIP_SPIRIT_QUICK)) then
        self:stopingQuickXunXian()
        self:processStopQuickXunXian()
        return false
    end
    return true
end

function SoulLifeFormationPanel:updateSpiritByInject()
    -- SpiritInfo.sortSpiritBagList()
    self:setScrollSoulLifes()
end

function SoulLifeFormationPanel:resetRoleStatusAfterQuick()
    for i = 0, 4 do
        if i == self.spiritType then
            self:createSoulLifeRoleFla(i,SoulLifeRoleStatus.choosed)
        else
            self:createSoulLifeRoleFla(i,SoulLifeRoleStatus.no_choosed)
        end
    end
end

function SoulLifeFormationPanel:continueFindAction()
    if self.findBreakIdx == 0 then
        return
    end
    print("SoulLifeFormationPanel:continueFindAction")
    local showFindDelay = self:breakFinalAction()

    local findSize = SpiritInfo.getFindSpiritSize()
    --已经是最后一个了
    if self.findBreakIdx == findSize then
        self:updateFindType()
        return
    end

    for i = self.findBreakIdx + 1, findSize do
        local spirit = SpiritInfo.getFindSpiritByIdx(i)
        if nil ~= spirit then
            local roleActTime = self:getRealRoleChoosingActTime(spirit.iFType)
            if self.quickXunXian then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay), cc.CallFunc:create(self.processQuickTypeFindAction, {self, spirit})))
                roleActTime = self:getRealRoleChoosingActTime(spirit.iFType)
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay + roleActTime), cc.CallFunc:create(self.processQuickSpiritAction, {self, spirit})))
                showFindDelay = showFindDelay + 0.1 + roleActTime
            else
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay), cc.CallFunc:create(self.processTypeFindAction, {self, spirit})))
                roleActTime = self:getRealRoleChoosingActTime(spirit.iFType)
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay + roleActTime), cc.CallFunc:create(self.processSpiritAction, {self, spirit})))
            end
            
            if spirit.iType == SPIRIT_TYPE.CHIP or spirit.iType == SPIRIT_TYPE.TIAN or spirit.iID == ITEM_SPIRIT_BUY then
                self.findBreak = true
                self.findBreakIdx = i
                if spirit.iID == ITEM_SPIRIT_BUY then
                    self.findBreakType = ITEM_SPIRIT_BUY
                else
                    self.findBreakType = spirit.iType
                end
                break
            end

            showFindDelay = showFindDelay + 0.2 + roleActTime
            --最后一个
            if i == findSize then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(showFindDelay) , cc.CallFunc:create(function()
                    self:updateFindType()
                end)))
            end
        end
    end
end

function SoulLifeFormationPanel:breakFinalAction()
    if self.findBreakType == nil then
        return 0
    end
    local showTime = 0
    if self.findBreakType == SPIRIT_TYPE.CHIP then
        local fraIcon = cc.Sprite:create("images/ui_soullife/soul_fra.png")
        fraIcon:setScale(1.5)
        self:addChild(fraIcon, 999, 999)
        fraIcon:setPositionY(-self:getNode("panel_break_bg"):getContentSize().height/2)
        fraIcon:setPositionX(self:getNode("panel_break_bg"):getContentSize().width/2)
        if gMainMoneyLayer ~= nil then
            local btnEng = gMainMoneyLayer:getNode("btn_eng")
            local moveToWorldPos = gMainMoneyLayer:getNode("layer_eng"):convertToWorldSpace(cc.p(btnEng:getPosition()))
            local moveToNodPos = self:convertToNodeSpace(moveToWorldPos)
            fraIcon:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, moveToNodPos),cc.CallFunc:create(function()
                fraIcon:removeFromParent()
                SpiritInfo.addFra(1)
                self:updateSoulLifeFragValue(SpiritInfo.getFraCount())
            end)))
            showTime = 0.1
        else
            SpiritInfo.addFra(1)
            self:updateSoulLifeFragValue(SpiritInfo.getFraCount())
        end
    elseif self.findBreakType == ITEM_SPIRIT_BUY then
        local itemIcon = cc.Sprite:create("images/icon/item/130.png")
        itemIcon:setScale(1.5)
        self:addChild(itemIcon, 999, 999)
        itemIcon:setPositionY(-self:getNode("panel_break_bg"):getContentSize().height/2)
        itemIcon:setPositionX(self:getNode("panel_break_bg"):getContentSize().width/2)
        if gMainMoneyLayer ~= nil then
            local btnEng = gMainMoneyLayer:getNode("btn_spirit_buy_item")
            local moveToWorldPos = gMainMoneyLayer:getNode("layer_spirit_buy_item"):convertToWorldSpace(cc.p(btnEng:getPosition()))
            local moveToNodPos = self:convertToNodeSpace(moveToWorldPos)
            itemIcon:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, moveToNodPos),cc.CallFunc:create(function()
                itemIcon:removeFromParent()
                Data.addItemNum(ITEM_SPIRIT_BUY,1)
                gMainMoneyLayer:refreshSpiritBuyItem()
            end)))
            showTime = 0.1
        end
    elseif self.findBreakType == SPIRIT_TYPE.TIAN then
        showTime = 0.1
        local spirit = SpiritInfo.getFindSpiritByIdx(self.findBreakIdx)
        local spiritItem = nil 
        if self.quickXunXian then
            spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, 2, true)
        else
            spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, self.scrollLayer:getSize(), true)
        end

        if nil ~= spiritItem then
            spiritItem.onChoosed = function(item)
                if not self.isFindingOrCalling then
                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                end
            end
            spiritItem:setItem()
            spiritItem:setOpacity(0)
            if self.quickXunXian then
                self.scrollLayer:addItem(spiritItem,1)
                self.scrollLayer:layout()
            else
                self.scrollLayer:addItem(spiritItem)
                self.scrollLayer:layout()
                self.scrollLayer:moveItemByIndex(self.scrollLayer:getSize() - 1)
            end
            spiritItem:runAction(cc.Sequence:create(cc.DelayTime:create(showTime), cc.FadeIn:create(0.5)))
        end

        local tianIcon = cc.Sprite:create("images/ui_soullife/soul_5.png")
        tianIcon:setScale(1.2)
        self:addChild(tianIcon, 999, 999)
        tianIcon:setPositionY(-self:getNode("panel_break_bg"):getContentSize().height/2)
        tianIcon:setPositionX(self:getNode("panel_break_bg"):getContentSize().width/2)

        local itemBg = spiritItem:getNode("icon_bg")
        local moveToWorldPos = spiritItem:convertToWorldSpace(cc.p(itemBg:getPosition()))
        local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
        local moveTo = cc.MoveTo:create(showTime, moveToNodPos)
        tianIcon:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(function ()
            tianIcon:removeFromParent()
        end)))
    end

    return showTime
end

function SoulLifeFormationPanel:updateUpgradeSpiritInfo(param)
    if Net.upgradeNewInfo.id ~= nil then
        local spirit = SpiritInfo.getBagSpiritById(Net.upgradeNewInfo.id )
        if nil ~= spirit then
            local size = self.scrollLayer:getSize() 
            for i = 1, size do
                local spiritItem = self.scrollLayer:getItem(i - 1)
                if nil ~= spiritItem then
                    if spiritItem._spirit.iID == spirit.iID then
                        spiritItem:setLabelString("lab_lv", param.lev)
                        if spirit.iLV ~= param.lev or spirit.iExp ~= param.curExp then
                            SpiritInfo.updateSpiritExpAndLvByPool(param)
                        end
                        break
                    end
                end
            end
        end
    elseif Net.upgradeNewInfo.pos ~= nil then
        local spirit = SpiritInfo.getSpiritWithPos(Net.upgradeNewInfo.pos)
        if nil ~= spirit then
            local soulLifePos = Net.upgradeNewInfo.pos % 10
            local addLv = DB.getSpiritAddLevByPos(soulLifePos)
            self:setZhenIconLv(param.lev,addLv,soulLifePos)
            self.equipSoulLifes[soulLifePos].iLV = param.lev
            if spirit.iLV ~= param.lev or spirit.iExp ~= param.curExp then
                SpiritInfo.updateSpiritExpAndLvByPool(param)
            end
        end
    end
end

function SoulLifeFormationPanel:createFindFraOrTianFla(type)
    local fla = gCreateFla("ui_minghun_huode")
    local replaceNode = nil
    if type == SPIRIT_TYPE.TIAN then
        replaceNode = cc.Sprite:create("images/ui_soullife/soul_5_2.png")
    elseif type == ITEM_SPIRIT_BUY then
        replaceNode = cc.Sprite:create("images/icon/item/130.png")
    else
        replaceNode = cc.Sprite:create("images/ui_soullife/soul_fra.png")
    end
    fla:replaceBoneWithNode({"icon"}, replaceNode)
    self:getNode("panel_break_bg"):addChild(fla,999,999)
    fla:setPositionY(self:getNode("panel_break_bg"):getContentSize().height/2)
    fla:setPositionX(self:getNode("panel_break_bg"):getContentSize().width/2)
    return fla
end

function SoulLifeFormationPanel:processBaoLi(param)
    SpiritInfo.exp = param.exp
    self.scrollLayer:getItem(0):updateExpLab()
    local itemSize = #param.items
    if itemSize > 0 then
        self.doingBaoLi = true
        self.scrollLayer:moveItemByIndex(0)
        local spiritItem = nil
        local showTime = 0.1
        local delayTimeInterval = 0.0
        for i = 1, itemSize do
            local spirit = param.items[i]
            if nil ~= spirit then
                if spirit.iType == SPIRIT_TYPE.CHIP then
                    local fraIcon = nil
                    local delayTime1 = cc.DelayTime:create(delayTimeInterval)
                    local callFunc1 = cc.CallFunc:create(function()
                            self:getNode("panel_break_bg"):setVisible(true)
                            fraIcon = self:createFindFraOrTianFla(SPIRIT_TYPE.CHIP)
                        end)
                    local delayTime2 = cc.DelayTime:create(0.5)
                    local callFunc2 = cc.CallFunc:create(function()
                        if gMainMoneyLayer ~= nil then
                            local btnEng = gMainMoneyLayer:getNode("btn_eng")
                            local moveToWorldPos = gMainMoneyLayer:getNode("btn_get_energy"):convertToWorldSpace(cc.p(btnEng:getPosition()))
                            local moveToNodPos = self:getNode("panel_break_bg"):convertToNodeSpace(moveToWorldPos)
                            fraIcon:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, moveToNodPos),cc.CallFunc:create(function()
                                fraIcon:removeFromParent()
                                SpiritInfo.addFra(spirit.iValue)
                                self:updateSoulLifeFragValue(SpiritInfo.getFraCount())
                                self:getNode("panel_break_bg"):setVisible(false)
                            end)))
                        else
                            SpiritInfo.addFra(spirit.iValue)
                            self:updateSoulLifeFragValue(SpiritInfo.getFraCount())
                            self:getNode("panel_break_bg"):setVisible(false)
                        end

                        if i == itemSize then
                            self.doingBaoLi = false
                        end
                    end)
                    delayTimeInterval = delayTimeInterval + 0.8
                    self:runAction(cc.Sequence:create(delayTime1,callFunc1,delayTime2,callFunc2))
                elseif spirit.iType == SPIRIT_TYPE.TIAN then
                    local tianIcon = nil
                    local delayTime1 = cc.DelayTime:create(delayTimeInterval)
                    local callFunc1 = cc.CallFunc:create(function()
                            self:getNode("panel_break_bg"):setVisible(true)
                            tianIcon = self:createFindFraOrTianFla(SPIRIT_TYPE.TIAN)
                        end)
                    local delayTime2 = cc.DelayTime:create(0.5)
                    local callFunc2  = cc.CallFunc:create(function ()
                        SpiritInfo.addBagSpiritItem(spirit)
                        self:updateBagNum()
                        local spiritItem = nil 
                        spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, 2, true)
                        if nil ~= spiritItem then
                            spiritItem.onChoosed = function(item)
                                if (not self.isFindingOrCalling) or (not self.doingBaoLi) then
                                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                                end
                            end
                            spiritItem:setItem()
                            spiritItem:setOpacity(0)
                            self.scrollLayer:addItem(spiritItem,1)
                            self.scrollLayer:layout()
                            spiritItem:runAction(cc.FadeIn:create(0.1))
                        end
                        local itemBg = spiritItem:getNode("icon_bg")
                        local moveToWorldPos = spiritItem:convertToWorldSpace(cc.p(itemBg:getPosition()))
                        local moveToNodPos   = self:getNode("panel_break_bg"):convertToNodeSpace(moveToWorldPos)
                        local moveTo = cc.MoveTo:create(showTime, moveToNodPos)
                        tianIcon:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(function ()
                            tianIcon:removeFromParent()
                            self:getNode("panel_break_bg"):setVisible(false)
                        end)))
                        if i == itemSize then
                            self.doingBaoLi = false
                        end
                    end)
                    delayTimeInterval = delayTimeInterval + 0.8
                    self:runAction(cc.Sequence:create(delayTime1,callFunc1,delayTime2,callFunc2))
                else
                    local delayTime = cc.DelayTime:create(delayTimeInterval)
                    local callFunc = cc.CallFunc:create(function()
                        SpiritInfo.addBagSpiritItem(spirit)
                        self:updateBagNum()
                        spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, 2, true)
                        if nil ~= spiritItem then
                            spiritItem.onChoosed = function(item)
                                if (not self.isFindingOrCalling) and (not self.doingBaoLi) then
                                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                                end
                            end
                            spiritItem:setItem()
                            self.scrollLayer:addItem(spiritItem,1)
                            self.scrollLayer:layout()
                        end

                        if i == itemSize then
                            self.doingBaoLi = false
                        end
                    end)
                    self:runAction(cc.Sequence:create(delayTime,callFunc))
                end 
            end
        end
    end
end

function SoulLifeFormationPanel:processBaoLiEx(param)
    local baoliRewardPanel = Panel.getOpenPanel(PANEL_SOULLIFE_BAOLI_REWARD)
    if nil == baoliRewardPanel then
        Panel.popUp(PANEL_SOULLIFE_BAOLI_REWARD,self,param)
    else
        baoliRewardPanel:updateData(param)
    end
end

function SoulLifeFormationPanel:updateBaoLiResult(param)
    SpiritInfo.exp = param.exp
    self.scrollLayer:getItem(0):updateExpLab()
    local itemSize = #param.items
    self.scrollLayer:moveItemByIndex(0)
    local spiritItem = nil
    local hasAdd = false
    for _, spirit in pairs(param.items) do
        if spirit.iType == SPIRIT_TYPE.CHIP then
            SpiritInfo.addFra(spirit.iValue)
            self:updateSoulLifeFragValue(SpiritInfo.getFraCount())
        elseif spirit.iType ~= SPIRIT_TYPE.EXP then
            SpiritInfo.addBagSpiritItem(spirit)
            self:updateBagNum()
            spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, 2, true)
            if nil ~= spiritItem then
                spiritItem.onChoosed = function(item)
                    if (not self.isFindingOrCalling) and (not self.doingBaoLi) then
                        Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, spirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                    end
                end
                spiritItem:setItem()
                self.scrollLayer:addItem(spiritItem,1)
                self.scrollLayer:layout()
            end
        end
    end
end

function SoulLifeFormationPanel:setSoulLifeIcon()
    local equSoulLifeStartLev = DB.getSpiritStartLev()
    local equSoulLifeStartVip = DB.getSpiritStartVip()
    local curChooseIdx = self.chooseIdx
    self.posUnlock = {}
    for i = 1, self.soulLifesNum do
        self.posUnlock[i] = false
        local openLev = equSoulLifeStartLev[i]
        local openVip = equSoulLifeStartVip[i]
        local curPos  = self.chooseIdx * 10 + i
        local isOpen  = SpiritInfo.isPosOpen(curPos)
        
        if Data.getCurLevel() >= openLev or 
            ((openVip ~= 0 and Data.getCurVip() >= openVip)) then
            self.posUnlock[i] = true
        end

        if i > 6 then
            if Module.isClose(SWITCH_SPIRIT_EXTRA) then
                self.posUnlock[i] = false
            else
                self.posUnlock[i] = isOpen
            end
        end

        if not self.posUnlock[i] then
            -- self:getNode("lab_lv" .. i):setVisible(false)
            self:getNode("layout_lv"..i):setVisible(false)
            self:getNode("icon_lock" .. i):setVisible(true)
            self:getNode("spirit_name" .. i):setVisible(false)
            self:getNode("layer_spirit_name"..i):setVisible(false)
            local txtOpenLv = self:getNode("txt_open_lv" .. i)
            if Module.isClose(SWITCH_SPIRIT_EXTRA) and (i > 6) then
                txtOpenLv:setString(gGetWords("spiritWord.plist", "spirit_forbid_vp"))
            elseif not Module.isClose(SWITCH_VIP) then
                if (openVip ~= 0 and Data.getCurVip() >= openVip) or Data.getCurLevel() >= openLev then
                    txtOpenLv:setString(gGetWords("spiritWord.plist", "spirit_pos_can_open"))
                elseif openVip == 0 then
                    txtOpenLv:setString(gGetWords("spiritWord.plist", "zhen_pos_open_lev", openLev))
                else
                    txtOpenLv:setString(gGetWords("spiritWord.plist", "zhen_pos_open_lev_and_vip", openVip, openLev))
                end
            else
                if openVip ~= 0 then
                    txtOpenLv:setString(gGetWords("spiritWord.plist", "spirit_forbid_vp"))
                else
                    txtOpenLv:setString(gGetWords("spiritWord.plist", "zhen_pos_open_lev", openLev))
                end
            end
            
            txtOpenLv:setVisible(true)
        else
            -- self:getNode("icon_soullife"..i):removeChildByTag(1)
            self:getNode("txt_open_lv" .. i):setVisible(false)
            -- self:getNode("lab_lv" .. i):setVisible(true)
            self:getNode("layout_lv"..i):setVisible(true)
            self:getNode("icon_lock" .. i):setVisible(false)
            self:getNode("spirit_name" .. i):setVisible(true)
            self:getNode("layer_spirit_name"..i):setVisible(true)
        end
    end
end

function SoulLifeFormationPanel:refreshOpenFlag(param)
    local iconPos = param - self.chooseIdx * 10
    self.posUnlock[iconPos] = true
    SpiritInfo.opens[param] = true
    self:getNode("txt_open_lv" .. iconPos):setVisible(false)
    self:getNode("icon_lock" .. iconPos):setVisible(false)
    gShowNotice(gGetWords("spiritWord.plist","spirit_pos_open_suc"))
    Data.redpos.spirit = true
end

function SoulLifeFormationPanel:setZhenIconLv(lv,addLv,idx)
    -- self:getNode("lab_lv"..idx):clear()
    -- local strLev = "\\w{c=ffc10a;s=20;o=000000ff,0.1}" .. lv
    -- if addLv ~= 0 then
    --     strLev = strLev .. "\\w{c=8aff00;s=20;o=000000ff,0.1}+"..addLv                   
    -- end
    -- self:getNode("lab_lv"..idx):setString(strLev)
    -- self:getNode("lab_lv"..idx):layout()
    self:setLabelString("lab_lv"..idx, lv)
    self:getNode("lab_add_lv"..idx):setVisible(false)
    if addLv ~= 0 then
        self:setLabelString("lab_add_lv"..idx, "+"..addLv)
        self:getNode("lab_add_lv"..idx):setVisible(true)
    end
    self:getNode("layout_lv"..idx):layout()
end

function SoulLifeFormationPanel:setMainLayerTouchEnable(enable)
    if nil ~= gMainMoneyLayer then
        gMainMoneyLayer:getNode("panel_money").touchEnable = enable
        gMainMoneyLayer:getNode("panel_menu").touchEnable = enable
    end
end

function SoulLifeFormationPanel:uploadEquSoulLifePos(pos)
    local panel = Panel.getOpenPanel(PANEL_SOULLIFE_DETAIL)
    if nil ~= panel then
        panel:onClose()
    end
    -- 卸下已装备的合魂信息
    local uploadIdx = SpiritInfo.getSpiritIndexWithPos(pos)
    local uploadSpirit = SpiritInfo.getSpiritByIdx(uploadIdx)
    local iPos = uploadSpirit.iPos
    uploadSpirit.iPos = 0
    SpiritInfo.removeSpiritByIdx(uploadIdx)

    if nil ~= uploadSpirit then
        local soulLifePos = iPos % 10
        self.equipSoulLifes[soulLifePos] = nil
        self:getNode("icon_soullife".. soulLifePos):removeChildByTag(1)

        -- self:getNode("lab_lv"..soulLifePos):setVisible(true)
        self:getNode("layout_lv"..soulLifePos):setVisible(false)
        self:getNode("layer_spirit_name"..soulLifePos):setVisible(false)
        self:getNode("spirit_name".. soulLifePos):setVisible(false)

        self:showSpiritAttr()
    end

    --更新背包及显示
    if nil ~= uploadSpirit then
        SpiritInfo.addBagSpiritItem(uploadSpirit)
        local spiritItem = XunXianItem.new(uploadSpirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, self.scrollLayer:getSize() + 1, true)
        if nil ~= spiritItem then
            spiritItem.onChoosed = function(item)
                if not self.isFindingOrCalling then
                    Panel.popUpVisible(PANEL_SOULLIFE_DETAIL, uploadSpirit, SOULLIFE_DETAIL_PANEL.XUNXIAN, true)
                end
            end
        end
        spiritItem:setItem()
        self.scrollLayer:addItem(spiritItem)
        self.scrollLayer:layout(false)
        self:updateBagNum()
    end
    self:checkUnlockPosEqu()
end

function SoulLifeFormationPanel:getPosItem(pos)
    local dis=0
    for i = 1, 8 do
        local itemPos= self:getNode("icon_soullife"..i):convertToWorldSpace(cc.p(0,0))
        local size= self:getNode("icon_soullife"..i):getContentSize()
        if(pos.x > itemPos.x - dis and
            pos.x < itemPos.x+size.width +dis and
            pos.y > itemPos.y -dis and
            pos.y < itemPos.y+size.height +dis
            )then
            return i
        end

    end
    return -1
end

function SoulLifeFormationPanel:initSoulLifeCallback()
    for i = 1, 8 do
        local item = self:getNode("icon_soullife"..i)
        item.__touchend = true
        item.moveItemCallback=function (touchPos,oriPos)
            self:onMoveSoullife(touchPos,oriPos)
        end

        item.selectItemCallback=function(touchPos,oriPos)
            return self:onSelectSoulLife(touchPos,oriPos)
        end
    end
end

function SoulLifeFormationPanel:onMoveSoulLife(touchPos,oriPos)
    local pos=  self:getPosItem(touchPos)
end


function SoulLifeFormationPanel:onSelectSoulLife(touchPos,oriPos)
    local pos=  self:getPosItem(touchPos)
    if pos == oriPos or 
       pos == -1 then
        return false
    end

    if not self.posUnlock[pos] then
        return true
    end

    local spiritInPos = SpiritInfo.getSpiritWithPos(self.chooseIdx * 10 + pos)
    if nil == spiritInPos then
        SpiritInfo.setCurEquSpiritPos(self.chooseIdx * 10 + pos)
        Net.sendSpiritExchangeChangePos(self.chooseIdx * 10 + pos, self.chooseIdx * 10 + oriPos)
    else
        SpiritInfo.setCurEquSpiritPos(self.chooseIdx * 10 + oriPos)
        Net.sendSpiritExchangeChangePos(self.chooseIdx * 10 + oriPos, self.chooseIdx * 10 + pos)
    end

    return true
end

function SoulLifeFormationPanel:exchangeEquSoulLifePos(param)
    -- {equPos1=pos1,equPos2=pos2}
    -- 更新已装备的合魂信息
    local changeIdx= SpiritInfo.getSpiritIndexWithPos(param.equPos2)
    local changeSpirit = SpiritInfo.getSpiritByIdx(changeIdx)
    local beRepaceIdx = SpiritInfo.getSpiritIndexWithPos(param.equPos1)
    local beRepaceSpirit = nil
    changeSpirit.iPos = param.equPos1
    if -1 ~= beRepaceIdx then
        beRepaceSpirit = SpiritInfo.getSpiritByIdx(beRepaceIdx)
        beRepaceSpirit.iPos = param.equPos2
    else
        SpiritInfo.addSpiritItem(changeSpirit)
        SpiritInfo.removeSpiritByIdx(changeIdx)
    end

    if nil ~= changeSpirit then
        local soulLifePos = changeSpirit.iPos % 10
        self.equipSoulLifes[soulLifePos] = changeSpirit
        Icon.setSpiritIcon(changeSpirit.iType, self:getNode("icon_soullife".. soulLifePos))
        local addLv = DB.getSpiritAddLevByPos(soulLifePos)
        self:setZhenIconLv(changeSpirit.iLV,addLv,soulLifePos)
        self:getNode("layout_lv"..soulLifePos):setVisible(true)
        self:getNode("layer_spirit_name"..soulLifePos):setVisible(true)
        self:getNode("spirit_name".. soulLifePos):setString(gGetSpiritAttrNameByType(changeSpirit.iType, changeSpirit.iAttr))
        self:getNode("spirit_name".. soulLifePos):setColor(gCreateSpiritNameColor(changeSpirit.iType))
        self:getNode("spirit_name".. soulLifePos):setVisible(true)
    end

    if nil ~= beRepaceSpirit then
        local soulLifePos = beRepaceSpirit.iPos % 10
        self.equipSoulLifes[soulLifePos] = beRepaceSpirit
        Icon.setSpiritIcon(beRepaceSpirit.iType, self:getNode("icon_soullife".. soulLifePos))
        local addLv = DB.getSpiritAddLevByPos(soulLifePos)
        self:setZhenIconLv(beRepaceSpirit.iLV,addLv,soulLifePos)
        self:getNode("layout_lv"..soulLifePos):setVisible(true)
        self:getNode("layer_spirit_name"..soulLifePos):setVisible(true)
        self:getNode("spirit_name".. soulLifePos):setString(gGetSpiritAttrNameByType(beRepaceSpirit.iType, beRepaceSpirit.iAttr))
        self:getNode("spirit_name".. soulLifePos):setColor(gCreateSpiritNameColor(beRepaceSpirit.iType))
        self:getNode("spirit_name".. soulLifePos):setVisible(true)
    else
        if math.floor(param.equPos1 / 10) == math.floor(param.equPos2 / 10) then
            local emptyPos = param.equPos2 % 10
            self.equipSoulLifes[emptyPos] = nil
            -- self:getNode("lab_lv"..emptyPos):setVisible(false)
            self:getNode("layout_lv"..emptyPos):setVisible(false)
            self:getNode("layer_spirit_name"..emptyPos):setVisible(false)
            self:getNode("icon_soullife"..emptyPos):removeChildByTag(1)
        end
    end

    self:showSpiritAttr()
    self:checkUnlockPosEqu()
end

function SoulLifeFormationPanel:setQuickFindState()
    local vipLimit = DB.getMinVipLevForQuickFind()
    local lvLimit  = DB.getSpiritOneKeyLev()
    local quickBtn = self:getNode("btn_quick_xunxian")
    local contentSize = quickBtn:getContentSize()
    local posX, posY = quickBtn:getPosition()

    if Data.getCurVip() >= vipLimit or
       Data.getCurLevel() >= lvLimit then
       quickBtn:getParent():removeChildByTag(100)
       self:setTouchEnable("btn_quick_xunxian", true, false)
    else
        local lock = cc.Sprite:create("images/ui_public1/small_lock.png")
        gRefreshNode(quickBtn:getParent(),lock,cc.p(0.5,1.0),cc.p(posX + contentSize.width * 0.3, posY - contentSize.height * 0.35),100)
        self:setTouchEnable("btn_quick_xunxian", true, true)
    end
end

function SoulLifeFormationPanel:onPopup()
    self:setQuickFindState()
end

function SoulLifeFormationPanel:initDiscount()
    local showDiscount = false
    local disCount = 0.0
    if Data.activeSoullifeSaleoff.time ~= nil then
        if Data.activeSoullifeSaleoff.time > gGetCurServerTime() then
            showDiscount = true
            disCount = gGetDiscount(Data.activeSoullifeSaleoff.val/10)
        else
            showDiscount = false
            Data.activeSoullifeSaleoff.time = nil
            Data.activeSoullifeSaleoff.val = nil
        end
    end

    for i = 1, 3 do
        if showDiscount then
            self:setLabelString("txt_discount"..i, gGetMapWords("ui_soul_1.plist","7",disCount))
        end
        self:getNode("flag_discount"..i):setVisible(showDiscount)
    end
end

return SoulLifeFormationPanel