Scene={}
Scene.funcs={}
Scene.funcsDone = {};
Scene.fileCache={}
Scene.textureCache={}
Scene.plistTextureCache={}
Scene.mapTextureCache={}
Scene.cardItemCache={}
Scene.uiLayerCache = {}
Scene.curSceneEffectLevel=3
Scene.maxSceneEffectLevel=0
Scene.minSceneEffectLevel=0
Scene.isInLoginScene=false


function Scene.canEnterCg()

    if(gIsFirstEnter==true and
        not Data.getSysIsUnlock(SYS_CG) and
        not Module.isClose(SWITCH_CG)
        )then
        return true
    end

    return false
end

function Scene.initSceneEffectLevel()

    Scene.curSceneEffectLevel= cc.UserDefault:getInstance():getIntegerForKey("sceneEffect",-1)

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        Scene.maxSceneEffectLevel=2
        Scene.minSceneEffectLevel=3
    else
        Scene.maxSceneEffectLevel=1
        Scene.minSceneEffectLevel=2
    end

    if(Scene.curSceneEffectLevel==Scene.maxSceneEffectLevel or
        Scene.curSceneEffectLevel==Scene.minSceneEffectLevel )then
        return
    end

    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        if gGetCurMem() == 0 then
            Scene.curSceneEffectLevel=Scene.maxSceneEffectLevel
        else
            if(gGetCurMem()<100)then
                Scene.curSceneEffectLevel=Scene.minSceneEffectLevel
            else
                Scene.curSceneEffectLevel=Scene.maxSceneEffectLevel
            end
        end
    else 
        Scene.curSceneEffectLevel=Scene.maxSceneEffectLevel
    end

  

end
function Scene.canClearCacheTexture()
    if(gGetCurMem()<50)then
        return true
    else
        return false
    end
end


function Scene.canCacheTexture()
    if(gGetCurMem()<80)then
        return false
    else
        return true
    end
end


function Scene.addPlistTexture(textureName)
    if(Scene.plistTextureCache[textureName] == nil)then
        local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
        if(texture)then
            Scene.plistTextureCache[textureName]=texture
            texture:retain()
            print("add plist cache"..textureName)
        end
    end
end

function Scene.removeAllPlistTexture()
    for key, var in pairs(Scene.plistTextureCache) do
        var:release()
    end
    Scene.plistTextureCache={}    
end

function Scene.addFlaTextureCache(fla,weaponid,skinid)
    if(Scene.canCacheTexture()==false)then
        return
    end
    local plist={}
    getFlaPackerRes(fla,weaponid,skinid,plist)
    for textureName, var in pairs(plist) do
        local textureName= string.gsub(textureName,".plist",".png")
        if(Scene.textureCache[textureName]==nil)then

            local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
            if(texture)then
                Scene.textureCache[textureName]=texture
                texture:retain()
                print("add fla cache"..textureName)
            end
        end
    end

end



function Scene.removeFlaTextureCache(fla,weaponid,skinid)

    local plist={}
    getFlaPackerRes(fla,weaponid,skinid,plist)
    for textureName, var in pairs(plist) do
        local textureName= string.gsub(textureName,".plist",".png")
        if(Scene.textureCache[textureName])then
            Scene.textureCache[textureName]:release()
            Scene.textureCache[textureName]=nil
            print("remove fla cache"..textureName)
        end
    end

end


function Scene.cacheAtlasMap(mapid,type)
    local max=table.getn(ATLAS_ID_MAP)
    for i=1, max do
        local mapPath
        if(type==7)then
            mapPath="ui/ui_atlas_item_7_"..i..".map"
        else
            mapPath="ui/ui_atlas_item"..i..".map"
        end
        Scene.removeMapTextureCache(mapPath)
    end

    local mapPath
    if(type==7)then
        mapPath="ui/ui_atlas_item_7_"..mapid..".map"
    else
        mapPath="ui/ui_atlas_item"..mapid..".map"
    end

    Scene.addMapTextureCache(mapPath)
end
function Scene.removeAllFlaTextureCache()
    for key, var in pairs(Scene.textureCache) do
        var:release()
    end
    Scene.textureCache={}
end

