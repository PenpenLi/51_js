----活动列表
function Net.sendActivityAll(type)

    local media=MediaObj:create()
    if type~=nil then
        media:setByte("type",type)
    end
    Net.sendExtensionMessage(media, CMD_ACT_GET_LIST)
end

function Net.recActivityAll(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local items_sort={}
    local sortList=obj:getArray("sortlist")
    if (sortList) then
        -- print("0=============")
        sortList=tolua.cast(sortList,"MediaArray")
        for i=0, sortList:count()-1 do
            local actObj=tolua.cast(sortList:getObj(i),"MediaObj")
            local item={}
            item.type = actObj:getInt("acttype")
            item.actId = actObj:getInt("actid")
            item.sortId = actObj:getInt("sortid")
            table.insert(items_sort,item)
        end
    end
    -- print_lua_table(items_sort)

    local items={}
    local actList=obj:getArray("acts")
    if(actList)then
        actList=tolua.cast(actList,"MediaArray")
        for i=0, actList:count()-1 do
            local actObj=tolua.cast(actList:getObj(i),"MediaObj")
            local item={}
            item.type = actObj:getInt("type")
            item.name = actObj:getString("name")
            item.icon = actObj:getString("icon")
            if tonumber(item.icon)~=nil then
                item.icon = tonumber(item.icon)
            end
            item.actId = actObj:getInt("id")
            item.param = actObj:getInt("param")
            item.param2 = actObj:getInt("param1")
            item.param3 = actObj:getInt("param3")
            if(actObj:containsKey("stime")) then
                item.begintime = actObj:getInt("stime")
                item.endtime = actObj:getInt("etime")
            end
            if (actObj:containsKey("diamond")) then--94
                item.diamond = actObj:getInt("diamond")
            end
            --特殊处理 增加时间 by zrz
            if (item.type == ACT_TYPE_8) then
                item.endtime = Data.activityCat.lefttime;
            elseif (item.type == ACT_TYPE_116) then
                item.endtime = Data.task7Day.lefttime
            elseif (item.type == ACT_TYPE_19 or item.type == ACT_TYPE_93) then
                item.begintime = nil
                item.endtime = nil
            elseif (item.type == ACT_TYPE_92) then
                item.endtime = actObj:getInt("etime")
            end

            item.sordId = Net.getActivitySortId(items_sort,item.actId,item.type)
            print("item.sordId="..item.sordId..",type="..item.type..",item.actId="..item.actId..",item.icon="..item.icon..",item.name="..item.name..",item.param3="..item.param3)

            --特殊处理
            if(item.type == ACT_TYPE_126 and Module.isClose(SWITCH_SHARE))then
            --分享关闭,不添加分享活动
            elseif (item.type == ACT_TYPE_127 and Module.isClose(SWITCH_SIGN)) then--签到
            else
                table.insert(items,item)
            end

        end
    end



    table.sort( items, function(a,b) return a.sordId>b.sordId end )

    local actObj = obj:getObj("act")
    if (actObj) then
        Net.updateActObj(actObj)
    end


    Data.activityAll=items
    Module.delActivity();
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_ALL)
end

function Net.getActivitySortId(sortList,aid,atype)
    for k,v in pairs(sortList) do
        if (v.actId == aid and v.type == atype) then
            return v.sortId;
        end
    end
    return 0;
end

---*******春节7天乐********-------
function Net.sendDaytActList()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "dayt.actlist");
end

function Net.rec_dayt_actlist(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.activityDayTasks = {};
    Data.activityDayTasks.endtime = obj:getInt("etime");
    Data.activityDayTasks.today = obj:getInt("curday");
    Data.activityDayTasks.list = {};
    local actList=obj:getArray("list")
    if(actList)then
        actList=tolua.cast(actList,"MediaArray")
        for i=0, actList:count()-1 do
            local actObj=tolua.cast(actList:getObj(i),"MediaObj")
            local item={}
            item.id = actObj:getInt("id")
            item.curp = actObj:getInt("curp")
            item.day = actObj:getInt("day")
            item.gtime = actObj:getInt("gtime")
            table.insert(Data.activityDayTasks.list,item);
        end
    end   

    -- print_lua_table(Data.activityDayTasks);
    -- Panel.popUp(PANEL_ACTIVITY_DAYTASK);
    gDispatchEvt(EVENT_ID_REFRESH_ACTIVITY_DAYTASK)
    -- if Panel.isTopPanel(PANEL_TASK7DAY) then
    --     gDispatchEvt(EVENT_ID_REFRESH_ACTIVITY_DAYTASK)
    -- else
    --     gDispatchEvt(EVENT_ID_ENTER_ACTIVITY_DAYTASK);
    -- end
    
end

function Net.sendDaytEnergyEat(id)
    local media=MediaObj:create()
    TaskPanelData.energyTaskId = id
    media:setInt("id",id);
    Net.sendExtensionMessage(media, "dayt.ereeat");
end

function Net.rec_dayt_ereeat(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2);

    local ret = {};
    ret.id = TaskPanelData.energyTaskId;
    gDispatchEvt(EVENT_ID_TASK_GET,ret);
    TaskPanelData.energyTaskId = 0;

end


function Net.sendDaytActGet(id,day)
    local media=MediaObj:create()
    media:setInt("id",id);
    media:setInt("day",day);
    Net.sendExtensionMessage(media, "dayt.actget");
end
function Net.rec_dayt_actget(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret = {};
    ret.id = obj:getInt("id");
    ret.day = obj:getInt("day");
    ret.gtime = obj:getInt("gtime");
    Net.updateReward(obj:getObj("reward"),2);

    for key,var in pairs(Data.activityDayTasks.list) do
        if(var.day == ret.day and var.id == ret.id)then
            Data.activityDayTasks.list[key].gtime = ret.gtime;
            break;
        end
    end

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_DAYTASK);
end
---*******春节7天乐********-------

----7天礼包
function Net.sendActivity7Day()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_GIFTBAG_OPEN_SERVER_INIT)
end


function Net.recActivity7Day(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    Data.activityLogin7={}
    local boxIdArrays=obj:getIntArray("list")
    if(boxIdArrays)then
        for i=0, boxIdArrays:size()-1 do
            Data.activityLogin7[boxIdArrays[i]]=1
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_7_DAY)
end


function Net.sendActivity7DayGet(boxid)

    local media=MediaObj:create()
    media:setInt("boxid", boxid)
    Net.sendExtensionMessage(media, CMD_GIFTBAG_GET_OPEN_SERVER)
    if (TalkingDataGA) then
        local param = {}
        param["id"]= tostring(boxid)
        gLogEvent("sevenday_get",param)
    end
end


function Net.recActivity7DayGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local boxid=obj:getInt("boxid")
    Data.activityLogin7[boxid]=1
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_7_DAY_GET)
end





----等级礼包
function Net.sendActivityLevelUp()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_GIFTBAG_LV_INIT)
end


function Net.recActivityLevelUp(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.activityLevelUp={}
    local boxIdArrays=obj:getIntArray("list")
    if(boxIdArrays)then
        for i=0, boxIdArrays:size()-1 do
            Data.activityLevelUp[boxIdArrays[i]]=1
        end
    end
    Data.activityLevelUpRemainTime=obj:getInt("regtime")
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_LEVEL_UP)
end


function Net.sendActivityLevelUpGet(boxid)

    local media=MediaObj:create()
    media:setInt("boxid", boxid)
    ActivityLevelUpPanelData.boxid = boxid;
    Net.sendExtensionMessage(media, CMD_GIFTBAG_GET_LV)
end


function Net.recActivityLevelUpGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- local boxid=obj:getInt("boxid")
    local boxid = ActivityLevelUpPanelData.boxid;
    Data.activityLevelUp[boxid]=1
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_LEVEL_UP_GET)
end



