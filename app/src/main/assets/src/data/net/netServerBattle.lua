
function Net.parseLastServerBattleInfo(obj)
    local icon = obj:getInt("icon", 0)
    local name = obj:getString("name", "")
    local sName = obj:getString("sname","")
    gServerBattle.setLastBattleInfo(icon, name, sName)
end

CMD_WORLD_WAR_GETINFO = "worwar.getinfo"
function Net.sendWorldWarGetInfo(callback)
    local obj = MediaObj:create()
    Net.sendWorldWarGetInfoFunc=callback
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_GETINFO)
end

function Net.rec_worwar_getinfo(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    local rank = 0
    if obj:containsKey("rank") then
        rank = obj:getInt("rank")
    end
    -- print("dan is:",obj:getInt("dan"),"honor is:",obj:getInt("honor"))
    gServerBattle.initBasicInfo(obj:getInt("honor"), obj:getInt("dan"), rank, obj:getInt("season"))
    gServerBattle.findNum = obj:getInt("findnum")
    gServerBattle.winning = obj:getInt("winning")
    gServerBattle.changeNum = obj:getInt("change") --已换一批次数
    gServerBattle.buyNum = obj:getInt("buy") --已购买次数
    Data.setUsedTimes(VIP_SERVERBATTLE_FIND,gServerBattle.buyNum)
    gServerBattle.setTotalLeftFindNum()
    gServerBattle.clearTop5KingRanks()
    local list = obj:getArray("list")
    if nil ~= list then
        list = tolua.cast(list, "MediaArray")
        for i = 0, list:count()-1 do
            local item = tolua.cast(list:getObj(i), "MediaObj")
            if nil ~= item then
                local kingRankInfo = {}
                kingRankInfo.uid = item:getLong("uid")
                kingRankInfo.uname = item:getString("uname")
                kingRankInfo.sname = item:getString("sname")
                if item:containsKey("fname") then
                    kingRankInfo.fname = item:getString("fname")
                end
                kingRankInfo.icon  = item:getInt("icon")
                kingRankInfo.show = Net.parserShowInfo(item:getObj("idetail"))
                kingRankInfo.level = item:getInt("level")
                kingRankInfo.vip = item:getByte("vip")
                kingRankInfo.price = item:getInt("price")
                gServerBattle.addTop5KingRanks(kingRankInfo)
            end
        end
    end

    if nil ~= Net.sendWorldWarGetInfoFunc then
        Net.sendWorldWarGetInfoFunc()
        Net.sendWorldWarGetInfoFunc = nil
    end

    -- if Panel.isOpenPanel(PANEL_SERVER_BATTLE_MAIN) then
    if Panel.isTopPanel(PANEL_SERVER_BATTLE_MAIN) then
        gDispatchEvt(EVENT_ID_SERVERBATTLE_MAIN_UPDATE)
    else
        Panel.popUp(PANEL_SERVER_BATTLE_MAIN)
    end
end

CMD_WORLD_WAR_FIND = "worwar.find"
function Net.sendWorldWarFind(change)
    local obj = MediaObj:create()
    obj:setBool("change",change)
    Net.WorldWarFindChange = change
    -- print("Net.WorldWarFindChange is",Net.WorldWarFindChange)
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_FIND)
end

