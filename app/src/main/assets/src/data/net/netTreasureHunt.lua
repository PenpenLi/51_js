-- 跨服寻宝大厅信息
CMD_CROSS_TREASURE_HALL_INFO = "crotre.hallinfo"
function Net.sendCroTreHallInfo(callback)
    local obj = MediaObj:create()
    Net.sendCroTreHallInfoCallback = callback
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_HALL_INFO)
end

function Net.rec_crotre_hallinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    if Net.sendCroTreHallInfoCallback ~= nil then
        Net.sendCroTreHallInfoCallback()
    end

    Data.setUsedTimes(VIP_BUY_TREASURE_MAP,obj:getInt("buynum"))

    local list = obj:getArray("list")
    gTreasureHunt.clearHallInfos()
    for i = 0, list:count() - 1 do
        local hallObj = list:getObj(i)
        if nil ~= hallObj then
            hallObj = tolua.cast(hallObj,"MediaObj")
            gTreasureHunt.addHallInfo(hallObj:getByte("id"), hallObj:getInt("num"))
        end
    end

    local chatList = obj:getArray("chat")
    gTreasureHunt.clearSpeakerInfos()
    for i = 0, chatList:count() - 1 do
        local chatObj = chatList:getObj(i)
        if nil ~= chatObj then
            chatObj = tolua.cast(chatObj,"MediaObj")
            gTreasureHunt.addSpeakerInfo(chatObj:getInt("time"), chatObj:getString("name"), chatObj:getString("sname"), chatObj:getString("str"),true)
        end
    end

    Panel.popUp(PANEL_TREASURE_HUNT_GROUP_CHOOSE)
end


-- 跨服寻宝大厅信息
CMD_CROSS_TREASURE_ROOM_INFO = "crotre.roominfo"
function Net.sendCroTreRoomInfo(hallid, page, first, isFromBattle) --page从1开始
    local obj = MediaObj:create()
    obj:setByte("hid", hallid)
    obj:setInt("page", page)
    obj:setByte("first", first)
    Net.sendCroTreRoomInfoFromBattle = isFromBattle
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_ROOM_INFO)
end

function Net.parseTreasureHuntNotice(noticeObj)
    local noticeInfo = {}
    noticeInfo.id = noticeObj:getInt("nid")
    noticeInfo.groupId = noticeObj:getByte("gid")
    noticeInfo.roomId = noticeObj:getInt("rid")
    noticeInfo.mapId = noticeObj:getLong("mapid")
    noticeInfo.username1 = noticeObj:getString("name1")
    noticeInfo.username2 = noticeObj:getString("name2")
    noticeInfo.param1 = noticeObj:getInt("param1")
    noticeInfo.param2 = noticeObj:getInt("param2")
    noticeInfo.param3 = noticeObj:getInt("param3")
    noticeInfo.time   = noticeObj:getInt("time")
    return noticeInfo
end

