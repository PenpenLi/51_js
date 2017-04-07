

function gParseAttackDownAction(isBack,isUp,params,downIndex,downNum)
    local downTime=0
    local upTime=0
    local role=params.targetRole
    local downActions={}
    local during=0
    if(isUp) then
        downTime=20/FLASH_FRAME
        upTime= 12/FLASH_FRAME
    else
        downTime=20/FLASH_FRAME
        upTime=12/FLASH_FRAME
    end
    local isDead=params.targetData.isDead

    params._moveTime=upTime

    if(role:isBoss())then
        downTime=0.1
        upTime=0.1
    end

    if(downIndex~=downNum)then
        local downAction=cc.CallFunc:create(onRoleAttackDownAndStandUpCallBack,params)
        table.insert(downActions, downAction)
    else

        local downAction=cc.CallFunc:create(onRoleAttackDownCallBack,params)
        if(isDead and   params.backDis~=-1)then
            local dieAction =cc.Sequence:create( cc.DelayTime:create(downTime) , cc.CallFunc:create(onRoleDieCallBack,params)   )
            table.insert(downActions, cc.Spawn:create(downAction,dieAction))
            during=downTime
        else
            local standupFunc=cc.Sequence:create( cc.DelayTime:create(downTime) ,cc.CallFunc:create(onRoleStandUpCallBack,params), cc.DelayTime:create(upTime) )
            table.insert(downActions, cc.Spawn:create(downAction,standupFunc))
            during=downTime
        end


    end
    return cc.Sequence:create(downActions),during

end


function gHasFlaAnimationData(name)
    return ccs.ArmatureDataManager:getInstance():getAnimationData(name)~=nil
end

function gGetFlaAnimationDuring(name)
    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(name)

    if(animationData==nil)then
        return 0
    end

    local movementData=  animationData:getMovement("stand")
    if(movementData==nil)then
        return 0
    end
    return movementData.duration/FLASH_FRAME
end

