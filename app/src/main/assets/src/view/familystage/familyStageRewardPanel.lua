local FamilyStageRewardPanel=class("FamilyStageRewardPanel",UILayer)

function FamilyStageRewardPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_family_stage_reward.map")
    self.isWindow = true
    self:initPanel()
    self:showType(1)
end

function FamilyStageRewardPanel:initPanel(type)
    self.scroll = self:getNode("scroll")
    self.scroll.eachLineNum = 1
    self.scroll:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
end

function FamilyStageRewardPanel:showType(type)
    self.scroll:clear()
    self:selectBtn("btn_type"..type)
    local winFlag = 1
    if type ~= 1 then
        winFlag = 0
    end

    local averPowers = DB.getFamilyStageRewardPowers()
    local powerSize = #averPowers
    local averPow = averPowers[1]
    for i = 1, powerSize - 1 do
        if gFamilyStageInfo.power > averPowers[i] and gFamilyStageInfo.power <= averPowers[i + 1] then
            averPow = averPowers[i + 1]
            break
        end
    end

    if gFamilyStageInfo.power > averPowers[powerSize] then
        averPow = averPowers[powerSize]
    end

    local rewards = DB.getFamilyStageRewardsByFlag(winFlag, averPow)
    for _, rewardInfo in pairs(rewards) do
        local rewardItem = FamilyStageRewardItem.new(rewardInfo)
        self.scroll:addItem(rewardItem)
    end

    self.scroll:layout()
end


function FamilyStageRewardPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    end
end

function   FamilyStageRewardPanel:resetBtnTexture()

    local btns={ 
        "btn_type1",
        "btn_type2",
    }
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
        self:setTouchEnable( btn,true)
    end

end

function  FamilyStageRewardPanel:selectBtn(btn)
    self:resetBtnTexture()
    self:changeTexture(btn,"images/ui_public1/b_biaoqian4.png")
end

function FamilyStageRewardPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_type1"then
        self:showType(1)
    elseif target.touchName=="btn_type2"then
        self:showType(2)
    end
end

return FamilyStageRewardPanel