local MainBgLayer=class("MainBgLayer",UILayer)

EXPLORE_TYPE_BOSS=1
EXPLORE_TYPE_TREASURE=2
EXPLORE_TYPE_FOOD=3


function MainBgLayer:ctor()
    self:init("ui/ui_main_bg.map")
    self.moveDistance = 0;

    local main3D=Main3D.new()
    self:addChild(main3D)
    main3D:initScene("fightScript/mainScene_"..Scene.curSceneEffectLevel..".plist")
    main3D:inited()
    self.main3D=main3D
    self:getNode("btn_move").__touchend=true
    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self.oldBgPos=main3D.bg:getPosition3D()
    self.oldMainRotation=main3D.main:getRotation3D()
    local posX ,posY=self:getPosition()
    self:getNode("night_cover"):setVisible(false)

    self.main3D:setPosition(-posX+winSize.width /2,-posY+winSize.height/2)


    --[[if(Scene.curSceneEffectLevel==1)then
    loadFlaXml("home_snow")
    local fla=gCreateFla("home_snow",1)
    fla:setPosition(-posX+winSize.width /2,-posY+winSize.height/2)
    self.snow=fla
    self:addChild(fla)
    end]]
    self.nodeEvents={
        {obj="main", subName="kuafu" ,event="kuafu",aabb_min={x=-200,y=0,z=-30},aabb_max={x=200,y=200,z=30}},
        {obj="main", subName="wakuang" ,event="wakuang",aabb_min={x=-40,y=0,z=-20},aabb_max={x=80,y=150,z=20}},
        {obj="main", subName="mail" ,event="mail",aabb_min={x=-50,y=-20,z=80},aabb_max={x=70,y=20,z=120}},
        {obj="main", subName="mail_bird" ,event="mail2",aabb_min={x=-20,y=-30,z=-10},aabb_max={x=20,y=30,z=10}},
        {obj="main", subName="dixue" ,event="dixue",aabb_min={x=-100,y=-100,z=-50},aabb_max={x=100,y=100,z=50}},
        {obj="main", subName="zhuanhuanwu" ,event="zhuanhuanwu",aabb_min={x=-50,y=-100,z=-100},aabb_max={x=50,y=100,z=100}},
        {obj="main", subName="family" ,event="family",aabb_min={x=-100,y=-100,z=0},aabb_max={x=100,y=100,z=300}},
        {obj="main", subName="shop_car" ,event="shop",aabb_min={x=-100,y=50,z=-50},aabb_max={x=100,y=170,z=50}},
        {obj="main", subName="arena" ,event="arena" ,aabb_min={x=-100,y=70,z=-70},aabb_max={x=150,y=200,z=70}},
        {obj="main", subName="dragon" ,event="drawCard",aabb_min={x=-100,y=-70,z=-50},aabb_max={x=100,y=70,z=50}},
        {obj="main", subName="fly_build" ,event="activity",aabb_min={x=-120,y=0,z=-120},aabb_max={x=120,y=120,z=120}},
        {obj="main", subName="atlas" ,event="atlas" ,aabb_min={x=-100,y=0,z=50},aabb_max={x=100,y=200,z=50}},
        {obj="main", subName="panjun" ,event="panjun" ,aabb_min={x=-100,y=0,z=-50},aabb_max={x=100,y=200,z=50}},
        {obj="main", subName="tower" ,event="tower" ,aabb_min={x=-100,y=100,z=0},aabb_max={x=100,y=100,z=600}},
        {obj="main", subName="shuiche" ,event="shuiche",aabb_min={x=-100,y=0,z=-50},aabb_max={x=100,y=200,z=50}},
        {obj="main", subName="feichuan" ,event="flyboard",aabb_min={x=-80,y=-80,z=-80},aabb_max={x=80,y=80,z=80}},
        {obj="main", subName="liangcang" ,event="liangcang",aabb_min={x=-80,y=-80,z=-0},aabb_max={x=80,y=80,z=240}},
        {obj="main", subName="shenmiao" ,event="shenmiao",aabb_min={x=-80,y=-80,z=-0},aabb_max={x=80,y=80,z=240}},
        {obj="main", subName="boss" ,event="boss",aabb_min={x=-80,y=-10,z=-20},aabb_max={x=80,y=120,z=20}},
        {obj="main", subName="lingshou" ,event="lingshou",aabb_min={x=-80,y=-10,z=-20},aabb_max={x=80,y=120,z=20}},
    }



    local function  onCheckInsde(touch,event)
        local target=  event:getCurrentTarget()
        return self:checkInside(touch,event)
    end


    local function convertTo3DWorldPos(target)

        local size=cc.Director:getInstance():getWinSize()
        local zeye = self.main3D.camera.zeye

        local pos={x=0,y=0,z=0}
        if(target.aabb_min)then
            pos.x=( target.aabb_min.x+ target.aabb_max.x)/2
            pos.y=( target.aabb_min.y+ target.aabb_max.y)/2
            pos.z=( target.aabb_min.z+ target.aabb_max.z)/2
        end

        local mat4=cc.mat4.new(target:getNodeToWorldTransform())
        pos.w=1
        pos=mat4:transformVector(pos,pos)
        local posZ=  zeye-pos.z
        local curWidth=size.width *(posZ/zeye)
        local curHeight=size.height *(posZ/zeye)

        local newX=(   (pos.x+(curWidth-size.width )/2)* (size.width/curWidth))
        local newY=(   (pos.y+(curHeight-size.height )/2)* (size.height/curHeight))

        return cc.p(newX  ,newY )

    end
    self.objects={}
    for key, nodeEvent in pairs(self.nodeEvents) do
        if(main3D:getObjById(nodeEvent.obj)==nil)then
            break
        end
        local obj=main3D:getObjNode(nodeEvent.obj,nodeEvent.subName)
        local isInside=false
        if(obj==nil)then
            isInside=true
            obj= gGetSpriteMesheByName(self.main3D:getObjNode(nodeEvent.obj,"water"),nodeEvent.subName)
        end
        if(obj)then
            obj.oldScaleX=obj:getScaleX()
            obj.oldScaleY=obj:getScaleY()
            obj.oldScaleZ=obj:getScaleZ()
            gSetCascadeOpacityEnabled(obj,true)
            obj.event=nodeEvent.event
            obj.aabb_min=nodeEvent.aabb_min
            obj.aabb_max=nodeEvent.aabb_max

            if(obj.getAABB)then
                obj.aabb_min.x= obj.aabb_min.x/obj:getScaleX()
                obj.aabb_min.y= obj.aabb_min.y/obj:getScaleY()
                obj.aabb_min.z= obj.aabb_min.z/obj:getScaleZ()
                obj.aabb_max.x= obj.aabb_max.x/obj:getScaleX()
                obj.aabb_max.y= obj.aabb_max.y/obj:getScaleY()
                obj.aabb_max.z= obj.aabb_max.z/obj:getScaleZ()
                obj.isInside=isInside
            end


            table.insert(self.objects,obj)
            obj.__isTouchInside=onCheckInsde
            obj.__convertToWorldPos=convertTo3DWorldPos
            self:addTouchNode(obj,nodeEvent.subName)
        end
    end
    -- local title=self:getBuildTitle(22)
    -- RedPoint.add(title,cc.p(0.5,1.0))
    local showStage=false
    if(gAtlas.maxMap0)then
        if(gAtlas.maxMap0<3   ) then
            showStage=true
        elseif(gAtlas.maxMap0==3  and gAtlas.maxStage0<16 ) then
            showStage=true
        end
    end

    self:getGuideItem("new_stage"):setVisible(showStage)
    -- if(gSceneArenaInfo.show)then
    --     self.main3D:changeStandPos(1,gSceneArenaInfo.icon,gSceneArenaInfo.name,gSceneArenaInfo.show.wlv,gSceneArenaInfo.show.wkn)
    -- end

    self:updateDayNight()
    self:setServerBattleInfo()
    self:checkBathInfo();
    self:checkFamilySpringInfo();
    self:checkArenaInfo();

    local _update = function()
        self:updateTime();
    end
    self:scheduleUpdate(_update, 1);
    Data.setHuntIntervalInfos()
    self:setExploreType(Data.finalHuntIntervalInfos[2].huntId)
