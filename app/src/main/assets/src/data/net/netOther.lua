function Net.recSystemInit(evt)
    local obj = evt.params:getObj("params")
    Scene.hideWaiting()
    if(obj:getByte("ret")~=0)then
        return
    end

    if(obj:containsKey("pc"))then
        Net.updateParamClient(obj:getArray("pc"))
    end

    gRichman.endTime=obj:getInt("richend")
    gRichman.startTime=obj:getInt("richstart")
    
    gLuckWheel.endTime=obj:getInt("turnend")
    gLuckWheel.startTime=obj:getInt("turnstart") 
    
    Data.activityProAdd={}
    local actParam = obj:getObj("act18")
    if (actParam) then
        Data.activityProAdd.pro= actParam:getInt("param1");
        Data.activityProAdd.value= actParam:getInt("param2");
    end

    Data.activity81={}
    local actParam = obj:getObj("act81")
    if (actParam) then
        Data.activity81.stime= actParam:getInt("stime");
        Data.activity81.etime= actParam:getInt("etime");
        Data.activity81.param1= actParam:getInt("param1");
        Data.activity81.param2= actParam:getInt("param2");
    end

    Data.initClentParam()


    local userInfo=obj:getObj("info")
    Net.parseUserInfo(userInfo)
    if(userInfo:containsKey("rename"))then
        local rename = userInfo:getByte("rename");
        print("rename = "..rename);
        if(rename == 1)then
            gUserInfo.needChangeName = true;
        end
    end
    gAccount:roleLogin()

    local function vip2Age(vip)
        local age = 1
        if vip <=6 then
            age =  vip + 5
        elseif vip <= 13 then
            age = (vip - 4) * 5 + 2
        elseif vip == 14 then
            age = 55
        elseif vip == 15 then
            age = 65
        end
        return age
    end

    if (TDGAAccount and gAccount) then
        gLogAccountId(gAccount.accountid)
        gLogAccountLevel(gUserInfo.level)
        if gUserInfo.name~="" then
            gLogAccountName(gUserInfo.name)
        end
        local curServer=gAccount:getCurServer()
        if(curServer)then
            --self:setLabelString("txt_server",curServer.name)
            gLogAccountServer(curServer.name)
        end
        gLogAccountAge(vip2Age(Data.getCurVip()))
    end

    if (gIsFirstEnter and gOnAdRegister) then
        gOnAdRegister(gUserInfo.id)
    end

    if (gOnAdLogin) then
        gOnAdLogin(gUserInfo.id)
    end

    -- youmeLogin(tostring(Data.getCurUserId()),tostring(Data.getCurUserId()),"");
    -- youmeJoinChatRoom(DataEDCode:encode(gAccount:getCurServer().name));

    gUserInfo.arenarank = obj:getInt("arenarank");
    gUserCards={}
    gUserItems={}--物品
    gUserEshared={}
    gUserSouls={}
    gUserPets={}
    gUserShared={}
    gUserPetSouls={}
    gSetServerTime(obj:getInt("time"))
    gSetServerTimeZone(obj:getInt("timezone")/3600)
    gLoginTime=gGetCurServerTime()

    Net.parserVipBuy(obj:getObj("vipbn"))
    Net.parserMineVipBuy(obj:getObj("minebn"))
    --免费vip体验
    local vipExperObj=obj:getObj("fevip")
    if vipExperObj then
        gUserInfo.fevip_vip = vipExperObj:getInt("vip")
        gUserInfo.fevip_endtime = vipExperObj:getInt("time")
    end

    local userPets=obj:getArray("pet")
    userPets=tolua.cast(userPets,"MediaArray")
    for i=0, userPets:count()-1 do
        table.insert(gUserPets,Net.parseUserPet(userPets:getObj(i)))
    end


    Data.hasRedPack=obj:getBool("redpack") 
    Data.loopPackNum=obj:getInt("rploot");

    local userCards=obj:getArray("card")
    userCards=tolua.cast(userCards,"MediaArray")
    for i=0, userCards:count()-1 do
        table.insert(gUserCards,Net.parseUserCard(userCards:getObj(i),false))
    end



    local userItem=obj:getArray("item")
    if(userItem)then
        userItem=tolua.cast(userItem,"MediaArray")
        for i=0, userItem:count()-1 do
            local item = Net.parseUserItem(userItem:getObj(i))
            if Data.isMineItem(item.itemid) then
                table.insert(gDigMine.userMineItems, item)
            else
                table.insert(gUserItems,item)
            end

        end
    end


    local drawObj=obj:getObj("dbobj")
    if(drawObj)then
        Data.drawCard={}
        Data.drawCard.gball=drawObj:getInt("gball")
        Data.drawCard.exlist=Net.updateDragonExchange(drawObj:getArray("exlist"))
    end


    local equipItem=obj:getArray("equitem")
    if(equipItem)then
        equipItem=tolua.cast(equipItem,"MediaArray")
        for i=0, equipItem:count()-1 do
            table.insert(gUserEquipItems,Net.parseEquipItem(equipItem:getObj(i)))
        end
    end
    
    
    local treasureItem=obj:getArray("treasure")
    if(treasureItem)then
        treasureItem=tolua.cast(treasureItem,"MediaArray")
        for i=0, treasureItem:count()-1 do
            table.insert(gUserTreasure,Net.parseTreasureItem(treasureItem:getObj(i)))
        end
    end
    local treasureShared=obj:getArray("treasureshard")
    if(treasureShared)then
        treasureShared=tolua.cast(treasureShared,"MediaArray")
        for i=0, treasureShared:count()-1 do
            table.insert(gUserTreasureShared,Net.parseTreasureShared(treasureShared:getObj(i)))
        end
    end


    local userShared=obj:getArray("eshard")
    if(userShared)then
        userShared=tolua.cast(userShared,"MediaArray")
        for i=0, userShared:count()-1 do
            table.insert(gUserShared,Net.parseUserShared(userShared:getObj(i)))
        end
    end




    local userSouls=obj:getArray("soul")
    if(userSouls)then
        userSouls=tolua.cast(userSouls,"MediaArray")
        for i=0, userSouls:count()-1 do
            table.insert(gUserSouls,Net.parseUserSouls(userSouls:getObj(i)))
        end
    end

    Data.pet.topFloor = obj:getInt("pettop");

    local petSouls=obj:getArray("psoul")
    if(petSouls)then
        petSouls=tolua.cast(petSouls,"MediaArray")
        for i=0, petSouls:count()-1 do
            table.insert(gUserPetSouls,Net.parsePetSouls(petSouls:getObj(i)))
        end
    end


    local userTeams=obj:getArray("teamlist")
    if(userTeams)then
        userTeams=tolua.cast(userTeams,"MediaArray")
        for i=0, userTeams:count()-1 do
            table.insert(gUserTeams,Net.parseUserTeam(userTeams:getObj(i)))
        end
        local today = gGetDate("%d")
        print ("td.date:" .. today)
        if (cc.UserDefault:getInstance():getStringForKey("td.date") ~= today) then
            cc.UserDefault:getInstance():setStringForKey("td.date",gGetDate("%d"))
            cards = Data.getUserTeam(TEAM_TYPE_ARENA_ATTACK)
            if (cards ~= nil) then
                for key,var  in pairs(cards) do
                    if(key==PET_POS)then
                        gLogEvent("arena_pet." .. tostring(var))
                    else
                        data =  Data.getUserCardById(var)
                        name = DB.getItemName(var)
                        if (data ~= nil) and (name ~= "") then
                            local td_param = {}
                            td_param['star'] = tostring(data.grade)
                            td_param['awakeLv'] = tostring(data.awakeLv)
                            td_param['weaponLv'] = tostring(data.weaponLv)
                            gLogEvent("jjc." .. tostring(name),td_param,true)
                            td_param['card_name'] = name
                            gLogEventBI("jjc." .. var, td_param)
                        end
                    end
                end
            end
            for key,var in pairs(gUserPets) do
                local td_param = {}
                td_param['grade'] = tostring(var.grade)
                td_param['level'] = tostring(var.level)
                gLogEvent("userpet." .. tostring(var.petid),td_param)
            end
        end
    end

    Net.updateMyFamilyInfo(obj:getObj("family"));

    gAtlas=Net.parserStage(obj:getObj("stage"))
    CoreAtlas.EliteFlop.initFlopTab(obj:getObj("stage"))

    Data.bindPhone=false
    if(obj:containsKey("phone"))then
        Data.bindPhone = obj:getBool("phone")
    end


    gIapBuy={}
    for i=1, 9 do
        if(obj:containsKey("iap"..i))then
            gIapBuy["iap"..i]=true
        end
    end
    gIapBuy["mctime"]=obj:getInt("mctime")

    local unlockArrays=obj:getByteArray("unlock")
    gUnlockSys={}
    if(unlockArrays)then
        unlockArrays:resetPos()
        for i=0, unlockArrays:getLen()-1 do
            table.insert(gUnlockSys,unlockArrays:getByte())
        end
    end
    unlockArrays=obj:getByteArray("unlock2")
    gEnterSys={}
    if(unlockArrays)then
        unlockArrays:resetPos()
        for i=0, unlockArrays:getLen()-1 do
            table.insert(gEnterSys,unlockArrays:getByte());
        end
    end
    
    
    
    --0-无；1-新手任务；2-七日任务
    gNewTaskType = obj:getInt("btask");
    -- gNewTaskType = 2;
    Data.task7Day.lefttime = obj:getInt("svtime");
    -- print("1111 time = "..Data.task7Day.lefttime);
    Data.task7Day.lefttime = Data.task7Day.lefttime + gGetCurServerTime();
    -- Data.task7Day.lefttime = math.floor(0.1*24*60*60) + gGetCurServerTime();
    -- print("222222 time = "..Data.task7Day.lefttime);

    -- print_lua_table(gUnlockSys);

    Data.updateMyselfInfo(0,0,0,0,0,0);
    local drinkObj = obj:getObj("drink")
    if(drinkObj) then
        Data.trainroom.myselfInfo.curRoomId = drinkObj:getInt("ridx")
        Data.trainroom.myselfInfo.curEndtime = drinkObj:getInt("endtime")
    end

    gRelations={}
    local relationArray = obj:getArray("relation")
    if nil ~= relationArray then
        relationArray = tolua.cast(relationArray,"MediaArray")
        for i=0, relationArray:count()-1 do
            local data=Net.parseRelationItem(relationArray:getObj(i))
            gRelations[data.id]=data.level
        end
    end


    gUserFamilyBuff = Net.parseFamilyUserSkillList(obj:getArray("ufs"));


    CardPro.setAllCardAttr(true)

    --限时活动，招财猫
    local catObj = obj:getObj("cat")
    if (catObj) then
        Data.activityCat.lefttime = catObj:getInt("time");
        Data.activityCat.lv = catObj:getByte("lv");
        Data.activityCat.rtime = gGetCurServerTime()
    else
        Data.activityCat.lefttime = 0;
        Data.activityCat.lv = 0;
    end
    -- Data.activityCat.lefttime = gGetCurServerTime() + 10

    --在线礼包
    Data.m_onlineInfo.bolOnline = false;
    Data.m_onlineInfo.bolShowRedPoint = false;
    local onlineObj = obj:getObj("online")
    if (onlineObj) then
        Net.updateOnlineGift(onlineObj);
    end

    --许愿树
    local wishObj = obj:getObj("wish")
    Net.updateWish(wishObj)

    --世界boss
    local bossObj = obj:getObj("wboss")
    Net.updateWorldBoss(bossObj)

    --TODO 元魂相关
    SpiritInfo.init()
    local spiritArray = obj:getArray("spirit")
    if nil ~= spiritArray then
        spiritArray = tolua.cast(spiritArray,"MediaArray")
        Net.updateSpiritList(spiritArray)
    end

    if (obj:containsKey("fra")) then
        SpiritInfo.setFraCount(obj:getInt("fra"))
    end

    if (obj:containsKey("spiritexp")) then
        SpiritInfo.exp = obj:getInt("spiritexp")
    end

    --是否开启吃体力 活动
    if(obj:containsKey("eatbun")) then
        Data.bolOpenEatBunAct = obj:getBool("eatbun")
    else
        Data.bolOpenEatBunAct = false
    end

    Data.bolOpenServerBattle = true;
    if(obj:containsKey("woropen")) then
        Data.bolOpenServerBattle = obj:getBool("woropen");
    end

    local actObj = obj:getObj("act")
    if (actObj) then
        Net.updateActObj(actObj)
    end

    gCurGuide = obj:getInt("teach")
    Data.redpos.bolNewTask  = obj:getBool("breward")
    --gCurGuide = -1;

    Net.parserModuleSwitch(obj:getArray("client"));
    Net.updateAllBathObj(obj:getObj("allbath"));
    Net.updateSceneArenaObj(obj:getObj("arena1"));
    updateFamilyCallSpringInfo(obj:getObj("call"));

    --公告
    if(obj:containsKey("noticeid")) then
        Net.updateNoticeRedpos(obj:getInt("noticeid"));
    end

    --跨服战
    if(obj:containsKey("worwin")) then
        Net.parseLastServerBattleInfo(obj:getObj("worwin"))
    end

    if(obj:containsKey("cru"))then
        local cruObj=obj:getObj("cru")
        gCrusadeData.feats=cruObj:getInt("feats")
        gCrusadeData.exploits=cruObj:getInt("exploits")
        gCrusadeData.crunum =cruObj:getInt("crunum")  --  当前可征讨次数        
        gCrusadeData.buynum =cruObj:getInt("buynum")  --  今日购买次数  
    end

    if(obj:containsKey("firstcg")) then
        gUserInfo.firstcg = obj:getByte("firstcg")
    end

    --出现商店（奸商、黑市）
    Net.updateLimitShop(obj)

    if(obj:containsKey("petshopinfo"))then
        Net.updatePetShopInfo(obj:getArray("petshopinfo"));
    end

    --是否完成五星评价
    if(obj:containsKey("apps"))then
        Data.appsComment = obj:getBool("apps")
    else
        Data.appsComment = false
    end

    --黑名单
    if(obj:containsKey("blackid"))then
        -- local blackList = obj:getLongArray("blackid");
        -- gFriend.blackList = {};
        -- if(blackList)then
        --     for i=0, blackList:size()-1 do
        --         table.insert(gFriend.blackList,{uid = blackList[i]});
        --     end
        -- end
        -- print("blackid count = "..obj:getArray("blackid"):count());
        gFriend.blackList = Net.parseBuddyList(obj:getArray("blackid"));
        -- print("@@@@@@@");
        -- print_lua_table(gFriend.blackList);
        -- print("@@@@@@@end");
    end
    --星宿系统
    ----星宿背包
    if(obj:containsKey("constellation"))then
        Net.parserConstellationBag(obj:getArray("constellation"))
    end
    ----法阵消息
    if(obj:containsKey("circle"))then
        Net.parserMagicCircle(obj:getObj("circle"))
    end
    --是否有排行榜活动
    if(obj:containsKey("rankact"))then
        Data.rankActFlag = obj:getBool("rankact")
    end

    --是否有节日活动
    if(obj:containsKey("holact"))then
        Data.holActFlag = obj:getBool("holact")
    end

    --是否有合服活动
    if(obj:containsKey("mixact"))then
        Data.hefuActFlag = obj:getBool("mixact")
    end

    youme.isNeedLogin = true;

    RedPoint.activityRead()

    Scene.enterMainScene()

    Net.sendSystemRollNotice()

    Net.sendChatInit() 
    -- Data.towerInfo.maxstar = obj:getInt("towmax");
    Data.towerInfo.maxstar = obj:getInt("maxstar");
    Data.redpackInfo.redtime = {}
    if(obj:containsKey("redtime"))then
        local redtime = obj:getString("redtime");
        Data.redpackInfo.redtime = string.split(redtime,";");
    end

    Net.LootFoodRank.ver = 0
    Net.updateMmBuyList(obj)
    LocalNotify.setupNotify()

    if (cc.UserDefault:getInstance():getStringForKey("td.userinfo" .. Data.getCurUserId()) ~= gGetDate("%d")) then
        cc.UserDefault:getInstance():setStringForKey("td.userinfo".. Data.getCurUserId(),gGetDate("%d"))
        local param = {}
        param["vip"] = tostring(gUserInfo.vip)

        local gold = gUserInfo.gold
        local strGold = "0"
        if gold < 100000 then
            gold = 0
        elseif gold < 1000000 then
            gold = math.floor(gold / 100000) * 10
            strGold = tostring(gold) ..'w'
        else 
            gold = math.floor(gold / 1000000)
            strGold = tostring(gold) .. 'mw'
        end
        param['gold'] = strGold
        param['serverid'] =tostring(gAccount:getCurRole().serverid)
        local formation =Data.getUserTeam(TEAM_TYPE_ATLAS)
        local power = CardPro.countFormation(formation,TEAM_TYPE_ATLAS)
        print ("power:" .. power)
        power = math.ceil(power/5000) * 5000
        param['power'] = tostring(power)
        local packageName=gAccount:getPackageName()
        param['package'] = packageName
        gLogEvent("td.userinfo", param,true)
        local petMoney = gUserInfo.petMoney
        petMoney = math.floor(petMoney/100) * 100
        param['pet_money'] = petMoney
        local energy = math.floor(gUserInfo.energy / 10) * 10
        param['energy'] = energy
        param['arena_rank'] = tostring(gUserInfo.arenarank)
        param['item_awake'] = tostring(Data.getUserItemNumById(42))
        gLogEventBI("td.userinfo", param)
        if gUserInfo.name~="" then
            local param2 = {}
            param2['name'] = gUserInfo.name
            gLogEvent2("set_name",param2)
        end
    end
    local param= {}
    param['serverid'] =tostring(gAccount:getCurRole().serverid)
    param['item_awake'] = tostring(Data.getUserItemNumById(42))
    gLogEvent("sys.init",param)