---招财猫
function Net.sendGiftbagGetBet()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_GIFTBAG_BET)--giftb.bet
end

function Net.rec_giftb_bet(evt)
    local obj = evt.params:getObj("params")
    local ret2 = obj:getByte("ret");
    if(ret2==0)then
        Data.activityCat.getdmd = obj:getInt("diamond");
        Net.updateReward(obj:getObj("reward"),0);

        local detObj=tolua.cast(obj:getObj("cat"),"MediaObj")
        Data.activityCat.lefttime = detObj:getInt("time");
        Data.activityCat.lv = detObj:getByte("lv");
    -- print("Data.activityCat.getdmd="..Data.activityCat.getdmd)
    -- print("Data.activityCat.lefttime="..Data.activityCat.lefttime)
    -- print("Data.activityCat.lv="..Data.activityCat.lv)
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_CAT,{ret = ret2})
end

--vip活动
function Net.sendGetVip(index)
    local media=MediaObj:create()
    -- print("---------index="..index)
    media:setInt("index", index)
    Net.sendExtensionMessage(media, "act.getvip")
end

function Net.rec_act_getvip(evt)
    local obj = evt.params:getObj("params")
    local ret2 = obj:getByte("ret");
    if(ret2==0)then
        local vip = obj:getInt("vip");
        gUserInfo.vip = vip;
        local maxLen = table.getn(Data.activity.vip_get);
        local maxGetVip = toint(Data.activity.vip_get[maxLen]);
        local bolOver = false;--是否结束
        if (gUserInfo.vip>=maxGetVip) then
            bolOver = true;
        end
        Panel.popUpVisible(PANEL_VIP_LEVELUP,nil,nil,true);
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_VIP,{bolOver = bolOver})
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    end
end

--许愿树
function Net.sendWishGetInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wish.getinfo")
end
function Net.updateWish(obj)
    if (obj) then
        Data.activityWish.point = obj:getInt("val")
        Data.activityWish.maxPoint = obj:getInt("max")
        Data.activityWish.iTime = obj:getInt("time")
        Data.activityWish.rTime = gGetCurServerTime();
    else
        Data.activityWish.maxPoint = Data.activity.wish_max;
    end
end
function Net.bolWishNotify()
    local size = #Data.activityWish.reward
    if (size>=Data.activity.wish_max) then
        LocalNotify.setGameWish()
    end
end
function Net.rec_wish_getinfo(evt)
    local obj = evt.params:getObj("params")
    local ret2 = obj:getByte("ret");
    if(ret2==0)then
        Net.updateWish(obj);
        -- Data.activityWish.loginCount = obj:getInt("login")
        Data.activityWish.reward = {};
        local list=obj:getArray("reward")
        if (list) then
            list=tolua.cast(list,"MediaArray")
            for i=0, list:count()-1 do
                local actObj=tolua.cast(list:getObj(i),"MediaObj")
                local item={}
                item.id = actObj:getInt("id")
                item.num = actObj:getInt("num")
                item.cri = actObj:getInt("cri")
                table.insert(Data.activityWish.reward,item)
            end
        end
        Data.activityWish.strReward = obj:getString("config")
        -- Net.bolWishNotify()
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_WISH)
    end
end
function Net.sendWishAddReward(idx)
    local media=MediaObj:create()
    media:setInt("idx", idx)
    Net.sendExtensionMessage(media, "wish.addreward")
    if (TalkingDataGA) then
        local param = {}
        -- table.insert(param, {id=tostring(self.curActData)})
        param["idx"] = tostring(idx)
        gLogEvent("wish.addreward",param)
    end
end
function Net.rec_wish_addreward(evt)
    local obj = evt.params:getObj("params")
    local ret2 = obj:getByte("ret");
    if(ret2==0)then
        Data.activityWish.point = obj:getInt("val")
        Data.activityWish.add_id = obj:getInt("id")
        Data.activityWish.add_num = obj:getInt("num")
        Data.activityWish.add_cri = obj:getInt("cri")
        -- print("Data.activityWish.add_cri="..Data.activityWish.add_cri)
        local item={}
        item.id = Data.activityWish.add_id
        item.cri = Data.activityWish.add_cri
        item.num = Data.activityWish.add_num
        table.insert(Data.activityWish.reward,item)
        if (Data.activityWish.point<=0) then
            Data.redpos.wish = false;
        end
        Net.bolWishNotify()
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_WISH_ADD_REWARD)
    end
end
function Net.sendWishRecReward()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "wish.recreward")
end
function Net.rec_wish_recreward(evt)
    local obj = evt.params:getObj("params")
    local ret2 = obj:getByte("ret");
    if(ret2==0)then
        Net.updateReward(obj:getObj("reward"),2);
        Data.activityWish.reward = {};
        local time = Data.task7Day.lefttime - gGetCurServerTime()
        if (Data.activityWish.point<=0 or time<=0) then
            Data.redpos.wish = false;
        end
        LocalNotify.clearGameWish()
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_WISH_REC_REWARD)
    end
end

----投资理财
function Net.sendActivityInvest()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_FUND_LIST)
end


function Net.recActivityInvest(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.activityInvestReward={}
    local boxIdArrays=obj:getIntArray("list")
    if(boxIdArrays)then
        for i=0, boxIdArrays:size()-1 do
            Data.activityInvestReward[boxIdArrays[i]]=1
        end
    end
    Data.activityInvestBuy=obj:getByte("ifbuy")==1

    -- print("--------0000000--------")
    -- print_lua_table(Data.activityInvestReward)

    if (Data.bolNewInvest) then
       gDispatchEvt(EVENT_ID_GET_ACTIVITY_INVEST2)
    else
       gDispatchEvt(EVENT_ID_GET_ACTIVITY_INVEST)
    end
end


function Net.sendActivityInvestGet(lv)

    local media=MediaObj:create()
    media:setInt("lv", lv)
    Net.sendExtensionMessage(media, CMD_FUND_GET)
end


function Net.recActivityInvestGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local lv=obj:getInt("lv")
    Data.activityInvestReward[lv]=1
    Data.redpos.fu = false
    local lvs,dias,dia=DB.getActivityInvest()
    for key, value in pairs(lvs) do
        local status = 0;
        if(Data.activityInvestBuy==false or gUserInfo.level<toint(lvs[key]))then
            status = -1;
        else
            if(Data.activityInvestReward[toint(lvs[key])]==1)then 
                status = 1;
            else
                status = 0;
            end
        end
        if (status==0) then
            Data.redpos.fu = true
            break
        end
    end

    -- Net.parseUserInfo(obj:getObj("uvobj"))
    Net.updateReward(obj:getObj("reward"),2);
    if (Data.bolNewInvest) then
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_INVEST2_GET)
    else
        gDispatchEvt(EVENT_ID_GET_ACTIVITY_INVEST_GET)
    end
end


function Net.sendActivityInvestBuy()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_FUND_BUY)
end


function Net.recActivityInvestBuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- Net.parseUserInfo(obj:getObj("uvobj"))
    Net.updateReward(obj:getObj("reward"),2);
    Data.activityInvestBuy=true
    if (Data.bolNewInvest) then
       gDispatchEvt(EVENT_ID_GET_ACTIVITY_INVEST2_BUY)
    else
       gDispatchEvt(EVENT_ID_GET_ACTIVITY_INVEST_BUY)
    end
end

