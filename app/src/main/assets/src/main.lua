
require "cocos.init"

-- cclog
cclog = function(...)
    print(string.format(...))
end


function gShowUiError(msg)
    if gUiErrorShow and gUiErrorShow==true then
        return
    end
    gUiErrorShow=true
    local winSize=cc.Director:getInstance():getWinSize()
    local numLabel= cc.Label:create()
    numLabel:setAnchorPoint(cc.p(0.5,0.5))
    numLabel:setString(msg)
    numLabel:setSystemFontSize(24)
    numLabel:setDimensions(winSize.width-20,winSize.height-20)
    numLabel:setPosition(winSize.width/2,winSize.height/2);
    local curScene = cc.Director:getInstance():getRunningScene()
    if curScene ==nil then
        local loadScene = cc.Scene:create();
        loadScene:addChild(numLabel,10000)
        cc.Director:getInstance():runWithScene(loadScene)
    else
        curScene:addChild(numLabel,10000)
    end
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------") 
    if gShowMapName and msg then
        gShowUiError(msg)
    end
    if(msg and string.len(msg)>=2 and gAccount)then 
        local function callback()
            Scene.hideWaiting()
        end
        local str= string.sub(msg,2,string.len(msg))   
        str= string.gsub(str,']','')  
        str= string.gsub(str,'\"','') 
        if(gLuaLog==nil)then
            gLuaLog={}
        end
        
        if(gLuaLog[str])then
            return
        end
        gLuaLog[str]=1 
        gAccount:sendLuaError(str,callback)
    end
    return msg
end

--是否禁止锁屏
--常亮模式 dimModel 半暗状态 
local preModel = true
function gSetIdleTimerDisabled(on,dimModel)
    if on == nil then
        on= true
    end
    if dimModel == nil then
        dimModel = true
    end
    preModel = dimModel
    if PlatformFunc then
        PlatformFunc:sharedPlatformFunc():setIdleTimerDisabled(on,dimModel)
    end
    
end

function ignoreStopAnimation()
    local  ignore = false
    if gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and (not gAccount:isLogin()) then
        ignore =  true
    end
    if gGetCurPlatform() == CHANNEL_ANDROID_JINLI and (not gAccount:isLogin()) then
        ignore =  true
    end
    return ignore
end

function applicationDidEnterBackground()
    --Panel.popBackTopPanelByType(PANEL_CHAT)
    --cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(false);
    if not ignoreStopAnimation() then
        cc.Director:getInstance():stopAnimation()
    end
    
    AudioEngine.pauseMusic()
    gSetIdleTimerDisabled(false,preModel)
    --LocalNotify.setGameUnActive()
    youmeSaveData();

    gDispatchEvt(EVENT_ID_DID_ENTER_BACKGROUND)
    print("applicationDidEnterBackground")
end

function applicationWillEnterForeground()
    --Panel.popBackTopPanelByType(PANEL_CHAT)
    cc.Director:getInstance():startAnimation()
    AudioEngine.resumeMusic()
    gSetIdleTimerDisabled(true,preModel)
    print("applicationWillEnterForeground")
    
    gCheckLoginTimeout()
    
    if AssetsUpdate and  AssetsUpdate:sharedAssetsUpdate().checkNeedUpdate then
         AssetsUpdate:sharedAssetsUpdate().nErrorCode = ERROR_NO
         AssetsUpdate:sharedAssetsUpdate():checkNeedUpdate()
    end 
 
    gDispatchEvt(EVENT_ID_WILL_ENTER_FOREGROUND)
end

function applicationWillTerminate()
    youmeUnInit();
    gDispatchEvt(EVENT_ID_WILL_TERMINATE)
end

function setScreenSize()
    local DESIGN_WIDTH = 1136
    local DESIGN_HEIGHT = 768
    --math.randomseed(tostring(os.time()):reverse():sub(1, 6))

    local winSize=cc.Director:getInstance():getWinSize()
    local fWidth=0
    local fHeight =0

    local fScale=winSize.width /winSize.height

    if(winSize.width /winSize.height >DESIGN_WIDTH /DESIGN_HEIGHT) then
        fWidth=DESIGN_WIDTH
        fHeight=DESIGN_WIDTH/fScale
    else
        fHeight=DESIGN_HEIGHT
        fWidth=DESIGN_HEIGHT*fScale
    end

    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(fWidth, fHeight, cc.ResolutionPolicy.NO_BORDER)
end

function  setSdkLanguageType(langType)
    if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
        ChannelPro:sharedChannelPro():extenInter("languageType",langType.."")
    end
end

local function initGame()
    if(gDebug)then
        gFileCache = false;
        cc.Director:getInstance():setDisplayStats(false);
        gPrintLuaTable = true;
    else
        gFileCache = true;
        gPrintLuaTable = false;    
    end
    
    IFrame.readGameConfig();
    gCurLanguage = cc.UserDefault:getInstance():getIntegerForKey("language",LANGUAGE_ZHS);
    setSdkLanguageType(gCurLanguage)
    Data.diffInit();
end

local gShowGameHealthTime = -1
local function enterGameHealth()
    -- 游戏健康说明
    gShowGameHealthTime = 0

    local sceneGame = cc.Scene:create()
    local layer = UILayer.new()
    layer:init("ui/ui_notice_h.map")
    sceneGame:addChild(layer)

    local size=cc.Director:getInstance():getWinSize()
    layer:ignoreAnchorPointForPosition(false);
    layer:setAnchorPoint(cc.p(0.5,-0.5));
    layer:setPosition((size.width)/2,(size.height)/2);
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(sceneGame)
    else
        cc.Director:getInstance():runWithScene(sceneGame)
    end
end