end

function MainBgLayer:setExploreType(type)
    self.type=type
    local node=nil
    self:getBuildTitleBone(SYS_WORLD_BOSS):setVisible(false)
    self:getBuildTitleBone(SYS_LOOT_FOOD):setVisible(false)
    self:getBuildTitleBone(SYS_TREASURE_HUNT):setVisible(false)
    self:getBuild("boss"):setVisible(false)

    if(self:getBuild("liangcang"))then
        self:getBuild("liangcang"):setVisible(false)
    end
    if(self:getBuild("shenmiao"))then
        self:getBuild("shenmiao"):setVisible(false)
    end
    
    if(self:getBuild("shenmiaolight"))then
        self:getBuild("shenmiaolight"):setVisible(false)
    end
    
    self:getBuild("boss"):pause()
    if(type==EXPLORE_TYPE_BOSS)then
        self:getBuild("boss"):resume()
        self:getBuildTitleBone(SYS_WORLD_BOSS):setVisible(true)
        self:getBuild("boss"):setVisible(true)

        if isNewBossCurDay() then
            self:getBuild("boss"):playAction("ui_main_bg_boss2")
        end

    elseif(type==EXPLORE_TYPE_TREASURE)then
        if(self:getBuild("shenmiao"))then
            self:getBuild("shenmiao"):setVisible(true)
        end
        if(self:getBuild("shenmiaolight"))then
            self:getBuild("shenmiaolight"):setVisible(true)
        end
        self:getBuildTitleBone(SYS_TREASURE_HUNT):setVisible(true)
    elseif(type==EXPLORE_TYPE_FOOD )then
        self:getBuildTitleBone(SYS_LOOT_FOOD):setVisible(true)
        if(self:getBuild("liangcang"))then
            self:getBuild("liangcang"):setVisible(true)
        end
    end