function Net.getActInfoData(obj)
    local action={}
    action.idx = obj:getInt("id")
    action.type = obj:getByte("type")
    action.myrank = obj:getInt("myrank")
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.updatetime = obj:getInt("updatetime")
    action.desc = obj:getString("desc")
    action.entry = obj:getInt("entry")
    action.ch_num = obj:getInt("num")
    if (obj:containsKey("param3")) then--param
        action.param3 = obj:getInt("param3")
    end

    action.list = {}
    -- action.list=Net.getActInfoData_List(obj)
    local detList=obj:getArray("det")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=0, detList:count()-1 do
            local detObj=tolua.cast(detList:getObj(i),"MediaObj")
            local info={}
            info.idx = detObj:getInt("detid")
            info.name = detObj:getString("name")
            info.rank1 = detObj:getInt("rank1")
            info.rank2 = detObj:getInt("rank2")
            info.rec = detObj:getBool("rec")
            info.max = detObj:getInt("max")
            if(detObj:containsKey("cnt")) then
                info.cur = detObj:getInt("cnt")
            else
                info.cur = detObj:getInt("num")
            end
            info.iapid = detObj:getInt("iapid")
            info.count = detObj:getInt("count")
            info.itemidList={}
            info.numList={}
            info.numList2={}
            info.numInBagList={}
            local itemList=detObj:getArray("items")
            if(itemList)then
                itemList=tolua.cast(itemList,"MediaArray")
                for i=0, itemList:count()-1 do
                    local itemObj=tolua.cast(itemList:getObj(i),"MediaObj")
                    table.insert(info.itemidList,itemObj:getInt("id"))
                    table.insert(info.numList,itemObj:getInt("qty"))
                    table.insert(info.numList2,itemObj:getInt("lv"))
                    table.insert(info.numInBagList,itemObj:getInt("bagqty"))

                end
            end
            -- print_lua_table(info.numInBagList)
            -- print_lua_table(info.itemidList)
            table.insert(action.list,info)
        end
    end
    return action;
end

--活动兑换
function Net.sendActivityExchange(id,first)
    local media=MediaObj:create()
    media:setInt("id", toint(id))
    media:setBool("first",first)
    Net.sendExtensionMessage(media, "act.getinfo1")
end
function Net.rec_act_getinfo1(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityExchangeData=Net.getActInfoData(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EXCHANGE,action)
end
function Net.sendActivityExchangeRec(detid,data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, "act.rec1")
end
function Net.rec_act_rec1(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    local detList=obj:getArray("det")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=0, detList:count()-1 do
            local detObj=tolua.cast(detList:getObj(i),"MediaObj")
            local detid = detObj:getInt("detid")
            local saleData=  Data.getExchangeDataByDetid(detid)
            if (saleData) then
                saleData.cur = detObj:getInt("cnt")
                saleData.rec = detObj:getBool("rec")
                local itemList=detObj:getArray("items")
                if(itemList)then
                    itemList=tolua.cast(itemList,"MediaArray")
                    for i=0, itemList:count()-1 do
                        local itemObj=tolua.cast(itemList:getObj(i),"MediaObj")
                        saleData.itemidList[i+1] = itemObj:getInt("id")
                        saleData.numInBagList[i+1] = itemObj:getInt("bagqty")
                    end
                end
            end
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EXCHANGE_REC)
end

----限时抢购
function Net.sendActivitySaleOff(data)


    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_7)
end


function Net.recActivitySaleOff(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local action={}
    action.idx = obj:getInt("id")
    action.type = obj:getByte("type")
    action.myrank = obj:getInt("myrank")
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.updatetime = obj:getInt("updatetime")
    action.desc = obj:getString("desc")
    action.entry = obj:getInt("entry")
    action.ch_num = obj:getInt("num")
    action.list={}


    local detList=obj:getArray("det")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=0, detList:count()-1 do
            local detObj=tolua.cast(detList:getObj(i),"MediaObj")
            local info={}
            info.idx = detObj:getInt("detid")
            info.name = detObj:getString("name")
            info.rank1 = detObj:getInt("rank1")
            info.rank2 = detObj:getInt("rank2")
            info.rec = detObj:getBool("rec")
            info.max = detObj:getInt("max")
            if(detObj:containsKey("cnt")) then
                info.cur = detObj:getInt("cnt")
            else
                info.cur = detObj:getInt("num")
            end
            info.iapid = detObj:getInt("iapid")
            info.count = detObj:getInt("count")
            info.itemidList={}
            info.numList={}
            info.numList2={}
            info.numInBagList={}
            local itemList=detObj:getArray("items")
            if(itemList)then
                itemList=tolua.cast(itemList,"MediaArray")
                for i=0, itemList:count()-1 do
                    local itemObj=tolua.cast(itemList:getObj(i),"MediaObj")
                    table.insert(info.itemidList,itemObj:getInt("id"))
                    table.insert(info.numList,itemObj:getInt("qty"))
                    table.insert(info.numList2,itemObj:getInt("lv"))
                    table.insert(info.numInBagList,itemObj:getInt("bagqty"))

                end
            end
            table.insert(action.list,info)
        end
    end

    Data.activitySaleOffData=action
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SALEOFF,action)

end

function Net.sendActivitySaleOffBuy(detid,data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, CMD_ACT_REC_7)
end
function Net.recActivitySaleOffBuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")
    Net.updateReward(obj:getObj("reward"),2)
    local saleData=  Data.getSaleOffDataByDetid(detid)
    if(saleData)then
        saleData.cur=saleData.cur+1
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SALEOFF_BUY)
end

