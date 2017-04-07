-- 寻宝地图类型
TreasureMap = {
    green = 1,
    blue  = 2,
    purple = 3,
}

-- 寻宝成员信息
TreasureHuntMember = class("TreasureHuntMember")
function TreasureHuntMember:ctor()
    self.id = 0
    self.name = ""
    self.isCaptain = false
    self.serverName = ""
    self.treasureMap = 0
    self.safeLv = 0 --安全勋章等级，medalNum
    self.power = 0
    self.icon = 0
end

-- 寻宝组队队伍状态
TreasureTeamStatus = {
    none = 0, --空
    -- TODO,原先逻辑需要修改
    -- wait_member_join = 1, --等待成员加入
    -- wait_start_find   = 2, --等待开始寻宝
    wait_start = 1, --等待开始
    wait_choose_path = 2, --等待路线选择
    finding   = 3, --正在寻宝
    finish    = 4, --结束
}

-- 寻宝组队信息
TreasureTeamInfo = class("TreasureTeamInfo")
function TreasureTeamInfo:ctor()
    self:resetData()
end

function TreasureTeamInfo:resetData()
    self.member1 = nil
    self.member2 = nil
    self.starEndTime = 0 --等待开始阶段，结束时间
    self.state = 0 --房间状态 0 空房间 1等待开始 2路线选择 3护送中
    self.ambushNum = 0
    self.curPath = 0
    self.curProgress = 0
    self.roomId = 0
    self.captainId = 0
    self.mapInfo = {}--地图信息
    self.mapInfo.road = 0
    self.mapInfo.createTime = 0
    self.mapInfo.endTime = 0
    self.mapInfo.ambushNum = 0

end

function TreasureTeamInfo:refreshAmbushNum(num)
    self.ambushNum = num
end

-- 地形类型
TerrainType = {
    plain  = 0,--开阔平原
    jungle = 1,--野蛮丛林
    snow   = 2,--格雷雪山
    valley = 3,--巨石山谷
    desert = 4,--大哈沙漠
}

--天气类型
TerrainWeatherType = {
    sunshine  = 0, --晴天
    rain      = 1, --下雨
    snowstorm = 2, --暴风雪
    lightning = 3, --闪电
    sand      = 4, --刮沙
}

--时间类型
TerrainTimeType = {
    day   = 0,
    night = 1,
}

--路线类型
TerrainRoadType = {
    none  = 0,
    right = 1,
    left  = 2,
}

--寻宝地图的最大小节数
MAX_TREASURE_STAGE = 7

--寻宝地图地型消息
TreasureTerrainInfo = class("TreasureTerrainInfo")
function TreasureTerrainInfo:ctor()
    self.stage = 0
    self.type = TerrainType.plain
    self.weather = TerrainWeatherType.sunshine
    self.time = TerrainTimeType.day
    self.ambushId = 0
    self.ambushName = ""
    self.ambushServerName = ""
    self.ambushIcon = 0
end

--寻宝地图具体信息
TreasureDetailMapInfo = class("TreasureDetailMapInfo")
function TreasureDetailMapInfo:ctor(groupId, roomId, captainId, road, createTime,ifreward)
    -- self.id = id
    self.groupId = groupId
    self.roomId = roomId
    self.captainId = captainId
    self.createTime = createTime
    self.road = road
    self.terrainInfos = {}
    self.ifreward = ifreward --奖励是否已发送
    self.endTime = 0
    self.eventInfos = {}
    self.createEventInfos = {}
end

function TreasureDetailMapInfo:setMemberInfo(member1, member2)
    self.member1 = member1
    self.member2 = member2
end

function TreasureDetailMapInfo:addTerrainInfo(info)
    table.insert(self.terrainInfos, info)
end

function TreasureDetailMapInfo:setEndTime(endTime)
    self.endTime = endTime
end

function TreasureDetailMapInfo:setRoad(road)
    self.road = road
end

function TreasureDetailMapInfo:clearEventInfos()
    self.eventInfos = {}
end

function TreasureDetailMapInfo:addEventInfo(eventInfo,idx)
    if self.eventInfos[idx] == nil then
        self.eventInfos[idx] = {}
    end


    table.insert(self.eventInfos[idx], eventInfo)
