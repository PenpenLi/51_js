 
----叛军副本
function Net.sendCrusadeFight(id,type) 
    local media=MediaObj:create()
    media:setLong("id",  id)
    media:setByte("type",type)  
    Net.sendExtensionMessage(media, CMD_CRUSADE_FIGHT)
    if (TalkingDataGA) then
        gLogEvent("rebel.kill")
    end
end




function Net.recCrusadeFight(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    
    
    gCrusadeData.reward={}
    gCrusadeData.reward.feats=obj:getInt("feats")-gCrusadeData.feats
    gCrusadeData.reward.exploits=obj:getInt("exploits")-gCrusadeData.exploits
    gCrusadeData.reward.damage= obj:getInt("damage")
    local db=DB.getMonsterById( obj:getInt("boss") )
    if(db)then
        gBossHead= db.cardid
    end
    gCrusadeData.feats=obj:getInt("feats") 
    gCrusadeData.exploits=obj:getInt("exploits")
    
    gParserGameVideo(byteArr,BATTLE_TYPE_CRUSADE)
end
 

function Net.sendCrusadeInfo(callback)

    local media=MediaObj:create() 
    Net.sendCrusadeInfoCallback=callback
    Net.sendExtensionMessage(media, CMD_CRUSADE_GETINFO) 
end


function Net.recCrusadeInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    ret.feats =obj:getInt("feats")  -- 今日功勋   
    ret.exploits =obj:getInt("exploits")  --  累计战功    
    ret.crunum =obj:getInt("crunum")  --  当前可征讨次数        
    ret.buynum =obj:getInt("buynum")  --  今日购买次数                 
    ret.list={}

    local  list=obj:getArray("list")
    if(list)then
        list=tolua.cast(list,"MediaArray")
        for i=0, list:count()-1 do
            table.insert(ret.list,Net.parseCrusadeObj(list:getObj(i)))
        end
    end           
    gCrusadeData=ret 
    
    if(Net.sendCrusadeInfoCallback)then
        Net.sendCrusadeInfoCallback()
        return 
    end
    if(Net.sendCrusadeInfoCallbackBreak)then
        Net.sendCrusadeInfoCallbackBreak=false
        return
    end

    if gMainBgLayer == nil then
        Scene.enterMainScene();
    end
    
    if( Panel.isTopPanel(PANEL_CRUSADE) )then
        gDispatchEvt(EVENT_ID_REFRESH_CRUSADE,ret)
    else 
        Panel.popUp(PANEL_CRUSADE,ret) 
    end
end


function Net.sendCrusadeShare(id)

    local media=MediaObj:create() 
    media:setLong("id", id)
    Net.sendCrusadeShareParam=id
    Net.sendExtensionMessage(media, CMD_CRUSADE_SHARE)
    if (TalkingDataGA) then
        gLogEvent("rebel.share")
    end
end


function Net.recCrusadeShare(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    gDispatchEvt(EVENT_ID_CRUSADE_SHARE,Net.sendCrusadeShareParam)
    Net.sendCrusadeShareParam=nil
end


function Net.sendCrusadeBuy(num)

    local media=MediaObj:create() 
    media:setInt("num",num)
    Net.sendCrusadeBuyParam=num
    Net.sendExtensionMessage(media, CMD_CRUSADE_BUY)
end


function Net.recCrusadeBuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    gCrusadeData.buynum=gCrusadeData.buynum+Net.sendCrusadeBuyParam
    gDispatchEvt(EVENT_ID_CRUSADE_BUY)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)  
end



function Net.sendCrusadeFeatOneKey() 
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "cru.recallfeats")
end


function Net.rec_cru_recallfeats(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2) 
    
    for key, var in pairs( gCrusadeData.featRec.list) do 
        gCrusadeData.featRec.list[key]=true 
    end
    gDispatchEvt(EVENT_ID_CRUSADE_FEAT_ALL ) 
end



function Net.sendCrusadeFeats()

    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, CMD_CRUSADE_FEATS)
end


function Net.recCrusadeFeats(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local ret={}
    ret.level =obj:getInt("level")               
    ret.list={}

    local  list=obj:getBoolArray("rec")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(ret.list,list[i])
        end
    end    
    gCrusadeData.featRec=ret
    Panel.popUp(PANEL_CRUSADE_FEAT,ret)
end


function Net.sendCrusadeRevFeats(idx,key)

    local media=MediaObj:create() 
    media:setInt("idx",idx)
    Net.sendCrusadeRevFeatsParam={}
    Net.sendCrusadeRevFeatsParam.idx=idx
    Net.sendCrusadeRevFeatsParam.key=key
    Net.sendExtensionMessage(media, CMD_CRUSADE_RECEIVE_FEATS)
end


function Net.recCrusadeRevFeats(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local idx=Net.sendCrusadeRevFeatsParam.idx
    gCrusadeData.featRec.list[idx+1]=true 
    gDispatchEvt(EVENT_ID_CRUSADE_FEAT_REC,Net.sendCrusadeRevFeatsParam.key)
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)  

end


function Net.sendCrusadeShopBuy(id,num,cost)

    local media=MediaObj:create() 
    media:setInt("id",id)
    media:setInt("num",num)
    Net.sendCrusadeShopBuyParam=cost
    Net.sendExtensionMessage(media, CMD_CRUSADE_SHOP_BUY)
end


function Net.recCrusadeShopBuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gCrusadeData.exploits=gCrusadeData.exploits-Net.sendCrusadeShopBuyParam
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_CRUSADE_SHOP_BUY)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)  

end

function Net.sendCrusadeGetNum()

    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, CMD_CRUSADE_GETNUM)
end


function Net.recCrusadeGetNum(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gDispatchEvt(EVENT_ID_CRUSADE_GET_NUM,obj:getInt("num"))  

end

function Net.sendCrusadeAddToken()

    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, CMD_CRUSADE_ADD_TOKEN)
end


function Net.recCrusadeAddToken(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

end

function Net.sendCrusadeCallInfo()
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, CMD_CRUSADE_CALLINFO)
end


function Net.recCrusadeCallInfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    
    local ret={}
    ret.eng =obj:getInt("eng")      
    ret.list={}

    local  list=obj:getBoolArray("rec")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(ret.list,list[i])
        end
    end    
    gCrusadeData.callInfo=ret
    Panel.popUp(PANEL_CRUSADE_CALL,ret)
end

function Net.sendCrusadeCall(idx,key)

    local media=MediaObj:create() 
    media:setInt("idx",idx)
    Net.sendCrusadeCallParam={}
    Net.sendCrusadeCallParam.idx=idx
    Net.sendCrusadeCallParam.key=key
    Net.sendExtensionMessage(media, CMD_CRUSADE_CALL)
end


function Net.recCrusadeCall(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local idx=Net.sendCrusadeCallParam.idx
    gCrusadeData.callInfo.list[idx+1]=true 
    gDispatchEvt(EVENT_ID_CRUSADE_CALL,Net.sendCrusadeCallParam.key)
    -- 显示动画
    local cru=nil
    if(obj:containsKey("cru"))then
        cru={}
        local curObj=obj:getObj("cru")
        cru.name=curObj:getString("name")
        cru.level=curObj:getInt("lv")
        cru.id=curObj:getLong("id")
        cru.cid=curObj:getInt("cid")
        cru.quality=curObj:getByte("quality")
        cru.mid = curObj:getInt("mid")
    end
    if (cru ~= nil) then
        Panel.popUp(PANEL_CRUSADE_CALL_FLA,cru) 
    end
end