end

function Net.updateLimitShop(obj)
    --出现商店（奸商、黑市）
    if(obj:containsKey("limitshop"))then
        local shopObj=obj:getObj("limitshop")
        Data.limit_etime = shopObj:getInt("etime")
        Data.limit_stype = shopObj:getByte("stype")
        gDispatchEvt(EVENT_ID_OPEN_LIMIT_SHOP)
        return true
    end
    return false
end

function Net.recSystemReload(evt)
    local obj = evt.params:getObj("params")
    Scene.hideWaiting()
    if(obj:getByte("ret")~=0)then
        return
    end

    gSetServerTime(obj:getInt("time"))

    local onlineObj = obj:getObj("online")
    if (onlineObj) then
        Net.updateOnlineGift(onlineObj);
    end

    --许愿树
    local wishObj = obj:getObj("wish")
    Net.updateWish(wishObj)

    --世界boss
    local bossObj = obj:getObj("wboss")
    Net.updateWorldBoss(bossObj)

    --公告
    if(obj:containsKey("noticeid")) then
        Net.updateNoticeRedpos(obj:getInt("noticeid"));
    end

    --限时活动，招财猫
    local catObj = obj:getObj("cat")
    if (catObj) then
        Data.activityCat.lefttime = catObj:getInt("time");
        Data.activityCat.lv = catObj:getByte("lv");
        Data.activityCat.rtime = gGetCurServerTime()
    else
        Data.activityCat.lefttime = 0;
        Data.activityCat.lv = 0;
    end

    Net.updateMyFamilyInfo(obj:getObj("family"));
    if(gFamilyInfo.familyId == 0)then
        gDispatchEvt(EVENT_ID_FAMILY_EXIT);
    end

    Net.updateAllBathObj(obj:getObj("allbath"));
    Net.updateSceneArenaObj(obj:getObj("arena1"));
    updateFamilyCallSpringInfo(obj:getObj("call"));

    gRollNoticeLayer:reSetRollNotice()
    gNoRollNoticeLayer:reSetRollNotice()
    Data.rollNoticeList = {}
    Data.noRollNoticeList = {}
    Net.sendSystemRollNotice()

    if ( obj:getObj("uvobj")) then
        Net.parseUserInfo(obj:getObj("uvobj"))
    end
    Net.sendChatInit()
