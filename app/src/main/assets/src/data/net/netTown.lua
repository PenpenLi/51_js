
function Net.resetTowerInfo()
    Data.towerInfo.stage =0;
    Data.towerInfo.star = 0;
    Data.towerInfo.curstar = 0;
    Data.towerInfo.reset = 0;
    Data.towerInfo.isEnd = false;
    Data.towerInfo.disreward = {};
    Data.towerInfo.attr = {};
    Data.towerInfo.stagestar = {};
    Data.towerInfo.addattr = {};
end

function Net.resetTowerInfoEnterNext()
    Data.towerInfo.score = 0;
    Data.towerInfo.actioned = {}
    Data.towerInfo.gridattr = 0;
    Data.towerInfo.actionnum = 0;
end

function Net.sendTownGetinfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "town.getinfo");
end

function Net.rec_town_getinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.towerInfo.maxstar = obj:getInt("maxstar");
    Data.towerInfo.curstar = obj:getInt("curstar");
    Data.towerInfo.stage = obj:getInt("stage");
    Data.towerInfo.star = obj:getInt("star");
    Data.towerInfo.reset = obj:getInt("reset");
    Data.towerInfo.buyreset = obj:getInt("buyreset");
    Data.towerInfo.isEnd = obj:getBool("end");
    Data.towerInfo.addScore = 0;
    Data.towerInfo.disreward = Net.parserTowerDisreward(obj:getObj("disreward"));
    Data.towerInfo.attr = {};
    local attrList = obj:getArray("attr");
    if(attrList)then
        listcnt = attrList:count();
        if (listcnt ~= 0) then
            for i = 0, listcnt - 1 do
                local robj = attrList:getObj(i);
                robj = tolua.cast(robj, "MediaObj");
                local data = {};
                data.attr = robj:getInt("attr");
                data.val = robj:getInt("val")/100;
                table.insert(Data.towerInfo.attr,data);
            end
        end
        -- local sortFunc = function(a,b)
        --     return toint(a.attr) < toint(b.attr);
        -- end
        -- table.sort(Data.towerInfo.attr,sortFunc);
    end
    -- print("#######");
    -- print_lua_table(Data.towerInfo.attr);
    Data.towerInfo.addattr = Net.parserTowerAddAttr(obj:getArray("addattr"));
    
    Data.towerInfo.stagestar={}
    local stardArrays=obj:getIntArray("stagestar")
    if(stardArrays)then
        for i=0, stardArrays:size()-1 do
            table.insert(Data.towerInfo.stagestar,stardArrays[i]);
        end
    end

    print("--------");
    print_lua_table(Data.towerInfo);

    if Panel.isTopPanel(PANEL_TOWER) then
        gDispatchEvt(EVENT_ID_TOWER_NEXT_FLOOR);
    else
        gDispatchEvt(EVENT_ID_TOWER_ENTER);
    end

    --[[local param = {}
    param['power'] = math.ceil(Data.towerInfo.power/5000) * 5000
    gLogEvent("town.enter-"..tostring(Data.towerInfo.floor), param)]]
end



function Net.parserTowerDisreward(disrewardObj)
    if(disrewardObj == nil)then
        return {};
    end

    local data = {};
    data.id = disrewardObj:getInt("id");
    data.num = disrewardObj:getInt("num");
    data.pty = disrewardObj:getInt("pty");
    data.pri = disrewardObj:getInt("pri");
    data.dis = disrewardObj:getInt("dis");

    return data;

end

function Net.parserTowerAddAttr(addattrList)
    if(addattrList == nil)then
        return {};
    end

    local ret = {};
    local listcnt = addattrList:count();
    if (listcnt ~= 0) then
        for i = 0, listcnt - 1 do
            local robj = addattrList:getObj(i);
            robj = tolua.cast(robj, "MediaObj");
            local data = {};
            data.star = robj:getInt("star");
            data.attr = robj:getInt("attr");
            data.val = robj:getInt("val")/100;
            table.insert(ret,data);
        end
    end
    return ret;
