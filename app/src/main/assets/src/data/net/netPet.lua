
function Net.sendPetUnlock(petid) 
    local media=MediaObj:create() 
    media:setInt("pid",petid)
    PetPanelData.petid = petid;
    Net.sendExtensionMessage(media, CMD_PET_UNLOCK)
end


function Net.recPetUnlock(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
    local soulnum = obj:getInt("soulnum");
    local petSoul = Data.getPetSouls(PetPanelData.petid);
    if(petSoul ~= nil)then
        petSoul.num = petSoul.num - soulnum;
    end
    CardPro.setAllCardAttr() 
    gDispatchEvt(EVENT_ID_PET_UNLOCK)
 
end


function Net.sendPetUpgrade(petid,type)
    if(NetErr.petUpgrade(petid,type)==false)then
        return
    end
    local media=MediaObj:create()
    media:setInt("type",type)
    media:setInt("pid",petid)
    Net.sendExtensionMessage(media, CMD_PET_UPGRADE)
    gLogEvent('pet.upgrade' .. tostring((type)), {petid=tostring(petid)})
end


function Net.recPetUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"))
    local pet=Net.parseUserPet(obj:getObj("pet"))
    Data.updateUserPet(pet)

    CardPro.setAllCardAttr() 

    local datalist = obj:getIntArray("list")
    local ids = {}
    -- print ("parse list:~~~")
    for i=0, datalist:size()-1 do
        -- print ("item" .. i .. ":" .. datalist[i])
        table.insert(ids, datalist[i])
    end
    gDispatchEvt(EVENT_ID_PET_UPGRADE,ids)

end



function Net.sendPetEvolve(petid)
    local media=MediaObj:create() 
    media:setInt("pid",petid)  
    Net.sendExtensionMessage(media, CMD_PET_EVOLVE)
end


function Net.recPetEvolve(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local pid=obj:getInt("pid")
    local petSoul=Data.getPetSouls(pid)
    petSoul.num=petSoul.num-obj:getShort("num")
    
    local pet=Net.parseUserPet(obj:getObj("pet"))
    Data.updateUserPet(pet)

    -- local pet=Data.getUserPetById(pid)
    -- pet.grade=pet.grade+1
    CardPro.setAllCardAttr() 
    gDispatchEvt(EVENT_ID_PET_EVOLVE)

end



function Net.sendPetUpgradeSkill(petid,idx)
    local media=MediaObj:create() 
    media:setInt("pid",petid)  
    media:setInt("pos",idx-1)  
    Net.sendPetUpgradeSkillParam=idx-1
    Net.sendExtensionMessage(media, CMD_PET_UPGRADE_SKILL)
end


function Net.recPetUpgradeSkill(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"))
    local pet=Net.parseUserPet(obj:getObj("pet"))

    Data.updateUserPet(pet) 
    CardPro.setAllCardAttr() 
    CardPro.showPetLevelUpDesc(pet ,Net.sendPetUpgradeSkillParam,pet["skillLevel"..(Net.sendPetUpgradeSkillParam+1)])
    gDispatchEvt(EVENT_ID_PET_REFRESH_DATA)
end

-- 宠物觉醒
CMD_PET_WAKEUP = "pet.wakeup"
function Net.sendPetWakeUp(petid)
    local media=MediaObj:create() 
    media:setInt("pid",petid)  
    Net.sendExtensionMessage(media, CMD_PET_WAKEUP)
end

function Net.rec_pet_wakeup(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local pet=Net.parseUserPet(obj:getObj("pet"))
    Data.updateUserPet(pet)
    Net.updateReward(obj:getObj("reward"), 0)
    CardPro.setAllCardAttr()
    gDispatchEvt(EVENT_ID_PET_WAKEUP)
end

--特殊天赋技能经验转换
function Net.sendPetStaddexp(petid,id,num)
    local media=MediaObj:create() 
    media:setInt("pid",petid)  
    media:setInt("id",id)  
    media:setInt("num",num)  
    Net.sendExtensionMessage(media, "pet.staddexp")
end

function Net.rec_pet_staddexp(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"), 0)
    local stexp = obj:getInt("stexp")
    local pid = obj:getInt("pid")
    local petinfo =Data.getUserPetById(pid)
    petinfo.stexp=stexp
    gDispatchEvt(EVENT_ID_PET_REFRESH_TALENT)
end

--特殊天赋技能领悟
function Net.sendPetStlearn(petid,shard)
    local media=MediaObj:create() 
    media:setInt("pid",petid)
    media:setBool("shard",shard)
    Net.sendExtensionMessage(media, "pet.stlearn")
end

function Net.rec_pet_stlearn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local pid = obj:getInt("pid")
    local pos = obj:getByte("pos")
    local psid  = obj:getInt("psid")
    gUserInfo.stexp  = obj:getInt("stexp")
    local petinfo =Data.getUserPetById(pid)
    petinfo["stid"..pos]=psid
    if obj:containsKey("reward") then
        Net.updateReward(obj:getObj("reward"), 0)
    end
    if petinfo.cid and petinfo.cid>0 then
        local card=Data.getUserCardById(petinfo.cid)
        CardPro.setCardAttr(card)
    end
    gDispatchEvt(EVENT_ID_PET_LEAR_TALENT,{pos=pos})
end

--特殊天赋技能锁定
function Net.sendPetStlock(petid,poss,locks)
    local media=MediaObj:create() 
    local locksArray = vector_int_:new_local()
    local posArray = vector_int_:new_local()
    for k,status in pairs(locks) do
        locksArray:push_back(status)
    end
    for k,pos in pairs(poss) do
        posArray:push_back(pos)
    end

    media:setInt("pid",petid)
    media:setIntArray("pos",posArray)
    media:setIntArray("lock",locksArray)

    Net.sendExtensionMessage(media, "pet.stlock")
end

function Net.rec_pet_stlock(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local pid = obj:getInt("pid")
    local petdata = Data.getUserPetById(pid)
    local posArray = obj:getIntArray("pos")
    local locksArray = obj:getIntArray("lock")
    for i=0, posArray:size()-1 do
        petdata.stlocks[posArray[i]]=locksArray[i]
    end
    gDispatchEvt(EVENT_ID_PET_REFRESH_TALENT)
end

--特殊天赋替换列表
function Net.sendPetStrelist(pid,pos) --1-8
    local media=MediaObj:create() 
    media:setInt("pid",pid)
    media:setByte("pos",pos)
    Net.sendExtensionMessage(media, "pet.strelist")
end

function Net.rec_pet_strelist(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local strelist = {}
    local pid = obj:getInt("pid")
    local pos = obj:getByte("pos")
    local relist = obj:getIntArray("relist")
    for i=0, relist:size()-1 do
        table.insert(strelist,relist[i])
    end
    gDispatchEvt(EVENT_ID_PET_REP_LIST,strelist)
end

--特殊天赋替换
function Net.sendPetStre(pid,pos,rstid) --1-8
    local media=MediaObj:create() 
    media:setInt("pid",pid)
    media:setByte("pos",pos)
    media:setInt("rstid",rstid)
    Net.sendExtensionMessage(media, "pet.stre")
end

function Net.rec_pet_stre(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local pid = obj:getInt("pid")
    local pet=Net.parseUserPet(obj:getObj("pet"))
    Data.updateUserPet(pet)
    Net.updateReward(obj:getObj("reward"), 0)
    gDispatchEvt(EVENT_ID_PET_REPLACE)
end


--灵兽附身
function Net.sendPetPossess(petid,cid)
    local media=MediaObj:create() 
    media:setInt("pid",petid)
    media:setInt("cid",cid)
    Net.sendExtensionMessage(media, "pet.possess")
end

function Net.rec_pet_possess(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local psid  = obj:getInt("pid")
    local cid  = obj:getInt("cid")
    Data.updateUserPetCard(psid,cid)
    local cardinfo=Data.getUserCardById(cid)
    cardinfo.pid=psid

    local card=Data.getUserCardById(cid)
    CardPro.setCardAttr(card)
    gDispatchEvt(EVENT_ID_PET_FOR_CARD)
end


--卸下灵兽附身
function Net.sendPetPossunload(cid)
    local media=MediaObj:create() 
    media:setInt("cid",cid)
    Net.sendExtensionMessage(media, "pet.possunload")
end

function Net.rec_pet_possunload(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local psid  = obj:getInt("pid")
    local cid  = obj:getInt("cid")
    local petInfo = Data.getUserPetById(psid)
    petInfo.cid=0
    local cardinfo=Data.getUserCardById(cid)
    cardinfo.pid=0
    local card=Data.getUserCardById(cid)
    CardPro.setCardAttr(card)
    gDispatchEvt(EVENT_ID_PET_FOR_CARD)
end


--灵兽窟探险界面信息
function Net.sendCaveInfo()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "cave.info")
end

function Net.rec_cave_info(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.CaveInfo.enum=obj:getInt("enum")
    Data.CaveInfo.coinreset=obj:getInt("coinreset")
    if Data.CaveInfo.eventList == nil then
        Data.CaveInfo.eventList = {}
    end
    local events = obj:getArray("events")
     events=tolua.cast(events,"MediaArray")
    if(events)then
         for i=0, events:count()-1 do
            local eventObj=tolua.cast(events:getObj(i),"MediaObj")
            local longId=eventObj:getLong("id")
            if longId>0  then
                if  Data.CaveInfo.eventList[longId] ==nil then
                    Data.CaveInfo.eventList[longId] ={}
                end
                Data.CaveInfo.eventList[longId].id=longId
                Data.CaveInfo.eventList[longId].etype=eventObj:getByte("etype")
                Data.CaveInfo.eventList[longId].endtime=eventObj:getInt("endtime")
            end
        end
    end

    Data.CaveInfo.chessinfo = {}
    local datalist = obj:getIntArray("chessinfo")
    for i=0, datalist:size()-1 do
        table.insert(Data.CaveInfo.chessinfo, datalist[i])
    end

    Data.CaveInfo.buffers = {}
    local buffers = obj:getArray("buffers")
     buffers=tolua.cast(buffers,"MediaArray")
    if(buffers)then
         for i=0, buffers:count()-1 do
            local buffObj=tolua.cast(buffers:getObj(i),"MediaObj")
            local bufferid=buffObj:getInt("bufferid")
            if bufferid>0  then
                Data.CaveInfo.buffers[bufferid]=buffObj:getByte("num")
            end
        end
    end
    Data.CaveInfo.box1=obj:getBool("box1")
    Data.CaveInfo.box2=obj:getBool("box2")
    Data.CaveInfo.box3=obj:getBool("box3")
    gDispatchEvt(EVENT_ID_PET_EXPLORE_INFO)
end

--探险
function Net.sendCaveExplore()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "cave.explore")
end

function Net.rec_cave_explore(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_PET_EXPLORE_ERROR)
        return
    end
    Data.CaveInfo.enum=obj:getInt("enum")
    if Data.CaveInfo.eventList==nil then
        Data.CaveInfo.eventList = {}
    end

    
    local eventinfo=tolua.cast(obj:getObj("eventinfo"),"MediaObj")
    local longId=eventinfo:getLong("id")
    if longId>0  then
        if Data.CaveInfo.eventList[longId] ==nil then
            Data.CaveInfo.eventList[longId] ={}
        end
        Data.CaveInfo.eventList[longId].id=longId
        Data.CaveInfo.eventList[longId].etype=eventinfo:getByte("etype")
        Data.CaveInfo.eventList[longId].endtime=eventinfo:getInt("endtime")
    end

    Data.CaveInfo.buffers = {}
    local buffers = obj:getArray("buffers")
     buffers=tolua.cast(buffers,"MediaArray")
    if(buffers)then
         for i=0, buffers:count()-1 do
            local buffObj=tolua.cast(buffers:getObj(i),"MediaObj")
            local bufferid=buffObj:getInt("bufferid")
            if bufferid>0  then
                Data.CaveInfo.buffers[bufferid]=buffObj:getByte("num")
            end
        end
    end

    local pos = obj:getByte("pos")
    local coin = obj:getByte("coin")
    local baoji = obj:getInt("baoji")
    if Data.CaveInfo.chessinfo[pos]==nil then
        Data.CaveInfo.chessinfo[pos] =0
    end
    Data.CaveInfo.chessinfo[pos] =coin

    if baoji>1 then
        AttChange.pushAttBaoji(PANNEL_PET_EXPLORE,0,"",baoji);
    end
    local ret = Net.updateReward(obj:getObj("reward"), 0)
    gDispatchEvt(EVENT_ID_PET_EXPLORE, {pos=pos,etype=coin,items=ret.items})
end


--事件列表
function Net.sendCaveEvenList()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "cave.elist")
end

function Net.rec_cave_elist(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.CaveInfo.eventList = {}
    local events = obj:getArray("events")
     events=tolua.cast(events,"MediaArray")
    if(events)then
         for i=0, events:count()-1 do
            local eventObj=tolua.cast(events:getObj(i),"MediaObj")
            local longId=eventObj:getLong("id")
            if longId>0  then
                if  Data.CaveInfo.eventList[longId] ==nil then
                    Data.CaveInfo.eventList[longId] ={}
                end
                Data.CaveInfo.eventList[longId].id=longId
                Data.CaveInfo.eventList[longId].etype=eventObj:getByte("etype")
                Data.CaveInfo.eventList[longId].endtime=eventObj:getInt("endtime")
            end
        end
    end
    if table.count(Data.CaveInfo.eventList) >0 then
        Panel.popUpVisible(PANNEL_PET_EXPLORE_HD)
    else
        gShowNotice(gGetWords("petWords.plist","no_pet_explore_event"));
    end
end


--宝箱领奖
function Net.sendCaveBoxReward(index)
    local media=MediaObj:create() 
    media:setByte("index",index)
    Net.sendExtensionMessage(media, "cave.boxreward")
end

function Net.rec_cave_boxreward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local index=obj:getByte("index")
    Data.CaveInfo["box"..index] = true
    local ifrest=obj:getBool("ifreset")
    if ifrest==true then
        Data.CaveInfo.chessinfo={}
        for i=1,3 do
            Data.CaveInfo["box"..i] = false
        end
    end
    Net.updateReward(obj:getObj("reward"),2)

    gDispatchEvt(EVENT_ID_CAVE_BOX_REWARD)
end

--翻牌事件详细
function Net.sendCaveEvent1Info(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event1info")
end

function Net.rec_cave_event1info(evt)
    local obj = evt.params:getObj("params")
    if(not (obj:getByte("ret")==0 or obj:getByte("ret")==10))then
        return
    end
    local longId = obj:getLong("dbid")
    if longId>0 then
            local endtime = obj:getInt("endtime")
        if Data.CaveInfo.eventList[longId] ==nil then
            Data.CaveInfo.eventList[longId] ={}
        end
        Data.CaveInfo.eventList[longId].endtime=endtime
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT1_INFO)
end

--翻牌事件处理
function Net.sendCaveEvent1Deal(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event1deal")
end

function Net.rec_cave_event1deal(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        local win = obj:getBool("win")--是否翻对了
        Net.updateReward(obj:getObj("reward"), 2)
        Data.CaveInfo.eventList[dbid].status=false
        Data.CaveInfo.eventList[dbid].win=win
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT1_DEAL)
end


--哥布林商人事件详细
function Net.sendCaveEvent2Info(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event2info")
end

function Net.rec_cave_event2info(evt)
    local obj = evt.params:getObj("params")
    if(not (obj:getByte("ret")==0 or obj:getByte("ret")==10))then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        local endtime = obj:getInt("endtime")
        if Data.CaveInfo.eventList[dbid] ==nil then
            Data.CaveInfo.eventList[dbid] ={}
        end
        Data.CaveInfo.eventList[dbid].endtime=endtime
        local itemid = obj:getInt("itemid")
        local itemnum = obj:getInt("itemnum")
        local oldprice = obj:getInt("oldprice")
        local nowprice = obj:getInt("nowprice")
        Data.CaveInfo.eventList[dbid].itemid=itemid
        Data.CaveInfo.eventList[dbid].itemnum=itemnum
        Data.CaveInfo.eventList[dbid].oldprice=oldprice
        Data.CaveInfo.eventList[dbid].nowprice=nowprice
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT2_INFO)
end

--哥布林商人事件购买
function Net.sendCaveEvent2Deal(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event2deal")
end

function Net.rec_cave_event2deal(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        Net.updateReward(obj:getObj("reward"), 2)
        Data.CaveInfo.eventList[dbid].status=false
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT2_DEAL)
end


--远古兽骸事件详细
function Net.sendCaveEvent3Info(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event3info")
end

function Net.rec_cave_event3info(evt)
    local obj = evt.params:getObj("params")
    if(not (obj:getByte("ret")==0 or obj:getByte("ret")==10))then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        local endtime = obj:getInt("endtime")
        if Data.CaveInfo.eventList[dbid] ==nil then
            Data.CaveInfo.eventList[dbid] ={}
        end
        local gettime = obj:getInt("gettime")
        Data.CaveInfo.eventList[dbid].endtime=endtime
        Data.CaveInfo.eventList[dbid].gettime=gettime 
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT3_INFO)
end

--远古兽骸事件领取
function Net.sendCaveEvent3Deal(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event3deal")
end

function Net.rec_cave_event3deal(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        Net.updateReward(obj:getObj("reward"), 2)
        Data.CaveInfo.eventList[dbid].status=false
    end

    gDispatchEvt(EVENT_ID_CAVE_EVENT3_DEAL)
end

--神奇宝箱事件详细
function Net.sendCaveEvent4Info(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event4info")
end

function Net.rec_cave_event4info(evt)
    local obj = evt.params:getObj("params")
    if(not (obj:getByte("ret")==0 or obj:getByte("ret")==10))then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        local endtime = obj:getInt("endtime")
        if Data.CaveInfo.eventList[dbid] ==nil then
            Data.CaveInfo.eventList[dbid] ={}
        end
        Data.CaveInfo.eventList[dbid].endtime=endtime

        local caveBoxid = obj:getInt("boxid")
        local opennum = obj:getInt("opennum")
        Data.CaveInfo.eventList[dbid].opennum=opennum
        Data.CaveInfo.eventList[dbid].caveBoxid=caveBoxid
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT4_INFO)
end

--神奇宝箱事件领取
function Net.sendCaveEvent4Deal(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event4deal")
end

function Net.rec_cave_event4deal(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        if Data.CaveInfo.eventList[dbid] ==nil then
            Data.CaveInfo.eventList[dbid] ={}
        end
        Net.updateReward(obj:getObj("reward"), 2)
        local opennum = obj:getInt("opennum")
        Data.CaveInfo.eventList[dbid].status=table.count(Data.petCave.eventDiamond)>opennum
        Data.CaveInfo.eventList[dbid].opennum=opennum
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT4_DEAL)
end

--挑战守卫事件详细
function Net.sendCaveEvent5Info(dbid)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    Net.sendExtensionMessage(media, "cave.event5info")
end

function Net.rec_cave_event5info(evt)
    local obj = evt.params:getObj("params")
    if(not (obj:getByte("ret")==0 or obj:getByte("ret")==10))then
        return
    end
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        local endtime = obj:getInt("endtime")
        if Data.CaveInfo.eventList[dbid] ==nil then
            Data.CaveInfo.eventList[dbid] ={}
        end
        local curpower = obj:getInt("curpower")
        Data.CaveInfo.eventList[dbid].endtime=endtime
        Data.CaveInfo.eventList[dbid].curpower=curpower
    end
    gDispatchEvt(EVENT_ID_CAVE_EVENT5_INFO)
end

--挑战守卫事件战斗
function Net.sendCaveEvent5fight(dbid,index)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    media:setByte("index",index)
    Net.sendExtensionMessage(media, "cave.event5fight")
end

function Net.rec_cave_event5fight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local attacknum = obj:getLong("attacknum")
    local dbid = obj:getLong("dbid")
    if dbid>0 then
        local data = obj:getObj("bat")
        if Data.CaveInfo.eventList[dbid] ==nil then
            Data.CaveInfo.eventList[dbid] ={}
        end
        Data.CaveInfo.eventList[dbid].endtime=0
        Data.CaveInfo.eventList[dbid].status=false
        local byteArr= data:getByteArray("info")
        gParserGameVideo(byteArr,BATTLE_TYPE_CAVE_CHALLENGE)
        Battle.reward.shows= Net.updateReward(obj:getObj("reward"),0)
    end
end

--挑战守卫事件进入
function Net.sendCaveEvent5enter(dbid,index)
    local media=MediaObj:create() 
    media:setLong("dbid",dbid)
    media:setByte("index",index)
    Net.sendExtensionMessage(media, "cave.event5enter")
end

function Net.rec_cave_event5enter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
end


--重置探险币
function Net.sendCaveReset(pos,dia)
    if not NetErr.isDiamondEnough(dia) then
       return
    end
    local media=MediaObj:create() 
    media:setByte("pos",pos)
    Net.sendExtensionMessage(media, "cave.coinreset")
end

function Net.rec_cave_coinreset(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local pos = obj:getByte("pos")
    local coin = obj:getByte("coin")
    local coinreset = obj:getInt("coinreset")
    Data.CaveInfo.coinreset=coinreset
    if Data.CaveInfo.chessinfo[pos]==nil then
        Data.CaveInfo.chessinfo[pos] =0
    end
    Data.CaveInfo.chessinfo[pos] =coin
    if obj:containsKey("reward") then
        Net.updateReward(obj:getObj("reward"), 0)
    end
    gDispatchEvt(EVENT_ID_CAVE_REPLACE_COIN,{coinreset=coinreset,pos=pos,coin=coin})
end

