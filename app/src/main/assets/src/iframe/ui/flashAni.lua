FLASH_FRAME=30

local FlashAni=classCacheFunc("FlashAni", function()
    return cc.Node:create()
end,{"pause","resume"})

function FlashAni:ctor()
    self:setCascadeOpacityEnabled(true)
    self.display=ccs.Armature:create()
    self:addChild(self.display)
    self.shadows={}
    self.isPause=false
    self.isFlashAni = true;
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        elseif event == "exit" then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function FlashAni:clearShadow()
    for key, var in pairs(self.shadows) do
        var:removeFromParent()
    end
    self.shadows={}
    self:unscheduleUpdate()
end
function FlashAni:setWeaponId(id,maxWeaponId)
    self.weaponId=id
    self.maxWeaponId=maxWeaponId
    if(self.display and self.display.setWeaponId)then
        self.display:setWeaponId(gParseWeaponId(id,maxWeaponId))
    end

end
function FlashAni:setSoundPlay(isPlay)
    if(self.display and self.display.setSoundPlay)then
        self.display:setSoundPlay(isPlay)
    end

end

function FlashAni:setChildWeaponId(name,id,maxWeaponId)
    if(self.display and self.display.setWeaponId)then 
        self.display:setWeaponId(name,gParseWeaponId(id,maxWeaponId))
    end

end

function FlashAni:setSkinId(id,maxSkinId)  
    self.skinId=id
    self.maxSkinId=maxSkinId
    if(self.display and self.display.setSkinId )then 
        self.display:setSkinId(gParseCardAwakeId(id,maxSkinId))
    end
end

function FlashAni:setPetSkinId(id)  
    self.skinId=id 
    if(self.display and self.display.setSkinId )then 
        self.display:setSkinId(id)
    end
end

function FlashAni:setChildSkinId(name,id,maxSkinId)
    if(self.display and self.display.setSkinId)then
        self.display:setSkinId(name,gParseCardAwakeId(id,maxSkinId))
    end

end


function FlashAni:createShadow(num,perFrame)


    local alphaMax=100
    local alphaMin=80
    self.lastShadowPos=self:convertToWorldSpace(cc.p(0,0))
    for i=1, num do
        local shadow=ccs.Armature:create()
        self:addChild(shadow,-i)
        if(self.skinId)then
            shadow:setSkinId(gParseCardAwakeId(self.skinId,self.maxSkinId)) 
        end 

        if(self.weaponId)then
            shadow:setWeaponId(gParseWeaponId(self.weaponId,self.maxWeaponId)) 
        end 
        shadow:init(self.curAction)
        shadow:getAnimation():play("stand",-1)
        shadow:setOpacity(alphaMin+(alphaMax-alphaMin)*(num-i)/num)
        table.insert(self.shadows,shadow)
        shadow.lastPos=self.lastShadowPos
    end



    self.recordFrame=0

    local function updateShadow()
        if(self.recordFrame<perFrame)then
            self.recordFrame=self.recordFrame+1
            return
        end
        self.recordFrame=0
        local curFrame=1
        if(self:getAnimation()~=nil)then
            curFrame=self:getAnimation():getCurrentFrameIndex()
        end
        local lastShadowPos=self.lastShadowPos
        for key, shadow in pairs(self.shadows) do
            local shadowFrame=curFrame-perFrame*key
            if(shadowFrame<0)then
                shadowFrame=0
            end

            shadow:setPosition(self:convertToNodeSpace(lastShadowPos))
            shadow:getAnimation():gotoAndPause(shadowFrame)
            local temp= shadow.lastPos
            shadow.lastPos=lastShadowPos
            lastShadowPos=temp
        end
        self.lastShadowPos=self:convertToWorldSpace(cc.p(0,0))
    end

    self:scheduleUpdateWithPriorityLua(updateShadow,1)
end

function FlashAni:onEnter()
    if self.delayplaytime then
        self:pause();
        self.display:pause();
        local start = function()
            self:resume();
            self.display:resume();
            if(self.startCallback)then
                self.startCallback()
            end
        end
        self:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(self.delayplaytime),
                cc.CallFunc:create(start)
                ));
    end

    if self.stopAnimation then
        self:pause();
        self.display:pause();
    end
