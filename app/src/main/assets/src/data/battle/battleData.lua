gBattleData={}


--——pos     byte    位置                  
--——cardid     int 卡牌ID                    
--——level      int 等级                  
--——grade      byte    进阶                  
--——wakeup     byte    觉醒                  
--——hpInit     int 初始血量                    
--——physicalAttack     int 物攻                  
--——magicAttack        int 魔攻                  
--——agility        int 敏捷                  
--——physicalDefend     int 物防                  
--——magicDefend        int 魔防                  
--——hit        int 命中                  
--——dodge      int 闪避                  
--——critical       int 暴击                  
--——toughness      int 抗暴                  
--——maxRage        int 怒气值上限    

function gParserGamePlayer(data)
    local player={}
    player.pos=data:getByte()
    player.cardid=data:getInt()
    player.level=data:getInt()
    player.grade=data:getByte()
    player.quality=data:getByte()
    player.hpInit=data:getInt()
    player.physicalAttack=data:getInt()
    player.hp=data:getInt()
    player.agility=data:getInt()
    player.physicalDefend=data:getInt()
    player.magicDefend=data:getInt()
    player.hit=data:getInt()
    player.dodge=data:getInt()
    player.critical=data:getInt()
    player.toughness=data:getInt()
    player.maxRage=data:getInt() 
    player.rage=data:getInt() 
    for i=1, 6 do
        data:getInt()  
    end
    player.weaponLv=data:getInt() 
    player.awakeLv=data:getInt() 
    for i=1, 8 do
        data:getInt()  
    end
    --[[
         putByte(pos);
        putInt(playerCard.cardId);
        putInt(playerCard.level);
        putByte(playerCard.grade);
        putByte(playerCard.wakeup);
        putInt(playerCard.hpInit);
        putInt(playerCard.physicalAttack);
        putInt(playerCard.hp);
        putInt(playerCard.agility);
        putInt(playerCard.physicalDefend);
        putInt(playerCard.magicDefend);
        putInt(playerCard.hit);
        putInt(playerCard.dodge);
        putInt(playerCard.critical);
        putInt(playerCard.toughness); 
        putInt(playerCard.maxRage);//怒气上限值
        putInt(playerCard.rage);//怒气值
        putInt(playerCard.hitRate);
        putInt(playerCard.dodgeRate);
        putInt(playerCard.criticalRate);
        putInt(playerCard.toughnessRate);
        putInt(playerCard.hurtDownPercent);
        putInt(playerCard.powerRaisePercent);
        '']]
   return player
end


function gParserGamePet(data)
    local pet={}
    pet.petid=data:getInt()
    if(pet.petid==0)then
        return nil
    end
    pet.level=data:getInt()
    pet.grade=data:getByte()
    pet.skillLevel=data:getInt()
    pet.awakeLv = Pet.getPetAwakeLvByGrade(pet.grade)
    local size=data:getInt()
    pet.buffs={}
    for i=1, size do
    	local buf={}
        buf.buffid=data:getInt()   
    	buf.level=data:getInt()   
        table.insert(pet.buffs,pet)
    end 
    return pet
end



function gParserGameTeam(data)
    local team={}
    for i=1, 2 do
        data:getInt()  
    end
    local circleId = data:getInt()
    -- 服务端有下发countryId,没有用到，未解析
    data:getInt()
    local power=data:getInt()   
    local pet=gParserGamePet(data)
    
    
    local num = data:getByte()
    for i=0, num-1 do
        table.insert(team,i,gParserGamePlayer(data))
    end  
    return team,pet,power,circleId; 

end

--—type       byte    0:伤害去血 1：属性增加 2：属性减少 3:触发免疫                 
--—attr       byte    属性                  
--—value      int 属性值                 
--—isCritical     bool    是否暴击                                      
function gParserRoundTargetEffect(data)
    local effect={}

    effect.type = data:getByte()
    effect.attr = data:getByte()
    effect.value = data:getInt() 
    effect.isCritical = data:getBool() 
   
    return effect
end

