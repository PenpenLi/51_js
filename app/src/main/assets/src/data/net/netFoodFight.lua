----夺粮战

function Net.initLootFoodClientParams()
    gLootfoodOpenLv = DB.getClientParam("LOOTFOOD_REQUEST_LEVEL",true) --跨服夺粮战开启等级
    gLootfoodBeginDay = DB.getClientParam("LOOTFOOD_BEGIN_DAY",true)--跨服夺粮战活动开始日期
    gLootfoodBeginHour = DB.getClientParam("LOOTFOOD_BEGIN_HOUR",true)--跨服夺粮战活动开始小时
    gLootfoodEndDay = DB.getClientParam("LOOTFOOD_END_DAY",true)--跨服夺粮战活动结束日期
    gLootfoodEndHour = DB.getClientParam("LOOTFOOD_END_HOUR",true)--跨服夺粮战活动结束小时
    --gLootfoodInitNum = DB.getClientParam("LOOTFOOD_INIT_NUM",true)--跨服夺粮战掠夺次数初始值
    gLootfoodMaxNum = DB.getClientParam("LOOTFOOD_MAX_NUM",true)--跨服夺粮战掠夺次数上限
    gLootfoodRecoveryTime = DB.getClientParam("LOOTFOOD_RECOVERY_TIME",true)--跨服夺粮战多久恢复一次掠夺次数（秒）
    gLootfoodRefNum = DB.getClientParam("LOOTFOOD_REF_NUM",true) --跨服夺粮战免费刷新次数
    gLootfoodRefBuyNum = DB.getClientParamToTable("LOOTFOOD_REF_BUY_NUM",true)--跨服夺粮战刷新购买次数
    gLootfoodRefBuyPrice = DB.getClientParamToTable("LOOTFOOD_REF_BUY_PRICE",true) --跨服夺粮战刷新购买元宝
    --gLootfoodBuyNum = DB.getClientParamToTable("LOOTFOOD_LOOT_BUY_NUM",true) --跨服夺粮战掠夺购买次数
    --gLootfoodLootBuyPrice = DB.getClientParamToTable("LOOTFOOD_LOOT_BUY_PRICE",true) --跨服夺粮战掠夺购买元宝
    --gLootfoodRevengeBuyNum = DB.getClientParamToTable("LOOTFOOD_REVENGE_BUY_NUM",true) --跨服夺粮战复仇购买次数
    --gLootfoodRevengeBuyPrice = DB.getClientParamToTable("LOOTFOOD_REVENGE_BUY_PRICE",true) --跨服夺粮战复仇购买元宝
    gLootfoodLootRate = DB.getClientParam("LOOTFOOD_LOOT_RATE",true) --跨服夺粮战掠夺粮草百分比
    gLootfoodRevengeNum = DB.getClientParam("LOOTFOOD_REVENGE_NUM",true) --跨服夺粮战免费复仇次数
    gLootfoodAddFoodTime = DB.getClientParam("LOOTFOOD_ADD_FOOD_TIME",true) --跨服夺粮战多久增加一次固定粮草（秒）
end

function Net.getLootfoodAchiDb(lv)
    local ret={}
    for key, var in pairs(lootfoodachireward_db) do
        if(var.level1<=lv and var.level2>=lv)then
            table.insert(ret,var)
        end
    end
    return ret
end

function Net.getLootfoodRankRewardDb(lv)
    local ret={}
    for key, var in pairs(lootfoodrankreward_db) do
        if(var.level1<=lv and var.level2>=lv)then
            table.insert(ret,var)
        end
    end
    return ret
end

function Net.ParserOppList(list)
    -- 解析对手列表
    local ret = {}
    if(list)then
        list=tolua.cast(list,"MediaArray")
        for i=0, list:count()-1 do
            local obj=tolua.cast(list:getObj(i),"MediaObj")
            local item = {}
            item.uid = obj:getLong("uid")
            item.sid = obj:getInt("sid")
            item.uname = obj:getString("uname")
            item.sname = obj:getString("sname")
            item.price = obj:getInt("price")
            item.status = obj:getByte("status")
            item.addfood = obj:getInt("addfood")
            item.loot = obj:getByte("loot")
            item.icon = obj:getInt("icon")
            item.idetail = Net.parserShowInfo(obj:getObj("idetail"))
            item.lv = obj:getInt("lv")
            table.insert(ret,item)
        end
    end
    return ret
end

-- 获取界面信息
function Net.sendLootFoodGetInfo() 
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "lootfood.getinfo")
end

