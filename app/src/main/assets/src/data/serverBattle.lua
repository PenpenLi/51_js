KING_RANK_NONE = 0 --没有进入天榜地榜
KING_RANK_GROUND = 2 --地榜
KING_RANK_SKY  = 1  --天榜
SERVER_BATTLE_TYPE1 = 1 --普通段位赛
SERVER_BATTLE_TYPE2 = 2 --巅峰对决

gServerBattle = {}
gServerBattle.honor = 0 --称号ID
gServerBattle.sectionLv   = 0 --段位等级
gServerBattle.kingRank  = 0 --王者排名
gServerBattle.oldHonor = 0 --
gServerBattle.oldSectionLv  = 0
gServerBattle.oldKingRank = 0 
gServerBattle.top5KingRanks = {}
gServerBattle.kingRanks = {}
gServerBattle.rivalInfos = {}
gServerBattle.exp = 0 --跨服战经验
gServerBattle.findNum = 0 --已匹配次数
gServerBattle.lastBattleInfo = {}
gServerBattle.sendMatchType = KING_RANK_NONE
gServerBattle.winning = 0 --连胜次数
gServerBattle.hasEnterFight = false --是否进入战斗界面(查找对手，观看日志)
gServerBattle.changeNum = 0
gServerBattle.buyNum = 0
gServerBattle.totalLeftFindNum = 0  --剩余匹配次数

function gServerBattle.clearTop5KingRanks()
    gServerBattle.top5KingRanks = {}
end

function gServerBattle.addTop5KingRanks(item)
    table.insert(gServerBattle.top5KingRanks,item)
end

function gServerBattle.clearKingRanks()
    gServerBattle.kingRanks = {}
end

function gServerBattle.addKingRanks(item)
    table.insert(gServerBattle.kingRanks,item)
end

function gServerBattle.clear()
    gServerBattle.top5KingRanks = {}
    gServerBattle.kingRanks = {}
    gServerBattle.rivalInfos = {}
    gServerBattle.clearBasicInfo()
    gServerBattle.exp = 0
    gServerBattle.matchedNums = 0
    gServerBattle.lastBattleInfo = {}
    gServerBattle.sendMatchType = KING_RANK_NONE
    gServerBattle.winning = 0
    gServerBattle.hasEnterFight = false
    gServerBattle.changeNum = 0
    gServerBattle.buyNum = 0
    gServerBattle.totalLeftFindNum = 0
end

function gServerBattle.clearRivalInfo()
    gServerBattle.rivalInfos = {}
end

function gServerBattle.setRivalInfo(power,teamInfo,name,duan,lv)
    -- gServerBattle.rivalInfo.power = power
    -- gServerBattle.rivalInfo.teamInfo = teamInfo
    -- gServerBattle.rivalInfo.name = name
    -- gServerBattle.rivalInfo.duan = duan
    -- gServerBattle.rivalInfo.lv = lv
end

function gServerBattle.initBasicInfo(honor,sectionLv,kingRank,season)
    gServerBattle.honor = honor
    gServerBattle.sectionLv   = sectionLv
    gServerBattle.kingRank  = kingRank
    gServerBattle.season = season
    gServerBattle.oldHonor = honor
    gServerBattle.oldSectionLv  = sectionLv
    gServerBattle.oldKingRank = kingRank  
end

function gServerBattle.clearBasicInfo()
    gServerBattle.honor = 0
    gServerBattle.sectionLv   = 0
    gServerBattle.kingRank  = 0
    gServerBattle.oldHonor = 0
    gServerBattle.oldSectionLv  = 0
    gServerBattle.oldKingRank = 0
end

function gServerBattle.setBasicInfo(honor,sectionLv,kingRank,addDan)
    if nil ~= addDan then
        gServerBattle.sectionLv = sectionLv
        gServerBattle.oldSectionLv = sectionLv - addDan
        if gServerBattle.oldSectionLv <= 0 then
            gServerBattle.oldSectionLv = 1
        end
    else
        gServerBattle.oldSectionLv  = gServerBattle.sectionLv
        gServerBattle.sectionLv = sectionLv
    end
    gServerBattle.oldHonor = gServerBattle.honor
    gServerBattle.oldKingRank = gServerBattle.kingRank
    gServerBattle.honor = honor
    
    if nil ~= kingRank then
        gServerBattle.kingRank = kingRank
    end
end

function gServerBattle.getDetailStarsBySecLv(secLv)
    
end

function gServerBattle.checkSectionSeasonFin()
    local conEndWeekDay,conEndTime = DB.getServerBattleEndTime()
    if conEndWeekDay == 0 then
        conEndWeekDay = 7
    end
    local curTimeTable = gGetDate("*t", gGetCurServerTime())
    local curWDay = (curTimeTable.wday + 6) % 7
    if curWDay == 0 then
        curWDay = 7
    end 

    if (curWDay > conEndWeekDay) or (curWDay == conEndWeekDay and curTimeTable.hour >= conEndTime) then
       return true
    end

    return false
end

