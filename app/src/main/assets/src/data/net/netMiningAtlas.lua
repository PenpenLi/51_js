
CMD_MINING_CHAPTER_LIST = "mining.chaplist"
function Net.sendMiningChapList(callback)
    local media = MediaObj:create()
    Net.chapListCallback = callback
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_LIST)
end

function Net.rec_mining_chaplist(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDigMine.mastery = obj:getInt("mastery")
    gDigMine.mapId = obj:getInt("chapterid")
    gDigMine.stageId = obj:getInt("stageid")
    gDigMine.drawLotsIdx = obj:getByte("drawidx")
    gDigMine.buyNum = obj:getInt("buynum")
    Data.setUsedTimes(VIP_MINING_ATLAS_RESET, gDigMine.buyNum)
    gDigMine.perfectBoxInfos = {}
    local perfectBoxInfos = tolua.cast(obj:getArray("clist"), "MediaArray")
    for i = 0, perfectBoxInfos:count() - 1 do
        local perfectInfo = tolua.cast(perfectBoxInfos:getObj(i), "MediaObj")
        if nil ~= perfectInfo then
            table.insert(gDigMine.perfectBoxInfos, {mapId=perfectInfo:getInt("id"),status=perfectInfo:getByte("status"),curstar=perfectInfo:getInt("curstar")})
        end
    end

    Panel.popUpVisible(PANEL_MINE_ATLAS)
    if Net.chapListCallback ~= nil then
        Net.chapListCallback()
        Net.chapListCallback = nil
    end
end

CMD_MINING_CHAPTER_INFO = "mining.chapinfo"
function Net.sendMiningChapInfo(chapterId)
    local media = MediaObj:create()
    Net.sendMiningChapterId = chapterId
    media:setInt("chapterid", chapterId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_INFO)
end

function Net.rec_mining_chapinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.detaiBoxStatus = {}
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP4, obj:getByte("fget"))
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP1, obj:getByte("sget"))
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP2, obj:getByte("eget"))
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP3, obj:getByte("bget"))

    gDigMine.stageInfos = {}
    local stageInfos = tolua.cast(obj:getArray("slist"), "MediaArray")
    for i = 0, stageInfos:count()-1 do
        local stageInfo = tolua.cast(stageInfos:getObj(i), "MediaObj")
        if nil ~= stageInfo then
            table.insert(gDigMine.stageInfos, {stageId=stageInfo:getInt("id"),star=stageInfo:getInt("star")})
        end
    end

    Panel.popUp(PANEL_MINE_ATLAS_DETAIL, Net.sendMiningChapterId)
end

