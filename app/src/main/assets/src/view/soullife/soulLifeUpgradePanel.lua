local SoulLifeUpgradePanel=class("SoulLifeUpgradePanel",UILayer)

function SoulLifeUpgradePanel:ctor(spirit,panelType)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_soullife_upgrade.map")
    self:initPanel(spirit,panelType)
end

function SoulLifeUpgradePanel:initPanel(spirit,panelType)
    self.panelType = panelType
    if panelType == SOULLIFE_UPGRADE_TYPE.SOULLIFE then
        self.spirit = spirit
        self.addExp  = 0
        self.levAfterUpgrade  = 0
        self.attrAfterUpgrade = 0
        self.attrAfterUpgrade2 = 0
        self.expAfterUpgrade  = 0
        self.upExpAfterUpgrade = 0
        self.sortedSpirits  = {}
        self.maxAddExp  = toint(DB.getSpiritMaxExp(self.spirit.iType, DB.getSpiritMaxLev()))
        self:getNode("bar_exp_add"):setVisible(false)
        self:initSoulLifeNeedUpgrade()
        self:getNode("panel_soullife_detail"):setVisible(true)
        self:getNode("panel_exp_inject"):setVisible(false)
        self:initAutoChooseShow()
    else
        self:getNode("panel_soullife_detail"):setVisible(false)
        self:getNode("panel_exp_inject"):setVisible(true)
        self:initExpPool()
    end
    Scene.clearLazyFunc("soullifeupgradeitem")

    self.scrollLayer = self:getNode("scroll_items")
    self.scrollLayer.eachLineNum = 5
    self.scrollLayer.offsetX = 5
    self.scrollLayer.offsetY = 5
    self.scrollLayer:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --选择标记，避免每次选择时对self.choosedIds进行insert和remove操作
    self.chooseIdxFlag  = {}
    self.choosedIds = {}
    self:createSortedSpirits(panelType)

    for i=1,4 do
        if(self:getNode("txt_title"..i))then
            self:getNode("txt_title"..i):setVisible(gIsZhLanguage());
        end
    end
end

function SoulLifeUpgradePanel:initSoulLifeNeedUpgrade()
    --设置Icon
    Icon.setSpiritIcon(self.spirit.iType, self:getNode("icon_bg"))
    local name = gGetSpiritAttrNameByType(self.spirit.iType, self.spirit.iAttr)
    self:getNode("txt_name"):setString(name)
    self:getNode("txt_name"):setColor(gCreateSpiritNameColor(self.spirit.iType))
    self:getNode("txt_lv_value"):setString(getLvReviewName("Lv") .. self.spirit.iLV)
    self:getNode("txt_lv"):setString(tostring(self.spirit.iLV))
    
    local spiritAttr  = DB.getSpiritAttr(self.spirit.iType, self.spirit.iLV, self.spirit.iAttr)
    local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)
    self:getNode("txt_attr_title"):setString(attrName..":")
    self:getNode("txt_attr_value"):setString(attrValue)
    self:getNode("layout_attr_value1"):layout()
    self:getNode("layout_attr1"):layout()
    if spiritAttr.attr2 ~= 0 then
        attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr2,spiritAttr.value2)
        self:getNode("txt_attr_title2"):setString(attrName..":")
        self:getNode("txt_attr_value2"):setString(attrValue)
        self:getNode("txt_attr_add2"):setString("")
        self:getNode("layout_attr_value2"):layout()
        self:getNode("layout_attr2"):layout()
        self:getNode("layout_attr2"):setVisible(true)
        self:getNode("txt_attr_title2"):setVisible(true)
        self:getNode("icon_attr2"):setVisible(true)
    end

    self:setExp()
end

function SoulLifeUpgradePanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName == "btn_auto_choose" then
        Panel.popUpVisible(PANEL_SOULLIFE_AUTOCHOOSE, self.spirit.iType, nil, true)
    elseif target.touchName == "btn_upgrade" then
        self:sendUpgradeMsg()
    elseif target.touchName == "btn_unchoose" then
        self:unchooseSpirits()
    elseif string.find(target.touchName, "icon_bg") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_bg")+1))
        self:autoChooseSoulLife(pos)
    elseif target.touchName == "btn_inject" then
        self:sendInjectMsg()
    end
end

