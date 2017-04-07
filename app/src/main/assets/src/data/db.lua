
DB={}

function DB.deleteReplaceItem()

    for i=#card_db, 1, -1 do
        card_db[i].show = true;
        if (DB.isReplaceItem(card_db[i].cardid)) then
            -- table.remove(card_db, i)
            card_db[i].show = false;
        end
    end

    for i=#pet_db, 1, -1 do
        pet_db[i].show = true;
        if (DB.isReplaceItem(pet_db[i].petid)) then
            -- table.remove(pet_db, i)
            pet_db[i].show = false;
        end
    end
end

function DB.getMinematerialBuy(itemid)
    for key, var in pairs(minematerialbuyinfo_db) do
    	if(var.itemid==itemid)then
    	   return var
    	end
    end
    return nil
end

function DB.isReplaceItem(itemid)
    if(itemid == nil)then
        return false;
    end
    for key,item in pairs(replaceitem_db) do
        if(toint(itemid) == toint(item.itemid))then
            return true;
        end
    end    
    return false;
end

function DB.checkReplaceItem(itemid)
    if(itemid == nil)then
        return itemid;
    end
    for key,item in pairs(replaceitem_db) do
        if(toint(itemid) == toint(item.itemid))then
            return toint(item.replaceid);
        end
    end
    return itemid;
end

function DB.getBuffById(id)
    if(id==0)then
        return nil
    end
    
     if(DB.buff_db==nil)then
        DB.buff_db={} 
        for key, var in pairs(buff_db) do
           DB.buff_db[var.buffid]=var
        end 
    end 
    return DB.buff_db[id]
    
end

function DB.getCaveBoxById(id)
    for key, var in pairs(cavebox_db) do
        if var.id == id then
            return var
        end
    end
    return nil
end

function DB.getCaveChallengeInfoByPower(power)
    local var= nil
    local lastVar = nil
    power =  power or 0
    for key, item in pairs(cavechallengeinfo_db) do
        if power<=item.power then
            var=item
            break
        end
        lastVar = item
    end
    if var==nil then
        var=lastVar
    end
    return var
end

function DB.getRaiseByCardid(cardid)
    if( DB.cardraiselevel_db==nil)then
        DB.cardraiselevel_db={}
        
        for key, var in pairs(cardraiselevel_db) do
            if(DB.cardraiselevel_db[var.cardid]==nil)then
                DB.cardraiselevel_db[var.cardid]={}
            end
            table.insert( DB.cardraiselevel_db[var.cardid],var)
        end
    end
 
    return DB.cardraiselevel_db[cardid]

end

function DB.getTreasureUpgradeParam(quality)
    if(DB.treasureUpgradeParam==nil)then
        local temp=DB.getClientParam("TREASURE_UPDATE_PARAMS")
        DB.treasureUpgradeParam= string.split(temp,";")
    end

    return toint(DB.treasureUpgradeParam[quality+1])
end


function DB.getTreasureUpgradeAttrParam(quality)
    if(DB.treasureUpgradeAttrParam==nil)then
        local temp=DB.getClientParam("TREASURE_UPDATE_ATTR_DATA_PARAMS")
        DB.treasureUpgradeAttrParam= string.split(temp,";")
    end

    return toint(DB.treasureUpgradeAttrParam[quality+1])
end



function DB.getTreasureQuanchAttrParam(quality)
    if(DB.treasureQuanchAttrParam==nil)then
        local temp=DB.getClientParam("TREASURE_QUANCH_ATTR_DATA_PARAMS")
        DB.treasureQuanchAttrParam= string.split(temp,";")
    end

    return toint(DB.treasureQuanchAttrParam[quality+1])
end


function DB.getTreasureQuanchParam(quality)
    if(DB.treasureQuanchParam==nil)then
        local temp=DB.getClientParam("TREASURE_QUANCH_PARAMS")
        DB.treasureQuanchParam= string.split(temp,";")
    end

    return toint(DB.treasureQuanchParam[quality+1])
end

function DB.getCardRaisePower(power)
    if(DB.cardraisepower_db==nil)then
        DB.cardraisepower_db={}
    end
    if(DB.cardraisepower_db[power]==nil)then
        local ret=nil
        for key, var in pairs(cardraisepower_db) do
            if(power>=var.power)then
                ret=var
            end
        end
        DB.cardraisepower_db[power]=ret
    end
    return DB.cardraisepower_db[power]

end

function DB.getCardRaisePowerByLevel(level)
    for key, var in pairs(cardraisepower_db) do
        if(var.level==level)then
            return var
        end
    end
    return nil
end

function DB.getTreasureUpdateMaster(type,need)
    local ret=nil
    for key, var in pairs(treasureupdatemaster_db) do
        if(var.type==type and var.needlv<=need )then
            ret=var
        end
    end
    return ret

end

function DB.getTreasureUpdateMasterByLevel(type,level)
    for key, var in pairs(treasureupdatemaster_db) do
        if(var.type==type and var.level==level )then
            return var
        end
    end
    return nil

end

function DB.getSignIapReward()
    local day=gGetCurDay()
    local regDay= gGetCurDay(gUserInfo.regTime)

    if(day.yday-regDay.yday<0)then
       if((day.year-1)%4==0)then
            day.yday=day.yday+366
        else
            day.yday=day.yday+365
       end
    end
    local diffTime = os.difftime(gGetCurServerTime(),gUserInfo.regTime)
    if(diffTime<7*24*3600 and day.yday-regDay.yday<=6)then
        local ret={}
        local totalDay=day.yday-regDay.yday+1
        for key, item in pairs(signiapreward_db) do
            if(item.signyear==1999 and
                item.signday==totalDay  )then
                table.insert(ret,item)
            end
        end
        return ret
    end


    local default={}
    local ret={}
    for key, item in pairs(signiapreward_db) do
        if(item.signyear==day.year and
            item.signmonth==day.month and
            item.signday==day.day  )then
            table.insert(ret,item)
        end
        if(item.signyear==2000)then
            table.insert(default,item)
        end
    end
    if(table.count(ret)==0)then
        return default
    else
        return ret
    end
end

function DB.IsInTeachStage(type,mapid,stageid)
    if(type~=0)then
        return false
    end

    local temp=DB.getClientParam("TEACH_VEDIO_STAGE")
    local temp= string.split(temp,";")
    for key, var in pairs(temp) do
        if(toint(var)==mapid*100+stageid)then
            return true
        end
    end
    return false
end

function DB.getFamilyDonateItem(itemid)
    if(DB.familydonateitem_db==nil)then
        DB.familydonateitem_db={} 
        for key, var in pairs(familydonateitem_db) do
            DB.familydonateitem_db[var.id]=var
        end 
    end 
    return DB.familydonateitem_db[itemid]
end


function DB.getFamilyBuff(buffid,level)
    for key,var in pairs(familyskillattr_db) do
        if(var.skillid == buffid and var.level == level)then
            return var;
        end
    end
    local ret = {};
    ret.val = 0;
    ret.val1 = 0;
    return ret;
end

function DB.getFamilySevenReward(familyLv)
    local reward = {};
    for key,var in pairs(familyselv_db) do
        if(toint(var.level) == familyLv)then
            if(toint(var.item1) > 0 and toint(var.num1) > 0)then
                table.insert(reward,{id=var.item1,num=var.num1});
            elseif(toint(var.item2) > 0 and toint(var.num2) > 0)then
                table.insert(reward,{id=var.item2,num=var.num2});
            elseif(toint(var.item3) > 0 and toint(var.num3) > 0)then
                table.insert(reward,{id=var.item3,num=var.num3});
            end
        end
    end
    return reward;
end

function DB.getBossData(lv)
    for k,v in pairs(worldbossconfig_db) do
        if (v.level == lv) then
            -- goldpro = v
            return v
        end
    end
    return nil
end


function DB.getWeaponUpgradeDia(point)
    local temp=string.split( DB.getClientParam("WEAPON_UPGRADE_ADD_RATE_PRICE"),";")

    local ret=0
    for i=1, point do
        ret=ret+  temp[1]+math.floor(i/temp[2])*temp[3]
    end
    return ret
end

function DB.getCardAwakeTable(cardid)
 if( DB.cardwaken_db==nil)then
        DB.cardwaken_db={}
        for key, var in pairs(cardwaken_db) do
            if(DB.cardwaken_db[var.cardid]==nil)then
                DB.cardwaken_db[var.cardid]={}
            end
            table.insert( DB.cardwaken_db[var.cardid],var)
        end
    end
 
    return DB.cardwaken_db[cardid]
    
    
end

function DB.getCardAwake(cardid,awakelv)
    local datas=DB.getCardAwakeTable(cardid)
    for key,var in pairs(datas) do
        if   var.waken == awakelv then
            return var;
        end
    end
    return nil;
end

function DB.getCountryId(id)
    for key, var in pairs(country_db) do
        if(var.countryid== id)then
            return var
        end
    end
end

function DB.getCountryBuffs(countryid)
    local countryInfo=DB.getCountryId(countryid)
    if(countryInfo)then
        local buffs=string.split(countryInfo.bufflist,";")
        return buffs
    end
    return {}
end

function DB.getCooperateDamage(level)
    local damage=string.split( DB.getClientParam("SKILL_COOPERATE_DAMAGE_ADD") ,";")
    if(damage[level])then
        return  toint(damage[level])
    end

    return 0
end

function DB.getPowerDiffRate(power,powerLimit)
    if(power>=powerLimit or powerLimit==0)then
        return 0
    end
    local curDiff=((powerLimit-power)/powerLimit)*10000
    local item=nil
    local diffs={}
    for i=1, table.getn(stagepower_db) do
        local key=table.getn(stagepower_db)-i+1
        if(stagepower_db[key] and powerLimit>=stagepower_db[key].powerdiff)then
            if(item==nil)then
                item=stagepower_db[key]
            end
            if(item.powerdiff~=stagepower_db[key].powerdiff)then
                break
            end
            table.insert(diffs,stagepower_db[key] )
        end
    end


    if(table.getn(diffs)~=0)then
        item=nil
    end

    for key, diff in pairs(diffs) do
        if(curDiff>=diff.diffpercent)then
            item=diff
            break
        end
    end

    if(item==nil)then
        if(table.getn(diffs)==0)then
            item=stagepower_db[1]
        else
            item=diffs[table.getn(diffs)]
        end

    end

    return item.damagepercet/10000

end




function DB.getRaiseCardNeedGold(card)

    return  math.rint((card["raise_physicalAttack"] / 1 + card["raise_physicalDefend"] / 0.76 +  card["raise_magicDefend"]/ 0.76 +card["raise_hp"]/ 4) / 4 * 18 + 15000)
end

function DB.getIapById(id)
    for key, var in pairs(iap_db) do
        if(var.iapid== id)then
            return var
        end
    end
end

function DB.getCardRaiseByLevel(cardid,level)
    for key, var in pairs(cardraiselevel_db) do
        if(var.cardid== cardid and var.level==level)then
            return var
        end
    end
end

function DB.getDiaForMonthCard()
    local taskDB=DB.getDayTask(15);
    if taskDB then
        return taskDB.gdata1;
    end
    return 0;
