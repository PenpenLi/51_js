



MAX_ROUND=10
local SIDE1 = 1 --左or下
local SIDE2 = 2 --右or上

local lWiner=0
local lplayerCards1={}  --战斗方1
local lplayerCards2={}  --战斗方2

local lplayerPet1=nil
local lplayerPet2=nil

local lbattleRoundList={}
local lbattleVedio={}

gBattleTouchLevel=0
gIsAutoBattle=false
gIsManualBattle=false
gLastBattleOrderList=nil --记录大招前的出手顺序
gLastBattleOrder=nil--记录大招钱的出手位置
gLastBattleRound=nil--记录大招前的回合数
gBattleSelectRolesRange={}--可以选择的卡牌范围
gBattleSelectRoles={}--玩家选择的卡牌
gBattleNeedSelectNum=0
gBattleNeedSelectType=0
gBattleCurReliveNum=0
gBattleTotalReliveNum=0
gIsSkinAttack=false
gIsBattleVideo=false
gIsBattleBreak=false
gBattleCountry1=0
gBattleCountry2=0
gBattlePowerRate=0
gBattlePowerDownPercent1=0
gBattlePowerDownPercent2=0
gBossHead=0

gBattleSpiritChain1 =nil;
gBattleSpiritChain2 = nil;

function gResetBattleData()
    gBossHead=0
    lWiner=0
    gBattlePowerDownPercent1=0
    gBattlePowerDownPercent2=0
    gBattlePowerRate=0
    gIsBattleBreak=false
    gIsBattleVideo=false

    gBattleSpiritChain1 =nil;
    gBattleSpiritChain2 = nil;
    Battle.curBattleGroup=1 --当前关卡
    Battle.maxBattleGroup=1
    gBattleTouchLevel=0
    Battle.beganStoryId=nil
    Battle.appearStoryId=nil
    Battle.endStoryId=nil
    lplayerCards1={}  --战斗方1
    lplayerCards2={}  --战斗方2
    lplayerPet1=nil
    lplayerPet2=nil
    lbattleRoundList={}
    lbattleVedio={}
    gLastBattleOrderList=nil --记录大招前的出手顺序
    gLastBattleOrder=nil--记录大招钱的出手位置
    gLastBattleRound=nil--记录大招前的回合数
    gBattleSelectRolesRange={}--可以选择的卡牌范围
    gBattleSelectRoles={}--玩家选择的卡牌
    gBattleNeedSelectNum=0
    gBattleNeedSelectType=0
    gBattleCurReliveNum=0
    gBattleTotalReliveNum=0
    gBattleCountry1=0
    gBattleCountry2=0
    Battle.brief=nil
    Battle.otherFormation={}
    Battle.otherBattleDamageData={}
    Battle.otherBattleHurtData={}
    Battle.otherBattleRecoverData={}

    Battle.myFormation={}
    Battle.myBattleDamageData={}
    Battle.myBattleHurtData={}
    Battle.myBattleRecoverData={}
end



function gResetBattleGroupData()

    lWiner=0
    lplayerCards2={}  --战斗方2
    lbattleRoundList={}
    lbattleVedio={}

    gLastBattleOrderList=nil --记录大招前的出手顺序
    gLastBattleOrder=nil--记录大招钱的出手位置
    gLastBattleRound=nil--记录大招前的回合数
    gBattleSelectRolesRange={}--可以选择的卡牌范围
    gBattleSelectRoles={}--玩家选择的卡牌
    gBattleNeedSelectNum=0
end


local lTargetPosOrders={{0,1,2,3,4,5},
    {1,0,2,4,3,5},
    {2,1,0,5,4,3},
    {0,1,2,3,4,5},
    {1,0,2,4,3,5},
    {2,1,0,5,4,3}
}

local lTargetPosOrders_front={{0,1,2,3,4,5},
    {1,0,2,4,3,5},
    {2,1,0,5,4,3},
    {0,1,2,3,4,5},
    {1,0,2,4,3,5},
    {2,1,0,5,4,3}
}
local lTargetPosOrders_back={{3,4,5,0,1,2},
    {4,3,5,1,0,2},
    {5,4,3,2,1,0},
    {3,4,5,0,1,2},
    {4,3,5,1,0,2},
    {5,4,3,2,1,0}
}

function isBuffInRange(buff,pos)
    if(buff.target_range == SKILL_RANGE_BACK_ROW)then
        return pos >= 3 and pos <= 5
    elseif(buff.target_range  == SKILL_RANGE_FRONT_ROW)then
        return pos >= 0 and pos <= 2
    end
    return true
end


local function isAllDead( playerCards)

    for key, card in pairs(playerCards) do
        if( card and card:isAlive())then
            return false
        end
    end

    return true
end
local function setWinner(attackSide)
    lWiner=attackSide
end

local function getTargetPosOrders( attackPos)
    return lTargetPosOrders[attackPos+1]
end

local function getTargetPosOrders_front( attackPos)
    return lTargetPosOrders_front[attackPos+1]
end

local function getTargetPosOrders_back( attackPos)
    return lTargetPosOrders_back[attackPos+1]
end

local function getEffectAttrValue(  playerCard,  attr,  attr_value)
    if(attr >= Attr_HP and attr <= Attr_TOUGHNESS) then
        return math.rint(attr_value)
    elseif(attr >= Attr_HP_PERCENT and attr <= Attr_MAGIC_DEFEND_PERCENT)then
        local value = 0
        if (attr ==Attr_HP_PERCENT)then
            value = playerCard.hp
        elseif  (attr ==Attr_AGILITY_PERCENT)then
            value = playerCard.agility
        elseif  (attr ==Attr_PHYSICAL_ATTACK_PERCENT)then
            value = playerCard.physicalAttack
        elseif  (attr ==Attr_MAGIC_ATTACK_PERCENT)then
            value = playerCard.magicAttack
        elseif  (attr ==Attr_PHYSICAL_DEFEND_PERCENT)then
            value = playerCard.physicalDefend
        elseif  (attr ==Attr_MAGIC_DEFEND_PERCENT)then
            value = playerCard.magicDefend
        end
        return value
    else
        return math.rint(attr_value)
    end
end

function getAttrValue0(buff, level)
    return buff.attr_value0+(level-1)*buff.attr_add_value0
end

function getAttrValue1(buff, level)
    return buff.attr_value1+(level-1)*buff.attr_add_value1
end
local function  findTargetPos(  attackPos,  enemyCards ,  rangeType)
    local  posOrders={}
    if(rangeType == SKILL_RANGE_FRONT_ROW) then
        posOrders = getTargetPosOrders_front(attackPos)
    elseif(rangeType == SKILL_RANGE_BACK_ROW) then
        posOrders = getTargetPosOrders_back(attackPos)
    else
        posOrders = getTargetPosOrders(attackPos)
    end

    for key, pos in pairs(posOrders) do
        if(enemyCards[pos] ~= nil and enemyCards[pos]:isAlive())then
            return pos
        end
    end


    return -1
end


function  createPlayerBuff(  type,  attr,  value,  round)
    return {
        type=type,
        attr=attr,
        value=value,
        roundCount=round*12 }
end

function createTargetEffect(  type,  attr,  value,  isCritical)

    return {
        type=type,
        attr=attr,
        value=value,
        isCritical=isCritical }
end

local function  addBuffBeforeAction(  buff,  buffLevel,  action,  attackPos,  attacker,  enemyCards,  myCards,skillType)
    if(buff.trigger_moment == BUFFER_TRIGGER_MOMENT_BEFORE_ACTION) then

        local temp=clone(gBattleSelectRoles)
        gBattleSelectRoles={}
        local targetPosArray = getTargetPosArray(attackPos,attackPos,buff.target_range, buff.target_num,myCards,nil,buff.target_card,nil)
        gBattleSelectRoles=temp
        for key, pos in pairs(targetPosArray) do
            local attacker = myCards[pos]
            if(attacker ~= nil and attacker:isAlive())then

                if(buff.type == BUFFER_TYPE_ADD_ATTR_WITHIN_ACTION) then
                    --出手前增加自身属性
                    if(gCheckBuffRate(buff,buffLevel, skillType))then
                        local attr = buff.attr_id0
                        local attr_value = getAttrValue0(buff,buffLevel)
                        local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE,attr,attr_value,buff.round )
                        attacker:addPlayerBuff(pbuff)
                        local  effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr, getEffectAttrValue(attacker,attr,attr_value), false)
                        local  target = PlayerTarget.new()
                        target:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect)
                        table.insert(action.buffTargets,target)
                    end

                elseif(buff.type == BUFFER_TYPE_REDUCE_HP_ADD_ATTACK)then
                    --出手前降血加攻
                    if( gCheckBuffRate(buff,buffLevel,skillType))then
                        local attr1 = buff.attr_id1 --攻击属性，物攻或魔攻
                        local attr_value1 =  getAttrValue1(buff,buffLevel) --加的数值
                        local percent =getAttrValue0(buff,buffLevel) --加的数值
                        local damage = attacker:reduceHp(percent)
                        local pbuff =   createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, attr1, attr_value1, buff.round)
                        attacker:addPlayerBuff(pbuff)

                        local effect = createTargetEffect(EFFECT_TYPE_ATTR_REDUCE, Attr_HP, damage, false)
                        local  target =   PlayerTarget.new()
                        target:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE,  0,damage, false, effect)
                        table.insert(action.buffTargets,target)

                        local effect1 = createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr1, getEffectAttrValue(attacker,attr1,attr_value1), false)
                        local  target1 =  PlayerTarget.new()
                        target1:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect1)
                        table.insert(action.buffTargets,target1)
                    end
                elseif(buff.type ==BUFFER_TYPE_ADD_ATTACK_WHEN_LOW_HP)then
                    local percent = buff.attr_value0--百分比数值
                    if(attacker:isHpLow(percent))then
                        local attr = buff.attr_id1
                        local attr_value = getAttrValue1(buff,buffLevel)
                        local pbuff =  createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, attr, attr_value, buff.round)
                        attacker:addPlayerBuff(pbuff)
                        local effect =   createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr, getEffectAttrValue(attacker,attr,attr_value), false)
                        local  target =  PlayerTarget.new()
                        target:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect)
                        table.insert(action.buffTargets,target)
                    end
                end
            end
        end
    end

end



