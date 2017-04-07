

function Net.sendTreasureSyn(id)
    local media=MediaObj:create()
    media:setInt("id",id);
    Net.sendExtensionMessage(media, "treasure.syn")
end


function Net.rec_treasure_syn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local treasure=Net.parseTreasureItem(obj:getObj("tobj"))
    table.insert(gUserTreasure,treasure)


    gShowItemPoolLayer:pushItems({{id=treasure.itemid,num=1}});
    local db=DB.getTreasureById(treasure.itemid)
    Data.reduceItemNum(db.com_item1,db.com_num1)
    Data.reduceTreasureSharedNum(treasure.itemid,db.com_num)
    gDispatchEvt(EVENT_ID_TREASURE_MERGE,treasure)
end



function Net.sendTreasureDecompose(id)
    local media=MediaObj:create()
    media:setLong("tid",id);
    Net.sendExtensionMessage(media, "treasure.decompose")
end


function Net.rec_treasure_decompose(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    local id=obj:getLong("tid")
    local treasure=Data.getTreasureById(id)
    Data.removeTreasureById(id)
    gDispatchEvt(EVENT_ID_TREASURE_DECOMPOSE,treasure)
end




function Net.sendTreasureUpgrade(tid,num)
    local media=MediaObj:create()
    media:setLong("tid",tid);
    media:setInt("num",num);
    Net.sendExtensionMessage(media, "treasure.upgrade")
end


function Net.rec_treasure_upgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2);
    local id=obj:getLong("tid")
    local treasure=Data.getTreasureById(id)
    local oldCard=clone(Data.getUserCardById(treasure.cardid) )

    local preLevel=treasure.upgradeLevel
    treasure.decomposeGold=obj:getInt("gold")
    local lvArray=obj:getIntArray("lvlist")
    if(lvArray)then
        for i=0, lvArray:size()-1 do
            treasure.upgradeLevel=lvArray[i]
            AttChange.pushAttBaoji(PANEL_TREASURE,1,gGetWords("treasureWord.plist","9").."+"..(treasure.upgradeLevel-preLevel),treasure.upgradeLevel-preLevel);
            preLevel=treasure.upgradeLevel
        end
    end
    Net.sortTreasure(treasure)
    CardPro.setCardAttr(  Data.getUserCardById(treasure.cardid),nil,oldCard)
    gDispatchEvt(EVENT_ID_TREASURE_UPGRADE,treasure)

end


function Net.sendTreasureQuenchOneKey(tid,itemids,nums)
    local media=MediaObj:create()
    media:setLong("tid",tid);
    local array=MediaArray:create()
    for key, var in pairs(itemids) do
        if(nums[key]>0)then 
            local obj=MediaObj:create()
            obj:setInt("itemid", var)
            obj:setInt("num", nums[key])
            array:addObj(obj) 
        end
    end
    media:setObjArray("mlist", array)
    Net.sendExtensionMessage(media, "treasure.okquench")
end