function Net.parseTreasureHuntRoomInfo(obj)
    if nil == obj then
        return
    end

    gTreasureHunt.setCurHallId(obj:getByte("hid"))
    gTreasureHunt.setCurRoomPage(obj:getInt("page"))

    if obj:containsKey("notice") then
        gTreasureHunt.clearNoticeList()
        local noticeList = obj:getArray("notice")
        for i = 0, noticeList:count() - 1 do
            local noticeObj = noticeList:getObj(i)
            if nil ~= noticeObj then
                noticeObj = tolua.cast(noticeObj,"MediaObj")
                gTreasureHunt.addNoticeInfo(Net.parseTreasureHuntNotice(noticeObj),true)
            end
        end        
    end

    if obj:containsKey("inroom") then
        gTreasureHunt.setCurInRoomStatus(obj:getBool("inroom"))
    end

    if obj:containsKey("inlurk") then
        gTreasureHunt.setCurAmbushStatus(obj:getBool("inlurk"))
    end

    if obj:containsKey("num") then
        gTreasureHunt.setCurRoomPlayerNum(obj:getInt("num"))
    end

    if obj:containsKey("cdtime") then
        gTreasureHunt.setAmbushCdTime(obj:getInt("cdtime"))
    end

    if obj:containsKey("lurknum") then
        gTreasureHunt.setAmbushNum(obj:getInt("lurknum"))
    end

    local roomList = obj:getArray("list")
    gTreasureHunt.clearPageTeamInfos()
    for i = 0, roomList:count() - 1 do
        local roomObj = roomList:getObj(i)
        if nil ~= roomObj then
            roomObj = tolua.cast(roomObj,"MediaObj")
            local treasureTeamInfo = TreasureTeamInfo.new()
            treasureTeamInfo.roomId = roomObj:getInt("rid")
            treasureTeamInfo.captainId = roomObj:getLong("leaid")
            treasureTeamInfo.state = roomObj:getByte("state")
            treasureTeamInfo.starEndTime = roomObj:getInt("time")
            treasureTeamInfo.mapInfo = {}
            treasureTeamInfo.mapInfo.road = roomObj:getInt("road")
            treasureTeamInfo.mapInfo.createTime = roomObj:getInt("ctime")
            treasureTeamInfo.mapInfo.endTime = roomObj:getInt("etime")
            treasureTeamInfo.mapInfo.ambushNum = roomObj:getByte("lnum")
            if roomObj:containsKey("uid1") then
                treasureTeamInfo.member1 = TreasureHuntMember.new()
                treasureTeamInfo.member1.id = roomObj:getLong("uid1")
                if treasureTeamInfo.member1.id ~= 0 and treasureTeamInfo.member1.id == treasureTeamInfo.captainId then
                    treasureTeamInfo.member1.isCaptain = true
                end
                treasureTeamInfo.member1.icon = roomObj:getInt("icon1")
                treasureTeamInfo.member1.name = roomObj:getString("name1")
                treasureTeamInfo.member1.treasureMap = roomObj:getInt("map1")
                treasureTeamInfo.member1.serverName = roomObj:getString("sname1")
                treasureTeamInfo.member1.safeLv = roomObj:getByte("safelv1")
            end

            if roomObj:containsKey("uid2") then
                treasureTeamInfo.member2 = TreasureHuntMember.new()
                treasureTeamInfo.member2.id = roomObj:getLong("uid2")
                if treasureTeamInfo.member2.id ~= 0 and treasureTeamInfo.member2.id == treasureTeamInfo.captainId then
                    treasureTeamInfo.member2.isCaptain = true
                end
                treasureTeamInfo.member2.icon = roomObj:getInt("icon2")
                treasureTeamInfo.member2.name = roomObj:getString("name2")
                treasureTeamInfo.member2.treasureMap = roomObj:getInt("map2")
                treasureTeamInfo.member2.serverName = roomObj:getString("sname2")
                treasureTeamInfo.member2.safeLv = roomObj:getByte("safelv2")
            end
            gTreasureHunt.addPageTeamInfo(treasureTeamInfo)
        end 
    end
    
    local openDlg = Panel.getOpenPanel(PANEL_TREASURE_HUNT_TEAM_FORMATION)
    if nil == openDlg then
        Panel.popUp(PANEL_TREASURE_HUNT_TEAM_FORMATION)
        if Net.sendCroTreRoomInfoFromBattle then
            Panel.popUp(PANEL_TREASURE_HUNT_STAGE_RECORD)
        end
    else
        openDlg:refreshInfo()
    end
end

function Net.rec_crotre_roominfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.parseTreasureHuntRoomInfo(obj)
end

-- 跨服寻宝加入房间
CMD_CROSS_TREASURE_JOIN_ROOM = "crotre.join"
function Net.sendCroTreJoinRoom(gId, rId, isLeft, itemId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    obj:setBool("isleft", isLeft)
    obj:setInt("map",itemId)
    Net.sendTreasureHuntJoinRoom = {rId=rId, isLeft=isLeft, itemId=itemId}
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_JOIN_ROOM)
end

function Net.rec_crotre_join(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
end


--退出房间 
CMD_CROSS_TREASURE_EXIT_ROOM = "crotre.exit"
function Net.sendCroTreExitRoom(gId, rId, isleft)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    obj:setBool("isleft",isleft)
    Net.sendTreasureHuntExitRoom = {rId=rId}
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_EXIT_ROOM)
end

function Net.rec_crotre_exit(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
end
-- 踢出房间 
CMD_CROSS_TREASURE_KICK = "crotre.kick"
function Net.sendCrotreKick(gId, rId, isleft)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    obj:setBool("isleft",isleft)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_KICK)    
end