end


function Net.sendTowerFightEnter()
    local media=MediaObj:create()
    media:setByte("diff",  Data.towerInfo.diff);
    Net.sendExtensionMessage(media, "town.fightenter");
end


function Net.rec_town_fightenter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.towerInfo.power = obj:getInt("price");
    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj);
    Net.sendAtlasEnterParam = {}
    Battle.battleType = BATTLE_TYPE_TOWER;
    local maxRound = 20;
    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,"b015",power);
end

----爬塔副本结算
function Net.sendTowerFight()
    local media=MediaObj:create()
    media:setObjArray("blist",Battle.getLogData())
    Net.sendExtensionMessage(media, "town.fight",true)
end

function Net.rec_town_fight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    if(obj:containsKey("disreward"))then
        Data.towerInfo.disreward = Net.parserTowerDisreward(obj:getObj("disreward"));
    end
    Data.towerInfo.maxstar = obj:getInt("maxstar");
    Data.towerInfo.curstar = obj:getInt("curstar");
    Data.towerInfo.star = obj:getInt("star");
    Data.towerInfo.stage = obj:getInt("stage");
    Data.towerInfo.isEnd = obj:getBool("end");
    Data.towerInfo.win = Battle.win;
    Battle.reward={}
    Battle.reward.formation={}
    local rewardObj=obj:getObj("reward");
    Data.towerInfo.addattr = Net.parserTowerAddAttr(obj:getArray("addattr"));
    Battle.reward.shows= Net.updateReward(rewardObj,0)
    Panel.popUp(PANEL_ATLAS_FINAL);

    Data.towerInfo.isEnd = Battle.win == 0;
    if(not Data.towerInfo.isEnd)then
        table.insert(Data.towerInfo.stagestar,Data.towerInfo.diff);
    end

    Data.towerInfo.floorReward= Net.updateReward(obj:getObj("reward1"),0)
    Data.towerInfo.floorStar = obj:getInt("floorstar");

    if( Data.towerInfo.floorReward
        and Data.towerInfo.floorReward.items
        and  table.count(Data.towerInfo.floorReward.items)>0)then
        --过一层
        Data.towerInfo.stage = Data.towerInfo.stage - 1;
    end

    -- if(TowerPanelData.guideIndex > 0)then
    --     if(Data.towerInfo.win == 1)then
    --         TowerPanelData.guideIndex = TowerPanelData.guideIndex + 1;
    --     else
    --         TowerPanelData.guideIndex = 10;
    --     end
    -- end
end

function Net.sendTowerAddAttr(star)
    local media=MediaObj:create()
    media:setInt("star",star);
    Net.sendExtensionMessage(media, "town.addattr");
end

function Net.rec_town_addattr(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.towerInfo.addattr = Net.parserTowerAddAttr(obj:getArray("addattr"));
    gDispatchEvt(EVENT_ID_TOWER_ADD_ATTR);
end

function Net.sendTowerBuydisGift()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "town.buydisgift");
end

function Net.rec_town_buydisgift(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2);
    Data.towerInfo.disreward = {};

    gDispatchEvt(EVENT_ID_TOWER_BUY_GIFT);

    gLogPurchase("town.buydisgift", 1, gTDParam.tower_gift_price)
end

function Net.sendTowerSweep(oneKey)
    local media=MediaObj:create()
    if(oneKey)then
        media:setBool("onekey",oneKey);
    end
    Net.sendExtensionMessage(media, "town.sweep");
end

