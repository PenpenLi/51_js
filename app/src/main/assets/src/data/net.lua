Net={}
Net.msgQueue={}
NetCmdTable=nil
Net.isConnected = false

function Net.createNetCmdTable()
    if(NetCmdTable~=nil)then
        return
    end

    NetCmdTable={}
    NetCmdTable[CMD_TEST_BATTLE]=Net.recGetTestBat
    NetCmdTable[CMD_SYSTEM_INIT]=Net.recSystemInit
    NetCmdTable[CMD_SYSTEM_RELOAD]=Net.recSystemReload
    NetCmdTable[CMD_SYSTEM_RETIME]=Net.recSystemRetime
    NetCmdTable[CMD_SYSTEM_SYSROLLNOTICE]=Net.recSystemRollNotice

    NetCmdTable[RECEIVE_WORLD_BOSS_END]=Net.recWorldBossEnd

    NetCmdTable[CMD_CARD_EXP_UPGRADE]=Net.recCardExpUpgrade
    NetCmdTable[CMD_CARD_EVOLVE]=Net.recCardEvolve
    NetCmdTable[CMD_CARD_AWAKEN]=Net.recCardUpQuality
    NetCmdTable[CMD_CARD_RECURIT]= Net.recCardRecurit
    NetCmdTable[CMD_CARD_ACTIVATE_RELATION]= Net.recCardActivateRelation
    NetCmdTable[CMD_EQU_ACTIVATE]=Net.recEquipActivate
    NetCmdTable[CMD_EQU_ACTIVATE_ONEKEY]=Net.recEquipActivateOneKey
    NetCmdTable[CMD_EQU_UPGRADE]=Net.recEquipUpgrade
    NetCmdTable[CMD_EQU_UPQUALITY]=Net.recEquipUpQuality
    NetCmdTable[CMD_EQU_MERGE]=Net.recEquipItemMerge
    NetCmdTable[CMD_SKILL_UPGRADE]=Net.recSkillUpgrade
    NetCmdTable[CMD_SKILL_QUICK_UPGRADE]=Net.recSkillQuickUpgrade
    NetCmdTable[CMD_EQU_QUICKUPGRADE]=Net.recEquipQuickUpgrade



    NetCmdTable[CMD_ARENA_INFO]=Net.recArena
    NetCmdTable[CMD_ARENA_CHALLENGE]=Net.recArenaChallenge
    -- NetCmdTable[CMD_ARENA_RANK]=Net.recArenaRank
    NetCmdTable[CMD_ARENA_RECORD]=Net.recArenaRecord
    NetCmdTable[CMD_ARENA_VEDIO]=Net.recArenaVideo
    NetCmdTable[CMD_ARENA_CARD_INFO]=Net.recArenaCardInfo

    NetCmdTable[CMD_ARENA_CLEAR_CD]=Net.recArenaClearCd
    NetCmdTable[CMD_ARENA_BUY_NUM]=Net.recArenaBuyNum

    NetCmdTable[CMD_ATLAS_ENTER]=Net.recAtlasEnter
    NetCmdTable[CMD_ATLAS_FIGHT]=Net.recAtlasFight
    NetCmdTable[CMD_ATLAS_GETINFO]=Net.recAtlasInfo
    NetCmdTable[CMD_ATLAS_BUYBATNUM]=Net.recAtlasBuyBatNum
    NetCmdTable[CMD_ATLAS_CRYSTALREWARDINFO]=Net.recAtlasRewinfo
    NetCmdTable[CMD_ATLAS_RECCRYSTALREWARD]=Net.recAtlasGetRewinfo
    NetCmdTable[CMD_ATLAS_SWEEP]=Net.recAtlasSweep
    NetCmdTable[CMD_ATLAS_CHANGENAME]=Net.recSetName
    NetCmdTable[CMD_SYSTEM_CHANGE_NAME]=Net.recChangeName




    NetCmdTable[CMD_ATLAS_ACT_ENTER]=Net.recActAtlasEnter
    NetCmdTable[CMD_ATLAS_ACT_FIGHT]=Net.recActAtlasFight
    NetCmdTable[CMD_ATLAS_ACT_GETINFO]=Net.recActAtlasInfo
    NetCmdTable[CMD_ATLAS_ACT_DOUBLE_REWARD]=Net.recGetActAtlasReward
    NetCmdTable[CMD_ATLAS_ACT_CLEARCD]=Net.recAtlasActClearCd


    NetCmdTable[CMD_ITEM_DIAMOND_BUY_HP]=Net.recBuyEnergy
    NetCmdTable[CMD_TURNGOLD_INIT]=Net.recInitBuyGold
    NetCmdTable[CMD_TURNGOLD_USE]=Net.recBuyGold
    NetCmdTable[CMD_ITEM_DIAMOND_BUY_SKILLPOINT]= Net.recBuySkillPoint

    NetCmdTable[CMD_SHOP_INIT]=Net.recInitShop
    NetCmdTable[CMD_SHOP_BUY]= Net.recBuyShopItem
    NetCmdTable[CMD_SHOP_REFRESH]= Net.recRefreshShop
    NetCmdTable[CMD_ITEM_SELL]= Net.recSellItem

    NetCmdTable[CMD_DRAW_LIST]= Net.recDrawCardList
    NetCmdTable[CMD_DRAW_GD_BUY]= Net.recDrawCard


    NetCmdTable[CMD_CHAT_INIT]=Net.recChatInit
    NetCmdTable[CMD_FAMILY_CHAT_INIT]=Net.recFamilyChatInit
    NetCmdTable[CMD_CHAT_WORLD]=Net.recChatWorld
    NetCmdTable[CMD_RECEIVE_CHAT]=Net.recChatMessage
    NetCmdTable[CMD_CHAT_PRIVATE]=Net.recPrivateChatMessage



    NetCmdTable[CMD_PET_UPGRADE]=Net.recPetUpgrade
    NetCmdTable[CMD_PET_EVOLVE]=Net.recPetEvolve
    NetCmdTable[CMD_PET_UPGRADE_SKILL]=Net.recPetUpgradeSkill



    NetCmdTable[CMD_ACHIEVE_LIST]=Net.recAchieveList
    NetCmdTable[CMD_ACHIEVE_GET]=Net.recAchieveGet
    NetCmdTable[CMD_DAYTASK_LIST]=Net.recDayTaskList
    NetCmdTable[CMD_DAYTASK_GET]=Net.recDayTaskGet




    NetCmdTable[CMD_ATLAS_PET_GETINFO]=Net.recPetAtlasInfo
    NetCmdTable[CMD_ATLAS_PET_ENTER]=Net.recPetAtlasEnter
    NetCmdTable[CMD_ATLAS_PETT_FIGHT]=Net.recPetAtlasFight
    NetCmdTable[CMD_ATLAS_PET_SWEEP]=Net.recPetAtlasSweep
    NetCmdTable[CMD_ATLAS_PET_GET_REWARD]=Net.recPetAtlasSweepReward



    NetCmdTable[CMD_GIFTBAG_INIT]=Net.recGiftInit
    NetCmdTable[CMD_GIFTBAG_BUY]=Net.recGiftBuy

    NetCmdTable[CMD_BUDDY_LIST]=Net.recBuddyList
    NetCmdTable[CMD_BUDDY_FIND]=Net.recBuddyFind
    NetCmdTable[CMD_BUDDY_FIGHT]=Net.recBuddyFight
    NetCmdTable[CMD_BUDDY_DEL]=Net.recBuddyDel
    NetCmdTable[CMD_BUDDY_BLACK]=Net.recBuddyBlack
    NetCmdTable[CMD_BUDDY_GIVE]=Net.recBuddyGive
    NetCmdTable[CMD_BUDDY_APPLYLIST]=Net.recBuddyApplyList
    NetCmdTable[CMD_BUDDY_REFUSE]=Net.recBuddyRefuse
    NetCmdTable[CMD_BUDDY_ACCEPT]=Net.recBuddyAccept
    NetCmdTable[CMD_BUDDY_GIVELIST]=Net.recBuddyGivelist
    NetCmdTable[CMD_BUDDY_RECEIVE]=Net.recBuddyReveive
    NetCmdTable[CMD_BUDDY_RECEIVE_ALL]=Net.recBuddyReveiveAll
    NetCmdTable[CMD_BUDDY_BLACKLIST]=Net.recBuddyBlackList
    NetCmdTable[CMD_BUDDY_DEL_BLACK]=Net.recBuddyDelBlack
    NetCmdTable[CMD_RECEIVE_BUDDY_ACCEPT]=Net.recReceiveBuddyAccept
    NetCmdTable[CMD_RECEIVE_BUDDY_DEL]=Net.recReveiveBuddyDel
    NetCmdTable[RECEIVE_PROMPT]=Net.recReceivePrompt
    NetCmdTable[RECEIVE_REWARD]=Net.recReceiveReward
    NetCmdTable[CMD_BUDDY_TEAM]=Net.recBuddyTeam
    NetCmdTable[CMD_BUDDY_INVITE]=Net.recBuddyInvite
    NetCmdTable[RECEIVE_IAP_MISSORDER]=Net.recIapMissOrder


    NetCmdTable[CMD_FAMILY_SEARCH]=Net.recFamilySearch
    NetCmdTable[CMD_FAMILY_CREATE]=Net.recFamilyCreate
    NetCmdTable[CMD_FAMILY_GETINFO]=Net.recFamilyGetInfo
    NetCmdTable[CMD_FAMILY_APPLY]=Net.recFamilyApply
    NetCmdTable[CMD_FAMILY_CANCEL_APPLY]=Net.recFamilyCancelApply
    NetCmdTable[CMD_FAMILY_APPLY_LIST]=Net.recFamilyApplyList
    NetCmdTable[CMD_FAMILY_PASS]=Net.recFamilyPass
    NetCmdTable[RECEIVE_FAMILY_PASS]=Net.recReceiveFamilyPass
    NetCmdTable[CMD_FAMILY_REFUSE]=Net.recFamilyRefuse
    NetCmdTable[CMD_FAMILY_SET_NOTICE]=Net.recFamilyNotice
    NetCmdTable[CMD_FAMILY_DISMISS]=Net.recFamilyDismiss
    NetCmdTable[RECEIVE_FAMILY_DISMISS]=Net.recReceiveFamilyDismiss
    NetCmdTable[CMD_FAMILY_CANCEL_DISMISS]=Net.recFamilyCancelDismiss
    NetCmdTable[CMD_FAMILY_EXIT]=Net.recFamilyExit
    NetCmdTable[CMD_FAMILY_EXPEL]=Net.recFamilyExpel
    NetCmdTable[RECEIVE_FAMILY_EXPEL]=Net.recReceiveFamilyExpel
    NetCmdTable[CMD_FAMILY_APPOINT]=Net.recFamilyAppoint
    NetCmdTable[RECEIVE_FAMILY_APPOINT]=Net.recReceiveFamilyAppoint
    NetCmdTable[CMD_FAMILY_ADD_WOOD]=Net.recFamilyAddWood
    NetCmdTable[CMD_FAMILY_FIGHT]=Net.recFamilyFight


    NetCmdTable[CMD_GIFTBAG_OPEN_SERVER_INIT]=Net.recActivity7Day
    NetCmdTable[CMD_GIFTBAG_GET_OPEN_SERVER]=Net.recActivity7DayGet

    NetCmdTable[CMD_GIFTBAG_LV_INIT]=Net.recActivityLevelUp
    NetCmdTable[CMD_GIFTBAG_GET_LV]=Net.recActivityLevelUpGet


    NetCmdTable[CMD_FUND_LIST]=Net.recActivityInvest
    NetCmdTable[CMD_FUND_GET]=Net.recActivityInvestGet
    NetCmdTable[CMD_FUND_BUY]=Net.recActivityInvestBuy

    NetCmdTable[CMD_ACT_GET_INFO_7]=Net.recActivitySaleOff
    NetCmdTable[CMD_ACT_REC_7]=Net.recActivitySaleOffBuy
    NetCmdTable[CMD_ACT_GET_LIST]=Net.recActivityAll

    -- NetCmdTable[CMD_ACT_GET_INFO_2]=Net.recActivityConsume
    -- NetCmdTable[CMD_ACT_REC_2]=Net.recActivityConsumeGet

    NetCmdTable[CMD_ACT_GET_INFO_3]=Net.recActivityPay
    NetCmdTable[CMD_ACT_REC_3]=Net.recActivityPayGet
    NetCmdTable[CMD_ACT_REC_9]=Net.recActivityTxt
    NetCmdTable[CMD_ACT_GET_INFO_28]=Net.recActivityHolidaySignInfo
    NetCmdTable[CMD_ACT_REC_28]=Net.recActivityHolidaySign
    

    NetCmdTable[CMD_ACT_GET_INFO_6]=Net.recActivityChargeReturn
    NetCmdTable[CMD_ACT_REC_6]=Net.recActivityChargeReturnGet

    NetCmdTable[CMD_ACT_WEEK_GIFT_INFO]=Net.recActivityWeekGiftInfo
    NetCmdTable[CMD_ACT_BUY_WEEK_GIFT]=Net.recActivityBuyWeekGift

    NetCmdTable[CMD_IAP_BUY]=Net.recIapBuy
    NetCmdTable[CMD_IAP_CHECKORDER]=Net.recCheckOrder
    NetCmdTable[CMD_IAP_CHECKRECEIPT]=Net.recIapCheckReceipt
    NetCmdTable[CMD_IAP_CANCEL]=Net.recIapCancel
    NetCmdTable[CMD_IAP_CHECKMISSORDER]=Net.recIapCheckMissOrder

    NetCmdTable[CMD_ITEM_USE]=Net.recUseItem

    -- NetCmdTable[CMD_SIG_INIT]=Net.rec_sig_init

    NetCmdTable[CMD_PET_UNLOCK]=Net.recPetUnlock

    --寻仙
    NetCmdTable[CMD_SPIRIT_INIT]=Net.recSpiritInit
    NetCmdTable[CMD_SPIRIT_FIND]=Net.recSpiritFind
    NetCmdTable[CMD_SPIRIT_CALL]=Net.recSpiritCall
    NetCmdTable[CMD_SPIRIT_CALLMORE]=Net.recSpiritCallMore
    NetCmdTable[CMD_SPIRIT_EQU]=Net.recSpiritEqu
    NetCmdTable[CMD_SPIRIT_UPGRADE]=Net.recSpiritUpgrade
    NetCmdTable[CMD_SPIRIT_EXCHANGE]=Net.recSpiritExchange


    NetCmdTable[CMD_CRUSADE_GETINFO]=Net.recCrusadeInfo
    NetCmdTable[CMD_CRUSADE_FIGHT]=Net.recCrusadeFight
    NetCmdTable[CMD_CRUSADE_SHARE]=Net.recCrusadeShare
    NetCmdTable[CMD_CRUSADE_BUY]=Net.recCrusadeBuy
    NetCmdTable[CMD_CRUSADE_SHOP_BUY]=Net.recCrusadeShopBuy
    NetCmdTable[CMD_CRUSADE_FEATS]=Net.recCrusadeFeats
    NetCmdTable[CMD_CRUSADE_RECEIVE_FEATS]=Net.recCrusadeRevFeats
    NetCmdTable[CMD_CRUSADE_GETNUM]=Net.recCrusadeGetNum
    NetCmdTable[CMD_CRUSADE_CALLINFO]=Net.recCrusadeCallInfo
    NetCmdTable[CMD_CRUSADE_CALL]=Net.recCrusadeCall

    NetCmdTable[CMD_TEST_GETBATTLEVEDIO]=Net.recGetBattle


    NetCmdTable[CMD_CARD_RAISE_INFO]=Net.recCardRaiseInfo
    NetCmdTable[CMD_CARD_RAISE]=Net.recCardRaise
    NetCmdTable[CMD_CARD_RAISE_CONFIRM]=Net.recCardRaiseConfirm
    NetCmdTable[CMD_CARD_WEAPON_UPGRADE]=Net.recCardRaiseUpgrade
    NetCmdTable[CMD_CARD_TRANSMIT]=Net.recCardRaiseTransmit

    NetCmdTable[CMD_EQU_MELT]=Net.revEquMelt
    NetCmdTable[CMD_DRAW_DBEXCHANGE]=Net.recDrawDbexchange

