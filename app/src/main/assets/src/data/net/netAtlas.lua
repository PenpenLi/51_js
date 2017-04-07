----副本进入
function Net.sendAtlasEnter(mapid,stageid,type)

    local media=MediaObj:create()

    media:setByte("mid", mapid)
    media:setInt("sid", stageid)
    media:setByte("type",type)

    Net.sendAtlasEnterParam={mapid=mapid,stageid=stageid,type=type}
    Net.sendExtensionMessage(media, CMD_ATLAS_ENTER,false)
    if (TDGAMission) then
        gLogMissionBegin(tostring(mapid) .. "-" .. tostring(stageid) .. "-" .. tostring(type))
    end
end

function Net.sendMonsterSize(enemyFormations,stage)
    for key, formations in pairs(enemyFormations) do
        for key2, role in pairs(formations) do
            local monsterid=stage["group"..key.."_"..(role.pos+1)]
            if(monsterid~=0)then
                local monster= DB.getMonsterById(monsterid)
                if(monster)then
                    role.roleScale=monster.size/100
                end
            end
        end
    end
end

function Net.recAtlasEnter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)

    Net.sendAtlasEnterParam.itemnum=obj:getInt("item")
    Battle.setDropNum(obj:getInt("item"),table.getn(enemyFormations))
    Net.updateReward(obj:getObj("reward"))

    local isFirstEnter= Data.isFirstEnterAtlas(
        Net.sendAtlasEnterParam.mapid,
        Net.sendAtlasEnterParam.stageid,
        Net.sendAtlasEnterParam.type)


    if( isFirstEnter and
        DB.IsInTeachStage( Net.sendAtlasEnterParam.type ,  Net.sendAtlasEnterParam.mapid , Net.sendAtlasEnterParam.stageid)
        )then
        gBattleData=Battle.guideBattle("fightScript/battle"..Net.sendAtlasEnterParam.stageid..".plist")
        Battle.battleType=BATTLE_TYPE_GUIDE
        return
    end

    local stage=nil
    if(isFirstEnter   )then
        stage=DB.getStageById(
            Net.sendAtlasEnterParam.mapid,
            Net.sendAtlasEnterParam.stageid,
            10)

    end

    if(stage==nil)then
        stage=DB.getStageById(
            Net.sendAtlasEnterParam.mapid,
            Net.sendAtlasEnterParam.stageid,
            Net.sendAtlasEnterParam.type)
    end
    local bgMap=""
    if(stage)then
        bgMap="b"..stage.backgroud_id
    end
    Net.sendMonsterSize(enemyFormations,stage)
    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,DB.getAtlasRound(),bgMap,power)
    Battle.battleType=BATTLE_TYPE_ATLAS


    if(Net.sendAtlasEnterParam.type==0 and isFirstEnter)then

        Battle.beganStoryId=Story.getAtlasStoryWord(Net.sendAtlasEnterParam.mapid,Net.sendAtlasEnterParam.stageid,"began")
        Battle.appearStoryId=Story.getAtlasStoryWord(Net.sendAtlasEnterParam.mapid,Net.sendAtlasEnterParam.stageid,"appear")
        Battle.endStoryId=Story.getAtlasStoryWord(Net.sendAtlasEnterParam.mapid,Net.sendAtlasEnterParam.stageid,"end")
    end

end

----副本信息
function Net.sendAtlasInfo(mapid,stageid,type)

    local media=MediaObj:create()

    media:setByte("mid", mapid)
    media:setInt("sid", stageid)
    media:setByte("type",type)

    Net.sendExtensionMessage(media, CMD_ATLAS_GETINFO)
end


function Net.recAtlasInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    if (obj:containsKey("double")) then
        ret.double=obj:getBool("double")
    end

    if (obj:containsKey("stageinfo")) then
        local stageInfo = tolua.cast(obj:getObj("stageinfo"),"MediaObj")
        ret = Net.parserStageInfo(stageInfo, ret)
    end

    gDispatchEvt(EVENT_ID_ATLAS_ENTER_INFO,ret)
end


----副本购买次数
function Net.sendBuyBatNum(mapid,stageid,type,num)

    local media=MediaObj:create()

    media:setByte("mid", mapid)
    media:setInt("sid", stageid)
    media:setByte("type",type)
    media:setInt("num",num)

    Net.sendBuyBatNumParam={mapid=mapid,stageid=stageid,type=type}
    Net.sendExtensionMessage(media, CMD_ATLAS_BUYBATNUM)
