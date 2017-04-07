local TipFamilyStageChaRecPanel=class("TipFamilyStageChaRecPanel",UILayer)

function TipFamilyStageChaRecPanel:ctor()
    self.appearType = 1
    self:init("ui/tip_family_stage_cha_desc.map")
    self:setData()
end

function TipFamilyStageChaRecPanel:setData()
    
    if #gFamilyStageInfo.harmDetailList == 0 then
        return
    end
    local name = ""
    local rate = ""
    local idx = 1
    self:getNode("scroll"):setPaddingXY(2,5)
    self:getNode("scroll").offsetX = 18
    self:getNode("scroll").offsetY = 8
    for i, harmDetail in ipairs(gFamilyStageInfo.harmDetailList) do
        local item = RTFLayer.new(self:getNode("scroll"):getContentSize().width-5)
        item:setAnchorPoint(cc.p(0,1))
        item:setDefaultConfig(gFont,20,cc.c3b(255,245,140))
        local harm = string.format("%0.2f%%", harmDetail.harm / 100)
        local word = gGetWords("familyWords.plist","txt_stage_fight_desc",harmDetail.name, harm)
        item:setString(word)
        item:layout()
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
end

return TipFamilyStageChaRecPanel