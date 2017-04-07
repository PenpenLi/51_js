local TreasureHuntRecordItem=class("TreasureHuntRecordItem",UILayer)
local itemTypeEscort = 1
local itemTypeAmbush = 2
function TreasureHuntRecordItem:ctor()
    self:init("ui/ui_treasure_hunt_record_item.map")
end

function TreasureHuntRecordItem:setData(data,itemType)
    self.data = data
    self.itemType = itemType
    self:changeTexture("treasure_map1", string.format("images/icon/item/%d.png", data.tmapId1))
    self:changeTexture("treasure_map2", string.format("images/icon/item/%d.png", data.tmapId2))

    if self.itemType == itemTypeEscort then
        self:getNode("layout_escort"):setVisible(true)
        self:getNode("txt_escort_info"):setVisible(true)
        self:getNode("txt_ambsuh_info"):setVisible(false)
        self:getNode("txt_ambush_reward"):setVisible(false)
        self:setLabelString("txt_battle_num", gGetMapWords("ui_treasure_hunt_record_item.plist", "3", data.battleNum))
        self:setLabelString("txt_win_num", gGetMapWords("ui_treasure_hunt_record_item.plist", "4", data.winNum))
        self:setLabelString("txt_lose_num", gGetMapWords("ui_treasure_hunt_record_item.plist", "5", data.loseNum))
        self:setRTFString("txt_escort_info", gGetWords("treasureHuntWord.plist","txt_escort_record_info", data.userName1,data.userName2,data.pro))
    else
        self:getNode("layout_escort"):setVisible(false)
        self:getNode("txt_escort_info"):setVisible(false)
        self:getNode("txt_ambsuh_info"):setVisible(true)
        self:getNode("txt_ambush_reward"):setVisible(true)
        self:setRTFString("txt_ambsuh_info", gGetWords("treasureHuntWord.plist","txt_ambush_record_info"..data.retType, data.userName1,data.userName2))
        if data.retType == 0 then
            self:setLabelString("txt_ambush_reward", gGetWords("treasureHuntWord.plist","txt_ambush_record_ret0",data.pro))
        else
            self:setLabelString("txt_ambush_reward", gGetWords("treasureHuntWord.plist","txt_ambush_record_ret1"))
        end
        

    end
end

function TreasureHuntRecordItem:onTouchEnded(target,touch, event)
    if target.touchName=="btn_detail" then
        Net.sendCrotreGetrecInfo(self.data.mapId)
    end
end


return TreasureHuntRecordItem