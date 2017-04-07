function Net.parserConstellationBag(list)
    gConstellation.bags = {}
    gConstellation.initBagItems()
    list = tolua.cast(list,"MediaArray")
    for i=0,list:count()-1 do
        local data=tolua.cast(list:getObj(i),"MediaObj")
        local bagItem = gConstellation.getBagById(data:getInt("conid"))
        if nil ~= bagItem then
            bagItem:setNum(data:getInt("num"))
        end
    end

end

function Net.parserMagicCircle(obj)
    gConstellation.initUnActivedGroups()
    gConstellation.setActivedMagicCircle(obj:getInt("cid"))
    gConstellation.setSelCircleId(obj:getInt("usecid"))
    gConstellation.setSelExtraAddIx(obj:getInt("addid"))
    gConstellation.setSoulNum(obj:getInt("soul"))
    gConstellation.setActivedAchieveId(obj:getInt("aid"))
    gConstellation.setNum(obj:getInt("conscore"))
    gConstellation.setLeftFightNum(obj:getInt("fnum"))
    local list = tolua.cast(obj:getArray("glist"),"MediaArray")
    for i = 0, list:count()-1 do
         local data=tolua.cast(list:getObj(i),"MediaObj")
         local circleId = data:getInt("cid")
         local groupIdList = data:getIntArray("gids")
         local starGroupIdList = data:getIntArray("starList")
         local groupIds = {}
         if(nil ~= groupIdList)then
            for j = 0, groupIdList:size()-1 do
                gConstellation.addActivedGroupMap(circleId, groupIdList[j])
                gConstellation.addStarListGroupMap(circleId, groupIdList[j],starGroupIdList[j])
            end
         end
    end
    gConstellation.updateGroupCanBeActive()
    RedPoint.constellation()
end


--星魂兑换商店
CMD_CIRCLE_SHOP_INFO = "circle.shopinfo"
function Net.sendCircleShopInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_CIRCLE_SHOP_INFO)   
end
function Net.rec_circle_shopinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    -- ids intarray 星宿商品id
    -- time 下次刷新时间
    -- fnum 今日刷新次数
    local itemArray = obj:getArray("list")
    if(itemArray)then
        itemArray = tolua.cast(itemArray,"MediaArray")
        for i = 0, itemArray:count()-1 do
            local itemObj = tolua.cast(itemArray:getObj(i),"MediaObj")
            local item = gShops[SHOP_TYPE_CONSTELLATION].items[i + 1]
            item.itemid = itemObj:getInt("cid")
            item.num = itemObj:getInt("num")
            item.buyNum = itemObj:getInt("buynum")
            if item.buyNum == item.num then
                item.num = 0
            end
            local itemInfo = DB.getConstellationsItemInfo(item.itemid)
            item.price = itemInfo.neednum
            item.pos = i + 1
        end
    end
    gShops[SHOP_TYPE_CONSTELLATION].time = obj:getInt("time")
    gShops[SHOP_TYPE_CONSTELLATION].refreshTimes = obj:getInt("fnum")

    gDispatchEvt(EVENT_ID_INIT_SHOP, gShops[SHOP_TYPE_CONSTELLATION])
end

-- 星宿商店刷新
CMD_CIRCLE_SHOP_REFRESH = "circle.srefresh"
function Net.sendCircleSrefresh()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_CIRCLE_SHOP_REFRESH)   
end

function Net.rec_circle_srefresh(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local itemArray = obj:getArray("list")
    if(itemArray)then
        itemArray = tolua.cast(itemArray,"MediaArray")
        for i = 0, itemArray:count()-1 do
            local itemObj = tolua.cast(itemArray:getObj(i),"MediaObj")
            local item = gShops[SHOP_TYPE_CONSTELLATION].items[i + 1]
            item.itemid = itemObj:getInt("cid")
            item.num = itemObj:getInt("num")
            item.buyNum = itemObj:getInt("buynum")
            if item.buyNum == item.num then
                item.num = 0
            end
            local itemInfo = DB.getConstellationsItemInfo(item.itemid)
            item.price = itemInfo.neednum
            item.pos = i + 1
        end
    end

    gShops[SHOP_TYPE_CONSTELLATION].refreshTimes = obj:getInt("fnum")
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_INIT_SHOP, gShops[SHOP_TYPE_CONSTELLATION])
end

-- 星宿商店购买
CMD_CIRCLE_SHOP_BUY = "circle.shopbuy"
function Net.sendCircleShopBuy(pos)
    local media=MediaObj:create()
    media:setByte("pos", pos)
    Net.sendCircleShopBuyPos = pos
    Net.sendExtensionMessage(media, CMD_CIRCLE_SHOP_BUY)   
end

