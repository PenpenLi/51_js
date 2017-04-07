


function Net.sendCardRaiseInfo(tab)
    local media=MediaObj:create()
    Net.sendCardRaiseInfoParam=tab
    Net.sendExtensionMessage(media, CMD_CARD_RAISE_INFO)
end


function Net.recCardRaiseInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local list_ = obj:getArray("card");
    if list_ ~= nil then
        for i = 0,list_:count()-1 do
            local list_obj = list_:getObj(i);
            local list_data = {};
            if list_obj ~= nil then
                list_data = Net.parseRaiseObj(list_obj)
                ret[list_data.cardid]=list_data
            end
        end
    end


    Panel.popUp(PANEL_CARD_WEAPON_RAISE,ret, Net.sendCardRaiseInfoParam)
end



function Net.sendEquMelt(data)
    local media=MediaObj:create()
    local array=MediaArray:create()
    for key, var in pairs(data) do
        local obj=MediaObj:create()
        obj:setInt("id", var.itemid)
        obj:setInt("num", var.num)
        array:addObj(obj)
    end
    media:setObjArray("list", array)
    Net.sendExtensionMessage(media, CMD_EQU_MELT)
end


function Net.revEquMelt(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_REFRESH_EQUIP_SOUL)

end


function Net.sendCardRaise(cid,type,num)
    local media=MediaObj:create()
    media:setInt("cid", cid)
    media:setByte("type", type)
    media:setByte("num", num)
    Net.sendExtensionMessage(media, CMD_CARD_RAISE)
end


function Net.recCardRaise(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local raiseObj= Net.parseRaiseObj(obj:getObj("ucr"))
    Net.updateReward(obj:getObj("reward"),0);
    gDispatchEvt(EVENT_ID_REFRESH_CARD_RAISE,raiseObj)
end


function Net.sendCardRaiseConfirm(cid,save)
    local media=MediaObj:create()
    media:setInt("cid", cid)
    media:setBool("ifc", save)
    Net.sendExtensionMessage(media, CMD_CARD_RAISE_CONFIRM)
end


function Net.recCardRaiseConfirm(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local raiseObj= Net.parseRaiseObj(obj:getObj("ucr"))
    Net.updateReward(obj:getObj("reward"),0);
    local card=Net.parseUserCard(obj:getObj("uc"))
    Data.updateUserCard(card )
    CardPro.setCardAttr(card)
    gDispatchEvt(EVENT_ID_CONFIRM_CARD_RAISE,raiseObj)

end



function Net.sendCardRaiseUpgrade(cid,rateadd)
    local media=MediaObj:create()
    media:setInt("cid", cid)
    Net.sendCardRaiseUpgradeParam=cid
    media:setInt("rateadd", rateadd)
    Net.sendExtensionMessage(media, CMD_CARD_WEAPON_UPGRADE)
end


function Net.recCardRaiseUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_WEAPON_UPGRADE,{id=Net.sendCardRaiseUpgradeParam,ret=false})
        return
    end

    local success=obj:getBool("suc")
    local card=Data.getUserCardById(Net.sendCardRaiseUpgradeParam)
    if(success)then
        card.weaponLv=card.weaponLv+1
        card.needRefresh = true;
        CardPro.setCardAttr(  card) 
    end
    Net.updateReward(obj:getObj("reward"),0);
    gDispatchEvt(EVENT_ID_WEAPON_UPGRADE,{id=Net.sendCardRaiseUpgradeParam,ret=success})
    gLogEvent("weapon.upgrade", {cardid=tostring(Net.sendCardRaiseUpgradeParam)})
end



function Net.sendCardRaiseTransmit(tcid,cid)
    local media=MediaObj:create()
    media:setInt("cid", cid)
    media:setInt("tcid", tcid)

    Net.sendCardRaiseTransmitParam={}
    Net.sendCardRaiseTransmitParam.card1=tcid
    Net.sendCardRaiseTransmitParam.card2=cid
    Net.sendExtensionMessage(media, CMD_CARD_TRANSMIT)
end


function Net.recCardRaiseTransmit(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local card=Net.parseUserCard(obj:getObj("tcard"))
    Data.updateUserCard(card )


    card=Net.parseUserCard(obj:getObj("card"))
    Data.updateUserCard(card )

    Net.updateReward(obj:getObj("reward"),0);
    Panel.popUp(PANEL_CARD_WEAPON_TRANSMIT_RESULT,card)
    gDispatchEvt(EVENT_ID_REFRESH_TRANSMIT_RESULT)
    
end


function Net.sendCardWpexTransmit(cid,ecid)
    local media=MediaObj:create()
    media:setInt("cid", cid)
    media:setInt("ecid", ecid)

    Net.sendCardRaiseTransmitParam={}
    Net.sendCardRaiseTransmitParam.card1=cid
    Net.sendCardRaiseTransmitParam.card2=ecid
    Net.sendExtensionMessage(media, "card.wpex")
end


function Net.rec_card_wpex(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ecard=Net.parseUserCard(obj:getObj("ecard"))
    Data.updateUserCard(ecard )

    local card=Net.parseUserCard(obj:getObj("card"))
    Data.updateUserCard(card )

    Net.updateReward(obj:getObj("reward"),0);

   local ucr = Net.parseRaiseObj(obj:getObj("ucr"))
   local eucr = Net.parseRaiseObj(obj:getObj("eucr"))

    Panel.popUp(PANEL_CARD_WEAPON_EXCHANGE_RESULT,card,ecard)
    gDispatchEvt(EVENT_ID_REFRESH_TRANSMIT_RESULT)
    
end



function Net.sendCardSoulMelt(data)
    local media=MediaObj:create()
    local array=MediaArray:create()
    for key, var in pairs(data) do
        local obj=MediaObj:create()
        obj:setInt("cid", var.itemid-ITEM_TYPE_SHARED_PRE)
        obj:setInt("num", var.num)
        array:addObj(obj) 
    end
    media:setObjArray("list", array)
    Net.sendExtensionMessage(media, "card.soulmelt")
end


function Net.rec_card_soulmelt(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2); 
    local userSouls=obj:getArray("slist")
    if(userSouls)then
        userSouls=tolua.cast(userSouls,"MediaArray")
        for i=0, userSouls:count()-1 do
            Net.updateSoulsReward(userSouls:getObj(i)) 
        end
    end

    gDispatchEvt(EVENT_ID_REFRESH_CARD_SOUL)

end



function Net.sendCardSoulBuy(cid,num)
    local media=MediaObj:create() 
    media:setInt("cid", cid)
    media:setInt("num", num)
    Net.sendExtensionMessage(media, "card.soulbb")
end


function Net.rec_card_soulbb(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2); 
    local userSouls=obj:getArray("slist")
    if(userSouls)then
        userSouls=tolua.cast(userSouls,"MediaArray")
        for i=0, userSouls:count()-1 do
            Net.updateSoulsReward(userSouls:getObj(i)) 
        end
    end 
    gDispatchEvt(EVENT_ID_REFRESH_CARD_SOULBUY)

end


                                       