local function addBuffAfterAction(  buff,  buffLevel,  action, attackSide, attackPos,  attacker,  enemyCards ,  myCards ,  skillType,targetPosArray,param,isEnemyKilled)
    if(buff.trigger_moment== BUFFER_TRIGGER_MOMENT_AFTER_ACTION  or
        buff.trigger_moment ==BUFFER_TRIGGER_MOMENT_BEFORE_ROUND or
        buff.trigger_moment== BUFFER_TRIGGER_MOMENT_AFTER_PET_ACTION) then

        if(buff.target_range ~= SKILL_RANGE_SAME_WITH_SKILL  )then
            targetPosArray = getTargetPosArray(attackPos, attackPos,buff.target_range, buff.target_num, myCards,nil,buff.target_card,getSpiritChain(attackSide));
        end

        if(targetPosArray==nil)then
            targetPosArray={}
        end


        for key, pos in pairs(targetPosArray) do
            local playerCard = myCards[pos]
            if(playerCard ~= nil  )then
                if(playerCard:isAlive())then
                    if(buff.type==  BUFFER_TYPE_ADD_ATTR_WITHIN_ACTION)then
                        --出手后回复自己怒气
                        if(gCheckBuffRate(buff,buffLevel, skillType)) then
                            local attr = buff.attr_id0
                            local attr_value = getAttrValue0(buff,buffLevel)
                            local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, attr, attr_value, buff.round)
                            playerCard:addPlayerBuff(pbuff)
                            local effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr, getEffectAttrValue(playerCard,attr,attr_value), false)
                            local  target =   PlayerTarget.new()
                            target:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect)
                            table.insert(action.targets,target)

                            local attr1 = buff.attr_id1
                            local attr_value1 = getAttrValue1(buff,buffLevel)
                            local pbuff1 = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, attr1, attr_value1, buff.round)
                            playerCard:addPlayerBuff(pbuff1)
                            local effect1 = createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr1, getEffectAttrValue(playerCard,attr1,attr_value1), false)
                            local  target1 =   PlayerTarget.new()
                            target1:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect1)
                            table.insert(action.targets,target1)
                        end
                    elseif(buff.type==  BUFFER_TYPE_ADD_RAGE_AFTER_ACTION)then
                        --出手后回复自己怒气
                        if(gCheckBuffRate(buff,buffLevel, skillType)) then
                            local attr = buff.attr_id0
                            local attr_value = getAttrValue0(buff,buffLevel)
                            local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, attr, attr_value, buff.round)
                            playerCard:addPlayerBuff(pbuff)
                            local effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr, getEffectAttrValue(playerCard,attr,attr_value), false)
                            local  target =   PlayerTarget.new()
                            target:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect)
                            table.insert(action.targets,target)
                        end
                    elseif(buff.type==  BUFFER_TYPE_RECOVERY) then
                        --出手后给自己回血
                        if(gCheckBuffRate(buff,buffLevel, skillType)) then
                            local percent = getAttrValue0(buff,buffLevel)--回血百分比
                            local exHp = getAttrValue1(buff,buffLevel) --回血固定值
                            local hpRecover = math.rint(playerCard.hpInit*percent/100+exHp)
                            local playerTarget =   PlayerTarget.new()
                            playerTarget:setParam2(playerCard, pos, hpRecover,false)
                            playerTarget.responseRound = 2 --标志出手后回血
                            table.insert(action.targets,playerTarget)
                        end

                    elseif(buff.type == BUFFER_TYPE_RECOVERY_EXTRA)then
                        --额外回血
                        if(param and param>0 and gCheckBuffRate(buff,buffLevel, skillType))then
                            local percent = getAttrValue0(buff,buffLevel)--回血百分比
                            local hpRecover = math.rint( param*percent/100)
                            local playerTarget =   PlayerTarget.new()
                            local addPercent = playerCard:getRecoverPercent()
                            local hpadd = math.rint( hpRecover*addPercent/100);--治疗效果增加
                            playerTarget:setParam2(playerCard, pos, hpRecover+hpadd,false)
                            playerTarget.responseRound = 2 --标志出手后回血
                            table.insert(action.targets,playerTarget)
                        end

                    elseif(buff.type == BUFFER_TYPE_ADD_RAGE_AFTER_ENEMY_KILLED)then
                        if(isEnemyKilled and gCheckBuffRate(buff,buffLevel, skillType))then
                            local attr = buff.attr_id0
                            local attr_value = getAttrValue0(buff,buffLevel)
                            local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, attr, attr_value, buff.round)
                            playerCard:addPlayerBuff(pbuff)
                            local effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD, attr, getEffectAttrValue(playerCard,attr,attr_value), false)
                            local  target =   PlayerTarget.new()
                            target:setParam1(pos, RESPONSE_TYPE_ATTR_CHANGE, buff.round,0, false, effect)
                            table.insert(action.targets,target)
                        end

                    elseif(buff.type ==  BUFFER_TYPE_ADD_SHIELD)then
                        --给自己加护盾
                        if(gCheckBuffRate(buff,buffLevel,skillType))then
                            local value = math.rint(getAttrValue0(buff,buffLevel))
                            local playerTarget =   PlayerTarget.new()
                            playerTarget:setParam1(pos,RESPONSE_TYPE_SHIELD,   0, value, false, nil)
                            table.insert(action.targets,playerTarget)
                            --设置护盾
                            playerCard.shield=(value)
                        end
                    elseif (buff.type ==  BUFFER_TYPE_RECOVERY_HP_BY_ATTACK) then --/出手后按攻击力给自己回血
                        if(gCheckBuffRate(buff,buffLevel,skillType))then
                            local percent = getAttrValue0(buff,buffLevel) --回血百分比
                            local hpRecover =math.rint(playerCard.physicalAttack*percent/100)
                            local playerTarget =   PlayerTarget.new()
                            playerTarget:setParam2(playerCard, pos, hpRecover,false)
                            playerTarget.responseRound = 2 --标志出手后回血
                            table.insert(action.targets,playerTarget)
                        end
                    elseif(buff.type == BUFFER_TYPE_IMMUNE)then
                        --免疫
                        if(gCheckBuffRate(buff,buffLevel,skillType))then
                            local responseRound = buff.round
                            local effect = createTargetEffect(EFFECT_TYPE_IMMNUE, buff.attr_id0, 0, false)
                            local playerTarget =   PlayerTarget.new()
                            playerTarget:setParam1(pos, RESPONSE_TYPE_IMMUNE, responseRound,buff.attr_id0, false,effect)
                            table.insert( action.targets,playerTarget)
                            local pbuff = createPlayerBuff(RESPONSE_TYPE_IMMUNE, buff.attr_id0, 0, responseRound)
                            playerCard:addPlayerBuff(pbuff)

                        end
                    elseif(buff.type == BUFFER_TYPE_CLEAR_HARMFUL_BUFF)then
                        if(gCheckBuffRate(buff,buffLevel,skillType))then
                            local clist = clearHarmfulBuff(playerCard);
                            if(table.count(clist) > 0)then
                                local target =  PlayerTarget.new()
                                target.response = RESPONSE_TYPE_BUFF_REMOVE;
                                target.isEnemy = false;
                                target.position = pos;

                                for key, pbuff in pairs(clist) do
                                    if(pbuff.type == RESPONSE_TYPE_STUN)then
                                        local effect = createTargetEffect(EFFECT_TYPE_STUN_REMOVE, 0, 0, false)
                                        table.insert(target.effectList,effect)
                                    elseif(pbuff.type == RESPONSE_TYPE_LOCK)then
                                        local effect = createTargetEffect(EFFECT_TYPE_LOCK_REMOVE, 0, 0, false)
                                        table.insert(target.effectList,effect)
                                    elseif(pbuff.type == RESPONSE_TYPE_REDUCE_HP)then
                                        local effect = createTargetEffect(EFFECT_TYPE_REDUCE_HP_REMOVE, 0, 0, false)
                                        table.insert(target.effectList,effect)
                                    elseif(pbuff.type == RESPONSE_TYPE_FROST)then
                                        local effect = createTargetEffect(EFFECT_TYPE_REDUCE_FROST_REMOVE, 0, 0, false)
                                        table.insert(target.effectList,effect)
                                    elseif(pbuff.type == RESPONSE_TYPE_FROZEN)then
                                        local effect = createTargetEffect(EFFECT_TYPE_REDUCE_FROZEN_REMOVE, 0, 0, false)
                                        table.insert(target.effectList,effect)
                                    end
                                end
                                table.insert( action.targets,target)
                            end
                        end
                    elseif buff.type == BUFFER_TYPE_IMMUNE_HARMFUL_BUFF then --//出手后加免疫负面效果BUFF
                        if(gCheckBuffRate(buff,buffLevel,skillType))then
                            local responseRound = buff.round
                            local playerTarget =   PlayerTarget.new()
                            playerTarget:setParam1(pos, RESPONSE_TYPE_IMMUNE_HARMFUL_BUFF, responseRound,buff.attr_id0, false,nil)
                            table.insert( action.targets,playerTarget)
                            local pbuff = createPlayerBuff(RESPONSE_TYPE_IMMUNE_HARMFUL_BUFF, buff.attr_id0, 0, responseRound)
                            playerCard:addPlayerBuff(pbuff)
                        end
                    elseif buff.type == BUFFER_TYPE_PET_RECOVERY then --//灵兽每回合回血
                        if(gCheckBuffRate(buff,buffLevel,skillType))then
                            local pet = getPlayerPetBySide(attackSide)
                            if(pet ~= nil)then
                                local hpRecover = math.rint(pet.level*getAttrValue0(buff,buffLevel));
                                local playerTarget = PlayerTarget.new()
                                playerTarget:setParam2(playerCard, pos, hpRecover,false)
                                table.insert( action.targets,playerTarget)
                            end
                        end
                    elseif buff.type == BUFFER_TYPE_RECOVERY_ALL_HP then
                        local hpPer = attacker:getHpRate()*100; 
                        if hpPer<buff.attr_value0 and attacker.recovery_all_hp_count<buff.round and gCheckBuffRate(buff,1,0) then
                            local hpRecover = attacker.hpInit - attacker.hp;
                            local playerTarget = PlayerTarget.new()
                            playerTarget:setParam2(attacker, pos, hpRecover,false)
                            table.insert( action.targets,playerTarget)
                            --增加记录的触发次数
                            attacker.recovery_all_hp_count =attacker.recovery_all_hp_count+1
                        end
                    end
                else
                    if(buff.type == BUFFER_TYPE_RELIVE_FRIEND)then
                        --出手会复活一个队友
                        if(attacker.relivePoint >=buff.attr_value0)then
                            local percent = getAttrValue1(buff,buffLevel)--回血百分比
                            local value = math.rint(playerCard.hpInit*percent/100);

                            playerCard:relive(value);


                            local reliveTarget =PlayerTarget.new()
                            reliveTarget:setParam1( pos, RESPONSE_TYPE_RELIVE,  0, value,false,nil)
                            table.insert( action.targets,reliveTarget)

                            local clearTarget=PlayerTarget.new()
                            clearTarget:setParam1( attackPos, RESPONSE_TYPE_CLEAR_RELIVE_POINT,  0, 0,false,nil)
                            table.insert( action.targets,clearTarget)

                            attacker:resetRelivePoint();

                        end
                    end

                end
            end
        end

    end
end

local function getHpRecover(  attacker,  attr,  percent,  percentAdd,  extraValue,  extraValueAdd,  level,extraPercent)
    local hpAdd =0.4*attacker:getAttackOrDefendValue(Attr_PHYSICAL_ATTACK)*(percent+extraPercent+percentAdd*(level-1))/100+extraValue+(level-1)*extraValueAdd
    return math.rint(hpAdd)
end

local function getSkillPercentValue(skill,  level,extraPercent)
    return  skill.percent_value +extraPercent+(level-1)* skill.percent_add_value
end

local function _getSKillDamage(skill,pValue ,skillLevel,extraPercent)
    return  math.rint(getSkillPercentValue(skill,skillLevel,extraPercent)*pValue/100+( skill.attr_value+(skillLevel-1)*skill.attr_add_value))
end

local function   getSkillDamage(  skill,  skillLevel,  attacker,  enemy,skillType)

    local  attack = attacker:getAttackOrDefendValue(Attr_PHYSICAL_ATTACK)
    local defend = enemy:getSkillDefendAttr(skill.attr_id)

    defend = math.max(0, defend-attacker.ignoreDefend)
    local dmg = 0
    if(attack >= defend*120/100)then
        dmg = 1*(attack - defend)
    else
        dmg = 1*(attack*attack/(attack + defend*6))
    end

    local extraPercent =0

    if( skillType == 1)then
        extraPercent=attacker.skillDamagePercent
    end

    local skillDamage=_getSKillDamage(skill,dmg,skillLevel,extraPercent)
    return math.max(1,skillDamage),attack,defend


end

function getSkillBuff(skill,index)
    if(index == 0 and skill.buff_id0 > 0)then
        return DB.getBuffById(skill.buff_id0)
    elseif(index == 1 and skill.buff_id1 > 0) then
        return DB.getBuffById(skill.buff_id1)
    end
    return nil
end

function getBuffById(buffid)
     return DB.getBuffById(buffid)
end

function getSkillBuffList(skill)
    local buffList ={}
    if(skill.buff_id2 and string.len(skill.buff_id2) > 0)then
        buffList=string.split(skill.buff_id2,";")
    end
    for k,id in pairs(buffList) do
        buffList[k]=tonum(id,10)
    end
    return buffList
end

local function createPlayerAction(  side,  activePosition)
    return  {
        buffTargets={},
        targets={},
        activeSide = side,
        activePosition = activePosition,
        targetPosition=0,
        actionType=0,
        skillId=0,
        rageAdd=0,
        skillType=0
    }
end


local function addOneTargetPosArray(  array,  i,  enemyCards)
    if(enemyCards[i] ~= nil and enemyCards[i]:isAlive())then
        table.insert( array,i)
    end
end

local function addSortPlyer(  slist,  splayer)

    for key, cur in pairs(slist) do
        if(splayer.hp < cur.hp)then
            table.insert(slist,key,splayer)
            return
        end
    end

    table.insert(slist,splayer)
end


