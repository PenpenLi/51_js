Data = Data or {}
Data.vip = {}

VIP_SWEEP              = 1;--扫荡
VIP_QUICKUPGRADE       = 2;--一键强化
VIP_BUYPETSOUL         = 3;--购买兽魂
VIP_DOUBLE             = 4;--活动副本奖励翻倍次数
VIP_ARENA              = 5;--竞技场购买次数
VIP_DIAMONDHP          = 6;--购买体力次数
VIP_MAX_SKILLPOT       = 7;--技能点上限增加至
VIP_STAGERESET         = 8;--精英关卡重置次数
VIP_MAXFRIEND          = 9;--好友上限数量
VIP_SKILLPOT           = 10;--钻石购买技能点次数
VIP_STONEGOLD          = 11;--点石成金
VIP_FUND               = 12;--可购买养成基金
VIP_SHOP2              = 13;--奸商
VIP_SHOP3              = 14;--黑市
VIP_EXP                = 15;--经验
VIP_TRAINROOM          = 16;--vip训练房
VIP_SPIRIT_QUICK       = 17;--命魂一键寻仙
VIP_DRAWCARD_SOUL      = 22;--魂匣
VIP_ATLAS_BOSS_BUY     = 23;--BOSS次数购买
VIP_SERVERBATTLE_FIND  = 24; --跨服战王者寻找对手次数
VIP_BATH_LAST          = 28; --召唤修仙最后一档
VIP_BATH_REWARD        = 29; --修仙奖励加成
VIP_SOULSHOP_REFRESH   = 30; --将星商店刷新次数
VIP_MINING_ATLAS_RESET = 32; --海底副本的重置次数
VIP_TOWERMONEY         = 33; --无尽徽章
VIP_SPIRIT_VIOLENCE    = 36; --暴力寻仙
VIP_GOLDBOX             = 37; --金宝箱
VIP_FAMILY_BUFF_UP     = 38;--帮派buff鼓舞次数
VIP_PETTOWER_SWEEP_TIMES     = 40;--购买卧龙窟扫荡次数
VIP_TOWN_RESET_TIMES     = 42;--购买无尽之塔重置次数

VIP_TRAINROOM_LOOT = 100;--购买训练房抢夺次数
VIP_MINE_BAG      = 101;--矿工包购买次数
VIP_MINE_BAG_LEV1 = 102;--初级矿石包购买次数
VIP_MINE_BAG_LEV2 = 103;--中级矿石包购买次数
VIP_MINE_BAG_LEV3 = 104;--高级矿石包购买次数
VIP_DETONATOR     = 105;--雷管购买次数
VIP_MINE_PROJ2 = 106;  --挖矿工程2
VIP_MINE_PROJ3 = 107;  --挖矿工程3
VIP_MINE_PROJ4 = 108;  --挖矿工程4
VIP_MINE_PROJ4 = 109;  --挖矿工程5
VIP_SERVERBATTLE_CHANGE = 110; --跨服战刷新金币数
VIP_LOOT_FOOD = 111;   --夺粮战
VIP_LOOT_FOOD_REVENG = 112;   --夺粮战复仇次数购买
VIP_RICHMAN=113
VIP_BUY_TREASURE_MAP=114 --跨服寻宝购买宝图
VIP_CRUSADE=115
VIP_WORLD_BOSS_NEW_FIGHT = 116 --新世界boss战斗次数
VIP_ACTIVITY_SNATCH = 117 --夺宝活动

function Data.canBuyTimes(type,shopTip,buyCallback,discount)

    local canBuy = true;
    local price = 0;
    local buyCount = 0;
    local showBuyPriceTip = false;
    for key,val in pairs(Data.vip) do
        if val.judgeTimes and val.type == type then
            canBuy = val.judgeTimes();
            if canBuy then
                price,buyCount = val.getBuyPriceAndCount();
                if val.isShowBuyPriceAndCount then
                    showBuyPriceTip = val.isShowBuyPriceAndCount();
                end
            end
            break;
        end
    end

    if(discount)then
        price=price*discount/100
    end


    if shopTip then
        if canBuy then
            if showBuyPriceTip then
                local data = {};
                data.type = type;
                -- local lefttimes = Data.getLeftUseTimes(type);
                -- data.info = gGetWords("vipWords.plist","vipBuy"..type,price,buyCount);
                -- data.tip = gGetWords("vipWords.plist","vipTimes"..type,lefttimes);
                -- if data.tip == nil or data.tip == "nil" then
                --     data.tip = gGetWords("vipWords.plist","vipTimes",lefttimes);
                -- end
                -- data.price = price;
                data.buyCallback = buyCallback;
                data.discount = discount;
                -- print_lua_table(data);
                Panel.popUpVisible(PANEL_VIP_BUYTIMES,data);
            else
                if NetErr.isDiamondEnough(price) then
                    if(buyCallback)then
                        buyCallback();
                    end
                    if (TDGAItem) then
                        if (type ~= VIP_STONEGOLD) then
                            gLogPurchase("vip_buy_times_"..tostring(type),1,price)
                        end
                    end
                else
                    canBuy = false;
                end
            end
        else
            local vip = Data.getCanBuyTimesVip(type);
            if Data.getCurVip() < vip and Module.isClose(SWITCH_VIP) == false then
                local word = gGetWords("vipWords.plist","vipBuy",vip);
                local onCharge = function ()
                    Panel.popUp(PANEL_PAY);
                end
                gConfirmCancel(word,onCharge);
                -- gShowNotice(gGetWords("vipWords.plist","vipBuy",vip));
            else
                if(Module.isClose(SWITCH_VIP))then
                    gShowNotice(gGetWords("vipWords.plist","maxBuy"));
                else
                    local isRefresh = false;
                    if(type == VIP_SOULSHOP_REFRESH)then
                        isRefresh = true;
                    end
                    if type == VIP_WORLD_BOSS_NEW_FIGHT then
                        gShowNotice(gGetWords("vipWords.plist","maxBuy"));
                    else
                        Panel.popUpVisible(PANEL_VIP_NOTICE,isRefresh);
                    end
                    
                end
            end
        end
    end

    return canBuy;
