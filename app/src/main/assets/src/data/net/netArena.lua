
----竞技场初始化
function Net.sendArena()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ARENA_INFO)
end


function Net.recArena(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    ret.rank=obj:getInt("rank")
    ret.count=obj:getInt("num")--剩余挑战次数
    Data.setUsedTimes(VIP_ARENA,obj:getInt("bnum"));
    ret.time=obj:getInt("time") 
    ret.serverTime=gGetCurServerTime()
    print(ret.time)
    ret.highrank=obj:getInt("highrank")
    ret.enemys={}
    local enemyList=obj:getArray("list")
    if(enemyList)then
        enemyList=tolua.cast(enemyList,"MediaArray")
        for i=0, enemyList:count()-1 do
            table.insert(ret.enemys,Net.parseArenaEnemy(enemyList:getObj(i)))
        end
    end
    gArena=ret
    gDispatchEvt(EVENT_ID_ARENA,ret)

end



----竞技场挑战
function Net.sendArenaChallenge(rank,id,rid)
    if(NetErr.arenaFight()==false)then
        return
    end 

    local media=MediaObj:create()
    media:setLong("id",id)
    media:setLong("rid",rid)
    media:setInt("rank",rank)
    Net.sendExtensionMessage(media, CMD_ARENA_CHALLENGE)
    if (TalkingDataGA) then
        gLogEvent("arena.challenge")
    end
end


function Net.recArenaChallenge(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if(ret~=0)then
        if ret == 12 then
            Panel.popBackAll();
            gEnterArena();
        end
        return
    end

    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    Battle.brief = {}
    Battle.brief.vid= obj:getLong("videoid")
    Battle.brief.n1 = data:getString("n1")
    Battle.brief.n2 = data:getString("n2")
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA)
    Battle.reward.shows= Net.updateReward(obj:getObj("reward"),0)
end


----竞技场记录
function Net.sendArenaRecord()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ARENA_RECORD)
end


function Net.recArenaRecord(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.records={}
    local recordList=obj:getArray("info")
    if(recordList)then
        recordList=tolua.cast(recordList,"MediaArray")
        for i=1, recordList:count() do
            table.insert(ret.records,i,Net.parseArenaRecord(recordList:getObj(i-1)))
        end
    end

    Panel.popUp(PANEL_ARENA_RECORD,ARENA_RECORD_TYPE,ret)
    
    -- gDispatchEvt(EVENT_ID_ARENA_RECORD,ret)
end


----观看战斗录像
function Net.sendGetBattle(id)

    local media=MediaObj:create()
    media:setInt("id",id)
    Net.sendExtensionMessage(media, CMD_TEST_GETBATTLEVEDIO)
end


function Net.recGetBattle(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local data = obj:getObj("bat") 
    Battle.testvedio = {} 
    Battle.testvedio.n1 = data:getString("n1")
    Battle.testvedio.n2 = data:getString("n2")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_TEST)
end
----竞技场视频
function Net.sendArenaVideo(vid,id)

    local media=MediaObj:create()
    media:setLong("vid",vid) 
    Net.sendExtensionMessage(media, CMD_ARENA_VEDIO)
end


function Net.recArenaVideo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local data = obj:getObj("bat") 
    Battle.brief = {} 
    Battle.brief.n1 = data:getString("n1")
    Battle.brief.n2 = data:getString("n2")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA_LOG)
end

----竞技场卡牌信息
function Net.sendArenaCardInfo(data)

    local media=MediaObj:create()
    ArenaPanelData.sendUID = data.id;
    media:setLong("id",data.id)
    media:setInt("rk",data.rank)
    Net.sendExtensionMessage(media, CMD_ARENA_CARD_INFO,true)
end


function Net.recArenaCardInfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if(ret~=0)then
        if ret == 12 then
            Panel.popBackAll();
            gEnterArena();
        end
        return
    end

    local ret = Net.parseFormationObj(obj);
    ret.uid = ArenaPanelData.sendUID;
    Panel.popUpVisible(PANEL_FORMATION,ret)
    -- ret={}
    -- ret.name=obj:getString("name")
    -- ret.rank=obj:getInt("rank")
    -- ret.price=obj:getInt("price")
    -- ret.level=obj:getInt("level")
    -- ret.cid=obj:getInt("cid")

    -- ret.cards={}
    -- local cardList=obj:getArray("card")
    -- if(cardList)then
    --     cardList=tolua.cast(cardList,"MediaArray")
    --     for i=0, cardList:count()-1 do
    --         table.insert(ret.cards,i,Net.parseArenaCard(cardList:getObj(i)))
    --     end
    -- end
end




----清理cd
function Net.sendArenaClearCd()
    if(NetErr.arenaClearCd()==false)then
        return
    end 
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, CMD_ARENA_CLEAR_CD)
end


function Net.recArenaClearCd(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end 

    Net.updateReward(obj:getObj("reward"))
    gArena.time=0
    gDispatchEvt(EVENT_ID_ARENA_RESET_CD)
 
end



----购买次数
function Net.sendArenaBuyNum(num)
    if(NetErr.arenaBuyNum()==false)then
        return
    end 
    local media=MediaObj:create() 
    media:setInt("num",num);
    Net.sendExtensionMessage(media, CMD_ARENA_BUY_NUM)
end


function Net.recArenaBuyNum(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end 
    Net.updateReward(obj:getObj("reward"))
    local num=obj:getInt("num")
    Data.setUsedTimes(VIP_ARENA,obj:getInt("bnum"));
    gArena.count=num 
    gDispatchEvt(EVENT_ID_ARENA_BUY_NUM,num)
end


