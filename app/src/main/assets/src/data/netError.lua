NetErr={}


function NetErr.isDiamondEnough(needdia)
    if Data.getCurDia() < toint(needdia) then
        NetErr.noEnoughDia();
        return false;
    end
    return true;
end

function NetErr.isGoldEnough(needgold,isShowNotice)
    if(isShowNotice == nil)then
        isShowNotice = true;
    end
    if Data.getCurGold() < toint(needgold) then
        if(isShowNotice)then
            NetErr.noEnoughGold();
        end
        return false;
    end
    return true;
end

function NetErr.showDrawGetWay(itemid)
    local data={}
    data.itemid=itemid
    Panel.popUpVisible(PANEL_ATLAS_DROP,data)
end

function NetErr.isDrawCardEnough(type,ntype)
    --金币抽卡
    --SG-4072,改为道具抽卡
    if(type==0)then
        if(ntype==0)then
            if(Data.drawCard.gold.fnum and Data.drawCard.gold.fnum>0) and Data.drawCard.gold.ftime then
                local passTime=gGetCurServerTime()-Data.drawCard.time
                if(passTime>=Data.drawCard.gold.ftime)then
                    return true
                end
            end

            if NetErr.isDrawGoldBuyEnough(1)==false then
                NetErr.showDrawGetWay(ITEM_DRAW_GOLD_BUY)
                return false
            end
        end


        if(ntype==1)then
            if NetErr.isDrawGoldBuyEnough(10)==false then
                NetErr.showDrawGetWay(ITEM_DRAW_GOLD_BUY)
                return false
            end
        end
    end

    --钻石抽卡
    if(type==1)then
        if(ntype==0)then
 
            if(Data.drawCard.diamond.ftime )then
                local passTime=gGetCurServerTime()-Data.drawCard.time 
                if(passTime>=Data.drawCard.diamond.ftime)then
                    return true
                end
            end
            if isBanshuReview() then
                local isEnough = NetErr.isItemEnough(ITEM_ID_DRAW_CARD_ONE,1,true)
                if isEnough==false then
                    NetErr.showDrawGetWay(ITEM_ID_DRAW_CARD_ONE)
                end
                return isEnough
            end
            if( Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)>0 )then
                return true
            end
            if NetErr.isDiamondEnough(DB.getDrawDiamondOne())==false then
                return false
            end
        end

        if(ntype==1)then
            if isBanshuReview() then
                local isEnough = NetErr.isItemEnough(ITEM_ID_DRAW_CARD_TEN,1,false)
                if isEnough==false then
                    isEnough = NetErr.isItemEnough(ITEM_ID_DRAW_CARD_ONE,10,true)
                    if isEnough==false then
                        NetErr.showDrawGetWay(ITEM_ID_DRAW_CARD_ONE)
                    end
                end
                return isEnough
            end
            if( Data.getItemNum(ITEM_ID_DRAW_CARD_TEN)>0 )then
                return true
            end
            if NetErr.isDiamondEnough(DB.getDrawDiamondTen())==false then
                return false
            end
        end

    end
    return true
end

function NetErr.isEquipSoulEnough(num)
    if gUserInfo.equipSoul < toint(num) then
        local word=gGetWords("noticeWords.plist","no_enough_equip_soul")
        local function onOk()
            Panel.popUp(PANEL_CARD_WEAPON_EQUIP_SOUL)
        end
        gConfirmAll(word,onOk)
        return false;
    end
    return true;
end

function NetErr.isItemEnough(itemid,num,isShowNotice)
    if(isShowNotice == nil)then
        isShowNotice = true;
    end
    local num2=Data.getItemNum(itemid)
    if num>num2  or num2==0 then
        if(isShowNotice)then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_item",DB.getItemName(itemid) ))
        end
        return false
    end
    return true;
end

function NetErr.isPetSoulEnough(petid,curSoulNum,needSoulNum)
    if(curSoulNum < needSoulNum)then
        local pet = DB.getPetById(petid);
        local name = pet.name..gGetWords("labelWords.plist","soul_name");
        gShowNotice(gGetWords("noticeWords.plist","no_enough_item",name));
        return false;
    end
    return true;
end


function NetErr.checkPkLevel(data)
    return NetErr.checkFight(data.level);
end

function NetErr.checkFight(level)
    if(gUserInfo.level<Data.friend.fightlv)then
        gShowNotice(gGetWords("noticeWords.plist","pk_level",Data.friend.fightlv))
        return false
    end

    if(level and level<Data.friend.fightlv)then
        gShowNotice(gGetWords("noticeWords.plist","friend_pk_level",Data.friend.fightlv))
        return false
    end

    return true
end