function SoulLifeUpgradePanel:checkCanChoose(spirit)
    if self.spirit.iType < spirit.iType then
        gShowNotice(gGetWords("spiritWord.plist", "spirit_upgrade_no_select"))
        return false
    end

    local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
    if self.spirit.iExp + self.addExp + spirit.iExp + baseExp > self.maxAddExp then
        gShowNotice(gGetWords("spiritWord.plist", "spirit_max_level"))
        return false
    end

    return true
end

function SoulLifeUpgradePanel:updateAddValue(spirit, choose)
    local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
    if choose then
        if self.spirit.iExp + self.addExp + spirit.iExp + baseExp >= self.maxAddExp then
            self.addExp = self.maxAddExp - self.spirit.iExp
        else
           self.addExp  = self.addExp + spirit.iExp + baseExp   
        end
    else
        self.addExp  = self.addExp - spirit.iExp - baseExp
        if self.addExp < 0 then
            self.addExp = 0
        end
    end
    self:setExp()
end

function SoulLifeUpgradePanel:setExp()
    local expProPreLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV - 1)
    local expProCurLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV)
    local curExp = self.spirit.iExp
    local curUpExp = expProCurLev.exp
    local curLev   = self.spirit.iLV
    local maxLevFlag = false

    local expPreLev = 0
    if nil ~= expProPreLev then
        expPreLev = expProPreLev.exp
    end

    local tmpCurExp = curExp - expPreLev
    local tmpCurUpExp = curUpExp - expPreLev
    --未升级的经验条
    self:getNode("txt_exp"):setString(string.format("%d/%d",tmpCurExp,tmpCurUpExp))

    self:setBarPer("bar_exp",tmpCurExp/tmpCurUpExp)

    --增加经验条
    local expAddBar = self:getNode("bar_exp_add")
    local addPercent = (tmpCurExp + self.addExp) / tmpCurUpExp
    local txtExpAdd = self:getNode("txt_exp_add")
    if self.addExp > 0 then
        txtExpAdd:setString("+ " .. self.addExp )
        self:setBarPer("bar_exp_add", addPercent)
        expAddBar:stopAllActions()
        expAddBar:setOpacity(0)
        expAddBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,128), cc.FadeTo:create(0.5,0))))
        expAddBar:setVisible(true)
    else
        txtExpAdd:setString("")
        expAddBar:setVisible(false)
    end

    --计算等级,增加几个等级
    local addLev = 0
    local allExp = curExp + self.addExp
    addLev = DB.getSpiritLevel(self.spirit.iType, allExp)
    local txtLvAdd   = self:getNode("txt_lv_add")
    local txtAttrAdd = self:getNode("txt_attr_add")
    local txtAttrAdd2 = self:getNode("txt_attr_add2")
    if addLev > curLev then
        if addLev>DB.getSpiritMaxLev() then
            addLev=DB.getSpiritMaxLev()
        end
        self.levAfterUpgrade  = addLev
        txtLvAdd:setString("+" .. (addLev - curLev))
        -- 属性
        local attr    = DB.getSpiritAttr(self.spirit.iType, self.spirit.iLV, self.spirit.iAttr)
        local attrAdd = DB.getSpiritAttr(self.spirit.iType, addLev, self.spirit.iAttr)
        if nil ~= attr and nil ~= attrAdd then
            self.attrAfterUpgrade = attrAdd.value
            if CardPro.isFloatAttr(attr.attr) then
                txtAttrAdd:setString("+" .. string.format("%0.1f%%",(attrAdd.value - attr.value)))
            else
                txtAttrAdd:setString("+" .. (attrAdd.value - attr.value))
            end
            if attr.attr2 ~= 0 and (attrAdd.value2 - attr.value2) ~= 0 then
                self.attrAfterUpgrade2 = attrAdd.value2
                if CardPro.isFloatAttr(attr.attr2) then
                    txtAttrAdd2:setString("+" .. string.format("%0.1f%%",(attrAdd.value2 - attr.value2)))
                else
                    txtAttrAdd2:setString("+" .. (attrAdd.value2 - attr.value2))
                end
            end 
        end

        local expProFinal = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV + addLev - curLev )
        local expProFinaPre  = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV + addLev - curLev - 1)
        self.expAfterUpgrade   = allExp
        self.upExpAfterUpgrade = expProFinal.exp
        self:getNode("layout_attr_value1"):layout()
        self:getNode("layout_attr_value2"):layout()
    else
        self.levAfterUpgrade  = curLev
        local attr    = DB.getSpiritAttr(self.spirit.iType, self.spirit.iLV, self.spirit.iAttr)
        self.attrAfterUpgrade = attr.value
        self.attrAfterUpgrade2 = attr.value2
        self.expAfterUpgrade  = allExp
        self.upExpAfterUpgrade = curUpExp
        txtLvAdd:setString("")
        txtAttrAdd:setString("")
        txtAttrAdd2:setString("")
        self:getNode("layout_attr_value1"):layout()
        self:getNode("layout_attr_value2"):layout()
    end

    self:resetLayOut()