function getTargetPosArray(  attackPos,  targetPos,  rangeType,  targetNum,  enemyCards,isSelectRange,targetCard,sc)

    if(rangeType == SKILL_RANGE_ORDER_BY_ATTACKER_POS)then
        if(attackPos < 3)then
            rangeType=SKILL_RANGE_FRONT_ROW

        else
            rangeType=SKILL_RANGE_BACK_ROW
        end
    end


    local array ={}
    local rangeArray=nil
    gBattleNeedSelectType=rangeType
    --全体
    if(rangeType == SKILL_RANGE_ALL or rangeType == SKILL_RANGE_RANDOM_NUM
        or rangeType == SKILL_RANGE_RANDOM_NEARBY )then
        for key, var in pairs(enemyCards) do
            addOneTargetPosArray(array,var.pos,enemyCards)
        end

        if(isSelectRange)then
            rangeArray=clone(array)
            gBattleNeedSelectNum=1 --全体选择一个
        end
    end

    --贯穿
    if(rangeType == SKILL_RANGE_VERTICAL) then
        if(table.getn(gBattleSelectRoles)~=0)then
            targetPos=gBattleSelectRoles[1]
        end
        table.insert(array,targetPos)
        if(targetPos == 0 or targetPos == 1 or targetPos == 2)then
            addOneTargetPosArray(array, (targetPos+3),enemyCards)
        elseif(targetPos == 3 or targetPos == 4 or targetPos == 5)then
            addOneTargetPosArray(array,  (targetPos-3),enemyCards)
        end
        if(isSelectRange)then
            rangeArray={}
            for key, var in pairs(enemyCards) do
                addOneTargetPosArray(rangeArray,var.pos,enemyCards)
            end
            gBattleNeedSelectNum=1 --贯穿选择一个
        end
    end

    --横扫
    if(rangeType == SKILL_RANGE_HORIZONTAL or rangeType == SKILL_RANGE_FRONT_ROW or rangeType ==  SKILL_RANGE_BACK_ROW) then
        --前后排
        if(rangeType == SKILL_RANGE_FRONT_ROW or rangeType == SKILL_RANGE_BACK_ROW) then
            targetPos = findTargetPos(attackPos, enemyCards, rangeType) --重新查找主目标
        end
        if(table.getn(gBattleSelectRoles)~=0)then
            targetPos=gBattleSelectRoles[1]
        end
        table.insert(array,targetPos)
        if(targetPos == 0) then
            addOneTargetPosArray(array, 1,enemyCards)
            addOneTargetPosArray(array, 2,enemyCards)
        elseif(targetPos == 1) then
            addOneTargetPosArray(array, 0,enemyCards)
            addOneTargetPosArray(array, 2,enemyCards)
        elseif(targetPos == 2) then
            addOneTargetPosArray(array, 0,enemyCards)
            addOneTargetPosArray(array, 1,enemyCards)
        elseif (targetPos == 3) then
            addOneTargetPosArray(array, 4,enemyCards)
            addOneTargetPosArray(array, 5,enemyCards)
        elseif (targetPos == 4)then
            addOneTargetPosArray(array, 3,enemyCards)
            addOneTargetPosArray(array, 5,enemyCards)
        elseif (targetPos == 5)then
            addOneTargetPosArray(array, 3,enemyCards)
            addOneTargetPosArray(array, 4,enemyCards)
        end
        if(isSelectRange)then
            rangeArray=clone(array)
            gBattleNeedSelectNum=1 --横扫
        end
        --前后排
        if(rangeType == SKILL_RANGE_FRONT_ROW or rangeType == SKILL_RANGE_BACK_ROW) then
            --如果目标个数不是前后排的全部人员(3个)，则目标要根据实际设定数量来算
            if(targetNum < 3 and  table.getn( array) > targetNum) then
                local a =  table.getn( array) - targetNum
                for i=0, a-1 do
                    table.remove(array,table.getn( array))
                end
            end
        end
    end


    if ( rangeType == SKILL_RANGE_SINGLE) then --单体
        table.insert(array,targetPos)

        if(isSelectRange)then
            rangeArray={}
            for key, var in pairs(enemyCards) do
                addOneTargetPosArray(rangeArray,var.pos,enemyCards)
            end
        end

        if(table.getn(gBattleSelectRoles)~=0)then
            rangeArray=clone(gBattleSelectRoles)
        end

    end

    if ( rangeType == SKILL_RANGE_RANDOM_LEIFENG) then --随机
        local posList={}
        for key, var in pairs(enemyCards) do
            if(var ~=nil and var:isAlive())then
                if(key ~= attackPos)then
                    table.insert(posList,var.pos)
                end
            end
        end

        if(table.count(posList)<targetNum )then
            table.insert(posList,attackPos)--如果人数不够，才加入自己
        end


        for j=0, targetNum-1 do
            local size =table.getn( posList)
            if(size > 0)then
                local rand = getRand(0,size-1)
                local pos = table.valueByIdx(posList,rand)
                table.insert(array,pos.value)
                table.remove( posList,pos.key)
            end
        end

        if(isSelectRange)then
            rangeArray={}
            for key, var in pairs(enemyCards) do
                addOneTargetPosArray(rangeArray,var.pos,enemyCards)
            end
        end

        if(table.getn(gBattleSelectRoles)~=0)then
            rangeArray=clone(gBattleSelectRoles)
        end
    end




    if ( rangeType == SKILL_RANGE_RANDOM) then --随机
        local posList={}
        for key, var in pairs(enemyCards) do
            if(var ~=nil and var:isAlive())then
                table.insert(posList,var.pos)
            end
        end


        for j=0, targetNum-1 do
            local size =table.getn( posList)
            if(size > 0)then
                local rand = getRand(0,size-1)
                local pos = table.valueByIdx(posList,rand)
                table.insert(array,pos.value)
                table.remove( posList,pos.key)
            end
        end

        if(isSelectRange)then
            rangeArray={}
            for key, var in pairs(enemyCards) do
                addOneTargetPosArray(rangeArray,var.pos,enemyCards)
            end
        end

        if(table.getn(gBattleSelectRoles)~=0)then
            rangeArray=clone(gBattleSelectRoles)
        end
    end


    if (rangeType == SKILL_RANGE_LOWEST_HP) then --生命值最低
        local slist={}

        for i, var in pairs(enemyCards) do
            if(enemyCards[i] ~= nil and enemyCards[i]:isAlive())then
                local  splayer={pos=i,hp=enemyCards[i]:getHpRate() }
                addSortPlyer(slist, splayer)
            end
        end

        for i=1, targetNum do
            if(slist[i])then
                table.insert(array,slist[i].pos)
            end

        end
        if(isSelectRange)then
            rangeArray={}
            for key, var in pairs(slist) do
                table.insert(rangeArray,var.pos)
            end

        end
        if(table.getn(gBattleSelectRoles)~=0)then
            rangeArray=clone(gBattleSelectRoles)
        end

    end

    if(rangeType == SKILL_RANGE_LOWEST_RAGE  or rangeType ==SKILL_RANGE_HIGHEST_RAGE )then--怒气值最低
        local slist={}

        for i, var in pairs(enemyCards) do
            if(enemyCards[i] ~= nil and enemyCards[i]:isAlive())then
                local startNum = enemyCards[i].rage*100;
                local endNum = (enemyCards[i].rage+1)*100-1;
                local param = getRand(startNum, endNum) ---根据怒气值分配随机权重

                local  splayer={pos=i,hp=param }
                addSortPlyer(slist, splayer)
            end
        end
        
        if(rangeType ==SKILL_RANGE_HIGHEST_RAGE )then 
            local  temp=slist
            slist={}
            for key, var in pairs(temp) do 
                table.insert(slist,1,var)
            	
            end 
        end
        

        for i=1, targetNum do
            if(slist[i])then
                table.insert(array,slist[i].pos)
            end
        end
        
        if(isSelectRange)then
            rangeArray={}
            for key, var in pairs(slist) do
                table.insert(rangeArray,var.pos)
            end
        end


        if(table.getn(gBattleSelectRoles)~=0)then
            rangeArray=clone(gBattleSelectRoles)
        end

    end

    if(rangeType == SKILL_RANGE_CARD)then
        for i, var in pairs(enemyCards) do
            if(enemyCards[i] ~= nil and enemyCards[i].cardid==targetCard)then
                addOneTargetPosArray(array,var.pos,enemyCards)
                break
            end
        end
    end
    if(rangeType == SKILL_RANGE_SPIRIT_CHAIN and sc ~= nil)then
        for key, pos in pairs(sc.chainPos) do
            if(pos~= -1)then
                addOneTargetPosArray(array,pos,enemyCards);
            end
        end
    end

    if(rangeType == SKILL_RANGE_FIRST_POS_DEAD)then
        for i=0, 5 do
            if(enemyCards[i] ~= nil and enemyCards[i]:isAlive()==false)then
                table.insert( array,enemyCards[i].pos)
                break
            end
        end
    end

    if(rangeArray)then
        return rangeArray
    end

    return array
end

local function checkHasCooperateCard(cardid,cards)
    for key, card in pairs(cards) do
        if(card~=nil and card:isAlive() and toint(card.cardid)==toint(cardid))then
            return true
        end
    end
    return false
end

local function triggerExtraSkill(skill)
    if(skill.extra_skill==0)then
        return false
    end
    return getRand(0,100)<=skill.extra_skill_rate
end

local function checkCooperateCard(skill ,cards)
    if(skill.cooperate_card=="")then
        return false
    end
    local cooperates=string.split(skill.cooperate_card,",")
    local   count = 0;
    for key, cardid in pairs(cooperates) do
        if(checkHasCooperateCard(cardid,cards))then
            count=count+1
        end
    end
    return count == table.getn(cooperates)
end
local function  addTargetElement(  pos, targetPosArray)
    for key, var in pairs(targetPosArray) do
        if(var==pos)then
            return
        end
    end
    table.insert( targetPosArray,pos);
end


local function  getOneRamdonTargetPos(  enemyCards)
    local posList={}
    for key, enemy in pairs(enemyCards) do
        if(enemy ~= nil and enemy:isAlive())then
            table.insert(posList,key)
        end
    end
    if(table.getn(posList)==0)then
        return nil
    end
    local rand =getRand(1,table.getn(posList))
    return posList[rand]

end
--[[***
* 根据指定目标取相邻的一个随机目标
* @param targetPos  指定目标
* @param enemyCards
* @return -1表示找不到目标了
*]]

local function getOneRamdonNearbyTargetPos(  targetPos,  enemyCards)
    local  array = {}
    if(targetPos == 0)then
        addOneTargetPosArray(array, 1,enemyCards);
        addOneTargetPosArray(array, 3,enemyCards);
    elseif (targetPos == 1)then
        addOneTargetPosArray(array, 0,enemyCards);
        addOneTargetPosArray(array, 2,enemyCards);
        addOneTargetPosArray(array, 4,enemyCards);
    elseif (targetPos == 2)then
        addOneTargetPosArray(array, 1,enemyCards);
        addOneTargetPosArray(array, 5,enemyCards);
    elseif (targetPos == 3)then
        addOneTargetPosArray(array, 0,enemyCards);
        addOneTargetPosArray(array, 4,enemyCards);
    elseif (targetPos == 4)then
        addOneTargetPosArray(array, 1,enemyCards);
        addOneTargetPosArray(array, 3,enemyCards);
        addOneTargetPosArray(array, 5,enemyCards);
    elseif (targetPos == 5)then
        addOneTargetPosArray(array, 2,enemyCards);
        addOneTargetPosArray(array, 4,enemyCards);
    end
    if(table.getn(array)  == 0)then
        return -1;
    end
    local idx=getRand(1,table.getn(array))
    return array[idx]
end