end

function FlashAni:onExit()
    -- print("FlashAni:onExist");
    if self.replaceNode then
        self.replaceNode:release();
        self.replaceNode = nil;
        print("self.replaceNode:release");
    end
    self:clearShadow()
end


function FlashAni:stopAni()
    self.stopAnimation = true;
    self:pause();
    self.display:pause();
end

-- *  loop < 0 : use the value from MovementData get from flash design panel
-- *  loop = 0 : this animation is not loop
-- *  loop > 0 : this animation is loop
function FlashAni:play(loop)
    if(loop ==nil)then
        loop=1
    end
    self:getAnimation():play("stand",-1,loop)

    for key, shadow in pairs(self.shadows) do
        shadow:getAnimation():play("stand",-1)
    end
end

--注意:必须是循环播放，才会调用finishCallback
--注意:必须是循环播放，才会调用finishCallback
--注意:必须是循环播放，才会调用finishCallback
function FlashAni:playAction(name,finishCallback,frameCallback,loop)

    if self.maxSkinId and self.maxSkinId>=FINAL_AWAKE then
        local cardAwakelv = Data.cardAwake.lv[self.maxSkinId+2]
        if cardAwakelv==nil then
            cardAwakelv = Data.cardAwake.lv[table.getn(Data.cardAwake.lv)]
        end
        if self.skinId >= cardAwakelv then
            local index = string.find(name,"wait")
            if(index and index>0) then
                local finalAwakeWait=name.."_awake4"
                local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(finalAwakeWait)
                if(animationData)then
                    name=finalAwakeWait
                end
            end
        end

    end
    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(name)
    if(animationData==nil)then
        return
    end
    if(
        self.curAction==name and
        self.curLoop==loop and
        self.curFinishCallback==finishCallback and
        self.curFrameCallback==frameCallback
        )then
        return
    end
    self.curLoop=loop
    self.curFinishCallback=finishCallback
    self.curFrameCallback=frameCallback
    self.curAction=name

    for key, shadow in pairs(self.shadows) do
        shadow:init(self.curAction)
    end
    self.display:init(self.curAction)
    self:play(loop)

    if(gIsAdvancedColor(name ) )then
        self:setChildShaderName(Shader.FLA_COLOR_SHADER)
    end

    local function onMovementEvent(arm, eventType, movmentID)
        -- print("self.curAction = "..self.curAction);
        if(finishCallback~=nil and eventType == ccs. MovementEventType.loopComplete) then
            -- print("finishCallback");
            finishCallback(self.param,arm, eventType, movmentID)
            if self.endDel and self.endDel == true then
                -- print("removeFromParent");
                self:removeFromParent();
            end
        end
    end

    local function onFrameEvent(bone, eventType, oIdx,toIdx)
        if(frameCallback~=nil ) then
            frameCallback(self.param,bone, eventType, oIdx)
        end
        if(self.replaceBoneTable and eventType=="replace_bone")then
            self:replaceBoneWithNode(
                self.replaceBoneTable,
                self.replaceNode
            )
        end
      --[[  if(eventType and string.find(eventType,"play_sound:"))then
            local soundPath=  string.split(eventType,":")[2]
            gPlayEffect("sound/effect/"..soundPath,false)
        end]]
    end

    if(onMovementEvent)then
        self:getAnimation():setMovementEventCallFunc(onMovementEvent)
    end

    if(onFrameEvent)then
        self:getAnimation():setFrameEventCallFunc( onFrameEvent)
    end

    return self:getActionTime()
end

function FlashAni:playAct(name,endDel,loop)
    if endDel and endDel==true then
        --标记删除,loop必须是1
        loop = 1;
        local remove = function()
            self:removeFromParent();
        end
        return self:playAction(name,remove,nil,loop);
    else
        return self:playAction(name,nil,nil,loop);
    end
end

