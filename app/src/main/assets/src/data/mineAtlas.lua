MINE_ATLAS_BOX_STATUS1 = 0 -- 未达条件
MINE_ATLAS_BOX_STATUS2 = 1 -- 未领取
MINE_ATLAS_BOX_STATUS3 = 2 -- 已领取

DETAIL_BOX_STEP1 = 1
DETAIL_BOX_STEP2 = 2
DETAIL_BOX_STEP3 = 3
DETAIL_BOX_STEP4 = 4

MAX_PERFECT_STAR = 30

MINE_ATLAS_RET_CONDITION1 = 1 --全队总血量大于@%
MINE_ATLAS_RET_CONDITION2 = 2 --全队死亡人数少于@人
MINE_ATLAS_RET_CONDITION3 = 3 --击杀全部敌人
MINE_ATLAS_RET_CONDITION4 = 4 --禁用@阵营武将
MINE_ATLAS_RET_CONDITION5 = 5 --@回合内击杀BOSS
MINE_ATLAS_RET_CONDITION6 = 6 --所有英雄血量始终高于@%
MINE_ATLAS_RET_CONDITION7 = 7 --上阵@个不同阵营英雄

MINE_ATLAS_DRAW_LOT_RET1 = 1 --前排攻击
MINE_ATLAS_DRAW_LOT_RET2 = 2 --前排血量
MINE_ATLAS_DRAW_LOT_RET3 = 3 --前排血量，后排攻击
MINE_ATLAS_DRAW_LOT_RET4 = 4 --前排攻击，后排血量
MINE_ATLAS_DRAW_LOT_RET5 = 5 --全部英雄血量
MINE_ATLAS_DRAW_LOT_RET6 = 6 --全部英雄攻击
MINE_ATLAS_DRAW_LOT_RET7 = 7 --直接跳过本关卡

MINE_ATLAS_BOX_STAR1 = 3
MINE_ATLAS_BOX_STAR2 = 6
MINE_ATLAS_BOX_STAR3 = 10

gDigMine = gDigMine or {}

--挖矿熟练度
gDigMine.mastery = 0
gDigMine.mapId = 0
gDigMine.stageId = 0
gDigMine.challengeNum = 0
gDigMine.stageInfos = {}
gDigMine.perfectBoxInfos = {}
gDigMine.detaiBoxStatus = {}
gDigMine.drawLotsIdx = 0 --抽签索引
gDigMine.mineAtlasEventBox = {}
gDigMine.resetBuyNums = 0
gDigMine.atlasRets = {}

function gDigMine.ClearMineAtals()
    gDigMine.mastery = 0
    gDigMine.mapId = 0 
    gDigMine.stageId = 0
    gDigMine.challengeNum = 0 
    gDigMine.perfectBoxInfos = {}
    gDigMine.stageInfos = {}
    gDigMine.drawLotsIdx = 0
    gDigMine.mineAtlasEventBox = {}
    gDigMine.resetBuyNums = 0
    gDigMine.atlasRets = {}
end

function gDigMine.getStageStar(stageId)
    local count = #gDigMine.stageInfos
    if count == 0 then
        return
    end

    local stageInfo = nil
    for i = 1, count do
        stageInfo = gDigMine.stageInfos[i]
        if stageInfo.stageId == stageId then
            --用星星数判断状态
            return stageInfo.star
        end
    end
end

function gDigMine.setDetailBoxStatus(stepType, status)
    gDigMine.detaiBoxStatus[stepType] = status
end

function gDigMine.updateDetailBoxStatusByWin()
    if gDigMine.stageId >= 3 and gDigMine.detaiBoxStatus[DETAIL_BOX_STEP1] == MINE_ATLAS_BOX_STATUS1 then
        gDigMine.detaiBoxStatus[DETAIL_BOX_STEP1] = MINE_ATLAS_BOX_STATUS2
    end

    if gDigMine.stageId >= 6 and gDigMine.detaiBoxStatus[DETAIL_BOX_STEP2] == MINE_ATLAS_BOX_STATUS1 then
        gDigMine.detaiBoxStatus[DETAIL_BOX_STEP2] = MINE_ATLAS_BOX_STATUS2
    end

    if gDigMine.stageId >= 10 and gDigMine.detaiBoxStatus[DETAIL_BOX_STEP3] == MINE_ATLAS_BOX_STATUS1 then
        gDigMine.detaiBoxStatus[DETAIL_BOX_STEP3] = MINE_ATLAS_BOX_STATUS2
    end
end

