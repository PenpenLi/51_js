local Main3D=class("Main3D",Scene3D)

function Main3D:ctor()

end

function Main3D:inited()
    self.camera:setTag(1)
    self.camera:setCameraFlag(cc.CameraFlag.USER1)
    self:setCameraMask(cc.CameraFlag.USER1,true)

    local pos=self:getObjById("main"):getPosition3D()
    self:setPositionZ(pos.z)

    self.main= self:getObjById("main")
    self.bg= self:getObjById("ui_main_bg")
    local rotation=self.main:getRotation3D()
    rotation.y=17.5
    self.main:setRotation3D(rotation)
    for key, obj in pairs(self.objects) do
        obj:setPositionZ(obj:getPositionZ()-pos.z)
    end
    self.bird= self:getObjNode("main","mail_bird")
    local panjun= self:getObjNode("main","panjun")
    if(panjun)then
        panjun:setVisible(false)
    end
    local item=self:getObjNode("main","name"..SYS_CRUSADE)
    if(item)then
        item:setVisible(false)
    end
end


function Main3D:changeNight()
    if(self.isNight==true)then
        return  false
    end
    self.isNight=true
    loadFlaXml("ui_main_night")
    local cloud =self:getObjNode("main","cloud") 
    cloud:playAction("ui_main_cloud3_night")

    local bg =self:getObjById("ui_main_bg") 
    bg:playAction("ui_main_bg_bg_night")
    
    local lan =self:getObjNode("main","lan") 
    lan:playAction("ui_main_bg_lan_night")

    local tower=self:getObjNode("main","tower") 
    self:changeTexture(tower,"c3b/mota_night.png")  

    local shan1 =self:getObjNode("main","shan1") 
    shan1:playAction("ui_main_far_night_bg_05_1_night")
    
    local shan2 =self:getObjNode("main","shan2") 
    shan2:playAction("ui_main_far_night_bg_05_2_night")
    
    local shan3 =self:getObjNode("main","shan3") 
    shan3:playAction("ui_main_far_night_bg_05_3_night")
    

    local shan4 =self:getObjNode("main","shan4") 
    if(shan4)then
        shan4:playAction("ui_main_far_night_bg_06_1_night")
    end

    local boss =self:getObjNode("main","boss") 
    boss:playAction("ui_main_bg_boss1_night")
    
    
    local light =self:getObjNode("main","kuafulight1") 
    if(light)then
        light:playAction("ui_main_bg_kuafulight_night")
    end
    
    
    local light =self:getObjNode("main","kuafulight2") 
    if(light)then
        light:playAction("ui_main_bg_kuafulight_night")
    end
    
    for i=1, 2 do
        local tree =self:getObjNode("main","lantree"..i) 
        tree:playAction("ui_main_far_night_bg_04_1_night") 
    end
     
    for i=3, 7 do
        local tree =self:getObjNode("main","lantree"..i) 
        if(tree)then
            tree:playAction("ui_main_far_night_bg_04_2_night")  
        end
    end
    
    local light=self:getObjNode("main","bglight") 
    if(light)then
        light:setVisible(false)
    end
    self:changeShop()

    local light=self:getObjNode("main","bglight") 
    if(light)then
        light:setVisible(false)
    end
    local redTree=self:getObjNode("main","red_tree") 
    redTree:replaceBoneWithNode({"Layer 2"},cc.Node:create()) 
    redTree:replaceBoneWithNode({"Layer 3"},cc.Node:create()) 
    return true
end


function Main3D:changeMoring()
    if(self.isNight==false)then
        return false
    end
    self.isNight=false
    loadFlaXml("ui_main")
    local cloud =self:getObjNode("main","cloud") 
    cloud:playAction("ui_main_cloud3")

    local bg =self:getObjById("ui_main_bg") 
    bg:playAction("ui_main_bg_bg")

    local lan =self:getObjNode("main","lan") 
    lan:playAction("ui_main_bg_lan")
    
    local tower=self:getObjNode("main","tower") 
    self:changeTexture(tower,"c3b/mota.png")  

    local boss =self:getObjNode("main","boss") 
    boss:playAction("ui_main_bg_boss1")

    local shan1 =self:getObjNode("main","shan1") 
    shan1:playAction("ui_main_far_bg_05_1")

    local shan2 =self:getObjNode("main","shan2") 
    shan2:playAction("ui_main_far_bg_05_2")

    local shan3 =self:getObjNode("main","shan3") 
    shan3:playAction("ui_main_far_bg_05_3")

    local shan4 =self:getObjNode("main","shan4") 
    if(shan4)then
        shan4:playAction("ui_main_far_bg_06_1")
    end
    

    local light =self:getObjNode("main","kuafulight1") 
    if(light)then
        light:playAction("ui_main_bg_kuafulight")
    end


    local light =self:getObjNode("main","kuafulight2") 
    if(light)then
        light:playAction("ui_main_bg_kuafulight")
    end
    
    for i=1, 2 do
        local tree =self:getObjNode("main","lantree"..i) 
        tree:playAction("ui_main_far_bg_04_1")  
    end

    for i=3, 7 do
        local tree =self:getObjNode("main","lantree"..i) 
        if(tree)then
            tree:playAction("ui_main_far_bg_04_2") 
        end
    end

    local light=self:getObjNode("main","bglight") 
    if(light)then
        light:setVisible(true)
    end
    

    local redTree=self:getObjNode("main","red_tree")  
    redTree.curAction=""
    redTree:playAction("ui_main_bg_tree")

    self:changeShop()

    return true 
