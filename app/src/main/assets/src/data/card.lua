CardPro={}
CardPro.expNetStack={}
CardPro.curExpId=0
CardPro.skillUnlock={}


CardPro.cardPros={
    attr11= "hpPercent",
    attr13= "physicalAttackPercent"  ,
    attr12="agilityPercent" ,
    attr15="physicalDefendPercent" ,
    attr16="magicDefendPercent" ,
    attr4= "magicAttack" ,
    attr3= "physicalAttack",
    attr2="agility" ,
    attr5="physicalDefend" ,
    attr6="magicDefend" ,
    attr1=  "hp" ,
    attr9="critical",
    attr10="toughness" ,
    attr7="hit" ,
    attr8="dodge" ,

    attr19="criticalPercent",
    attr20="toughnessPercent" ,
    attr17="hitPercent" ,
    attr18="dodgePercent" ,

    attr67="hitRate" ,
    attr68="dodgeRate" ,
    attr69="criticalRate" ,
    attr70="toughnessRate" ,
    attr41="hurtDownPercent" ,
    attr44="powerRaisePercent" ,
    attr71="skillDamagePercent",
}


function CardPro.recycle(card,isSoul)
    local cardDb=DB.getCardById(card.cardid)
    local lv=card.level
    local exp=card.exp
    for i=1, lv-1 do
        exp=exp+DB.getCardExpByLevel(i)
    end

    local gold = 0;
    local item = 0;
    local items={}
    for i=0, 4 do
        local sklv= card.skillLvs[i]
        if(sklv>1)then
            for j=1, sklv-1 do
                local _price,_item=    DB.getSkillPriceByLevel(j,i)
                gold=gold+_price
                item=item+_item
            end
        end
    end


    for i=0, MAX_CARD_EQUIP_NUM-1 do
        local equLv =card.equipLvs[i]
        for j=1, equLv do
            gold= gold+DB.getEquipPriceByLevel(j)
        end

        local equQlt=card.equipQuas[i]
        if(equQlt > 0)then
            for j=1, equQlt do
                local compound= DB.getEquCompound(cardDb["equid"..i],j)
                gold=gold+compound.price_gold
                local num=card.equipActives[k]
                for k=1, 5 do
                    local itemid=compound["item"..k]
                    if(items[itemid]==nil)then
                        items[itemid]=0
                    end
                    items[itemid]=items[itemid]+1
                end
            end
        end
        local num=card.equipActives[i]
        local compound= DB.getEquCompound(cardDb["equid"..i],equQlt+1)
        for k=0, 4 do
            if(CardPro.isEquipItemActivate(num,k))then
                local itemid=compound["item"..(k+1)]
                if(items[itemid]==nil)then
                    items[itemid]=0
                end
                items[itemid]=items[itemid]+1
            end
        end
    end
    local soulNum=0
    local awakeNum=0
    if(isSoul)then
        local data=DB.getCardAwakeTable(card.cardid)
        if(data)then

            local soulId=ITEM_TYPE_SHARED_PRE+card.cardid
            for key,var in pairs(data) do
                if   var.waken <=card.awakeLv then
                    awakeNum=awakeNum+var.itemnum
                    gold=gold+var.goldnum
                    soulNum=soulNum+var.soulnum
                end
            end
        end

        for i=cardDb.evolve, card.grade-1 do
            local needSoulNum=DB.getNeedSoulNum(i)
            soulNum=soulNum+needSoulNum
        end


    end

    return items,math.rint(gold*0.8),math.rint(item*0.8),math.rint(exp*0.8),soulNum,math.rint(awakeNum*0.8)
end


function CardPro.getExpItemParam(itemid)
    local item=DB.getItemById(itemid)
    if(item)then
        return item.param
    end
    return 0
end
function CardPro.getExpItemIdx(itemid)
    if(itemid==17)then
        return 1
    elseif(itemid==18)then
        return 2
    elseif(itemid==19)then
        return 3
    elseif(itemid==20)then
        return 4
    end
    return 0
end

function CardPro.sendEatExp()

    local lastData=CardPro.expNetStack[1]
    if(lastData ==nil)then
        return  true --栈没东西
    end

    if(lastData.hasSend==true)then
        return  false --还在发送中 等返回
    end

    lastData.hasSend=true
    Net.sendCardExpUpgrade(lastData.cardid, lastData.num1,lastData.num2,lastData.num3,lastData.num4)
    return true
end

function CardPro.pushEatExp(cardid,itemid,num)
    local lastData=CardPro.expNetStack[table.getn(CardPro.expNetStack)]
    local data={}
    local isNew=true
    if(lastData)then
        if(lastData.cardid==cardid)then
            isNew=false
            data=lastData
        else
            if( CardPro.sendEatExp()==false)then
                return  false,2
            end
        end
    end

    if(isNew)then
        data.num1=0
        data.num2=0
        data.num3=0
        data.num4=0
    end

    local numIdx=CardPro.getExpItemIdx(itemid)
    local bagNum= Data.getUserItemNumById(itemid)

    local totalNum=0

    for key, stackData in pairs(CardPro.expNetStack) do
        totalNum=totalNum+stackData["num"..numIdx]
    end

    if(totalNum+num>bagNum)then
        return false ,1--背包数量不足
    end

    data.cardid=cardid
    data["num"..numIdx]= data["num"..numIdx]+num

    if(isNew)then
        data.hasSend=false
        table.insert(CardPro.expNetStack,data)
    end

    return true

end



function CardPro.getActivateTable(num)
    if(CardPro.activateTable==nil)then
        CardPro.activateTable={}
    end

    local saveKey=num

    if(CardPro.activateTable[saveKey]==nil)then
        local ret={}
        for i=0, 4 do
            table.insert(ret,i,num%2)
            num=math.floor(num/2)
        end
        CardPro.activateTable[saveKey]=ret
    end

    return CardPro.activateTable[saveKey]
end

function CardPro.getActivateNum(activates)
    local ret=0
    for i=0, 4 do
        ret=ret*2+activates[4-i]
    end
    return ret
end

function CardPro.setActivate(num,pos)
    local activates=clone(CardPro.getActivateTable(num))
    activates[pos]=1
    return CardPro.getActivateNum(activates)
end



function CardPro.isEquipItemActivate(num,pos)
    local activates=CardPro.getActivateTable(num)
    return activates[pos]==1
end


function CardPro.isEquipItemAllActivate(num)

    for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
        if(CardPro.isEquipItemActivate(num,i) ==false)then
            return false
        end
    end

    return true

end


function CardPro.hasEquipItemActivate(itemid)
    for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
        if(CardPro.isEquipItemActivate(num,i) ==false)then
            return false
        end
    end

    return true

end



function CardPro.hasEquipItemShared(itemid)
    local item=DB.getEquipItemById(itemid)
    local num= Data.getEquipItemNum(itemid)
    if(num>0)then --足够物品激活
        if(item~=nil)then
            return true,false,0
    end
    elseif (item.com_num>0)then
        num= Data.getSharedNum(itemid)
        if(num>=item.com_num)then --足够合成
            return true,true,item.com_money
        end
    end
    return false,false,0
end


function CardPro.canUpQuality(card)
    local quality=card.quality
    for i=0, MAX_CARD_EQUIP_NUM-1 do
        if(  card.equipQuas[i]<quality+1)then
            return false
        end
    end
    return true
end


function CardPro.isAllEquipUpgrade(card)

    local quality=card.quality
    for i=0, MAX_CARD_EQUIP_NUM-1 do
        if(  card.equipLvs[i]<(quality+1)*10)then
            return false,(quality+1)*10
        end
    end
    return true,0
end

function CardPro.canEquipUpQuality(card,idx)
    if( CardPro.isEquipItemAllActivate(card.equipActives[idx])==false)then
        return false
    end

    --[[
    local cardDb=DB.getCardById(card.cardid)

    local equipId=cardDb["equid"..(idx)]
    local qua= card.equipQuas[idx]
    local equipLv=card.equipLvs[idx]


    local compound=DB.getEquCompound(equipId,qua+1)
    if(compound)then
    if(compound.price_gold>gUserInfo.gold )then
    return false
    end
    end
    ]]

    return true
end




function CardPro.canSkillUpgrade(card,pos)
    local lv=card.skillLvs[pos]
    local limitLevel={0,0,20,40,60,75,90}

    if(lv>=card.level-limitLevel[pos+1])then
        return false ,lv+limitLevel[pos+1]+1--等级不能超过卡牌等级
    end

    return true,lv+limitLevel[pos+1]+1

end

function CardPro.getSkillUnlockQuality(card,skillpos)
    local ret= CardPro.skillUnlock[card.cardid]
    for key, var in pairs(ret) do
        if(skillpos+1==var)then
            return key+1
        end
    end
    return 0
end

function CardPro.isSkillUnlock(card,skillpos)
    if(CardPro.skillUnlock[card.cardid])then
        if( CardPro.skillUnlock[card.cardid][ card.quality]==nil)then
            CardPro.skillUnlock[card.cardid][ card.quality]=0
        end
        return (skillpos+1)<= CardPro.skillUnlock[card.cardid][ card.quality]
    end

    --缓存起来
    local curSkillNum=2
    local ret={}
    for i=0, MAX_CARD_QUALITY do
        local data= DB.getCardQuality(card.cardid,i)
        if(data and data.new_skill==1)then
            curSkillNum=curSkillNum+1
        end
        ret[i]=curSkillNum
    end

    CardPro.skillUnlock[card.cardid]=ret
    if(CardPro.skillUnlock[card.cardid][ card.quality]==nil)then
        CardPro.skillUnlock[card.cardid][ card.quality]=0
    end
    return (skillpos+1)<= CardPro.skillUnlock[card.cardid][ card.quality]

end

function CardPro.showStar6(layer,num,awakeLv)
    local bgStar = layer:getNode("star_container");
    bgStar:removeAllChildren();
    CardPro:showNewStar(bgStar,num,awakeLv);


end

