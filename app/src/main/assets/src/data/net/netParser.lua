
--------------更新属性，物品-----------------------

function Net.updateItemReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= Data.getUserItemById(param:getInt("itid"))
    if(item)then
        item.num=param:getInt("num")
    else
        item={}
        item.itemid=param:getInt("itid")
        item.num=param:getInt("num")
        if Data.isMineItem(item.itemid) then
            table.insert(gDigMine.userMineItems, item )
        else
            table.insert(gUserItems,item)
        end
    end



end


function Net.updateMmBuyList(param)

    if(param:containsKey("mmbuylist"))then 
        Data.mmbuylist={}
        local mmbuylist=param:getArray("mmbuylist")
        mmbuylist=tolua.cast(mmbuylist,"MediaArray")
        if(mmbuylist)then
            for i=0, mmbuylist:count()-1 do
                local obj= mmbuylist:getObj(i)
                param=tolua.cast(obj,"MediaObj")
                local item={}
                item.itemid=param:getInt("itemid")
                item.num=param:getInt("num")
                table.insert(Data.mmbuylist,item)
            end
        end

    end
end

function Net.updateActObj(actObj)

    local buyHpObj= actObj:getObj("buyhp")
    if(buyHpObj)then
        Data.activityBuyEnergySaleoff.time=buyHpObj:getInt("time")
        Data.activityBuyEnergySaleoff.val=buyHpObj:getInt("val")
    end

    local shopObj= actObj:getObj("shop")
    if(shopObj)then
        Data.activityShopLimitSaleoff.time=shopObj:getInt("time")
        Data.activityShopLimitSaleoff.val=shopObj:getInt("val")
        Data.activityShopLimitSaleoff.val2=shopObj:getInt("val1")
    end

    local conshopObj= actObj:getObj("conshop")
    if(conshopObj)then
        Data.activityConShopLimitSaleoff.time=conshopObj:getInt("time")
        Data.activityConShopLimitSaleoff.val=conshopObj:getInt("val")
        Data.activityConShopLimitSaleoff.val2=conshopObj:getInt("val1")
    end

    local atlasObj = actObj:getObj("stagebuy")
    if(atlasObj)then
        Data.activityAtlasSaleoff.time=atlasObj:getInt("time")
        Data.activityAtlasSaleoff.val=atlasObj:getInt("val")
    end

    local soullifeObj = actObj:getObj("spirit")
    if(nil ~= soullifeObj)then
        Data.activeSoullifeSaleoff.time=soullifeObj:getInt("time")
        Data.activeSoullifeSaleoff.val=soullifeObj:getInt("val")
    end
end


function Net.updateParamClient(objs)

    objs=tolua.cast(objs,"MediaArray")
    if(objs)then
        for i=0, objs:count()-1 do
            local obj= objs:getObj(i)
            obj=tolua.cast(obj,"MediaObj")
            local name=obj:getString("name")
            local value=obj:getString("value")

            for key, var in pairs(params_client_db) do
                if(var.name==name)then
                    var.value=parseDBNumType(value)
                end
            end

        end
    end

end


function Net.updatePetReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end
    local pet=Net.parseUserPet(param)
    Data.updateUserPet(pet)



end



function Net.updateEquipItemReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= Data.getEquipItem(param:getInt("itid"))
    if(item)then
        item.num=param:getInt("num")
    else
        item={}
        item.itemid=param:getInt("itid")
        item.num=param:getInt("num")
        table.insert(gUserEquipItems,item)
    end

end
function Net.updateSoulsReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= Data.getSouls(param:getInt("cid"))
    if(item)then
        item.num=param:getInt("num")
        item.bbnum=param:getInt("bbnum")
        item.needRefresh = true;
    else
        item={}
        item.itemid=param:getInt("cid")
        item.num=param:getInt("num")
        item.bbnum=param:getInt("bbnum")
        item.needRefresh = true;
        table.insert(gUserSouls,item)
    end


end

function Net.updatePetSoulsReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= Data.getPetSouls(param:getInt("pid"))
    if(item)then
        item.num=param:getInt("num")
    else
        item={}
        item.itemid=param:getInt("pid")
        item.num=param:getInt("num")
        table.insert(gUserPetSouls,item)
    end


end



function Net.updateTreasureSharedReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= Data.getTreasureShared(param:getLong("id"))
    if(item)then
        item.num=param:getInt("num")
        Data.reduceTreasureSharedNum(item.itemid,0)
    else
        item=Net.parseTreasureShared(param)
        table.insert(gUserTreasureShared,item)
    end

end


function Net.updateTreasureReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end
    local  treasureId= param:getLong("id")
    if param:containsKey("del") and param:getBool("del") == true then
        Data.removeTreasureById(treasureId)
        return;
    end
    local item= Data.getTreasureById(treasureId)
    if(item)then
        item.num=param:getInt("num")
    else
        item=Net.parseTreasureItem(param)
        table.insert(gUserTreasure,item)
    end

end


function Net.updateSharedReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= Data.getShared(param:getInt("shid"))
    if(item)then
        item.num=param:getInt("num")
    else
        item={}
        item.itemid=param:getInt("shid")
        item.num=param:getInt("num")
        table.insert(gUserShared,item)
    end

end




function Net.updateTCardReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local card= Data.getUserCardById(param:getInt("id"))
    if(card)then
        card.exp=param:getInt("exp")
        if(param:containsKey("lv"))then
            card.level=param:getShort("lv")
            card.needRefresh = true;
            CardPro.setCardAttr(card)
        end
    end
end


function Net.updateCardReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end
    table.insert(gUserCards, Net.parseUserCard(param))
end