function Net.rec_worwar_find(evt)
    local obj = evt.params:getObj("params")
    --扣除
    Net.updateReward(obj:getObj("reward"),0)

    if obj:containsKey("findnum") then
        gServerBattle.findNum = obj:getInt("findnum")
        gServerBattle.setTotalLeftFindNum()
        local param = {}
        -- table.insert(param, {id=tostring(self.curActData)})
        param["findnum"] = tostring(gServerBattle.findNum)
        gLogEvent("worwar.find",param)
    end
    gServerBattle.changeNum = obj:getInt("change")
    --清空对手信息
    gServerBattle.clearRivalInfo()
    local ret = obj:getByte("ret")
    if ret == 0 then
        local list = obj:getArray("list")
        if nil ~= list then
            list = tolua.cast(list, "MediaArray")
            for i = 0, list:count()-1 do
                local item = tolua.cast(list:getObj(i), "MediaObj")
                if nil ~= item then
                    local rivalInfo = {}
                    rivalInfo.uid = item:getLong("id")
                    rivalInfo.icon = item:getInt("icon")
                    rivalInfo.power = item:getInt("price")
                    rivalInfo.uname = item:getString("name")
                    rivalInfo.sectionLv = item:getInt("dan")
                    rivalInfo.lv = item:getInt("lv")
                    rivalInfo.rank = item:getInt("rank")
                    rivalInfo.sname = item:getString("sname")
                    rivalInfo.teamInfo = {}
                    local cardidArr =item:getArray("team")
                    if nil ~= cardidArr then
                        --TODO,如果前排没有英雄
                        for i=0, cardidArr:count()-1 do
                            local teamItem = tolua.cast(cardidArr:getObj(i), "MediaObj")
                            local cardInfo = {}
                            if teamItem:containsKey("cid") then
                                cardInfo.cardid = teamItem:getInt("cid")
                                cardInfo.weaponLv  = teamItem:getInt("wlv")
                                cardInfo.awakeLv  = teamItem:getInt("wkn")
                            end
                            table.insert(rivalInfo.teamInfo,cardInfo)
                        end
                    end
                    table.insert(gServerBattle.rivalInfos,rivalInfo)
                end
            end
        end      
    end
    gDispatchEvt(EVENT_ID_SERVERBATTLE_FIND_RIVAL,ret)
end

--TODO
CMD_WORLD_WAR_FIGHT = "worwar.fight"
function Net.sendWorldWarFight(id)
    local obj = MediaObj:create()
    obj:setLong("id",id)
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_FIGHT)
end

--TODO
function Net.rec_worwar_fight(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        gDispatchEvt(EVENT_ID_SERVERBATTLE_SEC_MATCH_END, ret)
        return
    end
    local rank = 0
    if obj:containsKey("rank") then
        rank = obj:getInt("rank")
    end

    local addDan = nil
    if obj:containsKey("addDan") then
        addDan = obj:getInt("adddan")
    end

    gServerBattle.setBasicInfo(obj:getInt("honor"),obj:getInt("dan"),rank, addDan)
    gServerBattle.winning = obj:getInt("winning")
    gServerBattle.findNum = obj:getInt("findnum")
    gServerBattle.setTotalLeftFindNum()
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    Battle.brief = {} 
    Battle.brief.n1 = data:getString("n1")
    Battle.brief.n2 = data:getString("n2")
    gParserGameVideo(byteArr,BATTLE_TYPE_SERVER_BATTLE)
    gServerBattle.hasEnterFight = true
    gServerBattle.clearRivalInfo()
end

CMD_WORLD_WAR_QUIT = "worwar.quit"
function Net.sendWorldWarQuit()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_QUIT)
end

function Net.rec_worwar_quit(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    gServerBattle.setBasicInfo(obj:getInt("honor"),obj:getInt("dan"))
    gServerBattle.winning = 0
    gServerBattle.findNum = obj:getInt("findnum")
    gServerBattle.setTotalLeftFindNum()
    gServerBattle.clearRivalInfo()
    gDispatchEvt(EVENT_ID_SERVERBATTLE_QUIT)
end

CMD_WORLD_WAR_KING_RANK = "worwar.kingrank"
function Net.sendWorldWarKingRank()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_KING_RANK)
end