function Net.rec_crotre_kick(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
end

--推送跨服寻宝信息(服务器主动推送),推送类型
CT_ROOM_UPDATE_USER = 1 --更新玩家
CT_ROOM_DELETE_USER = 2 --删除玩家
CT_ROOM_START_ROOM = 3 --开始房间
CT_ROOM_UPDATE_LURK = 4 --更新埋伏信息
CT_ROOM_DELETE_LURK = 5 --删除埋伏信息
CT_ROOM_START_FIGHT = 6 --开始战斗
CT_ROOM_CLEAR_ROOM = 7 --结束时重置房间
CT_UPDATE_LURK_INFO= 8 --更新埋伏信息
CT_IN_ROOM_STATE= 9 --改变为加入房间状态
CT_OUT_ROOM_STATE= 10 --改变为无加入房间状态
CT_IN_LURK_STATE= 11 --改变为已埋伏状态
CT_OUT_LURK_STATE= 12 --改变为无埋伏状态
CT_SEND_SYSTEM_KICK= 13 --发送系统踢出提示
CT_SEND_LEADER_KICK= 14 --发送队长踢出提示
CT_CHAT = 20 --发送喇叭
CT_NOTICE = 21 --发送公告

RECEIVE_CROSS_TREASURE = "rec.ct"
function Net.rec_rec_ct(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    --推送类型 1加入房间 2退出房间 3开始选择4加入埋伏5离开埋伏6开始战斗7清空房间
    --8更新埋伏信息 9 改变为加入房间状态 10 改变为无加入房间状态
    --11 改变为已埋伏状态  12 改变为无埋伏状态 13 发送系统踢出提示 14 发送队长踢出提示
    --20推送喇叭,21推送公告(结构见roominfo协议notice)       
    local msgType = obj:getByte("type")
    print("Net.rec_rec_ct msgType is:",msgType)
    local param = {}
    param.groupId = obj:getByte("gid")
    param.roomId  = obj:getInt("rid")
    param.captainId  = obj:getLong("leaid")
    param.state   = obj:getByte("state") --0 空房间 1等待开始 2路线选择 3护送中
    param.starEndTime    = obj:getInt("time") -- 踢出时间点
    param.isLeft  = obj:getBool("isleft")
    param.uid     = obj:getLong("uid")
    param.icon    = obj:getInt("icon")
    param.name    = obj:getString("name")
    param.map     = obj:getInt("map")
    param.sname   = obj:getString("sname")
    param.safelv  = obj:getByte("safelv")
    param.mapCreateTime = obj:getInt("stime") --寻宝开始时间点

    if msgType == 4 or msgType == 5 then
        param.ambushStage = obj:getByte("lpos")
        param.ambushId   = obj:getLong("luid")
        param.ambushIcon = obj:getInt("licon")
        param.ambushName = obj:getString("lname")
        param.ambushNum = obj:getByte("lnum") --埋伏者人数
        param.ambushServerName = obj:getString("lsname")
        param.ambushJoin = (msgType == 4)
    end

    if msgType == 6 then
        param.road = obj:getByte("road")
        param.etime = obj:getInt("etime")
    end

    if msgType == 8 then
        param.cdtime = obj:getInt("cdtime")
        param.ambushnum = obj:getInt("lurknum")
    end

    if msgType == 20 then
        local chatObj = obj:getObj("chat")
        param.chat = {}
        param.chat.time = chatObj:getInt("time")
        param.chat.name = chatObj:getString("name")
        param.chat.sname = chatObj:getString("sname")
        param.chat.str = chatObj:getString("str")
    end

    if msgType == CT_NOTICE then
        param.notice = Net.parseTreasureHuntNotice(obj:getObj("notice"))
    end
    
    if msgType == 1 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_REFRESH_MEMBER, param)
    elseif msgType == 2 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_MEMBER_LEAVE,param)
    elseif msgType == 3 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_START_CHOOSE,param)
    elseif msgType == 4 or msgType == 5 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH,param)
        if nil ~= gTreasureHunt.detailMapInfo and 
           param.groupId == gTreasureHunt.detailMapInfo.groupId and 
           param.roomId == gTreasureHunt.detailMapInfo.roomId then
           gTreasureHunt.detailMapInfo:refreshAmbushInfo(param)
        end
        gTreasureHunt.refreshPageTeamInfoAmbushNum(param.ambushNum)
    elseif msgType == 6 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_TEAM_BEGIN_FIGHT, param)
    elseif msgType == 7 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_CLEAR_TEAM, param)
    elseif msgType == 8 then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH_NUM, param)
    elseif msgType == 20 then
        gTreasureHunt.addSpeakerInfo(param.chat.time, param.chat.name, param.chat.sname, param.chat.str)
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_ADD_SPEAKER)
    elseif msgType == CT_NOTICE then
        gTreasureHunt.addNoticeInfo(param.notice)
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_NOTICE_OPER,0)
    elseif (msgType == CT_IN_ROOM_STATE) or (msgType == CT_OUT_ROOM_STATE) or 
           (msgType == CT_IN_LURK_STATE) or (msgType == CT_OUT_LURK_STATE) or 
           (msgType == CT_SEND_SYSTEM_KICK) or (msgType == CT_SEND_LEADER_KICK) then
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_REFRESH_INFORMATION,msgType)
    end