end


function Net.recAtlasBuyBatNum(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    if (obj:containsKey("stageinfo")) then
        ret = Net.parserStageInfo(obj:getObj("stageinfo"))
    end
    local atlas=  Data.updateAtlasStatus(Net.sendBuyBatNumParam,ret.batNum)
    if(atlas)then
        atlas.buyNum=ret.buyNum
    end
    Net.updateReward(obj:getObj("reward"))
    gDispatchEvt(EVENT_ID_ATLAS_ENTER_INFO,ret)

end

----章节奖励领取信息
function Net.sendAtlasRewinfo(mapid,stageid,type)

    local media=MediaObj:create()

    media:setByte("mid", mapid)
    media:setInt("sid", stageid)
    media:setByte("type",type)

    Net.sendExtensionMessage(media, CMD_ATLAS_CRYSTALREWARDINFO)
end


function Net.recAtlasRewinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

end


----章节改名
function Net.sendSetName(name)

    local media=MediaObj:create()
    media:setString("name",name)
    Net.sendExtensionMessage(media, CMD_ATLAS_CHANGENAME)
end


function Net.recSetName(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    if(obj:containsKey("uvobj"))then
        Net.parseUserInfo(obj:getObj("uvobj"))
    end
    if gUserInfo.name~="" then
        gLogAccountName(gUserInfo.name)
        local param2 = {}
        param2['name'] = gUserInfo.name
        gLogEvent2("set_name",param2)
    end

    gAccount:roleInitFinish()
    gDispatchEvt(EVENT_ID_SET_NAME)
end



function Net.sendChangeName(name)

    local media=MediaObj:create()
    media:setString("name",name)
    Net.sendExtensionMessage(media, CMD_SYSTEM_CHANGE_NAME)
end


function Net.recChangeName(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    if(obj:containsKey("time"))then
        local time=obj:getInt("time")-gGetCurServerTime()
        gConfirm(gGetWords("noticeWords.plist","rename_fail",gParserHourTime(time)))
        return

    end

    if(obj:containsKey("uvobj"))then
        Net.parseUserInfo(obj:getObj("uvobj"))

        if(gUserInfo.name~="")then
            gShowNotice(gGetWords("noticeWords.plist","rename_success"))
        end
    end
    Net.updateReward(obj:getObj("reward"),0)

    gDispatchEvt(EVENT_ID_SET_NAME)
    gLogEvent("change_name")
end


----章节奖励领取
function Net.sendAtlasGetRewinfo(mapid,index,type)

    local media=MediaObj:create()

    media:setByte("mid", mapid)
    media:setByte("index", index)
    media:setByte("type",type)

    Net.sendAtlasGetRewinfoParam={mapid=mapid,index=index,type=type}
    Net.sendExtensionMessage(media, CMD_ATLAS_RECCRYSTALREWARD)
end


function Net.recAtlasGetRewinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.getAtlasBox( Net.sendAtlasGetRewinfoParam.mapid, Net.sendAtlasGetRewinfoParam.index, Net.sendAtlasGetRewinfoParam.type)

    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_ATLAS_BOX_GOT)
    Net.sendAtlasGetRewinfoParam=nil
end




----扫荡
function Net.sendAtlasSweep(mapid,stageid,type,count)
    if(NetErr.atlasSweep( type, mapid, stageid,count)==false)then
        return
    end
    local media=MediaObj:create()


    media:setByte("mid", mapid)
    media:setInt("sid", stageid)
    media:setByte("type",type)
    media:setInt("count", count)
    Net.sendAtlasSweepParam={mapid=mapid,stageid=stageid,type=type,count=count}
    Net.sendExtensionMessage(media, CMD_ATLAS_SWEEP)
   local td_param = {}
   local map = tostring(mapid) .. "-" .. tostring(stageid) .. "-" .. tostring(type)
   td_param['map'] = map
   gLogEvent('atlas.sweep'..tostring(count),td_param)
end




function Net.recAtlasSweep(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    ret.rewards={}
    local infoList=obj:getArray("info")
    if(infoList)then
        infoList=tolua.cast(infoList,"MediaArray")
        for i=0, infoList:count()-1 do
            local infoObj=infoList:getObj(i)
            infoObj=tolua.cast(infoObj,"MediaObj")
            local reward={}
            reward.rewards=Net.updateReward(infoObj,0)
            table.insert( ret.rewards,reward)
        end
    end

    Net.updateReward(obj:getObj("reward"),0)
    Scene.showLevelUp = false;

    local num=Data.getAtlasBatNum(Net.sendAtlasSweepParam)
    ret.batData=Data.updateAtlasStatus(Net.sendAtlasSweepParam,num-Net.sendAtlasSweepParam.count)

    local cru=nil
    if(obj:containsKey("cru"))then
        cru={}
        local curObj=obj:getObj("cru")
        cru.name=curObj:getString("name")
        cru.level=curObj:getInt("lv")
        cru.id=curObj:getLong("id")
        cru.cid=curObj:getInt("cid")
        cru.quality=curObj:getByte("quality")
        cru.mid = curObj:getInt("mid")
    end

    --出现商店（奸商、黑市）
    local bolopen = Net.updateLimitShop(obj)

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel and panel.__panelType==PANEL_ATLAS_AUTO)then
        Panel.popBack(panel:getTag())
    end
    Panel.popUp(PANEL_ATLAS_AUTO,ret,cru)
    gDispatchEvt(EVENT_ID_SWEEP_ATLAS)

    if (bolopen) then
        Data.limit_open = true
    end
end


----副本结算
function Net.sendAtlasFight(star,teach)

    local media=MediaObj:create()


    media:setByte("mid", Net.sendAtlasEnterParam.mapid)
    media:setInt("sid", Net.sendAtlasEnterParam.stageid)
    media:setByte("type",Net.sendAtlasEnterParam.type)
    media:setInt("star",star)
    media:setInt("num",Net.sendAtlasEnterParam.itemnum)
    media:setObjArray("blist",Battle.getLogData())
    if(teach)then
        media:setBool("teach",true)
    end
    Net.sendExtensionMessage(media, CMD_ATLAS_FIGHT,true)
    local mid = Net.sendAtlasEnterParam.mapid
    local sid =  Net.sendAtlasEnterParam.stageid
    local type = Net.sendAtlasEnterParam.type
    local id = tostring(mid) .. "-" .. tostring(sid) .. "-" .. tostring(type)
    local auto =cc.UserDefault:getInstance():getIntegerForKey("battle_auto",0)
    local td_param = {}
    td_param['round'] = tostring(gTDParam.battle_round)
    td_param['missionid'] = id
    td_param['battle_auto'] = tostring(auto)
    if (TDGAMission) then
        if (Battle.win == 1) then
            gLogMissionCompleted(id)
            gLogEvent('mission-comp', td_param)
        else
            gLogMissionFailed(id, "fail")
            gLogEvent('mission-fail', td_param)
        end
    end
end




function Net.recAtlasFight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Battle.reward={}
    Battle.reward.formation={}

    local userstageObj=obj:getObj("userstage")

    if(userstageObj)then
        local oldMaxMap0=gAtlas.maxMap0
        local oldMaxStage0=gAtlas.maxStage0

        for i=0, 10 do
            gAtlas["maxMap"..i]=userstageObj:getByte("maxcha"..i)
            gAtlas["maxStage"..i]=userstageObj:getInt("maxsta"..i)
        end
        gAtlas.isShowPassedFlag=false
        if 0 == Net.sendAtlasEnterParam.type then
            gAtlas.isShowPassedFlag=Data.isShowAtlasPassedFla(Net.sendAtlasEnterParam,gAtlas.maxMap0, gAtlas.maxStage0,oldMaxMap0,oldMaxStage0)
        end

    end

    local starObj=obj:getObj("stageinfo")
    if(starObj)then
        local starItem = Net.parserStageInfo(starObj)
        Data.updateAtlas(starItem)
        Battle.reward.starNum=starItem.num
    end

    local stage=DB.getStageById(
        Net.sendAtlasEnterParam.mapid,
        Net.sendAtlasEnterParam.stageid,
        Net.sendAtlasEnterParam.type)

    local rewardObj=obj:getObj("reward")
    if nil ~= rewardObj then
        local cardList=rewardObj:getArray("tcard")
        if(cardList)then
            cardList=tolua.cast(cardList,"MediaArray")
            for i=0, cardList:count()-1 do
                local cardObj=cardList:getObj(i)
                cardObj=tolua.cast(cardObj,"MediaObj")
                local card={}
                card.cardid=cardObj:getInt("id")
                card.exp=cardObj:getInt("exp")
                if(stage)then
                    card.addExp=stage.exp_card
                else
                    card.addExp=0
                end
                table.insert(Battle.reward.formation,card)
            end
        end

        Battle.reward.shows= Net.updateReward(rewardObj,0)
    end

    if(obj:containsKey("uvobj"))then
        Net.parseUserInfo(obj:getObj("uvobj"))
    end

    -- 精英首次三星翻牌
    CoreAtlas.EliteFlop.setBattleFlop(obj)

    --出现商店（奸商、黑市）
    local bolopen = Net.updateLimitShop(obj)

    Scene.showLevelUp = false
    Panel.popUp(PANEL_ATLAS_FINAL)

    local count = table.getn(Unlock.stack);
    if (bolopen and count<=0) then
        local param={type=Data.limit_stype}
        Panel.popUpVisible(PANEL_SHOP_NOTICE,param)
    end
end




----活动副本进入
function Net.sendActAtlasEnter(stageid,type)

    local media=MediaObj:create()

    media:setInt("sid", stageid)
    media:setByte("type",type)

    Net.sendAtlasEnterParam={mapid=mapid,stageid=stageid,type=type}
    Net.sendExtensionMessage(media, CMD_ATLAS_ACT_ENTER)
end


function Net.recActAtlasEnter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)

    Battle.setDropNum(obj:getInt("item"),table.getn(enemyFormations))
    Net.updateReward(obj:getObj("reward"))
    Battle.battleType=Data.getBattleType( Net.sendAtlasEnterParam.type)

    local maxRound=DB.getAtlasRound()
    local data= DB.getActStageInfoById( Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid)
    if(data)then
        maxRound=data.batparam
    end


    local stage=DB.getStageById(
        1,
        Net.sendAtlasEnterParam.stageid,
        Net.sendAtlasEnterParam.type)
    local bgMap=""
    if(stage)then
        bgMap="b"..stage.backgroud_id
    end

    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,bgMap,power)

