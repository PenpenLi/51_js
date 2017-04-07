local  PlayerTarget=class("PlayerTarget")


function PlayerTarget:ctor()
    self.effectList={}
    self.isDead=false
    self.isEnemy = true
    self.position = 0
    self.damage = 0
    self.response = 0
end

function PlayerTarget:setParam1(  targetPos,  response,  responseRound,  damage,  isEnemy,  effect)
    self.position = targetPos
    self.isEnemy = isEnemy
    self.response = response
    self.damage = damage
    self.responseRound = responseRound
    if(effect~=nil) then
        table.insert(self.effectList,effect)
    end

end

function PlayerTarget:setParam1_1(  targetPos,  response,  responseRound,  damage,  isEnemy,  effect,copyCardId)
    self.position = targetPos
    self.isEnemy = isEnemy
    self.response = response
    self.damage = damage
    self.responseRound = responseRound
    self.copyCardId = copyCardId
    if(effect~=nil) then
        table.insert(self.effectList,effect)
    end

end

function PlayerTarget:setParam2(  friend,  targetPos,  hpAdd,response, isEnemy)--buff回血,不分段显示,出手后回血，吸血等BUFF
    self.isEnemy = isEnemy
    self.position = targetPos
    self.damage = hpAdd
    self.response = RESPONSE_TYPE_RECOVERY
    local effect = createTargetEffect( EFFECT_TYPE_ATTR_ADD, Attr_HP, self.damage, false)
    table.insert(self.effectList,effect)
    friend:recovered(self.damage)
end




function PlayerTarget:setParam3(attackSide,  attacker,  friend,  targetPos,  skill,  hpAdd,  isPetSkill,petid,attackerPet)--技能回血，分段显示
    self.isEnemy = false
    self.position = targetPos
    local dpl =string.split(skill.damage_percent, ";")

    for key, value in pairs(dpl) do
        local isCritical = self:checkRecoverCritical(attacker,friend)
        if(isPetSkill)then
            --if(petid==50002)then
                isCritical=self:checkRandom(10+attackerPet.addcriticalrate)
            -- else
            --     isCritical=self:checkRandom(20)
            -- end
        end
        local dmg = math.rint( hpAdd*value*self:getDamageRandomRange()/100)
        --[[
        if(attackSide==1)then
        dmg=math.rint(dmg*(1-gBattlePowerRate))
        else
        dmg=math.rint(dmg*(1+ gBattlePowerRate))
        end
        ]]
        if(isCritical) then
            dmg =self:getRecoverCriticalDamage(dmg,attacker,friend)  --是否暴击
        end



        self.damage  = self.damage+ dmg
        local effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD, Attr_HP, dmg, isCritical)
        table.insert(self.effectList,effect)
    end
    self.response = RESPONSE_TYPE_RECOVERY
    friend:recovered(self.damage)

end



function PlayerTarget:setParam4(    action,  pcard,  targetPos,  dmg,  response,  isEnemy)
    self.isEnemy = isEnemy
    self.position = targetPos
    local checkShield = false
    if(pcard.shield>0)then
        checkShield = true
        local shieldProtect = pcard:subShield(dmg)
        local effect = createTargetEffect(EFFECT_TYPE_SHIELD_PROTECT, Attr_HP, shieldProtect, false)
        table.insert(self.effectList,effect)
        dmg  = dmg-shieldProtect --扣掉护盾吸收
    end
    local effect = createTargetEffect(EFFECT_TYPE_DAMAGE, Attr_HP, dmg, false)
    table.insert(self.effectList,effect)
    self.damage = dmg
    self.response = response
    pcard:attacked(dmg)
    if(pcard:isAlive()==false)then
        self.isDead = true
    elseif(checkShield)then
        if(pcard.shield<=0)then--护盾解除
            local pt = createPlayerTarget(targetPos, RESPONSE_TYPE_SHIELD_REMOVE,   0, 0, false, nil)
            table.insert(action.targets,pt)
        end
    end
end


function PlayerTarget:getDamageRandomRange()
    local rand = getRand(9500, 10500)
    return rand/10000
end