end

--创建地图
CMD_CROSS_TREASURE_CREATE_MAP = "crotre.creamap"
function Net.sendCrossTreasureCreateMap(gId, rId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    Net.sendTreasureMapInfo = {groupId=gId,roomId=rId}
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_CREATE_MAP)
end

function Net.parseMemberInfo(obj)
    if nil == obj then
        return
    end

    local memberInfo = TreasureHuntMember.new()
    memberInfo.id    = obj:getLong("tid")
    memberInfo.name  = obj:getString("tname")
    memberInfo.icon  = obj:getInt("ticon")
    memberInfo.power = obj:getInt("power")
    memberInfo.safelv = obj:getByte("safelv")
    memberInfo.treasureMap  = obj:getInt("tmap")
    return memberInfo
end

function Net.parseTerrainInfo(obj, stage)
    if nil == obj then
        return
    end

    local terrainInfo = TreasureTerrainInfo.new()
    terrainInfo.stage = stage
    terrainInfo.type = obj:getByte("terrain")
    terrainInfo.weather = obj:getByte("weather")
    terrainInfo.time = obj:getByte("time")
    terrainInfo.ambushId = obj:getLong("lurkerid")
    terrainInfo.ambushName = obj:getString("lurkername")
    terrainInfo.ambushServerName = obj:getString("sname")
    terrainInfo.ambushIcon = obj:getInt("icon")
    return terrainInfo
end

function Net.parseTreasureHuntEventInfos(eventObj)
    if eventObj == nil then
        return nil
    end

    local eventInfo = {}
    eventInfo.id  = eventObj:getLong("id")--数据库id
    eventInfo.eid = eventObj:getInt("eid")--事件id
    eventInfo.username1 = eventObj:getString("username1")
    eventInfo.username2 = eventObj:getString("username2")
    eventInfo.param1 = eventObj:getInt("param1")
    eventInfo.param2 = eventObj:getInt("param2")
    eventInfo.param3 = eventObj:getInt("param3")
    eventInfo.param4 = eventObj:getInt("param4")
    eventInfo.lurkid    = eventObj:getByte("lurkid")--埋伏点id,非0为有战斗信息 
    return eventInfo
end

function Net.rec_crotre_creamap(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local createTime = obj:getInt("ctime")
    local captainId  = obj:getLong("leaderid")

    gTreasureHunt.detailMapInfo = TreasureDetailMapInfo.new(Net.sendTreasureMapInfo.groupId, Net.sendTreasureMapInfo.roomId,captainId,
                                  TerrainRoadType.none,createTime,false)

    local member1 = Net.parseMemberInfo(obj:getObj("pobj1"))
    local member2 = Net.parseMemberInfo(obj:getObj("pobj2"))
    if captainId == member1.id then
        member1.isCaptain = true
    else
        member2.isCaptain = true
    end

    gTreasureHunt.detailMapInfo:setMemberInfo(member1,member2)
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj1"),1))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj2"),2))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj3"),3))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj4"),4))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj5"),5))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj6"),6))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj7"),7))

    local eventList = obj:getArray("eventlist")
    if nil ~= eventList then
        gTreasureHunt.detailMapInfo:clearCreateEventInfos()
        for i = 0, eventList:count() - 1 do
            local eventObj = eventList:getObj(i)
            if nil ~= eventObj then
                eventObj = tolua.cast(eventObj,"MediaObj")
                local eventInfo = Net.parseTreasureHuntEventInfos(eventObj)
                if nil ~= eventInfo then
                    gTreasureHunt.detailMapInfo:addCreateEventInfo(eventInfo)
                end
            end
        end
    end

    Panel.popUp(PANEL_TREASURE_HUNT_ENTER,true)
end

CMD_CROSS_TREASUER_FIGHT_RESULT = "crotre.fightr"
function Net.sendCrossTreasureFightResult(gId, rId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    Net.sendTreasureFightResult = {groupId=gId,roomId=rId}
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASUER_FIGHT_RESULT)
end

