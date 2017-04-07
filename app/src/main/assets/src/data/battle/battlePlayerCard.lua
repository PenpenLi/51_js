local PlayerCard=class("PlayerCard")



function PlayerCard:ctor()
    self.price = 0--身价
    self.cardid=0
    self.level=0--卡牌等级
    self.grade=0 --突破等级
    self.quality=0 --觉醒等级
    self.hp=0 --基础属性_气血
    self.hpInit=0 --战斗时的初始气血
    self.physicalAttack=0 --基础属性_物攻
    self.magicAttack=0 --基础属性_魔攻
    self.agility=0 --基础属性_身法
    self.physicalDefend=0 --基础属性_物防
    self.magicDefend=0 --基础属性_魔防
    self.country=0
    self.hpPercent=0 --基础属性_气血百分比
    self.physicalAttackPercent=0 --基础属性_武力百分比
    self.magicAttackPercent=0 --基础属性_内力百分比
    self.agilityPercent=0 --基础属性_身法百分比
    self.physicalDefendPercent=0 --基础属性_防御百分比
    self.magicDefendPercent=0 --基础属性_防御百分比
    self.recovery_all_hp_count=0

    self.hit=0 --附加属性_命中
    self.dodge=0 --附加属性_闪避
    self.critical=0 --附加属性_暴击
    self.toughness=0 --附加属性_抗暴

    self.hurtDownPercent = 0 --减伤百分比
    self.powerRaisePercent = 0 --输出增加百分比
    self.skillDamagePercent = 0 --招伤害百分比加成


    --  self.hitPercent=0 --附加属性_命中
    --  self.dodgePercent=0 --附加属性_闪避
    --  self.criticalPercent=0 --附加属性_暴击
    --  self.toughnessPercent=0 --附加属性_抗暴
    --  self.stuningCount=0 --被眩晕的回合数
    self.rage=0 --怒气值
    self.maxRage=0 --怒气上限值
    self.buff_relive_count=0

    self.ignoreDefend=0
    self.attackSkillList={}
    self.copySkillId={}
    self.cardBuffList={}
    self.buffList={}
    self.shield=0
    self.reliveCount=0
    self.relivePoint=0
    self.resistDamage=0
end

function PlayerCard:relive( hpAdd)
    self:recovered(hpAdd)
    self:clearPlayerBuffList()
    self.reliveCount=self.reliveCount +1 --复活加1
end

--[[
* 获取攻击方的降低输出百分比
* @return 百分比值[0,1]
]]
function PlayerCard:getPowerDownPercent()
    local value = 1
    for key, pbuff in pairs(self.buffList) do
        if((pbuff.type == RESPONSE_TYPE_ATTR_CHANGE or pbuff.type == RESPONSE_TYPE_FROST)and  pbuff.attr == Attr_POWER_DOWN)then
            value=value*((100+pbuff.value)/100)
        end
    end
    return value
end

--[[
* 获取攻击方的增加输出百分比，固定值+动态值
* @return 百分比数值[100,n]
]]
function PlayerCard:getPowerRaisePercent()
    local value = 0

    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and  pbuff.attr == Attr_POWER_RAISE)then
            value=value+pbuff.value
        end
    end
    return value+self.powerRaisePercent
end

--[[
/***
* 判断敌方是否被辐射
*/
]]
function PlayerCard:isRadiation() 
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_RADIATION)then
            return true
        end
    end
    return false
end

--[[
/***
* 是否免疫负面BUFF
*/
]]
function PlayerCard:isImmuneHarmfulBuff() 
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_IMMUNE_HARMFUL_BUFF)then
            return true
        end
    end
    return false
end

--[[
* 获取死亡释放辐射大招技能BUFF伤害百分比
]]
function PlayerCard:getRadiationSkillPercent()

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local  buff = DB.getBuffById(buffId)
            if buff.type == BUFFER_TYPE_DO_SKILL_AFTER_DEAD then 
                return getAttrValue0(buff,buffData[1])
            end
        end
    end

    return 0;