--[[
function PlayerTarget:checkBuffAfterAction(  buff,  action,  attackPos,  attacker,  enemy,  skillLevel,  skillType)
local buffType = buff.type
if(buffType == BUFFER_TYPE_ADD_FRIEND_RAGE_AFTER_ACTION) then
if(gCheckBuffRate(buff,skillLevel, skillType))then--出手后回复队友怒气
local value = getAttrValue0(buff,skillLevel)
local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, buff.attr_id0, value, buff.round)
enemy:addPlayerBuff(pbuff)
local effect = createTargetEffect(EFFECT_TYPE_ATTR_ADD,buff.attr_id0, value, false)
table.insert(self.effectList,effect)
end
end
end
]]


function PlayerTarget:getCountryAddDamagePercent(countryid,pos)
    if(countryid==0)then
        return 0
    end
    local buffs= DB.getCountryBuffs(countryid)
    local ret=0
    for key, buffid in pairs(buffs) do
        local buff=DB.getBuffById(toint(buffid))
        if(buff and isBuffInRange(buff,pos) and buff.type==BUFFER_TYPE_ADD_DAMAGE)then
            ret=ret+buff.attr_value0
        end
    end
    return ret
end


function PlayerTarget:getCountryResistPercent(countryid,pos)
    if(countryid==0)then
        return 0
    end
    local buffs= DB.getCountryBuffs(countryid)
    local ret=0
    for key, buffid in pairs(buffs) do
        local buff=DB.getBuffById(toint(buffid))
        if(buff and isBuffInRange(buff,pos) and buff.type==BUFFER_TYPE_REDUCE_HURT)then
            ret=ret+buff.attr_value0
        end
    end
    return ret
end