end

function DB.getDiaForLifeCard()
    local taskDB=DB.getDayTask(21);
    if taskDB then
        return taskDB.gdata1;
    end
    return 0;
end


function DB.getRelationByType(type,level)
    if(level==nil)then
        level=1
    end
    local ret={}
    for key, var in pairs(relation_db) do
        if(var.type == type and var.level==level)then
            table.insert(ret,var)
        end
    end
    return ret
end

function DB.getRelationByCardId(cardid,level)
    if(level==nil)then
        level=1
    end
    local ret={}
    for key, var in pairs(relation_db) do
        if(string.find(var.cardlist,cardid) and var.level==level)then
            table.insert(ret,var)
        end
    end
    return ret
end

function DB.getMaxRelationLevel(rid)
    if(DB.maxRelationLevel==nil)then
        DB.maxRelationLevel={}
    end

    if( DB.maxRelationLevel[rid]~=nil)then
        return  DB.maxRelationLevel[rid]
    end

    local count=0
    for key, var in pairs(relation_db) do
        if(var.relationid==rid)then
            count=count+1
        end
    end
    DB.maxRelationLevel[rid]=count

    return  DB.maxRelationLevel[rid]


end


function DB.getFamilyBuildUnlock(type)
    local temp=string.split(DB.getClientParam("FAMILY_BUILD_OPEN_LEVEL"),";")
    if( temp[type])then
        return toint( temp[type])
    end
    return 0
end


function DB.getLuckWheelMaxNum(type,vip)
    local temp=string.split(DB.getClientParam("TURN_TYPE"..type.."_NUM"),";")
    if( temp[vip+1])then
        return toint( temp[vip+1])
    end
    return 0
end

function DB.getLuckWheelFreeNum(type )
    local temp=string.split(DB.getClientParam("TURN_FREE_NUM"),";")
     
    return toint(temp[type])
end

function DB.getLuckWheelPriceType(type )
    local temp=string.split(DB.getClientParam("TURN_PRICE_TYPE"),";")
     
    return toint(temp[type])
end

function DB.getLuckWheelPrice1(type )
    local temp=string.split(DB.getClientParam("TURN_PRICE_1"),";") 
    return toint(temp[type])
end



function DB.getLuckWheelPrice10(type )
    local temp=string.split(DB.getClientParam("TURN_PRICE_10"),";") 
    return toint(temp[type])
end



function DB.getLuckWheelCostItem(type )
    local temp=string.split(DB.getClientParam("TURN_PRICE_ITEM"),";")

    return toint(temp[type])
end

function DB.getRelationById(rid,level)
    if(level==nil)then
        level=1
    end
    for key, var in pairs(relation_db) do
        if(var.relationid==rid and var.level==level)then
            return var
        end
    end
    return nil
end

function DB.getBattleSkip(id)
    local limit=  DB.getClientParam(id)
    limit =string.split(limit,";")
    return toint(limit[1]),toint(limit[2]),toint(limit[3])
end

function DB.getPetUnlockSoulNum(petid)
    local pet = DB.getPetById(petid);
    if(pet)then
        return toint(pet.unlocksoul);
    end
    return 0;
end

function DB.getPetUnlockLevel(petid)

    local pet = DB.getPetById(petid);
    if(pet)then
        return toint(pet.unlocklevel);
    end
    return 1;
-- local levels=  DB.getClientParam("PET_UNLOCK_LEVEL")
-- levels =string.split(levels,";")

-- local ids=  DB.getClientParam("PET_UNLOCK_LIST")
-- ids=  string.split(ids,";")

-- for key, id in pairs(ids) do
--     if(toint(id)==petid)then
--         return toint(levels[key])
--     end
-- end
-- return 0

end

function DB.getTowerShopById(itemid) 
    for key, var in pairs(townshop_db) do
        if(var.itemid== itemid)then
            return var
        end
    end
    return nil;
end

function DB.getItemSourceById(itemid)
    for key, var in pairs(itemsource_db) do
        if(var.id== itemid)then
            return var
        end
    end
    return nil;
end

function DB.getLogin7Reward()
    local ret={}
    for key, var in pairs(gift_common_db) do
        if(var.status== 6)then
            table.insert(ret,var)
        end
    end
    return ret;
end

function DB.getVipDayGift()
    local ret={}
    for key, var in pairs(gift_common_db) do
        if(var.status== 8)then
            table.insert(ret,var)
        end
    end
    return ret;
end

function DB.getLevelUpReward()
    local ret={}
    for key, var in pairs(gift_common_db) do
        if(var.status== 5)then
            table.insert(ret,var)
        end
    end
    return ret;
end

function DB.getLevelUpExtraReward()
    local ret={}
    for key, var in pairs(gift_common_db) do
        if(var.status== 55)then
            table.insert(ret,var)
        end
    end
    return ret;
end

function DB.getRelationTitleById(id)
    for key, var in pairs(relation_title_db) do
        if(var.titleid== id)then
            return var
        end
    end
    return nil
end

function DB.getActStageInfoById(type,diff)
    for key, info in pairs(actstageinfo_db) do
        if(info.type==type and info.diff==diff)then
            return info
        end
    end
    return nil
end

function DB.getMonsterById(id)
    
    if(DB.monster_db==nil)then
        DB.monster_db={}
        for key, var in pairs(monster_db) do
            DB.monster_db[var.id]=var
        end
    end 
     
    return DB.monster_db[id]
end

function DB.getPetById(id)
    if(id==0)then
        return nil
    end
    if(DB.pet_db==nil)then
        DB.pet_db={}
        for key, var in pairs(pet_db) do
            DB.pet_db[var.petid]=var
        end
    end

    return DB.pet_db[id]

end


function DB.getArenaReward(lv)
    for key, var in pairs(arenareward_db) do
        if(lv>=toint(var.rank_up) and lv<=toint(var.rank_down))then
            return var
        end
    end
    return nil
end

function DB.getArenaRewardForId(id)
    for key, var in pairs(arenareward_db) do
        if (id == toint(var.id)) then
            return var;
        end
    end
    return nil
end

function DB.getArenaReward_Last()
    local len = table.getn(arenareward_db)
    for i=len,1,-1 do
        local var = arenareward_db[i]
        if (var.item1 ~= 0) then
            return arenareward_db[i];
        end
        -- print(i)
    end
    return arenareward_db[len];
end

function DB.getUserExpByLevel(level)
    for key, var in pairs(user_exp_db) do
        if(var.level== level)then
            return var
        end
    end
    return nil
end

function DB.getPetExpByLevel(level,petid)
    for key, var in pairs(pet_exp_db) do
        if(var.level== level and var.petid==petid)then
            return var
        end
    end
    return nil
end



function DB.getBoxItemById(id)
    local ret={}
    for key, var in pairs(boxitem_db) do
        if(var.boxid== id)then
            table.insert(ret,var)
        end
    end
    return ret
end


function DB.getDayTask(id)


    local task = nil;
    for key, var in pairs(daytask_db) do
        if(var.id== id)then
            -- return var
            task = var;
            break;
        end
    end

    if(task) then
        -- if(id <= 101 and id <= 104)then
        for key,var in pairs(daytaskreward_db) do
            if(id == var.daytaskid)then
                if(Data.getCurLevel() >= var.min and Data.getCurLevel() <= var.max) then
                    task.gtype1 = var.gtype1;
                    task.gdata1 = var.gdata1;
                    task.gtype2 = var.gtype2;
                    task.gdata2 = var.gdata2;
                    task.gtype3 = var.gtype3;
                    task.gdata3 = var.gdata3;
                    -- print("replay task");
                    break;
                end
            end
        end
        -- end
    end

    return task
end

function DB.getRecruitMateById(id)
    for key, var in pairs(recruit_mate_db) do
        if(var.id== id)then
            return var
        end
    end
    return nil
end

function DB.getBoxById(id)
    for key, var in pairs(box_db) do
        if(var.boxid== id)then
            return var
        end
    end
    return nil
end

function DB.getChapterById(id,type)
    for key, var in pairs(chapter_db) do
        if(var.map_id== id and var.type==type)then
            return var
        end
    end
    return nil
end


function DB.getTurnGoldById(id)
    for key, var in pairs(turngold_db) do
        if(var.id== id)then
            return var
        end
    end
    return nil
end





function DB.getVip(vip)
    for key, var in pairs(vip_db) do
        if(var.vip== vip)then
            return var
        end
    end
    return nil
end

-- function DB.getMaxBuyGoldNum(vip)
--     for key, var in pairs(vip_db) do
--         if(var.vip== vip)then
--             return var.stonegold_11
--         end
--     end
--     return 0
-- end
function DB.getSweepTowerTime()
    return DB.getClientParam("PET_STAGE_SWEEP_TIME")
end


function DB.getFamilyWarJoinNum(level)
    local temp=string.split( DB.getClientParam("FAMILY_BATTLE_PLAYER_MAX"),";")
    local lastLv=0
    for key, var in pairs(temp) do
        if(level>=key)then
            lastLv=toint(var)
        end
    end
    return lastLv
end



function DB.getAtlasTotalStar(id,type)
    return 3*DB.getAtlasStageNum(id,type)
end

function DB.getAtlasStageNum(id,type)
    local stageNum=0
    for key, var in pairs(stage_db) do
        if(var.map_id== id   and var.type==type)then
            stageNum=stageNum+1
        end
    end

    if(type==ATLAS_TYPE_BOSS)then
        stageNum=stageNum-1
    end
    if(stageNum<=0)then
        stageNum=0
    end
    return stageNum
end



function DB.getStagesByMapId(id,type)
    local ret={}
    for key, var in pairs(stage_db) do
        if(var.map_id== id and   var.type==type)then
            table.insert(ret,var)
        end
    end
    return ret
end


function DB.getStageById(id,stageid,type)
    if(DB.stage_db==nil)then
        DB.stage_db={}
    end

    local saveKey=type*100000+id*100+stageid
    if(DB.stage_db[saveKey]==nil)then
        for key, var in pairs(stage_db) do
            if(var.map_id== id and var.stage_id==stageid and var.type==type)then
                DB.stage_db[saveKey]=var
                return var
            end
        end
    end 
    return DB.stage_db[saveKey]
end

function DB.getCrusadeFeatByLevel(lv)
    local ret={}
    for key, var in pairs(feats_db) do
        if(var.level1<=lv and var.level2>=lv)then
            table.insert(ret,var)
        end
    end
    return ret
end


function DB.findStringInTable(str1,str2)
    local temp= string.split(str1,";")
    for key, var in pairs(temp) do
        if(toint(var)==str2 or toint(var)-ITEM_TYPE_SHARED_PRE==str2 )then
            return true
        end
    end
    return false
end
function DB.getStageByItemId(itemid)
    local ret={}
    for key, var in pairs(stage_db) do
        if(var.type~=10 and var.node~=0 and DB.findStringInTable(var.passrew,itemid) )then
            if( Data.getAtlasStatus(var.map_id,var.stage_id,var.type)==false)then
                var.__pass=0
            else
                var.__pass=1
            end
            table.insert(ret,var)
        end
    end


    local sortStage = function(a, b)
        if(a.__pass==b.__pass)then
            if( a.type==b.type)then
                if( a.map_id==b.map_id)then
                    return a.stage_id<b.stage_id
                else
                    return a.map_id<b.map_id
                end
            else
                return a.type<b.type
            end
        else
            return    a.__pass>b.__pass
        end
    end

    if(table.getn(ret)>=2)then
        table.sort(ret, sortStage)
    end
    return ret
