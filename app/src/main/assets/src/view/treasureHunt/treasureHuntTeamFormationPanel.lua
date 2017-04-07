local TreasureHuntTeamFormationPanel=class("TreasureHuntTeamFormationPanel",UILayer)
local roomNumInOnePage = 4
local teamInfoTag = 10
function TreasureHuntTeamFormationPanel:ctor()
    self:init("ui/ui_team_room.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:initPanel()
    self:initTeamContainer()
    self:initSpeakerInfo()
    self:initNoticeInfo()
    self:setRecordRedPos()
end

function TreasureHuntTeamFormationPanel:onTouchEnded(target,touch, event)
    if target.touchName~="btn_up" then
        Panel.clearTouchTip()
    end
    if target.touchName=="btn_close" then
        Net.sendCrotreClose(2)
        self:onClose()
    elseif target.touchName=="btn_quick_find" then
        if gTreasureHunt.getCurInRoomStatus() then
            Net.sendCrotreOpenroom()
        else
            Net.sendCrotreFjoin(gTreasureHunt.getCurHallId())
        end
    elseif target.touchName=="btn_quick_ambush" then
        if gTreasureHunt.getCurAmbushStatus() then
            Net.sendCrotreOpenlurk()
        else
            if gTreasureHunt.getAmbushCdTime() > gGetCurServerTime() then
                gShowNotice(gGetWords("treasureHuntWord.plist","txt_ambush_cd"))
                return
            end
            Net.sendCrotreFlurk(gTreasureHunt.getCurHallId())
        end
    elseif target.touchName=="btn_notice_detail" then
        Panel.popUp(PANEL_TREASURE_HUNT_NOTICE)
    elseif target.touchName=="btn_goto" then
        local noticeInfo = gTreasureHunt.noticeList[#gTreasureHunt.noticeList]
        if self:getNode("btn_goto").type == 0 then
            Net.sendCrotreNotijoin(noticeInfo.groupId, noticeInfo.roomId, noticeInfo.mapId)
        else
            Net.sendCrotreGetrecInfo(noticeInfo.mapId)
        end
    elseif target.touchName=="btn_last" then
        self:queryPageInfo(self.curPage - 1)
    elseif target.touchName=="btn_next" then
        self:queryPageInfo(self.curPage + 1)
    elseif target.touchName=="btn_up" then
        if #gTouchTipLayer:getChildren() > 0 then
            Panel.clearTouchTip()
        else
            Panel.popTouchTip(self:getNode(target.touchName), TIP_TREASURE_HUNT_SPEAKER)
        end
    elseif target.touchName=="btn_record" then
        Data.redpos.treasurehUntRecord = false
        self:setRecordRedPos()
        Net.sendCrotreGetreclist()
    elseif target.touchName=="btn_formation" then
        Panel.popUp(PANEL_ATLAS_FORMATION, TEAM_TYPE_CROSS_TREASURE)
    elseif target.touchName == "btn_speaker" then
        Panel.popUp(PANEL_TREASURE_HUNT_SPEAKER)
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_TREASURE_HUNT_TEAM)
    end
end

function TreasureHuntTeamFormationPanel:events()
    return {
        EVENT_ID_TREASURE_HUNT_JOIN_ROOM,
        EVENT_ID_TREASURE_HUNT_REFRESH_MEMBER,
        EVENT_ID_TREASURE_HUNT_MEMBER_LEAVE,
        EVENT_ID_TREASURE_HUNT_START_CHOOSE,
        EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH,
        EVENT_ID_TREASURE_HUNT_TEAM_BEGIN_FIGHT,
        EVENT_ID_TREASURE_HUNT_CLEAR_TEAM,
        EVENT_ID_TREASURE_HUNT_RECORD_LIST,
        EVENT_ID_TREASURE_HUNT_ADD_SPEAKER,
        EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH_NUM,
        EVENT_ID_TREASURE_HUNT_REFRESH_INFORMATION,
        EVENT_ID_TREASURE_HUNT_NOTICE_OPER,
        EVENT_ID_TREASURE_HUNT_RECORD_DETAIL,
        EVENT_ID_TREASURE_HUNT_FRESH_REDPOS,
    }
end

function TreasureHuntTeamFormationPanel:dealEvent(event, param)
    if event == EVENT_ID_TREASURE_HUNT_JOIN_ROOM then
        if Net.sendTreasureHuntJoinRoom ~= nil then
            self:refreshTeamJoin(Net.sendTreasureHuntJoinRoom.rId)
        end
    elseif event == EVENT_ID_TREASURE_HUNT_REFRESH_MEMBER then
        self:refreshOneTeamInfo(param)
    elseif event == EVENT_ID_TREASURE_HUNT_MEMBER_LEAVE then
        self:oneLeaveTeam(param)
    elseif event == EVENT_ID_TREASURE_HUNT_START_CHOOSE then
        self:refreshTeamChoosePath(param)
    elseif event == EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH then
        self:refreshAmbushInfo(param)
    elseif event == EVENT_ID_TREASURE_HUNT_TEAM_BEGIN_FIGHT then
        self:refreshTeamBeginFight(param)
    elseif event == EVENT_ID_TREASURE_HUNT_CLEAR_TEAM then
        self:clearTeamInfo(param)
    elseif event == EVENT_ID_TREASURE_HUNT_RECORD_LIST then
        Panel.popUp(PANEL_TREASURE_HUNT_RECORD)
    elseif event == EVENT_ID_TREASURE_HUNT_ADD_SPEAKER then
        self:getNode("txt_speaker_info"):stopAllActions()
        local contentSize = self:getNode("layer_scroll_speaker"):getContentSize()
        self:getNode("txt_speaker_info"):setPositionX(contentSize.width)
        self:initSpeakerInfo()
    elseif event == EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH_NUM then
        gTreasureHunt.setAmbushCdTime(param.cdtime)
        gTreasureHunt.setAmbushNum(param.ambushnum)
        self:refreshAmbushDetail()
    elseif event == EVENT_ID_TREASURE_HUNT_REFRESH_INFORMATION then
        self:refreshSideInformation(param)
    elseif event == EVENT_ID_TREASURE_HUNT_NOTICE_OPER then
        self:getNode("layout_notice_info"):stopAllActions()
        local contentSize = self:getNode("layer_scroll_notice"):getContentSize()
        self:getNode("layout_notice_info"):setPositionX(contentSize.width)
        self:initNoticeInfo()
    elseif event == EVENT_ID_TREASURE_HUNT_RECORD_DETAIL then
        Panel.popUp(PANEL_TREASURE_HUNT_PROGRESS_DETAIL, 2)
    elseif event == EVENT_ID_TREASURE_HUNT_FRESH_REDPOS then
        self:setRecordRedPos()
    end
end

function TreasureHuntTeamFormationPanel:initTeamContainer()
    for i = 1, roomNumInOnePage do
        self:getNode("team_item"..i):removeChildByTag(teamInfoTag+i)
    end
    local teamCount = gTreasureHunt.getPageTeamSize()
    local contentSize = self:getNode("team_item1"):getContentSize()
    for i = 1, teamCount do
        local teamItem = TreasureHuntTeamItem.new(gTreasureHunt.getPageTeamInfoByIdx(i))
        teamItem:setAnchorPoint(cc.p(0.5, -0.5))
        teamItem:setTag(teamInfoTag+i)
        self:getNode("team_item"..i):addChild(teamItem)
        teamItem:setPosition(cc.p(contentSize.width/2, contentSize.height/2))
    end
end

function TreasureHuntTeamFormationPanel:initPanel()
    local hallId = gTreasureHunt.getCurHallId()
    local maxPage = math.floor(DB.getTreasureHuntHallRoomNum(hallId)/roomNumInOnePage)
    self.curPage = gTreasureHunt.getCurRoomPage()
    self:setLabelString("txt_page_info", string.format("%d/%d",gTreasureHunt.getCurRoomPage(), maxPage))
    self:getNode("layout_page_info"):layout()

    self:setLabelString("txt_hall_name", gTreasureHunt.getHallNameByIdx(hallId))
    self:setLabelString("txt_player_num", gGetMapWords("ui_team_room.plist","6",gTreasureHunt.getCurRoomPlayerNum()))

    local inRoomStatus = CT_OUT_ROOM_STATE
    if gTreasureHunt.getCurInRoomStatus() then
        inRoomStatus = CT_IN_ROOM_STATE
    end
    self:refreshSideInformation(inRoomStatus)

    local inAmbushStatus = CT_OUT_LURK_STATE
    if gTreasureHunt.getCurAmbushStatus() then
        inAmbushStatus = CT_IN_LURK_STATE
    end
    self:refreshSideInformation(inAmbushStatus)

    self:refreshAmbushDetail()
end

function TreasureHuntTeamFormationPanel:refreshTeamJoin(roomId)
    local teamCount = gTreasureHunt.getPageTeamSize()
    -- local contentSize = self:getNode("team_item1"):getContentSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag)
        if teamItem ~= nil and teamItem.teamInfo.roomId == roomId then
            teamItem:setData(teamItem.teamInfo)
            break
        end
    end    
