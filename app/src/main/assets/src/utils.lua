function gIsAndroid()
    local ret=false
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        ret = true
    end
    return ret
end

function gIsIOS()
    local ret=false
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
        ret = true
    end
    return ret
end

function gIsWindows()
    local ret=false
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        ret = true
    end
    return ret
end

function gIsMac()
    local ret=false
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_MAC then
        ret = true
    end
    return ret
end

function gParseZnNum(num)
    -- local znNums={"一","二","三","四","五","六","七","八","九","十"}
    if(gCurLanguage == LANGUAGE_ZHS or gCurLanguage == LANGUAGE_ZHT)then

        local znNums = {};
        for i=1,10 do
            znNums[i] = gGetWords("labelWords.plist","num"..i);
        end
        local ret=""
        if(num>10)then
            local temp=math.floor(num/10)
            if(temp>=2)then
                ret=znNums[temp]
            end
            ret=ret..znNums[10]
            num=num%10
        end
        if(znNums[num])then
            ret=ret..znNums[num]
        end
        return ret

    end
    return num;
end

function gGetTotalMem()
    if(gLastTotalMen)then
        return gLastTotalMen
    end
    gLastTotalMen=0
    if( PlatformFunc:sharedPlatformFunc().getTotalMem)then
        gLastTotalMen= math.floor( PlatformFunc:sharedPlatformFunc():getTotalMem()/1000)
    end
    return gLastTotalMen
end

function gGetCurMem()
    if(gLastCurMen)then
        return gLastCurMen
    end
    gLastCurMen=0
    if( PlatformFunc:sharedPlatformFunc().getUnusedMen)then
        gLastCurMen=math.floor(  PlatformFunc:sharedPlatformFunc():getUnusedMen()/1000)
    end
    return gLastCurMen
end



function gIsShowUpdateActivity()
    local packageName= gAccount:getPackageName()
    if( packageName=="com.shiji.luan2" or
        packageName=="com.wg.luan2")then
        return false
    end
    return false
end

function gNoticeAppstoreUpdate()

    local function onOk()
        local url =gAccount.installUrl
        PlatformFunc:sharedPlatformFunc():openURL(url)
        os.exit()

    end
    if(gIsAppstoreOld())then
        gConfirmCancel(gGetWords("noticeWords.plist","old_appstore"),onOk)
        return true
    end

    return false
end

function gIsAppstoreOld()
    if  gAccount:getPlatformId() == CHANNEL_APPSTORE then
        if(g_code_version==nil or g_code_version<5)then
            return false
        end
    end
    return false
end
--评审中
function gIsInReview()
    if(g_code_version==nil or g_serverlist_version==nil )then
        return false
    end
    if( g_code_version >g_serverlist_version)then
        return true
    end
    return false
end
--多语言
function gIsMultiLanguage()
    local platform = gGetCurPlatform();
    if  platform == CHANNEL_ANDROI_EFUNENCN or platform == CHANNEL_ANDROI_EFUNENCN_LY or platform == CHANNEL_IOS_EFUN_CN_EN or gDebug then
        return true;
    end
    return false;    
end

function gIsZhLanguage()
    if(gCurLanguage == LANGUAGE_ZHS or gCurLanguage == LANGUAGE_ZHT)then
        return true;
    end
    return false;
end

function gMultMergeItem(list)
    local temp={}
    for key, var in pairs(list.items) do
        if(temp[var.id]==nil)then
            temp[var.id]=0
        end
        temp[var.id]=temp[var.id]+var.num
    end
    local newItems={}
    for key, var in pairs(temp) do
        table.insert(newItems,{id=key,num=var})
    end
    list.items=newItems
    return list
end

function gCalAtlasHpReward(hp,  stageInfo)
    if(stageInfo==nil)then
        return 0
    end
    return math.min(math.round(hp*stageInfo.dmgparam/1000),stageInfo.itemmax)
end

function gShineNode(node)
    if(node==nil)then
        return
    end
    gSetCascadeOpacityEnabled(node,true)
    node:setOpacity(0)
    node:setVisible(true)
    node:stopAllActions()
    local actions={}
    table.insert(actions,cc.FadeTo:create(0.7,255))
    table.insert(actions,cc.FadeTo:create(0.7,100))

    local pAct_repeat =cc.RepeatForever:create(cc.Sequence:create(actions) )
    node:runAction(pAct_repeat)
end

--世界boss奖励值
function gCalWorldBossHpReward(hp)
    -- print("1gCalWorldBossHpReward="..hp)
    -- print("2gCalWorldBossHpReward="..hp)
    if (Data.worldBossInfo==nil) then
        return 0
    end
    --怪等级
    local lv = Data.worldBossInfo.bosslv
    if (lv<=0) then
        return 0
    end
    local param = 1
    if Data.worldBossInfo.bosstype == 1 then
        -- 新世界boss
        param = 2.5
    end
    return math.floor(hp * (0.9 * (350000 / (350000 + hp)) + 0.05)/param)
    -- return math.floor(hp/(Data.worldBossInfo.goldpro/100))
        -- return math.floor(hp)
end

function gCalAtlasDeadReward(num,  stageInfo)
    if(stageInfo==nil)then
        return 0
    end
    return math.min(math.round(num*stageInfo.dmgparam),stageInfo.itemmax)
end
function gSetDepth2d(node,value)
    if(node==nil)then
        return
    end
    if(node.setDepth2D==nil)then
        return
    end

    node:setDepth2D(value)
    local children = node:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        gSetDepth2d( children[i + 1],value)
    end
end

function gSetCascadeOpacityEnabled(node,value)
    if(node.setCascadeOpacityEnabled==nil)then
        return
    end
    node:setCascadeOpacityEnabled(value)
    local children = node:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        gSetCascadeOpacityEnabled( children[i + 1],value)
    end

end

function gConvertTo3DWorldPos(target)
    local size=cc.Director:getInstance():getWinSize()
    local zeye = cc.Director:getInstance():getZEye()
    local mat4=cc.mat4.new(target:getNodeToWorldTransform())
    local pos=cc.vec3(mat4[13],mat4[14],mat4[15])
    local posZ=  zeye-pos.z
    local curWidth=size.width *(posZ/zeye)
    local curHeight=size.height *(posZ/zeye)

    local newX=(   (pos.x+(curWidth-size.width )/2)* (size.width/curWidth))
    local newY=(   (pos.y+(curHeight-size.height )/2)* (size.height/curHeight))
    local size=target:getContentSize()
    return cc.p(newX+size.width/2 ,newY+size.height/2 )

end




function gConfirmAll(txt,onOk,onCancel,onClose,swap)
    local confirmLayer = ConfirmLayer.new(CONFIRM_TYPE_ALL,swap)
    confirmLayer:showContent("",txt)
    confirmLayer:setCloseFunction(onClose)
    confirmLayer:setConfirmFunction(onOk)
    confirmLayer:setCancelFunction(onCancel)

end

function gConfirm(txt,onOk)

    local confirmLayer = ConfirmLayer.new(CONFIRM_TYPE_CONFIRM)
    confirmLayer:showContent("",txt)
    confirmLayer:setConfirmFunction(onOk)

end

function gConfirmCancel(txt,onOk,onCancel,swap)
    local confirmLayer = ConfirmLayer.new(CONFIRM_TYPE_CONFIRM_CANCEL,swap)
    confirmLayer:showContent("",txt)
    confirmLayer:setConfirmFunction(onOk)
    confirmLayer:setCancelFunction(onCancel);
end

function gConfirmClose(txt,onOk,onClose)
    local confirmLayer = ConfirmLayer.new(CONFIRM_TYPE_CONFIRM_CLOSE)
    confirmLayer:showContent("",txt)
    confirmLayer:setConfirmFunction(onOk)
    confirmLayer:setCloseFunction(onClose)
end

function gSetEditObjPro(obj,objConf)

    assert(loadstring("  scale= "..objConf.scale))()
    obj:setScaleX(tonum(scale[1]))
    obj:setScaleY(tonum(scale[2]))
    obj:setScaleZ(tonum(scale[3]))

    if(objConf.globalZ)then
        obj:setGlobalZOrder(toint(objConf.globalZ))
    end

    assert(loadstring("  pos= "..objConf.pos))()
    obj:setPosition3D(cc.vec3(tonum(pos[1]),tonum(pos[2]),tonum(pos[3])))

    assert(loadstring("  rotation= "..objConf.rotation))()
    obj:setRotation3D(cc.vec3(tonum(rotation[1]),tonum(rotation[2]),tonum(rotation[3])))


end

function gCreateEditObj(conf,hideStandPos)
    local obj=nil

    if(string.find(conf.id,"standPos") and hideStandPos==true )then
        obj= cc.Node:create()
    elseif(conf.type=="sprite3d")then
        obj=cc.Sprite3D:create("c3b/"..conf.path)

        local animation = cc.Animation3D:create("c3b/"..conf.path)
        obj.animation=animation
        local isPlay=true
        if (conf.param and toint(conf.param)==0) then
            isPlay=false
        end

        if nil ~= animation  and isPlay then
            local animate = cc.Animate3D:create(animation)
            obj:runAction(cc.RepeatForever:create(animate))
        end




    elseif(conf.type=="flash")then
        loadFlaXml( conf.path)
        local fla=FlashAni.new()
        fla:playAction(conf.action)
        obj=fla
        if(conf.depth2d and not string.find(conf.action,"ui_main_name"))then
            obj:setDepth2D(true)
        end
    elseif(conf.type=="sprite")then

        if(cc.SpriteFrameCache:getInstance():getSpriteFrame(conf.path)~=nil) then

            obj=cc.Sprite:createWithSpriteFrameName(conf.path)
        else

            obj=cc.Sprite:create(conf.path)
        end
        if(conf.depth2d and obj)then
            obj:setDepth2D(true)
        end
    elseif(conf.type=="particle3d")then
        obj= cc.PUParticleSystem3D:create(conf.path,conf.material)
        obj:startParticleSystem()

    elseif(conf.type=="node")then
        obj= cc.Node:create()

    elseif(conf.type=="camera")then
        local winSize = cc.Director:getInstance():getWinSize()
        local zeye=     winSize.height/ (math.tan(math.rad(conf.fov/2))*2)
        local camera = cc.Camera:createPerspective(conf.fov, winSize.width / winSize.height, 1, zeye*10)
        gCameraLayer:addChild(camera)
        camera.zeye=zeye
        camera:lookAt(cc.vec3(0, 0, 0.0), cc.vec3(0.0, 1.0, 0.0))
        obj=camera

    end


    if(obj)then
        for key, var in pairs(conf) do
            obj[key]=conf[key]
        end
        obj.childObjs={}
        if(conf.children)then
            for key, childConf in pairs(conf.children) do
                local childObj= gCreateEditObj(childConf,hideStandPos)
                table.insert( obj.childObjs,childObj)
                if(childObj)then
                    gSetEditObjPro(childObj,childConf)
                    obj:addChild(childObj)
                end
            end
        end
    end
    return obj
end