--解析flash 的帧事件
function gParseFlaFrameEvent(name,touchLevel,maxEffectList,queueAction)
    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(name)

    if(animationData==nil)then
        return {},{},0,0,0,{}
    end

    local movementData=  animationData:getMovement("stand")
    if(movementData==nil)then
        return {},{},0,0,0,{}
    end

    local movementBoneData=  movementData:getMovementBoneData("action")
    if(movementBoneData==nil)then
        return {},{},0,0,0,{}
    end

    if(touchLevel==nil)then
        touchLevel=1
    end
    local cooperateEvent=CooperateSkill[name]


    local attackerEvents={}
    local targetAttackEvents={}
    local reachs={}
    local passTime=0
    local maxAttackNum=0
    local downNum=0
    local during=0
    local attackTime=0
    local runToEvent=nil
    local runBackEvent=nil
    local moveCameraEvent=nil
    local runtoCenterEvent=nil
    local resetCameraEvent=nil
    local downDuring=0
    local firstAttackTime=0
    for i=0, movementData.duration do
        local frameData= movementBoneData:getFrameData(i)
        if(frameData )then
            if(string.find( frameData.strEvent,"attack_down") )then
                downNum=downNum+1
                downDuring=passTime
            end


            if(frameData.strEvent=="attack") then
                maxAttackNum=maxAttackNum+1
                attackTime=passTime
            end

            if(frameData.strEvent=="reach") then
                table.insert(reachs,passTime)
            elseif(frameData.strEvent~="")then
                local a=frameData.strEvent
                local eventTable=string.split(frameData.strEvent,",")
                for key, var in pairs(eventTable) do
                    local event={}
                    event.strEvent=var
                    event.duration=frameData.duration
                    event.passTime=passTime

                    if(queueAction<=0 )then
                        if(frameData.strEvent=="attack") then
                            table.insert(targetAttackEvents,event)
                        else
                            table.insert(attackerEvents,event)
                        end
                    else
                        if(frameData.strEvent=="attack"   )then
                            if(firstAttackTime==0   )then
                                firstAttackTime=passTime
                            end

                        end
                        event.passTime=passTime-firstAttackTime

                        if(frameData.strEvent=="attack") then
                            table.insert(targetAttackEvents,event)
                        elseif(string.find( event.strEvent,"attack_skill") or
                            string.find( event.strEvent,"shoot")  ) then
                            table.insert(attackerEvents,event)
                        end

                    end



                    if(  string.find( event.strEvent,"move_camara") )then
                        moveCameraEvent=event
                    end

                    if(  string.find( event.strEvent,"reset_camara") )then
                        resetCameraEvent=event
                    end
                    if(  string.find( event.strEvent,"run_to") )then
                        runToEvent=event
                    end
                    if(  string.find( event.strEvent,"run_back") )then
                        runBackEvent=event

                    end

                    if(  string.find( event.strEvent,"run_to_center") )then
                        runtoCenterEvent=event
                    end

                end
            end

            passTime=passTime+frameData.duration
        end

    end

    local cooperateAttack={}
    if(cooperateEvent)then
        if(touchLevel<=0)then
            touchLevel=1
        end

        if(touchLevel>4)then
            touchLevel=4
        end
        local count=cooperateEvent["level"..touchLevel]

        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if targetPlatform == cc.PLATFORM_OS_ANDROID then
            count=  math.ceil(count/2)
        end
        local perTime=(cooperateEvent.max_frame-cooperateEvent.min_frame)/count
        for i=1, count do
            local rand=(getRand(-20,20)/10)
            if(i==count-2)then
                rand=0
            end
            local event=clone(cooperateEvent)
            if(cooperateEvent["effect"..touchLevel])then
                event.effect=cooperateEvent["effect"..touchLevel]
            end
            event.hitCount=count
            event.passTime=cooperateEvent.min_frame+i*perTime+rand*perTime
            table.insert(cooperateAttack,event)
        end

    end



    local curReachIdx=1
    local curAttackIdx=0

    for key, var in pairs(attackerEvents) do
        if(curReachIdx>table.getn(reachs) )then
            break
        end

        if(
            string.find( var.strEvent,"run_to") or
            var.strEvent=="run_back"or
            string.find( var.strEvent,"shoot")
            )then

            var.reachTime=reachs[curReachIdx]-var.passTime
            curReachIdx=curReachIdx+1
        end


    end

    if(moveCameraEvent and runToEvent)then
        moveCameraEvent.passTime=runToEvent.passTime
        moveCameraEvent.reachTime=runToEvent.reachTime
    end

    if(resetCameraEvent and runBackEvent)then
        resetCameraEvent.passTime=runBackEvent.passTime
        resetCameraEvent.reachTime=runBackEvent.reachTime
    end

    if(maxAttackNum<maxEffectList)then
        maxAttackNum=maxEffectList
    end
    local attackPassTime=0
    for key, var in pairs(targetAttackEvents) do
        curAttackIdx=curAttackIdx+1
        var.attackIdx=curAttackIdx
        var.attackMaxNum=maxAttackNum
        attackPassTime=var.passTime
    end

    for i=curAttackIdx+1, maxAttackNum do
        local var={}
        attackPassTime=attackPassTime+9
        curAttackIdx=curAttackIdx+1
        var.attackIdx=curAttackIdx
        var.attackMaxNum=maxAttackNum
        var.strEvent=var
        var.duration=9
        var.passTime=attackPassTime
        table.insert(targetAttackEvents,var)
    end
    downDuring = downDuring - firstAttackTime
    attackTime = attackTime - firstAttackTime
    downDuring=downDuring+9
    if(attackTime<downDuring)then
        attackTime=downDuring
    end

    return attackerEvents,targetAttackEvents,movementData.duration/FLASH_FRAME,attackTime/FLASH_FRAME,downNum,cooperateAttack
end

function gIsImmuneTrigger(targetData)
    if(targetData.effectList and
        targetData.effectList[1]  and
        (  targetData.effectList[1].attr==Attr_PHYSICAL_ATTACK or
        targetData.effectList[1].attr==Attr_MAGIC_ATTACK))then
        return true
    end

    return false

end

function gIsAttackTarget(targetData)
    if( targetData.response==RESPONSE_TYPE_NOTHING or
        targetData.response==RESPONSE_TYPE_STUN or
        targetData.response==RESPONSE_TYPE_DODGE or
        targetData.response==RESPONSE_TYPE_REDUCE_HP or
        targetData.response==RESPONSE_TYPE_ADD_DAMAGE or
        targetData.response==RESPONSE_TYPE_REDUCE_POWER or
        ( targetData.response==RESPONSE_TYPE_IMMUNE and gIsImmuneTrigger(targetData)==false) or
        targetData.response==RESPONSE_TYPE_FROST or
        targetData.response==RESPONSE_TYPE_FROZEN or
        targetData.response==RESPONSE_TYPE_FROZEN_BROKEN or
        targetData.response==RESPONSE_TYPE_SUB_RECOVERY or
        targetData.response==RESPONSE_TYPE_LOCK )then
        return true
    end
    return false
