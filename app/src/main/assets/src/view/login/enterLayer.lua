local EnterLayer=class("EnterLayer",UILayer)

gIsFirstLogin = true;
function EnterLayer:ctor()
    self:init("ui/ui_enter.map")

    self:hideCloseModule();
    -- self:getNode("btn_notice"):setVisible(false);

    -- gShowNotice("获取服务器列表")
    gShowNotice(gGetWords("noticeWords.plist","get_server_list"));

    self.supportWx = false
    self.installedWx = false

    local function onSeverListGot(result)
        if result then
            -- gShowNotice("获取服务器列表成功")
            gShowNotice(gGetWords("noticeWords.plist","get_server_list_success"));
            local curServer=gAccount:getCurServer()
            if(curServer and self.setLabelString)then
                local showid= curServer.showid
                if showid == nil then
                     showid = curServer.id
                end 
                if isBanshuReview() then
                    self:setLabelString("txt_server",(showid%1000).."服".."-"..curServer.name)
                else 
                    self:setLabelString("txt_server",gGetServerTag(curServer)..(showid%1000).."-"..curServer.name)
                end
            end
            Scene.hideWaiting()
            
            if( gNoticeAppstoreUpdate()==false)then
            
                if NoticeboardPanel.data.first == true then
                    -- Panel.popUp(PANEL_NOTICEBOARD);
                    gEnterNoticeBoard();
                end
            
            end
            
            
            if gAccount:getPlatformId() == CHANNEL_MOTU and gIsAndroid() and self.supportWx then
                gIsFirstLogin = false
            end
            if gAccount:getPlatformId() ~= CHANNEL_APPSTORE and gAccount:getPlatformId() ~= CHANNEL_IOS_JIURU  and gAccount:getPlatformId() ~= CHANNEL_IOS_JITUO and gAccount:getPlatformId() ~= CHANNEL_ANDROID_TENCENT then
                if(gIsFirstLogin and self.showLoginView)then
                    gIsFirstLogin = false
                    self:showLoginView()
                end
            end

            if ChannelPro and ChannelPro:sharedChannelPro().extenInter and gIsInReview() then
                ChannelPro:sharedChannelPro():extenInter("GADBannerView","")
            end
        else
            -- gShowNotice("获取服务器列表失败")
            gShowNotice(gGetWords("noticeWords.plist","get_server_list_fail"));
        end


    end

    self:setLabelString("txt_version","ver:"..gShowVersion);
    -- if isBanshuReview() then
    --     self:getNode("txt_version"):setVisible(false)
    -- end

    Scene.showWaiting()
    local  function getChanelServerlist()
        --local serlist="http://ldt2ios.more2.cn:8000/serverlist.xml"
        if Conf and Conf:shared().getString then
           local confURL =  Conf:shared():getString("g_serverlist_url")
           if confURL and confURL~="" then
                print("confURL==="..confURL)
               return confURL
           end
        end
        local serlist="http://120.26.115.73/master_3Guo_2/serverlist.xml"
        if ChannelPro  and ChannelPro:sharedChannelPro().getServerUrl then
            serlist =  ChannelPro:sharedChannelPro():getServerUrl()
        end 
        
        return serlist
    end

    gAccount:getServerList(getChanelServerlist(), onSeverListGot)


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2);

    if gAccount.motuAccount == false then
        gAccount:delAccount()
    end
    self:updateAccount()


    local function onConnectServer()
        self:updateAccount()
        local curServer=gAccount:getCurServer()
        gAccount:saveServer(curServer.id)
        if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
            gEnterLayer:enterLayer()
        elseif ChannelPro~=nil and ChannelPro:sharedChannelPro().needSelectChannel then
            local selectlayer = ChannelPro:sharedChannelPro():needSelectChannel()
            if selectlayer then
                gEnterLayer:enterLayer()
            end
        end
        Scene.hideWaiting()
    end

    local function onLoginCallback(result)
        account = ChannelPro:sharedChannelPro():getuid()
        if(gGetCurPlatform() == CHANNEL_ANDROID_360)then
            local json = cjson.decode(ChannelPro:sharedChannelPro():getSeesion());
            password = json.seesion;
            local minor = json.minor;
            if(minor == "1")then
                gAccount.isMinor = true;
            else
                gAccount.isMinor = false;
            end
        elseif(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
            local json = cjson.decode(ChannelPro:sharedChannelPro():getSeesion());
            password = json.openkey;
            gAccount.loginParams = json;
            -- 刷新腾讯的登录参数
            if gAccount.loginParams.atype == "wx" and Net.isConnected == true then
                Net.sendSystemRefreshParams();
                return;
            end
        elseif(gGetCurPlatform() == CHANNEL_ANDROID_QUICK)then
            password = ChannelPro:sharedChannelPro():getSeesion()
            if ChannelPro and ChannelPro:sharedChannelPro().getExt then
                local ext = ChannelPro:sharedChannelPro():getExt()
                local rootTable = json.decode(ext)
                if(rootTable.switchAccount == "1")then
                    gAccount.isChangeAccout = true;
                    local function callback()
                    end
                    -- gAccount:delAccount()
                    Net.disConnect(callback)
                    Scene.reEnter()
                    return;
                else
                    gAccount.isChangeAccout = false;
                end
            end
        else
            password = ChannelPro:sharedChannelPro():getSeesion()
        end
        gAccount:loginAccount(account,password,onConnectServer)
    end
    local function onLoutCallback(result)
        local function callback()
            Scene.reEnter()
        end
        gAccount:delAccount()
        Net.disConnect(callback)

        youmeLeaveChatRoom(DataEDCode:encode(gAccount:getCurServer().name));
        if (gFamilyInfo ~= nil and gFamilyInfo.familyId ~= nil and gFamilyInfo.familyId ~= 0) then
            youmeLeaveChatRoom(tostring(gFamilyInfo.familyId));
        end
        youmeLogout()
    end
    if ChannelPro then
        ChannelPro:sharedChannelPro().loginHandler:setHandler(onLoginCallback)
        ChannelPro:sharedChannelPro().logoutHandler:setHandler(onLoutCallback)
        ChannelPro:sharedChannelPro().payHandler:setHandler(PayItem.onPayCallback)
        if ChannelPro:sharedChannelPro().extenInterHandler then
            ChannelPro:sharedChannelPro().extenInterHandler:setHandler(onExtenInterllback)
        end
    end
    if gAccount:getPlatformId() == CHANNEL_MOTU then
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("SupportWeixin","")
        end
    end

    APPSTOREMODE = MOTUMODE


    self:showLayer()

    if(gAccount.isChangeAccout)then
        self:updateAccount()
        account = ChannelPro:sharedChannelPro():getuid()
        password = ChannelPro:sharedChannelPro():getSeesion()
        gAccount:loginAccount(account,password,onConnectServer)
    end
    --self:getNode("btn_show_mapname"):setVisible(gShowMapName)
end


function EnterLayer:showLayer()
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        self:getNode("select_layer"):setVisible(false)
        self:getNode("tencent_layer"):setVisible(true)
        self:getNode("normal_layer"):setVisible(false)
    elseif ChannelPro~=nil and ChannelPro:sharedChannelPro().needSelectChannel then
        local selectlayer = ChannelPro:sharedChannelPro():needSelectChannel()
        if selectlayer then
            self:getNode("select_layer"):setVisible(true)
            self:getNode("normal_layer"):setVisible(false)
            self:getNode("tencent_layer"):setVisible(false)
            if(gIsAndroid()) then
                -- if(self.supportWx == true)then
                --     self:getNode("weixin_login"):setVisible(true)
                -- else
                --     self:getNode("weixin_login"):setVisible(false)
                -- end
                self:getNode("weixin_login"):setVisible(gGetCurPlatform() == CHANNEL_MOTU or gGetCurPlatform() == CHANNEL_APPSTORE)
            elseif ChannelPro~=nil and ChannelPro:sharedChannelPro().getInitInfo then
                local initInfo = ChannelPro:sharedChannelPro():getInitInfo()
                local infoTable = json.decode(initInfo)
                if infoTable and infoTable.installedWx and infoTable.installedWx==1 then
                    self:getNode("weixin_login"):setVisible(true)
                else
                    self:getNode("weixin_login"):setVisible(false)
                end
                if AssetsUpdate and  AssetsUpdate:sharedAssetsUpdate().getCodeVersion then
                    local codeVersion = AssetsUpdate:sharedAssetsUpdate():getCodeVersion()
                    if ""..codeVersion == "1" then
                        self:getNode("weixin_login"):setVisible(true)
                    end
                end
            end
            if gIsInReview() and not gIsAndroid() then
                self:getNode("weixin_login"):setVisible(false)
                local packageName= gAccount:getPackageName()
                if( packageName~="com.m2game.chaosfighters2")then
                    self:getNode("guest_login"):setVisible(false)
                    local winSize=cc.Director:getInstance():getWinSize()
                    local old_pos = cc.p(self:getNode("normal_login"):getPosition())
                    self:getNode("normal_login"):setPosition(winSize.width/2,old_pos.y)
                end
            end
        else
            self:getNode("select_layer"):setVisible(false)
            self:getNode("tencent_layer"):setVisible(false)
            self:getNode("normal_layer"):setVisible(true)
        end
    else
        self:getNode("select_layer"):setVisible(false)
        self:getNode("tencent_layer"):setVisible(false)
        self:getNode("normal_layer"):setVisible(true)
    end
end

function EnterLayer:enterLayer()
    self:getNode("select_layer"):setVisible(false)
    self:getNode("tencent_layer"):setVisible(false)
    self:getNode("normal_layer"):setVisible(true)
    self:updateAccount()
    Scene.hideWaiting()
end

function EnterLayer:hideCloseModule()
    self:getNode("btn_notice"):setVisible(not Module.isClose(SWITCH_NOTICE));
    if(self:getNode("btn_change_lan"))then
        self:getNode("btn_change_lan"):setVisible(gIsMultiLanguage());
        self:setLabelString("txt_lan",gGetWords("languageWord.plist","language"..gCurLanguage));
    end
    self:resetLayOut();
end

-- function EnterLayer:tempDeal()
--     if(gGetCurPlatform() == CHANNEL_APPSTORE) then
--         self:getNode("logo_name"):setVisible(false);
--     end
-- end

function EnterLayer:showLoginView()
    if  gAccount.motuAccount == true then
        local  panelType = PANEL_LOGIN
        if gIsIOS() or gIsAndroid() then
            panelType = PANEL_WX_LOGIN
        end
        if( Panel.isOpenPanel(panelType)==false)then
            Panel.popUp(panelType)
        end
    else
        ChannelPro:sharedChannelPro():showLoginView()
    end

end

function EnterLayer:events()
    return {EVENT_ID_CHANGE_SERVER,EVENT_ID_NOTICE}
end

function EnterLayer:dealEvent(event,param)
    if(event==EVENT_ID_CHANGE_SERVER)then
        local curServer=gAccount:getCurServer()
        local showid= curServer.showid
        if showid == nil then
            showid = curServer.id
        end 
        if isBanshuReview() then
            self:setLabelString("txt_server",(showid%1000).."服".."-"..curServer.name)
        else
            self:setLabelString("txt_server",gGetServerTag(curServer)..(showid%1000).."-"..curServer.name)
        end
    elseif(event == EVENT_ID_NOTICE) then
        self:hideCloseModule();
    end
end


function EnterLayer:updateAccount()
    if(gAccount:isLogin())then
        self:setLabelString("lab_login_account","btn_account_logined","btnWords.plist")
        self:setLabelString("txt_account",gAccount:getAccountName())
    else
        self:setLabelString("lab_login_account","btn_account_login","btnWords.plist")
        self:setLabelString("txt_account","")
    end
end


function EnterLayer:onTouchEnded(target)


    local function onLoginCallback()
        local curServer=gAccount:getCurServer()
        Net.connectToServer(curServer.ip,curServer.port)
    end

    if  target.touchName=="btn_login" then
        if(gAccount:isLogin())then
            gAccount:delAccount()
            self:updateAccount()
            if gAccount.motuAccount == false then
                ChannelPro:sharedChannelPro():logout()
            end
            self:showLayer()
        else
            self:showLoginView()
        end
    elseif  target.touchName=="btn_enter" then
        if(gAccount:isLogin())then
            gAccount:loginEnter(onLoginCallback)
        else
            self:showLoginView()
        end
    elseif  target.touchName=="btn_server" then

        if(gAccount.rolelist)then
            Panel.popUp(PANEL_SERVER_LIST)
        else
            self:showLoginView()
        end

    elseif target.touchName=="normal_login" then

        gAccount.motuAccount =  true
        APPSTOREMODE = MOTUMODE
        Panel.popUp(PANEL_WX_LOGIN)

    elseif target.touchName=="weixin_login" then

        gAccount.motuAccount =  false
        ChannelPro:sharedChannelPro():showLoginView("wx")
        APPSTOREMODE = WXMODE

    elseif target.touchName=="guest_login" then

        local function onGuestCallback()
            local curServer=gAccount:getCurServer()
            gAccount:saveServer(curServer.id)
            gEnterLayer:enterLayer()
            APPSTOREMODE = GUESTMODE
        end
        gAccount.motuAccount =  true
        gAccount:guestLogin(onGuestCallback)

    elseif target.touchName=="tencent_qq_login" then

        gAccount.motuAccount =  false
        ChannelPro:sharedChannelPro():showLoginView("qq")

    elseif target.touchName=="tencent_weixin_login" then

        gAccount.motuAccount =  false
        ChannelPro:sharedChannelPro():showLoginView("wx")

    elseif target.touchName=="btn_test1"then
        gIsFirstEnter=true
        if(gAccount:isLogin())then
            gAccount:loginLastAccount(onLoginCallback)
        else
            Panel.popUp(PANEL_LOGIN)
        end
    elseif target.touchName=="btn_test2"then
        --  Panel.popUp(PANEL_NEW_CARD,10001)
        Scene.clearScene()
        gEnterLayer=EditLayer.new()
        gUiBottomLayer:addChild(gEnterLayer)
    elseif target.touchName=="btn_test3"then
        gIsFirstEnter=true
        if(gAccount:isLogin())then
            gAccount:loginLastAccount(onLoginCallback)
        else
            Panel.popUp(PANEL_LOGIN)
        end
    elseif target.touchName == "btn_notice" then
        -- Panel.popUp(PANEL_NOTICEBOARD);
        gEnterNoticeBoard();
    elseif target.touchName == "btn_show_mapname" then
        gShowMapName = not gShowMapName;
    elseif target.touchName == "btn_change_lan" then
        Panel.popUpVisible(PANEL_LANGUAGE_SET,1);
    end

end



return EnterLayer