end
function MainBgLayer:onUILayerExit()
    self:unscheduleUpdateEx();
end

function MainBgLayer:updateGame()
    if(self:isVisible()==false)then
        return
    end
    self:updateWater()
end

function MainBgLayer:updateTime()
    if(self:isVisible()==false)then
        return
    end
    self:updateDayNight();
    self:updateBathInfo(gGetCurServerTime());
    RedPoint.updateGame();
end

function MainBgLayer:updateBathInfo(curServerTime)
    -- body
    if(gBathInfo.all_uid > 0) then
        local lefttime = gBathInfo.all_time - curServerTime;
        -- print("lefttime = "..lefttime);
        if(lefttime <= 0) then
            gBathInfo.all_uid = 0;
            gBathInfo.all_time = 0;
            self:checkBathInfo();
        end
    end
end

function MainBgLayer:setServerBattleInfo()
    -- 10001,"越狱8服","你猜我猜不猜"
    local iconid = gServerBattle.lastBattleInfo.icon
    local serverName = gServerBattle.lastBattleInfo.sname
    local name = gServerBattle.lastBattleInfo.name

    local icon=nil
    local frameIcon=cc.Node:create()
    if(iconid==0 or iconid == nil)then
        icon=cc.Sprite:create("images/ui_severwar/npc_0.png")
    else
        local showIcon , frame =Icon.getHeadIconParam(iconid)
        icon=cc.Sprite:create("images/icon/head/"..showIcon..".png")
        --[[if frame == 0 then
        frameIcon=cc.Sprite:create("images/icon/head/frame"..frame..".png");
        else
        frameIcon=cc.Sprite:create("images/icon/head/frame"..frame.."_1.png");
        end ]]
    end
    loadFlaXml("kuafuguanjun")
    local fla=gCreateFla("kuafuguanjun",1)
    local kuafu=self:getBuild("kuafu")
    kuafu:removeAllAttachNode()

    local bone= kuafu:getAttachNode("bone_icon")
    fla:replaceBoneWithNode({"icon"},icon)
    fla:replaceBoneWithNode({"frame"},frameIcon)
    bone:addChild(fla)
    fla:setScale(0.090)
    gSetDepth2d(icon,true)
    gSetDepth2d(frameIcon,true)
    gSetDepth2d(bone,true)
    bone:setCameraMask(cc.CameraFlag.USER1,true)

    local bone= kuafu:getAttachNode("bone_name")
    local boundingBox = {width = 20,height = 3}
    local stencil = cc.LayerColor:create(cc.c4b(255,255,255,255), boundingBox.width, boundingBox.height)
    local node = cc.ClippingNode:create()
    node:setStencil(stencil);
    node:setContentSize(boundingBox.width, boundingBox.height)
    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(cc.p(0.5,0.4))
    node.stencil=stencil
    bone:addChild(node)
    bone:setCameraMask(cc.CameraFlag.USER1,true)

    -- local layerColor = cc.LayerColor:create(cc.c4b(255,255,255,0), boundingBox.width, boundingBox.height)
    -- layerColor:setPosition(cc.p(boundingBox.width/2,boundingBox.height/2))
    -- node:addChild(layerColor)

    local txt = RTFLayer.new(400);
    txt:setAnchorPoint(cc.p(0,0))
    local content = ""
    if serverName ~= "" and serverName ~= nil then
        content = "\\w{c=00c6ff}"..serverName.."\\ \\w{c=ffffff,s=24}"..name.."\\"
    end
    txt:setDefaultConfig(gFont,20,cc.c3b(255,255,255))
    txt:setString(content)
    txt:layout()
    node:addChild(txt)
    local txtContentSize = txt:getContentSize()
    txt:setScale(0.1)

    txtContentSize = txt:getContentSize()
    local txt2 = RTFLayer.new(400)
    txt2:setAnchorPoint(cc.p(0,0))
    txt2:setDefaultConfig(gFont,20,cc.c3b(255,255,255))
    txt2:setString(content)
    txt2:layout()
    node:addChild(txt2)
    txt2:setScale(0.1)
    txt2:setPosition(txtContentSize.width * 0.13,0)


    gSetDepth2d(bone,true)
    bone:setCameraMask(cc.CameraFlag.USER1,true)

    local action1 = cc.MoveBy:create(10,cc.p(-txtContentSize.width * 0.13,0))
    local action2 = cc.MoveBy:create(0,cc.p(2 * txtContentSize.width * 0.13, 0))
    local action3 = cc.MoveBy:create(10,cc.p(-txtContentSize.width * 0.13, 0))
    local repeation = cc.RepeatForever:create(cc.Sequence:create(action1,action2,action3))
    txt:runAction(repeation)

    local action4 = cc.MoveBy:create(20,cc.p(-2 * txtContentSize.width * 0.13,0))
    local action5 = cc.MoveBy:create(0,cc.p(2 * txtContentSize.width * 0.13, 0))
    local repeation2 = cc.RepeatForever:create(cc.Sequence:create(action4,action5))
    txt2:runAction(repeation2)
