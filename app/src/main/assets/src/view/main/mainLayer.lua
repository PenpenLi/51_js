local MainLayer=class("MainLayer",UILayer)

local ACTION_TAG_HIDE=1
function MainLayer:ctor()
    self:init("ui/ui_main.map")


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    --local particle =  cc.ParticleSystemQuad:create("particle/kdsg-chenai.plist")
    --self:getNode("particle_container"):addChild(particle)
    self.msgWin = MsgWinLayer.new();
    self.msgWin:setAnchorPoint(cc.p(0,-1));
    self:getNode("layer_msg"):addChild(self.msgWin);

    self:dealEvent(EVENT_ID_USER_DATA_UPDATE)

    self:getNode("btn_red_package2"):setVisible(false);
    self.btn_red_package = self:getNode("btn_red_package");
    local function update()
        -- print("update");
        self:updatePower()
        if (Data.m_onlineInfo.bolOnline) then
            self:updateOnlineGift();
        end
        if (Data.activityCat.lefttime - gGetCurServerTime()>=0) then
            self:updateCat()
        end
        self:updateLuckWheel()
        self:updateRichman()
        self:updateRedPack();

        self.btn_red_package:setVisible( Data.hasRedPack)
    end

    self:scheduleUpdate(update,1)

    self:refreshBtnChat();
    self:refreshBtnPay();

    if(gGetCurPlatform() ~= CHANNEL_ANDROID_TENCENT)then
        Net.g_sys_isreceipt=true
    end

    loadFlaXml("ui_muen")
    self:AniBtnChat()

    self:hideCloseModule()

    if(gUserInfo.needChangeName)then
        Panel.popUp(PANEL_SET_NAME,true);
    end

    if Data.rankActFlag then
        self:getNode("btn_activity_rank"):setVisible(true)
    else
        self:getNode("btn_activity_rank"):setVisible(false)
    end
  
    self:setBtnActivityFestival(Data.holActFlag)
    self:setBtnActivityHefu(Data.hefuActFlag)
    self:setBtnBindPhone(not Data.bindPhone)

    self:getNode("layout_top_docker"):layout()

    if(youme.isNeedInit == true)then
        youme.isNeedInit = false;
        youmeInit();
    end
    if(youme.isNeedLogin == true)then
        youme.isNeedLogin = false;
        youmeLogin(tostring(Data.getCurUserId()),tostring(Data.getCurUserId()),"");
    end
end

function MainLayer:onUILayerExit()
    self:unscheduleUpdateEx();
end

function MainLayer:bolOpenRank()
    if( Module.isClose(SWITCH_VIP)==true)then
        return false
    end
    if (gUserInfo.level>=20) then
        return true
    end
    return false;
end

function MainLayer:setBtnActivityNew()
    if self:getNode("btn_activity_new") then
        self:getNode("btn_activity_new"):setVisible(not Module.isClose(SWITCH_ACTIVITY_NEWYEAR));
    end
end

function MainLayer:setBtnActivityFestival(visible)
    if self:getNode("btn_activity_festival") then
        self:getNode("btn_activity_festival"):setVisible( visible);
    end
end

function MainLayer:setBtnActivityHefu(visible)
    if self:getNode("btn_activity_hefu") then
        self:getNode("btn_activity_hefu"):setVisible( visible);
    end
end

function MainLayer:setBtnBindPhone(visible)
    if gAccount.phone~=0 or Module.isClose(SWITCH_BIND_PHONE) then
        self:getNode("btn_bindphone"):setVisible(false);
        return
    end
    if self:getNode("btn_bindphone") then
        self:getNode("btn_bindphone"):setVisible( visible);
    end
    
end

