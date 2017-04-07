MINE_DIG_ICON1 = 1
MINE_DIG_ICON2 = 2
MINE_DIG_ICON3 = 3
MINE_DIG_ICON4 = 4
MINE_DIG_ICON5 = 5
MINE_DIG_ICON6 = 6

MINE_DIG_ICON2_1 = 1
MINE_DIG_ICON2_2 = 2

MINE_DIG_ICON3_1 = 1
MINE_DIG_ICON3_2 = 2

MINE_DIG_ICON4_1 = 1
MINE_DIG_ICON4_2 = 2

MINE_DIG_OPE_ADD  = 1
MINE_DIG_OPE_CHANGE = 2
MINE_DIG_OPE_DEL  = 3

local MineDigIconItem=class("MineDigIconItem",UILayer)

function MineDigIconItem:ctor()
    self:init("ui/ui_dig_mine_item.map")
end

function MineDigIconItem:onTouchEnded(target, touch, event)
    if target.touchName == "icon" then
        self:clickIcon()
    end
end

function MineDigIconItem:setData(type,subType)
    self.type=type
    self.subType=subType
    self:initIconTexture(type)
    self:initTxtShow(type,subType)
end

function MineDigIconItem:initIconTexture(type)
    if type==MINE_DIG_ICON1 then
        self:changeTexture("icon", "images/ui_digmine/niuguaia.png")
    elseif type==MINE_DIG_ICON2 then
        self:changeTexture("icon", "images/ui_digmine/mermaid.png")
    elseif type==MINE_DIG_ICON3 then
        self:changeTexture("icon", "images/ui_digmine/newzhuan.png")
    elseif type==MINE_DIG_ICON4 then
        self:changeTexture("icon", "images/ui_digmine/blackmarket.png")
    elseif type==MINE_DIG_ICON5 then
        self:changeTexture("icon", "images/ui_digmine/kuangshi.png")
    elseif type==MINE_DIG_ICON6 then
        self:changeTexture("icon", "images/ui_digmine/kuanggongicon.png")
    end
end

function MineDigIconItem:initTxtShow(type,subType)
    if type==MINE_DIG_ICON1 then
        self:getNode("txt_lefttime"):setVisible(false)
        self:getNode("txt_num"):setVisible(true)
        self:setLabelString("txt_num", gDigMine.getStatueCount())
    elseif type==MINE_DIG_ICON2 then
        if subType == MINE_DIG_ICON2_1 then
            self:getNode("txt_lefttime"):setVisible(false)
            self:getNode("txt_num"):setVisible(false)
        elseif subType == MINE_DIG_ICON2_2 then
            self:getNode("txt_lefttime"):setVisible(true)
            self:getNode("txt_num"):setVisible(false)
            self:setLabelString("txt_lefttime", gParserMinTimeEx(gDigMine.getMermaidBuyLeftTime() - gGetCurServerTime()))
        end
    elseif type==MINE_DIG_ICON3 then
        if subType == MINE_DIG_ICON3_1 then
            self:getNode("txt_lefttime"):setVisible(false)
            self:getNode("txt_num"):setVisible(false)
        elseif subType == MINE_DIG_ICON3_2 then
            self:getNode("txt_lefttime"):setVisible(true)
            self:getNode("txt_num"):setVisible(false)
            self:setLabelString("txt_lefttime", gParserMinTimeEx(gDigMine.getLuckyWheelLeftTime() - gGetCurServerTime()))
        end
    elseif type==MINE_DIG_ICON4 then
        if subType == MINE_DIG_ICON4_1 then
            self:getNode("txt_lefttime"):setVisible(false)
            self:getNode("txt_num"):setVisible(false)
        elseif subType == MINE_DIG_ICON4_2 then
            self:getNode("txt_lefttime"):setVisible(true)
            self:getNode("txt_num"):setVisible(false)
            self:setLabelString("txt_lefttime", gParserMinTimeEx(gDigMine.getBlackMarketLeftTime() - gGetCurServerTime()))
        end
    elseif type==MINE_DIG_ICON5 or type==MINE_DIG_ICON6 then
        self:getNode("txt_lefttime"):setVisible(false)
        self:getNode("txt_num"):setVisible(false)
    end
end

function MineDigIconItem:clickIcon()
    gDispatchEvt(EVENT_ID_MINING_CLICK_TIPICON, {self.type, self.subType, self.extraInfo})
end

function MineDigIconItem:setExtraInfo(extraInfo)
    self.extraInfo = extraInfo
end

function MineDigIconItem:updateLefttime()
    if self.subType == nil then
        return
    end

    if self.type == MINE_DIG_ICON2 and self.subType == MINE_DIG_ICON2_2 then
        self:setLabelString("txt_lefttime", gParserMinTimeEx(gDigMine.getMermaidBuyLeftTime() - gGetCurServerTime()))
    elseif self.type == MINE_DIG_ICON3 and self.subType == MINE_DIG_ICON3_2 then
        self:setLabelString("txt_lefttime", gParserMinTimeEx(gDigMine.getLuckyWheelLeftTime() - gGetCurServerTime()))
    elseif self.type == MINE_DIG_ICON4 and self.subType == MINE_DIG_ICON4_2 then
        self:setLabelString("txt_lefttime", gParserMinTimeEx(gDigMine.getBlackMarketLeftTime() - gGetCurServerTime()))
    end
end

function MineDigIconItem:updateNum()
    if self.type == MINE_DIG_ICON1 then
        self:setLabelString("txt_num", gDigMine.getStatueCount())
    end
end

return MineDigIconItem