end

function Data.getBuyPriceAndCount(type)
    for key,val in pairs(Data.vip) do
        if val.type == type and val.getBuyPriceAndCount then
            return val.getBuyPriceAndCount();
        end
    end
    return 0,0
end

function Data.getBuyPriceAndCountWithTimes(type,times)
    for key,val in pairs(Data.vip) do
        if val.type == type and val.getBuyPriceAndCountWithTimes then
            return val.getBuyPriceAndCountWithTimes(times);
        end
    end
    return 0,0
end

function Data.getBuyPriceAndCountMoreTimes(type,times)
    local curTimes = Data.getUsedTimes(type);
    local totalPrice = 0;
    local totalCount = 0;
    for i=curTimes+1,curTimes+times do
        local price,count = Data.getBuyPriceAndCountWithTimes(type,i);
        totalPrice = totalPrice + price;
        totalCount = totalCount + count;
    end

    return totalPrice,totalCount;
end

function Data.updateVipData()
    Data.friend.maxFriendCount = Data.getMaxUseTimes(VIP_MAXFRIEND);
end

function Data.setUsedTimes(type,num)
    for key,val in pairs(Data.vip) do
        if val.setUsedTimes and val.type == type then
            val.setUsedTimes(num);
            break;
        end
    end
end

function Data.getUsedTimes(type)
    for key,val in pairs(Data.vip) do
        if val.getUsedTimes and val.type == type then
            return val.getUsedTimes();
        end
    end
end

function Data.getMaxUseTimes(type)

    for key,val in pairs(Data.vip) do
        if val.getMaxUseTimes and val.type == type then
            return val.getMaxUseTimes();
        end
    end

    local vip = DB.getVip(Data.getCurVip());
    local maxTimes = DB.getVipValue(vip,type);

    if type == VIP_DIAMONDHP and  Data.activityProAdd and  Data.activityProAdd.value then
        maxTimes=maxTimes+ Data.activityProAdd.value
    end
    return maxTimes;
end

function Data.getLeftUseTimes(type)
    local lefttimes = Data.getMaxUseTimes(type) - Data.getUsedTimes(type);
    if lefttimes < 0 then
        lefttimes = 0;
    end
    return lefttimes;
end

function Data.getCanBuyTimesVip(type)
    for key,vip in pairs(vip_db) do
        local vipData = DB.getVip(vip.vip);
        local maxTimes = DB.getVipValue(vipData,type);
        -- print("type = "..type);
        -- print_lua_table(vipData);
        -- print("maxTimes = "..maxTimes);
        if maxTimes > 0 then
            return toint(vip.vip);
        end
    end
    return 0;
end

function Data.getBuyTimesPrice(num,diasKey,numsKey)
    local price = 0;
    local dias = DB.getClientParamToTable(diasKey);
    local nums = DB.getClientParamToTable(numsKey);

    local min = 1
    local max = 0

    for key, max in pairs(nums) do
        max=toint(max)
        if(num >= min and num <= max)then
            price = toint(dias[key])
            break;
        elseif num > max then
            price = toint(dias[table.getn(dias)]);
        end
        min = max + 1
    end
    return price;
end

function Data.getBuyTimesPrice2(curTimes,diasKey)
    local prices = DB.getClientParamToTable(diasKey);
    local num = table.getn(prices);
    local index = curTimes;
    if index > num then
        index = num;
    end
    local price = prices[index];
    return toint(price);
end

function Data.judgeTimes(type)
    for _,val in pairs(Data.vip) do
        if val.judgeTimes and val.type == type then
            return val.judgeTimes()
        end
    end
    return false
end

--将星商店刷新次数相关
Data.vip.soulshoprefresh = {};
Data.vip.soulshoprefresh.type = VIP_SOULSHOP_REFRESH;
Data.vip.soulshoprefresh.isUseRefresh = false;
function Data.vip.soulshoprefresh.setUsedTimes(num)
    Data.vip.soulshoprefresh.usedTimes = num;
end
function Data.vip.soulshoprefresh.getUsedTimes()
    return Data.vip.soulshoprefresh.usedTimes;
end
function Data.vip.soulshoprefresh.setUseRefreshItem(isUseRefresh)
    Data.vip.soulshoprefresh.isUseRefresh = isUseRefresh;
end

function Data.vip.soulshoprefresh.getBuyPriceAndCount()

    local price = DB.getClientParam("SHOP_CARDSTAR_REFRESH_PRICE_NEW");
    local count = 1;

    if(Data.vip.soulshoprefresh.isUseRefresh)then
        price = 0;
    end

    return price,count;

end

function Data.vip.soulshoprefresh.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.soulshoprefresh.type);
    if Data.vip.soulshoprefresh.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

--体力相关
Data.vip.energy = {};
Data.vip.energy.type = VIP_DIAMONDHP;
function Data.vip.energy.setUsedTimes(num)
    Data.vip.energy.usedTimes = num;
    print("set Data.vip.energy.usedTimes = " .. Data.vip.energy.usedTimes) ;
