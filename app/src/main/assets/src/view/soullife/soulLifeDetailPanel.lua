local SoulLifeDetailPanel=class("SoulLifeDetailPanel",UILayer)

function SoulLifeDetailPanel:ctor(spirit,panelType)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_soullife_detail.map")
    self.spirit = spirit
    if nil ~= panelType then
        self.panelType = panelType
    else
        if self.spirit.iPos ~= 0 then
           self.panelType = SOULLIFE_DETAIL_PANEL.FORMATION
           SpiritInfo.setCurEquSpiritPos(self.spirit.iPos)
        else
            self.panelType = SOULLIFE_DETAIL_PANEL.XUNXIAN
        end
    end
    self:setSpiritAffectLv()
    self:initPanel(panelType)
    self.aniFrame = 60
end

function SoulLifeDetailPanel:initPanel()
    --设置Icon
    Icon.setSpiritIcon(self.spirit.iType, self:getNode("icon_bg"))
    local name = gGetSpiritAttrNameByType(self.spirit.iType, self.spirit.iAttr)
    self:getNode("txt_name"):setString(name) 
    self:getNode("txt_name"):setColor(gCreateSpiritNameColor(self.spirit.iType))
    self:setSpiritLv()
    local spiritAttr  = DB.getSpiritAttr(self.spirit.iType, self.affectLv, self.spirit.iAttr)
    local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)
    self:getNode("txt_attr_name"):setString(attrName)
    self:getNode("txt_attr_value"):setString(attrValue)
    self:getNode("layout_attr"):layout()
    if spiritAttr.attr2 ~= 0 then
        local posX,posY = self:getNode("layout_attr"):getPosition()
        local contentSize = self:getNode("layout_attr"):getContentSize()
        local attrName2,attrValue2 = gGetSpiritAttrNameAndValue(spiritAttr.attr2, spiritAttr.value2)
        self:getNode("txt_attr_name2"):setString(attrName2)
        self:getNode("txt_attr_value2"):setString(attrValue2)
        self:getNode("layout_attr2"):layout()
        self:getNode("layout_attr2"):setPosition(posX + contentSize.width + 15, posY)
        self:getNode("layout_attr2"):setVisible(true)
    end
    self:getNode("layout_attr_all"):layout()
    self:setExp()
    self:setLabelString("txt_exp_pool", SpiritInfo.exp)
    --控制装备按钮以及分解按钮
    if self.panelType == SOULLIFE_DETAIL_PANEL.FORMATION then
        -- self:getNode("btn_upgrade"):setVisible(true)
        -- self:getNode("btn_bag"):setVisible(true)
        self:getNode("layout_btn1"):setVisible(true)
        self:getNode("btn_exchange"):setVisible(true)
        self:getNode("btn_upload"):setVisible(true)
        self:getNode("btn_breakUp"):setVisible(false)
        self:getNode("txt_breakUp"):setVisible(false)
        self:getNode("layout_btn1"):layout()
        self:getNode("layout_btn2"):setVisible(false)
    elseif self.panelType == SOULLIFE_DETAIL_PANEL.XUNXIAN then
        if self.spirit.iType == SPIRIT_TYPE.TIAN or self.spirit.iType == SPIRIT_TYPE.DOUBLE_ATTR then
            self:getNode("layout_btn1"):setVisible(true)
            -- self:getNode("btn_upgrade"):setVisible(true)
            -- self:getNode("btn_bag"):setVisible(true)
            self:getNode("btn_exchange"):setVisible(false)
            self:getNode("btn_upload"):setVisible(false)
            self:getNode("btn_breakUp"):setVisible(true)
            self:getNode("layout_btn1"):layout()
            --分解为兑换数量的1/2
            local breakupTip = ""
            if self.spirit.iType == SPIRIT_TYPE.TIAN then
                breakupTip = gGetWords("spiritWord.plist","soullife_break_up", DB.getSpiritExchangeCount() / 2)
            else
                breakupTip = gGetWords("spiritWord.plist","double_soullife_break_up", DB.getSpiritExchangeCount() / 2, DB.getSpiritExchangeItemCount() / 2)
            end
            self:getNode("txt_breakUp"):setString(breakupTip)
            self:getNode("txt_breakUp"):setVisible(true)
            self:getNode("layout_btn2"):setVisible(false)
        else
            self:getNode("layout_btn1"):setVisible(false)
            -- self:getNode("btn_exchange"):setVisible(false)
            -- self:getNode("btn_breakUp"):setVisible(false)
            self:getNode("txt_breakUp"):setVisible(false)
            self:getNode("layout_btn2"):setVisible(true)
        end
    end
end

function SoulLifeDetailPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_upgrade" or target.touchName=="btn_upgrade1" then
        if SpiritInfo.exp > 0 then
            Net.sendSpiritUpgradeNew(self.spirit.iID, self.spirit.iPos)
        else
            gShowNotice(gGetCmdCodeWord(CMD_SPIRIT_UPGRADE_NEW,33))
        end
    elseif target.touchName=="btn_exchange" then
        local exchangeSpirit = self.spirit
        self:onClose()
        Panel.popUpVisible(PANEL_SOULLIFE_EQUIP, SOULLIFE_BAG_TYPE.EQU, exchangeSpirit ,true)
    elseif target.touchName=="btn_upload" then
        Net.sendSpiritUnload(self.spirit.iPos)
    elseif target.touchName=="btn_breakUp" then
        local spiritName = gGetSpiritAttrNameByType(self.spirit.iType, self.spirit.iAttr)
        spiritName = spiritName .. getLvReviewName("Lv") .. self.spirit.iLV
        local tipInfo = ""
        if self.spirit.iType == SPIRIT_TYPE.TIAN then
            tipInfo = gGetWords("spiritWord.plist","soullife_break_up_tip", spiritName, DB.getSpiritBreadUpCount())
        else
            tipInfo = gGetWords("spiritWord.plist","double_soullife_break_up_tip",spiritName,DB.getSpiritBreadUpCount(),  DB.getSpiritExchangeItemCount() / 2)
        end
        gConfirmCancel(tipInfo,function ()
            Net.sendSpiritBreakUp(self.spirit.iID)
            self:onClose()
        end)
    elseif target.touchName=="btn_bag" or target.touchName=="btn_bag1" then
        local upgradeSpirit = self.spirit
        self:onClose()
        Panel.popUpVisible(PANEL_SOULLIFE_UPGRADE,upgradeSpirit,SOULLIFE_UPGRADE_TYPE.SOULLIFE,true)
    end
end

function SoulLifeDetailPanel:setExp()
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
    self:getNode("txt_exp_value"):setString(string.format("%d/%d", tmpCurExp, tmpCurUpExp))
    self:setBarPer("bar_exp",tmpCurExp/tmpCurUpExp)

    local spiritAttr  = DB.getSpiritAttr(self.spirit.iType, self.affectLv, self.spirit.iAttr)
    local attrName,attrValue = gGetSpiritAttrNameAndValue(spiritAttr.attr, spiritAttr.value)
    self:getNode("txt_attr_value"):setString(attrValue)
    self:getNode("layout_attr"):layout()
    if spiritAttr.attr2 ~= 0 then
        local attrName2,attrValue2 = gGetSpiritAttrNameAndValue(spiritAttr.attr2, spiritAttr.value2)
        self:getNode("txt_attr_value2"):setString(attrValue2)
        self:getNode("layout_attr2"):layout()
    end
    self:getNode("layout_attr_all"):layout()
end

function SoulLifeDetailPanel:events()
    return {EVENT_ID_SPIRIT_UPGRADE_BY_EXP}
end

function SoulLifeDetailPanel:dealEvent(event, param)
    if event == EVENT_ID_SPIRIT_UPGRADE_BY_EXP then
        -- self:updateSpiritInfo(param)
        self:levUpAction(param)
    end
end

function SoulLifeDetailPanel:updateSpiritInfo(param)
    self:setLabelString("txt_exp_pool", SpiritInfo.exp)
    self.spirit.iLV = param.lev
    self.spirit.iExp = param.curExp
    self:setSpiritLv()
    self:setSpiritAffectLv()
    self:setExp()
end

function SoulLifeDetailPanel:levUpAction(param)
    --升级
    local updatelev = param.lev
    local updateCurExp = param.curExp
    local isLevUp = self.spirit.iLV < updatelev

    local expProPreLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV - 1)
    local expProCurLev = DB.getSpiritExp(self.spirit.iType, self.spirit.iLV)
    local curExp = self.spirit.iExp
    local curUpExp = expProCurLev.exp

    local expPreLev = 0
    if nil ~= expProPreLev then
        expPreLev = expProPreLev.exp
    end

    local maxExp = expProCurLev.exp - expPreLev
    local tmpCurExp = curExp - expPreLev
    local tmpCurUpExp = curUpExp - expPreLev
    if not isLevUp then
        tmpCurUpExp = updateCurExp - expPreLev
    end
    local frame = (tmpCurUpExp - tmpCurExp) / tmpCurUpExp * self.aniFrame
    self:updateBarPer("bar_exp","txt_exp_value",tmpCurExp,tmpCurUpExp, maxExp,frame, function()
            self:levUpCallback(isLevUp,updatelev, updateCurExp)
        end)
end

function SoulLifeDetailPanel:levUpCallback(isLevUp,lev,curExp)
    if isLevUp then
        local upgradeEffect = FlashAni.new()
        upgradeEffect:playAction("ui_minghun_shengji", function()
                                upgradeEffect:removeFromParent()
                            end, nil, 1)
        gAddCenter(upgradeEffect, self:getNode("icon_bg"))
    end
    self:setLabelString("txt_exp_pool", SpiritInfo.exp)
    self.spirit.iLV = lev
    self.spirit.iExp = curExp
    self:setSpiritLv()
    self:setSpiritAffectLv()
    self:setExp()
end

function SoulLifeDetailPanel:setSpiritLv()
    self:getNode("txt_lv"):clear()
    local strLev = tostring(self.spirit.iLV)

    if self.spirit.iPos ~= 0 then
        local addLv = DB.getSpiritAddLevByPos(self.spirit.iPos % 10)
        if addLv ~= 0 then
            strLev = strLev .. "\\w{c=8aff00;s=20;}+"..addLv                   
        end
    end

    self:getNode("txt_lv"):setString(strLev)
    self:getNode("txt_lv"):layout() 
end

function SoulLifeDetailPanel:setSpiritAffectLv()
    local addLv = 0
    if self.spirit.iPos ~= 0 then
        addLv = DB.getSpiritAddLevByPos(self.spirit.iPos % 10)
    end
    self.affectLv = self.spirit.iLV + addLv
end
return SoulLifeDetailPanel