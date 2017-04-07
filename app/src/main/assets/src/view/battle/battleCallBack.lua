--玩家攻击动作
function onRoleAfterActionCallBack(sender,data)
    data.targetRole:afterAction(data.attackData,data.targetData)
end


--玩家攻击中buffer
function onRoleAttackBuffCallBack(sender,data)
    data.targetRole:AttackBuffAction(data.attackData,data.targetData)
end


--玩家buffer
function onRoleBeforeActionCallBack(sender,data)
    data.targetRole:beforeAction(data.attackData,data.targetData)
end

--设置黑屏
function onSetGrayBackCallBack(sender,data)
    local  role= data.attackRole
    role.battleLayer:setGray()
    DisplayUtil.setGray(role,false)
end
--重置黑屏
function onResetGrayBackCallBack(sender,data)
    local  role= data.attackRole
    role.battleLayer:resetGray()
end

function onCooperateCallBack(sender,data)
    local  role= data.attackRole
    role.battleLayer.attackRole=role
    local touchLevel=data.touchLevel
    role.battleLayer:showCooperation(touchLevel)
end


function onRoleReliveAfterDeadCallBack(sender,data)
    local  role= data.attackRole
    role:playReliveAfterDead()
end

--卡牌开始攻击
function onRoleStartAttackCallBack(sender,data)
    local  role= data.attackRole
    role.battleLayer.attackRole=role

    if(role.battleLayer.helpRole   )then
        role.battleLayer.helpRole:setVisible(false)
    else
        role.battleLayer:resetRoleState()
    end
    role:attack(data.attackData,data.targets,data.skillAfterDead)

    if(Battle.battleType==BATTLE_TYPE_ATLAS)then
        --播放引导音乐
        if(Guide.hasPlaySkillVoice==false and
            Net.sendAtlasEnterParam.mapid==1 and
            Net.sendAtlasEnterParam.stageid==3  and
            role.curSide==1 and
            Net.sendAtlasEnterParam.type==0 )then

            local isNewStage=   Data.isNewStage(
                Net.sendAtlasEnterParam.mapid,
                Net.sendAtlasEnterParam.stageid,
                Net.sendAtlasEnterParam.type)
            if( isNewStage and  data.attackData.skillType==1)then

                Guide.hasPlaySkillVoice=true
                gPlayTeachSound("v19.wav",true);

            end
        end
    end
end

--卡牌展示死亡
function onRoleDieCallBack(sender,data)
    data.targetRole:showDie(data.attackData)
end

--卡牌展示
function onPlayerSkillShow(sender,data)
    local  role= data.attackRole
    if(role:isPet())then
        role.battleLayer:createPetShow(role)
    else
        role.battleLayer:createSkillShow(data.skill)

    end

end


function onPlayerSkillShowEnd(sender,data)
    local  role= data.attackRole
    if(Battle.battleType==BATTLE_TYPE_GUIDE  and role:isPet() )then
        local function callback()
            role.battleLayer:resetCamera(0.3)
            role.battleLayer:unSetBgBlack(0.3,role)

        end
        role:playAction(role:getAngerActionName(),callback)
        role.battleLayer:moveCameraToRole(cc.p(role.initX+100,role.initY),1.3,0.3)
        role.battleLayer:setBgBlack({role},0.3,1.0,role)
    end


end

--卡牌出手结束
function onRoleSkillActionEnd(sender,data)
    local  role= data.attackRole
    if(role.battleLayer.helpRole)then
        role.battleLayer.helpRole:moveActionByTag(0.2,cc.p(role.battleLayer.helpRole.initX,role.battleLayer.helpRole.initY))
        onRoleMoveBack(role.battleLayer.attackRole,0.2)
        role.battleLayer.helpRole:setVisible(true)
        role.battleLayer.helpRole=nil
        role.battleLayer:getNode("cover_cotainer"):removeAllChildren()
        role.battleLayer:resetRoleState()
    end
    if(role.battleLayer:isFirstBattle()==false)then
        role.battleLayer:getNode("ui_panel"):setVisible(true)
    end

    role.battleLayer:getNode("touch_mode"):setVisible(false)
end


