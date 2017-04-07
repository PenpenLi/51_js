

--抽卡列表
function Net.sendDrawCardList()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_DRAW_LIST)
end

function Net.updateDragonExchange(objs)
    local ret={}
    objs=tolua.cast(objs,"MediaArray") 
    if(objs)then
        for i=0, objs:count()-1 do
            local obj= objs:getObj(i)
            obj=tolua.cast(obj,"MediaObj")
            local itemid=obj:getInt("cid")
            local num=obj:getInt("num")
            ret[itemid]=num
        end
    end
    return ret
end

function Net.recDrawCardList(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local goldObj= obj:getObj("gold")
    ret.gold={}
    ret.gold.fnum=goldObj:getByte("fnum")--今日剩余免费次数,如果为0,表示今日免费次数已用完
    ret.gold.ftime=goldObj:getInt("ftime")--免费剩余时间(秒),如果该参数大于0,需要10000金币购买
    ret.lucky=obj:getByte("lucky")
    ret.gball=obj:getInt("gball") 
    ret.exlist=Net.updateDragonExchange(obj:getArray("exlist"))

    if(obj:containsKey("dct"))then
        ret.dct=obj:getInt("dct")
    end
    local diamondObj= obj:getObj("diamond")
    ret.diamond={}
    ret.diamond.ftime=diamondObj:getInt("ftime")--免费剩余时间(秒),如果该参数大于0,需要288钻石购买

    local soul = obj:getObj("soul");
    if(soul)then
        ret.soul = {};
        ret.soul.soul1 = soul:getInt("week");
        ret.soul.soul2 = soul:getInt("day1");
        ret.soul.soul3 = soul:getInt("day2");
        ret.soul.soul4 = soul:getInt("day3");
        ret.soulluck = soul:getInt("slucky");
        print("soul");
        print_lua_table(ret.soul);
    end




    ret.time=gGetCurServerTime()
    Data.drawCard=ret
    gDispatchEvt(EVENT_ID_DRAW_CARD_LIST,Data.drawCard)

end

function Net.sendDrawDragonExchange(cardid)
    local media=MediaObj:create()
    media:setInt("cardid",cardid)
    media:setInt("num",1)
    Net.sendExtensionMessage(media, CMD_DRAW_DBEXCHANGE)
    td_param = {}
    td_param['cardid'] = tostring(cardid)
    td_param['card_name'] = DB.getItemName(cardid)
    gLogEvent("draw.dbexchange", td_param)
end


function Net.recDrawDbexchange(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    if(obj:containsKey("lucky"))then
        Data.drawCard.lucky= obj:getByte("lucky")
    end
    Data.drawCard.gball=obj:getInt("dbnum")
    Net.updateReward(obj:getObj("reward"),2)
    Data.drawCard.exlist=Net.updateDragonExchange(obj:getArray("exlist"))
    
     
        
    gDispatchEvt(EVENT_ID_DRAW_CARD_EXCHANGE)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)

end
--抽卡
function Net.sendDrawCard(type,ntype) 
    if(NetErr.isDrawCardEnough(type,ntype)==false)then
        return
    end
    local media=MediaObj:create()
    media:setByte("type",type)
    media:setByte("ntype",ntype)
    Net.sendDrawCardParam=type
    Net.sendExtensionMessage(media, CMD_DRAW_GD_BUY,false)
    --DB.getDrawDiamondTen()
    if(TDGAItem) then
        if((type == 1) and (ntype == 1)) then
            if (Data.getCurDia() >= DB.getDrawDiamondTen() and Data.getItemNum(ITEM_ID_DRAW_CARD_TEN) <= 0) then
                gLogPurchase("dia_ten", 1, DB.getDrawDiamondTen())
                gLogEvent("dia_ten")
            end
        end
        if((type == 1) and (ntype == 0)) then
            print ("dia one:" .. tostring(Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)))
            if (Data.drawCard.freeDia == false)  and  (Data.getCurDia() >= DB.getDrawDiamondOne() and Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)<=0) then
                gLogPurchase("dia_one", 1, DB.getDrawDiamondOne())
                gLogEvent("dia_one")
            end
        end
    end

    if (type == 0) and (ntype == 1) then
        if (Data.getCurGold() >= DB.getDrawGoldTen()) then
            gLogEvent("gold_ten")
        end
    end
    
    if (type == 0) and (ntype == 0) then
        if (Data.getCurGold() >= DB.getDrawGoldOne()) then
            gLogEvent("gold_one")
        end
    end