end
function Data.vip.energy.getUsedTimes()
    print("get Data.vip.energy.usedTimes = " .. Data.vip.energy.usedTimes) ;
    return Data.vip.energy.usedTimes;
end
function Data.vip.energy.getBuyPriceAndCount()

    local price = Data.getBuyTimesPrice(Data.vip.energy.usedTimes+1,"VIP_BUY_HP_DIAMOND","VIP_BUY_HP_DIAMOND_NUM");
    local count = DB.getClientParam("VIP_DIAMOND_HP");

    return price,count;
end

function Data.vip.energy.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.energy.type);
    if Data.vip.energy.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

--武将经验相关
Data.vip.exp = {};
Data.vip.exp.type = VIP_EXP;
function Data.vip.exp.setUsedTimes(num)
    Data.vip.exp.usedTimes = num;
end
function Data.vip.exp.getUsedTimes()
    return Data.vip.exp.usedTimes;
end
function Data.vip.exp.getBuyPriceAndCount()

    local price = Data.getBuyTimesPrice(Data.vip.exp.usedTimes+1,"VIP_BUY_CARDEXP_DIAMOND","VIP_BUY_CARDEXP_DIAMOND_NUM");
    -- local count = DB.getClientParam("VIP_DIAMOND_CARDEXP");
    local val = DB.getClientParamToTable("VIP_DIAMOND_CARDEXP");
    local count = val[1]+math.max(0, math.floor((Data.getCurLevel()-val[2])/val[3]))*val[4];

    return price,count;
end

function Data.vip.exp.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.exp.type);
    if Data.vip.exp.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

--兽魂相关
Data.vip.petsoul = {};
Data.vip.petsoul.type = VIP_BUYPETSOUL;
function Data.vip.petsoul.setUsedTimes(num)
    Data.vip.petsoul.usedTimes = num;
end
function Data.vip.petsoul.getUsedTimes()
    return Data.vip.petsoul.usedTimes;
end
function Data.vip.petsoul.getBuyPriceAndCount()

    local price = Data.getBuyTimesPrice(Data.vip.petsoul.usedTimes+1,"VIP_BUY_PETSOUL_DIAMOND","VIP_BUY_PETSOUL_DIAMOND_NUM");
    local count = DB.getClientParam("VIP_DIAMOND_PETSOUL");

    return price,count;
end

function Data.vip.petsoul.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.petsoul.type);
    if Data.vip.petsoul.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

--无尽徽章相关
Data.vip.towermoney = {};
Data.vip.towermoney.type = VIP_TOWERMONEY;
function Data.vip.towermoney.setUsedTimes(num)
    Data.vip.towermoney.usedTimes = num;
end
function Data.vip.towermoney.getUsedTimes()
    return Data.vip.towermoney.usedTimes;
end
function Data.vip.towermoney.getBuyPriceAndCount()

    local price = Data.getBuyTimesPrice(Data.vip.towermoney.usedTimes+1,"VIP_BUY_TOWER_DIAMOND","VIP_BUY_TOWER_DIAMOND_NUM");
    local count = DB.getClientParam("VIP_DIAMOND_TOWER");

    return price,count;
end

function Data.vip.towermoney.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.towermoney.type);
    if Data.vip.towermoney.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

--购买金宝箱相关
Data.vip.goldbox = {};
Data.vip.goldbox.type = VIP_GOLDBOX;
function Data.vip.goldbox.setUsedTimes(num)
    Data.vip.goldbox.usedTimes = num;
end
function Data.vip.goldbox.getUsedTimes()
    return Data.vip.goldbox.usedTimes;
end
function Data.vip.goldbox.getBuyPriceAndCount()

    local price = DB.getClientParam("PET_SHOP_GOLD_KEY_PRICE");
    local count = 1;

    return price,count;
end

function Data.vip.goldbox.getBuyPriceAndCountWithTimes(curTimes)
    local price = DB.getClientParam("PET_SHOP_GOLD_KEY_PRICE");
    local count = 1;

    return price,count
end

function Data.vip.goldbox.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.goldbox.type);
    if Data.vip.goldbox.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.goldbox.isShowBuyPriceAndCount()
    return true;
end

--点石成金相关
Data.vip.stonegold = {};
Data.vip.stonegold.type = VIP_STONEGOLD;
function Data.vip.stonegold.setUsedTimes(num)
    Data.vip.stonegold.usedTimes = num;
    print("set Data.vip.stonegold.usedTimes = " .. Data.vip.stonegold.usedTimes) ;
end
function Data.vip.stonegold.getUsedTimes()
    print("get Data.vip.stonegold.usedTimes = " .. Data.vip.stonegold.usedTimes) ;
    return Data.vip.stonegold.usedTimes;
end
function Data.vip.stonegold.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.stonegold.type);
    if Data.vip.stonegold.usedTimes >= maxTimes then
        return false;
    end
    return true;
end
function Data.vip.stonegold.setPrice(price)
    Data.vip.stonegold.price = price;
end
function Data.vip.stonegold.setBuyCount(num)
    Data.vip.stonegold.count = num;
end
function Data.vip.stonegold.getBuyPriceAndCount()

    local price = Data.vip.stonegold.price;
    local count = Data.vip.stonegold.count;

    return price,count;
end

--技能点相关
Data.vip.skillpot = {};
Data.vip.skillpot.type = VIP_SKILLPOT;
function Data.vip.skillpot.setUsedTimes(num)
    Data.vip.skillpot.usedTimes = num;
end
function Data.vip.skillpot.getUsedTimes()
    return Data.vip.skillpot.usedTimes;
end

