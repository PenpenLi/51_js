
--[[

CMD_FAMILY_MATCH_INFO = "family.matchinfo" --家族战信息
CMD_FAMILY_MATCH_SIGN = "family.matchsign" --家族战报名
CMD_FAMILY_MATCH_RECORD = "family.matchrecord" --查看正式比赛记录
CMD_FAMILY_TEAM_INFO    = "family.teaminfo" --查看家族布阵信息
CMD_FAMILY_TEAM_SAVE = "family.teamsave" --保存家族布阵信息
CMD_FAMILY_MATCH_DETAIL = "family.matchdetail"
CMD_FAMILY_VEDIO = "family.vedio"
CMD_FAMILY_LAST_WEEK = "family.lastweek"
CMD_FAMILY_WEEK_EXP = "family.weekexp"
CMD_FAMILY_READY = "family.ready" --查看预选赛信息
CMD_FAMILY_READY_DETAIL = "family.readydetail" --查看预选赛记录明细

]]
-------#####家族 家族战 start

function Net.parseFamilyWinerObj(msgObj)
    msgObj = tolua.cast(msgObj,"MediaObj");

    local uid = msgObj:getLong("uid");
    local uname = msgObj:getString("uname");
    local icon = msgObj:getInt("icon");
    local uType = msgObj:getByte("type");
    local vip = msgObj:getByte("vip");
    local show = Net.parserShowInfo(msgObj:getObj("idetail"));
    return  {show=show,uid=uid, name=uname, icon=icon, uType=uType, vip=vip,weaponLv=weaponLv}
end

function Net.sendFamilyMatchInfo()
    local obj = MediaObj:create();
    Net.sendExtensionMessage(obj,"family.matchinfo");
    gLogEvent("family.matchinfo")
end



function Net.rec_family_matchinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    gFamilyMatchInfo = {};
    gFamilyMatchInfo.season = obj:getInt("season", -1);
    gFamilyMatchInfo.sign = obj:getBool("sign");
    gFamilyMatchInfo.matchtime = obj:getBool("matchtime");
    gFamilyMatchInfo.matchday = obj:getBool("matchday");
    gFamilyMatchInfo.rank = obj:getByte("rank");
    gFamilyMatchInfo.winName = obj:getString("winname");
    gFamilyMatchInfo.winLevel = obj:getShort("winlevel");
    gFamilyMatchInfo.winPower = obj:getInt("winpower");
    gFamilyMatchInfo.winIcon = obj:getInt("winicon");
    gFamilyMatchInfo.winner = {};
    if obj:containsKey("winner") then
        local winner = obj:getArray("winner");
        for i=0,winner:count()-1 do
            table.insert(gFamilyMatchInfo.winner ,Net.parseFamilyWinerObj(winner:getObj(i)))
        end
    else

    end
    --gFamilyMatchInfo.sign=false
    -- gFamilyMatchInfo.matchday=true
    if(gFamilyMatchInfo.matchday)then
        Net.sendFamilyMatchRecord()
        --gFamilyInfo.winId=nil

    else

        if(Panel.isTopPanel(PANEL_FAMILY_WAR_SIGN))then
            gDispatchEvt(EVENT_ID_FAMILY_WAR_SIGN)
        else
            Panel.popUp(PANEL_FAMILY_WAR_SIGN)
        end
    end



end

function Net.sendFamilyMatchSign()
    local obj = MediaObj:create();
    Net.sendExtensionMessage(obj,"family.matchsign");
    gLogEvent("family.matchsign")
end