end


--[[
* 是否有死亡释放大招技能
]]
function PlayerCard:hasRadiationSkill()

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local pbuff = DB.getBuffById(buffId)
            if pbuff.type == BUFFER_TYPE_DO_SKILL_AFTER_DEAD then 
                return true
            end
        end
    end

    return false;
end

function PlayerCard:getPowerRaiseByPetPossessSkill()

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local pbuff = DB.getBuffById(buffId)
            if(pbuff.type == BUFFER_TYPE_POWER_RAISE_BY_PET_POSSESS_SKILL)then
                local hurtPer =100 - self:getHpRate()*100
                local num = math.rint(hurtPer/pbuff.attr_value0)
                return num*pbuff.attr_value1
            end
        end
    end

    return 0;
end


function PlayerCard:getPowerRaisePercentByCountry(  countryId)

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local pbuff = DB.getBuffById(buffId)
            if(pbuff.type == BUFFER_TYPE_ADD_ATTR_BY_COUNTRY and  pbuff.attr_id0 == Attr_POWER_RAISE)then
                if(pbuff.target_country and pbuff.target_country > 0 and pbuff.target_country == countryId)then
                    return  pbuff.attr_value0
                end
            end
        end
    end

    return 0;
end

--[[
* 获取被击方伤害增加的百分比
* @return 百分比数值[0,n]
]]
function PlayerCard:getHurtRaisePercent()
    local value = 0
    for key, pbuff in pairs(self.buffList) do
        if((pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and  pbuff.attr == Attr_HURT_RAISE) or pbuff.type == RESPONSE_TYPE_RADIATION)then
            value=value+pbuff.value
        end
    end
    return value
end


--[[
* 获取治疗回血百分比
* @return 百分比数值[0,n]
]]
function PlayerCard:getRecoverPercent()
    local value = self.recoveryAddPercent
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_SUB_RECOVERY)then
            value=value-pbuff.value
        end
    end
    local pk_hp = DB.getClientParam("BATTLE_PK_HP_RECOVER_LINK",true)
    return math.max(-70,value*pk_hp/100)
end


function PlayerCard:getHurtDownWhenSingleTarget()

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local buff = DB.getBuffById(buffId)
            if(buff.type == BUFFER_TYPE_HURT_DOWN_SIGNLE )then
                return (100-math.min(getAttrValue0(buff,buffData[1]),99))/100;
            end
        end
    end
    return 1
end



--[[
* 获取被击方的减伤百分比，固定值*浮动值
* @return
]]
function PlayerCard:getHurtDownPercent()
 

    local value = 0;
    for key, pbuff in pairs(self.buffList) do
        if((pbuff.type == RESPONSE_TYPE_ATTR_CHANGE or pbuff.type == RESPONSE_TYPE_FROST) and  pbuff.attr == Attr_HURT_DOWN)then
            value= value +pbuff.value;
        end
    end
    return 100/(100+self.hurtDownPercent+value)
end


function PlayerCard:isAlive()
    return self.hp > 0
end

function PlayerCard:clearPlayerBuffList()
    self.buffList={}
end
function PlayerCard:reset()
    self.buffList={}
    self.relivePoint=0
    self.buff_relive_count=0
end

function PlayerCard:addRage(  value)
    self.rage  = self.rage +value
    self.rage = math.max(0,math.min(self.rage,self.maxRage))
end

function PlayerCard:resetRage()--怒气清零
    self.rage=0
end

function PlayerCard:isFullRage()
    return self.maxRage > 0 and self.rage >= self.maxRage
end

function PlayerCard:getAttackSkillPos()
    if( self:isSkillLocked()==false and self:isFullRage()) then --怒气满，发动大招
        return 0
    end
    return 1
end

function PlayerCard:attacked(  damage)
    self.hp  = self.hp-damage
    self.hp = math.max(0,self.hp)
end