function gParserDay(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end
    local t = gGetDate("*t",time)
    local txt=gGetWords("labelWords.plist","lb_day_time",t.year,minNum(t.month),minNum(t.day),minNum(t.hour),minNum(t.min))
    return txt
end

function gParserMonDay(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end
    local t = gGetDate("*t",time)
    local txt=gGetWords("labelWords.plist","lb_mday_time",(t.month),minNum(t.day))
    return txt
end

function gParserMinTime(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end
    local hour= math.floor(time/3600)
    local min=math.floor((time%3600)/60)
    local sec=time%60
    return minNum(min)..":"..minNum(sec)
end

function gParserMinTimeStr(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end
    local hour= math.floor(time/3600)
    local min=math.floor((time%3600)/60)
    local sec=time%60
    if(min==0)then
        return gGetWords("labelWords.plist","secName",minNum(sec))
    else
        return gGetWords("labelWords.plist","minSecName",minNum(min),minNum(sec))
    end
end



function gFollowTouch(node,touch)
    local pos=touch:getLocation()
    pos= node:getParent():convertToNodeSpace(pos)
    pos.y= pos.y+node:getContentSize().height/2
    node:setPosition(pos)

end


function  gCheck3DInsde(touch,target,contentSize)
    local size=cc.Director:getInstance():getWinSize()
    local zeye = cc.Director:getInstance():getZEye()
    local mat4=cc.mat4.new(target:getNodeToWorldTransform())
    local pos=cc.vec3(mat4[13],mat4[14],mat4[15])
    local posZ=  zeye-pos.z
    local curWidth=size.width *(posZ/zeye)
    local curHeight=size.height *(posZ/zeye)

    local rect   = {}
    local newX=(   (pos.x+(curWidth-size.width )/2)* (size.width/curWidth))
    local newY=(   (pos.y+(curHeight-size.height )/2)* (size.height/curHeight))
    local size=target:getContentSize()
    if(contentSize~=nil)then
        size=contentSize
    end
    rect.width=size.width
    rect.height=size.height
    rect.x=newX
    rect.y=newY

    local location = touch:getLocation()
    return cc.rectContainsPoint(rect, location)
end


function gParserDayHourTime(leftTime) 
    if(leftTime<=0)then
        leftTime=0
    end
    local leftDay = gGetDayByLeftTime(leftTime);
    if(leftDay<=0)then
        return gParserHourTime(leftTime)
    else
        leftTime=leftTime-leftDay*24*60*60
        
        local   function parseTime(time)
            local function minNum(num)
                if(num<10)then
                    return "0"..num
                end
                return num
            end
            local hour= math.floor(time/3600)
            local min=math.floor((time%3600)/60)
            local sec=time%60
            return minNum(hour)..":"..minNum(min)
        end
        return gGetWords("luckyWheel.plist","dayTime",leftDay, parseTime(leftTime))
    end
end


function gParserHourTime(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end
    local hour= math.floor(time/3600)
    local min=math.floor((time%3600)/60)
    local sec=time%60
    return minNum(hour)..":"..minNum(min)..":"..minNum(sec)
end


-- function gGetCurWDay()
--     local date=( os.date("*t", gGetCurServerTime()))
--     return date.wday-1;

-- end


function gGetDayByLeftTime(lefttime)
    local day = math.floor(lefttime/24/60/60);
    if(day<0)then
        day = 0;
    end
    return day;
end

function gGetCurDay(time)
    if(time==nil)then
        time=gGetCurServerTime()
    end
    local date=( gGetDate("*t", time))
    return date

end


function gGetHourByTime(time)
    if(time==nil)then
        time=gGetCurServerTime()
    end
    local date=( gGetDate("*t", time))
    return date.hour

end

function gGetYYMMDDHHMMSSByTime(time)
    if(time==nil)then
        time=gGetCurServerTime()
    end
    -- local date=os.date("%Y%s%d %H:%M:%S",time)
    local date=gGetDate("%Y-%m-%d %X",time)
    return date
end

function gGetLeftTimeToday()
    local date=( gGetDate("*t", gGetCurServerTime()) )
    local curTime = date.hour*60*60+date.min*60+date.sec;
    local lefttime = 24*60*60 - curTime;
    return lefttime;
end

function gGetLeftTimeByTime(time,byhour)
    if(time==nil)then
        time=gGetCurServerTime()
    end
    if byhour==nil then
        byhour=24
    end
    local date=( gGetDate("*t", time) )
    local curTime = date.hour*60*60+date.min*60+date.sec;
    local lefttime = byhour*60*60 - curTime;
    return lefttime;
end

function table.count(table)
    local count=0
    if(table==nil)then
        return 0
    end
    for key, var in pairs(table) do
        count=count+1
    end
    return count
end

function table.getKeyAndValue(table)
    for key,value in pairs(table) do
        return key,value
    end
    return nil,nil
end

function table.shallowCopy(table)
    local tab = {}
    for k, v in pairs(table or {}) do
        tab[k] = v
    end
    return tab
end

-- function table.deepCopy(table)
--     local tab = {}
--     for k, v in pairs(table or {}) do
--         if type(v) ~= "table" then
--             tab[k] = v
--         else
--             tab[k] = table.deepCopy(v)
--         end
--     end
--     return tab
-- end

function gShowNotice(txt)
    if(gNoticeLayer) then
        gNoticeLayer:showNotice(txt)
    end
end

local function isMiningMsg(cmd)
    if string.find(cmd, "mining") ~= nil then
        return true
    end
    return false
end

local function isMiningEventMsg(cmd)
    if string.find(cmd, "mining.e") ~= nil then
        return true
    end
    return false
end

function gShowCmdNotice(cmd,code)
    if cmd == CMD_IAP_CHECKORDER then
        if (code==ERR_INVALID_OPERATE) or (code == 9 and gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and Net.isCheckingOrder == true) then
            if (Net.iIapCheckCount<20) then
                Net.g_sys_ischeckIap=true
            else
                Net.isCheckingOrder=false
            end
            return
        elseif code == 9 or code == 16 or code == 17 or code == 26 then
            return
        end
    elseif (cmd == CMD_WORLD_WAR_FIND and code == 30) or
           (cmd == CMD_CROSS_TREASUER_FIGHT_RESULT and code == 6) then
        return
    elseif cmd == CMD_CHAT_WORLD and code == 22 then
        return
    elseif cmd == CMD_ACHIEVE_GET and code == 11 then
        return
    elseif cmd == CMD_MINING_DIG and code == 20 then
        return
    elseif cmd == CMD_MINING_DIG and code == 11 then
        return
    elseif code == 9 and cmd == CMD_FAMILY_CANCEL_APPLY then
        return
    elseif code == 10 and (cmd =="cave.event5info" or cmd =="cave.event4info" or cmd =="cave.event3info" or cmd =="cave.event2info" or cmd =="cave.event1info") then
        return
    elseif (code == 9 and isMiningMsg(cmd)) or
        (code == 11 and isMiningEventMsg(cmd)) or
        (code == 5 and cmd == CMD_MINING_ENTER) or
        (code == 28 and cmd == CMD_MINING_ENTER)then
        -- local logStr = "mining msg is:"..cmd.."err code is:"..code
        -- gAccount:sendLuaError(logStr,function()
        -- end)
        Net.sendMiningInfo(0,true)
        Net.sendRefreshData()
        return
    elseif code == 34 and cmd == CMD_MINING_OPEN_BOX then
        gShowNotice(gGetWords("noticeWords.plist","data_error"))
        Net.sendRefreshData()
        return
    elseif code == 5 and cmd == CMD_DAYTASK_GET then
        --处理红点
        for key,var in pairs(TaskPanelData.getEnergyTaskIds) do
            if var == Data.task.pid then
                Data.redpos.bolDayEnergy = false; --老红点删掉
                break;
            end
        end
    end
    local word = gGetCmdCodeWord(cmd,code);
    if(word~="nil" and string.len(word)~=0)then
        gShowNotice(word)
    elseif code ~= 0 then
        gShowNotice("error code "..code.. " cmd "..cmd)
    end
end


function gAddCenter(child, node)
    node:addChild(child)
    child:setPositionY(node:getContentSize().height/2)
    child:setPositionX(node:getContentSize().width/2)
end

function gAddMapCenter(child, node)
    node:addChild(child)
    child:setPositionY(node:getContentSize().height/2+child:getContentSize().height/2)
    child:setPositionX(node:getContentSize().width/2-child:getContentSize().width/2)
end


function gDispatchEvt(event,param)
    Panel.dispatchEvt(event,param)

    if(gMainBgLayer)then
        local events=gMainBgLayer:events()
        for key, uiEvent in pairs(events ) do
            if(uiEvent==event)then
                gMainBgLayer:dealEvent(event,param)
            end
        end
    end
    if(gMainLayer)then
        local events=gMainLayer:events()
        for key, uiEvent in pairs(events ) do
            if(uiEvent==event)then
                gMainLayer:dealEvent(event,param)
            end
        end
    end

    if(gMainMoneyLayer)then
        local events=gMainMoneyLayer:events()
        for key, uiEvent in pairs(events ) do
            if(uiEvent==event)then
                gMainMoneyLayer:dealEvent(event,param)
            end
        end
    end
    
    if(gDragonPanel)then
        local events=gDragonPanel:events()
        for key, uiEvent in pairs(events ) do
            if(uiEvent==event)then
                gDragonPanel:dealEvent(event,param)
            end
        end
    end



    if(gEnterLayer)then
        local events=gEnterLayer:events()
        for key, uiEvent in pairs(events ) do
            if(uiEvent==event)then
                gEnterLayer:dealEvent(event,param)
            end
        end
    end

    if nil ~= gDigMineLayer then
        for _, uiEvent in pairs(gDigMineLayer:events() ) do
            if(uiEvent == event)then
                gDigMineLayer:dealEvent(event,param)
            end
        end
    end

    if(Guide.events)then
        local events=Guide.events()
        for key, uiEvent in pairs(events ) do
            if(uiEvent==event)then
                Guide.dealEvent(event,param)
            end
        end
    end
    gGlobalDealEvent(event,param)
end
function gStopEffect(id)
    return AudioEngine.stopEffect(id)
end
function gPlayEffect(url,stopPreSound,bolLoop)
    local loop = false
    if (bolLoop) then
        loop = bolLoop
    end
    if gSysEffectClose then
        return 0;
    end
    if stopPreSound and stopPreSound == true and gPreSound then
        gStopEffect(gPreSound);
    end
    gPreSound = AudioEngine.playEffect(url,loop);
    return gPreSound;
end

function gPlayTeachSound(filename,stopPreSound)
    if(isBanshuReview() == true) then return end
    -- body
    if stopPreSound and stopPreSound == true and gPreTeachSound then
        gStopEffect(gPreTeachSound);
    end

    filename = string.gsub(filename,".wav",".mp3");

    gPreTeachSound = gPlayEffect("sound/teach/"..filename);
end

function gStopMusic()
    return AudioEngine.stopMusic()
end
function gPlayMusic(url,forcePlay)

    if(url==nil)then
        return;
    end
    forcePlay = forcePlay or false;
    if(AudioEngine.lastMusic==url and not forcePlay)then
        return
    end
    AudioEngine.lastMusic=url

    if gSysMusicClose then
        return;
    end
    AudioEngine.stopMusic()
    AudioEngine.playMusic("sound/"..url,true)

    -- gSetMusic();

end

function gSetMusic()
    if gSysMusicClose then
        AudioEngine.stopMusic()
        -- AudioEngine.pauseMusic();
        -- AudioEngine.setMusicVolume(0);
    else
        -- print("AudioEngine.lastMusic = "..AudioEngine.lastMusic);
        gPlayMusic(AudioEngine.lastMusic,true)
        -- AudioEngine.resumeMusic();
        -- AudioEngine.setMusicVolume(100);
    end
end

function gSetVideo()
    local bShow = Module.isClose(SWITCH_VIDEO) == false
    bShow = bShow and (not gSysVideoClose)
    if (gShowWeRecBtn) then
        gShowWeRecBtn(bShow)
    end
end

function gReadCSVfile(path)
    local filePath=cc.FileUtils:getInstance():fullPathForFilename(path)
    local content = cc.FileUtils:getInstance():getStringFromFile(filePath);
    -- print("content = "..content);
    local lines = string.split(content,"\r\n");
    -- print_lua_table(lines);
    -- print("--------");
    ret = {};
    for key,var in pairs(lines) do
        if(string.sub(var,1,2) ~= "--")then
            if(var ~= "")then
                if(string.sub(var,1,1)=="\"")then
                    print("before var = "..var);
                    var = string.sub(var,2,string.len(var)-1)
                    print("after var = "..var);
                end
                local datas = string.split(var,";");
                table.insert(ret,datas);
            end
        end
    end
    print_lua_table(ret);
    return ret;

end

function gGetTimeZoneOffsetToZone8()
    local now = os.time()
    local nowDate = os.date("*t",now)
    -- local utcDate = os.date("!*t",now)
    local utcTime = os.time(os.date("!*t", now))
    local diffTime = os.difftime(now, utcTime + 8 * 3600)

    if nowDate.isdst then
        diffTime = diffTime + 3600
    end
    return diffTime
end

function gGetTimeZoneOffsetToServerZone()
    local now = os.time()
    local nowDate = os.date("*t",now)
    -- local utcDate = os.date("!*t",now)
    local utcTime = os.time(os.date("!*t", now))
    local diffTime = os.difftime(now, utcTime + gServerTimeZone * 3600)

    if nowDate.isdst then
        diffTime = diffTime + 3600
    end
    return diffTime
end

function gGetCurServerTime()
    return os.time()+ gServerTime-gClientTime -- - gGetTimeZoneOffsetToZone8()
end


function   gCheckLoginTimeout()
    if(gLoginTime==nil)then
        return
    end
    local isTimeout=false

    local dayTime=24*60*60
    local refreshHour=gResetDataInDay

    --超过24小时
    if(gGetCurServerTime()-gLoginTime>dayTime)then
        isTimeout=true
    end

    --微信超过2小时
    if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT and gGetCurServerTime()-gLoginTime>2*60*60)then
        if(gAccount.loginParams ~= nil and gAccount.loginParams.atype ~= nil and gAccount.loginParams.atype == "wx")then
            isTimeout=true
        end
    end

    local curHour= gGetHourByTime()
    local loginHour=gGetHourByTime(gLoginTime)

    if(curHour>=refreshHour    )then
        if( loginHour<refreshHour )then
            isTimeout=true
            print("timeout2")
        elseif(curHour<loginHour)then
            isTimeout=true
            print("timeout3")
        end
    end

    if(isTimeout)then
        local function callback()
            Scene.reEnter()
        end
        Net.disConnect(callback)
    end

end

--保留两位小数点
function gFloor2Point(num)
    local tmp_num = math.floor(num*10000)
    -- print("1tmp_num="..tmp_num)
    tmp_num = tmp_num/100
    -- print("2tmp_num="..tmp_num)
    return tmp_num
end

function gSetServerTime(time)
    gServerTime=time
    gClientTime=os.time();
end

function gSetServerTimeZone(zone)
    gServerTimeZone=zone
end

function gGetLocalZone()
    local now = os.time()
    local nowDate = os.date("*t",now)
    local utcTime = os.time(os.date("!*t", now))
    return os.difftime(now, utcTime) / 3600
end


function gGetDate(format,time)
    if(time == nil)then
        -- time = os.time();
        time = gGetCurServerTime();
    end
    return os.date(format,time - gGetTimeZoneOffsetToServerZone());
end


function gParseCardAwakeLv(lv)
    if(lv)then
        return math.floor(lv/7)
    end
    return 0
end

function gParseCardAwakeId(lv,maxSkinId,isPet)
    local max=1
    if(maxSkinId==nil)then
        maxSkinId=1
    end
    if maxSkinId and maxSkinId>=FINAL_AWAKE then
         maxSkinId=2
     end 
    if( ccs.ArmatureDataManager:getInstance().getVersion)then 
        max=maxSkinId
    end
    
    if(max>maxSkinId)then
        max=maxSkinId
    end
    if(lv )then
        -- print_lua_table(Data.cardAwake.lv);
        local curLv = 0;
        for key,var in pairs(Data.cardAwake.lv)do
            if(lv >= var)then
                curLv = toint(key-1);
            end
        end 
        if(curLv==0)then
            if isPet then
                if lv >= 1 then
                    return 1
                end
                return nil
            end
            return nil
        elseif(curLv>=max)then
            return max
        else
            return curLv
        end
    end
    return nil
end

function gParseCardAwakeDiaNum(lv)
    local diaNum = math.floor(lv/7);
    diaNum = math.min(diaNum,math.floor(Data.cardAwake.maxLv/7));
    return diaNum;
end

function gParseWeaponLv(lv)
    if(lv)then
        return math.floor(lv/6)
    end
    return 0
end

function gParseWeaponId(lv,maxWeaponId)
    local max=1
    if(maxWeaponId==nil)then
        maxWeaponId=1
    end 

    if( ccs.ArmatureDataManager:getInstance().getVersion)then 
        max=maxWeaponId
    end
    if(lv )then
        local curLv = 0;
        for key,var in pairs(WeaponChangeLv)do
            if(lv >= var)then
                curLv = toint(key-1);
            end
        end 
        if(curLv==0)then
            return nil
        elseif(curLv>=max)then
            return max
        else
            return curLv
        end

    end
    return nil
end

function loadFlaPacker(name,weaponid,skinid)
    local plist={}
    getFlaPackerRes(name,weaponid,skinid,plist)
    for packer, var in pairs(plist) do
        cc.SpriteFrameCache:getInstance():addSpriteFrames(packer)
    end
end


function gGetMaxWeaponAwakeId(cardid)
    local maxWeaponId=nil
    local maxAwakeId=nil
    local db= DB.getCardById(cardid)
    if(db and db.wakenshow)then
        maxWeaponId= db.wakenshow%10
        maxAwakeId=math.floor(db.wakenshow/10)
    end
    
    if( ccs.ArmatureDataManager:getInstance().getVersion==nil)then 
        if(maxWeaponId and maxWeaponId>1)then
            maxWeaponId=1
        end
        if(maxAwakeId and maxAwakeId>1)then
            maxAwakeId=1
        end 
    end
    return maxWeaponId,maxAwakeId
end

function gIsFinalAwake(cardid)
    local maxWeaponId=nil
    local maxAwakeId=nil 
    maxWeaponId,maxAwakeId = gGetMaxWeaponAwakeId(cardid)
    if maxAwakeId and maxAwakeId==3 then
        return true
    end
    return false
end

function getFlaPackerRes(name,weaponid,skinid,plists)
    local cardid= toint(string.sub(name,2,6))
    local maxWeaponId=nil
    local maxAwakeId=nil 
    if(cardid~=0)then
        maxWeaponId,maxAwakeId= gGetMaxWeaponAwakeId(cardid)
    end

    local isPet = false
    if maxAwakeId == nil then
        maxAwakeId = gGetMaxPetAwakeId(cardid)
        if maxAwakeId ~= nil then
            isPet = true
        end
    end

    weaponid=gParseWeaponId(weaponid,maxWeaponId)
    skinid=gParseCardAwakeId(skinid,maxAwakeId,isPet)

    if(gFlaPackers[name])then
        local packers= string.split(gFlaPackers[name],",")
        for key, packer in pairs(packers) do

            if(packer~="")then
                if(weaponid and string.find(packer,"images_role_"))then
                    local weaponPacker=packer.."_w_"..weaponid
                    plists["packer/"..weaponPacker..".plist"]=1
                end
                local needLoad=true
                if(skinid and string.find(packer,"images_role_"))then
                    local skinPacker=packer.."_s_"..skinid

                    if(cc.FileUtils:getInstance():isFileExist("packer/"..skinPacker..".plist"))then
                        plists["packer/"..skinPacker..".plist"]=1
                        needLoad=false
                    end
                end
                if(needLoad )then
                    plists["packer/"..packer..".plist"]=1
                end
            end
        end
    end

end



function gSetCameraMask(node,mask)
    if(node==nil)then
        return
    end
    node:setCameraMask(mask)
    local children = node:getChildren()
    if children and table.nums(children) > 0 then
        --遍历子对象设置
        for i,v in ipairs(children) do
            gSetCameraMask(v,mask)
        end
    end

end


function gPauseAllFla(node)
    local children = node:getChildren()
    if children and table.nums(children) > 0 then
        --遍历子对象设置
        for i,v in ipairs(children) do
            if v["getActionTime"] then
                v:pause()
            end
            gPauseAllFla(v)
        end
    end
end

function gResumeAllFla(node)
    local children = node:getChildren()
    if children and table.nums(children) > 0 then
        --遍历子对象设置
        for i,v in ipairs(children) do
            if v["getActionTime"] then
                v:resume()
            end
            gResumeAllFla(v)
        end
    end
end


function loadFlaXml(name,weaponid,skinid)
    loadFlaPacker(name,weaponid,skinid)
    if(cc.FileUtils:getInstance():isFileExist("fla/"..name..".xml"))then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("fla/"..name..".xml")
        return true
    end
    return false
end

function loadRelationFlaXml(name)
    loadFlaXml(name)
    if(gFlaRelation[name])then
        local flaXmls=string.split(gFlaRelation[name],",")
        for key, var in pairs(flaXmls) do
            if(var~="")then
                loadFlaXml(var)
            end
        end
    end
end
function gGetActionTime(name)
    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(name)

    if(animationData)then
        local movementData=  animationData:getMovement("stand")
        return movementData.duration/FLASH_FRAME
    end
    return 0
end
function gCreateWordsSprite(type,word)

    local ret=cc.Node:create()
    local curWidth=0
    local curHeight=0
    local size=table.getn(word)
    for i=1,size do
        local str="images/fonts/font_img/red_font/"..word[i]..".png"
        local numSprite=nil
        if(cc.SpriteFrameCache:getInstance():getSpriteFrame(str)~=nil) then
            numSprite=cc.Sprite:createWithSpriteFrameName(str)
        else
            numSprite=cc.Sprite:create(str)
        end

        if(numSprite) then
            ret:addChild(numSprite)
            numSprite:setPositionX(curWidth+numSprite:getContentSize().width/2)
            curWidth=curWidth+numSprite:getContentSize().width
            if numSprite:getContentSize().height>curHeight then
                curHeight=numSprite:getContentSize().height
            end
        end

    end


    ret:setCascadeOpacityEnabled(true)
    ret:setContentSize(cc.size(curWidth,curHeight))
    ret:setAnchorPoint(cc.p(0.5,0.5))
    return ret
end

function gCreateBattleWord(imagePath,scale)
    local numSprite=nil
    if(cc.SpriteFrameCache:getInstance():getSpriteFrame(imagePath)~=nil) then
        numSprite=cc.Sprite:createWithSpriteFrameName(imagePath)
    else
        numSprite=cc.Sprite:create(imagePath)
    end

    if numSprite and scale then
        numSprite:setScale(scale);
    end

    return numSprite;
end

function gCreateBaojiWord(times)
    local layout = LayOutLayer.new(LAYOUT_TYPE_HORIZONTAL,-10);

    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist")

    local num = gCreateBattleWord("images/fonts/font_img/red_font/baoji.png");
    layout:addNode(num);
    num = gCreateBattleWord("images/fonts/font_img/red_num/x.png");
    layout:addNode(num);
    -- if (times<10) then
    --    num = gCreateBattleWord("images/fonts/font_img/red_num/"..times..".png");
    --    layout:addNode(num);
    -- else
    --计算
    local strNum = tostring(times)
    local count = strNum:len();
    -- print("count="..count);
    for i=1,count do
        local numOne = toint(string.sub(strNum,i,i));
        num = gCreateBattleWord("images/fonts/font_img/red_num/"..numOne..".png");
        layout:addNode(num);
    end
    -- end
    layout:layout();
    return layout;
end

function gCreateLabelAtlas(image,w,h,num,offw,start)
    if(num==nil)then
        return  cc.Node:create();
    end
    offw = toint(offw);
    -- print("offw = "..offw);
    if offw == 0 then
        local ret = cc.LabelAtlas:_create(num,image,w,h,string.byte(start));
        ret:setAnchorPoint(cc.p(0.5,0.5));
        return ret;
    else
        local ret = cc.Node:create();
        local x = 0;
        local size=string.len(num);
        for i = 1,size do
            local one_num = string.sub(num,i,i);
            local lab = cc.LabelAtlas:_create(one_num,image,w,h,string.byte(start));
            lab:setPositionX(x);
            ret:addChild(lab);
            if(i == size) then
                x = x + w;
            else
                x = x + w + offw;
            end
        end
        ret:setCascadeOpacityEnabled(true);
        ret:setContentSize(cc.size(x,h));
        ret:setAnchorPoint(cc.p(0.5,0.5));
        return ret;
    end
end

function gSetBlendType(node)
    if( tolua.type(node) == "cc.Label" and node:getTTFConfig().fontFilePath == gCustomFont)then
        return false
    end

    return true

end

function gSetBlendFuncAll(node,blend)
    local children = node:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        local child = children[i + 1]
        if nil ~= child then
            if (gSetBlendType(child)) then
                gSetBlendFuncAll(child, blend)
            end
        end
    end

    if(node.setBlendFunc  and tolua.type(node)~="ccui.Scale9Sprite" )then
        node:setBlendFunc(blend )
    end

end


function gCreateNumSprite(type,num)
    local ret=cc.Node:create()
    local curWidth=0
    local curHeight=0
    local offsetX=-18
    local size=string.len(num)
    for i=1,size do
        local str="images/fonts/font_img/"..type.."/"..string.sub(num,i,i)..".png"
        local numSprite=nil
        if(cc.SpriteFrameCache:getInstance():getSpriteFrame(str)~=nil) then
            numSprite=cc.Sprite:createWithSpriteFrameName(str)
        else
            numSprite=cc.Sprite:create(str)
        end

        if(numSprite) then
            ret:addChild(numSprite)
            numSprite:setPositionX(curWidth+numSprite:getContentSize().width/2+offsetX)
            curWidth=curWidth+numSprite:getContentSize().width+offsetX
            if numSprite:getContentSize().height>curHeight then
                curHeight=numSprite:getContentSize().height
            end
        end
    end
    ret:setCascadeOpacityEnabled(true)
    ret:setContentSize(cc.size(curWidth,curHeight))
    ret:setAnchorPoint(cc.p(0.5,0.5))
    return ret
end

function gSplitWordByWidth(word,font,fontsize,width)
    local bUseTTF = false
    if string.find(font,".ttf") or string.find(font,".TTF") then
        bUseTTF = true;
    end
end

function gCreateWordLabelTTF(word,font,fontsize,color,demensions,alignment)

    local bUseTTF = false
    if string.find(font,".ttf") or string.find(font,".TTF") then
        bUseTTF = true
    end

    if font==gCustomFont and gContainSpeWord(word) then
        font = gFont
        bUseTTF = false
    end

    local lab = nil
    -- if(bUseTTF)then
    --     local ttfConfig = {}
    --     ttfConfig.fontFilePath = gCustomFont
    --     ttfConfig.fontSize = fontsize
    --     lab = cc.Label:createWithTTF(ttfConfig,"")
    -- else
    --     lab = cc.Label:create()
    --     lab:setSystemFontSize(fontsize)
    --     lab:setSystemFontName(gFont)
    -- end
    -- lab:setString(word)

    if(bUseTTF) then
        lab = cc.Label:createWithTTF(word,font,fontsize)
    else
        lab = cc.Label:create()
        lab:setSystemFontName(font)
        lab:setSystemFontSize(fontsize)
        lab:setString(word)
    end

    lab:setColor(color)
    if(demensions~=nil) then
        lab:setDimensions(demensions.width,demensions.height)
        if(alignment == nil) then
            alignment = cc.TEXT_ALIGNMENT_CENTER
        end
        lab:setAlignment(alignment)
    end
    return lab
end

function gCreateVerticalWord(word,font,fontSize,color,spaceH)

    if font==gCustomFont and gContainSpeWord(word) then
        font = gFont;
    end

    if(gIsHorizontal)then
        print("word = "..word);
        return gCreateWordLabelTTF(word,font,fontSize,color);
    end

    local contents = string.splitUtf8ToTable(word);
    local nodebg = cc.Node:create();
    local width = 0;
    local height = 0;
    local posY = 0;
    local count = table.getn(contents);
    for i=count,1,-1 do
        local var = contents[i];
        -- for key,var in pairs(contents) do
        -- print("var = "..var);
        local lab = gCreateWordLabelTTF(var,font,fontSize,color);
        lab:setAnchorPoint(cc.p(0.5,0));
        lab:setPosition(cc.p(lab:getContentSize().width/2,posY));
        nodebg:addChild(lab);
        width = math.max(width,lab:getContentSize().width);
        posY = posY + lab:getContentSize().height + spaceH;
        height = height + lab:getContentSize().height + spaceH;
    end
    nodebg:setContentSize(cc.size(width,height));
    nodebg:ignoreAnchorPointForPosition(false);
    nodebg:setAnchorPoint(cc.p(0.5,0.5));
    return nodebg;

end

function gGetNodePositionByAnchorPoint(pNode,anchor)
    if(pNode~=nil) then
        return cc.p(pNode:getContentSize().width * anchor.x,pNode:getContentSize().height * anchor.y)
    end
    return cc.vertex2F(0,0)
end
function gAddChildInCenterPos(pFatherNode,pChildNode, zOrder)

    if(pFatherNode~=nil and pChildNode~=nil) then
        pChildNode:setPosition(gGetNodePositionByAnchorPoint(pFatherNode, cc.p(0.5,0.5)))
        if nil == zOrder then
            zOrder = pChildNode:getLocalZOrder()
        end
        pFatherNode:addChild(pChildNode,zOrder)
    end
end
function gAddChildByAnchorPos(pFatherNode,pChildNode,anchor,offPos)

    if (pFatherNode~=nil and pChildNode~=nil) then

        if offPos == nil then
            offPos = cc.p(0,0);
        end
        pChildNode:setPosition(cc.pAdd(gGetNodePositionByAnchorPoint(pFatherNode, anchor),offPos))
        pFatherNode:addChild(pChildNode)
    end
end
--pSrcNode坐标换算成pDesNode坐标系上的坐标
function gGetPositionByAnchorInDesNode(pDesNode,pSrcNode,srcAnchor)
    local worldPos = pSrcNode:convertToWorldSpace(gGetNodePositionByAnchorPoint(pSrcNode,srcAnchor));
    return pDesNode:convertToNodeSpace(worldPos);
end
function gGetPositionInDesNode(pDesNode,pSrcNode)
    return gGetPositionByAnchorInDesNode(pDesNode,pSrcNode,pSrcNode:getAnchorPoint());
end
--修改已经被添加的Node的锚点，为了保持位置不变，修改锚点同时修改位置
function gModifyExistNodeAnchorPoint(node,anchorPoint)
    if(node:getAnchorPoint().x == anchorPoint.x and node:getAnchorPoint().y == anchorPoint.y)then
        print("same anchorpoint");
        return;
    end
    local size = node:getContentSize();
    local old_anchorPoint = node:getAnchorPoint();
    local old_pos = cc.p(node:getPosition());
    local scale = node:getScale();
    local pos = cc.p(old_pos.x - size.width * old_anchorPoint.x * scale
        ,old_pos.y - size.height * old_anchorPoint.y * scale);
    pos = cc.p(pos.x + size.width * anchorPoint.x * scale,pos.y + size.height * anchorPoint.y * scale);
    node:setPosition(pos);
    node:setAnchorPoint(anchorPoint);
end

function gRefreshNode(parent,child,anchorpoint,offset,tag)
    if parent ~= nil and child ~= nil then

        -- child = tolua.cast(child,"CCNode");
        if tag ~= nil then
            child:setTag(tag);
        end
        local iTag = child:getTag();
        --    echo("iTag = "..iTag);
        if iTag ~= -1 then
            parent:removeChildByTag(iTag,true);
        end


        gAddChildByAnchorPos(parent,child,anchorpoint,offset);

    end

end



function  gUnproject( viewProjection, viewport, src, dst)
    assert(viewport.width ~= 0.0 and viewport.height ~= 0)
    local screen = cc.vec4(src.x / viewport.width, (viewport.height - src.y) / viewport.height, src.z, 1.0)
    screen.x = screen.x * 2.0 - 1.0
    screen.y = screen.y * 2.0 - 1.0
    screen.z = screen.z * 2.0 - 1.0
    local inversed = cc.mat4.new(viewProjection:getInversed())
    screen = inversed:transformVector(screen, screen)
    if screen.w ~= 0.0 then
        screen.x = screen.x / screen.w
        screen.y = screen.y / screen.w
        screen.z = screen.z / screen.w
    end

    dst.x = screen.x
    dst.y = screen.y
    dst.z = screen.z
    return viewport, src, dst
end


function  gCalculateRayByLocationInView(ray, location,mat)
    local dir = cc.Director:getInstance()
    local view = dir:getWinSize()
    local src = cc.vec3(location.x, location.y, -1)
    local nearPoint = {}
    view, src, nearPoint = gUnproject(mat, view, src, nearPoint)
    src = cc.vec3(location.x, location.y, 1)
    local farPoint = {}
    view, src, farPoint = gUnproject(mat, view, src, farPoint)
    local direction = {}
    direction.x = farPoint.x - nearPoint.x
    direction.y = farPoint.y - nearPoint.y
    direction.z = farPoint.z - nearPoint.z
    direction   = cc.vec3normalize(direction)

    ray._origin    = nearPoint
    ray._direction = direction

end

function gCreateRoleFla(cardid,node,scale,showShadow,flaName,weaponid,skinid,halolv)
    return gCreateRoleFlaWithActName("wait",cardid,node,scale,showShadow,flaName,weaponid,skinid,halolv);
end

function gCreateRoleFlaInBath(cardid,node,scale,showShadow,flaName)
    return gCreateRoleFlaWithActName("wait2",cardid,node,scale,showShadow,flaName);
end

function gCreateRoleRunFla(cardid,node,scale,showShadow,flaName,weaponid,skinid,halolv)
    return gCreateRoleFlaWithActName("run",cardid,node,scale,showShadow,flaName,weaponid,skinid,halolv);
end

function gCreateRoleWinFla(cardid,node,scale,showShadow,flaName,weaponid,skinid)
    return gCreateRoleFlaWithActName("win",cardid,node,scale,showShadow,flaName,weaponid,skinid);
end

function gCreateRoleAttackBFla(cardid,node,scale,showShadow,flaName,weaponid,skinid)
    return gCreateRoleFlaWithActName("attack_b",cardid,node,scale,showShadow,flaName,weaponid,skinid);
end

function gCreateRoleFlaWithActName(actname,cardid,node,scale,showShadow,flaName,weaponid,skinid,halolv)

    local result= false
    if(flaName)then
        result= loadFlaXml(flaName,weaponid,skinid)
    end
    if(result==false)then
        result= loadFlaXml("r"..cardid,weaponid,skinid)
    end
    node:removeAllChildren()
    if(scale==nil)then
        scale=1
    end
    if(result)then

        local maxWeapon= nil
        local maxAwake= nil 
        maxWeapon,maxAwake= gGetMaxWeaponAwakeId(cardid)

        if maxAwake == nil then
            maxAwake = gGetMaxPetAwakeId(cardid)
            skinid = Pet.getPetAwakeLv(cardid)
        end

        local fla=FlashAni.new()
        if(weaponid)then
            fla:setWeaponId(weaponid,maxWeapon)
        end
        if(skinid)then
            if gGetMaxPetAwakeId(cardid) ~= nil then
                fla:setPetSkinId(skinid)
            else
                fla:setSkinId(skinid,maxAwake)
            end
            
        end
        fla:setScale(scale)
        fla.cardid=cardid
        if actname ~= "" then
            fla:playAction("r"..cardid.."_"..actname)
        end
        gAddCenter(fla,node)
        if showShadow == nil then
            showShadow = true;
        end
        if showShadow then
            local shadow=cc.Sprite:create("images/battle/shade_ui.png")
            -- shadow:setScaleY(0.5)
            fla:addChild(shadow,-1)
        end
        if halolv and halolv>=3 then--增加光环
            print("halolv="..halolv)
            loadFlaXml("shouhujingling")
            local name = "shjl_a"
            if (halolv>=3 and halolv<6) then
                name = "shjl_a"
            elseif (halolv>=6 and halolv<9) then
                name = "shjl_b"
            else
                name = "shjl_c"
            end
            local holaFla=gCreateFla(name,1)
            if (holaFla) then
                holaFla:setScale(scale)
                gAddCenter(holaFla,node)
                -- node:addChild(fla)
                local poy = 166
                local pox = 78
                poy = poy - (1-scale)*poy
                pox = pox - (1-scale)*pox
                holaFla:setPositionY(poy)
                holaFla:setPositionX(-pox)
            end
            fla.halo=holaFla
        end
        return fla
    end
end


function gCreateFlaDislpay(name,loop,flaName,skinid)

    local cardid= toint(string.sub(name,2,6))

    local maxWeapon= nil
    local maxAwake= nil 
    maxWeapon,maxAwake= gGetMaxWeaponAwakeId(cardid) 
    
    if maxAwake == nil then
        maxAwake = gGetMaxPetAwakeId(cardid)
        skinid = Pet.getPetAwakeLv(cardid)
    end
    
    if(flaName)then
        result = loadFlaXml(flaName,0,skinid)
        if(result == false) then
            local node = cc.Node:create();
            return node;
        end
    end
    local ret=ccs.Armature:create()
    if(skinid)then
        if gGetMaxPetAwakeId(cardid) ~= nil then
            ret:setSkinId(skinid)
        else
            ret:setSkinId(gParseCardAwakeId(skinid,maxAwake))
        end
    end 
    ret:init(name)
    ret:getAnimation():play("stand",-1,loop)
    return ret
end

function gReplaceBoneWithNode(armature,boneTable,replaceNode)

    for key, boneName in pairs(boneTable) do
        local bone=armature:getBone( boneName)
        if(bone==nil)then
            -- print("xxxxxxxx222222");
            return
        end
        armature= bone:getChildArmature()
        endBone=bone
        if(armature==nil and table.getn(boneTable)~=key)then
            -- print("xxxxxxxx3333333");
            return
        end
    end
    if(endBone)then

        local node=nil
        local sprite = replaceNode;

        if sprite == nil then
            -- print("replace sprite is nil");
            return;
        end

        if(tolua.type(sprite)~="ccs.Armature")then
            node=cc.Node:create()
            node:addChild(sprite);
            gSetBlendFuncAll( sprite,  endBone:getBlendFunc())
        else
            node=sprite
        end

        -- print("replace xxxx");

        sprite:setCascadeOpacityEnabled(true)
        node:setCascadeOpacityEnabled(true)
        endBone:addDisplay(node, 1)
        endBone:changeDisplayWithIndex(1, true)
        endBone:setIgnoreMovementBoneData(true)
    end
end

function gCreateFla(name,loop,playEnd)

    local effect=FlashAni.new()

    local function callback()
        effect:removeFromParent(true)
        if(playEnd)then
            playEnd()
        end
    end
    if(loop==1)then
        effect:playAction(name)
    elseif(loop==-1)then
        effect:playAction(name,nil,nil,0)
    else
        effect:playAction(name,callback)

    end
    return effect
end

function gCreateFlaDelay(delay,name,loop,endDel,startCallback)
    local fla = FlashAni.new();
    fla:playActDelay(delay,name,loop,endDel,startCallback);
    return fla;
end

function gCreateFlaDelayAndCallback(delay,name,loop,finishCallback,startCallback,endDel)
    local fla = FlashAni.new();
    fla.endDel = endDel;
    fla:playActDelayAndCallback(delay,name,loop,finishCallback,startCallback);
    return fla;
end
--通用放回按钮，这样保证返回位置一直
function gCreateBtnBack(uilayer)
    local btnBack = cc.Sprite:create("images/ui_public1/b_back.png");
    -- btnBack:setPosition(uilayer:convertToNodeSpace(cc.p(45,gGetScreenHeight() - 45)));
    btnBack:setPosition(47,-30);
    uilayer:addChild(btnBack,10);
    uilayer:setNodeOffsetType(btnBack,OFFSETTYPE_LEFT_UP);
    uilayer:addTouchNode(btnBack,"btn_close",1,"",0);
    uilayer.vars["btn_close"]=btnBack
end
--通用显示tip(点击屏幕任意区域退出)
function gCreateTouchScreenTip(uilayer,color,word)
    if color == nil then
        color = cc.c3b(65,20,20);
    end
    if(word == nil)then
        word = gGetWords("noticeWords.plist","touch_tip");
    end
    local lab = gCreateWordLabelTTF(word,gFont,20,color);
    lab:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.FadeTo:create(2,120),
            cc.FadeTo:create(2,255)
        )
    ));
    lab:setPosition(cc.p(uilayer:getContentSize().width/2,-uilayer:getContentSize().height + 20));
    uilayer:addChild(lab,1000);
    -- gAddChildByAnchorPos(uilayer,lab,cc.p(0.5,-1),cc.p(0,40));
    -- uilayer:setNodeOffsetType(lab,OFFSETTYPE_DOWN);
    return lab;
end
--通用显示状态(-1未达成; 0可领取; 1已领取)
function gShowBtnStatus(node,status)
    node:setVisible(false);
    node:getParent():removeChildByTag(110);
    node:getParent():removeChildByTag(120);
    if status == -1 then
        local flag = cc.Sprite:create("images/ui_word/unget.png");
        gRefreshNode(node:getParent(),flag,cc.p(0,0),cc.p(node:getPosition()),110);
    elseif status == 0 then
        node:setVisible(true);
    elseif status == 1 then
        local flag = cc.Sprite:create("images/ui_word/xget_2.png");
        gRefreshNode(node:getParent(),flag,cc.p(0,0),cc.p(node:getPosition()),120);
    end
end
--名字+n
function gShowRoleName(uilayer,nameVar,name,cardid,outline)
    local qua = 0;
    local data=Data.getUserCardById(cardid)
    if(data)then
        qua=data.quality
    end
    -- local tabColor = gQuaColor;
    uilayer:setLabelString(nameVar,name,nil,true);
    local lab = uilayer:getNode(nameVar);
    if lab then
        if outline and outline == true then
            local outline_color = cc.c4b(0,0,0,255);
            local outline_offset = 0.1;
            lab:enableOutline(outline_color,20*outline_offset);
        end
        local baseQua,detailQua = Icon.convertItemDetailQuality(qua+1);
        -- print("baseQua = "..baseQua);
        lab:setColor(cc.c3b(gQuaColor[baseQua][1],gQuaColor[baseQua][2],gQuaColor[baseQua][3]));
        gCreateRoleNameQua(lab,cardid,qua);
    end

end
--品质:名字+n
function gCreateRoleNameQua(nameNode,cardid,qua)
    local quaTag = 50000;
    nameNode:getParent():removeChildByTag(quaTag);
    if(qua==nil)then
        local data=Data.getUserCardById(cardid)
        if(data)then
            qua=data.quality
        end
    end

    if(qua)then
        local baseQua,detailQua = Icon.convertItemDetailQuality(qua+1);
        -- print("detailQua = "..detailQua);
        if detailQua > 0 then
            local labNum = nil;
            -- local tabColor = {
            --     {255,255,255},
            --     {60,255,0},
            --     {0,255,246},
            --     {222,122,255},
            --     {250,210,0}
            -- };

            if baseQua <= table.getn(gQuaColor) then
                labNum = gCreateWordLabelTTF("+"..detailQua,gFont,20,cc.c3b(gQuaColor[baseQua][1],gQuaColor[baseQua][2],gQuaColor[baseQua][3]));
            end
            if labNum then
                labNum:setAnchorPoint(cc.p(0,0.5));

                local outline_color = cc.c4b(0,0,0,255);
                local outline_offset = 0.2;
                labNum:enableOutline(outline_color,20*outline_offset);
                local posx = nameNode:getPositionX()+nameNode:getContentSize().width*(1-nameNode:getAnchorPoint().x)+5;
                labNum:setPosition(cc.p(posx,nameNode:getPositionY()));
                labNum:setTag(quaTag);
                if nameNode:getParent().__cname=="LayOutLayer" then
                    -- nameNode:getParent():addNode(labNum);
                    nameNode:setContentSize(cc.size(nameNode:getContentSize().width + labNum:getContentSize().width+5,
                        nameNode:getContentSize().height));
                end
                nameNode:getParent():addChild(labNum);
            -- gAddChildByAnchorPos(nameNode:getParent(),labNum,cc.p(1,0.5),cc.p(5,0));
            end
        end
    end
end
--Lv.xx
function gShowRoleLv(uilayer,name,lv)
    uilayer:setLabelString(name,getLvReviewName("Lv.")..lv)
end
--xx/MAX
function gShowLabStringCurAndMax(uilayer,name,curValue,maxValue)
    local maxTag = 5000;
    local node = uilayer:getNode(name);
    node:getParent():removeChildByTag(maxTag);
    if maxValue > 0 then
        node:setVisible(true);
        uilayer:setLabelString(name,curValue.."/"..maxValue);
    else
        node:setVisible(false);
        local rtf = RTFLayer.new();
        rtf:addWord(curValue.."/",node.font,node.fontsize,node:getDisplayedColor(),nil,nil,node.outline_color,node.outline_offset);
        local strMax = "MAX"
        if isBanshuReview() then
            strMax = "最大"
        end
        rtf:addWord(strMax,node.font,node.fontsize,cc.c3b(255,0,0),nil,nil,node.outline_color,node.outline_offset);
        rtf:layout();
        rtf:setLocalZOrder(node:getLocalZOrder());
        rtf:setAnchorPoint(node:getAnchorPoint());
        gRefreshNode(node:getParent(),rtf,cc.p(0,0),cc.p(node:getPosition()),maxTag);
    -- uilayer:setLabelString(name,curValue.."/");
    -- local posx = node:getPositionX()+node:getContentSize().width*(1-node:getAnchorPoint().x);
    -- max:setLocalZOrder(node:getLocalZOrder());
    -- max:setAnchorPoint(cc.p(0,0.5));
    -- gRefreshNode(node:getParent(),max,cc.p(0,0),cc.p(posx,node:getPositionY()),maxTag);
    end
end

function gCallFuncDelay(delay,target,func)
    local action = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(func));
    target:runAction(action);