end

function SoulLifeUpgradePanel:sendUpgradeMsg()
    if self.scrollLayer:getSize() == 0 then
        return
    end

    self.choosedIds = {}
    local tianSoulNums = 0
    local doubleSoulNums = 0
    for  i = 1, self.scrollLayer:getSize() do
        if self.chooseIdxFlag[i] then
            table.insert(self.choosedIds, self.scrollLayer:getItem(i - 1)._ID)
            if self.scrollLayer:getItem(i - 1)._spirit.iType == SPIRIT_TYPE.TIAN then
                tianSoulNums = tianSoulNums + 1
            elseif self.scrollLayer:getItem(i - 1)._spirit.iType == SPIRIT_TYPE.DOUBLE_ATTR then
                doubleSoulNums = doubleSoulNums + 1
            end
        end
    end

    if #self.choosedIds == 0 then
        return
    end

    if tianSoulNums > 0 or doubleSoulNums > 0 then
        local tipInfo = ""
        if tianSoulNums > 0 and doubleSoulNums > 0 then
            tipInfo = gGetWords("spiritWord.plist","spirit_upgrade_have_tian_double", tianSoulNums, doubleSoulNums)
        elseif tianSoulNums > 0 then
            tipInfo = gGetWords("spiritWord.plist","spirit_upgrade_have_tian", tianSoulNums)
        else
            tipInfo = gGetWords("spiritWord.plist","spirit_upgrade_have_double", doubleSoulNums)
        end

        gConfirmCancel(tipInfo, function ()
                SpiritInfo.setChooseIds(self.choosedIds)
                SpiritInfo.setUpgradeSpiritID(self.spirit.iID)
                Net.sendSpiritUpgrade(self.spirit.iID, self.spirit.iPos, self.choosedIds)
        end)
    else
        SpiritInfo.setChooseIds(self.choosedIds)
        SpiritInfo.setUpgradeSpiritID(self.spirit.iID)
        Net.sendSpiritUpgrade(self.spirit.iID, self.spirit.iPos, self.choosedIds)
    end
end

function SoulLifeUpgradePanel:events()
    return { EVENT_ID_SPIRIT_UPGRADE, EVENT_ID_SPIRIT_AUTO_CHOOSE,EVENT_ID_SPIRIT_CH_EXP}
end

function SoulLifeUpgradePanel:dealEvent(event, param)
    if event == EVENT_ID_SPIRIT_UPGRADE then
        for i = 1, #self.choosedIds do
            local spiritType = SpiritInfo.getBagSpiritById(self.choosedIds[i]).iType
            SpiritInfo.removeBagSpiritByID(self.choosedIds[i])
            local idx = self:getScrollItemIdx(self.choosedIds[i])
            if -1 ~= idx then
                self:soulLifeRemoveAction(spiritType,idx,1)
                self.scrollLayer:removeItemByIndex(idx - 1)  
            end        
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
            self:addUpgradeEffect(1)
        end )))
        self:updateSpiritPro()
        self:updateOtherPanel()
    elseif event == EVENT_ID_SPIRIT_AUTO_CHOOSE then
        self:autoChooseSpirits()
    elseif event == EVENT_ID_SPIRIT_CH_EXP then
        for i = 1, #self.chooseInjectIds do
            local spiritType = SpiritInfo.getBagSpiritById(self.chooseInjectIds[i]).iType
            SpiritInfo.removeBagSpiritByID(self.chooseInjectIds[i])
            local idx = self:getScrollItemIdx(self.chooseInjectIds[i])
            if -1 ~= idx then
                self:soulLifeRemoveAction(spiritType,idx,2)
                self.scrollLayer:removeItemByIndex(idx - 1)  
            end        
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
            self:addUpgradeEffect(2)
        end )))
        self:updateInjectPanel()
        self:updateOtherPanelByInject(self.chooseInjectIds)
    end