end


function gResetCooperateAttackTargets(actionParam,count)
    local ret={}

    local roleGetNum={}
    local countPer= count

    while countPer>0 do
        for key, role in pairs(actionParam.targets) do
            local targetData=actionParam.attackData.targets[key]
            if( gIsAttackTarget(targetData))then
                if(roleGetNum[role]==nil)then
                    roleGetNum[role]=0
                end
                roleGetNum[role]=roleGetNum[role]+1
                countPer=countPer-1
                if(countPer<=0)then
                    break
                end
            end
        end
    end


    for key, role in pairs(actionParam.targets) do
        local targetData=actionParam.attackData.targets[key]
        if( gIsAttackTarget(targetData) and roleGetNum[role] and  roleGetNum[role]>0 )then
            local effectlist={}
            for key, var in pairs(targetData.effectList) do
                if(var.attr==Attr_HP)then
                    table.insert(effectlist,var)
                end
            end
            local effectCount=table.getn(effectlist)
            local totalCount= effectCount+roleGetNum[role]
            local reduceHp=0
            for key, var in pairs(effectlist) do
                local newValue=toint(var.value*0.4)
                reduceHp=(var.value-newValue)+reduceHp
                var.value=newValue
            end
            local tempHp=0
            for i=1, roleGetNum[role] do
                local obj={}
                obj.role=role
                if(i==roleGetNum[role])then
                    obj.hp=reduceHp-tempHp
                else
                    obj.hp=toint(reduceHp/roleGetNum[role])
                end
                if(targetData.response==RESPONSE_TYPE_IMMUNE)then
                    obj.hp=0
                end
                tempHp=tempHp+obj.hp
                table.insert(ret,obj)
            end
        end
    end

    local roles=gRandSortTable(ret)
    local totalCount=table.getn(roles)
    for i=1, totalCount do
        local curRole=roles[totalCount-i+1]
        if(roleGetNum[curRole.role])then
            roleGetNum[curRole.role]=nil
            curRole.isEnd=true
        end
    end
    return roles
end


function getMaxEffectNum(targets)
    local ret=0
    for key, target in pairs(targets) do
        if(target.effectList)then
            local effectListNum=table.getn(target.effectList)
            if(ret<effectListNum)then
                ret=effectListNum
            end
        end
    end
    return ret
end