--卡牌出手结束
function onRoleActionEnd(sender,data)
    local  role= data.attackRole
    local attackData= data.attackData

    if(attackData.skillType==1) then
        role.bloodNode:resetBlue(true)
    end
    if( attackData.rageAdd) then
        local  role= data.attackRole
        role:addRage(attackData.rageAdd)
    end
    
    if(data.skillAfterDead)then
        role:playDie()
        role.isDead=true
        role.bloodNode:setVisible(false)
        role.shadow:setVisible(false)
    end
end

--卡牌移动近身
function onRoleMoveCallBack(sender,data)
    local  role= data.attackRole
    local pos=clone(data.targetPos)
    if(role.curSide==1)then
        pos.x=pos.x-data.dis
    else
        pos.x=pos.x+data.dis
    end
    role:setLocalZOrder(1000)

    local function callback()
        role.shadow:setVisible(true)
    end
    local callFunc=cc.CallFunc:create(callback)
    role:moveActionByTag( data._moveTime,pos,callFunc,2)
    role.shadow:setVisible(false)
end

local function coverRolesWithBlack(targets,role,alpha)

    if(role.battleLayer.helpRole   )then
        return
    end
    local roles=clone(targets)
    table.insert(roles,role)
    role.battleLayer:setBgBlack(roles,0.3,0.7*alpha,role)
    role:setLocalZOrder(300)
end
--卡牌移动到屏幕中间
function onRoleMoveCenterCallBack(sender,data)
    local  role= data.attackRole
    local posX,posY=role.battleLayer:getNode("bg_container"):getPosition()

    if(role.curSide==1)then
        posX=posX-300
    else
        posX=posX+300
    end

    coverRolesWithBlack(data.targets,role,data.alpha)


    local function callback()
        role.shadow:setVisible(true)
    end


    local callFunc=cc.CallFunc:create(callback)
    role:moveActionByTag(data._moveTime,cc.p(posX,posY-100),callFunc,2)
    role.shadow:setVisible(false)

end




--卡牌移动到屏幕中间
function onRoleMoveOtherCenterCallBack(sender,data)
    local  role= data.attackRole
    local posX,posY=role.battleLayer:getNode("bg_container"):getPosition()

    if(role.curSide==1)then
        posX=posX+300
    else
        posX=posX-300
    end

    role:setLocalZOrder(300)

    local function callback()
    end
    local callFunc=cc.CallFunc:create(callback)
    role:moveActionByTag( data._moveTime,cc.p(posX,posY-100),callFunc,2)

end


function onRoleMoveScreenCenterCallBack(sender,data)
    local  role= data.attackRole
    local posX,posY=role.battleLayer:getNode("bg_container"):getPosition()
    local targetX,targetY=data.targetRole:getPosition()
    role:setLocalZOrder(300)

    local function callback()
    end
    local callFunc=cc.CallFunc:create(callback)
    role:moveActionByTag(  data._moveTime,cc.p(posX,targetY),callFunc,2)

end




function onRoleMoveRawCallBack(sender,data)
    local  role= data.attackRole
    local posX,posY=role.battleLayer:getNode("bg_container"):getPosition()
    local targetX,targetY=data.targetRole:getPosition()
    if(role.curSide==1)then
        posX=posX-300
    else
        posX=posX+300
    end
    coverRolesWithBlack(data.targets,role,1)

    local function callback()
    end
    local callFunc=cc.CallFunc:create(callback)
    role:moveActionByTag( data._moveTime,cc.p(posX,targetY),callFunc )


end

function onRoleMoveBack(role,moveTime,isIgoreMove)
    role.battleLayer:unSetBgBlack(0.2,role)
    if(isIgoreMove~=true)then
        role:moveActionByTag(moveTime ,cc.p(role.initX,role.initY))
    end
    role.scaleAdd=1
    role:resetScale()
    role:removeBufferEffect(EFFECT_ATTACK_HOT)
end

--卡牌移动回原位
function onRoleMoveBackCallBack(sender,data)
    local role= data.attackRole
    if(role.curAttackData~=data.attackData)then
        onRoleMoveBack(role,data._moveTime,true)
        return
    end

    onRoleMoveBack(role,data._moveTime)

end