end

function gGetScreenWidth()
    local view = cc.Director:getInstance():getWinSize()
    return view.width;
end

function gGetScreenHeight()
    local view = cc.Director:getInstance():getWinSize()
    return view.height;
end

function gGetWordWithWidth(word,font,fontSize,width)
    local lab = gCreateWordLabelTTF(word,font,fontSize,cc.c3b(0,0,0));
    local maxWidth = lab:getContentSize().width;
    local isCut = false;
    if(maxWidth <= width)then
        return word,isCut;
    end
    isCut = true;
    local percent = width/maxWidth;
    local maxCount = string.utf8len(word);
    local leftCount = math.ceil( percent * maxCount );

    local leftWords = string.utf8sub(word,1,leftCount);
    local leftLabel = gCreateWordLabelTTF(leftWords,font,fontSize,cc.c3b(0,0,0));
    local leftLabelWidth = leftLabel:getContentSize().width;
    if(leftLabelWidth < width)then
        while(leftLabelWidth < width)do
            leftWords = string.utf8sub(word,1,leftCount+1);
            leftLabel = gCreateWordLabelTTF(leftWords,font,fontSize,cc.c3b(0,0,0));
            leftLabelWidth = leftLabel:getContentSize().width;
            if(leftLabelWidth > width)then
                break;
            else
                leftCount = leftCount + 1;
            end
        end
    elseif(leftLabelWidth > width)then
        while(leftLabelWidth > width)do
            leftWords = string.utf8sub(word,1,leftCount-1);
            leftLabel = gCreateWordLabelTTF(leftWords,font,fontSize,cc.c3b(0,0,0));
            leftLabelWidth = leftLabel:getContentSize().width;
            if(leftLabelWidth < width)then
                leftCount = leftCount - 1;
                break;
            else
                leftCount = leftCount - 1;
            end
        end
    end
    -- print("maxWidth = "..maxWidth);
    -- print("width = "..width);
    -- print("percent = "..percent);
    -- print("maxCount = "..maxCount);
    -- print("leftCount = "..leftCount);
    -- while (leftCount >= 0) do
    --     local s = string.utf8sub(word,1,leftCount)
    --     lab = gCreateWordLabelTTF(s,font,fontSize,cc.c3b(0,0,0))
    --     maxWidth = lab:getContentSize().width
    --     if(maxWidth <= width) then
    --         break
    --     else
    --         leftCount = leftCount - 1
    --     end
    -- end
    return string.utf8sub(word,1,leftCount),isCut;
