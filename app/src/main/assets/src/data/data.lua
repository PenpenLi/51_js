
Data=Data or {}



function  Data.clear()
    gUserInfo={}--角色信息
    gUserCards={}--卡牌
    gUserTeams={}
    gUserFormation={}
    gUserPets={} --宠物
    gUserFamilyBuff={}
    gGiftBagAct={}
    gGiftBagBuy={}
    gGiftPay={}
    gLuckWheel={}
    gRichman={}

    gPhoneSecond=0
    ghdShowBtnkip = false
    gServerTime=0
    gServerTimeZone=8
    gClientTime=0
    gResetDataInDay = 0;--凌晨5点重置数据
    gSendSMSTime=0 --发送信息时间

    gShops={}
    gArena={}
    gChats={}


    gIapBuy={}

    gUserItems={}--背包(消耗，宝石，其他）
    gUserEquipItems={}--背包(材料）

    gUserTreasure={} --宝物
    gUserTreasureShared={} --宝物碎片

    gUserSouls={} --碎片（卡牌）
    gUserShared={} --碎片（材料)
    gUserPetSouls={}
    gFriend={}
    FriendListPanel.data.friend.uid = 0
    gCrusadeData={}
    gAtlas={} --副本信息
    gFamily = {};
    gFamilyInfo = {}; --军团信息
    gFamilyInfo.iMemexp = 0;
    gFamilyInfo.iExp = 0;
    gFamilyInfo.iDayExp = 0;
    gFamilyInfo.weekexp = 0;

    gFamilySearchList = {};
    gFamilyAppListInfo = {};
    gFamilyAppList = {};
    gFamilySpringInfo = {};
    gFamilySevenData = {};
    gPushSet = {}
    gRelations={}
    gTDParam={} --for talkingdata
    -- gNotices = {}
    Data.drawCard={}
    Data.skillPointTime=0
    Data.energyTime=0
    Data.atlasBossTime=0
    Data.systemHandShakeTime=0
    Data.remainBuyGoldNum=0 --购买金币次数
    Data.buyEnergyNum=0 --购买体力次数
    Data.activity = {};
    Data.activityLogin7={}
    Data.activityLevelUp={}
    Data.activityLevelUpRemainTime=0
    Data.activityInvestReward={}
    Data.activityInvestBuy=false
    Data.activitySaleOffData={}
    Data.activityExchangeData={}
    Data.activityPayData={}
    Data.activityExpenseReturnData={}
    Data.activityAll={}
    Data.activityCat={}
    Data.activityWish={}
    Data.activityProAdd={}
    Data.activityWeekGiftInfo={}
    Data.activityChargeReturn={}
    Data.activityBuyEnergySaleoff={}
    Data.activityShopLimitSaleoff={}
    Data.activityConShopLimitSaleoff={}
    Data.activityAtlasSaleoff={}
    Data.activeSoullifeSaleoff={}
    Data.activityEatBun = {}
    Data.activityDayTasks = {}
    Data.activityRecruitData={}    
    Data.activityHolidaySign={}
    Data.activityInfo29={}
    Data.activity81={}
    Data.donateList = {}
    Data.activitySnatchData={}
    Data.activitySnatchShopData={}
    Data.emoney = 0;
    
    Data.hefuActFlag=false;

    gSceneArenaInfo = {};
    Data.redpos = {}; -- 红点
    Data.redpos.act97 = {}
    Data.redpos.act98 = {}
    Data.redpos.act = {}
    Data.redpos.act2 = {}
    Data.redpos.act3 = {}
    -- Data.actRedposTime = 0
    Data.wantedItem=0
    Data.wantedItemNum=0
    Data.gChatQuery = false;

    Data.worldBossInfo = {}
    Data.worldBossParam = {}

    Data.m_onlineInfo = {};
    Data.rollNoticeList = {};
    Data.noRollNoticeList = {};
    Data.CaveInfo={}
    gCloseModules = {};
    Data.initSysRecord();
    Data.mptTime = 0 --矿区点数恢复时间
    -- table.insert(gCloseModules,SWITCH_NOTICE);
    Data.cardRaiseBatchTime=1
    Data.initActivityRedPosLogin()
    Data.initCardAwakeParam()

    gFamilyMatchInfo = {};
    gServerBattle.clear()
    Net.sendAtlasEnterParam=nil
    gFirstEnterSound=false
    gEnterFromLevelup = false;
    Data.redposRefreshFrame = 0;
    gRedposRefreshDirty = true;
    Data.appsComment = false
    Data.hasRedPack=false
    Data.loopPackNum=0
    gPayInfo = {}

    Data.limit_etime = nil
    Data.limit_stype = nil

    Data.advertises = {}

    gUserInfo.halo = 0
    gUserInfo.firstcg = 0
    Data.bolFisrtSend = false

    Data.bolInPayPanel = false

    gFamilyStageInfo = {} --军团竞赛信息
    Data.initFamilyStageInfo()
    gTreasureHunt.clear()
    Data.huntIntervalInfos = {} --冒险活动开启时间与当前时间间隔tabe,冒险活动包括世界boss,跨服寻宝,夺粮战
    Data.finalHuntIntervalInfos = {}
    gConstellation.clear()

    -- tracking bi log errors
    gLogError = 0
end

--在活动里，要每天都出现红点一次的设定（注意：可出现1个类型多个活动，没办法设置，得服务端加）
--此方法 只适合 固定1个活动
function Data.initActivityRedPosLogin()
    Data.activityRedPosLogin={}

    -- Data.activityRedPosLogin[ACT_TYPE_1]=true
    -- Data.activityRedPosLogin[ACT_TYPE_7]=true
    Data.activityRedPosLogin[ACT_TYPE_19]=true
    Data.activityRedPosLogin[ACT_TYPE_96]=true
    Data.activityRedPosLogin[ACT_TYPE_114]=true
    Data.activityRedPosLogin[ACT_TYPE_115]=true
    Data.activityRedPosLogin[ACT_TYPE_81]=true
    Data.activityRedPosLogin[ACT_TYPE_117]=true
    Data.activityRedPosLogin[ACT_TYPE_118]=true
    Data.activityRedPosLogin[ACT_TYPE_119]=true
    Data.activityRedPosLogin[ACT_TYPE_120]=true
    Data.activityRedPosLogin[ACT_TYPE_30]=true
    Data.activityRedPosLogin[ACT_TYPE_121]=true
    Data.activityRedPosLogin[ACT_TYPE_122]=true
    Data.activityRedPosLogin[ACT_TYPE_123]=true
    Data.activityRedPosLogin[ACT_TYPE_124]=true
    Data.activityRedPosLogin[ACT_TYPE_1001]=true
    Data.activityRedPosLogin[ACT_TYPE_1002]=true

    Data.activityRedPosLogin[ACT_TYPE_97]=true
    Data.activityRedPosLogin[ACT_TYPE_98]=true

    Data.activityRedPosLogin[ACT_TYPE_92]=true
    Data.activityRedPosLogin[ACT_TYPE_93]=true
end

function Data.toint(data)
    for key, var in pairs(data) do
        data[key]=toint(var)
    end
end

function Data.initTowerParam()
    Data.towerInfo = {};
    Data.towerInfo.maxResetTimesToday = DB.getClientParam("TOWN_RESET_COUNT",true);
    Data.towerInfo.maxFloor = DB.getClientParam("TOWN_MAX_FLOOR",true); 
    Data.towerInfo.sweepPercent = DB.getClientParam("TOWN_SWEEP_PERCENT",true);
    -- Data.towerInfo.maxFloor = 15;
    -- Data.towerInfo.weatherAttrValue = DB.getClientParam("TOWER_ACTION_DOWN_ATTR",true)/100;
    TowerPanelData.guideIndex = -1;
end

function Data.initWorldBossParam()
    Data.worldBossParam.power_need_diamond = string.split(DB.getClientParam("WORLD_BOSS_POWER_NEED_DIAMOND"),";")--toint(DB.getClientParam("WORLD_BOSS_POWER_NEED_DIAMOND"));
    Data.toint(Data.worldBossParam.power_need_diamond)

    Data.worldBossParam.power_max = toint(DB.getClientParam("WORLD_BOSS_POWER_MAX"));
    Data.worldBossParam.power = toint(DB.getClientParam("WORLD_BOSS_POWER"));
    Data.worldBossParam.reborn_need_diamond = string.split(DB.getClientParam("WORLD_BOSS_REBORN_NEED_DIAMOND"),";")
    Data.toint(Data.worldBossParam.reborn_need_diamond)
    Data.worldBossParam.reborn_num = string.split(DB.getClientParam("WORLD_BOSS_REBORN_NUM"),";")
    Data.toint(Data.worldBossParam.reborn_num)
    Data.worldBossParam.fight_round = toint(DB.getClientParam("WORLD_BOSS_FIGHT_ROUND"));

    -- 新世界boss
    -- 新世界boss增加点数的时间点(0;4;8;12;16;20;24)
    Data.worldBossParam.add_cnum_time = string.split(DB.getClientParam("WORLD_BOSS_ADD_CNUM_TIME"),";")
    Data.toint(Data.worldBossParam.add_cnum_time)
    -- 新世界boss增加点数的参数(2,10)(每次增加点数;点数上限)
    Data.worldBossParam.add_cnum_params = string.split(DB.getClientParam("WORLD_BOSS_ADD_CNUM_PARAMS"),";")
    Data.toint(Data.worldBossParam.add_cnum_params)
    -- 新世界boss挑战点数购买次数(5;10;20;50)
    Data.worldBossParam.add_cnum_buy_num = string.split(DB.getClientParam("WORLD_BOSS_ADD_CNUM_BUY_NUM"),";")
    Data.toint(Data.worldBossParam.add_cnum_buy_num)
    -- 新世界boss挑战点数的费用(20;40;80;100)
    Data.worldBossParam.add_cnum_buy_price = string.split(DB.getClientParam("WORLD_BOSS_ADD_CNUM_BUY_PRICE"),";")
    Data.toint(Data.worldBossParam.add_cnum_buy_price)
    -- 新世界boss扫荡等级VIP3;战队等级50
    Data.worldBossParam.sweep_vip_lv = string.split(DB.getClientParam("WORLD_BOSS_SWEEP_VIP_LV"),";");
    Data.toint(Data.worldBossParam.sweep_vip_lv)
    -- 最大战斗购买次数
    Data.worldBossParam.add_cnum_buy_max = toint(DB.getClientParam("WORLD_BOSS_ADD_CNUM_BUY_MAX"));
end

function Data.initWeaponParam()
    WeaponChangeLv={}
    local temps= string.split(DB.getClientParam("WEAPON_CHANGE_LEVEL"),";")
    for key, var in pairs(temps) do
        WeaponChangeLv[key]=toint(var)
    end
    Data.cardRaiseMaxLevel= toint(DB.getClientParam("CARD_RAISE_MAX_LEVEL"));
    Data.treasureExchangeDias = DB.getClientParamToTable("TREASURE_EXCHANGE_DIAMOND",isToint)
end

function Data.initCardAwakeParam()
    Data.cardAwake = {}
    Data.cardAwake.lv = {}
    local temps= string.split(DB.getClientParam("CARD_WAKEN_CHANGE"),";")
    for key, var in pairs(temps) do
        Data.cardAwake.lv[key]=toint(var)
    end
    Data.cardAwake.needLv = toint(DB.getClientParam("CARD_WAKEN_REQUEST"));
    Data.cardAwake.maxLv = toint(DB.getClientParam("CARD_WAKEN_MAX"));
end

function Data.initShopParams()
    --TEMP:
    --将星商店
    -- gShops[SHOP_TYPE_SOUL] = {};
    -- gShops[SHOP_TYPE_SOUL].time = gGetCurServerTime()+1000000;
    -- gShops[SHOP_TYPE_SOUL].refreshTimes = 0;
    -- gShops[SHOP_TYPE_SOUL].type = SHOP_TYPE_SOUL;
    -- gShops[SHOP_TYPE_SOUL].items = {};

    --跨服商店
    gShops[SHOP_TYPE_SERVERBATTLE] = {};
    gShops[SHOP_TYPE_SERVERBATTLE].type = SHOP_TYPE_SERVERBATTLE;
    gShops[SHOP_TYPE_SERVERBATTLE].time = 0;
    gShops[SHOP_TYPE_SERVERBATTLE].refreshTimes = 0;
    gShops[SHOP_TYPE_SERVERBATTLE].items = {};
    for key,var in pairs(worldshop_db)do
        local item    = {};
        -- item.shopid   = var.id;
        item.itemid   = var.itemid;
        item.type     = SHOP_TYPE_SERVERBATTLE;
        item.num      = toint(var.itemnum);
        item.limitNum = toint(var.count);
        item.buyNum   = 0;
        item.price    = toint(var.price);
        item.costType = toint(var.priceid);
        -- item.pos   = toint(key);
        item.pos      = var.id;--特殊处理
        table.insert(gShops[SHOP_TYPE_SERVERBATTLE].items,item);
    end

    --情义商店
    gShops[SHOP_TYPE_EMOTION] = {};
    gShops[SHOP_TYPE_EMOTION].type = SHOP_TYPE_EMOTION;
    gShops[SHOP_TYPE_EMOTION].time = 0;
    gShops[SHOP_TYPE_EMOTION].refreshTimes = 0;
    gShops[SHOP_TYPE_EMOTION].items = {};
    -- { id=1 , itemid=42 , price=10 , num=1 , limitcount=20 ,},
    for key,var in pairs(emotionshop_db)do
        local item    = {};
        item.itemid   = var.itemid;
        item.type     = SHOP_TYPE_EMOTION;
        item.num      = toint(var.num);
        item.limitNum = toint(var.limitcount);
        item.buyNum   = 0;
        item.price    = toint(var.price);
        item.costType = (OPEN_BOX_EMOTION_MONEY);
        item.pos      = var.id;
        table.insert(gShops[SHOP_TYPE_EMOTION].items,item);
    end

    --夺宝商店
    gShops[SHOP_TYPE_SNATCH] = {}
    gShops[SHOP_TYPE_SNATCH].type = SHOP_TYPE_SNATCH;
    gShops[SHOP_TYPE_SNATCH].time = 0;
    gShops[SHOP_TYPE_SNATCH].refreshTimes = 0;
    gShops[SHOP_TYPE_SNATCH].items = {};

    --无尽之塔
    gShops[SHOP_TYPE_TOWER1] = {}
    gShops[SHOP_TYPE_TOWER1].type = SHOP_TYPE_TOWER1;
    gShops[SHOP_TYPE_TOWER1].time = 0;
    gShops[SHOP_TYPE_TOWER1].refreshTimes = 0;
    gShops[SHOP_TYPE_TOWER1].items = {};

    gShops[SHOP_TYPE_TOWER2] = {}
    gShops[SHOP_TYPE_TOWER2].type = SHOP_TYPE_TOWER2;
    gShops[SHOP_TYPE_TOWER2].time = 0;
    gShops[SHOP_TYPE_TOWER2].refreshTimes = 0;
    gShops[SHOP_TYPE_TOWER2].items = {};

    gShops[SHOP_TYPE_TOWER3] = {}
    gShops[SHOP_TYPE_TOWER3].type = SHOP_TYPE_TOWER3;
    gShops[SHOP_TYPE_TOWER3].time = 0;
    gShops[SHOP_TYPE_TOWER3].refreshTimes = 0;
    gShops[SHOP_TYPE_TOWER3].items = {};

    for key,var in pairs(townshop_db) do
        local item    = {};
        -- item.shopid   = var.id;
        item.itemid   = var.itemid;
        item.type     = SHOP_TYPE_TOWER1;
        item.num      = toint(var.num);
        item.limitNum = toint(var.buylimit);
        item.buyNum   = 0;
        item.price    = toint(var.price);
        item.costType = toint(var.ptype);
        item.pos      = var.id;--特殊处理
        item.unlockStar = toint(var.starlimit);
        local shoptype = toint(var.type);
        if(shoptype == 1) then
            table.insert(gShops[SHOP_TYPE_TOWER1].items,item);
        elseif(shoptype == 2)then
            table.insert(gShops[SHOP_TYPE_TOWER2].items,item);
        elseif(shoptype == 3)then
            table.insert(gShops[SHOP_TYPE_TOWER3].items,item);
        end
    end

    --军团热拍商店
    gShops[SHOP_TYPE_FAMILY_4] = {}
    gShops[SHOP_TYPE_FAMILY_4].type = SHOP_TYPE_FAMILY_4;
    gShops[SHOP_TYPE_FAMILY_4].time = 0;
    gShops[SHOP_TYPE_FAMILY_4].refreshTimes = 0;
    gShops[SHOP_TYPE_FAMILY_4].items = {};
    --星魂兑换商店
    gShops[SHOP_TYPE_CONSTELLATION] = {}
    gShops[SHOP_TYPE_CONSTELLATION].type = SHOP_TYPE_CONSTELLATION;
    gShops[SHOP_TYPE_CONSTELLATION].time = 0;
    gShops[SHOP_TYPE_CONSTELLATION].refreshTimes = 0;
    gShops[SHOP_TYPE_CONSTELLATION].items = {};
    for i = 1, 6 do
       local item = {}
       item.itemid = 0
       item.type = SHOP_TYPE_CONSTELLATION
       item.costType = OPEN_BOX_CONSTELLATION_SOUL
       item.price = 0
       item.num = 1
       item.pos = 0
       table.insert(gShops[SHOP_TYPE_CONSTELLATION].items,item);
    end
end

function Data.init7DayTaskParams()
    Data.task7Day = {};
    Data.task7Day.lefttime = 0;
    local taskid1 = DB.getClientParamToTable("SEVEN_DAY_TASK_ID1",true);
    local taskid2 = DB.getClientParamToTable("SEVEN_DAY_TASK_ID2",true);
    Data.task7Day.taskid = {};
    for key,var in pairs(taskid1) do
        table.insert(Data.task7Day.taskid,var);
    end
    for key,var in pairs(taskid2) do
        table.insert(Data.task7Day.taskid,var);
    end
end

function Data.initRedposParams()
    Data.redpos = {};
    Data.redpos.act97 = {}
    Data.redpos.act98 = {}
    Data.redpos.bolNewTask = false;
    Data.redpos.bol7DayTask = {};
    for i=1,7 do
        Data.redpos.bol7DayTask[i] = false;
    end
    Data.redpos.bol7DayTaskLabel = {};
    for i=1,4 do
        Data.redpos.bol7DayTaskLabel[i] = false;
    end

    Data.redpos.bolActivityDayTaskCanGet = false;
    Data.redpos.bolActivityDayTask = {};
    for i=1,7 do
        Data.redpos.bolActivityDayTask[i] = false;
    end
end

function Data.initLevelUp()
    Data.levelup = {};

    --命魂
    local xunxian = DB.getSpiritStartLev();
    for key,var in pairs(xunxian) do
        if(toint(key) >= 3)then
            local ret = {};
            ret.unlocktype = SYS_XUNXIAN;
            ret.id = key - 2;
            ret.level = var;
            -- print("key = ".."unlock_item"..ret.unlocktype..".._name"..ret.id);
            ret.name = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_name"..ret.id);
            ret.content = gGetWords("unlockWords.plist","unlock_item36_content");
            table.insert(Data.levelup,ret);
        end
    end

    --金币试炼
    for key=2,4 do
        local ret = {};
        ret.unlocktype = SYS_ACT_GOLD;
        ret.id = key - 1;
        local data = DB.getActStageInfoById(2,key);
        ret.level = data.level;
        ret.name = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_name"..ret.id);
        ret.content = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_content"..ret.id);
        table.insert(Data.levelup,ret);
    end

    --经验试炼
    for key=2,4 do
        local ret = {};
        ret.unlocktype = SYS_ACT_EXP;
        ret.id = key - 1;
        local data = DB.getActStageInfoById(3,key);
        ret.level = data.level;
        ret.name = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_name"..ret.id);
        ret.content = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_content"..ret.id);
        table.insert(Data.levelup,ret);
    end

    --兽魂试炼
    for key=2,4 do
        local ret = {};
        ret.unlocktype = SYS_ACT_PETSOUL;
        ret.id = key - 1;
        local data = DB.getActStageInfoById(4,key);
        ret.level = data.level;
        ret.name = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_name"..ret.id);
        ret.content = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_content"..ret.id);
        table.insert(Data.levelup,ret);
    end

    --器皿试炼
    for key=2,4 do
        local ret = {};
        ret.unlocktype = SYS_ACT_EQUSOUL;
        ret.id = key - 1;
        local data = DB.getActStageInfoById(11,key);
        ret.level = data.level;
        ret.name = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_name"..ret.id);
        ret.content = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_content"..ret.id);
        table.insert(Data.levelup,ret);
    end

    --灵兽
    -- local pets = DB.getClientParamToTable("PET_UNLOCK_LEVEL");
    local index = 1;
    for key,pet in pairs(pet_db) do
        if(index>1)then
            local ret = {};
            ret.unlocktype = SYS_PET;
            ret.id = index-1;
            ret.level = pet.unlocklevel;
            ret.unlocksoul = toint(pet.unlocksoul);
            ret.petid = pet.petid;
            ret.name = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_name"..ret.id);
            ret.content = gGetWords("unlockWords.plist","unlock_item"..ret.unlocktype.."_content"..ret.id);
            table.insert(Data.levelup,ret);
        end
        index = index + 1;
    end

    local sortlevel = function(d1,d2)
        return toint(d1.level) < toint(d2.level);
    end
    table.sort( Data.levelup, sortlevel );
-- print("Data.levelup");
-- print_lua_table(Data.levelup);

end

function Data.initClentParam()
    Data.initTowerParam();
    Data.initCardAwakeParam();
    Data.initWeaponParam()
    Data.initModuleUnLockLevel()
    Data.initFamilyParams();
    Data.initActAtlasParams();
    Data.initSignInParams();
    Data.initIconParams();
    Data.initMailParams();
    Data.initFriendParams();
    Data.initBuyEnergyParams();
    Data.initTaskParams();
    Data.initArenaParams();
    Data.initActivityParams();
    Data.initActInvestCanBeGot();
    Data.initActLvUpCanBeGot();
    Data.initAct7DayCanBeGot();
    Data.initBathParams();
    Data.initTrainRoomParams();
    Data.initPetParams();
    Data.initDrawCardParams();
    Data.initShopParams();
    Data.initWorldBossParam();
    Data.init7DayTaskParams();
    Data.initRedposParams();
    Data.initLevelUp();
    Data.initUserParams();
    Data.initPetTowerParams();
    Data.initAtlasParams()
    Data.initRedPackParams();
    Data.initPetCaveParams();
    Net.initLootFoodClientParams();

end

function Data.initRedPackParams()
    Data.redpackInfo = {}
    Data.redpackInfo.endTime = 0;
end

function Data.initPetCaveParams()
    Data.petCave = {};
    Data.petCave.openLv = DB.getClientParam("CAVE_OPEN_LV",true);--灵兽窟开放等级(70)
    Data.petCave.oneKeyOpenLv = DB.getClientParam("CAVE_ONEKEY_SWEEP_LV",true);--一键探索开启等级(80)
    Data.petCave.dayNum = DB.getClientParam("CAVE_GO_DAY_NUM",true);--每日可以探索的次数(27次)
    Data.petCave.restDiaNums = DB.getClientParamToTable("CAVE_RESET_COIN_DIAMOND",true);--重置所需钻石数(0;20;40;60)
    Data.petCave.chessMuls = DB.getClientParamToTable("CAVE_CHESS_MUL",true);--斜,横,竖.全不同
    Data.petCave.eventCardRewards = DB.getClientParamToTable("CAVE_EVENT1_REWARD_WIN_LOSE_ITEMID",true);--翻牌奖励

    Data.petCave.eventAnimalItemId = DB.getClientParamToTable("CAVE_EVENT3_ITEM_IDS",true);--考古得到的物品id
    Data.petCave.eventAnimalItemNum = DB.getClientParamToTable("CAVE_EVENT3_ITEM_NUMS",true);--考古得到的物品id

    Data.petCave.eventDiamond = DB.getClientParamToTable("CAVE_EVENT4_DIAMOND",true);--神奇宝箱砖石
    
    Data.petCave.resetCoinNums = DB.getClientParamToTable("CAVE_RESET_COIN_NUM",true);--重置次数(3;6;8;9999)
    Data.petCave.resetCoinDiamond = DB.getClientParamToTable("CAVE_RESET_COIN_DIAMOND",true);--/重置所需钻石数(0;20;40;60)

    Data.petCave.caveRewardTime = DB.getClientParam("CAVE_EVENT3_GET_REWARD_TIME",true);--领取时间
    

end

function Data.initAtlasParams()
    local maxNum=DB.getClientParam("STAGE_MAX_ID",true)
    if(maxNum~=0)then
        MAX_ATLAS_NUM=maxNum
    end
end

function Data.initPetTowerParams()
    Data.petTower = {};
    Data.petTower.sweepprice = DB.getClientParamToTable("PET_ATLAS_BUY_PRICE",true);
    Data.petTower.sweepFinishprice = DB.getClientParam("PET_ATLAS_SWEEP_FINISH_PRICE",true);
end

function Data.initSysRecord()
    print ("Data.initSysRecord")
    gSysEffectClose = cc.UserDefault:getInstance():getBoolForKey("effect",false);
    gSysMusicClose = cc.UserDefault:getInstance():getBoolForKey("music",false);
    gSysVideoClose = cc.UserDefault:getInstance():getBoolForKey("video",false);
    gSysVoiceClose = cc.UserDefault:getInstance():getBoolForKey("voice",false);

    gSysSet = {};
    for i=1,7 do
        local value = cc.UserDefault:getInstance():getBoolForKey("set"..i,true);
        table.insert(gSysSet,value);
    end

    gSysDeleteMail = cc.UserDefault:getInstance():getBoolForKey("deletemail",false);
    if( ccs.ArmatureDataManager.setSoundPlay)then
        ccs.ArmatureDataManager:getInstance():setSoundPlay(not gSysEffectClose)
    end
    --gSetVideo();
    if(gDebug)then
        gShowMapName = not gSysVideoClose;
    end
end

function Data.saveEffect(effect)
    cc.UserDefault:getInstance():setBoolForKey("effect",effect);
end

function Data.saveMusic(music)
    cc.UserDefault:getInstance():setBoolForKey("music",music);
end

function Data.saveVideo(video)
    cc.UserDefault:getInstance():setBoolForKey("video",video);
end

function Data.saveVoice(voice)
    cc.UserDefault:getInstance():setBoolForKey("voice",voice);
end

function Data.saveSet(index,value)
    cc.UserDefault:getInstance():setBoolForKey("set"..index,value);
end

function Data.saveDeleteMail(delete)
    cc.UserDefault:getInstance():setBoolForKey("deletemail",delete);
end

function Data.saveLanguageSet(lan)
    gCurLanguage = lan;
    cc.UserDefault:getInstance():setIntegerForKey("language",lan);
end

function Data.saveBoolConfig(key,value)
    cc.UserDefault:getInstance():setBoolForKey(key,value);
end

function Data.getBoolConfig(key)
    return cc.UserDefault:getInstance():getBoolForKey(key);
end


function Data.getSaleOffDataByDetid(id)
    for key, var in pairs( Data.activitySaleOffData.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.get26DataByDetid(id)
    for key, var in pairs( Data.activity26Data.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getExchangeDataByDetid(id)
    for key, var in pairs( Data.activityExchangeData.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityPayByDetid(id)
    for key, var in pairs( Data.activityPayData.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityWeekGiftInfoByDetid(id)
    for key, var in pairs( Data.activityWeekGiftInfo.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityChargeReturnByDetid(id)
    for key, var in pairs( Data.activityChargeReturn.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityShareByShareid(id)
    for key, var in pairs( Data.activityShare.list) do
        if(var.id==id)then
            return var
        end
    end
    return nil
end

function Data.getActivity17id(id)
    for key, var in pairs( Data.activity17Data.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivity28id(id)
    for key, var in pairs( Data.activityHolidaySign.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.updateActivity29ItemBuyNum(detid,count)
    for key, var in pairs( Data.activityInfo29.list) do
        if(var.idx==detid)then
           var.count = count
           break;
        end
    end
    return nil
end

function Data.getActivity19id(id)
    for key, var in pairs( Data.activity19Data.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivity23id(stall)
    for key, var in pairs( Data.activityFreeVipData.list) do
        if(var.stall==stall)then
            return var
        end
    end
    return nil
end

function Data.getActivity93id(id)
    for key, var in pairs( Data.activityRecruitData.list) do
        if(var.id==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityExpenseReturnByDetid(id)
    for key, var in pairs( Data.activityExpenseReturnData.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityTuanByDetid(id)
    for key, var in pairs( Data.activityTuanData.list) do
        if(var.idx==id)then
            return var
        end
    end
    return nil
end

function Data.getActivityByType(type)
    for key, var in pairs(Data.activityAll) do
        if(var.type==type)then
            return var
        end
    end
    return nil

end

function Data.isShowAct81hd()
    local hdShowBtnkip = false
    if Data.activity81.stime and Data.activity81.etime then
        local curtime = gGetCurServerTime()
        if curtime > Data.activity81.stime and curtime < Data.activity81.etime then
            if Data.getCurVip() >= Data.activity81.param1 or Data.getCurLevel() >= Data.activity81.param2 then
                hdShowBtnkip = true
            end
        end
    end
    return hdShowBtnkip
end



--解锁等级
function Data.initModuleUnLockLevel()
    gUnlockLevel = {};
    -- gUnlockLevel.family = DB.getClientParam("FAMILY_REQUEST_LEVEL");
    gUnlockLevel[SYS_FAMILY] = DB.getClientParam("FAMILY_REQUEST_LEVEL");
    gUnlockLevel[SYS_ARENA] = DB.getClientParam("ARENA_OPEN_LV");
    gUnlockLevel[SYS_SHOP] = DB.getClientParam("SHOP_OPEN_LV");
    gUnlockLevel[SYS_ELITE_ATLAS] = DB.getClientParam("ATLAS_ELITE_REQUEST_LEVEL");
    gUnlockLevel[SYS_BOSS_ATLAS] = DB.getClientParam("CARD_WAKEN_REQUEST");
    gUnlockLevel[SYS_TURN_GOLD] = DB.getClientParam("TURN_GOLD_REQUEST_LEVEL");
    gUnlockLevel[SYS_TASK] = DB.getClientParam("TASK_REQUEST_LEVEL");
    gUnlockLevel[SYS_SKILL] = DB.getClientParam("SKILL_UPGRADE_REQUEST_LEVEL");
    gUnlockLevel[SYS_FRIEND] = DB.getClientParam("BUDDY_REQUEST_LEVEL");
    gUnlockLevel[SYS_CHAT] = DB.getClientParam("BUDDY_REQUEST_LEVEL");
    gUnlockLevel[SYS_ACT_GOLD] = DB.getClientParam("ACT_GOLD_REQUEST_LEVEL");
    gUnlockLevel[SYS_ACT_EXP] = DB.getClientParam("ACT_EXP_REQUEST_LEVEL");
    gUnlockLevel[SYS_ACT_PETSOUL] = DB.getClientParam("ACT_PETSOUL_REQUEST_LEVEL");
    gUnlockLevel[SYS_PET_TOWER] = DB.getClientParam("PET_TOWER_REQUEST_LEVEL");
    gUnlockLevel[SYS_PET] = DB.getClientParam("PET_REQUEST_LEVEL");
    -- gUnlockLevel[SYS_BATTLE_SPEEDUP] = DB.getClientParamToTable("BATTLE_SPEEDUP_REQUEST_LEVEL");
    gUnlockLevel[SYS_PET_SKILL] = DB.getClientParam("PET_SKILL_UPGRADE_REQUEST_LEVEL");
    gUnlockLevel[SYS_PET_STAR] = DB.getClientParam("PET_STAR_UPGRADE_SOUL_NUM");
    --gUnlockLevel[SYS_ATLAS_BOX] = DB.getClientParam("ATLAS_BOX_STAR_NUM");
    gUnlockLevel[SYS_BATH] = DB.getClientParam("BATH_REQUEST_LEVEL");
    gUnlockLevel[SYS_TRAINROOM] = DB.getClientParam("DRINK_REQUEST_LEVEL");
    --gUnlockLevel[SYS_BATTLE_AUTO] = DB.getClientParam("BATTLE_AUTO_FIGHT_LEVEL");
    gUnlockLevel[SYS_CRUSADE] = DB.getClientParam("CRUSADE_REQUEST_LEVEL");
    gUnlockLevel[SYS_XUNXIAN] = toint(DB.getSpiritStartLev()[1])
    gUnlockLevel[SYS_MINE] = DB.getClientParam("MINING_OPEN_LV");
    gUnlockLevel[SYS_WEAPON] = DB.getClientParam("WEAPON_OPEN_LV");
    gUnlockLevel[SYS_SHOP_SOUL] = DB.getClientParam("EVIL_MAP_OPEN_LV");
    gUnlockLevel[SYS_WORLD_BOSS] = DB.getClientParam("WORLD_BOSS_OPEN_LV");
    gUnlockLevel[SYS_SERVER_BATTLE] = DB.getClientParam("WORLD_WAR_REQUEST_LEVEL");
    gUnlockLevel[SYS_TREASURE_RISESTAR] = DB.getClientParam("TREASURE_STAR_OPEN_LV");
    gUnlockLevel[SYS_PET_CAVE] = DB.getClientParam("CAVE_OPEN_LV",true);

    gUnlockLevel[SYS_ACT_ITEM_AWAKE] = 1
    local data=DB.getActStageInfoById(16,1)
    if(data)then
        gUnlockLevel[SYS_ACT_ITEM_AWAKE] = data.level
    end

    gCurGuide = -1;
    gUnlockSys = {};

    gUnlockLevel.posLevel = DB.getClientParamToTable("TEAM_POS_LEVEL");
    table.insert(gUnlockLevel.posLevel,gUnlockLevel[SYS_PET]);

end

function Data.getSysIsUnlock(sysid)
    for key,var in pairs(gUnlockSys) do
        if var == sysid then
            return true;
        end
    end
    return false;
end

function Data.getSysIsEnter(sysid)
    for key,var in pairs(gEnterSys) do
        if var == sysid then
            return true;
        end
    end
    return false;
end

function Data.getCardRaiseAttrMax(card)
    local ret={}
    local db=DB.getCardById(card.cardid)
    ret[Attr_HP] =db.raise_hp_max
    ret[Attr_PHYSICAL_ATTACK] =db.raise_atk_max
    ret[Attr_PHYSICAL_DEFEND] =db.raise_pdef_max
    ret[Attr_MAGIC_DEFEND] =db.raise_mdef_max

    for i=1, card.weaponLv do
        local levelData=DB.getCardRaiseByLevel(card.cardid,i)
        if(levelData)then
            ret[Attr_HP] =ret[Attr_HP] + levelData.hp_max_add
            ret[Attr_PHYSICAL_ATTACK] =ret[Attr_PHYSICAL_ATTACK] + levelData.atk_max_add
            ret[Attr_PHYSICAL_DEFEND] =ret[Attr_PHYSICAL_DEFEND] + levelData.pdef_max_add
            ret[Attr_MAGIC_DEFEND] =ret[Attr_MAGIC_DEFEND] + levelData.mdef_max_add
        end
    end

    return ret
end

function Data.getTownFloorStar(floor)
    local star = 0;
    -- print(">>>>floor");
    -- print_lua_table(Data.towerInfo.stagestar);
    for key,var in pairs(Data.towerInfo.stagestar) do
        if(math.floor((toint(key)-1) / 3) + 1 == toint(floor))then
            -- print("add star = "..Data.towerInfo.stagestar[key]);
            star = star + Data.towerInfo.stagestar[key]
        end
    end
    return star;
end

--个人信息
function Data.getCurName()
    return gUserInfo.name;
end
function Data.getCurUserId()
    if(gUserInfo.id==nil)then
        return 0
    end
    return gUserInfo.id;
end
function Data.getCurLevel()
    return gUserInfo.level;
end
function Data.getCurIconFrame()
    return gUserInfo.icon_frame;
end
function Data.convertToIcon(icon)
    return math.mod(icon,100000);
end
function Data.getCurIcon()
    return gUserInfo.icon;
end

function Data.getCurWeapon()
    local card=Data.getUserCardById(gUserInfo.icon)
    if(card)then
        return card.weaponLv
    end
    return nil
end

function Data.getCurAwake()
    local card=Data.getUserCardById(gUserInfo.icon)
    if(card)then
        return card.awakeLv;
    end
    return nil
end

--是否腾讯渠道
function Data.bolTencent()
    if (Module.isClose(SWITCH_HALO)) then return false end
    if Unlock.isUnlock(SYS_HALO,false) == false then
        return false;
    end
    local bol = false
    if (gAccount:getPlatformId() == CHANNEL_ANDROID_TENCENT) then
        bol = true
    end
    return bol;
end

function Data.getCurHalo()
    --如果不是应用宝 renturn 0
    if (not Data.bolTencent()) then return 0 end
    return gUserInfo.halo;
end

function Data.getCurFrame()
    return gUserInfo.frame;
end
function Data.getCurArenaRank()
    return gUserInfo.arenarank;
end

function Data.getCurDia()
    return gUserInfo.diamond;
end

function Data.getCurGold()
    return gUserInfo.gold;
end

function Data.getCurRepuNum()
    return gUserInfo.repuNum;
end

function Data.getCurCardExp()
    return gUserInfo.cexp;
end

function Data.getCurVip()
    if not gUserInfo.fevip_vip or not gUserInfo.fevip_endtime then
        return gUserInfo.vip
    end

    if gUserInfo.fevip_endtime > 0
    and gUserInfo.fevip_endtime > gGetCurServerTime()
    and gUserInfo.vip < gUserInfo.fevip_vip then
        return gUserInfo.fevip_vip
    end

    return gUserInfo.vip;
end

function Data.getCurVipScore()
    return gUserInfo.vipsc;
end

function Data.getCurEnergy()
    -- body
    return gUserInfo.energy;
end

function Data.getCurPetSoul()
    -- body
    return gUserInfo.petPoint;
end

function Data.getCurPetMoney()
    return gUserInfo.petMoney;
end

function Data.getSnatchScore()
    local score = 0
    if (Data.activitySnatchData.score) then
        score = Data.activitySnatchData.score
    end
    return score
end


function Data.getCurSoulMoney()
    return gUserInfo.cstar;
end

function Data.hasFamily()
    if gFamilyInfo.familyId ~= 0 then
        return true;
    end
    return false;
end

--个人贡献(货币)
function Data.getCurFamilyExp()
    if Data.hasFamily() then
        return gFamilyInfo.iMemexp;
    end
    return 0;
end

function Data.updateCurFamilyExp(fexp)
    local offsetExp = fexp - gFamilyInfo.iMemexp;
    gFamilyInfo.iMemexp = fexp;
    -- print("offsetExp = "..offsetExp);
    -- gFamilyInfo.iMemexp = gFamilyInfo.iMemexp + offsetExp;
    -- gFamilyInfo.iMemexp = math.max(gFamilyInfo.iMemexp,0);
    if offsetExp > 0 and gFamilyMemList then
        gFamilyInfo.iExp = gFamilyInfo.iExp + offsetExp;
        gFamilyInfo.iDayExp = gFamilyInfo.iDayExp + offsetExp;
        gFamilyInfo.weekexp = gFamilyInfo.weekexp + offsetExp;

        for key,mem in pairs(gFamilyMemList) do
            if mem.uid == Data.getCurUserId() then
                mem.iDayExp = gFamilyInfo.iDayExp;
                break;
            end
        end

        gDispatchEvt(EVENT_ID_FAMILY_REFRESH_INFO);
    end

    -- if showGetTip and offsetExp > 0 then
    --     gShowItemPoolLayer:pushOneItem({id=OPEN_BOX_FAMILY_DEVOTE,num=offsetExp});
    -- end

    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE);
end

function Data.getCurFamilyLevel()
    -- body
    return gFamilyInfo.iLevel;
end

function Data.getCurFamilyType()
    return gFamilyInfo.iType;
end
function Data.isFamilyManager()
    local type = Data.getCurFamilyType();
    if type == 1 or type == 2 then
        return true;
    end
    return false;
end

function Data.isFirstPay()
    return gUserInfo.iapbuy <= 0;
end

function Data.getCurFirstcg()
    return gUserInfo.firstcg;
end

--军团参数
function Data.initFamilyParams()
    Data.family = {};
    Data.family.eggFExp = DB.getClientParam("FAMILY_KNOCK_EGG_EXP");
    Data.family.sevenFExp = DB.getClientParam("FAMILY_SEVEN_EXP");
    Data.family.springCallFExp = DB.getClientParam("FAMILY_CALL_SPRING_EXP");
    Data.family.springDrinkFExp = DB.getClientParam("FAMILY_DRINK_SPRING_EXP");
    Data.family.maxLevel = DB.getClientParam("FAMILY_LEVEL_MAX");
    Data.family.donateRestTimes = DB.getClientParamToTable("FAMILY_DONATE_RESET_ASK_TIME",true)
    Data.family.donateAllAskTime = DB.getClientParam("FAMILY_DONATE_ASK_TIME")


    Data.family.dynamic = {};
    Data.family.exprank = {};

    Data.family.shop3Data = {};
    for key,var in pairs(familylvreward_db) do
        local data = {};
        data.lv = var.id;
        data.items = cjson.decode(var.reward);
        table.insert(Data.family.shop3Data,data);
    end
    local familyMailLimit = DB.getClientParamToTable("FAMILY_MAIL_LIMIT_DATA",true);
    gFamilyEamilTitleCount = familyMailLimit[1];
    gFamilyEamilContentCount = familyMailLimit[2];
    gFamilyNoticeCount = DB.getClientParam("FAMILY_NOTICE_LENGTH");
    gFamilySloganCount = DB.getClientParam("FAMILY_DEC_LENGTH");
    gFamily.createNeedDia = DB.getClientParam("FAMILY_CREATE_DIAMOND");
    gFamily.createNeedGold = DB.getClientParam("FAMILY_CREATE_GOLD");

    gFamilyInfo.module = {};
    for i=1,2 do
        table.insert(gFamilyInfo.module,{id = i,unlock_level = 1});
    end
    -- gFamilyInfo

    local costItemId = DB.getClientParamToTable("FAMILY_WOOD_CURRENCY_TYPE");
    local costItemNum = DB.getClientParamToTable("FAMILY_WOOD_CURRENCY_VALUE");
    local getExpNum = DB.getClientParamToTable("FAMILY_WOOD_EXP");
    local getFamilyExp = DB.getClientParamToTable("FAMILY_DRUM_EXP");
    gFamilyInfo.contribution = {};
    for i = 1,3 do
        local contribution = {};
        contribution.type = i;
        -- contribution.wood = 0;
        -- contribution.fexp = 0;
        contribution.constItemId = toint(costItemId[i]);
        contribution.costItemNum = costItemNum[i];
        contribution.getExp = toint(getExpNum[i]);
        contribution.getFamilyExp = toint(getFamilyExp[i]);
        local rewardItems = DB.getClientParamToTable("FAMILY_WOOD_REWARD"..i);
        contribution.items={}
        local itemnum = table.count(rewardItems)
        if itemnum>=2 then
            for i=1,itemnum/2 do
                contribution.items[rewardItems[i*2-1]] = rewardItems[i*2]
            end
        end
        
        table.insert(gFamilyInfo.contribution,contribution);
    end

    gFamilySpringInfo.callDiamond = DB.getClientParam("FAMILY_SPING_CALL_DIAMOND");

    gFamilyInfo.mobai_price = DB.getClientParam("FAMILY_WORSHIP_PRICE");
    gFamilyInfo.mobai_num = DB.getClientParam("FAMILY_WORSHIP_NUM");
    gFamilyInfo.mobai_eng_get = DB.getClientParam("FAMILY_WORSHIP_ENG");

    for kye,update in pairs(familyupgrade_db) do
        for k,v in pairs(familymembertypeinfo_db) do
            if(toint(update.id) == toint(v.level))then
                if(toint(v.membertype) == 2)then
                    update.memType2 = v.maxnum;
                elseif(toint(v.membertype) == 3)then
                    update.memType3 = v.maxnum;
                elseif(toint(v.membertype) == 4)then
                    update.memType4 = v.maxnum;
                end
            end
        end
    end
end

--试炼场参数
function Data.initActAtlasParams()
    gActAtlasInfo = {};
    gActAtlasInfo.clearCdNeddDia = DB.getClientParam("ACT_STAGE_CLEAR_CD_PRICE");
end

--签到
function Data.initSignInParams()
    Data.signInfo = {}; -- 签到

    --累计签到奖励
    Data.signInfo.reward = {};
    local days = DB.getClientParamToTable("SIGN_COUNT_REWARD_DAY");
    -- local itemids = DB.getClientParamToTable("SIGN_COUNT_REWARD_ITEMID");
    -- local itemnums = DB.getClientParamToTable("SIGN_COUNT_REWARD_ITEMNUM");

    for i=1,3 do
        table.insert(Data.signInfo.reward,{day=toint(days[i]),itemid=toint(0),itemnum=toint(0),bolGet = false});
    end
end

function Data.initIconParams()
    UserChangeIconPanel.data.vip = DB.getClientParam("ICON_FRAME_VIP");
    UserChangeIconPanel.data.arenaRank = DB.getClientParam("ICON_FRAME_ARENA");
-- UserChangeIconPanel.initData();
end

function Data.initMailParams()
    Data.mail = {};
    Data.mail.list  = {};
    Data.mail.familymaillist = {};
end

function Data.updateRelation(data)
    gRelations[data.id]=data.level
end

function Data.getRelationLevelById(id)
    local level=gRelations[id]

    if(level==nil)then
        level=0
    end
    return level
end

function Data.initFriendParams()
    Data.friend = {};
    Data.friend.maxSignCount = DB.getClientParam("FAMILY_DEC_LENGTH");
    Data.friend.maxGiveCount = DB.getClientParam("BUDDY_GIVE_MAX");
    Data.friend.maxFriendCount = 0;--DB.getClientParam("BUDDY_MAX_COUNT");
    Data.friend.maillist = {};
    Data.friend.gettime = 0;
    Data.friend.maillength = DB.getClientParam("CHAT_WORLD_LENGTH");
    Data.friend.fightlv = DB.getClientParam("PK_REQUEST_LEVEL",true);
end


function Data.initBuyEnergyParams()
    Data.buyEnergy = {};
    Data.buyEnergy.maxHp = DB.getClientParam("ENERGY_MAX_BUY");
    Data.buyEnergy.reeat_diamond = DB.getClientParam("ENERGY_REEAT_DIAMOND");
    Data.buyEnergy.exchangeHp = DB.getItemData(ITEM_HP).param;

end

function Data.initTaskParams()
    Data.task = {};
    Data.task.getEnergyTime = {};
    for i = 1,3 do
        local ret = {};
        ret.time = DB.getClientParamToTable("DAYENG_TIME"..i);
        ret.hasGet = false;
        table.insert(Data.task.getEnergyTime,ret);
    end
end
function Data.initArenaParams()
    Data.arena = {};
    Data.arena.maxTimes = DB.getClientParam("ARENA_ADD_TIMES");
    Data.arena.clearCDDia = DB.getClientParam("ARENA_CLEAR_CD_COST");
end
function Data.initUserParams()
    Data.halo_price = DB.getClientParamToTable("ROLE_HALO_PRICE");
    Data.toint(Data.halo_price)
    Data.halo_buffid = DB.getClientParamToTable("ROLE_HALO_BUFFID");
    Data.toint(Data.halo_buffid)
    Data.halo_buffid2 = DB.getClientParamToTable("ROLE_HALO_BUFFID2");
    Data.toint(Data.halo_buffid2)
end
function Data.initActivityParams()
    Data.activity = {};
    Data.activity.fundNeedDia = DB.getClientParam("FUND_NEED_DIAMOND");

    Data.activity.cat_diamond_price = DB.getClientParamToTable("CAT_DIAMOND_PRICE");
    Data.activity.cat_diamond_max = DB.getClientParamToTable("CAT_DIAMOND_MAX");

    Data.activity.vip_get_level = DB.getClientParamToTable("ACT_GET_VIP_LEVEL");
    Data.activity.vip_get = DB.getClientParamToTable("ACT_GET_VIP");

    Data.activity.wish_retime = DB.getClientParam("WISH_RESTORE_TIME");
    Data.activity.wish_max = DB.getClientParam("WISH_DAY_MAX");

    Data.activity.bun_box_click_num = DB.getClientParamToTable("BUN_BOX_CLICK_NUM");
    Data.toint(Data.activity.bun_box_click_num)
    Data.activity.bun_box_id = DB.getClientParamToTable("BUN_BOX_ID");
    Data.toint(Data.activity.bun_box_id)
    Data.activity.bun_eat_click_max = DB.getClientParam("BUN_EAT_CLICK_MAX");
    Data.activity.bun_eat_time = DB.getClientParam("BUN_EAT_TIME");

    Data.activity.free_vip_need_acoin = DB.getClientParamToTable("ACT_23_NEED_ACOIN");
    Data.toint(Data.activity.free_vip_need_acoin)
    Data.activity.free_vip_need_vip = DB.getClientParamToTable("ACT_23_NEED_VIP");
    Data.toint(Data.activity.free_vip_need_vip)
    Data.activity.free_vip_rec_vipscore = DB.getClientParamToTable("ACT_23_REC_VIPSCORE");
    Data.toint(Data.activity.free_vip_rec_vipscore)
    Data.activity.free_vip_item_id = DB.getClientParamToTable("ACT_23_ITEM_ID");
    Data.toint(Data.activity.free_vip_item_id)

    Data.activity.recruit_mate_reward = DB.getClientParamToTable("RECRUIT_MATE_REWARD");
    Data.toint(Data.activity.recruit_mate_reward)

    Data.activity.recruit_max_num = DB.getClientParam("RECRUIT_MAX_NUM");
end
function Data.initBathParams()

    -- gBathNumOneDay = readNodeElement(6512);
    -- gBathMolestNumOneDay = readNodeElement(6513);--打劫次数
    -- gBathFinish = readNodeElement(6514);
    -- gBathRewardTimes = readNodeArray(6515);
    -- gBathRewardRepu = readNodeArray(6516);
    -- gBathRewardGold = readNodeArray(6517);
    -- gBathRewardPercent = readNodeElement(6518);
    -- gBathRefreshOneDay = readNodeElement(6526);
    -- gBathRefreshNeedDia = readNodeElement(6520);
    -- gBathRefreshLastNeedDia = readNodeElement(6521);
    -- gBathAddPercent = readNodeElement(6527);
    -- gBathAddPercentNeedDia = readNodeElement(6522);
    -- gBathAddPercentTimes = readNodeElement(6528);
    -- gBathMolestTimes = readNodeElement(6529);--被打劫次数
    -- gBathCallNeedDia = readNodeElement(6533);
    -- gBathCallTime = readNodeElement(6534);
    -- gBathCallGetRepu = readNodeElement(6530);
    -- gBathCallAddPercent = readNodeElement(6531);
    -- gBathCallAllAddPercent = readNodeElement(6519);

    gBathInfo = {};
    gBathInfo.all_uid = 0;
    gBathInfo.all_time = 0;
    gBathInfo.show = {};
    Data.bath = {};
    Data.bath.gBathNumOneDay = DB.getClientParam("BATH_NUM");
    Data.bath.gBathMolestNumOneDay = DB.getClientParam("BATH_MOLEST_NUM");
    Data.bath.gBathFinish = DB.getClientParam("BATH_FINISH_DIAMOND");
    Data.bath.gBathRewardTimes = DB.getClientParamToTable("BATH_TIME",true);
    Data.bath.gBathRewardRepu = DB.getClientParamToTable("BATH_REPU_REWARD",true);
    Data.bath.gBathRewardGold = DB.getClientParamToTable("BATH_GOLD_REWARD",true);
    Data.bath.gBathRewardGold2 = DB.getClientParamToTable("BATH_GOLD_REWARD2",true);
    Data.bath.gBathRewardPercent = DB.getClientParam("BATH_MOLEST_RATE");
    Data.bath.gBathRefreshOneDay = DB.getClientParam("BATH_REF_NUM");
    Data.bath.gBathRefreshNeedDia = DB.getClientParam("BATH_REF1_DIAMOND");
    Data.bath.gBathRefreshLastNeedDia = DB.getClientParam("BATH_REF2_DIAMOND");
    Data.bath.gBathAddPercent = DB.getClientParam("BATH_ATTR_RATE");
    Data.bath.gBathAddPercentNeedDia = DB.getClientParam("BATH_ATTR_DIAMOND");
    Data.bath.gBathAddPercentTimes = DB.getClientParam("BATH_ATTR_NUM");
    Data.bath.gBathMolestTimes = DB.getClientParam("BATH_BEMOLEST_NUM");
    Data.bath.gBathCallNeedDia = DB.getClientParam("BATH_ALL_DIAMOND");
    Data.bath.gBathCallGetRepuMax = DB.getClientParam("BATH_CALL_ADD_REPU_MAX");
    Data.bath.gBathCallTime = DB.getClientParam("BATH_ALL_TIME");
    Data.bath.gBathCallGetRepu = DB.getClientParam("BATH_ALL_REPU");
    Data.bath.gBathCallAddPercent = DB.getClientParam("BATH_ALL_OTHER_RATE");
    Data.bath.gBathCallAllAddPercent = DB.getClientParam("BATH_ALL_ADD_RATE");
    Data.bath.gBathRewardItems = cjson.decode(DB.getClientParam("BATH_REWARD"));
end

function Data.initTrainRoomParams()
    Data.trainroom = {};
    Data.trainroom.myselfInfo = {};--自己的相关信息
    Data.trainroom.roomList = {};
    Data.trainroom.seatList = {};--魔鬼训练房当前房间的位置信息
    -- Data.trainroom.room

    Data.trainroom.freeTimesOneDay = DB.getClientParam("DRINK_LOOT_NUM"); --喝花酒每日免费抢夺次数
    Data.trainroom.baseExp = DB.getClientParam("DRINK_BASE_EXP");
    Data.trainroom.addExp = DB.getClientParam("DRINK_ADD_EXP");
    Data.trainroom.protectTimes = DB.getClientParamToTable("DRINK_PROTECT_TIME");
    Data.trainroom.protectNeedDias = DB.getClientParamToTable("DRINK_PROTECT_DIAMOND");

    local roomOpenId = 3;
    Data.trainroom.roomOpen = {};
    for key,var in pairs(drinkroom_db) do
        if (var.roomid > 2) then
            local isAdded = false;
            for k,v in pairs(Data.trainroom.roomOpen) do
                if v.minlv == var.minlv and v.maxlv == var.maxlv then
                    isAdded = true;
                    break;
                end
            end

            if (not isAdded) then
                local ret = {};
                ret.minlv = var.minlv;
                ret.maxlv = var.maxlv;
                ret.roomOpenId = roomOpenId;
                table.insert(Data.trainroom.roomOpen,ret);
                roomOpenId = roomOpenId + 1;
            end
        end
    end
    -- print_lua_table(Data.trainroom.roomOpen);
end

function Data.initPetParams()
    Data.pet = {};
    Data.pet.topFloor = 0;
    Data.pet.needExp = DB.getClientParamToTable("PET_UPGRADE_EXP_ARRAY");
    Data.pet.maxLevel = DB.getClientParam("PET_MAX_LEVEL");
    Data.pet.skilAniLevel = DB.getClientParam("PET_UPDATE_PASS_ANI_LV");

    Data.pet.stRepConsts = DB.getClientParamToTable("PET_ST_REPLACE_NEED_ITEM",true);--普通;专属
    Data.pet.possessOpenlv = DB.getClientParam("PET_POSSESS_OPEN_LV",true);-- //灵兽附身开放等级(70)
    Data.pet.possessAddRate = DB.getClientParam("PET_POSSESS_UP_PARAM",true);-- //附身提供15%灵兽基础属性
    Data.pet.talentOpenlv = DB.getClientParam("PET_TALENT_OPEN_LV",true);
    Data.pet.stDiamondTable = DB.getClientParamToTable("PET_ST_DIAMOND_EXP",true);--//灵兽特殊天赋元宝悟性(50;100)
    Data.pet.freeSt = DB.getClientParam("PET_FREE_ST",true);--//3  宠物默认特殊天赋孔数
    Data.pet.addStTypeTable = DB.getClientParamToTable("PET_ADD_ST_TYPE",true);-- //[1;1;1;2;3]//宠物特殊天赋,增加空数条件  类型为1:星数,2,觉醒,3:等级
    Data.pet.addSTValueTable = DB.getClientParamToTable("PET_ADD_ST_VALUE",true);-- //[3;4;5;1;100] //增加孔数条件数值
    Data.pet.firstBingTable= DB.getClientParamToTable("PET_FIRST_BINGO",true);--//首次中sss级技能次数范围 (200;220)
    Data.pet.bingRangeTable= DB.getClientParamToTable("PET_BINGO_RANGE",true);--//首次之后中sss级技能次数范围 (300;320)

    local stExpTable=DB.getClientParamToTable("PET_ST_ITEM_GET_EXP",true)--//灵兽特殊天赋消耗道具产生的悟性
    Data.pet.talentExpTable={}
    for i=1,table.count(stExpTable)/3 do
        local ltable = {itemid=stExpTable[(i-1)*3+1],const=stExpTable[(i-1)*3+2],exp=stExpTable[(i-1)*3+3]}
        table.insert(Data.pet.talentExpTable,ltable)
    end

    Data.pet.learnExpTable=DB.getClientParamToTable("PET_ST_LEARN_EXP",true)--//灵兽特殊天赋消耗道具产生的悟
    Data.pet.learnLockExpTable=DB.getClientParamToTable("PET_ST_LEARN_EXP_LOCK",true)
    Data.pet.learnShardTable = DB.getClientParamToTable("PET_ST_LEARN_SHARD",true);

    gShops[SHOP_TYPE_PET] = {};
    gShops[SHOP_TYPE_PET].items = Data.shopSort(DB.getPetShopItems());

end

function Data.initDrawCardParams()
    Data.drawCardParams = {};
    Data.drawCardParams.price_soul_refresh = DB.getClientParam("DARW_SOUL_REFRESH_DIAMOND");
    Data.drawCardParams.price_soul_buy = DB.getClientParam("DRAW_SOUL_BOX");
    Data.drawCardParams.maxLuck = DB.getClientParam("SOUL_DRAW_LUCKY_MAX",true);
    Data.drawCardParams.drawLuckCardNum = DB.getClientParam("SOUL_DRAW_LUCKY_CARD_NUM",true);
    --排序
    for key,var in pairs(soulboxshardinfo_db) do
        local db=DB.getCardById(var.cardid)
        if(db) then
            var.evolve = db.evolve;
        end
    end

    local sortfunc = function(card1,card2)
        if(card1.iflight > card2.iflight) then
            return true;
        else
            if(card1.evolve > card2.evolve)then
                return true;
            end
        end
        return false;
    end
    --table.sort(soulboxshardinfo_db,sortfunc);

end

function Data.shopSort(items)
    --武将碎片、道具、材料、材料碎片 进行排序。
    for key,item in pairs(items) do
        item.itemType = DB.getItemType(item.itemid);
        item.sort = 10;
        if item.itemType == ITEMTYPE_CARD_SOUL then
            item.sort = 0;
        elseif item.itemType == ITEMTYPE_ITEM then
            item.sort = 1;
        elseif item.itemType == ITEMTYPE_EQU then
            item.sort = 2;
        elseif item.itemType == ITEMTYPE_EQU_SHARED then
            item.sort = 3;
        end
    end

    local sortfunc = function(item1,item2)
        if item1.sort < item2.sort then
            return true;
        end
        return false;
    end

    table.sort(items,sortfunc);
    return items;
end

function Data.buyTrainLootTimes()
    Data.vip.trainloot.setUsedTimes(Data.trainroom.myselfInfo.buyTimes);
    local callback = function(num)
        Net.sendDrinkBuy(num);
    end
    Data.canBuyTimes(VIP_TRAINROOM_LOOT,true,callback);
end

--计算已经获得的经验
function Data.getExpInTrainRoom()
    if Data.trainroom.myselfInfo.curRoomId > 0 then
        local data = DB.getTrainRoom(Data.trainroom.myselfInfo.curRoomId);
        local addLevelExp = Data.trainroom.baseExp+math.floor(Data.getCurLevel()/10)*Data.trainroom.addExp;
        local endTime = math.min(gGetCurServerTime(),Data.trainroom.myselfInfo.curEndtime);
        local diffTime = math.max(endTime - Data.trainroom.myselfInfo.curBegintime,0);
        local addTime = data.getexptime;
        local count = math.floor(diffTime / addTime);
        local addExpPercent = data.getexppercent;
        --至尊位置
        if Data.trainroom.myselfInfo.curRoomId > ROOM_VIP and
            Data.trainroom.myselfInfo.curSeatIndex == ADVANCED_SEAT_INDEX then
            addExpPercent = data.specialpercent;
        end

        -- print("beginTim = "..Data.trainroom.info.begintime);
        -- print("endTim = "..Data.trainroom.info.endtime);
        -- print("diffTime = "..diffTime);

        local addExp = addLevelExp * count * addExpPercent * addTime/60 / 100 ;
        return math.floor(addExp);
    end
    return 0;
end
--每分钟获得经验值
function Data.getExpPerMin(roomid,isAdvancedSeat)
    print("roomid = "..roomid);
    local data = DB.getTrainRoom(roomid);
    if(data == nil)then
        return;
    end
    local addLevelExp = Data.trainroom.baseExp+math.floor(Data.getCurLevel()/10)*Data.trainroom.addExp;
    local addExpPercent = data.getexppercent;
    if(isAdvancedSeat) then
        addExpPercent = data.specialpercent;
    end
    -- local count = 1;
    -- local addTime = data.getexptime;
    local addExp = addLevelExp * addExpPercent / 100 ;
    print("addExp = "..addExp);
    return math.floor(addExp);
end
--判断是否在该房间
function Data.isInTrainRoom(roomid)
    if toint(roomid) == Data.trainroom.myselfInfo.curRoomId and Data.trainroom.myselfInfo.curEndtime > gGetCurServerTime() then
        return true;
    end
    return false;
end
--判断是否有坐下
function Data.isInTraining()
    if Data.trainroom.myselfInfo.curRoomId > 0 and Data.trainroom.myselfInfo.curEndtime > gGetCurServerTime() then
        return true;
    end
    return false;
end
function Data.sendSitDown(roomid,seatindex)

    if (NetErr.isBelongRoom(roomid) == false) then
        return;
    end

    if Data.isInTraining() then
        local callback = function()
            Net.sendDrinkDrink(roomid,seatindex);
        end
        gConfirmCancel(gGetWords("trainWords.plist","change_desk"),callback);
    else
        Net.sendDrinkDrink(roomid,seatindex);
    end
end
--坐下
function Data.sitdown(roomid,seatindex)

    --先删除改位置的数据
    for key,var in pairs(Data.trainroom.seatList) do
        if var.didx == seatindex then
            table.remove(Data.trainroom.seatList,key);
            break;
        end
    end

    if Data.isInTrainRoom(roomid) then
        --已经在该房间了 就是换位置
        --换位置
        for key,var in pairs(Data.trainroom.seatList) do
            if var.uid == Data.getCurUserId() then
                var.didx = seatindex;
                var.ptime = 0;
                var.ptype = 0;
                break;
            end
        end
    else
        --没有在该房间 就是坐下
        local var = {};
        var.didx = seatindex;
        var.uid = Data.getCurUserId();
        var.uname = Data.getCurName();
        var.icon = Data.getCurIconFrame();
        var.lv = Data.getCurLevel();
        var.fname = "";
        var.ptime = 0;
        var.ptype = 0;
        var.show = {};
        var.show.wlv = Data.getCurWeapon();
        var.show.wkn = Data.getCurAwake();
        var.show.hlv = gUserInfo.honor;
        var.show.halo = Data.getCurHalo();
        table.insert(Data.trainroom.seatList,var);
    end

    Data.trainroom.myselfInfo.curRoomId = roomid;
    Data.trainroom.myselfInfo.curSeatIndex = seatindex;
end

function Data.updateMyselfInfo(begintime,endtime,roomid,seatindex,buy,loot)

    if begintime ~= nil then
        Data.trainroom.myselfInfo.curBegintime = begintime;
    end

    if endtime ~= nil then
        Data.trainroom.myselfInfo.curEndtime = endtime;
    end

    if roomid ~= nil then
        Data.trainroom.myselfInfo.curRoomId = roomid;
    end

    if seatindex ~= nil then
        Data.trainroom.myselfInfo.curSeatIndex = seatindex;
    end

    if buy ~= nil then
        Data.trainroom.myselfInfo.buyTimes = buy;
    end

    if loot ~= nil then
        Data.trainroom.myselfInfo.leftLootTimes = loot;
    end

    print_lua_table(Data.trainroom.myselfInfo);
end

function Data.addTrainSeat(data)
    local oldSeatInx = -1;
    local newSeatIndex = data.didx;
    for key,var in pairs(Data.trainroom.seatList) do
        print("var.didx = "..var.didx)
        if var.uid == data.uid then
            print("replace");
            oldSeatInx = var.didx
            table.remove(Data.trainroom.seatList,key);
        -- var = data;
        -- return oldSeatInx,newSeatIndex;
        end
    end

    table.insert(Data.trainroom.seatList,data);

    return oldSeatInx,newSeatIndex;
end

function Data.getGiftBagBuy(id)
    for key, item in pairs(gGiftBagBuy) do
        if(item.itemid==toint(id))then
            return item
        end
    end
    return nil
end

function Data.addGiftBagBuy(itemid,num)
    for key, item in pairs(gGiftBagBuy) do
        if(item.itemid==itemid)then
            item.num=item.num+1
            return
        end
    end
    local item={itemid=itemid,num=num}
    table.insert(gGiftBagBuy,item)
end



--添加好友
function Data.addMyFriend(obj)
    if(obj==nil)then
        return
    end
    if(gFriend.myFriends==nil)then
        gFriend.myFriends={}
    end
    table.insert(gFriend.myFriends,obj)
end

function Data.addBlackFriend(obj)
    if(gFriend.blackList ==nil)then
        gFriend.blackList ={}
    end
    table.insert(gFriend.blackList ,obj)
end

--删除好友
function Data.removeMyFriend(uid)
    if(gFriend.myFriends==nil)then
        return
    end
    for key, friend in pairs(gFriend.myFriends) do
        if(friend.uid==uid)then
            gFriend.myFriends[key]=nil
            return
        end
    end
end

function Data.removeMyFriendGive(uid)
    if(gFriend.myFriends==nil)then
        return
    end
    for key, friend in pairs(gFriend.myFriends) do
        if(friend.uid==uid)then
            friend.giveme=false
        end
    end
    -- if(gFriend.gives==nil)then
    --     return
    -- end
    -- for key, give in pairs(gFriend.gives) do
    --     if(give.uid==uid)then
    --         gFriend.gives[key]=nil
    --         return
    --     end
    -- end
end

function Data.removeMyFriendGiveAll()
    if(gFriend.myFriends==nil)then
        return
    end
    for key, friend in pairs(gFriend.myFriends) do
        friend.giveme=false
    end
end

function Data.revMyFriendGive(uid)
    if(gFriend.myFriends==nil)then
        return
    end
    for key, friend in pairs(gFriend.myFriends) do
        if(friend.uid==uid)then
            friend.give=true
        end
    end
end

function Data.revMyFriendGiveAll()
    if(gFriend.myFriends==nil)then
        return
    end
    for key, friend in pairs(gFriend.myFriends) do
        friend.give=true
    end
end
--删除黑名单
function Data.removeBlackFriend(uid)
    if(gFriend.blackList==nil)then
        return
    end
    for key, friend in pairs(gFriend.blackList) do
        if(friend.uid==uid)then
            gFriend.blackList[key]=nil
            return
        end
    end
end
--邀请列表删除
function Data.removeFriendInvite(uid)

    for key, invite in pairs(gFriend.inviteList) do
        if(invite.uid==uid)then
            gFriend.inviteList[key]=nil
            return
        end
    end
end

function Data.clearWorldChat()
    gChats.world = {}
end
--过滤黑名单聊天
function Data.isInBlackList(userid)
    if(gFriend == nil or gFriend.blackList == nil)then
        return false;
    end
    for key,friend in pairs(gFriend.blackList) do
        if(friend.uid == userid)then
            return true;
        end
    end
    return false;
end

function Data.addWorldChat(data)
    if(gChats.world==nil)then
        gChats.world={}
    end

    if(Data.isInBlackList(data.uid))then
        return;
    end

    if(table.getn(gChats.world)>49) then
        table.remove(gChats.world,1)
    end
    table.insert(gChats.world,data)
    gChats.dirty = true
    -- print("+++++++++++");
    -- print("Data.addWorldChat");
    -- print_lua_table(data);
end

function Data.getWorldChats()
    return gChats.world
end

function Data.clearFamilyChat()
    gChats.family = {}
end

function Data.addFamilyChat(data)
    if(gChats.family==nil)then
        gChats.family={}
    end
    if(table.getn(gChats.family)>49) then
        table.remove(gChats.family,1)
    end
    table.insert(gChats.family,data)
end

function Data.getFamilyChats()
    return gChats.family
end

function Data.addSystemChat(data)
    if(gChats.system==nil)then
        gChats.system={}
    end
    if(table.getn(gChats.system)>49) then
        table.remove(gChats.system,1)
    end
    table.insert(gChats.system,data)
end

function Data.getSystemChats()
    return gChats.system
end

function Data.getFriendChats(id)
    if(gChats.friend==nil)then
        return nil

    end
    if(gChats.friend[id]==nil)then
        return nil
    end
    return gChats.friend[id]
end


function Data.addRecentChatRole(uid,name,icon,vip)
    print("Data.addRecentChatRole...")
    if(gChats.recent==nil)then
        gChats.recent={}
    end
    gChats.recent[uid]={uid=uid,name=name,icon=icon,vip=vip}
end

function Data.addFriendChat(data)
    if(gChats.friend==nil)then
        gChats.friend={}
    end

    if(gChats.friend[data.uid]==nil)then
        gChats.friend[data.uid]={}
    end

    if(Data.isInBlackList(data.uid))then
        return;
    end

    if(table.getn(gChats.friend[data.uid])>49) then
        table.remove(gChats.friend[data.uid],1)
    end
    table.insert(gChats.friend[data.uid],data)
end



function Data.getBuyGoldNum()
    -- local totalCount=Data.getMaxUseTimes(VIP_STONEGOLD)--DB.getMaxBuyGoldNum(gUserInfo.vip)
    -- local leftcount = totalCount - Data.getUsedTimes(VIP_STONEGOLD);
    -- print("leftcount = "..leftcount.." totalCount = "..totalCount);
    -- return leftcount--Data.remainBuyGoldNum
    return Data.getUsedTimes(VIP_STONEGOLD);
end


function Data.isFirstEnterAtlas(mapid,stageid,type)
    return Data.getAtlasStar(mapid,stageid,type)==0
end

function Data.getAtlasStar(mapid,stageid,type)
    local ret=Data.getAtlasStatus(mapid,stageid,type)
    if(ret==false)then
        return 0
    end
    return ret.num
end


function Data.getAtlasBox(mapid,boxidx,type)
    for key, box in pairs(gAtlas.box) do
        if(box.mapid==mapid  and box.type==type) then
            box["rec"..boxidx]=true
            return
        end
    end

    local obj={}
    obj.mapid=mapid
    obj.type=type
    obj["rec"..boxidx]=true
    table.insert(gAtlas.box,obj)
end


function Data.hasAtlasGetBox(mapid,boxidx,type)
    for key, box in pairs(gAtlas.box) do
        if(box.mapid==mapid and box.type==type) then
            return box["rec"..boxidx]==true
        end
    end
    return false
end

function Data.updateAtlas(newStar)


    for key, star in pairs(gAtlas.star) do
        if(star.mapid==newStar.mapid and   star.stageid==newStar.stageid and    star.type==newStar.type)then
            if(newStar.num>star.num)then
                gAtlas.star[key]=newStar
            else
                star.batNum=newStar.batNum
            end
            return
        end
    end

    table.insert(gAtlas.star,newStar)

end


function Data.getCurAtlasStar(mapid,type)
    local ret=0
    for key, star in pairs(gAtlas.star) do
        if(star.mapid==mapid   and    star.type==type)then
            ret=ret+star.num
        end
    end
    return ret
end


function Data.isNewStage(mapid,stageid,type)
    local _mapid,_stageid=Data.getNewAtlasStage(type)

    if(mapid==_mapid and stageid==_stageid)then
        return true
    end

    return false
end


--当前map 是不是都通关了
function Data.isCurAtlasMapPass(type,mapid)

    local maxMapid=gAtlas["maxMap"..type]

    if(mapid)then
        maxMapid=mapid
    end

    if(maxMapid<gAtlas["maxMap"..type])then
        return true
    end

    if(maxMapid>gAtlas["maxMap"..type])then
        return false
    end

    local totalStageNum=DB.getAtlasStageNum(maxMapid,type)

    if(gAtlas["maxStage"..type]>=totalStageNum   )then
        return true
    end

    return false
end

--能不能进入下一章
function Data.canEnterNextAtlasMap(type,mapid,notice)

    local chapter=DB.getChapterById(mapid,type)
    if(chapter and chapter.level>gUserInfo.level)then
        if(notice)then

            if(chapter.level==15 and Data.isCurAtlasMapPass(type,mapid-1))then
                Panel.popUpVisible(PANEL_ALTAS_NOTICE)
            else
                gShowNotice(gGetWords("noticeWords.plist","chapter_need_level",chapter.level))
            end
        end
        return false
    end

    if(Data.isCurAtlasMapPass(type,mapid)==false)then
        return false
    end
    return true

end



function Data.getNewAtlasStage(type)
    local maxMapid=gAtlas["maxMap"..type]
    local maxStageid=gAtlas["maxStage"..type]+1
    local totalStageNum=DB.getAtlasStageNum(maxMapid,type)

    if(gAtlas["maxStage"..type]>=totalStageNum   )then
        maxMapid= maxMapid+1
        maxStageid=1
    end
    local realMapid=maxMapid

    local chapter=DB.getChapterById(gAtlas["maxMap"..type]+1,type)
    if(chapter and chapter.level>gUserInfo.level)then
        maxMapid=gAtlas["maxMap"..type]
    end

    if(maxMapid>MAX_ATLAS_NUM)then
        maxMapid=MAX_ATLAS_NUM
    end
    if(maxMapid<=1)then
        maxMapid=1
    end
    return maxMapid,maxStageid,realMapid
end


function Data.updateAtlasStatus(atlas,batNum)
    local data=Data.getAtlasStatus(atlas.mapid,atlas.stageid,atlas.type)
    if(data==false)then
        return
    end
    data.batNum=batNum
    return data
end


function Data.getAtlasBatNum(atlas)
    local data=Data.getAtlasStatus(atlas.mapid,atlas.stageid,atlas.type)
    if(data==false)then
        return 0
    end
    return data.batNum
end


function Data.isPassAtlas(mapid,stageid,type)
    local passMapid=gAtlas["maxMap"..type]
    local passStageid=gAtlas["maxStage"..type]

    if(passStageid==nil or passMapid==nil)then
        return false
    end

    if(mapid<passMapid  )then
        return true
    end

    if(mapid>passMapid)then
        return false
    end

    return passStageid>=stageid
end


function Data.canAtlasFight7(mapid,stageid,type)


    local stage7= Data.getMaxStageNode(mapid,stageid,type)
    local stage1= Data.getMaxStageNode(gAtlas["maxMap1"],gAtlas["maxStage1"],1)

    if(stage1==nil or stage7==nil)then
        return false
    end


    if(stage7.map_id*100+ stage7.node>stage1.map_id*100+stage1.node)then
        return false
    end
    return true

end



function Data.canAtlasFight1(mapid,stageid,type)

    if(Unlock.isUnlock(SYS_ELITE_ATLAS,false)==false)then
        return false
    end

    local stage1= Data.getMaxStageNode(mapid,stageid,type)
    local stage0= Data.getMaxStageNode(gAtlas["maxMap0"],gAtlas["maxStage0"],0)

    if(stage0==nil or stage1==nil)then
        return false
    end


    if(stage1.map_id*100+ stage1.node>stage0.map_id*100+stage0.node)then
        return false
    end
    return true
end


function Data.canAtlasFight(mapid,stageid,type)
    if(type==0)then
        return true
    elseif(type==1)then
        return  Data.canAtlasFight1(mapid,stageid,type)
    elseif(type==7)then
        return  Data.canAtlasFight7(mapid,stageid,type)
    end

end

function Data.getMaxStageNode(mapid,stageid,type)
    local stage=nil
    for key, var in pairs(stage_db) do
        if( var.type==type )then
            if( var.map_id== mapid and var.stage_id==stageid )then
                if(var.node~=0 and var.islast~=2)then
                    return var
                end
                return stage
            end

            if(var.node~=0)then
                stage=var
            end
        end
    end
    return stage

end



function Data.getAtlasStatus(mapid,stageid,type)

    if(gAtlas["maxMap"..type]==nil)then
        gAtlas["maxMap"..type]=0
    end

    if(gAtlas["maxStage"..type]==nil)then
        gAtlas["maxStage"..type]=0
    end
    if(mapid>gAtlas["maxMap"..type]+1  )then--跨度2个章节跳过
        return false
    end

    if(mapid==gAtlas["maxMap"..type]+1  )then --最后一关解锁下一关
        local totalStageNum=DB.getAtlasStageNum(mapid-1,type)
        if(gAtlas["maxStage"..type]>=totalStageNum and  stageid==1 )then
        else
            return false
        end
    end

    local chapter=DB.getChapterById(mapid,type)
    if(chapter and chapter.level>gUserInfo.level)then
        return false
    end


    if( mapid==gAtlas["maxMap"..type]  and stageid>gAtlas["maxStage"..type]+1)then
        return false
    end

    for key, star in pairs(gAtlas.star) do
        if(star.mapid==mapid and   star.stageid==stageid and    star.type==type)then
            return star
        end
    end

    return {num=0,batNum=ATLAS_SWEEP_REAMIN_TIME,buyNum=0}

end

--装备是否可获取
function Data.canGetForEquip(itemid)
    local atlas=DB.getStageByItemId(itemid)
    for key, data in pairs(atlas) do

        local ret=Data.getAtlasStatus(data.map_id,data.stage_id,data.type)
        if(ret~=false)then
            local temp=Data.canAtlasFight(data.map_id,data.stage_id,data.type)
            if(temp==nil or temp==false )then
                ret=false
            end
        end

        if(ret~=false)then
            return true;
        end
    end

    return false;
end

function Data.getBuyGoldNeedDia(  count)
    local ret = 0
    local buyNum=Data.getBuyGoldNum()
    for i=1, count do
        local turnGold=DB.getTurnGoldById(buyNum+i)
        if(turnGold)then
            ret=ret+ turnGold.diamond
        end
    end
    return ret
end

function Data.getBuyGoldReward(  count)
    local ret = 0
    local buyNum=Data.getBuyGoldNum()
    local param1=DB.getBuyGoldParam1()
    local param2=DB.getBuyGoldParam2()
    for i=1, count do
        local turnGold=DB.getTurnGoldById(buyNum+i)
        if(turnGold)then
            ret=ret+( param1 +  gUserInfo.level*param2)* ( turnGold.ratio/100)
        end
    end
    return toint( ret)
end

function Data.sortUserCard()
    local sortHasFunc = function(a, b)
        return a.sort > b.sort
    end

    for key, user in pairs(gUserCards) do
        if(user.power==nil)then
            user.power=0
        end
        user.sort=user.level*100000000+ user.power
        user.cache=false
    end

    table.sort(gUserCards, sortHasFunc)
    for key, var in pairs(gUserCards) do
        if(key<=6)then
            var.cache=true
        end
    end
end

function Data.getUserTeam(type)
    type=Data.parseTeamType(type)
    for key, var in pairs(gUserTeams) do
        if(var.type==type)then
            return var.card
        end
    end

    return {}
end

function Data.parseTeamType(type)


    if(type==TEAM_TYPE_BATH_MOLEST or
        type== TEAM_TYPE_DRINK_LOOT or
        type== TEAM_TYPE_BUDDY_FIGHT or
        type==TEAM_TYPE_FAMILY_FIGHT or
        type== TEAM_TYPE_LOOT_FOOD or
        type== TEAM_TYPE_LOOT_FOOD_REVENGE)then

        type=TEAM_TYPE_ARENA_ATTACK
    end
    return type
end
function Data.isTeamChange(card1,card2)
    for i=0, MAX_TEAM_NUM-1  do
        if(card1[i]~=card2[i])then
            return true
        end
    end
    return false
end

function Data.saveUserTeam(type,cards,petid)
    type=Data.parseTeamType(type)
    for key, var in pairs(gUserTeams) do
        if(var.type==type)then
            if(Data.isTeamChange(var.card,cards)==true)then
                var.card=cards
                Net.sendSaveTeam(type,cards)
            end
            return
        end
    end

    local item={}
    item.type=type
    item.card=cards
    table.insert(gUserTeams,item)
    Net.sendSaveTeam(type,cards)
end

function Data.getCardPosInTeam(cardID)
    for key, var in pairs(gUserTeams) do
        for i = 1, #var.card do
            if var.card[i] == cardID then
                return i
            end
        end
    end

    return -1
end

function Data.getEquipItemNum(id)
    for key, var in pairs(gUserEquipItems) do
        if(var.itemid==id)then
            return var.num
        end
    end

    return 0
end

function Data.addEquipItemNum(id,num)
    for key, var in pairs(gUserEquipItems) do
        if(var.itemid==id)then
            var.num=var.num+num
            return
        end
    end

    local item={}
    item.itemid=id
    item.num=num
    table.insert(gUserEquipItems,item)

end

function Data.getSharedNum(id)
    for key, var in pairs(gUserShared) do
        if(var.itemid==id)then
            return var.num
        end
    end

    return 0
end

function Data.getItemNum(itemid)
    --矿石资源
    local isMineType = Data.isMineItem(itemid)
    if isMineType then
        return gDigMine.getMineItemNum(itemid)
    end

    local  type=  DB.getItemType(itemid)
    if(type==ITEMTYPE_ITEM or type==ITEMTYPE_BOX)then
        for key, var in pairs(gUserItems) do
            if(var.itemid==itemid)then
                return var.num
            end
        end
    elseif(type==ITEMTYPE_EQU)then
        return Data.getEquipItemNum(itemid)
    elseif(type==ITEMTYPE_EQU_SHARED)then
        return Data.getSharedNum(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_CARD_SOUL)then
        return Data.getSoulsNumById(itemid-ITEM_TYPE_SHARED_PRE)

    elseif(type==ITEMTYPE_PET_SOUL)then
        return Data.getPetSoulsNumById(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_CONSTELLATION)then
        return gConstellation.getConstellationItemNum(itemid)
    elseif(itemid==OPEN_BOX_DIAMOND )then
        return gUserInfo.diamond

    elseif(itemid==OPEN_BOX_ENERGY )then
        return gUserInfo.energy
    elseif(itemid==OPEN_BOX_PETMONEY)then
        return gUserInfo.petMoney
    elseif(itemid==OPEN_BOX_GOLD )then
        return gUserInfo.gold
    elseif(itemid==OPEN_BOX_SPIRIT_EXP )then
        return SpiritInfo.exp
    elseif(type==ITEMTYPE_TREASURE) then
        return Data.getTreasureNum(itemid)
    elseif(type==ITEMTYPE_TREASURE_SHARED)then
        return Data.getTreasureSharedNum(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_SPIRIT) then
        return SpiritInfo.getFraCount()
    elseif(itemid==OPEN_BOX_PET_SOUL )then
        return Data.getCurPetSoul()
    elseif(itemid==OPEN_BOX_EQUIP_SOUL )then
        return gUserInfo.equipSoul
    elseif(itemid==OPEN_BOX_CARDEXP_ITEM )then
        return Data.getCurCardExp()
    elseif(itemid==OPEN_BOX_SOULMONEY )then
        return Data.getCurSoulMoney()
    elseif(itemid==OPEN_BOX_FAMILY_MONEY)then
        return gUserInfo.famoney
    elseif(itemid==OPEN_BOX_CONSTELLATION_SOUL)then
        return gConstellation.getSoulNum()
    end
    return 0
end


function Data.reduceSoulNum(id,num)
    for key, var in pairs(gUserSouls) do
        if(var.itemid==id)then
            if(var.num<num)then
                gUserSouls[key]=nil
            else
                var.num=var.num-num
            end
            var.needRefresh = true;
            return
        end
    end

end
function Data.reduceItemNum(id,num)
    for key, var in pairs(gUserItems) do
        if(var.itemid==id)then
            if(var.num<num)then
                gUserItems[key]=nil
            else
                var.num=var.num-num
            end
            return
        end
    end
    if id==OPEN_BOX_DIAMOND then
       gUserInfo.diamond=gUserInfo.diamond - num
       return
    end
    gDigMine.reduceItemNum(id,num)
end

function Data.addItemNum(id,num)
    for key, var in pairs(gUserItems) do
        if(var.itemid==id)then
            var.num=var.num+num
            return
        end
    end

    local item={}
    item.itemid=id
    item.num=num
    table.insert(gUserItems,item)
end


function Data.reduceSharedNum(id,num)
    for key, var in pairs(gUserShared) do
        if(var.itemid==id)then
            if(var.num<num)then
                gUserShared[key]=nil
            else
                var.num=var.num-num
            end
            return
        end
    end

end


function Data.getTreasureByType(type)
    local ret={}
    for key, var in pairs(gUserTreasure) do
        if(var.cardid==0 and  var.db and var.db.type==type)then
            table.insert(ret,var)
        end
    end
    return ret
end

function Data.getTreasureBySuit( suit,type)
    local items={}
    for key, var in pairs(gUserTreasure) do
        if(var.cardid==0 and  var.db and  var.db.suitid==suit and  var.db.type==type)then
            table.insert(items,var)
            var.temp=var.quenchLevel+var.upgradeLevel
        end
    end

    local function sortFunc(item1,item2)
        return item1.temp>item2.temp
    end
    table.sort(items,sortFunc)
    return items[1]
end

function Data.removeTreasureById(id)
    for key, var in pairs(gUserTreasure) do
        if(var.id==id)then
            gUserTreasure[key]=nil
        end
    end

    return nil
end

function Data.getTreasureByCardId(id)
    local ret={}
    for key, var in pairs(gUserTreasure) do
        if(var.cardid==id)then
            table.insert(ret,var)
        end
    end

    return ret
end



function Data.getTreasureById(id)
    for key, var in pairs(gUserTreasure) do
        if(var.id==id)then
            return var
        end
    end

    return nil
end

function Data.updateTreasureById(treasure)
    for key, var in pairs(gUserTreasure) do
        if(var.id==treasure.id)then
            var.id=treasure.id
            var.itemid=treasure.itemid
            var.cardid=treasure.cardid
            var.upgradeLevel=treasure.upgradeLevel
            var.decomposeGold=treasure.decomposeGold
            var.quenchLevel=treasure.quenchLevel
            var.quenchExp=treasure.quenchExp
            var.starlv=treasure.starlv
            var.starexp=treasure.starexp
            var.starpoint=treasure.starpoint
            for k,buff in pairs(treasure.buffList) do
                var.buffList[k].sid = buff.sid
                var.buffList[k].slv = buff.slv
            end
            break
        end
    end
end


function Data.getTreasureByItemId(id)
    for key, var in pairs(gUserTreasure) do
        if(var.itemid==id)then
            return var
        end
    end

    return nil
end

function Data.getTreasureNum(itemid)
    local num = 0
    for key, var in pairs(gUserTreasure) do
        if(var.itemid==itemid)then
            num = num +1
        end
    end
    return num
end


function Data.reduceTreasureSharedNum(itemid,num)
    for key, var in pairs(gUserTreasureShared) do
        if(var.itemid==itemid)then
            var.num=var.num-num
            if(var.num<=0)then
                gUserTreasureShared[key]=nil
            end
            return
        end
    end
end

function Data.getTreasureSharedNum(itemid)
    for key, var in pairs(gUserTreasureShared) do
        if(var.itemid==itemid)then
            return var.num
        end
    end
    return 0
end

function Data.getTreasureShared(id)
    for key, var in pairs(gUserTreasureShared) do
        if(var.id==id)then
            return var
        end
    end

    return nil
end



function Data.getShared(id)
    for key, var in pairs(gUserShared) do
        if(var.itemid==id)then
            return var
        end
    end

    return nil
end

function Data.getEquipItem(id)
    for key, var in pairs(gUserEquipItems) do
        if(var.itemid==id)then
            return var
        end
    end

    return nil
end

function Data.updateUserPet(pet)
    for key, var in pairs(gUserPets) do
        if(var.petid==pet.petid)then
            for type, value in pairs(pet) do
                var[type]=pet[type]
            end
            return
        end
    end

    table.insert(gUserPets,pet)

end

function Data.getSoulsNumById(id)
    for key, var in pairs(gUserSouls) do
        if(var.itemid==id)then
            return var.num
        end
    end

    return 0
end

function Data.getUserSoul(id)
    for key, var in pairs(gUserSouls) do
        if(var.itemid==id)then
            return var;
        end
    end
    return nil;
end

function Data.getPetSoulsNumById(id)
    for key, var in pairs(gUserPetSouls) do
        if(var.itemid==id)then
            return var.num
        end
    end

    return 0
end

function Data.getPetSouls(id)
    for key, var in pairs(gUserPetSouls) do
        if(var.itemid==id)then
            return var
        end
    end
    return nil
end



function Data.setSoulsNum(id,num)
    for key, var in pairs(gUserSouls) do
        if(var.itemid==id)then
            var.num=num
            var.needRefresh = true;
        end
    end

end

function Data.getSouls(id)
    for key, var in pairs(gUserSouls) do
        if(var.itemid==id)then
            return var
        end
    end
    return nil
end



function Data.getSoulsNeedNumById(id)
    for key, var in pairs(gUserSouls) do
        if(var.itemid==id)then
            return var.num
        end
    end

    return 0
end

function Data.getUserItemById(id)
    for key, var in pairs(gUserItems) do
        if(var.itemid==id)then
            return var
        end
    end

    for _,var in pairs(gDigMine.userMineItems) do
        if(var.itemid==id)then
            return var
        end
    end

    return nil
end

function Data.checkNum()

    for i=#gUserItems, 1, -1 do
        if (gUserItems[i].num==0) then
            table.remove(gUserItems, i)
        end
    end

    for i=#gUserEquipItems, 1, -1 do
        if (gUserEquipItems[i].num==0) then
            table.remove(gUserEquipItems, i)
        end
    end

    for i=#gUserSouls, 1, -1 do
        if (gUserSouls[i].num==0) then
          --  table.remove(gUserSouls, i)
        end
    end

    for i=#gUserShared, 1, -1 do
        if (gUserShared[i].num==0) then
            table.remove(gUserShared, i)
        end
    end

    for i=#gDigMine.userMineItems,1, -1 do
        if (gDigMine.userMineItems[i].num==0) then
            table.remove(gDigMine.userMineItems, i)
        end
    end

end

function Data.getUserItemNumById(id)
    local item=Data.getUserItemById(id)

    if(item)then
        return item.num
    end

    return 0
end


function Data.getUserCardById(id)
    for key, var in pairs(gUserCards) do
        if(var.cardid==id)then
            return var
        end
    end

    return nil
end

function Data.getUserPetById(id)
    for key, var in pairs(gUserPets) do
        if(var.petid==id)then
            return var
        end
    end

    return nil
end

function Data.updateUserPetCard(pid,cid)
    for key, var in pairs(gUserPets) do
        if(var.cid==cid)then
            var.cid=0
        end
        if(var.petid==pid)then
            var.cid=cid
        end
    end
end


function Data.updateUserCard(card)
    for key, var in pairs(gUserCards) do
        if(var.cardid==card.cardid)then
            card.needRefresh = true;
            gUserCards[key]=card
            return
        end
    end

end

function Data.getMaxEnergy()
    return  DB.getMaxEnergy(gUserInfo.level)
end

function Data.buyEnergy()
    if(gUserInfo.energy>Data.getMaxEnergy())then
        return false
    end

end

function Data.initUserCard(cardid,grade)
    local card={}
    card.id=0
    card.cardid=cardid
    card.level=1
    card.grade=0
    if(grade==nil)then
        local db=DB.getCardById(cardid)
        if(db)then
            card.grade=db.evolve
        end
    else
        card.grade=grade
    end
    card.quality=0
    card.exp=0
    card.awakeLv=0
    card.raise_physicalAttack=0
    card.raise_physicalDefend=0
    card.raise_magicDefend=0
    card.raise_hp=0
    card.weaponLv=0


    card.skillLvs={}
    card.equipLvs={}
    card.equipQuas={}
    card.equipActives={}
    for i=0, 7 do
        table.insert(card.skillLvs,i,1)
        table.insert(card.equipLvs,i,0)
        table.insert(card.equipQuas,i,0)
        table.insert(card.equipActives,i,0)
    end
    CardPro.setCardAttr(card,true)
    return card
end



function Data.getTeamType(actType)
    if(actType==2)then
        return TEAM_TYPE_ATLAS_ACT_GOLD
    elseif(actType==3)then
        return TEAM_TYPE_ATLAS_ACT_EXP
    elseif(actType==4)then
        return TEAM_TYPE_ATLAS_ACT_PET
    elseif(actType==11)then
        return TEAM_TYPE_ATLAS_ACT_EQUSOUL
    elseif(actType==16)then
        return TEAM_TYPE_ATLAS_ACT_ITEMAWAKE
    end
end


function Data.getBattleType(actType)
    if(actType==2)then
        return BATTLE_TYPE_ATLAS_GOLD
    elseif(actType==3)then
        return BATTLE_TYPE_ATLAS_EXP
    elseif(actType==4)then
        return BATTLE_TYPE_ATLAS_PET
    elseif(actType==11)then
        return BATTLE_TYPE_ATLAS_EQUSOUL
    elseif(actType==16)then
        return BATTLE_TYPE_ATLAS_ITEMAWAKE
    end
end

function Data.removeFamilyAppWithUid(uid)
    return Data.removeBuddyDataWithId(gFamilyAppList,"uid",uid);
end

function Data.removeFamilyMemWithUid(uid)
    return Data.removeBuddyDataWithId(gFamilyMemList,"uid",uid);
end

function Data.removeBuddyDataWithId(data,key,id)
    --echo("count = "..table.getn(data));
    for i,value in ipairs(data) do
        --    echo("for value[key] = "..value[key] .. "    id = "..id);
        if value[key] == id then
            table.remove(data, i);
            --      echo("find it !!! return index = "..(i-1));
            return i-1;
        end
    end
    return -1;
end

--是否拥有月卡或年卡
function Data.hasMemberCard(cardType)
    if cardType == CARD_TYPE_MON then
        if gIapBuy["iap"..CARD_TYPE_MON] and gIapBuy["mctime"] >= os.time() then
            return true;
        end
    elseif cardType == CARD_TYPE_LIFE then
        if gIapBuy["iap"..CARD_TYPE_LIFE] then
            return true;
        end
    end
    return false;
end

--是否iap
function Data.hasIap(id)
    if gIapBuy["iap"..id] then
        return true;
    end
    return false
end

function Data.isExpItem(itemid)
    if(itemid==17 or itemid==18 or itemid==19 or itemid==20)then
        return true
    end
    return false
end

function Data.isBoxKeyItem(itemid)
    if(  itemid==38 or itemid==39 or itemid==40)then
        return true
    end
    return false
end


function Data.isDrawCardItem(itemid)
    if(  itemid==ITEM_ID_DRAW_CARD_ONE or itemid==ITEM_ID_DRAW_CARD_TEN)then
        return true
    end

    return false
end

function Data.useItem(itemid)
    if( Data.isExpItem(itemid))then
        CardPro.curExpId= itemid
        Panel.popUp(PANEL_CARD_EXP,1)
        return
    end

    if(DB.getItemType(itemid)==ITEMTYPE_BOX)then

        local db=DB.getBoxById(itemid)
        if(db and db.limittype==1 and gUserInfo.level<db.openlv)then
            gShowNotice(gGetWords("noticeWords.plist","not_enough_level"))
            return
        end
        --多选1宝箱
        if db.type==2 then
            Panel.popUp(PANEL_MULTIITEM_OPEN_BOX,{type=1,boxid=itemid})
            return
        end
        if(Data.getItemNum(itemid)==1)then
            Net.sendOpenBox(itemid,1)
        else
            Panel.popUp(PANEL_MULT_OPEN_BOX,itemid)
        end
        return
    end

    if( Data.isBoxKeyItem(itemid))then
        Panel.popUp(PANEL_PET_TOWER_BOX)
        return
    end



    if( Data.isDrawCardItem(itemid))then
        Panel.popUp(PANEL_DRAW_CARD)
        return
    end

    if(itemid == ITEM_HP) then
        if(NetErr.isEnergyFull()) then
            return;
        end
    end

    Net.sendUseItem(itemid,1)
end

function Data.isRewardItemShouldBeSkipped(panelName, id)
    if panelName == "AtlasFinalPanel" or panelName == "AtlasActFinalPanel" then
        if id == OPEN_BOX_GOLD or id == OPEN_BOX_EXP then
            return true
        end
    end
    return false
end

function Data.isReachMaxStage(type, mapid, stageid)
    local totalStageNum=DB.getAtlasStageNum(mapid,type)

    return totalStageNum == stageid
end
-- Net.sendAtlasEnterParam,gAtlas.maxMap0, gAtlas.maxStage0,oldMaxMap0,oldMaxStage0
function Data.isShowAtlasPassedFla(enterParam, curMaxMap0, curMaxStage0, oldMaxMap0, oldMaxStage0)
    if enterParam.type~=0 or enterParam.mapid < curMaxMap0 or curMaxStage0 == oldMaxStage0 then
        return false
    end

    if Data.isReachMaxStage(0, curMaxMap0, curMaxStage0) then
        return true
    end

    return false
end

function Data.initActInvestCanBeGot()
    Data.actInvestCanBeGot = {}
end

function Data.updateActInvestCanBeGot(lv, canBeGot)
    Data.actInvestCanBeGot[lv] = canBeGot
end

function Data.hasActInvestCanBeGot()
    for _, value in pairs(Data.actInvestCanBeGot) do
        if value then
            return true
        end
    end

    return false
end

function Data.initActLvUpCanBeGot()
    Data.actLvUpCanBeGot = {}
end

function Data.updateActLvUpCanBeGot(lv, canBeGot)
    Data.actLvUpCanBeGot[lv] = canBeGot
end

function Data.hasActLvUpCanBeGot()
    for key, value in pairs(Data.actLvUpCanBeGot) do
        if value then
            return true
        end

        local boxid = DB.getActLevelUpBoxid(key)
        if Data.getCurLevel() >= key and Data.activityLevelUp[boxid] == nil then
            Data.actLvUpCanBeGot[key] = true
            return true
        end
    end

    return false
end



function Data.hasPayDataCanBeGot()
    if nil == Data.activityPayData.list then
        return false
    end

    for i=1, #Data.activityPayData.list do
        if Data.activityPayData.list[i].rec then
            return true
        end
    end

    return false
end

function Data.initAct7DayCanBeGot()
    Data.act7DayCanBeGot = {}
end

function Data.updateAct7DayCanBeGot(idx, canBeGot)
    Data.act7DayCanBeGot[idx] = canBeGot
end

function Data.hasAct7DayCanBeGot()
    for _, value in pairs(Data.act7DayCanBeGot) do
        if value then
            return true
        end
    end

    return false
end

function Data.canShowActAtlasRedPoint(sysType, redPosItem)
    local actAtlasInfo = Battle.getActAtlasInfoByType(redPosItem.type)
    if nil ~= actAtlasInfo then
        if actAtlasInfo.num > 0 and actAtlasInfo.cdTime - gGetCurServerTime() <= 0 and Unlock.isUnlock(sysType, false) then
            return true
        end
    elseif nil ~= redPosItem and redPosItem.num > 0 and (redPosItem.cdTime == 0 or redPosItem.cdTime < gGetCurServerTime()- redPosItem.serverTime) and Unlock.isUnlock(sysType, false) then
        return true
    end
end

function Data.setMaxSkillPointRedPoint(card,hasCard)
    if hasCard and Unlock.isUnlock(SYS_SKILL,false) then
        if gUserInfo.skillPoint>=Data.vip.skillpot.maxSkillPoint() and CardPro.hasSkillUpgrade(card) then
            Data.redpos.bolMaxSkillPoint = true
        else
            Data.redpos.bolMaxSkillPoint = false
        end
    else
        Data.redpos.bolMaxSkillPoint = false
    end
end

function Data.isGoldEnough(needGold)
    if gUserInfo.gold < needGold then
        return false
    end
    return true
end

-- function Data.savePushSet()
--     cc.UserDefault:getInstance():setBoolForKey("pushset_hp_get",gPushSet[Pushset_HpGet_Open]);
--     cc.UserDefault:getInstance():setBoolForKey("pushset_hp_full",gPushSet[Pushset_HpFull_Open]);
-- end

function Data.getPushSet(key)
    return cc.UserDefault:getInstance():getBoolForKey(key,true)
end


function Data.getVipGetIdxByLv(lv)
    if nil == lv then
        return -1
    end

    local vipGetLev = Data.activity.vip_get_level
    local maxIdx = #vipGetLev

    if lv >= toint(vipGetLev[maxIdx]) then
        return maxIdx
    end

    for i = 1, maxIdx - 1 do
        if lv >= toint(vipGetLev[i]) and lv < toint(vipGetLev[i + 1]) then
            return i
        end
    end

    return -1
end

function Data.canShowVipGetRedPoint()
    if nil == gUserInfo.level then
        return
    end

    local vipGetIdx = Data.getVipGetIdxByLv(gUserInfo.level)
    if vipGetIdx == -1 then
        return false
    end

    local vipGetValue = Data.activity.vip_get[vipGetIdx]
    if Data.getCurVip() < toint(vipGetValue) then
        return true
    end

    return false
end

function Data.isMineItem(itemid)
    local itemData = DB.getItemData(itemid)
    if nil ~= itemData and itemData.type == ITEMTYPE_MINE then
        return true
    end
    return false
end
--是否为矿式包，初级矿石包，中级矿石凶，高级矿石包，雷管
function Data.isMineToolItem(itemid)
    if nil == itemid then
        return false
    end

    if itemid >= ITEM_DETONATOR and itemid <= ITEM_MINE_BAG_LEVEL3 then
        return true
    end

    return false
end

function Data.getToolVipType(itemid)
    if itemid == ITEM_DETONATOR then
        return VIP_DETONATOR
    elseif itemid >= ITEM_MINE_BAG and itemid <= ITEM_MINE_BAG_LEVEL3 then
        return VIP_MINE_BAG + itemid - ITEM_MINE_BAG
    end

    return nil
end

function Data.getMaxAtlasPassedIntro()
    local name="word/atlasPassedWords.plist"
    local passIntro=Scene.fileCache[name]
    if(passIntro==nil)then
        passIntro=cc.FileUtils:getInstance():getValueMapFromFile(name)
        Scene.fileCache[name]=passIntro
    end

    local maxIndex = 0
    for key,value in pairs(passIntro) do
        if value.info ~= "" then
            if maxIndex < toint(key) then
                maxIndex = toint(key)
            end
        end
    end
    return maxIndex
end

function Data.shouldCommentAppStore(type,param)
    if Module.isClose(SWITCH_APPSTORE_GOOD) or Data.appsComment then
        return false
    end

    if nil ~= gAccount and (gAccount:getPlatformId() ~= CHANNEL_APPSTORE or gAccount:getPlatformId() ~= CHANNEL_IOS_JIURU or gAccount:getPlatformId() ~= CHANNEL_IOS_JITUO) then
        return false
    end

    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform ~= cc.PLATFORM_OS_IPHONE and targetPlatform ~= cc.PLATFORM_OS_IPAD then
    --     return false
    -- end

    if type == APPSTORE_COMMENT_NEWCARD then
        if gUserInfo.vipsc > 0 and param == 10013 then
            return true
        end
    elseif type == APPSTORE_COMMENT_ATLAS_FINAL then
        if param == ATLAS_COMPLETE_FOR_APPSTORE then
            return true
        end
    end

    return false
end

function Data.openAppStoreCommentURL()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_IPHONE then
    -- https://itunes.apple.com/cn/app/luan-dou-tang2-jiu-ji-bian/id1049602254?mt=8
    -- itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1049602254
    local url = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1049602254&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
    PlatformFunc:sharedPlatformFunc():openURL(url)
    -- elseif targetPlatform == cc.PLATFORM_OS_IPAD then
    --TODO
    -- end
end

function Data.clearAdvertises()
    Data.advertises = {}
end

function Data.addAdvertise(_endTime,_aid,_sortid,_param1,_param2)
    table.insert(Data.advertises,{endTime = _endTime, aid = _aid, sortid = _sortid, param1 = _param1, param2 = _param2})
end

function Data.sortAdvertises()
    if #Data.advertises == 0 then
        return
    end

    local sortFuc= function(leftAdver, rightAdver)
        return toint(leftAdver.sortid) > toint(rightAdver.sortid)
    end
    table.sort( Data.advertises, sortFuc )
end

function Data.getAdvertisesCount()
    return #Data.advertises
end

function Data.getAdvertiseByIdx(idx)
    if idx > #Data.advertises then
        return nil
    end

    return Data.advertises[idx]
end

function Data.isMineBagItem(itemid)
    if itemid >= ITEM_MINE_BAG and itemid <= ITEM_MINE_BAG_LEVEL3 then
        return true
    end
    return false
end

function Data.getCurFamilyMoney()
    return gUserInfo.famoney
end

function Data.setFamilyStageFightNum(num)
   gFamilyStageInfo.fightNum = num
end

function Data.setFamilyStageBuffUpNum(num)
    gFamilyStageInfo.buffUpNum = num
end

function Data.setFamilyStageBuffCountry(major,minor)
    if gFamilyStageInfo.buff == nil then
        gFamilyStageInfo.buff = {}
    end

    gFamilyStageInfo.buff.major = major
    gFamilyStageInfo.buff.minor = minor
end

function Data.setFamilyStageBuffInfo(lv, exp, rewards)
    if gFamilyStageInfo.buff == nil then
        gFamilyStageInfo.buff = {}
    end

    gFamilyStageInfo.buff.lv  = lv
    gFamilyStageInfo.buff.exp = exp
    if nil ~= rewards then
        gFamilyStageInfo.buff.rewards = rewards
    end
end
function Data.clearFamilyStageKills()
    gFamilyStageInfo.kills = {}
end

function Data.setFamilyStageKills(stageId, name, rewards)
    if gFamilyStageInfo.kills == nil then
        gFamilyStageInfo.kills = {}
    end

    table.insert(gFamilyStageInfo.kills, {stageId=stageId,name=name,rewards=rewards})
end

function Data.setFamilyStageAverPower(power)
    gFamilyStageInfo.power = power
end

function Data.setFamilyStageActiveNum(num)
    gFamilyStageInfo.activeNum = num
end

function Data.setFamilyStagePro(pro)
    gFamilyStageInfo.pro = pro
end

function Data.setFamilyStageFightTime(time)
    gFamilyStageInfo.fightTime = time
end

function Data.clearFamilyStageOppInfo()
    gFamilyStageInfo.oppInfo = {}
end

function Data.setFamilyStageOppId(id)
    if gFamilyStageInfo.oppInfo == nil then
        gFamilyStageInfo.oppInfo = {}
    end

    gFamilyStageInfo.oppInfo.familyId = id
end

function Data.setFamilyStageOppInfo(name, icon, pro, fighttime)
    if gFamilyStageInfo.oppInfo == nil then
        gFamilyStageInfo.oppInfo = {}
    end
    gFamilyStageInfo.oppInfo.name = name
    gFamilyStageInfo.oppInfo.icon = icon
    gFamilyStageInfo.oppInfo.pro = pro
    gFamilyStageInfo.oppInfo.fightTime = fighttime
end

function Data.setFamilyStageProList(stageid, prog, isSelf)
    if isSelf then
        if gFamilyStageInfo.selfProLists == nil then
            gFamilyStageInfo.selfProLists = {}
        end
        gFamilyStageInfo.selfProLists[stageid] = prog
    else
        if gFamilyStageInfo.otherProLists == nil then
            gFamilyStageInfo.otherProLists = {}
        end
        gFamilyStageInfo.otherProLists[stageid] = prog
    end
end

function Data.clearFamilyStageProList(isSelf)
    if isSelf then
        gFamilyStageInfo.selfProLists = {}
    else
        gFamilyStageInfo.otherProLists = {}
    end
end

function Data.updateFamilyStageUserFightInfo(uid, power, num)
    for _, memInfo in ipairs(gFamilyMemList) do
        if memInfo.uid == uid then
            memInfo.iPower = power
            memInfo.iStageFightNum = num
            break
        end
    end
end

function Data.clearFamilyStageMonsterList()
    gFamilyStageInfo.monsters = {}
end

function Data.addFamilyStageMonsters(id, hp, thp)
    table.insert(gFamilyStageInfo.monsters, {id=id, hp=hp, thp=thp})
end

function Data.getFamilyMaxAndPassingIdByMapId(mapId,isSelf)
    local passingStageId = -1
    local stageProList = gFamilyStageInfo.otherProLists
    if isSelf then
        stageProList = gFamilyStageInfo.selfProLists
    end

    local stageInfo = DB.getFamilyStageInfoByMapId(mapId)

    for key, var in pairs(stageInfo) do
        if stageProList[var.id] ~= nil and stageProList[var.id] > 0 then
            passingStageId = var.id
        end
    end

    return passingStageId,#stageInfo
end

function Data.clearMyFamilyStageHarmRank()
    gFamilyStageInfo.myHarmRank = 0
    gFamilyStageInfo.myHarmValue = 0
end

function Data.setMyFamilyStageHarmRank(rank)
    gFamilyStageInfo.myHarmRank = rank
end

function Data.setMyFamilyStageHarmValue(value)
    gFamilyStageInfo.myHarmValue = value
end

function Data.clearFamilyStageHarmRanks()
    gFamilyStageInfo.harmRanks = {}
end

function Data.addFamilyStageHarmRank(rank, uId, uName,lv, vip, icon, post, harm)
    table.insert(gFamilyStageInfo.harmRanks, {rank=rank, id=uId, name=uName, level=lv, vip=vip, cid=icon, post=post, harm=harm})
end

function Data.clearFamilyStageHarmDetailList()
    gFamilyStageInfo.harmDetailList = { }
end

function Data.addFamilyStageHarmDetailList(name, harm)
    table.insert(gFamilyStageInfo.harmDetailList, {name=name, harm=harm})
end

function Data.setFamilyStageLastProg(prog)
    gFamilyStageInfo.lastProg = prog
end

function Data.setFamilyStageOtherLastInfo(name,icon)
    if gFamilyStageInfo.otherLastProg == nil then
        gFamilyStageInfo.otherLastProg = {}
    end

    gFamilyStageInfo.otherLastProg.name = name
    gFamilyStageInfo.otherLastProg.icon = icon
end

function Data.setFamilyStageLastWinFlag(flag)
    gFamilyStageInfo.lastWinFlag = flag
end

function Data.clearFamilyStageSelfLastInfos()
    gFamilyStageInfo.selfLastInfos = { }
end

function Data.addFamilyStageSelfLastInfo(name, lv, vip, icon, post, num)
    if gFamilyStageInfo.selfLastInfos == nil then
        gFamilyStageInfo.selfLastInfos = {}
    end
    table.insert(gFamilyStageInfo.selfLastInfos,{name=name, lv=lv, vip=vip, icon=icon, post=post, num=num})
end

function Data.clearFamilyStageOtherLastInfos()
    gFamilyStageInfo.otherLastInfos = { }
end

function Data.addFamilyStageOtherLastInfo(name, lv, vip, icon, post, num)
    if gFamilyStageInfo.otherLastInfos == nil then
        gFamilyStageInfo.otherLastInfos = {}
    end
    table.insert(gFamilyStageInfo.otherLastInfos,{name=name, lv=lv, vip=vip, icon=icon, post=post, num=num})
end

function Data.initFamilyStageInfo()
    Data.setFamilyStageFightNum(0)
    Data.setFamilyStageBuffUpNum(0)
    Data.setFamilyStageBuffCountry(0,0)
    Data.setFamilyStageBuffInfo(0,0, {})
    Data.clearFamilyStageKills()
    Data.setFamilyStageAverPower(0)
    Data.setFamilyStageActiveNum(0)
    Data.setFamilyStagePro(0)
    Data.setFamilyStageFightTime(0)
    Data.setFamilyStageOppId(0)
    Data.clearFamilyStageOppInfo()
    Data.clearFamilyStageProList(true)
    Data.clearFamilyStageProList()
    Data.clearFamilyStageBasicAttr()
    Data.clearFamilyStageTipInfo()
end

function Data.getFamilyStagePhase()
    local beginDay1,beginHour1 = DB.getFamilyStageBeginTime1()
    local endDay1,endHour1 = DB.getFamilyStageEndTime1()
    local beginDay2,beginHour2 = DB.getFamilyStageBeginTime2()
    local endDay2,endHour2 = DB.getFamilyStageEndTime2()

    if beginDay1 == 0 then
        beginDay1 = 7
    end

    if endDay1 == 0 then
        endDay1 = 7
    end

    if beginDay2 == 0 then
        beginDay2 = 7
    end

    if endDay2 == 0 then
        endDay2 = 7
    end

    local beginTime1 = gGetWeekOneTimeByCur(beginDay1,beginHour1)
    local endTime1 = gGetWeekOneTimeByCur(endDay1,endHour1)

    local beginTime2 = gGetWeekOneTimeByCur(beginDay2,beginHour2)
    local endTime2 = gGetWeekOneTimeByCur(endDay2,endHour2)

    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8()

    if (curTime >= beginTime1 and curTime < endTime1) then
        return FAMILY_STAGE_1, endTime1 - curTime
    elseif (curTime >= beginTime2 and curTime < endTime2) then
        return FAMILY_STAGE_2, endTime2 - curTime
    elseif (curTime >= endTime1 and curTime < beginTime2) then
        return FAMILY_STAGE_NONE, beginTime2 - curTime
    elseif curTime >= endTime2 then
        local tmpTime = gGetWeekOneTimeByCur(7,23)
        return FAMILY_STAGE_NONE, (tmpTime - curTime + 3600) + (beginDay1 - 1) * 24 * 3600 + beginHour1 * 3600
    elseif curTime < beginTime1 then
        return FAMILY_STAGE_NONE, beginTime1 - curTime
    end
end

function Data.clearFamilyStageBasicAttr()
    gFamilyStageInfo.baseAttr = {}
end

function Data.addFamilyStageBasicAttrValue(value)
    table.insert(gFamilyStageInfo.baseAttr, value)
end

function Data.clearFamilyStageTipInfo()
    gFamilyStageInfo.tipInfo = {}
end

function Data.addFamilyStageTipInfo(id)
    gFamilyStageInfo.tipInfo[id] = true
end

function Data.isFamilyStageAllPassed(isSelf)
    local allPassed = true

    if isSelf then
        allPassed = (DB.getMaxFamilyStageCount() == gFamilyStageInfo.pro)
    else
        if gFamilyStageInfo.oppInfo.pro ~= nil then
            allPassed = (DB.getMaxFamilyStageCount() == gFamilyStageInfo.oppInfo.pro)
        else
            allPassed = false
        end

    end

    return allPassed
end

function Data.setHuntIntervalInfosOfWorldBoss()
    if not Unlock.isUnlock(SYS_WORLD_BOSS,false) then
        return
    end
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8()
    local worldBossDays = string.split(DB.getOpenDayOfWorldBoss(), ";")
    local worldBossTimes = string.split(DB.getOpenTimeOfWorldBoss(), ";")
    for _, day in ipairs(worldBossDays) do
        local detailTime = gGetWeekOneTimeByCur(toint(day),toint(worldBossTimes[1]),toint(worldBossTimes[2]))
        local intervalTime = detailTime-curTime
        local duration = toint(worldBossTimes[3])
        if intervalTime <= 0 and math.abs(intervalTime) > duration then
            intervalTime = intervalTime + 7 * 24 * 3600
        end
        Data.addHuntIntervalInfo(HUNT_ID_MAP[1], intervalTime, duration)
    end

    -- 新世界boss
    local newBossDays = string.split(DB.getClientParam("WORLD_BOSS_NEW_DAY"), ";")
    local newBossTimes = string.split(DB.getClientParam("WORLD_BOSS_NEW_TIME"), ";")
    for _, day in ipairs(newBossDays) do
        local detailTime = gGetWeekOneTimeByCur(toint(day),toint(newBossTimes[1]),toint(newBossTimes[2]))
        local intervalTime = detailTime-curTime
        local duration = toint(newBossTimes[3])
        if intervalTime <= 0 and math.abs(intervalTime) > duration then
            intervalTime = intervalTime + 7 * 24 * 3600
        end
        Data.addHuntIntervalInfo(HUNT_ID_MAP[1], intervalTime, duration)
    end
end

function Data.setHuntIntervalInfosOfTreasure()
    if not Unlock.isUnlock(SYS_TREASURE_HUNT,false) then
        return
    end
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8()
    local treasureHuntDays = string.split(DB.getOpenDayOfTreasureHunt(), ";")
    local treasureHuntTimes = string.split(DB.getOpenTimeOfTreasureHunt(), ";")
    for _, day in ipairs(treasureHuntDays) do
        local detailTime = gGetWeekOneTimeByCur(toint(day),toint(treasureHuntTimes[1]),toint(treasureHuntTimes[2]))
        local intervalTime = detailTime-curTime
        local duration = toint(treasureHuntTimes[3])
        if intervalTime <= 0 and math.abs(intervalTime) > duration then
            intervalTime = intervalTime + 7 * 24 * 3600
        end
        Data.addHuntIntervalInfo(HUNT_ID_MAP[2], intervalTime, duration)
    end
end

function Data.setHuntIntervalInfosOfLootFood()
    if not Unlock.isUnlock(SYS_LOOT_FOOD,false) then
        return
    end
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8()
    local detailTime = gGetWeekOneTimeByCur(gLootfoodBeginDay,gLootfoodBeginHour)
    local endtime = gGetWeekOneTimeByCur(gLootfoodEndDay,gLootfoodEndHour)
    local intervalTime = detailTime-curTime
    local duration = endtime-detailTime
    if intervalTime < 0 and math.abs(intervalTime) > duration then
        intervalTime = intervalTime + 7 * 24 * 3600
    end
    Data.addHuntIntervalInfo(HUNT_ID_MAP[3], intervalTime, endtime-detailTime)
end

function Data.clearHuntIntervalInfos()
    Data.huntIntervalInfos = {}
    Data.finalHuntIntervalInfos = {}
end

function Data.addHuntIntervalInfo(_huntId, _interval, _duration)
    table.insert(Data.huntIntervalInfos, {huntId=_huntId, interval=_interval, duration=_duration})
end

function Data.setHuntIntervalInfos()
    Data.setHuntIntervalInfosOfWorldBoss()
    Data.setHuntIntervalInfosOfTreasure()
    Data.setHuntIntervalInfosOfLootFood()

    --[[if isBanshuReview() then
        for k,v in pairs(HUNT_ID_MAP) do
            if v == 3 then
                table.remove(HUNT_ID_MAP,k)
                break
            end
        end
    end]]

    table.sort(Data.huntIntervalInfos, function(lInfo, rInfo)
        if lInfo.interval < 0 and rInfo.interval < 0 then
            return lInfo.interval > rInfo.interval
        end
        return lInfo.interval < rInfo.interval
    end)

    for i = 1, #HUNT_ID_MAP do
        Data.finalHuntIntervalInfos[i] = nil
    end

    local huntFinalInfos = {}
    local idx = 1
    for _,var in ipairs(Data.huntIntervalInfos) do
        if huntFinalInfos[var.huntId] == nil then
            huntFinalInfos[var.huntId] = var
            Data.finalHuntIntervalInfos[idx] = var
            idx = idx + 1
        end
    end
    -- 如果最终的时间间隔小于探险系统的总值，表示有系统未开启
    local finalInfosSize = #Data.finalHuntIntervalInfos
    if finalInfosSize < #HUNT_ID_MAP then
        if finalInfosSize < 1 then --表示没有任务系统开启
            for i = 1, #HUNT_ID_MAP do
                Data.finalHuntIntervalInfos[i] = {huntId=HUNT_ID_MAP[i], interval=0, duration=0}
            end
        elseif finalInfosSize < 2 then
            for i = 1, #HUNT_ID_MAP do
                if Data.finalHuntIntervalInfos[1].huntId ~= HUNT_ID_MAP[i] then
                    table.insert(Data.finalHuntIntervalInfos,{huntId=HUNT_ID_MAP[i], interval=0, duration=0})
                end
            end
        elseif finalInfosSize < 3 then
            local idx1HuntId = Data.finalHuntIntervalInfos[1].huntId
            local idx2HuntId = Data.finalHuntIntervalInfos[2].huntId
            for i = 1, #HUNT_ID_MAP do
                if idx1HuntId ~= HUNT_ID_MAP[i] and idx2HuntId ~= HUNT_ID_MAP[i]  then
                    table.insert(Data.finalHuntIntervalInfos,{huntId=HUNT_ID_MAP[i], interval=0, duration=0})
                end
            end
        end
    end

    local idx1Info = Data.finalHuntIntervalInfos[1]
    Data.finalHuntIntervalInfos[1] = Data.finalHuntIntervalInfos[2]
    Data.finalHuntIntervalInfos[2] = idx1Info
end

function Data.getHuntIntervalInfos(huntId)
    for _,var in pairs(Data.finalHuntIntervalInfos) do
        if var.huntId == huntId then
            return var
        end
    end
    return nil
end

function Data.getMmBuyItemNumById(itemid)
    if(Data.mmbuylist)then 
        for key, var in pairs(Data.mmbuylist) do
            if(var.itemid==itemid)then
                return var.num
            end
        end
    end
    return 0
end

function Data.getPetSkin(awakeLv)
    if awakeLv == 1 then
        return "_1"
    end
    return ""
end

function Data.isCardTop6(id)
    for i = 1, 6 do
        local card = gUserCards[i]
        if card ~= nil and card.cardid == id then
            return true
        end
    end

    return false
end