--—isEnemy       bool    是否敌人                    
--—position       byte    目标位置                    
--—response       byte    反应（0：无 1：闪避 2：化解 3：回血 4:替补上场）                   
--—responseRound      byte    眩晕或者封印的回合数                  
--—isDead     bool    是否死亡（0：否 1：是）                   
--—damage     int 伤害值、吸血值、回血值                   
--—length     byte    列表的长度                   
--—list       列表  targetEffect列表             
function gParserRoundTarget(data)
    local target={}
    
    target.isEnemy = data:getBool()
    target.position = data:getByte()
    target.response = data:getByte()
    target.responseRound = data:getByte()
    target.isDead = data:getBool()
    target.damage = data:getInt()
    target.copyCardId = data:getInt()
      
    target.effectList={}
    local num = data:getByte()
    for i=1, num do
        table.insert(target.effectList,gParserRoundTargetEffect(data))
    end  
    return target
end
--—activeSide     byte    攻击方在哪边（1：左or下 2：右or上）                   
--—activePosition     byte    攻击者位置 （0-6）                 
--—targetPosition     byte    攻击目标位置                  
--—actionType     byte    攻击类型（0：普通攻击 1：技能攻击 2：反击 3：自爆）                   
--—skillId        int 技能ID（0：表示无技能）                   
--—skillType       bool    是否为大招                   
--—rageAdd        int 怒气增加值                   
--—length     byte    目标对象个数                  
--—list       数组  target列表                
function gParserRoundAction(data)
   
    local action={}
    action.activeSide = data:getByte()
    action.activePosition =  data:getByte()
    action.targetPosition =  data:getByte()
    action.actionType =  data:getByte() 
    action.skillId =  data:getInt() 
    action.skillType =  data:getByte() 
    action.rageAdd =  data:getInt()  
    action.buffTargets={}
    local num = data:getByte()
    for i=1, num do
        table.insert(action.buffTargets,gParserRoundTarget(data))
    end  
    
    action.targets={}
    num = data:getByte()
    for i=1, num do
        table.insert(action.targets,gParserRoundTarget(data))
    end  
   
    return action
end
                
function gParserRound(data)


    local round={};
    round.roundIndex =data:getByte()  
    round.actions={}
    local num = data:getByte()
    for i=1, num do
        table.insert(round.actions,gParserRoundAction(data))
    end   
    return round;
 

end


function gParserRoundList(data)

    local roundList={}
    local num = data:getByte()
    for i=1, num do
        table.insert(roundList,gParserRound(data))
    end  
    return roundList; 

end

--竞技场战斗录像
function gParserGameVideo(data,type)
    gBattleData={}
    Battle.battleType=type
    Battle.reward={}
    Battle.reward.formation={}

    gIsBattleVideo=true
    
    if(type==BATTLE_TYPE_CRUSADE or type==BATTLE_TYPE_FAMILY_STAGE)then
        MAX_ROUND=5
    elseif (type==BATTLE_TYPE_WORLD_BOSS) then
        MAX_ROUND=Data.worldBossParam.fight_round
    else 
        MAX_ROUND=DB.getServerRound()
    end
    data:resetPos()
    gBattleData.playerCards1,gBattleData.playerPet1,gBattleData.power1,gBattleData.circleId1=gParserGameTeam(data)
    gBattleData.playerCards2,gBattleData.playerPet2,gBattleData.power2,gBattleData.circleId2=gParserGameTeam(data)
    gBattleData.win=data:getByte()
    gBattleData.battleRoundList=gParserRoundList(data)

    for key, card in pairs(gBattleData.playerCards1) do 
        table.insert(Battle.reward.formation,{cardid=card.cardid})
    end
    if type==BATTLE_TYPE_WORLD_BOSS then
        gBattleData.bgName="b010"
    elseif type==BATTLE_TYPE_SERVER_BATTLE or type==BATTLE_TYPE_SERVER_BATTLE_LOG then
        gBattleData.bgName="b012"
    elseif type==BATTLE_TYPE_CAVE_CHALLENGE then
        gBattleData.bgName="b006"
    else
        gBattleData.bgName="b003"
    end
    Battle.preloadBattle(gBattleData,{},Scene.enterBattle)
     
end

    

 