function Net.parseMapEventInfo(dataList, isRecord)
    if nil == dataList then
        return
    end
    print("mapEventInfo size is:",dataList:count())
    for i = 0, dataList:count() - 1 do
       local dataObj = dataList:getObj(i)
       if nil ~= dataObj then
            dataObj = tolua.cast(dataObj, "MediaObj")
            local eventList = dataObj:getArray("eventlist")
            if nil ~= eventList then
                for j = 0, eventList:count() - 1 do
                    local eventObj = eventList:getObj(j)
                    if nil ~= eventObj then
                        eventObj = tolua.cast(eventObj,"MediaObj")
                        local eventInfo = Net.parseTreasureHuntEventInfos(eventObj)
                        print("id is",eventInfo.id, "eid is:",eventInfo.eid," username1 is:",eventInfo.username1," username2 is:",eventInfo.username2,
                              "param1 is:",eventInfo.param1," param2 is:",eventInfo.param2," param3 is:",eventInfo.param3,
                              " param4 is:",eventInfo.param4," vid is:",eventInfo.lurkid)
                        if isRecord then
                            gTreasureHunt.addDetailRecordInfo(eventInfo, i+1)
                        else
                            gTreasureHunt.detailMapInfo:addEventInfo(eventInfo, i+1)
                        end
                    end
                end
            end
       end
    end
end

function Net.rec_crotre_fightr(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        if ret == 6 then
            Net.sendCrossTreasureFightResult(Net.sendTreasureFightResult.groupId, Net.sendTreasureFightResult.roomId)
        end
        return
    end
    gTreasureHunt.detailMapInfo:setEndTime(obj:getInt("etime"))
    gTreasureHunt.detailMapInfo:setRoad(obj:getByte("road"))
    local aniObj = obj:getObj("aniobj")
    gTreasureHunt.detailMapInfo.endTime = aniObj:getInt("etime")
    Net.parseMapEventInfo(aniObj:getArray("datalist"))
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_BEGIN_FIGHT)
end

CMD_CROSS_TREASUER_FIGHT_RESULT_CHECK = "crotre.frcheck"
function Net.sendCrotreFrCheck(gId, rId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASUER_FIGHT_RESULT_CHECK)
end

function Net.rec_crotre_frcheck(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    gSetServerTime(obj:getInt("curtime"))
    gTreasureHunt.detailMapInfo:setEndTime(obj:getInt("endtime"))
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_CHECK_STAGE)
end

-- 埋伏
CMD_CROSS_TREASURE_LURK = "crotre.lurk"
function Net.sendCrotreLurk(gId, rId, lurkId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    obj:setByte("lurkid", lurkId) --埋伏点
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_LURK)
end

function Net.rec_crotre_lurk(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    -- 广播里面刷新
end

--离开埋伏点
CMD_CROSS_TREASURE_LFET_LURK = "crotre.leftlurk"
function Net.sendCrotreLeftlurk(gId, rId, lurkId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    obj:setByte("lurkid", lurkId) --埋伏点
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_LFET_LURK)
end

function Net.rec_crotre_leftlurk(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    -- 广播里面刷新
end

--查看玩家信息
CMD_CROSS_TREASURE_USERINFO = "crotre.userinfo"
function Net.sendCrotreUserInfo(id)
    local obj = MediaObj:create()
    obj:setLong("uid", id)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_USERINFO)
end

function Net.rec_crotre_userinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local userInfo = Net.parseFormationObj(obj)
    userInfo.sname = obj:getString("sname")
    
    Panel.popUpVisible(PANEL_FORMATION,userInfo,2)
end


-- 推送跨服寻宝更新路径选择状态(服务器主动推送)
RECEIVE_CROSS_TREASUER_UPDATE_ROAD_INFO = "rec.ctroad"
function Net.rec_rec_ctroad(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local road =  obj:getByte("road")
    if gTreasureHunt.detailMapInfo ~= nil then
        print("Net.rec_rec_ctroad:", road)
        gTreasureHunt.detailMapInfo:setRoad(road)
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_CHOOSE_ROAD,road)
    end
end

-- 队长选择路线
CMD_CROSS_TREASURE_CHOOSE_ROAD = "crotre.croad"
function Net.sendCrotreCroad(gId, rId, road)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    obj:setByte("road", road)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_CHOOSE_ROAD)
end

function Net.rec_crotre_croad(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    local road = obj:getByte("road")
    print("Net.rec_crotre_croad")
    gTreasureHunt.detailMapInfo:setRoad(road)
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_CHOOSE_ROAD,road)
end

-- 初始化地图信息
CMD_CROSS_TREASURE_INIT_MAP = "crotre.initmap"
function Net.sendCrotreInitmap(gId, rId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    obj:setInt("rid", rId)
    Net.sendTreasureMapInfo = {groupId=gId,roomId=rId}
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_INIT_MAP)
end