function PlayerCard:reduceHp(  percent)
    local value =  math.rint(percent*self.hp/100)
    value = math.min(value, self.hp-1)--保底要有一点血量
    self.hp  =  self.hp-value
    return value
end


function PlayerCard:recovered( hpAdd)
    self.hp  =self.hp+ hpAdd
    self.hp = math.min(self.hp,self.hpInit)
end

function PlayerCard:addPrice(   price)
    self.price  = self.price+price
end



function PlayerCard:countPercent() --加上百分比的值
    self.hp  = self.hp +self.hpPercent*self.hp/100
    self.physicalAttack  =  self.physicalAttack +self.physicalAttackPercent*self.physicalAttack/100
    self.magicAttack =self.magicAttack + self.magicAttackPercent*self.magicAttack/100
    self.agility =   self.agility +self.agilityPercent*self.agility/100
    self.physicalDefend = self.physicalDefend +self.physicalDefendPercent*self.physicalDefend/100
    self.magicDefend = self.magicDefend +self.magicDefendPercent*self.magicDefend/100
end


function PlayerCard:setHpInit()
    self.hpInit = self.hp
    self.maxRage = 2
end

function PlayerCard:getBuffAttrValue(attr)
    local value=0
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE)then
            if (pbuff.attr == attr) then
                value =value+ pbuff.value;
            end
        end
    end

    local k=math.rint(self:getAttrValue(attr) + value)
    return k;

end

function PlayerCard:addPlayerBuff(pbuff)
    if(pbuff.type == RESPONSE_TYPE_STUN or
        pbuff.type == RESPONSE_TYPE_REDUCE_HP or
        pbuff.type == RESPONSE_TYPE_IMMUNE or
        pbuff.type == RESPONSE_TYPE_LOCK  or
        pbuff.type == RESPONSE_TYPE_FROST or
        pbuff.type == RESPONSE_TYPE_FROZEN)then

        for key, pb in pairs(self.buffList) do
            if(pb.type == pbuff.type)then
                if(pbuff.type == RESPONSE_TYPE_IMMUNE)then
                    if(pb.attr == pbuff.attr)then
                        table.remove( self.buffList,key)--这些BUFF不能叠加
                    end
                else
                    table.remove( self.buffList,key)--这些BUFF不能叠加

                end
            end
        end

    end
    if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and pbuff.attr == Attr_RAGE) then
        self:addRage( pbuff.value)
    elseif(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and pbuff.attr == Attr_RELIVE_POINT) then
        self:addRelivePoint();
    else
        table.insert(self.buffList,pbuff)
    end
    --print("PlayerCard "..self.cardid.." addPlayerBuff pbuff.type = "..pbuff.type)
end



function PlayerCard:getExplodeBuff(  i)
    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local buff = DB.getBuffById(buffId)
            if(buff.type== BUFFER_TYPE_EXPLODE_AFTER_DEAD) then
                if(gCheckBuffRate(buff, buffData[1],SKILL_TYPE_ALL)) then
                    return buff
                end
            end
        end
    end
    return nil
end

function PlayerCard:getRebondDamagePercent()
    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local buff = DB.getBuffById(buffId)
            if(buff.type == BUFFER_TYPE_REBOUND_DAMAGE)then
                return getAttrValue0(buff,buffData[1])
            end
        end
    end

    return 0
end