----团购
function Net.sendActivityTuan(data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("fc", true)
    Net.sendExtensionMessage(media, "act.getinfo15")
end
function Net.rec_act_getinfo15(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local action={}
    action.idx = obj:getInt("id")
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.desc = obj:getString("desc")
    action.score = obj:getInt("score")
    action.ticket = obj:getInt("ticket")
    action.bolRedpos = obj:getBool("ifget")
    Data.redpos.bolTuanRewardRec = action.bolRedpos
    action.list={}
    local detList=obj:getArray("list")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.idx = detObj:getInt("actdetailid")
            info.itemid = detObj:getInt("itemid")
            info.itemnum = detObj:getInt("itemnum")
            info.diamond = detObj:getInt("diamond")
            info.allnum = detObj:getInt("allnum")
            info.needticket = detObj:getInt("needticket")
            info.leftnum = detObj:getInt("leftnum")
            info.maxnum = detObj:getInt("maxnum")
            info.plist={}
            local pList=detObj:getArray("plist")
            if(pList)then
                pList=tolua.cast(pList,"MediaArray")
                for j=1, pList:count() do
                    local itemObj=tolua.cast(pList:getObj(j-1),"MediaObj")
                    local item={}
                    item.sale =itemObj:getInt("sale")
                    item.num =itemObj:getInt("num")
                    table.insert(info.plist,item)
                end
            end
            table.insert(action.list,info)
        end
    end
    -- print_lua_table(action)
    Data.activityTuanData = action
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_TUAN,Data.activityTuanData)
end
function Net.sendActivityTuanBuy(id,detid)
    local media=MediaObj:create()
    media:setInt("id", toint(id))
    media:setInt("detid", toint(detid))
    Net.sendExtensionMessage(media, "act.buy15")
    if (TalkingDataGA) then
        local param = {}
        -- table.insert(param, {id=tostring(self.curActData)})
        param["id"] = tostring(detid)
        gLogEvent("activity_tuangou",param)
    end
end
function Net.rec_act_buy15(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Data.activityTuanData.score = obj:getInt("score")
    Data.activityTuanData.ticket = obj:getInt("ticket")
    Data.redpos.bolTuanRewardRec = obj:getBool("ifget")
    if (Data.redpos.bolTuanRewardRec) then
        Net.moveActRedpos(Data.activityTuanData.idx)
        table.insert(Data.redpos.act,Data.activityTuanData.idx)
    end

    local detList=obj:getArray("list")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            local detid = detObj:getInt("actdetailid")
            local payData=  Data.getActivityTuanByDetid(detid)
            if(payData)then
                payData.allnum=detObj:getInt("allnum")
                payData.leftnum=detObj:getInt("leftnum")
            end
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_TUAN_GET)
end

----团购奖励
function Net.sendActivityTuanReward(id)
    local media=MediaObj:create()
    media:setInt("id", id)
    Net.sendExtensionMessage(media, "act.rinfo15")
end
function Net.rec_act_rinfo15(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    ret.list={}
    local  list=obj:getBoolArray("rec")
    if(list)then
        for i=0, list:size()-1 do
            table.insert(ret.list,list[i])
        end
    end
    -- print_lua_table(ret.list)
    Data.activityTuanRewardData=ret
    Panel.popUp(PANEL_ACTIVITY_TUAN_REWARD,ret)
    -- gDispatchEvt(EVENT_ID_GET_ACTIVITY_TUAN_REWARD)
end
function Net.sendActivityTuanRewardGet(id,idx,key)
    local media=MediaObj:create()
    media:setInt("id", toint(id))
    media:setInt("idx", toint(idx))
    Net.sendActivityTuanRewardParam={}
    Net.sendActivityTuanRewardParam.id=id
    Net.sendActivityTuanRewardParam.idx=idx
    Net.sendActivityTuanRewardParam.key=key
    Net.sendExtensionMessage(media, "act.getr15")
end
function Net.rec_act_getr15(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local idx=Net.sendActivityTuanRewardParam.idx
    Data.activityTuanRewardData.list[idx+1]=true
    print_lua_table(Data.activityTuanRewardData.list)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_TUAN_REWARD_GET,Net.sendActivityTuanRewardParam.key)
    Net.updateReward(obj:getObj("reward"),2)
end

----累积消返
function Net.sendActivityExpenseReturn(data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_2)
end
function Net.rec_act_getinfo2(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityExpenseReturnData=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EXPENSE_RETURN,Data.activityExpenseReturnData)
end
function Net.sendActivityExpenseReturnGet(id,detid)
    local media=MediaObj:create()
    media:setInt("id", toint(id))
    media:setInt("detid", toint(detid))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_REC_2)
    if (TalkingDataGA) then
        local param = {}
        -- table.insert(param, {id=tostring(self.curActData)})
        param["detid"] = tostring(detid)
        gLogEvent("activity_expense_return",param)
    end
end
function Net.moveActRedpos(detid,bolNewYear,bolHoliDay,bolHefu)
    if (bolNewYear) then
        for k,v in pairs(Data.redpos.act2) do
            if (v == detid) then
                table.remove(Data.redpos.act2,k)
                break;
            end
        end
        return
    end
    if bolHoliDay then
        for k,v in pairs(Data.redpos.act3) do
            if (v == detid) then
                table.remove(Data.redpos.act3,k)
                break;
            end
        end
    end
    if bolHefu then
        for k,v in pairs(Data.redpos.act4) do
            if (v == detid) then
                table.remove(Data.redpos.act4,k)
                break;
            end
        end
    end
    for k,v in pairs(Data.redpos.act) do
        if (v == detid) then
            table.remove(Data.redpos.act,k)
            break;
        end
    end
end
function Net.dealActRecRedpos(detid,data)
    --处理红点
    local bolRedpos = false
    for key, var in pairs( data.list) do
        local info1 = var.items[1]
        if (data.var >= info1.num) then
            if (var.rec==true) then
                bolRedpos = true
                break
            end
        end
    end
    -- print("Data.activityActid="..Data.activityActid)
    if (not bolRedpos) then
        --删除
        local bolNewYear = false
        if (data.param3 and data.param3==1) then
            bolNewYear = true
        end
        local bolHoliday = false
        if (data.param3 and data.param3==2) then
            bolHoliday = true
        end
        local bolHefu = false
        if (data.param3 and data.param3==3) then
            bolHefu = true
        end
        Net.moveActRedpos(Data.activityActid,bolNewYear,bolHoliday,bolHefu)
    end
end
function Net.rec_act_rec2(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")
    Net.updateReward(obj:getObj("reward"),2)
    local payData=  Data.getActivityExpenseReturnByDetid(detid)
    if(payData)then
        payData.rec=false
    end
    Net.dealActRecRedpos(detid,Data.activityExpenseReturnData)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EXPENSE_RETURN_GET)
end


----节日签到
function Net.sendActivityHolidaySignInfo(data)

    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_28)
end


function Net.recActivityHolidaySignInfo(evt)

    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityHolidaySign=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_GETINFO_28)

end

----签到领取
function Net.sendActivityHolidaySign(actId,detid)

    local media=MediaObj:create()
    media:setInt("id", toint(actId))
    media:setInt("detid", toint(detid))
    Net.sendExtensionMessage(media, CMD_ACT_REC_28)
end

function Net.recActivityHolidaySign(evt)

    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")
    local data=  Data.getActivity28id(detid)
    if(data)then
        data.status=4
    end
    Net.moveActRedpos(Data.activityHolidaySign.idx,false,true,true)
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_28_REC)
end


----道具多选1info
function Net.sendActivityGetInfo29(data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, "act.getinfo29")
end

function Net.rec_act_getinfo29(evt)
   local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityInfo29=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_GETINFO_29)
end
----道具多选1
function Net.sendBuyItem29(actId,detid,itemid,num)

    local media=MediaObj:create()
    media:setInt("id", toint(actId))
    media:setInt("detid", toint(detid))
    media:setInt("itemid", toint(itemid))
    media:setInt("num", toint(num))
    Net.sendExtensionMessage(media, "act.rec29")
end

function Net.rec_act_rec29(evt)
   local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local actid = obj:getInt("id") 
    local detid = obj:getInt("detid")
    local count = obj:getInt("count")
    Data.updateActivity29ItemBuyNum(detid,count)
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_29_REC)
end


----累积充返
function Net.sendActivityPay(data)

    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_3)
end


function Net.recActivityPay(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityPayData=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_PAY)

end




----累积充返
function Net.sendActivityPayGet(idx,detid,itemid)
    local media=MediaObj:create()
    media:setInt("id", idx)
    media:setInt("detid", detid)
    if (itemid) then
        local vector_int_ = vector_int_:new_local()
        vector_int_:push_back(itemid)
        media:setIntArray("rewards",vector_int_)
    end
    Net.sendExtensionMessage(media, CMD_ACT_REC_3)
end


function Net.recActivityPayGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")
    Net.updateReward(obj:getObj("reward"),2)
    local payData=  Data.getActivityPayByDetid(detid)
    if(payData)then
        payData.rec=false
    end
    Net.dealActRecRedpos(detid,Data.activityPayData)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_PAY_GET)

end




----纯文本

function Net.sendActivityTxt(data)

    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_9)
end


function Net.recActivityTxt(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityPayData=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_TXT)

end

--每周礼包
function Net.sendActivityWeekGiftInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_ACT_WEEK_GIFT_INFO)
end
function Net.recActivityWeekGiftInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Data.activityWeekGiftInfo = {}
    Data.activityWeekGiftInfo.list = {}

    Data.activityWeekGiftInfo.refreshTime = obj:getInt("reftime")
    local detList=obj:getArray("list")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.idx = detObj:getInt("id")
            info.boxid = detObj:getInt("itemid")
            info.itemnum = detObj:getInt("itemnum")
            info.priceid = detObj:getInt("priceid")
            info.oldprice = detObj:getInt("oldprice")
            info.price = detObj:getInt("price")
            info.unum = detObj:getInt("unum")
            local max = detObj:getString("max")
            info.maxlist = string.split(max, ";")
            table.insert(Data.activityWeekGiftInfo.list,info)
        end
    end

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_WEEK_GIFT)
end
function Net.sendActivityBuyWeekGif(id)
    local media=MediaObj:create()
    media:setInt("id", id)
    Net.sendExtensionMessage(media, CMD_ACT_BUY_WEEK_GIFT)