end

function Main3D:changeShop()
    local shop=self:getObjNode("main","shop") 
    if (Data.limit_etime and Data.limit_etime>0) then
        loadFlaXml("ui_main_2")
        if (Data.limit_stype == 2) then
            shop:playAction("ui_main_bg_jianshan")
        elseif (Data.limit_stype == 3) then
            shop:playAction("ui_main_bg_heishi")
        end
    else
        loadFlaXml("ui_main")
        shop:playAction("ui_main_bg_shop")
    end
end

function Main3D:changeStandPos(pos,cardid,name,weaponLv,awakeLv,halo)
    local node =self:getObjNode("main","standPos"..pos) 
    local effectNode=self:getObjNode("main","standpost1_1")
    if(pos==1 and effectNode)then
         effectNode:setVisible(false)
    end 
    if(name==nil)then
        name=""
    end
    if(cardid==nil or cardid==0)then 
        node:removeAllChildren()
        return
    end  
    cardid=cardid%100000
    if(node.cardid==cardid and node.weaponLv==weaponLv and node.awakeLv==awakeLv and node.halo==halo)then
        return
    end
    node.cardid=cardid
    node.weaponLv=weaponLv
    node.awakeLv=awakeLv  
    node.halo=halo 
    local fla = gCreateRoleFla(cardid, node,1.0,false,"r"..cardid.."_wait",weaponLv,awakeLv,halo);
    if(fla)then
        if(fla.halo)then
            fla.halo:setDepth2D(true)
            fla.halo:setCameraMask(cc.CameraFlag.USER1,true) 
        end
        fla:setDepth2D(true)
        fla:setCameraMask(cc.CameraFlag.USER1,true) 
    end

    local billboard=cc.BillBoard:create()
    billboard:setMode(1)  
    local bg=cc.Sprite:create("images/ui_public1/name_di_y.png")
    bg:setPositionY(250)
    local  label= cc.Label:create();
    local fontSize=34  
    bg:setScale(1.2)
    if(pos==2)then
        bg:setScale(1.5)
        fontSize = 40 
        if(fla)then
            fla:setScaleX(-1)
        end 
    end
    if(pos==1 and effectNode)then
        effectNode:setVisible(true)
    end
    label:setPositionY(250)
    label:setSystemFontSize(fontSize) 
    label:setString(name) 
    label:setColor(cc.c3b(0,0,0));
    --label:setDepth2D(true)  
    billboard:addChild(bg) 
    billboard:addChild(label)
    billboard:setCameraMask(cc.CameraFlag.USER1,true) 
    node:addChild(billboard)
   
end

function Main3D:setMailVisible(value)
    if(self.bird==nil)then
        return
    end

    local mesh=self.bird:getMeshByName("xinfen")
    if(mesh)then
        mesh:setVisible(value)
    end
end

function Main3D:flyIn()
    local pos={
        {-558,-79 , 2741 },
        {-712 , -331,  2636},
        { -964  , -456  , 2721 },
        { -1054  , -494  , 2654 },
    }
    local temp=self.bird:getPosition3D()
    table.insert(pos,{temp.x,temp.y,temp.z})

    local rotation={
        {-3.6 , -71,28},
        { 25  ,  -31 , 0},
        {33  ,  13.1   , 1.6},
        {26  , 36  , 1.08},
    }
    local temp=self.bird:getRotation3D()
    table.insert(rotation,{temp.x,temp.y,temp.z})
    local timeScale=0.5
    local time={
        0,
        1*timeScale,
        1*timeScale,
        0.5*timeScale,
        0.9*timeScale
    }
    local actions={}
    self.bird:setPosition3D(cc.vec3(pos[1][1],pos[1][2],pos[1][3]))
    self.bird:setRotation3D(cc.vec3(rotation[1][1],rotation[1][2],rotation[1][3]))
    for i=2, table.getn(pos) do
        local moveAction=cc.MoveTo:create(time[i],cc.vec3(pos[i][1],pos[i][2],pos[i][3]))
        local rotationAction=cc.RotateTo:create(time[i],cc.vec3(rotation[i][1],rotation[i][2],rotation[i][3]))
        local spawActions={}
        table.insert(spawActions, moveAction)
        table.insert(spawActions, rotationAction)
        local spaw=cc.Spawn:create(spawActions)
        table.insert(actions,spaw)
    end

    local function callback()
        self:playWait2()
    end
    table.insert(actions,cc.CallFunc:create(callback,{}))
    local animate =self:playAction(self.bird,10,22)
    if(animate)then
        animate:setSpeed(1.2)
    end
    local sequence=cc.Sequence:create(actions)
    self.bird:stopActionByTag(1)
    sequence:setTag(1)
    self.bird:runAction(sequence)
end


function Main3D:playWait()
    local function onPlayEnd()
        if(getRand(0,100)>20)then
            self:playWait()
        else
            self:playWait2()
        end
    end
    self:playAction(self.bird,30,70,onPlayEnd)
end

function Main3D:playWait2()
    local function onPlayEnd()
        self:playWait()
    end
    self:playAction(self.bird,80,140,onPlayEnd)
end


return Main3D