--解析发动方时间callback
function gParseAttackEventCallback(attackerEvents,actionParam,spawnActions,totalDuring)
    local isUp=false
    for frameKey,frameData in pairs(attackerEvents) do
        local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
        if(frameData and string.len(frameData.strEvent)~=0 ) then
            local curAction=nil
            local params={
                attackRole=actionParam.attackRole,
                targetRole=actionParam.targetRole,
                attackData= actionParam.attackData
            }

            if(  string.find( frameData.strEvent,"run_to_center")  ) then --攻击方事件
                params._moveTime=frameData.reachTime/FLASH_FRAME
                params.targets=actionParam.targets
                if(string.len(frameData.strEvent)>13)then
                    params.alpha=toint(string.sub(frameData.strEvent,14,string.len(frameData.strEvent)))
                else
                    params.alpha=1
                end
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleMoveCenterCallBack,params) )
            elseif(  string.find( frameData.strEvent,"run_to_other_center")  ) then --攻击方事件

                params._moveTime=frameData.reachTime/FLASH_FRAME
                params.targets=actionParam.targets
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleMoveOtherCenterCallBack,params) )
            elseif(  string.find( frameData.strEvent,"run_to_raw")  ) then --攻击方事件

                params._moveTime=frameData.reachTime/FLASH_FRAME
                params.targets=actionParam.targets
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleMoveRawCallBack,params) )

            elseif(  string.find( frameData.strEvent,"run_to_screen_center")  ) then --攻击方事件

                params._moveTime=frameData.reachTime/FLASH_FRAME
                params.targets=actionParam.targets
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleMoveScreenCenterCallBack,params) )

            elseif(string.find( frameData.strEvent,"reset_speed")  and actionParam.passSpeed~=true) then
                params.targetData=targetData
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleResetSpeedCallBack,params) )
            elseif(string.find( frameData.strEvent,"speed_") and actionParam.passSpeed~=true  ) then
                params.targetData=targetData
                params.speedScale=tonum(string.sub(frameData.strEvent,7,string.len(frameData.strEvent)))
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleSetSpeedCallBack,params) )

            elseif(string.find( frameData.strEvent,"run_to") ) then --攻击方事件
                params.targetPos=actionParam.targetPos
                params.dis=string.sub(frameData.strEvent,8,string.len(frameData.strEvent))
                params._moveTime=frameData.reachTime/FLASH_FRAME
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleMoveCallBack,params) )
            elseif(  frameData.strEvent=="run_back" ) then
                params._moveTime=frameData.reachTime/FLASH_FRAME
                totalDuring=totalDuring-params._moveTime
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleMoveBackCallBack,params) )
            elseif(  frameData.strEvent=="set_gray" ) then
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onSetGrayBackCallBack,params) )
            elseif(  frameData.strEvent=="reset_gray" ) then
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onResetGrayBackCallBack,params) )
            elseif(string.find( frameData.strEvent,"play_skill")  ) then
                params._skill=string.sub(frameData.strEvent,12,string.len(frameData.strEvent))
                local skillTime=gGetActionTime( params._skill)
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlaySkillCallBack,params))
            elseif(string.find( frameData.strEvent,"play_cooperate_skill")  )  then
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayCooperateSkillCallBack,params))
            elseif(string.find( frameData.strEvent,"play_stretch_skill2")  ) then
                params._skill=string.sub(frameData.strEvent,21,string.len(frameData.strEvent))
                local skillTime=gGetActionTime( params._skill)
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayStretchSkill2CallBack,params))
            elseif(string.find( frameData.strEvent,"play_stretch_skill")  ) then
                params._skill=string.sub(frameData.strEvent,20,string.len(frameData.strEvent))
                local skillTime=gGetActionTime( params._skill)
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayStretchSkillCallBack,params))
            elseif(string.find( frameData.strEvent,"play_cover")     ) then
                local coverName=string.sub(frameData.strEvent,12,string.len(frameData.strEvent))
                if(coverName=="battle_cover5" and actionParam.passCover==true )then
                --过滤合体技速度线
                else
                    params.targets=actionParam.targets
                    params._cover=coverName
                    curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayCoverCallBack,params))
                end
            elseif(string.find( frameData.strEvent,"play_side_cover")  ) then
                params._cover=string.sub(frameData.strEvent,17,string.len(frameData.strEvent))
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlaySideCoverCallBack,params))
            elseif(string.find( frameData.strEvent,"play_raw_cover")  ) then
                params._cover=string.sub(frameData.strEvent,16,string.len(frameData.strEvent))
                params.targetRoles=actionParam.targets
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayRawCoverCallBack,params))
            elseif(string.find( frameData.strEvent,"play_face_cover")  ) then
                params._cover=string.sub(frameData.strEvent,17,string.len(frameData.strEvent))
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayFaceCoverCallBack,params))
            elseif(  frameData.strEvent=="move_camara" ) then
                if(frameData.reachTime)then
                    params._moveTime=frameData.reachTime/FLASH_FRAME
                end
                params.targetPos=actionParam.targetPos
                actionParam.relationNextAttacker=2
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onMoveCamaraCallBack,params) )
            elseif(  frameData.strEvent=="reset_camara" ) then
                if(frameData.reachTime)then
                    params._moveTime=frameData.reachTime/FLASH_FRAME
                end
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onMoveCamaraBackCallBack,params) )
            elseif( string.find( frameData.strEvent,"shake") ) then
                local shakeEvent=frameData.strEvent
                local table= string.split(shakeEvent,"_")
                if(table[2]=="h" )then --横向
                    params.shakeDir = 2
                    params.shakeTime= toint(table[3])
                    params.shakeOffset=toint(table[4])
                elseif(table[2]=="v")then --上下
                    params.shakeDir =3
                    params.shakeTime= toint(table[3])
                    params.shakeOffset=toint(table[4])
                else
                    params.shakeDir =1
                    params.shakeTime= toint(table[2])
                    params.shakeOffset=toint(table[3])

                end
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onShakeCallBack,params) )
            end

            if(curAction)then
                table.insert(spawnActions,curAction)
            end

        end

    end
    return totalDuring