end

function Net.sendSystemRollNotice()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_SYSTEM_SYSROLLNOTICE)
end

function Net.recSystemRollNotice(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- print("=----------------recSystemRollNotice")

    local notice = {}
    notice.content = obj:getString("content")
    notice.endtime = obj:getInt("endtime")
    notice.pos = obj:getByte("pos")
    notice.priority = obj:getInt("priority")
    notice.num = obj:getInt("num")
    notice.interval = obj:getInt("interval")
    notice.insertTime = os.clock()
    notice.show_time = 0
    -- showtype 0:滚动，1：不滚动
    notice.showType = obj:getByte("showtype")
    if (obj:containsKey("uid")) then
        notice.userid = obj:getLong("uid")
    else
        notice.userid = 0
    end
    if (obj:containsKey("id")) then
        notice.id = obj:getInt("id")
    end

    if (notice.num==0) then--无限循环
        -- notice.num = 9999999;
        notice.num = -100;
    end

    -- print_lua_table(notice)
    -- 解析消息里的道具
    notice.content = gParserMsgTxt(notice.content)

    --判断如果有了替掉
    if notice.showType == 0 then
        for k,v in pairs(Data.rollNoticeList) do
            if (v.id and notice.id and (notice.id==v.id)) then
                table.remove(Data.rollNoticeList,k)
                break
            end
        end
        table.insert(Data.rollNoticeList,notice);
    else
        for k,v in pairs(Data.noRollNoticeList) do
            if (v.id and notice.id and (notice.id==v.id)) then
                table.remove(Data.noRollNoticeList,k)
                break
            end
        end
        table.insert(Data.noRollNoticeList,notice)
    end
-- end
-- print(">>>>>>>>>>>");
-- print_lua_table(Data.rollNoticeList)
-- print("<<<<<<<<");

-- gDispatchEvt(EVENT_ID_SYSTEM_ROLL_NOTICE,notice.priority)
end

function Net.updateOnlineGift(obj)
    if (obj) then
        Data.m_onlineInfo.iLv = obj:getByte("lv")
        Data.m_onlineInfo.iTime = obj:getInt("time")
        Data.m_onlineInfo.rTime = gGetCurServerTime();

        Data.m_onlineInfo.bolShowRedPoint = false;
        if (Data.m_onlineInfo.iTime<=0) then
            Data.m_onlineInfo.bolShowRedPoint = true;
        end

        Data.m_onlineInfo.bolOnline = true;
        if (Data.m_onlineInfo.iLv>=table.getn(DB.getOnlineGift())) then
            Data.m_onlineInfo.bolOnline = false;
            Data.m_onlineInfo.bolShowRedPoint = false;
        end
        gDispatchEvt(EVENT_ID_ONLINE_GIFT_REFRESH)
    end
end

--标记当前教学
function Net.sendCurGuide(guideid)
    local media=MediaObj:create();
    media:setInt("id",guideid);
    Net.sendExtensionMessage(media, "sys.teach",false,false);
end
--解锁模块
function Net.setSysUnlock(sysid)
    local media=MediaObj:create();
    media:setByte("id",sysid);
    Net.sendExtensionMessage(media, "sys.unlock",false,false);
end
--标记模块
function Net.setSysEnter(id)
    local media=MediaObj:create();
    media:setByte("id",id);
    Net.sendExtensionMessage(media, "sys.unlock2",false,false);
end

--点石初始化成金
function Net.sendInitBuyGold()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_TURNGOLD_INIT)
end