end

function ConvertToSeverLanguageIndex()
    local lan = 1;
    if(gCurLanguage == LANGUAGE_ZHS)then
        lan = 1;
    elseif(gCurLanguage == LANGUAGE_EN)then
        lan = 2;
    end
    print("lan = "..lan);
    return lan;    
end

local function sendLoginMessage()

    local mObj = MediaObj:create()
    print(gAccount.session )
    mObj:setString("session", gAccount.session)
    print("gAccount.session"..gAccount.session)
    mObj:setInt("ver", 1)--程序版本号
    mObj:setInt("ver_res", 1)--资源版本号
    mObj:setInt("platform",gAccount:getPlatformId())
    if(gAccount.phone == nil)then
        gAccount.phone = 0
    end
    mObj:setLong("phone",gAccount.phone)
    mObj:setLong("channel",gAccount:getAdId())
    mObj:setBool("reload", true)
    mObj:setString("mac", gAccount:getMacAddress());
    mObj:setString("udid", gAccount:getDeviceId());
    mObj:setString("channeluserid", gAccount.channeluserid);
    mObj:setBool("minor", gAccount.isMinor);
    if(gIsMultiLanguage())then
        mObj:setInt("language", ConvertToSeverLanguageIndex());
    end
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        local tencentObj = MediaObj:create()
        tencentObj:setString("openid", gAccount.loginParams.openid);
        tencentObj:setString("openkey", gAccount.loginParams.openkey);
        tencentObj:setString("pay_token", gAccount.loginParams.pay_token);
        tencentObj:setString("pfkey", gAccount.loginParams.pfkey);
        tencentObj:setString("pf", gAccount.loginParams.pf);
        tencentObj:setString("atype", gAccount.loginParams.atype);
        mObj:setObj("tencent",tencentObj);

        -- print("settencentObj start")
        -- print("gAccount.loginParams.openid"..gAccount.loginParams.openid)
        -- print("gAccount.loginParams.openkey"..gAccount.loginParams.openkey)
        -- print("gAccount.loginParams.pay_token"..gAccount.loginParams.pay_token)
        -- print("gAccount.loginParams.pfkey"..gAccount.loginParams.pfkey)
        -- print("gAccount.loginParams.pf"..gAccount.loginParams.pf)
        -- print("gAccount.loginParams.atype"..gAccount.loginParams.atype)
        -- print("settencentObj end")
    end
    
    if(gAccount:getCurRole() and gAccount:getCurRole().gm)then 
        mObj:setString("gmact", gAccount.accountid);
    end
    -- print("client_mac = "..gAccount:getMacAddress());
    -- print("client_udid = "..gAccount:getDeviceId());

    local curRole=gAccount:getCurRole()
    local curServer=gAccount:getCurServer()
    MediaServer:shared():sendLoginMessage(mObj,curServer.zone,curRole.userid,"")
    gSendIndx = 1;