end

--处理事件
function gParseAttackAction(skillId,name,actionParam,actions,queueAction)
    local attackerEvents,targetAttackEvents,totalDuring,attackDuring,downNum,cooperateAttackEvents=gParseFlaFrameEvent(name,actionParam.touchLevel,getMaxEffectNum(actionParam.attackData.targets),queueAction)

    local skillDuring=totalDuring
    local isAttackDown=downNum>0
    local spawnActions={}



    for key, role in pairs(actionParam.targets) do
        role.curDownIdx=0
        role.curAfterEffectIdx=0
    end
    for key, role in pairs(actionParam.afterTargets) do
        role.curDownIdx=0
        role.curAfterEffectIdx=0
    end


    if(table.getn(cooperateAttackEvents)~=0)then
        local coopearteRoles= gResetCooperateAttackTargets(actionParam,table.getn(cooperateAttackEvents))
        for frameKey,frameData in pairs(cooperateAttackEvents) do
            local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
            if(frameData and string.len(frameData.strEvent)~=0  and coopearteRoles[frameKey]) then
                local curAction=nil
                local params=clone(frameData);
                params.attackRole=actionParam.attackRole
                params.targetRole=coopearteRoles[frameKey].role
                params.hp=coopearteRoles[frameKey].hp
                params.isEnd=coopearteRoles[frameKey].isEnd
                params.attackData=actionParam.attackData
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleRandShootCallBack,params) )
                table.insert(spawnActions,curAction)
            end
        end
    end






    local downDuring=0
    totalDuring= gParseAttackEventCallback(attackerEvents,actionParam,spawnActions,totalDuring)

    if(skillId==GUOJIA_SKILL_ID and actionParam.nextTargetRole)then
        for key, frameData in pairs(attackerEvents) do
            local curAction=nil
            if(string.find( frameData.strEvent,"shoot")  and  actionParam.nextTargetRole.curSide~=actionParam.attackRole.curSide ) then
                --射击事件
                local params={
                    targetRole=actionParam.nextTargetRole,
                    attackData= actionParam.attackData
                }
                if(queueAction==0)then
                    params.attackRole=actionParam.attackRole
                    local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
                    local delayTime2=cc.DelayTime:create((frameData.duration+10)/FLASH_FRAME)
                    params._moveTime=frameData.reachTime/FLASH_FRAME
                    params._shootH=toint(string.sub(frameData.strEvent,7,7))
                    params._bullet=string.sub(frameData.strEvent,9,string.len(frameData.strEvent))
                    curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleShootCallBack,params),delayTime2 )
                else
                    params.attackRole=actionParam.targetRole
                    local delayTime=cc.DelayTime:create(0.2)
                    local delayTime2=cc.DelayTime:create((frameData.duration+10)/FLASH_FRAME)
                    params._moveTime=0.6
                    params._shootH=toint(string.sub(frameData.strEvent,7,7))
                    params._bullet=string.sub(frameData.strEvent,9,string.len(frameData.strEvent))
                    curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleShootDelayCallBack,params),delayTime2 )
                end

            end
            if(curAction)then
                table.insert(spawnActions,curAction)
            end
        end
    end

    for key, role in pairs(actionParam.targets) do --被击方事件
        local targetData=actionParam.attackData.targets[key]
        if( gIsAttackTarget(targetData))then

            local during=gParserAttackTarget(spawnActions,skillId,skillDuring,role,actionParam,targetData,attackerEvents,targetAttackEvents,isAttackDown,downNum)
            if(during>downDuring)then
                downDuring=during
            end
        elseif( targetData.response==RESPONSE_TYPE_RECOVERY) then   -- 回血
            gParserAttackRecoveryTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)

        elseif( targetData.response==RESPONSE_TYPE_SUCK) then   --吸血
            gParserAttackSuckTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)

        elseif( targetData.response==RESPONSE_TYPE_CHAIN_DAMAGE)then
            gParserChainDamageTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
        elseif( targetData.response==RESPONSE_TYPE_BUFF_REMOVE)then
            gParserAttackBuffRemoveTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)

        elseif( targetData.response==RESPONSE_TYPE_IMMUNE and gIsImmuneTrigger(targetData) )then
            gParserAttackImmuneTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
        else
            gParserAttackBuffTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
        end

        --[[ elseif( targetData.response==RESPONSE_TYPE_REBOUND_DAMAGE) then   --反伤
        curAction=gParserAttackReboundDamageTarget(role,params,actionParam,targetData,frameData,isAttackDown,delayTime)
        ]]
    end


    if(actionParam.relationNextAttacker==0)then
        totalDuring=attackDuring
    elseif(actionParam.relationNextAttacker==1)then
        totalDuring=skillDuring
    elseif(actionParam.relationNextAttacker==2)then
        totalDuring=skillDuring+downDuring
    end

    local isHuangZhong = false
    if(queueAction==0)then
        if(skillId==GUOJIA_SKILL_ID)then
            totalDuring=attackDuring-0.2
            skillDuring=totalDuring
        else
            totalDuring=attackDuring+0.2
            skillDuring=totalDuring
            isHuangZhong = true
        end
    elseif(queueAction>0)then
        if(skillId==GUOJIA_SKILL_ID)then 
            totalDuring= 0.6
            skillDuring=totalDuring
        else
            totalDuring= 0.2
            skillDuring=totalDuring
            isHuangZhong = true
        end
    end

    local delayTime=cc.DelayTime:create(totalDuring)

    for key, role in pairs(actionParam.afterTargets) do --攻击后播放的target
        local params={attackRole=actionParam.attackRole,targetRole=role,key=key }
        params.attackData=actionParam.attackData
        params.targets=actionParam.afterTargets
        params.targetData=actionParam.attackData.afterTargets[key]
        local delayTimeNum=10*(role.curAfterEffectIdx )+5
        if isHuangZhong == true then
            delayTimeNum =6
        end

        curAction=cc.Sequence:create(delayTime,cc.DelayTime:create(delayTimeNum/FLASH_FRAME) , cc.CallFunc:create(onRoleAfterActionCallBack,params)  )
        role.curAfterEffectIdx=role.curAfterEffectIdx+1
        table.insert(spawnActions,curAction)

        if( params.targetData.response==RESPONSE_TYPE_ATTR_CHANGE) then
            for key, var in pairs(params.targetData.effectList) do
                params.targetRole:setSkipChangeAttr(var,actionParam.attackRole)
            end
        end

    end


    if(table.getn(spawnActions)>1) then
        table.insert(actions,cc.Spawn:create( spawnActions))
    elseif(table.getn(spawnActions)==1) then
        table.insert(actions, spawnActions[1])
    end

    return totalDuring,skillDuring,attackDuring

