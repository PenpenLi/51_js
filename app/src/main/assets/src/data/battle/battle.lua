Battle={}
Battle.curBattleGroup=1 --当前关卡
Battle.maxBattleGroup=1 --最大关卡
Battle.dropNum={}
Battle.dropedNum={}
Battle.logs={}
Battle.win=0
Battle.curLog={}  --日志为了验证
Battle.battleType=0
Battle.reward={}
Battle.beganStoryId=nil
Battle.appearStoryId=nil
Battle.endStoryId=nil
Battle.startFightNum=0
Battle.actAtlas = {}

Battle.otherFormation={}
Battle.otherBattleDamageData={}
Battle.otherBattleHurtData={}
Battle.otherBattleRecoverData={}

Battle.myFormation={}
Battle.myBattleDamageData={}
Battle.myBattleHurtData={}
Battle.myBattleRecoverData={}

function  Battle.setDropNum(num,group)
    Battle.dropNum={}
    Battle.dropedNum={} 
    for i=1, 3 do 
        Battle.dropedNum[i]=0
    end
    if(group==1)then
        Battle.dropNum[1]=num
    elseif(group==2)then
        Battle.dropNum[1]=math.floor(num/4) 
        Battle.dropNum[2]=num-math.floor(num/4) 
    elseif(group==3)then
        Battle.dropNum[1]=math.floor(num/4) 
        Battle.dropNum[2]=math.floor(num/4) 
        Battle.dropNum[3]=num-math.floor(num/4)*2
    end

    
end


function Battle.getLogPetData(pet,obj) 
    obj:putInt(0)
 --   obj:putByte(0)
 --   obj:putByte(0)

end 

function Battle.getLogCardsData(card,obj) 
    obj:putByte(card.pos)
    obj:putInt(card.cardid)
    obj:putInt(card.level)
    obj:putByte(card.grade)
    obj:putByte(card.quality)
    obj:putInt(card.hpInit)
    obj:putInt(card.physicalAttack)
    obj:putInt(card.hp)
    obj:putInt(card.agility)
    obj:putInt(card.physicalDefend)
    obj:putInt(card.magicDefend)
    obj:putInt(card.hit)
    obj:putInt(card.dodge)
    obj:putInt(card.critical)
    obj:putInt(card.toughness)
    obj:putInt(card.maxRage)
    obj:putInt(card.rage)
    for i=1, 16 do
        obj:putInt(0)
    end
end 

function Battle.getLogFormationData(cards,obj) 
    obj:putByte(table.count(cards))
    if(cards)then 
        for key, card in pairs(cards) do
            Battle.getLogCardsData(card,obj) 
        end
    end
    --   obj:putByte(0)
    --   obj:putByte(0)

end 

function Battle.getLogTeamData(obj,price,player) 
    for i=1, 4 do
        obj:putInt(0)
    end
    obj:putInt(price)
    Battle.getLogPetData(nil,obj)
    Battle.getLogFormationData(player,obj) 
end


function Battle.getLogItemData(log) 
    local obj=MediaData:create() 
    
    Battle.getLogTeamData(obj,1,log.player1)
    Battle.getLogTeamData(obj,0,log.player2)
    obj:putByte(log.win)
    obj:putByte(0)
    return obj
end

function Battle.getLogData()

    local array=MediaArray:create()
    for key, log in pairs(Battle.logs) do
        array:addMediaData(Battle.getLogItemData(log))
    end 
    return array
end

function  Battle.addLog(actionRound)
    if(Battle.rounds==nil)then
        Battle.rounds={}
    end
    if(Battle.rounds[actionRound.roundIndex]==nil)then
        Battle.rounds[actionRound.roundIndex]={}
        Battle.rounds[actionRound.roundIndex].actions={}
    end
    for key, action in pairs(actionRound.actions) do
        if(action.actionType~=ACTION_TYPE_SELECT_TARGET)then 
            table.insert(Battle.rounds[actionRound.roundIndex].actions,action)
        end 
    end
end