end

function TreasureHuntTeamFormationPanel:onUILayerExit()
    self:unscheduleUpdateEx()
end

function TreasureHuntTeamFormationPanel:initSpeakerInfo()
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

function TreasureHuntTeamFormationPanel:initNoticeInfo()
    local noticeSize = #gTreasureHunt.noticeList
    if noticeSize == 0 then
        self:setRTFString("txt_notice_info", "")
        self:getNode("layout_notice_info"):setVisible(false)
        return
    end
    self:getNode("layout_notice_info"):setVisible(true)
    local lastNoticeInfo = gTreasureHunt.noticeList[noticeSize]
    local noticeDbInfo = DB.getTreasureHuntNoticeInfo(lastNoticeInfo.id)
    local noticeWord = gTreasureHunt.getNoticeInfoWord(lastNoticeInfo,true)

    local contentSize = self:getNode("layer_scroll_notice"):getContentSize()
    self:setRTFString("txt_notice_info", noticeWord)
    if noticeDbInfo.type == 0 then
        -- self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_go_to"))
        self:getNode("btn_goto").type = 0
    else
        -- self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_detail"))
        self:getNode("btn_goto").type = 1
    end
    self:getNode("layout_notice_info"):layout()

    local labelContentSize = self:getNode("layout_notice_info"):getContentSize()
    self:getNode("layout_notice_info"):setPositionX(contentSize.width)
    local move_feed = (contentSize.width + labelContentSize.width) / 50
    self:getNode("layout_notice_info"):stopAllActions()

    local sequence = cc.Sequence:create(cc.MoveBy:create(move_feed, cc.p(-(contentSize.width + labelContentSize.width), 0)),
                                cc.CallFunc:create(function( ... )
                                    self:getNode("layout_notice_info"):setPositionX(contentSize.width)
                                end ))
    self:getNode("layout_notice_info"):runAction(cc.RepeatForever:create(sequence))