--卡牌执行普通攻击事件
function onRoleAttackCallBack(sender,data)
    if( data.targetData.response==RESPONSE_TYPE_DODGE)then
        data.targetRole:attackedDodge()
    else

        data.targetRole:attacked( data.effectData,data.targetData,data.attackRole,data)
    end
end



--卡牌执行普通攻击事件
function onRoleAttackAfterCallBack(sender,data)
    if( data.targetData.response==RESPONSE_TYPE_DODGE)then
        data.targetRole:attackedDodge()
    else

        data.targetRole:attacked( data.effectData,data.targetData,data.attackRole,data,false)
    end
end



--卡牌执行回血攻击事件
function onRoleAttackRecoveryCallBack(send,data)
    data.targetRole:attackedRecovery( data.effectData,data.targetData,data.attackRole,data)
end

--卡牌执行反伤攻击事件
function onRoleAttackReboundDamageCallBack(send,data)
    data.targetRole:attackedReboundDamage( data.effectData,data.targetData,data.attackRole,data)
end

function onPlayChangeStatusCallBack(send,data)
    data.targetRole:playChange(data.cardid) 
    createSkillEffect(data.targetRole,"s061_d")
end


--卡牌执行免疫攻击事件
function onRoleAttackImmuneCallBack(send,data)
    data.targetRole:attackedImmune(data.targetData)

end

function onRoleAttackSuckCallBack(send,data)
    data.targetRole:attackedSuck(data.targetData)

end

function onRoleAttackSpiritChainCallBack(send,data)
    data.targetRole:attackedSpiritChain(data.targetData)

end


function onRoleAttackRemoveBuffCallBack(send,data)
    if(data.targetData.effectList==nil)then
        return
    end
    data.targetRole:addBufferEffect("clearbuff")
    for key, var in pairs(data.targetData.effectList) do 
        if(var.type ==EFFECT_TYPE_IMMNUE_REMOVE)then  
            data.targetRole:showRemoveBuff(RESPONSE_TYPE_IMMUNE_REMOVE)
        elseif(var.type==EFFECT_TYPE_SHIELD_REMOVE)then
            data.targetRole:showRemoveBuff(RESPONSE_TYPE_SHIELD_REMOVE)
        elseif(var.type==EFFECT_TYPE_HURT_DOWN_REMOVE)then
            data.targetRole:removeBufferEffect(EFFECT_REDUCE_HURT)
          
        elseif(var.type==EFFECT_TYPE_STUN_REMOVE)then   
            data.targetRole:showRemoveBuff(RESPONSE_TYPE_STUN_REMOVE)
        elseif(var.type==EFFECT_TYPE_LOCK_REMOVE)then  
            data.targetRole:showRemoveBuff(RESPONSE_TYPE_LOCK_REMOVE)
        elseif(var.type==EFFECT_TYPE_REDUCE_HP_REMOVE)then 
            data.targetRole:showRemoveBuff(RESPONSE_TYPE_REDUCE_HP_REMOVE)
         elseif(var.type==EFFECT_TYPE_REDUCE_FROST_REMOVE)then 
                data.targetRole:showRemoveBuff(RESPONSE_TYPE_FROST_REMOVE)
         elseif(var.type==EFFECT_TYPE_REDUCE_FROZEN_REMOVE)then 
                data.targetRole:showRemoveBuff(RESPONSE_TYPE_FROZEN_REMOVE)
        end
    end 
end

--卡牌执行减伤攻击事件
function onRoleAttackResistCallBack(send,data)
    data.targetRole:attackedResist()

end

--卡牌执行加盾攻击事件
function onRoleAttackShieldCallBack(send,data)
    data.targetRole:attackedShield()
end




function onRoleAttackUpCallBack(sender,data)

    data.targetRole:showAttackUp(data.backDis,data.upDis)
end

function onRoleRemoveHpCallBack(sender,data)
    local temp={}
    temp.attackIdx=1
    temp.attackMaxNum=1
    temp.isAttackDown=false
    data.targetRole:attacked(data.effectData,data.targetData,nil ,temp)
end

function onRoleRecoverFriendHpCallBack(sender,data)
    local temp={}
    temp.attackIdx=1
    temp.attackMaxNum=1
    temp.isAttackDown=false
    data.targetRole:attackedRecovery(data.effectData,data.targetData,nil ,temp)