end

function Net.checkReconnect()
    Net.isReconnect=true
    local function onCheckConnect()

        if(Guide.isGuiding())then 
            if gAccount.motuAccount == false then 
                gAccount:doLogOut() 
            else
                local function callback()
                    Scene.reEnter()
                end
                Net.disConnect(callback)
            end 
        else
            Net.reconnect() 
        end
    end
    gConfirm(gGetWords("noticeWords.plist","connect_lost"),onCheckConnect)
end



local function onConnnected(evt)
    local isConnected = evt.params:getBool("success")
    if isConnected then
        gShowNotice(gGetWords("noticeWords.plist","connect_success"))
        -- gShowNotice("连接服务端成功")
        sendLoginMessage()
        Net.isConnected=true
    else
        if(Net.isReconnect==true)then
            Net.checkReconnect()
        end
        gShowNotice(gGetWords("noticeWords.plist","connect_fail"))
        -- gShowNotice("连接服务端失败")
        Scene.hideWaiting()
    end
end




local function onConnectLost(evt)
    Net.isConnected=false
    Scene.hideWaiting()
    if(Net.disConnectCallback)then
        Net.disConnectCallback()
        Net.disConnectCallback=nil
    else
        if( Net.isDisConnect~=true)then
            -- gShowNotice("断开链接")
            gShowNotice(gGetWords("noticeWords.plist","disconnect"))
            Net.checkReconnect()
        end
        Net.isDisConnect=false
    end