function FlashAni:playActDelay(delay,name,loop,endDel,startCallback)
    self.delayplaytime = delay;
    self.startCallback=startCallback
    self:playAct(name,endDel,loop);
    -- local callback = function()
    --     self:playAct(name,endDel,loop);
    -- end
    -- self:runAction(
    --     cc.Sequence:create(
    --         cc.DelayTime:create(delay),
    --         cc.CallFunc:create(callback)
    --     )
    -- );
end

function FlashAni:replaceBoneWithNode(boneTable,replaceNode)

    if replaceNode == nil then
        return;
    end

    -- print("FlashAni:replaceBoneWithNode");
    -- print_lua_table(boneTable);

    local armature=self
    local endBone=nil

    self.replaceBoneTable=boneTable
    if self.replaceNode == nil then
        print("xxxxxxxx11111111");
        self.replaceNode=replaceNode
        self.replaceNode:retain();
    end

    for key, boneName in pairs(boneTable) do
        print("boneName = "..boneName);
        local bone=armature:getBone( boneName)
        if(bone==nil)then
            print("xxxxxxxx222222");
            return
        end
        armature= bone:getChildArmature()
        endBone=bone
        if(armature==nil and table.getn(boneTable)~=key)then
            print("xxxxxxxx3333333");
            return
        end
    end
    if(endBone)then

        local node=nil
        local sprite = self.replaceNode;

        if sprite == nil then
            print("replace sprite is nil");
            return;
        end

        if(tolua.type(sprite)~="ccs.Armature")then
            node=cc.Node:create()
            node:addChild(sprite);
            gSetBlendFuncAll( sprite,  endBone:getBlendFunc())
        else 
            node=sprite
        end

        print("replace xxxx");

        sprite:setCascadeOpacityEnabled(true)
        node:setCascadeOpacityEnabled(true)
        self.replaceNode:release();
        endBone:addDisplay(node, 1)
        endBone:changeDisplayWithIndex(1, true)
        endBone:setIgnoreMovementBoneData(true)
        self.replaceBoneTable=nil
        self.replaceNode=nil
        self.display:update(0)
    end
end

function FlashAni:replaceBone(boneTable,nodePath)


    local sprite =nil
    if(cc.SpriteFrameCache:getInstance():getSpriteFrame(nodePath)~=nil) then
        sprite=cc.Sprite:createWithSpriteFrameName(nodePath)
    else
        sprite= cc.Sprite:create(nodePath)
    end
    self:replaceBoneWithNode(boneTable,sprite);


end

function FlashAni:setSpeedScale(speed)
    self:getAnimation():setSpeedScale(speed)
end

function FlashAni:getActionTime()
    return self:getAnimation():getRawDuration()/FLASH_FRAME
end

function FlashAni:changeBoneParent(bone,name)
    self.display:changeBoneParent(bone,name)
end

function FlashAni:setChildShaderName(name)
    self.display:setChildShaderName(name)
end

function FlashAni:setBlendFunc(blend)
    self.display:setBlendFunc(blend)
end


function FlashAni:pause() 
    self.isPause=true
    if(self._pause)then
        self:_pause()
    end
    self.display:pause()
end


function FlashAni:resume() 
    self.isPause=false
    if(self._resume)then
        self:_resume()
    end
    self.display:resume()
end


function FlashAni:setDepth2D(value)
    self.display:setDepth2D(value)
end


function FlashAni:getBone(name)
    return self.display:getBone(name)
end

function FlashAni:getAnimation()
    return self.display:getAnimation()
end

function FlashAni:getBoundingBox()
    local rect = self.display:getBoundingBox()
    local parent = self:getParent()
    if nil ~= parent then
        local worldPos = self.display:convertToWorldSpace(cc.p(rect.x, rect.y))
        local nodePos  = parent:convertToNodeSpace(worldPos)
        rect.x,rect.y = nodePos.x, nodePos.y
    end

    return rect
end

function FlashAni:playActDelayAndCallback(delay,name,loop,finishCallback,startCallback)
    self.delayplaytime = delay
    self.startCallback=startCallback
    self:playAction(name,finishCallback,nil,loop)
end

return FlashAni;