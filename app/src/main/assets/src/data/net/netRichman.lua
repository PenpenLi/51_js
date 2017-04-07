
function Net.sendRichmanEnter(init)

    local media=MediaObj:create()
    media:setBool("init",init); 
    Net.sendExtensionMessage(media, "richman.enter")
    
end

function Net.rec_richman_enter(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local info={}
    local posInfo={}
    local list=obj:getIntArray("list")
    if(list)then
        for i=0, list:size()-1 do
           posInfo[i+1]=list[i]
        end
    end
    gRichman.posInfo=posInfo
    gRichman.curPos=obj:getInt("pos")
    gRichman.score=obj:getInt("score")
    gRichman.rank=obj:getInt("rank")
    gRichman.actionnum=obj:getInt("actionnum")
    gRichman.lucknum=obj:getInt("lucknum")
    gRichman.buynum=obj:getInt("buynum")

    gDispatchEvt(EVENT_ID_RICHMAN_ENTER)
    Panel.popUp(PANEL_RICHMAN)
    
end
 


function Net.sendRichmanAction(count)

    local media=MediaObj:create()
    media:setInt("count",count); 
    Net.sendExtensionMessage(media, "richman.action")
end

function Net.rec_richman_action(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local rewards=Net.updateReward(obj:getObj("reward"),0)
    local ret={}
    ret.movecount=obj:getInt("movecount")
    ret.eventid=obj:getInt("eventid")
    ret.shopid=obj:getInt("shopid") 
    ret.count=obj:getInt("count") 
    ret.rewards=rewards
    ret.firstReward=Net.updateReward(obj:getObj("firstreward"),0)
    ret.firstScore=obj:getInt("firstscore")
    gRichman.actionnum=obj:getInt("actionnum")
    gRichman.score=obj:getInt("score")
    gRichman.rank=obj:getInt("rank") 
    gRichman.lucknum=obj:getInt("lucknum") 

    gDispatchEvt(EVENT_ID_RICHMAN_ACTION,ret)
    
end
 


function Net.sendRichmanShopBuy()

    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "richman.shopbuy")
end

function Net.rec_richman_shopbuy(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    gRichman.lucknum=obj:getInt("lucknum")
    Net.updateReward(obj:getObj("reward"),2)  
    gDispatchEvt(EVENT_ID_RICHMAN_SHOPBUY)
end
 
 
function Net.sendRichmanBuyAction(count)

    local media=MediaObj:create() 
    media:setInt("num",count)
    Net.sendRichmanBuyActionParam=count
    Net.sendExtensionMessage(media, "richman.buyaction")
end

function Net.rec_richman_buyaction(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end 
    gRichman.actionnum=obj:getInt("actionnum")
    Net.updateReward(obj:getObj("reward")) 
    gRichman.buynum=gRichman.buynum+  Net.sendRichmanBuyActionParam
    
    gDispatchEvt(EVENT_ID_RICHMAN_BUYACTION)
    
end
 
 
 
function Net.sendRichmanRewardInfo()

    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "richman.scorerewardinfo")
end

function Net.rec_richman_scorerewardinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end  
    
    gRichman.recRewards={} 
    local  list=obj:getBoolArray("rec")
    if(list)then 
        for i=0, list:size()-1 do
            table.insert(gRichman.recRewards,list[i])
        end
    end      
    gDispatchEvt(EVENT_ID_RICHMAN_REWARDINFO)
    Panel.popUp(PANEL_RICHMAN_REWARD)
end
 
 
function Net.sendRichmanGetReward(idx,key)

    local media=MediaObj:create() 
    media:setInt("idx",idx)
    Net.sendRichmanGetRewardParam={}
    Net.sendRichmanGetRewardParam.idx=idx
    Net.sendRichmanGetRewardParam.key=key
    Net.sendExtensionMessage(media, "richman.recscorereward") 
end


function Net.rec_richman_recscorereward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end  


    local idx=Net.sendRichmanGetRewardParam.idx
    gRichman.recRewards[idx+1]=true  
    Net.updateReward(obj:getObj("reward"),2) 
    gDispatchEvt(EVENT_ID_RICHMAN_GETREWARD, Net.sendRichmanGetRewardParam.key)
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)  
end


function Net.sendRichmanRewardOneKey() 
    local media=MediaObj:create() 
    Net.sendExtensionMessage(media, "richman.recallscorereward")
end


function Net.rec_richman_recallscorereward(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),2) 

    for key, var in pairs( gRichman.recRewards) do 
        gRichman.recRewards[key]=true 
    end
    
    gDispatchEvt(EVENT_ID_RICHMAN_GETREWARD_ALL ) 
end

 
function Net.sendRichmanRank()

    local media=MediaObj:create() 
    if(gRichman.ver==nil)then
        gRichman.ver=0
    end 
    media:setInt("ver",gRichman.ver)
    Net.sendExtensionMessage(media, "richman.rank")
end

function Net.rec_richman_rank(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return 
    end  
    
        
    gRichman.ranks={}
    gRichman.ver=obj:getInt("var")
    gRichman.lastrank=obj:getInt("rank") 
    gRichman.lastscore=obj:getInt("score")
    local array = tolua.cast(obj:getArray("list"),"MediaArray")
    if(array)then

        for i = 0,array:count()-1 do
            local item = tolua.cast(array:getObj(i),"MediaObj")
            local tmp = {}
            tmp.id = item:getLong("id") 
            tmp.rank =i+1
            tmp.username = item:getString("username") 
            tmp.level = item:getShort("level")
            tmp.vip = item:getByte("vip")
            tmp.icon = item:getInt("icon")
            tmp.fname = item:getString("fname") 
            tmp.score = item:getInt("score") 
            table.insert(gRichman.ranks,tmp)  
        end

    
    end
  --  gDispatchEvt(EVENT_ID_RICHMAN_RANK)
    Panel.popUp(PANEL_RICHMAN_RANK)
end
 
 
