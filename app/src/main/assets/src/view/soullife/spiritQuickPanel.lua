local SpiritQuickPanel=class("SpiritQuickPanel",UILayer)

local GOLD_COST_SUB = 1
local GOLD_COST_ADD = 2
local GOLD_COST_MAX = 3
local GOLD_STEP     = 100000

function SpiritQuickPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_xunxian_quick.map")
    self:getNode("gold_input"):setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self:initVipTxtShow()
    self:initDiscount()
    self:handleChooseFlag(0)
    self.chooseType = SPIRIT_TYPE.GUI
    self:initInputText()
    gSetLabelScroll(self:getNode("tip"));
end

function SpiritQuickPanel:onTouchEnded(target,touch, event)

    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_ok" then
        if not Unlock.isUnlock(SYS_SPIRIT_QUICK,true) then
            return
        end
        self:onClose()
        if not SpiritInfo.isFindLimited(10) and self:isGoldEnough() and (not SpiritInfo.checkSpiritExpFull()) then
            local paramTable = {self.chooseType, toint(self:getNode("gold_input"):getText())}
            gDispatchEvt(EVENT_ID_SPIRIT_QUICK_CHOOSE, paramTable)
            if (TDGAMission) then 
                gLogMissionBegin("quick_sprit_find")
            end
        end
    elseif nil ~= target.touchName and string.find(target.touchName, "icon_bg") ~= nil then
        local startIdx, endIdx = string.find(target.touchName, "icon_bg")
        local pos = toint(string.sub(target.touchName,endIdx + 1, -1))
        self:handleChooseFlag(pos)
    elseif target.touchName=="btn_sub" then
        self:processGoldCost(GOLD_COST_SUB)
    elseif target.touchName=="btn_add" then
        self:processGoldCost(GOLD_COST_ADD)
    elseif target.touchName=="btn_max" then
        self:processGoldCost(GOLD_COST_MAX)
    end
end

function SpiritQuickPanel:handleChooseFlag(pos)

    if not Unlock.isUnlock(SYS_SPIRIT_QUICK,true) then
        return
    end

    self.chooseType = pos
    for i = SPIRIT_TYPE.GUI, SPIRIT_TYPE.SHEN do
        self:getNode("icon_choosed"..i):setVisible(i == pos)
    end
end

function SpiritQuickPanel:initVipTxtShow()
    local info = gGetWords("spiritWord.plist","quick_xunxian_vip", DB.getMinVipLevForQuickFind())
    for i = SPIRIT_TYPE.GUI, SPIRIT_TYPE.SHEN do
        self:getNode("txt_vip"..i):setString(info)
    end
end

function SpiritQuickPanel:initInputText()
    local function onEditCallback(name, sender)
        if name=="ended" then
            self:inputEnded()
        end
    end
    self:getNode("gold_input"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("gold_input"):setMaxLength(11)
    self:getNode("gold_input"):setText(0)
    self:getNode("layout_gold"):layout()
end

function SpiritQuickPanel:inputEnded()
    local goldInput = toint(self:getNode("gold_input"):getText())
    if goldInput >= Data.getCurGold() then
        goldInput = Data.getCurGold()
        self:getNode("gold_input"):setText(tostring(goldInput))
        self:getNode("layout_gold"):layout()
    end
end

function SpiritQuickPanel:processGoldCost(proessType)
    local goldInput = toint(self:getNode("gold_input"):getText())
    local curGold = goldInput
    if proessType == GOLD_COST_SUB then
        curGold = curGold - GOLD_STEP
        if curGold <= 0 then
            gShowNotice(gGetWords("spiritWord.plist","spirit_quick_cost_no_empty"))
        else
            self:getNode("gold_input"):setText(tostring(curGold))
            self:getNode("layout_gold"):layout()
        end
    elseif proessType == GOLD_COST_ADD then
        curGold = curGold + GOLD_STEP
        if curGold > Data.getCurGold() then
            gShowNotice(gGetWords("spiritWord.plist","spirit_quick_cost_no_enough"))
        else
            self:getNode("gold_input"):setText(tostring(curGold))
            self:getNode("layout_gold"):layout()
        end
    elseif proessType == GOLD_COST_MAX then
        self:getNode("gold_input"):setText(tostring(Data.getCurGold()))
        self:getNode("layout_gold"):layout()
    end
end

function SpiritQuickPanel:isGoldEnough()
    local goldInput = toint(self:getNode("gold_input"):getText())
    if goldInput > Data.getCurGold() then
        NetErr.noEnoughGold()
        return false
    end
    return true
end

function SpiritQuickPanel:initDiscount()
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

    if showDiscount then
        self:setRTFString("txt_discount", gGetMapWords("ui_xunxian_quick.plist","3",disCount))
    end
    self:getNode("txt_discount"):setVisible(showDiscount)
end

return SpiritQuickPanel
