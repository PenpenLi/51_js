local TreasureHuntChooseMapPanel=class("TreasureHuntChooseMapPanel",UILayer)
function TreasureHuntChooseMapPanel:ctor(teamInfo,isLeft)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_team_choose_map.map")
    self.teamInfo = teamInfo
    self.isLeft = isLeft
    self:setLabelString("txt_num1", Data.getItemNum(ITEM_PRI_TREASURE_MAP))
    self:setLabelString("txt_num2", Data.getItemNum(ITEM_MID_TREASURE_MAP))
    self:setLabelString("txt_num3", Data.getItemNum(ITEM_HIG_TREASURE_MAP))
end

function TreasureHuntChooseMapPanel:onTouchEnded(target,touch, event)
    if target.touchName=="icon_map1" then
        if Data.getItemNum(ITEM_PRI_TREASURE_MAP) <= 0 then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_treasure_map"))
            self:onClose()
            return
        end
        self:sendEnterRoomMsg(ITEM_PRI_TREASURE_MAP)
        self:onClose()
    elseif target.touchName=="icon_map2" then
        if Data.getItemNum(ITEM_MID_TREASURE_MAP) <= 0 then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_treasure_map"))
            self:onClose()
            return
        end
        self:sendEnterRoomMsg(ITEM_MID_TREASURE_MAP)
        self:onClose()
    elseif target.touchName=="icon_map3" then
        if Data.getItemNum(ITEM_HIG_TREASURE_MAP) <= 0 then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_treasure_map"))
            self:onClose()
            return
        end
        self:sendEnterRoomMsg(ITEM_HIG_TREASURE_MAP)
        self:onClose()
    elseif target.touchName=="btn_close" then
        self:onClose()
    end
end

function TreasureHuntChooseMapPanel:sendEnterRoomMsg(itemId)
   local groupId = gTreasureHunt.getCurHallId()
   local roomId = self.teamInfo.roomId
   Net.sendCroTreJoinRoom(groupId, roomId, self.isLeft, itemId)
end

return TreasureHuntChooseMapPanel