end

function DB.getEquipPriceByLevel(lv)
    for key, var in pairs(equ_price_db) do
        if(var.level== lv)then
            return var.upgrade_price
        end
    end
    return nil
end



function DB.getSkillPriceByLevel(lv,pos)
    for key, var in pairs(skill_upgrade_price_db) do
        if(var.level== lv)then
            return var["price_skill"..(pos+1)], var["item_skill"..(pos+1)],var["price_skill"..(pos+1).."_type"]
        end
    end
    return nil,nil
end


function DB.getPetSkillByLevel(petid,lv)
    for key, var in pairs(pet_skill_upgrade_db) do
        if(var.petid == petid and var.level== lv)then
            return var
        end
    end
    return nil
end


function DB.getCardQuality(cardid,quality)
    if(DB.cardquality_db==nil)then
        DB.cardquality_db={}
    end

    local saveKey=cardid*100+quality
    if(DB.cardquality_db[saveKey]==nil)then
        for key, var in pairs(cardquality_db) do
            if(var.cardid== cardid and  var.quality==quality)then
                DB.cardquality_db[saveKey]=var
                return var
            end
        end
    end

    return DB.cardquality_db[saveKey]
end



function DB.getNewLvAndExp(level,exp,addExp)
    local newExp=exp+addExp
    local maxExp=DB.getCardExpByLevel(level)

    local newLevel=level
    while newExp>=maxExp do
        newExp=newExp-maxExp
        newLevel=newLevel+1
        maxExp=DB.getCardExpByLevel(newLevel)
    end


    return newLevel,newExp


end

function DB.getVipCharge()
    local vipCharge = {};
    for key,var in pairs(vip_db) do
        table.insert(vipCharge,var.charge);
    end
    return vipCharge;
-- local params=  DB.getClientParam("SYSTEM_VIP_IAPBUY")
-- return  string.split(params,";")

end


-- function DB.getBuyEnergyNeedDia(num)
--     local params=  DB.getClientParam("VIP_BUY_HP_DIAMOND_NUM")
--     local nums= string.split(params,";")

--     local params2=  DB.getClientParam("VIP_BUY_HP_DIAMOND")
--     local dias= string.split(params2,";")

--     local min = 1
--     local max = 0
--     for key, max in pairs(nums) do
--         max=toint(max)
--         if(num >= min and num <= max)then
--             return toint(dias[key])
--         end
--         min = max + 1
--     end
--     return 0
-- end

-- function DB.getBuyEnergyRewardNum()
--     return DB.getClientParam("VIP_DIAMOND_HP")
-- end

-- function DB.getMaxSkillPointNum()
--     return DB.getClientParam("SKILLPOINT_MAX")
-- end

function DB.getCardSharedPrice()
    return  5000--DB.getClientParam(8740)
end


function DB.getMaxBuyEnergyNum(vip)
    for key, var in pairs(vip_db) do
        if(var.vip== vip)then
            return var.diamondhp_6
        end
    end
    return 0
end

function DB.getSkillPointTime()
    local times=string.split( DB.getClientParam("RECOVERY_TIME_SKILLPOINT"),";")
    if(Data.hasMemberCard(CARD_TYPE_LIFE))then
        return toint(times[2])
    else
        return toint(times[1])
    end
end


function DB.getServerRound()
    return DB.getClientParam("BATTLE_ROUND",true)
end

function DB.getAtlasRound()
    return 20
end

function DB.getEnergyCheckTime()
    return DB.getClientParam("RECOVERY_TIME_ENERGY")
end


function DB.getBuyGoldParam1()
    return DB.getClientParam("TURNGOLD_BASEGOLD")
end


function DB.getBuyGoldParam2()
    return DB.getClientParam("TURNGOLD_LEVEL_RATIO")
end

function DB.getMaxDrawFreeNum()
    return DB.getClientParam("DRAW_FREE_NUM")
end
-- 策划说写死
function DB.getDrawGoldOne()
    return 1
    -- return DB.getClientParam("DRAW_GOLD_ONE")
end

function DB.getDrawGoldTen()
    return 10
    -- return DB.getClientParam("DRAW_GOLD_TEN")
end

function DB.getRaiseNeedDia()
    return DB.getClientParam("CARD_RAISE_NEED_DIAMOND")

end
function DB.getRaiseNeedDan()
    if(DB.raiseNeedDanParam==nil)then
        DB.raiseNeedDanParam={}
        local needs=string.split(DB.getClientParam("CARD_RAISE_NEED_DAN"),";")
        for key, var in pairs(needs) do
            DB.raiseNeedDanParam[key]=toint(var)
        end
    end

    return DB.raiseNeedDanParam
end

function DB.getDrawDiamondOne()
    local scale=1
    if(Data.drawCard and Data.drawCard.dct and  Data.drawCard.dct ~=0)then
        scale=Data.drawCard.dct /100
    end
    return toint(DB.getClientParam("DRAW_DIAMOND_ONE")*scale)
end

function DB.getDrawDiamondTen()
    local scale=1
    if(Data.drawCard and Data.drawCard.dct and  Data.drawCard.dct ~=0)then
        scale=Data.drawCard.dct /100
    end
    return toint(DB.getClientParam("DRAW_DIAMOND_TEN_FEE")*scale)
end

function DB.getArenaCdCost()
    return DB.getClientParam("ARENA_CLEAR_CD_COST")
end


function DB.getActivityInvest()
    local dia= DB.getClientParam("FUND_NEED_DIAMOND")
    local lvs=string.split( DB.getClientParam("FUND_LV"),";")
    local dias=string.split( DB.getClientParam("FUND_DIAMOND"),";")

    return lvs,dias,dia
end

function DB.getActivityInvest2()
    local id1=string.split( DB.getClientParam("FUND_ITEM_ID1"),";")
    local id2=string.split( DB.getClientParam("FUND_ITEM_ID2"),";")
    local num1=string.split( DB.getClientParam("FUND_ITEM_NUM1"),";")
    local num2=string.split( DB.getClientParam("FUND_ITEM_NUM2"),";")
    
    return id1,id2,num1,num2
end


function DB.getArenaCdTime()
    return 600
        --return DB.getClientParam(8319)
end

function DB.getFriendPkLevel()
    return toint(DB.getClientParam("PK_REQUEST_LEVEL"))
end


function DB.getCreateFamilyDia()
    return 200
end

function DB.getCreateFamilyGold()
    return 100000
end

function DB.getFamilyExpContribution(type)
    for key,var in pairs(gFamilyInfo.contribution) do
        if toint(key) == toint(type) then
            return var.getExp;
        end
    end
    return 0;
end

function DB.getFamilySplv_maxnum(level)
    -- familysplv_db
    for k,v in pairs(familysplv_db) do
        if (level == v.level) then
            return v.drinknum;
        end
    end
    return 0;
end

function DB.getTeachUnlock(id)
    for key,teach in pairs(teach_db) do
        if(toint(teach.teachid) == id)then
            return teach;
        end
    end
    return nil;
end

function DB.getMaxEnergy(level)
    if(level==nil)then
        level=1
    end
    local params=  DB.getClientParam("ENERGY_MAX")
    local exps= string.split(params,";")
    local ret= toint(exps[1]) + exps[2] * math.floor(level/ exps[3])
    if(Data.hasMemberCard(CARD_TYPE_MON))then
        ret=ret+toint(exps[4]) --最大体力上限+50点
    end
    return ret
end

function DB.getCardMaxEvolve()
    return DB.getClientParam("CARD_GRADE_MAX")
end

function DB.getNeedSoulNum(grade)
    return DB.getNeedInitSoulNum(grade)-DB.getNeedInitSoulNum(grade-1)
end

function DB.getNeedSoulNumForAwake(cardid,awakeLv)
    local awakeData = DB.getCardAwake(cardid,awakeLv+1);
    if(awakeData)then
        return awakeData.soulnum;
    end
    return 0;
end

function DB.getNeedSoulForAll(grade,cardid,awakelv)

    if(grade<5)then
        return DB.getNeedSoulNum(grade);
    else
        return DB.getNeedSoulNumForAwake(cardid,awakelv);
    end

end

function DB.getNeedInitSoulNum(grade)
    if(DB.clientParam8206)then
        return toint(DB.clientParam8206[grade+1])
    end
    local params=  DB.getClientParam("CARD_EVOLVE_CARD_NUM")
    local grades= string.split(params,";")
    DB.clientParam8206=grades
    return toint(DB.clientParam8206[grade+1])
end

function DB.getPetTriggerRate(num)
    if(DB.petTriggerRate==nil)then
        local params=  DB.getClientParam("PET_SKILL_TRIGGER_PERCENT")
        DB.petTriggerRate=string.split(params,";")
    end
    return toint( DB.petTriggerRate[num])
end
function DB.getPetNeedSoulNum(petid,grade)
    local pet = DB.getPetById(petid);
    local grades = string.split(pet.gradeup,";");
    return toint(grades[grade+1]);
-- if(DB.clientParam8651)then
--     return toint(DB.clientParam8651[grade+1])
-- end
-- local params=  DB.getClientParam("PET_EVOLVE_SOUL_NUM")
-- local grades= string.split(params,";")
-- DB.clientParam8651=grades
-- return toint(DB.clientParam8651[grade+1])
end

function DB.getPetGoldFeedNum(level,petid)
    -- local params=  string.split(DB.getClientParam("PET_UPGRADE_PRICE"),";")
    -- return toint(params[1])+(level-1)*params[2]
    local price = 0;
    for key,value in pairs(pet_upgrade_db) do
        if(toint(value.petid) == toint(petid) and toint(value.level) == toint(level))then
            price = value.upgrade_price;
            break;
        end
    end
    return price;
end

function DB.getPetNormalFeedNum(level,petid)
    -- local params=  string.split(DB.getClientParam("PET_UPGRADE_POINT"),";")
    -- return toint(params[1])+(level-1)*params[2]
    local point = 0;
    for key,value in pairs(pet_upgrade_db) do
        if(toint(value.petid) == toint(petid) and toint(value.level) == toint(level))then
            point = value.upgrade_point;
            break;
        end
    end
    return point;
end

function DB.getPetFeedRewardExps()
    return string.split(DB.getClientParam("PET_UPGRADE_EXP_ARRAY") ,";")
end

function DB.getOnlineGift()
    return string.split(DB.getClientParam("ONLINE_BOXID") ,";")
end

function DB.getClientParam(id,isToint)
    if(DB.params_client_db==nil)then
        DB.params_client_db={}
        for key, var in pairs(params_client_db) do
            DB.params_client_db[var.name]=var
        end
    end
    
    local var=DB.params_client_db[id] 
    if(var)then
        if(isToint)then
            return toint(var.value)
        else
            return var.value
        end
    end
 
    if(isToint)then
        return 0;
    else
        return ""
    end