end

function onRoleRemoveBuffCallBack(sender,data)
    local effectData=nil
    if(data.targetData and data.targetData.effectList[1])then
        effectData=data.targetData.effectList[1] 
    end
    data.targetRole:showRemoveBuff(data.response,effectData,data.data)
end

function onRoleAddBuffCallBack(sender,data)
    if data.response == RESPONSE_TYPE_RECOVERY then
         data.targetRole:attackedRecovery(data.targetData.effectList[1],nil)
    else
        data.targetRole:afterAction(data.attackData,data.targetData )
    end
    
end





function onPlayStoryCallBack(sender,data)
    if(Battle.win==1 or data.needPlay or  Battle.battleType==BATTLE_TYPE_GUIDE )then
        data.battleLayer:setPause()
        local function callback()
            data.battleLayer:setPlay()
        end
        Story.showStory(toint(data.storyId),callback)
        data.battleLayer:resetRoleState()
    end
end

function onPlayRoleStoryCallBack(sender,data)
    local story=Story.getStory( toint(data.storyId))
    local self=data.battleLayer
    if(story and  story.talks and story.talks[1] )then
        local talk=story.talks[1]
        local cardid= toint( talk.headid)
        local side=toint( talk.headside)
        local role=self:getRoleById(side+1,cardid)
        local talkWords=Story.getStoryWord(talk.dialogkey)
        
        if(role)then
            role:talk(talkWords)
        end 

        if(talk.dialogsound and talk.dialogsound~="")then
            gPlayTeachSound(talk.dialogsound,true);
        end
        
    end
end




function onPlayAppearCallBack(sender,data)

    for key, pos in pairs(data.pos) do
        data.battleLayer:appearRole(data.side,toint(pos))
    end
end

function onPlayHurtActionCallBack(sender,data)

    local role= data.battleLayer:getTargetRole(data.activeSide,data.activePosition)
    if(role)then
        --用来播放受伤状态
        role:playActions({role:getHurtStateActionName(),role:getHurtWaitStateActionName()})
    end

end

function onPlayChangeCallBack(sender,data)
    local role= data.battleLayer:getTargetRole(data.activeSide,data.activePosition)
    if(role)then
        if(data.isBoss)then
            role:playChangeBoss(data.targetPosition)
        else
            role:playChange(data.targetPosition)
        end
        role.battleLayer:resetRoleState()
    end

end

function onPlayChangeHeroCallBack(sender,data)
    if( data.targetRole)then 
        data.targetRole:playChangeToEnemy(data.copyCardId,data.weaponLv,data.awakeLv)
    end
end

function onPlayPrepareEscapeCallBack(sender,data)
    local role= data.battleLayer:getTargetRole(data.activeSide,data.activePosition)
    if(role)then 
        role:resetScapeRound(data.skillId)
    end

end

function onPlayEscapeCallBack(sender,data)
    local role= data.battleLayer:getTargetRole(data.activeSide,data.activePosition)
    if(role)then 
        role:escape()
    end

end

function onRoleAttackScrollCallBack(sender,data)

    data.targetRole:showAttackScroll(data.backDis,data.upDis)
end


function onPlaySpiritChainCallBack(sender,data)
    if( data.targetRole)then
        local function callback() 
            data.targetRole.curAction=""
            data.targetRole:playAction(data.targetRole:getWaitActionName())
        end
        data.targetRole:playAction( data.targetRole.curXmlName.."_attack_c",callback ) 
        createSkillEffect(data.targetRole,"s061_c")
    end
end


function onPlaySpiritChainGetCallBack(sender,data)
    if( data.targetRole)then 
        data.targetRole:addBufferEffect(RESPONSE_TYPE_SPIRIT_CHAIN)
    end
end

function onPlayRadiationCallBack(sender,data)
    if( data.targetRole)then 
        data.targetRole:addBufferEffect( RESPONSE_TYPE_RADIATION)
    end
end