function gServerBattle.getSectionSeasonFinTime()
    local conEndWeekDay,conEndTime = DB.getServerBattleEndTime()
    if conEndWeekDay == 0 then
        conEndWeekDay = 7
    end 
    local curTimeTable = gGetDate("*t", gGetCurServerTime())
    local curWDay = (curTimeTable.wday + 6) % 7
    if curWDay == 0 then
        curWDay = 7
    end 

    if (curWDay > conEndWeekDay) or (curWDay == conEndWeekDay and curTimeTable.hour >= conEndTime) then
        return nil
    elseif curWDay ==  conEndWeekDay then
        curTimeTable.hour = conEndTime
        curTimeTable.min  = 0
        curTimeTable.sec  = 0
        return os.time(curTimeTable)
    else
        curTimeTable.hour = 23
        curTimeTable.min = 59
        curTimeTable.sec = 59
        return os.time(curTimeTable) + 1 + (conEndWeekDay - curWDay - 1) * 24 * 3600 + conEndTime * 3600
    end
end

function gServerBattle.getNextSectionLv()
    local sectionType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)
    local nextLv = 0
    if sectionType < SERVER_BATTLE_DUAN16 then
        nextLv = DB.getServerBattleRangeSecLvByType(sectionType + 1)
    end
    return nextLv
end

function gServerBattle.checkDefendTeam()
    local teamInfo = Data.getUserTeam(TEAM_TYPE_WORLD_WAR_DEFEND)
    if not NetErr.isTeamEmpty(teamInfo) then
        return
    end

    teamInfo = Data.getUserTeam(TEAM_TYPE_ARENA_DEFEND)
    if not NetErr.isTeamEmpty(teamInfo) then
        Data.saveUserTeam(TEAM_TYPE_WORLD_WAR_DEFEND,teamInfo)
        return
    end

    teamInfo = Data.getUserTeam(TEAM_TYPE_ATLAS)
    if not NetErr.isTeamEmpty(teamInfo) then
        Data.saveUserTeam(TEAM_TYPE_WORLD_WAR_DEFEND,teamInfo)
        return
    end
end

function gServerBattle.checkAttackTeam()
    local teamInfo = Data.getUserTeam(TEAM_TYPE_WORLD_WAR_ATTACK)
    if not NetErr.isTeamEmpty(teamInfo) then
        return
    end

    teamInfo = Data.getUserTeam(TEAM_TYPE_ARENA_ATTACK)
    if not NetErr.isTeamEmpty(teamInfo) then
        Data.saveUserTeam(TEAM_TYPE_WORLD_WAR_ATTACK,teamInfo)
        return
    end

    teamInfo = Data.getUserTeam(TEAM_TYPE_ATLAS)
    if not NetErr.isTeamEmpty(teamInfo) then
        Data.saveUserTeam(TEAM_TYPE_WORLD_WAR_ATTACK,teamInfo)
        return
    end
end

function gServerBattle.checkTeamInfo()
    gServerBattle.checkDefendTeam()
    gServerBattle.checkAttackTeam()
end

function gServerBattle.getKingRankType()
    if gServerBattle.kingRank > 32 or gServerBattle.kingRank == 0 then
        return KING_RANK_NONE
    elseif gServerBattle.kingRank > 17 then
        return  KING_RANK_GROUND
    else
        return  KING_RANK_SKY
    end
end

function gServerBattle.getKingRankName(kingRankType)
    if kingRankType == KING_RANK_GROUND then
        return gGetWords("serverBattleWords.plist","ground_rank")
    elseif kingRankType == KING_RANK_SKY then
        return gGetWords("serverBattleWords.plist","sky_rank")
    else
        return ""
    end
end

function gServerBattle.getServerBattleType()
    local conEndWeekDay,conEndTime = DB.getServerBattleEndTime()
    local conBeginWeedDay,conBeginTime = DB.getServerBattleBeginTime()
    if conEndWeekDay == 0 then
        conEndWeekDay = 7
    end

    if conBeginWeedDay == 0 then
        conBeginWeedDay = 7
    end

    local beginTime = gGetWeekOneTimeByCur(conBeginWeedDay,conBeginTime)
    local endTime = gGetWeekOneTimeByCur(conEndWeekDay,conEndTime)
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8();
    if curTime >= beginTime and curTime<= endTime then
        return SERVER_BATTLE_TYPE1
    else
        return SERVER_BATTLE_TYPE2
    end
end



function gServerBattle.setLastBattleInfo(icon,name,sname)
    gServerBattle.lastBattleInfo.icon = icon
    gServerBattle.lastBattleInfo.name = name
    gServerBattle.lastBattleInfo.sname = sname
end

function gServerBattle.canFindRival()

    if gServerBattle.totalLeftFindNum <= 0 then
        gShowNotice(gGetWords("serverBattleWords.plist","txt_find_num_no_enough"))
        return false
    end

    return true
end

function gServerBattle.setTotalLeftFindNum()
    local maxTimes = DB.getMaxFindNumsOfSeverBattle()
    print("gServerBattle buy Num is:",gServerBattle.buyNum)
    gServerBattle.totalLeftFindNum = maxTimes + DB.getServerBattleVipBuyNums() * gServerBattle.buyNum - gServerBattle.findNum
    print("gServerBattle.totalLeftFindNum is:", gServerBattle.totalLeftFindNum)
end

function gServerBattle.isRivalsEmpty()
    if #gServerBattle.rivalInfos == 0 then
        return true
    end

    return false
end