function PlayerTarget:setParam5(  action, attackSide, attackPos,  attacker, enemyNum, enemyCards, enemy,  targetPos,  skill,  skillDamage,  skillLevel,  skillType,isPetSkill,attackerPet,enemyPet,country1,country2,sc,powerChange)
    self.position = targetPos
    if(isPetSkill==nil)then
        isPetSkill=false
    end

    self.damage = 0
    if(isPetSkill==false and self:checkDodge(attacker,enemy))then--产生闪避
        self.damage = 0
        self.response = RESPONSE_TYPE_DODGE
        for i=0, 1 do
            local buff =  getSkillBuff(skill,i)
            if(buff ~= nil)then
                self:clearBuff(buff, action, attackPos,targetPos, attacker, enemy, skillLevel, skillType)
            end
        end
        local buffList = getSkillBuffList(skill)
        for k,buffid in pairs(buffList) do
            local buff = getBuffById(buffid)
            if(buff ~= nil)then
                self:clearBuff(buff, action, attackPos,targetPos, attacker, enemy, skillLevel, skillType)
            end
        end
    elseif(isPetSkill==false and skill.break_type~=BREAK_TYPE_IMMUNE and enemy:isSkillImmune(skill.attr_id))  then--是否免疫物攻或者魔攻
        self.damage = 0
        self.response = RESPONSE_TYPE_IMMUNE
        self.responseRound=skill.attr_id

        for i=0, 1 do
            local buff =  getSkillBuff(skill,i)
            if(buff ~= nil)then
                self:clearBuff(buff, action, attackPos,targetPos, attacker, enemy, skillLevel, skillType)
            end
        end
        local buffList = getSkillBuffList(skill)
        for k,buffid in pairs(buffList) do
            local buff = getBuffById(buffid)
            if(buff ~= nil)then
                self:clearBuff(buff, action, attackPos,targetPos, attacker, enemy, skillLevel, skillType)
            end
        end
        if(isPetSkill~=true and  skill.isextra==0)then --非附加技能才判断BUFF
            for key, buffData in pairs(attacker.cardBuffList) do
                local buffId = buffData[0]
                if(buffId and buffId > 0) then
                    local buff = DB.getBuffById(buffId)
                    if(buff ~= nil)then
                        self:checkBuff(buff, action, attackPos,targetPos, attacker, enemy, buffData[1], skillType)
                    end
                end
            end
        end
    else
        self.response =  RESPONSE_TYPE_NOTHING



        local reducePercent = 1
        local addPercent = 0


        if(not isPetSkill )then
            local enemyNum=6-enemyNum
            if(enemyNum > 0)then
                for i=0, 1 do
                    local buff =  getSkillBuff(skill,i)
                    if(buff ~= nil and buff.type == BUFFER_TYPE_ADD_POWER_WHEN_FEW_ENEMY)then
                        addPercent  =addPercent+ enemyNum*buff.attr_value0  --东方不败的大招BUFF
                    end
                end
            end

            addPercent =addPercent+ enemy:getHurtRaisePercent() --被击方是否有增加伤害的BUFF
            if(enemy:isFrozen() and skill.skillid ~= GUOJIA_SKILL_ID)then
                addPercent =addPercent+ 50 --冰冻时受击增加50%的伤害
                self.response = RESPONSE_TYPE_FROZEN_BROKEN --破冰状态
                enemy:removeFrozenBuff();
            end

            addPercent =addPercent+ attacker:getPowerRaisePercent()

            -- 技能带的两个buff 目前只用于辐射技能
            for i=0, 1 do
                local buff =  getSkillBuff(skill,i)
                if(buff ~= nil and buff.type == BUFFER_TYPE_NO_RADIATION_HURT)then
                    if enemy:isRadiation() == false then
                        addPercent =addPercent+ buff.attr_value0  --如果没被辐射 伤害加深X%
                    end
                end
            end

            addPercent =addPercent+attacker:getPowerRaisePercentByCountry(enemy.country)--对指定阵营的人伤害加成
            addPercent = addPercent+ attacker:getPowerRaiseByPetPossessSkill()--/灵兽附身技能加成

            reducePercent =reducePercent* attacker:getPowerDownPercent();
            reducePercent =reducePercent*enemy:getHurtDownPercent();
            if(skill.target_num==1)then
                local a = enemy:getHurtDownWhenSingleTarget()
                if(a ~= 1)then
                    reducePercent =reducePercent*a
                end
            end



            if(attackSide==1)then
                addPercent=addPercent-gBattlePowerRate*100
            else
                addPercent=addPercent+gBattlePowerRate*100
            end
        else
            if(attackerPet~=nil and  skill.isextra==0)then
                for key, petBuff in pairs(attackerPet.buffList) do
                    local buffLevel=attackerPet.buffLevel[key]
                    self:checkBuff(petBuff, action, attackPos, targetPos, attacker, enemy, buffLevel, skillType)
                end
            end
              
            if(enemy:isFrozen())then
                addPercent =addPercent+ 50 --冰冻时受击增加50%的伤害
                self.response = RESPONSE_TYPE_FROZEN_BROKEN --破冰状态
                enemy:removeFrozenBuff();
            end
            
        end

        -- reducePercent = math.min(0.9, reducePercent)
        skillDamage =skillDamage+  math.rint(skillDamage*addPercent/100)
        skillDamage =skillDamage* reducePercent;
        if(enemy.resistDamage > 0)then
            skillDamage  = skillDamage -math.rint(enemy.hpInit*enemy.resistDamage/250)--减掉抵消伤害值
        end

        skillDamage = math.max(skillDamage, 1) --最低一点伤害
        if(sc ~= nil and sc:isInChain(targetPos))then
            local num  = sc:getChainAliveNum(enemyCards);
            local tmpDmg = 0;
            if(num == 3)then
                tmpDmg = math.rint(skillDamage*0.25);
                skillDamage = math.rint(skillDamage*0.5);
            elseif(num == 2)then
                tmpDmg = math.rint(skillDamage*0.35);
                skillDamage = math.rint(skillDamage*0.65);
            end
            if(tmpDmg > 0)then
                for key, pos in pairs(sc.chainPos) do
                    if(pos ~= -1 and pos ~= targetPos and enemyCards[pos] ~= nil and enemyCards[pos]:isAlive())then

                        local target=PlayerTarget.new()
                        target:setParam4(action,enemyCards[pos], pos,tmpDmg, RESPONSE_TYPE_CHAIN_DAMAGE,true)
                        table.insert(action.targets,target)
                    end
                end
            end
        end


        if(gBattleTouchLevel>0)then
            skillDamage = skillDamage + math.rint( skillDamage*DB.getCooperateDamage(gBattleTouchLevel)/100)
        end





        local dpl =string.split( skill.damage_percent,";")
        local checkShield = false --被击前时候有护盾
        for key, var in pairs(dpl) do
            var=toint(var)
            local isCritical = self:checkCritical(attacker,enemy,attackerPet,isPetSkill)
            local a = math.rint( skillDamage*var/100)
            local  dmg = 0;
            if(a < 1000)then
                dmg = math.rint(a*self:getDamageRandomRange());
            else
                dmg = a+getRand(-50, 50);
            end


            if(isCritical)then
                dmg=self:getCriticalDamage(dmg,attacker,enemy)
            end
            if(enemy.shield>0)then
                checkShield = true
                local shieldProtect = enemy:subShield(dmg)
                local effect = createTargetEffect( EFFECT_TYPE_SHIELD_PROTECT, Attr_HP, shieldProtect, false)
                table.insert(self.effectList,effect )
                dmg  =dmg- shieldProtect --扣掉护盾吸收
            end
            dmg = math.max(dmg, 1) --最低一点伤害
            self.damage  =self.damage+ dmg
            local effect = createTargetEffect(EFFECT_TYPE_DAMAGE, Attr_HP, dmg, isCritical)
            table.insert(self.effectList,effect)
        end

        enemy:attacked( self.damage)--扣血

        for i=0, 1 do --技能带的两个buff
            local buff =  getSkillBuff(skill,i)
            if(buff ~= nil)then
                self:checkBuff(buff, action, attackPos,targetPos, attacker, enemy, skillLevel, skillType)
            end
        end

        local buffList = getSkillBuffList(skill)
        for k,buffid in pairs(buffList) do
            local buff = getBuffById(buffid)
            if(buff ~= nil)then
                self:checkBuff(buff, action, attackPos,targetPos, attacker, enemy, skillLevel, skillType)
            end
        end

        if(isPetSkill~=true and  skill.isextra==0)then --非附加技能才判断BUFF
            for key, buffData in pairs(attacker.cardBuffList) do
                local buffId = buffData[0]
                if(buffId and buffId > 0) then
                    local buff = DB.getBuffById(buffId)
                    if(buff ~= nil)then
                        self:checkBuff(buff, action, attackPos,targetPos, attacker, enemy, buffData[1], skillType)
                    end
                end

            end
        end

        if(enemy:isAlive()==false)then
            self.isDead = true --死亡
        elseif(checkShield)then
            if( enemy.shield<=0)then--护盾解除
                local pt =    PlayerTarget.new()
                pt:setParam1(targetPos, RESPONSE_TYPE_SHIELD_REMOVE,   0, 0, false, nil)
                table.insert( action.targets,pt)
            end
        end


        if(isPetSkill~=true and self.damage > 0)then--有可能护盾全部吸收完，就不产生反伤
            local percent = enemy:getRebondDamagePercent()
            if(percent > 0)then
                local value = math.rint(self.damage*percent/100)
                local sign = false
                local effect = nil
                if(attacker.shield>0)then
                    sign = true
                    local shieldProtect = enemy:subShield(value)
                    effect = createTargetEffect(EFFECT_TYPE_SHIELD_PROTECT, Attr_HP, shieldProtect, false)
                    value=value- shieldProtect
                end
                local e = createTargetEffect(EFFECT_TYPE_DAMAGE, Attr_HP, value, false)

                --注意：反伤的targetPos为发起反伤的人
                local rebondTarget =  PlayerTarget.new()
                rebondTarget:setParam1(targetPos, RESPONSE_TYPE_REBOUND_DAMAGE, 0, value,true,e)
                if(effect ~= nil)then
                    table.insert(rebondTarget.effectList,effect)
                end
                attacker:attacked(value)--扣血
                table.insert(action.targets,rebondTarget)
                if( attacker:isAlive()==false)then
                    rebondTarget.isDead = true
                elseif(sign) then
                    if(attacker.shield <=0) then --护盾解除
                        local pt =    PlayerTarget.new()
                        pt:setParam1(attackPos, RESPONSE_TYPE_SHIELD_REMOVE,   0, 0, false, nil)
                        table.insert(action.targets,pt)
                    end
                end


            end
        end
    end