function MainLayer:hideCloseModule()
    self:getNode("btn_chat"):setVisible(not Module.isClose(SWITCH_CHAT));
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("btn_activity"):setVisible(not Module.isClose(SWITCH_ALLACTIVITY));
    self:getNode("btn_notice"):setVisible(not Module.isClose(SWITCH_NOTICE));
    self:getNode("btn_first_pay"):setVisible(not Module.isClose(SWITCH_FIRST_PAY));
    self:getNode("btn_mall"):setVisible(not Module.isClose(SWITCH_MALL));
    self:getNode("btn_rank"):setVisible(self:bolOpenRank());
    self:setBtnActivityNew()
    self:getNode("btn_feedback"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("btn_facebook"):setVisible(not Module.isClose(SWITCH_FACEBOOK));

    self:getNode("time_word"):setVisible(false);
    if (not Data.m_onlineInfo.bolOnline) then
        self:getNode("btn_online_gift_bg"):setVisible(false);
    end
    self:getNode("time_word_cat"):setVisible(false);
    if (Data.activityCat.lefttime - gGetCurServerTime()<=0) then
        self:getNode("btn_cat_bg"):setVisible(false);
    end

    if not Data.isFirstPay() then
        self:getNode("btn_pay"):setVisible(false);
        if not Data.isFirstPay() then
            self:getNode("btn_first_pay"):setVisible(false)
            self:getNode("btn_pay"):setVisible(true);
            if (Data.getCurFirstcg()<4 and not Module.isClose(SWITCH_PAY2)) then
                self:getNode("btn_first_pay"):setVisible(Data.getCurFirstcg()<4)
                self:changeTexture("btn_first_pay","images/ui_main/menu_icon2_iap3.png")
            end
        end
        -- self:getNode("btn_first_pay"):setVisible(Data.getCurFirstcg()<4);
        -- if (Data.getCurFirstcg()<4 and not Module.isClose(SWITCH_PAY2)) then
        --     self:changeTexture("btn_first_pay","images/ui_main/menu_icon2_iap3.png")
        --     self:getNode("btn_first_pay"):setVisible(not Module.isClose(SWITCH_PAY2));
        -- end
    end
    -- self:getNode("btn_family_skill"):setVisible(#gUserFamilyBuff > 0);

    self:refreshNewTaskType();
    gSetVideo();

    self:resetLayOut();
end

function MainLayer:refreshNewTaskType()

    self:getNode("btn_task"):setVisible(false);
    self:getNode("btn_task7"):setVisible(false);
    if(gNewTaskType==1)then
        self:getNode("btn_task"):setVisible(true);
        self:getNode("btn_task7"):setVisible(false);
    elseif(gNewTaskType==2)then
        self:getNode("btn_task"):setVisible(false);
        self:getNode("btn_task7"):setVisible(true);
    end
end

function MainLayer:refreshOnlineGift()
    self:updateOnlineGift();
end

function MainLayer:updateOnlineGift()
    if (not Data.m_onlineInfo.bolOnline) then
        self:getNode("btn_online_gift_bg"):setVisible(false);
        self:resetLayOut();
        return
    end
    if (Data.m_onlineInfo.iTime) then
        if (not self:getNode("time_word"):isVisible()) then
            self:getNode("time_word"):setVisible(true);
        end
        local passTime=gGetCurServerTime()-Data.m_onlineInfo.iTime
        -- print("passTime="..passTime)
        if(passTime>=Data.m_onlineInfo.rTime)then
            --提示领取
            self:getNode("time_word"):setVisible(false);
            Data.m_onlineInfo.bolShowRedPoint = true;
        else
            --倒计时
            local word=gParserMinTime(Data.m_onlineInfo.rTime-passTime);
            self:setLabelString("time_word", word)
        end
    end
end
function MainLayer:updateLuckWheel()
    if(gGetCurServerTime()>=gLuckWheel.endTime  )then
        self:getNode("btn_activity_luck_wheel"):setVisible(false)
        return
    end
    if(gLuckWheel.startTime~=0 and gLuckWheel.startTime)then 
        if(gLuckWheel.startTime<=gGetCurServerTime()  )then 
            self:getNode("btn_activity_luck_wheel"):setVisible(true) 
            gLuckWheel.startTime=0 
            self:resetLayOut()
        else 
            self:getNode("btn_activity_luck_wheel"):setVisible(false)
            return
        end 
    end


    self:getNode("btn_activity_luck_wheel"):setVisible(true)
    local leftTime=gLuckWheel.endTime -gGetCurServerTime()
    self:setLabelString("txt_luck_wheel_time",  gParserDayHourTime(leftTime))
end


function MainLayer:updateRichman()
    if Module.isClose(SWITCH_RICHMAN) then
        self:getNode("btn_richman"):setVisible(false)
        return        
    end

    if(gGetCurServerTime()>=gRichman.endTime  )then
        self:getNode("btn_richman"):setVisible(false)
        return
    end 
    if(gRichman.startTime~=0 and gRichman.startTime)then  
        if(gRichman.startTime<=gGetCurServerTime()  )then 
            self:getNode("btn_richman"):setVisible(true) 
            gRichman.startTime=0 
            self:resetLayOut()
        else 
            self:getNode("btn_richman"):setVisible(false)
            return
        end 
    end

    self:getNode("btn_richman"):setVisible(true)
    local leftTime=gRichman.endTime -gGetCurServerTime()
    self:setLabelString("txt_richman_time",  gParserDayHourTime(leftTime))
end

function MainLayer:updateRedPack()
    if(Data.redpackInfo.redtime==nil)then
        return;
    end
    local hasNextRedPack = false;
    if(Data.redpackInfo.endTime <= 0 or gGetCurServerTime() >= Data.redpackInfo.endTime)then
        for key,var in pairs (Data.redpackInfo.redtime) do
            if(gGetCurServerTime() < toint(var))then
                Data.redpackInfo.endTime = toint(var);
                hasNextRedPack = true;
                break;
            end
        end
    else
        hasNextRedPack = true;
    end

    self:getNode("btn_red_package2"):setVisible(hasNextRedPack);
    if(hasNextRedPack) then
        local leftTime = Data.redpackInfo.endTime-gGetCurServerTime()
        self:setLabelString("btn_red_package2_time",  gParserDayHourTime(leftTime))
    else
        Data.redpackInfo.redtime = nil;
    end
end


function MainLayer:updateCat()
    -- print("Data.activityCat.lefttime="..Data.activityCat.lefttime)
    if (not self:getNode("time_word_cat"):isVisible()) then
        self:getNode("time_word_cat"):setVisible(true);
    end
    local passTime=Data.activityCat.lefttime - gGetCurServerTime()
    -- print("passtime="..passTime)
    if(passTime>0)then
        --倒计时
        local word=gParserHourTime(passTime);
        self:setLabelString("time_word_cat", word)
    else
        self:getNode("btn_cat_bg"):setVisible(false);
        self:getNode("time_word_cat"):setVisible(false);
        Data.activityCat.lefttime = 0
        self:resetLayOut();
    end
end

function MainLayer:refreshBtnChat()
-- body
-- self:getNode("btn_chat"):setVisible(gSysSet[2]);
end

function MainLayer:refreshBtnPay()
    self:getNode("btn_pay"):setVisible(false);
    if not Data.isFirstPay() then
        self:getNode("btn_first_pay"):setVisible(false)
        self:getNode("btn_pay"):setVisible(true);
        if (Data.getCurFirstcg()<4 and not Module.isClose(SWITCH_PAY2)) then
            self:getNode("btn_first_pay"):setVisible(Data.getCurFirstcg()<4)
            self:changeTexture("btn_first_pay","images/ui_main/menu_icon2_iap3.png")
        end
    end
    self:resetLayOut();
end

function MainLayer:showBtnChat(visible)
    if (Module.isClose(SWITCH_CHAT)) then
        return;
    end
    local node = self:getNode("btn_chat")
    self:setNodeTouchRectOffset("btn_chat", 30,30)
    node:setVisible(visible);
    self.msgWin:setVisible(visible);
end

function MainLayer:AniBtnChat()
    local node = self:getNode("btn_chat")
    local ret=FlashAni.new()
    local size=node:getContentSize()
    local width=size.width
    local height=size.height
    ret:setPositionX(6)
    ret:setPositionY(height/2)
    node:addChild(ret,0,1)
    ret:playAction("ui_munu_dian")
end


function MainLayer:onTouchEnded(target)
    Panel.popBackTopPanelByType(PANEL_CHAT)

    if(target.touchName=="btn_head")then
        -- Unlock.show();
        -- Panel.popUp(PANEL_LEVEL_UP)
        -- cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        -- Scene.removeAllFlaTextureCache()
        -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
        --  cc.Director:getInstance():getTextureCache():removeUnusedTextures()

        Panel.popUpUnVisible(PANEL_USER_INFO,nil,nil,true);
    --[[ -- Panel.popUpVisible(PANEL_SHARE_NEWCARD,10017); ]]
    -- local ret = {};
    -- ret.items = {};
    -- for i=1,11 do
    --     table.insert(ret.items,{id=90001,num=100});
    -- end
    -- Panel.popUpVisible(PANEL_GET_REWARD,ret);
        
    elseif(target.touchName == "btn_family_skill")then
        -- if (Data.bolTencent()) then
        Panel.popUpVisible(PANEL_HALO,nil,nil,true);
    -- else
    -- Panel.popUpVisible(PANEL_FAMILY_USERSKILL,nil,nil,true);
    -- end
    elseif(target.touchName=="btn_chat")then
        --if Unlock.isUnlock(SYS_CHAT) then
        Panel.popUpVisible(PANEL_CHAT,1,{curType = 1},true)
        self:showBtnChat(false);
    -- gMsgWinLayer:hide()
    --end

    elseif(target.touchName=="btn_activity")then
        Panel.popUp(PANEL_ACTIVITY_ALL)
    elseif(target.touchName=="btn_activity_new") then
        Panel.popUp(PANEL_ACTIVITY_ALL,{bolNewYear=true})
    elseif(target.touchName=="btn_activity_festival") then
        Panel.popUp(PANEL_ACTIVITY_ALL,{bolFestival=true})
    elseif(target.touchName=="btn_activity_hefu") then
        Panel.popUp(PANEL_ACTIVITY_ALL,{bolHefu=true})

    elseif(target.touchName=="btn_activity_luck_wheel") then
        Net.sendGetLuckWheelInfo(0,false,0,0)
    elseif(target.touchName=="btn_red_package")then
        Net.sendActivityGetList20()
    elseif(target.touchName=="btn_red_package2")then
        gConfirm(gGetWords("redPackage.plist","15"));
    elseif(target.touchName=="btn_first_pay")then
        if Data.isFirstPay() then
            Panel.popUp(PANEL_FIRST_PAY)
        elseif (Data.getCurFirstcg()<4 and not Module.isClose(SWITCH_PAY2)) then
            Net.sendActivityFirstPay()
        else
            Panel.popUp(PANEL_PAY);
        end
    elseif(target.touchName=="btn_mall")then
        Panel.popUp(PANEL_MALL);
    elseif(target.touchName == "btn_pay") then
        Panel.popUp(PANEL_PAY);
    elseif(target.touchName == "btn_notice") then
        -- Panel.popUp(PANEL_NOTICEBOARD);
        local serverId = gAccount:getCurRole().serverid;
        print("serverid = "..serverId);
        gEnterNoticeBoard(serverId);
    elseif(target.touchName == "btn_online_gift")then
        self:delOnlineGift();
    elseif(target.touchName == "btn_cat")then
        Panel.popUp(PANEL_ACTIVITY_CAT)
    elseif(target.touchName == "btn_feedback")then
        local platformid = gAccount:getPlatformId()
        if(platformid == CHANNEL_IOS_EFUNTW or platformid == CHANNEL_IOS_EFUNHK or platformid == CHANNEL_ANDROID_EFUNTWGP or platformid == CHANNEL_ANDROID_EFUNTWGW or platformid == CHANNEL_ANDROID_EFUNHK)then
            Panel.popUp(PANEL_FEEDBACK_GT)
        else
            Panel.popUp(PANEL_FEEDBACK)
        end
    elseif(target.touchName == "btn_rank")then
        Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_LEVEL)
        -- Panel.popUp(PANEL_FAMILY_WAR_EDIT )
    elseif(target.touchName=="btn_sign")then
        -- Panel.popUpVisible(PANEL_VIP_LEVELUP,nil,nil,true);
        Net.sendSignInit();
    elseif(target.touchName == "btn_task")then
        Panel.popUpVisible(PANEL_NEWTASK,nil,nil,true);
    -- Panel.popUpVisible(PANEL_VIP_LEVELUP,nil,nil,true);
    elseif(target.touchName == "btn_task7")then
        Net.sendAchieveList(true,true);
        if(table.getn(gGiftBagBuy)==0)then
            Net.sendGiftInit()
        end
        -- Panel.popUpVisible(PANEL_TASK7DAY,nil,nil,true);
    elseif(target.touchName == "btn_bag")then

        Panel.popUp(PANEL_BAG,1)
        
    elseif(target.touchName == "btn_richman")then
        Net.sendRichmanEnter(true)
        
    elseif(target.touchName == "btn_facebook")then
        local platform = gAccount:getPlatformId();
        if  platform == CHANNEL_ANDROI_EFUNENCN or platform == CHANNEL_ANDROI_EFUNENCN_LY or platform == CHANNEL_IOS_EFUN_CN_EN then
            PlatformFunc:sharedPlatformFunc():openURL("https://www.facebook.com/616984168455175")
        end
        -- if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
        --     ChannelPro:sharedChannelPro():extenInter("facebook","")
        -- end
    elseif(target.touchName=="btn_friend")then
        if Unlock.isUnlock(SYS_FRIEND) then
            Panel.popUp(PANEL_FRIEND)
        end
    elseif(target.touchName=="btn_activity_rank")then
        Panel.popUp(PANEL_ACTIVITY_ALL,{bolRank=true})
    elseif(target.touchName=="btn_bindphone")then
        Panel.popUpVisible(PANNEL_BIND_PHONE_NUM,nil,nil,true)
    end

end

function MainLayer:enterSign()
    Panel.popUp(PANEL_SIGNIN);
end

function MainLayer:enter7Day(param)
    Panel.popUpVisible(PANEL_TASK7DAY,param,nil,true);
end


function MainLayer:callWhenPopPanel()
    gRollNoticeLayer:setPos(false)
    gNoRollNoticeLayer:setPos(false)

    -- self:getNode("panel_money"):runAction(cc.MoveTo:create(0.1,cc.p(self.layerGoldPos.x-100,self.layerGoldPos.y)));
    self:getNode("panel_head"):setVisible(false)
    self:checkMusic()
    local showCover=true
    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel and panel.bgVisible==false)then
        showCover=false
    end


    if(showCover)then
        if(gMainBgLayer)then
            gMainBgLayer:stopActionByTag(ACTION_TAG_HIDE)
            local action=cc.Sequence:create(cc.DelayTime:create(0.5),cc.Hide:create())
            action:setTag(ACTION_TAG_HIDE)
            gMainBgLayer:runAction(action);
        -- gMainBgLayer:setVisible(false)
        end

        if(gMainBgCoverLayer )then
            gMainBgCoverLayer:setVisible(true)
            -- gMainBgCoverLayer:setAllChildCascadeOpacityEnabled(true);
            -- gMainBgCoverLayer:setOpacity(0);
            gMainBgCoverLayer:runAction(cc.FadeIn:create(0.4));
        end
        self:showBtnChat(false);
    end

    self:showBtnChat(false);