function PlayerCard:getAttrValue(  attr)


    if( attr== Attr_PHYSICAL_ATTACK)then
        return self.physicalAttack
    elseif( attr== Attr_MAGIC_ATTACK)then
        return self.physicalAttack
    elseif( attr== Attr_PHYSICAL_DEFEND)then
        return self.physicalDefend
    elseif( attr== Attr_MAGIC_DEFEND)then
        return self.magicDefend
    elseif( attr== Attr_PHYSICAL_ATTACK_PERCENT)then
        return self.physicalAttackPercent
    elseif( attr== Attr_MAGIC_ATTACK_PERCENT)then

        return self.magicAttackPercent
    elseif( attr== Attr_PHYSICAL_DEFEND_PERCENT)then
        return self.physicalDefendPercent
    elseif( attr== Attr_MAGIC_DEFEND_PERCENT)then
        return self.magicDefendPercent


    elseif( attr== Attr_HIT_RATE)then
        return self.hitRate
    elseif( attr== Attr_DODGE_RATE)then
        return self.dodgeRate
    elseif( attr== Attr_CRITICAL_RATE)then
        return self.criticalRate

    elseif( attr== Attr_TOUGHNESS_RATE)then
        return self.toughnessRate
    else

        print("PlayerCard.getAttrValue error = "..attr)
    end

    return 0

end

function PlayerCard:getReliveHpPercent(rateReduce)

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local buff = DB.getBuffById(buffId)
            if(buff.type == BUFFER_TYPE_RELIVE)then
                if(gCheckReliveRate(buff,buffData[1],SKILL_TYPE_ALL,self.reliveCount,rateReduce))then
                    return getAttrValue0(buff,buffData[1])
                end
            end
        end
    end

    return 0
end

function PlayerCard:getReliveLimitCountHpPercent()

    for key, buffData in pairs(self.cardBuffList) do
        local buffId = buffData[0]
        if(buffId and buffId > 0) then
            local buff = DB.getBuffById(buffId)
            if(buff and buff.type == BUFFER_TYPE_RELIVE_LIMIT_COUNT and self.buff_relive_count<buff.round)then
                 self.buff_relive_count =  self.buff_relive_count+1
                 return buff.attr_value0
            end
        end
    end

    return 0
end



--[[
 * 判断是否触发 希尔瓦娜斯技能
 * @return 血量百分比
]]

function getReliveHpPercent(playerCards)
    local info={}
    info[0]=-1
    info[1]=-1
    info[2]=-1

    for k,friend in pairs(playerCards) do
        if friend and friend:isAlive() then
            for key, buffData in pairs(friend.cardBuffList) do
                local buffId = buffData[0]
                if(buffId and buffId > 0) then
                    local buff = DB.getBuffById(buffId)
                    if(buff.type == BUFFER_TYPE_RELIVE_FRIEND_BY_HP and
                    friend.hp > math.rint(friend.hpInit*getAttrValue0(buff,buffData[1])/100) and
                    friend.hp > math.rint(friend.hpInit*buff.target_card/100)
                     )then
                        info[0]=math.rint(getAttrValue1(buff,buffData[1]))
                        info[1]=math.rint(friend.hpInit*getAttrValue0(buff,buffData[1])/100)
                        info[2]=k
                        return info 
                    end
                end
            end
        end
    end

    return info
end


--[[***
     * 判断是否处于霜冻状态
     * @return 判断结果
     *]]
function PlayerCard:isFrost() 
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_FROST)then
            return true
        end
    end
    return false
end
--[[***
     * 被击后移除霜冻buff
     * @param playerCard
     *]]
     
function PlayerCard:removeFrostBuff() 
     for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_FROST)then
            table.remove(self.buffList,key)
            return 
        end
    end   
end
--[[**
     * 判断是否处于结冰状态
     * @return 判断结果
     *]]

function PlayerCard:isFrozen() 
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_FROZEN)then
            return true
        end
    end
    return false
end
       
function PlayerCard:removeFrozenBuff() 
     for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_FROZEN)then
            table.remove(self.buffList,key)
            return 
        end
    end   
end
 

function PlayerCard:isStuning()
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_STUN)then
            return true
        end
    end
    return false
end
function PlayerCard:isSkillImmune(  attackAttr)
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_IMMUNE and  attackAttr == pbuff.attr)then
            return true
        end
    end
    return false
end


function PlayerCard:getReduceHpBuff()
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_REDUCE_HP)then
            return pbuff
        end
    end
    return nil
end