local function gameHealthFinish(lloadingHandle)
    if isBanshuReview() then
        if MAX_ATLAS_NUM > 19 then
            MAX_ATLAS_NUM = 19
        end
    end
    DB.deleteReplaceItem();
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(lloadingHandle)
    initGame();
    Scene.enterGame();
end

local function showingGameHealth(dt,lloadingHandle)
    if gShowGameHealthTime < 0 then
        return false
    end
    -- 游戏健康显示时间
    local showtime = 1.6

    gShowGameHealthTime = gShowGameHealthTime+dt
    if gShowGameHealthTime >= showtime then
        gShowGameHealthTime = -1
            
        gameHealthFinish(lloadingHandle);
    end

    return true
end

local  llastTime= 1
local  lloadingHandle = 1
local  ltotal = 1
local  lcurnum = 0
local  numLabel = nil
local  tipstr = ""
local function loadingGame(dt)
    if showingGameHealth(dt,lloadingHandle) == true then
        return
    end

    if  #(gameInit_table)==0 then
        -- loadingLua();

        --[[local lan = cc.UserDefault:getInstance():getIntegerForKey("language",LANGUAGE_ZHS);
        if lan == LANGUAGE_ZHS and gIsMultiLanguage() == false then
            -- 国内版本显示游戏健康提醒
            enterGameHealth();
        else]]
            gameHealthFinish(lloadingHandle);
        --end
        
        return;
    end
    
    llastTime=os.clock()
    while #(gameInit_table)>0 do
        result = gameInit_table[1]
        if nil ~= result then
            result_tab = string.split(result, "=")

            if table.getn(result_tab) ==2 then
                key = string.trim(result_tab[1])
                value = string.trim(result_tab[2])
                _G[key] = require(value)
            elseif table.getn(result_tab) ==1 then
                value=string.trim(result_tab[1])
                require(value)
                --print("="..value)
            end
            table.remove(gameInit_table, 1)
            lcurnum = lcurnum +1
            if(os.clock()-llastTime>=1/60)then
                break
            end
        end
    end

    if UpdateLayer and UpdateLayer.s_sharedUplayer then
        UpdateLayer.s_sharedUplayer:refresh(0,0,0,lcurnum/ltotal,tipstr)
    else
        if  numLabel then
            numLabel:setString(""..string.format("%.1f",lcurnum*100/ltotal) .."%")
        end
    end

end

-- function loadingLua(dt)
--     if  #(startGameInit_table)==0 then
      
--         -- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(lloadingHandle)
--         -- IFrame.readGameConfig();
--         -- Scene.enterGame() 
--         print("startGameInit_table is empty");
--         return;
--     end
    
--     llastTime=os.clock()
--     while #(startGameInit_table)>0 do
--         result = startGameInit_table[1]
--         if nil ~= result then
--             result_tab = string.split(result, "=")

--             if table.getn(result_tab) ==2 then
--                 key = string.trim(result_tab[1])
--                 value = string.trim(result_tab[2])
--                 _G[key] = require(value)
--                 -- print("lua ="..value)
--             elseif table.getn(result_tab) ==1 then
--                 value=string.trim(result_tab[1])
--                 require(value)
--                 -- print("lua ="..value)
--             end
--             table.remove(startGameInit_table, 1)
--             -- lcurnum = lcurnum +1
--             -- if(os.clock()-llastTime>=1/60)then
--             --     break
--             -- end
--             -- print("lcurnum = "..lcurnum);
--         end
--     end

--     -- if UpdateLayer and UpdateLayer.s_sharedUplayer then
--     --     UpdateLayer.s_sharedUplayer:refresh(0,0,0,lcurnum/ltotal,tipstr)
--     -- else
--     --     if  numLabel then
--     --         numLabel:setString(""..string.format("%.1f",lcurnum*100/ltotal) .."%")
--     --     end
--     -- end

-- end

local function startGame()
    require "iframe.utils.functions"
    require "gameinit"
    -- while #(gameInit_table)>0 do
    --     result = gameInit_table[1]
    --     if nil ~= result then
    --         result_tab = string.split(result, "=")

    --         if table.getn(result_tab) ==2 then
    --             key = string.trim(result_tab[1])
    --             value = string.trim(result_tab[2])
    --             _G[key] = require(value)
    --         elseif table.getn(result_tab) ==1 then
    --             value=string.trim(result_tab[1])
    --             require(value)
    --             --print("="..value)
    --         end
    --         table.remove(gameInit_table, 1)
    --     end
    -- end
    -- IFrame.readGameConfig();
    -- Scene.enterGame()


    ltotal = #(gameInit_table)
    numLabel= cc.Label:create()
    numLabel:setString("0%")
    numLabel:setSystemFontSize(24)
    local winSize=cc.Director:getInstance():getWinSize()
    numLabel:setPosition(winSize.width/2,winSize.height/2-45);
    local curScene = cc.Director:getInstance():getRunningScene()
    if curScene ==nil then
        local loadScene = cc.Scene:create();
        loadScene:addChild(numLabel,1500)
        cc.Director:getInstance():runWithScene(loadScene)
    else
        if UpdateLayer and UpdateLayer.s_sharedUplayer then
            print("newload ")
            tipstr = getWordWithFile("updateTip.plist", "enter_game_init")
            UpdateLayer.s_sharedUplayer:refresh(0,0,0,0,tipstr)
        else
            curScene:addChild(numLabel,1500)
        end
        
    end

    lloadingHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(loadingGame,1/60,false )

end



local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    math.randomseed(os.time())

    gSetIdleTimerDisabled(true)
    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLView:createWithRect("HelloLua", cc.rect(0,0,480,640))
        director:setOpenGLView(glview)
    end



    --turn on display FPS
    director:setDisplayStats(false)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

   --setScreenSize()
    startGame()
    
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