end

--去掉rtf关键字
function gRemoveRtf(str)
    -- 替换换行符
    if(string.find(str,"\\n") == nil) then
        if(string.find(str,"\r\n")) then
            str = string.gsub(str, "\r\n", "\\n{}\\");
        else
            str = string.gsub(str, "\n", "\\n{}\\");
            str = string.gsub(str, "\r", "\\n{}\\");
        end
    end

    local datas = {};
    local words = string.split(str,"\\");
    local retWord = "";
    for i,var in pairs(words) do
        if string.len(var) > 0 then
            if string.sub(var,1,2) == "w{" then
                local pos = string.find(var,"}",2);
                if pos ~= nil then
                    local word = string.sub(var,pos+1);
                    retWord = retWord .. word;
                end
            elseif string.sub(var,1,2) == "i{" then
            elseif string.sub(var,1,2) == "c{" then
            elseif string.sub(var,1,2) == "n{" then
            else
                retWord = retWord .. var;
            end
        end
    end

    -- print("str = "..str);
    -- print("retWord = "..retWord);

    return retWord;
end

function gRemoveWordAttr(word,patten)
    --ocal word = "亲爱的玩家，欢迎来到《乱斗堂2》！独乱斗，不如众乱斗！加入以下互动渠道，与众基友一同探讨游戏、扯淡嗨皮，更有以下互动好礼哦：\\n{}\\《乱斗堂2》官方QQ群: \\w{c=FF0000;s=18}123\\ (小窗联系GM领取加群礼包)\\n{}\\《乱斗堂2》微信公众号: \\w{c=FF0000;s=18}luandoutang2\\(丰富的微信活动福利)\\n{}\\《乱斗堂2》贴吧:"
    -- local p = "\\w"
    -- if (patten) then
    --     p = patten
    -- end
    -- local newWord = word;
    -- local pos1 = string.find(newWord,p)
    -- local pos2 = string.find(newWord,"}");
    -- while(pos1 ~= nil and pos2 ~= nil)do
    --     newWord = string.sub(newWord,1,pos1-1)..string.sub(newWord,pos2+1);
    --     pos1 = string.find(newWord,p)
    --     pos2 = string.find(newWord,"}");
    -- end
    local p = "\\w"
    if (patten) then
        p = patten
    end
    local newWord = word;
    --print("gVerifyWordAttr:" .. newWord)
    local pos1 = string.find(newWord,p)
    if pos1 == nil then
        return word
    end
    local pos2 = string.find(newWord,"}",pos1);
    --print ("pos1:"..tostring(pos1))
    --print ("pos2:" .. tostring(pos2))
    if(pos2 == nil) then
        newWord = string.sub(newWord,1,pos1-1)
        return newWord
    end
    while(pos1 ~= nil and pos2 ~= nil)do
        --print ("xxxxxx:" .. string.len(newWord))
        print ("newWord:" .. newWord)
        newWord = string.sub(newWord,1,pos1-1)..string.sub(newWord,pos2+1);
        pos1 = string.find(newWord,p)
        if (pos1 == nil) then
            return newWord
        end
        pos2 = string.find(newWord,"}",pos1)
        if(pos2 == nil) then
            newWord = string.sub(newWord,1,pos1-1)
            return newWord
        end
    end
    return newWord;
