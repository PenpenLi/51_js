local SoulLifeAutoChoosePanel=class("SoulLifeAutoChoosePanel",UILayer)
local chooseCount = 4

local chooseType  = {SPIRIT_TYPE.GUI, SPIRIT_TYPE.REN,SPIRIT_TYPE.DI,SPIRIT_TYPE.SHEN}
function SoulLifeAutoChoosePanel:ctor(spiritType)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_soullife_autochoose.map")
    self.spiritType = spiritType
    self.choosed = {false, false, false, false}
    self:initPanel()
end

function SoulLifeAutoChoosePanel:initPanel()
    for i = 1, chooseCount do
        SpiritInfo.autoChooseFlag[i]=false
        self:getNode("icon_choose"..i):setVisible(false)
    end
end

function SoulLifeAutoChoosePanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif string.find(target.touchName, "icon_bg") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("icon_bg")+1))
        if self:canChoose(pos) then
            SpiritInfo.autoChooseFlag[pos] = not SpiritInfo.autoChooseFlag[pos]
            self:showChoose(pos, SpiritInfo.autoChooseFlag[pos])
        end
    elseif target.touchName == "btn_ok" then
        self:onClose()
        gDispatchEvt(EVENT_ID_SPIRIT_AUTO_CHOOSE)
    end
end

function SoulLifeAutoChoosePanel:showChoose(pos, choose)
    self:getNode("icon_choose"..pos):setVisible(choose)
end

function SoulLifeAutoChoosePanel:canChoose(pos)
    if self.spiritType < chooseType[pos] then
        gShowNotice(gGetWords("spiritWord.plist", "spirit_upgrade_no_select"))
        return false
    end

    return true
end

return SoulLifeAutoChoosePanel