end

function TreasureDetailMapInfo:clearCreateEventInfos()
    self.createEventInfos = {}
end

function TreasureDetailMapInfo:addCreateEventInfo(eventInfo)
    if self.createEventInfos == nil then
        self.createEventInfos = {}
    end


    table.insert(self.createEventInfos, eventInfo)
end

function TreasureDetailMapInfo:refreshAmbushInfo(param)
    if param.ambushStage == 0 then
        return
    end

    for key, terrainInfo in ipairs(self.terrainInfos) do
        if terrainInfo.stage == param.ambushStage then
            terrainInfo.ambushId = param.ambushId
            terrainInfo.ambushName = param.ambushName
            terrainInfo.ambushServerName = param.ambushServerName
            terrainInfo.ambushIcon = param.ambushIcon
        end
    end
end

gTreasureHunt = {}
gTreasureHunt.pageTeamInfos = {}
gTreasureHunt.detailMapInfo = nil
gTreasureHunt.recordMemName1 = ""
gTreasureHunt.recordMemName2 = ""
gTreasureHunt.noticeList = {}
gTreasureHunt.hallInfos = {}
gTreasureHunt.speakerInfos = {}
gTreasureHunt.curHallId = 1
gTreasureHunt.curRoomPage = 1
gTreasureHunt.curRoomPlayerNum = 0
gTreasureHunt.curAmbushCdTime = 0
gTreasureHunt.curAmbushNum = 0
gTreasureHunt.curInRoomStatus = false
gTreasureHunt.curAmbuseStatus = false
gTreasureHunt.escortList = {}
gTreasureHunt.ambushList = {}
gTreasureHunt.detailRecordInfo = {}
gTreasureHunt.fightRetInfo = {}

function gTreasureHunt.clear()
   gTreasureHunt.pageTeamInfos = {}
   gTreasureHunt.detailMapInfo = nil
   gTreasureHunt.recordMemName1 = ""
   gTreasureHunt.recordMemName2 = ""
   gTreasureHunt.noticeList = {}
   gTreasureHunt.hallInfos = {}
   gTreasureHunt.speakerInfos = {}
   gTreasureHunt.curHallId = 1
   gTreasureHunt.curRoomPage = 1
   gTreasureHunt.curRoomPlayerNum = 0
   gTreasureHunt.curAmbushCdTime = 0
   gTreasureHunt.curAmbushNum = 0
   gTreasureHunt.escortList = {}
   gTreasureHunt.ambushList = {}
   gTreasureHunt.detailRecordInfo = {}
   gTreasureHunt.fightRetInfo = {}
   gTreasureHunt.curInRoomStatus = false
   gTreasureHunt.curAmbuseStatus = false
end

function gTreasureHunt.clearPageTeamInfos()
    gTreasureHunt.pageTeamInfos = {} 
end

function gTreasureHunt.addPageTeamInfo(info)
    table.insert(gTreasureHunt.pageTeamInfos, info)
end

function gTreasureHunt.getPageTeamInfoByIdx(idx)
    if idx == 0 or idx > #gTreasureHunt.pageTeamInfos then
        return nil
    end

    return gTreasureHunt.pageTeamInfos[idx]
end

function gTreasureHunt.getPageTeamInfoByRoomId(roomId)
    for _,teamInfo in pairs(gTreasureHunt.pageTeamInfos) do
        if teamInfo.roomId == roomId then
            return teamInfo
        end
    end 

    return nil  
end

function gTreasureHunt.refreshPageTeamInfoAmbushNum(groupId, roomId, ambushNum)
    if gTreasureHunt.curHallId == groupId then
        for _,teamInfo in pairs(gTreasureHunt.pageTeamInfos) do
            if teamInfo.roomId == roomId then
                teamInfo:refreshAmbushNum(ambushNum)
            end
        end
    end
end

function gTreasureHunt.getPageTeamSize()
    return #gTreasureHunt.pageTeamInfos
end

function gTreasureHunt.updatePageTeamInfo(info, idx)
    
end

-- 初始化
function gTreasureHunt.setDetailMapInfo(detailMapInfo)
    gTreasureHunt.detailMapInfo = detailMapInfo