end


function gVerifyWordAttr(word,patten)
    local p = "\\w"
    if (patten) then
        p = patten
    end
    local newWord = word;
    --print("gVerifyWordAttr:" .. newWord)
    local pos1 = string.find(newWord,p)
    if pos1 == nil then
        return word
    end
    local pos2 = string.find(newWord,"}",pos1);
    if(pos2 == nil) then
        newWord = string.sub(newWord,1,pos1-1)
        return newWord
    end
    while(pos1 ~= nil and pos2 ~= nil)do
        pos1 = string.find(word, p, pos2)
        if pos1 == nil then
            return word
        end
        pos2 = string.find(word,"}",pos1)
        if(pos2 == nil) then
            newWord = string.sub(word,1,pos1-1)
            return newWord
        end
    end
    return word
end

function gParseChatEmoj(input_msg)
    local str = input_msg
    local ret = string.gsub(str, "%[([0-1]%d)%]", "\\i{p=images/biaoqing/".."%1"..".png;s=0.4}\\")
    ret = string.gsub(ret, "%[20%]", "\\i{p=images/biaoqing/20.png;s=0.4}\\")
    ret = string.gsub(ret, "%[9(%d)%]","\\i{p=images/icon/item/9".."%1"..".png;s=0.3}\\")
    --print ("gParserChatEmoj:" .. ret)
    return ret
