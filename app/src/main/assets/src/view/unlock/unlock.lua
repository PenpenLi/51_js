Unlock = {}
Unlock.stack = {};
Unlock.system = {};

SYS_SHOP             = 1;	--神秘商人
SYS_ELITE_ATLAS      = 2;	--精英副本
SYS_TURN_GOLD        = 3;	--点石成金
SYS_TASK             = 4;	--任务
SYS_SKILL            = 5;	--武将技能
SYS_FRIEND           = 6;	--好友
SYS_ACT_GOLD         = 7;	--试炼场-金币
SYS_ACT_EXP          = 8;	--试炼场-经验
SYS_ACT_PETSOUL      = 9;	--试炼场-神兽丹
SYS_ARENA            = 10;--竞技场
SYS_FAMILY           = 11;--军团
SYS_PET_TOWER        = 12;--卧龙窟
SYS_PET              = 13;--神兽
SYS_BATTLE_SPEEDUP   = 14;--战斗加速

SYS_PET_SKILL        = 15;--神兽技能
SYS_PET_STAR         = 16;--神兽升星
SYS_ATLAS_BOX        = 17;--副本奖励保险

SYS_ATLAS            = 18;--副本远征
SYS_TOWER            = 19;--无尽之塔
SYS_EXPEDITION       = 20;--外域远征
SYS_MAIL             = 21;--邮件
SYS_CARD             = 22;--点将台
SYS_ACT              = 23;--试炼场大入口
SYS_PET_FORMATION    = 24; --神兽布阵
SYS_SWEEP            = 25;--多次扫荡
SYS_QUICKUPGRADE     = 26;--一键强化
SYS_FUND             = 27;--养成基金
SYS_SHOP2            = 28;--奸商
SYS_SHOP3            = 29;--黑市
SYS_TRAINVIPROOM     = 30;--vip训练房
SYS_TRAINROOM        = 31;--训练房
SYS_BATH             = 32;--修仙
SYS_FAMILY_SPRING    = 33;--军团泉水
SYS_FAMILY_SEVEN     = 34;--军团封魔
SYS_BATTLE_AUTO      = 35;--自动战斗
SYS_XUNXIAN          = 36;--寻仙系统
SYS_CHAT             = 37;--聊天
SYS_SPIRIT_QUICK     = 38;--一键寻仙
SYS_CRUSADE          = 39;--叛军
SYS_ACT_WISH         = 40;--许愿树
SYS_DRAWSOUL         = 51;--魂匣
SYS_MINE_PROJ2       = 52;--挖矿工程2
SYS_MINE_PROJ3       = 53;--挖矿工程3
SYS_MINE_PROJ4       = 54;--挖矿工程4
SYS_MINE_PROJ4       = 55;--挖矿工程5
SYS_FAMILY_SKILL     = 56;--图腾
SYS_MINE             = 57;--挖矿入口
SYS_WEAPON           = 58;--神器入口
SYS_WEAPON_TRANSFORM = 59;--神器转移
SYS_SHOP_SOUL        = 60;--将星商店
SYS_CARDAWAKE        = 61;--觉醒
SYS_FAMILY_WAR       = 62;--家族战
SYS_WORLD_BOSS       = 63;--世界BOSS
SYS_BOSS_ATLAS       = 64; --魔王副本
SYS_SERVER_BATTLE    = 65; --跨服战
SYS_SWEEP_ONE        = 66; --单次扫荡
SYS_TRANSMIT_CARD    = 67; --回炉
SYS_DRAGON_BALL_EXCHANGE    = 68; --兑换龙珠
SYS_ACT_EQUSOUL      =69;
SYS_MINE_BLACKMARKET = 70 --海底黑市商店
SYS_CG               = 71 --CG开关
SYS_TREASURE         = 72  --宝物
SYS_TREASURE_UPGRADE = 73  --宝物强化
SYS_TREASURE_QUENCH  = 74  --宝物精炼
SYS_ACT_RECRUIT      = 75  --活动招募
SYS_HALO		     = 76  --幻灵守卫
SYS_LUCK_WHEEL       = 77  --幸运转盘
SYS_MINE_ATLAS       = 78  --海底副本
SYS_FAMILY_ORE		 = 79  --军团挖矿
SYS_FAMILY_STAGE     = 80  --军团竞赛
SYS_FAMILY_STAGE_BUFF_UP = 81 --军团buff鼓舞
SYS_EXCHANGE_CARD    = 82 --变身
SYS_TREASURE_HUNT = 83 --跨服寻宝
SYS_LOOT_FOOD = 84 --粮草战
SYS_TREASURE_HUNT_TEAM = 85 --跨服寻宝组队
SYS_CONSTELLATION = 86 --星宿系统
SYS_RICHMAN = 87 --探索
SYS_CONSTELLATION_FIGHT = 88 --星空系系统挑战
SYS_TOWN            = 89;--新版无尽之塔(只是用来标记新教学，功能性还是用旧的)
SYS_FAMILY_DONATE   =90 -- 军团捐赠
SYS_SNATCH_ACTIVITY  =91 -- 夺宝活动
SYS_ACT_ITEM_AWAKE  =92 -- 觉醒丹活动
SYS_ACT_QUICK_SWEEP  =93 -- 一键试炼
SYS_TREASURE_RISESTAR =94 --升星
SYS_PET_TALENT =95 --灵兽天赋
SYS_PET_CAVE =96 --灵兽探险
SYS_TREASURE_TRANSFORM =97 --宝物转移