end

function clearUsefulBuff(playerCard)
    local list={}

    for key, pbuff in pairs(playerCard.buffList) do
        if(pbuff.type == RESPONSE_TYPE_IMMUNE or  pbuff.type == RESPONSE_TYPE_SHIELD)then
            table.insert(list,pbuff)
            playerCard.buffList[key]=nil
        end

        if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE)then
            if(pbuff.attr == Attr_HURT_DOWN )then
                table.insert(list,pbuff)
                playerCard.buffList[key]=nil
            elseif( pbuff.attr == Attr_POWER_RAISE)then
                table.insert(list,pbuff)
                playerCard.buffList[key]=nil

            end
        end
    end

    return list;

end

function clearHarmfulBuff(playerCard)
    local list={}
    for key, pbuff in pairs(playerCard.buffList) do
        if(pbuff.type == RESPONSE_TYPE_STUN or
            pbuff.type == RESPONSE_TYPE_LOCK or
            pbuff.type == RESPONSE_TYPE_REDUCE_HP or
            pbuff.type == RESPONSE_TYPE_FROST or
            pbuff.type == RESPONSE_TYPE_FROZEN )then
            table.insert(list,pbuff)
            playerCard.buffList[key]=nil
        end

        if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE)then
            if(pbuff.attr == Attr_HURT_RAISE )then
                table.insert(list,pbuff)
                playerCard.buffList[key]=nil
            elseif( pbuff.attr == Attr_POWER_DOWN)then
                table.insert(list,pbuff)
                playerCard.buffList[key]=nil

            end
        end
    end

    return list;