local function doSkillAction( attackSide, attackPos, round, action, attacker, enemyCards, myCards,skillId,skillLv,skillType,damagePercent,attackerPet,enemyPet)
    action.actionType =  ATTACK_TYPE_SKILL --技能攻击

    local enemyNum1 =gGetPlayerCardAlive(enemyCards);

    action.skillId=skillId
    local skillLevel =skillLv
    local skill = DB.getSkillById(skillId)
    if(skill == nil)then
        print("  error skill "..skillId)
        return
    end
    local function checkNoTarget(pos,action,skillDamage,enemyCards,skillDamage)
        if( skill.no_target  and skill.no_target > 0 and  skill.no_target< 100)then
            local targetPos= action.targetPosition
            if(skill.target_range == SKILL_RANGE_VERTICAL) then
                if(targetPos>=3)then
                    local enemy2 = enemyCards[targetPos-3]
                    if(enemy2 ~= nil and enemy2:isAlive())then
                        targetPos=targetPos-3
                    end
                end
            end

            if(pos ~=  targetPos)then
                skillDamage = skillDamage*skill.no_target/100;
            end
        end
        return  skillDamage
    end

    local targetPosArray=nil
    local c1 = getCountryBySide(attackSide);
    local c2 = getCountryBySide(getCounterSide(attackSide));
    local powerChange = gGetPowerChange(round.roundIndex);

    local param = 0

    for i=0, 1 do
        local buff =  getSkillBuff(skill,i)
        if(buff) then
            addBuffBeforeAction(buff, skillLevel, action, attackPos, attacker, enemyCards, myCards,buff.skill_range)
        end
    end

    local buffList = getSkillBuffList(skill)
    for k,buffid in pairs(buffList) do
        local buff = getBuffById(buffid)
        if(buff) then
            addBuffBeforeAction(buff, skillLevel, action, attackPos, attacker, enemyCards, myCards,buff.skill_range)
        end
    end

    if(skill.type == SKILL_TYPE_ATTACK )then
        --纯攻击技能或眩晕技能

        local sc = getSpiritChain(getCounterSide(attackSide))
        if(skill.target_range==SKILL_RANGE_RANDOM_NUM)then
            local targetPosArray={}
            local dmgCount={}
            for i=0, 5 do
                dmgCount[i]=0
            end
            table.insert(round.actions,action)--主要告诉客户端回复怒气
            action.skillId=(skillId*100);
            for i=1, skill.target_num do
                local pos = getOneRamdonTargetPos(enemyCards)
                if(i==1 and gBattleSelectRoles[1])then
                    pos=gBattleSelectRoles[1]
                end
                if(pos ~= nil)then
                    addTargetElement(pos, targetPosArray) ---添加被击目标位置，排重
                else
                    break;--都死光了
                end

                local actionNew =createPlayerAction(attackSide,attackPos);
                actionNew.skillType=(action.skillType);
                actionNew.actionType=(action.actionType);
                actionNew.skillId=(skillId*100+(i));--表示技能的分段action
                actionNew.targetPosition = pos---主目标可能改变，需要重置
                local enemyNum = gGetPlayerCardAlive(enemyCards);
                local enemy = enemyCards[pos];
                if(enemy ~= nil and enemy:isAlive())then
                    local skillDamage ,attack,defend= getSkillDamage(skill, skillLevel, attacker, enemy,skillType)
                    skillDamage = math.rint( skillDamage*math.pow(0.88, dmgCount[pos]))
                    local target=PlayerTarget.new()
                    target:setParam5(action,attackSide,attackPos,attacker,enemyNum,enemyCards,enemy,pos,skill,skillDamage,skillLevel,skillType,false,attackerPet,enemyPet,c1,c2,sc,powerChange)
                    table.insert(actionNew.targets,target)
                    dmgCount[pos] =dmgCount[pos] +1 --累加一次伤害
                end
                table.insert(round.actions,actionNew);

                if(enemy ~= nil and enemy:isAlive()==false)then
                    if(checkRecoverAfterDead( getCounterSide(attackSide), pos,round,  actionNew,  enemy, enemyCards)==false)then
                        doExplodeAfterDead(attackSide, attackPos, pos, round, actionNew, attacker, enemy, enemyCards, myCards)
                    end
                end
            end
        elseif(skill.target_range ==SKILL_RANGE_RANDOM_NEARBY)then
            --随机找相邻的目标
            table.insert(round.actions,action)--主要告诉客户端回复怒气
            action.skillId=(skillId*100);
            targetPosArray ={}

            local tmp =getTargetPosArray(attackPos,action.targetPosition,SKILL_RANGE_SINGLE, 1,enemyCards,nil,0,getSpiritChain(attackSide))

            for i=1, skill.target_num do

                local lastPos = tmp[table.getn(tmp)]
                local pos = getOneRamdonNearbyTargetPos(lastPos,enemyCards);
                if(i==1  )then
                    if( gBattleSelectRoles[1])then
                        pos=gBattleSelectRoles[1]
                    else
                        pos=lastPos
                    end
                end
                if(pos ~= -1)then
                    if(targetPosArray == nil)then
                        targetPosArray = {}
                    end
                    addTargetElement(pos, targetPosArray)--添加被击目标位置，排重
                    table.insert(tmp,pos);
                else
                    break;--都死光了
                end

                local actionNew =createPlayerAction(attackSide,attackPos);
                actionNew.skillType=(action.skillType);
                actionNew.actionType=(action.actionType);
                actionNew.skillId=(skillId*100+(i));--表示技能的分段action
                actionNew.targetPosition = pos---主目标可能改变，需要重置

                local enemyNum = gGetPlayerCardAlive(enemyCards);
                local enemy = enemyCards[pos];
                if(enemy ~= nil and enemy:isAlive())then
                    local skillDamage ,attack,defend= getSkillDamage(skill, skillLevel, attacker, enemy,skillType)
                    local target=PlayerTarget.new()
                    target:setParam5(actionNew,attackSide,attackPos,attacker,enemyNum,enemyCards,enemy,pos,skill,skillDamage,skillLevel,skillType,false,attackerPet,enemyPet,c1,c2,sc,powerChange)
                    table.insert(actionNew.targets,target)
                end
                table.insert(round.actions,actionNew);

                if(enemy ~= nil and enemy:isAlive()==false)then
                    if(checkRecoverAfterDead( getCounterSide(attackSide), pos,round,  actionNew,  enemy, enemyCards)==false)then
                        doExplodeAfterDead(attackSide, attackPos, pos, round, actionNew, attacker, enemy, enemyCards, myCards)
                    end
                end


            end
        else
            targetPosArray = getTargetPosArray(attackPos,action.targetPosition,skill.target_range, skill.target_num,enemyCards,nil,0,getSpiritChain(attackSide))
            if(table.getn(targetPosArray)  == 0)then
                print("!!!!!!!! error targetPosArray skillId = "..skill.skillid)
                return nil
            end
            action.targetPosition = targetPosArray[1] --主目标可能改变，需要重置

            local enemyNum =gGetPlayerCardAlive(enemyCards);
            for key, pos in pairs(targetPosArray) do
                local enemy = enemyCards[pos]
                if(enemy ~= nil and enemy:isAlive())then
                    local skillDamage ,attack,defend= getSkillDamage(skill, skillLevel, attacker, enemy,skillType)
                    skillDamage=checkNoTarget(pos,action,skillDamage,enemyCards,skillDamage)

                    if damagePercent ~= 100 then
                        skillDamage =  math.rint(skillDamage*damagePercent/100);
                    end
                    local target=PlayerTarget.new()
                    target:setParam5(action,attackSide,attackPos,attacker,enemyNum,enemyCards,enemy,pos,skill,skillDamage,skillLevel,skillType,false,attackerPet,enemyPet,c1,c2,sc,powerChange)
                    table.insert(action.targets,target)
                end
            end
            table.insert(round.actions,action)

            for key, pos in pairs(targetPosArray) do --//检查敌人是否有复活或自爆
                local enemy = enemyCards[pos]
                if(enemy ~= nil and enemy:isAlive()==false)then
                    if(checkRecoverAfterDead( getCounterSide(attackSide), pos,round,  action,  enemy, enemyCards)==false)then
                        doExplodeAfterDead(attackSide, attackPos, pos, round, action, attacker, enemy, enemyCards, myCards)
                    end
                end
            end
        end
        local scAction = createSpiritChainRemoveAction(getCounterSide(attackSide));
        if(scAction ~= nil)then
            table.insert(round.actions,scAction)
        end


    elseif(skill.type== SKILL_TYPE_HP_RECOVER)  then
        local extraPercent=0;
        if(skillType==1)then
            extraPercent=attacker.skillDamagePercent
        end
        local hpAdd = getHpRecover(attacker, skill.attr_id, skill.percent_value, skill.percent_add_value, skill.attr_value, skill.attr_add_value, skillLevel,extraPercent)
        param = hpAdd
        action.targetPosition = attackPos --补血时先把主目标设置在自己身上
        targetPosArray = getTargetPosArray(attackPos,action.targetPosition,skill.target_range, skill.target_num,myCards,nil,0,getSpiritChain(attackSide))
        action.targetPosition = targetPosArray[1]--主目标可能改变，需要重置
        for key, pos in pairs(targetPosArray) do
            local friend = myCards[pos]
            if(friend ~= nil and friend:isAlive())then
                local tmpAdd=0
                local addPercent = friend:getRecoverPercent()
                if(addPercent ~= 0)then
                    tmpAdd = math.rint( hpAdd*addPercent/100);--治疗效果增加
                end

                local playerTarget =  PlayerTarget.new()
                playerTarget:setParam3(attackSide,attacker,friend, pos,skill, hpAdd+tmpAdd,false,0,attackerPet)
                table.insert(action.targets,playerTarget)


            end
        end
        table.insert(round.actions,action)

    else
        print(skillId.."@@@@@@@@@@@ doSkillAction error skill type = "..skill.type)
    end



    gBattleSelectRoles={} --清楚选择人物

    local enemyNum2 =gGetPlayerCardAlive(enemyCards);
    local isEnemyKilled = enemyNum1-enemyNum2  > 0--判断是否造成击杀

    for i=0, 1 do
        local buff =  getSkillBuff(skill,i)
        if(buff) then
            addBuffAfterAction(buff, skillLevel, action,attackSide, attackPos, attacker, enemyCards, myCards, skillType,targetPosArray,param,isEnemyKilled)
        end

    end

    local buffList = getSkillBuffList(skill)
    for k,buffid in pairs(buffList) do
        local buff = getBuffById(buffid)
        if(buff) then
            addBuffAfterAction(buff, skillLevel, action,attackSide, attackPos, attacker, enemyCards, myCards, skillType,targetPosArray,param,isEnemyKilled)
        end
    end

    if(attackerPet ~= nil and action.skillType~=2 )then
        local hpAdd = attackerPet:getRecoverHp(attackPos,attacker)
        if(hpAdd > 0)then
            local playerTarget =  PlayerTarget.new()
            playerTarget.responseRound = 2
            playerTarget:setParam2(attacker,attackPos,hpAdd, false)
            table.insert(action.targets,playerTarget)
        end
    end

    if skill.type~= SKILL_TYPE_HP_RECOVER and targetPosArray ~= nil then
        for key, pos in pairs(targetPosArray) do
            local enemy = enemyCards[pos]
            if(enemy ~= nil and enemy:isAlive() == false )then
                doSkillAfterDead(getCounterSide(attackSide), pos, round, enemy);
            end
        end
    end

    return targetPosArray
end

-- 施放死亡后的技能
function doSkillAfterDead(attackSide, attackPos, round, enemy)
    local enemyCards = nil
    local myCards  = nil
    if(attackSide== SIDE1) then
        myCards= lplayerCards1
        enemyCards=lplayerCards2
    else
        myCards= lplayerCards2
        enemyCards=lplayerCards1
    end
    if isAllDead(myCards) then
        return
    end
    local percent = enemy:getRadiationSkillPercent()
    if percent and percent>0 then
        local skillId = enemy.attackSkillList[0][0]
        local skillLv = enemy.attackSkillList[0][1]
        local attackerPet = nil
        local   enemyPet = nil
        if(attackSide == SIDE1)then
            attackerPet = lplayerPet1
            enemyPet = lplayerPet2
        else
            attackerPet = lplayerPet2
            enemyPet = lplayerPet1
        end
         local actionNew =createPlayerAction(attackSide,attackPos);
         doSkillAction(attackSide, attackPos, round, actionNew, enemy, enemyCards,myCards, skillId, skillLv, SKILL_TYPE_GREAT, percent, attackerPet, enemyPet)
         actionNew.actionType=ACTION_TYPE_SKILL_AFTER_DIE
         actionNew.skillType=SKILL_TYPE_GREAT
    end
end



function getLiveCardNum(  activeSide)
    local cards=nil
    if(activeSide == SIDE1) then
        cards= lplayerCards1
    else
        cards= lplayerCards2
    end
    local count = 0
    for key, card in pairs(lplayerCards1) do
        if(card ~= nil and card:isAlive())then
            count=count+1
        end
    end
    return count;
end

