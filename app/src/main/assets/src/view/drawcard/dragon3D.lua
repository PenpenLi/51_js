local Dragon3D=class("Dragon3D",Scene3D)

function Dragon3D:ctor()

end

function Dragon3D:inited()
    self.camera:setTag(2)
    self.camera:setCameraFlag(cc.CameraFlag.USER1)
    self:setCameraMask(cc.CameraFlag.USER1,true)


    local dragon=self:getObjById("dragon") 
    self.dragonBone=dragon:getAttachNode("Bone03")

    local winSize = cc.Director:getInstance():getWinSize()
    local function updateShopTime()
        if( self.fireEffect)then
            local mat =cc.mat4.new( self.dragonBone:getNodeToWorldTransform())
            self.fireEffect:setPosition3D(cc.vec3(mat[13]-winSize.width/2,mat[14]-winSize.height/2-20,-100))
            
        end
    end

    self:scheduleUpdateWithPriorityLua(updateShopTime,1)
   
end

function Dragon3D:changeSkin(type)
    local dragon=self:getObjById("dragon")
    self:changeTexture(dragon,"c3b/"..(type+2)..".png")  
end

function Dragon3D:playWait()
    local function onPlayEnd()
        if(getRand(0,100)>30)then
            self:playWait()
        else
            self:playWait2()
        end
    end
    local dragon=self:getObjById("dragon")
    self:playAction(dragon,0,50,onPlayEnd)
end

function Dragon3D:playWait2()
    local function onPlayEnd()
        self:playWait()
    end
    local dragon=self:getObjById("dragon")
    self:playAction(dragon,230,330,onPlayEnd)
end


function Dragon3D:playBuyOne()
    local function onPlayEnd()
        self:playWait()
    end
    local dragon=self:getObjById("dragon")
    self:playAction(dragon,60,120,onPlayEnd)

    local function startCallback()
        gPlayEffect("sound/effect/ui_dragon_3d_s.mp3")

        self.fireEffect = cc.PUParticleSystem3D:create("test_fire2.pu", "xulie_smoke01_4x4.material") 
        self.fireEffect:setScale(60)
        self:addChild(self.fireEffect)  
        self.fireEffect:startParticleSystem()
        self.fireEffect:setRotation3D( cc.vec3(140,0,0))
    end

    local function endCallback()
        self.fireEffect:removeFromParent()
        self.fireEffect=nil
    end

    self:runAction(
        cc.Sequence:create(cc.DelayTime:create(0.8),
            cc.CallFunc:create(startCallback) ,
            cc.DelayTime:create(0.7),
            cc.CallFunc:create(endCallback)
        )
    )

end




function Dragon3D:playBuyTen()
    local function onPlayEnd() 
        self:playWait()
    end
    local dragon=self:getObjById("dragon")
    self:playAction(dragon,130,220,onPlayEnd)
    


    local function startCallback()
        gPlayEffect("sound/effect/ui_dragon_3d_b.mp3")
        self.fireEffect = cc.PUParticleSystem3D:create("test_fire2.pu", "xulie_smoke01_4x4.material") 
        self.fireEffect:setScale(60)
        self.fireEffect:startParticleSystem()
        self:addChild(self.fireEffect)  
        self.fireEffect:setRotation3D( cc.vec3(130, -20,0))
        self.fireEffect:runAction(cc.RotateTo:create(1.6,  cc.vec3(130,120,0)))
    end

    local function endCallback()
        self.fireEffect:removeFromParent()
        self.fireEffect=nil
    end

    self:runAction(
        cc.Sequence:create(cc.DelayTime:create(1.2),
            cc.CallFunc:create(startCallback) ,
            cc.DelayTime:create(1.4),
            cc.CallFunc:create(endCallback)
        )
    )
end


return Dragon3D