function Battle.enterAtlas(formation,pet,enemyFormations,country,groupId,maxRound,bgName,power)
    local ret={}
    Battle.logs={}
    Battle.reward={}
    Battle.curLog={} 
    gBattlePowerRate=power
    CoreAtlas.EliteFlop.bShowEliteFlop = false
    CoreAtlas.EliteFlop.bNeedEliteFlop = false

    local stageInfo=DB.getActStageInfoById( Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid)
    if(stageInfo)then
        if( Battle.battleType==BATTLE_TYPE_ATLAS_PET)then
            gBattleTotalReliveNum=stageInfo.itemmax/stageInfo.dmgparam-6
        end
    end
    if(maxRound)then
        MAX_ROUND=maxRound
    end
    Battle.curAtlasEnemyFormations=enemyFormations
    Battle.curBattleGroup=groupId
    Battle.maxBattleGroup=table.getn(enemyFormations)
    ret.playerCards1=formation
    Battle.startFightNum=table.count(formation)
    
    ret.playerCards2=enemyFormations[groupId]
    Battle.curLog.player1=clone(ret.playerCards1)
    Battle.curLog.player2=clone(ret.playerCards2)
    ret.battleRoundList,ret.playerPet1=gGetBattleVideo( clone(ret.playerCards1) ,clone(ret.playerCards2),pet,country)
 
    local addCards={}
    for key, enemyFormation in pairs(enemyFormations) do 
        for key, card in pairs( enemyFormation) do
            table.insert(addCards,{cardid=card.cardid,weaponLv=card.weaponLv,awakeLv=card.awakeLv})
        end
    end
 
    ret.bgName=bgName
    Battle.preloadBattle(ret,addCards,Scene.enterBattle) 
    return ret
end

function Battle.enterAtlasNextGroup(groupId,formation)
    local ret={}  
    Battle.curLog={}
    Battle.curBattleGroup=groupId  
    ret.playerCards2=Battle.curAtlasEnemyFormations[groupId]
    Battle.curLog.player2=clone(ret.playerCards2)
    ret.battleRoundList,ret.playerCards1,ret.playerPet1=gGetNextGroupBattleVideo( clone( ret.playerCards2)) 
    Battle.curLog.player1=clone(ret.playerCards1)
 
    return ret
end
 





function Battle.preloadBattle(ret,addCards,callback)

    local cards=addCards 
    for key, card in pairs(ret.playerCards1) do
        table.insert(cards,{cardid=card.cardid,weaponLv=card.weaponLv,awakeLv=card.awakeLv})
    end
    
    if(ret.playerPet1)then
        -- 暂时处理，后面改
        local awakeLv = nil
        if (ret.playerPet1.grade ~= nil and ret.playerPet1.grade == 6) or
           (ret.playerPet1.quality ~= nil and ret.playerPet1.quality == 6)then
            awakeLv = 1
        end
        table.insert(cards,{cardid=ret.playerPet1.petid,awakeLv=awakeLv})
    end
    

    if(ret.playerPet2)then
        -- 暂时处理，后面改
        local awakeLv = nil
        if (ret.playerPet2.grade ~= nil and ret.playerPet2.grade == 6) or
           (ret.playerPet2.quality ~= nil and ret.playerPet2.quality == 6)then
            awakeLv = 1
        end
        table.insert(cards,{cardid=ret.playerPet2.petid,awakeLv=awakeLv})
    end

    for key, card in pairs(ret.playerCards2) do
        table.insert(cards,{cardid=card.cardid,weaponLv=card.weaponLv,awakeLv=card.awakeLv})
    end

    Scene.preLoadBattleRes(cards,ret.bgName,callback)
end

function Battle.parseGuideBattleTarget(targetParams,addCards)
    local target={}
    target.isEnemy =true
    target.position =toint(targetParams[3])
    target.response = 0
    target.responseRound = 0
    target.isDead = toint(targetParams[6])==1
    
    local damages=string.split(targetParams[7],"|")
    if(damages[1] and toint(damages[1])<0)then
        target.isEnemy =false
        target.response=RESPONSE_TYPE_RECOVERY
    end
    local totalDamage=0
    target.effectList={}
    
    --—type       byte    0:伤害去血 1：属性增加 2：属性减少 3:触发免疫                 
--—attr       byte    属性                  
--—value      int 属性值                 
--—isCritical     bool    是否暴击            
    
    
    for key, damage in pairs(damages) do
        if(damage~="")then  
            totalDamage=totalDamage+toint(damage)
            local effect={}

            effect.type = 0
            effect.attr = Attr_HP
            effect.value =toint(damage)
            if(effect.value<0)then
                effect.value=-effect.value
            end
            effect.isCritical = getRand(0,100)>70

            table.insert(target.effectList,effect)
        end
    end
    target.damage =  totalDamage
    return target