end


local function onLoginFail(evt)
    local msg= evt.params:getString("errorMessage")
  --  gShowNotice("登录服务端失败:"..msg)
    Net.isReconnect=false
    Net.clearMsgQueue()

    local errWord=""
    local needReEnter=true
    if (string.find(msg,"Requested Zone") ) then
        --重新读取服务器列表
        errWord = gGetWords("noticeWords.plist", "login_zone_null")
    elseif (string.find(msg,"session is null") ) then---缓存里面没有这个account对应的session
        ---重新登录
        ---("缓存里面没有这个account对应的session")
        errWord = gGetWords("noticeWords.plist", "login_session_null")
    elseif (string.find(msg,"session is wrong") ) then---缓存里面的session跟客户端提交的不一致
        ---("客户端已经在其他设备上登录")
        errWord = gGetWords("noticeWords.plist", "login_session_wrong")
        gAccount:resetIsLogin()
        if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
            ChannelPro:sharedChannelPro():logout();
        end
    elseif (string.find(msg,"version is low") ) then---版本号太低
        ---重新读取服务器列表，如果是安卓版本，则可以得到新版本的下载地址
        ---("版本号太低")
        errWord = gGetWords("noticeWords.plist", "login_version_low")
    elseif (string.find(msg,"loginid is wrong") ) then---用户id不存在
        ---("用户id不存在")
        errWord = gGetWords("noticeWords.plist", "login_userid_wrong")
    elseif (string.find(msg,"user is null") ) then---服务端内存中用户数据为空
        ---("服务端内存中用户数据为空")
        errWord = gGetWords("noticeWords.plist", "login_user_null")
    elseif (string.find(msg,"already logged") ) then---服务端内存中用户数据为空
        ---("该用户已经登录")
        errWord = gGetWords("noticeWords.plist", "login_already_logged")
    elseif (string.find(msg,"login too ofen") ) then---服务端内存中用户数据为空
        ---("登录太频繁")
        errWord = gGetWords("noticeWords.plist", "login_too_ofen")
    elseif (string.find(msg,"server is maintaining") ) then---服务器正在维护
        ---("服务器正在维护")
        errWord = gGetWords("noticeWords.plist", "login_server_maintain")
        if(string.find(msg,"desc=") )then
            errWord=string.gsub(msg,"server is maintaining desc=","")
        end

    elseif (string.find(msg,"user status seal time = ") ) then---服务器正在维护
        local time=0
        if(string.find(msg,"time = ") )then
            time=toint(string.gsub(msg,"user status seal time = ",""))
        end
        local date=gParserDay(time)
        errWord= gGetWords("noticeWords.plist", "user_status_seal",date)
        

    elseif (string.find(msg,"gm is hosting") ) then 
        
        errWord= gGetWords("noticeWords.plist", "user_gm_use")
    end
    local function onReEnter()
        local function callback()
            Net.isReconnect=false
            Net.clearMsgQueue()
            Scene.reEnter()
        end
        Net.disConnect(callback)
    end

    gConfirm(errWord,onReEnter)
