----无尽之塔排行
function Net.sendRankTower(ver)
    local media=MediaObj:create()
    media:setInt("ver",ver);
    Net.sendExtensionMessage(media, "town.rank")
end
function Net.rec_town_rank(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.rank = obj:getInt("rank")
    ret.star = obj:getInt("star")
    ret.ranks={}
    local rankList=obj:getArray("list")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseRankTower(rankList:getObj(i-1)))
        end
    end
    -- print(">>>>>>")
    -- print_lua_table(ret)
    gDispatchEvt(EVENT_ID_RANK_TOWER,ret)
end

----世界boss排行
function Net.sendRankWorldBoss()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "rank.wboss")
end


function Net.rec_rank_wboss(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.rank = obj:getInt("rank")
    ret.price = obj:getInt("price")
    ret.islast = obj:getBool("islast")
    ret.ranks={}
    local rankList=obj:getArray("list")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseRankWorldBoss(rankList:getObj(i-1)))
        end
    end
    -- print_lua_table(ret)
    gDispatchEvt(EVENT_ID_RANK_BOSS,ret)
end

function Net.sendRankFamily(ver)
    local media=MediaObj:create();
    media:setInt("ver",ver);
    Net.sendExtensionMessage(media, "rank.family"); 
end

function Net.rec_rank_family(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.ranks={}
    ret.rank = obj:getInt("rank")
    ret.exp = obj:getInt("exp")
    local rankList=obj:getArray("list")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseFamilyRank(rankList:getObj(i-1)))
        end
    end
    -- print_lua_table(ret)
    gDispatchEvt(EVENT_ID_RANK_FAMILY,ret)
end

function Net.sendRankPetstage(ver)
    local media=MediaObj:create();
    media:setInt("ver",ver);
    Net.sendExtensionMessage(media, "rank.petstage");      
end

function Net.rec_rank_petstage(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.ranks={}
    ret.rank = obj:getInt("rank")
    ret.stage = obj:getInt("stage")
    local rankList=obj:getArray("list")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseRankPet(rankList:getObj(i-1)))
        end
    end
    -- print_lua_table(ret.ranks)
    gDispatchEvt(EVENT_ID_RANK_PET,ret)
end

function Net.sendRankLevel(ver)
    local media=MediaObj:create();
    media:setInt("ver",ver);
    Net.sendExtensionMessage(media, "rank.level");      
end

function Net.rec_rank_level(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.ranks={}
    ret.rank = obj:getInt("rank")
    ret.level = obj:getInt("level")
    local rankList=obj:getArray("list")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseRankLevel(rankList:getObj(i-1)))
        end
    end
    gDispatchEvt(EVENT_ID_RANK_LEVEL,ret)
end

----竞技场排行
function Net.sendArenaRank(page)

    local media=MediaObj:create()
    media:setInt("index",page)
    Net.sendExtensionMessage(media, CMD_ARENA_RANK)
end


function Net.rec_arena_rank(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.rank = obj:getInt("rank")
    ret.ranks={}
    local rankList=obj:getArray("info")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseArenaRank(rankList:getObj(i-1)))
        end
    end
    gDispatchEvt(EVENT_ID_ARENA_RANK,ret)
end

function Net.sendRankCave(ver)
    local media=MediaObj:create();
    --media:setInt("ver",ver);
    Net.sendExtensionMessage(media, "rank.cave");      
end

function Net.rec_rank_cave(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    ret={}
    ret.ranks={}
    ret.rank = obj:getInt("rank")
    ret.price = obj:getInt("price")
    local rankList=obj:getArray("list")
    if(rankList)then
        rankList=tolua.cast(rankList,"MediaArray")
        for i=1, rankList:count() do
            table.insert(ret.ranks,i,Net.parseRankPetCave(rankList:getObj(i-1)))
        end
    end
    gDispatchEvt(EVENT_ID_RANK_CAVE,ret)
end