local function doPlayerAction(round,  attackSide,  attackPos,  attacker,  enemyCards ,  myCards )
    local action=createPlayerAction(attackSide ,attackPos)
    action.targetPosition =  findTargetPos(attackPos,enemyCards,-1)
    if(action.targetPosition == -1)then
        print(attacker.cardid.." @@@@@@@@@@@ action.targetPosition == -1")
        setWinner(attackSide)
        return true
    end





    local attackerPet = nil
    local   enemyPet = nil
    if(attackSide == SIDE1)then
        attackerPet = lplayerPet1
        enemyPet = lplayerPet2
    else
        attackerPet = lplayerPet2
        enemyPet = lplayerPet1
    end

    local attackSkillPos = attacker:getAttackSkillPos()
    if(attackSkillPos ~= -1)then --5个技能触发哪一个
        local skillType =0--是普攻还是大招
        if(gIsSkinAttack) then
            gIsSkinAttack=false
            attackSkillPos=1
        end

        if(attackSkillPos==0) then
            skillType=SKILL_TYPE_GREAT
        else
            skillType=SKILL_TYPE_NORMAL
        end

        for key, buffData in pairs(attacker.cardBuffList) do
            local buffId = buffData[0]
            if(buffId and buffId > 0) then
                local buff =  DB.getBuffById(buffId)
                if(buff ~= nil) then
                    addBuffBeforeAction(buff,buffData[1], action, attackPos, attacker, enemyCards,myCards,skillType)
                end
            end
        end


        if(attackerPet~=nil)then
            for key, buff in pairs(attackerPet.buffList) do
                if(buff.trigger_moment == BUFFER_TRIGGER_MOMENT_BEFORE_ACTION) then
                    if(isBuffInRange(buff,attackPos) )then
                        addBuffBeforeAction(buff, attackerPet.buffLevel[key], action, attackPos, attacker, enemyCards,myCards,skillType)
                    end
                end
            end
        end


        if(attackSkillPos == 0)then--大招技能
            attacker:resetRage()--怒气清零
            action.skillType=1--设置大招变量
        else
            if(attacker:isSkillLocked()==false)then
                action.rageAdd = 1
                attacker:addRage(action.rageAdd)
            else
                print("skill lock "..attackPos)
            end
            action.skillType=0
        end
        --// 背锅侠技能要特殊处理
        local skillId = attacker.copySkillId[attackSkillPos]
        if  skillId == nil or skillId == 0 then
            skillId = attacker.attackSkillList[attackSkillPos][0]
        end
        local skillLv = attacker.attackSkillList[attackSkillPos][1]
        local skill=nil

        if(attacker.cardid == Card_MIKU)then
            local sc = getSpiritChain(attackSide);
            if(sc ~= nil)then
                if(attackSkillPos==0)then
                    skillId=sc.skillId0
                else
                    skillId=sc.skillId1
                end
                --灵魂状态重新设置技能ID
            end
        end
        if(attackSkillPos == 0)then
            local card = DB.getCardById(attacker.cardid)
            skill = DB.getSkillById(skillId)
            if(card.skillid2 > 0)then
                skill = DB.getSkillById(card.skillid2)
                if(checkCooperateCard(skill,myCards))then
                    skillId = card.skillid2
                end
            end
        end
        local enemyNum1 = gGetPlayerCardAlive(enemyCards);
        local  targetPosArray= doSkillAction(attackSide,attackPos, round, action, attacker, enemyCards,myCards,skillId,skillLv,skillType,100,attackerPet,enemyPet)

        if( skill~= nil and  triggerExtraSkill(skill) and attacker:isAlive() and isAllDead(enemyCards)==false )then
            local action2 =createPlayerAction(attackSide,attackPos);
            action2.targetPosition =  findTargetPos(attackPos,enemyCards,-1) --获取攻击目标的位置
            action2.skillType=2
            doSkillAction(attackSide,attackPos, round, action2, attacker, enemyCards,myCards, skill.extra_skill,skillLv,2,100,attackerPet,enemyPet);
        end

        local enemyNum2 = gGetPlayerCardAlive(enemyCards); 
        local isEnemyKilled = false
        if enemyNum1-enemyNum2>0 then
            isEnemyKilled = true
        end
        if(attacker:isAlive() and targetPosArray~=nil)then

            for key, buffData in pairs(attacker.cardBuffList) do
                local buffId = buffData[0]
                if(buffId and buffId > 0) then

                    local buff =  DB.getBuffById(buffId)
                    if(buff ~= nil and buff.trigger_moment==BUFFER_TRIGGER_MOMENT_AFTER_ACTION) then
                        addBuffAfterAction(buff, buffData[1], action,attackSide, attackPos, attacker, enemyCards,myCards,skillType,targetPosArray,nil,isEnemyKilled)
                    end
                end
            end

            if(attackerPet~=nil)then
                for key, buff in pairs(attackerPet.buffList) do
                    if(isBuffInRange(buff,attackPos) )then
                        if(   buff.trigger_moment==BUFFER_TRIGGER_MOMENT_AFTER_ACTION) then
                            addBuffAfterAction(buff, attackerPet.buffLevel[key], action, attackSide,attackPos, attacker, enemyCards,myCards,skillType,targetPosArray,nil,isEnemyKilled)
                        end
                    end
                end
            end
        end
    else
        print(attacker.cardid.."@@@@@@@@@@@ doPlayerAction attackSkillPos == -1")
    end



    if(attackerPet~=nil)then
        if(isAllDead(myCards)==false and isAllDead(enemyCards)==false  )then
            local pnum = getLiveCardNum(attackSide);
            attackerPet:addTriggerRate(pnum)
            if(attackerPet:isTriggerSkill(gGetPlayerCardAlive(myCards)))then
                local pet = DB.getPetById(attackerPet.petid)
                local skill = DB.getSkillById(pet.skillid)
                local petAction = createPetAction(round,attackSide, attackPos, attacker, enemyCards,myCards, attackerPet,enemyPet,skill)
                if(petAction~=nil)then
                    --table.insert(round.actions,petAction)

                    if(triggerExtraSkill(skill))then--猴子的附加技能
                        local skill2 = DB.getSkillById(skill.extra_skill );
                        local petAction2 = createPetAction(round,attackSide, attackPos, attacker, enemyCards,myCards, attackerPet,enemyPet,skill2);

                        if(petAction2 ~=nil)then
                            petAction2.skillType=2
                           --table.insert(round.actions,petAction2)
                        end
                    end

                end
            end
        end
    end
    if(isAllDead(myCards)) then
        setWinner(getCounterSide(attackSide))
        return true
    elseif(isAllDead(enemyCards))then
        setWinner(attackSide)
        return true
    else

    end
    return false

end


function triggerExtraSkill(skill)
    if(skill.extra_skill~= 0)then
        return  getRand(0,100)<skill.extra_skill_rate
    end
    return false;
end

function  getCountryBySide(  side)
    if(side == SIDE1)then
        return gBattleCountry1
    else
        return gBattleCountry2
    end
end


function  createPetAction( round, attackSide,  attackPos,  attacker,  enemyCards,  myCards,  attackerPet,enemyPet,skill)

    local targetPosArray =nil
    local petAction =nil
    local param=0
    --纯攻击技能或眩晕技能
    if(skill.type == SKILL_TYPE_ATTACK)then
        local targetPosition = findTargetPos(attackPos, enemyCards, skill.target_range)
        if(enemyCards[targetPosition] ~=nil and enemyCards[targetPosition]:isAlive() )then
            --attackerPet:addTriggerCount();
            petAction = createPlayerAction(attackSide, 6)
            targetPosArray = getTargetPosArray(attackPos,targetPosition,skill.target_range, skill.target_num,enemyCards,nil,0,nil)

            table.insert(round.actions,petAction)
            petAction.targetPosition=targetPosArray[1] --重新设置主目标
            local attackParam = attackerPet.attackParam/10000;--万分比
            
            local skillDamage = math.rint(skill.attr_value+(attackerPet.skill_level-1)*skill.attr_add_value+attacker.price*attackParam*skill.percent_value/100)

            local enemyNum = gGetPlayerCardAlive(enemyCards);

            for key, pos in pairs(targetPosArray) do
                local enemy1 = enemyCards[pos]
                if(enemy1 ~= nil and enemy1:isAlive())then
                    local target=PlayerTarget.new()

                    local c1 = getCountryBySide(attackSide);
                    local c2 = getCountryBySide(getCounterSide(attackSide));
                    local sc = getSpiritChain(getCounterSide(attackSide))
                    target:setParam5(petAction,attackSide,attackPos,attacker,enemyNum,enemyCards,enemy1,pos,skill,skillDamage,attackerPet.skill_level,SKILL_TYPE_ALL,true,attackerPet,enemyPet,c1,c2,sc,100)


                    table.insert(petAction.targets,target)

                    if(enemy1:isAlive() ==false)then
                        checkRecoverAfterDead(getCounterSide(attackSide),pos,round, petAction, enemy1, enemyCards);
                    end
                    if(enemy1:isAlive() ==false)then
                        doSkillAfterDead(getCounterSide(attackSide), pos, round, enemy1);
                    end
                end
            end
        end
    elseif(skill.type == SKILL_TYPE_HP_RECOVER)then
        local attackParam = attackerPet.attackParam/10000;--万分比
        local hpAdd = math.rint(skill.attr_value+(attackerPet.skill_level-1)*skill.attr_add_value+attacker.price*attackParam*skill.percent_value/100)
        param=hpAdd
        petAction = createPlayerAction(attackSide,6)
        table.insert(round.actions,petAction)
        petAction.targetPosition = attackPos  --补血时先把主目标设置在自己身上
        targetPosArray  = getTargetPosArray(attackPos,petAction.targetPosition,skill.target_range, skill.target_num,myCards,nil,0,nil);
        petAction.targetPosition =targetPosArray[1] --主目标可能改变，需要重置


        for key, pos in pairs(targetPosArray) do
            local friend = myCards[pos];
            if(friend ~= nil and friend:isAlive())then
                local playerTarget =   PlayerTarget.new()
                local tmpAdd=0
                local addPercent= friend:getRecoverPercent()
                if(addPercent ~= 0)then
                    tmpAdd = math.rint( hpAdd*addPercent/100);--治疗效果增加
                end
                playerTarget:setParam3(attackSide,attacker,friend, pos,skill, hpAdd+tmpAdd,true,attackerPet.petid,attackerPet)
                table.insert(petAction.targets,playerTarget)
            end
        end
    end



    if(petAction ~= nil and skill.isextra==0)then
        for i=0, 1 do
            local buff =  getSkillBuff(skill,i)
            if(buff ~= nil and buff.trigger_moment == BUFFER_TRIGGER_MOMENT_AFTER_PET_ACTION)then
                addBuffAfterAction(buff, attackerPet.skill_level, petAction,attackSide, attackPos, attacker, enemyCards, myCards,SKILL_TYPE_ALL,targetPosArray,param,false);
            end
        end

        local buffList = getSkillBuffList(skill)
        for k,buffid in pairs(buffList) do
            local buff = getBuffById(buffid)
            if(buff ~= nil and buff.trigger_moment == BUFFER_TRIGGER_MOMENT_AFTER_PET_ACTION )then
                addBuffAfterAction(buff, attackerPet.skill_level, petAction,attackSide, attackPos, attacker, enemyCards, myCards,SKILL_TYPE_ALL,targetPosArray,param,false);
            end
        end

        for key, buff in pairs(attackerPet.buffList) do
            if(buff.trigger_moment == BUFFER_TRIGGER_MOMENT_AFTER_PET_ACTION) then
                if(isBuffInRange(buff,attackPos) )then
                    addBuffAfterAction(buff, attackerPet.buffLevel[key], petAction,attackSide, attackPos, attacker, enemyCards,myCards,SKILL_TYPE_ALL,targetPosArray,param,false)
                end
            end
        end
    end
    return petAction
end

function getPlayerPetBySide( activeSide)
    if(activeSide == SIDE1)then
        return lplayerPet1
    else
        return lplayerPet2
    end
end