function Net.rec_worwar_kingrank(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    if obj:containsKey("rank") then
        gServerBattle.kingRank = obj:getInt("rank")
    end

    gServerBattle.clearKingRanks()
    local list = obj:getArray("list")
    if nil ~= list then
        list = tolua.cast(list, "MediaArray")
        local idx = 0
        for i = 0, list:count()-1 do
            local item = tolua.cast(list:getObj(i), "MediaObj")
            if nil ~= item then
                local kingRankInfo = {}
                kingRankInfo.uid = item:getLong("uid")
                kingRankInfo.uname = item:getString("uname")
                kingRankInfo.sname = item:getString("sname")
                if item:containsKey("fname") then
                    kingRankInfo.fname = item:getString("fname")
                end
                kingRankInfo.icon  = item:getInt("icon")
                kingRankInfo.level = item:getInt("level")
                kingRankInfo.vip = item:getByte("vip")
                kingRankInfo.power = item:getInt("price")
                idx = idx + 1
                kingRankInfo.rank = idx
                gServerBattle.addKingRanks(kingRankInfo)
            end
        end
    end
    Panel.popUpVisible(PANEL_SERVER_BATTLE_RANK,nil,nil,true)
end

CMD_WORLD_WAR_RECORD = "worwar.record"
function Net.sendWorldWarRecord()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_RECORD)
end

function Net.parseServerBattleRecord(data)
    local  data=tolua.cast(data,"MediaObj")
    local item={}
    item.id=data:getLong("id")
    item.name=data:getString("name")
    item.level=data:getInt("lv")
    item.win=data:getByte("win")
    item.recid=data:getLong("recid")
    item.time=data:getInt("time")
    item.cid=data:getInt("cid")
    item.pw=data:getInt("pw")
    item.vid=data:getLong("vid")
    item.atk=data:getBool("atk")
    item.sectionLv=data:getInt("dan")
    item.rank = 0
    if data:containsKey("rank") then
        item.rank = data:getInt("rank")
    end
    -- item.state=data:getByte("state")
    -- item.atk=data:getBool("atk")
    return item
end

function Net.rec_worwar_record(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    local ret={}
    ret.records={}
    local recordList = obj:getArray("info")
    if (nil ~= recordList)then
        recordList = tolua.cast(recordList,"MediaArray")
        for i=1, recordList:count() do
            table.insert(ret.records,i,Net.parseServerBattleRecord(recordList:getObj(i-1)))
        end
    end
    Panel.popUpVisible(PANEL_ARENA_RECORD,SERVERBATTLE_RECORD_TYPE,ret)
end


CMD_WORLD_WAR_VEDIO = "worwar.vedio"
function Net.sendWorldWarVedio(id,recordType)
    local obj = MediaObj:create()
    obj:setLong("vid",id)
    obj:setByte("type",recordType)
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_VEDIO)
end

function Net.rec_worwar_vedio(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    local data = obj:getObj("bat")
    local byteArr = data:getByteArray("info")
    Battle.brief = {} 
    Battle.brief.n1 = data:getString("n1")
    Battle.brief.n2 = data:getString("n2")
    gParserGameVideo(byteArr,BATTLE_TYPE_SERVER_BATTLE_LOG)
    gServerBattle.hasEnterFight = true
end

CMD_WORLD_WAR_MATCH_RECORD = "worwar.matchrecord"
function Net.sendWorldWarMatchRecord(matchType,callback)
    local obj = MediaObj:create()
    obj:setByte("type",matchType)
    gServerBattle.sendMatchType = matchType
    Net.sendWorldWarRecordFunc = callback
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_MATCH_RECORD)
end