function Net.rec_town_sweep(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local starFloor = Data.towerInfo.stage;
    local desFloor = obj:getInt("stage");
    -- Data.towerInfo.floor = desFloor;
    Data.towerInfo.maxstar = obj:getInt("maxstar");
    Data.towerInfo.curstar = obj:getInt("curstar");
    Data.towerInfo.stage = obj:getInt("stage");
    Data.towerInfo.star = obj:getInt("star");

    Data.towerInfo.isEnd = obj:getBool("end"); 
    Data.towerInfo.disreward = Net.parserTowerDisreward(obj:getObj("disreward"));

    Data.towerInfo.addattr = Net.parserTowerAddAttr(obj:getArray("addattr"));
    Data.towerInfo.autoattr = Net.parserTowerAddAttr(obj:getArray("autoattr"));
    Data.towerInfo.attr={}
    local attrList = obj:getArray("attr");
    if(attrList)then
        listcnt = attrList:count();
        if (listcnt ~= 0) then
            for i = 0, listcnt - 1 do
                local robj = attrList:getObj(i);
                robj = tolua.cast(robj, "MediaObj");
                local data = {};
                data.attr = robj:getInt("attr");
                data.val = robj:getInt("val")/100;
                table.insert(Data.towerInfo.attr,data);
            end
        end 
    end
    Net.updateReward(obj:getObj("reward"),0);

    local baseGold=DB.getClientParam("TOWN_FLOOR_BASE_REWARD")
    local addGold=DB.getClientParam("TOWN_FLOOR_ADD_REWARD")

    --计算奖励
    local sweepRewards = {};

    if(starFloor==desFloor)then
        gShowNotice(gGetWords("towerWords.plist","44"));
        return;
    end
    
    
    for i=starFloor,desFloor-1 do
        table.insert(Data.towerInfo.stagestar,3);
        local reward = {};
        reward.stage = i+1;
        local data = DB.getTowerData(i+1);  
        table.insert(sweepRewards,reward);
        if(data)then
            reward.items={}
            table.insert(reward.items,{id=OPEN_BOX_TOWERMONEY,num=data.ratio*3})
              
            if(i~=0 and  (i+1)%3==0 )then 
                local floorReward = {}; 
                floorReward.items={}
                floorReward.floor=(i+1)/3
                local floorStar = Data.getTownFloorStar(floorReward.floor);
                floorReward.floorStar = floorStar
                local totalGold=(gUserInfo.level*addGold+baseGold)*floorStar
                table.insert(floorReward.items,{id=OPEN_BOX_GOLD,num=totalGold})
                local rewards = cjson.decode(data.reward);
                for key, var in pairs(rewards) do
                    if(var.star==math.floor(floorStar/3)*3)then
                        table.insert(floorReward.items,var);
                    end
                end
                table.insert(sweepRewards,floorReward);
            end
        end 
        
    end
    Panel.popUp(PANEL_TOWER_SWEEP,sweepRewards);

end

function Net.sendTowerReset()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "town.reset");
end

function Net.rec_town_reset(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.resetTowerInfo();
    Data.towerInfo.reset = obj:getInt("reset");


    gDispatchEvt(EVENT_ID_TOWER_RESET);

    -- print("reset TowerPanelData.guideIndex = "..TowerPanelData.guideIndex);
    --[[if(TowerPanelData.guideIndex > 0)then
        TowerPanelData.guideIndex = 1;
        Unlock.system.town.guideByIndex(TowerPanelData.guideIndex);
    end
    ]]
end

function Net.sendTowerShopInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "town.shopbuyinfo");
end