end

function Battle.parseGuideBattleAction(actions,addCards)
    local targetCmds={}
    local attackCmds={}
    local storyCmds={}
    local appearCmds={}
    local changeCmds={}
    local hurtCmds={}
    local selectCmds={}
    local guideCmds={}
    local delayCmds={}
    local faceCmds={}
    local function getParamNum(param)
        return param%10,math.floor(param/10)
    end
    for i=0,10  do   
        if(actions["cmd"..i])then 
            local cmdTabls=string.split(actions["cmd"..i],",")
            if(toint(cmdTabls[1])==0)then
                attackCmds=cmdTabls 
            elseif(toint(cmdTabls[1])==2)then
                local param=toint(cmdTabls[2]) 
                if( param >=100000 and param <200000)then
                    if(appearCmds.pos==nil)then
                        appearCmds.pos={}
                    end
                    table.insert(appearCmds.pos ,param%10)
                    appearCmds.side=math.floor(param/10)%10+1 
                elseif(param>200000 and param<300000)then --受伤200014

                    hurtCmds.pos=param%10
                    param=math.floor(param/10)
                    hurtCmds.side=param%10
                elseif(param>300000 and param<400000)then --delay
                    delayCmds.delayTime=param%100  
                elseif(param>400000 and param<500000)then --guideid
                    guideCmds.guideid=param%100 
                    param=math.floor(param/100)
                elseif(param>500000 and param<600000)then --face
                    faceCmds.faceid=param%100  
                elseif(param>3000000 and param<4000000)then --选择300014 
                    selectCmds.guideid=param%100
                    param=math.floor(param/100)
                    selectCmds.pos1,param= getParamNum(param) 
                    selectCmds.side1,param= getParamNum(param) 
                    selectCmds.selectType,param= getParamNum(param)
                    selectCmds.needSelectNum,param= getParamNum(param)
                    guideCmds.needPause,param= getParamNum(param) 
                elseif(param>10000000 and param<20000000)then --变身12411000
                    changeCmds.cardid=param%100000
                    param=math.floor(param/100000)
                    changeCmds.pos=param%10
                    param=math.floor(param/10)
                    changeCmds.side=param%10
                    
                else
                    storyCmds=cmdTabls
                end 
            else
                table.insert(targetCmds,cmdTabls) 
            end 
        end
    end

    local action={}
    if(faceCmds.faceid~=nil)then 
        action.faceid=faceCmds.faceid
        action.actionType = ACTION_TYPE_SHOW_FACE  
        return action
    end
    if(delayCmds.delayTime~=nil)then
 
        action.delayTime=delayCmds.delayTime
        action.actionType = ACTION_TYPE_ADD_DELAY_TIME  
        return action
    end
    
    if(guideCmds.guideid~=nil)then

        action.guideid = guideCmds.guideid 
        action.needPause=guideCmds.needPause
        action.actionType = ACTION_TYPE_DISPATCH_GUIDE  
        return action
    end
    
    if(changeCmds.cardid~=nil)then  
        action.activeSide = changeCmds.side
        action.activePosition = changeCmds.pos
        action.targetPosition = changeCmds.cardid --变身的id
        action.actionType = ACTION_TYPE_CHANGE 
        table.insert(addCards,{cardid=action.targetPosition})
        return action
    end
    
    if(selectCmds.pos1~=nil)then 
        action.activeSide = selectCmds.side1 
        action.activePosition = selectCmds.pos1 
        action.guideid=selectCmds.guideid
        action.actionType = ACTION_TYPE_SELECT_TARGET_GUIDE
        action.selectType=selectCmds.selectType
        action.needSelectNum=selectCmds.needSelectNum
        action.targets={}
        for key, target in pairs(targetCmds) do
            table.insert(action.targets,Battle.parseGuideBattleTarget(target))

        end
        return action
    end
    
    if(hurtCmds.pos~=nil)then
        action.activeSide = hurtCmds.side 
        action.activePosition = hurtCmds.pos
        action.actionType = ACTION_TYPE_HURT
        return action
    end
    
    if(appearCmds.pos~=nil)then
        action.side = appearCmds.side 
        action.pos = appearCmds.pos
        action.actionType = ACTION_TYPE_APPEAR 
        return action
    end
     
    if(storyCmds[2]~=nil)then  
        action.activeSide = storyCmds[2]
        action.actionType = ACTION_TYPE_STORY 
        return action
    end
    

    
    if(toint(attackCmds[3])==0)then 
        action.activeSide = 1
    else
        action.activeSide = 2
    end
    action.buffTargets={}
    action.activePosition =toint(attackCmds[4])
    action.targetPosition =toint(attackCmds[5])
     
    action.actionType = ACTION_TYPE_SKILL 
    action.rageAdd =0 
    if(toint(attackCmds[2])>3)then  
        action.skillType =  1
        action.skillId =  toint(attackCmds[2]) 
    elseif(toint(attackCmds[2])==3)then  
        action.skillType =  2 
    elseif(toint(attackCmds[2])==2)then  
        action.skillType =  1
    else
        action.skillType =  0
        action.rageAdd =1
    end
    action.targets={} 
     
    for key, target in pairs(targetCmds) do
        table.insert(action.targets,Battle.parseGuideBattleTarget(target))
    	 
    end
  
   
    return action 