function CardPro:showNewStar(bgStar,starNum,awakeLv,starSpaceW,isNeedEmptyStar,isLeftAglin)
    if(awakeLv == nil)then
        awakeLv = 0;
    end
    if(bgStar == nil)then
        return;
    end
    local starLayer = UILayer.new();
    starLayer:init("ui/ui_card_star.map")
    starLayer:ignoreAnchorPointForPosition(false);
    if(isLeftAglin and isLeftAglin == true)then
        starLayer:setAnchorPoint(cc.p(0,-0.5));
        gModifyExistNodeAnchorPoint(starLayer:getNode("star_parent"),cc.p(0,0.5));
        gRefreshNode(bgStar,starLayer,cc.p(0,0.5),cc.p(0,0),101);
    else
        starLayer:setAnchorPoint(cc.p(0.5,-0.5));
        gRefreshNode(bgStar,starLayer,cc.p(0.5,0.5),cc.p(0,0),101);
    end

    local star_parent = starLayer:getNode("star_parent");
    if(starSpaceW)then
        star_parent.space = starSpaceW;
    end

    if(awakeLv >= 7)then
        local diaNum = math.floor(awakeLv/7);
        for i=1,6 do
            if(i<=diaNum)then
                starLayer:changeTexture("icon_star"..i,"images/ui_public1/stdia.png")
            else
                starLayer:getNode("icon_star"..i):setVisible(false);
            end
        end
    elseif(awakeLv > 0 and starNum > 5) then --灵兽觉醒后星数大于5，并且awakeLv为实际的awakeLv
        for i=1,6 do
            if(i<=awakeLv)then
                starLayer:changeTexture("icon_star"..i,"images/ui_public1/stdia.png")
            else
                starLayer:getNode("icon_star"..i):setVisible(false);
            end
        end
    elseif(starNum <= 5)then
        starLayer:getNode("icon_star"..6):setVisible(false);
        for i=starNum+1,5 do
            if(isNeedEmptyStar)then
                starLayer:changeTexture("icon_star"..i,"images/ui_public1/star1-1.png")
            else
                starLayer:getNode("icon_star"..i):setVisible(false);
            end
        end
    end

    -- if(isLeftAglin and isLeftAglin == true)then
    --     gModifyExistNodeAnchorPoint(starLayer:getNode("star_parent"),cc.p(0,0.5));
    --     -- starLayer:getNode("star_parent")
    -- end

    star_parent:layout();
end

function CardPro:showStar(layer,num,awakeLv,space)

    layer:getNode("star_container"):setVisible(true)
    local bgStar = layer:getNode("star_container");
    bgStar:removeAllChildren();
    CardPro:showNewStar(bgStar,num,awakeLv,space);


end

function CardPro:showStarLeftToRight(layer,num,awakeLv)
    layer:getNode("star_container"):setVisible(true);
    if(not Module.isClose(SWITCH_AWAKE))then
        local bgStar = layer:getNode("star_container");
        bgStar:removeAllChildren();
        CardPro:showNewStar(bgStar,num,awakeLv,nil,nil,true);
    else
        for i=1,6 do
            local node=layer:getNode("icon_star"..i)
            node:setVisible(false);
            if i <= num then
                node:setVisible(true);
                layer:changeTexture("icon_star"..i,"images/ui_public1/star1.png")
            end
        end
    end
end


function CardPro.getSkillRangeDes(skill)
    return gGetWords("skillWord.plist","skill_rang"..skill.target_range)
end

function CardPro.isMaxLevel(lv,exp)
    if(lv>gUserInfo.level)then
        return true
    end

    if(lv==gUserInfo.level and exp==DB.getCardExpByLevel(gUserInfo.level))then
        return true
    end

    return false
end


--获取属性名称
function CardPro.getAttrName(type)
    if(type==nil)then
        return ""
    end
    return gGetWords("cardAttrWords.plist","attr"..type)
end

function CardPro.isFloatAttr(type)
    type=toint(type)
    if((type>=11 and type<=20) or
        type==67 or type==68 or
        type==69 or   type==70 or
        type==41  or type==42 or
        type==43   or type==44 or type==96 or
        type==72 or type==73)then
        return true
    end
    return  false
end

function CardPro.getAttrValue(type,value)

    if(CardPro.isFloatAttr(type))then
        return (value).."%"
    end
    return math.rint(value)
end
--获取卡牌装备 激活额外获取的属性描述
function CardPro.getEquipAtivateAttrAddDesc(data)
    local cardDb=DB.getCardById(data.cardid)
    local equipId=cardDb["equid"..data.equipIdx]
    local equipment= DB.getEquipment(equipId,data.equipQua)
    if(equipment)then
        local addAttrType=equipment["item_attr"..(data.activatePos+1)]
        local addAttrValue=equipment["item_value"..(data.activatePos+1)]
        return CardPro.getAttrAddDesc(addAttrType,addAttrValue)
    end
    return ""
end

--获取属性描述
function CardPro.getAttrAddDesc(type,value)
    local txt=""
    txt=txt..CardPro.getAttrName(type)
    txt=txt.."+"..value
    return txt
end

function CardPro.showPetLevelUpDesc(pet, pos,level)
    local ret={}
    local petDb=DB.getPetById(pet.petid)
    if(pos==0)then
        local data=  DB.getSkillById(petDb.skillid)
        table.insert(ret,  gGetSkillLevelUpDesc(data,level))
        if(data.buff_id0>0)then
            local buff=  DB.getBuffById(data.buff_id0)
            table.insert(ret,  gGetBuffLevelUpDesc(buff,level))
        end

        if(data.buff_id1>0)then
            local buff=  DB.getBuffById(data.buff_id1)
            table.insert(ret,  gGetBuffLevelUpDesc(buff,level))
        end
    else
        local buffs=petDb["buff"..(pos-1)]
        for key, buffId in pairs(buffs) do
            local buff=  DB.getBuffById(buffId)
            table.insert(ret,  gGetBuffLevelUpDesc(buff,level))
        end
    end
    AttChange.pushAtt(PANEL_PET,ret)
end


function CardPro.showSkillLevelUpDesc(card, pos,level)
    local ret={}
    local cardDb=DB.getCardById(card.cardid)
    if(pos<=1)then
        local data=  DB.getSkillById(cardDb["skillid"..pos])
        table.insert(ret,  gGetSkillLevelUpDesc(data,level))
        if(data.buff_id0>0)then
            local buff=  DB.getBuffById(data.buff_id0)
            table.insert(ret,  gGetBuffLevelUpDesc(buff,level))
        end

        if(data.buff_id1>0)then
            local buff=  DB.getBuffById(data.buff_id1)
            table.insert(ret,  gGetBuffLevelUpDesc(buff,level))
        end
    else
        local data=  DB.getBuffById(cardDb["buffid"..(pos-2)])
        table.insert(ret,  gGetBuffLevelUpDesc(data,level))
    end
    AttChange.pushAtt(PANEL_CARD_INFO,ret)
end


function CardPro.compairAttr(  card,oldCard)
    local ret={}
    for key, var in pairs(CardPro.cardPros) do
        if(var~="hurtDownPercent")then
            local i=string.gsub(key,"attr","")
            local add=0
            if(CardPro.isFloatAttr(i))then
                add= card[var] -  oldCard[var]
            else
                add=math.rint(card[var])- math.rint(oldCard[var])
            end

            if(math.abs(add)>0.001)then
                local label=gGetWords("cardAttrWords.plist","attr"..i)
                local addStr=add
                addStr=string.sub(addStr,1,4)
                if(add>0)then
                    label=label.."+"..addStr
                else
                    label=label..addStr
                end

                if(CardPro.isFloatAttr(i))then
                    label=label.."%"
                end
                table.insert(ret,label)
            end
        end
    end
    return ret
end



function CardPro.printCard(  card)
    if(oldCardData==nil)then
        oldCardData=clone(card)
    end

    --   print("血量:"..card.hp)
    -- print("攻击:"..card.physicalAttack.."  增加 "..(card.physicalAttack-oldCardData.physicalAttack))
    print("攻击:"..card.physicalAttack.."  增加 "..(card.physicalAttack-oldCardData.physicalAttack))

    oldCardData=clone(card)
end

--是否卡牌装备要升级
function CardPro.hasRelationActivate(card)

    local relations=DB.getRelationByCardId(card.cardid)
    local needRelation={}

    for key, data in pairs(relations) do
        local level=Data.getRelationLevelById(data.relationid)
        local cards=string.split(data.cardlist,";")
        local totalStar=0
        local hasAll=true
        for key, cardid in pairs(cards) do
            cardid=toint(cardid)
            local card=Data.getUserCardById(cardid)
            if(card~=nil)then
                totalStar=totalStar+card.grade
            else
                hasAll=false
            end
        end

        if(level>=1   )then
            if(level<DB.getMaxRelationLevel(data.relationid))then
                local var =DB.getRelationById(data.relationid,level+1)
                if(totalStar>= var.param )then
                    needRelation[data.relationid]=1
                end
            end
        else
            if(hasAll)then
                needRelation[data.relationid]=1
            end
        end
    end

    return needRelation
end


function CardPro.addSkillAttr(  i,   card,  skillId,  skillLv,addValue)
    if(card.attackSkillList[i]==nil)then
        card.attackSkillList[i]={}
        card.attackSkillList[i][0]=0
        card.attackSkillList[i][1]=0
    end

    if(i < 2)then
        card.attackSkillList[i][0] = skillId -- 技能id
        card.attackSkillList[i][1] = skillLv -- 技能等级
    end

end



--是否卡牌装备要升级
function CardPro.hasEquipUpgrade(card)

    if(card==nil)then
        return {};
    end

    local ret = {};
    for i=0, MAX_CARD_EQUIP_NUM-1 do
        if(CardPro.canEquipUpgrade(card,i))then
            -- return true
            ret[i] = true;
        end
    end

    return ret;
end



function CardPro.canEquipUpgrade(card,pos)
    local lv=card.equipLvs[pos]
    if(lv>=card.equipQuas[pos]*10)then
        return false --等级不能超过卡牌等级
    end

    return true

end
--是否有装备能强化
function CardPro.canOneEquipUpgrade(card)
    if(card==nil)then
        return false
    end

    for i=0, MAX_CARD_EQUIP_NUM-1 do
        if(CardPro.canEquipUpgrade(card,i))then
            return true
        end
    end

    return false
end


--是否卡牌装备要升介
function CardPro.hasEquipUpQuality(card)
    if(card==nil)then
        return {}
    end


    local ret={}
    for i=0, MAX_CARD_EQUIP_NUM-1 do
        if(card.equipQuas[i]<MAX_EQUIP_QUALITY and CardPro.canEquipUpQuality(card,i)==true)then
            ret[i]=true
        end
    end
    return ret
end