SYS_TOWER_TYPE5  = 200;
SYS_TOWER_TYPE8  = 201;
SYS_TOWER_TYPE10 = 202;
SYS_TOWER_TYPE12 = 203;
SYS_TOWER_TYPE11 = 204;
--表现(开启和未开启)
function Unlock.showEnter(unlockSys)

end

--主页加锁
function Unlock.showMainBgEnter(unlockSys,isUnlock)
	if gMainBgLayer == nil then
		return;
	end
	local bg = gMainBgLayer:getBuildTitle(unlockSys);
	if(bg==nil)then
	   return
	end
	if isUnlock then 
		bg:removeChildByTag(100);
	else
		local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png");
		lock:setScale(0.5);
		gRefreshNode(bg,lock,cc.p(0.5,1.0),cc.p(0,0),100);
	end
end

--主页菜单加锁
function Unlock.showMenuEnter(unlockSys,isUnlock)
	
	if gMainLayer == nil then
		return;
	end

	local var = "";
	if unlockSys == SYS_PET then
		var = "btn_pet";
	elseif unlockSys == SYS_TASK then
		var = "btn_task";
	elseif unlockSys == SYS_FRIEND then
		var = "btn_friend";
	elseif unlockSys == SYS_XUNXIAN then
        var = "btn_xunxian";
    elseif unlockSys == SYS_WEAPON then
        var = "btn_weapon";
    elseif unlockSys == SYS_CONSTELLATION then
        var = "btn_constellation";
	end	
    local btn = gMainMoneyLayer:getNode(var);
	if btn == nil then
        btn = gMainLayer:getNode(var);
        if btn == nil then
		  return;
        end
	end

	if isUnlock then
		btn:removeChildByTag(100);
		DisplayUtil.removeGray(btn);
	else
		DisplayUtil.setGray(btn);
		local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png");
		lock:setScale(0.8);
		gRefreshNode(btn,lock,cc.p(0.75,0.45),cc.p(0,0),100);
	end
end

--未开放显示加锁或隐藏
function Unlock.initEnter()
	for key,var in pairs(Unlock.system) do
		if var.show then
			var.show();
		end
	end
end

function Unlock.isUnlock(unlockSys,isShowNotice)
	if isShowNotice == nil then
		isShowNotice = true;
	end
	for key,var in pairs(Unlock.system) do
		if var.unlockType == unlockSys then
 			if var.isUnlock then
				return var.isUnlock(isShowNotice);
			end
		end
	end
	return true;
end

function Unlock._isUnlockSys(id)
    local teach = DB.getTeachUnlock(id);
    if(teach)then
        return Data.isPassAtlas(teach.mapid,teach.stageid,0);
    end
    return false;	
end

function Unlock._isUnlockSysByAtlas(id,mapid,stageid)
    local teach = DB.getTeachUnlock(id);
    if(teach)then
    	if(mapid == toint(teach.mapid) and stageid == toint(teach.stageid))then
    		return true;
    	end
    end
    return false;	
end

function Unlock._isUnlockSysCommon(Unlockdbid,unlockSys,isShowNotice)
    local isUnlock = Unlock._isUnlockSys(Unlockdbid);
    if(isUnlock)then
        return true;
    elseif(isShowNotice)then
        local teach = DB.getTeachUnlock(Unlockdbid);
        local stage=DB.getStageById(teach.mapid,teach.stageid,0);
        if(stage)then
            local word = gGetWords("unlockWords.plist","unlock_tip_atlas",gParseZnNum(teach.mapid).."."..stage.name
            ,gGetWords("unlockWords.plist","name"..unlockSys));
            gShowNotice(word);
        end
    end
    return false;
end