CMD_MINING_CHAPTER_DRAW = "mining.chapdraw"
function Net.sendChapDraw(mapId, stageId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    media:setInt("stageid", stageId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_DRAW)
end

function Net.rec_mining_chapdraw(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDigMine.mapId = obj:getInt("chapterid")
    gDigMine.drawLotsIdx = obj:getByte("idx")
    gDispatchEvt(EVENT_ID_MINING_DRAW_LOTS)
end

CMD_MINING_CHAPTER_RESET = "mining.chapreset"
function Net.sendMiningChapreset()
    local media = MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_RESET)
end

function Net.rec_mining_chapreset(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mastery = obj:getInt("mastery")
    gDigMine.mapId= obj:getInt("chapterid")
    gDigMine.stageId = obj:getInt("stageid")
    gDigMine.drawLotsIdx = obj:getByte("drawidx")
    gDigMine.buyNum = obj:getInt("buynum")
    Data.setUsedTimes(VIP_MINING_ATLAS_RESET, gDigMine.buyNum)
    Net.updateReward(obj:getObj("reward"),2)
    gDigMine.perfectBoxInfos = {}
    gDigMine.drawLotsIdx = 0
    local perfectBoxInfos = tolua.cast(obj:getArray("clist"), "MediaArray")
    for i = 0, perfectBoxInfos:count() - 1 do
        local perfectInfo = tolua.cast(perfectBoxInfos:getObj(i), "MediaObj")
        if nil ~= perfectInfo then
            table.insert(gDigMine.perfectBoxInfos, {mapId=perfectInfo:getInt("id"),status=perfectInfo:getByte("status"),curstar=perfectInfo:getInt("curstar")})
        end
    end

    gDispatchEvt(EVENT_ID_MINING_ATLAS_REFRESH)
end

CMD_MINING_CHAPTER_GET_FULL_BOX = "mining.getfbox"
function Net.sendMiningGetFBox(mapId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    Net.sendMiningGetFBoxMapId = mapId
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_GET_FULL_BOX)
end

function Net.rec_mining_getfbox(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP4, MINE_ATLAS_BOX_STATUS3)
    gDigMine.updatePerfectBoxInfos(Net.sendMiningGetFBoxMapId , MINE_ATLAS_BOX_STATUS3, 30)
    gDispatchEvt(EVENT_ID_MINING_REFRESH_GETBOX, DETAIL_BOX_STEP4)
end

CMD_MINING_CHAPTER_GET_SMALL_BOX = "mining.getsbox"
function Net.sendMiningGetSBox(mapId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_GET_SMALL_BOX)
end

function Net.rec_mining_getsbox(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP1,MINE_ATLAS_BOX_STATUS3)
    gDispatchEvt(EVENT_ID_MINING_REFRESH_GETBOX, DETAIL_BOX_STEP1)
end

CMD_MINING_CHAPTER_EVENT_BOX_INFO = "mining.eboxinfo"
function Net.sendMiningEBoxInfo(mapId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_EVENT_BOX_INFO)
end

function Net.rec_mining_eboxinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local boxInfo = obj:getObj("boxinfo")
    if nil == boxInfo then
        return
    end

    local eid1 = boxInfo:getInt("eid1")
    local enum1 = boxInfo:getInt("enum1")
    local eid2 = boxInfo:getInt("eid2")
    local enum2 = boxInfo:getInt("enum2")
    local eid3 = boxInfo:getInt("eid3")
    local enum3 = boxInfo:getInt("enum3")
    local diamond = boxInfo:getInt("diamond")
    gDigMine.mineAtlasEventBox = {items = {{id = eid1, num = enum1}, {id = eid2, num = enum2}, {id = eid3, num = enum3}}, dia = diamond}

    Panel.popUpVisible(PANEL_MINE_ATLAS_BOX, gDigMine.mapId, 2)
end

CMD_MINING_CHAPTER_EVENT_BOX_BUY = "mining.eboxbuy"
function Net.sendMiningEBoxBuy(mapId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_EVENT_BOX_BUY)
end

function Net.rec_mining_eboxbuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)

    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP2, MINE_ATLAS_BOX_STATUS3)
    gDispatchEvt(EVENT_ID_MINING_REFRESH_GETBOX, DETAIL_BOX_STEP2)
end

CMD_MINING_CHAPTER_GET_BIG_BOX = "mining.getbbox"
function Net.sendMiningGetBBox(mapId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_GET_BIG_BOX)
end

function Net.rec_mining_getbbox(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),1)
    gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP3, MINE_ATLAS_BOX_STATUS3)
    gDispatchEvt(EVENT_ID_MINING_REFRESH_GETBOX, DETAIL_BOX_STEP3)
end

CMD_MINING_CHAPTER_ENTER = "mining.chapenter"
function Net.sendChapterEnter(mapId, stageId)
    local media = MediaObj:create()
    media:setInt("mid", mapId)
    media:setInt("sid", stageId)
    Net.sendAtlasEnterParam = {}
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_ENTER)
end

function Net.rec_mining_chapenter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)
    Battle.setDropNum(obj:getInt("item"),table.getn(enemyFormations))
    Net.updateReward(obj:getObj("reward"))
    Battle.battleType=BATTLE_TYPE_MINING_ATLAS

    local maxRound=DB.getAtlasRound()
    -- local stage = DB.getMineStageById(gDigMine.statusLv)
    -- Net.sendMonsterSize(enemyFormations,stage)
    gBattleData = Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,"b007",power)