function gDigMine.getStars(mapId)
    local curStars = 0
    local count = #gDigMine.stageInfos
    if count ~= 0 then
        for _, var in ipairs(gDigMine.stageInfos) do
            curStars = curStars + toint(var.star)
        end
    end

    return curStars
end

function gDigMine.checkMasteryLimit(mapId)
    local chapterInfo = DB.getMineAtlasChapterInfo(mapId)
    if nil == chapterInfo then
        return true
    end

    if gDigMine.mastery < chapterInfo.mastery then
        gShowNotice(gGetWords("noticeWords.plist","no_enough_mastery", chapterInfo.mastery))
        return true
    end

    return false
end

function gDigMine.getDrawLotDesc(retCondition,value)
    local desc = ""
    if retCondition == MINE_ATLAS_RET_CONDITION3 then
        desc = gGetWords("mineWords.plist","txt_ret_condition3")
    elseif retCondition == MINE_ATLAS_RET_CONDITION4 then
        local country = gGetWords("cardAttrWords.plist","country_"..value)
        desc = gGetWords("mineWords.plist","txt_ret_condition4", country)
    else
        desc = gGetWords("mineWords.plist","txt_ret_condition"..retCondition, value)
    end
    return desc
end

function gDigMine.updateStageInfo(mapId, stageId,starNum)
    local curStars = 0
    for _, var in ipairs(gDigMine.stageInfos) do
        if var.stageId == stageId then
            var.star = starNum
        end
        curStars = curStars + var.star 
    end
end

function gDigMine.canChallengeCurMap(curMapId)
    if gDigMine.mapId == 0 then
        return true
    end

    if gDigMine.mapId ~= curMapId then
        gShowNotice(gGetWords("mineWords.plist","txt_atlas_map_limit"))
        return false
    end

    return true
end

function gDigMine.canOpenAtalsBBox(boxStep)
    if gDigMine.detaiBoxStatus[DETAIL_BOX_STEP3] ~= MINE_ATLAS_BOX_STATUS2 then
        return false
    end
    local totalStars = gDigMine.getStars(gDigMine.mapId)
    if boxStep == 1 and (totalStars >= 10  and totalStars <= 19)  then
        return true
    elseif boxStep == 2 and (totalStars >= 20 and totalStars <= 29)  then
        return true
    elseif boxStep == 3 and (totalStars == 30)  then
        return true
    end

    return false
end

function gDigMine.checkMineAtlasTeam()
    local teamInfo = Data.getUserTeam(TEAM_TYPE_ATLAS_MINING)
    if not NetErr.isTeamEmpty(teamInfo) then
        return
    end

    teamInfo = Data.getUserTeam(TEAM_TYPE_ATLAS)
    if not NetErr.isTeamEmpty(teamInfo) then
        Data.saveUserTeam(TEAM_TYPE_ATLAS_MINING,teamInfo)
        return
    end
end

function gDigMine.clearAtlasRets()
    gDigMine.atlasRets = {}
end

function gDigMine.getSpeRetIdx(retType)
    if table.count(gDigMine.atlasRets) == 0 or 
        gDigMine.atlasRets.types == nil then
        return -1
    end

    for idx, var in pairs(gDigMine.atlasRets.types) do
        if var == retType then
            return idx
        end
    end

    return -1
end

function gDigMine.getPerfectBoxStatus(mapId)
    for _,var in ipairs(gDigMine.perfectBoxInfos) do
        if var.mapId == mapId then
            return var.status
        end
    end
end

function gDigMine.getDrawLotsFlaByIdx()
    if gDigMine.drawLotsIdx == 0 then
        return ""
    end

    if gDigMine.drawLotsIdx == 1 or gDigMine.drawLotsIdx == 2 then
        return "ui_haidan_1"
    elseif gDigMine.drawLotsIdx == 3 or gDigMine.drawLotsIdx == 4 then
        return "ui_haidan_2"
    elseif gDigMine.drawLotsIdx == 5 or gDigMine.drawLotsIdx == 6 then
        return "ui_haidan_3"
    elseif  gDigMine.drawLotsIdx == 7 then
        return "ui_haidan_4"
    end

    return ""
end

function gDigMine.updatePerfectBoxInfos(mapId, status, star)
    for _,var in ipairs(gDigMine.perfectBoxInfos) do
        if var.mapId == mapId then
            var.curstar = star
            var.status = status
            break
        end
    end
end

function gDigMine.getPerfectBoxStars(mapId)
    for _,var in ipairs(gDigMine.perfectBoxInfos) do
        if var.mapId == mapId then
            return var.curstar
        end
    end
end
