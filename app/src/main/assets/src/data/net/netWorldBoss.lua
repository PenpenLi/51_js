
function Net.updateWorldBoss(obj)
    Data.worldBossInfo.bossid = obj:getInt("bossid")
    Data.worldBossInfo.status = obj:getByte("status")
    Data.worldBossInfo.starttime = obj:getInt("time")
end

function Net.sendWorldBossInfo(bolRefresh)
    Data.worldBossInfo.bolRefresh = bolRefresh
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wboss.info")
end

function Net.returnWorldList(obj)
    local alist = {}
    local bollist = false
    local list = obj:getArray("list")
    if(list) then
        bollist = true
        list=tolua.cast(list,"MediaArray")
        for i=1, list:count() do
            local obj1=tolua.cast(list:getObj(i-1),"MediaObj")
            local info = {};
            info.rank = obj1:getInt("rank")
            info.userid = obj1:getLong("userid");
            info.name = obj1:getString("name")
            info.icon = obj1:getInt("icon")
            info.damage = obj1:getInt("damage")
            table.insert(alist,info)
        end
    end
    return alist,bollist
end

function Net.returnWorldOldList(obj)
    local alist = {}
    local list = obj:getArray("oldlist")
    if(list) then
        list=tolua.cast(list,"MediaArray")
        for i=1, list:count() do
            local obj1=tolua.cast(list:getObj(i-1),"MediaObj")
            local info = {};
            info.rank = obj1:getInt("rank")--排名(名次为0的,为最后击杀玩家信息)
            info.userid = obj1:getLong("userid");
            info.icon = obj1:getInt("icon")
            info.name = obj1:getString("name")
            info.damage = obj1:getInt("damage")
            info.show = Net.parserShowInfo(obj1:getObj("show"))
            table.insert(alist,info)
        end
    end
    return alist
end