end
function Net.recActivityBuyWeekGift(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    local id = obj:getInt("id")
    local unum = obj:getInt("unum")
    local data = Data.getActivityWeekGiftInfoByDetid(id)
    if(data)then
        data.unum = unum
    end

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_WEEK_GIFT_GET,id)
end

----充值返利
function Net.sendActivityChargeReturn(data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_6)
end

function Net.recActivityChargeReturn(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityChargeReturn=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_CHARGE_RETURN,Data.activityChargeReturn)
end

function Net.sendActivityChargeReturnGet(id,detid,itemid)
    local media=MediaObj:create()
    media:setInt("id", toint(id))
    media:setInt("detid", toint(detid))
    if(itemid)then
        local vector_int_ = vector_int_:new_local()
        vector_int_:push_back(itemid)
        media:setIntArray("rewards",vector_int_)
    end
    Net.sendExtensionMessage(media, CMD_ACT_REC_6)
    if (TalkingDataGA) then
        gLogEvent("activity_charge_return")
    end
end

function Net.recActivityChargeReturnGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local detid = obj:getInt("detid")
    Net.updateReward(obj:getObj("reward"),2)
    local payData= Data.getActivityChargeReturnByDetid(detid)
    if(payData)then
        payData.num=payData.num+1
    end
    Net.dealActivityChargeReturnRedpos(detid,Data.activityChargeReturn)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_CHARGE_RETURN_GET)

end

function Net.dealActivityChargeReturnRedpos(detid,data)
    --处理红点
    local bolRedpos = false
    for key, var in pairs(data.list) do
        if (var.num < var.count) then
            bolRedpos = true
            break
        end
    end
    if (not bolRedpos) then
        --删除
        local bolNewYear = false
        local bolHoliday = false
        local bolHefu = false
        if (data.param3 and data.param3==1) then
            bolNewYear = true
            for k,v in pairs(Data.redpos.act2) do
                if (v == data.idx) then
                    table.remove(Data.redpos.act2,k)
                    break;
                end
            end
            return;
        end
        if (data.param3 and data.param3==2) then
            bolHoliday = true
            for k,v in pairs(Data.redpos.act3) do
                if (v == data.idx) then
                    table.remove(Data.redpos.act3,k)
                    break;
                end
            end
            return;
        end
        if (data.param3 and data.param3==3) then
            bolHefu = true
            for k,v in pairs(Data.redpos.act4) do
                if (v == data.idx) then
                    table.remove(Data.redpos.act4,k)
                    break;
                end
            end
            return;
        end
        for k,v in pairs(Data.redpos.act) do
            if (v == data.idx) then
                table.remove(Data.redpos.act,k)
                break;
            end
        end
    end
end

----分享领取奖励
function Net.sendActivityShareGetInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "share.getinfo")
end

function Net.getShareListOne(id)
    for k,v in pairs(Data.activityShare.list) do
        if (id == v.id) then
            return v
        end
    end
    return nil
end

function Net.rec_share_getinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gUserInfo.rank = obj:getInt("rank");
    Data.activityShare = {}
    Data.activityShare.list = {}
    local detList=obj:getArray("list")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.id = detObj:getInt("id")
            info.plan = detObj:getInt("plan")
            info.finish = detObj:getBool("finish")
            info.share = detObj:getBool("share")
            info.rec = detObj:getBool("rec")
            table.insert(Data.activityShare.list,info)
        end
    end
    -- local size_db = #share_db
    -- local size_list = #Data.activityShare.list
    print_lua_table(Data.activityShare)

    for k,v in pairs(share_db) do
        local tmp_one = Net.getShareListOne(v.id)
        if (tmp_one) then
            tmp_one.request = v.request
            tmp_one.items = cjson.decode(v.reward)
            tmp_one.des = v.des
            tmp_one.achieve = true
        else
            local info={}
            info.id = v.id
            info.plan = 0
            info.finish = false
            info.share = false
            info.rec = false
            info.achieve = false -- 未达成
            info.request = v.request
            info.items = cjson.decode(v.reward)
            info.des = v.des
            table.insert(Data.activityShare.list,info)
        end
    end
    -- print("rec_share_getinfo")
    -- print_lua_table(Data.activityShare)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SHARE_GET_INFO)
end
-- function Net.sendActivityShareShare(id)
--     local media=MediaObj:create()
--     media:setInt("id", id)
--     Data.activityShare.shareId = id
--     Net.sendExtensionMessage(media, "share.share")
-- end
-- function Net.rec_share_share(evt)
--     local obj = evt.params:getObj("params")
--     if(obj:getByte("ret")~=0)then
--         return
--     end
--     local data= Data.getActivityShareByShareid(Data.activityShare.shareId)
--     if (data) then
--     end
--     gDispatchEvt(EVENT_ID_GET_ACTIVITY_SHARE_SHARE)
-- end
function Net.sendActivityShareRec(id)
    local media=MediaObj:create()
    media:setInt("id", id)
    Data.activityShare.shareId = id
    Net.sendExtensionMessage(media, "share.rec")
end
function Net.rec_share_rec(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local data= Data.getActivityShareByShareid(Data.activityShare.shareId)
    if (data) then
        data.rec = true
    end
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SHARE_REC)
end

--分享
function Net.sendShared(shareId)
    print("Net.sendShared(shareId) = "..shareId);
    local media=MediaObj:create();
    media:setInt("id", shareId);
    Net.sendExtensionMessage(media, "share.share");
end


--吃包子
function Net.sendActivityEatBun(data,click)
    local media=MediaObj:create()
    -- media:setInt("id", toint(data.actId))
    media:setInt("click", click)
    Net.sendExtensionMessage(media, "act.eatbun")
end
function Net.rec_act_eatbun(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local curServerTime = gGetCurServerTime(true);
    local curHour = gGetHourByTime(curServerTime)
    for key,var in pairs(Data.task.getEnergyTime) do
        if (curHour >= toint(var.time[1]) and curHour < toint(var.time[2])) then
            if (key==1) then
                Data.activityEatBun.eat1 = true
                break
            elseif (key==2) then
                Data.activityEatBun.eat2 = true
                break
            elseif (key==3) then
                Data.activityEatBun.eat3 = true
                break
            end
        end
    end

    Data.activityEatBun.shows = Net.updateReward(obj:getObj("reward"),0)
    -- print("--------------------")
    -- print_lua_table(Data.activityEatBun.shows)
    Data.activityEatBun.click = obj:getInt("click")
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EAT_BUN)

    

    --完成吃包子活动
    local ret = {};
    ret.id = TaskPanelData.energyTaskId;
    gDispatchEvt(EVENT_ID_TASK_GET,ret);
    TaskPanelData.energyTaskId = 0;

end
function Net.sendActivityEatBunInfo(data)
    local media=MediaObj:create()
    -- media:setInt("id", toint(data.actId))
    -- print("data.actId="..data.actId)
    Net.sendExtensionMessage(media, "act.ebinfo")
end
function Net.rec_act_ebinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local eatObj = obj:getObj("eatobj")
    Data.activityEatBun.eat1 = false
    Data.activityEatBun.eat2 = false
    Data.activityEatBun.eat3 = false
    if (eatObj) then
        Data.activityEatBun.eat1 = eatObj:getBool("eat1")
        Data.activityEatBun.eat2 = eatObj:getBool("eat2")
        Data.activityEatBun.eat3 = eatObj:getBool("eat3")
    end
    Data.activityEatBun.click = obj:getInt("click")
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EAT_BUN_INFO)
end