function Net.recInitBuyGold(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.setUsedTimes(VIP_STONEGOLD,obj:getShort("num"));
    -- Data.remainBuyGoldNum=obj:getShort("num")
    gDispatchEvt(EVENT_ID_INIT_BUY_GOLD)
end





--点石成金
function Net.sendBuyGold(more)
    local media=MediaObj:create()
    media:setBool("more",more)
    Net.sendExtensionMessage(media, CMD_TURNGOLD_USE)
end

function Net.rec_rec_chkupd(evt)
    if AssetsUpdate and  AssetsUpdate:sharedAssetsUpdate().checkNeedUpdate then
        AssetsUpdate:sharedAssetsUpdate().nErrorCode = ERROR_NO
        AssetsUpdate:sharedAssetsUpdate():checkNeedUpdate()
    end

end

function Net.recBuyGold(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    local critArrays=obj:getByteArray("crit")
    ret={}
    if(critArrays)then
        critArrays:resetPos()
        for i=0, critArrays:getLen()-1 do
            table.insert( ret,critArrays:getByte())
        end
    end

    -- Data.remainBuyGoldNum=obj:getShort("num")
    -- Data.setUsedTimes(VIP_STONEGOLD,obj:getShort("num"));
    Net.parserVipBuy(obj:getObj("vipbn"));
    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_INIT_BUY_GOLD,ret)


    -- if not Data.getSysIsUnlock(SYS_TURN_GOLD) then
    --     Unlock.setSysUnlock(SYS_TURN_GOLD);
    -- end
end




--购买体力
function Net.sendBuyEnergy()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ITEM_DIAMOND_BUY_HP)
end


function Net.recBuyEnergy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Net.parserVipBuy(obj:getObj("vipbn"))
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    gDispatchEvt(EVENT_ID_GOLBAL_BUY)
end

--购买经验
function Net.sendBuyExp()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "item.dce")
end


function Net.rec_item_dce(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Net.parserVipBuy(obj:getObj("vipbn"))
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    gDispatchEvt(EVENT_ID_GOLBAL_BUY)
end


--购买兽魂
function Net.sendBuyPetSoul()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "item.dps")
end


function Net.rec_item_dps(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Net.parserVipBuy(obj:getObj("vipbn"))
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    gDispatchEvt(EVENT_ID_GOLBAL_BUY)
end


--购买无尽徽章
function Net.sendBuyTowerMoney()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "item.dtow")
end


function Net.rec_item_dtow(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Net.parserVipBuy(obj:getObj("vipbn"))
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    gDispatchEvt(EVENT_ID_GOLBAL_BUY)
end

--购买金钥匙
function Net.sendBuyPetGoldBox(num)
    local media=MediaObj:create()
    media:setInt("num",num);
    Net.sendExtensionMessage(media, "pet.gbbuy");
end

function Net.rec_pet_gbbuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Net.parserVipBuy(obj:getObj("vipbn"))
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    gDispatchEvt(EVENT_ID_BUY_GOLDBOX)    
end


function Net.sendGetTestBat()
    local media=MediaObj:create()
    media:setLong("id1",10010000000000)
    media:setLong("id2",10010000000003)
    Net.sendExtensionMessage(media, CMD_TEST_BATTLE)
end



function Net.recGetTestBat(evt)
    local obj = evt.params:getObj("params")
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_TEST)
end