end

function gParserAttackBuffRemoveTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
    role:setSkipHp(targetData.damage,actionParam.attackRole)
    local passTime=7
    if(table.getn(targetAttackEvents)~=0)then
        passTime=passTime+ targetAttackEvents[table.getn(targetAttackEvents)].passTime
    end


    local delayTime=cc.DelayTime:create(passTime/FLASH_FRAME)
    local params={attackRole=actionParam.attackRole,targetRole=role }
    params.attackData=actionParam.attackData
    params.targets=actionParam.targets
    params.targetData=targetData
    local curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackRemoveBuffCallBack,params)  )
    table.insert(spawnActions,curAction)
end

function gParserAttackSuckTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
    role:setSkipHp(targetData.damage,actionParam.attackRole)
    local passTime=7
    if(table.getn(targetAttackEvents)~=0)then
        passTime=passTime+ targetAttackEvents[table.getn(targetAttackEvents)].passTime
    end

    local delayTime=cc.DelayTime:create(passTime/FLASH_FRAME)
    local params={attackRole=actionParam.attackRole,targetRole=role }
    params.attackData=actionParam.attackData
    params.targets=actionParam.targets
    params.targetData=targetData
    local curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackSuckCallBack,params)  )
    table.insert(spawnActions,curAction)
end

function gParserChainDamageTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
    role:setSkipHp(-targetData.damage,actionParam.attackRole)
    local passTime=7
    if(table.getn(targetAttackEvents)~=0)then
        passTime=passTime+ targetAttackEvents[table.getn(targetAttackEvents)].passTime
    end

    local delayTime=cc.DelayTime:create(passTime/FLASH_FRAME)
    local params={attackRole=actionParam.attackRole,targetRole=role }
    params.attackData=actionParam.attackData
    params.targets=actionParam.targets
    params.targetData=targetData
    local curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackSpiritChainCallBack,params)  )
    table.insert(spawnActions,curAction)