function NetErr.noEnoughDia()
    local word=gGetWords("noticeWords.plist","no_dia")
    local function onOk()
        Panel.popUp(PANEL_PAY);
    end
    gConfirmAll(word,onOk)
end


function NetErr.noEnoughEnergy()

    local word=gGetWords("noticeWords.plist","no_energy")
    local function onOk()
        Panel.popUp(PANEL_BUY_ENERGY,VIP_DIAMONDHP)
    end
    gConfirmAll(word,onOk)
end

function NetErr.noAtlasBossNum()

    local word=gGetWords("noticeWords.plist","no_atlas_boss_time")
    local function onOk()
        local callback = function(num)
            Net.sendBuyBossNum(num)
        end
        Data.canBuyTimes(VIP_ATLAS_BOSS_BUY,true,callback);
    end
    gConfirmAll(word,onOk)
end

function NetErr.noEnoughGold()
    local word=gGetWords("noticeWords.plist","no_gold")
    local function onOk()
        Panel.popUp(PANEL_BUY_GOLD)
    end
    gConfirmAll(word,onOk)
end

function NetErr.noEnoughCardExp()
    local word=gGetWords("noticeWords.plist","no_cardexp")
    local function onOk()
        Panel.popUpVisible(PANEL_GLOBAL_BUY,VIP_EXP);
    end
    gConfirmAll(word,onOk)
end

function NetErr.noEnoughPetPoint()
    local word=gGetWords("noticeWords.plist","no_pet_point")
    local function onOk()
        Panel.popUp(PANEL_GLOBAL_BUY,VIP_BUYPETSOUL)
    end
    gConfirmAll(word,onOk)
end

--体力达到购买上限
function NetErr.isEnergyFull()
    if(Data.getCurEnergy() >= Data.buyEnergy.maxHp) then
        gShowCmdNotice(CMD_ITEM_DIAMOND_BUY_HP,14);
        return true;
    end
    return false;
end


function NetErr.isTeamEmpty(team)

    local ret=false
    for i=0, MAX_TEAM_NUM-2 do
        if(team[i]~=nil and team[i]>0)then
            ret=true
        end
    end

    return not ret
end
function NetErr.saveTeam(team)
    local ret=NetErr.isTeamEmpty(team)

    if(ret==true)then
        local word=gGetWords("noticeWords.plist","no_formation_empty")
        gShowNotice(word)
    end

    return  not ret
end

function NetErr.cardEquipUpgrade(cardid,idx)
    local card=Data.getUserCardById(cardid)
    if(card)then
        local gold= DB.getEquipPriceByLevel( card.equipLvs[idx]+1)
        if(gUserInfo.gold>=gold)then
            return true
        end
    end
    NetErr.noEnoughGold()
    return  false

end


function NetErr.atlasEnter(type,mapid,stageid)
    if(type==ATLAS_TYPE_BOSS)then
        if(gAtlas.bossNum<=0)then
            NetErr.noAtlasBossNum()
            return false
        end
        return true
    end

    local stage=DB.getStageById( mapid, stageid,type)
    if(gUserInfo.energy<stage.energy)then
        NetErr.noEnoughEnergy()
        return false
    end
    return true
end


function NetErr.atlasSweep(type,mapid,stageid,num)

    local stage=DB.getStageById( mapid, stageid,type)
    if(gUserInfo.energy<stage.energy*num)then
        NetErr.noEnoughEnergy()
        return false
    end
    return true
end


function NetErr.arenaBuyNum()
    local vip=DB.getVip(Data.getCurVip())
    return true
end

function NetErr.arenaClearCd()
    if(gUserInfo.diamond>=DB.getArenaCdCost())then
        return true
    end
    NetErr.noEnoughDia()
    return false
end

function NetErr.arenaFight()

    if(gArena.count<=0)then
        -- gShowNotice(gGetWords("noticeWords.plist","arena_no_time"));
        -- local callback = function(num)
        --     Net.sendArenaBuyNum(num);
        -- end
        -- Data.canBuyTimes(VIP_ARENA,true,callback);
        local word=gGetWords("noticeWords.plist","arena_no_time")
        local function onBuyTime()
            local callback = function(num)
                Net.sendArenaBuyNum(num);
            end
            Data.canBuyTimes(VIP_ARENA,true,callback);
        end
        gConfirmAll(word,onBuyTime)
        return false
    end
    if( gArena.time>0)then

        local word = gGetWords("noticeWords.plist","act_atlas_cd",Data.arena.clearCDDia)
        -- local word=gGetWords("noticeWords.plist","arena_cool_down")
        local function onResetCd()
            Net.sendArenaClearCd()
        end
        gConfirmAll(word,onResetCd)
        return false
    end

    return true