function Scene.removeMapTextureCache(map)
    local data = Scene.fileCache[map]
    if(data==nil)then
        return
    end

    local images=string.split(data.images,",")
    for key, image in pairs(images) do
        local textureName="images/"..image
        if(Scene.mapTextureCache[textureName])then
            Scene.mapTextureCache[textureName]:release()
            Scene.mapTextureCache[textureName]=nil
            print("remove cache"..textureName)
        end
    end

end
function Scene.addMapTextureCache(map)
    local data = Scene.fileCache[map]
    if(data==nil)then
        return
    end

    local images=string.split(data.images,",")
    for key, image in pairs(images) do
        local textureName="images/"..image
        if(Scene.mapTextureCache[textureName]==nil)then
            local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
            if(texture)then
                Scene.mapTextureCache[textureName]=texture
                texture:retain()
                print("add cache "..textureName)
            end
        end
    end
end

function Scene.removeAllMapTextureCache()
    for key, var in pairs(Scene.mapTextureCache) do
        var:release()
    end
    Scene.mapTextureCache={}
end


function Scene.addCardItemInCache(cardid,carditem)
    if(Scene.cardItemCache[cardid] == nil)then
        Scene.cardItemCache[cardid] = carditem;
        carditem:retain();
    end
end

function Scene.clearCardItemCache()
    for key,carditem in pairs(Scene.cardItemCache) do
        carditem:release();
    end
    Scene.cardItemCache = {};
end

function Scene.addUILayerInCache(panelType,uilayer)
    if(Scene.uiLayerCache[panelType] == nil)then
        Scene.uiLayerCache[panelType] = uilayer;
        uilayer:retain();
    end
end

function Scene.clearUILayerCache()
    for key,uilayer in pairs(Scene.uiLayerCache) do
        uilayer:release();
    end
    Scene.uiLayerCache = {};
end

function Scene.preLoadMainSceneRes(cards,callback)
    local preLoadXml={}
    table.insert(preLoadXml,{path="ui_main"})
    local curHour= gGetHourByTime()
    if(curHour>=18 or curHour<=6)then
        table.insert(preLoadXml,{path="ui_main_night"})
    end

    local sprite3ds={}

    local function getSprite3d(conf,files)
        if(conf.type=="sprite3d")then
            table.insert(files,"c3b/"..conf.path)
        end
        if(conf.children)then
            for key, childConf in pairs(conf.children) do
                getSprite3d(childConf,sprite3ds)
            end
        end
    end

    local objsConf=cc.FileUtils:getInstance():getValueMapFromFile("res/fightScript/mainScene_"..Scene.curSceneEffectLevel..".plist")
    for key, var in pairs(objsConf.objs) do
        getSprite3d(var,sprite3ds)
    end
    Scene.showLoading(preLoadXml,callback,sprite3ds)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_ui_packer_arena.plist");
    Scene.addPlistTexture("packer/images_ui_packer_arena.png");
end