function Net.sendActivityEatBunStatus()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.ebstatus")
end
function Net.rec_act_ebstatus(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityEatBun.status = obj:getByte("status")
    print("Data.activityEatBun.status="..Data.activityEatBun.status)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_EAT_BUN_STATUS)
end


--n日成壕 act.getinfo17
function Net.sendActivity17(data,first)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first",first)
    Net.sendExtensionMessage(media, "act.getinfo17")
end
function Net.rec_act_getinfo17(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activity17Data=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_17,Data.activity17Data)
    -- print_lua_table(Data.activity17Data)
end
function Net.sendActivity17Rec(id,detid)
    local media=MediaObj:create()
    media:setInt("id", id)
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, "act.rec17")
end
function Net.rec_act_rec17(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")

    local data=  Data.getActivity17id(detid)
    if(data)then
        data.status=3
    end
    Data.redpos.richday = false
    for k,v in pairs(Data.activity17Data.list) do
        if (v.status == 2) then
            Data.redpos.richday = true
            break
        end
    end
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_17_REC)
end

function Net.sendActivityGetInfo97(type)
    local media=MediaObj:create()
    media:setByte("type", type)
    Net.sendExtensionMessage(media, "act.getinfo97")
end
function Net.rec_act_getinfo97(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local listArr={}
    local consumeArr={}
    local returnArr={}
    local boxArr={}
    local list=obj:getArray("list")
    if (list) then
        list=tolua.cast(list,"MediaArray")
        for i=0, list:count()-1 do
            local listObj=tolua.cast(list:getObj(i),"MediaObj")
            local item={}
            item.rec = listObj:getBool("rec")
            item.consume =listObj:getInt("consume")
            listArr[listObj:getInt("day")]=item
        end
    end

    list=obj:getArray("box")
    if (list) then
        list=tolua.cast(list,"MediaArray")
        for i=0, list:count()-1 do
            local listObj=tolua.cast(list:getObj(i),"MediaObj")
            local item={}
            item.day = listObj:getInt("day")
            item.boxid = listObj:getInt("boxid")
            item.rec = listObj:getBool("rec")
            table.insert(boxArr,item)
        end
    end

    list=obj:getIntArray("consume")
    if(list)then
        for i=0, list:size()-1 do
            consumeArr[i+1]=list[i]
        end
    end

    list=obj:getIntArray("return")
    if(list)then
        for i=0, list:size()-1 do
            returnArr[i+1]=list[i]
        end
    end



    local ret={}
    ret.listArr=listArr
    ret.consumeArr=consumeArr
    ret.returnArr=returnArr
    ret.boxArr=boxArr
    ret.dayneed=obj:getInt("dayneed")
    ret.desc=obj:getString("desc")
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_97_GETINFO,ret)
end


function Net.sendActivityRec97Day(type,day,callback)
    local media=MediaObj:create()
    media:setByte("type", type)
    media:setInt("day", day)
    Net.sendActivityRec9DayCall=callback
    Net.sendExtensionMessage(media, "act.rec97day")
end

function Net.rec_act_rec97day(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    if( Net.sendActivityRec9DayCall)then
        Net.sendActivityRec9DayCall()
    end
end


function Net.sendActivityRec97Box(type,day,callback)
    local media=MediaObj:create()
    media:setByte("type", type)
    media:setInt("day", day)
    Net.sendActivityRec97BoxCall=callback
    Net.sendExtensionMessage(media, "act.rec97box")
end

function Net.rec_act_rec97box(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    if( Net.sendActivityRec97BoxCall)then
        Net.sendActivityRec97BoxCall()
    end
end


--开门红 act.getinfo19
function Net.sendActivity19(data,first)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setBool("first",first)
    Net.sendExtensionMessage(media, "act.getinfo19")
end
function Net.rec_act_getinfo19(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activity19Data=Net.parseActivityObj(obj)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_19,Data.activity19Data)
    -- print_lua_table(Data.activity19Data)
end
function Net.sendActivity19Rec(id,detid)
    local media=MediaObj:create()
    media:setInt("id", id)
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, "act.rec19")
end
function Net.rec_act_rec19(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")

    local data=  Data.getActivity19id(detid)
    if(data)then
        data.num=data.num+1
    end
    if (Data.activity19Data.begintime <= gGetCurServerTime() and Data.activity19Data.endtime >= gGetCurServerTime()) then
        for k,v in pairs(Data.activity19Data.list) do
            if (v.num > 0) then
                Net.moveActRedpos(Data.activity19Data.idx,true)
                break
            end
        end
    end
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_19_REC,data.num)
end

--
function Net.sendActivity96(data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    Net.sendExtensionMessage(media, "act.getinfo96")
end
function Net.rec_act_getinfo96(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local num = obj:getInt("num")
    local per = obj:getInt("per")
    local eng = obj:getInt("eng")
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_96,{num=num,per=per,eng=eng})
end



function Net.sendActivityBoxInfo(id,callback)
    local media=MediaObj:create()
    media:setInt("id", id)
    Net.sendActivityBoxInfoCallback=callback
    Net.sendExtensionMessage(media, "item.boxinfo")
end
function Net.rec_item_boxinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local list=obj:getArray("list")
    if (list) then
        list=tolua.cast(list,"MediaArray")
        for i=0, list:count()-1 do
            local listObj=tolua.cast(list:getObj(i),"MediaObj")
            local item={}
            item.itemid=listObj:getInt("id")
            item.itemnum=listObj:getInt("num")
            table.insert( ret  ,item)
        end
    end
    if(Net.sendActivityBoxInfoCallback)then
        Net.sendActivityBoxInfoCallback(ret)
    end
end



--喜从天降
function Net.sendActivityGetInfo20(id)
    local media=MediaObj:create()
    media:setInt("id", id)
    Net.sendExtensionMessage(media, "act.getinfo20")
end
function Net.rec_act_getinfo20(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local action={}
    action.idx = obj:getInt("id")
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.desc = obj:getString("desc")
    local detList=obj:getArray("det")
    action.list={}
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.detid = detObj:getInt("detid")
            info.name = detObj:getString("name")
            info.price = detObj:getInt("price")
            info.boxid = detObj:getInt("boxid")
            info.num = detObj:getInt("num")
            info.max = detObj:getInt("max")
            info.boxName = detObj:getString("boxname")
            info.items={}
            local pList=detObj:getArray("items")
            if(pList)then
                pList=tolua.cast(pList,"MediaArray")
                for j=1, pList:count() do
                    local itemObj=tolua.cast(pList:getObj(j-1),"MediaObj")
                    local item={}
                    item.id =itemObj:getInt("id") 
                    item.num =itemObj:getInt("num")
                    table.insert(info.items,item) 
                end
            end 
            table.insert(action.list,info)
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_RED_PACKAGE,action)
end


function Net.sendActivityRec20(id,detid,callback)
    local media=MediaObj:create()
    media:setInt("id", id)
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, "act.rec20")
    Net.sendActivityRec20Callback=callback
end
function Net.rec_act_rec20(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),1)
    if(Net.sendActivityRec20Callback)then
        Net.sendActivityRec20Callback()
    end
end


--抢红包
function Net.sendActivityLoot20(id,callback)
    local media=MediaObj:create()
    media:setLong("id", id) 
    Net.sendActivityLoot20Param=id
    Net.sendActivityLoot20Callback=callback
    Net.sendExtensionMessage(media, "act.loot20")