function Unlock.getUnlockName(Unlockdbid)

	for key,var in pairs(Unlock.system) do
		if var.Unlockdbid and var.Unlockdbid == Unlockdbid then
		    if(Data.getSysIsUnlock(var.unlockType))then
		        return "";
		    end
			if(Unlock.checkSysSwitch(var.unlockType))then
				return gGetWords("unlockWords.plist","name"..var.unlockType);
			end
		end
	end

	return "";

end

function Unlock.checkSysSwitch(unlockType)
	local switchId = 0;
	if(unlockType == SYS_TOWER)then
		switchId = SWITCH_TOWER;
	elseif(unlockType == SYS_TREASURE)then
		switchId = SWITCH_TREASURE;
	elseif(unlockType == SYS_SERVER_BATTLE)then
		switchId = SWITCH_SERVER_BATTLE;	
	elseif(unlockType == SYS_HALO)then
		switchId = SWITCH_HALO;
    elseif(unlockType == SYS_BATH)then
        switchId = SWITCH_BATH;	
	end

	if(Module.isClose(switchId))then
		return false;
	end
	return true;
end

--检测开启条件
function Unlock.checkUnlock()

	for key,var in pairs(Unlock.system) do
		if var.checkUnlock then
			var.checkUnlock();
		end
	end

end

function Unlock.checkUnlockByAtlas(mapid,stageid)
	for key,var in pairs(Unlock.system) do
		if var.checkUnlock then
			var.checkUnlock(mapid,stageid);
		end
	end	
end

function Unlock.checkFirstEnter(unlockSys)
	for key,var in pairs(Unlock.system) do
		if var.unlockType == unlockSys then
 			if var.checkFirstEnter then
				return var.checkFirstEnter();
			end
		end
	end	
end

function Unlock.isShowUnlockPanel(unlockSys)

	if unlockSys == SYS_BATTLE_SPEEDUP 
	or unlockSys == SYS_PET_SKILL
	or unlockSys == SYS_PET_STAR
	or unlockSys == SYS_ATLAS_BOX
	or unlockSys == SYS_MINE 
	 then
	 return false;
	end

	return true;
end

function Unlock.show()

	-- print_lua_table(Unlock.stack);
	-- table.insert(Unlock.stack,SYS_ARENA);

	local count = table.getn(Unlock.stack);
	if count > 0 then
		local curUnlockType = Unlock.stack[1];
		Unlock.showUnlockPanel(curUnlockType);
		Unlock.setSysUnlock(curUnlockType)
		table.remove(Unlock.stack,1);
		-- if Unlock.isShowUnlockPanel(curUnlockType) then
		-- 	Unlock.showUnlockPanel(curUnlockType);
		-- else
		-- 	Unlock.guide(curUnlockType);
		-- end
		-- Unlock.setSysUnlock(curUnlockType)
		-- table.remove(Unlock.stack,1);
	end

end

function Unlock.showOtherUnlock(unlockSys)
	Unlock.guide(unlockSys);
	Unlock.setSysUnlock(unlockSys);
end

function Unlock.showUnlockPanel(curUnlockType)
    -- if gMainLayer then
    --     Panel.popBackAll();
    -- else
    --     Panel.clearRepopup()
    --     Scene.enterMainScene(); 
    -- end
    -- Unlock.initEnter();
    Panel.popUpVisible(PANEL_UNLOCK,curUnlockType,nil,true);
    
    --神兽强制前往   
    if(curUnlockType==SYS_PET or curUnlockType == SYS_TREASURE)then 
        Guide.dispatch(GUIDE_ID_ENTER_PET_PRE);
    end

end

function Unlock.setSysUnlock(unlockSys)
	table.insert(gUnlockSys,unlockSys);
	Net.setSysUnlock(unlockSys);	
end

function Unlock.setSysEnter(unlockSys)
	table.insert(gEnterSys,unlockSys);
	Net.setSysEnter(unlockSys);		
end

function Unlock.preGuide(unlockSys)

    for key,var in pairs(Unlock.system) do
        -- print("unlockSys = "..unlockSys);
        -- print("var.unlockType = "..var.unlockType);
        if var.unlockType == unlockSys then
            if var.preGuide then 
                var.preGuide(); 
            end
            break;
        end
    end

end


function Unlock.guide(unlockSys)

	for key,var in pairs(Unlock.system) do
		-- print("unlockSys = "..unlockSys);
		-- print("var.unlockType = "..var.unlockType);
		if var.unlockType == unlockSys then
            if var.guide then
                Guide.changeStack()
				var.guide();
                Guide.resetStack()
			end
			break;
		end
	end

end

function Unlock.getUnlockSysByLevUp(lev)
	for key,var in pairs(Unlock.system) do
		if  nil ~= var.needUnlockByLevUp and var.needUnlockByLevUp(lev) then
			return var.unlockType
		end
	end 

	return nil 
end

function Unlock.update()
end