end



--免疫
function gParserAttackImmuneTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
    local passTime=0
    if(table.getn(targetAttackEvents)~=0)then
        passTime=passTime+ targetAttackEvents[table.getn(targetAttackEvents)].passTime
    end

    local delayTime=cc.DelayTime:create(passTime/FLASH_FRAME)
    local params={attackRole=actionParam.attackRole,targetRole=role }
    params.attackData=actionParam.attackData
    params.targets=actionParam.targets
    params.targetData=targetData
    local curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackImmuneCallBack,params)  )
    table.insert(spawnActions,curAction)

end

--攻击中buff
function gParserAttackBuffTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)
    local passTime=0
    if(table.getn(targetAttackEvents)~=0)then
        passTime=passTime+ targetAttackEvents[table.getn(targetAttackEvents)].passTime
    end

    local delayTime=cc.DelayTime:create(passTime/FLASH_FRAME)
    local params={attackRole=actionParam.attackRole,targetRole=role }
    params.attackData=actionParam.attackData
    params.targets=actionParam.targets
    params.targetData=targetData
    local curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackBuffCallBack,params)  )
    table.insert(spawnActions,curAction)

end

--反伤
function gParserAttackReboundDamageTarget(role,params,actionParam,targetData,frameData,isAttackDown,delayTime)
    local curAction=nil
    if(frameData.strEvent=="attack" and frameData.attackIdx==frameData.attackMaxNum ) then
        params.attackData=actionParam.attackData
        params.targets=actionParam.targets
        params.targetData=targetData
        params.attackIdx=frameData.attackIdx
        params.attackMaxNum=frameData.attackMaxNum
        params.isAttackDown=isAttackDown
        curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackReboundDamageCallBack,params)  )

    end
    return curAction
end

function gParserAttackRecoveryTarget(spawnActions,role,actionParam,targetData,attackerEvents,targetAttackEvents)

    role:setSkipHp(targetData.damage)
    --出手后补血
    if(targetData.responseRound==2)then
        local passTime=10

        if(table.getn(targetAttackEvents)~=0)then
            passTime=passTime+ targetAttackEvents[table.getn(targetAttackEvents)].passTime
        end

        local delayTime=cc.DelayTime:create(passTime/FLASH_FRAME)
        local params={attackRole=actionParam.attackRole,targetRole=role }
        params.attackData=actionParam.attackData
        params.targets=actionParam.targets
        params.targetData=targetData
        params.effectData= targetData.effectList[1]
        local curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackRecoveryCallBack,params)  )
        table.insert(spawnActions,curAction)
    else
        for key, frameData in pairs(targetAttackEvents) do
            local params={attackRole=actionParam.attackRole,targetRole=role }
            local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
            local curAction=nil
            if(targetData.effectList[key]) then
                params.attackData=actionParam.attackData
                params.targets=actionParam.targets
                params.targetData=targetData
                params.effectData= targetData.effectList[key]
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackRecoveryCallBack,params)  )
            end
            if(curAction)then
                table.insert(spawnActions,curAction)
            end
        end

        for key, frameData in pairs(attackerEvents) do
            local params={attackRole=actionParam.attackRole,targetRole=role }
            local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
            local curAction=nil
            if(string.find( frameData.strEvent,"attack_skill")  ) then
                params._skill=string.sub(frameData.strEvent,14,string.len(frameData.strEvent))
                params.targetData=targetData
                params.targets=actionParam.targets
                params.includeSelf=true
                curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayAttackSkillCallBack,params)  )

            end
            if(curAction)then
                table.insert(spawnActions,curAction)
            end
        end
    end
end