end

function MainBgLayer:setBirdFly(value)
    if(self.hasShowBird==true)then
        return
    end
    self.hasShowBird=true
    if(gHasShowBirdFly~=true and value)then
        self.main3D:flyIn()
        gHasShowBirdFly=true
    else
        self.main3D:playWait2()

    end
end


function MainBgLayer:updateDayNight()
    if(gUserInfo.level==nil or gUserInfo.level<25)then
        return
    end

    local curHour= gGetHourByTime()
    local change=false
    local isNight=false
    if(curHour>=18 or curHour<=6)then
        change= self.main3D:changeNight()
        isNight=true
    else
        change= self.main3D:changeMoring()
        isNight=false
    end
    if(change)then
        if(isNight)then
            local winSize=cc.Director:getInstance():getWinSize()
            self:getNode("night_cover"):setVisible(true)
            self:getNode("night_cover"):setScaleX(winSize.width/160)
            self:getNode("night_cover"):setScaleY(winSize.height/110)
        else
            self:getNode("night_cover"):setVisible(false)
        end
    end

    if(isNight)then
        if(gMainBgCoverLayer)then
            gMainBgCoverLayer:changeNight()
        end
    else
        if(gMainBgCoverLayer)then
            gMainBgCoverLayer:changeMoring()
        end
    end
end

function MainBgLayer:setMainVisible(value)
    self.main3D:setMailVisible(value)
end