function Scene.preLoadFirstEnterGame()
    local callback = function()
        local mObj = MediaObj:create()
        mObj:setInt("nid",0)
        Net.sendExtensionMessage(mObj,CMD_SYSTEM_INIT)
    end
    if(#startGameInit_table > 0)then
        if(gEnterLayer)then
            gEnterLayer:setVisible(false);
        end
        Scene.showLoading({},callback,{},startGameInit_table);
    else
        callback();
    end
end

function Scene.preLoadBattleRes(cards,bgName,callback)
    local preLoadXml={}
    table.insert(preLoadXml,{path="washit"})
    table.insert(preLoadXml,{path=bgName})
    table.insert(preLoadXml,{path="ui_battle_common"})
    table.insert(preLoadXml,{path="battle_cooperation"})
    table.insert(preLoadXml,{path="battle_buff"})


    local function inCard(cardstr)
        for temp, var in pairs(cards) do
            if(string.find(cardstr,var.cardid))then
                return true
            end
        end
        return false
    end
    local addCardids={}
    local coopertateIds=clone(cards)
    for key, var in ipairs(coopertateIds) do
        local cardid=var.cardid
        local cardDb=DB.getCardById(cardid)
        if(cardDb)then
            local skillDb=DB.getSkillById(cardDb.skillid2)
            if(skillDb and  skillDb.cooperate_card~="" and  inCard(skillDb.cooperate_card))then
                table.insert(addCardids,{cardid=cardid.."_1"})
            end
        end
    end

    for key, var in pairs(addCardids) do
        table.insert(cards,var)
    end

    for key, card in pairs(cards) do
        local cardid=card.cardid
        if(cardid and cardid~=0)then
            table.insert(preLoadXml,{path="r"..cardid,weaponLv=card.weaponLv,awakeLv=card.awakeLv})
            if(gFlaRelation["r"..cardid])then
                local flaXmls=string.split(gFlaRelation["r"..cardid],",")
                for temp, var in pairs(flaXmls) do
                    if(var~="")then
                        table.insert(preLoadXml,{path=var})
                    end
                end
            end
        end


    end
    Scene.clearScene()
    Scene.showLoading(preLoadXml,callback)
end

function Scene.showWaiting(time)
    UILayer.pauseTouch=true
    if(time==nil)then
        time=0
    end
    UILayer.pauseStartTime=gGetCurServerTime()+ time
end

function Scene.hideWaiting()
    UILayer.pauseTouch=false
    UILayer.pauseStartTime=0
end

function Scene.setScreenTouchEnable(enable)
    UILayer.pauseTouchForScreen = not enable;
end

function Scene.createGuideFullEffect()
    loadFlaXml("ui_guide")
    local black =  Panel.createBlackBg()

    local function playEnd()
        gEffectLayer:removeAllChildren()
    end

    local fla=FlashAni.new()

    local function callback()
        fla:playAction("ui_guide_wake",playEnd)
    end
    black:setOpacity(0)
    local size=cc.Director:getInstance():getWinSize()
    fla:playAction("ui_guide_words3",callback)
    fla:setPosition(cc.p(size.width/2,size.height/2))
    gEffectLayer:addChild(black)
    gEffectLayer:addChild(fla,2)
end

function Scene.showLoading(preLoadXml,callback,sprite3ds,luaFiles)
    gLoadingLayer:setVisible(true)
    gLoadingLayer:show(preLoadXml,callback,sprite3ds,luaFiles)
end

function Scene.hideLoading()
    gLoadingLayer:hide()
end


function Scene.clearLazyFunc(tag)
    if(tag==nil)then
        Scene.funcs={}
        Scene.funcsDone = {}
        print("Scene.clearLazyFunc")
    else
        local i=0
        for key, funcData in pairs(Scene.funcs) do
            if(funcData.tag==tag)then
                Scene.funcs[key]=nil
                i=i+1
            end
        end
        -- i=0
        -- for key, funcData in pairs(Scene.funcsDone) do
        -- 	if(funcData.tag==tag)then
        -- 	     Scene.funcsDone[key]=nil
        -- 	     i=i+1
        -- 	end
        -- end
        Scene.funcsDone = {};
        print("Scene.clearLazyFunc "..tag.." num="..i)
    end
end

function Scene.addLazyFunc(target,func,tag)
    table.insert(Scene.funcs,{target=target,func=func,tag=tag})
end

function Scene.setAllLazyFuncDone(target,func)
    Scene.funcsDone.target = target;
    Scene.funcsDone.func = func;
--table.insert(Scene.funcsDone,{target=target,func=func,tag=tag})
end


function Scene.hideDragonScene()

    if(gCameraLayer:getChildByTag(1) )then
        gCameraLayer:getChildByTag(1):setVisible(true)
    end
    gCameraLayer:removeChildByTag(2)
    Panel.popBackAll()
    gPanelLayer:removeAllChildren()
    gStoryLayer:removeAllChildren()
    gDragonLayer:removeAllChildren()
    Scene.clearWinCache()
    gDragonPanel=nil
    gUiBottomLayer:setVisible(true)
    gUiLayer:setVisible(true)
    Panel.rePopupPanel()
end

function Scene.hideMainScene()

    if(gCameraLayer:getChildByTag(1) )then
        gCameraLayer:getChildByTag(1):setVisible(false)
    end
    Panel.popBackAll()
    gPanelLayer:removeAllChildren()
    gStoryLayer:removeAllChildren()
    gDragonLayer:removeAllChildren()
    Scene.clearWinCache()
    gUiBottomLayer:setVisible(false)
    gUiLayer:setVisible(false)
end

function Scene.clearScene()

    gUiBottomLayer:removeAllChildren()
    gUiLayer:removeAllChildren()
    gBattleLayer:removeAllChildren()
    gDragonLayer:removeAllChildren()
    gCameraLayer:removeAllChildren()
    gStoryLayer:removeAllChildren()
    gShowNotice("")
    gMainLayer=nil
    gMainMoneyLayer=nil
    gMainBgLayer=nil
    gMainBgCoverLayer=nil
    gEnterLayer=nil
    gDragonPanel=nil
    battleLayer=nil
    Panel.popBackAll()
    Guide.hideGuide()
    gPanelLayer:removeAllChildren()
    if(gFirstEnterLayer)then
        gFirstEnterLayer:removeFromParent()
        gFirstEnterLayer=nil
    end
    if(gShowMapNamePanel)then
        gShowMapNamePanel:clear();
    end
    gRollNoticeLayer:setPos(false)
    gNoRollNoticeLayer:setPos(false)
    Data.bolInBattle = false;
    -- if(gMsgWinLayer) then
    --     gMsgWinLayer:hide()
    -- end

    cc.Director:getInstance():getScheduler():setTimeScale(1)
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    if(Scene.canClearCacheTexture())then
        Scene.removeAllFlaTextureCache()
        Scene.removeAllMapTextureCache()
        Scene.clearCardItemCache();
        ccs.ArmatureDataManager:destroyInstance()
        if( ccs.ArmatureDataManager.setSoundPlay)then
            ccs.ArmatureDataManager:getInstance():setSoundPlay(not  gSysEffectClose)
        end
        Scene.fileCache={}
    end
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    loadFlaXml("ui_common")
end

function Scene.clearWinCache()
    if(Data.bolInBattle~=true and Scene.canCacheTexture()==false)then
        cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        loadFlaXml("ui_common")
    end
end
function Scene.reEnter()
    Scene.clearCardItemCache();
    Scene.clearScene()
    Data.clear()
    Battle.clear()
    gDigMine.clear()
    gPlayMusic("bg/bgm_logo.mp3")
    gEnterLayer=EnterLayer.new()
    gUiBottomLayer:addChild(gEnterLayer)
    gUiBottomLayer:setVisible(true)
    gUiLayer:setVisible(true)
    Guide.clearGuide()
    Panel.clearRepopup()
    Net.isReconnect=false
    Scene.isInLoginScene=true
    Scene.hideLoading()

end


function Scene.enterMainScene()

    Scene.isInLoginScene=false
    if(Scene.canEnterCg())then
        Scene.firstEnter(1)
        return
    end
    gResetBattleData()
    local ret = Panel.rePopUpPre();
    if ret then
        return;
    end
    Scene.clearScene()
    Panel.rePopupPanel()

    local function callback()
        Scene._enterMainScene()
    end
    Scene.preLoadMainSceneRes({},callback)
end

function Scene.enterBattle()
    battleLayer=BattleLayer.new()
    gBattleLayer:addChild(battleLayer,0)
    gBattleLayer.layer=battleLayer
    battleLayer:playAppear()
    Data.bolInBattle = true;
    Scene.hideLoading()
end

function Scene.firstEnter(type)
    Scene.clearScene()
    gFirstEnterLayer=FirstEnterLayer.new(type)
    gCurScene:addChild(gFirstEnterLayer,15)
end


function Scene.enterDragon(ret,type)
    if(gDragonPanel~=nil)then
        gRollNoticeLayer:setPos(false)
        gDragonPanel:setItems(ret.items,type,ret.cidArray)
        return
    end
    Scene.hideMainScene()
    gDragonPanel=DragonLayer.new()
    gDragonPanel:setItems(ret.items,type,ret.cidArray)
    gDragonLayer:addChild(gDragonPanel,0)
    gRollNoticeLayer:setPos(false)
end


function Scene._enterMainScene()





    gMainBgLayer=MainBgLayer.new()
    gUiBottomLayer:addChild(gMainBgLayer)

    gMainBgCoverLayer=MainBgCoverLayer.new()
    gMainBgCoverLayer:setVisible(false)
    gMainBgCoverLayer:setAllChildCascadeOpacityEnabled(true);
    gMainBgCoverLayer:setOpacity(0);
    gUiBottomLayer:addChild(gMainBgCoverLayer)


    gMainLayer=MainLayer.new()
    gUiBottomLayer:addChild(gMainLayer)


    gMainMoneyLayer=MainMoneyLayer.new()
    gUiLayer:addChild(gMainMoneyLayer)

    gUiBottomLayer:setVisible(true)
    gUiLayer:setVisible(true)
    gRollNoticeLayer:setPos(true)
    gNoRollNoticeLayer:setPos(true)
    gPlayMusic("bg/bgm_home.mp3")


    if(string.len(gUserInfo.name)==0)then
        Guide.dispatch(GUIDE_ID_SET_NAME)
    else
        gAccount:enterGame()
        Guide.initChainStackByPhaseID()
        GuideStepData.taskReward.guide()
    end

    if(gFirstEnterSound==false)then
        gFirstEnterSound=true
        if(gUserInfo.level>5)then
            gPlayTeachSound("v44.mp3",true);
        end
    end
    RedPoint.bolCardViewDirty=true
    --Panel.popUp(PANEL_CARD)
    -- Panel.popUp(PANEL_CARD_INFO,10001)
    Unlock.initEnter();
    Guide.updateGame()
    -- RedPoint.update(true);
    gRedposRefreshDirty = true;



    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel)then
        Panel.checkPanelRefreshMoneyType(panel.__panelType);
        Panel.checkMainPopup(visible)
        Panel.checkMainLayerGold()
    end

    if Guide.isGuiding() and Data.getAdvertisesCount() > 0 then
        Data.clearAdvertises()
    elseif not Guide.isGuiding() and Data.getAdvertisesCount() > 0 then
        Panel.popUp(PANEL_ADVERTISE,1,nil,true,true)
    end

    if(gDebug)then
        if(gCurScene:getChildByTag(9999))then
            return;
        end
        local debugWord = gCreateWordLabelTTF("DEBUG",gFont,30,cc.c3b(255,0,0));
        debugWord:setTag(9999);
        debugWord:setAnchorPoint(cc.p(0,1));
        debugWord:setPosition(cc.p(0,gGetScreenHeight()));
        gCurScene:addChild(debugWord,10000);
    end