function Data.vip.skillpot.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.skillpot.type);
    -- print("maxTimes = "..maxTimes);
    -- print("usedTimes = "..Data.vip.skillpot.usedTimes);
    if Data.vip.skillpot.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

-- function Data.vip.skillpot.isShowBuyPriceAndCount()
--     return true;
-- end

function Data.vip.skillpot.maxSkillPoint()
    local ret=Data.getMaxUseTimes(VIP_MAX_SKILLPOT);
    if( Data.hasMemberCard(CARD_TYPE_LIFE))then
        ret=ret+DB.getClientParam("LIFECARD_ADD_SKILLPOINT");
    end
    return ret
end

function Data.vip.skillpot.getBuyPriceAndCount()

    local price = Data.getBuyTimesPrice(Data.vip.skillpot.usedTimes+1,"VIP_BUY_SKILLPOINT_DIAMOND","VIP_BUY_SKILLPOINT_DIAMOND_NUM");
    local count = DB.getClientParam("VIP_DIAMOND_SKILLPOINT");

    return price,count;
end

--竞技场次数相关
Data.vip.arena = {};
Data.vip.arena.type = VIP_ARENA;
function Data.vip.arena.setUsedTimes(num)
    Data.vip.arena.usedTimes = num;
end
function Data.vip.arena.getUsedTimes()
    return Data.vip.arena.usedTimes;
end

function Data.vip.arena.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.arena.type);
    -- print("maxTimes = "..maxTimes);
    -- print("usedTimes = "..Data.vip.skillpot.usedTimes);
    if Data.vip.arena.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.arena.getBuyPriceAndCount()

    -- local price = DB.getClientParam("ARENA_BUY_TIMES_PRICE");
    -- local price = Data.getBuyTimesPrice(Data.vip.arena.usedTimes+1,"VIP_BUY_ARENA_DIAMOND","VIP_BUY_ARENA_DIAMOND_NUM");
    -- local count = DB.getClientParam("ARENA_ADD_TIMES");

    -- return price,count;

    return Data.vip.arena.getBuyPriceAndCountWithTimes(Data.vip.arena.usedTimes+1);
end

function Data.vip.arena.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_ARENA_DIAMOND","VIP_BUY_ARENA_DIAMOND_NUM");
    local count = DB.getClientParam("ARENA_ADD_TIMES");

    return price,count;
end

function Data.vip.arena.isShowBuyPriceAndCount()
    return true;
end

--精英副本重置次数
Data.vip.atlasreset = {};
Data.vip.atlasreset.type = VIP_STAGERESET;
function Data.vip.atlasreset.setUsedTimes(num)
    Data.vip.atlasreset.usedTimes = num;
end
function Data.vip.atlasreset.getUsedTimes()
    return Data.vip.atlasreset.usedTimes;
end

function Data.vip.atlasreset.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.atlasreset.type);
    -- print("maxTimes = "..maxTimes);
    -- print("usedTimes = "..Data.vip.skillpot.usedTimes);
    if Data.vip.atlasreset.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.atlasreset.setBuyCount(num)
    Data.vip.atlasreset.count = num;
end

function Data.vip.atlasreset.getBuyPriceAndCount()
    -- local prices = DB.getClientParamToTable("STAGE_BUYBAT_DIAMOND");
    -- local num = table.getn(prices);
    -- local index = Data.vip.atlasreset.usedTimes+1;
    -- if index > num then
    --     index = num;
    -- end
    -- local price = prices[index];
    -- local count = Data.vip.atlasreset.count;

    -- return price,count;
    return Data.vip.atlasreset.getBuyPriceAndCountWithTimes(Data.vip.atlasreset.usedTimes+1);
end


function Data.vip.atlasreset.getBuyPriceAndCountWithTimes(curTimes)
    -- local prices = DB.getClientParamToTable("STAGE_BUYBAT_DIAMOND");
    -- local num = table.getn(prices);
    -- local index = curTimes;
    -- if index > num then
    --     index = num;
    -- end
    -- local price = prices[index];
    local count = Data.vip.atlasreset.count;
    local price = Data.getBuyTimesPrice2(curTimes,"STAGE_BUYBAT_DIAMOND");
    return price,count;
end

function Data.vip.atlasreset.isShowBuyPriceAndCount()
    return true;
end

--活动副本奖励翻倍次数
Data.vip.activitydouble = {};
Data.vip.activitydouble.type = VIP_DOUBLE;

function Data.vip.activitydouble.setUsedTimes(num)
    Data.vip.activitydouble.usedTimes = num;
end
function Data.vip.activitydouble.getUsedTimes()
    return Data.vip.activitydouble.usedTimes;
end

function Data.vip.activitydouble.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.activitydouble.type);
    if Data.vip.activitydouble.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.activitydouble.setPrice(price)
    Data.vip.activitydouble.price = price;
end

function Data.vip.activitydouble.getBuyPriceAndCount()
    local price = Data.vip.activitydouble.price;
    local count = 1;

    return price,count;
end

--抢位置购买次数
Data.vip.trainloot = {};
Data.vip.trainloot.type = VIP_TRAINROOM_LOOT;
function Data.vip.trainloot.setUsedTimes(num)
    Data.vip.trainloot.usedTimes = num;
end
function Data.vip.trainloot.getUsedTimes()
    return Data.vip.trainloot.usedTimes;
end
function Data.vip.trainloot.getMaxUseTimes()
    return DB.getClientParam("DRINK_LOOT_MAX");
end