end




----活动副本结算
function Net.sendActAtlasFight(hp)

    local media=MediaObj:create()
    media:setInt("sid", Net.sendAtlasEnterParam.stageid)
    media:setByte("type",Net.sendAtlasEnterParam.type)
    media:setObjArray("blist",Battle.getLogData())
    media:setInt("dmg",hp)
    Net.sendActAtlasFightHp=hp
    Net.sendExtensionMessage(media, CMD_ATLAS_ACT_FIGHT,true)
end




function Net.recActAtlasFight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Battle.reward={}
    Battle.reward.formation={}

    if(obj:containsKey("uvobj"))then
        Net.parseUserInfo(obj:getObj("uvobj"))
    end

    local actstage = obj:getObj("actstage")
    local dnum     = 0
    local cdTime   = 0
    local batNum   = 0
    if nil ~= actstage then
        dnum = actstage:getByte("dnum")
        batNum = actstage:getByte("num")
        cdTime = actstage:getInt("cdtime")
        local actsStage = DB.getActStageByType(Net.sendAtlasEnterParam.type)
        Battle.updateActAtlasInfo(Net.sendAtlasEnterParam.type, batNum, cdTime)
    end

    local rewardObj=obj:getObj("reward")
    if nil ~= rewardObj then
        Battle.reward.shows= Net.updateReward(rewardObj, 0)
    end
    Scene.showLevelUp = false
    Panel.popUp(PANEL_ACT_ATLAS_FINAL,Net.sendActAtlasFightHp,dnum)