end
--local msgs = "\\" .. data.msg
--显示在线或xx分钟前登陆
function gShowLoginTime(uilayer,nodeVar,loginTime,bolShowLogin)
    if(bolShowLogin == nil)then
        bolShowLogin = true;
    end
    if loginTime == 0 then
        uilayer:setLabelString(nodeVar,gGetWords("familyMenuWord.plist","menu_mem5"));
        uilayer:getNode(nodeVar):setColor(cc.c3b(174,251,52));
    else
        local word = getTimeDiff(loginTime);
        if(bolShowLogin)then
            word = word .. gGetWords("familyMenuWord.plist","login");
        end
        uilayer:setLabelString(nodeVar,word);
        uilayer:getNode(nodeVar):setColor(cc.c3b(160,140,128));
    end
end

function getTimeDiff(time)

    local min = time / 60 ;
    local hour = min / 60;
    local day = hour / 24;
    local word = nil;
    if day > 1 then
        word = gGetWords("familyMenuWord.plist","offline3",math.floor(day));
    elseif hour > 1 then
        word = gGetWords("familyMenuWord.plist","offline2",math.floor(hour));
    else
        if min < 1 then
            min = 1;
        end
        word = gGetWords("familyMenuWord.plist","offline1",math.floor(min));
    end

    return word;
end

--还可以输入多少字
function gRefreshLeftCount(rtfNode,maxCount,string)
    if rtfNode == nil then
        return;
    end

    local curCount = string.utf8len(string);
    local leftCount = maxCount - curCount;

    local word = gGetWords("friendWords.plist","11",leftCount);
    if leftCount < 0 then
        word = gGetWords("friendWords.plist","12",-leftCount);
    end

    rtfNode:clear();
    rtfNode:setString(word);
    rtfNode:layout();

end

--滚动的label
--scrollDir=0 左右； scrollDir=1上下
function gSetLabelScroll(labNode,scrollDir,speed)
    if(labNode == nil)then
        return;
    end
    labNode:stopAllActions();
    local parent = labNode:getParent();

    -- local time = parentWidth/75;
    if(speed == nil)then
        speed = 30;
    end
    if(scrollDir == nil)then
        scrollDir = 0;
    end
    if(scrollDir == 0)then
        --左右滚动
        local labWidth = labNode:getContentSize().width;
        local parentWidth = parent:getContentSize().width;
        if(labWidth > parentWidth)then
            gModifyExistNodeAnchorPoint(labNode,cc.p(0,labNode:getAnchorPoint().y));
            labNode:setPositionX(0);
            labNode:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveBy:create(labWidth/speed,cc.p(-labWidth,0)),
                    cc.Place:create(cc.p(parentWidth,labNode:getPositionY())),
                    cc.MoveBy:create(parentWidth/speed,cc.p(-parentWidth,0))
                )
            ));
        end
    elseif(scrollDir == 1)then
        --上下滚动
        local labHeight = labNode:getContentSize().height;
        local parentHeight = parent:getContentSize().height;
        if(labHeight > parentHeight)then
            gModifyExistNodeAnchorPoint(labNode,cc.p(labNode:getAnchorPoint().x,1));
            labNode:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.MoveBy:create(labHeight/speed,cc.p(0,labHeight)),
                    cc.Place:create(cc.p(labNode:getPositionX(),0)),
                    cc.MoveBy:create(parentHeight/speed,cc.p(0,parentHeight))
                )
            ));
        end
    end

end

--折扣
function gGetDiscount(discount)
    if(gCurLanguage == LANGUAGE_EN)then
        if(discount > 10)then
            discount = (100-discount).."%";
        else
            discount = ((10-discount)*10).."%";    
        end
    end
    return discount;
end

--数字缩写
function gGetNumForShort(num,maxShortNum,exact)
    --精确到小数点
    if(exact == nil)then
        exact = true;
    end
    local needShort = false;
    if maxShortNum == nil then
        maxShortNum = gMaxShortNum;
    end
    if num > (maxShortNum-1) then
        -- local str = math.floor(num/10000);
        -- local str = num/10000;
        local str = "";
        if num % gMaxShortNum == 0 then
            str = tostring(num/gMaxShortNum);
        else
            if(exact)then
                str = string.format("%0.1f",tostring(num/gMaxShortNum));
            else
                str = math.floor(num/gMaxShortNum);
            end
        end

        needShort = true;
        return str,needShort;
    -- return str.."W"
    -- local str = "";
    -- if num % 10000 == 0 then
    --     str = tostring(num/10000);
    -- else
    --     str = string.format("%0.1f",tostring(num/10000));
    -- end
    -- return str.."W";
    end
    return num,needShort;
end
function gGetCurGoldNumForShort()
    -- return Data.getCurGold()
    local num,needShort = gGetNumForShort(Data.getCurGold(),1000000,false);
    return num,needShort;
end

function gShowCurGoldShortNum(uilayer,varName)
    gShowShortNum(uilayer,varName,Data.getCurGold(),1000000,false);
end

--- xxxW
function gShowShortNum(uilayer,varName,num,maxShortNum,exact)
    local lab = uilayer:getNode(varName);
    local shortNum,needShort = gGetNumForShort(num,maxShortNum,exact);
    uilayer:setLabelString(varName,shortNum);
    lab:getParent():removeChildByTag(1111);
    if needShort then
        local flagW = cc.Sprite:create("images/ui_main/menu_W.png");
        flagW:setTag(1111);
        local pos = cc.p(lab:getPosition());
        pos.x = pos.x + (1-lab:getAnchorPoint().x)*lab:getContentSize().width+2;
        flagW:setAnchorPoint(cc.p(0,lab:getAnchorPoint().y));
        flagW:setPosition(pos);
        lab:getParent():addChild(flagW);
    end
end
-- xxxW/xxxW
function gShowShortNum2(uilayer,varName,curNum,maxNum,maxShortNum,curNumNeedShort,exact)
    if(curNumNeedShort == nil)then
        curNumNeedShort = true;
    end
    local node = uilayer:getNode(varName);
    local rtf = RTFLayer.new();
    rtf:setDefaultConfig(node.font,node.fontsize,node:getDisplayedColor());
    local shortNum,needShort = gGetNumForShort(curNum,maxShortNum,exact);
    if(curNumNeedShort)then
        rtf:addWord(shortNum);
        if needShort then
            rtf:addImage("images/ui_main/menu_W.png");
        end
    else
        rtf:addWord(curNum);
        needShort = false;    
    end
    rtf:addWord("/");
    shortNum,needShort = gGetNumForShort(maxNum,maxShortNum,true);
    rtf:addWord(shortNum);
    if needShort then
        rtf:addImage("images/ui_main/menu_W.png");
    end
    rtf:layout();

    uilayer:replaceNode(varName,rtf);
end

function gReplaceWtoK(str)
    if(gIsMultiLanguage())then
        str = string.gsub(str,'W','0K')  
        str = string.gsub(str,'w','0k')  
    end
    return str;
end


--获取sprite 的所有模型
function gGetSpriteMeshes(sprite,ret)
    if(sprite==nil )then
        return
    end
    if(sprite:getName()~="")then
        table.insert(ret,sprite)
    end

    local children = sprite:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        gGetSpriteMeshes(children[i + 1] ,ret)
    end

    return ret
end
function cc.blendFunc(_src, _dst)
    return {src = _src, dst = _dst}
end


--设置混合模式
function gSetChildBlendFunc(node ,src,dst)
    node:setBlendFunc(cc.blendFunc(src,dst))

end
--通过名字获取sprite 模型
function gGetSpriteMesheByName(sprite,name)

    local meshes={}
    gGetSpriteMeshes(sprite ,meshes)
    local len=table.getn(meshes)
    for i= 1 ,len do
        if(meshes[len-i+1]:getName()==name)then
            return meshes[len-i+1]
        end

    end
    return nil
end


function gGetItemQualityColor(qua)
    local baseQua,detailQua = Icon.convertItemDetailQuality(qua);
    return cc.c3b(gQuaColor[baseQua+1][1],gQuaColor[baseQua+1][2],gQuaColor[baseQua+1][3])
end

function gGetWeaponQuality(lv)
    if(lv<5)then
        return 1
    elseif lv<8 then
        return 3
    elseif lv<10 then
        return 5
    else
        return 8
    end

end


function gParseRgbNum(r,g,b)
    r= string.gsub( string.format("%#x",r),"0x","")
    g= string.gsub( string.format("%#x",g),"0x","")
    b= string.gsub( string.format("%#x",b),"0x","")
    if(string.len(r)==1)then
        r="0"..r
    end
    if(string.len(g)==1)then
        g="0"..g
    end

    if(string.len(b)==1)then
        b="0"..b
    end
    return r..g..b
end

function gGetTimesDescBySec(time)
    local hour = math.floor(time/3600)
    local min = math.floor((time%3600)/60)
    local sec = time % 60
    local desc = ""
    if hour > 0 then
        desc = desc .. gGetWords("labelWords.plist","lab_time_hour", hour)
    end

    if min > 0 then
        desc = desc .. gGetWords("labelWords.plist","lab_time_min", min)
    end

    if sec > 0 then
        desc = desc .. gGetWords("labelWords.plist","lab_time_sec", sec)
    end

    return desc