end




local g_fCheckIapDelay=0
local g_fCheckReceiptDelay=0
function Scene.updateGame(dt)
    --接收网络
    MediaServer:shared():update(0)

    --print( cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    if gPhoneSecond>=0 then
        gPhoneSecond=gPhoneSecond-dt
    end
    if Net.isCheckingOrder==false and  Net.g_sys_isreceipt==true then
        g_fCheckReceiptDelay = g_fCheckReceiptDelay +dt
        if g_fCheckReceiptDelay>3.0 then
            g_fCheckReceiptDelay = 0
            if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
                Net.reSendCheckOrder()
            else
                Net.reSendIapCheckReceipt()
            end
        end

    end

    if Net.g_sys_ischeckIap==true then
        g_fCheckIapDelay = g_fCheckIapDelay +dt
        if g_fCheckIapDelay>3.0 then
            Net.g_sys_ischeckIap= false
            g_fCheckIapDelay = 0;
            Net.sendCheckOrderRepeat()
        end
    end

    if(gWaitingLayer)then
        gWaitingLayer:setVisible(false)
        if( UILayer.pauseStartTime~=0 and gGetCurServerTime()>UILayer.pauseStartTime  )then
            gWaitingLayer:setVisible(UILayer.pauseTouch)
        end
    end


    if(gLoadingLayer:isVisible())then
        gLoadingLayer:updateLoading()
    end


    if(Net.isConnected==true)then

        if(  os.time() - Data.systemHandShakeTime>60  )then
            Data.systemHandShakeTime= os.time()
            Net.sendSystemHandShake()
        end
    end

    if(not Scene.isInLoginScene)then
        Scene.updateInGameScene();
    end

    Scene.lastTime=os.clock()
    while(table.count(Scene.funcs)>0)do
        local pos,funcObj= table.getKeyAndValue(Scene.funcs)
        if nil ~= funcObj then
            if(os.clock()-Scene.lastTime>1/60)then
                break
            end
            Scene.funcs[pos] = nil
            funcObj.func(funcObj.target)

            if table.count(Scene.funcs) == 0 then
                --结束回调
                if Scene.funcsDone.func then
                    Scene.funcsDone.func(Scene.funcsDone.target);
                end
            end
        end
    end
    gPetAddAttrDirty=true
    gLastCurMen=nil
end

function Scene.updateInGameScene()
    --称号过期
    if(gUserInfo.honor and  gUserInfo.htime and gUserInfo.honor>0)then
        if(gGetCurServerTime()>gUserInfo.htime)then
            gUserInfo.honor=0
            CardPro.setAllCardAttr()
        end
    end

    if(gMainBgLayer)then
        gMainBgLayer:updateGame()
    end

    if(Scene.needLevelup==true and Scene.showLevelUp)then
        Scene.needLevelup=false
        Scene.showLevelUp = false;
        Unlock.initEnter()
        Panel.popUp(PANEL_LEVEL_UP)
    end

    -- 三星翻牌奖励
    CoreAtlas.EliteFlop.showFlopPanel()

    if(Net.isConnected==true)then
        if(gServerTime>0)then

            local curServerTime = gGetCurServerTime();

            if( curServerTime-Data.skillPointTime>DB.getSkillPointTime())then
                Data.skillPointTime=curServerTime
                Net.sendSystemRetime(1) --技能点
            end

            if( curServerTime-Data.energyTime>DB.getEnergyCheckTime())then
                Data.energyTime=curServerTime
                Net.sendSystemRetime(0) --体力
            end

            if( curServerTime-Data.atlasBossTime>DB.getAtlasBossPointCheckTime())then
                Data.atlasBossTime=curServerTime
                Net.sendSystemRetime(3) --boss点数
            end

            --每日体力红点
            local dTime = gGetCurDay(curServerTime)
            if(not Data.redpos.bolDayEnergy) then
                -- print("curTime = "..gGetHourByTime(curServerTime));
                for key,var in pairs(Data.task.getEnergyTime) do

                    if (dTime.hour == toint(var.time[1]) and dTime.min == 0 and dTime.sec == 0) then --12\18\21点的时候 亮起红点
                        Data.redpos.bolDayEnergy = true
                    end
                    -- print("time 1 = "..toint(var.time[1]));
                    -- print("time 2 = "..toint(var.time[2]));
                    if (gGetHourByTime(curServerTime) >= toint(var.time[1]) and gGetHourByTime(curServerTime) < toint(var.time[2]) and not var.hasGet) then
                        Data.redpos.bolDayEnergy = true;
                    -- print("bolDayEnergy ");
                    end
                end
            else
                for key,var in pairs(Data.task.getEnergyTime) do
                    if (dTime.hour == toint(var.time[2]) and dTime.min == 0 and dTime.sec == 0) then --14\20\23点的时候 红点隐藏
                        Data.redpos.bolDayEnergy = false
                    end
                end
            end
            --活动许愿树红点
            Scene.dealActWishRedPoint()
        end
    end

    Guide.updateGame()
    AttChange.update()
    RedPoint.update()

    if gUserInfo.fevip_vip and gUserInfo.fevip_endtime then
        if gUserInfo.fevip_endtime > 0 and gUserInfo.fevip_endtime < gGetCurServerTime() then
            gUserInfo.fevip_endtime = 0
            Data.updateVipData()
            gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
            gDispatchEvt(EVENT_ID_GET_ACTIVITY_VIP_CHANGE)
        end
    end
end

-- function Scene.updateBathInfo(curServerTime)
--     -- body
--     if(gBathInfo.all_uid > 0) then
--         local lefttime = gBathInfo.all_time - curServerTime;
--         -- print("lefttime = "..lefttime);
--         if(lefttime <= 0) then
--             gBathInfo.all_uid = 0;
--             gBathInfo.all_time = 0;
--             if(gMainBgLayer)then
--                 gMainBgLayer:checkBathInfo();
--             end
--         end
--     end
-- end

function Scene.dealActWishRedPoint()
    if(Data.activityWish.maxPoint==nil or Data.activity.wish_max==nil)then
        return
    end
    if (Data.activityWish.maxPoint>=Data.activity.wish_max) then
        return
    end
    -- print("point")
    local passTime=gGetCurServerTime()-Data.activityWish.rTime
    Data.activityWish.newTime = Data.activityWish.iTime-passTime
    if(Data.activityWish.newTime<0)then
        --加诚意点
        Data.activityWish.maxPoint = Data.activityWish.maxPoint + 1;
        Data.activityWish.point = Data.activityWish.point + 1;
        Data.activityWish.iTime = Data.activity.wish_retime;
        Data.activityWish.rTime = gGetCurServerTime();
        Data.redpos.wish = true;
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_WISH_REFRESH)
    end