end

----副本信息
function Net.sendActAtlasInfo(type)

    local media=MediaObj:create()

    media:setByte("type",type)

    Net.sendExtensionMessage(media, CMD_ATLAS_ACT_GETINFO)
end


function Net.recActAtlasInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    if (obj:containsKey("actstage")) then
        ret = Net.parserActStage(obj:getObj("actstage"))
    end
    ret.serverTime=gGetCurServerTime()
    gDispatchEvt(EVENT_ID_ATLAS_ACTIVITY_INFO,ret)
end

function Net.sendAtlasActClearCD(type)

    local media=MediaObj:create()
    media:setByte("type",type)
    Net.sendExtensionMessage(media, CMD_ATLAS_ACT_CLEARCD)

end

function Net.recAtlasActClearCd(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}

    Net.updateReward(obj:getObj("reward"));
    if (obj:containsKey("actstage")) then
        local actstageObj = obj:getObj("actstage")
        ret.cd = actstageObj:getInt("cdtime")
    end
    gDispatchEvt(EVENT_ID_ATLAS_ACTIVITY_INFO,ret)
end

----副本信息
function Net.sendGetActAtlasReward()

    local media=MediaObj:create()
    media:setByte("type",Net.sendAtlasEnterParam.type)
    media:setByte("diff",Net.sendAtlasEnterParam.stageid)
    Net.sendExtensionMessage(media, CMD_ATLAS_ACT_DOUBLE_REWARD)
