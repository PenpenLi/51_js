local PlayerPet=class("PlayerPet")



function PlayerPet:ctor(pet)
    self.petid=pet.petid
    self.level=pet.level
    self.grade=pet.grade
    self.triggerCount=1
    self.skill_level=pet.skillLevel1
    self.buff0_level=pet.skillLevel2
    self.buff1_level=pet.skillLevel3
    self.buff2_level=pet.skillLevel4
    self.buff3_level=pet.skillLevel5
    self.buffList={}
    self.buffLevel={}
    self.triggerRateInit = 0--初始触发概率
    self.triggerRateAdd = 0--触发概率增长值
    self.triggerRate = 0--触发概率
    self.triggerCount=0
    self.addcriticalrate=0

    local petDb=DB.getPetById(pet.petid)
    
    self.attackParam=toint( string.split( petDb.attack_params,";")[self.grade])
    for i=0, 3 do
        if(self["buff"..i.."_level"]>=1)then
            for key, buffid in pairs(petDb["buff"..i]) do
                table.insert(self.buffList, DB.getBuffById(toint(buffid)))
                table.insert(self.buffLevel, self["buff"..i.."_level"])
            end
        end
    end
    self.triggerRateInit=petDb.skill_rate
    if(pet.trinit and pet.trinit>0)then
        self.triggerRateInit= self.triggerRateInit+ pet.trinit
    end
    self.triggerRateAdd=petDb.skill_rate_add
    self.triggerRate = self.triggerRateInit;
    if pet.addcriticalrate then
        self.addcriticalrate = pet.addcriticalrate
    end

    self.trggerTable=string.split(petDb.trigger_param,";")
end


--[[
function PlayerPet:getResistPercent( pos)

for key, buff in pairs(self.buffList) do
if(isBuffInRange(buff,pos)  and buff.type ==BUFFER_TYPE_REDUCE_HURT)then
return getAttrValue0(buff,self.buffLevel[key]) --减伤不能超过100%
end
end

return 0
end



function PlayerPet:getAddDamagePercent( pos)

for key, buff in pairs(self.buffList) do
if(isBuffInRange(buff,pos)  and buff.type ==BUFFER_TYPE_ADD_DAMAGE)then
return getAttrValue0(buff,self.buffLevel[key])
end

end
return 0

end
]]


function PlayerPet:getRecoverHp(  pos,playerCard)
    if playerCard:hasRadiationSkill() and  playerCard:isAlive() == false then --带有死亡释放大招技能，死亡出手不回血
       return 0
    end

    for key, buff in pairs(self.buffList) do
        if(isBuffInRange(buff,pos)  and buff.type ==BUFFER_TYPE_RECOVERY_AFTER_ATTACK and   gCheckBuffRate(buff,self.buffLevel[key],0))then
            local value = 0;
            local percent = getAttrValue0(buff,self.buffLevel[key])
            if(buff.attr_id0 == Attr_PHYSICAL_ATTACK_PERCENT)then
                value = playerCard.physicalAttack;
                return math.rint( value*percent/100)
            elseif(buff.attr_id0 == Attr_PET_SKILL_LEVEL)then
                value = self.level;
                return math.rint( value*percent)
            end
        end
    end
    return 0
end

function PlayerPet:reliveIsAddRage()
    for key, buff in pairs(self.buffList) do
        if buff.type ==BUFFER_TYPE_PET_RELIVE_ADD_RAGE then
            return true
        end
    end
    return false
end

function PlayerPet:getReliveHpPercent(  pos,reliveCount,rateReduce)
    for key, buff in pairs(self.buffList) do
        if(isBuffInRange(buff,pos)  and buff.type ==BUFFER_TYPE_RELIVE  and  gCheckReliveRate(buff,self.buffLevel[key],SKILL_TYPE_ALL,reliveCount,rateReduce))then
            return getAttrValue0(buff,self.buffLevel[key])
        end

    end
    return 0
end

function PlayerPet:getReduceAttrAfterRelive()
    for key, buff in pairs(self.buffList) do
        if (buff.type == BUFFER_TYPE_REDUCE_ATTR_AFTER_RELIVE) then
            return petBuff,self.buffLevel[key]
        end
    end
end


function PlayerPet:getPowerRaiseWhenLowHp(  pos,   playerCard)
    for key, buff in pairs(self.buffList) do
        if (isBuffInRange(buff,pos) and buff.type == BUFFER_TYPE_POWER_RAISE_WHEN_LOW_HP ) then
            local per= 1-( playerCard.hpInit- playerCard.hp)/playerCard.hpInit*buff.attr_value1 ;
            local value = getAttrValue0(buff,self.buffLevel[key])*per
            return math.max(0, value);
         elseif (isBuffInRange(buff,pos) and buff.type ==BUFFER_TYPE_ADD_ATTACK_WHEN_LOW_HP ) then
            local value =buff.attr_value0+ ( playerCard.hpInit- playerCard.hp)/ playerCard.hpInit*buff.attr_add_value0*(self.buffLevel[key]-1);
            return math.max(0, value); 
         end

    end
    return 0;
end




function PlayerPet:getReduceReliveRate()
    for key, buff in pairs(self.buffList) do
        if (buff.type== BUFFER_TYPE_REDUCE_RELIVE_RATE) then
            return getAttrValue0(buff,self.buffLevel[key])
        end
    end
    return 0;
end



function PlayerPet:addTriggerRate( pnum)
    local rate=DB.getPetTriggerRate(pnum)
    self.triggerRate =self.triggerRate+ self.triggerRateAdd*rate/100;

end



function PlayerPet:addTriggerCount()
    self.triggerCount =self.triggerCount+1
end

function PlayerPet:isTriggerSkill(playerNum)
    if(playerNum == 0)then
         return false;
    end

    self.triggerCount=self.triggerCount+1
    
 
    
    local max=toint(self.trggerTable[playerNum])
    
    local rate = self.triggerRate
    local rand = getRand(0,10000)
    local ret =  rand < rate
 
    if(not ret and self.triggerCount >= max)then
        --两回合不触发技能，做保底概率
        ret = true;--rand < 9000;
    end
    if(ret)then
        self.triggerRate = self.triggerRateInit;
        self.triggerCount = 0;
    end

    return ret
end


return PlayerPet