end

function Net.clearMsgQueue()
    for key, var in pairs(Net.msgQueue) do
        var:release()
    end
    Net.msgQueue={}
end


function Net.resendMsg()
    if(table.getn(Net.msgQueue)==0)then
        return
    end
    for key, media in pairs(Net.msgQueue) do
        print("resend :"..media.cmd)
        MediaServer:shared():sendExtensionMessage(media, media.cmd)
    end
    Scene.showWaiting(1)

end

local function onLoginSuccess(evt)
    gShowNotice(gGetWords("noticeWords.plist","login_success"));
    -- gShowNotice("登录服务端成功")
    local mObj = MediaObj:create()
    mObj:setInt("nid",0)
    if(Net.isReconnect==true)then
        Net.sendExtensionMessage(mObj,CMD_SYSTEM_RELOAD)
        Scene.hideWaiting()
        Net.resendMsg()
    else
        Scene.preLoadFirstEnterGame();
    end
    Net.isReconnect=false
    Net.isDisConnect=false
end

function Net.removeQueueMsg(cmd)
    local msgQueue=Net.msgQueue
    for key, var in pairs(msgQueue) do
        print(var.cmd)
        if(var.cmd==cmd)then
            var:release()
            table.remove(msgQueue,key)
            break
        end
    end
    print("======="..table.count(msgQueue))
