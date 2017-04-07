FAMILY_STAGE_REFRESH_PROG_LIST = 1
FAMILY_STAGE_REFRESH_SET_BUFF = 2
FAMILY_STAGE_REFRESH_BUFF_UP = 3
FAMILY_STAGE_REFRESH_FIGHT_LIST = 4


CMD_FAMILY_STAGE_INFO = "family.stageinfo"
function Net.sendFamilyStageInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_INFO)
end

function Net.rec_family_stageinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.setFamilyStageFightNum(obj:getInt("stagenum"))
    Data.setFamilyStageBuffUpNum(obj:getInt("buffnum"))
    Data.setUsedTimes(VIP_FAMILY_BUFF_UP, obj:getInt("buffnum"))
    if obj:containsKey("buff1") then
        Data.setFamilyStageBuffCountry(obj:getByte("buff1"),obj:getByte("buff2"))
    end

    -- buff阵营奖励
    local buffRew = {}
    if obj:containsKey("buffrew")then
        local list = obj:getArray("buffrew")
        for i = 0, list:count() - 1 do
            local bufRewObj = list:getObj(i)
            if nil ~= bufRewObj then
                bufRewObj = tolua.cast(bufRewObj,"MediaObj")
                table.insert(buffRew, {country=bufRewObj:getInt("c"), id=bufRewObj:getInt("id"), num=bufRewObj:getInt("num")})
            end
        end
    end
    Data.setFamilyStageBuffInfo(obj:getInt("bufflv"), obj:getInt("buffexp"),buffRew)

    -- 阵营加成基础属性(气血、物攻、物防、魔防)
    Data.clearFamilyStageBasicAttr()
    if obj:containsKey("baseattr") then
        local attrArrays=obj:getIntArray("baseattr") 
        if(attrArrays)then
            for i=0, attrArrays:size()-1 do 
                Data.addFamilyStageBasicAttrValue(attrArrays[i])
            end
        end
    end
    
    -- 击杀记录
    Data.clearFamilyStageKills()
    if obj:containsKey("kills")then
        local list = obj:getArray("kills")
        for i = 0, list:count() - 1 do
            local killObj = list:getObj(i)
            if nil ~= killObj then
                killObj = tolua.cast(killObj,"MediaObj")
                local rewItems = {}
                if killObj:containsKey("rew") then
                    local rewList = killObj:getArray("rew")
                    if nil ~= rewList then
                        for i = 0 , rewList:count() - 1 do
                            local rewObj = rewList:getObj(i)
                            if nil ~= rewObj then
                                rewObj = tolua.cast(rewObj,"MediaObj")
                                table.insert(rewItems, {id=rewObj:getInt("id"),num=rewObj:getInt("num")}) 
                            end   
                        end
                    end
                end
                Data.setFamilyStageKills(killObj:getInt("id"), killObj:getString("nm"), rewItems)
            end
        end
    end

    Data.setFamilyStageAverPower(obj:getInt("power"))
    Data.setFamilyStageActiveNum(obj:getInt("active"))
    Data.setFamilyStagePro(obj:getInt("prog"))
    Data.setFamilyStageFightTime(obj:getInt("time"))


    Data.setFamilyStageOppId(obj:getLong("oppid"))
    if obj:containsKey("oppname") then
        Data.setFamilyStageOppInfo(obj:getString("oppname"), obj:getInt("oppicon"), obj:getInt("oppprog"), obj:getInt("opptime"))
    end


    -- 副本进度列表
    Data.clearFamilyStageProList(true)
    if obj:containsKey("list")then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local stageObj = list:getObj(i)
            if nil ~= stageObj then
                stageObj = tolua.cast(stageObj,"MediaObj")
                Data.setFamilyStageProList(stageObj:getInt("stageid"), stageObj:getInt("prog"), true)
            end
        end
    end

    Data.clearFamilyStageProList(false)
    if obj:containsKey("list2")then
        local list = obj:getArray("list2")
        for i = 0, list:count() - 1 do
            local stageObj = list:getObj(i)
            if nil ~= stageObj then
                stageObj = tolua.cast(stageObj,"MediaObj")
                Data.setFamilyStageProList(stageObj:getInt("stageid"), stageObj:getInt("prog"), false)
            end
        end
    end

    if Panel.isOpenPanel(PANEL_FAMILY_STAGE_MAIN) then
        gDispatchEvt(EVENT_ID_FAMILY_STAGE_MAIN_REFRESH)
    else
        Panel.popUpVisible(PANEL_FAMILY_STAGE_MAIN)
    end 