function Net.rec_crotre_initmap(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local stage = obj:getByte("stage")
    local road  = obj:getByte("road")
    local createTime = obj:getInt("ctime")
    local captainId = obj:getLong("leaderid")

    gTreasureHunt.detailMapInfo = TreasureDetailMapInfo.new(Net.sendTreasureMapInfo.groupId, Net.sendTreasureMapInfo.roomId,captainId,
                                  road,createTime,false)

    local member1 = Net.parseMemberInfo(obj:getObj("pobj1"))
    local member2 = Net.parseMemberInfo(obj:getObj("pobj2"))
    if captainId == member1.id then
        member1.isCaptain = true
    else
        member2.isCaptain = true
    end

    gTreasureHunt.detailMapInfo:setMemberInfo(member1,member2)
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj1"),1))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj2"),2))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj3"),3))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj4"),4))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj5"),5))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj6"),6))
    gTreasureHunt.detailMapInfo:addTerrainInfo(Net.parseTerrainInfo(obj:getObj("lurkobj7"),7))


    local eventList = obj:getArray("eventlist")
    if nil ~= eventList then
        gTreasureHunt.detailMapInfo:clearCreateEventInfos()
        for i = 0, eventList:count() - 1 do
            local eventObj = eventList:getObj(i)
            if nil ~= eventObj then
                eventObj = tolua.cast(eventObj,"MediaObj")
                local eventInfo = Net.parseTreasureHuntEventInfos(eventObj)
                if nil ~= eventInfo then
                    gTreasureHunt.detailMapInfo:addCreateEventInfo(eventInfo)
                end
            end
        end
    end

    if obj:containsKey("aniobj") then
        local aniObj = obj:getObj("aniobj")
        gTreasureHunt.detailMapInfo:setEndTime(aniObj:getInt("etime"))
        Net.parseMapEventInfo(aniObj:getArray("datalist"))
    end

    Panel.popUp(PANEL_TREASURE_HUNT_ENTER)
end

 -- 快速寻宝
CMD_CROSS_TREASURE_FAST_JOIN = "crotre.fjoin"
function Net.sendCrotreFjoin(gId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_FAST_JOIN)
end

function Net.rec_crotre_fjoin(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.parseTreasureHuntRoomInfo(obj)
end

-- 快速埋伏
CMD_CROSS_TREASURE_FAST_LURK = "crotre.flurk"
function Net.sendCrotreFlurk(gId)
    local obj = MediaObj:create()
    obj:setByte("gid", gId)
    Net.sendCrotreFlurkGroupId = gId
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_FAST_LURK)
end

function Net.rec_crotre_flurk(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.parseTreasureHuntRoomInfo(obj)
    Net.sendCrotreInitmap(Net.sendCrotreFlurkGroupId, obj:getInt("roomid"))
end

-- 发送喇叭
CMD_CROSS_TREASURE_CHAT = "crotre.chat"
function Net.sendCrotreChat(chatStr)
    local obj = MediaObj:create()
    obj:setString("str", chatStr)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_CHAT)
end

function Net.rec_crotre_chat(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
end
-- 获取角色的记录(包括护送信息,埋伏信息)
CMD_CROSS_TREASURE_GET_RECORD_LIST = "crotre.getreclist"
function Net.sendCrotreGetreclist()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_GET_RECORD_LIST)
end