function Net.rec_town_shopbuyinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.towerInfo.maxstar = obj:getInt("maxstar");

    local buylist = {};
    local list = obj:getArray("list");
    local listcnt = list:count();
    if (listcnt ~= 0) then
        for i = 0, listcnt - 1 do
            local robj = list:getObj(i);
            robj = tolua.cast(robj, "MediaObj");
            local data = {};
            data.id = robj:getInt("id");
            data.buyedNum = robj:getInt("num");
            table.insert(buylist,data);
        end
    end


    for key,var in pairs(gShops[SHOP_TYPE_TOWER1].items) do
        for k,buyitem in pairs(buylist) do
            if(var.pos == buyitem.id)then
                var.buyNum = buyitem.buyedNum;
                break;
            end
        end
    end
    for key,var in pairs(gShops[SHOP_TYPE_TOWER2].items) do
        for k,buyitem in pairs(buylist) do
            if(var.pos == buyitem.id)then
                var.buyNum = buyitem.buyedNum;
                break;
            end
        end
    end
    for key,var in pairs(gShops[SHOP_TYPE_TOWER3].items) do
        for k,buyitem in pairs(buylist) do
            if(var.pos == buyitem.id)then
                var.buyNum = buyitem.buyedNum;
                break;
            end
        end
    end

    gDispatchEvt(EVENT_ID_INIT_SHOP,gShops[SHOP_TYPE_TOWER1]);
end

function Net.sendTowerShopBuy(id,num)
    local media=MediaObj:create()
    media:setInt("id",id);
    media:setInt("num",num)
    Net.sendExtensionMessage(media, "town.shopbuy");
end

function Net.rec_town_shopbuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_TREASURE_SHARED_BUY)
end

function Net.sendTowerRewardInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "town.rewardinfo");
end

function Net.rec_town_rewardinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

   -- Data.towerInfo.maxstar = obj:getInt("maxstar");

    local rewardlist = {};
    local list = obj:getArray("list");
    local listcnt = list:count();
    if (listcnt ~= 0) then
        for i = 0, listcnt - 1 do
            local robj = list:getObj(i);
            robj = tolua.cast(robj, "MediaObj");
            local data = {};
            data.star = robj:getInt("star");
            data.buyedNum = robj:getInt("num");
            table.insert(rewardlist,data);
        end
    end

    gDispatchEvt(EVENT_ID_TOWER_SHOP_REWARD,rewardlist);
end

function Net.sendTowerBuyReward(star)
    local media=MediaObj:create()
    media:setInt("star",star);
    ShopPanelData.towerBuyRewardid = star;
    Net.sendExtensionMessage(media, "town.buyreward");
end

function Net.rec_town_buyreward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    local data = {};
    data.id = ShopPanelData.towerBuyRewardid;
    gDispatchEvt(EVENT_ID_TOWER_SHOP_REWARD_BUY,data);
end


function Net.sendTowerBuyInfo()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "town.buyinfo");
end

function Net.rec_town_buyinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end ;
    local ret = {};
    ret.maxstar = obj:getInt("maxstar");
    ret.rec={}

    local  list=obj:getBoolArray("rec")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(ret.rec,list[i])
        end
    end     
    Panel.popUpVisible(PANEL_BUY_MONEY_PANEL,ret); 
end



function Net.sendTowerBuy(idx)
    local media=MediaObj:create() 
    Net.sendTowerBuyParam = idx;
    media:setInt("idx",idx);
    Net.sendExtensionMessage(media, "town.buy");
end

function Net.rec_town_buy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end ; 
    Net.updateReward(obj:getObj("reward"),2);
    Net.parserVipBuy(obj:getObj("vipbn"))
    gDispatchEvt(EVENT_ID_TOWER_BUY_INFO,Net.sendTowerBuyParam ) 
end

-- 购买掠夺次数
function Net.sendTownBuyReset(num)
    -- Net.lootfoodinfo.lootaddbuy = num
    local media=MediaObj:create() 
    media:setInt("num",num)
    Net.sendExtensionMessage(media, "town.buyreset")
end

function Net.rec_town_buyreset(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    Data.towerInfo.buyreset = obj:getInt("buyreset");
    local ret = {}
    -- ret.lootnum =obj:getInt("lootnum")
    -- ret.lootaddbuy = Net.lootfoodinfo.lootaddbuy               
    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_TOWER_BUY_RESET,ret)

    -- Net.lootfoodinfo.lootbuy = Net.lootfoodinfo.lootbuy + ret.lootaddbuy
    -- Net.lootfoodinfo.lootnum = ret.lootnum
end