end

function DB.getClientParamToTable(name,isToint)
    local data = string.split(DB.getClientParam(name) ,";");
    if(isToint)then
        local intData = {}
        for key,var in pairs(data) do
            -- var = toint(var);
            table.insert(intData,toint(var));
        end
        return intData;
    end
    return data;
end


function DB.getSkillById(id)
    if(id==0)then
        return nil
    end
     
    if(DB.skill_db==nil)then
        DB.skill_db={} 
        for key, var in pairs(skill_db) do
            DB.skill_db[var.skillid]=var
        end 
    end 
    return DB.skill_db[id]
end


function DB.getCardGrade(cardid,grade)

    if(DB.cardgrade_db==nil)then
        DB.cardgrade_db={}
    end

    local saveKey=cardid*100+grade
    if(DB.cardgrade_db[saveKey]==nil)then
        for key, var in pairs(cardgrade_db) do
            if(var.cardid==cardid and var.grade==grade)then
                DB.cardgrade_db[saveKey]=var
                return var
            end
        end
    end

    return DB.cardgrade_db[saveKey]


end

function DB.getCardExpByLevel(lv)
    for key, var in pairs(card_exp_db) do
        if(var.level==lv)then
            return var.exp
        end
    end

    return 1000000000
end

function DB.getCardById(id)
    if(DB.card_db==nil)then
        DB.card_db={} 
        for key, var in pairs(card_db) do
            DB.card_db[var.cardid]=var
        end 
    end 
    return DB.card_db[id]
end


function DB.getWeaponById(id)
    for key, var in pairs(cardweapon_db) do
        if(var.weaponid==id)then
            return var
        end
    end
    return nil
end

function DB.getEquCompound(id,qua)
    if(DB.equcompound_db==nil)then
        DB.equcompound_db={}
    end

    local saveKey=id*100+qua
    if(DB.equcompound_db[saveKey]==nil)then
        for key, var in pairs(equcompound_db) do
            if(var.equ_id==id and var.quality==qua)then
                DB.equcompound_db[saveKey]=var
                return var
            end
        end
    end
    return DB.equcompound_db[saveKey]


end

function DB.getEquipment(id,qua)
    if(DB.equipment_db==nil)then
        DB.equipment_db={}
    end


    local saveKey=id*100+qua
    if(DB.equipment_db[saveKey]==nil)then
        for key, var in pairs(equipment_db) do
            if(var.equ_id==id and var.quality==qua)then
                DB.equipment_db[saveKey]=var
                return var
            end
        end
    end
    return DB.equipment_db[saveKey]
end


function DB.getEquipItemById(id)
    for key, var in pairs(equipitem_db) do
        if(var.itemid==id  )then
            return var
        end
    end
    return nil
end

function DB.getItemQuality(itemid)
    local itemType=DB.getItemType(itemid)
    if(itemType==ITEMTYPE_CARD_SOUL or
        itemType==ITEMTYPE_BOX )then
        return 5
    end

    if itemType==ITEMTYPE_CONSTELLATION then
        return DB.getConstellationItemQuality(itemid)
    end

    local ret =DB.getItemData(itemid)
    if(ret)then
        if(itemType==ITEMTYPE_TREASURE or itemType==ITEMTYPE_TREASURE_SHARED)then
            return ret.quality
        end
        return ret.quality
    end

    return 0
end

function DB.getConstellationItemQuality(itemId)
    local itemInfo = DB.getConstellationsItemInfo(itemId)
    if itemInfo.star == 4 then
        return 11
    elseif  itemInfo.star == 3 then
        return 8
    elseif itemInfo.star == 2 then
        return 5
    else
        return 3
    end
end

function DB.getItemName(itemid,needReplaceItem)

    if(needReplaceItem == nil)then
        needReplaceItem = true;
    end

    if(needReplaceItem)then
        itemid = DB.checkReplaceItem(itemid);
    end
    local name = "";
    local ret,type =DB.getItemData(itemid)
    if(ret)then
        name = ret.name
        if(type==ITEMTYPE_CARD_SOUL)then
            name=name.. gGetWords("labelWords.plist","soul_name");
        end
    else
        name = gGetWords("item.plist","item_id_"..itemid);
    end

    if name == nil then
        name = "";
    end

    -- print("itemid = "..itemid.."  name = "..name);

    return name;
end



function DB.getItemType(itemid)
    local ret = 0
    if(itemid==nil)then
        return 0
    end

    if(itemid == OPEN_BOX_FAMILY_EXP)then
        return ITEMTYPE_SPECIAL;
    end

    if(itemid >= 0 and itemid < 10000)then
        ret = ITEMTYPE_ITEM
    elseif(itemid >= 10000 and itemid < 20000)then
        ret = ITEMTYPE_CARD
    elseif(itemid >= 20000 and itemid < 30000)then
        ret = ITEMTYPE_BOX
    elseif(itemid >= 30000 and itemid < 40000)then
        ret = ITEMTYPE_EQU
    elseif(itemid >= 40000 and itemid < 50000)then
        ret = ITEMTYPE_SKILL
    elseif(itemid >= 50000 and itemid < 60000)then
        ret = ITEMTYPE_PET
    elseif(itemid >= 60000 and itemid < 70000)then --技能buff的itemid段也在[60000,70000)段内。和服务端统一，将技能buff抽出。
        ret = ITEMTYPE_SPIRIT
    elseif(itemid >= 70000 and itemid < 80000)then
        ret = ITEMTYPE_TREASURE
    elseif (itemid >= 80000 and itemid < 90000) then
        ret = ITEMTYPE_TALENT_SKILL
    elseif(itemid >= 90000 and itemid < 100000)then
        ret = ITEMTYPE_SPECIAL;
    elseif(itemid >= 110000 and itemid < 120000)then
        ret = ITEMTYPE_CARD_SOUL
    elseif(itemid >= 130000 and itemid < 140000)then
        ret = ITEMTYPE_EQU_SHARED
    elseif(itemid >= 150000 and itemid < 160000)then
        ret = ITEMTYPE_PET_SOUL
    elseif(itemid >= 170000 and itemid < 180000)then
        ret = ITEMTYPE_TREASURE_SHARED
    elseif(itemid >= 210000 and itemid < 220000) then
        ret = ITEMTYPE_CONSTELLATION
    end

    return ret
end

function DB.getItemAttrDes(itemid)
    local type=  DB.getItemType(itemid)
    local des=""
    local item=nil
    if(type==ITEMTYPE_ITEM)then
        item=DB.getItemById(itemid)
        if(item)then
            des=item.des
        end

    elseif(type==ITEMTYPE_BOX)then
        item=DB.getBoxById(itemid)
        if(item)then
            des=item.desc
        end
    elseif(type==ITEMTYPE_SPECIAL)then
        item=DB.getItemById( DB.parseItemid(itemid))
        if(item)then
            des=item.des
        else

            des = gGetWords("item.plist","item_desc_"..itemid)
        end
    elseif(type==ITEMTYPE_EQU)then
        item=DB.getEquipItemById(itemid)
        if(item)then
            des=item.des
        end
    elseif(type==ITEMTYPE_CARD_SOUL)then
        item=DB.getCardById(itemid-ITEM_TYPE_SHARED_PRE)
        if(item)then

            des=gGetWords("labelWords.plist" ,"lab_collect_soul",DB.getNeedInitSoulNum(item.evolve-1),item.name)
        end
    elseif(type==ITEMTYPE_PET_SOUL)then
        des=gGetWords("labelWords.plist" ,"lab_collect_pet_soul",Data.getPetSoulsNumById(itemid-ITEM_TYPE_SHARED_PRE))

    elseif(type==ITEMTYPE_EQU_SHARED)then
        item=DB.getEquipItemById(itemid-ITEM_TYPE_SHARED_PRE)
        if(item)then
            des=gGetWords("labelWords.plist" ,"lab_need_com",item.com_num,item.name)
        end
    elseif(type==ITEMTYPE_TREASURE)then
        item=DB.getTreasureById(itemid)
        if(item)then
            des=item.info
        end

    elseif(type==ITEMTYPE_TREASURE_SHARED)then
        item=DB.getTreasureById(itemid-ITEM_TYPE_SHARED_PRE)
        if(item)then
            des=gGetWords("labelWords.plist" ,"lab_need_com2",item.com_num,item.name) 
        end
    elseif(type==ITEMTYPE_CONSTELLATION)then
        item=DB.getConstellationsItemInfo(itemid)
        if(item)then
            des=gGetWords("constellationWords.plist" ,"tip_item_desc")
        end
    else
        des = gGetWords("item.plist","item_desc_"..itemid)
    end

    return des

end

function DB.parseItemid(itemid)

    if(itemid>90000)then
        itemid=9000+itemid%10000
    end
    return itemid
end

function DB.getItemData(itemid)
    itemid = DB.checkReplaceItem(itemid);
    local type=  DB.getItemType(itemid)
    local ret=nil
    if(itemid==ID_SPIRIT_FRAGMENT)then -- 命魂碎片特殊处理
        local id = math.modf(itemid/10)
        ret=DB.getItemById(id)
    elseif(type==ITEMTYPE_ITEM)then
        ret=DB.getItemById(itemid)
    elseif(type==ITEMTYPE_SPECIAL)then
        ret=DB.getItemById( DB.parseItemid(itemid))
    elseif(type==ITEMTYPE_CARD)then
        ret=DB.getCardById(itemid)
    elseif(type==ITEMTYPE_BOX)then
        ret=DB.getBoxById(itemid)
    elseif(type==ITEMTYPE_EQU)then
        ret=DB.getEquipItemById(itemid)
    elseif(type==ITEMTYPE_CARD_SOUL)then
        ret=DB.getCardById(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_PET)then
        ret=DB.getPetById(itemid)
    elseif(type==ITEMTYPE_PET_SOUL)then
        ret=DB.getPetById(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_EQU_SHARED)then
        ret=DB.getEquipItemById(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_TREASURE)then
        ret=DB.getTreasureById(itemid)
    elseif(type==ITEMTYPE_TREASURE_SHARED)then
        ret=DB.getTreasureById(itemid-ITEM_TYPE_SHARED_PRE)
    elseif(type==ITEMTYPE_CONSTELLATION) then
        ret=DB.getConstellationsItemInfo(itemid)
    end

    return ret,type

end


function DB.getPetStagesRange(idx,startMapid,endMapid)
    local ret={}
    for key, stage in pairs(pet_stage_db) do
        if(stage.stage_id==idx and (stage.map_id>startMapid and stage.map_id<=endMapid))then
            table.insert(ret,stage)
        end
    end
    return ret

end



function DB.getPetStages(idx)
    local ret={}
    for key, stage in pairs(pet_stage_db) do
        if(stage.stage_id==idx)then
            table.insert(ret,stage)
        end
    end
    return ret

end



function DB.getPetLastStages()
    local ret={}
    for key, stage in pairs(pet_stage_db) do
        if(stage.islast==1)then
            table.insert(ret,stage)
        end
    end
    return ret