-- self:getNode("btn_chat"):setVisible(false);
-- if(gMsgWinLayer) then
--     gMsgWinLayer:hide()
-- end
end

function MainLayer:checkMusic()
    local panel=Panel.getTopPanel(Panel.popPanels)
    if( panel )then

        for mainPanelType, param in pairs(Panel.BgMusic) do
            if( panel.__panelType== mainPanelType )then
                gPlayMusic(param.music)
            end
        end
        return
    end
    gPlayMusic("bg/bgm_home.mp3")
end

function MainLayer:callWhenPopBackPanel()
    --显示
    -- self:getNode("panel_money"):runAction(cc.MoveTo:create(0.1,cc.p(self.layerGoldPos.x,self.layerGoldPos.y)));
    if(gMainBgLayer)then
        gMainBgLayer:stopActionByTag(ACTION_TAG_HIDE)
        gMainBgLayer:setVisible(true)
    end

    if(gMainBgCoverLayer)then
        gMainBgCoverLayer:setVisible(false)
        gMainBgCoverLayer:setOpacity(0);
    -- gMainBgCoverLayer:setOpacity(255);
    -- gMainBgCoverLayer:runAction(
    --     cc.Sequence:create(cc.FadeOut:create(0.5),cc.Hide:create())
    --     );
    end
    self:getNode("panel_head"):setVisible(true)

    self:showBtnChat(true);
    -- self:getNode("btn_chat"):setVisible(true);
    self:refreshBtnPay();
    self:checkMusic()

    -- self:getNode("btn_family_skill"):setVisible(#gUserFamilyBuff > 0);

    if(gMainMoneyLayer)then
        gMainMoneyLayer:callWhenPopBackPanel()
    end
    if(gDragonPanel==nil)then
        -- gMsgWinLayer:show()
        gRollNoticeLayer:setPos(true)
    else
    -- gMsgWinLayer:hide()
    end
end

function MainLayer:delOnlineGift()
    if (Data.m_onlineInfo.bolOnline) then
        Panel.popUpVisible(PANEL_ONLINE_GIFT,nil,nil,true)
    end
end

function MainLayer:events()
    return {
        EVENT_ID_USER_DATA_UPDATE,
        EVENT_ID_USER_POWER_UPDATE,
        EVENT_ID_SIGN_INIT,
        EVENT_ID_ONLINE_GIFT_REFRESH,
        EVENT_ID_WORLD_BOSS_INFO,
        EVENT_ID_ENTER_7DAY,
        EVENT_ID_NEW_CHAT,
        EVENT_ID_PLAY_SOUND,
        EVENT_ID_SHOW_ACTIVITY_NEWYER,
        EVENT_ID_SHOW_ACTIVITY_HEFU,
        EVENT_ID_SHOW_ACTIVITY_FESTIVAL,
        EVENT_ID_GET_ACTIVITY_FIRST_PAY_INFO,
        EVENT_ID_SHOW_ACTIVITY_RANK,
        EVENT_ID_SHOW_BIND_PHONE
    }
end

function MainLayer:updatePower()
    if(self.powerDirty==false)then
        return
    end
    self.powerDirty=false

    self.curFormation=(Data.getUserTeam(TEAM_TYPE_ATLAS))
    local power=CardPro.countFormation(self.curFormation,TEAM_TYPE_ATLAS)
    self:setLabelString("txt_power",power)

end


function MainLayer:dealEvent(event,param)
    if(event==EVENT_ID_USER_DATA_UPDATE)then
        -- self:setLabelString("txt_gold",gGetCurGoldNumForShort())
        self:setLabelAtlas("txt_lv",gUserInfo.level)
        self:setLabelString("txt_name",gUserInfo.name)
        self:setLabelAtlas("txt_vip",Data.getCurVip());

        Icon.setHeadIcon(self:getNode("head_icon"),Data.getCurIconFrame());

        local expData= DB.getUserExpByLevel(gUserInfo.level)
        if(expData)then
            local per= gUserInfo.exp/expData.exp
            self:setBarPer("bar",per)
            self:setLabelString("txt_exp",gUserInfo.exp.."/"..expData.exp)
        end
        
        self:refreshBtnPay();

    elseif(event == EVENT_ID_SIGN_INIT) then
        self:enterSign();

    elseif(event==EVENT_ID_USER_POWER_UPDATE)then
        self.powerDirty=true
    elseif(event==EVENT_ID_ONLINE_GIFT_REFRESH)then
        self:refreshOnlineGift()
    elseif(event==EVENT_ID_WORLD_BOSS_INFO)then
        Panel.popUp(PANEL_WORLD_BOSS);
    elseif(event == EVENT_ID_ENTER_7DAY)then
        self:enter7Day(param);
    elseif(event == EVENT_ID_NEW_CHAT)then
        self.msgWin:dealEvent(event,param);
    elseif(event==EVENT_ID_PLAY_SOUND)then
        gPlayTeachSound(param)
    elseif(event==EVENT_ID_SHOW_ACTIVITY_NEWYER)then
        if (param) then
            if (param==1) then
                self:getNode("btn_activity_new"):setVisible(false);
            end
        else
            self:setBtnActivityNew()
        end
    elseif(event==EVENT_ID_SHOW_ACTIVITY_FESTIVAL)then
        if (param) then
            if (param==1) then
                --self:getNode("btn_activity_festival"):setVisible(false);
                self:setBtnActivityFestival(false)
            end
        end
    elseif(event==EVENT_ID_SHOW_ACTIVITY_HEFU)then
        if (param) then
            if (param==1) then
                --self:getNode("btn_activity_festival"):setVisible(false);
                self:setBtnActivityHefu(false)
            end
        end
    elseif(event==EVENT_ID_SHOW_BIND_PHONE)then
            self:setBtnBindPhone(false)
            local panel = Panel.getPanelByType(PANNEL_BIND_PHONE_NUM)
            if panel then
                Panel.popBack(panel:getTag())
            end
    elseif(event==EVENT_ID_GET_ACTIVITY_FIRST_PAY_INFO) then
        Panel.popUp(PANEL_FIRST_PAY,param)
    elseif(event==EVENT_ID_SHOW_ACTIVITY_RANK)then
        self:getNode("btn_activity_rank"):setVisible(false)
        self:getNode("layout_top_docker"):layout()
    end

end

return MainLayer