Net.lootfoodinfo = {}
function Net.rec_lootfood_getinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {
        -- lv1 等级段1
        -- lv2 等级段2
        -- food1 固定粮草 我的粮草=固定粮草+流动粮草
        -- food2 流动粮草 掠夺损失粮草=流动粮草*百分比
        -- rank 排名
        -- lootnum 可夺次数
        -- refnum 刷新次数
        -- lootbuy 掠夺购买次数
        -- revengenum 复仇次数
        -- revengebuy 复仇购买次数
        -- opplist 对手列表
            -- uid 用户ID
            -- sid 服务器ID
            -- uname 用户名称
            -- icon 用户图标
            -- idetail obj 用户图标明细
                -- halo
                -- wlv
                -- wkn
                -- hlv
            -- sname 服务器名称
            -- price 战力
            -- status 状态:0-正常 1-同军团 2-仇人
            -- addfood 可得粮草
            -- loot 是否掠夺(0否 1是)
            -- lv 用户等级
    }
    ret.lv1 = obj:getInt("lv1")
    ret.lv2 = obj:getInt("lv2")
    ret.food1 = obj:getInt("food1")
    ret.food2 = obj:getInt("food2")
    ret.rank = obj:getInt("rank")
    ret.lootnum = obj:getInt("lootnum")
    ret.refnum = obj:getInt("refnum")
    ret.lootbuy = obj:getInt("lootbuy")
    ret.revengenum = obj:getInt("revengenum")
    ret.revengebuy = obj:getInt("revengebuy")
    ret.opplist = Net.ParserOppList(obj:getArray("opplist"))

    Net.lootfoodinfo.revengenum = ret.revengenum
    Net.lootfoodinfo.lootnum = ret.lootnum
    Net.lootfoodinfo.lootbuy = ret.lootbuy

    gDispatchEvt(EVENT_ID_LOOTFOOD_GETINFO,ret)
    gLogEvent('lootfood.info')
end

function Net.rec_lootfood_getinfo_test()
    local ret = {}
    ret.lv1 = 2
    ret.lv2 = 12
    ret.food1 = 100
    ret.food2 = 200
    ret.rank = 102
    ret.lootnum = 5
    ret.refnum = 5
    ret.lootbuy = 3
    ret.revengenum = 5
    ret.revengebuy = 5
    ret.opplist = {}
    for i = 1,5 do
        local obj = {}
        obj.uid = 1002
        obj.sid = 12
        obj.uname = "喵喵"
        obj.sname = "建设天下"
        obj.price = 143535
        obj.status = 0
        obj.addfood = 100
        obj.loot = 1
        table.insert(ret.opplist,obj)
    end
    gDispatchEvt(EVENT_ID_LOOTFOOD_GETINFO,ret)
end
 
-- 查看玩家信息
function Net.sendLootFoodUserInfo(uid,sid)
    local media=MediaObj:create() 
    media:setLong("uid",uid)
    media:setInt("sid",sid)
    Net.lootFoodUid = uid
    Net.lootFoodSid = sid
    Net.sendExtensionMessage(media, "lootfood.userinfo") 
end


function Net.rec_lootfood_userinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={
        -- team 队伍信息（同竞技场）
        -- name 用户名称
        -- fname 家族
        -- sname 服务器名称
        -- price 战力
        -- lv 等级
        -- icon 头像
        -- idetail 形象
        -- rank 排名
        -- addfood 可得粮草
        -- vip byte
    }
    ret.team = Net.parseTeamObj(obj:getObj("team"))
    ret.name =obj:getString("name")  --   
    ret.sname =obj:getString("sname")  --   
    ret.fname =obj:getString("fname")
    ret.price =obj:getInt("price")  --        
    ret.lv =obj:getInt("lv")  --
    ret.icon = obj:getInt("icon")
    ret.show = Net.parserShowInfo(obj:getObj("idetail"))                 
    ret.rank = obj:getInt("rank")
    ret.vip = obj:getByte("vip")
    ret.addfood = obj:getInt("addfood")
    ret.uid = Net.lootFoodUid
    ret.sid = Net.lootFoodSid

    Panel.popUpVisible(PANEL_FORMATION,ret,3)
    gLogEvent("lootfood.userinfo")
end

-- 掠夺战斗
function Net.sendLootfoodFight(uid,sid)
    local media=MediaObj:create() 
    media:setLong("uid",uid)
    media:setInt("sid",sid)
    Net.sendExtensionMessage(media, "lootfood.fight")
end