function doExplodeAfterDead(  attackSide,  attackPos,  targetPos,  round,  action,  attacker,  enemy,  enemyCards, myCards)
--[[  local hpPercent = enemy:getReliveHpPercent()
if(hpPercent == 0)then
local pet = getPlayerPetBySide(getCounterSide(attackSide))
if(pet ~= nil)then
hpPercent = pet:getReliveHpPercent(targetPos,attacker.reliveCount)
end
end

if(Battle.battleType==BATTLE_TYPE_ATLAS_PET   )then
if(gBattleCurReliveNum<gBattleTotalReliveNum)then
hpPercent=100
gBattleCurReliveNum=gBattleCurReliveNum+1
end
end

if(hpPercent > 0) then
local value = math.rint( enemy.hpInit*hpPercent/100)
local reliveTarget =   PlayerTarget.new()
enemy:relive(value)
reliveTarget:setParam1( targetPos, RESPONSE_TYPE_RELIVE,  0, value,true,nil)
table.insert(action.targets,reliveTarget)
else
for j=2, 4 do
local explodeBuff = enemy:getExplodeBuff(j)
if(explodeBuff ~= nil)then
local damagePercent = getAttrValue0(explodeBuff,enemy.attackSkillList[j][1])
local attrValue = enemy:getAttackOrDefendValue(explodeBuff.attr_id0)
local damage = math.rint(attrValue*damagePercent/100)
local explodeAction =createPlayerAction(getCounterSide(attackSide), targetPos)
explodeAction.targetPosition=attackPos
explodeAction.actionType= ACTION_TYPE_EXPLODE
local explodeTargetPosArray = getTargetPosArray(targetPos,attackPos,explodeBuff.target_range, explodeBuff.target_num,myCards)
if(explodeTargetPosArray ~= nil and table.getn(explodeTargetPosArray) > 0)then
for key, index in pairs(explodeTargetPosArray) do
local card = myCards[index]
if(card ~=nil and card:isAlive())then
local target=  PlayerTarget.new()
target:setParam4(explodeAction,card, index, damage, RESPONSE_TYPE_EXPLODE_DAMAGE,true)
table.insert(explodeAction,table)
if(card:isAlive())then
checkRecoverAfterDead(getCounterSide(attackSide), index,round, explodeAction, card, myCards)
end
end
end
table.insert(round.actions,explodeAction)--把自爆的动作系列加入列表
end

end
local recoverBuff = enemy:getRecoverFriendAfterDeadBuff(j)
if(recoverBuff ~= nil)then --死亡后给队友回血
local recoverTargetPosArray = getTargetPosArray(targetPos,targetPos,recoverBuff.target_range, recoverBuff.target_num,enemyCards)
if(recoverTargetPosArray ~= nil and table.getn(recoverTargetPosArray) > 0)then
local buffLevel = enemy.attackSkillList[j][1]
for k=0, table.getn(recoverTargetPosArray)-1 do

local friend = enemyCards[k]
if(friend ~=nil)then
local percent = getAttrValue0(recoverBuff,buffLevel)--回血百分比
local exHp = getAttrValue1(recoverBuff,buffLevel)--回血固定值
local hpRecover = math.rint( friend.hpInit*percent/100+exHp)
local playerTarget = PlayerTarget.new()
playerTarget:setParamt2(attacker, attackPos, hpRecover,true)
table.insert(action.targets,playerTarget)
end
end
end
end
end
end]]
end

--[[
* 检查死后是否复活或者给队友加血
* @param activeSide 死亡的一方
* @param targetPos 死亡者的位置
* @param round 回合对象
* @param action 当前动作对象
* @param pCard 死亡的卡牌对象
* @param myCards 死亡一方的所有卡牌
* @return 有复活或者有给队友加血
*/
]]
function checkRecoverAfterDead( activeSide, targetPos, round, action,  pCard,  myCards )
    local rateReduce = 0;
    local attackPet = getPlayerPetBySide(getCounterSide(activeSide))
    if(attackPet ~= nil)then
        rateReduce = attackPet:getReduceReliveRate();--攻击方的宠物是否有减少对方复活概率的BUFF
    end

    local hpPercent = pCard:getReliveLimitCountHpPercent() --//优先判断必定复活buff
    if hpPercent==0 then
        hpPercent = pCard:getReliveHpPercent(rateReduce)
    end
    local hpPercent1 =0 --/宠物复活百分比
    local hpPercent2 = {} --//希尔瓦纳斯复活技能 0复活百分比 1消耗血量百分比 2卡牌位置
    if(hpPercent == 0)then
        local pet = getPlayerPetBySide(activeSide)
        if(pet ~= nil)then
            hpPercent1 =  pet:getReliveHpPercent(targetPos,pCard.reliveCount,rateReduce)
        end
    end

    if hpPercent == 0 and hpPercent1==0 then
        hpPercent2=getReliveHpPercent(myCards)
    end

    if(Battle.battleType==BATTLE_TYPE_ATLAS_PET)then
        if(gBattleCurReliveNum<gBattleTotalReliveNum)then
            hpPercent=100
            gBattleCurReliveNum=gBattleCurReliveNum+1
        end
    end



    if(hpPercent > 0 or hpPercent1>0 or hpPercent2[0]>0 ) then

        local value = 0;
        if(hpPercent > 0)then
            value = math.rint( pCard.hpInit*hpPercent/100)
        elseif(hpPercent1 > 0)then
            local pet = getPlayerPetBySide(activeSide)
            value = math.rint(pet.level*hpPercent1)  ---兔子的复活不按血量百分比
        elseif hpPercent2[0]>0 then --希尔瓦娜斯复活
            value = math.rint( pCard.hpInit*hpPercent2[0]/100)
            local  pos = hpPercent2[2]
            local card = myCards[pos]
            local dmg =  hpPercent2[1]
            card:attacked(dmg) --扣血
            local action2 = createPlayerAction(activeSide, pos)
            action2.actionType = ACTION_TYPE_REDUCE_HP
            local target = PlayerTarget.new()
            target:setParam1(pos, RESPONSE_TYPE_REDUCE_HP_RELIVE_FRIEND, 0, dmg,false,nil)
            local  effect = createTargetEffect(EFFECT_TYPE_DAMAGE, Attr_HP, dmg, false)
            table.insert(target.effectList,effect)

            table.insert(action2.targets,target)
            table.insert(round.actions,action2)
        end

        local reliveTarget = PlayerTarget.new()
        reliveTarget:setParam1(targetPos, RESPONSE_TYPE_RELIVE, 0, value,true,nil)
        table.insert(action.targets,reliveTarget)
        pCard:relive(value)

        if(attackPet ~= nil)then
            ---复活后属性降低
            local petBuff,buffLevel = attackPet:getReduceAttrAfterRelive()
            if(petBuff ~= nil)then
                local buff = DB.getBuffById(petBuff.buffid);
                local attrValue = math.rint(getAttrValue0(buff,buffLevel));

                if( buff.attr_id0==Attr_HURT_RAISE)then
                    attrValue=attrValue
                else
                    attrValue=-attrValue
                end
                local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE,attr,attr_value,buff.round )
                pCard:addPlayerBuff(pbuff)
                local  effect = createTargetEffect(EFFECT_TYPE_ATTR_REDUCE, buff.attr_id0, attrValue, false)
                table.insert(reliveTarget.effectList,effecct)
            end
        end
        local pet = getPlayerPetBySide(activeSide)
        if pet and pet:reliveIsAddRage() then --灵兽复活增加怒气
            local pet_attr = Attr_RAGE
            local pet_attr_value = 2
            local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE,pet_attr,pet_attr_value,0 )
            pCard:addPlayerBuff(pbuff)
            local effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD,pet_attr,pet_attr_value,false)
            local petTarget = PlayerTarget.new()
            petTarget:setParam1(targetPos, RESPONSE_TYPE_ATTR_CHANGE, 0, 0,true,effect)
            table.insert(action.targets,petTarget)
        end
        return true
    else
        local ret = false
        for key, buffData in pairs(pCard.cardBuffList) do
            local buffId = buffData[0]
            local buff = DB.getBuffById(buffId)

            if(buff ~= nil and buff.type == BUFFER_TYPE_RECOVER_FRIEND_AFTER_DEAD)then
                if(gCheckBuffRate(buff,buffData[1] ,SKILL_TYPE_ALL))then

                    local recoverTargetPosArray = getTargetPosArray(targetPos,targetPos,recoverBuff.target_range, recoverBuff.target_num,myCards,nil,buff.target_card,getSpiritChain(activeSide))
                    if(recoverTargetPosArray ~= nil and  table.getn(recoverTargetPosArray) > 0)then
                        local buffLevel =buffData[1]
                        local recoverAction = createPlayerAction(activeSide, targetPos)
                        recoverAction.actionType = ACTION_TYPE_RECOVER_FRIEND_AFTER_DIE

                        for key, pos in pairs(recoverTargetPosArray) do

                            local friend =  myCards[pos]
                            if(friend  ~=nil and friend:isAlive() )then
                                local percent = getAttrValue0(recoverBuff,buffLevel)--回血百分比
                                local exHp = getAttrValue1(recoverBuff,buffLevel)--回血固定值
                                local hpRecover = math.rint( friend.hpInit*percent/100+exHp)
                                local playerTarget =PlayerTarget.new()
                                playerTarget:setParam2(friend, pos, hpRecover,false)
                                table.insert(recoverAction.targets,playerTarget)
                                ret = true
                            end
                        end

                        if(table.getn(recoverAction.targets)>0)then
                            table.insert(round.actions,recoverAction)
                        end
                    end
                end
            end
        end
        return ret
    end
end


local function checkReduceHpBuff(  round, activeSide, order,  card,  playerCards)
    local pbuff = card:getReduceHpBuff()
    if(pbuff ~= nil) then --每回合掉血
        local action = createPlayerAction(order.side, order.pos)
        action.actionType=ACTION_TYPE_REDUCE_HP

        local target=PlayerTarget.new()
        local dmg =math.min( math.rint( card.hp*pbuff.value/100) ,pbuff.param)--每回合掉血百分比

        target:setParam4(action,card, order.pos,dmg, RESPONSE_TYPE_REDUCE_HP,false)
        table.insert(action.targets,target)
        if(card:isAlive()==false)then
            checkRecoverAfterDead(activeSide,order.pos,round, action, card, playerCards)
        end
        table.insert(round.actions,action)
        if card:isAlive() == false then
            doSkillAfterDead(order.side, order.pos, round, card);
        end
    end
end



local function createBuffRemoveAction(  buffRemovelist,  attackSide,  attackPos)
    local action = createPlayerAction(attackSide, attackPos)
    action.actionType =  ACTION_TYPE_REMOVE_BUFF

    for key, buff in pairs(buffRemovelist) do
        local buffType=buff.type
        local removeType =  (buffType + 100)
        local target = PlayerTarget.new()
        local effect = nil
        if(buff.type ==  RESPONSE_TYPE_IMMUNE)then--移除免疫的时候告诉客户端是哪一类型
            effect = createTargetEffect(EFFECT_TYPE_IMMNUE_REMOVE, buff.attr, 0, false)
        elseif(buff.type ==  RESPONSE_TYPE_ATTR_CHANGE)then--除减伤的时候告诉客户端
            effect = createTargetEffect(EFFECT_TYPE_ATTR_REDUCE, buff.attr, 0, false)
        end

        target:setParam1(attackPos, removeType,   0, 0, false, effect)
        table.insert(action.targets,target)
    end

    return action
end




local function createAttackOrder(  side,  pos)
    return
        {
            side = side,
            pos = pos
        }
end

local function getOrderAgility(  order)
    if(order.side == SIDE1) then
        return lplayerCards1[order.pos].agility
    else
        return lplayerCards2[order.pos].agility
    end
end

local function insertOrderList(orderList,  playerCards,  side)
    for i=0, MAX_TEAM_NUM-1 do
        if(playerCards[i]~=nil) then
            local agility = playerCards[i].agility
            playerCards[i].curSide=side
            local newOrder = createAttackOrder( side,  i)
            local isInsert = false --是否已经插入队列

            for key, var in pairs(orderList) do
                if(agility > getOrderAgility(var))then
                    table.insert(orderList,key,newOrder)
                    isInsert = true
                    break
                end
            end

            if( isInsert==false)then --插入队列末端
                table.insert(orderList,newOrder)
            end
        end
    end

end

local function sortAttackOrder()
    local orderList={}
    --[[insertOrderList(orderList,lplayerCards1,SIDE1)
    insertOrderList(orderList,lplayerCards2,SIDE2)
    ]]

    for i=0, 5 do
        table.insert( orderList,createAttackOrder( SIDE1,  i))

        table.insert( orderList,createAttackOrder( SIDE2,  i))

    end
    return orderList
end

function getCounterSide(  activeSide)
    if(activeSide == SIDE1) then
        return SIDE2
    else
        return SIDE1
    end
end


function  checkBuffRemove(  actionRound)
    for i=0, 5 do
        local card=lplayerCards1[i]
        if(card and card:isAlive())then
            local buffRemovelist = card:resetBuffRound(SIDE1,i)
            if(table.getn( buffRemovelist) > 0) then
                table.insert(actionRound.actions,createBuffRemoveAction(buffRemovelist,  SIDE1,i))
            end
        end
        local card=lplayerCards2[i]
        if(card and card:isAlive())then


            local buffRemovelist = card:resetBuffRound(SIDE2,i)
            if(table.getn( buffRemovelist) > 0) then
                table.insert(actionRound.actions,createBuffRemoveAction(buffRemovelist, SIDE2,i))
            end
        end
    end
end