end

function Scene.enterGame()

    local size=cc.Director:getInstance():getWinSize()
    cc.Director:getInstance():getScheduler():scheduleScriptFunc( Scene.updateGame,1/30,false )

    -- youmeInit();

    ScriptHandlerMgr:getInstance():registerNetHandler(onRecNetMessage)

    local sceneGame = cc.Scene:create()


    gUiBottomLayer=cc.Layer:create()
    sceneGame:addChild(gUiBottomLayer,4)

    gPanelLayer=cc.Layer:create()
    sceneGame:addChild(gPanelLayer,5)


    gUiLayer=cc.Layer:create()
    sceneGame:addChild(gUiLayer,5)  --ui层

    -- gMsgWinLayer=MsgWinLayer.new()
    -- sceneGame:addChild(gMsgWinLayer,5)  --消息层
    gBattleLayer=cc.Layer:create()
    sceneGame:addChild(gBattleLayer,4)  --战斗层


    gDragonLayer=cc.Layer:create()
    sceneGame:addChild(gDragonLayer,4)  --龙

    gCameraLayer=cc.Node:create()
    gCameraLayer:setPositionX(size.width/2)
    gCameraLayer:setPositionY(size.height/2)
    sceneGame:addChild(gCameraLayer,7)


    gDragLayer=cc.Node:create()
    sceneGame:addChild(gDragLayer,8)

    gStoryLayer=cc.Node:create()
    sceneGame:addChild(gStoryLayer,9)


    gGuideLayer=cc.Node:create()
    sceneGame:addChild(gGuideLayer,10)

    gShowItemPoolLayer = ShowItemPoolLayer.new()
    sceneGame:addChild(gShowItemPoolLayer,11)  --提示层

    gNoticeLayer=NoticeLayer.new()
    sceneGame:addChild(gNoticeLayer,11)  --提示层

    gRollNoticeLayer=RollNoticeLayer.new()--cc.Node:create()
    sceneGame:addChild(gRollNoticeLayer,11)  --提示层

    gNoRollNoticeLayer=NoRollNoticeLayer.new()
    sceneGame:addChild(gNoRollNoticeLayer,11)  --提示层

    gTouchTipLayer=cc.Node:create()
    sceneGame:addChild(gTouchTipLayer,12)


    gWaitingLayer=WaitingLayer.new()
    sceneGame:addChild(gWaitingLayer,13)  --提示层


    gLoadingLayer=LoadingLayer.new()
    sceneGame:addChild(gLoadingLayer,14)
    gLoadingLayer:setVisible(false)


    gEffectLayer=cc.Node:create()
    sceneGame:addChild(gEffectLayer,15)

    gConfirmLayer = cc.Node:create();
    local blackBg = gCreateBg();
    gConfirmLayer:addChild(blackBg);
    sceneGame:addChild(gConfirmLayer,20);
    gConfirmLayer:setVisible(false);

    gShowMapNamePanel = MapNamePanel.new();
    sceneGame:addChild(gShowMapNamePanel,1000);

    gCurScene=sceneGame

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(sceneGame)
    else
        cc.Director:getInstance():runWithScene(sceneGame)
    end

    Guide.initGuideData()

    gAccount=Account:new()

    Scene.reEnter()
    Scene.initSceneEffectLevel()
end

function Scene.checkAndCreateMoneyLayer()
    if nil == gMainMoneyLayer then
        gMainMoneyLayer=MainMoneyLayer.new()
        gUiLayer:addChild(gMainMoneyLayer)
    end
end