end

CMD_MINING_CHAPTER_FIGHT = "mining.chapfight"
function Net.sendMiningChapterFight(mapId,stageId, starNum)
    local media = MediaObj:create()
    media:setInt("mid", mapId)
    media:setInt("sid", stageId)

    -- TODO
    media:setInt("star", starNum)
    media:setObjArray("blist",Battle.getLogData())
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_FIGHT)
end

function Net.rec_mining_chapfight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDigMine.mapId = obj:getInt("mid")
    gDigMine.stageId = obj:getInt("sid")
    Battle.reward.starNum = obj:getInt("star")
    if obj:containsKey("starobj") then
        local starObj = obj:getObj("starobj")
        local status = starObj:getByte("status")
        local curStar = starObj:getInt("curstar")
        gDigMine.updatePerfectBoxInfos(gDigMine.mapId, status, curStar)
    end

    local rewardObj=obj:getObj("reward")
    if nil ~= rewardObj then
        local cardList=rewardObj:getArray("tcard")
        if nil ~= cardList then
            -- cardList = tolua.cast(cardList,"MediaArray")
            -- for i = 0, cardList:count()-1 do
            --     local cardObj = cardList:getObj(i)
            --     cardObj = tolua.cast(cardObj,"MediaObj")
            --     local card={}
            --     card.cardid=cardObj:getInt("id")
            --     card.exp=cardObj:getInt("exp")
            --     if(stage)then
            --         card.addExp=stage.exp_card
            --     else
            --         card.addExp=0
            --     end
            --     table.insert(Battle.reward.formation,card)
            -- end
        end

        Battle.reward.shows= Net.updateReward(rewardObj,0)
    end

    if Battle.win == 1 then
        gDigMine.updateStageInfo(gDigMine.mapId, gDigMine.stageId, Battle.reward.starNum)
        gDigMine.updateDetailBoxStatusByWin()
    end
    gDigMine.drawLotsIdx = 0
    -- gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    Panel.popUp(PANEL_ATLAS_FINAL)
end


CMD_MINING_CHAPTER_SWEEP = "mining.chapsweep"
function Net.sendMiningChapterSweep(mapId,stageId)
    local media = MediaObj:create()
    media:setInt("chapterid", mapId)
    media:setInt("stageid", stageId)
    Net.sendExtensionMessage(media, CMD_MINING_CHAPTER_SWEEP)
end

function Net.rec_mining_chapsweep(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Battle.reward.starNum = 3
    Battle.reward.shows = Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    gDigMine.mapId = obj:getInt("chapterid")
    gDigMine.stageId = obj:getInt("stageid")
    gDigMine.updateStageInfo(gDigMine.mapId, gDigMine.stageId, 3)
    if obj:containsKey("starobj") then
        local starObj = obj:getObj("starobj")
        local status = starObj:getByte("status")
        local curStar = starObj:getInt("curstar")
        gDigMine.updatePerfectBoxInfos(gDigMine.mapId, status, curStar)
    end
    gDigMine.updateDetailBoxStatusByWin()
    gDigMine.drawLotsIdx = 0
    gDispatchEvt(EVENT_ID_MINING_ATLAS_SWEEP)
    gDigMine.drawLotsIdx = 0
    Panel.popUpVisible(PANEL_MINE_ATLAS_SWEEP)
end

CMD_MINING_BUY_MINER = "mining.buyminer"
function Net.sendMiningBuyMiner()
    local media = MediaObj:create()
    Net.sendExtensionMessage(media, CMD_MINING_BUY_MINER)
end

function Net.rec_mining_buyminer(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    -- reward扣钻
    Net.updateReward(obj:getObj("reward"),0)
    gDigMine.miner = obj:getInt("miner")
    gDispatchEvt(EVENT_ID_MINING_BUY_MINERS)
end