function Net.rec_circle_shopbuy(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    for key,item in pairs(gShops[SHOP_TYPE_CONSTELLATION].items) do
        if item.pos == Net.sendCircleShopBuyPos then
            item.num = 0
        end
    end

    Net.updateReward(obj:getObj("reward"),2)
    gConstellation.updateGroupCanBeActive()
    RedPoint.constellation()
    gDispatchEvt(EVENT_ID_SHOP_REFRESH)
end

-- 激活星宿组
CMD_CIRCLE_CONSTELLATION_GROUP_ACTIVE = "circle.congact"
function Net.sendConstellationGroupAcitve(circleId,groupId)
    print("Net.sendConstellationGroupAcitve circleId is:",circleId, " groupId is:", groupId)
    local media=MediaObj:create()
    media:setInt("gid",groupId)
    Net.sendActiveGroupCircleId = circleId
    Net.sendExtensionMessage(media, CMD_CIRCLE_CONSTELLATION_GROUP_ACTIVE)   
end

function Net.rec_circle_congact(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local oldNum = gConstellation.getNum()
    Net.updateReward(obj:getObj("reward"),0)
    local groupId = obj:getInt("gid")
    gConstellation.showGroupActivedNum(gConstellation.getNum()-oldNum, groupId)
    gConstellation.updateActivedGroupId(Net.sendActiveGroupCircleId, groupId)
    gConstellation.updateGroupCanBeActive()
    RedPoint.constellation()
    gDispatchEvt(EVENT_ID_CONSTELLATION_ACTIVE_GROUP, groupId)
end
-- 点亮成就
CMD_CIRCLE_LIGHT_STAR = "circle.lightstar"
function Net.sendCircleLightStar(achieveId)
    local media=MediaObj:create()
    media:setInt("aid",achieveId)
    Net.sendExtensionMessage(media, CMD_CIRCLE_LIGHT_STAR)   
end

function Net.rec_circle_lightstar(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    local achieveId = obj:getInt("aid")
    gConstellation.setActivedAchieveId(achieveId)
    -- 需封装一个函数
    local achieveInfo = DB.getConstellationAchieveInfo(achieveId)
    local attr = achieveInfo.attr1
    local value = achieveInfo.param1
    local attrTitle = gGetWords("cardAttrWords.plist", "attr" .. attr)
    local formatValue = ""
    if CardPro.isFloatAttr(attr) then
        formatValue = string.format("+%0.1f%%", value)
    else
        formatValue = string.format("+%d", value)
    end
    gShowNotice(gGetWords("constellationWords.plist","notice_active_achieve",attrTitle,formatValue))
    gDispatchEvt(EVENT_ID_CONSTELLATION_ACTIVE_ACHIEVE, achieveId)
end

-- 选择法阵
CMD_CIRCLE_SELECT_CIRCLE = "circle.selecircle"
function Net.sendCircleSelecircle(circleId,isSelect)
    local media=MediaObj:create()
    media:setInt("cid",circleId)
    media:setBool("select",isSelect)
    Net.sendExtensionMessage(media, CMD_CIRCLE_SELECT_CIRCLE)   
end

function Net.rec_circle_selecircle(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    -- cid可能为0
    print("Net.rec_circle_selecircle", obj:getInt("cid"))
    gConstellation.setSelCircleId(obj:getInt("cid"))

    gDispatchEvt(EVENT_ID_CONSTELLATION_ITEM_CHOOSE,obj:getInt("cid"))
end

-- 取得猎星界面详细
CMD_CIRCLE_HUNT_INFO = "circle.huntinfo"
function Net.sendCircleHuntInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_CIRCLE_HUNT_INFO)   
end

function Net.rec_circle_huntinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    local freeNum = obj:getInt("fnum")
    gConstellation.setHuntFreeNum(freeNum)
    gConstellation.setHuntBingo(obj:getInt("bingo"))
    Data.redpos.constellationhunt = (freeNum ~= 0)
    RedPoint.constellation()
    Panel.popUp(PANEL_CONSTELLATION_HUNT) 
end

-- 开始猎星
CMD_CIRCLE_HUNT = "circle.hunt"
function Net.sendCircleHunt(num)
    local media=MediaObj:create()
    media:setInt("num",num)
    Net.sendHuntCircleNum=num
    Net.sendExtensionMessage(media, CMD_CIRCLE_HUNT)   
end

function Net.rec_circle_hunt(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    local freeNum = obj:getInt("fnum")
    gConstellation.setHuntFreeNum(freeNum)
    gConstellation.setHuntBingo(obj:getInt("bingo"))
    Data.redpos.constellationhunt = (freeNum ~= 0)
    local ret= Net.updateReward(obj:getObj("reward"),0)
    gConstellation.updateGroupCanBeActive()
    RedPoint.constellation()
    -- 刷新界面信息
    gDispatchEvt(EVENT_ID_CONSTELLATION_REDPOS_REFRESH,{items=ret.items,type=Net.sendHuntCircleNum})
end

-- 化魂
CMD_CIRCLE_CHANGE_SOUL = "circle.csoul"
function Net.sendCircleCsoul(data)
    local media=MediaObj:create()
    local array=MediaArray:create()
    for key, var in pairs(data) do
        local obj=MediaObj:create()
        obj:setInt("cid", var.itemid)
        obj:setInt("num", var.num)
        array:addObj(obj) 
    end
    media:setObjArray("clist", array)
    Net.sendExtensionMessage(media, CMD_CIRCLE_CHANGE_SOUL)
end

function Net.rec_circle_csoul(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    gConstellation.updateGroupCanBeActive()
    RedPoint.constellation()
    gDispatchEvt(EVENT_ID_CONSTELLATION_ITEM_REFRESH)
end

-- 星宿法阵激活通知
RECEIVE_CIRCLE_ACTIVE_PROMPT = "rec.circleactive"
function Net.rec_rec_circleactive(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local circleId = obj:getInt("cid")
    gConstellation.setActivedMagicCircle(circleId)
    local magicCircleInfo = gConstellation.getMagicCircleInfoById(circleId)
    if nil ~= magicCircleInfo then
        magicCircleInfo.isUnlock = true
    end

    gDispatchEvt(EVENT_ID_CONSTELLATION_ACTIVE_CIRCLE, circleId)
end

-- 挑战界面详细
CMD_CIRCLE_FIGHT_INFO = "circle.fightinfo"
function Net.sendCircleFightinfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_CIRCLE_FIGHT_INFO)
end

function Net.rec_circle_fightinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local leftFightNum = obj:getInt("num")
    local leftFreeNum = obj:getInt("fcnum")
    local diaChangeNum = obj:getInt("dcnum")
    local fightConstellaionId = obj:getInt("fcid") 

    gConstellation.setLeftFightNum(leftFightNum)
    gConstellation.setFreeLeftChangeNum(leftFreeNum)
    gConstellation.setDiaChangeNum(diaChangeNum)
    gConstellation.setFightConstellationId(fightConstellaionId)
    RedPoint.constellation()
    Panel.popUp(PANEL_CONSTELLATION_FIGHT,fightConstellaionId)
end

-- 进入战斗界面
CMD_CIRCLE_FIGHT_ENTER = "circle.fightenter"
function Net.sendCircleFightEnter()
    local media=MediaObj:create()
    Net.sendAtlasEnterParam = {}
    Net.sendExtensionMessage(media, CMD_CIRCLE_FIGHT_ENTER)
end

function Net.rec_circle_fightenter(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local curFormation ,pet,enemyFormations,country,power= Net.parseAtlasData(obj)
    local maxRound=DB.getAtlasRound()
    Battle.battleType=BATTLE_TYPE_CONSTELLATION
    gBattleData=Battle.enterAtlas(curFormation,pet,enemyFormations,country,1,maxRound,"b003",power)
end

-- 挑战
CMD_CIRCLE_FIGHT = "circle.fight"
function Net.sendCircleFight()
    local media=MediaObj:create()
    media:setObjArray("blist",Battle.getLogData())
    Net.sendExtensionMessage(media, CMD_CIRCLE_FIGHT)
end

function Net.rec_circle_fight(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end


    Battle.reward={}
    Battle.reward.formation={}
    local rewardObj=obj:getObj("reward")
    Battle.reward.shows= Net.updateReward(rewardObj,0)

    Panel.popUp(PANEL_ATLAS_FINAL)
end

-- 换将
CMD_CIRCLE_CHANGE_FIGHTER = "circle.chfigter"
function Net.sendCircleChfigter()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_CIRCLE_CHANGE_FIGHTER)
end

function Net.rec_circle_chfigter(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local leftFreeNum = obj:getInt("fcnum")
    local diaChangeNum = obj:getInt("dcnum")
    local fightConstellaionId = obj:getInt("fcid") 

    gConstellation.setFreeLeftChangeNum(leftFreeNum)
    gConstellation.setDiaChangeNum(diaChangeNum)
    gConstellation.setFightConstellationId(fightConstellaionId)

    Net.updateReward(obj:getObj("reward"), 0)
    gDispatchEvt(EVENT_ID_CONSTELLATION_FIGHT_REFRESH,fightConstellaionId)
end


--星宿升星
CMD_CIRCLE_STAR_UPGRADE = "circle.starupgrade"
function Net.sendCircleStarUpgrade(gid)
    local media=MediaObj:create()
    media:setInt("gid",gid)
    Net.sendExtensionMessage(media, CMD_CIRCLE_STAR_UPGRADE)
end

function Net.rec_circle_starupgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    -- 升星小红点
    if(obj:containsKey("cstar"))then
        Data.redpos.constellationstar= obj:getBool("cstar")
        RedPoint.constellation()
    end

    local oldNum = gConstellation.getNum()
    local circleId = obj:getInt("cid")
    local gid = obj:getInt("gid")
    local star = obj:getByte("star")
    gConstellation.addStarListGroupMap(circleId, gid,star)
    Net.updateReward(obj:getObj("reward"), 0)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    gConstellation.showGroupStarNum(gConstellation.getNum()-oldNum, gid,star)
    RedPoint.constellation()
    gDispatchEvt(EVENT_ID_CONSTELLATION_STAR_GROUP,gid)
end