end

function TreasureHuntTeamFormationPanel:queryPageInfo(queryPage)
    local hallId = gTreasureHunt.getCurHallId()
    local maxPage = math.floor(DB.getTreasureHuntHallRoomNum(hallId)/roomNumInOnePage)

    if queryPage <= 0 then
        queryPage = maxPage
    end

    if queryPage > maxPage then
        queryPage = 1
    end

    if queryPage == self.curPage then
        return
    end

    Net.sendCroTreRoomInfo(hallId, queryPage, 0)
end

function TreasureHuntTeamFormationPanel:refreshInfo()
    self:initPanel()
    self:initTeamContainer()
end

function TreasureHuntTeamFormationPanel:refreshOneTeamInfo(param)
    local teamCount = gTreasureHunt.getPageTeamSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag + i)
        --当前页面是否包含了队伍信息
        if nil ~= teamItem and 
            gTreasureHunt.getCurHallId() == param.groupId and
            teamItem.teamInfo.roomId == param.roomId then
            teamItem:refreshItemInfo(param)
        end
    end    
end

function TreasureHuntTeamFormationPanel:oneLeaveTeam(param)
    local teamCount = gTreasureHunt.getPageTeamSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag + i)
        if nil ~= teamItem and 
            gTreasureHunt.getCurHallId() == param.groupId and
            teamItem.teamInfo.roomId == param.roomId then
            teamItem:oneLeaveTeam(param)
        end
    end
end

function TreasureHuntTeamFormationPanel:refreshAmbushInfo(param)
    local teamCount = gTreasureHunt.getPageTeamSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag + i)
        if nil ~= teamItem and 
            gTreasureHunt.getCurHallId() == param.groupId and
            teamItem.teamInfo.roomId == param.roomId then
            teamItem:refreshAmbushInfo(param)
        end
    end    
end