--卡牌是否又激活的
function CardPro.canEquipActivate(card,idx)
    local num=card.equipActives[idx]
    local cardDb=DB.getCardById(card.cardid)
    local equipid= cardDb["equid"..(idx)]
    local qua= card.equipQuas[idx]
    local compound= DB.getEquCompound(equipid,qua+1)

    if(compound )then
        for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
            if(CardPro.isEquipItemActivate(num,i) ==false)then
                local itemid= compound["item"..(i+1)]
                if(CardPro.hasEquipItemShared(itemid))then
                    return true
                end
            end
        end
    end
    return false
end
--是否卡牌装备要激活
function CardPro.hasEquipActivate(card)
    if(card==nil)then
        return {}
    end


    local ret={}
    for i=0, MAX_CARD_EQUIP_NUM-1 do
        if(CardPro.canEquipActivate(card,i)==true)then
            ret[i]=true
        end
    end
    return ret
end


--是否有卡牌要升星
function CardPro.canEvolve(card)
    if( card.grade>=DB.getCardMaxEvolve())then
        return false
    end

    local curSoulNum=Data.getSoulsNumById(card.cardid)
    local needSoulNum=DB.getNeedSoulNum(card.grade)

    if(curSoulNum>=needSoulNum)then
        return true
    end
    return false
end

--觉醒
function CardPro.canAwake(card)
    if(card.awakeLv >= Data.cardAwake.maxLv or card.grade < 5 or card.level < Data.cardAwake.needLv)then
        return false;
    end

    -- print("card.awakeLv = "..card.awakeLv);
    -- print("@@@@card.cardid = "..card.awakeLv);
    local awakeData = DB.getCardAwake(card.cardid,card.awakeLv+1);

    if(awakeData and NetErr.CardWaken(awakeData.itemnum,card.cardid,awakeData.soulnum,awakeData.goldnum,false))then
        return true;
    end
    return false;
end


--觉醒
function CardPro.canRaise(card)

    return false;
end


function CardPro.canTreasureEquip(card)

    local ret={}
    local needTreasure=false
    for i=1, 4 do
        ret[i]={}
        local treasures=Data.getTreasureByType(i-1)
        local treasureId=card["treasure"..i]
        if(treasureId==0)then
            ret[i]=treasures
            needTreasure=table.getn(treasures)>0
        else
            local curTreasure=Data.getTreasureById(treasureId)
            for key, var in pairs(treasures) do
                if(var.db.quality>curTreasure.db.quality)then
                    table.insert(ret[i],var)
                    needTreasure=true
                elseif(var.db.quality==curTreasure.db.quality and var.upgradeLevel>curTreasure.upgradeLevel)then
                    table.insert(ret[i],var)
                    needTreasure=true
                end
            end
        end
    end

    if(needTreasure)then
        return ret
    end
    return nil;
end



function CardPro.canWeaponUpgrade(card)
    local levelData=DB.getCardRaiseByLevel(card.cardid,card.weaponLv+1)
    if(levelData==nil)then
        return false
    end
    if card.weaponLv>=Data.cardRaiseMaxLevel then
        return false
    end
    for i=1, 5 do
        local cur=Data.getItemNum(levelData["itemid"..i])
        local max=levelData["itemnum"..i]
        if(max~=0)then
            if cur<max then
                return false
            end
        end
    end


    if(gUserInfo.level<levelData.userlevel)then
        return false
    end
    return true;
end


--是否有卡牌要技能要升级
function CardPro.hasSkillUpgrade(card)
    local ret=false

    if(card==nil)then
        return
    end

    local limitLevel={0,0,20,40,60,75,90}

    for i=0, MAX_CARD_SKILL_NUM-1 do
        if (CardPro.isSkillUnlock(card, i) and card.skillLvs[i] < card.level - limitLevel[i + 1]) then
            return true
        end
    end
    return ret
end

--
function CardPro.addTeamSpiritAttr(card,cardPos)
    --TODO
    if cardPos >= 0 and cardPos < 6 then
        local addLvs = DB.getSpiritAddLevs()
        for i = 1, 8 do
            local spirit = SpiritInfo.getSpiritWithPos(cardPos * 10 + i)
            if nil ~= spirit then
                local attr = DB.getSpiritAttr(spirit.iType, spirit.iLV + addLvs[i], spirit.iAttr)
                if nil ~= attr then
                    local value = attr.value
                    --TODO
                    CardPro.addOneAttr(card, spirit.iAttr, attr.value)
                    if attr.attr2 ~= 0 then
                        CardPro.addOneAttr(card, attr.attr2, attr.value2)
                    end
                end
            end
        end
    end
end






function CardPro.setCardRelationAttr(  card,   level,  grade,  quality)

    local relations=DB.getRelationByCardId(card.cardid)
    local cloneCard=clone(card)

    for key, data in pairs(relations) do
        local level=Data.getRelationLevelById(data.relationid)

        if(level>=1)then
            local var =DB.getRelationById(data.relationid,level)
            if(var)then
                CardPro.addOneAttr(card, var.attr, var.attr_value)
            end

        end

    end

    for key, var in pairs(CardPro.cardPros) do
        card[var.."_add"]=card[var]-cloneCard[var]
    end

    for key, var in pairs(card) do
        if(var~=0 and string.find(key,"Percent_add") )then
            key= string.gsub(key,"Percent_add","")
            card[key.."_add"]=card[key.."_add"]+math.floor(card[key.."_base"]*card[key.."Percent_add"]/100)
        end
    end
end




function CardPro.getOneAttr(  card,   attr )

    if (attr==Attr_HP) then
        return  card.hp
    elseif (attr==Attr_PHYSICAL_ATTACK) then
        return  card.physicalAttack
    elseif (attr==Attr_MAGIC_ATTACK) then
        return   card.magicAttack
    elseif (attr==Attr_AGILITY) then
        return  card.agility
    elseif (attr==Attr_PHYSICAL_DEFEND) then
        return  card.physicalDefend
    elseif (attr==Attr_MAGIC_DEFEND) then
        return  card.magicDefend
    elseif (attr==Attr_HIT) then
        return  card.hit
    elseif (attr==Attr_DODGE) then
        return   card.dodge
    elseif (attr==Attr_CRITICAL) then
        return   card.critical
    elseif (attr==Attr_TOUGHNESS) then
        return   card.toughness
    elseif (attr==Attr_HP_PERCENT) then
        return  card.hpPercent
    elseif (attr==Attr_PHYSICAL_ATTACK_PERCENT) then
        return   card.physicalAttackPercent
    elseif (attr==Attr_MAGIC_ATTACK_PERCENT) then
        return  card.magicAttackPercent
    elseif (attr==Attr_AGILITY_PERCENT) then
        return   card.agilityPercent
    elseif (attr==Attr_PHYSICAL_DEFEND_PERCENT) then
        return  card.physicalDefendPercent
    elseif (attr==Attr_MAGIC_DEFEND_PERCENT) then
        return  card.magicDefendPercent
    elseif (attr==Attr_IGNORE_DEFEND) then
        return  card.ignoreDefend


    elseif (attr==Attr_HIT_PERCENT) then
        return  card.hitPercent
    elseif (attr==Attr_DODGE_PERCENT) then
        return  card.dodgePercent
    elseif (attr==Attr_CRITICAL_PERCENT) then
        return  card.criticalPercent
    elseif (attr==Attr_TOUGHNESS_PERCENT) then
        return  card.toughnessPercent
    end
    return 0
end



function CardPro.addOneAttr(  card,   attr,   value)
    if(attr==0)then
        return
    end
    if (attr==Attr_HP) then
        card.hp = card.hp+value
    elseif (attr==Attr_PHYSICAL_ATTACK) then
        card.physicalAttack = card.physicalAttack+ value
    elseif (attr==Attr_MAGIC_ATTACK) then
        card.magicAttack = card.magicAttack   +value
    elseif (attr==Attr_AGILITY) then
        card.agility = card.agility   +value
    elseif (attr==Attr_PHYSICAL_DEFEND) then
        card.physicalDefend = card.physicalDefend   +value
    elseif (attr==Attr_MAGIC_DEFEND) then
        card.magicDefend = card.magicDefend   +value
    elseif (attr==Attr_HIT) then
        card.hit = card.hit   +value
    elseif (attr==Attr_DODGE) then
        card.dodge = card.dodge   +value
    elseif (attr==Attr_CRITICAL) then
        card.critical = card.critical   +value
    elseif (attr==Attr_TOUGHNESS) then
        card.toughness = card.toughness   +value
    elseif (attr==Attr_HP_PERCENT) then
        card.hpPercent = card.hpPercent   +value
    elseif (attr==Attr_PHYSICAL_ATTACK_PERCENT) then
        card.physicalAttackPercent = card.physicalAttackPercent   +value
    elseif (attr==Attr_MAGIC_ATTACK_PERCENT) then
        card.magicAttackPercent = card.magicAttackPercent   +value
    elseif (attr==Attr_AGILITY_PERCENT) then
        card.agilityPercent = card.agilityPercent   +value
    elseif (attr==Attr_PHYSICAL_DEFEND_PERCENT) then
        card.physicalDefendPercent = card.physicalDefendPercent   +value
    elseif (attr==Attr_MAGIC_DEFEND_PERCENT) then
        card.magicDefendPercent = card.magicDefendPercent   +value
    elseif(attr==Attr_BASE_ATTR_PERCENT)then
        card.hpPercent = card.hpPercent   +value
        card.magicDefendPercent = card.magicDefendPercent   +value
        card.physicalDefendPercent = card.physicalDefendPercent   +value
        card.physicalAttackPercent = card.physicalAttackPercent   +value
    elseif(attr==Attr_ALL_DEFEND_PERCENT)then
        card.magicDefendPercent = card.magicDefendPercent   +value
        card.physicalDefendPercent = card.physicalDefendPercent   +value
    elseif (attr==Attr_ALL_ATTACK) then
        card.physicalAttack = card.physicalAttack   +value
        card.magicAttack = card.magicAttack   +value

    elseif (attr==Attr_ALL_DEFEND) then
        card.physicalDefend = card.physicalDefend   +value
        card.magicDefend = card.magicDefend   +value

    elseif (attr==Attr_IGNORE_DEFEND) then
        card.ignoreDefend = card.ignoreDefend   +value

    elseif (attr==Attr_HURT_DOWN) then 
        card.hurtDownPercent =  card.hurtDownPercent   +value
    elseif (attr==Attr_POWER_RAISE) then
        card.powerRaisePercent =card.powerRaisePercent+ value
    elseif (attr==Attr_HIT_RATE) then
        card.hitRate =card.hitRate+ value

    elseif (attr==Attr_DODGE_RATE) then
        card.dodgeRate =card.dodgeRate+ value

    elseif (attr==Attr_CRITICAL_RATE) then
        card.criticalRate =card.criticalRate+ value

    elseif (attr==Attr_TOUGHNESS_RATE) then
        card.toughnessRate =card.toughnessRate+ value
    elseif (attr==Attr_SKILL_DAMAGE_PERCENT) then
        card.skillDamagePercent =card.skillDamagePercent+ value
    elseif (attr==Attr_HIT_PERCENT) then
        card.hitPercent=card.hitPercent+ value
    elseif (attr==Attr_DODGE_PERCENT) then
        card.dodgePercent=card.dodgePercent+ value
    elseif (attr==Attr_CRITICAL_PERCENT) then
        card.criticalPercent=card.criticalPercent+ value
    elseif (attr==Attr_TOUGHNESS_PERCENT) then
        card.toughnessPercent=card.toughnessPercent+ value
    else
        print("CardPro.addOneAttr error attr ".. attr)
    end