end

function  math.rint(num)
    return  math.floor(num+0.5)
end

function gGetCurPlatform()
    if ChannelPro == nil then
        return 1
    else
        return ChannelPro:sharedChannelPro():getPlatformId()
    end    
    -- return gAccount:getPlatformId();
end

function gGetDeviceOSVer()
    local  deviceOsVer = "";
    if PlatformFunc and  PlatformFunc:sharedPlatformFunc().getDeviceOSVer then
        deviceOsVer = PlatformFunc:sharedPlatformFunc():getDeviceOSVer()
    end 
    return deviceOsVer
end

function gGetDeviceModel()
    local  deviceModel = "";
    if PlatformFunc and  PlatformFunc:sharedPlatformFunc().getDeviceModel then
        deviceModel = PlatformFunc:sharedPlatformFunc():getDeviceModel()
    end 
    return deviceModel
end

local function TDGetCurPlatform()
    --return 9999
    return gAccount:getPlatformId();
end
function gRandSortTable(temp)
    local ret={}
    while(table.getn(temp)>0)do
        local key=getRand(1,table.getn(temp))
        table.insert(ret,temp[key])
        table.remove(temp,key)
    end
    return ret
end


function gGetCurVersion()
    local  version = "1.0.0"
    local  resourceVersion = "0"
    local  codeVersion = "1"
    if PlatformFunc and  PlatformFunc:sharedPlatformFunc().getVersion then
        version = PlatformFunc:sharedPlatformFunc():getVersion()
    end
    if AssetsUpdate and  AssetsUpdate:sharedAssetsUpdate().getResourceVersion then
        resourceVersion = AssetsUpdate:sharedAssetsUpdate():getResourceVersion()
    end
    if AssetsUpdate and  AssetsUpdate:sharedAssetsUpdate().getCodeVersion then
        codeVersion = AssetsUpdate:sharedAssetsUpdate():getCodeVersion()
    end

    return version.."("..codeVersion.."-"..resourceVersion.."-"..gBuildNumber.."):"..gLuaVersion;
end

--分享
function gScreenShotNodeForThumbImage(fileName)
    local node = cc.Node:create();
    if (gSaveScreenShot) then
        gSaveScreenShot(tolua.cast(node,"cc.Node"), 10,10, fileName)
    else
        ScreenShot:saveScreenshot(tolua.cast(node,"cc.Node"), 10,10, fileName)
    end
    -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if targetPlatform == cc.PLATFORM_OS_ANDROID then
    --     -- gSaveScreenShot(tolua.cast(node,"cc.Node"), 10,10, fileName)
    --     gSaveScreenLua(tolua.cast(node,"cc.Node"), 10,10, fileName)
    -- else
    --     gSaveScreenLua(tolua.cast(node,"cc.Node"), 10,10, fileName)
    -- end
end
function gScreenShotNode(node,resetPos)
    if(resetPos == nil)then
        resetPos = true;
    end
    fileName = "_share_luan.png"
    --更新C++ 要修改这个变量
    local isChangeCpp = true;

    -- --appstore和内部版本 C++代码已经是最新的
    -- if(gGetCurPlatform() == CHANNEL_APPSTORE or gGetCurPlatform() == CHANNEL_MOTU)then
    --     isChangeCpp = true;
    -- end

    local scale = 0.8;
    if(isChangeCpp)then
        scale = 1.0;
        gScreenShotNodeForThumbImage(fileName);
        fileName = "1"..fileName;
    else
        node:setOpacity(0);
    end

    local pos = cc.p(node:getPosition());
    local anchor = cc.p(node:getAnchorPoint());
    local width = node:getContentSize().width;
    local height = node:getContentSize().height;
    node:setPosition(cc.p(width/2,height/2));
    node:setAnchorPoint(cc.p(0.5,0.5));
    node:ignoreAnchorPointForPosition(false);
    node:setScale(scale);
    -- local platform = gAccount:getPlatformId();
    -- if  platform == CHANNEL_ANDROI_EFUNENCN or platform == CHANNEL_IOS_EFUN_CN_EN or platform == CHANNEL_IOS_APPSTORE then
    gSaveScreenLua(tolua.cast(node,"cc.Node"), width,height, fileName)
    -- else
    --     if (gSaveScreenShot) then
    --         gSaveScreenShot(tolua.cast(node,"cc.Node"), width,height, fileName)
    --     else
    --         ScreenShot:saveScreenshot(tolua.cast(node,"cc.Node"), width,height, fileName)
    --     end
    --end
    if(resetPos)then
        node:setPosition(pos);
        node:setAnchorPoint(anchor);
        node:setScale(1.0);
        node:setOpacity(0);
    end
end

function gSaveScreenLua(node,width,height,fileName)
    print ("gSaveScreenLua>>>")
    local texture = cc.RenderTexture:create(width,height,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888,gl.DEPTH24_STENCIL8_OES)
    --local texture = cc.RenderTexture:create(width,height)
    local autoDraw = texture:isAutoDraw()
    if(autoDraw ~= true) then
        texture:setAutoDraw(true)
    end
    texture:setClearStencil(gl.DEPTH24_STENCIL8_OES)
    texture:setContentSize(cc.size(width,height))
    texture:setPosition(cc.p(width/2,height/2))
    texture:begin()
    node:visit()
    texture:endToLua()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        --todo android platform is required to save in sdcard
        texture:saveToFile(PlatformFunc:sharedPlatformFunc():getSDCardDir()..fileName)
    else
        texture:saveToFile(getWritePath()..fileName)
    end
end
function gShare(shareType,data)
    if(shareType == nil)then
        shareType = 0;
    end
    gShareType = shareType;

    local isChangeCpp = true;
    -- if(gGetCurPlatform() == CHANNEL_APPSTORE or gGetCurPlatform() == CHANNEL_MOTU)then
    --     isChangeCpp = true;
    -- end

    print("shareType = "..shareType);
    print("gGetCurPlatform() = "..gGetCurPlatform());

    if(isChangeCpp == false)then
        if(shareType == SHARE_TYPE_LEVEL)then
            Net.sendShared(1);
        elseif(shareType == SHARE_TYPE_ATLAS)then
            Net.sendShared(2);
        elseif(shareType == SHARE_TYPE_ARENA)then
            Net.sendShared(3);
            Net.sendShared(4);
        elseif(shareType == SHARE_TYPE_CARD)then
            Net.sendShared(5);
            Net.sendShared(6);
        end
    end
    local platform = gAccount:getPlatformId();
    if  platform == CHANNEL_ANDROI_EFUNENCN or platform == CHANNEL_ANDROI_EFUNENCN_LY  or platform == CHANNEL_IOS_EFUN_CN_EN then
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if targetPlatform == cc.PLATFORM_OS_ANDROID then
            data.imageName = PlatformFunc:sharedPlatformFunc():getSDCardDir().."1_share_luan.png";
        else
            data.imageName = getWritePath().."1_share_luan.png";
        end
        data.linkUrl = "https://www.facebook.com/FighterUtopia/";
        local extra=gAccount:tableToString(data)
        if ChannelPro and ChannelPro:sharedChannelPro().extenInter then
            ChannelPro:sharedChannelPro():extenInter("share",extra)
        end
    else
        gShareContent(23, "hellohello", "_share_luan.png");
    end
    gLogEvent("sharecontent")
end

--weixin share callback

function gShareWeixinSuccess()
    print ("weixin share success")
    if(gShareType)then
        if(gShareType == SHARE_TYPE_LEVEL)then
            Net.sendShared(1);
        elseif(gShareType == SHARE_TYPE_ATLAS)then
            Net.sendShared(2);
        elseif(gShareType == SHARE_TYPE_ARENA)then
            Net.sendShared(3);
            Net.sendShared(4);
        elseif(gShareType == SHARE_TYPE_CARD)then
            Net.sendShared(5);
            Net.sendShared(6);
        end
    end
end

function gShareWeixinFail()
    print ("weixin share failed")
end

function gShareWeixinCancel()
    print ("weixin share canceled")
end

function onExtenInterllback(param1,param2)
    print("onExtenInterllback param1 ="..param1)
    print("onExtenInterllback param2 ="..param2)
    if(param1 == "SharingSucceed")then
        gShareWeixinSuccess()
    elseif(param1 == "SharingFailed")then
        gShareWeixinFail();
    elseif(param1 == "SupportWeixin")then
        local parseTable =  json.decode(param2)   
        if parseTable~=nil then
            -- if parseTable.supportWx=="1" then
            --     self.supportWx = true
            -- end
            -- if parseTable.installedWx=="1" then
            --     self.installedWx = true
            -- end
            -- self:showLayer()
        end
    elseif(string.find(param1,"youme"))then
        print("youmeRespone start")
        youmeRespone(param1,param2)
        print("youmeRespone end")
    end
end

function gHttpPost(url,data,callback)
    if(url==nil) then
        return
    end
    local xhr = cc.XMLHttpRequest:new()-- 新建一个XMLHttpRequest对象
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --返回数据为字节流
    -- 状态改变时调用
    local function onReadyStateChange()
        callback(xhr.responseText,url,data)
    end
    -- 注册脚本方法回调
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:open('POST', url) -- 打开Socket
    xhr:setRequestHeader('Content-Type','application/json')
    print(url)

    if(data~=nil) then
        xhr:send(data)-- 发送
    else
        xhr:send()-- 发送
    end
end

function log_filter(id)
    local _filter = {
        "mining.dig",
        "light_mine"
    }
    for k,v in ipairs(_filter) do
        if (id == v) then
            return true
        end
    end
    return false
end

function gLogEvent2(id, param)
    if(true)then
        return
    end
    if (log_filter(id) == true) then
        print ("filter_log:" .. id)
        return
    end

    local url = 'http://bi.more2.cn:5000/event/' .. id
    local str = nil
    if (param ~= nil) then
        param['uid'] = Data.getCurUserId()
        str = gAccount:tableToString(param)
        print ("gLogEvent2:" .. str)
    end
    local function callback(resp,url,data)
        if (resp == nil or resp == '') then
            print ('gLogEvent2 send data fail:' .. data)
            if (gLogError < 16) then
                gHttpPost(url,data,callback)
                gLogError = gLogError + 1
            end
        else
            print ('gLogEvent2 callback:' .. resp)
            if (gLogError > 0) then
                gLogError = gLogError - 1
            end
        end
    end
    gHttpPost(url,str,callback)
end
----------------------------
--talkingdata wrapper-------
----------------------------
-----------------------------
--记录TD事件，事件会同时发到BI服务器（可设置skipBI跳过）
--注意自定义参数不能超过4个，每个参数的取值不能超过500个
--使用gLogEventBI没有这两个限制
function gLogEvent(id, param,skipBI)
    if gUserInfo == nil then
        return
    end

    local dia = Data.getCurDia()
    if (dia == nil) then
        dia = 0
    end
    dia = math.ceil(dia/1000)

    local level = gUserInfo.level
    if level == nil then
        level = 0
    end

    local vip = gUserInfo.vip
    if vip == nil then
        vip = 0
    end

    local serverid = 0
    if (gAccount) then
        local cur_role = gAccount:getCurRole()
        if (cur_role) then
            serverid = gAccount:getCurRole().serverid
        end
    end

    local retain = gUserInfo.retain_day
    
    if (retain == nil) then
        retain = -1
    end

    if (retain > 7) then
        retain = math.ceil(retain/7) * 7
    end

    if (param ~= nil) then
        param['serverid'] =tostring(serverid)
        param['platform'] = tostring(gGetCurPlatform())
        param['lv'] = tostring(level)
        param['vip'] = tostring(vip)
        param['dia'] = tostring(dia) .. "k"
        param['retain_day'] = tostring(retain)
        if (TalkingDataGA) then
            TalkingDataGA:onEvent(id,param)
        end
        param['dia'] = tostring(Data.getCurDia())
        param['retain_day'] = tostring(gUserInfo.retain_day)
        param['regtime'] = tostring(gUserInfo.regTime)
        if(skipBI == nil) then
            gLogEvent2(id,param)
        end
    else
        local p = {}
        p['serverid'] =tostring(serverid)
        p['platform'] = tostring(gGetCurPlatform())
        p['lv'] = tostring(level)
        p['vip'] = tostring(vip)
        p['dia'] = tostring(dia) .. "k"
        p['retain_day'] = tostring(retain)
        if(TalkingDataGA) then
            TalkingDataGA:onEvent(id,p)
        end
        p['dia'] = tostring(Data.getCurDia())
        p['retain_day'] = tostring(gUserInfo.retain_day)
        p['regtime'] = tostring(gUserInfo.regTime)
        if (skipBI == nil) then
            gLogEvent2(id,p)
        end
    end
