
--卡牌经验
function Net.sendCardExpUpgrade(cardid,num)

    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setInt("num",num)
     Net.sendCardExpUpgradeParam=cardid
    Net.sendExtensionMessage(media, CMD_CARD_EXP_UPGRADE)
end
function Net.recCardExpUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"))
    -- table.remove(CardPro.expNetStack,1) 
    CardPro.setCardAttr(  Data.getUserCardById(Net.sendCardExpUpgradeParam))
    gDispatchEvt(EVENT_ID_UPDATE_REWORDS)
end


--卡牌升星
function Net.sendCardEvolve(cardid)

    local media=MediaObj:create()
    media:setInt("cid",cardid)
    Net.sendExtensionMessage(media, CMD_CARD_EVOLVE)
end




function Net.recCardEvolve(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local cardid=obj:getInt("cid")
    Data.reduceSoulNum(cardid,obj:getShort("num"))
    Net.parseUserInfo(obj:getObj("uvobj"))
    local card=Data.getUserCardById(cardid)
    card.grade=card.grade+1
    card.needRefresh = true;
    CardPro.setCardAttr(  card)
    gDispatchEvt(EVENT_ID_CARD_EVOLVE,{cardid=cardid})
end




--卡牌升星
function Net.sendCardIngore(cardid,ign)

    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setBool("ign",ign)
    Net.sendExtensionMessage(media, "card.ignore")
end




function Net.rec_card_ignore(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end  
    local card=Net.parseUserCard(obj:getObj("card"))
    Data.updateUserCard(card) 
    RedPoint.bolCardViewDirty=true
    RedPoint.bolCardDataDirty=true
    gDispatchEvt(EVENT_ID_CARD_INGORE,card)
end

--卡牌觉醒
function Net.sendCardWaken(cardid)
    local media=MediaObj:create()
    media:setInt("cid",cardid)
    Net.sendExtensionMessage(media, "card.waken");
end

function Net.rec_card_waken(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.parserIcon(obj);
    Net.updateReward(obj:getObj("reward"),0);
    local card=Net.parseUserCard(obj:getObj("card"),false)  
    local oldCard=Data.getUserCardById(card.cardid)
    CardPro.setCardAttr(card,nil,oldCard)
    Data.updateUserCard(card)
    gDispatchEvt(EVENT_ID_CARD_AWAKE,card)
    gLogEvent("card.waken",{cardid=tostring(card.cardid)})
end

function Net.sendSaveTeam(type,cards)

    local media=MediaObj:create()
    media:setInt("type",type)
    if(cards[PET_POS])then
        media:setInt("pet",cards[PET_POS])
    else
        media:setInt("pet",0)
    end
    local vector_int_ = vector_int_:new_local()

    for i=0, MAX_TEAM_NUM-2 do 
        if(cards[i])then
            vector_int_:push_back(cards[i])
        else
            vector_int_:push_back(0)
        end
    end 
    print("save team")
    media:setIntArray("card",vector_int_)
    Net.sendExtensionMessage(media, CMD_TEAM_SAVE) 
end

function Net.rec_team_save(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDispatchEvt(EVENT_ID_SAVE_FORMATION)
end

--卡牌突破
function Net.sendCardUpQuality(cardid)
    local media=MediaObj:create()
    media:setInt("cid",cardid)
    Net.sendExtensionMessage(media, CMD_CARD_AWAKEN)
end

--卡牌突破




function Net.recCardUpQuality(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local cardid=obj:getInt("cid")
    local card=Data.getUserCardById(cardid)
    card.quality=card.quality+1
    card.needRefresh = true
    CardPro.setCardAttr(  card)
    gDispatchEvt(EVENT_ID_CARD_UP_QUALITY ,{cardid=cardid})
    gLogEvent("card.upquality", {cardid=cardid})

end

--装备激活
function Net.sendEquipActivate(cardid,idx,pos)

    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setByte("pos",idx)
    media:setByte("apos",pos)
    Net.sendExtensionMessage(media, CMD_EQU_ACTIVATE)
end


function Net.recEquipActivate(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gShowNotice(gGetWords("noticeWords.plist","data_error"))
        Net.sendRefreshData()
        return
    end

    local cardid=obj:getInt("cid")
    local pos=obj:getByte("pos")
    local apos=obj:getByte("apos")
    local card=Data.getUserCardById(cardid)
    local aciviate=card.equipActives[pos]
    local ret= CardPro.setActivate(aciviate,apos)
    card.equipActives[pos]=  ret
    Net.updateReward(obj:getObj("reward"),0)
    CardPro.setCardAttr(  card)
    gDispatchEvt(EVENT_ID_EQUIP_ACTIVATE,{pos=pos,apos={apos}})

end

--装备一键激活
function Net.sendEquipActivateOneKey(cardid,idx,poses)

    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setByte("pos",idx)


    local vector_int_ = vector_int_:new_local() 
    for key, pos in pairs(poses) do
        vector_int_:push_back(pos)
    end
    media:setIntArray("plist",vector_int_)

    Net.sendExtensionMessage(media, CMD_EQU_ACTIVATE_ONEKEY)
end


function Net.recEquipActivateOneKey(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then 
        gShowNotice(gGetWords("noticeWords.plist","data_error"))
        Net.sendRefreshData()
        return
    end
    Net.hasRecEquipActivateOneKey=true 
    local cardid=obj:getInt("cid")
    local pos=obj:getByte("pos") 
    local card=Data.getUserCardById(cardid)

    local plistArrays=obj:getIntArray("plist")
    local aciviate=card.equipActives[pos]
    local apos={}
    if(plistArrays)then
        for i=0, plistArrays:size()-1 do
            aciviate= CardPro.setActivate(aciviate,plistArrays[i]) 
            table.insert(apos,plistArrays[i])
        end
    end 
     
    if(table.count(apos)==0)then
        gShowNotice(gGetWords("noticeWords.plist","data_error"))
        Net.sendRefreshData()
    end

    card.equipActives[pos]=  aciviate
    Net.updateReward(obj:getObj("reward"),0)
    CardPro.setCardAttr(  card)
    gDispatchEvt(EVENT_ID_EQUIP_ACTIVATE,{pos=pos ,apos=apos})

end






function Net.sendRefreshData()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "sys.checkbag")

end

function Net.rec_sys_checkbag(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then 
        return
    end
    local userInfo=obj:getObj("info")
    Net.parseUserInfo(userInfo)
    
    gUserEquipItems={}
    local equipItem=obj:getArray("equitem")
    if(equipItem)then
        equipItem=tolua.cast(equipItem,"MediaArray")
        for i=0, equipItem:count()-1 do
            table.insert(gUserEquipItems,Net.parseEquipItem(equipItem:getObj(i)))
        end
    end
    
    gUserItems={}
    gDigMine.userMineItems={}
    local userItem=obj:getArray("item")
    if(userItem)then
        userItem=tolua.cast(userItem,"MediaArray")
        for i=0, userItem:count()-1 do
            local item = Net.parseUserItem(userItem:getObj(i))
            if Data.isMineItem(item.itemid) then
                table.insert(gDigMine.userMineItems, item)
            else
                table.insert(gUserItems,item)
            end

        end
    end
    
    gUserShared={}
    local userShared=obj:getArray("eshard")
    if(userShared)then
        userShared=tolua.cast(userShared,"MediaArray")
        for i=0, userShared:count()-1 do
            table.insert(gUserShared,Net.parseUserShared(userShared:getObj(i)))
        end
    end
    
    
    gUserCards={}
    local userCards=obj:getArray("card")
    userCards=tolua.cast(userCards,"MediaArray")
    for i=0, userCards:count()-1 do
        table.insert(gUserCards,Net.parseUserCard(userCards:getObj(i),false))
    end

    CardPro.setAllCardAttr(true)
    gDispatchEvt(EVENT_ID_REFRESH_DATA)
end

--装备强化
function Net.sendEquipUpgrade(cardid,idx,quick)
    if(NetErr.cardEquipUpgrade(cardid,idx)==false)then
        return 
    end
    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setByte("pos",idx)
    media:setBool("quick",quick)
    Net.sendExtensionMessage(media, CMD_EQU_UPGRADE)
end


function Net.recEquipUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local cardid=obj:getInt("cid")
    local card=Data.getUserCardById(cardid)
    local pos=obj:getByte("pos")
    local lv=obj:getByte("lv")
    card.equipLvs[pos]= card.equipLvs[pos]+lv
    Net.parseUserInfo(obj:getObj("uvobj"))
    CardPro.setCardAttr(  card)
    gDispatchEvt(EVENT_ID_EQUIP_UPGRADE,pos)

end





--装备升品
function Net.sendEquipUpQuality(cardid,idx)

    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setByte("pos",idx)
    Net.sendExtensionMessage(media, CMD_EQU_UPQUALITY)
end


function Net.recEquipUpQuality(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then

        gShowNotice(gGetWords("noticeWords.plist","data_error"))
        Net.sendRefreshData()
        return 
    end
    local cardid=obj:getInt("cid")
    local card=Data.getUserCardById(cardid)
    local pos=obj:getByte("pos")
    card.equipQuas[pos]= card.equipQuas[pos]+1
    card.equipActives[pos]=0
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    Net.updateReward(obj:getObj("reward"),0);
    CardPro.setCardAttr(  card)
    gDispatchEvt(EVENT_ID_EQUIP_UPQUALITY,{pos=pos,cardid=cardid})
    gLogEvent('equ.upquality', {cid=tostring(cardid),pos=tostring(pos)})
end


--装备合成
function Net.sendEquipItemMerge(itemid)
    if(NetErr.cardEquipItemMerge(itemid)==false)then
        return 
    end
    local media=MediaObj:create()
    media:setInt("id",itemid) 
    Net.equipItemMergeId=itemid
    Net.sendExtensionMessage(media, CMD_EQU_MERGE)
end


 

function Net.recEquipItemMerge(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
     Net.updateReward(obj:getObj("reward"),0)
--[[
    local item=DB.getEquipItemById(Net.equipItemMergeId)
    if(item==nil)then
        return
    end
    Data.reduceSharedNum(Net.equipItemMergeId,item.com_num)
    Data.addEquipItemNum(Net.equipItemMergeId,1) 
    ]]
    gDispatchEvt(EVENT_ID_EQUIP_MERGE)
    gDispatchEvt(EVENT_ID_UPDATE_REWORDS)
end

--升级技能
function Net.sendSkillUpgrade(cardid,idx)
    if(NetErr.cardSkillUpgrade(cardid,idx)==false)then
        return 
    end
    local media=MediaObj:create()
    media:setInt("cid",cardid)
    media:setByte("pos",idx)
    Net.sendExtensionMessage(media, CMD_SKILL_UPGRADE)
end


function Net.recSkillUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local cardid=obj:getInt("cid")
    local card=Data.getUserCardById(cardid)
    local pos=obj:getByte("pos")
    local oldCard=clone(card)
    card.skillLvs[pos]= card.skillLvs[pos]+1
    Net.parseUserInfo(obj:getObj("uvobj"))
    CardPro.setCardAttr(  card,true,oldCard) 
    local oldPower=CardPro.countPower(oldCard)
    local newPower=CardPro.countPower(card)
    AttChange.pushPower(PANEL_CARD_INFO, oldPower,newPower)
    CardPro.showSkillLevelUpDesc(card ,pos,card.skillLvs[pos])
    gDispatchEvt(EVENT_ID_SKILL_UPGRADE)

end


--技能快速升级
function Net.sendSkillQuickUpgrade(cardid)
    -- if(NetErr.cardSkillUpgrade(cardid,idx)==false)then
    --     return 
    -- end
    local media=MediaObj:create()
    media:setInt("cid",cardid)
    Net.sendExtensionMessage(media, CMD_SKILL_QUICK_UPGRADE)
end

function Net.recSkillQuickUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local cardid=obj:getInt("cid")
    local card=Data.getUserCardById(cardid)
    local oldCard=clone(card)
    local posArray=obj:getIntArray("pos")
    if posArray then
        for i=0,posArray:size()-1 do
            card.skillLvs[i]= card.skillLvs[i]+posArray[i]
        end
    end
    Net.parseUserInfo(obj:getObj("uvobj"))
    CardPro.setCardAttr(  card,true,oldCard) 
    -- local oldPower=CardPro.countPower(oldCard)
    -- local newPower=CardPro.countPower(card)
    -- AttChange.pushPower(PANEL_CARD_INFO, oldPower,newPower)
    -- for i=0,4 do
    --     CardPro.showSkillLevelUpDesc(card ,i,card.skillLvs[i])
    -- end
    Panel.popUp(PANEL_CARD_SKILL_LEVELUP,oldCard,card)
    --gDispatchEvt(EVENT_ID_SKILL_UPGRADE)
end

--合成卡牌
function Net.sendCardRecurit(cardid)
    local media=MediaObj:create()
    media:setInt("cid",cardid)
    Net.sendExtensionMessage(media, CMD_CARD_RECURIT)
end


function Net.recCardRecurit(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end 

    local cid=obj:getInt("cid")
    local num=obj:getInt("num")

    Data.reduceSoulNum(cid,num)
    table.insert(gUserCards,Net.parseUserCard(obj:getObj("card")))

    CardPro.setAllCardAttr(true) 
    
    
    Panel.popUp(PANEL_NEW_CARD, {id = cid, num=num})
    gDispatchEvt(EVENT_ID_CARD_RECURIT)
end


--购买技能点
function Net.sendBuySkillPoint()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ITEM_DIAMOND_BUY_SKILLPOINT)
end


function Net.recBuySkillPoint(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    Net.parserVipBuy(obj:getObj("vipbn"))
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    -- gShowNotice(gGetWords("labelWords.plist","lab_buy_success"))
    gDispatchEvt(EVENT_ID_GOLBAL_BUY)
end


function Net.sendCardActivateRelation(rid,level)
    local media=MediaObj:create()
    media:setInt("rid",rid) 
    media:setByte("lv",level) 
    Net.sendExtensionMessage(media, CMD_CARD_ACTIVATE_RELATION)
end


function Net.recCardActivateRelation(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local relation=Net.parseRelationItem(obj:getObj("relation"))
    Data.updateRelation( relation)
    
    local db=DB.getRelationById(relation.id,relation.level)
    
    local cards=string.split(db.cardlist,";")
 
    for key, cardid in pairs(cards) do
        local card=Data.getUserCardById(toint(cardid))
        if(card)then
            CardPro.setCardAttr(  card) 
        end
    end
    
    Panel.popUp(PANEL_CARD_NEW_RELATION,relation)

    if(relation.id >= 1000)then
        CardPro.setAllCardAttr() 
        gDispatchEvt(EVENT_ID_PET_NEW_RELATION,relation)
    end
end


 
function Net.sendEquipQuickUpgrade(cid)
    local media=MediaObj:create()
    media:setInt("cid",cid) 
    Net.sendExtensionMessage(media, CMD_EQU_QUICKUPGRADE)
end


function Net.recEquipQuickUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local card=Net.parseUserCard(obj:getObj("card"))
 
    local oldCard=clone(Data.getUserCardById(card.cardid) )
    
    Data.updateUserCard(card)
    Net.parseUserInfo(obj:getObj("uvobj"))
    
    local plistArrays=obj:getIntArray("plist") 
    local apos={}
    if(plistArrays)then
        for i=0, plistArrays:size()-1 do 
            table.insert(apos,plistArrays[i])
        end
    end 
    local card=Data.getUserCardById(card.cardid) 
    CardPro.setCardAttr(  card,nil,oldCard)
    
    gDispatchEvt(EVENT_ID_CARD_QUIKE_EQUIP_UPGRADE,{apos=apos})
end

--回炉
function Net.sendCardRecycle(cid,soul)
    local media=MediaObj:create()
    media:setInt("cid",cid) 
    if(soul==nil)then
        soul=false
    end 
    media:setBool("soul",soul) 
    Net.sendExtensionMessage(media, "card.recycle");
end

function Net.rec_card_recycle(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    if obj:containsKey("rela") then 
        local relationArray = obj:getArray("rela")
        if nil ~= relationArray then
            relationArray = tolua.cast(relationArray,"MediaArray")
            for i=0, relationArray:count()-1 do
                local data=Net.parseRelationItem(relationArray:getObj(i))
                gRelations[data.id]=data.level
            end
        end
    end
  
    
    
    Net.parserIcon(obj); 
    local rewards= Net.updateReward(obj:getObj("reward"),0);
    local card=Net.parseUserCard(obj:getObj("card"))
    Data.updateUserCard(card)
    CardPro.setAllCardAttr(true) 
    Panel.popUp(PANEL_CARD_TRANSMIT_RESULT,rewards,card) 
    gDispatchEvt(EVENT_ID_REFRESH_TRANSMIT_RESULT)
end





function Net.sendCardExchange(cid,tcid)
    local media=MediaObj:create()
    media:setInt("tcid",cid)  
    media:setInt("cid",tcid) 
    Net.sendExtensionMessage(media, "card.exchange");
end

function Net.rec_card_exchange(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateSoulsReward(obj:getObj("soul1"))
    Net.updateSoulsReward(obj:getObj("soul2"))
    Net.parserIcon(obj );
    gUserTreasure={}
    local treasureItem=obj:getArray("treasure")
    if(treasureItem)then
        treasureItem=tolua.cast(treasureItem,"MediaArray")
        for i=0, treasureItem:count()-1 do
            table.insert(gUserTreasure,Net.parseTreasureItem(treasureItem:getObj(i)))
        end
    end
     
    local rewards= Net.updateReward(obj:getObj("reward"),0);
    local card=Net.parseUserCard(obj:getObj("card"))
    Data.updateUserCard(card)
    local card=Net.parseUserCard(obj:getObj("tcard"))
    Data.updateUserCard(card)
    
    
    if obj:containsKey("rela") then 
        local relationArray = obj:getArray("rela")
        if nil ~= relationArray then
            relationArray = tolua.cast(relationArray,"MediaArray")
            for i=0, relationArray:count()-1 do
                local data=Net.parseRelationItem(relationArray:getObj(i))
                gRelations[data.id]=data.level
            end
        end
    end
    

    CardPro.setAllCardAttr(true) 
    gDispatchEvt(EVENT_ID_EXCHANGE_CARD_RESULT)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
     
end


function Net.sendTreasureExchange(tid,etid)
    local media=MediaObj:create()
    media:setLong("tid",tid)  
    media:setInt("etid",etid) 
    Net.sendExtensionMessage(media, "treasure.exchange");
end

function Net.rec_treasure_exchange(evt)
     local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    local treasure=Net.parseTreasureItem(obj:getObj("tobj"))
    Data.updateTreasureById(treasure)
    gDispatchEvt(EVENT_TREASURE_EXCHANGE,treasure)
end