end
function DB.getPetStageMaxMapid()
    local ret=0
    for key, stage in pairs(pet_stage_db) do
        if(stage.map_id>ret)then
            ret=stage.map_id
        end
    end
    return ret

end

function DB.getVipValue(vip,type)
    local key=""
    -- print_lua_table(vip);
    -- print("type = "..type);
    for key, var in pairs(vip) do
        local values = string.split(key,"_");
        if table.getn(values) > 1 and  toint(values[2]) == toint(type) then
            -- print("find var = "..var);
            return toint(var);
        end
        -- if(string.find(key,"_"..type))then
        --     return var
        -- end
    end
    return 0
end


function DB.getPetStageDetail(mapid,stageid)
    for key, stage in pairs(pet_stage_db) do
        if(stage.stage_id==stageid and stage.map_id==mapid)then
            return stage
        end
    end
    return nil

end

function DB.getPetStage(mapid)
    for key, stage in pairs(pet_stage_db) do
        if(stage.islast==1 and stage.map_id==mapid)then
            return stage
        end
    end
    return nil

end

function DB.getItemById(id)
    for key, var in pairs(item_db) do
        if(var.id==id  )then
            return var
        end
    end
    return nil
end
function DB.getTreasureUpgrade(level,type)
    for key, var in pairs(treasure_upgrade_db) do
        if(var.level==level and var.type==type  )then
            return var
        end
    end
    return nil
end


function DB.getTreasureQuench(level,type)
    for key, var in pairs(treasure_quench_db) do
        if(var.level==level and var.type==type  )then
            return var
        end
    end
    return nil
end

function DB.getTreasureStar(treasureid,star)
    for key, var in pairs(treasurestar_db) do
        if(var.treasureid==treasureid and var.star==star)then
            return var
        end
    end
    return nil
end

function DB.canTreasureStar(treasureid)
    
    if DB.treasurestar == nil then
        DB.treasurestar={}
        for key, var in pairs(treasurestar_db) do
            DB.treasurestar[var.treasureid]=true
        end
    end
    
    return DB.treasurestar[treasureid]
end

function DB.getMaxTreasureStar(treasureid)
    if DB.maxTreasurestar == nil then
        DB.maxTreasurestar={}
    end
    if DB.maxTreasurestar[treasureid] == nil then
        local star = 0
        for key, var in pairs(treasurestar_db) do
            if(var.treasureid==treasureid)then
                if var.star>star then
                    star=var.star
                end
            end
        end
        DB.maxTreasurestar[treasureid]=star
    end
    
    return DB.maxTreasurestar[treasureid]
end

function DB.getMaxTreasureStarBuffLv(buffid)
    local level = 0
    for key, var in pairs(treasurestarbuff_db) do
        if(var.buffid==buffid)then
           if var.level>level then
                level=var.level
            end
        end
    end
    return level
end


function DB.getTreasureStarBuff(buffid,level)
    for key, var in pairs(treasurestarbuff_db) do
        if(var.buffid==buffid and var.level==level)then
            return var
        end
    end
    return nil
end

function DB.getTreasureById(id)
    for key, var in pairs(treasure_db) do
        if(var.id==id  )then
            return var
        end
    end
    return nil
end

function DB.getTreasureByQuaAndType(qua,type)
    local tmp = {}
    for key, var in pairs(treasure_db) do
        if(var.type==type and var.quality==qua )then
            table.insert(tmp,var)
        end
    end
    return tmp
end


function DB.getTreasureBySuitId(id)
    local ret={}
    for key, var in pairs(treasure_db) do
        if(var.suitid==id  )then
            table.insert(ret,var)
        end
    end
    return ret
end

function DB.getTreasureSuitById(id)
    local ret={}
    for key, var in pairs(treasure_suit_db) do
        if(var.suitid==id  )then
            table.insert(ret,var)
        end
    end
    return ret
end


function DB.getTreasureSuitByIdAndNum(id,num)
    for key, var in pairs(treasure_suit_db) do
        if(var.suitid==id  and var.num==num  )then
            return var
        end
    end
    return nil
end



function DB.getGiftCommonById(id)
    for key, var in pairs(gift_common_db) do
        if(var.boxid==id  )then
            return var
        end
    end
    return nil
end

function DB.getAchieveType(iAchId)
    for key, var in pairs(achievetype_db) do
        if(var.achieveid==iAchId)then
            return var
        end
    end
    return nil;
end

function DB.getAchieve(iAchId,iLv)
    for key, var in pairs(achieve_db) do
        if(var.achieveid==iAchId and var.level == iLv)then
            return var
        end
    end
    return nil;
end
function DB.getSignDataIndex(curDay)
    local days = #sign_db;
    -- print("days = "..days);
    return math.floor((curDay-1)%days/30);
end
function DB.getSignData(curDay)
    local data = {};
    local index = DB.getSignDataIndex(curDay);
    for key,var in pairs(sign_db) do
        if(toint(var.id)>index*30 and toint(var.id) <= (index+1)*30)then
            table.insert(data,var);
        end
    end

    -- if(curDay <= 30)then
    --     for key,var in pairs(sign_db) do
    --         if(toint(var.id) <= 30)then
    --             table.insert(data,var);
    --         end
    --     end
    -- else
    --     for key,var in pairs(sign_db) do
    --         if(toint(var.id) > 30 and toint(var.id) <= 60)then
    --             table.insert(data,var);
    --         end
    --     end
    -- end

    return data;
end
function DB.getSignRewardData(curDay)
    local index = DB.getSignDataIndex(curDay);
    -- print("###### index = "..index);
    return signreward_db[index+1];
    -- if(curDay <= 30)then
    --     return signreward_db[1];
    -- else
    --     return signreward_db[2];
    -- end
end

function DB.getSign(year,month)
    local data = {};
    -- print("year = "..year .. " month = "..month);
    for key, var in pairs(sign_db) do
        if var.year == nil then
            local words= string.split( var.time,"-");
            var.year = toint(words[1]);
            var.month = toint(words[2]);
            var.day = toint(words[3]);
        -- print("var.year = "..var.year .. " var.month = "..var.month);
        end
        if(var.year==year and var.month == month)then
            table.insert(data,var);
        end
    end

    return data;
end
function DB.getSignVip(year,month)
    local data = {};
    -- print("year = "..year .. " month = "..month);
    for key, var in pairs(sign_vip_db) do
        if var.year == nil then
            local words= string.split( var.time,"-");
            var.year = toint(words[1]);
            var.month = toint(words[2]);
            var.day = toint(words[3]);
        -- print("var.year = "..var.year .. " var.month = "..var.month);
        end
        if(var.year==year and var.month == month)then
            table.insert(data,var);
        end
    end

    return data;
end
function DB.getSignReward(year,month)
    local data = {};
    -- print("year = "..year .. " month = "..month);
    for key, var in pairs(signreward_db) do
        if(var.signyear==year and var.signmonth == month)then
            -- table.insert(data,var);
            data = var;
            break;
        end
    end

    return data;
end

function DB.getIconData(icon)
    local data = nil;
    for key, var in pairs(icon_db) do
        if(var.iconid==icon)then
            data = {};
            data = var;
            break;
        end
    end

    return data;
end

function DB.getActStageByType(actType)
    for key, info in pairs(actstage_db) do
        if info.type == actType then
            return info
        end
    end
    return nil
end



function DB.getTrainRoomMaxNum(roomid)
    for key,var in pairs(drinkroom_db) do
        if toint(var.roomid) == roomid then
            return var.desknum;
        end
    end
    return 0;
end

function DB.getTrainRoom(roomid)
    for key,var in pairs(drinkroom_db) do
        if toint(var.roomid) == roomid then
            return var;
        end
    end
    return nil;
end

function DB.getSoulNeedLight(itemid)
    -- local quality = 5;
    for key,card in pairs(card_db) do
        if(card.show == true and toint("1"..card.cardid) == toint(itemid))then
            return toint(card.supercard)== 1;
        end
    end
    return false;

    -- for key,var in pairs(soulboxshardinfo_db) do
    --     if(toint(itemid) == toint("1"..var.cardid)) then
    --         if(var.iflight == 1)then
    --             -- quality = 8;
    --             return true;
    --         end
    --     end
    -- end
    -- return false;
end

function DB.getPetShopItems()
    local ret = {};
    for key,var in pairs(pet_shop_db) do
        local item = {};
        item.itemid = var.item_id;
        item.type = SHOP_TYPE_PET;
        item.num = var.item_num;
        item.price = var.price;
        item.costType = var.price_type;
        item.pos = var.id;
        item.pettower = var.param;
        item.limitNum = var.limit;
        item.buyNum = 0;
        table.insert(ret,item);
    end
    return ret;
end

function DB.getSpiritAttr(type, level, attr)
    if(DB.spiritattr_db==nil)then
        DB.spiritattr_db={}
    end

    local saveKey=type*10000+level*100+attr 

    if( DB.spiritattr_db[saveKey]==nil)then
        for key, spirit in pairs(spiritattr_db) do
            if toint(spirit.type)==type and toint(spirit.level)==level and toint(spirit.attr)==attr then
                DB.spiritattr_db[saveKey]=spirit
                return spirit
            end
        end
    end
    return  DB.spiritattr_db[saveKey]
end

function DB.getSpiritAttrTable(type, level)
    DB.spiritattr_db_table = DB.spiritattr_db_tabe or {}

    local saveKey = type*10000+level*100

    if (DB.spiritattr_db_table[saveKey] == nil) then
        DB.spiritattr_db_table[saveKey] = {}
        for i = 1, #spiritattr_db do
            local spirit = spiritattr_db[i]
            if toint(spirit.type)==type and toint(spirit.level)==level then
                table.insert(DB.spiritattr_db_table[saveKey], spirit)
            end
        end
    end

    return DB.spiritattr_db_table[saveKey]
end

function DB.getSpiritExp(type, level)
    for i = 1, #spiritexp_db do
        local spiritExp = spiritexp_db[i]
        if toint(spiritExp.type)==type and toint(spiritExp.level)==level then
            return spiritExp
        end
    end
    return nil
end

function DB.getSpiritLevel(type, exp)
    local level = 1
    local sExp = DB.getSpiritExp(type,exp)
    if nil ~= sExP then
        if exp >= sExp.exp then
            return DB.getSpiritMaxLev()
        end
    end

    for i = 1, #spiritexp_db - 1 do
        local spiritExp = spiritexp_db[i]
        local spiritExp_next = spiritexp_db[i+1]
        if (toint(spiritExp.type) == type) then
            if exp >= toint(spiritExp.exp) and exp < toint(spiritExp_next.exp) then
                level = spiritExp.level + 1
                break
            end
        end
    end

    return level
end

function DB.getSpiritMaxExp(type, maxLev)
    for i = 1, #spiritexp_db do
        local spiritExp = spiritexp_db[i]
        if toint(spiritExp.type)==type and toint(spiritExp.level)==maxLev then
            return spiritExp.exp
        end
    end
    return 0
end

function DB.getNeedGoldForSpirit(type)
    local needGold = DB.getClientParamToTable("SPIRIT_NEED_GOLD")
    return toint(needGold[type])
end