function  MainBgLayer:updateWater(dt)
    if(Scene.curSceneEffectLevel~=1)then
        local sprite3d=self:getGuideItem("water")
        self.water= gGetSpriteMesheByName(sprite3d,"sui_mian")
        self.water:setVisible(false)
        return
    end
    local rotation= self.main3D.main:getRotation3D()
    local pos=clone(self.oldBgPos)
    pos.x=pos.x+( rotation.y-self.oldMainRotation.y) *30
    self.main3D.bg:setPosition3D(pos)


    if(self.water==nil)then
        local sprite3d=self:getGuideItem("water")
        self.water= gGetSpriteMesheByName(sprite3d,"sui_mian")

    end
    self.water:setVisible(true)
    if(self.water.state==nil)then
        local state=cc.GLProgramState:create( Shader.getShader(Shader.UV_ANI_SHADER))
        self.water:setGLProgramState(state)
        self.water.state=state
        self.water.state.lastUVy=0
        self.water.state.lastUVx=0
    end


    self.water.state.lastUVy= self.water.state.lastUVy-0.0007
    self.water.state.lastUVx= self.water.state.lastUVx-0.0005
    if(self.water.state.lastUVy<-1)then
        self.water.state.lastUVy=0
    end


    if(self.water.state.lastUVx<-1)then
        self.water.state.lastUVx=0
    end


    self.water.state:setUniformVec2("texOffset",cc.p(self.water.state.lastUVx, self.water.state.lastUVy))
    -- self:checkBathInfo();
    -- self:checkFamilySpringInfo();
end

function MainBgLayer:checkFamilySpringInfo()
    local hasSpring = false;
    if(Data.hasFamily() and gFamilySpringInfo.callUid and gFamilySpringInfo.callUid > 0) then
        hasSpring = true;
    end

    local node1 = self:getBuild("quanshui1");
    local node2 = self:getBuild("quanshui2");
    node1:setVisible(hasSpring);
    if(node2)then
        node2:setVisible(hasSpring);
    end
end
function MainBgLayer:checkBathInfo()
    local hasBath = false;
    if(gBathInfo.all_uid > 0 and gBathInfo.all_time - gGetCurServerTime() > 0) then
        hasBath = true;
    end

    local node1 = self:getBuild("foguang1");
    local node2 = self:getBuild("foguang2");
    -- if(hasBath)then
    if(node1)then
        node1:setVisible(hasBath);
    end
    if(node2)then
        node2:setVisible(hasBath);
    end

    -- end

    if(gBathInfo.all_uid == Data.getCurUserId())then
        gBathInfo.show = {};
        gBathInfo.show.wlv = Data.getCurWeapon();
        gBathInfo.show.wkn = Data.getCurAwake();
    end

    if(gBathInfo.show)then
        self.main3D:changeStandPos(2,gBathInfo.all_coatid,gBathInfo.all_name,gBathInfo.show.wlv,gBathInfo.show.wkn,gBathInfo.show.halo)
    end
    self.main3D:getObjNode("main","standPos2"):setVisible(hasBath)
end
function MainBgLayer:checkArenaInfo()
    if(gSceneArenaInfo.show)then
        self.main3D:changeStandPos(1,gSceneArenaInfo.icon,gSceneArenaInfo.name,gSceneArenaInfo.show.wlv,gSceneArenaInfo.show.wkn,gSceneArenaInfo.show.halo)
    end
end

function MainBgLayer:getBuildTitle(type)
    local nameObj=self.main3D:getObjNode("main","name"..type)
    if(nameObj)then
        local bone= nameObj:getBone("billboard2")
        if(bone)then
            return bone:getDisplayRenderNode()
        end
    end
    return nil
end

function MainBgLayer:getBuildTitleBone(type)
    local nameObj=self.main3D:getObjNode("main","name"..type)

    return nameObj
end


function MainBgLayer:getBuild(name)
    return  self.main3D:getObjNode("main",name)
end


function MainBgLayer:getGuideItem(name)
    return  self.main3D:getObjNode("main",name)
end

