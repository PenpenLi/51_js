--相关模块的开关
Switch = {}
Switch.module = {}
Module = {}

SWITCH_CHAT               = 1; --聊天
SWITCH_VIP                = 2; --vip模块
SWITCH_CARDYEAR           = 3; --终身卡
SWITCH_ALLACTIVITY        = 4; --活动入口
SWITCH_FIRST_PAY          = 5; --首冲入口
SWITCH_NOTICE             = 6; --公告
SWITCH_SWITCH             = 7; --兑换码
SWITCH_DIGMINE            = 8; --挖矿(无效)
SWITCH_WEAPON             = 9; --神器(无效)
SWITCH_FAMILY_WAR         = 10; --家族战(无效)
SWITCH_MALL               = 11; --商城
SWITCH_WEEK_BOX           = 12; --周礼包(无效)
SWITCH_VIDEO              = 13; --录像
SWITCH_WORLD_BOSS         = 14; --世界boss
SWITCH_AWAKE              = 15; --觉醒
SWITCH_SHOP_SOUL          = 16; --将星商店
SWITCH_SERVER_BATTLE      = 17; --跨服战
SWITCH_SHARE              = 18; --分享
SWITCH_REPLACE_CARDYEAR   = 19; --显示年卡
SWITCH_APPSTORE_GOOD      = 20; --五星评价
SWITCH_TOWER              = 21; --无尽之塔
SWITCH_ACTIVITY_NEWYEAR   = 22; --新年活动
SWITCH_CARD_MONTH         = 23; --月卡
SWITCH_SIGN               = 24; --签到
SWITCH_FEEDBACK           = 25; --反馈
SWITCH_FREE_VIP           = 26; --免费vip
SWITCH_TREASURE           = 27; --宝物
SWITCH_SHOP_EMOTION       = 28; --情义商店
SWITCH_LANGUAGE           = 29; --多语言
SWITCH_CG                 = 30; --CG
SWITCH_HALO               = 31; --应用宝幻灵光环
SWITCH_PAY2               = 32; --累充
SWITCH_ACCOUTID           = 33; --显示账号id
SWITCH_FACEBOOK           = 34; --显示Facebook按钮
SWITCH_Alipay             = 35; --支付宝开关
SWITCH_ELITE_FLOP         = 36; --精英翻牌
SWITCH_CARDSOUL           = 37; --化魂
SWITCH_GOLDKEY            = 38; --金钥匙购买
SWITCH_SHARE_TWITTER      = 39; --显示Twitter分享
SWITCH_SHARE_LINE         = 40; --显示Line分享
SWITCH_SPIRIT_EXTRA       = 41; --命魂7，8位开启
SWITCH_DOUBLE_ATTR_SPIRIT = 42; --魂之命魂开关
SWITCH_MINE_ATLAS         = 43; --海底密穴开关
SWITCH_FAMILY_ORE         = 44; --军团挖矿
SWITCH_FAMILY_SHOP4       = 45; --军团商店热拍和宝物标签
SWITCH_FAMILY_STAGE       = 46; --军团商店竞赛开关
SWITCH_LOOT_FOOD          = 48; --夺粮开关
SWITCH_PAY                = 101; --封测充值
SWITCH_TREASURE_HUNT    = 47; --跨服寻宝
SWITCH_EXCHANGE_CARD    = 49; --变身
SWITCH_CONSTELLATION    = 50; --星宿系统
SWITCH_BATH             = 51; --修仙
SWITCH_INVITE           = 52; --好友邀请开关
SWITCH_RICHMAN          = 53; --宇宙控险开关
SWITCH_FAMILY_DONATE    = 54; --家族捐赠开关
SWITCH_AD_API    		= 55; --广告投放API
SWITCH_YOUME_VOICE    	= 56; --语音SDK开关
SWITCH_IAppPay         	= 57; --爱贝支付开关
SWITCH_BIND_PHONE       = 58; --绑定开关开关
SWITCH_IAppPayH5       	= 59; --爱贝支付H5开关

