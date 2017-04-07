local FamilyStageBuffUpPanel=class("FamilyStageBuffUpPanel",UILayer)

function FamilyStageBuffUpPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_family_stage_buff_up.map")
    self.__tip=true
    self.leveluping = false
    self.aniFrame = 60
    self:setPanelInfo()
end


function FamilyStageBuffUpPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_up" then
        if self.leveluping then
            return
        end
        local maxTimes = Data.getMaxUseTimes(VIP_FAMILY_BUFF_UP)
        local useTimes = Data.getUsedTimes(VIP_FAMILY_BUFF_UP)
        if useTimes >= maxTimes then
            gShowNotice(gGetWords("noticeWords.plist","no_family_stage_buff_up_num"))
            return
        end

        if Data.getCurDia() < self.nextPrice then
            NetErr.noEnoughDia()
            return
        end
        Net.sendFamilyStageBuffUp()
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_FAMILY_STAGE_BUFF_UP)
    end
end

function FamilyStageBuffUpPanel:events()
    return {
        EVENT_ID_FAMILY_STAGE_REFRESH_INFO,
    }
end

function FamilyStageBuffUpPanel:dealEvent(event, param)
    if event == EVENT_ID_FAMILY_STAGE_REFRESH_INFO then
        local updateLv = gFamilyStageInfo.buff.lv
        local updateCurExp = gFamilyStageInfo.buff.exp
        local isLvUp = self.curLv < updateLv
        if isLvUp then
            gShowNotice(gGetWords("noticeWords.plist","family_stage_buff_lv_up"))
        else
            local curBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv)
            local lastBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv - 1)
            local lastLvFullExp = 0
            if nil ~= lastBuffLvInfo then
                lastLvFullExp = lastBuffLvInfo.exp
            end

            local maxExp = curBuffLvInfo.exp - lastLvFullExp
            local tmpCurExp = self.curExp - lastLvFullExp
            local tmpCurUpExp = updateCurExp - lastLvFullExp
            gShowNotice(gGetWords("noticeWords.plist","family_stage_buff_rate_up", tmpCurUpExp - tmpCurExp))
        end

        self:lvUpAction()
    end
end

function FamilyStageBuffUpPanel:refreshInfo(refreshType)

end

function FamilyStageBuffUpPanel:setPanelInfo(init)
    self.curLv  = gFamilyStageInfo.buff.lv
    self.curExp = gFamilyStageInfo.buff.exp
    local maxLv = DB.getFamilyStageBuffMaxLv()
    local str_no = gGetWords("arenaWords.plist", "lab_no")
    local curBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv)
    local lastLvFullExp = 0
    local lastBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv - 1)
    if nil ~= lastBuffLvInfo then
        lastLvFullExp = lastBuffLvInfo.exp
    end
    local nextBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv + 1)

    self:setLabelString("txt_lv1", gGetMapWords("ui_family_stage_buff_up.plist", "8", self.curLv))

    local curRate = (self.curExp - lastLvFullExp) / (curBuffLvInfo.exp - lastLvFullExp)
    if nil ~= nextBuffLvInfo and self.curLv ~= maxLv then
        self:setBarPer("bar_exp", curRate)
        self:setLabelString("bar_txt_value", string.format("%d/%d", self.curExp - lastLvFullExp, curBuffLvInfo.exp - lastLvFullExp))
        self:setLabelString("txt_lv2", gGetMapWords("ui_family_stage_buff_up.plist", "8", self.curLv + 1))
    else
        self:setBarPer("bar_exp", 0)
        self:setLabelString("bar_txt_value", "MAX")
        self:setLabelString("txt_lv2",str_no)
        self:getNode("txt_lv2"):setColor(cc.c3b(255, 0, 0))
        self:getNode("layout_exp_bar"):setVisible(false)
    end

    self:setAttrValue(curBuffLvInfo, nextBuffLvInfo)
    self:setUseTimes()
    self:setPrice(nextBuffLvInfo)
end

function FamilyStageBuffUpPanel:setNextCostInfo()
    if self.nextPrice == -1 then
        self:getNode("layout_cost"):setVisible(false)
        return
    end

    if self.nextPrice == 0 then
        self:getNode("icon_gold"):setVisible(false)
        self:setLabelString("txt_price", gGetWords("labelWords.plist", "lab_free"))
    else
        self:getNode("icon_gold"):setVisible(true)
        self:setLabelString("txt_price", self.nextPrice)
    end
    self:getNode("layout_cost"):layout()
end

function FamilyStageBuffUpPanel:setAttrValue(curBuffLvInfo, nextBuffLvInfo)
    local attrName = ""
    local attrValue1 = 0
    local attrValue2 = 0
    local maxLv = DB.getFamilyStageBuffMaxLv()
    local str_no = gGetWords("arenaWords.plist", "lab_no")
    for i,value in ipairs(gFamilyStageInfo.baseAttr) do
        if i == 1 then
            attrName = gGetWords("cardAttrWords.plist", "attr1")
        elseif i == 2 then
            attrName = gGetWords("cardAttrWords.plist", "attr3")
        elseif i == 3 then
            attrName = gGetWords("cardAttrWords.plist", "attr5")
        elseif i == 4 then
            attrName = gGetWords("cardAttrWords.plist", "attr6")
        end
        attrValue1 = value * (curBuffLvInfo.percent / 100)
        self:setLabelString(string.format("txt_attr%d_1",i), string.format("%s+%d",attrName, attrValue1))
        if nil ~= nextBuffLvInfo and self.curLv ~= maxLv then
            attrValue2 = value * (nextBuffLvInfo.percent / 100)
            self:setLabelString(string.format("txt_attr%d_2",i), string.format("%s+%d",attrName, attrValue2))
        else
            self:setLabelString(string.format("txt_attr%d_2",i), str_no)
            self:getNode(string.format("txt_attr%d_2",i)):setColor(cc.c3b(255, 0, 0))
        end
    end    