function Net.rec_crotre_getreclist(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    gTreasureHunt.clearEscortList()
    local escortList = obj:getArray("frlist")
    for i = 0, escortList:count() - 1 do
        local escortObj = escortList:getObj(i)
        if nil ~= escortObj then
            escortObj = tolua.cast(escortObj,"MediaObj")
            local escortInfo = {}
            escortInfo.mapId = escortObj:getLong("mapid") --战斗地图id
            escortInfo.tmapId1 = escortObj:getInt("tmapid1")
            escortInfo.tmapId2 = escortObj:getInt("tmapid2")
            escortInfo.userName1 = escortObj:getString("username1")
            escortInfo.userName2 = escortObj:getString("username2")
            escortInfo.pro = escortObj:getInt("pro") --提升百分率
            escortInfo.battleNum = escortObj:getInt("battle")
            escortInfo.winNum = escortObj:getInt("win")
            escortInfo.loseNum = escortObj:getInt("lose")
            gTreasureHunt.addEscortInfo(escortInfo)
        end
    end

    gTreasureHunt.clearAmbushList()
    local ambushList = obj:getArray("lrlist")
    for i = 0, ambushList:count() - 1 do
        local ambushObj = ambushList:getObj(i)
        if nil ~= ambushObj then
            ambushObj = tolua.cast(ambushObj,"MediaObj")
            if nil ~= ambushObj then
                ambushObj = tolua.cast(ambushObj,"MediaObj")
                local ambushInfo = {}
                ambushInfo.mapId = ambushObj:getLong("mapid") --战斗地图id
                ambushInfo.retType = ambushObj:getByte("rtype") --0:埋伏胜利，1:埋伏失败，被打败，2:埋伏失败，不在护送线路上
                ambushInfo.tmapId1 = ambushObj:getInt("tmapid1")
                ambushInfo.tmapId2 = ambushObj:getInt("tmapid2")
                ambushInfo.userName1 = ambushObj:getString("username1")
                ambushInfo.userName2 = ambushObj:getString("username2")
                ambushInfo.pro = ambushObj:getInt("pro")
                gTreasureHunt.addAmbushInfo(ambushInfo)
            end
        end
    end

    gDispatchEvt(EVENT_ID_TREASURE_HUNT_RECORD_LIST)
end

-- 记录详细
CMD_CROSS_TREASURE_GET_RECORD_INFO = "crotre.getrecinfo"
function Net.sendCrotreGetrecInfo(mapId)
    local obj = MediaObj:create()
    obj:setLong("mapid", mapId)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_GET_RECORD_INFO)
end

function Net.rec_crotre_getrecinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    gTreasureHunt.clearDetailRecordInfo()

    local eventList = obj:getArray("eventlist")
    if nil ~= eventList then
        for i = 0, eventList:count() - 1 do
            local eventObj = eventList:getObj(i)
            if nil ~= eventObj then
                eventObj = tolua.cast(eventObj,"MediaObj")
                local eventInfo = Net.parseTreasureHuntEventInfos(eventObj)
                if nil ~= eventInfo then
                    gTreasureHunt.addDetailRecordCreateInfo(eventInfo)
                end
            end
        end
    end

    local aniObj = obj:getObj("aniobj")
    gTreasureHunt.setDetailRecordInfo(aniObj:getInt("etime")) 
    Net.parseMapEventInfo(aniObj:getArray("datalist"),true)
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_RECORD_DETAIL)
end

-- 战斗录像详细
CMD_CROSS_TREASURE_FIGHT_RECORD_INFO = "crotre.frecinfo"
function Net.sendCrotreFrecInfo(id)
    local obj = MediaObj:create()
    obj:setLong("id",id)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_FIGHT_RECORD_INFO)
end

function Net.rec_crotre_frecinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    gTreasureHunt.clearFightRetInfo()
    local fightRetList = obj:getArray("rlist")
    gTreasureHunt.fightRetInfo.winner = obj:getByte("winner")
    gTreasureHunt.fightRetInfo.infos = {}
    for i = 0, fightRetList:count() - 1 do
        local fightRetObj = fightRetList:getObj(i)
        if nil ~= fightRetObj then
            fightRetObj = tolua.cast(fightRetObj,"MediaObj")
            if nil ~= fightRetObj then
                local fightRetInfo = {}
                fightRetInfo.winner = fightRetObj:getByte("winner")

                fightRetInfo.player1 = {}
                fightRetInfo.player1.lv = fightRetObj:getInt("lv1")
                fightRetInfo.player1.userName = fightRetObj:getString("username1")
                fightRetInfo.player1.icon = fightRetObj:getInt("icon1")
                fightRetInfo.player1.add  = fightRetObj:getInt("add1")
                -- 没有发生战斗时，战力加成为0
                if fightRetInfo.player1.add == 0 then
                    fightRetInfo.player1.add = 100
                end
                fightRetInfo.player1.power = fightRetObj:getInt("price1")

                fightRetInfo.player2 = {}
                fightRetInfo.player2.lv = fightRetObj:getInt("lv2")
                fightRetInfo.player2.userName = fightRetObj:getString("username2")
                fightRetInfo.player2.icon = fightRetObj:getInt("icon2")
                fightRetInfo.player2.add  = fightRetObj:getInt("add2")
                if fightRetInfo.player2.add == 0 then
                    fightRetInfo.player2.add = 100
                end
                fightRetInfo.player2.power = fightRetObj:getInt("price2")

                fightRetInfo.vid = fightRetObj:getLong("vid")

                gTreasureHunt.addFightRetInfoWiner(fightRetInfo)
            end
        end
    end
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_FIGHT_RET)
end