end

function CardPro.addBuffAttr(  i,   card,  skillId,  skillLv,addValue)
    if(card.cardBuffList[i]==nil)then
        card.cardBuffList[i]={}
        card.cardBuffList[i][0]=0
        card.cardBuffList[i][1]=0
    end

    if(skillId and  skillId > 0)then
        local buff = DB.getBuffById(skillId)
        if (buff ~= nil) then
            local level = skillLv - 1
            if (buff.type == BUFFER_TYPE_ADD_ATTR) then-- 加属性的技能
            else
                card.cardBuffList[i][0] = skillId -- 技能id
                card.cardBuffList[i][1] = skillLv -- 技能等级
            end
        end
    end
end




function CardPro.setTeamWeaponBuffAttr(  cards)
    for key, card in pairs(cards) do
        local raiseDatas=DB.getRaiseByCardid(card.cardid)
        if(raiseDatas)then
            for key, var in pairs(raiseDatas) do
                if(  card.weaponLv>=var.level and var.buffid~=0 )then
                    local buff = DB.getBuffById(var.buffid)
                    if (buff ~= nil) then
                        local level = 1
                        if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR) then-- 加属性的技能
                            local attr = buff.attr_id0 -- 这个值表示心术加哪项属性
                            if(attr>0)then
                                --local value = math.rint(buff.attr_value0 + buff.attr_add_value0 * level) -- 技能加的属性值
                                local value = buff.attr_value0 + buff.attr_add_value0 * level -- 技能加的属性值
                                CardPro.addTeamOneAttr( cards,attr, value,buff.target_range) -- 加上主属性的值
                            end
                        end
                    end
                end
            end
        end
    end
end


function CardPro.addTeamBuffAttr( cards )
    for key, card in pairs(cards) do
        local cardDb=DB.getCardById(card.cardid)
        if(cardDb and card)then
            for i=0, 4 do
                if(CardPro.isSkillUnlock(card, i+2))then
                    local skillid=cardDb["buffid"..i]
                    local skillLv= card.skillLvs[i+2]
                    local buff = DB.getBuffById(skillid)
                    if (buff ~= nil) then
                        local level = skillLv - 1
                        if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR) then-- 加属性的技能
                            local attr = buff.attr_id0 -- 这个值表示心术加哪项属性
                            if(attr>0)then
                                --local value = math.rint(buff.attr_value0 + buff.attr_add_value0 * level) -- 技能加的属性值
                                local value = buff.attr_value0 + buff.attr_add_value0 * level -- 技能加的属性值
                                CardPro.addTeamOneAttr( cards,attr, value,buff.target_range) -- 加上主属性的值
                            end
                            attr = buff.attr_id1 -- 这个值表示心术加哪项属性
                            if(attr>0)then
                                --local value = math.rint(buff.attr_value1 + buff.attr_add_value1 * level) -- 技能加的属性值
                                local value = buff.attr_value1 + buff.attr_add_value1 * level -- 技能加的属性值
                                CardPro.addTeamOneAttr( cards,attr, value,buff.target_range) -- 加上主属性的值
                            end
                        end
                    end
                end
            end

            --灵兽天赋全体加技能
            if card.pid and card.pid>0 then
                local userPet = Data.getUserPetById(card.pid)
                for i=1,8 do --8个天赋
                    local stid=userPet["stid"..i]
                    if stid>0 then
                        local stidDB = DB.getSpecialTalentById(stid)
                        for j=1,2 do --每个天赋2个技能
                            local bufid = stidDB["bufid"..j]
                            if (bufid>0) then
                                local buff = DB.getBuffById(bufid)
                                if (buff ~= nil) then
                                    local level = 0
                                    if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR) then-- 加属性的技能
                                        local attr = buff.attr_id0 -- 这个值表示心术加哪项属性
                                        if(attr>0)then
                                             --local value = math.rint(buff.attr_value0 + buff.attr_add_value0 * level) -- 技能加的属性值
                                            local value = buff.attr_value0 + buff.attr_add_value0 * level -- 技能加的属性值
                                            CardPro.addTeamOneAttr( cards,attr, value,buff.target_range) -- 加上主属性的值
                                        end
                                        attr = buff.attr_id1 -- 这个值表示心术加哪项属性
                                        if(attr>0)then
                                            --local value = math.rint(buff.attr_value1 + buff.attr_add_value1 * level) -- 技能加的属性值
                                            local value = buff.attr_value1 + buff.attr_add_value1 * level -- 技能加的属性值
                                            CardPro.addTeamOneAttr(cards,attr, value,buff.target_range) -- 加上主属性的值
                                        end
                                    end
                                end

                            end
                        end
                    end
                end
            end

        end
    end
end


function CardPro.addTeamPetAttr( petid,cards ,isPk)
    local petDb = DB.getPetById(petid)
    local userPet=Data.getUserPetById(petid)
    if(petDb and userPet)then
        for i=2, 5 do
            local lv=userPet["skillLevel"..i]
            if(lv>0)then
                CardPro.addTeamPetOneAttr(cards,i,lv-1, userPet,petDb,isPk )
            end
        end
    end
end

function CardPro.isBattleType(buff,isPk)


    if(buff.battle_type==0)then
        return  true
    elseif(buff.battle_type==1 and isPk==false)then

        return  true
    elseif(buff.battle_type==2 and isPk==true)then
        return  true
    end

    return  false
end

function CardPro.addTeamPetOneAttr(cards,i,level, userPet,petDb,isPk )
    local buffs=    petDb["buff"..i-2]
    for key, buffid in pairs(buffs) do
        local buff=DB.getBuffById(buffid)

        if( CardPro.isBattleType(buff,isPk) )then
            if (buff.type ==BUFFER_TYPE_ADD_ATTR or buff.type==BUFFER_TYPE_ADD_TEAM_ATTR)then --- 加属性的技能
                local attr = buff.attr_id0 -- 这个值表示心术加哪项属性
                local value = (buff.attr_value0 + buff.attr_add_value0 * level) -- 技能加的属性值
                CardPro.addTeamOneAttr(cards,attr,value,buff.target_range)

                attr = buff.attr_id1 -- 这个值表示心术加哪项属性
                value = (buff.attr_value1 + buff.attr_add_value1 * level) -- 技能加的属性值
                CardPro.addTeamOneAttr(cards,attr,value,buff.target_range)
            end
        end

    end
end



function CardPro.addTeamOneAttr(cards,attr,value,rangeType)
    local startPos = 0;
    local endPos = 0;
    if(rangeType == SKILL_RANGE_ALL)then
        startPos = 0;
        endPos = 5;
    elseif(rangeType == SKILL_RANGE_FRONT_ROW)then
        startPos = 0;
        endPos = 2;
    elseif(rangeType == SKILL_RANGE_BACK_ROW)then
        startPos = 3;
        endPos = 5;
    end

    for i=startPos, endPos do
        if(cards[i])then
            CardPro.addOneAttr(cards[i], attr,value)
        end
    end

end




function CardPro.saveCardBaseAttr(  card)
    for key, var in pairs(CardPro.cardPros) do
        card[var.."_base"]=card[var]
    end
end

function CardPro.setAllCardAttr(hide)
    local socket = require "socket"
    local t0 = socket.gettime()
    for key, card in pairs(gUserCards) do
        CardPro.setCardAttr(  card,hide)
    end
    local t1 = socket.gettime()
    print("used time: "..t1-t0.."ms")
end


function CardPro.setWeaponBuffAttr(  card,   level,  grade,  quality)

    local raiseDatas=DB.getRaiseByCardid(card.cardid)
    if(raiseDatas==nil)then
        return
    end
    for key, var in pairs(raiseDatas) do
        if(  card.weaponLv>=var.level   )then
            if( var.buffid~=0)then
                CardPro.addCardSkillAttr(card,var.buffid,1)
            end
            if(var.hp>0)then
                card.hp=card.hp+var.hp
            end

            if(var.atk>0)then
                card.physicalAttack=card.physicalAttack+var.atk
            end

            if(var.pdef>0)then
                card.physicalDefend=card.physicalDefend+var.pdef
            end

            if(var.mdef>0)then
                card.magicDefend=card.magicDefend+var.mdef
            end

            --  hp=20 , atk=10 , pdef=10 , mdef=60

        end
    end



end





function CardPro.setFamilyBuffAttr(  card)
    if(gUserFamilyBuff==nil)then
        return
    end
    for key, var in pairs(gUserFamilyBuff) do
        local buff=DB.getBuffById(var.id)
        local lv=var.userskilllv
        if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR)then
            local ufs=DB.getFamilyBuff(var.id,var.userskilllv);
            -- 加属性的技能

            if(ufs and var.userskilllv > 0)then
                local levels={}
                levels[0] = ufs.val- 1;
                levels[1]= ufs.val1- 1;

                for i=0, 1 do
                    local value =  (buff["attr_value"..i] + buff["attr_add_value"..i] * levels[i])-- 技能加的属性值
                    local attr = buff["attr_id"..i] -- 这个值表示心术加哪项属性

                    if(buff.target_range==0)then
                        CardPro.addOneAttr(card, attr,value)
                    end

                end
            end
        end

    end
end