function Data.vip.trainloot.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.trainloot.type);
    if Data.vip.trainloot.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.trainloot.getBuyPriceAndCount()
    return Data.vip.trainloot.getBuyPriceAndCountWithTimes(Data.vip.trainloot.usedTimes+1);
end

function Data.vip.trainloot.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"DRINK_LOOT_DIAMOND","DRINK_LOOT_DIAMOND_NUM");
    local count = 1;

    return price,count;
end

function Data.vip.trainloot.isShowBuyPriceAndCount()
    return true;
end


-- VIP_MINE_BAG      = 23;--矿工包购买次数
-- VIP_MINE_BAG_LEV1 = 24;--初级矿石包购买次数
-- VIP_MINE_BAG_LEV2 = 25;--中级矿石包购买次数
-- VIP_MINE_BAG_LEV3 = 26;--高级矿石包购买次数
-- VIP_DETONATOR     = 27;--雷管购买次数
--矿工包购买次数
Data.vip.mineBag = {}
Data.vip.mineBag.type = VIP_MINE_BAG
function Data.vip.mineBag.setUsedTimes(num)
    Data.vip.mineBag.usedTimes = num
end

function Data.vip.mineBag.getUsedTimes()
    return Data.vip.mineBag.usedTimes
end
--TODO
function Data.vip.mineBag.getMaxUseTimes()
    local maxNums = DB.getClientParamToTable("VIP_BUY_MINE_BAG_MAX")
    if maxNums[Data.getCurVip() + 1] ~= nil then
        return toint(maxNums[Data.getCurVip() + 1])
    else
        return toint(maxNums[#maxNums])
    end
end

function Data.vip.mineBag.isShowBuyPriceAndCount()
    return true
end

function Data.vip.mineBag.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.mineBag.type)
    if Data.vip.mineBag.usedTimes >= maxTimes then
        return false
    end
    return true
end

function Data.vip.mineBag.getBuyPriceAndCount()
    return Data.vip.mineBag.getBuyPriceAndCountWithTimes(Data.vip.mineBag.usedTimes+1)
end
--TODO
function Data.vip.mineBag.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_MINE_BAG_DIAMOND","VIP_BUY_MINE_BAG_DIAMOND_NUM")
    local count = 1

    return price,count
end

Data.vip.mineBagLev1 = {}
Data.vip.mineBagLev1.type = VIP_MINE_BAG_LEV1
function Data.vip.mineBagLev1.setUsedTimes(num)
    Data.vip.mineBagLev1.usedTimes = num
end

function Data.vip.mineBagLev1.getUsedTimes()
    return Data.vip.mineBagLev1.usedTimes
end

function Data.vip.mineBagLev1.getMaxUseTimes()
    local maxNums = DB.getClientParamToTable("VIP_BUY_MINE_BAG_LEVEL1_MAX")
    if maxNums[Data.getCurVip() + 1] ~= nil then
        return toint(maxNums[Data.getCurVip() + 1])
    else
        return toint(maxNums[#maxNums])
    end
end

function Data.vip.mineBagLev1.isShowBuyPriceAndCount()
    return true
end

function Data.vip.mineBagLev1.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.mineBagLev1.type)
    if Data.vip.mineBagLev1.usedTimes >= maxTimes then
        return false
    end
    return true
end

function Data.vip.mineBagLev1.getBuyPriceAndCount()
    return Data.vip.mineBagLev1.getBuyPriceAndCountWithTimes(Data.vip.mineBagLev1.usedTimes+1)
end

function Data.vip.mineBagLev1.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_MINE_BAG_LEVEL1_DIAMOND","VIP_BUY_MINE_BAG_LEVEL1_DIAMOND_NUM")
    local count = 1

    return price,count
end

Data.vip.mineBagLev2 = {}
Data.vip.mineBagLev2.type = VIP_MINE_BAG_LEV2
function Data.vip.mineBagLev2.setUsedTimes(num)
    Data.vip.mineBagLev2.usedTimes = num
end

function Data.vip.mineBagLev2.getUsedTimes()
    return Data.vip.mineBagLev2.usedTimes
end

function Data.vip.mineBagLev2.getMaxUseTimes()
    local maxNums = DB.getClientParamToTable("VIP_BUY_MINE_BAG_LEVEL2_MAX")
    if maxNums[Data.getCurVip() + 1] ~= nil then
        return toint(maxNums[Data.getCurVip() + 1])
    else
        return toint(maxNums[#maxNums])
    end
end

function Data.vip.mineBagLev2.isShowBuyPriceAndCount()
    return true
end

function Data.vip.mineBagLev2.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.mineBagLev2.type)
    if Data.vip.mineBagLev2.usedTimes >= maxTimes then
        return false
    end
    return true
end

function Data.vip.mineBagLev2.getBuyPriceAndCount()
    return Data.vip.mineBagLev2.getBuyPriceAndCountWithTimes(Data.vip.mineBagLev2.usedTimes+1)
end

function Data.vip.mineBagLev2.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_MINE_BAG_LEVEL2_DIAMOND","VIP_BUY_MINE_BAG_LEVEL2_DIAMOND_NUM")
    local count = 1

    return price,count
end

Data.vip.mineBagLev3 = {}
Data.vip.mineBagLev3.type = VIP_MINE_BAG_LEV3
function Data.vip.mineBagLev3.setUsedTimes(num)
    Data.vip.mineBagLev3.usedTimes = num
end

function Data.vip.mineBagLev3.getUsedTimes()
    return Data.vip.mineBagLev3.usedTimes
end

function Data.vip.mineBagLev3.getMaxUseTimes()
    local maxNums = DB.getClientParamToTable("VIP_BUY_MINE_BAG_LEVEL3_MAX")
    if maxNums[Data.getCurVip() + 1] ~= nil then
        return toint(maxNums[Data.getCurVip() + 1])
    else
        return toint(maxNums[#maxNums])
    end
end

function Data.vip.mineBagLev3.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.mineBagLev3.type)
    if Data.vip.mineBagLev3.usedTimes >= maxTimes then
        return false
    end
    return true
end

function Data.vip.mineBagLev3.isShowBuyPriceAndCount()
    return true
end

function Data.vip.mineBagLev3.getBuyPriceAndCount()
    return Data.vip.mineBagLev3.getBuyPriceAndCountWithTimes(Data.vip.mineBagLev3.usedTimes+1)
end

function Data.vip.mineBagLev3.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_MINE_BAG_LEVEL3_DIAMOND","VIP_BUY_MINE_BAG_LEVEL3_DIAMOND_NUM")
    local count = 1

    return price,count
end


Data.vip.detonator = {}
Data.vip.detonator.type = VIP_DETONATOR
function Data.vip.detonator.setUsedTimes(num)
    Data.vip.detonator.usedTimes = num
end

function Data.vip.detonator.getUsedTimes()
    return Data.vip.detonator.usedTimes
end

--TODO
function Data.vip.detonator.getMaxUseTimes()
    local maxNums = DB.getClientParamToTable("VIP_BUY_MINE_BAG_EXPLODER_MAX")
    if maxNums[Data.getCurVip() + 1] ~= nil then
        return toint(maxNums[Data.getCurVip() + 1])
    else
        return toint(maxNums[#maxNums])
    end
end

function Data.vip.detonator.isShowBuyPriceAndCount()
    return true
end

function Data.vip.detonator.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.detonator.type)
    if Data.vip.detonator.usedTimes >= maxTimes then
        return false
    end
    return true
end

function Data.vip.detonator.getBuyPriceAndCount()
    return Data.vip.detonator.getBuyPriceAndCountWithTimes(Data.vip.detonator.usedTimes+1)
end

function Data.vip.detonator.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_MINE_BAG_EXPLODER_DIAMOND","VIP_BUY_MINE_BAG_EXPLODER_DIAMOND_NUM")
    local count = 1

    return price,count
end

Data.vip.mineProj2 = {}
Data.vip.mineProj2.type = VIP_MINE_PROJ2
function Data.vip.mineProj2.getMaxUseTimes()
    return DB.getMinVipLvByMineProjNums(2)
end

Data.vip.mineProj3 = {}
Data.vip.mineProj3.type = VIP_MINE_PROJ3
function Data.vip.mineProj3.getMaxUseTimes()
    return DB.getMinVipLvByMineProjNums(3)
end

Data.vip.mineProj4 = {}
Data.vip.mineProj4.type = VIP_MINE_PROJ4
function Data.vip.mineProj4.getMaxUseTimes()
    return DB.getMinVipLvByMineProjNums(4)
end

Data.vip.mineProj5 = {}
Data.vip.mineProj5.type = VIP_MINE_PROJ5
function Data.vip.mineProj5.getMaxUseTimes()
    return DB.getMinVipLvByMineProjNums(5)
end






--精英副本重置次数
Data.vip.atlasBossBuy = {};
Data.vip.atlasBossBuy.type = VIP_ATLAS_BOSS_BUY;
function Data.vip.atlasBossBuy.setUsedTimes(num)
    Data.vip.atlasBossBuy.usedTimes = num;
end
function Data.vip.atlasBossBuy.getUsedTimes()
    return Data.vip.atlasBossBuy.usedTimes;
end
function Data.vip.atlasBossBuy.getBuyPriceAndCount()
    local price = Data.getBuyTimesPrice(Data.vip.atlasBossBuy.usedTimes+1,"VIP_BUY_EVIL_DIAMOND","VIP_BUY_EVIL_DIAMOND_NUM");
    local count = DB.getClientParam("VIP_DIAMOND_EVIL");
    return price,count;
end

function Data.vip.atlasBossBuy.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"VIP_BUY_EVIL_DIAMOND","VIP_BUY_EVIL_DIAMOND_NUM");
    local count = DB.getClientParam("VIP_DIAMOND_EVIL");
    return price,count;
end

function Data.vip.atlasBossBuy.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.atlasBossBuy.type);
    if Data.vip.atlasBossBuy.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.atlasBossBuy.isShowBuyPriceAndCount()
    return true;
end

--跨服战寻找对手次数
--TODO
Data.vip.serverBattleFind = {};
Data.vip.serverBattleFind.type = VIP_SERVERBATTLE_FIND;
function Data.vip.serverBattleFind.setUsedTimes(num)
    Data.vip.serverBattleFind.usedTimes = num;
end
function Data.vip.serverBattleFind.getUsedTimes()
    return Data.vip.serverBattleFind.usedTimes;
end

function Data.vip.serverBattleFind.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.serverBattleFind.type);
    -- print("maxTimes = "..maxTimes);
    -- print("usedTimes = "..Data.vip.skillpot.usedTimes);
    if Data.vip.serverBattleFind.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.serverBattleFind.getBuyPriceAndCount()
    return Data.vip.serverBattleFind.getBuyPriceAndCountWithTimes(Data.vip.serverBattleFind.usedTimes+1);
end

function Data.vip.serverBattleFind.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"WORLD_WAR_VIP_BUY_PRICE","WORLD_WAR_VIP_BUY_PRICE_NUM");
    local count = DB.getClientParam("WORLD_WAR_VIP_BUY_NUM");

    return price,count;
end

function Data.vip.serverBattleFind.isShowBuyPriceAndCount()
    return true;
end

--海底副本的重置次数
Data.vip.miningAtlasReset = {};
Data.vip.miningAtlasReset.type = VIP_MINING_ATLAS_RESET;
function Data.vip.miningAtlasReset.setUsedTimes(num)
    Data.vip.miningAtlasReset.usedTimes = num;
end

function Data.vip.miningAtlasReset.getUsedTimes()
    return Data.vip.miningAtlasReset.usedTimes;
end

function Data.vip.miningAtlasReset.getBuyPriceAndCount()
    local nextUseTimes = Data.vip.miningAtlasReset.usedTimes + 1
    local price = Data.getBuyTimesPrice2(nextUseTimes,"MINING_CHAPTER_RESET_DIAMOND")
    return price,1
end

function Data.vip.miningAtlasReset.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.miningAtlasReset.type);
    if Data.vip.miningAtlasReset.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.miningAtlasReset.isShowBuyPriceAndCount()
    return false