end

function Net.sendExtensionMessage(media,cmd,stack,showWaiting,sendIndex)
    if Net.onRecTestData(cmd)==true then
        return
    end

    if(stack~=false)then
        media.cmd=cmd
        media:retain()
        table.insert(Net.msgQueue,media)
    end

    if(Net.isConnected==true)then
        print("sendExtensionMessage:"..cmd )

        if showWaiting == nil then
            showWaiting = true;
        end
        if showWaiting then
            Scene.showWaiting(1)
        end
        if(sendIndex)then
            print("gSendIndx = "..gSendIndx);
            media:setInt("_idx_",gSendIndx);
            gSendIndx = gSendIndx + 1;
            if(gSendIndx > 99999)then
                gSendIndx = 1;
            end
        end
        MediaServer:shared():sendExtensionMessage(media, cmd)
    else
        Net.checkReconnect()
    end

end

function Net.reconnect()
    local curServer=gAccount:getCurServer()
    Net.connectToServer(curServer.ip,curServer.port)
end

function Net.disConnect(callback)
    if(Net.isConnected==false)then
        callback()
        return
    end
    Net.isDisConnect=true
    Net.disConnectCallback=callback
    MediaServer:shared():disconnectServer()
end

function Net.connectToServer(ip,port)
    Scene.showWaiting()
    local function callback()
        MediaServer:shared():connectToServer( ip,port)
    end
    if  MediaServer:shared():isSFSConnected() then
        Net.disConnect(callback)
    else
        callback()
    end