function MainBgLayer:checkInside(touch,event)
    local location = touch:getLocationInView()
    local obj= event:getCurrentTarget()
    local ray = cc.Ray:new()
    local mat=cc.mat4.new(self.main3D.camera:getViewProjectionMatrix())
    gCalculateRayByLocationInView(ray, location,mat)

    local mat =cc.mat4.new( obj:getNodeToWorldTransform())
    aabb=cc.AABB:new(obj.aabb_min,obj.aabb_max)
    aabb:transform(mat)
    local _obbt = cc.OBB:new(aabb)
    if ray:intersects(_obbt) then
        return true
    end
    return false
end

function MainBgLayer:getObjByTouch(touch)
    local location = touch:getLocationInView()
    local ray = cc.Ray:new()
    local mat=cc.mat4.new(self.main3D.camera:getViewProjectionMatrix())
    gCalculateRayByLocationInView(ray, location,mat)
    for key, obj in pairs(self.objects) do
        if( obj:isVisible())then
            local aabb= nil
            local mat =cc.mat4.new( obj:getNodeToWorldTransform())

            if(obj.isInside)then
                aabb=obj:getAABB()
            else
                aabb=cc.AABB:new(obj.aabb_min,obj.aabb_max)
                aabb:transform(mat)
            end

            local _obbt = cc.OBB:new(aabb)

            if( obj.event=="mail2" and Guide.isGuiding() ) then

            else
                if ray:intersects(_obbt)   then
                    return obj
                end
            end
        end
    end

    return nil
end

function MainBgLayer:onTouchBegan(target, touch)

    self.preLocation = touch:getLocation()
    local node= self:getObjByTouch(touch)
    self.curSelectNode=nil


    if(node)then
        -- self:setNodeScale(node,1.1)
        self.curSelectNode=node
    end

    self.stopSchedule = true;
end

function MainBgLayer:setNodeScale(obj ,scale)
    obj:setScaleX(obj.oldScaleX*scale)
    obj:setScaleY(obj.oldScaleY*scale)
    obj:setScaleZ(obj.oldScaleZ*scale)
end

function MainBgLayer:runNodeScaleAction(obj,scale,callback)
    -- body
    if callback == nil then
        callback = function()
            print("callback");
        end
    end
    obj:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.05,obj.oldScaleX*scale,obj.oldScaleY*scale,obj.oldScaleZ*scale),
        cc.CallFunc:create(callback),
        cc.ScaleTo:create(0.05,obj.oldScaleX*1,obj.oldScaleY*1,obj.oldScaleZ*1)

    ));
end

local MAX_END_ROTATIONY=23.84
local MAX_ROTATIONY=22.16
local MIN_ROTATIONY=-18.02
local MIN_END_ROTATIONY=-20.8
function MainBgLayer:onTouchMoved(target, touch)
    if(Guide.isMainScrollPause())then
        return
    end

    local posX=touch:getDelta().x

    if math.abs(posX) > 5 then
        self.moveDistance = posX * 0.8;
    end
    self:rotationMain3D(posX);


    if(self.snow)then
        self.snow:setPositionX(self.snow:getPosition()+ posX/2)
    end

end

function MainBgLayer:rotationMain3D(posXOffset)

    local rotation= self.main3D.main:getRotation3D()
    local addRotation=posXOffset/30

    if(rotation.y>MAX_ROTATIONY   and addRotation>0)then
        addRotation=addRotation*0.2
    end


    if(rotation.y<MIN_ROTATIONY  and addRotation<0 )then
        addRotation=addRotation*0.2
    end

    rotation.y=rotation.y+addRotation

    if(rotation.y>MAX_END_ROTATIONY)then
        rotation.y=MAX_END_ROTATIONY
    end

    if(rotation.y<MIN_END_ROTATIONY)then
        rotation.y=MIN_END_ROTATIONY
    end
    self.main3D.main:setRotation3D(rotation)
end

function MainBgLayer:deaccelerateMoveing()

    -- print("self.moveDistance = "..self.moveDistance);
    if self.stopSchedule and self.stopSchedule == true then
        -- print("stop");
        self.moveDistance = 0;
        self:unscheduleUpdate()
    end

    self.moveDistance = self.moveDistance * 0.9;
    self:rotationMain3D(self.moveDistance);

    if self:checkBorder() or math.abs(self.moveDistance) <= 0.05 then
        self.moveDistance = 0;
        self:unscheduleUpdate()
    end

end