end
function Net.rec_act_loot20(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel and panel.__panelType==PANEL_RED_PACKAGE_RAIN)then
            Panel.popBack(panel:getTag())
        end
        return
    end
    local list=Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_LOOP_PACKAGE,Net.sendActivityLoot20Param)
    local items={}
    if(list)then
        items=list.items
    end  
    Panel.popUpVisible(PANEL_RED_PACKAGE_REWARD,items,nil,true); 
    if(table.count(items)>0)then 
        Data.loopPackNum=Data.loopPackNum+1
    end
    if(Net.sendActivityLoot20Callback)then
        Net.sendActivityLoot20Callback()
    end
end


function Net.sendActivityRedPackInfo(id)
    local media=MediaObj:create()
    media:setLong("id", id) 
    Net.sendExtensionMessage(media,  "act.redpackinfo")
end
function Net.rec_act_redpackinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    ret.time=obj:getInt("time")
    ret.count=obj:getInt("count")
    ret.icon=obj:getInt("icon")
    ret.name=obj:getString("name")
    ret.id =obj:getInt("id") 
    ret.num =obj:getInt("num") 
    ret.list={} 
    local pList=obj:getArray("list")
    if(pList)then
        pList=tolua.cast(pList,"MediaArray")
        for j=1, pList:count() do
            local itemObj=tolua.cast(pList:getObj(j-1),"MediaObj")
            local item={}
            item.id =itemObj:getInt("id")
            item.name =itemObj:getString("name") 
            item.num =itemObj:getInt("num") 
            item.icon =itemObj:getInt("icon")
            table.insert(ret.list,item)
        end
    end
    Panel.popUpVisible(PANEL_RED_PACKAGE_DETAIL,ret,nil,true);
    
end
 