function onRoleStandUpCallBack(sender,data)
    if( data.targetRole.curAttackData==data.attackData)then
        data.targetRole:moveActionByTag(data._moveTime,cc.p( data.targetRole.initX, data.targetRole.initY))
    end


    local function callback()
        data.targetRole.curAction=""
        data.targetRole:playAction( data.targetRole:getWaitActionName())
    end

    if( data.targetRole:isUp()) then --如果之前被击浮空，现在落地
        data.targetRole:playAction(data.targetRole:getUpStandUpActionName(),callback)
    else
        data.targetRole:playAction( data.targetRole:getDownStandUpActionName(),callback)

    end
end



function onRoleSetSpeedCallBack(sender,data)
    data.attackRole.battleLayer:setSpeedScale(data.speedScale)
end

function onRoleResetSpeedCallBack(sender,data)
    data.attackRole.battleLayer:setSpeedScale(1)
end


function onRoleAttackDownCallBack(sender,data)
    data.targetRole.curAttackData=data.attackData
    if( data.targetRole:isUp()) then
        data.targetRole:showAttackDown(data.backDis)
    else
        data.targetRole:showAttackBackDown(data.backDis)
    end

end

function onRoleAttackDownAndStandUpCallBack(sender,data)
    data.targetRole.curAttackData=data.attackData

    local function callback()
        onRoleStandUpCallBack(sender,data)
    end
    if( data.targetRole:isUp()) then
        data.targetRole:showAttackDown(data.backDis,callback)
    else
        data.targetRole:showAttackBackDown(data.backDis,callback)
    end

end



function getBonePosition(attackRole,boneName)
    local startX,startY= attackRole:getPosition()
    local shootPos=attackRole.display:getBone(boneName)
    local hasShootPos =false
    if shootPos then
        local box=  shootPos:getDisplayManager():getBoundingBox()
        startY=startY+box.y
        if( attackRole.curSide==1) then
            startX=startX+box.x
        else
            startX=startX-box.x
        end
        hasShootPos=true
    end
    return startX,startY,hasShootPos

end
--创建设计特效
function createShootSkillEffect(attackRole,targetRole,moveTime,bulletName,shootH,delayTime,ignoreRotation,removeDelay,callback,ease)
    local function onHitRole(send,data)
        data.effect:removeFromParent()
        if(callback)then
            callback()
        end
    end
    local flashAni= nil
    local skillEffect =nil;
    if(string.find(bulletName,".plist") ) then
        skillEffect =  cc.ParticleSystemQuad:create(bulletName)
    else

        skillEffect=cc.Node:create()
        flashAni= FlashAni.new()
        if( attackRole.curSide==2) then
            flashAni:setScaleX(-1)
        end
        skillEffect:addChild(flashAni)
        flashAni:playAction(bulletName)
    end


    if(attackRole.battleLayer ==nil) then
        return
    end

    local effectContainer=attackRole.battleLayer
    if(tolua.type(effectContainer)=="BattleLayer" ) then
        effectContainer= attackRole.battleLayer:getNode("effect_container")
    end
    effectContainer:addChild(skillEffect,500)

    local targetPosX=targetRole:getPositionX()
    local targetPosY=targetRole:getPositionY()

    local startX,startY= getBonePosition(attackRole,"shoot_pos")
    if(attackRole.lastShoot==1)then
        attackRole.lastShoot=2
    else
        local tempX,tempY,tempHas= getBonePosition(attackRole,"shoot_pos2")
        attackRole.lastShoot=1
        if(tempHas)then
            startX=tempX
            startY=tempY
        end
    
    end
    skillEffect:setPosition(cc.p(startX,startY))

    if(delayTime==nil)then
        delayTime=0
    end
    if(shootH==0)then
         local moveTo=nil
        if(ease==1)then 
            moveTo= cc.EaseIn:create(cc.MoveTo:create(moveTime, cc.p(targetPosX, targetPosY)),4.0)
        else
            moveTo= cc.EaseOut:create(cc.MoveTo:create(moveTime, cc.p(targetPosX, targetPosY)),2.0)
        
        end
        local callFunc=cc.CallFunc:create(onHitRole,{effect=skillEffect,role=role,data=data,key=key})
        skillEffect:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),moveTo,callFunc) )
        return skillEffect,flashAni
    end

    local dh = (targetPosX-startX)/4;
    if( attackRole.curSide==1) then
        dh = dh*shootH
    else
        dh = dh*-1*shootH
    end

    local bezier = {
        cc.p(startX, startY),
        cc.p(startX + (targetPosX-startX)/2,startY + (targetPosY-startY)/2 + dh),
        cc.p(targetPosX, targetPosY),
    }



    local lastY=math.abs(skillEffect:getPositionY()-3000)
    local lastX=skillEffect:getPositionX()

    local function updateRotation()

        local curX=skillEffect:getPositionX()
        local curY=math.abs(skillEffect:getPositionY()-3000)
        local rotation=180

        local distance=getDistance(curX, curY , lastX, lastY)
        if(distance==0)then
            return;
        end

        if (curY > lastY)then
            local _local4 = (curY - lastY)*1.0 /distance
            local temp=math.asin(_local4)
            local  _local5 = (math.asin(_local4) * 180) / math.pi
            if (curX> lastX)then
                skillEffect:setRotation( 90 + _local5  + rotation)
            else
                skillEffect:setRotation(  -90- _local5 +rotation)
            end
        else
            local temp=math.abs(curX- lastX)
            local _local6 = math.abs(curX- lastX) / distance
            local _local7 = ((math.acos(_local6) * 180) /  math.pi)
            if (curX> lastX)then
                skillEffect:setRotation( 90 - _local7  + rotation);
            else
                skillEffect:setRotation(  -90+ _local7 + rotation);
            end
        end
        lastY=math.abs(skillEffect:getPositionY()-3000)
        lastX=skillEffect:getPositionX()

    end
    if(ignoreRotation==nil)then
        skillEffect:scheduleUpdateWithPriorityLua(updateRotation,1)
        skillEffect:setRotation(180)
        skillEffect:setPositionX(skillEffect:getPositionX()+2)
        updateRotation()
    end

    if(removeDelay==nil)then
        removeDelay=0
    end

    local moveTo=cc.EaseOut:create(cc.BezierTo:create(moveTime, bezier),2.0)
    local callFunc=cc.CallFunc:create(onHitRole,{effect=skillEffect,role=role,data=data,key=key})
    skillEffect:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),moveTo,cc.DelayTime:create(removeDelay),callFunc) )
    return skillEffect,flashAni