function Net.rec_family_matchsign(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if(obj:getByte("ret")~=0)then
        return
    end
    gFamilyMatchInfo.sign=true
    gDispatchEvt(EVENT_ID_FAMILY_WAR_SIGN)
    gShowNotice(gGetWords("familyWords.plist","family_war_sign_success"))

end

function Net.sendFamilyMatchRecord()
    local obj = MediaObj:create();
    Net.sendExtensionMessage(obj,"family.matchrecord");
end


function Net.rec_family_matchrecord(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret ~= 0 then
        return
    end
    local ret = {};
    ret.list={}
    ret.notice=obj:getString("notice");
    if obj:containsKey("list") then
        local list = obj:getArray("list");
        for i=0,list:count()-1 do
            local msgObj = list:getObj(i);
            msgObj = tolua.cast(msgObj,"MediaObj");
            local id = msgObj:getLong("id");
            ret.season=msgObj:getInt("season"); 
            local fid1 = msgObj:getLong("fid1");
            local name1 = msgObj:getString("name1");
            local fid2= msgObj:getLong("fid2");
            local name2 = msgObj:getString("name2");
            local round = msgObj:getByte("round");
            local groupId = msgObj:getByte("groupid");
            local win1 = msgObj:getByte("win1", -1);
            local detail1 = msgObj:getBool("detail1");
            local icon1 = msgObj:getInt("icon1");
            local icon2 = msgObj:getInt("icon2" );
            local lv1 = msgObj:getShort("lv1");
            local lv2 = msgObj:getShort("lv2" );
            table.insert(ret.list,
                {lv1=lv1,lv2=lv2,icon1=icon1,icon2=icon2,id=id,fid1=fid1,name1=name1,fid2=fid2,name2=name2,
                    round=round,groupId=groupId,win1=win1,win2=win2,win3=win3,
                    detail1=detail1,detail2=detail2,detail3=detail3}
            );
        end
    end

    Panel.popUp(PANEL_FAMILY_WAR_MATCH,ret)
    -- Panel.popUp(PANEL_SERVER_BATTLE_MATCH,ret,nil,true)
end


function Net.sendFamilyTeamInfo(id)
    local obj = MediaObj:create();
    obj:setLong("id",id)
    Net.sendExtensionMessage(obj,"family.teaminfo");
end

function Net.rec_family_teaminfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret ~= 0 then
        return
    end

    local free={}
    local match={}
    local familyid = obj:getLong("id");

    if obj:containsKey("member") then
        local all_members = obj:getArray("member");
        for i=0,all_members:count()-1 do
            local msgObj = all_members:getObj(i);
            msgObj = tolua.cast(msgObj,"MediaObj");
            local uid = msgObj:getLong("uid");
            local sName = msgObj:getString("name");
            local iPower = msgObj:getInt("power");
            local iCoat = msgObj:getInt("icon");
            table.insert(free, {uid=uid, sName=sName, iPower=iPower, iCoat=iCoat});
        end
    end

    local team1 = obj:getArray("team1");
    for i=0,team1:count()-1 do
        local msgObj = team1:getObj(i);
        msgObj = tolua.cast(msgObj,"MediaObj");
        local uid = msgObj:getLong("uid");
        local idx = nil;
        local data = nil
        for k,v in pairs(free) do
            if v.uid == uid then
                idx = k;
                data = v;
                break
            end
        end
        if (idx ~= nil) then
            table.insert(match, data);
            table.remove(free, idx);
        end
    end

    if(Panel.isTopPanel(PANEL_FAMILY_WAR_EDIT))then

        gDispatchEvt(EVENT_ID_FAMILY_WAR_EDIT_LIST,{free=free,match=match,familyid=familyid})
    else

        Panel.popUp(PANEL_FAMILY_WAR_EDIT,{free=free,match=match,familyid=familyid})
    end


end

function Net.sendFamilyTeamSave(ids)
    local obj = MediaObj:create();

    local vectorIds = vector_long2X_:new_local();
    for k, v in ipairs(ids) do
        vectorIds:push_back(v)
    end
    obj:setLongArray("ids1", vectorIds);
    Net.sendExtensionMessage(obj,"family.teamsave");
end

function Net.rev_family_teamsave(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret ~= 0 then
        return
    end
end

function Net.sendFamilyMatchDetail(id)
    local obj = MediaObj:create();
    obj:setLong("id", id);
    obj:setByte("pos",1)
    Net.sendExtensionMessage(obj, "family.matchdetail");
end

function Net.rec_family_matchdetail(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret ~= 0 then
        return
    end
    local ret={}
    if obj:containsKey("list") then
        local list = obj:getArray("list");
        for i=0,list:count()-1 do
            local msgObj = list:getObj(i);
            msgObj = tolua.cast(msgObj,"MediaObj");
            local fname1 = msgObj:getString("fname1");
            local fname2 = msgObj:getString("fname2");
            local name1 = msgObj:getString("name1");
            local name2 = msgObj:getString("name2");
            local icon1 = msgObj:getInt("icon1");
            local icon2 = msgObj:getInt("icon2");
            local idx = msgObj:getInt("idx");
            local win = msgObj:getBool("win");
            local vid = msgObj:getLong("vid");
            local pos = msgObj:getByte("pos");

            local lv1 = msgObj:getShort("lv1");
            local lv2 = msgObj:getShort("lv2");
            local power1 = msgObj:getInt("pw1");
            local power2 = msgObj:getInt("pw2");
            
            local weaponLv1 = msgObj:getByte("wlv1");
            local weaponLv2 = msgObj:getByte("wlv2");
            local awakeLv1 = msgObj:getByte("wkn1");
            local awakeLv2 = msgObj:getByte("wkn2");
            

            local hpall1 = msgObj:getInt("hpall1");
            local hpall2 = msgObj:getInt("hpall2");
            local hpinit1 = msgObj:getInt("hpinit1");
            local hpinit2 = msgObj:getInt("hpinit2");
            local hpend1 = msgObj:getInt("hpend1");
            local hpend2 = msgObj:getInt("hpend2");
            local rcount = msgObj:getInt("rcount");
            local winCount1= msgObj:getInt("wincnt1" );
            local winCount2= msgObj:getInt("wincnt2" );  
            table.insert(ret,
                {
                    winCount1=winCount1,winCount2=winCount2,
                    rcount=rcount,
                    weaponLv1=weaponLv1,awakeLv1=awakeLv1,
                    weaponLv2=weaponLv2,awakeLv2=awakeLv2, 
                    
                    lv1=lv1,power1=power1,
                    lv2=lv2,power2=power2,
                    idx=idx,name1=name1,
                    pos=pos,
                    fname1=fname1,fname2=fname2,
                    hpall1=hpall1,hpall2=hpall2,
                    hpinit1=hpinit1,hpinit2=hpinit2,
                    hpend1=hpend1,hpend2=hpend2,
                    name2=name2,win=win,
                    vid=vid,
                    icon1=icon1,icon2=icon2
                }
            );
        end
    end
    Panel.popUp(PANEL_FAMILY_WAR_MATCH_DETAIL,ret)
end

function Net.sendFamilyVedio(battleid)
    local obj = MediaObj:create();
    obj:setLong("id",battleid);
    Net.sendExtensionMessage(obj, "family.vedio");
end

function Net.rec_family_vedio(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret ~= 0 then
        return
    end

    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA_LOG)
end


function Net.sendFamilyWeekExp()
    local obj = MediaObj:create();
    Net.sendExtensionMessage(obj, "family.weekexp");
end

function Net.rec_family_weekexp(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret ~= 0 then
        return
    end
    local ret={}
    ret.mine = obj:getInt("weekexp");
    if obj:containsKey("list") then
        local list = obj:getArray("list");
        ret.list = {};
        for i=0,list:count()-1 do
            local pObj = list:getObj(i);
            pObj = tolua.cast(pObj,"MediaObj");
            local signFamily={}
            signFamily.id = pObj:getLong("id")
            signFamily.sName = pObj:getString("name")
            signFamily.iLevel = pObj:getShort("level")
            signFamily.sMasName = pObj:getString("mname")
            signFamily.iPower = pObj:getInt("power")
            signFamily.iRank = pObj:getInt("rank")
            signFamily.icon = pObj:getInt("icon")
            signFamily.iExp = pObj:getInt("exp")
            table.insert(ret.list, signFamily );
        end
    end
    

    if(Panel.isTopPanel(PANEL_FAMILY_WAR_RANK))then
        gDispatchEvt(EVENT_ID_FAMILY_WAR_SIGN_LIST,ret);
    else
        Panel.popUp(PANEL_FAMILY_WAR_RANK,ret)
    end
end