--showGetItemsType=0 不提示
--showGetItemsType=1 面板提示
--showGetItemsType=2 飘提示
function Net.updateReward(param,showGetItemsType)
    if(param==nil)then
        return
    end
    local userCards=param:getArray("tcard")
    userCards=tolua.cast(userCards,"MediaArray")
    if(userCards)then
        for i=0, userCards:count()-1 do
            Net.updateTCardReward( userCards:getObj(i))
        end
    end



    local userCards=param:getArray("card")
    userCards=tolua.cast(userCards,"MediaArray")
    if(userCards)then
        for i=0, userCards:count()-1 do
            Net.updateCardReward( userCards:getObj(i))
        end
    end


    local userItems=param:getArray("item")
    userItems=tolua.cast(userItems,"MediaArray")
    if(userItems)then
        for i=0, userItems:count()-1 do
            Net.updateItemReward( userItems:getObj(i))
        end
    end

    local equipItems=param:getArray("equ")
    equipItems=tolua.cast(equipItems,"MediaArray")
    if(equipItems)then
        for i=0, equipItems:count()-1 do
            Net.updateEquipItemReward( equipItems:getObj(i))
        end
    end


    local shared=param:getArray("eshard")
    shared=tolua.cast(shared,"MediaArray")
    if(shared)then
        for i=0, shared:count()-1 do
            Net.updateSharedReward( shared:getObj(i))
        end
    end
    local treasure=param:getArray("treasure")
    treasure=tolua.cast(treasure,"MediaArray")
    if(treasure)then
        for i=0, treasure:count()-1 do
            Net.updateTreasureReward( treasure:getObj(i))
        end
    end



    shared=param:getArray("tshard")
    shared=tolua.cast(shared,"MediaArray")
    if(shared)then
        for i=0, shared:count()-1 do
            Net.updateTreasureSharedReward( shared:getObj(i))
        end
    end

    local pets=param:getArray("pet")
    pets=tolua.cast(pets,"MediaArray")
    if(pets)then
        for i=0, pets:count()-1 do
            Net.updatePetReward( pets:getObj(i))
        end
    end





    local userSouls=param:getArray("soul")
    if(userSouls)then
        userSouls=tolua.cast(userSouls,"MediaArray")
        for i=0, userSouls:count()-1 do
            Net.updateSoulsReward(userSouls:getObj(i))
        end
    end

    local petSould=param:getArray("psoul")
    if(petSould)then
        petSould=tolua.cast(petSould,"MediaArray")
        for i=0, petSould:count()-1 do
            Net.updatePetSoulsReward(petSould:getObj(i))
        end
    end

    local constellationItems=param:getArray("constellation")
    if(constellationItems)then
        constellationItems=tolua.cast(constellationItems,"MediaArray")
        local count = constellationItems:count()-1
        for i=0, count do
            Net.updateConstellationItemReward(constellationItems:getObj(i))
        end
        if count >= 0 then
            gConstellation.updateGroupCanBeActive()
        end
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    end


    if(param:containsKey("uvobj"))then
        local data = param:getObj("uvobj")
        -- local dia = data:getInt("dia")
        -- if gUserInfo.diamond ~= nil then
        --     if (dia > gUserInfo.diamond) then
        --         local num = dia - gUserInfo.diamond
        --         local td_param = {}
        --         td_param['num'] = tostring(num)
        --         gLogEvent("reward_dia", td_param)
        --     end
        -- end
        Net.parseUserInfo(data)
    end

    --帮派贡献(个人货币)
    if(param:containsKey("fexp"))then
        local fexp = param:getInt("fexp");
        -- print("fexp = "..fexp);
        Data.updateCurFamilyExp(fexp);
    end
    --矿镐点数
    if(param:containsKey("mp"))then
        gDigMine.mpt  = param:getInt("mp")
    end

    --情义值
    if(param:containsKey("emoney"))then
        Data.emoney = param:getInt("emoney")
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    end

    --星宿值
    if(param:containsKey("constellationscore"))then
        gConstellation.setNum(param:getInt("constellationscore"))
    end
    --星魂
    if(param:containsKey("constellationsoul"))then
        gConstellation.setSoulNum(param:getInt("constellationsoul"))
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    end
    --命魂碎片
    if(param:containsKey("fra"))then
        SpiritInfo.setFraCount(param:getInt("fra"))
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    end
    --命魂经验
    if(param:containsKey("spiritexp"))then
        SpiritInfo.exp = param:getInt("spiritexp")
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    end

    local ret={}
    ret.items={}
    local listArray=param:getArray("list")
    listArray=tolua.cast(listArray,"MediaArray")
    if(listArray)then
        for i=0, listArray:count()-1 do
            local listObj=tolua.cast(listArray:getObj(i),"MediaObj")
            local needShow=true
            if(listObj:getInt("id")==OPEN_BOX_GOLD  )then
                ret.gold=listObj:getInt("num")
            elseif(listObj:getInt("id")==OPEN_BOX_EXP  )then
                ret.exp=listObj:getInt("num")
                needShow=true
            elseif(listObj:getInt("id")==OPEN_BOX_CARDEXP  )then
                ret.cardExp=listObj:getInt("num")
                needShow=false
            elseif(listObj:getInt("id")==OPEN_BOX_CARDEXP_ITEM) then
                ret.cardExpItem=listObj:getInt("num")
                needShow=true
            elseif(listObj:getInt("id")==OPEN_BOX_SKILLPOINT) then
                ret.skillPoint=listObj:getInt("num")
                needShow=true
            elseif(listObj:getInt("id")==OPEN_BOX_FAMILY_DEVOTE) then
                -- ret.fexp=listObj:getInt("fexp")
                needShow=true
            elseif(listObj:getInt("id")==OPEN_BOX_VIP_SCORE) then
                needShow=true
            elseif(listObj:getInt("id")==OPEN_BOX_EMOTION_MONEY) then
                needShow=true
            elseif(math.floor(listObj:getInt("id") / 10000) == SPIRIT_SPIRIT_TYPE ) then
                needShow=true
            end

            if(needShow)then
                local item={}
                item.id=listObj:getInt("id")
                item.num=listObj:getInt("num")
                table.insert( ret.items,item)
            end
        end
        if showGetItemsType == nil and table.getn(ret.items) > 0 then
            showGetItemsType = 1;
        end

        if showGetItemsType == 1 then
            Panel.popUpVisible(PANEL_GET_REWARD,ret);
        elseif showGetItemsType == 2 then
            gShowItemPoolLayer:pushItems(ret.items);
        end
    end
    Data.checkNum()

    RedPoint.bolCardDataDirty=true
    RedPoint.bolCardViewDirty=true

    if table.getn(ret.items) > 0 then
        gLogItemListBI('update_reward',ret.items)
    end
    
    return ret
end