end

--军团buff鼓舞次数
Data.vip.familyBuffUp = {}
Data.vip.familyBuffUp.type = VIP_FAMILY_BUFF_UP
function Data.vip.familyBuffUp.setUsedTimes(num)
    Data.vip.familyBuffUp.usedTimes = num
end

function Data.vip.familyBuffUp.getUsedTimes()
    return Data.vip.familyBuffUp.usedTimes
end

function Data.vip.familyBuffUp.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.familyBuffUp.type);
    if Data.vip.familyBuffUp.usedTimes >= maxTimes then
        return false;
    end
    return true;
end


--购买卧龙窟扫荡次数
Data.vip.petTower = {};
Data.vip.petTower.type = VIP_PETTOWER_SWEEP_TIMES;
function Data.vip.petTower.setUsedTimes(num)
    Data.vip.petTower.usedTimes = num;
end
function Data.vip.petTower.getUsedTimes()
    return Data.vip.petTower.usedTimes;
end

function Data.vip.petTower.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.petTower.type);
    -- print("maxTimes = "..maxTimes);
    -- print("usedTimes = "..Data.vip.petTower.usedTimes);
    if Data.vip.petTower.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.petTower.setNeedPrice(price)
    Data.vip.petTower.needPrice = price;
end

function Data.vip.petTower.getBuyPriceAndCount()
    return Data.vip.petTower.getBuyPriceAndCountWithTimes(Data.vip.petTower.usedTimes+1);