function MainBgLayer:checkBorder()
    local rotation= self.main3D.main:getRotation3D()
    if(rotation.y>MAX_ROTATIONY or rotation.y<MIN_ROTATIONY)then
        if(rotation.y>MAX_ROTATIONY)then
            rotation.y=MAX_ROTATIONY
        end
        if(rotation.y<MIN_ROTATIONY)then
            rotation.y=MIN_ROTATIONY
        end
        local pos=clone(self.oldBgPos)
        pos.x=pos.x+( rotation.y-self.oldMainRotation.y) *30
        local rotationAction=cc.EaseBackOut:create( cc.RotateTo:create(0.5,rotation))
        --self.main3D.main:stopAllActions()
        self.main3D.main:runAction(rotationAction)
        return true;
    end
    return false;
end

function MainBgLayer:setRotationPer(per)
    local rotation= self.main3D.main:getRotation3D()
    rotation.y=MIN_ROTATIONY+(per/100)*(MAX_ROTATIONY-MIN_ROTATIONY)
    self.main3D.main:setRotation3D(rotation)
end

function MainBgLayer:onTouchEnded(target, touch)

    if(UILayer.pauseTouch==true or UILayer.pauseTouchForScreen == true)then
        return;
    end

    Panel.popBackTopPanelByType(PANEL_CHAT)
    self.stopSchedule = false;
    local rotation= self.main3D.main:getRotation3D()
    if(rotation.y>MAX_ROTATIONY or rotation.y<MIN_ROTATIONY)then
        if(rotation.y>MAX_ROTATIONY)then
            rotation.y=MAX_ROTATIONY
        end
        if(rotation.y<MIN_ROTATIONY)then
            rotation.y=MIN_ROTATIONY
        end
        local pos=clone(self.oldBgPos)
        pos.x=pos.x+( rotation.y-self.oldMainRotation.y) *30
        local rotationAction=cc.EaseBackOut:create( cc.RotateTo:create(0.5,rotation))
        --self.main3D.main:stopAllActions()
        self.main3D.main:runAction(rotationAction)
    elseif math.abs(self.moveDistance) > 0 then
        local updateMoving = function()
            self:deaccelerateMoveing();
        end
        self:scheduleUpdateWithPriorityLua(updateMoving,1)
    end

    for key, obj in pairs(self.objects) do
        self:setNodeScale(obj,1.0)
    end
    local endLocation = touch:getLocation()
    local dis= getDistance(self.preLocation.x,self.preLocation.y, endLocation.x,endLocation.y)
    if(Guide.isForceGuiding())then
        dis=0
    end
    if(self.curSelectNode)then
        if(dis<20)then
            local onTouchCallBack = function()
                if(self.curSelectNode.event=="arena")then
                    if Unlock.isUnlock(SYS_ARENA) then
                        -- Panel.popUp(PANEL_ARENA)
                        gEnterArena();
                    end
                elseif(self.curSelectNode.event=="drawCard")then
                    Panel.popUp(PANEL_DRAW_CARD)
                elseif(self.curSelectNode.event=="atlas")then
                    Panel.popUp(PANEL_ATLAS)
                elseif(self.curSelectNode.event=="activity")then
                    if Unlock.isUnlock(SYS_ACT) then
                        Panel.popUp(PANEL_ACTIVITY)
                    end
                elseif(self.curSelectNode.event=="dixue")then
                    if Unlock.isUnlock(SYS_PET_TOWER) then
                        -- Panel.popUp(PANEL_PET_TOWER)
                        Net.sendPetAtlasInfo()
                    end
                elseif(self.curSelectNode.event=="shop")then
                    if Unlock.isUnlock(SYS_SHOP) then
                        Panel.popUp(PANEL_SHOP,SHOP_TYPE_1)
                    end
                elseif(self.curSelectNode.event=="family")then
                    if Unlock.isUnlock(SYS_FAMILY) then
                        self:onFamily();
                    end
                elseif(self.curSelectNode.event=="mail")then
                    Net.sendMailList()

                elseif(self.curSelectNode.event=="mail2")then
                    Net.sendMailList()
                elseif(self.curSelectNode.event=="panjun")then
                    if Unlock.isUnlock(SYS_CRUSADE) then
                        Net.sendCrusadeInfo()
                    end
                elseif(self.curSelectNode.event=="tower")then
                    if Unlock.isUnlock(SYS_TOWER) then
                        Net.sendTownGetinfo();
                    -- self:enterTower();
                    end
                elseif(self.curSelectNode.event=="shuiche")then
                    if Unlock.isUnlock(SYS_TRAINROOM) then
                        Net.sendDrinkGetinfo();
                    end
                elseif(self.curSelectNode.event=="flyboard")then
                    if Unlock.isUnlock(SYS_BATH) then
                        Net.sendBathGetInfo();
                    end
                elseif(self.curSelectNode.event=="boss")then
                    -- if Unlock.isUnlock(SYS_WORLD_BOSS) then--SWITCH_WORLD_BOSS
                    --     Net.sendWorldBossInfo(0)
                    -- end
                    Net.sendSysAdvlist()
                elseif(self.curSelectNode.event=="wakuang")then
                    if(Unlock.isUnlock(SYS_MINE))then
                        gDigMine.processSendInitMsg()
                    end

                elseif(self.curSelectNode.event=="liangcang")then
                    Net.sendSysAdvlist()
                    
                elseif(self.curSelectNode.event=="shenmiao")then
                    Net.sendSysAdvlist()
                elseif(self.curSelectNode.event=="lingshou")then
                     if Unlock.isUnlock(SYS_PET_CAVE) then
                        Panel.popUp(PANNEL_PET_EXPLORE)
                    end
                elseif(self.curSelectNode.event=="zhuanhuanwu")then
                    Panel.popUp(PANEL_TRANSMIT,1)
                elseif(self.curSelectNode.event=="kuafu")then
                    if Unlock.isUnlock(SYS_SERVER_BATTLE) then
                        local serverBattleType = gServerBattle.getServerBattleType()
                        if serverBattleType == SERVER_BATTLE_TYPE1 then
                            gServerBattle.checkTeamInfo()
                            Net.sendWorldWarGetInfo()
                        elseif serverBattleType == SERVER_BATTLE_TYPE2 then
                            Net.sendWorldWarMatchRecord(KING_RANK_SKY)
                            -- else
                            --     gShowNotice(gGetWords("serverBattleWords.plist","txt_rank_no_open"))
                        end
                    end
                end


            end
            self:runNodeScaleAction(self.curSelectNode,1.1,onTouchCallBack);

        end
    end