function Module.parserExtraParam(switchType,extraParam,isAdd)
	local newAdd = isAdd
	if (SWITCH_Alipay == switchType or SWITCH_IAppPay == switchType or SWITCH_IAppPayH5 == switchType or SWITCH_INVITE == switchType) and extraParam then
		newAdd = false
		local extraParams = string.split(extraParam,",")
		for k,param in pairs(extraParams) do
            if param == gAccount:getPackageName() or param == gAccount:getPlatformId().."" then
                newAdd = true;
                break;
            end
        end
	end

	return newAdd
end

function Module.updateSwitch(switchData)
    for key,var in pairs(switchData) do
        -- print("var.version_up = "..var.version_up);
        -- print("var.version_down = "..var.version_down);
        -- print("gLuaVersion = "..gLuaVersion);
        -- print_lua_table(var.platforms);
        -- print("##### gGetCurPlatform = "..gGetCurPlatform());
        if gLuaVersion >= toint(var.version_up) and gLuaVersion <= toint(var.version_down) then
            -- print("add");
            isAdd = true;
            --平台
            for k,v in pairs(var.platforms) do
                if toint(v) == gGetCurPlatform() then
                    -- print("isAdd = false");
                    isAdd = false;
                    break;
                end
            end

            isAdd = Module.parserExtraParam(var.id,var.extraParam,isAdd)

            if (isAdd) then
                -- print("isAdd = true");
                if(toint(var.open) == 0) then
	                Module.closeSwitch(var.id);
                else
                	Module.openSwitch(var.id);
                end
            end
        end

    end

    -- print("@@@@@@11111");
    -- print_lua_table(gCloseModules);
    -- print("@@@@@@222222");
end

function Module.closeSwitch(switchType)
	for key,id in pairs(gCloseModules) do
		if(id == switchType)then
			return;
		end
	end	
	table.insert(gCloseModules,switchType);
end

function Module.openSwitch(switchType)
	-- print("openSwitch switchType = "..switchType);
	for key,id in pairs(gCloseModules) do
		if(id == switchType)then
			table.remove(gCloseModules,key);
			-- print("remove switchType");
			break;
		end
	end

end

function Module.isClose(switchType)
	-- print("Module.isClose");
	-- print_lua_table(gCloseModules);
	-- 版署特别号
	if(Module.banshuClose(switchType))then
		return true;
	end

    if(switchType == SWITCH_SHARE)then
    	local packageName= gAccount:getPackageName();
	    if(packageName=="com.ldersea.ce")then
	        return true;
	    end
    end
	for key,var in pairs(gCloseModules) do
		-- print("var = "..var);
		-- print("switchType = "..switchType);
		if(toint(var) == switchType)then
			return true;
		end
	end
	return false;

end

function Module.banshuClose(switchType)
	if gUserInfo.banshuClose then
		for i=1,#gUserInfo.banshuClose do
			if(gUserInfo.banshuClose[i]==switchType)then
				return true;
			end
		end
	end
	return false
end

function Module.delDataForClose()
	for key,var in pairs(gCloseModules) do
		Module.handleDelData(var);
	end	
end

function Module.handleDelData(switchType)
	for key,var in pairs(Switch.module) do
		if(var.type == switchType)then
			if (var.handleData) then
				var.handleData();
			end
		end
	end
end

-- function Module.close(uilayer)
-- 	for key,var in pairs(gCloseModules) do
-- 		Module.handleClose(var,uilayer);
-- 	end
-- end

-- function Module.handleClose(switchType,uilayer)
-- 	-- print("switchType = "..switchType);
-- 	for key,var in pairs(Switch.module) do
-- 		if(var.type == switchType)then
-- 			-- print("type = "..var.type);
-- 			if (var.close) then
-- 				var.close(uilayer);
-- 			end
-- 		end
-- 	end
-- end

function Module.delActivity()
	for key,var in pairs(gCloseModules) do
		Module.handleDelActivity(var);
	end		
end

function Module.handleDelActivity(switchType,func)
	for key,var in pairs(Switch.module) do
		if(var.type == switchType)then
			if (var.delActivity) then
				var.delActivity();
			end
		end
	end	
end
