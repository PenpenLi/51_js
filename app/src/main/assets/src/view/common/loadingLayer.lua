local LoadingLayer=class("LoadingLayer",UILayer)

function LoadingLayer:ctor()
    self:init("ui/ui_loading_b.map") 
    self:setRTFString("txt_tip","")


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self.actioins={
        {roleid=10006,action1="attack_b"},
        {roleid=10021,action1="run",action2="attack_s"},
        {roleid=10029,action1="wait"},
        {roleid=10026,action1="attack_b"},
        {roleid=10004,action1="attack_s"},
        {roleid=10009,action1="wait"},
        {roleid=10003,action1="win"},
        {roleid=10028,action1="win"},
        {roleid=10022,action1="attack_b"}
    }

    self.tips=cc.FileUtils:getInstance():getValueMapFromFile("word/loadingTip.plist")

end
local result=nil;
local result_tab=nil;
local key=nil;
local value=nil;
function LoadingLayer:updateLoading()
    if( self.loaded3d>= self.needLoad3d and table.getn(self.preLoadXml)==0 and table.getn(self.preLoadPlist)==0 and table.getn(self.preLoadSounds)==0 and table.getn(self.preLuaFiles)==0 and self.isShowing~=true)then


        if(table.getn( self.sprite3ds)==0)then
            if(self.loadedCallback)then
                self.loadedCallback()
                self.loadedCallback=nil
            end
            if(self.loadedCallbackHideSelf)then
                self:hide()
            end
        end
        return
    end

   

    local lastTime=os.clock()

    while(table.getn(self.preLoadPlist)>0)do
        local name= self.preLoadPlist[1]
        if(os.clock()-lastTime>1/15)then
            return
        end
        table.remove( self.preLoadPlist,1)
        cc.SpriteFrameCache:getInstance():addSpriteFrames(name)

    end

    while(table.getn(self.preLoadXml)>0)do
        local name= self.preLoadXml[1]
        if(os.clock()-lastTime>1/15)then
            return
        end
        table.remove( self.preLoadXml,1)
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("fla/"..name..".xml")
    end

    while(table.getn(self.preLoadSounds)>0)do
        local name= self.preLoadSounds[1]
        if(os.clock()-lastTime>1/15)then
            return
        end
        table.remove( self.preLoadSounds,1)
        cc.SimpleAudioEngine:getInstance():preloadEffect(name)
    end

    while #(self.preLuaFiles)>0 do
        result = self.preLuaFiles[1]
        if nil ~= result then
            result_tab = string.split(result, "=")

            if table.getn(result_tab) ==2 then
                key = string.trim(result_tab[1])
                value = string.trim(result_tab[2])
                _G[key] = require(value)
                -- print("lua ="..value)
            elseif table.getn(result_tab) ==1 then
                value=string.trim(result_tab[1])
                require(value)
                -- print("lua ="..value)
            end
            table.remove(self.preLuaFiles, 1)
            -- lcurnum = lcurnum +1
            if(os.clock()-lastTime>=1/15)then
                break
            end
            -- print("lcurnum = "..lcurnum);
        end
    end


end

function LoadingLayer:hide()
    Guide.pause=false
    self:setVisible(false)
    self.loadedCallback=nil 
    self.preLoadXml={}
    self.preLoadPlist={}
    self.preLoadSounds={}
    self.sprite3ds={}
    self.preLuaFiles={}
    self:getNode("role_container"):removeAllChildren()
    self:setRTFString("txt_tip","")
    ccs.ArmatureDataManager:getInstance():setSoundPlay(not  gSysEffectClose)
end

function  LoadingLayer:showRole()
    local tip=self.tips["tip"..getRand(1,31)]
    if(#self.preLuaFiles>0)then
        tip = gGetWords("loadingTip.plist","tipLoadingLua");
    end
    self:getNode("txt_tip"):setDimensions(gGetScreenWidth() - 100,0);
    self:setLabelString("txt_tip",tip)
    -- self:setRTFString("txt_tip",tip)

    local action=self.actioins[getRand(1,table.getn(self.actioins))]
    if(action==nil)then
        return
    end
    local result= loadFlaXml("r"..action.roleid)
    if(result)then
        local fla=FlashAni.new()
        fla:setSoundPlay(false)
        fla.curActionParam=action.action1
        self:getNode("role_container"):addChild(fla)

        local function callback()
            if(action.action2~=nil)then
                if(fla.curActionParam==action.action1)then
                    fla.curActionParam=action.action2
                    fla:playAction("r"..action.roleid.."_"..action.action2,callback)
                else
                    fla.curActionParam=action.action1
                    fla:playAction("r"..action.roleid.."_"..action.action1,callback)
                end
            end
        end

        fla:playAction("r"..action.roleid.."_"..action.action1,callback)
    end
end

function  LoadingLayer:showWord()
    local fla=FlashAni.new()
    loadFlaXml("ui_guide")
    self:getNode("role_container"):addChild(fla)
    local function callback()
        self.isShowing=false
        loadFlaXml("loading")
        fla:playAction("loading_4")
    end
    fla:playAction("ui_guide_words4",callback)
end

function LoadingLayer:show(flaXml,callback,sprite3ds,luaFiles)
    Guide.pause=true 
    print("start loading")
    self.preLoadXml={}
    self.preLoadPlist={}
    self.preLoadSounds={}
    self.sprite3ds={}
    self.preLuaFiles={}
    self.loadedCallbackHideSelf = true;

    self.needLoad3d=0
    self.loaded3d=0
    if(sprite3ds)then
        self.needLoad3d= table.getn(sprite3ds)
    else
        sprite3ds={}
    end


    local function load3dCallback()
        self.loaded3d=self.loaded3d+1
    end

    for key, sprite3d in pairs(sprite3ds) do
        cc.Sprite3D:createAsync(sprite3d,load3dCallback)
    end



    local plists={}
    local xmls={}
    for key, fla in pairs(flaXml) do
        xmls[fla.path]=1
        local name= fla.path
        local weaponLv= fla.weaponLv
        local awakeLv= fla.awakeLv
        getFlaPackerRes(name,weaponLv,awakeLv,plists)
    end

    for key, name in pairs(xmls) do
        table.insert(self.preLoadXml,key)
    end


    for key, name in pairs(plists) do
        table.insert(self.preLoadPlist,key)
    end

    if(not  gSysEffectClose)then
        temp={}
        for key, name in pairs(self.preLoadXml) do
            if(gFlaSounds[name])then
                local sounds=string.split(gFlaSounds[name],",")
                for key, sound in pairs(sounds) do
                    temp["sound/effect/"..sound]=1
                end
            end
        end
        for key, var in pairs(temp) do
            table.insert(self.preLoadSounds,key)
        end
    end

    if(luaFiles)then
        self.preLuaFiles = luaFiles;
        self.loadedCallbackHideSelf = false;
        print_lua_table(self.preLuaFiles);
    end


    self.loadedCallback=callback
    self:getNode("role_container"):removeAllChildren()
    self:setLabelString("txt_tip","")
    self.isShowing=true
    if(#self.preLuaFiles <=0 and Scene.canEnterCg() )then
        self:showWord()
        gIsFirstEnter=false
    else
        ccs.ArmatureDataManager:getInstance():setSoundPlay(false)
        self:showRole()
        self.isShowing=false

    end
end



return LoadingLayer