function TreasureHuntTeamFormationPanel:refreshTeamChoosePath(param)
    local teamCount = gTreasureHunt.getPageTeamSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag + i)
        if nil ~= teamItem and 
            gTreasureHunt.getCurHallId() == param.groupId and
            teamItem.teamInfo.roomId == param.roomId then
            teamItem:refreshTeamChoosePath(param)
        end
    end     
end

function TreasureHuntTeamFormationPanel:refreshTeamBeginFight(param)
    local teamCount = gTreasureHunt.getPageTeamSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag + i)
        if nil ~= teamItem and 
            gTreasureHunt.getCurHallId() == param.groupId and
            teamItem.teamInfo.roomId == param.roomId then
            teamItem:refreshTeamBeginFight(param)
        end
    end 
end

function TreasureHuntTeamFormationPanel:clearTeamInfo(param)
    local teamCount = gTreasureHunt.getPageTeamSize()
    for i = 1, teamCount do
        local teamItem = self:getNode("team_item"..i):getChildByTag(teamInfoTag + i)
        if nil ~= teamItem and 
            gTreasureHunt.getCurHallId() == param.groupId and
            teamItem.teamInfo.roomId == param.roomId then
            teamItem:clearTeamInfo(param)
        end
    end 
end

function TreasureHuntTeamFormationPanel:refreshAmbushDetail()
    self:unscheduleUpdateEx()
    local leftTime = gTreasureHunt.getAmbushCdTime() - gGetCurServerTime()
    if leftTime < 0 then
        leftTime = 0
    end
    self:setLabelString("txt_ambush_lefttime", gParserMinTime(leftTime))
    if leftTime ~= 0 then
        self:scheduleUpdate(function(dt)
            local updateLeftTime = gTreasureHunt.getAmbushCdTime() - gGetCurServerTime()
            if updateLeftTime > 0 then
                self:setLabelString("txt_ambush_lefttime", gParserMinTime(updateLeftTime))
            else
                self:setLabelString("txt_ambush_lefttime", "00:00")
                self:unscheduleUpdateEx()
            end
        end , 1)
    end

    self:setLabelString("txt_ambush_num", gTreasureHunt.getAmbushNum())
end

function TreasureHuntTeamFormationPanel:refreshSideInformation(refreshType)
    if refreshType == CT_IN_ROOM_STATE then--改变为加入房间状态,//查看寻宝
        self:setLabelString("txt_quick_find", gGetWords("treasureHuntWord.plist", "txt_look_treasure_hunt"))
        gTreasureHunt.setCurInRoomStatus(true)
    elseif refreshType == CT_OUT_ROOM_STATE then--改变为无加入房间状态
        self:setLabelString("txt_quick_find", gGetMapWords("ui_team_room.plist", "2"))
        gTreasureHunt.setCurInRoomStatus(false)
    elseif refreshType == CT_IN_LURK_STATE then--改变为已埋伏状态
        self:setLabelString("txt_quick_ambush",gGetWords("treasureHuntWord.plist", "txt_look_ambush"))
        gTreasureHunt.setCurAmbushStatus(true)
    elseif refreshType == CT_OUT_LURK_STATE then--改变为无埋伏状态
        self:setLabelString("txt_quick_ambush",gGetMapWords("ui_team_room.plist", "3"))
        gTreasureHunt.setCurAmbushStatus(false)
    elseif refreshType == CT_SEND_SYSTEM_KICK then--发送系统踢出提示
        self:setLabelString("txt_quick_find", gGetMapWords("ui_team_room.plist", "2"))
        gTreasureHunt.setCurInRoomStatus(false)
        gConfirm(gGetWords("treasureHuntWord.plist","txt_kick_by_sys"))
    elseif refreshType == CT_SEND_LEADER_KICK then--发送队长踢出提示
        self:setLabelString("txt_quick_find", gGetMapWords("ui_team_room.plist", "2"))
        gTreasureHunt.setCurInRoomStatus(false)
        gConfirm(gGetWords("treasureHuntWord.plist","txt_kick_by_leader"))
    end
end

function TreasureHuntTeamFormationPanel:setRecordRedPos()
    if Data.redpos.treasurehUntRecord then
        RedPoint.add(self:getNode("btn_record"))
    else
        RedPoint.remove(self:getNode("btn_record"))
    end
end


return TreasureHuntTeamFormationPanel