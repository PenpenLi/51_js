local TreasureHuntStageRecordPanel=class("TreasureHuntStageRecordPanel",UILayer)

function TreasureHuntStageRecordPanel:ctor()
    self:init("ui/ui_treasure_hunt_stage_record.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:initPanel()
end

function TreasureHuntStageRecordPanel:initPanel()
    -- 护送方胜利
    if gTreasureHunt.fightRetInfo.winner == 0 then
        self:changeTexture("top_win_flag2", "images/ui_jingji/shibai.png")
    else
        self:changeTexture("top_win_flag1", "images/ui_jingji/shibai.png")
        self:setLabelString("txt_win_info", gGetWords("treasureHuntWord.plist","txt_escort_fail"))
    end

    local fightRetSize = #gTreasureHunt.fightRetInfo.infos
    for i = 1, fightRetSize do
        local info = gTreasureHunt.fightRetInfo.infos[i]
        if info.winner == 0 then
            self:changeTexture("win2_"..i, "images/ui_jingji/shibai.png")
        else
            self:changeTexture("win1_"..i, "images/ui_jingji/shibai.png")
        end

        self:setPlayerInfo(i, 1, info.player1)
        self:setPlayerInfo(i, 2, info.player2)
        self:getNode("btn_replay"..i).vid = info.vid
        self:getNode("btn_replay"..i):setVisible(info.vid ~= 0)
    end

    for i = fightRetSize + 1, 2 do
        self:getNode("layer_record"..i):setVisible(false)
    end
end

function TreasureHuntStageRecordPanel:setPlayerInfo(idx, playerIdx, playerInfo)
    self:setLabelString(string.format("txt_lv%d_%d",playerIdx,idx), string.format("%s%d", getLvReviewName("Lv."),playerInfo.lv))
    self:setLabelString(string.format("txt_down%d_%d",playerIdx,idx), string.format("%d%%",math.abs(playerInfo.add - 100)))
    if playerInfo.add == 100 then
        self:getNode(string.format("icon_down%d_%d",playerIdx,idx)):setVisible(false)
        self:getNode(string.format("txt_down%d_%d",playerIdx,idx)):setVisible(false)
    elseif playerInfo.add > 100 then
        self:changeTexture(string.format("icon_down%d_%d",playerIdx,idx), "images/ui_public1/jiantou_green.png")
        self:getNode(string.format("txt_down%d_%d",playerIdx,idx)):setColor(cc.c3b(120, 250, 0))
    end
    self:setLabelString(string.format("txt_name%d_%d",playerIdx,idx), playerInfo.userName)
    self:setLabelString(string.format("txt_power%d_%d",playerIdx,idx), playerInfo.power)
    Icon.setHeadIcon(self:getNode(string.format("icon%d_%d",playerIdx,idx)), playerInfo.icon)
end

function TreasureHuntStageRecordPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_replay1" or target.touchName=="btn_replay2" then
        local func = function()
            local function callback()
                if gMainBgLayer == nil then
                    Scene.enterMainScene()
                end
                Panel.popUp(PANEL_HUNT)
                Net.sendCroTreRoomInfo(gTreasureHunt.curHallId, gTreasureHunt.curRoomPage, 1, true)
            end
            Net.sendCroTreHallInfo(callback)
        end
        Panel.pushRePopupPre(func)
        Net.sendCrotreVedio(self:getNode(target.touchName).vid)
    end
end


return TreasureHuntStageRecordPanel