end





--创建设计特效
function createSkillEffect(attackRole,skillName,_onPlayEnd,weaponLv,awakeLv,cardid)
    local skillEffect =nil;
    

    if(gIsInReview())then
        return cc.Node:create();
    end

    local function onPlayEnd(send,data)
        skillEffect:removeFromParent()
        if(_onPlayEnd~=nil)then
            _onPlayEnd()
        end
    end

    if(string.find(skillName,".plist") ) then
        skillEffect =  cc.ParticleSystemQuad:create(skillName)
    else

        local maxWeapon= nil
        local maxAwake= nil 
        maxWeapon,maxAwake= gGetMaxWeaponAwakeId(cardid)
        if maxAwake == nil then
            maxAwake = gGetMaxPetAwakeId(cardid)
            awakeLv = Pet.getPetAwakeLv(cardid)
        end
        
        skillEffect=FlashAni.new() 
        if(weaponLv)then
            skillEffect:setWeaponId(weaponLv,maxWeapon)
        end

        if(awakeLv)then
            if gGetMaxPetAwakeId(cardid) ~= nil then
                skillEffect:setPetSkinId(awakeLv)
            else
                skillEffect:setSkinId(awakeLv,maxAwake)
            end
        end
        skillEffect:playAction(skillName,onPlayEnd)
    end

    skillEffect:setScale(attackRole:roleScale())




    if(attackRole.battleLayer ==nil) then
        return
    end

    local effectContainer=attackRole.battleLayer
    if(type(effectContainer)=="BattleLayer" ) then
        effectContainer= attackRole.battleLayer:getNode("effect_container")
    end
    attackRole.skillNode:addChild(skillEffect,500)
    --skillEffect:setPosition(attackRole:getPosition())
    return skillEffect

end

function onRoleShootCallBack(sender,data)
    local  role= data.attackRole
    createShootSkillEffect(role,data.targetRole,data._moveTime,data._bullet,data._shootH)

end