end

function Battle.parseGuideBattleRound(actions,addCards)
    local round={}

    for i=0,40  do  
        if(actions["att"..i])then
            table.insert(round,Battle.parseGuideBattleAction(actions["att"..i],addCards))
        end
    end  
    return round
end

function Battle.parseGuideBattle(rounds,addCards)
    local roundList={}
    for i=0,10  do  
        if(rounds["round"..i])then
            local round={}
            round.actions=Battle.parseGuideBattleRound(rounds["round"..i],addCards)
            round.roundIndex=i 
            table.insert(roundList,round)
        end
    end 

    return roundList
end


function Battle.parseGuideBattleCard(cards)
    local ret={}
    local pet=nil
    
    for key, cardData in pairs(cards) do
        local cardDataTable= string.split(cardData,",")
        if(toint(cardDataTable[2])~=0)then 
            local playerCard=PlayerCard.new() 
            playerCard.cardid=toint(cardDataTable[2])  
            playerCard.hp =toint( cardDataTable[4])
            playerCard.appearType=toint( cardDataTable[3]) 
            playerCard.maxRage=2
            local param=toint(cardDataTable[5])
            playerCard.rage=param%10
            param=math.floor(param/10)
            if( param>0)then
                playerCard.roleScale=(param%100)/10 
                param=math.floor(param/100)
            end
            
            if(param>0)then
                playerCard.weaponLv= param%10
                param=math.floor(param/10)
            end

            if(param>0)then
                playerCard.awakeLv= param%10
                param=math.floor(param/10)
            end
            
            playerCard:setHpInit()
            playerCard.pos=key-1
            
            if(key==7)then
                pet=playerCard
                pet.petid=50000+pet.cardid
            else 
                ret[key-1]=playerCard 
            end
        end 
    end
    
    return ret,pet
end



function Battle.guideBattle(file)
    local battleData=cc.FileUtils:getInstance():getValueMapFromFile(file) 
    local initData= battleData.init
    
    
    
    local ret={}
    gIsBattleVideo=true
    Battle.curAtlasMapId=1
    Battle.curAtlasStageId=1
    ret.playerCards1,ret.playerPet1=Battle.parseGuideBattleCard(initData.down)
    ret.playerCards2,ret.playerPet2=Battle.parseGuideBattleCard(initData.up) 
    local addCards={}
    ret.battleRoundList=Battle.parseGuideBattle(battleData.cmds.round,addCards)
    ret.bgName="b002" 
    Battle.preloadBattle(ret,addCards,Scene.enterBattle)
    return ret
end

function Battle.updateActAtlasInfo(actAtlasType, num, cdTime)
    local exist = false
    for i =1, #Battle.actAtlas do
        if nil ~= Battle.actAtlas[i].type and Battle.actAtlas[i].type == actAtlasType then
            Battle.actAtlas[i].num = num
            Battle.actAtlas[i].cdTime = cdTime
            exist = true
            break
        end
    end

    if not exist then
        local item = {}
        item.type = actAtlasType
        item.num  = num
        item.cdTime = cdTime
        table.insert(Battle.actAtlas, item)
    end
end

function Battle.getActAtlasInfoByType(actAtlasType)
    for i =1, #Battle.actAtlas do
        if nil ~= Battle.actAtlas[i].type and Battle.actAtlas[i].type == actAtlasType then
            return Battle.actAtlas[i]
        end
    end
    return nil
end

function Battle.clear()
    Battle.actAtlas = {}
end