function Net.rec_treasure_okquench(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local tid=obj:getLong("tid")
    local treasure=Data.getTreasureById(tid)
    if(treasure)then
        local oldCard=clone(Data.getUserCardById(treasure.cardid))
        treasure.quenchLevel=obj:getInt("qlv")
        treasure.quenchExp=obj:getInt("qexp") 
        
        local card=Data.getUserCardById(treasure.cardid) 
        CardPro.setCardAttr(card,nil,oldCard)
    end
    Net.updateReward(obj:getObj("reward"),2);

    gDispatchEvt(EVENT_ID_TREASURE_QUENCH,treasure)

end



function Net.sendTreasureQuench(tid,itemid,num)
    local media=MediaObj:create()
    media:setLong("tid",tid);
    media:setInt("itemid",itemid);
    media:setInt("num",num);
    Net.sendExtensionMessage(media, "treasure.quench")
end


function Net.rec_treasure_quench(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    --[[
    local tid=obj:getLong("tid")
    local treasure=Data.getTreasureById(tid)
    if(treasure)then
    treasure.quenchLevel=obj:getInt("qlv")
    treasure.quenchExp=obj:getInt("qexp")
    end
    Net.updateReward(obj:getObj("reward"),2);

    gDispatchEvt(EVENT_ID_TREASURE_QUENCH,treasure)
    ]]

end


function Net.sendTreasureWear(cardid,tid)
    local media=MediaObj:create()
    media:setInt("cardid",cardid);
    media:setLong("tid",tid);
    Net.sendExtensionMessage(media, "treasure.wear")
end


function Net.rec_treasure_wear(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local oldTreasure=nil
    if(obj:containsKey("oldtid"))then
        local id=obj:getLong("oldtid")
        local treasure=Data.getTreasureById(id)
        treasure.cardid=0
        oldTreasure=treasure
    end

    local card=Net.parseUserCard(obj:getObj("card"),false)

    local id=obj:getLong("tid")
    local treasure=Data.getTreasureById(id)
    treasure.cardid=card.cardid

    local oldCard=Data.getUserCardById(card.cardid)
    CardPro.setCardAttr(card,nil,oldCard)
    Data.updateUserCard(card)
    gDispatchEvt(EVENT_ID_TREASURE_WEAR,{treasure=treasure,oldTreasure=oldTreasure})
end


function Net.sendTreasureUnload(cardid,tid)
    local media=MediaObj:create()
    media:setInt("cardid",cardid);
    media:setLong("tid",tid);
    Net.sendExtensionMessage(media, "treasure.unload")
end


function Net.rec_treasure_unload(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local id=obj:getLong("tid")
    local treasure=Data.getTreasureById(id)
    treasure.cardid=0
    local card=Net.parseUserCard(obj:getObj("card"),false)
    local oldCard=Data.getUserCardById(card.cardid)
    CardPro.setCardAttr(card,nil,oldCard)
    Data.updateUserCard(card)
    gDispatchEvt(EVENT_ID_TREASURE_TAKE_OFF,treasure)
end

--一键分解
function Net.sendTreasureOkDecompose(listItems)
    local media=MediaObj:create()
    local vectorIds = vector_long2X_:new_local();
    for k, v in pairs(listItems) do
        vectorIds:push_back(v)
    end
    media:setLongArray("list", vectorIds);
    Net.sendExtensionMessage(media, "treasure.okdecompose")
end

function Net.rec_treasure_okdecompose(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local treasureList= {}
    Net.updateReward(obj:getObj("reward"),2)
    local listIds = obj:getArray("list");
    if(listIds)then
        listIds=tolua.cast(listIds,"MediaArray")
        for i=0, listIds:count()-1 do
            local objItem = tolua.cast(listIds:getObj(i),"MediaObj") 
            local  id = objItem:getLong("id")
            local treasure=Data.getTreasureById(id)
            treasureList[treasure.id] = treasure
            Data.removeTreasureById(id)
        end
    end

    gDispatchEvt(EVENT_ID_TREASURE_OKDECOMPOSE,treasureList)
end

--一键合成
function Net.sendTreasureoOksyn(id,num)
    local media=MediaObj:create()
    media:setInt("id", id);
    media:setInt("num", num);
    Net.sendExtensionMessage(media, "treasure.oksyn")
    
end

function Net.rec_treasure_oksyn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local treasureList= {}
    local synList=obj:getArray("tlist")
    if(synList)then
        synList=tolua.cast(synList,"MediaArray")
        for i=0, synList:count()-1 do
            local treasure=Net.parseTreasureItem(synList:getObj(i))
            table.insert(gUserTreasure,treasure)

            gShowItemPoolLayer:pushItems({{id=treasure.itemid,num=1}});
            local db=DB.getTreasureById(treasure.itemid)
            Data.reduceItemNum(db.com_item1,db.com_num1)
            Data.reduceTreasureSharedNum(treasure.itemid,db.com_num)
            table.insert(treasureList,treasure)
        end
    end
    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_TREASURE_OKMERGE,treasureList)
end


--魔纹升星
function Net.sendTreasureStarup(tid,type)
    local media=MediaObj:create()
    media:setLong("tid", tid);
    media:setByte("type",type)
    Net.sendExtensionMessage(media, "treasure.starup")
end

function Net.rec_treasure_starup(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local id=obj:getLong("tid")
    local treasure=Data.getTreasureById(id)
    local oldCard=clone(Data.getUserCardById(treasure.cardid) )

    local preLevel=treasure.starexp
    local isCritical = obj:getBool("double")
    treasure=Net.parseTreasureItem(obj:getObj("tobj"))
    if isCritical then
        AttChange.pushAttBaoji(PANEL_TREASURE,1,gGetWords("treasureWord.plist","26").."+"..(treasure.starexp-preLevel),2);
    else
        AttChange.pushAttBaoji(PANEL_TREASURE,1,gGetWords("treasureWord.plist","26").."+"..(treasure.starexp-preLevel),0);
    end
    Net.updateReward(obj:getObj("reward"),0)
    Data.updateTreasureById(treasure)
    CardPro.setCardAttr(  Data.getUserCardById(treasure.cardid),nil,oldCard)
    gDispatchEvt(EVENT_ID_TREASURE_RISESTAR,isCritical)
end

--纹耀技能升级
function Net.sendTreasureStarSkillUp(tid,sid)
    local media=MediaObj:create()
    media:setLong("tid", tid);
    media:setInt("sid",sid)
    Net.sendExtensionMessage(media, "treasure.starskillup")
end

function Net.rec_treasure_starskillup(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local treasure=Net.parseTreasureItem(obj:getObj("tobj"))
    Data.updateTreasureById(treasure)
    gDispatchEvt(EVENT_ID_WENYAO_UPGRADE)
end

--纹耀技能重置
function Net.sendTreasureStarSkillre(tid)
    local media=MediaObj:create()
    media:setLong("tid", tid);
    Net.sendExtensionMessage(media, "treasure.starskillre")
end

function Net.rec_treasure_starskillre(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
    local treasure=Net.parseTreasureItem(obj:getObj("tobj"))
    Data.updateTreasureById(treasure)
    gDispatchEvt(EVENT_ID_WENYAO_RESET)
end

--分解预览
function Net.sendTreasureOkdcForsee(listItems)
    local media=MediaObj:create()
    local vectorIds = vector_long2X_:new_local();
    for k, var in pairs(listItems) do
        vectorIds:push_back(var.id)
    end
    media:setLongArray("list", vectorIds);
    Net.sendExtensionMessage(media, "treasure.okdcforsee")
end

function Net.rec_treasure_okdcforsee(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local reviewList = {}
    local rlist=obj:getArray("rlist")
    if(rlist)then
        rlist=tolua.cast(rlist,"MediaArray")
        for i=0, rlist:count()-1 do
            local objItem = tolua.cast(rlist:getObj(i),"MediaObj") 
            table.insert(reviewList,{id=objItem:getInt("id"),num=objItem:getInt("num")})
        end
    end
    gDispatchEvt(EVENT_ID_OKDCFORSEE,reviewList)
end