function Net.rec_wboss_info(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- local ret = {}
    Data.worldBossInfo.bosstype = obj:getByte("bosstype") -- 0:旧boss 1:新boss
    Data.worldBossInfo.bossid = obj:getInt("bossid")
    Data.worldBossInfo.bosslv = obj:getInt("bosslv")
    Data.worldBossInfo.status = obj:getByte("status")
    Data.worldBossInfo.starttime = obj:getInt("starttime")
    Data.worldBossInfo.powernum = obj:getInt("powernum")
    Data.worldBossInfo.bnum = obj:getInt("bnum")
    Data.worldBossInfo.allmoney = obj:getInt("allmoney")
    Data.worldBossInfo.buynum = obj:getInt("buynum") -- 当日购买挑战次数
    
    if (Data.worldBossInfo.status==1) then
        Data.worldBossInfo.endtime = obj:getInt("endtime")
        Data.worldBossInfo.ifkill = obj:getBool("ifkill")
        if (Data.worldBossInfo.ifkill) then
           Data.worldBossInfo.status = 2
        end
        Data.worldBossInfo.hp = obj:getInt("hp")
        Data.worldBossInfo.hpmax = obj:getInt("hpmax")
        Data.worldBossInfo.attacknum = obj:getInt("attacknum")
        Data.worldBossInfo.damage = obj:getInt("damage")
        Data.worldBossInfo.rank = obj:getInt("rank")
        Data.worldBossInfo.fighttime = obj:getInt("fighttime")
        
        local list,bollist = Net.returnWorldList(obj)
        if (bollist) then
            Data.worldBossInfo.list = list
        end
    end

    if (Data.worldBossInfo.bolRefresh == 1) then 
        gDispatchEvt(EVENT_ID_WORLD_BOSS_INFO_REF); 
    elseif (Data.worldBossInfo.bolRefresh == 2) then
        gDispatchEvt(EVENT_ID_WORLD_BOSS_INFO_REF2);
    elseif (Data.worldBossInfo.bolRefresh == 3) then
        Data.worldBossInfo.oldlist = Net.returnWorldOldList(obj)
        gDispatchEvt(EVENT_ID_WORLD_BOSS_INFO_REF2);
        -- print_lua_table(Data.worldBossInfo.oldlist)
    else
        Data.worldBossInfo.logCurTime = nil
        Data.worldBossInfo.logNextLeftTime = nil
        Data.worldBossInfo.fnum = obj:getInt("fnum") -- 我的挑战次数
        Data.worldBossInfo.oldlist = Net.returnWorldOldList(obj)
        gDispatchEvt(EVENT_ID_WORLD_BOSS_INFO);
    end
    Data.worldBossInfo.iEndNotice = 0

    -- print_lua_table(Data.worldBossInfo)
end

function Net.sendWorldBossReborn()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wboss.reborn")
end

function Net.rec_wboss_reborn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"))
    Data.worldBossInfo.endtime = obj:getInt("endtime")
    Data.worldBossInfo.ifkill = obj:getBool("ifkill")
    if (Data.worldBossInfo.ifkill) then
        -- Data.worldBossInfo.status = 2
    end
    Data.worldBossInfo.hp = obj:getInt("hp")
    Data.worldBossInfo.hpmax = obj:getInt("hpmax")
    Data.worldBossInfo.rank = obj:getInt("rank")
    Data.worldBossInfo.fighttime = obj:getInt("fighttime")
    Data.worldBossInfo.bnum = obj:getInt("bnum")
    local list,bollist = Net.returnWorldList(obj)
    if (bollist) then
        Data.worldBossInfo.list = list
    end
    -- print_lua_table(Data.worldBossInfo)
    -- Data.worldBossInfo.list =Net.returnWorldList(obj)
    gDispatchEvt(EVENT_ID_WORLD_BOSS_REBORN);
end

function Net.sendWorldBossPlus(type)
    local media=MediaObj:create()
    media:setByte("type", type)
    Net.sendExtensionMessage(media, "wboss.plus")
end

function Net.rec_wboss_plus(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"))
    Data.worldBossInfo.endtime = obj:getInt("endtime")
    Data.worldBossInfo.ifkill = obj:getBool("ifkill")
    if (Data.worldBossInfo.ifkill) then
        -- Data.worldBossInfo.status = 2
    end
    Data.worldBossInfo.hp = obj:getInt("hp")
    Data.worldBossInfo.hpmax = obj:getInt("hpmax")
    Data.worldBossInfo.rank = obj:getInt("rank")
    Data.worldBossInfo.fighttime = obj:getInt("fighttime")
    Data.worldBossInfo.powernum = obj:getInt("powernum")
    local list,bollist = Net.returnWorldList(obj)
    if (bollist) then
        Data.worldBossInfo.list = list
    end
    -- Data.worldBossInfo.list =Net.returnWorldList(obj)

    gDispatchEvt(EVENT_ID_WORLD_BOSS_PLUS);
end


function Net.sendWorldBossFight()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wboss.fight")
    gLogEvent("wboss.fight")
end

function Net.rec_wboss_fight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local items = Net.updateReward(obj:getObj("reward"), 0)
    if (items) then
        -- print("items")
        -- print_lua_table(items)
        Data.worldBossInfo.goldReword = items.gold
        -- print("gold===="..Data.worldBossInfo.goldReword)
    end

    Data.worldBossInfo.mykill = false
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_WORLD_BOSS)

    Data.worldBossInfo.mydamage = obj:getInt("mydamage")
    Data.worldBossInfo.allmoney = obj:getInt("allmoney")
    -- Data.worldBossInfo.endtime = obj:getInt("endtime")
    Data.worldBossInfo.damage = obj:getInt("damage")
    Data.worldBossInfo.attacknum = obj:getInt("attacknum")
    Data.worldBossInfo.ifkill = obj:getBool("ifkill")
    Data.worldBossInfo.bnum = obj:getInt("bnum")
    if (Data.worldBossInfo.ifkill) then
        -- Data.worldBossInfo.status = 2
    end
    Data.worldBossInfo.hp = obj:getInt("hp")
    Data.worldBossInfo.hpmax = obj:getInt("hpmax")
    Data.worldBossInfo.rank = obj:getInt("rank")
    Data.worldBossInfo.fighttime = obj:getInt("fighttime")
    local list,bollist = Net.returnWorldList(obj)
    if (bollist) then
        Data.worldBossInfo.list = list
    end

    if(obj:containsKey("oldlist"))then
        Data.worldBossInfo.mykill = true
    end
    if(obj:containsKey("bosslv"))then
        Data.worldBossInfo.bosslv = obj:getInt("bosslv")
    end

    if(obj:containsKey("status"))then
        Data.worldBossInfo.status = obj:getByte("status")
        if Data.worldBossInfo.status == 0 then
            Data.worldBossInfo.fighttime = nil
        end
    end
    -- Data.worldBossInfo.list =Net.returnWorldList(obj)

    -- print_lua_table(Data.worldBossInfo)

    --Data.worldBossInfo.fnum = obj:getInt("fnum") -- 我的挑战次数
    if(Data.worldBossInfo.bosstype == 1)then
        Data.worldBossInfo.fnum = Data.worldBossInfo.fnum - 1
    end

    Data.worldBossInfo.lkreward = nil
    if(obj:containsKey("lkreward"))then
        Data.worldBossInfo.lkreward = Net.updateReward(obj:getObj("lkreward"), 0)
    end
    gDispatchEvt(EVENT_ID_WORLD_BOSS_FIGHT);
end

function Net.sendWorldBossEnter()
    local media=MediaObj:create()
    Net.sendAtlasEnterParam = {}
    Net.sendExtensionMessage(media, "wboss.enter")
end

function Net.rec_wboss_enter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)
    -- Battle.setDropNum(obj:getInt("item"),table.getn(enemyFormations))
    Battle.battleType=BATTLE_TYPE_WORLD_BOSS
    local maxRound=DB.getAtlasRound()
    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,"b008",power)
    -- gDispatchEvt(EVENT_ID_WORLD_BOSS_ENTER);