function Net.parseUserItem(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.itemid=data:getInt("itid")
    item.num=data:getInt("num")

    return item
end

function Net.parseEquipItem(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.itemid=data:getInt("itid")
    item.num=data:getInt("num")

    return item

end

function Net.parseTreasureItem(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.itemid=data:getInt("tid")
    item.cardid=data:getInt("cid")
    item.upgradeLevel=data:getInt("ulv")
    item.decomposeGold=data:getInt("gold")
    item.quenchLevel=data:getInt("qlv")
    item.quenchExp=data:getInt("qexp")
    item.starlv=data:getInt("star")
    item.starexp=data:getInt("starexp")
    item.starpoint=data:getInt("starpoint")
    item.buffList = {}
    local buffArrays=data:getArray("bufflist")
    if(buffArrays)then
        buffArrays=tolua.cast(buffArrays,"MediaArray")
        for i=0, buffArrays:count()-1 do
            local  obj=tolua.cast(buffArrays:getObj(i),"MediaObj")
            table.insert(item.buffList,{sid=obj:getInt("sid"),slv=obj:getInt("slv")})
        end
    end
    item.db=DB.getTreasureById(item.itemid)
    Net.sortTreasure(item)
    return item

end

function Net.sortTreasure(item)
    item.sort=0
    if(item.db)then
        item.sort=item.db.quality*10000000+item.itemid%1000+(item.upgradeLevel+item.quenchLevel)*1000
    end
end


function Net.parseTreasureShared(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.itemid=data:getInt("tid")
    item.num=data:getInt("num")
    item.db=DB.getTreasureById(item.itemid)
    item.sort=0
    if(item.db)then
        item.sort=item.db.quality*1000000+item.itemid
    end
    return item

end


function Net.parseUserShared(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.itemid=data:getInt("shid")
    item.num=data:getInt("num")

    return item
end


function Net.parseUserSouls(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.itemid=data:getInt("cid")
    item.id=data:getLong("id")
    item.num=data:getInt("num")
    item.bbnum=data:getInt("bbnum")
    item.needRefresh = true;
    return item
end

function Net.parsePetSouls(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.itemid=data:getInt("pid")
    item.id=data:getLong("id")
    item.num=data:getInt("num")

    return item
end

function Net.updatePetShopInfo(array)
    if(array)then
        -- local pets=param:getArray("pet")
        local petShopBuyInfo =tolua.cast(array,"MediaArray")
        if(petShopBuyInfo)then
            for i=0, petShopBuyInfo:count()-1 do
                Net.updatePetShopBuyInfo( petShopBuyInfo:getObj(i))
            end
        end
    end
end

function Net.updatePetShopBuyInfo(obj)
    if(obj)then
        local  data=tolua.cast(obj,"MediaObj")
        local id = data:getInt("sid");
        local num = data:getInt("num");
        for key,item in pairs(gShops[SHOP_TYPE_PET].items)do
            if(item.pos == id)then
                item.buyNum = num;
                break;
            end
        end
    end
end

function Net.parseArenaRank(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.level=data:getInt("lv")
    item.rank=data:getInt("rk")+1
    item.price=data:getInt("price")
    item.name=data:getString("name")
    item.cid=data:getInt("cid")
    item.fight=data:getInt("fight")
    item.vip=data:getByte("vip")
    item.fname = nil;
    if data:containsKey("fname") then
        item.fname = data:getString("fname")
    end
    return item
end

function Net.parseFamilyRank(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.level=data:getShort("level")
    item.name=data:getString("name")
    item.cid=data:getInt("icon")
    item.exp=data:getInt("allexp")
    item.fname = nil;
    if data:containsKey("mastername") then
        item.fname = data:getString("mastername")
    end
    return item
end

function Net.parseRankPet(data)
    local data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("userid")
    item.name=data:getString("username")
    item.level=data:getShort("level")
    item.vip=data:getByte("vip")
    item.cid=data:getInt("icon")
    item.mapid=data:getInt("mapid")
    item.fname = nil;
    if data:containsKey("fname") then
        item.fname = data:getString("fname")
    end
    return item
end

function Net.parseRankWorldBoss(data)
    local data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("userid")
    item.name=data:getString("username")
    item.level=data:getShort("level")
    item.vip=data:getByte("vip")
    item.cid=data:getInt("icon")
    item.price=data:getInt("price")
    item.fname = nil;
    if data:containsKey("fname") then
        item.fname = data:getString("fname")
    end
    return item
end

function Net.parseRankPetCave(data)
    local data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("userid")
    item.name=data:getString("username")
    item.level=data:getShort("level")
    item.vip=data:getByte("vip")
    item.cid=data:getInt("icon")
    item.price=data:getInt("price")
    item.fname = nil;
    if data:containsKey("fname") then
        item.fname = data:getString("fname")
    end
    return item
end

function Net.parseRankTower(data)
    local data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("userid")
    item.name=data:getString("username")
    item.level=data:getShort("level")
    item.vip=data:getByte("vip")
    item.cid=data:getInt("icon")
    item.maxstar=data:getInt("maxstar")
    item.fname = nil;
    if data:containsKey("fname") then
        item.fname = data:getString("fname")
    end
    return item
end

function Net.parseRankLevel(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.name=data:getString("username")
    item.level=data:getShort("level")
    item.vip=data:getByte("vip")
    item.cid=data:getInt("icon")
    item.fname = nil;
    if data:containsKey("fname") then
        item.fname = data:getString("fname")
    end
    return item
end

function Net.parseArenaCard(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.cardid=data:getInt("id")
    item.grade=data:getInt("gd")
    item.quality=data:getInt("wk")
    item.level=data:getInt("lv")
    return item
end


function Net.parseFriendCard(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.cardid=data:getInt("cardid")
    item.grade=data:getByte("grade")
    return item
end



function Net.parseArenaRecord(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.level=data:getInt("lv")
    item.rank=data:getInt("rk")
    item.name=data:getString("name")
    item.cid=data:getInt("cid")
    item.state=data:getByte("state")
    item.win=data:getByte("win")
    item.recid=data:getLong("recid")
    item.vid=data:getLong("vid")
    item.time=data:getInt("time")
    item.pw=data:getInt("pw")
    item.atk=data:getBool("atk")
    return item
end

function Net.parseArenaEnemy(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.level=data:getInt("lv")
    item.rank=data:getInt("rk")
    item.price=data:getInt("price")
    item.name=data:getString("name")
    item.cid=data:getInt("cid")
    item.show=Net.parserShowInfo(data:getObj("idetail"));
    return item
end

function Net.parseRelationItem(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getInt("rid")
    item.level=data:getByte("lv")
    return item
end


function Net.parseUserTeam(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.type=data:getByte("type")
    item.petid=data:getInt("petid")
    item.card={}
    local cardArrays=data:getIntArray("card")
    if(cardArrays)then
        for i=0, cardArrays:size()-1 do
            table.insert( item.card,i,cardArrays[i])
        end
    end
    item.card[PET_POS]=item.petid
    return item
end


function Net.parseAtlasCard(data,i)
    local  data=tolua.cast(data,"MediaObj")
    if(data==nil)then
        return nil
    end
    local playerCard=PlayerCard.new()
    playerCard.cardid=data:getInt("cid")
    local cardDb=DB.getCardById(playerCard.cardid)
    playerCard.country=cardDb.country
    --[[ obj.putInt("lv", level)
    obj.putByte("gd", grade)
    obj.putByte("wk", wakeup)
    obj.putInt("rage", maxRage)
    ]]
    local attrArrays=data:getIntArray("attr")
    if(attrArrays)then
        playerCard.hp =attrArrays[0]
        playerCard.physicalAttack = attrArrays[1]
        playerCard.magicAttack =attrArrays[2]
        playerCard.agility =attrArrays[3]
        playerCard.physicalDefend =attrArrays[4]
        playerCard.magicDefend =attrArrays[5]
        playerCard.hit =  attrArrays[6]
        playerCard.dodge =attrArrays[7]
        playerCard.critical =attrArrays[8]
        playerCard.toughness =attrArrays[9]
        playerCard.hitRate =attrArrays[10]
        playerCard.dodgeRate =attrArrays[11]
        playerCard.criticalRate =attrArrays[12]
        playerCard.toughnessRate =attrArrays[13]
        playerCard.hurtDownPercent =attrArrays[14]
        playerCard.powerRaisePercent =attrArrays[15]
        playerCard.skillDamagePercent =attrArrays[16]
        playerCard.resistHarmfulRate =attrArrays[17]
        playerCard.recoveryAddPercent =attrArrays[18]
        playerCard.resistDamage =attrArrays[19]



    end
    playerCard.price=data:getInt("pr")
    playerCard.weaponLv=data:getInt("wlv")
    playerCard.awakeLv=data:getByte("wkn")
    playerCard.maxRage =data:getInt("maxRage")
    playerCard.rage = data:getInt("rage")
    playerCard.quality = data:getByte("qlt")

    if(data:containsKey("round"))then
        playerCard.escapeRound= data:getInt("round")
    end

    local skillArrays=data:getIntArray("sklist")
    local skillLvArrays=data:getIntArray("sklvlist")
    if(skillArrays and skillLvArrays)then
        for i=0, skillArrays:size()-1 do
            CardPro.addSkillAttr(i, playerCard, skillArrays[i],skillLvArrays[i])
        end
    end

    local buffArrays=data:getArray("bufflist")
    if(buffArrays and buffArrays)then
        buffArrays=tolua.cast(buffArrays,"MediaArray")
        for i=0, buffArrays:count()-1 do
            local  obj=tolua.cast(buffArrays:getObj(i),"MediaObj")
            CardPro.addBuffAttr(i, playerCard, obj:getInt("bid"),obj:getInt("blv"))
        end
    end



    playerCard:countPercent()
    playerCard:setHpInit()
    playerCard.pos=i

    return playerCard
end


function Net.parseAtlasData(obj)
    local enemyFormations={}
    local formationObj=obj:getObj("pobj")
    local curFormation=Net.parseAtlasFormation(formationObj)
    local country=obj:getInt("country")
    local pet=nil
    if(formationObj:containsKey("pet"))then
        pet= Net.parseUserPet(formationObj:getObj("pet"))
    end

    local monsterList=obj:getArray("mlist")
    if(monsterList)then
        monsterList=tolua.cast(monsterList,"MediaArray")
        for i=0, monsterList:count()-1 do
            table.insert(enemyFormations,Net.parseAtlasEnemyFormation(monsterList:getObj(i)))
        end
    end
    local power=obj:getInt("stagepower")
    local power1=obj:getInt("teampower")
    local powerRate=DB.getPowerDiffRate(power1,power)
    return curFormation ,pet,enemyFormations,country,powerRate
end

function Net.parseAtlasFormation(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    for i=0, MAX_TEAM_NUM-1 do
        item[i]=Net.parseAtlasCard( data:getObj("p"..i),i)
    end
    return item
end



function Net.parseAtlasEnemyFormation(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    for i=0, MAX_TEAM_NUM-1 do
        if(data:containsKey("p"..i))then

        end
        item[i]=Net.parseAtlasCard( data:getObj("m"..i),i)

    end
    return item
end


function Net.parserVipBuy(data)
    local  data=tolua.cast(data,"MediaObj")
    if(data)then
        if data:containsKey("hpbuy_num") then
            -- Data.buyEnergyNum=data:getInt("hpbuy_num");
            Data.setUsedTimes(VIP_DIAMONDHP,data:getInt("hpbuy_num"));
        end
        if data:containsKey("skptbuy_num") then
            Data.setUsedTimes(VIP_SKILLPOT,data:getInt("skptbuy_num"));
        end
        --点石成金
        if data:containsKey("tg_num") then
            Data.setUsedTimes(VIP_STONEGOLD,data:getInt("tg_num"));
        end
        -- --竞技场购买次数
        -- if data:containsKey("arbuy_num") then
        --     -- print("VIP_ARENA num = "..data:getInt("arbuy_num"));
        --     Data.setUsedTimes(VIP_ARENA,data:getInt("arbuy_num"));
        -- end
        if data:containsKey("shop2") then
            Unlock.system.shop2.isOpen = data:getBool("shop2");
        end
        if data:containsKey("shop3") then
            Unlock.system.shop3.isOpen = data:getBool("shop3");
        end
        --经验
        if data:containsKey("cebuy_num") then
            Data.setUsedTimes(VIP_EXP,data:getInt("cebuy_num"));
        end
        --兽魂
        if data:containsKey("psbuy_num") then
            Data.setUsedTimes(VIP_BUYPETSOUL,data:getInt("psbuy_num"));
        end
        --无尽徽章
        if data:containsKey("tower_num") then
            Data.setUsedTimes(VIP_TOWERMONEY,data:getInt("tower_num"));
        end
        --金宝箱
        if data:containsKey("goldbox_num") then
            Data.setUsedTimes(VIP_GOLDBOX,data:getInt("goldbox_num"));
        end

        if data:containsKey("evilbuy_num") then
            Data.setUsedTimes(VIP_ATLAS_BOSS_BUY,data:getInt("evilbuy_num"));
        end
    end

end

function Net.parserIcon(obj)
    if(obj:containsKey("icon"))then
        local icon = obj:getInt("icon");
        gUserInfo.icon_frame = icon;
        gUserInfo.icon = math.mod(icon,100000);
        local frame = math.floor(icon/100000);
        gUserInfo.frame = frame;
        gUserInfo.awakeLv = 0;
        if(frame>=100)then
            gUserInfo.frame = math.mod(frame,100);
            gUserInfo.awakeLv = math.floor(frame/100);
            gUserInfo.awakeLv = gParseCardAwakeId(gUserInfo.awakeLv);
            if(gUserInfo.awakeLv)then
                gUserInfo.awakeLv = 0;
            end
        end
        -- gUserInfo.awakeLv = math.floor(gUserInfo.frame/100);
        -- gUserInfo.frame = math.mod(gUserInfo.frame,100);
        -- print("gUserInfo.icon_frame = "..gUserInfo.icon_frame);
        -- print("gUserInfo.icon = "..gUserInfo.icon);
        -- print("gUserInfo.frame = "..gUserInfo.frame);
        -- print("gUserInfo.awakeLv = "..gUserInfo.awakeLv);
    end
end

function Net.parserShowInfo(obj)
    local ret = {};
    if(obj == nil)then
        return ret;
    end
    -- if(obj:containsKey("icon"))then
    --     ret.icon = obj:getInt("icon");
    -- end
    if(obj:containsKey("halo"))then
        ret.halo = obj:getByte("halo");
    end
    if(obj:containsKey("wlv"))then
        ret.wlv = obj:getByte("wlv");
    end
    if(obj:containsKey("wkn"))then
        ret.wkn = obj:getByte("wkn");
    end
    -- if(obj:containsKey("hlv"))then
    ret.hlv = obj:getByte("hlv");
    -- end

    print_lua_table(ret)

    return ret;
end

function Net.parseUserInfo(data)
    if(data==nil)then
        return
    end
    if(data:containsKey("id"))then
        gUserInfo.id=data:getLong("id")
    end

    if(data:containsKey("name"))then
        gUserInfo.name=data:getString("name")
    end

    if(data:containsKey("stexp"))then
        gUserInfo.stexp=data:getInt("stexp")
    end

    if(data:containsKey("vip"))then
        if(gUserInfo.vip~=nil and gUserInfo.vip<data:getByte("vip") and Module.isClose(SWITCH_VIP) == false)then
            gUserInfo.vip=data:getByte("vip")
            -- print("111111newVip = "..gUserInfo.vip);
            local panel=Panel.getTopPanel(Panel.popPanels);
            if(panel and panel.__panelType == PANEL_VIP_LEVELUP)then
                Panel.popBackTopPanelByType(PANEL_VIP_LEVELUP);
            end
            Panel.popUpVisible(PANEL_VIP_LEVELUP,nil,nil,true);
        end
        gUserInfo.vip=data:getByte("vip")
        Data.updateVipData();
    end

    if(data:containsKey("vipsc"))then
        gUserInfo.vipsc=data:getInt("vipsc")
        Data.activityPayData.var = gUserInfo.vipsc
    end

    if(data:containsKey("iapbuy"))then
        gUserInfo.iapbuy=data:getInt("iapbuy")
    end

    if(data:containsKey("icon"))then
        Net.parserIcon(data);
    -- local icon = data:getInt("icon");
    -- gUserInfo.icon_frame = icon;
    -- gUserInfo.icon = math.mod(icon,100000);
    -- gUserInfo.frame = math.floor(icon/100000);
    -- print("icon = "..icon);
    -- print("gUserInfo.icon = "..gUserInfo.icon);
    -- print("gUserInfo.frame = "..gUserInfo.frame);
    end

    -- --test
    -- gUserInfo.icon = 10001;
    -- gUserInfo.frame = 1;

    if(data:containsKey("lv"))then

        if(gUserInfo.level~=nil and gUserInfo.level~=data:getShort("lv"))then
            Scene.needLevelup=true
            gUserInfo.level=data:getShort("lv")
            local unlockSys = Unlock.getUnlockSysByLevUp(data:getShort("lv"))
            if nil ~= unlockSys then
                -- 暂时先放
                if unlockSys == SYS_CONSTELLATION then
                    Unlock.system.constellation.show()
                end 
            -- Guide.sendUnlockSysBeginGuide(unlockSys)
            end
            gAccount:roleUpdate()
        end
        gUserInfo.level=data:getShort("lv")

    end

    if(data:containsKey("exp"))then
        gUserInfo.exp=data:getInt("exp")
    end

    if(data:containsKey("dia"))then
        gUserInfo.diamond=data:getInt("dia")
    end

    if(data:containsKey("gold"))then
        gUserInfo.gold=data:getInt("gold")
    end

    if(data:containsKey("tower"))then
        gUserInfo.towermoney=data:getInt("tower")
    end

    if(data:containsKey("eng"))then
        gUserInfo.energy=data:getInt("eng")
    end

    if(data:containsKey("spr"))then
        gUserInfo.spirit=data:getInt("spr")
    end

    if(data:containsKey("repu"))then
        gUserInfo.reputation=data:getInt("repu")
    end

    if(data:containsKey("esoul"))then
        gUserInfo.equipSoul=data:getInt("esoul")
    end

    if(data:containsKey("repum"))then
        gUserInfo.repuNum=data:getInt("repum")
    end

    if(data:containsKey("sglv"))then
        gUserInfo.signinlevel=data:getByte("sglv")
    end

    if(data:containsKey("etime"))then
        gUserInfo.energytime=data:getInt("etime")
    end

    if(data:containsKey("stime"))then
        gUserInfo.spirittime=data:getInt("stime")
    end

    if(data:containsKey("ldc"))then
        gUserInfo.logindaycount=data:getInt("ldc")
    end


    if(data:containsKey("csoul"))then
        gUserInfo.cardsoul=data:getInt("csoul")
    end


    if(data:containsKey("skpt"))then
        gUserInfo.skillPoint=data:getInt("skpt")
    end


    if(data:containsKey("petpt"))then
        gUserInfo.petPoint=data:getInt("petpt")
    end

    if(data:containsKey("petmny"))then
        gUserInfo.petMoney=data:getInt("petmny")
    end


    if(data:containsKey("cexp"))then
        gUserInfo.cexp=data:getInt("cexp")
    end

    if(data:containsKey("cstar"))then
        gUserInfo.cstar=data:getInt("cstar")
    end

    if(data:containsKey("honor"))then
        gUserInfo.honor=data:getInt("honor")
    end


    if(data:containsKey("htime"))then
        gUserInfo.htime=data:getInt("htime")
    end

    if(data:containsKey("acoin"))then
        gUserInfo.acoin=data:getInt("acoin")
    end

    if(data:containsKey("emotion"))then
        gUserInfo.emotion=data:getInt("emotion")
    end

    if(data:containsKey("skpttime"))then
        Data.skillPointTime=data:getInt("skpttime")
    end

    if(data:containsKey("sword"))then
        gFriend.sign = data:getString("sword");
    end
    -- print("gFriend.sign = "..gFriend.sign);
    if data:containsKey("mpt") then
        gDigMine.setMptByReTime(data:getInt("mpt"))
    end

    if data:containsKey("mtime") then
        gDigMine.setMptTime(data:getInt("mtime"))
    end
    if data:containsKey("regtime") then
        gUserInfo.regTime=data:getInt("regtime")
        gUserInfo.retain_day = math.ceil((gGetCurServerTime() - gUserInfo.regTime) / (3600 * 24))
    end

    if data:containsKey("evilnum") then
        local evilnum=data:getInt("evilnum")
        gAtlas.bossNum=evilnum
    end

    if data:containsKey("wp") then
        -- print("containsKey wp", data:getInt("wp"))
        gServerBattle.exp = data:getInt("wp")
    end

    if(data:containsKey("halo"))then
        gUserInfo.halo=data:getByte("halo")
    end

    if(data:containsKey("firstcg"))then
        gUserInfo.firstcg=data:getByte("firstcg")
    end

    if(data:containsKey("famoney"))then
        gUserInfo.famoney = data:getInt("famoney")
    end

    if(data:containsKey("cfnum"))then
        local cfNum = data:getInt("cfnum")
        gConstellation.setLeftFightNum(cfNum)
        RedPoint.constellation()
    end

    if(data:containsKey("cftime"))then
        gConstellation.setLeftFightRecoveryTime(data:getInt("cftime"))
    end

    --给版署的号需要关闭的模块
    if(data:containsKey("close"))then
        local strClose = data:getString("close");--strClose = "0,38";
        if(strClose~="") then
            local list = string.split(strClose,",");
            local banshuClose = {}
            for i=1,#list do
                table.insert(banshuClose,toint(list[i]));
            end
            gUserInfo.banshuClose = banshuClose;
        end
    end

    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end

function Net.parserActStage(data)
    data=tolua.cast(data,"MediaObj")
    local ret={}
    ret.batNum=data:getByte("num")
    ret.dnum=data:getByte("dnum")
    ret.cd=data:getInt("cdtime")
  
    return ret
end

function Net.parserStage(data)
    data=tolua.cast(data,"MediaObj")
    local ret={}

    for i=0, 10 do
        ret["maxMap"..i]=data:getByte("maxcha"..i)
        ret["maxStage"..i]=data:getInt("maxsta"..i)
    end

    ret.bossNum=data:getInt("ebid")
    ret.star={}
    local starList=data:getArray("star")
    if(starList)then
        starList=tolua.cast(starList,"MediaArray")
        for i=0, starList:count()-1 do
            local starItem={}
            local starObj=tolua.cast(starList:getObj(i),"MediaObj")
            starItem.type=starObj:getByte("type")
            starItem.mapid=starObj:getByte("cid")
            starItem.stageid=starObj:getInt("sid")
            starItem.num=starObj:getInt("num")
            starItem.batNum=starObj:getInt("batnum")
            starItem.buyNum=starObj:getInt("buynum")


            table.insert(ret.star,starItem)
        end
    end

    ret.box={}
    local boxList=data:getArray("chap")
    if(boxList)then
        boxList=tolua.cast(boxList,"MediaArray")
        for i=0, boxList:count()-1 do
            local boxItem={}
            local boxObj=tolua.cast(boxList:getObj(i),"MediaObj")
            boxItem.rec1=boxObj:getBool("rec1")
            boxItem.rec2=boxObj:getBool("rec2")
            boxItem.rec3=boxObj:getBool("rec3")
            boxItem.type=boxObj:getByte("type")
            boxItem.mapid=boxObj:getByte("cid")
            table.insert(ret.box,boxItem)
        end
    end
    return ret
end

function Net.parseUserCard(data,countpro)
    if(countpro==nil)then
        countpro=true
    end
    data=tolua.cast(data,"MediaObj")
    local card={}
    card.id=data:getLong("id")
    card.cardid=data:getInt("cid")
    card.level=data:getShort("lv")
    card.grade=data:getByte("gd")
    card.quality= data:getByte("qlt")
    card.exp=data:getInt("exp")
    card.raise_hp=data:getInt("hp")
    card.raise_physicalAttack=data:getInt("atk")
    card.raise_physicalDefend=data:getInt("pdef")
    card.raise_magicDefend=data:getInt("mdef")
    card.weaponLv=data:getInt("wplv")
    card.awakeLv=data:getByte("wkn")--觉醒等级
    card.ignore=data:getBool("ign")--觉醒等级
    card.pid=data:getInt("petid")
    card.needRefresh = true;
    -- card.awakeLv = 7;
    for i=1, 4 do
    -- card["treasure"..i]=data:getLong("t"..i)
    end

    local skillLvArrays=data:getIntArray("sklv")
    card.skillLvs={}
    if(skillLvArrays)then
        for i=0, skillLvArrays:size()-1 do
            table.insert( card.skillLvs,i,skillLvArrays[i])
        end
    end

    local equipLvArrays=data:getShortArray("elv")
    card.equipLvs={}
    if(equipLvArrays)then
        for i=0, equipLvArrays:size()-1 do
            table.insert( card.equipLvs,i,equipLvArrays[i])
        end
    end


    local equipQuaArrays=data:getByteArray("eqlv")
    card.equipQuas={}
    if(equipQuaArrays)then
        equipQuaArrays:resetPos()
        for i=0, equipQuaArrays:getLen()-1 do
            table.insert( card.equipQuas,i,equipQuaArrays:getByte())
        end
    end



    local equipActiveArrays=data:getIntArray("einfo")
    card.equipActives={}
    if(equipActiveArrays)then
        for i=0, equipActiveArrays:size()-1 do
            table.insert( card.equipActives,i,equipActiveArrays[i])
        end
    end

    if(countpro)then
        CardPro.setCardAttr(card,true)
    end
    return card
end




function Net.parseUserPet(data)
    data=tolua.cast(data,"MediaObj")
    if(data==nil)then
        return
    end
    local pet={}
    pet.petid=data:getInt("pid")
    pet.grade= data:getByte("gd")
    pet.awakeLv = Pet.getPetAwakeLvByGrade(pet.grade)
    pet.level=  data:getInt("lv")
    pet.exp=data:getInt("exp")
    pet.skillLevel1=data:getInt("sklv")
    pet.skillLevel2=data:getInt("bflv0")
    pet.skillLevel3=data:getInt("bflv1")
    pet.skillLevel4=data:getInt("bflv2")
    pet.skillLevel5=data:getInt("bflv3")
    pet.trinit=data:getInt("trinit",0)

    pet.unlockst=data:getByte("unlockst") --特殊技能解锁孔数
    pet.stid1=data:getInt("stid1")
    pet.stid2=data:getInt("stid2")
    pet.stid3=data:getInt("stid3")
    pet.stid4=data:getInt("stid4")
    pet.stid5=data:getInt("stid5")
    pet.stid6=data:getInt("stid6")
    pet.stid7=data:getInt("stid7")
    pet.stid8=data:getInt("stid8")
    pet.cid=data:getInt("cardid")
    pet.stlocks={}
    local stlocks = data:getIntArray("stlock")
    for i=0, stlocks:size()-1 do
        table.insert(pet.stlocks,stlocks[i])
    end
    return pet
end


function Net.parseBuddyList( list )
    local buddylist = {}
    if(list ~= nil) then
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            local buddytable = Net.parseBuddyObj(buddyObj)
            if buddytable ~= nil then
                table.insert(buddylist,buddytable)
            end
        end

        --好友排序
        local function sortWithLv(buddy1,buddy2)
            local lv1 = buddy1.level
            local lv2 = buddy2.level
            if(lv1 > lv2) then
                return true
            end
            return false
        end
        table.sort(buddylist,sortWithLv)

    end
    return buddylist
end


function Net.getBuddyGiveList(list)
    local ret = {}
    if( list ~= nil) then
        for i=0,list:count()-1 do
            local pGiveObj = list:getObj(i)
            pGiveObj =tolua.cast(pGiveObj,"MediaObj")
            local uid = pGiveObj:getLong("uid")
            local name = pGiveObj:getString("name")
            local lv = pGiveObj:getShort("lv")
            local power = pGiveObj:getInt("power")
            local time = pGiveObj:getInt("time")
            table.insert(ret,{uid=uid,name=name,lv=lv,power=power,time=time})
        end
    end
    return ret
end
function Net.parseBuddyObj( buddyObj )
    buddyObj =tolua.cast(buddyObj,"MediaObj")
    if buddyObj == nil then
        return nil
    end

    local uid=buddyObj:getLong("uid")
    local name=buddyObj:getString("name")
    local level=buddyObj:getShort("lv")
    local power=buddyObj:getInt("power")
    local give=buddyObj:getBool("give")
    local vip = buddyObj:getByte("vip")
    local giveme = buddyObj:getBool("giveme");
    local icon = buddyObj:getInt("icon");
    local login = buddyObj:getInt("lgtime")
    local sign = buddyObj:getString("sword")
    local rank = buddyObj:getInt("rank")
    local show = Net.parserShowInfo(buddyObj:getObj("idetail"));
    return {uid=uid,name=name,level=level,power=power,give=give,vip=vip,giveme=giveme,icon=icon,login=login,sign=sign,rank=rank,show = show}
end


function Net.parsePetStageObj( obj )
    local ret={}
    ret.mapid=obj:getInt("map") --最高层次
    ret.maptdid=obj:getInt("maptd") --最高层次
    ret.batnum=obj:getInt("batnum") --今日已打次数
    ret.sweepnum=obj:getInt("snum") --今日已打次数
    ret.cd=obj:getInt("stime") --开始扫荡时间
    ret.rewardcd=obj:getInt("rtime") --领取扫荡奖励时间
    Data.setUsedTimes(VIP_PETTOWER_SWEEP_TIMES,obj:getInt("buynum")); --购买的扫荡次数
    Data.pet.topFloor = ret.mapid;

    ret.rewards={}
    local list=obj:getArray("rewlist")
    if( list ~= nil) then
        for i=0,list:count()-1 do
            local rewardObj = tolua.cast(list:getObj(i),"MediaObj")
            local itemid = rewardObj:getInt("itemid")
            local itemnum = rewardObj:getInt("num")
            table.insert(ret.rewards,{itemid=itemid,itemnum=itemnum})
        end
    end
    return  ret
end

function Net.parseretieveObj( obj )
    local ret={}
    ret.retId = obj:getInt("id")
    ret.curp = obj:getInt("curp")
    ret.curlv = obj:getInt("curl")+1
    ret.bolGet = obj:getBool("get")
    return  ret
end

function Net.parseTaskObj( obj )
    local ret={}
    obj =tolua.cast(obj,"MediaObj")

    ret.dayid = obj:getInt("id")
    ret.curp = obj:getInt("curp")
    ret.status = obj:getByte("status") --0:进行中 1: 可领取 2: 已完成
    ret.sortid = 0;

    return  ret
end

function Net.parseAchieveObj( obj )
    local ach={}
    obj2 =tolua.cast(obj,"MediaObj")

    -- if (obj2) then
    ach.achId = obj2:getInt("id");
    ach.curp = obj2:getInt("curp");
    ach.curlv = obj2:getInt("curl")+1;
    ach.bolGet = obj2:getBool("get");
    ach.sort = 0;
    if ach.bolGet then
        ach.sort = 1;
    end
    -- end

    return ach;
end



function Net.parseActivityObj( obj )
    local action={}
    action.idx = obj:getInt("id")
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.desc = obj:getString("desc")
    action.var = obj:getInt("val")
    action.num = obj:getInt("num")
    if (obj:containsKey("maxd")) then
        action.maxd = obj:getInt("maxd")
    end
    if (obj:containsKey("curd")) then
        action.curd = obj:getInt("curd")
    end
    if (obj:containsKey("param3")) then--param
        action.param3 = obj:getInt("param3")
    end

    action.list={}


    local detList=obj:getArray("det")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.idx = detObj:getInt("detid")
            info.name = detObj:getString("name")
            info.rec = detObj:getBool("rec")
            info.max = detObj:getInt("max")
            info.iapid = detObj:getInt("iapid")
            info.num = detObj:getInt("num")
            info.count = detObj:getInt("count")
            if (detObj:containsKey("cnt")) then
                info.cnt = detObj:getInt("cnt")
            end
            if (detObj:containsKey("stime")) then
                info.stime = detObj:getInt("stime")
            end
            if (detObj:containsKey("etime")) then
                info.etime = detObj:getInt("etime")
            end
            info.items={}
            local itemList=detObj:getArray("items")
            if(itemList)then
                itemList=tolua.cast(itemList,"MediaArray")
                for j=1, itemList:count() do
                    local itemObj=tolua.cast(itemList:getObj(j-1),"MediaObj")
                    local item={}
                    item.itemid =itemObj:getInt("id")
                    item.num =itemObj:getInt("qty")
                    item.level =itemObj:getInt("lv")
                    item.param =itemObj:getInt("param")
                    if (itemObj:containsKey("p1")) then
                        item.p1 = itemObj:getInt("p1")
                    end
                    if (itemObj:containsKey("oldprice")) then
                        item.oldprice = itemObj:getInt("oldprice")
                    end
                    if (itemObj:containsKey("price")) then
                        item.price = itemObj:getInt("price")
                    end
                    table.insert(info.items,item)
                end
            end
            if (detObj:containsKey("status")) then
                info.status = detObj:getByte("status")
            end
            if (detObj:containsKey("cnt")) then
                info.cnt = detObj:getInt("cnt")
            end
            table.insert(action.list,info)
        end
    end

    return action
end

function Net.parseFormationObj(obj)
    local data = {};
    data.uid = obj:getLong("id");
    data.name = obj:getString("name");
    data.price = obj:getInt("price");
    data.power = data.price;
    data.lv = obj:getInt("lv");
    data.level = obj:getInt("lv");
    data.vip = obj:getByte("vip");
    data.fname = obj:getString("fname");
    data.rank = obj:getInt("rank");
    data.icon = obj:getInt("icon");
    data.sign = obj:getString("sword")

    data.team = Net.parseTeamObj(obj:getObj("team"));
    data.show = Net.parserShowInfo(obj:getObj("idetail"));
    -- print_lua_table(data);
    return data;
end

function Net.parseRaiseObj(obj)

    ---cid        int 卡牌ID
    ---hp     int 血量
    ---atk        int 攻击
    ---pdef       int 物防
    ---mdef       int 魔防
    ---hpla       int 血量(未保存)
    ---atkla      int 攻击(未保存)
    ---pdefla     int 物防(未保存)
    ---mdefla     int 魔防(未保存)

    obj = tolua.cast(obj,"MediaObj");
    local ret={}
    ret.cardid=obj:getInt("cid")
    ret.hp=obj:getInt("hp")
    ret.physicalAttack=obj:getInt("atk")
    ret.physicalDefend=obj:getInt("pdef")
    ret.magicDefend=obj:getInt("mdef")

    ret.hpLast=obj:getInt("hpla")
    ret.physicalAttackLast=obj:getInt("atkla")
    ret.physicalDefendLast=obj:getInt("pdefla")
    ret.magicDefendLast=obj:getInt("mdefla")
    return ret
end



function Net.parseCrusadeObj(obj)
    local data = {};
    obj = tolua.cast(obj,"MediaObj");
    --[[
    ——id        long    叛军ID
    ——cid       int 卡牌ID
    ——name      String  叛军名称
    ——lv        int 等级
    ——hp        int 当前血量
    ——hpmax     int 血量上限
    ——fid       long    发现者ID
    ——fname     String  发现者名称
    ——share     bool    是否分享
    ——endtime       int 叛军逃跑时间
    --mid       int 多语言叛军名字id

    ]]
    data.id = obj:getLong("id");
    data.cid = obj:getInt("cid");
    data.name = obj:getString("name");
    data.lv = obj:getInt("lv");
    data.hp = obj:getInt("hp");
    data.hpmax = obj:getInt("hpmax");
    data.fid = obj:getLong("fid");
    data.fname = obj:getString("fname");
    data.share = obj:getBool("share");
    data.endtime = obj:getInt("endtime")
    data.quality = obj:getByte("quality")
    data.mid = obj:getInt("mid")

    return data;
end




function Net.parseTeamObj(teamObj)
    local team = {};
    if(teamObj == nil)then
        return team;
    end
    team.pid = teamObj:getInt("pid");       --宠物id,0表示没有宠物
    team.plv = teamObj:getInt("plv");       --宠物等级
    team.pgd = teamObj:getByte("pgd");      --宠物星级
    team.pawakeLv = Pet.getPetAwakeLvByGrade(team.pgd) --宠物觉醒
    team.clist = {};
    local list = teamObj:getArray("clist");
    if list then
        list = tolua.cast(list,"MediaArray");
        for i=0, list:count()-1 do
            local listObj = tolua.cast(list:getObj(i),"MediaObj");
            local card = {};
            card.pos = listObj:getByte("pos");  --卡牌位置
            card.cid = listObj:getInt("cid");   --卡牌id
            card.gd = listObj:getByte("gd");    --卡牌星级
            card.lv = listObj:getInt("lv");     --卡牌等级
            card.qlt = listObj:getByte("qlt");  --卡牌品质
            card.awakeLv = listObj:getByte("wkn");  --卡牌觉醒等级
            table.insert(team.clist,card);
        end
    end
    return team;
end

--公告红点
function Net.updateNoticeRedpos(noticeid)
    -- print("##########")
    local maxNoticeId = 0;
    local curServerId =gAccount:getCurRole().serverid
    if(gNotices) then
        for key,data in pairs(gNotices) do
            -- print("data.serverid = "..data.serverid);
            -- print_lua_table(data);
            -- print("curServerId = "..curServerId);
            if(toint(data.id) > maxNoticeId and toint(curServerId) == toint(data.serverid))then
                maxNoticeId = toint(data.id);
            -- print("replace maxNoticeId = "..maxNoticeId);
            end
        end
    end

    -- print("curServerId = "..curServerId);
    -- print_lua_table(gNotices);
    print("noticeid = "..noticeid);
    print("maxNoticeId = "..maxNoticeId);
    if(noticeid>maxNoticeId)then
        Data.redpos.bolNotice = true;
    else
        Data.redpos.bolNotice = false;
    end
end

function Net.updatePrompt( obj )
    -- body
    if(obj:containsKey("ta")) then
        Data.redpos.bolDayTask = obj:getBool("ta");
    end
    if(obj:containsKey("ac")) then
        Data.redpos.bolAchieve = obj:getBool("ac");
    end

    if(obj:containsKey("sv")) then
        Data.redpos.bolNewTask = obj:getBool("sv");
    end
    print("每日体力")
    --每日体力
    if(obj:containsKey("de")) then
        print("每日体力de")
        Data.redpos.bolDayEnergy = obj:getBool("de");
        if (Data.redpos.bolDayEnergy) then
            print("每日体力 true")
        end
    end
    --标记时间段是否领取过体力
    if(Data.task == nil)then
        Data.initTaskParams();
    end
    local curServerTime = gGetCurServerTime(true);
    for key,var in pairs(Data.task.getEnergyTime) do
        if (gGetHourByTime(curServerTime) >= toint(var.time[1]) and gGetHourByTime(curServerTime) < toint(var.time[2])) then
            var.hasGet = not Data.redpos.bolDayEnergy;
        end
    end

    if (obj:containsKey("family")) then
        local familyObj = tolua.cast(obj:getObj("family"),"MediaObj")
        Data.redpos.bolFamilyApply = familyObj:getBool("apply");
        Data.redpos.bolFamilyGu = familyObj:getBool("wood");--擂鼓
        Data.redpos.bolFamilyEgg = familyObj:getBool("stone");--砸蛋
        Data.redpos.bolFamilySeven = familyObj:getBool("seven");--封魔
        Data.redpos.bolFamilySpring = familyObj:getBool("spring");--泉水
        Data.redpos.bolFamilyActive = familyObj:getBool("active");--活跃宝箱
        Data.redpos.bolFamilyOre = familyObj:getBool("ore");--挖矿
        Data.redpos.bolFamilyStage = familyObj:getBool("stage");--军团竞赛副本
        Data.redpos.bolFamilyShopReward = familyObj:getBool("lvreward");--军团商店奖励
        if(familyObj:containsKey("fdonate")) then
            Data.redpos.bolFamilyDonate = familyObj:getBool("fdonate");--捐赠
              if Module.isClose(SWITCH_FAMILY_DONATE) then
                Data.redpos.bolFamilyDonate =false
              end
        end
    end
    if(obj:containsKey("nm")) then
        Data.redpos.bolNewMail = obj:getBool("nm");
    end
    if(obj:containsKey("bm")) then
        Data.redpos.bolBuddyMail = obj:getBool("bm");
    end
    if(obj:containsKey("fm")) then
        Data.redpos.bolFamilyMail = obj:getBool("fm");
    end
    --好友
    if (obj:containsKey("ba")) then
        Data.redpos.bolBuddyApply = obj:getBool("ba");
    end
    if (obj:containsKey("bg")) then
        Data.redpos.bolBuddyHp = obj:getBool("bg");
        gFriend.myFriendsInited = false;
    end
    --签到
    if(obj:containsKey("si")) then
        Data.redpos.bolDaySign = obj:getBool("si");
    end

    if(obj:containsKey("cru")) then
        local cruObj = tolua.cast(obj:getObj("cru"),"MediaObj")
        if(cruObj:containsKey("num")) then
            Data.redpos.bolCrusadeNum = cruObj:getBool("num");
        end
        if(cruObj:containsKey("rec")) then
            Data.redpos.bolCrusadeRec = cruObj:getBool("rec");
        end
        if(cruObj:containsKey("call")) then
            Data.redpos.bolCrusadeCall = cruObj:getBool("call");
        end
    end

    if(obj:containsKey("turn")) then
        local turnObj = tolua.cast(obj:getObj("turn"),"MediaObj")
        if(turnObj:containsKey("rec")) then
            Data.redpos.bolLuckWheelRec =  turnObj:getBool("rec");
        end

        if(turnObj:containsKey("free0")) then
            Data.redpos.bolLuckWheelfree0 =  turnObj:getBool("free0");
        end
        if(turnObj:containsKey("free1")) then
            Data.redpos.bolLuckWheelfree1 =  turnObj:getBool("free1");
        end


    end


    if(obj:containsKey("vipsi")) then
        Data.redpos.bolVipSign = obj:getBool("vipsi");
    end
    if(obj:containsKey("cntsi")) then
        Data.redpos.bolCntSign = obj:getBool("cntsi");
    end
    --招募，点将台
    if (obj:containsKey("fc")) then
        local dragonObj = tolua.cast(obj:getObj("fc"),"MediaObj")
        Data.redpos.gcNumDragon = dragonObj:getByte("gc")
        Data.redpos.gtFTimeDragon = dragonObj:getInt("gt")
        Data.redpos.dtFTimeDragon = dragonObj:getInt("dt")
    end

    --试炼
    if (obj:containsKey("actsta")) then
        local actAtlasList = obj:getArray("actsta")
        if nil ~= actAtlasList then
            Data.redpos.actAtlas = {}
            actAtlasList = tolua.cast(actAtlasList,"MediaArray")
            for i = 0, actAtlasList:count() - 1 do
                local actObj = tolua.cast(actAtlasList:getObj(i),"MediaObj")
                local item   = {}
                item.type    = actObj:getInt("id")
                item.num     = actObj:getInt("num")
                item.cdTime     = actObj:getInt("time")
                if item.cdTime > 0 then
                    item.serverTime = gGetCurServerTime()
                end
                item.unlockTime = actObj:getInt("ulktime");
                table.insert(Data.redpos.actAtlas,item)
            end
        end
    end

    --登录礼包
    if (obj:containsKey("lr")) then
        Data.redpos.bolLogin7 = obj:getBool("lr")
    end

    -- --月卡
    -- if (obj:containsKey("mc")) then
    --     local mc = tolua.cast(obj:getObj("mc"),"MediaObj")
    --     Data.redpos.mc = {}
    --     Data.redpos.mc.pr = mc:getBool("pr")
    --     Data.redpos.mc.mt = mc:getInt("mt")
    -- end
    if (obj:containsKey("mlc")) then
        Data.redpos.mlc = obj:getBool("mlc")
    end
    -- print_lua_table(Data.redpos)

    --投资理财
    if (obj:containsKey("fu")) then
        Data.redpos.fu = obj:getBool("fu")
    end

    --等级礼包
    if (obj:containsKey("lg")) then
        Data.redpos.lg = obj:getBool("lg")
    end

    --累计充返
    if (obj:containsKey("act")) then
        if (Data.redpos.act==nil) then
            Data.redpos.act = {}
        end
        local act = obj:getIntArray("act")
        for i = 1, act:size() do
            local info = act[i-1]
            if (not Net.bolRedPosAct(info)) then
                table.insert(Data.redpos.act,info)
            end
        end
        print("累计充返 红点")
        print_lua_table(Data.redpos.act)
    end
    --新年活动
    if (obj:containsKey("act2")) then
        if (Data.redpos.act2==nil) then
            Data.redpos.act2 = {}
        end
        local act = obj:getIntArray("act2")
        for i = 1, act:size() do
            local info = act[i-1]
            if (not Net.bolRedPosAct2(info)) then
                table.insert(Data.redpos.act2,info)
            end
        end
        print("新年活动 红点")
        print_lua_table(Data.redpos.act2)
    end
    --节日大派送
    if (obj:containsKey("act3")) then
        if (Data.redpos.act3==nil) then
            Data.redpos.act3 = {}
        end
        local act = obj:getIntArray("act3")
        for i = 1, act:size() do
            local info = act[i-1]
            if (not Net.bolRedPosAct3(info)) then
                table.insert(Data.redpos.act3,info)
            end
        end
        print("节日大派送 红点")
        print_lua_table(Data.redpos.act3)
    end

    --合服活动
    if (obj:containsKey("act4")) then
        if (Data.redpos.act4==nil) then
            Data.redpos.act4 = {}
        end
        local act = obj:getIntArray("act4")
        for i = 1, act:size() do
            local info = act[i-1]
            if (not Net.bolRedPosAct4(info)) then
                table.insert(Data.redpos.act4,info)
            end
        end
        print("合服 红点")
        print_lua_table(Data.redpos.act3)
    end

    --许愿树
    if (obj:containsKey("wish")) then
        Data.redpos.wish = obj:getBool("wish")
    end

    --vip礼包
    if (obj:containsKey("vipgift")) then
        Data.redpos.vipgift = obj:getBool("vipgift");
    end

    --vip每日礼包
    -- if (obj:containsKey("vipday")) then
    --     Data.redpos.vipDaygift = obj:getBool("vipday");
    -- end
    --竞技场
    -- if (obj:containsKey("ar")) then
    --     local ar = tolua.cast(obj:getObj("ar"),"MediaObj")
    --     Data.redpos.ar = {}
    --     Data.redpos.ar.num  = ar:getInt("num")
    --     Data.redpos.ar.time = ar:getInt("time")
    --     gArena.serverTime   = gGetCurServerTime()
    -- end

    --公告
    if(obj:containsKey("noticeid")) then
        Net.updateNoticeRedpos(obj:getInt("noticeid"));
    end

    --命魂红点
    if(obj:containsKey("spirit")) then
        Data.redpos.spirit = obj:getBool("spirit")
    end

    --卧龙窟扫荡红点
    if(obj:containsKey("swp")) then
        Data.redpos.swp = obj:getBool("swp")
        -- else
        --     Data.redpos.swp = false
    end

    --挖矿红点
    if(obj:containsKey("minep")) then
        Data.redpos.minep = obj:getBool("minep")
    end


    if(obj:containsKey("act97")) then
        if (Data.redpos.act97==nil) then
            Data.redpos.act97 = {}
        end
        local act97Obj = tolua.cast(obj:getObj("act97"),"MediaObj")
        Data.redpos.act97.pt = act97Obj:getBool("pt")
        Data.redpos.act97.type = act97Obj:getByte("type")
    end

    --吃体力红点
    if(obj:containsKey("act98")) then
         if (Data.redpos.act98==nil) then
            Data.redpos.act98 = {}
        end
        local act98Obj = tolua.cast(obj:getObj("act98"),"MediaObj")
        Data.redpos.act98.pt = act98Obj:getBool("pt")
        Data.redpos.act98.type = act98Obj:getByte("type")
    end

    --跨服战被打
    if(obj:containsKey("warlose"))then
        Data.redpos.warlose = obj:getBool("warlose")
    end

    --活动N日豪礼
    if(obj:containsKey("richday"))then
        Data.redpos.richday = obj:getBool("richday")
    end

    --免费vip
    if(obj:containsKey("act23"))then
        Data.redpos.act23 = obj:getBool("act23")
    end

    --招募
    if(obj:containsKey("act93"))then
        Data.redpos.act93 = obj:getBool("act93")
    end

    --春节七天乐
    if(obj:containsKey("taact"))then
        Data.redpos.bolActivityDayTaskCanGet = obj:getBool("taact");
    end

    -- 夺粮战 成就奖励红点提示
    if(obj:containsKey("lootfoodrec"))then
        Data.redpos.lootfoodrec = obj:getBool("lootfoodrec")
    end

    if(obj:containsKey("richmanrec"))then
        Data.redpos.richmanrec = obj:getBool("richmanrec")
    end
    -- 夺粮战 新记录提示
    if(obj:containsKey("lootfoodrecord"))then
        Data.redpos.lootfoodrecord = obj:getBool("lootfoodrecord")
    end
    -- 星宿系统
    -- 激活成就
    if(obj:containsKey("circleachieve"))then
        Data.redpos.circleachieve = obj:getBool("circleachieve")
        RedPoint.constellation()
    end
    -- 猎星小红点
    if(obj:containsKey("chunt"))then
        Data.redpos.constellationhunt = obj:getBool("chunt")
        RedPoint.constellation()
    end
    -- 升星小红点
    if(obj:containsKey("cstar"))then
        Data.redpos.constellationstar= obj:getBool("cstar")
        if Data.getCurLevel()<gConstellation.getStarUnLockLv() then
            Data.redpos.constellationstar = false
        end
        RedPoint.constellation()
    end
    -- 新世界boss 击杀奖励领取 成就奖励红点提示
    if(obj:containsKey("newbosskillrec"))then
        Data.redpos.newbosskillrec = obj:getBool("newbosskillrec")
    end

    --灵兽探险
    --成就
    if(obj:containsKey("caveachieve"))then
        Data.redpos.caveachieve = obj:getBool("caveachieve")
    end
    --事件
    if(obj:containsKey("caveevent"))then
        Data.redpos.caveevent = obj:getBool("caveevent")
    end
    --次数
    if(obj:containsKey("caveexplore"))then
        Data.redpos.caveexplore = obj:getBool("caveexplore")
    end

    -- gPrintLuaTable = true
    -- print_lua_table(Data.redpos)

    print("Net.updatePrompt");
end

function Net.bolRedPosAct(id)
    local bolId = false
    for k,v in pairs(Data.redpos.act) do
        if (v == id) then
            bolId = true
            break;
        end
    end
    return bolId
end

function Net.bolRedPosAct2(id)
    local bolId = false
    for k,v in pairs(Data.redpos.act2) do
        if (v == id) then
            bolId = true
            break;
        end
    end
    return bolId
end

function Net.bolRedPosAct3(id)
    local bolId = false
    for k,v in pairs(Data.redpos.act3) do
        if (v == id) then
            bolId = true
            break;
        end
    end
    return bolId
end

function Net.bolRedPosAct4(id)
    local bolId = false
    for k,v in pairs(Data.redpos.act4) do
        if (v == id) then
            bolId = true
            break;
        end
    end
    return bolId
end

function Net.parserStageInfo(stageInfo, inTable)

    local ret = inTable or {}
    ret.type = stageInfo:getByte("type")
    ret.mapid = stageInfo:getByte("cid")
    ret.stageid = stageInfo:getInt("sid")
    ret.num = stageInfo:getInt("num")
    ret.batNum = stageInfo:getShort("batnum")
    ret.buyNum = stageInfo:getShort("buynum")

    return ret
end

function Net.parserBattle(data,type)
    -- local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,type)
end

function Net.parserTrainRoomSeat(list_obj)
    local list_data = {};
    list_obj = tolua.cast(list_obj,"MediaObj");
    list_data.didx = list_obj:getByte("didx");
    list_data.haskey_didx = list_obj:containsKey("didx");
    list_data.uid = list_obj:getLong("uid");
    list_data.haskey_uid = list_obj:containsKey("uid");
    list_data.uname = list_obj:getString("uname");
    list_data.haskey_uname = list_obj:containsKey("uname");
    list_data.icon = list_obj:getInt("icon");
    list_data.haskey_icon = list_obj:containsKey("icon");
    list_data.lv = list_obj:getShort("lv");
    list_data.haskey_lv = list_obj:containsKey("lv");
    list_data.power = list_obj:getInt("power");
    list_data.haskey_power = list_obj:containsKey("power");
    list_data.fname = list_obj:getString("fname");
    list_data.haskey_fname = list_obj:containsKey("fname");
    list_data.ptime = list_obj:getInt("ptime");
    list_data.haskey_ptime = list_obj:containsKey("ptime");
    list_data.ptype = list_obj:getByte("ptype");
    list_data.haskey_ptype = list_obj:containsKey("ptype");
    list_data.show = Net.parserShowInfo(list_obj:getObj("idetail"));
    return list_data;
end

function Net.parserModuleSwitch(array)

    -- print("Net.parserModuleSwitch");

    gCloseModules = {};
    --默认关闭开关
    table.insert(gCloseModules,SWITCH_REPLACE_CARDYEAR);
    table.insert(gCloseModules,SWITCH_SERVER_BATTLE)
    table.insert(gCloseModules,SWITCH_APPSTORE_GOOD)
    table.insert(gCloseModules,SWITCH_ACTIVITY_NEWYEAR)
    table.insert(gCloseModules,SWITCH_LANGUAGE)
    table.insert(gCloseModules,SWITCH_TOWER)
    table.insert(gCloseModules,SWITCH_TREASURE)
    table.insert(gCloseModules,SWITCH_SHOP_EMOTION)
    table.insert(gCloseModules,SWITCH_FACEBOOK)
    table.insert(gCloseModules,SWITCH_INVITE)
    table.insert(gCloseModules,SWITCH_Alipay)
    table.insert(gCloseModules,SWITCH_IAppPay)
    table.insert(gCloseModules,SWITCH_IAppPayH5)
    -- table.insert(gCloseModules,SWITCH_FAMILY_ORE)
    table.insert(gCloseModules,SWITCH_LOOT_FOOD)
    table.insert(gCloseModules,SWITCH_TREASURE_HUNT)
    table.insert(gCloseModules,SWITCH_AD_API)
    table.insert(gCloseModules,SWITCH_YOUME_VOICE)
    table.insert(gCloseModules,SWITCH_ELITE_FLOP)

    if (array == nil) then
        return;
    end

    local switchs = {};
    array = tolua.cast(array,"MediaArray")
    for i=0,array:count()-1 do
        local data=tolua.cast(array:getObj(i),"MediaObj")
        local ret = Net.parserOneModuleSwitch(data:getInt("id"),data:getString("version"),data:getString("platform"),data:getInt("open"),data:getString("param"));
        table.insert(switchs,ret);

        if (data:getInt("id") == SWITCH_ACTIVITY_NEWYEAR) then
            gDispatchEvt(EVENT_ID_SHOW_ACTIVITY_NEWYER)
        end
    end



    -- print("switchs len = "..#switchs);
    -- print_lua_table(switchs);

    local isAdd = false;

    Module.updateSwitch(switchs);

    -- print("gCloseModules len = "..#gCloseModules);
    -- print_lua_table(gCloseModules);

    -- table.insert(gCloseModules,SWITCH_VIP);

    --删除关闭模块的数据
    Module.delDataForClose();
end

function Net.parserOneModuleSwitch(id,version,platforms,open,extraParam)
    local ret = {};
    ret.id = id;
    local vers = string.split(version,",");
    if(#vers > 1)then
        ret.version_up = vers[1];
        ret.version_down = vers[2];
    else
        ret.version_up = vers[1];
        ret.version_down = vers[1];
    end
    ret.platforms=string.split(platforms,",");
    ret.open = open;
    ret.extraParam = extraParam;
    return ret;
end

function Net.parserMineVipBuy(obj)
    if nil == obj then
        return
    end
    local  data=tolua.cast(obj,"MediaObj")
    if data then
        if data:containsKey("mb") then
            Data.setUsedTimes(VIP_MINE_BAG,data:getInt("mb"))
        end

        if data:containsKey("mblv1") then
            Data.setUsedTimes(VIP_MINE_BAG_LEV1,data:getInt("mblv1"))
        end

        if data:containsKey("mblv2") then
            Data.setUsedTimes(VIP_MINE_BAG_LEV2,data:getInt("mblv2"))
        end

        if data:containsKey("mblv3") then
            Data.setUsedTimes(VIP_MINE_BAG_LEV3,data:getInt("mblv3"))
        end

        if data:containsKey("me") then
            Data.setUsedTimes(VIP_DETONATOR,data:getInt("me"))
        end
    end
end

function Net.updateConstellationItemReward(param)
    param=tolua.cast(param,"MediaObj")
    if(param==nil)then
        return
    end

    local item= gConstellation.getBagById(param:getInt("conid"))
    if(item)then
        item.num=param:getInt("num")
    else
        local bagItem = ConstellationItemInfo.new(param:getInt("conid"))
        if nil ~= bagItem then
            bagItem.num=param:getInt("num")
            gConstellation.addBag(bagItem)
        end
    end
end