-- 查看战斗录像
CMD_CROSS_TREASURE_VEDIO = "crotre.vedio"
function Net.sendCrotreVedio(vid)
    local obj = MediaObj:create()
    obj:setLong("vid", vid)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_VEDIO)
end

function Net.rec_crotre_vedio(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local data = obj:getObj("bat")
    Battle.brief = {} 
    Battle.brief.n1 = data:getString("n1")
    Battle.brief.n2 = data:getString("n2")
    local byteArr= data:getByteArray("info")
    -- TODO
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA_LOG)
end

-- 打开我加入的房间
CMD_CROSS_TREASURE_OPEN_MY_ROOM = "crotre.openroom"
function Net.sendCrotreOpenroom()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_OPEN_MY_ROOM)
end

function Net.rec_crotre_openroom(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.parseTreasureHuntRoomInfo(obj)
    if obj:getInt("roomid") ~= 0 then
        Net.sendCrotreInitmap(gTreasureHunt.getCurHallId(), obj:getInt("roomid"))
    end
end

-- 打开我埋伏的房间
CMD_CROSS_TREASURE_OPEN_MY_LURK = "crotre.openlurk"
function Net.sendCrotreOpenlurk()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_OPEN_MY_LURK)
end

function Net.rec_crotre_openlurk(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.parseTreasureHuntRoomInfo(obj)
    if obj:getInt("roomid") ~= 0 then
        Net.sendCrotreInitmap(gTreasureHunt.getCurHallId(), obj:getInt("roomid"))
    end
end

-- 公告加入房间
CMD_CROSS_TREASURE_NOTICE_JOIN = "crotre.notijoin"
function Net.sendCrotreNotijoin(gid,rid, mapid,noticeIdx)
    local obj = MediaObj:create()
    obj:setByte("gid",gid)
    obj:setInt("rid",rid)
    obj:setLong("mapid",mapid)
    Net.treasureHuntQueryNotice = {groupId=gid,roomId=rid,mapId=mapid}
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_NOTICE_JOIN)
end

function Net.rec_crotre_notijoin(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        if ret == 12 then
            local idx = 0
            if Net.treasureHuntQueryNotice ~= nil then
                idx = gTreasureHunt.delNoticeInfo(Net.treasureHuntQueryNotice.groupId, Net.treasureHuntQueryNotice.roomId, Net.treasureHuntQueryNotice.mapId)
            end
            gDispatchEvt(EVENT_ID_TREASURE_HUNT_NOTICE_OPER,idx)
        end
        return
    end

    Net.parseTreasureHuntRoomInfo(obj)
    if obj:getInt("roomid") ~= 0 then
        Net.sendCrotreInitmap(gTreasureHunt.getCurHallId(), obj:getInt("roomid"))
    end
end

-- 关闭界面,1退出组  2 退出房间
CMD_CROSS_TREASURE_CLOSE_UI = "crotre.close"
function Net.sendCrotreClose(type)
    local obj = MediaObj:create()
    obj:setByte("type",type)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_CLOSE_UI)
end

function Net.rec_crotre_close(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local hallObj = list:getObj(i)
            if nil ~= hallObj then
                hallObj = tolua.cast(hallObj,"MediaObj")
                gTreasureHunt.refreshHallInfo(hallObj:getByte("id"), hallObj:getInt("num"))
            end
        end
        gDispatchEvt(EVENT_ID_TREASURE_HUNT_GROUP_NUM)
    end
end

--推送跨服寻宝有记录提醒
RECEIVE_CROSS_TREASUER_RECORD_PROMPT = "rec.ctrecpro"
function Net.rec_rec_ctrecpro(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.redpos.treasurehUntRecord = true
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_FRESH_REDPOS)
end

-- 购买宝图
CMD_CROSS_TREASURE_BUYMAP = "crotre.buymap"
function Net.sendCrotreBuy(num)
    local obj = MediaObj:create()
    obj:setInt("num",num)
    Net.sendExtensionMessage(obj,CMD_CROSS_TREASURE_BUYMAP)
end

function Net.rec_crotre_buymap(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        if ret == 11 then
           gDispatchEvt(EVENT_ID_TREASURE_HUNT_BUY_MAP, 1) 
        end
        return
    end
    Data.setUsedTimes(VIP_BUY_TREASURE_MAP,obj:getInt("buynum"))
    Net.updateReward(obj:getObj("reward"),1)
    gDispatchEvt(EVENT_ID_TREASURE_HUNT_BUY_MAP)
end