end

CMD_FAMILY_STAGE_PROG = "family.stageprog"
function Net.sendFamilyStageProg(fid)
    local obj = MediaObj:create()
    obj:setLong("fid",fid)
    Net.familyStageQueryFid = fid
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_PROG)
end

function Net.rec_family_stageprog(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    local isSelf = (Net.familyStageQueryFid == gFamilyInfo.familyId)

    Data.clearFamilyStageProList(isSelf)
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local progObj = list:getObj(i)
            if nil ~= progObj then
                progObj = tolua.cast(progObj,"MediaObj")
                local stageId = progObj:getInt("stageid")
                local prog = progObj:getInt("prog")
                Data.setFamilyStageProList(stageId, prog, isSelf)
            end
        end
    end

    gDispatchEvt(EVENT_ID_FAMILY_STAGE_REFRESH_INFO, FAMILY_STAGE_REFRESH_PROG_LIST)
end


CMD_FAMILY_STAGE_SET_BUFF = "family.stagesetbuff"
function Net.sendFamilyStageSetBuff(buff1, buff2)
    local obj = MediaObj:create()
    obj:setByte("buff1", buff1)
    obj:setByte("buff2", buff2)
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_SET_BUFF)
end

function Net.rec_family_stagesetbuff(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    gShowNotice(gGetWords("noticeWords.plist", "family_stage_set_buff_suc"))
    gDispatchEvt(EVENT_ID_FAMILY_STAGE_REFRESH_INFO,FAMILY_STAGE_REFRESH_SET_BUFF)
end

CMD_FAMILY_STAGE_BUFF_UP= "family.stagebuffup"
function Net.sendFamilyStageBuffUp()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_BUFF_UP)
end

function Net.rec_family_stagebuffup(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.setFamilyStageBuffUpNum(obj:getInt("buffnum"))
    Data.setFamilyStageBuffInfo(obj:getInt("bufflv"), obj:getInt("buffexp"))
    Data.setUsedTimes(VIP_FAMILY_BUFF_UP, Data.getUsedTimes(VIP_FAMILY_BUFF_UP) + 1)
    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_FAMILY_STAGE_REFRESH_INFO, FAMILY_STAGE_REFRESH_BUFF_UP)
end

CMD_FAMILY_STAGE_USER_FIGHT= "family.stageuserfight"
function Net.sendFamilyStageUseright()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_USER_FIGHT)
end

function Net.rec_family_stageuserfight(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local memberObj = list:getObj(i)
            if nil ~= memberObj then
                memberObj = tolua.cast(memberObj,"MediaObj")
                local uid = memberObj:getLong("uid")
                local power = memberObj:getInt("power")
                local num = memberObj:getInt("num")
                Data.updateFamilyStageUserFightInfo(uid, power, num)
            end
        end
    end

    gDispatchEvt(EVENT_ID_FAMILY_STAGE_REFRESH_INFO,FAMILY_STAGE_REFRESH_FIGHT_LIST)
end

--军团副本查看怪物信息
CMD_FAMILY_STAGE_MONSTER= "family.stagemonster"
function Net.sendFamilyStageMonster(fsid)--fsid军团副本id
    local obj = MediaObj:create()
    obj:setInt("fsid", fsid)
    Net.sendFamilyStagId = fsid
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_MONSTER)
end