function CardPro.setTeamFamilyBuffAttr(  cards)

    if(gUserFamilyBuff==nil)then
        return
    end

    for key, var in pairs(gUserFamilyBuff) do
        local buff=DB.getBuffById(var.id)
        local lv=var.userskilllv
        if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR)then
            local ufs=DB.getFamilyBuff(var.id,var.userskilllv);
            -- 加属性的技能

            if(ufs and var.userskilllv > 0)then
                local levels={}
                levels[0] = ufs.val- 1;
                levels[1]= ufs.val1- 1;

                for i=0, 1 do
                    local value =  (buff["attr_value"..i] + buff["attr_add_value"..i] * levels[i])-- 技能加的属性值
                    local attr = buff["attr_id"..i] -- 这个值表示心术加哪项属性

                    if(buff.target_range~=0)then
                        CardPro.addTeamOneAttr(cards, attr, value,buff.target_range)-- 加上主属性的值
                    end

                end

            end
        end

    end
end
function CardPro.setPetAttr(  card,   level,  grade,  quality)
    local attrs={Attr_HP,Attr_PHYSICAL_ATTACK,Attr_PHYSICAL_DEFEND,Attr_MAGIC_DEFEND}
    if(gPetAddAttrDirty==true)then
        local attrAdd={}
        for key, pet in pairs(gUserPets) do
            local isWakedup = pet.grade > 5
            local db=DB.getPetById(pet.petid)
            for key, var in pairs(pet_upgrade_db) do
                if(var.petid==pet.petid and var.level<=pet.level)then

                    if(attrAdd[var.attr_id]==nil)then
                        attrAdd[var.attr_id]=0
                    end
                    local attr_value = var.attr_value
                    if isWakedup and db then 
                        attr_value = var.attr_value * (1 + db.wakeup_attrpercent / 100)
                    end
                    attrAdd[var.attr_id]=attrAdd[var.attr_id]+attr_value
                end
            end
            

            if(db and (db["attr_value_grade"..pet.grade] or isWakedup))then
                local addStr=    db["attr_value_grade"..pet.grade];
                if isWakedup then
                    addStr = db["attr_value_grade5"];
                end
                local addData = string.split(addStr,";");
                for key, var in pairs(attrs) do
                    if(attrAdd[var]==nil)then
                        attrAdd[var]=0
                    end

                    if isWakedup then
                        addData[key] = addData[key] * (1 + db.wakeup_attrpercent / 100)
                    end
                    attrAdd[var]=attrAdd[var]+addData[key]
                end
            end

            --加对当前的属性
            local addcriticalrate = 0
            for i=1,8 do
                local stid=pet["stid"..i]
                if stid>0 then
                    local stidDB = DB.getSpecialTalentById(stid)
                    for j=1,2 do
                        local bufid = stidDB["bufid"..j]
                        if (bufid>0) then
                            local buff = DB.getBuffById(bufid)
                            if buff and buff.type == BUFFER_TYPE_ADD_PET_CRITICAL  then
                                addcriticalrate = addcriticalrate + buff.attr_value0
                            end
                        end
                    end
                end
            end
            pet.addcriticalrate = addcriticalrate
        end
        gPetAddAttrDirty=false
        gPetAddAttr=attrAdd
    end
    for key, var in pairs(gPetAddAttr) do
        CardPro.addOneAttr(card, key, var)
    end
end

--附身
function CardPro.setPossPetAttr(  card,   level,  grade,  quality)
    if card.pid and card.pid>0 then
        --加45%基础属性
        local attrs={Attr_HP,Attr_PHYSICAL_ATTACK,Attr_PHYSICAL_DEFEND,Attr_MAGIC_DEFEND}
        local attrAdd={}
        local pet = Data.getUserPetById(card.pid)
        local isWakedup = pet.grade > 5
        local db=DB.getPetById(pet.petid)
        for key, var in pairs(pet_upgrade_db) do
            if(var.petid==pet.petid and var.level<=pet.level)then
                if(attrAdd[var.attr_id]==nil)then
                    attrAdd[var.attr_id]=0
                end
                local attr_value = var.attr_value
                if isWakedup and db then 
                    attr_value = var.attr_value * (1 + db.wakeup_attrpercent / 100)
                end
                attrAdd[var.attr_id]=attrAdd[var.attr_id]+attr_value
            end
        end
        if(db and (db["attr_value_grade"..pet.grade] or isWakedup))then
            local addStr= db["attr_value_grade"..pet.grade];
            if isWakedup then
                addStr = db["attr_value_grade5"];
            end
            local addData = string.split(addStr,";");
            for key, var in pairs(attrs) do
                if(attrAdd[var]==nil)then
                    attrAdd[var]=0
                end
                if isWakedup then
                    addData[key] = addData[key] * (1 + db.wakeup_attrpercent / 100)
                end
                attrAdd[var]=attrAdd[var]+addData[key]
            end
        end
        for key, var in pairs(attrAdd) do
            local value = math.rint(Data.pet.possessAddRate/100*var)
            CardPro.addOneAttr(card, key, value)
        end
        --加对当前的属性
        for i=1,8 do
            local stid=pet["stid"..i]
            if stid>0 then
                local stidDB = DB.getSpecialTalentById(stid)
                for j=1,2 do
                    local bufid = stidDB["bufid"..j]
                    if (bufid>0) then
                        CardPro.addCardSkillAttr(card,bufid,0)
                    end
                end
            end
        end
    end
    
end

function CardPro.setPetRelationAttr(  card,   level,  grade,  quality)
    local attrAdd={}
    local relations=DB.getRelationByType(2,1)
    for key, var in pairs(relations) do
        local cards=string.split(var.cardlist,";")
        local relationData={}
        relationData.id=var.relationid
        relationData.level=Data.getRelationLevelById(var.relationid)
        local maxLevel=DB.getMaxRelationLevel(var.relationid)
        if(relationData.level>maxLevel)then
            relationData.level=maxLevel
        end
        if(relationData.level > 0)then
            local levelData=DB.getRelationById(var.relationid,relationData.level)
            if(relationData)then
                if(attrAdd[levelData.attr]==nil)then
                    attrAdd[levelData.attr]=0
                end
                attrAdd[levelData.attr]=attrAdd[levelData.attr]+levelData.attr_value

                if(attrAdd[levelData.attr2]==nil)then
                    attrAdd[levelData.attr2]=0
                end
                attrAdd[levelData.attr2]=attrAdd[levelData.attr2]+levelData.attr_value2

                if(attrAdd[levelData.attr3]==nil)then
                    attrAdd[levelData.attr3]=0
                end
                attrAdd[levelData.attr3]=attrAdd[levelData.attr3]+levelData.attr_value3

                if(attrAdd[levelData.attr4]==nil)then
                    attrAdd[levelData.attr4]=0
                end
                attrAdd[levelData.attr4]=attrAdd[levelData.attr4]+levelData.attr_value4
            end
        end
    end
    for key, var in pairs(attrAdd) do
        CardPro.addOneAttr(card, key, var)
    end
end

function CardPro.getLevelVec(  lv)
    if(CardPro.levelVecs==nil)then
        CardPro.levelVecs={}
    end
    local curLv=lv
    if(CardPro.levelVecs[curLv]==nil)then
        local vec ={}
        if(lv<=0)then
            return vec
        end
        local i=0
        while(lv>10)do
            if(i==0)then
                table.insert( vec,9)
            else
                table.insert( vec,10)
            end
            lv=lv-10
            i=i+1
        end


        if(i==0)then
            table.insert( vec,lv-1)
        else
            table.insert( vec,lv)
        end
        CardPro.levelVecs[curLv]= vec
    end

    return CardPro.levelVecs[curLv]
end


function CardPro.getQualityAttr(db,type)
    if(db==nil)then
        return 0
    end
    if(type== Attr_HP)then
        return db.hp
    elseif(type== Attr_AGILITY)then
        return db.agility
    elseif(type== Attr_PHYSICAL_ATTACK)then
        return db.physical_attack
    elseif(type== Attr_MAGIC_ATTACK)then
        return db.magic_attack
    elseif(type== Attr_PHYSICAL_DEFEND)then
        return db.physical_defend
    elseif(type== Attr_MAGIC_DEFEND)then
        return db.magic_defend
    elseif(type== Attr_HIT)then
        return db.hit
    elseif(type== Attr_DODGE)then
        return db.dodge
    elseif(type== Attr_CRITICAL)then
        return db.critical
    elseif(type== Attr_TOUGHNESS)then
        return db.toughness
    end
    return 0
end



function CardPro.getGradeAttr(db,type)
    if(db==nil)then
        return 0
    end
    if(type== Attr_HP)then
        return db.hp_add
    elseif(type== Attr_AGILITY)then
        return db.agility_add
    elseif(type== Attr_PHYSICAL_ATTACK)then
        return db.physical_attack_add
    elseif(type== Attr_MAGIC_ATTACK)then
        return db.magic_attack_add
    elseif(type== Attr_PHYSICAL_DEFEND)then
        return db.physical_defend_add
    elseif(type== Attr_MAGIC_DEFEND)then
        return db.magic_defend_add
    elseif(type== Attr_HIT)then
        return db.hit_add
    elseif(type== Attr_DODGE)then
        return db.dodge_add
    elseif(type== Attr_CRITICAL)then
        return db.critical_add
    elseif(type== Attr_TOUGHNESS)then
        return db.toughness_add
    end
    return 0
end


function CardPro.getAddAttrValue(db,attr,levelVec)
    if(db==nil)then
        return 0
    end
    local value = 0
    local addValue = CardPro.getGradeAttr(db,attr)
    for key, a in pairs(levelVec) do
        local k=math.min(key-1 ,7)
        value =value+ (1+0.13*k)*a
    end
    return math.rint(value*addValue)

end

function CardPro.clearCardAttrPercent(card)
    card.physicalAttack =0
    card.hp =0
    card.physicalDefend =0
    card. magicDefend = 0

end



function CardPro.clearCardAttrPercent(card)

    local percentAttr={"physicalAttack","hp","physicalDefend","magicDefend"}
    for key, attr in pairs(percentAttr) do
        card[attr.."_percent_add"]=nil
    end
end

function CardPro.countCardAttrPercent(card)
    local percentAttr={"physicalAttack","hp","physicalDefend","magicDefend"}

    for key, attr in pairs(percentAttr) do
        if(card[attr.."_percent_add"])then
            card[attr]=card[attr]- card[attr.."_percent_add"]
            card[attr.."_percent_add"]=nil
        end
        local value= card[attr.."Percent"]*card[attr.."_base"]/100
        card[attr.."_percent_add"]=value
        card[attr]=card[attr]+ card[attr.."_percent_add"]
    end