end

--设置进入寻宝详细界面时的名字
function gTreasureHunt.setRecordMemName(name1, name2)
    gTreasureHunt.recordMemName1 = name1
    gTreasureHunt.recordMemName2 = name2    
end

--设置公告内容相关
function gTreasureHunt.clearNoticeList()
    gTreasureHunt.noticeList = {}
end

function gTreasureHunt.addNoticeInfo(noticeInfo,front)
    if front then
        table.insert(gTreasureHunt.noticeList, 1, noticeInfo)
    else
        table.insert(gTreasureHunt.noticeList, noticeInfo)
    end
end

function gTreasureHunt.getNoticeInfo(idx)
    if idx == 0 or idx > #gTreasureHunt.noticeList then
        return nil
    end

    return gTreasureHunt.noticeList[idx]
end

function gTreasureHunt.delNoticeInfo(groupId, roomId, mapId)
    local idx = 0
    for key, noticeInfo in ipairs(gTreasureHunt.noticeList) do
        if noticeInfo.groupId == groupId and noticeInfo.roomId == roomId and
            noticeInfo.mapId == mapId then
            local noticeDbInfo = DB.getTreasureHuntNoticeInfo(noticeInfo.id)
            if nil ~= noticeDbInfo and noticeDbInfo.type == 0 then
                idx = key
                break
            end
        end
    end

    if idx ~= 0 then
        table.remove(gTreasureHunt.noticeList, idx)
    end

    return idx
end

--跨服寻宝大厅信息
function gTreasureHunt.clearHallInfos()
    gTreasureHunt.hallInfos = {}
end

function gTreasureHunt.addHallInfo(id, num)
    gTreasureHunt.hallInfos[id] = {id = id, num = num}
end

function gTreasureHunt.getHallInfo(idx)
    if idx == 0 or idx > #gTreasureHunt.hallInfos then
        return nil
    end

    return gTreasureHunt.hallInfos[idx]
end

function gTreasureHunt.refreshHallInfo(id, num)
    gTreasureHunt.hallInfos[id].num = num
end

--跨服寻宝喇叭信息
function gTreasureHunt.clearSpeakerInfos()
    gTreasureHunt.speakerInfos = {}
end

function gTreasureHunt.addSpeakerInfo(time, name, sname, str, front)
    if front then
        table.insert(gTreasureHunt.speakerInfos, 1, {time=time, name=name, severName=sname,str=str})
    else
        table.insert(gTreasureHunt.speakerInfos, {time=time, name=name, severName=sname,str=str})
    end
end

function gTreasureHunt.getSpeakerInfo(idx)
    if idx == 0 or idx > #gTreasureHunt.speakerInfos then
        return nil
    end

    return gTreasureHunt.speakerInfos[idx]
end

function gTreasureHunt.setCurHallId(id)
    gTreasureHunt.curHallId = id
end

function gTreasureHunt.getCurHallId()
    return gTreasureHunt.curHallId
end

function gTreasureHunt.setCurRoomPage(page)
    gTreasureHunt.curRoomPage = page
end

function gTreasureHunt.getCurRoomPage()
    return gTreasureHunt.curRoomPage
end

--当前房间的人数
function gTreasureHunt.setCurRoomPlayerNum(num)
    gTreasureHunt.curRoomPlayerNum = num
end

function gTreasureHunt.getCurRoomPlayerNum()
    return gTreasureHunt.curRoomPlayerNum
end
    
--埋伏cd时间以及次数
function gTreasureHunt.setAmbushCdTime(time)
    gTreasureHunt.curAmbushCdTime = time
end

function gTreasureHunt.getAmbushCdTime()
    return gTreasureHunt.curAmbushCdTime
end

function gTreasureHunt.setAmbushNum(num)
    gTreasureHunt.curAmbushNum = num
end

function gTreasureHunt.getAmbushNum()
    return gTreasureHunt.curAmbushNum
end

function gTreasureHunt.getHallNameByIdx(idx)
    return gGetWords("treasureHuntWord.plist", "txt_hall_name"..idx)
end