function onRoleShootDelayCallBack(sender,data)
    local  role= data.attackRole
    createShootSkillEffect(role,data.targetRole,data._moveTime,data._bullet,data._shootH,nil,nil,nil,nil,1)

end


function onRolePlayAttackSkillCallBack(send,data)
    local role=data.targetRole
    local need,temp=gIsAttackSkillNeedWeapon(data._skill)
    if( need)then 
        if(temp==1)then
            createSkillEffect(role,data._skill,nil,data.attackRole.curWeaponLv,data.attackRole.curAwakeLv,data.attackRole.curCardid) 
        else
            createSkillEffect(role,data._skill,nil,data.attackRole.cooperateWeaponLv,data.attackRole.cooperateAwakeLv,data.attackRole.cooperateCardid)
        end 
    else
        createSkillEffect(role,data._skill)
    end
    
    if(gIsInAttackToTop(data._skill))then
        role.initZAdd=20
        role:setLocalZOrder(400)
    end
end





function onRoleRandShootCallBack(sender,data)
    local  role= data.attackRole
    local targetRole=data.targetRole 
    local ignoreRotation=1
    if(data.rotation==1)then
        ignoreRotation=nil
    end
    local function callback()
        targetRole:showHited(data.hitEffect)
    end
    local effect,flashAni= createShootSkillEffect(
        role,
        targetRole,
        (data.move_time-data.param2)/FLASH_FRAME,
        data.effect,
        data.param1+getRand(-data.param4*10,data.param4*10)/10,
        data.param2/FLASH_FRAME,
        ignoreRotation,
        data.param3/FLASH_FRAME,
        callback
    )
    if(flashAni and data.shadow_num)then
        flashAni:createShadow(data.shadow_num,1)
    end
    role.battleLayer:addHit()
    effect:setScaleX(math.abs(role:getScaleX()))
    effect:setScaleY(role:getScaleY())
    targetRole:reduceLife(data.hp )
  
end





function onRolePlayAttackStandSkillCallBack(send,data)
    local role=data.targetRole
    local effect=nil
    if(data.attackRole~=role)then
        effect= createSkillEffect(role,data._skill)
    elseif(data.includeSelf and data.includeSelf==true)then
        effect= createSkillEffect(role,data._skill)
    end

    if(effect)then
        effect:retain()
        effect:removeFromParent()
        role:getParent():addChild(effect)
        effect:release()
        effect:setPosition(cc.p(role.initX,role.initY))
        effect:setLocalZOrder(role:getLocalZOrder())
    end
end


function onRolePlaySkillCallBack(sender,data)
    local  role= data.attackRole
     
    local needWakeup=gIsAttackSkillNeedAwake(data._skill)
    if(needWakeup)then
        createSkillEffect(role,data._skill,nil,role.curWeaponLv,role.curAwakeLv,role.curCardid)
    else
        createSkillEffect(role,data._skill)
    end

end


function onRolePlayCooperateSkillCallBack(sender,data)
    local  role= data.attackRole
    createSkillEffect(role,"battle_cooperate_start")
    role:addBufferEffect(EFFECT_ATTACK_HOT)
    local cooperateRole=role.battleLayer:getRoleById(role.curSide,role.cooperateCardid)
    if(cooperateRole)then
        cooperateRole:setVisible(false)
    end
end




function onRolePlayStretchSkill2CallBack(sender,data)
    local targetRole=data.targetRole
    local  role= data.attackRole
    local stretch=toint(string.sub( data._skill,1,3))
    local skillName=string.sub( data._skill,5,string.len(data._skill))



    local skillEffect= createSkillEffect(role,skillName)
    local shootPos=role.display:getBone( "shoot_pos")
    if(shootPos)then
        local box=  shootPos:getDisplayManager():getBoundingBox()
        skillEffect:setPosition(box.x,box.y)
    end
    local dis=  math.abs(role:getPositionX()-targetRole.initX+skillEffect:getPositionX() )/role:roleScale()
    local scaleX=dis/stretch
    skillEffect:setScale(scaleX)

end