end

function Data.vip.petTower.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.vip.petTower.needPrice;
    local count = 1;
    return price,count;
end

function Data.vip.petTower.isShowBuyPriceAndCount()
    return true;
end

--购买无尽之塔重置次数
Data.vip.townReset = {};
Data.vip.townReset.type = VIP_TOWN_RESET_TIMES;
function Data.vip.townReset.setUsedTimes(num)
    print("Data.vip.townReset.setUsedTimes"..num)
    Data.vip.townReset.usedTimes = num;
end
function Data.vip.townReset.getUsedTimes()
    return Data.vip.townReset.usedTimes;
end

function Data.vip.townReset.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.townReset.type);
    if Data.vip.townReset.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.townReset.getBuyPriceAndCount()
    return Data.vip.townReset.getBuyPriceAndCountWithTimes(Data.vip.townReset.usedTimes+1);
end

function Data.vip.townReset.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"TOWN_BUY_RESET_PRICE","TOWN_BUY_RESET_COUNT");
    local count = 1;
    return price,count;
end

function Data.vip.townReset.isShowBuyPriceAndCount()
    return true;
end

--夺粮战 购买可掠夺次数
Data.vip.lootfood = {};
Data.vip.lootfood.type = VIP_LOOT_FOOD;
function Data.vip.lootfood.setUsedTimes(num)
    Data.vip.lootfood.usedTimes = num;
end
function Data.vip.lootfood.getUsedTimes()
    return Data.vip.lootfood.usedTimes;
end

function Data.vip.lootfood.judgeTimes()
    return true;
end

function Data.vip.lootfood.getMaxUseTimes()
    return 100
end

function Data.vip.lootfood.getBuyPriceAndCount()
    return Data.vip.lootfood.getBuyPriceAndCountWithTimes(Data.vip.lootfood.usedTimes+1);
end

function Data.vip.lootfood.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"LOOTFOOD_LOOT_BUY_PRICE","LOOTFOOD_LOOT_BUY_NUM");
    local count = 1;

    return price,count;
end

function Data.vip.lootfood.isShowBuyPriceAndCount()
    return true;
end

--夺粮战 购买复仇次数
Data.vip.lootfoodreveng = {};
Data.vip.lootfoodreveng.type = VIP_LOOT_FOOD_REVENG;
function Data.vip.lootfoodreveng.setUsedTimes(num)
    Data.vip.lootfoodreveng.usedTimes = num;
end
function Data.vip.lootfoodreveng.getUsedTimes()
    return Data.vip.lootfoodreveng.usedTimes;
end

function Data.vip.lootfoodreveng.judgeTimes()
    return true;
end

function Data.vip.lootfoodreveng.getMaxUseTimes()
    return 100
end

function Data.vip.lootfoodreveng.getBuyPriceAndCount()
    return Data.vip.lootfoodreveng.getBuyPriceAndCountWithTimes(Data.vip.lootfoodreveng.usedTimes+1);
end

function Data.vip.lootfoodreveng.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"LOOTFOOD_REVENGE_BUY_PRICE","LOOTFOOD_REVENGE_BUY_NUM");
    local count = 1;

    return price,count;
end