end

function MainBgLayer:onFamily()

    -- print("onFamily");
    -- print_lua_table(gFamilyInfo);

    -- if Data.getCurLevel() < gUnlockLevel[SYS_FAMILY] then
    --     local word = gGetWords("noticeWords.plist","module_unlock_level",gUnlockLevel[SYS_FAMILY]);
    --     gShowNotice(word);
    --     return;
    -- end


    if gFamilyInfo.familyId == 0 then
        -- Net.sendFamilySearch(0);
        Panel.popUpUnVisible(PANEL_FAMILY_BG);
        Panel.popUpVisible(PANEL_FAMILY_SEARCH,1);
    else
        Net.sendFamilyGetInfo();
    end

end


function MainBgLayer:enterFamilySearch(evt,list)

    local panel = Panel.getPanelByType(PANEL_FAMILY_SEARCH);
    if panel == nil then
        gFamilySearchList = list;
        Panel.popUp(PANEL_FAMILY_SEARCH,1);
    else

        gDispatchEvt(EVENT_ID_FAMILY_SEARCH,list);
    -- EventListener:sharedEventListener():handleLuaEvent(c_event_refresh_familysearch_list,list);
    end

end

function MainBgLayer:enterMail()
    Panel.popUp(PANEL_MAIL)
end

function  MainBgLayer:events()
    return {
        EVENT_ID_MAIL_ENTER,
        EVENT_ID_OPEN_LIMIT_SHOP,
    }
end

function MainBgLayer:dealEvent(event,param)

    if(event == EVENT_ID_MAIL_ENTER) then
        self:enterMail();
    elseif(event == EVENT_ID_OPEN_LIMIT_SHOP) then
        self.main3D:changeShop()
    end
end

return MainBgLayer