function onRolePlayStretchSkillCallBack(sender,data)
    local targetRole=data.targetRole
    local  role= data.attackRole
    local stretch=toint(string.sub( data._skill,1,3))
    local skillName=string.sub( data._skill,5,string.len(data._skill))



    local skillEffect= createSkillEffect(role,skillName,onPlayEnd)
    local node=cc.Node:create()
    skillEffect:addChild(node)
    local function updateShootPos()
        local shootPos=role.display:getBone( "shoot_pos")
        if(shootPos)then
            local box=  shootPos:getDisplayManager():getBoundingBox()
            box.x=box.x*role:roleScale()
            box.y=box.y*role:roleScale()
            skillEffect:setPosition(box.x,box.y)

            local px=0
            local py=box.y
            if(role.curSide==1)then
                px=box.x
            else
                px=-box.x
            end


            local dis= getDistance(role.initX+px,role.initY+py,targetRole.initX,targetRole.initY)
            local scaleX=dis/stretch
            skillEffect:setScale(scaleX)


            local disX=math.abs(role.initX+px-targetRole.initX)
            local disY=role.initY+py-targetRole.initY-30
            local rotaion=math.deg(math.atan( disY/disX))
            skillEffect:setRotation( rotaion  )
        end

    end
    node:scheduleUpdateWithPriorityLua(updateShootPos,1)

end


function onRolePlayCoverCallBack(sender,data)
    local  role= data.attackRole
    local roles=clone(data.targets)
    table.insert(roles,role)
    role.battleLayer:createCover(data._cover,roles)

end

function onRolePlaySideCoverCallBack(sender,data)
    local  role= data.attackRole
    coverEffect=role.battleLayer:createCover(data._cover,{role})
    local winSize=cc.Director:getInstance():getWinSize()
    if(role.curSide==1)then
        coverEffect:setPositionX(coverEffect:getPositionX()-winSize.width/4)
    else
        coverEffect:setPositionX(coverEffect:getPositionX()+winSize.width/4)
    end
end


function onRolePlayRawCoverCallBack(sender,data)
    local  role= data.attackRole
    local roles=clone(data.targetRoles)
    table.insert(roles,role)
    local coverEffect=role.battleLayer:createCover(data._cover,roles)
    role.battleLayer:setCoverContainerTop()
    local winSize=cc.Director:getInstance():getWinSize()
    if(role.curSide==2)then
        coverEffect:setScaleX(-1*role:roleScale())
    else
        coverEffect:setScaleX(role:roleScale())
    end
    coverEffect:setScaleY(role:roleScale())
    local  targetRole= data.targetRole
    local targetPos= data.targetRole:convertToWorldSpaceAR(cc.p(0,0))
    local pos= role.battleLayer:getNode("cover_cotainer"):convertToNodeSpace(targetPos)
    coverEffect:setPositionY(pos.y)


end


function onRolePlayFaceCoverCallBack(sender,data)
    local  role= data.attackRole
    coverEffect=role.battleLayer:createCover(data._cover,{role})
    if(role.curSide==2)then
        coverEffect:setScaleX(-1)
    end
end

function onMoveCamaraCallBack(sender,data)
    local moveTime=data._moveTime
    if(moveTime==nil)then
        moveTime=0.2
    end
    local  attackRole= data.attackRole
    local  targetRole= data.targetRole
    local layer=attackRole.battleLayer
    layer:moveCameraToRole(cc.p(targetRole.initX,targetRole.initY),1.2,moveTime,attackRole)
    layer:setBgBlack({attackRole,targetRole},moveTime1,1.0,attackRole)
end


function onShakeCallBack(sender,data)

    local shakeDir=data.shakeDir
    local shakeTime=data.shakeTime
    local shakeOffset=data.shakeOffset
    local  attackRole= data.attackRole
    local layer=attackRole.battleLayer


    layer:shake(shakeTime,shakeOffset,shakeDir)
end

function onMoveCamaraBackCallBack(sender,data)
    local  attackRole= data.attackRole
    local layer=attackRole.battleLayer
    local moveTime=data._moveTime
    if(moveTime==nil)then
        moveTime=0.2
    end
    local ret=layer:resetCamera(moveTime,attackRole)
    if(ret)then
        layer:resetRoleZOrder()
    end
    layer:unSetBgBlack(moveTime,attackRole)

end

function onRoleWaitCallBack(sender,data)
    data.targetRole:playAction(data.targetRole:getWaitActionName())
end