end

function FamilyStageBuffUpPanel:setUseTimes()
    local maxTimes = Data.getMaxUseTimes(VIP_FAMILY_BUFF_UP)
    local useTimes = Data.getUsedTimes(VIP_FAMILY_BUFF_UP)
    local leftTimes = maxTimes - useTimes
    if leftTimes < 0 then
        leftTimes = 0
    end
    self:setLabelString("txt_buff_num", string.format("%d/%d", leftTimes, maxTimes))
    self:getNode("layout_buff_num"):layout()
end

function FamilyStageBuffUpPanel:setPrice(nextBuffLvInfo)
    local maxLv = DB.getFamilyStageBuffMaxLv()
    local useTimes = Data.getUsedTimes(VIP_FAMILY_BUFF_UP)
    if nil ~= nextBuffLvInfo and self.curLv ~= maxLv then
        self.nextPrice = DB.getFamilyStageBuffupPrice(useTimes+1)
        self:setNextCostInfo()
    else
        self:getNode("btn_up"):setVisible(false)
        self:getNode("layout_cost"):setVisible(false)
    end
end

function FamilyStageBuffUpPanel:lvUpAction()
    local updateLv = gFamilyStageInfo.buff.lv
    local updateCurExp = gFamilyStageInfo.buff.exp
    local isLvUp = self.curLv < updateLv

    local curBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv)
    local lastBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv - 1)
    local lastLvFullExp = 0

    if nil ~= lastBuffLvInfo then
        lastLvFullExp = lastBuffLvInfo.exp
    end

    local maxExp = curBuffLvInfo.exp - lastLvFullExp
    local tmpCurExp = self.curExp - lastLvFullExp
    local tmpCurUpExp = curBuffLvInfo.exp - lastLvFullExp
    if not isLvUp then
        tmpCurUpExp = updateCurExp - lastLvFullExp
    end

    local frame = (tmpCurUpExp - tmpCurExp) / tmpCurUpExp * self.aniFrame
    self:updateBarPer("bar_exp","bar_txt_value", tmpCurExp, tmpCurUpExp, maxExp, frame, function()
        self:LvUpCallback(isLvUp)
    end)
end

function FamilyStageBuffUpPanel:LvUpCallback(isLvUp)
    if isLvUp then
        self.curExp = DB.getFamilyStageBuffLvInfo(self.curLv).exp
        self.curLv  = self.curLv + 1
        if self.curLv == DB.getFamilyStageBuffMaxLv() then
            self:setMaxLvShow()
        else
            self:lvUpAction()
        end
    else
        local maxLv = DB.getFamilyStageBuffMaxLv()
        local str_no = gGetWords("arenaWords.plist", "lab_no")
        self.curExp = gFamilyStageInfo.buff.exp
        local curBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv)
        local lastLvFullExp = 0
        local lastBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv - 1)
        if nil ~= lastBuffLvInfo then
            lastLvFullExp = lastBuffLvInfo.exp
        end
        local nextBuffLvInfo = DB.getFamilyStageBuffLvInfo(self.curLv + 1)

        local curRate = (self.curExp - lastLvFullExp) / (curBuffLvInfo.exp - lastLvFullExp)
        if nil ~= nextBuffLvInfo and maxLv ~= self.curLv then
            self:setLabelString("bar_txt_value", string.format("%d/%d", self.curExp - lastLvFullExp, curBuffLvInfo.exp - lastLvFullExp))
            self:setLabelString("txt_lv1", gGetMapWords("ui_family_stage_buff_up.plist", "8", self.curLv))
            self:setLabelString("txt_lv2", gGetMapWords("ui_family_stage_buff_up.plist", "8", self.curLv + 1))
        else
            self:setLabelString("txt_lv2", str_no)
            self:getNode("txt_lv2"):setColor(cc.c3b(255, 0, 0))
            self:getNode("layout_exp_bar"):setVisible(false)
            self:setTouchEnable("btn_up", false, true)
        end

        self:setAttrValue(curBuffLvInfo, nextBuffLvInfo)
        self:setUseTimes()
        self:setPrice(nextBuffLvInfo)
    end
end

function FamilyStageBuffUpPanel:setMaxLvShow()
    local str_no = gGetWords("arenaWords.plist", "lab_no")
    self:setLabelString("txt_lv1", gGetMapWords("ui_family_stage_buff_up.plist", "8", self.curLv))
    self:setLabelString("bar_txt_value", "MAX")
    self:setLabelString("txt_lv2", str_no)
    self:getNode("txt_lv2"):setColor(cc.c3b(255, 0, 0))
    self:setTouchEnable("btn_up", false, true)
    self:setAttrValue(curBuffLvInfo, nextBuffLvInfo)
    self:setUseTimes()
    self:setPrice(nextBuffLvInfo) 
end

return FamilyStageBuffUpPanel