function DB.getMaxSpiritCount()
    return toint(DB.getClientParam("SPIRIT_COUNT"))
end

function DB.getSpiritBagMax()
    return toint(DB.getClientParam("SPIRIT_BAG_MAX"))
end



function DB.getRenameDia()
    return toint(DB.getClientParam("SYSTEM_CHANGENAME_DIAMOND"))
end


function DB.getSpiritCallDia()
    return toint(DB.getClientParam("SPIRIT_CALL_DIAMOND"))
end

function DB.getSpiritStartLev()
    return DB.getClientParamToTable("SPIRIT_START_LEVEL",true)
end

function DB.getSpiritBaseExp(iType)
    return DB.getClientParamToTable("SPIRIT_BASE_EXP")[iType]
end

function DB.getSpiritMaxLev()
    return toint(DB.getClientParam("SPIRIT_MAX_LEVEL"))
end

function DB.getSpiritExchangeCount()
    return toint(DB.getClientParam("SPIRIT_EXCHANGE_COUNT"))
end

function DB.getSpiritBreadUpCount()
    return toint(DB.getClientParam("SPIRIT_EXCHANGE_COUNT")) / 2
end

function DB.getQuickFindFlag(vip)
    for key, var in pairs(vip_db) do
        if(var.vip == vip)then
            return var.quickfind_17
        end
    end
    return 0
end


function DB.getCrusadeBuyNum(vip)
    for key, var in pairs(vip_db) do
        if(var.vip == vip)then
            return var.buycrusade_18
        end
    end
    return 0
end

function DB.getCrusadeBuyGold(num)

    local price=  DB.getClientParam("CRUSADE_TOKEN_BUY_PRICE")
    price =string.split(price,";")
    if(num>table.getn(price))then
        num=table.getn(price)
    end
    return toint(price[num])
end



function DB.getMinVipLevForQuickFind()
    for key, var in pairs(vip_db) do
        if(var.quickfind_17 == 1)then
            return key - 1
        end
    end
    return 0
end

function DB.getCardMaxLevel()
    return #card_exp_db
end

function DB.getActLevelUpBoxid(lv)
    for key, var in pairs(gift_common_db) do
        if var.status== 5 and var.limitpara == lv then
            return var.boxid
        end
    end
    return 0
end
--矿区点数多少秒钟恢复一点
function DB.getMiningPointCheckTime()
    return DB.getClientParam("MINING_RECOVERY_TIME_POINT")
end

function DB.getAtlasBossPointCheckTime()
    return DB.getClientParam("RECOVERY_TIME_EVIL")
end



--获取最大数量矿区点数
function DB.getMaxMiningPoint(vip)
    for _, var in pairs(vip_db) do
        if(var.vip == vip)then
            return var.maxminingpoint_19
        end
    end
    return 0
end

--获取地形对应的所需的雷管数
function DB.getDetonatorCostByMine(id)
    for _, value in pairs(miningelement_db) do
        if value.id == id then
            return value.bnum
        end
    end
    return 0
end

--获取地形对应的挖掘时间
function DB.getDigingTimeForMine(id)
    for _, value in pairs(miningelement_db) do
        if value.id == id then
            return value.dtime
        end
    end
    return 0
end

--获取地形对应的矿石名字
function DB.getMineNameByMineType(id)
    for _, value in pairs(miningelement_db) do
        if value.id == id then
            local idx = string.find(value.name,"%(")
            if idx ~= nil then
                return string.sub(value.name,1, idx - 1)
            else
                return value.name
            end
        end
    end
    return ""
end

--获取地形对应的矿石id,以及获取数量
function DB.getMineAndNumsByMineType(id)
    for _, value in pairs(miningelement_db) do
        if value.id == id then
            return value.gid,value.gnum
        end
    end
    return nil,nil
end

--获取vip等级对应的挖矿工程数
function DB.getMaxMiningProjNums(vip)
    for key, var in pairs(vip_db) do
        if(var.vip == vip)then
            return var.maxminingpoint_20
        end
    end
    return 0
end

--获取对应工程数的最小vip等级
function DB.getMinVipLvByMineProjNums(num)
    for i = 1, #vip_db do
        if vip_db[i].maxminingproject_20 == num then
            return vip_db[i].vip
        end
    end

    return 0
end

--获取对应深度的工程信息
function DB.getMiningProjInfo(id)
    for _, value in pairs(miningproject_db) do
        if value.id == id then
            return value
        end
    end

    return nil
end

function DB.getMineStageById(lev)
    -- local realLev = lev
    -- local maxLev = DB.getMaxMineStageID()
    -- if realLev > maxLev then
    --     realLev = maxLev
    -- end

    for _, var in pairs(mine_stage_db) do
        if var.stage_id==lev then
            return var
        end
    end

    return nil
end

function DB.getMaxMineStageID()
    local length = #mine_stage_db
    return mine_stage_db[length].stage_id
end
--根据等级获取段位类型
function DB.getServerBattleSecTypeByLv(lv)
    if lv == 0 then
        return SERVER_BATTLE_DUAN1
    end

    if lv > #worlddan_db then
        lv = #worlddan_db
    end

    return worlddan_db[lv].type
end
--获取段位对应的星星数
function DB.getServerBattleTotalStarsByLv(type)
    local stars = 0
    for i = 1,#worlddan_db do
        local value = worlddan_db[i]
        if value.type == type then
            stars = stars + 1
        elseif value.type > type then
            break
        end
    end
    return stars
end

function DB.getServerBattleRangeSecLvByType(type)
    local minLv = 9999
    local maxLv = 0
    for i = 1,#worlddan_db do
        local value = worlddan_db[i]
        if value.type == type then
            if minLv > value.level then
                minLv = value.level
            end

            if maxLv < value.level then
                maxLv = value.level
            end
        elseif value.type > type then
            break
        end
    end
    return minLv,maxLv
end

function DB.getServerBattleSecNameByLv(lv)
    if lv == 0 then
        return ""
    end

    if lv > #worlddan_db then
        lv = #worlddan_db
    end

    return worlddan_db[lv].name
end

function DB.getRewIntroOfServerBattle()
    local rewardTable = {}
    for key,value in ipairs(worlddanreward_db) do
        local item = {}
        item.secLv = key
        item.dayrews = cjson.decode(value.dayrew)
        item.weekrews = cjson.decode(value.weekrew)
        table.insert(rewardTable,item)
    end
    return rewardTable
end

function DB.getRewIntroOfServerBattleByLv(lv)
    local rewardItems = {}
    for key,value in ipairs(worlddanreward_db) do
        if key == lv then
            rewardItems.secLv = key
            rewardItems.dayrews = cjson.decode(value.dayrew)
            rewardItems.weekrews = cjson.decode(value.weekrew)
            return rewardItems
        end
    end
    return nil
end

function DB.getWorldRankIndex(rank)
    local rankIndex = 0
    if (rank>=4 and rank<=10) then
        rankIndex = 4
    elseif (rank>=11 and rank<=32) then
        rankIndex = 11
    else
        rankIndex = rank
    end
    return rankIndex
end

function DB.getWorldRankReByRank(rank)
    local rewardItems = {}
    for key,value in ipairs(worldrankreward_db) do
        local vRank = toint(value.rank)
        if (vRank == rank) then
            rewardItems.secLv = 1000+vRank
            rewardItems.dayrews = cjson.decode(value.dayrew)
            rewardItems.weekrews = cjson.decode(value.weekrew)
            return rewardItems
        end
    end
    return nil
end

function DB.getServerBattleEndTime()
    return DB.getClientParam("WORLD_WAR_DAN_END_DATE"), DB.getClientParam("WORLD_WAR_DAN_END_TIME")
end

function DB.getTowerData(floor)
    for key,var in pairs(townconfig_db) do
        if(toint(var.id) == floor)then
            return var;
        end
    end
    return nil;
end

function DB.getTowerMonster(id)
    for key,var in pairs(townmonster_db) do
        if(var.id == id)then
            return var;
        end
    end
    return nil;
end

function DB.getHonorIDbySecLv(lv)
    if lv == 0 then
        return 0
    end

    if lv > #worlddan_db then
        lv = #worlddan_db
    end

    return worlddan_db[lv].honor
end

function DB.getHonorTitleByID(id)
    return honor_db[id].name
end

function DB.getHonorBuffDescByID(id)
    local honorTabel = honor_db[id]
    local buffid0 = honorTabel.buffid0
    local buffid1 = honorTabel.buffid1
    local buffDesc1 = ""
    local buffDesc2 = ""
    if buffid0 ~= 0 then
        local buff1 = DB.getBuffById(buffid0)
        if buff1 ~= nil then
            buffDesc1 = buff1.des
        end
    end

    if buffid1 ~= 0 then
        local buff2 = DB.getBuffById(buffid1)
        if buff2 ~= nil then
            buffDesc2 = buff2.des
        end
    end

    return buffDesc1,buffDesc2
end

function DB.getMaxFindNumsOfSeverBattle()
    return DB.getClientParam("WORLD_WAR_DAY_FIND_NUM")