function Data.vip.lootfoodreveng.isShowBuyPriceAndCount()
    return true;
end




--夺粮战 购买可掠夺次数
Data.vip.richman = {};
Data.vip.richman.type = VIP_RICHMAN;
function Data.vip.richman.setUsedTimes(num)
    Data.vip.richman.usedTimes = num;
end
function Data.vip.richman.getUsedTimes()
    return Data.vip.richman.usedTimes;
end

function Data.vip.richman.judgeTimes()
    return true;
end

function Data.vip.richman.getMaxUseTimes()
    return 100
end

function Data.vip.richman.getBuyPriceAndCount()
    return Data.vip.richman.getBuyPriceAndCountWithTimes(Data.vip.richman.usedTimes+1);
end

function Data.vip.richman.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"RICHMAN_REF_BUY_PRICE","RICHMAN_REF_BUY_NUM");
    local count = 1; 
    return price,count;
end

function Data.vip.richman.isShowBuyPriceAndCount()
    return true;
end





--夺粮战 购买可掠夺次数
Data.vip.crusade = {};
Data.vip.crusade.type = VIP_CRUSADE;
function Data.vip.crusade.setUsedTimes(num)
    Data.vip.crusade.usedTimes = num;
end
function Data.vip.crusade.getUsedTimes()
    return Data.vip.crusade.usedTimes;
end

function Data.vip.crusade.judgeTimes()
    return true;
end

function Data.vip.crusade.getMaxUseTimes()
    return DB.getCrusadeBuyNum(Data.getCurVip())
end

function Data.vip.crusade.getBuyPriceAndCount()
    return Data.vip.crusade.getBuyPriceAndCountWithTimes(Data.vip.crusade.usedTimes+1);
end

function Data.vip.crusade.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"CRUSADE_TOKEN_BUY_PRICE","CRUSADE_TOKEN_BUY_PRICE_NUM");
    local count = 1; 
    return price,count;
end

function Data.vip.crusade.isShowBuyPriceAndCount()
    return true;
end


--跨服寻宝，购买宝图次数
Data.vip.buyTreasureMap = {};
Data.vip.buyTreasureMap.type = VIP_BUY_TREASURE_MAP;
function Data.vip.buyTreasureMap.setUsedTimes(num)
    Data.vip.buyTreasureMap.usedTimes = num;
end
function Data.vip.buyTreasureMap.getUsedTimes()
    return Data.vip.buyTreasureMap.usedTimes;
end

function Data.vip.buyTreasureMap.judgeTimes()
    return true;
end

function Data.vip.buyTreasureMap.getMaxUseTimes()
    return DB.getTreasureHuntMaxBuy()
end

function Data.vip.buyTreasureMap.getBuyPriceAndCount()
    return Data.vip.buyTreasureMap.getBuyPriceAndCountWithTimes(Data.vip.buyTreasureMap.usedTimes+1);
end

function Data.vip.buyTreasureMap.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"CT_BUY_MAP_PRICE","CT_BUY_MAP_NUM");
    local count = 1; 
    return price,count;
end

function Data.vip.buyTreasureMap.isShowBuyPriceAndCount()
    return true;
end

function Data.vip.buyTreasureMap.getFreeBuyNum()
    local buyMapNums = DB.getClientParamToTable("CT_BUY_MAP_NUM", true)
    return buyMapNums[1]
end

--新世界boss 购买战斗次数
Data.vip.wordbossnew = {};
Data.vip.wordbossnew.type = VIP_WORLD_BOSS_NEW_FIGHT;
function Data.vip.wordbossnew.setUsedTimes(num)
    Data.vip.wordbossnew.usedTimes = num;
end
function Data.vip.wordbossnew.getUsedTimes()
    return Data.vip.wordbossnew.usedTimes;
end

function Data.vip.wordbossnew.judgeTimes()
    local maxTimes = Data.getMaxUseTimes(Data.vip.wordbossnew.type);
    if Data.vip.wordbossnew.usedTimes >= maxTimes then
        return false;
    end
    return true;
end

function Data.vip.wordbossnew.getMaxUseTimes()
    return Data.worldBossParam.add_cnum_buy_max
end

function Data.vip.wordbossnew.getBuyPriceAndCount()
    return Data.vip.wordbossnew.getBuyPriceAndCountWithTimes(Data.vip.wordbossnew.usedTimes+1);
end

function Data.vip.wordbossnew.getBuyPriceAndCountWithTimes(curTimes)
    local price = Data.getBuyTimesPrice(curTimes,"WORLD_BOSS_ADD_CNUM_BUY_PRICE","WORLD_BOSS_ADD_CNUM_BUY_NUM");
    local count = 1;

    return price,count;
end

function Data.vip.wordbossnew.isShowBuyPriceAndCount()
    return true;
end

--夺宝活动
Data.vip.snatchact = {};
Data.vip.snatchact.type = VIP_ACTIVITY_SNATCH;
function Data.vip.snatchact.setUsedTimes(num)
    
end
function Data.vip.snatchact.getUsedTimes()
    return 0;
end

function Data.vip.snatchact.judgeTimes()
    return true;
end

function Data.vip.snatchact.getMaxUseTimes()
    return Data.vip.snatchact.maxUseTimes
end

function Data.vip.snatchact.getBuyPriceAndCount()
    return Data.vip.snatchact.getBuyPriceAndCountWithTimes(1);
end

function Data.vip.snatchact.getBuyPriceAndCountWithTimes(curTimes)
    local price = 1;
    local count = 1;

    return price,count;
end

function Data.vip.snatchact.isShowBuyPriceAndCount()
    return true;
end