end

local function isShouldSkipErrCode3(cmd)
    if cmd == CMD_SPIRIT_FIND_NEW then
        return true 
    elseif cmd == CMD_EQU_ACTIVATE_ONEKEY then
        return true
    end
    return false
end

local function onExtendCmd(evt)
    local cmd = evt.params:getString("cmd")
    local obj= evt.params:getObj("params")
    local ret=obj:getByte("ret")

    Scene.hideWaiting()
    Net.removeQueueMsg(cmd)

    -- gShowCmdNotice(cmd,ret);

    if ret == 3 and not isShouldSkipErrCode3(cmd) then
        NetErr.noEnoughGold();
    elseif ret == 4 then
        NetErr.noEnoughDia();
    elseif ret == 125 then
        gShowNotice(gGetWords("noticeWords.plist","code125")); 
    elseif ret == 124 then
        gShowNotice(gGetWords("noticeWords.plist","code124"));    
    elseif ret == 38 then
        if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
            local errWord = gGetWords("noticeWords.plist", "tencent_token_wrong")
            local function onLogout()
                ChannelPro:sharedChannelPro():logout();
            end
            gConfirm(errWord,onLogout)
        -- Net.sendSystemRefreshParams();
        end
    else
        gShowCmdNotice(cmd,ret);
    end

    Net.createNetCmdTable()
    local cmdFunc=NetCmdTable[cmd]
    if(cmdFunc)then
        cmdFunc(evt)
    else
        cmd = string.gsub(cmd,"%.","_");
        local cmdVar = "CMD_"..string.upper(cmd);
        local sFuncJudgeCmdVar = string.format("if(Net.rec_%s ~= nil)then return true else return false end",cmd);
        -- print(sFuncJudgeCmdVar);
        if(loadstring(sFuncJudgeCmdVar)()) then
            local sFunc = string.format("local evt = ...; Net.rec_%s(evt)",cmd);
            print(sFunc);
            local f = assert(loadstring(sFunc));
            f(evt);
        end
    end
    -- RedPoint.update(true);
    gRedposRefreshDirty = true;
end



function onRecNetMessage(type,evt )


    if type==EVENT_TYPE_ON_CONNECT then
        onConnnected(evt)
    elseif type==EVENT_TYPE_ON_LOGIN_SUCCESS then
        onLoginSuccess(evt)
    elseif type==EVENT_TYPE_ON_CONNECT_LOST then
        onConnectLost(evt)
    elseif type==  EVENT_TYPE_ON_LOGIN_FAIL then
        onLoginFail(evt)
        Scene.hideWaiting()
    elseif type==EVENT_TYPE_ON_EXTEN_CMD then
        onExtendCmd(evt)
    end


end

function Net.onRecTestData(cmd)
    if true then return false end
    -- 模拟返回测试数据
    local tmp = string.split(cmd,".")
    local cmdhead = ""
    if table.getn(tmp) > 0 then
        cmdhead = tmp[1]
    end
    if cmdhead == "" or cmdhead ~= "lootfood" then
        return false
    end

    cmd = string.gsub(cmd,"%.","_");
    local cmdVar = "CMD_"..string.upper(cmd);
    local sFuncJudgeCmdVar = string.format("if(Net.rec_%s_test ~= nil)then return true else return false end",cmd);
    -- print(sFuncJudgeCmdVar);
    if(loadstring(sFuncJudgeCmdVar)()) then
        local sFunc = string.format("Net.rec_%s_test()",cmd);
        print(sFunc);
        local f = assert(loadstring(sFunc));
        f(evt);
    end

    return true
end