function PlayerCard:getSkillDefendAttr(  attackAttr)
    if(attackAttr == Attr_PHYSICAL_ATTACK)then
        return self:getAttackOrDefendValue(Attr_PHYSICAL_DEFEND)
    elseif(attackAttr == Attr_MAGIC_ATTACK)then
        return self:getAttackOrDefendValue(Attr_MAGIC_DEFEND)
    else
        --print("PlayerCard.getSkillDefendAttr error = "..attackAttr);
        return 0;
    end
end

function PlayerCard:isSkillLocked()

    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_LOCK)then
            return true
        end
    end
    return false
end

function PlayerCard:isOneOfAttack(  attr)
    return attr == Attr_PHYSICAL_ATTACK or attr == Attr_MAGIC_ATTACK;
end
function PlayerCard:isOneOfDefend(  attr)
    return attr == Attr_PHYSICAL_DEFEND or attr == Attr_MAGIC_DEFEND;
end

--[[
/***
* 获取当前的攻击或者防御值
* @param attr 属性ID
* @return
*/ ]]
function PlayerCard:getAttackOrDefendValue(  attr)
    if(attr == Attr_PHYSICAL_ATTACK or
        attr == Attr_PHYSICAL_DEFEND or
        attr == Attr_MAGIC_ATTACK or
        attr == Attr_MAGIC_DEFEND) then
        local value = 0
        local percent = 0
        for key, pbuff in pairs(self.buffList) do
            if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE)then
                if( pbuff.attr == Attr_ALL_ATTACK and self:isOneOfAttack(attr))then
                    value  =value+ pbuff.value
                elseif(attr == pbuff.attr or (pbuff.attr == Attr_ALL_DEFEND and self:isOneOfDefend(attr)))then
                    value  =value+ pbuff.value
                elseif(attr + 10 == pbuff.attr)then
                    percent  =percent+ pbuff.value
                end
            end
        end
        if(percent<0)then
            percent=math.max(-90,percent)
        end

        local a=self:getAttrValue(attr)
        local b=(100+percent)/100
        return math.rint(a*b+value)
    end
    -- print("PlayerCard "..cardid.." getAttackOrDefendValue error = "..attr)
    return 0
end

function PlayerCard:subShield(  damage)
    return self.shield - damage
end

function PlayerCard:getHpRate()
    return self.hp/self.hpInit
end


function PlayerCard:isHpLow(  percent)
    return self:getHpRate() < percent/100
end

---返回要删除的buff
function PlayerCard:resetBuffRound()
    local list={}
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.roundCount <= 0)then
            if(pbuff.type == RESPONSE_TYPE_REDUCE_HP or
                pbuff.type ==  RESPONSE_TYPE_STUN or
                pbuff.type ==  RESPONSE_TYPE_LOCK or
                pbuff.type ==  RESPONSE_TYPE_FROST or
                pbuff.type ==  RESPONSE_TYPE_FROZEN or
                pbuff.type ==  RESPONSE_TYPE_IMMUNE) then
                table.insert(list,pbuff)
            end

            if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and pbuff.attr == Attr_HURT_DOWN and  self:getHurtDownBuffNum() <=1 )then
                table.insert(list,pbuff) --当最后一条减伤移除的时候，才通知客户端取消减伤效果
            end


            table.remove(self.buffList,key)
        else
            pbuff.roundCount=pbuff.roundCount-1
        end
    end
    return list
end

function PlayerCard:resetRelivePoint()
    self.relivePoint = 0;
end


function PlayerCard:addRelivePoint()
    self.relivePoint=self.relivePoint+1
end
--[[
* 获取buff列表中还有几条减伤
* @return
]]
function PlayerCard:getHurtDownBuffNum()
    local count = 0;
    for key, pbuff in pairs(self.buffList) do
        if(pbuff.type == RESPONSE_TYPE_ATTR_CHANGE and  pbuff.attr == Attr_HURT_DOWN)then
            count=count+1;
        end
    end
    return count;
end



return PlayerCard