end



function NetErr.cardEquipItemMerge(itemid)
    local db = DB.getItemData(itemid)
    if(db)then
        local gold= db.com_money
        if(gUserInfo.gold>=gold)then
            return true
        end
    end
    NetErr.noEnoughGold()
    return  false

end


function NetErr.petUpgrade(petid,type)
    local pet=Data.getUserPetById(petid)
    if(pet.level >= Data.pet.maxLevel) then
        gShowNotice(gGetWords("noticeWords.plist","full_pet_level"));
        return false;
    end
    if(gUserInfo.petPoint<DB.getPetNormalFeedNum(pet.level,petid))then
        -- local word=gGetWords("noticeWords.plist","no_pet_point")
        -- gShowNotice(word)
        NetErr.noEnoughPetPoint();
        return false
    end

    local pet=Data.getUserPetById(petid)
    if(gUserInfo.gold<DB.getPetGoldFeedNum(pet.level,petid))then
        NetErr.noEnoughGold()
        return  false
    end

    return  true

end

function NetErr.petUpgradeSkill(needGold,needPetSkill)

    if NetErr.isGoldEnough(needGold) == false then
        return false;
    end

    if Data.getItemNum(ITEM_PET_SKILL) < needPetSkill then
        local word=gGetWords("noticeWords.plist","no_pet_skill")
        gShowNotice(word)
        return false
    end

    return true;
end


function NetErr.transmitCard(card1,card2)
    if(card1==nil)then
        gShowNotice(gGetWords("noticeWords.plist","error_transmit_card1"))
        return false
    end

    if(card2==nil)then
        gShowNotice(gGetWords("noticeWords.plist","error_transmit_card2"))
        return false
    end

    local breakWeaponLv1=gParseWeaponLv(card1.weaponLv)
    local breakWeaponLv2=gParseWeaponLv(card2.weaponLv)
    local raiseData1 =DB.getCardRaiseByLevel(card1.cardid,card2.weaponLv)
    local raiseData2 =DB.getCardRaiseByLevel(card2.cardid,card1.weaponLv)
    if breakWeaponLv1==0 and breakWeaponLv2==0  then
       gConfirm(gGetWords("weaponWords.plist","29"))
       return false
    end

    local price = (breakWeaponLv1+breakWeaponLv2)*100
    if NetErr.isDiamondEnough(price) == false then
        return false;
    end
    return true
end

function NetErr.transmitTreasure(treasure1,treasure2)
    if(treasure1==nil or treasure1==nil )then
        gShowNotice(gGetWords("noticeWords.plist","error_transmit_treasure1"))
        return false
    end

    if(treasure2==nil)then
        gShowNotice(gGetWords("noticeWords.plist","error_transmit_treasure2"))
        return false
    end

    
    local transmit_price = 0
    local treasureDB = DB.getTreasureById(treasure1.itemid)
    if treasureDB.quality>=QUALITY11 then
       transmit_price=Data.treasureExchangeDias[2]
    elseif treasureDB.quality>=QUALITY8 then
        transmit_price=Data.treasureExchangeDias[1]
    end
    
    if NetErr.isDiamondEnough(transmit_price) == false then
        return false;
    end
    return true
end


function NetErr.cardSkillUpgrade(cardid,pos)
    local card=Data.getUserCardById(cardid)
    if(card)then
        local constnum,point,constType= DB.getSkillPriceByLevel( card.skillLvs[pos],pos)
        if(constType==OPEN_BOX_GOLD and gUserInfo.gold<constnum)then
            NetErr.noEnoughGold()
            return false
        end
        if(constType==OPEN_BOX_CARDEXP_ITEM and Data.getCurCardExp()<constnum)then
            NetErr.noEnoughCardExp()
            return false
        end
        if(gUserInfo.skillPoint<point)then

            Panel.popUp(PANEL_GLOBAL_BUY,VIP_SKILLPOT);
            return false
        end

        return  true
    else
        return false
    end


end

function NetErr.ActAtlasEnter(hasCdTime,leftNum,needEnergy,actType)



    if leftNum <= 0 then
        gShowNotice(gGetWords("noticeWords.plist","act_atlas_no_batnum"));
        return false;
    end

    if hasCdTime then
        local word = gGetWords("noticeWords.plist","act_atlas_cd",gActAtlasInfo.clearCdNeddDia)
        local function onOk()
            Net.sendAtlasActClearCD(actType);
        end
        gConfirmCancel(word,onOk);
        return false;
    end

    if Data.getCurEnergy() < needEnergy then
        NetErr.noEnoughEnergy();
        return false;
    end

    return true;
end