end

function CardPro.initAttr(card,attr)
    card[attr]=0
    card[attr.."_add"]=0
    card[attr.."_base"]=0

end

function CardPro.setCardBaseAttr(  card,   level,  grade,  quality)
    local cardDb=DB.getCardById(card.cardid)

    for key, var in pairs(CardPro.cardPros) do
        CardPro.initAttr(card,var)
    end
    card["hurtDownPercent"]=0
    card["hurtDownPercent_add"]=0
    card["hurtDownPercent_base"]=0


    if(cardDb==nil)then
        return
    end
    local qualityData= DB.getCardQuality(card.cardid,quality)
    local gradeData= DB.getCardGrade(card.cardid,grade)

    if(qualityData==nil)then
        return
    end
    if(gradeData==nil)then
        return
    end
    levelVec=CardPro.getLevelVec(level)


    card.hp= qualityData.hp+  CardPro.getAddAttrValue( gradeData, Attr_HP,levelVec)+  (grade-1)*cardDb.hp
    card.physicalAttack=qualityData.physical_attack+  CardPro.getAddAttrValue( gradeData, Attr_PHYSICAL_ATTACK,levelVec)+  (grade-1)*cardDb.physical_attack
    card.agility=qualityData.agility+  CardPro.getAddAttrValue( gradeData, Attr_AGILITY,levelVec)+  (grade-1)*cardDb.agility
    card.physicalDefend= qualityData.physical_defend+  CardPro.getAddAttrValue( gradeData, Attr_PHYSICAL_DEFEND,levelVec)+  (grade-1)*cardDb.physical_defend
    card.magicDefend= qualityData.magic_defend+  CardPro.getAddAttrValue( gradeData, Attr_MAGIC_DEFEND,levelVec)+  (grade-1)*cardDb.magic_defend
    card.hit=qualityData.hit+  CardPro.getAddAttrValue( gradeData, Attr_HIT,levelVec)+  (grade-1)*cardDb.hit
    card.dodge=qualityData.dodge+  CardPro.getAddAttrValue( gradeData, Attr_DODGE,levelVec)+  (grade-1)*cardDb.dodge
    card.critical=qualityData.critical+  CardPro.getAddAttrValue( gradeData, Attr_CRITICAL,levelVec)+  (grade-1)*cardDb.critical
    card.toughness=qualityData.toughness+  CardPro.getAddAttrValue( gradeData, Attr_TOUGHNESS,levelVec)+  (grade-1)*cardDb.toughness

    card.hitRate=   cardDb.hit_rate
    card.dodgeRate=  cardDb.dodge_rate
    card.criticalRate=    cardDb.critical_rate
    card.toughnessRate=  cardDb.toughness_rate
    
     
end
 

function CardPro.getCardRaiseAttr(card)

    card.physicalAttack=card.physicalAttack+ card["raise_physicalAttack"]
    card.physicalDefend=card.physicalDefend+ card["raise_physicalDefend"]
    card.magicDefend=card.magicDefend+ card["raise_magicDefend"]
    card.hp=card.hp+ card["raise_hp"]

    local power=  CardPro.countWeaponPower(card)
    local powerData=DB.getCardRaisePower(power)
    if(powerData )then
        if(powerData.attr_value0~=0)then
            CardPro.addOneAttr(card,Attr_POWER_RAISE,powerData.attr_value0)
        end
        if(powerData.attr_value1~=0)then
            CardPro.addOneAttr(card,Attr_HURT_DOWN,powerData.attr_value1)
        end
    end
end



--获取卡牌装备的强化属性
function CardPro.getCardEquipUpgradeAttr(   equipId,upgradeLevel,quality)
    local ret={}
    local base={}
    local lv = upgradeLevel
    local vec=CardPro.getLevelVec(lv)

    local equBase = DB.getEquipment(equipId, quality)

    for i=1, 3 do
        local attr=equBase["attr_type"..i]
        if(attr > 0)then
            local value= equBase["value"..i]
            if(ret[attr]==nil)then
                ret[attr]=0
            end

            if(base[attr]==nil)then
                base[attr]=0
            end
            ret[attr]=  ret[attr]+value
            base[attr]=  base[attr]+value
        end
    end


    for i, a in pairs(vec) do
        local equ = DB.getEquipment(equipId, i) --白装不能强化，所以+1品质开始算属性
        for j=1, 3 do
            local attr = equ["attr_type"..j]
            if(attr > 0)then
                local value =  equ["add_value"..j]*a
                if(ret[attr]==nil)then
                    ret[attr]=0
                end
                ret[attr]=  ret[attr]+value
            end
        end
    end
    return ret,base
end


function CardPro.getCardEquipActivateAttr(equipId,equipQua,activate)
    local equipment= DB.getEquipment(equipId,equipQua)
    local ret={}
    if(equipment)then
        for i=1, 5 do
            if(CardPro.isEquipItemActivate( activate,i-1) )then
                local attr=equipment["item_attr"..i]
                local value=equipment["item_value"..i]
                if(ret[attr]==nil)then
                    ret[attr]=0
                end
                ret[attr]=  ret[attr]+value
            end
        end

    end
    return ret
end


function CardPro.addTreasureUpgradeAttr(card,level,db)
    local upgradeDb= DB.getTreasureUpgrade(level,db.type)
    if(upgradeDb)then
        local rate= DB.getTreasureUpgradeAttrParam(db.quality)/100
        for i=1, 3 do
            local attr=upgradeDb["attr"..i]
            local value= upgradeDb["param"..i]*rate
            if(card["treasure_attr"][attr]==nil)then
                card["treasure_attr"][attr]=0
            end
            card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
        end
    end

end


function CardPro.addTreasureQuenchAttr(card,level,db)
    local quenchDb= DB.getTreasureQuench(level,db.type)

    if(quenchDb)then
        local rate= DB.getTreasureQuanchAttrParam(db.quality)/100
        for i=1, 3 do
            local attr=quenchDb["attr"..i]
            local value=quenchDb["param"..i]*rate
            if(card["treasure_attr"][attr]==nil)then
                card["treasure_attr"][attr]=0
            end
            card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
        end
    end

end

function CardPro.addTreasureStarAttr(card,treasure,treasureDb)

    local treasureStarAttr=CardPro.getTreasureStarAttr(treasure.itemid,treasure.starlv,treasure.starexp)
    for k,attrItem in pairs(treasureStarAttr) do
         if(card["treasure_attr"][attrItem.attr]==nil)then
            card["treasure_attr"][attrItem.attr]=0
        end
        card["treasure_attr"][attrItem.attr]=  card["treasure_attr"][attrItem.attr]+attrItem.value
    end

    local treasureStarBuffAttr = CardPro.getTreasureStarBuffAttr(treasure)
    for attr,value in pairs(treasureStarBuffAttr) do
         if(card["treasure_attr"][attr]==nil)then
            card["treasure_attr"][attr]=0
        end
        card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
    end

end


function CardPro.addTreasureSuitAttr(card,campMap,suitMap)
    for suitid,maxnum  in pairs(suitMap) do
        for num=2, maxnum do
            local suitDb=DB.getTreasureSuitByIdAndNum(suitid,num)
            if(suitDb)then
                for i=1, 3 do
                    local attr=suitDb["attr"..i]
                    local value=suitDb["param"..i]
                    if(card["treasure_attr"][attr]==nil)then
                        card["treasure_attr"][attr]=0
                    end
                    card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
                end
            end

            if(campMap[suitid])then
                local cardDb=DB.getCardById(card.cardid)
                local countrys=string.split(campMap[suitid],";")
                local effect=false
                for key, country in pairs(countrys) do
                    if(cardDb.country==toint(country))then
                        effect=true
                    end
                end

                if(effect)then
                    for i=1, 3 do
                        local attr=suitDb["attr"..i.."_camp"]
                        local value=suitDb["param"..i.."_camp"]
                        if(card["treasure_attr"][attr]==nil)then
                            card["treasure_attr"][attr]=0
                        end
                        card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
                    end
                end
            end
        end
    end
end

function CardPro.addTreasureBaseAttr(card,treasureDb)
    for i=1, 3 do
        local attr=treasureDb["attr"..i]
        local value=treasureDb["param"..i]
        if(card["treasure_attr"][attr]==nil)then
            card["treasure_attr"][attr]=0
        end
        card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
    end
end

function CardPro.addTreasureMaster(card,type,level)


    local attrData=DB.getTreasureUpdateMaster(type,level)
    if(attrData)then
        for i=1, 3 do
            local attr=attrData["attr"..i]
            local value=attrData["param"..i]
            if(card["treasure_attr"][attr]==nil)then
                card["treasure_attr"][attr]=0
            end
            card["treasure_attr"][attr]=  card["treasure_attr"][attr]+value
        end
    end
end


function CardPro.resetCardTreasure(card) 
    local treasures=Data.getTreasureByCardId(card.cardid)
    for pos=1, 4 do
        card["treasure"..pos]=0
    end
    
    for key, treasure in pairs(treasures) do
        card["treasure"..(treasure.db.type+1)]=treasure.id 
    end
end

function CardPro.addTreasureAttr(card)
 
    card["treasure_attr"]={}
    local suitMap={}
    local campMap={}
    local minUpdradeLevel=1000
    local minQuenchLevel=1000

    CardPro.resetCardTreasure(card) 
  

    for pos=1, 4 do
        local tresureid=  card["treasure"..pos]
        if(tresureid and tresureid~=0)then
            local treasure=Data.getTreasureById(tresureid)

            if(minUpdradeLevel>treasure.upgradeLevel)then
                minUpdradeLevel=treasure.upgradeLevel
            end


            if(minQuenchLevel>treasure.quenchLevel)then
                minQuenchLevel=treasure.quenchLevel
            end

            local treasureDb=DB.getTreasureById(treasure.itemid)

            if(treasureDb)then
                CardPro.addTreasureBaseAttr(card,treasureDb)
                CardPro.addTreasureUpgradeAttr(card,treasure.upgradeLevel,treasureDb)
                CardPro.addTreasureQuenchAttr(card,treasure.quenchLevel,treasureDb)
                CardPro.addTreasureStarAttr(card,treasure,treasureDb)

                if(suitMap[treasureDb.suitid]==nil)then
                    suitMap[treasureDb.suitid]=1
                else
                    suitMap[treasureDb.suitid]=suitMap[treasureDb.suitid]+1
                end

                if(treasureDb.campid~=0)then
                    campMap[treasureDb.suitid]=treasureDb.campid
                end
            end
        else
            minQuenchLevel=0
            minUpdradeLevel=0
        end

    end
    CardPro.addTreasureMaster(card,1,minQuenchLevel)
    CardPro.addTreasureMaster(card,0,minUpdradeLevel)

    CardPro.addTreasureSuitAttr(card,campMap,suitMap)

    if(card["treasure_attr"])then
        for attr, value in pairs(card["treasure_attr"]) do
            if(attr~=0)then
                CardPro.addOneAttr(  card,   attr,   value)
            end
        end
    end