function Net.sendSystemHandShake()
    if(Net.isConnected==true)then
        local media=MediaObj:create()
        Net.sendExtensionMessage(media, CMD_SYSTEM_HANDSHAKE,false,false)
    end
end



--system retime
function Net.sendSystemRetime(type)

    local media=MediaObj:create()
    print("system retime "..type)
    media:setInt("type",type)
    Net.sendExtensionMessage(media, CMD_SYSTEM_RETIME)
end


function Net.recSystemRetime(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.parseUserInfo(obj:getObj("uvobj"))
    if(obj:containsKey("time"))then
        gSetServerTime(obj:getInt("time"))
    end

end

-- const string CMD_GIFTBAG_GET_ONLINE = "giftb.getol";//领取在线礼包
function Net.sendGiftbagGetOnline()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "giftb.getol")
end

function Net.rec_giftb_getol(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateOnlineGift(obj:getObj("online"));
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_ONLINE_GIFT_GET)
end





function Net.sendGiftInit()
    local media=MediaObj:create()
    media:setBool("fr", true)
    Net.sendExtensionMessage(media, CMD_GIFTBAG_INIT)
end



function Net.recGiftInit(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gGiftBagAct={}
    gGiftBagBuy={}
    gGiftPay={}

    local listArray=obj:getArray("list")
    listArray=tolua.cast(listArray,"MediaArray")
    if(listArray)then
        for i=0, listArray:count()-1 do
            local obj=listArray:getObj(i)
            obj=tolua.cast(obj,"MediaObj")
            table.insert(gGiftBagBuy,{itemid=obj:getInt("id"),num=obj:getInt("num")})
        end
    end

    gGiftPay.idx=obj:getByte("siwidx")
    gGiftPay.daymoney=obj:getInt("daymoney")/100

    local action = {}
    local acts=obj:getArray("acts")
    acts=tolua.cast(acts,"MediaArray")
    if(acts)then
        for i=0, acts:count()-1 do
            local obj=acts:getObj(i)
            obj=tolua.cast(obj,"MediaObj")
            table.insert(action,{type=obj:getInt("type"),stime=obj:getInt("stime"),etime=obj:getInt("etime")})
        end
    end

    --[[   if (obj->containsKey("alist")) {
    DataBase::shared()->m_vGiftBagAct.clear();
    MediaArray *alist = obj->getArray("alist");
    for (int i=0; i<alist->count(); i++) {
    MediaObj *obj = (MediaObj*)alist->getObj(i);
    if (obj) {
    DTGiftBagAct act;
    act.boxID = obj->getInt("boxid");
    act.maxBuy = obj->getInt("limitbuynum");
    act.status = obj->getByte("status");
    act.num = obj->getInt("num");
    act.orliPrice = obj->getInt("orliprice");
    act.curPrice = obj->getInt("curprice");
    act.introduce = obj->getString("introduce");
    act.cType = obj->getByte("limittype");
    act.cBuyLv = obj->getInt("limitpara");
    act.sTime = obj->getInt("starttime");
    act.eTime = obj->getInt("endtime");
    act.sortID = obj->getInt("sortid");
    act.pricetype = obj->getByte("pricetype");
    DataBase::shared()->m_vGiftBagAct.push_back(act);
    }
    }
    }
    ]]
    gDispatchEvt(EVENT_ID_GIFT_GIFT_INIT,action)
end

function Net.sendGiftBuy(boxid)
    local media=MediaObj:create()
    media:setInt("boxid", boxid)
    Net.sendExtensionMessage(media, CMD_GIFTBAG_BUY)
end



function Net.recGiftBuy(evt)

    print("Net.recGiftBuy(evt)");

    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.addGiftBagBuy(obj:getInt("boxid"),1)
    Net.updateReward(obj:getObj("reward"),2)


    local count = 0;
    for key,var in pairs(vip_db) do
        if(Data.getCurVip() >= toint(var.vip))then
            local item= Data.getGiftBagBuy(var.boxid)
            if(item and item.num<=0)then
                count = count + 1;
            end
        end
    end
    -- print("getCanBuyVipGiftCount count = "..count);
    if(count <= 0)then
        Data.redpos.vipgift = false;
    end

    -- count = 0
    -- local gift=DB.getVipDayGift()
    -- for key, var in pairs(gift) do
    --     if(Data.getCurVip() >= toint(var.limitpara))then
    --         local item= Data.getGiftBagBuy(var.boxid)
    --         if(item and item.num<=0)then
    --             count = count + 1;
    --         end
    --     end
    -- end
    -- if(count <= 0)then
    --     Data.redpos.vipDaygift = false;
    -- end

    gDispatchEvt(EVENT_ID_GIFT_BAG_GOT)

    --  local list={}
    --  table.insert(list,{itemid=obj:getInt("boxid"),num=1})
    --  Panel.popUp(PANEL_GET_REWARD,{items=list})
end


function Net.sendIapCheckMissOrder()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_IAP_CHECKMISSORDER)
end

function Net.recIapCheckMissOrder()

end

function Net.sendIapBuy(index)
    local media=MediaObj:create()
    media:setInt("id", index)
    media:setString("mac", gAccount:getMacAddress());
    media:setString("udid", gAccount:getDeviceId());
    Net.sendExtensionMessage(media, CMD_IAP_BUY)
end


Net.orderId="0"
Net.iapId=0
Net.iIapCheckCount=0
Net.isCheckingOrder=false
Net.g_sys_ischeckIap=false
Net.g_sys_isreceipt=false
Net.g_rereceiptIndex = 0
function Net.recIapBuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local orderId = obj:getString("oid")
    PayItem.pay(orderId)
    Net.orderId=orderId
end

function Net.sendCheckOrder(orderId,iapId)
    local media=MediaObj:create()
    media:setString("oid", orderId)
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and iapId ~= nil)then
        Net.iapId=iapId
        media:setInt("iapid", toint(Net.iapId))
        -- local userId= gAccount:getCurRole().userid
        -- local serverId =gAccount:getCurRole().serverid
        -- local platformId = gAccount:getPlatformId()
        -- Net.addReceipt("",userId,serverId,platformId,orderId,"","",iapId)
    end

    Net.iIapCheckCount=0
    Net.isCheckingOrder=true
    Net.sendExtensionMessage(media, CMD_IAP_CHECKORDER)
end