end


function PlayerTarget:checkBuff(  buff,  action,  attackPos, targetPos, attacker,  enemy,  skillLevel,  skillType)
    local buffType = buff.type

    if(buff.traget_type~= 0)then
        if(buff.traget_type == 1)then
            ---仅对主目标有效
            if(targetPos ~= action.targetPosition)then
                return;
            end
        elseif(buff.traget_type == 2)then
            ----//仅对非主目标有效
            if(targetPos == action.targetPosition)then
                return;
            end

        end
    end

    if(buffType == BUFFER_TYPE_REDUCE_TARGET_ATTR)then
        if( gCheckBuffRate(buff,skillLevel, skillType))then

            if buff.attr_id0 == Attr_RAGE and enemy:isImmuneHarmfulBuff() then
                return
            end
            local value = getAttrValue0(buff,skillLevel)
            local value2=value
            if(buff.attr_id0~=Attr_HURT_RAISE)then
                value2=-value2
            end
            local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, buff.attr_id0, value2, buff.round)
            enemy:addPlayerBuff(pbuff)
            local effect = createTargetEffect(EFFECT_TYPE_ATTR_REDUCE,buff.attr_id0, value, false)
            table.insert(self.effectList,effect)
            if buff.attr_id1>0 then
                local value = getAttrValue1(buff,skillLevel)
                local value2=value
                if(buff.attr_id1~=Attr_HURT_RAISE)then
                    value2=-value2
                end
                local pbuff = createPlayerBuff(RESPONSE_TYPE_ATTR_CHANGE, buff.attr_id1, value2, buff.round)
                enemy:addPlayerBuff(pbuff)
                local effect = createTargetEffect(EFFECT_TYPE_ATTR_REDUCE,buff.attr_id1, value, false)
                table.insert(self.effectList,effect)
            end
        end

    elseif(buffType ==BUFFER_TYPE_FROST)then
        --//产成霜冻
        if(not enemy:isFrozen() and (not enemy:isImmuneHarmfulBuff()) and gCheckHarmfulBuffRate(buff,skillLevel, skillType,enemy.resistHarmfulRate))then
            local target =    PlayerTarget.new()

            local value = getAttrValue0(buff,skillLevel)
            
            target:setParam1(targetPos, RESPONSE_TYPE_FROST,   buff.round, 0, true, nil)
            target.isDead=not enemy:isAlive()
            table.insert( action.targets,target)

            local pbuff = createPlayerBuff(RESPONSE_TYPE_FROST,  buff.attr_id0, -value, buff.round)
            enemy:addPlayerBuff(pbuff)

            local effect = createTargetEffect(EFFECT_TYPE_ATTR_REDUCE,buff.attr_id0, value, false)
            table.insert(target.effectList,effect)
        end
    elseif(buffType == BUFFER_TYPE_FROZEN)then
        --产生结冰
        if( enemy:isFrost() and gCheckHarmfulBuffRate(buff,skillLevel, skillType,enemy.resistHarmfulRate))then
            enemy:removeFrostBuff()

            local target =    PlayerTarget.new()
            target:setParam1(targetPos, RESPONSE_TYPE_FROZEN,   buff.round, 0, true, nil)
            target.isDead=not enemy:isAlive()
            table.insert( action.targets,target)

            local pbuff = createPlayerBuff(RESPONSE_TYPE_FROZEN,   0, 0, buff.round)
            enemy:addPlayerBuff(pbuff)

        end
    elseif(buffType ==  BUFFER_TYPE_STUN)then
        if(gCheckHarmfulBuffRate(buff,skillLevel, skillType,enemy.resistHarmfulRate) and (not enemy:isImmuneHarmfulBuff()))then--产成眩晕
            local target =    PlayerTarget.new()
            target:setParam1(targetPos, RESPONSE_TYPE_STUN,   buff.round, 0, true, nil)
            target.isDead=not enemy:isAlive()
            table.insert( action.targets,target)

            local pbuff = createPlayerBuff(RESPONSE_TYPE_STUN,   0, 0, buff.round)
            enemy:addPlayerBuff(pbuff)
        end
    elseif(buffType == BUFFER_TYPE_LOCK)then
        if(gCheckHarmfulBuffRate(buff,skillLevel, skillType,enemy.resistHarmfulRate) and (not enemy:isImmuneHarmfulBuff()) )then--产成封印

            local target =    PlayerTarget.new()
            target:setParam1(targetPos, RESPONSE_TYPE_LOCK,   buff.round, 0, true, nil)
            target.isDead=not enemy:isAlive()
            table.insert( action.targets,target)


            pbuff = createPlayerBuff(RESPONSE_TYPE_LOCK,   0, 0, buff.round)
            enemy:addPlayerBuff(pbuff)
        end
    elseif(buffType == BUFFER_TYPE_SUCK)then
        local value = getAttrValue0(buff,skillLevel)
        local hpAdd = math.rint(self.damage*value/100)--吸血量
        local selfTarget =  PlayerTarget.new()
        attacker:recovered(hpAdd)
        selfTarget:setParam1( attackPos, RESPONSE_TYPE_SUCK, 0, hpAdd, false, nil)
        table.insert( action.targets,selfTarget)
    elseif(buffType ==BUFFER_TYPE_REDUCE_HP_EVERY_ROUND) then
        if(gCheckBuffRate(buff,skillLevel, skillType))then--使目标没回合掉血


            local target =    PlayerTarget.new()
            target:setParam1(targetPos, RESPONSE_TYPE_REDUCE_HP,   buff.round, 0, true, nil)
            target.isDead=not enemy:isAlive()
            table.insert( action.targets,target)


            local value = getAttrValue0(buff,skillLevel)
            local pbuff = createPlayerBuff(RESPONSE_TYPE_REDUCE_HP, buff.attr_id0, value, buff.round)
            pbuff.param=math.rint(attacker:getAttackOrDefendValue(Attr_PHYSICAL_ATTACK)*3*value/100)
            enemy:addPlayerBuff(pbuff)
        end

    elseif(buffType ==BUFFER_TYPE_NO_RADIATION_HURT)then --辐射BUFF有眩晕效果
        if enemy:isRadiation() and (not enemy:isImmuneHarmfulBuff()) then --产成眩晕
            local target =    PlayerTarget.new()
            target:setParam1(targetPos, RESPONSE_TYPE_STUN,   buff.round, 0, true, nil)
            target.isDead=not enemy:isAlive()
            table.insert( action.targets,target)
            local pbuff = createPlayerBuff(RESPONSE_TYPE_STUN,   0, 0, buff.round)
            enemy:addPlayerBuff(pbuff)
        end
    elseif(buffType ==BUFFER_TYPE_SUB_RECOVERY)then --治疗效果降低
        if gCheckBuffRate(buff,skillLevel, skillType) then
            local value = getAttrValue0(buff,skillLevel)
            local pbuff = createPlayerBuff(RESPONSE_TYPE_SUB_RECOVERY,buff.attr_id0, value, buff.round)
            enemy:addPlayerBuff(pbuff)

            local target =    PlayerTarget.new()
            target.isDead=not enemy:isAlive()
            target:setParam1(targetPos, RESPONSE_TYPE_SUB_RECOVERY,   buff.round, 0, true, nil)
            table.insert( action.targets,target)
            
        end
    elseif(buffType ==BUFFER_TYPE_CLEAR_USEFUL_BUFF)then
        self:clearBuff(  buff,  action,  attackPos, targetPos, attacker,  enemy,  skillLevel,  skillType)
    end