end
--(0-6分别是周日到周六）
function DB.getServerBattleMatchDate()
    return DB.getClientParam("WORLD_WAR_MATCH_DATE")
end
--（0-23）
function DB.getServerBattleMatchTime(timeType)
    return DB.getClientParam("WORLD_WAR_MATCH_TIME_"..timeType)
end

function DB.getFamilyWarMatchDate()
    return toint(DB.getClientParam("FAMILY_MATCH_DATE"))
end

function DB.getFamilyWarMatchTime(timeType)
    return DB.getClientParam("FAMILY_MATCH_HOUR_"..timeType)
end

function DB.getFamilyGoldMineByLv(lv)
    for key,var in pairs(familyorelv_db) do
        if(toint(var.level) == toint(lv))then
            return var;
        end
    end
  return nil;
end

function DB.getFamilyOreTile(times)
    for key,var in pairs(familyoretier_db) do
        if(toint(var.tier) == toint(times))then
            return var;
        end
    end
    return nil;
end

function DB.getFamilyGoldMineShovelFreeTimes(lv,type)
  if type == 1 then
    return DB.getFamilyGoldMineByLv(lv).num1;
  elseif type == 2 then
    return DB.getFamilyGoldMineByLv(lv).num2;
  elseif type == 3 then
    return DB.getFamilyGoldMineByLv(lv).num3;
  end
  return 0;
end

function DB.getFamilyGoldMineMaxCry(lv)
  return DB.getFamilyGoldMineByLv(lv).crystal;
end

function DB.getFamilyGoldMineShovelType(times)
  return DB.getFamilyOreTile(times).type;
end

function DB.getFamilyGoldMineShovelDia(times)
  return DB.getFamilyOreTile(times).diamond;
end

function DB.getFamilyGoldMineMaxNextRate(times)
  return DB.getFamilyOreTile(times).value4;
end

function DB.getServerBattleMatchReward(battleType,rank)
    local rewardInfo = {}
    for _,value in ipairs(worldmatchreward_db) do
        if value.type == battleType and value.rank == rank then
            rewardInfo.battleType = battleType
            rewardInfo.rank = rank
            rewardInfo.items = cjson.decode(value.reward)
        end
    end
    return rewardInfo
end

function DB.getServerBattleMatchRewardByHonor(honor)
    local rewardInfo = {}
    for _,value in ipairs(worldmatchreward_db) do
        if value.honor == honor then
            rewardInfo.rank = value.rank
            rewardInfo.honor = honor
            rewardInfo.items = cjson.decode(value.reward)
        end
    end
    return rewardInfo
end

function DB.getServerBattleChangeFree()
    return toint(DB.getClientParam("WORLD_WAR_CHANGE_FREE"))
end


function DB.getServerBattleVipBuyNums()
    return toint(DB.getClientParam("WORLD_WAR_VIP_BUY_NUM"))
end

function DB.getServerBattleShopItem(itemid)
    for _,var in pairs(worldshop_db)do
        if var.itemid == itemid then
            return var
        end
    end
    return nil
end

function DB.getMaxSpiritExp()
    return toint(DB.getClientParam("SPIRIT_EXP_MAX"))
end

function DB.getSoulLifeFraToExpParam()
    local fraToExp = DB.getClientParamToTable("SPIRIT_CHANGE_EXP")
    return toint(fraToExp[1]),toint(fraToExp[2])
end

function DB.getFreeLuckWheelNums()
    local luckWheelPrices = DB.getClientParamToTable("MINING_EVENT_3_PRICE",true)
    local freeNums = 0
    for i = 1, #luckWheelPrices do
        if luckWheelPrices[i] == 0 then
            freeNums = freeNums + 1
        end
    end
    return freeNums
end

function DB.getMaxLuckWheelNums()
    return toint(DB.getClientParam("MINING_EVENT_3_NUM"))
end

function DB.getLuckWheelCost(idx)
    local luckWheelPrices = DB.getClientParamToTable("MINING_EVENT_3_PRICE",true)
    return luckWheelPrices[idx]
end

function DB.getMineBlackSPrice(itemid)
    for _,var in pairs(mineeventshop_db) do
        if itemid == var.itemid then
            return var.sprice
        end
    end
    return -1
end

function DB.getMineBlackCPrice(itemid)
    for _,var in pairs(mineeventshop_db) do
        if itemid == var.itemid then
            return var.cprice
        end
    end
    return -1
end

function DB.getMaxMineEventTradeNum(itemid)
    for key,value in pairs(mineeventshop_db) do
        if value.itemid == itemid then
            return toint(value.num)
        end
    end
    return 0
end

function DB.getMiningEvent4FreeNums()
    return toint(DB.getClientParam("MINING_EVENT_4_NUM"))
end

function DB.getChapterNumByType(type)
    local ret = 0
    for _, var in pairs(chapter_db) do
        if(var.type==type)then
            ret = ret + 1
        end
    end
    return ret
end

function DB.getMineAtlasChapterNum()
    return #minechapterinfo_db
end

function DB.getMineAtlasMasteryLim(mapId)
    for _,chapterInfo in ipairs(minechapterinfo_db) do
        if chapterInfo.id == mapId then
            return chapterInfo.mastery
        end
    end

    return -1
end

function DB.getMineAtlasChapterInfo(mapId)
    for _,chapterInfo in ipairs(minechapterinfo_db) do
        if chapterInfo.id == mapId then
            return chapterInfo
        end
    end

    return nil 
end

function DB.getMineAtlasBoxRewards(mapId, step)
    if mapId > #minechapterinfo_db then
        return nil
    end

    local ret={}
    local chapterInfo = minechapterinfo_db[mapId]
    if step == 1 then
        for key,value in pairs(chapterInfo) do
            if string.find(key, "sboxitemid") ~= nil then
                local pos = toint(string.sub(key, string.len("sboxitemid") + 1))
                ret[pos] = ret[pos] or {}
                ret[pos].id = value
            elseif string.find(key,"sboxitemnum") ~= nil then
                local pos = toint(string.sub(key, string.len("sboxitemnum") + 1))
                ret[pos] = ret[pos] or {}
                ret[pos].num = value
            end 
        end
        return ret
    end

    return ret
end

function DB.getMineAtlasFullRewards(mapId)
    if mapId > #minechapterinfo_db then
        return nil
    end

    local ret={}
    local chapterInfo = minechapterinfo_db[mapId]
    for key,value in pairs(chapterInfo) do
        if string.find(key, "fullitemid") ~= nil then
            local pos = toint(string.sub(key, string.len("fullitemid") + 1))
            ret[pos] = ret[pos] or {}
            ret[pos].id = value
        elseif string.find(key,"fullitemnum") ~= nil then
            local pos = toint(string.sub(key, string.len("fullitemnum") + 1))
            ret[pos] = ret[pos] or {}
            ret[pos].num = value
        end 
    end
    return ret
end

function DB.getMineAtlasProRewards(mapId)
    if mapId > #minechapterinfo_db then
        return nil
    end

    local ret={}
    local chapterInfo = minechapterinfo_db[mapId]
    for key,value in pairs(chapterInfo) do
        if string.find(key, "proitemid") ~= nil then
            local pos = toint(string.sub(key, string.len("proitemid") + 1))
            ret[pos] = ret[pos] or {}
            ret[pos].id = value
        end 
    end
    return ret
end

function DB.getMineStageDrawDesc(idx)
    if idx <= 0 or idx > #minestagedraw_db then
        return ""
    end

    local mineStageDraw = minestagedraw_db[idx]
    local descInfo = ""
    if mineStageDraw.data2 == 0 then
        descInfo = gReplaceParam(mineStageDraw.info, mineStageDraw.data1)
    else
        descInfo = gReplaceParam(mineStageDraw.info, mineStageDraw.data1,mineStageDraw.data2)
    end
    return descInfo
end

function DB.getMineDrawLotsBuffIds(idx)
    if idx <= 0 or idx > #minestagedraw_db then
        return nil
    end

    local mineStageDraw = minestagedraw_db[idx]
    local buffIds = {}
    table.insert(buffIds, mineStageDraw.attr1)
    if mineStageDraw.attr2 ~= 0 then
        table.insert(buffIds, mineStageDraw.attr2)
    end

    return buffIds
end

function DB.getPriceToBuyMiner(idx)
    local priceTable = DB.getClientParamToTable("MINING_BUY_MINER_NEED_DIAMOND",true);
    return priceTable[idx]
end

function DB.getMasteryLimToBuyMiner(idx)
    local masteryTable = DB.getClientParamToTable("MINING_BUY_MINER_NEED_MASTERY",true);
    return masteryTable[idx]
end

function DB.getMaxMiners()
    local priceTable = DB.getClientParamToTable("MINING_BUY_MINER_NEED_DIAMOND",true);
    return #priceTable + 1
end

function DB.getMineAtlasEndBoxReward(mapId, starNums)
    if mapId <= 0 or mapId > #minechapterinfo_db then
        return nil
    end

    local ret={}
    local chapterInfo = minechapterinfo_db[mapId]
    local idKey = ""
    local idValue = 0
    local numKey = ""
    local numValue = 0
    for i = 1,4 do
        idKey = string.format("itemid%d_%d",i,starNums)
        numKey = string.format("itemnum%d_%d",i,starNums)
        idValue = chapterInfo[idKey]
        numValue =  chapterInfo[numKey]
        if idValue ~= nil and numValue ~= nil then
            table.insert(ret, {id=toint(idValue), num=toint(numValue)})
        end
    end
    return ret
end

function DB.getMiningAtlasLvLim()
    return toint(DB.getClientParam("MINING_CHAPTER_LV"))
end

function DB.getNewProjCritParam(miner)
    local critParams = DB.getClientParamToTable("MINING_CRIT_PARAM",true)
    if miner <= 0 or miner > #critParams then
        return -1
    end

    return critParams[miner]
end

function DB.getBaoLiSpiritCost()
    return toint(DB.getClientParam("SPIRIT_BAOLI_PRICE"))
end

function DB.getServerBattleBeginTime()
    return DB.getClientParam("WORLD_WAR_DAN_BEGIN_DATE"), DB.getClientParam("WORLD_WAR_DAN_BEGIN_TIME")
end

function DB.getSpiritExchangeItemCount()
    return DB.getClientParam("SPIRIT_EXCHANGE_ITEM_COUNT")
end

function DB.getSpiritBuyItemPrice()
    return DB.getClientParam("SPIRIT_BUY_ITEM_PRICE")
end

function DB.getSpiritDayBuyNum()
    return DB.getClientParam("SPIRIT_DAY_BUY_NUM")
end

function DB.getSpiritStartVip()
    return DB.getClientParamToTable("SPIRIT_START_VIP",true)
end

function DB.getSpiritStartPrice()
    return DB.getClientParamToTable("SPIRIT_START_PRICE",true)
end

function  DB.getSpiritAddLevs()
    return DB.getClientParamToTable("SPIRIT_ADD_LEVEL",true)
end

function DB.getSpiritAddLevByPos(pos)
    local params = DB.getClientParamToTable("SPIRIT_ADD_LEVEL",true)
    return params[pos]
end

function DB.getMaxFamilyStageMaxMapId()
    local count = #familystageconf_db
    return familystageconf_db[count].map_id
end

function DB.getMaxFamilyStageCount()
    return #familystageconf_db
end

function DB.getFamilyStageInfoByMapId(mapId)
    local stageInfo = {}
    for _,var in ipairs(familystageconf_db) do
        if var.map_id == mapId then
            table.insert(stageInfo, var)
        end
    end

    return stageInfo
end

function DB.getMaxFamilyStageIdByMapId(mapId)
    local maxStageId = 1
    for _,var in ipairs(familystageconf_db) do
        if var.map_id == mapId and var.stage_id > maxStageId then
            maxStageId = var.stage_id
        end

        if var.map_id > mapId then
            break
        end
    end

    return maxStageId
end

function DB.getFamilyStageRewardsById(id)
    local rewards = {}
    for _,var in ipairs(familystageconf_db) do
        if var.id == id then
            rewards = cjson.decode(var.showreward)
        end
    end

    return rewards
end

function DB.getFamilyFightBuff()
    return DB.getClientParamToTable("FAMILY_STAGE_FIGHT_BUFF",true)
end

function DB.getFamilyStageFightNum()
    return DB.getClientParam("FAMILY_STAGE_FIGHT_NUM", true)
end

function DB.getFamilyStageRewardsByFlag(win,power)
    local rewards = {}
    for _,var in pairs(familystagereward_db) do
        if var.power == power and var.win == win then
            table.insert(rewards, var)
        end
    end
    return rewards 
end

function DB.getFamilyStageCountryBuff(country)
    local stagetCountryBuff = DB.getClientParamToTable("FAMILY_STAGE_COUNTRY_BUFF",true)
    return stagetCountryBuff[country]
end

function DB.getFamilyStageBeginTime1()
    return DB.getClientParam("FAMILY_STAGE_BEGIN_DAY_1"), DB.getClientParam("FAMILY_STAGE_BEGIN_HOUR_1")
end

function DB.getFamilyStageEndTime1()
    return DB.getClientParam("FAMILY_STAGE_END_DAY_1"), DB.getClientParam("FAMILY_STAGE_END_HOUR_1")
end

function DB.getFamilyStageBeginTime2()
    return DB.getClientParam("FAMILY_STAGE_BEGIN_DAY_2"), DB.getClientParam("FAMILY_STAGE_BEGIN_HOUR_2")
end

function DB.getFamilyStageEndTime2()
    return DB.getClientParam("FAMILY_STAGE_END_DAY_2"), DB.getClientParam("FAMILY_STAGE_END_HOUR_2")
end

function DB.getFamilyStageBuffLvInfo(lv)
    if lv < 1 or lv > #familystagebufflv_db then
        return nil
    end

    return familystagebufflv_db[lv]
end

function DB.getFamilyStageBuffupPrice(num)
    if num < 1 or num > #familystagebuffup_db then
        return -1
    end

    return familystagebuffup_db[num].price
end

function DB.getFamilyStagePowerMemNum()
    return DB.getClientParam("FAMILY_STAGE_POWER_MEMBER_NUM")
end

function DB.getFamilyStagePowerMapRate(mapId)
    local mapRateTable = DB.getClientParamToTable("FAMILY_STAGE_POWER_MAP_RATE", true)
    return mapRateTable[mapId]
end

function DB.getFamilyStageRewardPowers()
    return DB.getClientParamToTable("FAMILY_STAGE_REWARD_POWER", true)
end

function DB.getFamilyStageBuffMaxLv()
    return DB.getClientParam("FAMILY_STAGE_BUFF_LV_MAX")
end

function DB.getMiningProjAddMastery()    
    return DB.getClientParam("MINING_PROGECT_ADD_MASTERY_PRO")
end

function DB.getTreasureHuntSize()
    return #crosstreasurehall_db
end

function DB.getTreasureHuntHallInfo(idx)
    return crosstreasurehall_db[idx]
end

function DB.getMiningImFinishParam()
    return DB.getClientParam("MINING_IM_FINISH_PARAM")
end

function DB.getTreasureHuntHallRoomNum(idx)
    return crosstreasurehall_db[idx].roomnum
end
-- 一键寻仙开启等级
function DB.getSpiritOneKeyLev()
    return DB.getClientParam("SPIRIT_ONEKEY_LEVEL")
end

--跨服战力下降最低百分比
function DB.getTreasureHuntBattleMinPer()
    return DB.getClientParam("CT_BATTLE_MIN_PERCENT")
end

function DB.getTreasureHuntFightTime1()
    return DB.getClientParam("CT_FIGHT_TIME_1")
end

function DB.getTreasureHuntFightTime2()
    return DB.getClientParam("CT_FIGHT_TIME_2")
end

function DB.getTreasureHuntFightTime3()
    return DB.getClientParam("CT_FIGHT_TIME_3")
end

function DB.getTreasureHuntEventInfo(eventId)
    if eventId <= 0 or eventId > #cteventinfo_db then
        return ""
    end
    return cteventinfo_db[eventId]
end

function DB.getTreasureHuntTerrainEffct(terrainType)
    for key,var in ipairs(ctterraininfo_db) do
        if var.tertype == terrainType then
            return var.terintroduce
        end
    end

    return ""
end

function DB.getRichmanConfigByType2(id)
    for key,var in ipairs(richmanconfig_db) do
        if var.type2 == id then
            return var
        end
    end

    return nil
end


function DB.getRichmanConfig(id)
    for key,var in ipairs(richmanconfig_db) do
        if var.id == id then
            return var
        end
    end

    return nil
end


function DB.getRichmanRankReward(id)
    for key,var in ipairs(richmanrankreward_db) do
        if var.id == id then
            return var
        end
    end

    return nil
end


function DB.getRichmanScoreReward(id)
    for key,var in ipairs(richmanscorereward_db) do
        if var.id == id then
            return var
        end
    end

    return nil
end 
    
    

function DB.getTreasureHuntWeatherEffct(weatherType)
    for key,var in ipairs(ctweatherinfo_db) do
        if var.weatype == weatherType then
            return var.weaeffinfo
        end
    end

    return ""    
end

function DB.getTreasureHuntTimeEffect(timeType)
    if timeType == TerrainTimeType.day then
        return DB.getClientParamToTable("CT_TIME_DAY_LURK_ADD_PARAM",true)
    else
        return DB.getClientParamToTable("CT_TIME_NIGHT_LURK_ADD_PARAM",true)
    end
end

function DB.getOpenDayOfTreasureHunt()
    return DB.getClientParam("CT_DAY")
end

function DB.getOpenTimeOfTreasureHunt()
    return DB.getClientParam("CT_TIME")
end

function DB.getOpenDayOfWorldBoss()
    --return DB.getClientParam("WORLD_BOSS_DAY")
    if not gOpenDayWorldBossOld then
        local oldDay = DB.getClientParam("WORLD_BOSS_DAY")
        local newDay = DB.getClientParam("WORLD_BOSS_NEW_DAY") print(oldDay.." "..newDay)
        local ret = {}
        oldDay = string.split(oldDay,";")
        newDay = string.split(newDay,";")
        for _,_oldDay in pairs(oldDay) do
            local bNewDay = false
            for _,_newDay in pairs(newDay) do
                if toint(_oldDay) == toint(_newDay) then
                    bNewDay = true
                    break
                end
            end

            if bNewDay == false then
                table.insert(ret,_oldDay)
            end
        end
        
        gOpenDayWorldBossOld = ""
        for i = 1,table.getn(ret) do
            if i > 1 then
                gOpenDayWorldBossOld = gOpenDayWorldBossOld..";"..ret[i]
            else
                gOpenDayWorldBossOld = ret[i]
            end
        end
        return gOpenDayWorldBossOld
    else
        return gOpenDayWorldBossOld
    end
    
end

function DB.getSpecialTalentById(id)
    for k,var in pairs(petspecialtalent_db) do
        if var.id==id then
            return var
        end
    end
    return nil
end

function DB.getOpenTimeOfWorldBoss()
    return DB.getClientParam("WORLD_BOSS_TIME")
end

function DB.getTreasureHuntChatDia()
    return DB.getClientParam("CT_CHAT_DIAMOND")
end

function DB.getTreasureHuntNoticeInfo(noticeId)
    if noticeId <= 0 or noticeId > #ctnotice_db then
        return ""
    end
    return ctnotice_db[noticeId]
end

function DB.getTreasureHuntOpenLv()
    return DB.getClientParam("CT_OPEN_LV")
end

function DB.getConstellationGroupInfo(groupId)
    return constellationgroup_db[groupId]
end
-- sortId,表示第几条
function DB.getConstellationCircleExtraInfo(circleId,sortId)
    for _,var in ipairs(circleadd_db) do
        if var.cid == circleId and var.sort == sortId then
            return var
        end 
    end

    return nil
end

function DB.getConstellationCircleCount()
    return #circle_db
end

function DB.getConstellationCircleInfo(idx)
    return circle_db[idx]
end

function DB.getConstellationsCount()
    return #constellation_db
end

function DB.getConstellationsItemInfo(itemId)
    if DB.constellation_db==nil then
        DB.constellation_db={}
    end

    if DB.constellation_db[itemId] == nil then
        DB.constellation_db[itemId] = 0
        for _, var in pairs(constellation_db) do
            if(var.id == itemId)then
                DB.constellation_db[itemId] = var
            end
        end
    end 
    return DB.constellation_db[itemId]   
end

function DB.getConstellationCircleName(id)
    local circleInfo = circle_db[id]
    if nil ~= circleInfo then
        return circleInfo.name
    end
    return ""
end

function DB.getTotalCirceGroupNums(circleId)
    if DB.constellationgroup_nums==nil then
        DB.constellationgroup_nums={}
    end

    if DB.constellationgroup_nums[circleId] == nil then
        DB.constellationgroup_nums[circleId] = 0
        for _, var in pairs(constellationgroup_db) do
            if(var.cid == circleId)then
                DB.constellationgroup_nums[circleId] = DB.constellationgroup_nums[circleId] + 1
            end
        end
    end 
    return DB.constellationgroup_nums[circleId]
end

function DB.getCircleGroupInfos(circleId)
    if DB.constellationgroup_infos == nil then
        DB.constellationgroup_infos = {}
    end

    if DB.constellationgroup_infos[circleId] == nil then
        DB.constellationgroup_infos[circleId] = {}
        for _, var in pairs(constellationgroup_db) do
            if(var.cid == circleId)then
                table.insert(DB.constellationgroup_infos[circleId], var)
            end
        end
    end

    return DB.constellationgroup_infos[circleId]
end

function DB.getCircleGroupStar(cgid,starLv)
    for _, var in pairs(constellationstar_db) do
        if(var.cgid == cgid and var.star==starLv )then
            return var
        end
    end
    return nil
end


function DB.getConstellationUnlockLv()
    return DB.getClientParam("CONSTELLATION_OPEN_LV")
end

function DB.getConstellationHuntPrices()
    return DB.getClientParamToTable("CON_HUNT_STAR_PRICES", true)
end

function DB.getConstellationFightMaxNum()
    return DB.getClientParam("CONSTELLATION_FIGHT_NUM_MAX")
end

function DB.getConstellationFreeChangeNum()
    return DB.getClientParam("CONSTELLATION_FIGHT_FREE_CHANGE_NUM")
end

function DB.getConstellationAchieveInfo(achieveId)
    return constellationachieve_db[achieveId]
end

function DB.getConstellationAchieveSize()
    return #constellationachieve_db
end

function DB.getConstallationChangeSoul(starNum)
    local changeSouls = DB.getClientParamToTable("CON_CHANGE_SOUL",true)
    return changeSouls[starNum]
end

function DB.getConstellationStageById(constellationId)
    for key, var in pairs(constellation_stage_db) do
        if var.stage_id== constellationId then
            return var
        end
    end

    return nil
end

function DB.getPetSpecialTalentBook()
    if DB.talentBook==nil then
        DB.talentBook={}
        for key, var in pairs(petspecialtalent_db) do
            if DB.talentBook[var.type]==nil then
                DB.talentBook[var.type]={}
            end
            table.insert(DB.talentBook[var.type],var)
        end
    end
    return DB.talentBook
end


function DB.getConstellationFightRecovery()
    return DB.getClientParam("RECOVERY_TIME_CONSTELLATION_FIGHT")
end

function DB.getTreasureHuntMaxBuy()
    return DB.getClientParam("CT_BUY_MAP_MAX")
end

function parseDBNumType(var)

    if(string.len(var)>9) then
        return   (var)
    end


    if(string.find(var,";")~=nil or string.find(var,",")~=nil)then
        return   (var)
    end

    if(string.find(var,".")~=nil)then
        return tonum(var)
    end


    return toint(var)
end

--转换table 的列类型
function paserDBColType()


    for idx, pet in pairs(pet_db) do
        for key, var in pairs(pet) do
            if(
                key=="buff0" or
                key=="buff1" or
                key=="buff2" or
                key=="buff3" )then
                pet[key]=  string.split(var,";")
                for buffidx, buff in pairs(pet[key]) do
                    pet[key][buffidx]=toint(pet[key][buffidx])
                end
            end
        end
    end
end


paserDBColType()