function Net.reSendCheckOrder()
    Net.g_sys_isreceipt=false
    local userid = gAccount:getCurRole().userid
    local rootjson = cc.UserDefault:getInstance():getStringForKey(userid, "{}")
    local rootTable = json.decode(rootjson)
    local serverid = gAccount:getCurRole().serverid
    local platformid = gAccount:getPlatformId()
    local receipt = ""
    local payUrl = ""
    local oid = ""
    local sign = ""
    local orderid = ""
    local iapid = ""
    if Net.g_rereceiptIndex <0 or Net.g_rereceiptIndex>= #(rootTable) then
        return
    end
    local valueTable = json.decode(rootTable[Net.g_rereceiptIndex+1])
    if valueTable.serverid == serverid and  valueTable.platform == platformid then
        receipt = valueTable.receipt
        payUrl = valueTable.payurl
        oid = valueTable.oid
        sign = valueTable.sign
        orderid = valueTable.oid
        iapid = valueTable.iapid
    end

    Net.g_rereceiptIndex = Net.g_rereceiptIndex +1
    Net.g_sys_isreceipt=true;

    local media=MediaObj:create()
    media:setString("oid", orderid)
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        media:setInt("iapid", toint(iapid))
    end
    Net.sendExtensionMessage(media, CMD_IAP_CHECKORDER)
    -- print("========reSendCheckOrder======== orderid = "..orderid.." iapid = "..iapid)
end

function Net.sendCheckOrderRepeat()
    local media=MediaObj:create()
    media:setString("oid", Net.orderId)
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        media:setInt("iapid", toint(Net.iapId))
    end
    Net.iIapCheckCount=Net.iIapCheckCount+1
    Net.isCheckingOrder=true
    Net.sendExtensionMessage(media, CMD_IAP_CHECKORDER)
end

--腾讯客户端手动补单
function Net.sendCheckOrderMiss(orderid,iapid,miss)
    local media=MediaObj:create()
    media:setString("oid", orderid)
    media:setInt("iapid", iapid)
    media:setBool("miss", miss)
    Net.iIapCheckCount = 999 --不轮询，只发送一次
    Net.sendExtensionMessage(media, CMD_IAP_CHECKORDER)
end


function Net.recCheckOrder(evt)
    print ("Net.recCheckOrder>>>")
    local obj = evt.params:getObj("params")
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and (obj:getByte("ret") == 9 or obj:getByte("ret") == 16 or obj:getByte("ret") == 17 or obj:getByte("ret") == 26))then
        -- local oid = obj:getString("oid")
        -- if(oid ~= nil)then
        --     local isRemove = Net.removeReceipt(oid)
        --     if(isRemove == true) then
        --         gDispatchEvt(EVENT_ID_PAY_CHECK_ORDER_MISS)
        --     end
        -- end
    end
    if(obj:getByte("ret")~=0)then
        return
    end
    local oid = obj:getString("oid")
    local money = obj:getInt("money")
    -- if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and oid ~= nil)then
    --     Net.removeReceipt(oid,true)
    --     gDispatchEvt(EVENT_ID_PAY_CHECK_ORDER_MISS)
    -- end
    Net.isCheckingOrder=false
    -- print("recCheckOrder....111111111...."..Net.orderId)
    if Data.isFirstPay() then
        gConfirm(gGetWords("vipWords.plist","firstPay"));
    end
    -- print ("td confirm order:" .. oid)
    -- if (TDGAVirtualCurrency) then
    --     TDGAVirtualCurrency:onChargeSuccess(oid)
    -- end
    if (money == 0 and (gPayInfo[oid] ~= nil)) then
        money = gPayInfo[oid]
    end
    if (gOnAdPay) then
        gOnAdPay(gUserInfo.id, oid, money, "CNY", "钻石")
    end

    for i=0, 9 do
        if(obj:containsKey("iap"..i))then
            gIapBuy["iap"..i]=true
            if(i==6)then
                gIapBuy["mctime"]=obj:getInt("mctime")
            end
        end
    end
    Net.parseUserInfo(obj:getObj("uvobj"));

-- local diamond = obj:getInt("diamond");
-- gUserInfo.diamond= gUserInfo.diamond+diamond;
-- gUserInfo.iapbuy = gUserInfo.iapbuy + diamond;
-- if(obj:containsKey("uvobj"))then
--     Net.parseUserInfo(obj:getObj("uvobj"))
-- else
--     local charge = obj:getInt("charge");
--     gUserInfo.vipsc = gUserInfo.vipsc + charge;
--     Data.activityPayData.var = gUserInfo.vipsc
--     gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
-- end
end


function Net.addReceipt(payUrl,userid,serverid,platformid,orderid,receipt,sign,iapid)
    local rootjson = cc.UserDefault:getInstance():getStringForKey(userid, "{}")
    local rootTable = json.decode(rootjson)

    local data={}
    data.receipt=receipt
    data.oid=orderid
    data.sign=sign
    data.serverid=serverid
    data.userid=userid
    data.platform=platformid
    data.payurl=payUrl
    data.time=gGetCurServerTime()
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and iapid ~= nil)then
        data.iapid=iapid
    end
    local str = json.encode(data)
    print("-----------addreceipt--------"..orderid)
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        table.insert(rootTable,1,str)
    else
        table.insert(rootTable,str)
    end
    local ret = json.encode(rootTable)
    print(ret)
    cc.UserDefault:getInstance():setStringForKey(userid, ret)
end

function Net.removeReceipt(orderid,forceRemove)
    print("-----------removeReceipt--------")
    if orderid then
        orderid =""..orderid
    end
    if forceRemove == nil then
        forceRemove = false
    end
    local userid = gAccount:getCurRole().userid
    local rootjson = cc.UserDefault:getInstance():getStringForKey(userid, "{}")
    local rootTable = json.decode(rootjson)
    local isRemove = true
    for key,value in pairs(rootTable) do
        local valueTable = json.decode(value)
        if valueTable.oid == orderid  then
            if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
                local dayTime=6*60*60
                if(forceRemove == false and valueTable.time ~= nil and gGetCurServerTime() - valueTable.time < dayTime)then
                    isRemove = false;
                end
            end
            if isRemove then
                table.remove(rootTable,key)
                Net.g_rereceiptIndex = Net.g_rereceiptIndex -1
            end
            break;
        end
    end
    local ret = json.encode(rootTable)

    cc.UserDefault:getInstance():setStringForKey(userid, ret)
    return isRemove;
end


local function  payCallBack(responseText)
    local ret= cjson.decode(responseText)
    if ret and ret.ret==0 then
        Net.removeReceipt(ret.oid,true)
        Net.sendCheckOrder(ret.oid)
    end
    Net.g_sys_isreceipt=true
    Scene.hideWaiting()
end