end

function SoulLifeUpgradePanel:updateSpiritPro()
    self.spirit.iLV  = self.levAfterUpgrade
    self.spirit.iExp = self.expAfterUpgrade

    local expProPreLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV - 1)
    local expProCurLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV)
    local curExp = self.spirit.iExp
    local curUpExp = expProCurLev.exp
    local curLev   = self.spirit.iLV
    local expPreLev = 0
    if nil ~= expProPreLev then
        expPreLev = expProPreLev.exp
    end

    local tmpCurExp = curExp - expPreLev
    local tmpCurUpExp = curUpExp - expPreLev

    local spiritAttr  = DB.getSpiritAttr(self.spirit.iType, self.spirit.iLV, self.spirit.iAttr)
    local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)

    self:getNode("txt_lv"):setString(tostring(self.spirit.iLV))
    self:getNode("txt_lv_value"):setString(getLvReviewName("Lv") .. self.spirit.iLV)
    self:getNode("txt_attr_value"):setString(attrValue)
    self:getNode("layout_attr_value1"):layout()
    if spiritAttr.attr2 ~= 0 then
        attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr2, spiritAttr.value2)
        self:getNode("txt_attr_value2"):setString(attrValue)
        self:getNode("layout_attr_value2"):layout()
    end
    self:getNode("txt_exp"):setString(string.format("%d/%d",tmpCurExp,tmpCurUpExp))
    self:setBarPer("bar_exp",tmpCurExp/tmpCurUpExp)
    self:getNode("txt_lv_add"):setString("")
    self:getNode("txt_attr_add"):setString("")
    self:getNode("txt_attr_add2"):setString("")
    self:getNode("txt_exp_add"):setString("")
    self:getNode("bar_exp_add"):stopAllActions()
    self:getNode("bar_exp_add"):setVisible(false)
    self.addExp = 0
    self:resetAllChooseFlag()
    self.choosedIds = {}
end

function SoulLifeUpgradePanel:autoChooseSpirits()
    local count = self.scrollLayer:getSize()
    if  count == 0 then
        return
    end
    self:resetSoulLifeDetail()
    self:resetChoosedInfo()
    --要判断最终先择的等级
    for i = 1, count do
        local spiritItem = self.scrollLayer:getItem(i - 1)
        if nil ~= spiritItem then
            local spirit  = spiritItem._spirit
            if (SpiritInfo.autoChooseFlag[spirit.iType + 1]) and self:canBeAutoChoosed(spirit) then
                spiritItem:setItem()
                spiritItem:getNode("icon_choose"):setVisible(true)
                spiritItem._isChoose = true
                self.chooseIdxFlag[i] = true
                self:updateAddValue(spirit, true)
            end 
        end
    end
end

function SoulLifeUpgradePanel:unchooseSpirits()
    local count = self.scrollLayer:getSize()
    if  count == 0 then
        return
    end

    for i = 1, count do
        local spiritItem = self.scrollLayer:getItem(i - 1)
        local spirit  = spiritItem._spirit
        if nil ~= spirit and nil ~= spiritItem then
            if spiritItem._isChoose then
                spiritItem:getNode("icon_choose"):setVisible(false)
                self.chooseIdxFlag[i] = false
                spiritItem._isChoose = false
                self:updateAddValue(spirit, false)
            end 
        end
    end
end

function SoulLifeUpgradePanel:updateOtherPanel()
    local formationPanel = Panel.getOpenPanel(PANEL_SOULLIFE_FORMATION)
    if nil ~= formationPanel then
        formationPanel:updateBagNum()
        formationPanel:updateEquSpiritByUpgrade()
    end
end

function SoulLifeUpgradePanel:getScrollItemIdx(ID)
    for i = 1, self.scrollLayer:getSize() do
        local item = self.scrollLayer:getItem(i - 1)
        if item._ID == ID then
            return i
        end
    end
    return -1
end

function SoulLifeUpgradePanel:onPopback()
    Scene.clearLazyFunc("soullifeupgradeitem")
end