end


function Net.recGetActAtlasReward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local double=obj:getBool("isdouble")
    Net.updateReward(obj:getObj("reward"),0)

    local dnum = obj:getObj("actstage"):getByte("dnum")

    gDispatchEvt(EVENT_ID_ACT_FINAL_DOUBLE, {double, dnum})
end




----爬塔副本信息
function Net.sendPetAtlasInfo()

    local media=MediaObj:create()

    Net.sendExtensionMessage(media, CMD_ATLAS_PET_GETINFO)
end


function Net.recPetAtlasInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret=Net.parsePetStageObj(obj:getObj("stage"))
    -- gDispatchEvt(EVENT_ID_PET_ATLAS_ENTER_INFO,ret)
    if gMainBgLayer == nil then
        Scene.enterMainScene();
    end
    Panel.popUp(PANEL_PET_TOWER,ret);
end


----爬塔副本进入
function Net.sendPetAtlasEnter(mapid)

    local media=MediaObj:create()
    media:setInt("mid", mapid)
    gLogMissionBegin("pet-" .. tostring(mapid) )
    Net.sendAtlasEnterParam={mapid=mapid}
    Net.sendExtensionMessage(media, CMD_ATLAS_PET_ENTER)
end

function Net.sendPetAtlasMonsterSize(enemyFormations,mapid)
    for key, formations in pairs(enemyFormations) do

        local stage= DB.getPetStageDetail(mapid,key)

        for key2, role in pairs(formations) do
            local monsterid=stage["group1_"..(role.pos+1)]
            if(monsterid~=0)then
                local monster= DB.getMonsterById(monsterid)
                if(monster)then
                    role.roleScale=monster.size/100
                end
            end
        end
    end
end

function Net.recPetAtlasEnter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)


    Battle.setDropNum(obj:getInt("item"),table.getn(enemyFormations))
    Net.updateReward(obj:getObj("reward"))
    Battle.battleType=BATTLE_TYPE_ATLAS_PET_TOWER

    local maxRound=DB.getAtlasRound()
    Net.sendPetAtlasMonsterSize(enemyFormations,Net.sendAtlasEnterParam.mapid)

    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,"b006",power)

end



----爬塔副本结算
function Net.sendPetAtlasFight()

    local media=MediaObj:create()

    media:setObjArray("blist",Battle.getLogData())
    media:setShort("mid", Net.sendAtlasEnterParam.mapid)
    Net.sendExtensionMessage(media, CMD_ATLAS_PETT_FIGHT,true)
end




function Net.recPetAtlasFight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    win = obj:getBool("win")
    local td_param = {}
    td_param['round'] = tostring(gTDParam.battle_round)
    if (win == true) then

        gLogMissionCompleted("pet-" .. tostring(Net.sendAtlasEnterParam.mapid))
        gLogEvent("mission-comp-pet-" .. tostring(Net.sendAtlasEnterParam.mapid), td_param)
    else
        gLogMissionFailed("pet-" .. tostring(Net.sendAtlasEnterParam.mapid), "failed")
        gLogEvent("mission-fail-pet-" .. tostring(Net.sendAtlasEnterParam.mapid), td_param)
    end
    Battle.reward={}
    Battle.reward.formation={}
    local rewardObj=obj:getObj("reward")



    if(obj:containsKey("uvobj"))then
        Net.parseUserInfo(obj:getObj("uvobj"))
    end

    Battle.reward.shows= Net.updateReward(rewardObj,0)
    Scene.showLevelUp = false
    Panel.popUp(PANEL_ATLAS_FINAL)
