local TreasureHuntRecordPanel=class("TreasureHuntRecordPanel",UILayer)

function TreasureHuntRecordPanel:ctor()
    self:init("ui/ui_treasure_hunt_record.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:selectBtn("btn_escort")
    self:showEscort()
    self.curType = escortTag
end

function TreasureHuntRecordPanel:events()
    return {
        EVENT_ID_TREASURE_HUNT_RECORD_DETAIL,
    }
end

function TreasureHuntRecordPanel:dealEvent(event, data)
    if event == EVENT_ID_TREASURE_HUNT_RECORD_DETAIL then
        Panel.popUp(PANEL_TREASURE_HUNT_PROGRESS_DETAIL, 2)
    end
end

function TreasureHuntRecordPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_escort" then
        self:selectBtn("btn_escort")
        self:showEscort()
    elseif target.touchName=="btn_ambush" then
        self:selectBtn("btn_ambush")
        self:showAmbush()
    end
end

function TreasureHuntRecordPanel:selectBtn(name)
    self:resetBtnTex()
    self:changeTexture(name,"images/ui_public1/b_biaoqian4.png")
end

function TreasureHuntRecordPanel:resetBtnTex()
    local btns={
        "btn_escort",
        "btn_ambush",
    }

    for _, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function TreasureHuntRecordPanel:showEscort()
    self:getNode("scroll"):clear()
    for _,var in ipairs(gTreasureHunt.escortList) do
        local recordItem = TreasureHuntRecordItem.new()
        recordItem:setData(var, 1)
        self:getNode("scroll"):addItem(recordItem)
    end
    self:getNode("scroll"):layout()
end

function TreasureHuntRecordPanel:showAmbush()
    self:getNode("scroll"):clear()
    for _,var in ipairs(gTreasureHunt.ambushList) do
        local recordItem = TreasureHuntRecordItem.new()
        recordItem:setData(var, 2)
        self:getNode("scroll"):addItem(recordItem)
    end
    self:getNode("scroll"):layout()
end

return TreasureHuntRecordPanel