function NetErr.CardExpUpgrade(cardlevel)

    if gUserInfo.cexp <= 0 then
        gShowNotice(gGetWords("noticeWords.plist","card_levelup_noexp"));
        return false;
    end
    if cardlevel >= Data.getCurLevel() then
        gShowNotice(gGetWords("noticeWords.plist","card_levelup_tip",Data.getCurLevel()));
        return false;
    end
    return true;
end

function NetErr.DrinkLoot()
    if Data.trainroom.myselfInfo.leftLootTimes <= 0 then
        local callback = function()
            Data.buyTrainLootTimes();
        end
        gConfirmAll(gGetWords("trainWords.plist","no_times"),callback);
        return false;
    end
    return true;
end

function NetErr.isBelongRoom(roomid)
    for key,room in pairs(drinkroom_db) do
        if (room.roomid == roomid) then
            if Data.getCurLevel() >= room.minlv and Data.getCurLevel() <= room.maxlv then
                return true;
            end
        end
    end
    gShowNotice(gGetWords("trainWords.plist","21"));
    return false;
end

function NetErr.BuyShopItem(constType,constPrice)
    if(constType==OPEN_BOX_DIAMOND)then
        if NetErr.isDiamondEnough(constPrice) == false then
            return false;
        end
    elseif(constType==OPEN_BOX_GOLD)then
        if NetErr.isGoldEnough(constPrice) == false then
            return false;
        end
    elseif(constType == OPEN_BOX_REPU)then
        -- print("gUserInfo.reputation = "..gUserInfo.reputation);
        -- print("constPrice = "..constPrice);
        if Data.getCurRepuNum() < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_repu"));
            return false;
        end
    elseif(constType == OPEN_BOX_FAMILY_DEVOTE)then
        if Data.getCurFamilyExp() < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_devote"));
            return false;
        end
    elseif(constType == OPEN_BOX_PETMONEY)then
        if Data.getCurPetMoney() < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_pet_money"));
            return false;
        end
    elseif(constType == OPEN_BOX_SOULMONEY)then
        if Data.getCurSoulMoney() < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_soul_money"));
            return false;
        end
    elseif(constType == OPEN_BOX_SERVERBATTLE)then
        if gServerBattle.exp < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_serverbattle"));
            return false;
        end
    elseif(constType == OPEN_BOX_TOWERMONEY)then
        if gUserInfo.towermoney < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_towermoney"));
            return false;
        end
    elseif(constType == OPEN_BOX_FAMILY_MONEY)then
        if gUserInfo.famoney < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_famoney"));
            return false;
        end
    elseif(constType == OPEN_BOX_CONSTELLATION_SOUL)then
        if gConstellation.getSoulNum() < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_consmoney"));
            return false;            
        end  
    elseif(constType == OPEN_BOX_SNATCH_MONEY)then
        if Data.getSnatchScore() < constPrice then
            gShowNotice(gGetWords("noticeWords.plist","no_snatchmoney"));
            return false;            
        end      
    end

    return true;

end

function NetErr.noEnoughLevel(needLevel)
    if Data.getCurLevel() < needLevel then
        gShowNotice(gGetWords("noticeWords.plist","no_level"));
        return false;
    end
    return true;
end

function NetErr.FamilyUpgrade()

    if(Data.getCurFamilyLv() >= Data.family.maxLevel)then
        gShowNotice(gGetWords("noticeWords.plist","family_maxlevel"));
        return false;
    end

    return true;
end

function NetErr.BuddyAccept()
    local friendCount = table.count(gFriend.myFriends);
    if(friendCount>=Data.friend.maxFriendCount)then
        gShowNotice(gGetWords("noticeWords.plist","friend_full"));
        return false;
    end
    return true;
end

function NetErr.CardWaken(itemNum,cardid,soulNum,goldNum,isShowNotice)
    if(isShowNotice==nil)then
        isShowNotice = true;
    end
    --觉醒丹
    local itemEnough = NetErr.isItemEnough(ITEM_AWAKE,itemNum,isShowNotice);
    if(itemEnough == false)then
        return false;
    end
    --魂魄
    local curSoulNum=Data.getSoulsNumById(cardid)
    if(curSoulNum < soulNum)then
        if(isShowNotice)then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_item",DB.getItemName( toint("1"..cardid)) ))
        end
        return false;
    end

    --金币
    local goldEnough = NetErr.isGoldEnough(goldNum,isShowNotice);
    if(goldEnough == false)then
        return false;
    end
    return true;
end

function NetErr.isDrawGoldBuyEnough(num)
    if Data.getItemNum(ITEM_DRAW_GOLD_BUY) >= num then
        return true
    else
        gShowNotice(gGetWords("noticeWords.plist","no_draw_gold_item"))
        return false
    end
end