function gTreasureHunt.getTeamInfoByRoomId(roomId)
    if #gTreasureHunt.pageTeamInfos == 0 then
        return nil
    end

    for key, teamInfo in pairs(gTreasureHunt.pageTeamInfos) do
        if teamInfo.roomId == roomId then
            return teamInfo
        end
    end

    return nil
end

function gTreasureHunt.getTerrainEventInfo(eventInfo)
    local formatWord = DB.getTreasureHuntEventInfo(eventInfo.eid).einfo
    if formatWord == "" then
        return
    end

    local eventWord = ""
    if eventInfo.eid == 1 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.username2)
    elseif eventInfo.eid == 2 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1,eventInfo.param2,eventInfo.param3)
    elseif eventInfo.eid == 3 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 4 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    elseif eventInfo.eid == 5 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    elseif eventInfo.eid == 6 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.username2,eventInfo.param1,eventInfo.param2)
    elseif eventInfo.eid == 7 then
        local terrain = gGetWords("treasureHuntWord.plist","terrain"..eventInfo.param2)
        local weather = gGetWords("treasureHuntWord.plist","weather"..eventInfo.param3)
        local day = gGetWords("treasureHuntWord.plist","day"..eventInfo.param4)
        eventWord = gReplaceParam(formatWord,eventInfo.param1,terrain,weather,day)
    elseif eventInfo.eid == 8 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 9 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 10 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.username2,eventInfo.param1)
    elseif eventInfo.eid == 11 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    elseif eventInfo.eid == 12 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    elseif eventInfo.eid == 13 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1)
    elseif eventInfo.eid == 14 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 15 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 16 then
        eventWord = formatWord
    elseif eventInfo.eid == 17 then
        eventWord = formatWord
    elseif eventInfo.eid == 18 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 19 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 20 then
        eventWord = gReplaceParam(formatWord,eventInfo.param1)
    elseif eventInfo.eid == 21 then
        eventWord = formatWord
    elseif eventInfo.eid == 22 then
        eventWord = formatWord
    elseif eventInfo.eid == 23 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.username2,eventInfo.param1)
    elseif eventInfo.eid == 24 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    elseif eventInfo.eid == 25 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    elseif eventInfo.eid == 26 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1,eventInfo.param2)
    elseif eventInfo.eid == 27 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1,eventInfo.param2)
    elseif eventInfo.eid == 28 then
        eventWord = gReplaceParam(formatWord,eventInfo.username1,eventInfo.param1)
    end
    return eventWord  
end

function gTreasureHunt.refreshTerrainAmbushInfo(param)

end

local road1StageIdx = {1,2,7}
local road2StageIdx = {3,4,5,6,7}
function gTreasureHunt.getHuntFightTimeTip(road, endTime)
    local totalFightTime = 0
    local time2 = DB.getTreasureHuntFightTime2()
    local time3 = DB.getTreasureHuntFightTime3()
    if road == TerrainRoadType.right then
        totalFightTime = #road1StageIdx * time2 + time3
    else
        totalFightTime = #road2StageIdx * time2 + time3
    end

    local leftTime = endTime - gGetCurServerTime()
    -- print("leftTime is:",leftTime, " endTime is:", endTime, "curServerTime is:",gGetCurServerTime())
    if leftTime == 0 then
        return gGetWords("treasureHuntWord.plist", "tip_stage_final2")
    end
    -- print("totalFightTime is:",totalFightTime)
    local elapseTime = totalFightTime - leftTime
    if elapseTime < 0 then
        elapseTime = 0
    end
    if leftTime <= time3 then
        if leftTime <= time3 / 2 then
            return gGetWords("treasureHuntWord.plist", "tip_stage_final2")
        else
            return gGetWords("treasureHuntWord.plist", "tip_stage_final1")
        end
    else
        local stageIdx = math.floor(elapseTime * 2 / time2)
        local bigStageIdx = math.floor(stageIdx / 2) + 1
        local roadStagIdx = 1
        -- print("bigStageIdx is:", bigStageIdx)
        if road == TerrainRoadType.right then
            roadStagIdx = road1StageIdx[bigStageIdx]
        else
            roadStagIdx = road2StageIdx[bigStageIdx]
        end
        if stageIdx % 2 == 0 then
            return gGetWords("treasureHuntWord.plist", "tip_stage_pre1",roadStagIdx)
        else
            return gGetWords("treasureHuntWord.plist", "tip_stage_pre2",roadStagIdx)
        end
    end

    return ""