function SoulLifeUpgradePanel:resetAllChooseFlag()
    self.chooseIdxFlag = {}
    for  i = 1, self.scrollLayer:getSize() do
        self.chooseIdxFlag[i] = false
        local spiritItem = self.scrollLayer:getItem(i - 1)
        if nil ~= spiritItem then
            spiritItem:setItem()
            spiritItem:getNode("icon_choose"):setVisible(false)
            spiritItem._idx = i
            spiritItem._isChoose = false
        end
    end
end

function SoulLifeUpgradePanel:createSortedSpirits(panelType)
    self.scrollLayer:clear()
    self.sortedSpirits = {}
    local size = SpiritInfo.getBagSpiritSize()

    for i = 1, size do
        local spirit = SpiritInfo.getBagSpiritByIdx(i)
        if nil ~= spirit then
            if panelType == SOULLIFE_UPGRADE_TYPE.SOULLIFE  then
                if spirit.iID ~= self.spirit.iID then
                    self.sortedSpirits[#self.sortedSpirits + 1] = spirit  
                end
            else
                self.sortedSpirits[#self.sortedSpirits + 1] = spirit  
            end
        end
    end

    local sortedSpiritsSize = #self.sortedSpirits
    if sortedSpiritsSize == 0 then
        return
    end

    table.sort( self.sortedSpirits, function (lSpirit, rSpirit)
        if lSpirit.iType ~= rSpirit.iType then
            return lSpirit.iType < rSpirit.iType
        else
            if lSpirit.iLV ~= rSpirit.iLV then
                return lSpirit.iLV < rSpirit.iLV
            else
                return lSpirit.iAttr < rSpirit.iAttr
            end
        end
    end )

    local drawNum = 20

    for i = 1, sortedSpiritsSize do
        local spirit =  self.sortedSpirits[i]
        local spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, i, true)
        spiritItem.onChoosed = function(item)
            if panelType == SOULLIFE_UPGRADE_TYPE.SOULLIFE then
                if item._isChoose then
                    -- print("coming in _isChoose")
                    if not self:checkCanChoose(item._spirit) then
                        item._isChoose = not item._isChoose
                        self.chooseIdxFlag[item._idx] = false
                    else
                        item:getNode("icon_choose"):setVisible(true)
                        self.chooseIdxFlag[item._idx] = true
                        self:updateAddValue(item._spirit, item._isChoose)
                    end
                else
                    -- print("coming in not _isChoose")
                    item:getNode("icon_choose"):setVisible(false)
                    self.chooseIdxFlag[item._idx] = false
                    self:updateAddValue(item._spirit, item._isChoose)
                end
            else
                if item._isChoose then
                    item:getNode("icon_choose"):setVisible(true)
                    self.chooseIdxFlag[item._idx] = true
                    self:updateAddExp(item._spirit,true)
                else
                    item:getNode("icon_choose"):setVisible(false)
                    self.chooseIdxFlag[item._idx] = false
                    self:updateAddExp(item._spirit,false)
                end
            end
        end

        if drawNum > 0 then
            drawNum = drawNum - 1
            spiritItem:setItem()
        else
            spiritItem:setLazyFunc("soullifeupgradeitem") 
        end
        self.scrollLayer:addItem(spiritItem)
    end
    self.scrollLayer:layout()
end

function SoulLifeUpgradePanel:canBeAutoChoosed(spirit)
    local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
    if self.spirit.iExp + self.addExp + spirit.iExp + baseExp > self.maxAddExp then
        return false
    end
    return true
end

function SoulLifeUpgradePanel:resetChoosedInfo()
    self.addExp = 0
    self:resetAllChooseFlag()
    self.choosedIds = {}
end

function SoulLifeUpgradePanel:initExpPool()
    Icon.setSpiritExpIcon(self:getNode("icon_exp_bg"))
    self:setLabelString("txt_left_exp", SpiritInfo.exp)
    self.addExpToPool    = 0
    self:getNode("txt_add_exp"):setVisible(false)
    self:getNode("layout_exp_pool"):layout()
    self.chooseInjectIds = {}
    self:initAutoChooseShow()
end

function SoulLifeUpgradePanel:autoChooseSoulLife(pos)
    self.autoChooseShow[pos] = not self.autoChooseShow[pos]
    local chooseFlag = self.autoChooseShow[pos]
    if chooseFlag then
        self:getNode("icon_choose"..pos):setVisible(true)
    else
        self:getNode("icon_choose"..pos):setVisible(false)
    end
    local count = self.scrollLayer:getSize()
    if  count == 0 then
        return
    end

    for i = 1, count do
        local spiritItem = self.scrollLayer:getItem(i - 1)
        if nil ~= spiritItem then
            local spirit  = spiritItem._spirit
            if spirit.iType + 1 == pos then
                if chooseFlag then
                    if (not spiritItem._isChoose) then
                        spiritItem:setItem()
                        spiritItem:getNode("icon_choose"):setVisible(true)
                        spiritItem._isChoose = true
                        self.chooseIdxFlag[i] = true
                        if self.panelType == SOULLIFE_UPGRADE_TYPE.SOULLIFE then
                            self:updateAddValue(spiritItem._spirit, spiritItem._isChoose)
                        else
                            self:updateAddExp(spirit,true)
                        end
                    end
                else
                    if spiritItem._isChoose then
                        spiritItem:getNode("icon_choose"):setVisible(false)
                        self.chooseIdxFlag[i] = false
                        spiritItem._isChoose = false
                        if self.panelType == SOULLIFE_UPGRADE_TYPE.SOULLIFE then
                            self:updateAddValue(spiritItem._spirit, spiritItem._isChoose)
                        else
                            self:updateAddExp(spirit,false)
                        end
                    end 
                end
            end
        end
    end
end

function SoulLifeUpgradePanel:updateAddExp(spirit,choose)
    local baseExp = toint(DB.getSpiritBaseExp(spirit.iType + 1))
    if choose then
        self.addExpToPool = self.addExpToPool + spirit.iExp + baseExp
    else
        self.addExpToPool = self.addExpToPool - spirit.iExp - baseExp
        if self.addExpToPool < 0 then
            self.addExpToPool = 0
        end
    end

    if self.addExpToPool > 0 then
        self:setLabelString("txt_add_exp", string.format("+%d", self.addExpToPool))
        self:getNode("txt_add_exp"):setVisible(true)
    else
        self:getNode("txt_add_exp"):setVisible(false)
    end
    self:getNode("layout_exp_pool"):layout()
end

function SoulLifeUpgradePanel:sendInjectMsg()
    if self.scrollLayer:getSize() == 0 then
        return
    end

    self.chooseInjectIds = {}
    local tianSoulNums = 0
    local doubleSoulNums = 0
    for  i = 1, self.scrollLayer:getSize() do
        if self.chooseIdxFlag[i] then
            table.insert(self.chooseInjectIds, self.scrollLayer:getItem(i - 1)._ID)
            if self.scrollLayer:getItem(i - 1)._spirit.iType == SPIRIT_TYPE.TIAN then
                tianSoulNums = tianSoulNums + 1
            elseif self.scrollLayer:getItem(i - 1)._spirit.iType == SPIRIT_TYPE.DOUBLE_ATTR then
                doubleSoulNums = doubleSoulNums + 1
            end
        end
    end

    if #self.chooseInjectIds == 0 then
        return
    end

    if tianSoulNums > 0 or doubleSoulNums > 0 then
        local tipInfo = ""
        if tianSoulNums > 0 and doubleSoulNums > 0 then
            tipInfo = gGetWords("spiritWord.plist","spirit_upgrade_have_tian_double", tianSoulNums, doubleSoulNums)
        elseif tianSoulNums > 0 then
            tipInfo = gGetWords("spiritWord.plist","spirit_upgrade_have_tian", tianSoulNums)
        else
            tipInfo = gGetWords("spiritWord.plist","spirit_upgrade_have_double", doubleSoulNums)
        end
        gConfirmCancel(tipInfo, function ()
            Net.sendSpiritChExp(self.chooseInjectIds)
        end)
    else
        Net.sendSpiritChExp(self.chooseInjectIds)
    end    
end

function SoulLifeUpgradePanel:updateInjectPanel()

    self:setLabelString("txt_left_exp", SpiritInfo.exp)
    self:getNode("txt_add_exp"):setVisible(false)
    self:getNode("layout_exp_pool"):layout()
    self.addExpToPool = 0
    self.chooseIdxFlag = {}
    for  i = 1, self.scrollLayer:getSize() do
        self.chooseIdxFlag[i] = false
        local spiritItem = self.scrollLayer:getItem(i - 1)
        if nil ~= spiritItem then
            spiritItem:setItem()
            spiritItem:getNode("icon_choose"):setVisible(false)
            spiritItem._idx = i
            spiritItem._isChoose = false
        end
    end
    --更新动画表现
end

function SoulLifeUpgradePanel:updateOtherPanelByInject()
    local formationPanel = Panel.getOpenPanel(PANEL_SOULLIFE_FORMATION)
    if nil ~= formationPanel then
        formationPanel:updateSpiritByInject()
        formationPanel:updateBagNum()
    end
end

function SoulLifeUpgradePanel:soulLifeRemoveAction(spiritType,idx,type)
    local flyTime = 0.3
    if spiritType == SPIRIT_TYPE.DOUBLE_ATTR then
        spiritType = 6
    end
    local spiritIcon = cc.Sprite:create(string.format("images/ui_soullife/soul_%d.png", spiritType + 1))
    spiritIcon:setScale(1.2)
    spiritIcon:setAnchorPoint(cc.p(0.5, 0.5))
    local soulLifeItem = self.scrollLayer:getItem(idx - 1)
    local itemBg = soulLifeItem:getNode("icon_bg")
    local worldPos = soulLifeItem:convertToWorldSpace(cc.p(itemBg:getPosition()))
    local nodePos   = self:convertToNodeSpace(worldPos)
    spiritIcon:setPosition(nodePos)
    self:addChild(spiritIcon,99)

    local itemBg = nil
    local moveToWorldPos = nil
    if type == 1 then
        itemBg = self:getNode("icon_bg")
        moveToWorldPos = self:getNode("panel_soullife_detail"):convertToWorldSpace(cc.p(itemBg:getPosition()))
    else
        itemBg = self:getNode("icon_exp_bg")
        moveToWorldPos = self:getNode("panel_exp_inject"):convertToWorldSpace(cc.p(itemBg:getPosition()))
    end
    
    local moveToNodPos   = self:convertToNodeSpace(moveToWorldPos)
    local moveTo = cc.MoveTo:create(flyTime, moveToNodPos)
    spiritIcon:runAction(cc.Sequence:create(moveTo, cc.CallFunc:create(function ()
        spiritIcon:removeFromParent()
    end)))
end

function SoulLifeUpgradePanel:addUpgradeEffect(type)
    local upgradeEffect = FlashAni.new()
    upgradeEffect:playAction("ui_minghun_shengji", function()
                            upgradeEffect:removeFromParent()
                        end, nil, 1)

    if type == 1 then
        gAddCenter(upgradeEffect, self:getNode("icon_bg"))
    else
        gAddCenter(upgradeEffect, self:getNode("icon_exp_bg"))
    end
end

function SoulLifeUpgradePanel:resetSoulLifeDetail()
    local expProPreLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV - 1)
    local expProCurLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV)
    local curExp = self.spirit.iExp
    local curUpExp = expProCurLev.exp
    local expPreLev = 0
    if nil ~= expProPreLev then
        expPreLev = expProPreLev.exp
    end

    local tmpCurExp = curExp - expPreLev
    local tmpCurUpExp = curUpExp - expPreLev

    self:getNode("txt_lv"):setString(tostring(self.spirit.iLV))
    self:getNode("txt_lv_value"):setString(getLvReviewName("Lv") .. self.spirit.iLV)
    local spiritAttr  = DB.getSpiritAttr(self.spirit.iType, self.spirit.iLV, self.spirit.iAttr)
    self:getNode("txt_attr_value"):setString(tostring(spiritAttr.value))
    self:getNode("layout_attr_value1"):layout()
    self:getNode("txt_exp"):setString(string.format("%d/%d",tmpCurExp,tmpCurUpExp))
    self:setBarPer("bar_exp",tmpCurExp/tmpCurUpExp)
    self:getNode("txt_lv_add"):setString("")
    self:getNode("txt_attr_add"):setString("")
    self:getNode("txt_exp_add"):setString("")
    self:getNode("bar_exp_add"):stopAllActions()
    self:getNode("bar_exp_add"):setVisible(false)  
end

function SoulLifeUpgradePanel:initAutoChooseShow()
    self.autoChooseShow = {}
    for i = 1, 4 do
        self:getNode("icon_choose"..i):setVisible(false)
        self.autoChooseShow[i] = false 
    end
end

return SoulLifeUpgradePanel