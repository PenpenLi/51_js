local TreasureHuntGroupChoosePanel=class("TreasureHuntGroupChoosePanel",UILayer)
function TreasureHuntGroupChoosePanel:ctor()
    self:init("ui/ui_team_choose_room.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:initGroupInfo()
    self:initSpeakerInfo()
    self:initBuyNumInfo(true)
end

function TreasureHuntGroupChoosePanel:onTouchEnded(target,touch, event)
    if target.touchName~="btn_up" then
        Panel.clearTouchTip()
    end
    if target.touchName=="btn_close" then
        Net.sendCrotreClose(1)
        self:onClose()
    elseif string.find(target.touchName,"icon_group") ~= nil then
        local groupIdx = toint(string.sub(target.touchName, string.len("icon_group") + 1))
        if not self:isLvLimit(groupIdx) then
            Net.sendCroTreRoomInfo(groupIdx, 1, 1)
        end
    elseif target.touchName=="btn_up" then
        if #gTouchTipLayer:getChildren() > 0 then
            Panel.clearTouchTip()
        else
            Panel.popTouchTip(self:getNode(target.touchName), TIP_TREASURE_HUNT_SPEAKER)
        end
    elseif target.touchName == "btn_speaker" then
        Panel.popUp(PANEL_TREASURE_HUNT_SPEAKER)
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_TREASURE_HUNT)
    elseif target.touchName == "btn_buy_map" then
        local callback = function(num)
            Net.sendCrotreBuy(num)
        end
        Data.canBuyTimes(VIP_BUY_TREASURE_MAP,true,callback)
    end
end

function TreasureHuntGroupChoosePanel:events()
    return {
        EVENT_ID_TREASURE_HUNT_ADD_SPEAKER,
        EVENT_ID_TREASURE_HUNT_GROUP_NUM,
        EVENT_ID_TREASURE_HUNT_BUY_MAP,
    }
end

function TreasureHuntGroupChoosePanel:dealEvent(event, param)
    if event == EVENT_ID_TREASURE_HUNT_ADD_SPEAKER then
        self:getNode("txt_speaker_info"):stopAllActions()
        local contentSize = self:getNode("layer_scroll_speaker"):getContentSize()
        self:getNode("txt_speaker_info"):setPositionX(contentSize.width)
        self:initSpeakerInfo()
    elseif event == EVENT_ID_TREASURE_HUNT_GROUP_NUM then
        local size = DB.getTreasureHuntSize()
        for i = 1, size do
            self:setLabelString("txt_num"..i, gTreasureHunt.getHallInfo(i).num)
        end
    elseif event == EVENT_ID_TREASURE_HUNT_BUY_MAP then
        if param == 1 then
            self:getNode("layer_buy_map"):setVisible(false)
            self.hideLayerBuyMap = true
        else
            self:initBuyNumInfo()
        end
    end
end

function TreasureHuntGroupChoosePanel:initGroupInfo()
    local size = DB.getTreasureHuntSize()
    for i = 1, size do
        local treasureHuntHallInfo = DB.getTreasureHuntHallInfo(i)
        if i ~= 4 then
            local str = gGetWords("treasureHuntWord.plist","txt_lv_limit", treasureHuntHallInfo.minlevel, treasureHuntHallInfo.maxlevel);
            if isBanshuReview() then
                str = "等级."..treasureHuntHallInfo.minlevel.."-"..treasureHuntHallInfo.maxlevel;
            end
            self:setLabelString("txt_lv"..i, str);
        end
        if isBanshuReview() then
            self:setLabelString("txt_lv4", "等级不限");
        end
        self:getNode("layout_lv"..i):layout()
        if treasureHuntHallInfo.addper ~= 0 then
            self:getNode("layer_add_attr"..i):setVisible(true)
            self:setLabelString("txt_add_attr"..i, gGetMapWords("ui_team_choose_room.plist", "9", treasureHuntHallInfo.addper))
        else
            self:getNode("layer_add_attr"..i):setVisible(false)
        end
        self:setLabelString("txt_num"..i, gTreasureHunt.getHallInfo(i).num)
    end
end

function TreasureHuntGroupChoosePanel:initSpeakerInfo()
    local speakerInfo = gTreasureHunt.getSpeakerInfo(#gTreasureHunt.speakerInfos)
    if speakerInfo == nil or speakerInfo.str == "" then
        self:setLabelString("txt_speaker_info", "")
        return
    end

    local txtInfo = string.format("%s(%s):%s",speakerInfo.name,speakerInfo.severName,speakerInfo.str)
    local contentSize = self:getNode("layer_scroll_speaker"):getContentSize()
    self:setLabelString("txt_speaker_info", txtInfo)
    local labelContentSize = self:getNode("txt_speaker_info"):getContentSize()
    self:getNode("txt_speaker_info"):setPositionX(contentSize.width)
    local move_feed = (contentSize.width + labelContentSize.width) / 50
    self:getNode("txt_speaker_info"):stopAllActions()

    local sequence = cc.Sequence:create(cc.MoveBy:create(move_feed, cc.p(-(contentSize.width + labelContentSize.width), 0)),
                                cc.CallFunc:create(function( ... )
                                    self:getNode("txt_speaker_info"):setPositionX(contentSize.width)
                                end ))
    self:getNode("txt_speaker_info"):runAction(cc.RepeatForever:create(sequence))
end

function TreasureHuntGroupChoosePanel:isLvLimit(idx)
    if idx == 4 then
        return false
    end

    local treasureHuntHallInfo = DB.getTreasureHuntHallInfo(idx)

    if Data.getCurLevel() < treasureHuntHallInfo.minlevel or Data.getCurLevel() > treasureHuntHallInfo.maxlevel then
        gShowNotice(gGetWords("treasureHuntWord.plist","txt_group_enter_lim"))
        return true
    end
    
    return false
end

function TreasureHuntGroupChoosePanel:initBuyNumInfo(init)
    if init then
        local treasureHuntIntervalInfo = Data.getHuntIntervalInfos(HUNT_ID_MAP[2])

        if treasureHuntIntervalInfo.interval > 0 then
            self:getNode("layer_buy_map"):setVisible(false)
            self.hideLayerBuyMap = true
            return
        end
    end

    if self.hideLayerBuyMap then
        return
    end

    local buyNum = Data.getUsedTimes(VIP_BUY_TREASURE_MAP)
    local price = Data.getBuyPriceAndCount(VIP_BUY_TREASURE_MAP)
    local leftTime = DB.getTreasureHuntMaxBuy() - buyNum
    self:setLabelString("txt_buy_left_num", gGetMapWords("ui_team_choose_room.plist","13",leftTime))
    local isCanBuy = (leftTime > 0)
    self:setTouchEnable("btn_buy_map", isCanBuy, not isCanBuy)
    RedPoint.refresh(self:getNode("btn_buy_map"), price == 0, cc.p(0.8,0.8))
end

return TreasureHuntGroupChoosePanel