local function escapeCard(card,order,actions)
    if(card==nil or card:isAlive()==false)then
        return false
    end

    if(card.escapeRound==nil)then
        return false
    end

    local action=createPlayerAction(order.side, order.pos)
    card.escapeRound=card.escapeRound-1
    action.skillId=card.escapeRound
    action.actionType=ACTION_TYPE_PREPAIR_ESCAPE
    table.insert(actions,action)

    if(card.escapeRound==0)then
        local action=createPlayerAction(order.side, order.pos)
        action.skillId=0
        card.hp=0
        action.actionType=ACTION_TYPE_ESCAPE
        table.insert(actions,action)
        return true
    end
    return false

end

local function checkRoundBuff(  round,orderList)
    if(lplayerPet1 ~=nil)then
        local action = createPlayerAction(SIDE1, 0);
        action.actionType=ACTION_TYPE_ROUND_BUFF

        for key, buff in pairs(lplayerPet1.buffList) do
            local level=lplayerPet1.buffLevel[key]
            if(buff.trigger_moment ==BUFFER_TRIGGER_MOMENT_BEFORE_ROUND)then
                addBuffAfterAction(buff,  level, action, SIDE1,   0, nil, lplayerCards2, lplayerCards1, buff.target_range, nil, 0, false);
            end
        end
        if(table.getn(action.targets) > 0)then
            table.insert( round.actions,action);
        end
    end

    if(lplayerPet2 ~=nil)then
        local action = createPlayerAction(SIDE2, 0);
        action.actionType=ACTION_TYPE_ROUND_BUFF

        for key, buff in pairs(lplayerPet2.buffList) do
            local level=lplayerPet2.buffLevel[key]
            if(buff.trigger_moment ==BUFFER_TRIGGER_MOMENT_BEFORE_ROUND)then
                addBuffAfterAction(buff,  buffLevel, action, SIDE2,   0, nil, lplayerCards1, lplayerCards2, buff.target_range, nil, 0, false);
            end
        end
        if(table.getn(action.targets) > 0)then
            table.insert( round.actions,action);
        end
    end
    --// 人物大回合buff
    for key, order in pairs(orderList) do
        local cards=nil
        local otherCards=nil
        if(order.side == SIDE1) then
            cards= lplayerCards1
            otherCards=lplayerCards2
        else
            cards= lplayerCards2
            otherCards=lplayerCards1
        end
        local card = cards[order.pos]
        if card and card:isAlive() then
             for key, buffData in pairs(card.cardBuffList) do
                local buffId = buffData[0]
                if(buffId and buffId > 0) then
                    local buff =  DB.getBuffById(buffId)
                    if(buff.trigger_moment == BUFFER_TRIGGER_MOMENT_BEFORE_ROUND) then
                        local action = createPlayerAction(order.side, order.pos);
                        action.actionType=ACTION_TYPE_ROUND_BUFF
                        if buff.type == BUFFER_TYPE_CLEAR_HARMFUL_BUFF then
                            action.actionType=ACTION_TYPE_ROUND_REMOVE_BUFF
                        end
                        addBuffAfterAction(buff,1, action, order.side,order.pos, card, otherCards, cards, buff.target_range, nil, 0, false);
                         if(table.getn(action.targets) > 0)then
                            table.insert( round.actions,action);
                         end
                    end
                end
            end
        end
    end

end

local function doBattleRound(orderList,actionRound,lastOrder)

    if(lastOrder==nil)then  
        checkRoundBuff(actionRound,orderList);
    end
    local lastPassPos=false --是否经过了上次中断部分
    for key, order in pairs(orderList) do

        local cards=nil
        local otherCards=nil
        if(order.side == SIDE1) then
            cards= lplayerCards1
            otherCards=lplayerCards2
        else
            cards= lplayerCards2
            otherCards=lplayerCards1
        end



        local canContinue=true
        if(lastOrder and lastPassPos==false )then
            canContinue=false
            if(lastOrder.pos==order.pos and lastOrder.side==order.side)then
                lastPassPos=true
                lastOrder=nil
            end
        end


        local card = cards[order.pos]
        if(lastOrder==nil and lastPassPos==false)then
            checkBuffRemove(  actionRound)
        end
        if(card)then
            if(lastPassPos) then  --断点继续
                lastPassPos=false
                canContinue=false
                gLastBattleOrderList=nil
                gLastBattleOrder=nil
                gLastBattleRound=nil
                gBattleNeedSelectNum=0
                gBattleSelectRolesRange={}
                local ret=doPlayerAction(actionRound,order.side, order.pos, card, otherCards, cards)
                gBattleSelectRoles={}
                if(ret)then
                    return true,false
                end
            end

            if(canContinue)then
                if card:isAlive() then

                    checkReduceHpBuff(actionRound, order.side ,order, card, cards) --//是否有每回合掉血

                    if(card:isStuning() or card:isFrozen() or card:isAlive()==false)then --是否还在眩晕状态
                    else

                        local attackSkillPos = card:getAttackSkillPos() --设置大招断点
                        if( attackSkillPos==0 and order.side == SIDE1 and gIsAutoBattle==false)then
                            gLastBattleOrderList=orderList --记录大招前的出手顺序
                            gLastBattleOrder=order
                            gLastBattleRound=actionRound
                            gBattleSelectRolesRange={}--可以选择的卡牌范围

                            --local skillId = card.attackSkillList[attackSkillPos][0]
                            local skillId = card.copySkillId[attackSkillPos]
                            if  skillId == nil or skillId == 0 then
                                skillId = card.attackSkillList[attackSkillPos][0]
                            end
                            local skillLevel = card.attackSkillList[attackSkillPos][1]
                            if(card.cardid == Card_MIKU)then
                                local sc = getSpiritChain(order.side);
                                if(sc ~= nil)then
                                    if(attackSkillPos==0)then
                                        skillId=sc.skillId0
                                    else
                                        skillId=sc.skillId1
                                    end
                                end
                            end
                            local skill = DB.getSkillById(skillId)
                            if(skill)then
                                local attackPos=order.pos
                                gBattleNeedSelectNum=skill.target_num
                                local action=createPlayerAction(order.side, order.pos)
                                local targetPosition= findTargetPos(attackPos,otherCards,-1)
                                if(skill.type== SKILL_TYPE_HP_RECOVER)  then
                                    action.isEnemy =false
                                    gBattleSelectRolesRange=getTargetPosArray(attackPos,targetPosition,skill.target_range, skill.target_num,cards,true,0)
                                elseif(skill.type== SKILL_TYPE_ATTACK)  then
                                    action.isEnemy =true
                                    gBattleSelectRolesRange= getTargetPosArray(attackPos,targetPosition,skill.target_range, skill.target_num,otherCards,true,0)

                                end
                                action.actionType=ACTION_TYPE_SELECT_TARGET
                                table.insert(actionRound.actions,action)
                            end
                            return false,true
                        end


                        if(Battle.battleType==BATTLE_TYPE_ATLAS_PET and order.side == SIDE2) then

                        elseif(Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL and order.side == SIDE2) then
                            if( escapeCard(cards[order.pos],order,actionRound.actions))then
                                if(Battle.curBattleGroup<Battle.maxBattleGroup )then
                                    return true,false
                                end
                            end
                        elseif(doPlayerAction(actionRound,order.side, order.pos, card, otherCards, cards))then
                            return true,false
                        end
                    end
                end
            end

        end

    end

    return false,false
end


local function startBattle()
    gBattleSelectRolesRange={}
    for i=1, MAX_ROUND-1 do
        local orderList=sortAttackOrder()
        local actionRound={roundIndex=i-1,actions={}}
        if(i==1)then --判断有没有出场buff
            checkAppearanceBuff(orderList, actionRound);
            --背锅侠变身
            checkHeroChange(orderList, actionRound);
            --灵兽出场buff
            checkPetAppearanceBuff(actionRound);
        end

        local isBattleEnd,isBattleBreak=doBattleRound(orderList,actionRound)
        table.insert(lbattleRoundList,actionRound)
        Battle.addLog(actionRound)
        gIsBattleBreak=isBattleBreak
        if(isBattleEnd or isBattleBreak) then
            return
        end
    end

end
--[[
* 获取灵魂锁链被锁链者的位置列表
* @param playerCards 攻击方所有卡牌
* @param attackPos 释放者位置
* @return 被锁链者的位置列表
*]]
local function getSpiritChainPos(  playerCards,  attackPos)
    local vec = {}

    for i=0,2 do
        if(i ~= attackPos and playerCards[i] ~= nil)then
            table.insert(vec,i);
        end
    end
    if(table.getn(vec) == 3)then
        local rand = getRand(1,3);
        table.remove(vec,rand)
    elseif(table.getn(vec)  < 2)then
        local num = 2-table.getn(vec)
        local count=0
        for i=3, 5 do
            --后排按顺序选，非随机
            if(count<num)then
                if(i ~= attackPos and playerCards[i] ~= nil)then
                    table.insert(vec,i);
                    count=count+1
                end
            end
        end
    end

    return vec;
end




--[[***
* 生成一个释放出场buff的action
* @param attackSide 攻击方
* @param attackPos 释放者位置
* @param buffId
* @return 如果不满足释放条件返回null
*]]
function createAppearanceAction(  attackSide ,  attackPos,  buffId)
    local action = createPlayerAction(attackSide, attackPos);
    action.actionType=ACTION_TYPE_APPEARANCE
    local buff = DB.getBuffById(buffId);
    if(buff.type == BUFFER_TYPE_SPIRIT_CHAIN)then--灵魂锁链


        local playerCards=nil
        if(attackSide== SIDE1) then
            playerCards= lplayerCards1
        else
            playerCards= lplayerCards2
        end

        local posVec = getSpiritChainPos(playerCards, attackPos);
        if(table.getn(posVec) == 0)then
            local action = createPlayerAction(attackSide, attackPos);
            action.actionType=ACTION_TYPE_CHANGE_STATUS
            return action
        end
        local sc=SpiritChain.new(playerCards[attackPos].cardid,attackPos, posVec)
        setSpiritChain(attackSide, sc);
        local target1 = PlayerTarget.new()
        target1:setParam1(attackPos, RESPONSE_TYPE_SPIRIT_CHAIN,   0, 0, false, nil);
        table.insert(action.targets,target1)--释放者也加上灵魂状态
        for key, pos in pairs(posVec) do
            local target = PlayerTarget.new()
            target:setParam1(pos, RESPONSE_TYPE_SPIRIT_CHAIN_GET,  attackPos, 0, false, null);
            table.insert(action.targets,target)
        end
    elseif buff.type == BUFFER_TYPE_RADIATION then
        --找出辐射伤害加深BUFFID和等级
        local radiaBuffId = 0
        local radiaBuffLv = 0
        local playerCardSelf=nil
        if(attackSide== SIDE1) then
            playerCardSelf= lplayerCards1
        else
            playerCardSelf= lplayerCards2
        end
        local attackCard = playerCardSelf[attackPos]
        for key, buffData in pairs(attackCard.cardBuffList) do
            local buffId = buffData[0]
            if(buffId and buffId > 0) then
                local buff =  DB.getBuffById(buffId)
                if(buff.type == BUFFER_TYPE_RADIATION_HURT) then
                    radiaBuffId = buffData[0]
                    radiaBuffLv = buffData[1]
                    break
                end
            end
        end
        local playerCards=nil
        if(attackSide== SIDE2) then
            playerCards= lplayerCards1
        else
            playerCards= lplayerCards2
        end
        local posVec= getTargetPosArray(attackPos,attackPos,buff.target_range, buff.target_num,playerCards,nil,0,nil)
        for key, pos in pairs(posVec) do
            if radiaBuffId >0 then
                --加伤害增加buff
                local buffHurt = DB.getBuffById(radiaBuffId);
                local attr = buffHurt.attr_id0
                local attr_value = getAttrValue0(buffHurt,radiaBuffLv)
                local pbuff = createPlayerBuff(RESPONSE_TYPE_RADIATION,attr,attr_value,buffHurt.round )
                playerCards[pos]:addPlayerBuff(pbuff)
                local target = PlayerTarget.new()
                target:setParam1(pos, RESPONSE_TYPE_RADIATION, attackPos, 0, true, nil);
                table.insert(action.targets,target)
            end
        end

    end
    return action;
end

--[[***
* 设置灵魂锁链
* @param attackSide 攻击方
* @param sc 灵魂锁链对象
*]]
function  setSpiritChain(  attackSide,  sc)
    if(attackSide == SIDE1)then
        gBattleSpiritChain1 = sc
    else
        gBattleSpiritChain2 =sc
    end
end

function  getSpiritChain(  attackSide)
    if(attackSide == SIDE1)then
        return gBattleSpiritChain1
    else
        return gBattleSpiritChain2
    end