function Net.reSendIapCheckReceipt()
    Net.g_sys_isreceipt=false
    local userid = gAccount:getCurRole().userid
    local rootjson = cc.UserDefault:getInstance():getStringForKey(userid, "{}")
    local rootTable = json.decode(rootjson)
    local serverid = gAccount:getCurRole().serverid
    local platformid = gAccount:getPlatformId()
    local receipt = ""
    local payUrl = ""
    local oid = ""
    local sign = ""
    if Net.g_rereceiptIndex <0 or Net.g_rereceiptIndex>= #(rootTable) then
        return
    end
    local valueTable = json.decode(rootTable[Net.g_rereceiptIndex+1])
    if valueTable.serverid == serverid and  valueTable.platform == platformid then
        receipt = valueTable.receipt
        payUrl = valueTable.payurl
        oid = valueTable.oid
        sign = valueTable.sign
    end


    Net.g_rereceiptIndex = Net.g_rereceiptIndex +1
    local data={}
    data.receipt=receipt
    data.oid=oid
    data.sign=sign
    data.serverid=gAccount:getCurRole().serverid
    data.userid=gAccount:getCurRole().userid
    data.platform=gAccount:getPlatformId()
    local str=gAccount:tableToString(data)
    print("========reSendIapCheckReceipt111========"..str)
    gAccount:getHttp(payUrl,"POST",str, payCallBack)
end


local lastOrderid="0"
--local payUrl=""
function Net.sendIapCheckReceipt(payUrl,orderid,receipt,sign)
    Scene.showWaiting()
    if lastOrderid == orderid then
        return
    end
    lastOrderid= orderid
    local  userId= gAccount:getCurRole().userid
    local serverId =gAccount:getCurRole().serverid
    local platformId = gAccount:getPlatformId()
    Net.addReceipt(payUrl,userId,serverId,platformId,orderid,receipt,sign)
    local data={}
    data.receipt=receipt
    data.oid=orderid
    data.serverid=serverId
    data.userid=userId
    data.platform=platformId
    data.sign=sign
    local str=gAccount:tableToString(data)
    Net.g_rereceiptIndex = 1
    gAccount:getHttp(payUrl,"POST",str,payCallBack)
end


function Net.recIapCheckReceipt(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
end

function Net.sendIapCancel(orderid)
    local media=MediaObj:create()
    media:setString("oid", orderid)
    Net.sendExtensionMessage(media, CMD_IAP_CANCEL)
end


function Net.recIapCancel(evt)

end


function Net.sendOpenBox(boxid,num,itemid)
    if NetErr.isItemEnough(boxid,num)==false then
        return;
    end
    local media=MediaObj:create()
    media:setInt("boxid", boxid)
    media:setInt("num", num)
    if itemid~=nil then
        media:setInt("itemid", itemid)
    end
    Net.sendExtensionMessage(media, "item.obn")
end

function Net.rec_item_obn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.reduceItemNum(obj:getInt("boxid"),obj:getInt("num"))
    local list= Net.updateReward(obj:getObj("reward"),0 );
    list =gMultMergeItem(list)
    Panel.popUpVisible(PANEL_GET_REWARD,list,1);
    gDispatchEvt(EVENT_ID_UPDATE_REWORDS)

end

function Net.sendUseItem(itemid,num)
    if NetErr.isItemEnough(itemid,num)==false then
        return;
    end
    local media=MediaObj:create()
    media:setInt("itemid", itemid)
    media:setInt("num", num)
    Net.sendUseItemParam=num
    Net.sendUseItemId = itemid;
    Net.sendExtensionMessage(media, CMD_ITEM_USE)
end



function Net.recUseItem(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.reduceItemNum(obj:getInt("itemid"), Net.sendUseItemParam)

    local bOpenBox = false;
    local bShowGetReward = 2;
    if(Net.sendUseItemId == BOX_KEY_ID1 or Net.sendUseItemId == BOX_KEY_ID2 or Net.sendUseItemId == BOX_KEY_ID3) then
        bOpenBox = true;
        bShowGetReward = 0;
    end

    local list = Net.updateReward(obj:getObj("reward"),bShowGetReward);
    if bOpenBox then
        gDispatchEvt(EVENT_ID_PET_BOXOPEN,{items = list.items,id = Net.sendUseItemId});
    end

    gCrusadeData.crunum=obj:getInt("crunum")
    gDispatchEvt(EVENT_ID_CRUSADE_BUY)
    gDispatchEvt(EVENT_ID_UPDATE_REWORDS_DIRECT)
    local itemid=obj:getInt("itemid")
    if(gGetWords("noticeWords.plist","use_item_name_"..itemid)~="")then
        gShowNotice(gGetWords("noticeWords.plist","use_item_name_"..itemid,Net.sendUseItemParam))

    end

end

--- 红点处理
function Net.recReceivePrompt(evt)

    local obj = evt.params:getObj("params")
    Net.updatePrompt(obj);
end

function Net.recReceiveReward(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),0)
    end
end

function Net.rec_rec_push(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret == 0 then
        Net.updateAllBathObj(obj:getObj("allbath"));
        if(obj:containsKey("call"))then
            updateFamilyCallSpringInfo(obj:getObj("call"));
        end
        Net.updateSceneArenaObj(obj:getObj("arena1"));
        Net.updateRedPackage(obj:getObj("redpack"));

        if(obj:containsKey("turn"))then
            local turnObj=obj:getObj("turn")
            gLuckWheel.endTime=turnObj:getInt("turnend")
            gLuckWheel.startTime=turnObj:getInt("turnstart") 

        end
    end
end

function Net.updateRedPackage(obj)
    if(obj==nil)then
        return;
    end
    
    if( Data.loopPackNum>=DB.getClientParam("ACT_REDPACK_LOOT_NUM"))then
        return
    end
    local id=obj:getLong("id")
    local name=obj:getString("name")
    Data.hasRedPack=true
    local showRain=false
    if(gMainLayer and table.count(Panel.popPanels)==0)then
        showRain=true
    end

    if(Guide.isGuiding())then
        showRain=false
    end

    if(Data.packRainTime~=nil and gGetCurServerTime()-Data.packRainTime<DB.getClientParam("ACT_REDPACK_INTERVAL_TIME"))then
        showRain=false
    end

    if(showRain)then
        Data.packRainTime=gGetCurServerTime()
        Panel.popUpVisible(PANEL_RED_PACKAGE_RAIN,name,id,false);
    else
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_NEW_PACKAGE,{name=name,id=id})

    end


    --
end

function Net.sendSysChangeIcon(icon,frame)
    -- body
    local media=MediaObj:create()
    if icon ~= nil then
        print("changeicon = "..icon);
        media:setInt("icon", icon)
    end
    if frame ~= nil then
        print("changeframe = "..frame);
        media:setInt("frame", frame)
    end
    Net.sendExtensionMessage(media, "sys.changeicon");
end

function Net.rec_sys_changeicon(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.parseUserInfo(obj:getObj("uvobj"));
    gDispatchEvt(EVENT_ID_ICON_CHANGE);
end

function Net.sendSystemChangeSign(sign)
    local media=MediaObj:create()
    media:setString("sword", sign);
    Net.sendExtensionMessage(media, "sys.changesword");
end
function Net.rec_sys_changesword(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.parseUserInfo(obj:getObj("uvobj"));
    gDispatchEvt(EVENT_ID_FRIEND_MODIFY_SIGN);
end

function Net.sendItemExGift(key)
    local media=MediaObj:create()
    media:setString("key", key);
    Net.sendExtensionMessage(media, "item.exgift");
end
function Net.rec_item_exgift(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),1)
    gDispatchEvt(EVENT_ID_ITEM_EXGIFT);
end
function Net.recIapMissOrder(evt)
    Net.recCheckOrder(evt);
end

function Net.sendIapInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "iap.info");
end

function Net.rec_iap_info(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- print_lua_table(gIapBuy);
    -- print("----------");
    for i=0, 7 do
        gIapBuy["iap"..i]=obj:getBool("iap"..i);
    end
    -- print_lua_table(gIapBuy);
    -- print("+++++++++++++++");
    gDispatchEvt(EVENT_ID_PAY_ENTER);
end

function Net.sendSystemGetemail()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "sys.getemail");
end

function Net.rec_sys_getemail(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gUserInfo.email = obj:getString("email");
    print("gUserInfo.email = "..gUserInfo.email);
    gDispatchEvt(EVENT_ID_REFRESH_EAMIL);
end

function Net.sendSystemBindEmail(email)
    local media=MediaObj:create()
    media:setString("email",email);
    UserInfoPanelData.email = email;
    Net.sendExtensionMessage(media, "sys.bindemail");
end

function Net.rec_sys_bindemail(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gUserInfo.email = UserInfoPanelData.email;
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_REFRESH_EAMIL);
end

--购买光环
function Net.sendSystemBuyHalo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "sys.buyhalo");
end
function Net.rec_sys_buyhalo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gUserInfo.halo = obj:getByte("halo")
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_BUY_HALO);
end

