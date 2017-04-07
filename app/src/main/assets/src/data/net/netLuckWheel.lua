
function Net.sendGetLuckWheelInfo(type,data, actid,lasttime)

    local media=MediaObj:create()
    media:setByte("type",type);
    media:setBool("data",data);
    media:setInt("actid",actid);
    media:setInt("lasttime",lasttime);
    Net.sendGetLuckWheelInfoParam=type
    Net.sendExtensionMessage(media, "turn.getinfo")
end


function Net.rec_turn_getinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    if obj:containsKey("actid") and gLuckWheel.actid and gLuckWheel.actid~=obj:containsKey("actid") then
            gLuckWheel={}
    end
    local type=Net.sendGetLuckWheelInfoParam
    if(gLuckWheel["type"..type]==nil)then
        gLuckWheel["type"..type]={}
    end
    local curData=gLuckWheel["type"..type]

    local turnItem=obj:getArray("turn")
    local isCloseReward=true
    if(turnItem)then

        curData.items={}
        turnItem=tolua.cast(turnItem,"MediaArray")
        for i=0, turnItem:count()-1 do
            local obj=turnItem:getObj(i)
            obj=tolua.cast(obj,"MediaObj")
            local item={}
            item.id=obj:getInt("icon")
            item.icon1=obj:getInt("icon1")
            item.numdes=gReplaceWtoK(obj:getString("numdes"))
            item.rewarddes=obj:getString("rewarddes")
            item.reward=obj:getBool("reward")
            table.insert(curData.items,item) 
            if(item.reward==true)then
                isCloseReward=false 
            end
        end


        gLuckWheel["type"..type].itemid=obj:getInt("itemid")
        gLuckWheel["type"..type].rewardnum=obj:getInt("rewardnum")
        gLuckWheel["type"..type].freenum=obj:getInt("freenum")
        gLuckWheel["type"..type].turnnum=obj:getInt("turnnum")
    end
    
    gLuckWheel["type"..type].closeReward=isCloseReward
    
    if obj:containsKey("actid") then
        gLuckWheel.actid=obj:getInt("actid")
    end
    if obj:containsKey("endtime") then
        gLuckWheel.endTime=obj:getInt("endtime")
    end

    if obj:containsKey("score") then
        gLuckWheel.score=obj:getInt("score")
    end 

    -- print("###########")
    -- print_lua_table(gLuckWheel);

    local addNotice=Net.addTurnLuckNotice(obj:getArray("notice"))
    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel and panel.__panelType==PANEL_ACTIVITY_LUCK_WHEEL)then
        gDispatchEvt(EVENT_ID_LUCK_WHEEL_INFO,addNotice)
    else
        Panel.popUp(PANEL_ACTIVITY_LUCK_WHEEL,nil,nil,false)
    end
end


function Net.addTurnLuckNotice(noticeItem)
    if(gLuckWheel.notice==nil)then
        gLuckWheel.notice={}
    end
    local addNotice={}
    if(noticeItem)then
        noticeItem=tolua.cast(noticeItem,"MediaArray")
        for i=0, noticeItem:count()-1 do
            local obj=noticeItem:getObj(i)
            obj=tolua.cast(obj,"MediaObj")
            local item={}
            item.name=obj:getString("name")
            item.type=obj:getByte("type")
            item.id=obj:getInt("itemid")
            item.num=obj:getInt("itemnum")
            table.insert(gLuckWheel.notice,1,item)
            table.insert(addNotice,1,item)
        end
    end
    local maxNum=30
    for i=maxNum, table.getn(gLuckWheel.notice) do
        table.remove(gLuckWheel.notice,maxNum)
    end 
    gLuckWheel.curTime=gGetCurServerTime()
    return addNotice
end

function Net.sendTurnLuckWheel(type,actiontype,num,cost)

    local media=MediaObj:create()
    media:setByte("type",type);
    media:setByte("actiontype",actiontype);
    media:setInt("num",num);
    media:setInt("lasttime",gLuckWheel.curTime)
    Net.sendTurnLuckWheelParam=type
    Net.sendExtensionMessage(media, "turn.action")
    local td_param = {}
    td_param['num'] = tostring(num)
    td_param['cost'] = tostring(cost)
    gLogEvent("turn_action_" .. tostring(type) .."_" .. tostring(actiontype), td_param)
end


function Net.rec_turn_action(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local type=Net.sendTurnLuckWheelParam
    local curData=gLuckWheel["type"..type] 
    gLuckWheel["type"..type].freenum=obj:getInt("freenum")
    gLuckWheel["type"..type].turnnum=obj:getInt("turnnum")


    gLuckWheel.score=obj:getInt("score")
    Net.updateReward(obj:getObj("reward"),0)
    local addNotice=Net.addTurnLuckNotice(obj:getArray("notice"))
    local results={}

    local resultList=obj:getArray("result")
    if(resultList)then
        resultList=tolua.cast(resultList,"MediaArray")
        for i=0, resultList:count()-1 do
            local obj=resultList:getObj(i)
            local resultObj=tolua.cast(obj,"MediaObj") 
            local result={}
            result.idx=resultObj:getInt("idx")
            result.id=resultObj:getInt("itemid")
            result.num=resultObj:getInt("itemnum")
            result.flower=resultObj:getBool("flower")
            curData.rewardnum=resultObj:getInt("rewardnum")
            table.insert(results,result)
        end
    end
    gDispatchEvt(EVENT_ID_LUCK_WHEEL_TURN,{notice=addNotice,result=results})
end

function Net.sendGetLuckWheelRewardInfo()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "turn.scorewinfo")
end


function Net.rec_turn_scorewinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local  list=obj:getBoolArray("rec")
    if(list)then
        for i=0, list:size()-1 do
            table.insert( ret,list[i])
        end
    end
    gLuckWheel.rewardRec=ret
    Panel.popUp( PANEL_ACTIVITY_LUCK_REWARD )
end




function Net.sendGetLuckWheelReward(idx,key)

    local media=MediaObj:create()
    media:setInt("idx",idx)
    Net.sendGetLuckWheelRewardParam={}
    Net.sendGetLuckWheelRewardParam.idx=idx
    Net.sendGetLuckWheelRewardParam.key=key
    Net.sendExtensionMessage(media, "turn.recscorew")
end


function Net.rec_turn_recscorew(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    local idx=Net.sendGetLuckWheelRewardParam.idx
    gLuckWheel.rewardRec[idx+1]=true
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_LUCK_WHEEL_REWARD_REC,Net.sendGetLuckWheelRewardParam.key)  
end