end

function gTreasureHunt.clearEscortList()
    gTreasureHunt.escortList = {}
end

function gTreasureHunt.addEscortInfo(info)
    table.insert(gTreasureHunt.escortList, info)
end

function gTreasureHunt.getEscortInfoByIdx(idx)
    if idx == 0 or idx > #gTreasureHunt.escortList then
        return nil
    end
    
    return gTreasureHunt.escortList[idx]
end

function gTreasureHunt.clearAmbushList()
    gTreasureHunt.ambushList = {}
end

function gTreasureHunt.addAmbushInfo(info)
    table.insert(gTreasureHunt.ambushList, info)
end

function gTreasureHunt.getAmbushInfoByIdx(idx)
    if idx == 0 or idx > #gTreasureHunt.ambushList then
        return nil
    end
    
    return gTreasureHunt.ambushList[idx]
end

function gTreasureHunt.clearDetailRecordInfo()
    gTreasureHunt.detailRecordInfo = {}
    gTreasureHunt.detailRecordInfo.eventInfos = {}
    gTreasureHunt.detailRecordInfo.createEventInfos = {}
end

function gTreasureHunt.setDetailRecordInfo(etime)
    gTreasureHunt.detailRecordInfo.endTime = etime
end

function gTreasureHunt.addDetailRecordInfo(eventInfo,idx)
    if gTreasureHunt.detailRecordInfo.eventInfos[idx] == nil then
        gTreasureHunt.detailRecordInfo.eventInfos[idx] = {}
    end

    table.insert(gTreasureHunt.detailRecordInfo.eventInfos[idx], eventInfo)
end

function gTreasureHunt.addDetailRecordCreateInfo(eventInfo)
    table.insert(gTreasureHunt.detailRecordInfo.createEventInfos, eventInfo)
end

function gTreasureHunt.clearFightRetInfo()
    gTreasureHunt.fightRetInfo = {}
    gTreasureHunt.fightRetInfo.winner = 0
    gTreasureHunt.fightRetInfo.infos = {}
end

function gTreasureHunt.setFightRetInfoWiner(winner)
    gTreasureHunt.fightRetInfo.winner = winner
end

function gTreasureHunt.addFightRetInfoWiner(info)
    table.insert(gTreasureHunt.fightRetInfo.infos, info)
end

function gTreasureHunt.getNoticeInfoWord(noticeInfo,isTeamFormation)
    local formatWord = DB.getTreasureHuntNoticeInfo(noticeInfo.id).info
    if formatWord == "" then
        return
    end
    local nameColor = "w{c=0048ff;s=20;f=0}"
    if isTeamFormation then
        nameColor = "w{c=00deff;s=20;f=0}"
    end

    local groupName = gTreasureHunt.getHallNameByIdx(noticeInfo.groupId)

    local noticeWord = ""
    if noticeInfo.id == 1 or noticeInfo.id == 2 or noticeInfo.id == 3 then
        noticeWord = gReplaceParam(formatWord,nameColor,noticeInfo.username1,noticeInfo.param1, nameColor,noticeInfo.username2,noticeInfo.param2,groupName,noticeInfo.param3)
    elseif noticeInfo.id == 4 then
        noticeWord = gReplaceParam(formatWord,nameColor,noticeInfo.username1,nameColor,noticeInfo.username2)
    elseif noticeInfo.id == 5 or noticeInfo.id == 6 then
        noticeWord = gReplaceParam(formatWord,nameColor,noticeInfo.username1,nameColor,noticeInfo.username2,noticeInfo.param1)
    end
        
    return noticeWord 
end

function gTreasureHunt.setCurInRoomStatus(status)
    gTreasureHunt.curInRoomStatus = status
end

function gTreasureHunt.getCurInRoomStatus()
    return gTreasureHunt.curInRoomStatus
end

function gTreasureHunt.setCurAmbushStatus(status)
    gTreasureHunt.curAmbuseStatus = status
end

function gTreasureHunt.getCurAmbushStatus()
    return gTreasureHunt.curAmbuseStatus
end