end


----扫荡
function Net.sendPetAtlasSweep()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ATLAS_PET_SWEEP)
end


function Net.recPetAtlasSweep(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret=Net.parsePetStageObj(obj:getObj("stage"))
    gDispatchEvt(EVENT_ID_PET_ATLAS_ENTER_INFO,ret)
end


----扫荡
function Net.sendPetAtlasSweepReward()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ATLAS_PET_GET_REWARD)
end


function Net.recPetAtlasSweepReward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.redpos.swp = false -- 红点消失
    local ret=Net.parsePetStageObj(obj:getObj("stage"))

    Net.updateReward(obj:getObj("reward"),1,true)
end



----扫荡
function Net.sendBuyBossNum(num)

    local media=MediaObj:create()
    media:setInt("num", num)
    Net.sendExtensionMessage(media, "item.devil")
end


function Net.rec_item_devil(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
    Net.parserVipBuy(obj:getObj("vipbn"))
    gDispatchEvt(EVENT_ID_ATLAS_BOSS_BUY_TIME)
end

--购买扫荡次数
function Net.sendBuyPetAtlasSweepTimes(num)
    local media=MediaObj:create()
    media:setInt("num", num)
    Net.sendExtensionMessage(media, "atlas.petbuy");
end

function Net.rec_atlas_petbuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
    local ret=Net.parsePetStageObj(obj:getObj("stage"))
    gDispatchEvt(EVENT_ID_PETTOWER_BUY_SWEEPTIMES,ret.sweepnum);
end

--扫荡立即结束
function Net.sendPetAtlasSweepFinish()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "atlas.petswpfns");
end

function Net.rec_atlas_petswpfns(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),1)
    local ret=Net.parsePetStageObj(obj:getObj("stage"))
    gDispatchEvt(EVENT_ID_PET_ATLAS_ENTER_INFO,ret)
end

--一键试炼
function Net.sendActAtlasSweep(type,stageid)
    local media=MediaObj:create()
    Net.sendAtlasEnterParam={}
    Net.sendAtlasEnterParam.type = type
    Net.sendAtlasEnterParam.stageid = stageid
    media:setByte("type", type)
    Net.sendExtensionMessage(media, "atlas.actsweep");
end

function Net.rec_atlas_actsweep(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local allreward = Net.updateReward(obj:getObj("reward"),0)
    local ret = {}
    if (obj:containsKey("actstage")) then
        local actstage = obj:getObj("actstage")
        actstage=tolua.cast(actstage,"MediaObj")
        ret.dNum=actstage:getByte("dnum")
        ret.batNum=actstage:getByte("num")
        ret.cd=actstage:getInt("cdtime")
        local actsStage = DB.getActStageByType(Net.sendAtlasEnterParam.type)
        Battle.updateActAtlasInfo(Net.sendAtlasEnterParam.type, ret.batNum, ret.cd)
    end

    ret.serverTime=gGetCurServerTime()
    gDispatchEvt(EVENT_ID_ATLAS_ACTIVITY_INFO,ret)

    local result = {}
    result.exp = allreward.exp
    local rewardlist=obj:getArray("rewardlist")
    rewardlist=tolua.cast(rewardlist,"MediaArray")
    local dmg = obj:getInt("dmg");
    if(rewardlist)then
        result.rewardlist={}
        for i=0, rewardlist:count()-1 do
            local listObj=tolua.cast(rewardlist:getObj(i),"MediaObj")
           local reward = Net.updateReward(listObj,0)
           reward.dmg = dmg
           table.insert(result.rewardlist,reward)
        end
        result.dNum = ret.dNum
    end
    gDispatchEvt(EVENT_ID_ACT_SWEEP,result)
end

--副本双倍奖励(一键试炼)
function Net.sendActAtlasActdourewok(type,diff,idx)
    local media=MediaObj:create()
    media:setByte("type", type)
    media:setByte("diff", diff)
    media:setByte("idx", idx)
    Net.sendExtensionMessage(media, "atlas.actdourewok");
end

function Net.rec_atlas_actdourewok(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
  
    local double=obj:getBool("isdouble")
    local dnum=obj:getByte("dnum")
    local idx=obj:getByte("idx")
    gDispatchEvt(EVENT_ID_ACT_FINAL_SWEEP_DOUBLE, {double,dnum,idx})

end