function Net.rec_lootfood_fight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        if(obj:getByte("ret") == 12)then
            Panel.popBack(PANEL_ATLAS_FORMATION)
            Net.sendLootFoodGetInfo()
        end
        return
    end
    
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    local ret = {
        -- bat 战斗数据
        -- food 流动粮草
        -- lootnum 可夺次数
        -- addfood 获得粮草
    }
    ret.food = obj:getInt("food")
    ret.lootnum = obj:getInt("lootnum")
    gParserGameVideo(byteArr,BATTLE_TYPE_BATH)
    -- 抢夺获得粮草
    local rewards={}
    rewards.items={}
    table.insert(rewards.items,{id=OPEN_BOX_FOOD, num=obj:getInt("addfood")})
    Battle.reward.shows = rewards
    gLogEvent("lootfood.fight")
end


-- 刷新
function Net.sendLootfoodRef()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "lootfood.ref")
end


function Net.rec_lootfood_ref(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local ret = {
        -- opplist 对手列表
        -- reward 更新客户端缓存
        -- refnum 刷新次数
    }

    ret.opplist = Net.ParserOppList(obj:getArray("opplist")) 
    Net.updateReward(obj:getObj("reward"),0)
    ret.refnum = obj:getInt("refnum")
    gDispatchEvt(EVENT_ID_LOOTFOOD_REFRESH,ret)
    gLogEvent('lootfood.refresh')
end

-- 购买掠夺次数
function Net.sendLootfoodBuyloot(num)
    Net.lootfoodinfo.lootaddbuy = num
    local media=MediaObj:create() 
    media:setInt("num",num)
    Net.sendExtensionMessage(media, "lootfood.buyloot")
end

function Net.rec_lootfood_buyloot(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local ret = {
        -- lootnum 可夺次数
        -- reward 更新客户端缓存
    }

    ret.lootnum =obj:getInt("lootnum")
    ret.lootaddbuy = Net.lootfoodinfo.lootaddbuy               
    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_LOOTFOOD_BUYLOOT,ret)

    Net.lootfoodinfo.lootbuy = Net.lootfoodinfo.lootbuy + ret.lootaddbuy
    Net.lootfoodinfo.lootnum = ret.lootnum
    gLogEvent("lootfood.buyloot")
end

-- 购买复仇次数
Net.lootfoodrevenge = {}
function Net.sendLootfoodBuyrevenge(num)
    Net.lootfoodrevenge.buynum = num
    local media=MediaObj:create()
    media:setInt("num",num) 
    Net.sendExtensionMessage(media, "lootfood.buyrevenge")
end


function Net.rec_lootfood_buyrevenge(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_LOOTFOOD_REVENGE_BUY,Net.lootfoodrevenge.buynum)
    gLogEvent("lootfood.buyrevenge")
end

-- 查看战斗记录
Net.lootfoodrecord = {}
function Net.send_lootfood_record()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "lootfood.record")
end