-- CMD_SYSTEM_REFRESH_TENCENT_PARAM = "sys.refpam"; //刷新腾讯的登录参数
function Net.sendSystemRefreshParams()
    print("Net.sendSystemRefreshParams")
    local media=MediaObj:create()
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        local tencentObj = MediaObj:create()
        tencentObj:setString("openid", gAccount.loginParams.openid);
        tencentObj:setString("openkey", gAccount.loginParams.openkey);
        tencentObj:setString("pay_token", gAccount.loginParams.pay_token);
        tencentObj:setString("pfkey", gAccount.loginParams.pfkey);
        tencentObj:setString("pf", gAccount.loginParams.pf);
        tencentObj:setString("atype", gAccount.loginParams.atype);
        media:setObj("tencent",tencentObj);
    end

    Net.sendExtensionMessage(media, "sys.refpam");
end

function Net.rec_sys_refpam(evt)
    print("Net.rec_sys_refpam")
end

-- CMD_SYSTEM_TENCENT_CHECK_BALANCE = "sys.chkbln"; //应用宝，查询余额
function Net.sendSystemTencentCheckBalance()
    print("Net.sendSystemTencentCheckBalance");
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "sys.chkbln");
end

function Net.rec_sys_chkbln(evt)
    print("Net.rec_sys_chkbln");
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gUserInfo.diamond = obj:getInt("diamond")

    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end

---推送广告信息
--CMD_RECEIVE_ADVER = "rec.adver"
function Net.rec_rec_adver(evt)
    -- print("Net.rec_sys_chkbln");
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local adversList = obj:getArray("list")
    if nil ~= adversList then
        Data.clearAdvertises()

        adversList = tolua.cast(adversList, "MediaArray")
        for i = 0, adversList:count()-1 do
            local adverInfo = tolua.cast(adversList:getObj(i), "MediaObj")
            if nil ~= adverInfo then
                local endTime = adverInfo:getInt("endtime")
                local aid = adverInfo:getInt("aid")
                local sortid = adverInfo:getInt("sortid")
                local param1 = nil
                if adverInfo:containsKey("param") then
                    param1 = adverInfo:getInt("param")
                end
                local param2 = nil
                if adverInfo:containsKey("num") then
                    param2 = adverInfo:getInt("num")
                end

                Data.addAdvertise(endTime,aid,sortid,param1,param2)
            end
        end

        Data.sortAdvertises()
    end
end

function Net.sendSystemLanguage(Language)
    local media=MediaObj:create()
    LanguageSetPanelData.language = Language;
    local lan = 1;
    if(Language == LANGUAGE_ZHS)then
        lan = 1;
    elseif(Language == LANGUAGE_EN)then
        lan = 2;
    end
    media:setByte("type",lan);
    Net.sendExtensionMessage(media, "sys.language");    
end

function Net.rec_sys_language(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.saveLanguageSet(LanguageSetPanelData.language);
    print("xxxxx");
    if GlobalEvent~=nil and GlobalEvent:sharedGlobalEvent().restartGame then
        print("restartGame");
        GlobalEvent:sharedGlobalEvent():restartGame();
    end    
end

-- 冒险列表(世界boss,幻境寻宝，抢仓夺粮)
CMD_SYSTEM_ANVENTURE_LIST="sys.advlist"
function Net.sendSysAdvlist()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_SYSTEM_ANVENTURE_LIST)
end

function Net.rec_sys_advlist(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local list = obj:getArray("list")
    for i = 0, list:count() - 1 do
        local huntObj = list:getObj(i)
        if nil ~= huntObj then
            huntObj = tolua.cast(huntObj,"MediaObj")
            if huntObj:getByte("type") == 0 then
                Data.worldBossInfo.status = huntObj:getByte("status")
            end
        end
    end

    Data.clearHuntIntervalInfos()
    Data.setHuntIntervalInfos()
    Panel.popUp(PANEL_HUNT)
    if nil ~= gMainBgLayer then
        gMainBgLayer:setExploreType(Data.finalHuntIntervalInfos[2].huntId)
    end
end

--获得奖励列表
function Net.sendIphoneGift()
    local media = MediaObj:create()
    Net.sendExtensionMessage(media,"sys.phonegift")
end

function Net.rec_sys_phonegift(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local giftItemList = {}
    local list = obj:getArray("gift")
    for i = 0, list:count() - 1 do
        local gitfObj = list:getObj(i)
        if nil ~= gitfObj then
            gitfObj = tolua.cast(gitfObj,"MediaObj")
            local itemTable = {}
            itemTable.itemid=gitfObj:getInt("itemid")
            itemTable.num=gitfObj:getInt("num")
            table.insert(giftItemList,itemTable)
        end
    end
    gDispatchEvt(EVENT_ID_BIND_PHONE_GETGIF, giftItemList)
end

--领取奖励
function Net.sendGetIphoneGift(phone,code)
    local media = MediaObj:create()
     media:setInt("code", code)
     media:setLong("phone", phone)
    Net.sendExtensionMessage(media,"sys.getphonegift")
end

function Net.rec_sys_getphonegift(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_SHOW_BIND_PHONE)
end