end
--记录BI事件
function gLogEventBI(id, param)
    if gUserInfo == nil then
        return
    end

    local dia = Data.getCurDia()
    if (dia == nil) then
        dia = 0
    end
    dia = math.ceil(dia/1000)

    local level = gUserInfo.level
    if level == nil then
        level = 0
    end

    local vip = gUserInfo.vip
    if vip == nil then
        vip = 0
    end

    local serverid = 0
    if (gAccount) then
        local cur_role = gAccount:getCurRole()
        if (cur_role) then
            serverid = gAccount:getCurRole().serverid
        end
    end

    local retain = gUserInfo.retain_day
    
    if (retain == nil) then
        retain = -1
    end

    if (retain > 7) then
        retain = math.ceil(retain/7) * 7
    end

    if (param ~= nil) then
        param['serverid'] =tostring(serverid)
        param['platform'] = tostring(gGetCurPlatform())
        param['lv'] = tostring(level)
        param['vip'] = tostring(vip)
        param['dia'] = tostring(dia) .. "k"
        param['retain_day'] = tostring(retain)
        param['regtime'] = tostring(gUserInfo.regTime)
        --TalkingDataGA:onEvent(id,param)
        gLogEvent2(id,param)
    else
        local p = {}
        p['serverid'] =tostring(serverid)
        p['platform'] = tostring(gGetCurPlatform())
        p['lv'] = tostring(level)
        p['vip'] = tostring(vip)
        p['dia'] = tostring(dia) .. "k"
        p['retain_day'] = tostring(retain)
        p['regtime'] = tostring(gUserInfo.regTime)
        --TalkingDataGA:onEvent(id,p)
        gLogEvent2(id,p)
    end
end

function gLogItemListBI(id, itemlist)
    if gUserInfo == nil then
        return
    end

    local dia = Data.getCurDia()
    if (dia == nil) then
        dia = 0
    end
    dia = math.ceil(dia/1000)

    local level = gUserInfo.level
    if level == nil then
        level = 0
    end

    local vip = gUserInfo.vip
    if vip == nil then
        vip = 0
    end

    local serverid = 0
    if (gAccount) then
        local cur_role = gAccount:getCurRole()
        if (cur_role) then
            serverid = gAccount:getCurRole().serverid
        end
    end

    local retain = gUserInfo.retain_day
    
    if (retain == nil) then
        retain = -1
    end

    if (retain > 7) then
        retain = math.ceil(retain/7) * 7
    end
    item_str = ""
    for i, item in ipairs(itemlist) do
        item_str = item_str .. tostring(item.id) .. "#" .. tostring(item.num) .. "-"
    end

    local p = {}
    p['serverid'] =tostring(serverid)
    p['platform'] = tostring(gGetCurPlatform())
    p['lv'] = tostring(level)
    p['vip'] = tostring(vip)
    p['dia'] = tostring(dia) .. "k"
    p['retain_day'] = tostring(retain)
    p['regtime'] = tostring(gUserInfo.regTime)
    --TalkingDataGA:onEvent(id,p)
    p['itemlist'] = item_str
    gLogEvent2(id,p)
end

-- 统计元宝消费
function gLogPurchase(id, num, price)
    if (toint(num) < 0 or toint(price) < 0) then
        print ("gLogPurchase param error: num:" .. tostring(num) .. "price:" .. tostring(price))
        return
    end
    if(TDGAItem) then
        TDGAItem:onPurchase(id, num, price)
    end
    local bi_param = {}
    bi_param['price'] = tostring(price)
    bi_param['purchase_id'] = id
    gLogEventBI('dia_purchase',bi_param)
end
-- 记录关卡开始
function gLogMissionBegin(missionId)
    if (TDGAMission) then
        TDGAMission:onBegin(missionId)
    end
end
-- 记录关卡完成
function gLogMissionCompleted(missionId)
    if (TDGAMission) then
        TDGAMission:onCompleted(missionId)
    end
end
-- 记录关卡失败
function gLogMissionFailed(missionId, reason)
    if (TDGAMission) then
        TDGAMission:onFailed(missionId, reason)
    end
end

function gLogAccountId(id)
    if (TDGAAccount) then
        TDGAAccount:setAccount(id)
    end
end

function gLogAccountLevel(level)
    if (TDGAAccount) then
        TDGAAccount:setLevel(level)
    end
end


function gLogAccountName(name)
    if (TDGAAccount) then
        TDGAAccount:setAccountName(name)
    end
end

function gLogAccountServer(server)

    if (TDGAAccount) then
        TDGAAccount:setGameServer(server)
    end
end

function gLogAccountAge(age)
    if (TDGAAccount) then
        TDGAAccount:setAge(age)
    end
end

function gLogChargeRequest(orderid, productid, money, currency, num, desc)
    if (TDGAVirtualCurrency) then
        TDGAVirtualCurrency:onChargeRequest(orderid, productid, money, currency, num, desc)
    end
end

function gLogChargeSuccess(orderid)
    if (TDGAVirtualCurrency) then
        TDGAVirtualCurrency:onChargeSuccess(orderid)
    end
end

function getGetCurMonthDayNum(date)
    local months
    if(date.year%4==0)then
        months={31,29,31,30,31,30,31,31,30,31,30,31}
    else
        months={31,28,31,30,31,30,31,31,30,31,30,31}
    end
    return months[date.month]

end

function gParserMinTimeEx(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end

    local min=math.floor( time/60 )
    local sec=time%60
    return minNum(min)..":"..minNum(sec)
end

function gParserMsgTxt(content)
    -- 解析滚动公告 xxxx<itemid,1002>xxxxx
    if content == "" or content == nil then 
        return ""
    end 

    local split = string.split(content,"<")
    if table.getn(split) < 2 then
        return content
    end

    local replace_list = {
        -- need_replace
        -- cur_replace
    }
    for i = 2,table.getn(split) do
        local v = split[i]
        local idx = string.find(v,">")
        if idx ~= nil then
            local conf = string.sub(v,1,idx-1)
            --print("解析到的conf:"..conf)
            local items = string.split(conf,",")
            local need_replace = "<"..conf..">"
            local cur_replace = ""
            if items[1] == "itemid" then
                cur_replace = DB.getItemName(toint(items[2]))
                --print("道具名:"..cur_replace)
            end

            table.insert(replace_list,{need_replace = need_replace,cur_replace = cur_replace})
        end
    end

    for k,v in pairs(replace_list) do
        --print("替换:"..v.need_replace..","..v.cur_replace)
        content = gReplaceParamOnce(content,v.need_replace,v.cur_replace)
    end
    --print("完成:"..content)
    return content
end

function gGetWeekOneTimeByCur(target, hour, min)
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8();
    local timeDate = os.date("*t", curTime);
    local dayOfWeek = (timeDate.wday + 6) % 7
    if dayOfWeek == 0 then
        dayOfWeek = 7
    end

    local interval = target - dayOfWeek
    local zeroTime = os.time({year=timeDate.year,month=timeDate.month,day=timeDate.day,hour=0})
    local diffTime = zeroTime + interval*24*3600 + hour*3600
    if nil ~= min then
        diffTime = diffTime + min * 60
    end

    return diffTime
end

function gGetCurDrawGoldItemForShort()
    local num,needShort = gGetNumForShort(Data.getItemNum(ITEM_DRAW_GOLD_BUY),1000000,false);
    return num,needShort;
end

function gGetMonsterName(mid,defname)
    if not defname then
        defname = ""
    end

    if not mid then
        mid = 0
    end

    local monster=DB.getMonsterById(mid)
    if monster then
        defname = monster.name
    end

    return defname
end

function gGetHex(num)
    -- 十进制转十六进制
    if num == 0 then
        return "00"
    end
    local s = string.format("%#x",num)
    return string.gsub(s,"0x","")
end

function gIsVipExperTimeOver(vip_type)
    -- vip体验是否过期
    if gUserInfo.fevip_endtime
    and gUserInfo.fevip_endtime > 0 
    and gUserInfo.fevip_endtime > gGetCurServerTime() then
        return false
    end

    if vip_type == VIP_MINING_ATLAS_RESET then
        if Data.canBuyTimes(VIP_MINING_ATLAS_RESET,false) == false then
            local txt = gGetCmdCodeWord("act.getreward88",27)
            txt = txt..","..gGetWords("activityNameWords.plist","act_timeover")
            gShowNotice(txt)
            return true
        end
    else
        local need_vip = Data.getCanBuyTimesVip(vip_type)
        if gUserInfo.vip < need_vip then
            local txt = gGetCmdCodeWord("act.getreward88",27)
            txt = txt..","..gGetWords("activityNameWords.plist","act_timeover")
            gShowNotice(txt)
            return true
        end
    end

    return false
end

-- openDayString --->'1;2;3;4;5;6;0'
-- opentime
function gGetOpenDaysFormateStr(openDayStr,openTimeStr)
    local days = string.split(openDayStr,";")
    local strDay = ""
    for key, var in ipairs(days) do
        local day_key = "num"
        local spl_sym = "." 
        if gCurLanguage == LANGUAGE_EN then
            day_key = "weekday"
            spl_sym = ","
        end
        strDay = strDay .. gGetWords("labelWords.plist",day_key..var)
        if(key ~= #days)then
            strDay = strDay .. spl_sym
        end        
    end

    local times = string.split(openTimeStr,";")
    if gCurLanguage == LANGUAGE_EN then
        strDay = strDay.." "..times[1]
    else
        strDay = strDay..times[1]
    end
    local formateStr = gGetWords("labelWords.plist","lab_unlock_time_week",strDay)
    return formateStr
end

function gGetMaxPetAwakeId(cardid)
    local maxAwakeId = nil
    local db= DB.getPetById(cardid)
    if(db ~= nil)then
        maxAwakeId = db.wakenshow
    end
    
    return maxAwakeId
end

function isNewBossInDay(dayOfWeek)
    local bNewBossDay = false
    local minOffDay = 7

    local oldBossDays = string.split(DB.getOpenDayOfWorldBoss(), ";")
    for _, day in ipairs(oldBossDays) do
        local offDay = toint(day) - dayOfWeek
        if offDay >= 0 and minOffDay > offDay then
            minOffDay = offDay
        end
    end
    
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8();

    -- 新世界boss
    local newBossDays = string.split(DB.getClientParam("WORLD_BOSS_NEW_DAY"), ";")
    local newBossTimes = string.split(DB.getClientParam("WORLD_BOSS_NEW_TIME"), ";")
    for _, day in ipairs(newBossDays) do
        local offDay = toint(day) - dayOfWeek
        if offDay >= 0 and minOffDay > offDay then
            local endTime = gGetWeekOneTimeByCur(toint(day),toint(newBossTimes[1]),toint(newBossTimes[2]))
            endTime = endTime + newBossTimes[3]
            if(curTime <= endTime) then
                bNewBossDay = true
                break
            end
        end
    end

    return bNewBossDay
end

function isNewBossCurDay()
    --[[
    -- 当天是否新世界boss战
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8();
    local timeDate = os.date("*t", curTime);
    local dayOfWeek = (timeDate.wday + 6) % 7
    if dayOfWeek == 0 then
        dayOfWeek = 7
    end

    local bNewBossDay = isNewBossInDay(dayOfWeek)

    --for i = 1,7 do
    --    if self:isNewBossInDay(i) then
    --        print("周"..i.."下一个新boss")
    --    else
    --        print("周"..i.."下一个旧boss")
    --    end
    --end
    
    local isOldBossDead = false
    if Data.worldBossInfo.status then
        if Data.worldBossInfo.status == 0 and curTime+gGetTimeZoneOffsetToZone8() > Data.worldBossInfo.oldstarttime then
            isOldBossDead = true
        end
    end

    -- 判断旧boss活动是否结束
    if bNewBossDay == false and isOldBossDead == true then
        bNewBossDay = true
    end

    return bNewBossDay
    ]]
    return Data.worldBossInfo.bossid == 12008
end