function Net.rec_family_stagemonster(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.clearFamilyStageMonsterList()
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local monsterObj = list:getObj(i)
            if nil ~= monsterObj then
                monsterObj = tolua.cast(monsterObj,"MediaObj")
                local monsterid = monsterObj:getInt("id")
                local hp = monsterObj:getInt("hp")
                local thp = monsterObj:getInt("thp")
                Data.addFamilyStageMonsters(monsterid, hp, thp)
            end
        end
    end
    Panel.popUpVisible(PANEL_FAMILY_STAGE_FORMATION, Net.sendFamilyStagId)
end

CMD_FAMILY_STAGE_FIGHT= "family.stagefight"
function Net.sendFamilyStageFight(fsid, buffid)--fsid:军团副本id,buffid:加成buffID
    local obj = MediaObj:create()
    obj:setInt("fsid", fsid)
    obj:setInt("buffid", buffid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_FIGHT)
end

function Net.rec_family_stagefight(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        if ret == 26 then
            Net.sendFamilyStageInfo()
        end
        return
    end

    Data.setFamilyStageFightNum(obj:getInt("stagenum"))
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_FAMILY_STAGE)
    Battle.win = 1
    Battle.reward.shows = Net.updateReward(obj:getObj("reward"),0)
    --TODO,伤害百分比这一块还需要确认一下以及怪物列表的刷新这一块还需要确认一下
    if obj:containsKey("list") then

    end
end

--军团副本伤害排名
CMD_FAMILY_STAGE_HARM_RANK= "family.stageharmrank"
function Net.sendFamilyStageHarmRank(fsid)
    local obj = MediaObj:create()
    obj:setInt("fsid", fsid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_HARM_RANK)
end


function Net.rec_family_stageharmrank(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.clearMyFamilyStageHarmRank()

    if obj:containsKey("rank") then
        Data.setMyFamilyStageHarmRank(obj:getInt("rank"))
    end

    if obj:containsKey("harm") then
        Data.setMyFamilyStageHarmValue(obj:getInt("harm"))
    end

    Data.clearFamilyStageHarmRanks()
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local harmObj = list:getObj(i)
            if nil ~= harmObj then
                harmObj = tolua.cast(harmObj,"MediaObj")
                Data.addFamilyStageHarmRank(i,harmObj:getLong("userid"), harmObj:getString("username"), harmObj:getShort("level"), harmObj:getByte("vip"),
                                            harmObj:getInt("icon"), harmObj:getByte("post"), harmObj:getInt("harm"))
            end
        end
    end

    Panel.popUpVisible(PANEL_FAMILY_STAGE_HARM_RANK)
end

-- 军团副本挑战详情
CMD_FAMILY_STAGE_FIGHT_LIST= "family.stagefightlist"
function Net.sendFamilyStageFightList(fsid)
    local obj = MediaObj:create()
    obj:setInt("fsid", fsid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_FIGHT_LIST)
end

function Net.rec_family_stagefightlist(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.clearFamilyStageHarmDetailList()
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local fightInfoObj = list:getObj(i)
            if nil ~= fightInfoObj then
                fightInfoObj = tolua.cast(fightInfoObj,"MediaObj")
                Data.addFamilyStageHarmDetailList(fightInfoObj:getString("uname"), fightInfoObj:getInt("harm"))
            end
        end
    end
    Panel.popUp(TIP_FAMILY_STAGE_CHA_REC)
end

-- 军团副本上届排名
CMD_FAMILY_STAGE_LAST_RANK= "family.stagelastrank"
function Net.sendFamilyStageLastRank()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_STAGE_LAST_RANK)
end

function Net.rec_family_stagelastrank(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.setFamilyStageOtherLastInfo(obj:getString("oppname"), obj:getInt("oppicon"))--obj:getInt("oppprog"))
    Data.setFamilyStageLastWinFlag(obj:getBool("win"))

    Data.clearFamilyStageSelfLastInfos()
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0, list:count() - 1 do
            local lastInfoObj = list:getObj(i)
            if nil ~= lastInfoObj then
                lastInfoObj = tolua.cast(lastInfoObj,"MediaObj")
                Data.addFamilyStageSelfLastInfo(lastInfoObj:getString("username"), lastInfoObj:getShort("level"), lastInfoObj:getByte("vip"), 
                                            lastInfoObj:getInt("icon"), lastInfoObj:getByte("post"), lastInfoObj:getInt("num"))
            end
        end
    end

    Data.clearFamilyStageOtherLastInfos()
    if obj:containsKey("list2") then
        local list = obj:getArray("list2")
        for i = 0, list:count() - 1 do
            local lastInfoObj = list:getObj(i)
            if nil ~= lastInfoObj then
                lastInfoObj = tolua.cast(lastInfoObj,"MediaObj")
                Data.addFamilyStageOtherLastInfo(lastInfoObj:getString("username"), lastInfoObj:getShort("level"), lastInfoObj:getByte("vip"), 
                                            lastInfoObj:getInt("icon"), lastInfoObj:getByte("post"), lastInfoObj:getInt("num"))
            end
        end
    end

    Panel.popUpVisible(PANEL_FAMILY_STAGE_LAST_RANK)
end