end


function CardPro.setCardEquipAttr(  card,   level,  grade,  quality)
    local cardDb=DB.getCardById(card.cardid)
    if(cardDb==nil)then
        return
    end

    for i=0, 5 do
        local equipId=cardDb["equid"..i]
        local equ = DB.getEquipment(equipId, card.equipQuas[i])
        if(equ)then
            CardPro.setCardOneEquipAttr(card,equipId, card.equipLvs[i],card.equipQuas[i])
        end

        for j=1, 5 do
            if(CardPro.isEquipItemActivate(card.equipActives[i],j-1) )then
                local itemAttr = equ["item_attr"..j]
                local itemValue = equ["item_value"..j]
                if(itemAttr > 0)then
                    CardPro.addOneAttr(card, itemAttr, itemValue)
                end

            end
        end
    end


end



function CardPro.setCardOneEquipAttr(  card,  equipId,upgradeLevel,quality)
    local ret=CardPro.getCardEquipUpgradeAttr(   equipId,upgradeLevel,quality)
    for attr, value in pairs(ret) do
        CardPro.addOneAttr(card, attr, value)
    end

end


function CardPro.setCardSkillAttr(  card,   level,  grade,  quality)
    local cardDb=DB.getCardById(card.cardid)
    if(cardDb==nil)then
        return
    end

    for i=0, 4 do
        local skillid=cardDb["buffid"..i]
        if(CardPro.isSkillUnlock(card, i+2))then

            local skillLv= card.skillLvs[i+2]
            local level = skillLv - 1
            CardPro.addCardSkillAttr(card,skillid,level)
        end
    end

end

function CardPro.setCardAwakeAttr(  card,   level,  grade,  quality)
    local data=DB.getCardAwakeTable(card.cardid)
    if(data==nil)then
        return
    end
    for key,var in pairs(data) do
        if   var.waken <=card.awakeLv then
            CardPro.addCardSkillAttr(card,var.buffid0,1)
            CardPro.addCardSkillAttr(card,var.buffid1,1)
        end
    end

end


function CardPro.addHonorBuffAttr(card,skillid,level)
    local buff = DB.getBuffById(skillid)
    if (buff ~= nil) then
        if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR or
            buff.type == BUFFER_TYPE_ADD_ATTR) then
            -- 加属性的技能
            for i=0, 1 do
                --local value = math.rint(buff["attr_value"..i] + buff["attr_add_value"..i] * level)-- 技能加的属性值
                local value = buff["attr_value"..i] + buff["attr_add_value"..i] * level-- 技能加的属性值
                local attr = buff["attr_id"..i] -- 这个值表示心术加哪项属性
                if(attr>0)then
                    CardPro.addOneAttr(card, attr,value)
                end
            end
        end
    end
end

function CardPro.addHaloAttr(card)
    if (Data.getCurHalo()>0) then
        for j=1,Data.getCurHalo() do
            local buffid = Data.halo_buffid[j];
            if (buffid>0) then
                local buff = DB.getBuffById(buffid)
                if (buff ~= nil) then
                    if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR) then
                        -- 加属性的技能
                        for i=0, 1 do
                            --local value = math.rint(buff["attr_value"..i] + buff["attr_add_value"..i])-- 技能加的属性值
                            local value = buff["attr_value"..i] + buff["attr_add_value"..i]-- 技能加的属性值
                            local attr = buff["attr_id"..i] -- 这个值表示心术加哪项属性
                            if(attr>0)then
                                CardPro.addOneAttr(card, attr,value)
                            end
                        end
                    end
                end
            end

            local buffid2 = Data.halo_buffid2[j];
            if (buffid2>0) then
                local buff = DB.getBuffById(buffid2)
                if (buff ~= nil) then
                    if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR) then
                        -- 加属性的技能
                        for i=0, 1 do
                            --local value = math.rint(buff["attr_value"..i] + buff["attr_add_value"..i])-- 技能加的属性值
                            local value =buff["attr_value"..i] + buff["attr_add_value"..i]-- 技能加的属性值
                            local attr = buff["attr_id"..i] -- 这个值表示心术加哪项属性
                            if(attr>0)then
                                CardPro.addOneAttr(card, attr,value)
                            end
                        end
                    end
                end
            end
        end
    end
end

function CardPro.addCardSkillAttr(card,skillid,level)
    local buff = DB.getBuffById(skillid)
    if (buff ~= nil) then
        if (buff.type == BUFFER_TYPE_ADD_ATTR) then
            -- 加属性的技能
            for i=0, 1 do
                local value =  buff["attr_value"..i] + buff["attr_add_value"..i] * level -- 技能加的属性值
                local attr = buff["attr_id"..i] -- 这个值表示心术加哪项属性
                if(attr>0)then
                    CardPro.addOneAttr(card, attr,value)
                end
            end
        end
    end
end



function CardPro.countWeaponPower(card)

    local ret= math.rint(card["raise_physicalAttack"]+
        card["raise_physicalDefend"]*0.7+
        card["raise_magicDefend"]*0.7+
        card["raise_hp"]*0.15)
    return ret
end
function CardPro.countPower(newCard)
    local card=clone(newCard)
    --  攻 + 0.7* 物防 + 0.7 * 法防 + 气血 * 0.15 + 暴击 * 2.5 + 韧性 * 2.5 + 命中 * 2.5 + 闪避 * 2.5
    if(card==nil or card.physicalAttack==nil)then
        card.power= 0
        return
    end
    for key, var in pairs(CardPro.cardPros) do
        card[var ]=math.rint( card[var ])
    end

    local cardDb = DB.getCardById(card.cardid)
    if(cardDb==nil)then
        return
    end

    local skillPower=0
    local ret=0
    for i=0, 6 do
        if(CardPro.isSkillUnlock(card, i))then
            if(i<=1)then
                local data=  DB.getSkillById(cardDb["skillid"..i])
                if(data)then
                    skillPower=skillPower+ data.power+data.power_add*(card.skillLvs[i]-1)
                end
            else
                local data=  DB.getBuffById(cardDb["buffid"..(i-2)])
                if(data)then
                    skillPower=skillPower+ data.power+ data.power_add*(card.skillLvs[i]-1)
                end
            end
        end
    end
    
    local talentBuffPower=0
    if card.pid and card.pid>0 then
        local pet = Data.getUserPetById(card.pid)
        for i=1,8 do
            local stid=pet["stid"..i]
            if stid>0 then
                local stidDB = DB.getSpecialTalentById(stid)
                for j=1,2 do
                    local bufid = stidDB["bufid"..j]
                    if (bufid>0) then
                        local buff = DB.getBuffById(bufid)
                        if buff then
                            talentBuffPower = talentBuffPower + buff.power
                        end
                    end
                end
            end
        end
    end
    ret=ret+talentBuffPower

    local raiseDatas=DB.getRaiseByCardid(card.cardid)
    if(raiseDatas)then
        for key, var in pairs(raiseDatas) do
            if(  card.weaponLv>=var.level and var.buffid~=0 )then
                local buff = DB.getBuffById(var.buffid)
                if (buff ~= nil) then
                    ret=ret+buff.power
                end
            end
        end
    end

    ret=ret+skillPower


    local power1=math.rint( card.physicalAttack)+
        math.rint(card.physicalDefend*0.7)+
        math.rint(card.magicDefend*0.7)+
        math.rint(card.hp*0.15)+
        math.rint(card.critical*2.5)+
        math.rint(card.toughness*2.5)+
        math.rint(card.hit*2.5)+
        math.rint(card.dodge*2.5)
    ret=ret+power1

    local power2=math.rint(card.physicalAttack*0.6*(card.criticalRate+card.hitRate+card.powerRaisePercent)*0.01)
    ret=ret+power2

    local hhh =  100/(100+card.hurtDownPercent);

 
    local a=(card.toughnessRate+card.dodgeRate)/100
    local power3  =math.rint(card.hp*0.15*(a+1/hhh-1));
    ret=ret+power3




    newCard.power= math.rint(ret)
    return  newCard.power
end


function CardPro.setCardHonorAttr(  card,   honor)
    local honor=honor_db[honor]
    if(honor)then
        CardPro.addHonorBuffAttr(card,honor.buffid0,0)
        CardPro.addHonorBuffAttr(card,honor.buffid1,0)
    end
end

function CardPro.setCardAttr(  card,hide,oldCard)
    local level=card.level
    local grade=card.grade
    local quality=card.quality

    if(hide==nil)then
        if(oldCard==nil)then
            oldCard=clone(card)
        end
    end
     
     
    
    CardPro.setCardBaseAttr(  card,   level,  grade,  quality)
    CardPro.setCardEquipAttr(  card,   level,  grade,  quality)
    CardPro.saveCardBaseAttr(card)


    CardPro.setCardSkillAttr(  card,   level,  grade,  quality)
    CardPro.setWeaponBuffAttr(  card,   level,  grade,  quality)
    CardPro.setCardAwakeAttr(  card,   level,  grade,  quality)
    CardPro.getCardRaiseAttr(card)
    CardPro.setCardRelationAttr(  card,   level,  grade,  quality)


    CardPro.setPetAttr(  card,   level,  grade,  quality)
    CardPro.setPossPetAttr(  card,   level,  grade,  quality)

    CardPro.setPetRelationAttr(  card,   level,  grade,  quality)
    CardPro.setFamilyBuffAttr(  card,   level,  grade,  quality)
    CardPro.addTreasureAttr(card)
    CardPro.addHaloAttr(card)
    CardPro.clearCardAttrPercent(card)
    CardPro.countCardAttrPercent(card)


    if(hide==nil)then
        local ret=  CardPro.compairAttr(  card,oldCard)
        AttChange.pushAtt(PANEL_CARD_INFO,ret)
        local oldPower=CardPro.countPower(oldCard)
        local newPower=CardPro.countPower(card)
        AttChange.pushPower(PANEL_CARD_INFO, oldPower,newPower)
    else
        CardPro.countPower(card)
    end
    gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    RedPoint.bolCardDataDirty=true