--红包列表
function Net.sendActivityGetList20()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getlist20")
end
function Net.rec_act_getlist20(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local pList=obj:getArray("list")
    if(pList)then
        pList=tolua.cast(pList,"MediaArray")
        for j=1, pList:count() do
            local itemObj=tolua.cast(pList:getObj(j-1),"MediaObj")
            local item={}
            item.id =itemObj:getLong("id")
            item.name =itemObj:getString("name") 
            item.time =itemObj:getInt("time")
            item.loot =itemObj:getBool("loot") 
            table.insert(ret,item)
        end
    end
    Panel.popUpVisible(PANEL_RED_PACKAGE,ret,nil,true);
    
end

function Net.sendActivityFreeVipInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getinfo23")
end
function Net.rec_act_getinfo23(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityFreeVipData={}
    -- Data.activityFreeVipData.acoin = obj:getInt("acoin")
    Data.activityFreeVipData.list = {}
    local pList=obj:getArray("list")
    if(pList)then
        pList=tolua.cast(pList,"MediaArray")
        for j=1, pList:count() do
            local itemObj=tolua.cast(pList:getObj(j-1),"MediaObj")
            local item={}
            item.stall =itemObj:getByte("stall")
            item.rec =itemObj:getByte("rec")
            -- item.needact =itemObj:getInt("needact")
            -- item.needvip =itemObj:getByte("needvip") 
            -- item.vipscore =itemObj:getInt("vipscore")
            table.insert(Data.activityFreeVipData.list,item)
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_23,Data.activityFreeVipData)
end
function Net.sendActivityFreeVipRec(stall)
    local media=MediaObj:create()
    media:setByte("stall", stall)
    Net.sendExtensionMessage(media, "act.rec23")
end
function Net.rec_act_rec23(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local stall = obj:getByte("stall")
    local data=  Data.getActivity23id(stall)
    if(data)then
        data.rec=2
    end

    Net.updateReward(obj:getObj("reward"),2);

    --处理红点
    Data.redpos.act23 = false
    for key, var in pairs( Data.activityFreeVipData.list) do
        if (var.rec == 1 and gUserInfo.acoin>= Data.activity.free_vip_need_acoin[var.stall]) then
            Data.redpos.act23 = true
            break
        end
    end
    -- print_lua_table(Data.activityFreeVipData.list)
    
    -- Net.parseUserInfo(obj:getObj("uvobj"))
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_23_REC)
end


--招募
function Net.sendActivityRecruitInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getinfo93")
end
function Net.rec_act_getinfo93(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Data.activityRecruitData.isrecruit = obj:getBool("isrecruit")
    
    if (Data.activityRecruitData.isrecruit) then
        Data.activityRecruitData.list = {}
        local pList=obj:getArray("info")
        if(pList)then
            pList=tolua.cast(pList,"MediaArray")
            for j=1, pList:count() do
                local itemObj=tolua.cast(pList:getObj(j-1),"MediaObj")
                local item={}
                item.id =itemObj:getInt("id")
                item.num =itemObj:getInt("num")
                item.rnum =itemObj:getInt("rnum")
                table.insert(Data.activityRecruitData.list,item)
            end
        end
        Data.activityRecruitData.count = obj:getInt("count")
        Data.emoney = obj:getInt("emoney")
        Data.activityRecruitData.finish = obj:getByte("finish")

        -- print_lua_table(Data.activityRecruitData)
        -- gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
        -- gDispatchEvt(EVENT_ID_GET_ACTIVITY_RECRUIT,Data.activityRecruitData)
        -- return
    end
    print_lua_table(Data.activityRecruitData)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_RECRUIT_INFO,Data.activityRecruitData)
end
function Net.sendActivityRecruit(uid)
    local media=MediaObj:create()
    media:setLong("codeid", uid)
    Net.sendExtensionMessage(media, "act.recruit93")
end
function Net.rec_act_recruit93(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gLogEvent("act.recruit")
    Net.updateReward(obj:getObj("reward"),2);
    -- Data.activityRecruitData.emoney = obj:getInt("emoney")
    Net.sendActivityRecruitInfo()

    -- gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    -- gDispatchEvt(EVENT_ID_GET_ACTIVITY_RECRUIT)
end
function Net.sendActivityRecruitRec(id)
    local media=MediaObj:create()
    media:setInt("id", id)
    Net.sendExtensionMessage(media, "act.rec93")
end
function Net.rec_act_rec93(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2);
    local id = obj:getInt("id")
    local num = obj:getInt("num")
    local rnum = obj:getInt("rnum")
    local data=  Data.getActivity93id(id)
    if(data)then
        data.num=num
        data.rnum=rnum
    end
    --判断红点
    Data.redpos.act93 = false
    for k,v in pairs(Data.activityRecruitData.list) do
        if (v.id~=1 and v.num>0 and v.rnum>=v.num) then
            Data.redpos.act93 = true
            break
        end
    end
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_RECRUIT_REC)
end
function Net.sendActivityPublish()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.publish93")
end
function Net.rec_act_publish93(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local uid = obj:getLong("codeid")
    Data.activityRecruitData.uid = uid
    -- print("------------------uid="..uid)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_PUBLISH)
end

function Net.sendActivityFirstPay()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getinfo90")
end
function Net.rec_act_getinfo90(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret = {}
    ret.money = obj:getInt("money")
    ret.needmoney = obj:getInt("needmoney")
    gDispatchEvt(Data.bolFisrtSend and EVENT_ID_GET_ACTIVITY_FIRST_PAY_INFO1 or EVENT_ID_GET_ACTIVITY_FIRST_PAY_INFO,ret)
end

----小初活动
function Net.sendActivity26(data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    Net.sendExtensionMessage(media, "act.getinfo26")
end

function Net.rec_act_getinfo26(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local action={}
    action.idx = obj:getInt("id")
    action.type = obj:getByte("type")
    action.myrank = obj:getInt("myrank")
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.updatetime = obj:getInt("updatetime")
    action.desc = obj:getString("desc")
    action.entry = obj:getInt("entry")
    action.ch_num = obj:getInt("num")
    action.cardid = obj:getInt("cardid")
    action.grade = obj:getInt("grade")
    action.list={}


    local detList=obj:getArray("det")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=0, detList:count()-1 do
            local detObj=tolua.cast(detList:getObj(i),"MediaObj")
            local info={}
            info.idx = detObj:getInt("detid")
            info.name = detObj:getString("name")
            info.rank1 = detObj:getInt("rank1")
            info.rank2 = detObj:getInt("rank2")
            info.rec = detObj:getBool("rec")
            info.max = detObj:getInt("max")
            if(detObj:containsKey("cnt")) then
                info.cur = detObj:getInt("cnt")
            else
                info.cur = detObj:getInt("num")
            end
            info.iapid = detObj:getInt("iapid")
            info.count = detObj:getInt("count")
            info.itemidList={}
            info.numList={}
            info.numList2={}
            info.numInBagList={}
            local itemList=detObj:getArray("items")
            if(itemList)then
                itemList=tolua.cast(itemList,"MediaArray")
                for i=0, itemList:count()-1 do
                    local itemObj=tolua.cast(itemList:getObj(i),"MediaObj")
                    table.insert(info.itemidList,itemObj:getInt("id"))
                    table.insert(info.numList,itemObj:getInt("qty"))
                    table.insert(info.numList2,itemObj:getInt("lv"))
                    table.insert(info.numInBagList,itemObj:getInt("bagqty"))

                end
            end
            table.insert(action.list,info)
        end
    end

    Data.activity26Data=action
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_26,action)
end

function Net.sendActivity26Buy(detid,data)
    local media=MediaObj:create()
    media:setInt("id", toint(data.actId))
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, "act.rec26")
end
function Net.rec_act_rec26(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local detid = obj:getInt("detid")
    Net.updateReward(obj:getObj("reward"),2)
    local saleData=  Data.get26DataByDetid(detid)
    if(saleData)then
        saleData.cur=saleData.cur+1
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_26_REC)
end

function Net.sendActivityVipExperienceInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getinfo88")
end

function Net.rec_act_getinfo88(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local action={}
    action.begintime = obj:getInt("starttime")
    action.endtime = obj:getInt("endtime")
    action.vip = obj:getInt("vip")
    action.time = obj:getInt("time")
    action.isget = obj:getByte("isget")==1
    action.isgetrwd = obj:getByte("isgetrwd")==1
    action.remaintime = obj:getInt("remaintime") --vip到期时间
    action.ids = {}
    local list=obj:getIntArray("ids")
    if(list)then
        for i=0, list:size()-1 do
            action.ids[i+1]=list[i]
            --print("奖励物品:"..list[i])
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_VIPEXP_INFO,action)
end

function Net.sendActivityVipExperienceGetVip()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getvip88")
end

function Net.rec_act_getvip88(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local action={}
    action.remaintime = obj:getInt("remaintime") --vip到期时间
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_VIPEXP_GETVIP,action)
    
end

function Net.sendActivityVipExperienceGetRwd()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.getreward88")
end

function Net.rec_act_getreward88(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_VIPEXP_GETRWD)
end

-- 排行榜活动
-- CMD_ACT_GET_INFO_10 = "act.getinfo10"
function Net.sendActivityRank(id)
    local media = MediaObj:create()
    media:setInt("id", id)
    media:setBool("first", true)
    Net.sendExtensionMessage(media, CMD_ACT_GET_INFO_10)
end

function Net.rec_act_getinfo10(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gDispatchEvt(EVENT_ID_GET_ACTIVITY_10, Net.getActInfoData(obj))
end

---领取排行活动奖励
-- CMD_ACT_REC_10 = "act.rec10"
function Net.sendGetActivityRankReward(id, detid)
    local media = MediaObj:create()
    media:setInt("id", id)
    media:setInt("detid", detid)
    Net.sendExtensionMessage(media, CMD_ACT_REC_10)
end

function Net.rec_act_rec10(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_10_REC,{actId=obj:getInt("id"),detId=obj:getInt("detid")})
end

function Net.sendActivitySnatchInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.snatchinfo")
end
function Net.rec_act_snatchinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local action={}
    action.score = obj:getInt("score")
    action.list={}
    local detList=obj:getArray("list")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.idx = detObj:getInt("id")
            info.curnum = detObj:getInt("curnum")
            info.curturn = detObj:getInt("curturn")
            info.itemnum = detObj:getInt("itemnum")
            info.itemname = detObj:getString("itemname")
            info.maxunm = detObj:getInt("maxnum")
            info.maxturn = detObj:getInt("maxturn")
            table.insert(action.list,info)
        end
    end
    action.nlist={}
    local nList=obj:getArray("nlist")
    if(nList)then
        nList=tolua.cast(nList,"MediaArray")
        for i=1, nList:count() do
            local nObj=tolua.cast(nList:getObj(i-1),"MediaObj")
            local notice={}
            notice.id = nObj:getInt("id")
            notice.name = nObj:getString("name")
            notice.itemid = nObj:getInt("itemid")
            notice.itemnum = nObj:getInt("itemnum")
            notice.money = nObj:getInt("money")
            notice.type = nObj:getByte("type")
            table.insert(action.nlist,notice)
        end
    end

    Data.activitySnatchData = action
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SNATCH_INFO)
end

function Net.sendActivitySnatch(itemid,curturn,num)
    local media=MediaObj:create()
    media:setInt("itemid",itemid)
    media:setInt("curturn",curturn)
    media:setInt("num",num)
    Net.sendExtensionMessage(media, "act.snatch")
end


function Net.rec_act_snatch(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        Net.sendActivitySnatchInfo()
        return
    end
    local score = obj:getInt("score")
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SNATCH_UPDATESCORE,score-Data.getSnatchScore())
    Net.rec_act_snatchinfo(evt)
    Net.updateReward(obj:getObj("reward"),2);
end


function Net.sendActivitySnaShopInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "act.snashopinfo")
end
function Net.rec_act_snashopinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local action={}
    action.list={}
    local detList=obj:getArray("list")
    if(detList)then
        detList=tolua.cast(detList,"MediaArray")
        for i=1, detList:count() do
            local detObj=tolua.cast(detList:getObj(i-1),"MediaObj")
            local info={}
            info.itemid = detObj:getInt("itemid")
            info.pos =  info.itemid
            info.buyNum = detObj:getInt("num")
            info.limitNum = detObj:getInt("maxnum")
            info.itemnum = detObj:getInt("itemnum")
            info.num = info.limitNum-info.buyNum
            info.price = detObj:getInt("price")
            info.costType = OPEN_BOX_SNATCH_MONEY;
            info.type     = SHOP_TYPE_SNATCH;
            table.insert(action.list,info)
        end
    end
    gShops[SHOP_TYPE_SNATCH].items = action.list
    local data = gShops[SHOP_TYPE_SNATCH];
    gDispatchEvt(EVENT_ID_INIT_SHOP,data)
end

function Net.sendActivitySnaBuy(itemid,num)
    local media=MediaObj:create()
    media:setInt("itemid",itemid)
    media:setInt("num",num)
    Net.sendExtensionMessage(media, "act.snabuy")
end
function Net.rec_act_snabuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local itemid = obj:getInt("itemid")
    local buyNum = obj:getInt("num")
    Data.activitySnatchData.score = obj:getInt("score")
    Net.updateReward(obj:getObj("reward"),2);
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE);

    for key,item in pairs(gShops[SHOP_TYPE_SNATCH].items)do
        if item.itemid == itemid then
            item.buyNum = buyNum
            item.num = item.limitNum-item.buyNum
        end
    end
    gDispatchEvt(EVENT_ID_GET_ACTIVITY_SNATCH_INFO);
    gDispatchEvt(EVENT_ID_SHOP_REFRESH);
end
 