function Net.rec_lootfood_record(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {
        -- list 
            -- id 记录ID
            -- uid 掠夺者ID
            -- sid 掠夺者服务器ID
            -- uname 掠夺者名称
            -- sname 掠夺者服务器名称
            -- icon 掠夺者icon
            -- vip 掠夺者vip
            -- price 掠夺者战力
            -- food 掠夺粮草
            -- vid 战斗录像ID
            -- revenge byte 是否复仇
    }

    Net.lootfoodrecord = {}
    local array = tolua.cast(obj:getArray("list"),"MediaArray")
    for i = 0,array:count()-1 do
        local item = tolua.cast(array:getObj(i),"MediaObj")
        local tmp = {}
        tmp.id = item:getLong("id")
        tmp.uid = item:getLong("uid")
        tmp.sid = item:getInt("sid")
        tmp.uname = item:getString("uname")
        tmp.sname = item:getString("sname")
        tmp.icon = item:getInt("icon")
        tmp.vip = item:getByte("vip")
        tmp.price = item:getInt("price")
        tmp.food = item:getInt("food")
        tmp.vid = item:getLong("vid")
        tmp.revenge = item:getByte("revenge")
        table.insert(ret,tmp)
        table.insert(Net.lootfoodrecord,tmp)
    end
    
    gDispatchEvt(EVENT_ID_LOOTFOOD_RECORD,ret)
end

-- 复仇
function Net.sendLootfoodRevenge(id)
    local media=MediaObj:create()
    media:setLong("id",id) 
    Net.lootfoodrevengeid = id
    Net.sendExtensionMessage(media, "lootfood.revenge")
end

function Net.rec_lootfood_revenge(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local ret = {
        -- bat 战斗数据
        -- food 流动粮草
    }
    ret.food = obj:getInt("food") 
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")

    Net.lootfoodinfo.revengenum = Net.lootfoodinfo.revengenum+1
    gParserGameVideo(byteArr,BATTLE_TYPE_BATH)

    -- 抢夺获得粮草
    local rewards={}
    rewards.items={}
    table.insert(rewards.items,{id=OPEN_BOX_FOOD, num=obj:getInt("addfood")})
    Battle.reward.shows = rewards

    if gBattleData.win == 1 then
        for k,v in pairs(Net.lootfoodrecord) do
            if v.id == Net.lootfoodrevengeid then
                v.revenge = 1
            end
        end
    end
    gLogEvent("lootfood.revenge")
end

-- 查看战斗录像
function Net.sendLootfoodVedio(vid)
    local media=MediaObj:create()
    media:setLong("vid",vid)
    Net.sendExtensionMessage(media, "lootfood.vedio")
end


function Net.rec_lootfood_vedio(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    Battle.brief = {} 
    Battle.brief.n1 = data:getString("n1")
    Battle.brief.n2 = data:getString("n2")
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA_LOG)
end

-- 查看成就奖励领取情况
function Net.sendLootfoodAchirecinfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "lootfood.achirecinfo")
end

function Net.rec_lootfood_achirecinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {
        -- food 我的粮草
        -- rec 领取情况(true表示已领取）
    }
    ret.food =obj:getInt("food")               
    ret.list={}

    local  list=obj:getBoolArray("rec")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(ret.list,list[i])
        end
    end 

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel and panel.__panelType == PANEL_FOODFIGHT_ACHI) then
        panel:refreshData(ret)
    else
        Panel.popUp(PANEL_FOODFIGHT_ACHI,ret)
    end
    
end

-- 领取成就奖励
function Net.sendLootfoodRecachireward(idx)
    local media=MediaObj:create()
    media:setInt("idx",idx)
    gLootFoodAchiIdx = idx
    Net.sendExtensionMessage(media, "lootfood.recachireward")
end

function Net.rec_lootfood_recachireward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        if(obj:getByte("ret")==33)then
            -- 粮草不足
            Net.sendLootfoodAchirecinfo()
        end
        return
    end

    Net.updateReward(obj:getObj("reward"),2)

    gDispatchEvt(EVENT_ID_LOOTFOOD_ACHI_REC,gLootFoodAchiIdx)
end

-- 夺粮战排行榜（参考原来的排名榜）
Net.LootFoodRank = {}
Net.LootFoodRank.ver = 0
Net.LootFoodRank.rank = 0
Net.LootFoodRank.food = 0
Net.LootFoodRank.list = {}
function Net.sendLootfoodRank(ver)
    -- ver 排行版本号（第一次传0）
    local media=MediaObj:create()
    media:setInt("ver",ver)
    Net.sendExtensionMessage(media, "lootfood.rank")
end

function Net.rec_lootfood_rank(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {
        -- ver 排行版本号
        -- rank 我的排名（版本号一致时不下发）
        -- food 我的粮草（版本号一致时不下发）
        -- list 排行列表（版本号一致时不下发）
            -- id 用户ID
            -- username 用户名称
            -- level 用户等级
            -- vip 用户VIP等级
            -- icon 图标
            -- fname 家族名称
            -- food 粮草
    }
    
    ret.rank = obj:getInt("rank")
    ret.food = obj:getInt("food")
    local userlist = {}
    
    local list = obj:getArray("list")
    if(list)then
        list = tolua.cast(list,"MediaArray")
        for i=0,list:count()-1 do
            local tmp = tolua.cast(list:getObj(i),"MediaObj")
            local item = {}
            item.uid = tmp:getLong("id")
            item.uname = tmp:getString("username")
            item.level = tmp:getShort("level")
            item.vip = tmp:getByte("vip")
            item.icon = tmp:getInt("icon")
            item.fname = tmp:getString("fname")
            item.food = tmp:getInt("food")
            table.insert(userlist,item)
        end
    end

    if obj:getInt("ver") == Net.LootFoodRank.ver then
        ret.rank = Net.LootFoodRank.rank
        ret.food = Net.LootFoodRank.food
    else
        Net.LootFoodRank.ver = obj:getInt("ver")
        Net.LootFoodRank.rank = ret.rank
        Net.LootFoodRank.food = ret.food
        Net.LootFoodRank.list = userlist
    end
    
    gDispatchEvt(EVENT_ID_LOOTFOOD_RANK,ret)
end

function Net.sendLootfoodRecAllAchiReward()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "lootfood.recallachireward")
end

function Net.rec_lootfood_recallachireward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2) 
    gDispatchEvt(EVENT_ID_LOOTFOOD_REC_ACHI_ALL)
end