function gParserAttackTarget(spawnActions,skillId,skillDuring,role,actionParam,targetData,attackerEvents,targetAttackEvents,isAttackDown,downNum)

    local during=0
    role:setSkipHp(-targetData.damage,actionParam.attackRole)
    for key, frameData in pairs(targetAttackEvents) do
        local params={attackRole=actionParam.attackRole,targetRole=role }
        local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
        local curAction=nil
        params.attackData=actionParam.attackData
        params.targets=actionParam.targets
        params.targetData=targetData
        params.effectData= targetData.effectList[key]
        params.attackIdx=frameData.attackIdx
        params.attackMaxNum=frameData.attackMaxNum
        params.isAttackDown=isAttackDown
        curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackCallBack,params),cc.DelayTime:create(0.4) )
        table.insert(spawnActions,curAction)
    end

    for key, frameData in pairs(attackerEvents) do
        local params={
            attackRole=actionParam.attackRole,
            targetRole=role,
            attackData= actionParam.attackData
        }
        local delayTime=cc.DelayTime:create(frameData.passTime/FLASH_FRAME)
        local curAction=nil
        if(skillId~=GUOJIA_SKILL_ID and string.find( frameData.strEvent,"shoot")  and not string.find( frameData.strEvent,"rand_shoot") ) then --射击事件
            local delayTime2=cc.DelayTime:create((frameData.duration+10)/FLASH_FRAME)
            params._moveTime=frameData.reachTime/FLASH_FRAME
            params._shootH=toint(string.sub(frameData.strEvent,7,7))
            params._bullet=string.sub(frameData.strEvent,9,string.len(frameData.strEvent))
            curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleShootCallBack,params),delayTime2 )

        elseif(string.find( frameData.strEvent,"attack_scroll")    ) then
            local table= string.split(frameData.strEvent,"_")
            params.backDis=toint(table[3])
            params.upDis=toint(table[4])
            curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackScrollCallBack,params) )
        elseif(string.find( frameData.strEvent,"attack_up")  ) then
            isUp=true
            local table= string.split(frameData.strEvent,"_")
            params.backDis=toint(table[3])
            params.upDis=toint(table[4])
            curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRoleAttackUpCallBack,params) )
        elseif(string.find( frameData.strEvent,"attack_down")   )then
            params.targetData=targetData
            local table= string.split(frameData.strEvent,"_")
            params.backDis=toint(table[3])
            role.curDownIdx=role.curDownIdx+1
            local action=nil
            local temp
            action,temp=gParseAttackDownAction(params.backDis~=0,isUp,params,role.curDownIdx,downNum)
            curAction=cc.Sequence:create(delayTime, action)
            temp=temp-(skillDuring-frameData.passTime/FLASH_FRAME)
            if(temp>during)then
                during=temp
            end


        elseif(string.find( frameData.strEvent,"attack_skill") ) then
            params._skill=string.sub(frameData.strEvent,14,string.len(frameData.strEvent))
            params.targetData=targetData
            params.targets=actionParam.targets
            curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayAttackSkillCallBack,params))

        elseif(string.find( frameData.strEvent,"attack_stand_skill") ) then
            params._skill=string.sub(frameData.strEvent,20,string.len(frameData.strEvent))
            params.targetData=targetData
            params.targets=actionParam.targets
            curAction=cc.Sequence:create(delayTime, cc.CallFunc:create(onRolePlayAttackStandSkillCallBack,params))

        end
        if(curAction)then
            table.insert(spawnActions,curAction)
        end
    end

    return during

end


--处理事件
function gParseBeforeActionBuff(self,actionParam)
    local spawnActions={}
    local idx=0

    for key, role in pairs(actionParam.targets) do
        role.curBuffIdx=0
    end
    local showTime=0
    for key, role in pairs(actionParam.targets) do
        local params={attackRole=actionParam.attackRole,targetRole=role,key=key }
        params.attackData=actionParam.attackData
        params.targets=actionParam.targets
        params.targetData=actionParam.attackData.buffTargets[key]
        showTime=0.2*role.curBuffIdx
        table.insert(spawnActions ,cc.Sequence:create( cc.DelayTime:create(showTime), cc.CallFunc:create(onRoleBeforeActionCallBack,params) ) )
        role.curBuffIdx=role.curBuffIdx+1

        -- 属性变化
        if( params.targetData.response==RESPONSE_TYPE_ATTR_CHANGE) then
            for key, var in pairs(params.targetData.effectList) do
                params.targetRole:setSkipChangeAttr(var)
            end
        end
    end

    local action=nil
    if(table.getn(spawnActions)>1) then
        action=cc.Spawn:create( spawnActions)
    elseif(table.getn(spawnActions)==1) then
        action= spawnActions[1]
    end

    if(action)then
        action.actionPassTime=self.actionPassTime
        table.insert( self.battleActions, action)
    end

end