end

function  createSpiritChainRemoveAction(  side)
    local sc = getSpiritChain(side);

    if(sc ~= nil)then
        local remove = false;
        playerCards =nil

        if(side == SIDE1)then
            playerCards=lplayerCards1
        else
            playerCards=lplayerCards2

        end
        if(sc.chainPos[0] ~= -1)then
            if(playerCards[sc.chainPos[0]] ~=nil and not playerCards[sc.chainPos[0]]:isAlive())then
                remove = true;
            end
        end
        local chainDead = 0;
        if(sc.chainPos[1] ~= -1)then
            if(playerCards[sc.chainPos[1]] ~= nil and  not playerCards[sc.chainPos[1]]:isAlive())then
                chainDead=chainDead+1;
            end
        else
            chainDead=chainDead+1;--如果初始就没绑定，当做死了
        end

        if(sc.chainPos[2] ~= -1)then
            if(playerCards[sc.chainPos[2]] ~= nil and  not playerCards[sc.chainPos[2]]:isAlive())then

                chainDead=chainDead+1;--如果初始就没绑定，当做死了
            end
        else
            chainDead=chainDead+1;--如果初始就没绑定，当做死了
        end
        if(chainDead == 2)then
            remove = true;
        end
        if(remove)then
            local action = createPlayerAction(side, sc.chainPos[0]);
            action.actionType= ACTION_TYPE_REMOVE_BUFF
            local removeType = RESPONSE_TYPE_SPIRIT_CHAIN + 100

            for key, pos in pairs(sc.chainPos) do
                if( pos~= -1 and playerCards[pos]~=nil )then
                    local target = PlayerTarget.new()
                    target:setParam1 (pos, removeType,  0, 0, false, nil);
                    table.insert(action.targets,target);
                end
            end

            setSpiritChain(side, nil)--清空灵魂状态
            return action;
        end
    end
    return nil;
end


--[[**
* 检查有没有出场BUFF要释放
* @param orderList 出场顺序列表
* @param round 回合对象
*]]
function checkAppearanceBuff(  orderList,  round)
    for key, order in pairs(orderList) do

        local pcard=nil
        if(order.side == SIDE1) then
            pcard= lplayerCards1[order.pos]
        else
            pcard= lplayerCards2[order.pos]
        end

        if(pcard ~=nil and  pcard:isAlive())then--还没阵亡
            local card=DB.getCardById(pcard.cardid)
            if(card.buffid30> 0)then
                local action = createAppearanceAction(order.side, order.pos, card.buffid30)
                if(action ~= nil)then
                    table.insert(round.actions,action);
                end
            end
        end
    end
end

--[[**
 * 检查背锅侠是否要变身
 * @param orderList 出场顺序列表
 * @param round 回合对象
*]]
function checkHeroChange(  orderList,  round)
    local heroCardId = PAN_MAN --背锅侠卡牌ID
    local noChangeArray = DB.getClientParamToTable("HERO_NO_CHANGE_CARD_ID",true)
    local function inNochangeCards(cardid) --//对方背锅侠不加入计算  不能变成对方背锅侠  以及小初、警察等特殊英雄
        for k,v in pairs(noChangeArray) do
            if v == cardid then
                return true
            end
        end
        return false
    end
     -- 计算进攻方
    for i,card in pairs(lplayerCards1) do
        card.copySkillId={}
        if card.cardid == heroCardId and card:isAlive() then
            local  posArray = {}
            for j,enemyCard in pairs(lplayerCards2) do
                local enemyCardDb = DB.getCardById(enemyCard.cardid)
                --怪物BOSS 等不能复制
                if enemyCardDb.isspecial ~= 1 and not inNochangeCards(enemyCard.cardid)  then
                    table.insert(posArray,j)
                end
            end
            if table.count(posArray) >= 1 then
                local rand =getRand(1,table.getn(posArray))
                local index = posArray[rand]
                local targetCard =  lplayerCards2[index]
                -- 复制技能ID
                card.copySkillId[0] = targetCard.attackSkillList[0][0]
                card.copySkillId[1] = targetCard.attackSkillList[1][0]

                local action = createPlayerAction(SIDE1, i);
                action.actionType=ACTION_TYPE_APPEARANCE
                local target = PlayerTarget.new()
                target:setParam1_1(i, RESPONSE_TYPE_COPY_HERO, 0, 0, false, nil,targetCard.cardid);
                table.insert(action.targets,target)
                table.insert(round.actions,action)
            end
        end
    end

    -- 计算防守方
    for i,card in pairs(lplayerCards2) do
        card.copySkillId={}
        if card.cardid == heroCardId and card:isAlive()then
            local  posArray = {}
            for j,enemyCard in pairs(lplayerCards1) do
                local enemyCardDb = DB.getCardById(enemyCard.cardid)
                --怪物BOSS 等不能复制
                if enemyCardDb.isspecial ~= 1 and not inNochangeCards(enemyCard.cardid)  then
                    table.insert(posArray,j)
                end
            end
            if table.count(posArray) >= 1 then
                local rand =getRand(1,table.getn(posArray))
                local index = posArray[rand]
                local targetCard =  lplayerCards1[index]
                -- 复制技能ID
                card.copySkillId[0] = targetCard.attackSkillList[0][0]
                card.copySkillId[1] = targetCard.attackSkillList[1][0]

                local action = createPlayerAction(SIDE2, i);
                action.actionType=ACTION_TYPE_APPEARANCE
                local target = PlayerTarget.new()
                target:setParam1_1(i, RESPONSE_TYPE_COPY_HERO, 0, 0, false, nil,targetCard.cardid);
                table.insert(action.targets,target)
                table.insert(round.actions,action)
            end
        end
    end


end

--[[
 * 宠物开场buff
 * @param round
 */
]]
function checkPetAppearanceBuff(round)
    if lplayerPet1 ~=nil then
        local action = createPlayerAction(SIDE1, 0);
        action.actionType=ACTION_TYPE_ROUND_BUFF
         for key, buff in pairs(lplayerPet1.buffList) do
            local buffLevel=lplayerPet1.buffLevel[key]
            if buff.type == BUFFER_TYPE_PET_APPEARANCE_SUB_RECOVERY then
                local posVec= getTargetPosArray(0,0,buff.target_range, buff.target_num,lplayerCards2,nil,0,getSpiritChain(SIDE1))
                for key, pos in pairs(posVec) do
                    local enemy = lplayerCards2[pos]
                    if enemy then
                        local pbuff = createPlayerBuff(RESPONSE_TYPE_SUB_RECOVERY,buff.attr_id0,getAttrValue0(buff,buffLevel),buff.round )
                        enemy:addPlayerBuff(pbuff)
                        local target = PlayerTarget.new()
                        target:setParam1(pos, RESPONSE_TYPE_SUB_RECOVERY, buff.round, 0, true, nil);
                        table.insert(action.targets,target)
                    end
                end
            end
        end
        if(table.getn(action.targets) > 0)then
            table.insert( round.actions,action);
        end
    end

    if lplayerPet2 ~=nil then
        local action = createPlayerAction(SIDE2, 0);
        action.actionType=ACTION_TYPE_ROUND_BUFF
         for key, buff in pairs(lplayerPet2.buffList) do
            local buffLevel=lplayerPet2.buffLevel[key]
            if buff.type == BUFFER_TYPE_PET_APPEARANCE_SUB_RECOVERY then
                local posVec= getTargetPosArray(0,0,buff.target_range, buff.target_num,lplayerCards1,nil,0,getSpiritChain(SIDE2))
                for key, pos in pairs(posVec) do
                    local enemy = lplayerCards1[pos]
                    if enemy then
                        local pbuff = createPlayerBuff(RESPONSE_TYPE_SUB_RECOVERY,buff.attr_id0,getAttrValue0(buff,buffLevel),buff.round )
                        enemy:addPlayerBuff(pbuff)
                        local target = PlayerTarget.new()
                        target:setParam1(pos, RESPONSE_TYPE_SUB_RECOVERY, buff.round, 0, true, nil);
                        table.insert(action.targets,target)
                    end
                end
            end
        end
        if(table.getn(action.targets) > 0)then
            table.insert( round.actions,action);
        end
    end

end

function gContinueBattle()
    if(gLastBattleRound==nil)then
        return
    end
    lbattleRoundList={}
    local newRoundIdx=0
    newRoundIdx=gLastBattleRound.roundIndex
    local actionRound={roundIndex=gLastBattleRound.roundIndex,actions={}}
    local isBattleEnd,isBattleBreak=doBattleRound(gLastBattleOrderList,actionRound,gLastBattleOrder)
    table.insert(lbattleRoundList,actionRound)
    Battle.addLog(actionRound)
    gBattleTouchLevel=0--清0
    gIsBattleBreak=isBattleBreak
    if(isBattleEnd or isBattleBreak) then
        return lbattleRoundList
    end

    for i=newRoundIdx+1, MAX_ROUND-1 do
        local orderList=sortAttackOrder()
        local actionRound={roundIndex=i,actions={}}
        local isBattleEnd,isBattleBreak=doBattleRound(orderList,actionRound)
        table.insert(lbattleRoundList,actionRound)
        Battle.addLog(actionRound)
        gIsBattleBreak=isBattleBreak

        if(isBattleEnd or isBattleBreak) then
            return lbattleRoundList
        end
    end

    return lbattleRoundList

end




--buffer
local function   gGetBuffAttrValue0(buffer, level)
    return buffer.attr_value0+(level-1)*buffer.attr_add_value0
end

local function   gGetBuffAttrValue1(buffer, level)
    return buffer.attr_value1+(level-1)*buffer.attr_add_value1
end

function getFloatRandom()
    return getRand(0,10000)/100
end



function gCheckHarmfulBuffRate(buffer , level,  skillRange,  resistHarmfulRate)
    local  skType = buffer.skill_range
    if(skType ~= SKILL_TYPE_ALL  and skillRange ~= skType) then
        return false;
    end
    if(buffer.rate == 0 or buffer.rate == 100) then
        return true
    end


    local rrr = buffer.rate +  buffer.rate_add*(level - 1)*(100-resistHarmfulRate)/100
    local rand =getFloatRandom()
    return rand < rrr;
end

function gCheckReliveRate(buffer, level,  skillType,reliveCount,rateReduce)
    skType = buffer.skill_range
    if(skType ~= SKILL_TYPE_ALL  and skillType ~= skType) then
        return false
    end
    if(buffer.rate == 0 or buffer.rate == 100) then
        return true
    end

    local rrr =( buffer.rate +  buffer.rate_add*(level - 1))/(100+rateReduce)*100
    local rand =getFloatRandom()

    if(reliveCount>0)then
        local a=(100- DB.getClientParam("RELIVE_RATE_DOWN_PERCENT"))/100
        rrr =rrr * math.pow(a, reliveCount)
    end

    return rand < rrr
end

function gCheckBuffRate(buffer, level,  skillType)
    skType = buffer.skill_range
    if(skType ~= SKILL_TYPE_ALL  and skillType ~= skType) then
        return false
    end
    if(buffer.rate == 0 or buffer.rate == 100) then
        return true
    end
    local rrr = buffer.rate +  buffer.rate_add*(level - 1)
    local rand =getFloatRandom()
    print(rrr.." "..rand)
    return rand < rrr
end


--获取战斗录像
function gGetBattleVideo( cards1,cards2,pet1,country)


    lplayerCards1=cards1
    lplayerCards2=cards2
    gBattleCountry1=country
    if(pet1)then
        lplayerPet1=PlayerPet.new(pet1)
    end

    startBattle()
    return lbattleRoundList,lplayerPet1
end

function gResetPlayerCard(cards)
    for key, card in pairs(cards) do
        card:reset()
    end
end

function gGetPlayerCardAlive( playerCards)
    local count = 0;
    for key, card in pairs(playerCards) do
        if(card and card:isAlive()) then
            count=count+1
        end
    end
    return count
end


function gGetNextGroupBattleVideo(cards2)

    local retPlayerCard1=clone(lplayerCards1)
    lplayerCards2=cards2
    gResetPlayerCard(lplayerCards1)
    gResetPlayerCard(lplayerCards2)
    gBattleSpiritChain1 =nil;
    gBattleSpiritChain2 = nil;
    startBattle()
    return lbattleRoundList,retPlayerCard1,lplayerPet1
end

function gGetPowerChange(  roundIndex)
    return 100;
end

function gGetPlayCardsInfo(side)
    if side == 1 then
        return lplayerCards1
    else
        return lplayerCards2
    end
end