end

function Net.sendWorldBossRefresh()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wboss.refresh")
end

function Net.rec_wboss_refresh(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.worldBossInfo.ifkill = obj:getBool("ifkill")
    if (Data.worldBossInfo.ifkill) then
        -- Data.worldBossInfo.status = 2
        -- return;
    end
    Data.worldBossInfo.hp = obj:getInt("hp")
    Data.worldBossInfo.hpmax = obj:getInt("hpmax")
    Data.worldBossInfo.rank = obj:getInt("rank")
    -- print("Data.worldBossInfo.hp="..Data.worldBossInfo.hp)
    local list,bollist = Net.returnWorldList(obj)
    if (bollist) then
        Data.worldBossInfo.list = list
    end

    if(obj:containsKey("bosslv"))then
        Data.worldBossInfo.bosslv = obj:getInt("bosslv")
    end
    
    gDispatchEvt(EVENT_ID_WORLD_BOSS_REFRESH);
end

function Net.recWorldBossEnd(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.worldBossInfo.status = 0
    if(obj:containsKey("kname"))then
        Data.worldBossInfo.kname = obj:getString("kname")
        Data.worldBossInfo.iEndNotice = 1
        Data.worldBossInfo.ifkill = true
        Data.worldBossInfo.hp = 0
        gDispatchEvt(EVENT_ID_WORLD_BOSS_END);
    else -- 时间到了
        Data.worldBossInfo.iEndNotice = 3
    end

    if obj:containsKey("bossid") then
        Data.worldBossInfo.bossid = obj:getInt("bossid")
    end
end

-- 扫荡
function Net.sendWorldBossSweep()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wboss.sweep")
end

function Net.rec_wboss_sweep(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local items = Net.updateReward(obj:getObj("reward"), 0)
    if (items) then
        -- print("items")
        -- print_lua_table(items)
        Data.worldBossInfo.goldReword = items.gold
        -- print("gold===="..Data.worldBossInfo.goldReword)
    end

    --Data.worldBossInfo.mykill = false

    Data.worldBossInfo.mydamage = obj:getInt("mydamage") -- 本次我的伤害数
    Data.worldBossInfo.attacknum = obj:getInt("attacknum") -- 我的攻击次数
    --Data.worldBossInfo.fnum = obj:getInt("fnum") -- 我的挑战次数
    Data.worldBossInfo.fnum = Data.worldBossInfo.fnum - 1
    Data.worldBossInfo.damage = obj:getInt("damage") -- 我的伤害总数
    Data.worldBossInfo.bosslv = obj:getInt("bosslv") -- boss等级
    Data.worldBossInfo.hp = obj:getInt("hp") -- boss当前血量
    Data.worldBossInfo.hpmax = obj:getInt("hpmax") -- boss最大血量
    Data.worldBossInfo.rank = obj:getInt("rank") -- 我的当前排名(0表示没有)
    Data.worldBossInfo.allmoney = obj:getInt("allmoney")

    --[[if(obj:containsKey("oldlist"))then
        Data.worldBossInfo.mykill = true
    end]]
    if(obj:containsKey("bosslv"))then
        Data.worldBossInfo.bosslv = obj:getInt("bosslv")
    end
    Data.worldBossInfo.lkreward = nil
    if(obj:containsKey("lkreward"))then
        Data.worldBossInfo.lkreward = Net.updateReward(obj:getObj("lkreward"), 0)
    end
    gDispatchEvt(EVENT_ID_WORLD_BOSS_SWEEP);
end

-- 购买挑战次数
function Net.sendWorldBossBuyfnum(num)
    Data.worldBossInfo.userbuyfightnum = num
    local media=MediaObj:create()
    media:setInt("num",num)
    Net.sendExtensionMessage(media, "wboss.buyfnum")
end

function Net.rec_wboss_buyfnum(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- Data.worldBossInfo.fnum = obj:getInt("fnum") -- 我的挑战次数
    Data.worldBossInfo.buynum = obj:getInt("buynum") -- 今日购买挑战次数
    Data.worldBossInfo.fnum = Data.worldBossInfo.fnum + Data.worldBossInfo.userbuyfightnum

    Net.updateReward(obj:getObj("reward"),0)

    gDispatchEvt(EVENT_ID_WORLD_BOSS_BUY_FIGHT_NUM)
end

-- 击杀奖励领取列表
function Net.sendWorldBossKillRewordInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wboss.krinfo")
end

function Net.rec_wboss_krinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {}
    ret.list={}

    local  list=obj:getIntArray("grlist")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(ret.list,list[i])
            --print("已经领取idx:"..list[i])
        end
    end 

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel and panel.__panelType == PANEL_WORLD_BOSS_REWARD) then
        panel:refreshData(ret)
    else
        Panel.popUp(PANEL_WORLD_BOSS_REWARD,ret)
    end
end

-- 领取击杀奖励
-- id:要领取的奖励id(没有该参数就是一键领取)
function Net.sendWorldBossGetKillReward(idx)
    local media=MediaObj:create()
    if not idx then
        Data.worldBossInfo.onekeykillrec = true
    else
        Data.worldBossInfo.onekeykillrec = false
        Data.worldBossInfo.killrecidx = idx
        media:setInt("id",idx)
    end
    Net.sendExtensionMessage(media, "wboss.getkr")
end

function Net.rec_wboss_getkr(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {}
    -- reward
    Net.updateReward(obj:getObj("reward"),2)

    ret.list={}
    local  list=obj:getIntArray("grlist")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(ret.list,list[i])
        end
    end

    gDispatchEvt(EVENT_ID_WORLD_BOSS_KILL_REWORD_REC)
end