end



function PlayerTarget:clearBuff(  buff,  action,  attackPos, targetPos, attacker,  enemy,  skillLevel,  skillType)
    local buffType = buff.type

    if(buffType == BUFFER_TYPE_CLEAR_USEFUL_BUFF)then
        if(gCheckBuffRate(buff,skillLevel, skillType))then--使目标没回合掉血
            local clist = clearUsefulBuff(enemy);
            if(table.count(clist) > 0)then
                local target =  PlayerTarget.new()
                target.response = RESPONSE_TYPE_BUFF_REMOVE;
                target.isEnemy = true;
                target.responseRound = 1---标记清除增益BUFF
                target.position = targetPos;

                for key, pbuff in pairs(clist) do

                    if(pbuff.type == RESPONSE_TYPE_IMMUNE)then
                        local effect = createTargetEffect(EFFECT_TYPE_IMMNUE_REMOVE, 0, 0, false)
                        table.insert(target.effectList,effect)
                    elseif(pbuff.type == RESPONSE_TYPE_SHIELD)then
                        local effect = createTargetEffect(EFFECT_TYPE_SHIELD_REMOVE, 0, 0, false)
                        table.insert(target.effectList,effect)
                    elseif(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and pbuff.attr == Attr_HURT_DOWN)then
                        local effect = createTargetEffect(EFFECT_TYPE_HURT_DOWN_REMOVE, 0, 0, false)
                        table.insert(target.effectList,effect)
                    end
                end
                table.insert( action.targets,target)
            end
        end
    end