end


function CardPro.isPkFormation(type)
    if(type==TEAM_TYPE_WORLD_WAR_ATTACK or
        type==TEAM_TYPE_WORLD_WAR_DEFEND or
        type==TEAM_TYPE_ARENA_ATTACK or
        type==TEAM_TYPE_BUDDY_FIGHT or
        type==TEAM_TYPE_ARENA_DEFEND or
        type==TEAM_TYPE_DRINK_LOOT or
        type==TEAM_TYPE_BATH_MOLEST or
        type==TEAM_TYPE_FAMILY_FIGHT or

        type==TEAM_TYPE_FAMILY_WAR or
        type== TEAM_TYPE_LOOT_FOOD or
        type== TEAM_TYPE_LOOT_FOOD_REVENGE )then
        return true
    end



    return false
end

function CardPro.getFormationCountry(formation)
    local country={}
    local supercard=0
    for key, var in pairs(formation) do
        local card=DB.getCardById(var)
        if(card)then
            if(country[card.country]==nil)then
                country[card.country]=0
            end
            country[card.country]=country[card.country]+1

            if(card.supercard==1)then
                supercard=supercard+1
            end
        end


    end

    ret=0
    if(supercard>=3)then
        ret=30
    end

    if(ret==0)then
        for key, var in pairs(country) do
            if(var>=4)then
                ret=key
                break
            end
        end

    end


    if(ret==0)then
        for key, var in pairs(country) do
            if(var>=3)then
                ret=13
                break
            end
        end
    end
    return ret
end

function CardPro.getTreasureStarBuffAttr(treasure)
    local starBuffAttrValue = {}
    for i=1,6 do
        local treasureStarBuffDB= DB.getTreasureStarBuff(treasure.buffList[i].sid,treasure.buffList[i].slv)
        local budffdb = DB.getBuffById(treasure.buffList[i].sid)
        if treasureStarBuffDB then
            if starBuffAttrValue[budffdb.attr_id0]==nil then
                starBuffAttrValue[budffdb.attr_id0]=0
            end
           starBuffAttrValue[budffdb.attr_id0] = budffdb.attr_value0+budffdb.attr_add_value0*(treasureStarBuffDB.valuelevel-1)
        end
    end
    return starBuffAttrValue
end

function CardPro.getTreasureStarAttr(itemid,starlv,starexp)
    local starAttrValue = {{attr=0,value=0},{attr=0,value=0}}
    local starExpAttrValue = {{attr=0,value=0},{attr=0,value=0}}
    for i=1,starlv do
        local levelData=DB.getTreasureStar(itemid,i)
        if(levelData)then
            local tmpAttrlist = {}
            for j=1, 2 do
                local attr=levelData["attr"..j]
                local value=levelData["value"..j]
                if starAttrValue[j]==nil then
                    starAttrValue[j]={attr=attr,value=0}
                end
                starAttrValue[j].value=starAttrValue[j].value+value
                starAttrValue[j].attr=attr
                tmpAttrlist[attr]=j
            end
            local extra_attr = levelData["extra_attr"]
            local extra_value = levelData["extra_value"]
            local addExtra = false
            if tmpAttrlist[extra_attr] ~=nil then
                local k = tmpAttrlist[extra_attr]
                starAttrValue[k].value=starAttrValue[k].value+extra_value
                addExtra= true
            end
            if addExtra==false then
               table.insert(starAttrValue,{attr=extra_attr,value=extra_value})
            end
        end
    end
    if starexp and starexp~=0 then
        local levelData=DB.getTreasureStar(itemid,starlv+1)
        if(levelData)then
            for i=1, 2 do
                local attr=levelData["attr"..i]
                local value=levelData["value"..i]
                if starAttrValue[i]==nil then
                    starAttrValue[i]={attr=attr,value=0}
                end
                if starExpAttrValue[i]==nil then
                    starExpAttrValue[i]={attr=attr,value=0}
                end
                starAttrValue[i].attr=attr
                starExpAttrValue[i].attr=attr
                starExpAttrValue[i].value=starExpAttrValue[i].value+ starexp*value/levelData.exp
                starAttrValue[i].value=starAttrValue[i].value+ starexp*value/levelData.exp
            end
        end
    end
    return starAttrValue,starExpAttrValue
end


function CardPro.setTeamCountryBuffAttr(  cards,formation)
    local country=CardPro.getFormationCountry(formation)
    if(country==0)then
        return
    end
    local country= DB.getCountryId(country)
    local temp=string.split(country.bufflist,";")
    for key, card in pairs(cards) do
        for key, buffid in pairs(temp) do
            local buff = DB.getBuffById(toint(buffid))
            if (buff ~= nil) then
                local level = 1
                if (buff.type == BUFFER_TYPE_ADD_TEAM_ATTR) then-- 加属性的技能
                    local attr = buff.attr_id0 -- 这个值表示心术加哪项属性
                    if(attr>0)then
                        --local value = math.rint(buff.attr_value0 + buff.attr_add_value0 * level) -- 技能加的属性值
                        local value = buff.attr_value0 + buff.attr_add_value0 * level -- 技能加的属性值
                        CardPro.addOneAttr(card, attr,value)
                    end
                end
            end
        end
    end
end

function CardPro.addMiningAtlasAttr(cards)
    local buffIds = DB.getMineDrawLotsBuffIds(gDigMine.drawLotsIdx)
    if nil ~= buffIds then
        for _, buffId in pairs(buffIds) do
            local buff = DB.getBuffById(buffId)
            if nil ~= buff then
                CardPro.addTeamOneAttr(cards,buff.attr_id0,buff.attr_value0,buff.target_range)
                if buff.attr_id1 ~= 0 then
                    CardPro.addTeamOneAttr(cards,buff.attr_id1,buff.attr_value1,buff.target_range)
                end
            end
        end
    end
end

function CardPro.addConstellationAttr(cards)
    if Unlock.isUnlock(SYS_CONSTELLATION,false) == false then
        return
    end
    --已激活星宿组加成
    local size = DB.getConstellationCircleCount()
    local activedCircle = gConstellation.getActivedMagicCircle()
    for i = 1, size do
        if i <= activedCircle then
            local groupInfos = gConstellation.getActivedGroupInfos(i)
            for j,value in pairs(groupInfos) do

                local groupInfo = DB.getConstellationGroupInfo(j)
                if groupInfo.attr > 0 and groupInfo.param > 0 then
                    CardPro.addTeamOneAttr(cards, groupInfo.attr, groupInfo.param,SKILL_RANGE_ALL)
                end
            end
        end
    end

    --升星星宿组加成
    local size = DB.getConstellationCircleCount()
    local activedCircle = gConstellation.getActivedMagicCircle()
    for i = 1, size do
        if i <= activedCircle then
            local groupInfos = gConstellation.getActivedGroupInfos(i)
            for j,value in pairs(groupInfos) do
                local starlv =gConstellation.getStarNumByGroupMap(i, j)
                if starlv>0 then
                    local groupStarInfo = DB.getCircleGroupStar(j,starlv)
                    if groupStarInfo then
                        for i=1,3 do
                            local attrtype = groupStarInfo["attr"..i]
                            if attrtype and attrtype>0 then
                                CardPro.addTeamOneAttr(cards, attrtype, groupStarInfo["param"..i],SKILL_RANGE_ALL)
                            end
                        end
                    end
                end
            end
        end
    end

    --已选择法阵附加属性加成
    for i = 1, size do
        local activedGroupNum = gConstellation.getActivedGroupNum(i)
        for j = 1, 3 do
            local extraInfo = DB.getConstellationCircleExtraInfo(i, j)
            if extraInfo.unlocknum <= activedGroupNum  then
                local buff = DB.getBuffById(extraInfo.bufid)
                if nil ~= buff then
                    CardPro.addTeamOneAttr(cards,buff.attr_id0,buff.attr_value0,buff.target_range)
                    if buff.attr_id1 ~= 0 then
                        CardPro.addTeamOneAttr(cards,buff.attr_id1,buff.attr_value1,buff.target_range)
                    end 
                end
            end
        end
    end

    -- 所有激活成就的属性加成
    local activedAchieveId = gConstellation.getActivedAchieveId()
    for i = 1, activedAchieveId do
        local achieveInfo = DB.getConstellationAchieveInfo(i)
        CardPro.addTeamOneAttr(cards, achieveInfo.attr1, achieveInfo.param1, SKILL_RANGE_ALL)
    end
end


function CardPro.countFormation(formation,type)
    local power=0
    local cards={}
    local petid=formation[PET_POS]
    local formation=formation
    local pkformation=CardPro.isPkFormation(type)
    for key, cardid in pairs(formation) do
        if(key<PET_POS)then
            local card=  clone(Data.getUserCardById(cardid)) --clone 出来
            if(card)then
                CardPro.addTeamSpiritAttr(card,key)
                cards[key]=card


                if(pkformation==false and gUserInfo.honor and gUserInfo.honor>0)then
                    CardPro.setCardHonorAttr(  card,   gUserInfo.honor )
                end
            end
        end
    end

    CardPro.addTeamBuffAttr( cards)
    if(petid and petid~=0)then
        CardPro.addTeamPetAttr( petid,cards,pkformation )
    end
    CardPro.setTeamFamilyBuffAttr( cards);
    CardPro.setTeamWeaponBuffAttr( cards)
    CardPro.setTeamCountryBuffAttr(cards,formation)
    -- 策划说临时属性不需要加到战力计算里面
    -- if type==TEAM_TYPE_ATLAS_MINING then
    --     CardPro.addMiningAtlasAttr(cards)
    -- end
    -- 星宿系统属性加成
    CardPro.addConstellationAttr(cards)

    for key, card in pairs(cards) do
        CardPro.countCardAttrPercent(card)
        CardPro.countPower(card)
       -- CardPro.printAttr(card)
        power=power+card.power
    end
    return power
end

function CardPro.printAttr(card)
    for key, var in pairs(CardPro.cardPros) do
        print(var.."="..card[var])
    end

end