function Net.rec_worwar_matchrecord(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    local data = {}
    data.rank = nil
    if obj:containsKey("rank") then
        data.rank  = obj:getInt("rank")
    end
    data.list = {}
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0,list:count()-1 do
            local msgObj = list:getObj(i)
            msgObj = tolua.cast(msgObj,"MediaObj")
            local id = msgObj:getLong("id")
            local uid1 = msgObj:getLong("uid1")
            local icon1 = msgObj:getInt("icon1")
            local name1 = msgObj:getString("name1")
            local sname1 = msgObj:getString("sname1")
            local uid2 = msgObj:getLong("uid2")
            local icon2 = msgObj:getInt("icon2")
            local name2 = msgObj:getString("name2")
            local sname2 = msgObj:getString("sname2")
            local round = msgObj:getByte("round")
            local groupId = msgObj:getByte("groupid")
            local win = msgObj:getByte("win",-1)
            local vid =  msgObj:getLong("vid",0)
            local resultTable = {}
            if msgObj:containsKey("result") then
                local resultList = msgObj:getArray("result")
                for j = 0, resultList:count() - 1 do
                    local resultObj = tolua.cast(resultList:getObj(j),"MediaObj")
                    table.insert(resultTable, {win=resultObj:getInt("win"), vid=resultObj:getLong("vid")})
                end
            end

            table.insert(data.list,
                    {id=id,uid1=uid1,icon1=icon1,name1=name1,sname1=sname1,uid2=uid2,icon2=icon2,name2=name2,sname2=sname2,
                        round=round,groupId=groupId,win=win,vid=vid,result=resultTable}
            )
        end
    end

    if nil ~= Net.sendWorldWarRecordFunc then
        Net.sendWorldWarRecordFunc()
        Net.sendWorldWarRecordFunc = nil
    end

    if Panel.isOpenPanel(PANEL_SERVER_BATTLE_MATCH) then
        gDispatchEvt(EVENT_ID_SERVERBATTLE_UPDATE_MATCH,data)
    else
        Panel.popUpUnVisible(PANEL_SERVER_BATTLE_MATCH,data,gServerBattle.sendMatchType,true)
    end
end

CMD_WORLD_WAR_MATCH_USERINFO = "worwar.matchuserinfo"
function Net.sendWorldWarMatchUserInfo(matchType,id,uid)
    local obj = MediaObj:create()
    obj:setByte("type", matchType)
    obj:setLong("id",id)
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_MATCH_USERINFO)
end

function Net.rec_worwar_matchuserinfo(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    local ret = {}
    ret.team = Net.parseTeamObj(obj:getObj("team"))
    ret.name = obj:getString("name")
    ret.sname = obj:getString("sname")
    ret.fname = obj:getString("fname")
    ret.price = obj:getInt("price")
    ret.lv = obj:getInt("lv")
    ret.icon = obj:getInt("icon")
    ret.show = Net.parserShowInfo(obj:getObj("idetail"))
    Panel.popUpVisible(PANEL_FORMATION,ret,1)
end

CMD_WORLD_WAR_USERINFO = "worwar.userinfo"
function Net.sendWorldWarUserInfo(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_USERINFO)
end

function Net.rec_worwar_userinfo(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    local ret = {}
    ret.team = Net.parseTeamObj(obj:getObj("team"))
    ret.name = obj:getString("name")
    ret.sname = obj:getString("sname")
    ret.fname = obj:getString("fname")
    ret.price = obj:getInt("price")
    ret.lv = obj:getInt("lv")
    ret.icon = obj:getInt("icon")
    ret.show = Net.parserShowInfo(obj:getObj("idetail"))
    Panel.popUpVisible(PANEL_FORMATION,ret,1)
end

CMD_WORLD_WAR_FIND_BUY = "worwar.findbuy"
function Net.sendWorldWarFindBuy(num)
    local obj = MediaObj:create()
    obj:setInt("num",num);
    Net.sendExtensionMessage(obj, CMD_WORLD_WAR_FIND_BUY)
end

function Net.rec_worwar_findbuy(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end

    Net.updateReward(obj:getObj("reward"))
    local oldBuyNum = gServerBattle.buyNum
    gServerBattle.buyNum = obj:getInt("buy") --已购买次数
    Data.setUsedTimes(VIP_SERVERBATTLE_FIND,gServerBattle.buyNum)
    gServerBattle.setTotalLeftFindNum()
    gDispatchEvt(EVENT_ID_SERVERBATTLE_FIND_BUY)
end