end

function PlayerTarget:checkRandom(  random)
    return getRand(0,100)<random
end

function PlayerTarget:checkCritical(  attacker,  enemy,attckerPet,isPetSkill)


    local clv =  (0.08*attacker.level*attacker.level+4.8*attacker.level+2.2)*(5+attacker.level*0.06)
    local a =  toint(clv*100)

    local criticalRate = attacker:getBuffAttrValue(Attr_CRITICAL_RATE);
    local toughnessRate = enemy:getBuffAttrValue(Attr_TOUGHNESS_RATE);
    local value =toint( math.min(math.max((attacker.critical - enemy.toughness)/a+criticalRate-toughnessRate,getRand(1, 5)), 60))
    if isPetSkill == true then
        value =value+ attckerPet.addcriticalrate --宠物附身技能增加的暴击率
    end

    return self:checkRandom(value)
end



function PlayerTarget:checkRecoverCritical(  attacker,  enemy)

    local clv = (0.08*attacker.level*attacker.level+4.8*attacker.level+2.2)*(5+attacker.level*0.06)
    local t = attacker.critical/clv
    local value = math.min(math.max(0.6*t*t-0.5*t+0.1+attacker.criticalRate/400,0), 0.25)
    return self:checkRandom(toint(value*100))

end

function PlayerTarget:checkDodge(  attacker,  enemy)


    local clv =   (0.08*enemy.level*enemy.level+4.8*enemy.level+2.2)*(5+enemy.level*0.06)
    local a =toint(clv*100)

    local dodgeRate = enemy:getBuffAttrValue(Attr_DODGE_RATE);
    local hitRate = attacker:getBuffAttrValue(Attr_HIT_RATE);

    local value = math.min(math.max((enemy.dodge - attacker.hit)/a+dodgeRate-hitRate,1), 45)
    return  self:checkRandom(value)
end

function PlayerTarget:getCriticalDamage( dmg, attacker, enemy)
    --[[   local b = (1.2+(attacker.critical - enemy.toughness)*10/(10000+(enemy.level-1)*500))
    return math.rint( dmg*b)
    ]]

    return dmg*2
end

function PlayerTarget:getRecoverCriticalDamage(  dmg,  attacker,  enemy)
    --[[local b =   (1.2+(attacker.critical)*10/(10000+(enemy.level-1)*500))
    return math.rint( dmg*b)]]
    return dmg*2
end

function PlayerTarget:getMinDamage( attack, dmg)
    local minDmg = math.rint( attack/10) --保底攻击值
    return math.max(minDmg, dmg)
end



return PlayerTarget