end

function Net.recDrawCard(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    local goldObj= obj:getObj("gold")
    Data.drawCard.gold={}
    Data.drawCard.gold.fnum=goldObj:getByte("fnum")--今日剩余免费次数,如果为0,表示今日免费次数已用完
    Data.drawCard.gold.ftime=goldObj:getInt("ftime")--免费剩余时间(秒),如果该参数大于0,需要10000金币购买

    local diamondObj= obj:getObj("diamond")
    Data.drawCard.diamond={}
    Data.drawCard.diamond.ftime=diamondObj:getInt("ftime")--免费剩余时间(秒),如果该参数大于0,需要288钻石购买

    Data.drawCard.time=gGetCurServerTime()
    Data.drawCard.lucky= obj:getByte("lucky")
    local ret= Net.updateReward(obj:getObj("reward"),0)
    Net.parseUserInfo(obj:getObj("uvobj"))



    local petSoulNum=obj:getInt("petp")
    local items={}
    if(petSoulNum>0)then
        local item={}
        item.id=OPEN_BOX_PET_SOUL
        item.num=petSoulNum;
        table.insert( items,item)
        gUserInfo.petPoint=gUserInfo.petPoint+item.num
    end




    local dragonNum=obj:getInt("dbnum")
    if(dragonNum>0)then
        local item={}
        item.id=OPEN_BOX_DRAGON_BALL
        item.num=dragonNum
        table.insert( items,item)
        Data.drawCard.gball=Data.drawCard.gball+dragonNum
    end

    if(table.getn(items)>0)then
        gShowItemPoolLayer:pushItems(items);
    end

    Data.drawCard.exlist=Net.updateDragonExchange(obj:getArray("exlist"))



    local cidArray=obj:getIntArray("cid") --抽卡中卡牌转成碎片的索引[1-10]
    if nil ~= cidArray then
        ret.cidArray=cidArray
    end

    Scene.enterDragon(ret,Net.sendDrawCardParam)
    -- Panel.popUp(PANEL_DRAW_CARD_REWARD,ret.items)
end



function Net.sendDrawSoulRefresh()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "draw.sfresh");
    --Data.drawCardParams.price_soul_refresh
    if (Data.getCurDia() > Data.drawCardParams.price_soul_refresh) then
        gLogPurchase("dia_soul_refresh", 1, Data.drawCardParams.price_soul_refresh)
    end
end

function Net.rec_draw_sfresh( evt )
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local soul = obj:getObj("soul");
    if(soul)then
        Data.drawCard.soul = {};
        Data.drawCard.soul.soul1 = soul:getInt("week");
        Data.drawCard.soul.soul2 = soul:getInt("day1");
        Data.drawCard.soul.soul3 = soul:getInt("day2");
        Data.drawCard.soul.soul4 = soul:getInt("day3");
    end
    Net.updateReward(obj:getObj("reward"),0)

    gDispatchEvt(EVENT_ID_DRAW_CARD_LIST,Data.drawCard)

end


function Net.sendDrawSoulBuy()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_DRAW_SOUL_BUY)
    --Data.drawCardParams.price_soul_buy
    if (Data.getCurDia() > Data.drawCardParams.price_soul_buy) then
        gLogPurchase("dia_soul_buy", 1, Data.drawCardParams.price_soul_buy)
    end
end


function Net.rec_draw_sbuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.drawCard.soulluck = obj:getInt("slucky");
    local ret= Net.updateReward(obj:getObj("reward"),0)
    Net.parseUserInfo(obj:getObj("uvobj"))
    local cidArray=obj:getIntArray("cid") --抽卡中卡牌转成碎片的索引[1-10]
    if nil ~= cidArray then
        ret.cidArray=cidArray
    end
    Scene.enterDragon(ret,2)
end

function Net.sendDrawSluckybox()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "draw.sluckybox");
end

function Net.rec_draw_sluckybox(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.drawCard.soulluck = obj:getInt("slucky");
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_DRAW_GET_LUCKBOX);    
end