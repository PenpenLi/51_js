
-------#####军团 任务 start
--
function Net.sendFamilyTaskInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_TASK_INFO)
end
function dealFamilyTaskList(listobj)
    local listcnt = listobj:count()
    gFamilyTaskInfo.taskList = {}
    if (listcnt ~= 0) then
        for i = 0, listcnt - 1 do
            local robj = listobj:getObj(i)
            robj = tolua.cast(robj, "MediaObj")
            gFamilyTaskInfo.taskList[i+1] = {}
            gFamilyTaskInfo.taskList[i+1].pos = robj:getByte("pos")
            gFamilyTaskInfo.taskList[i+1].taskid = robj:getInt("taskid")
            gFamilyTaskInfo.taskList[i+1].quality = robj:getByte("quality")
            gFamilyTaskInfo.taskList[i+1].jumpid = robj:getInt("jumpid")
            gFamilyTaskInfo.taskList[i+1].npcid = robj:getInt("npcid")
            gFamilyTaskInfo.taskList[i+1].title = robj:getString("title")
            gFamilyTaskInfo.taskList[i+1].step = robj:getInt("step")
            gFamilyTaskInfo.taskList[i+1].target = robj:getInt("target")
            gFamilyTaskInfo.taskList[i+1].info = robj:getString("info")
            gFamilyTaskInfo.taskList[i+1].status = robj:getByte("status")
            gFamilyTaskInfo.taskList[i+1].diamond = robj:getInt("diamond")
            gFamilyTaskInfo.taskList[i+1].type = robj:getByte("type")
            gFamilyTaskInfo.taskList[i+1].reward = {}
            local rArray = robj:getArray("reward1")
            local rArraycnt = rArray:count()
            if (rArraycnt ~= 0) then
                for j = 0,rArraycnt - 1 do
                    local robj2 = rArray:getObj(j)
                    robj2 = tolua.cast(robj2, "MediaObj")
                    gFamilyTaskInfo.taskList[i+1].reward[j+1] = {}
                    gFamilyTaskInfo.taskList[i+1].reward[j+1].id = robj2:getInt("id")
                    gFamilyTaskInfo.taskList[i+1].reward[j+1].num = robj2:getInt("num")
                end
            end
            print("i=",i+1,"title",gFamilyTaskInfo.taskList[i+1].title,"status",gFamilyTaskInfo.taskList[i+1].status)
        end
    end
end
--是否已经有接受过任务
function returnTaskIsAccept()
    for key,value in ipairs(gFamilyTaskInfo.taskList) do
        if (value.status ~= 0) then
            return true
        end
    end
    return false
end
function Net.recFamilyTaskInfo(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyTaskInfo.leftnum = obj:getInt("leftnum")
        local listobj = obj:getArray("tlist")
        dealFamilyTaskList(listobj)
        EventListener:sharedEventListener():handleEvent(c_event_family_task_info)
    end
end

--接受任务
function Net.sendFamilyTaskAccept(pos)
    local obj = MediaObj:create()
    obj:setByte("pos",pos)
    --   echo("pos = "..pos)
    Net.sendExtensionMessage(obj,CMD_FAMILY_TASK_ACCEPT)
end
function Net.recFamilyTaskAccept(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local listobj = obj:getArray("tlist")
        local listcnt = listobj:count()
        --      gFamilyTaskInfo.taskList = {}
        if (listcnt ~= 0) then
            for i = 0, listcnt - 1 do
                local robj = listobj:getObj(i)
                robj = tolua.cast(robj, "MediaObj")
                local pos = robj:getByte("pos")
                local step = robj:getInt("step")
                local status = robj:getByte("status")
                echo("pos = "..pos.."i= "..i)
                echo("1111step = "..step.." status="..status)
                for key,value in ipairs(gFamilyTaskInfo.taskList) do
                    if (value.pos == pos) then
                        value.step = step
                        value.status = status
                        echo("step = "..step.." status="..status)
                        break
                    end
                end
            end
            EventListener:sharedEventListener():handleEvent(c_event_family_task_accept)
        end
    end
end
--放弃任务
function Net.sendFamilyTaskGiveup(pos)
    local obj = MediaObj:create()
    obj:setByte("pos",pos)
    Net.sendExtensionMessage(obj,CMD_FAMILY_TASK_GIVEUP)
end
function Net.recFamilyTaskGiveup(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local pos = obj:getByte("pos")
        local step = obj:getInt("step")
        local status = obj:getByte("status")
        for key,value in ipairs(gFamilyTaskInfo.taskList) do
            if (value.pos == pos) then
                value.step = step
                value.status = status
                --              echo("step = "..step.." status="..status)
                break
            end
        end
        EventListener:sharedEventListener():handleEvent(c_event_family_task_giveup)
    end
end
--完成任务
function Net.sendFamilyTaskFinish(pos)
    local obj = MediaObj:create()
    obj:setByte("pos",pos)
    Net.sendExtensionMessage(obj,CMD_FAMILY_TASK_FINISH)
end
function Net.recFamilyTaskFinish(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyTaskInfo.leftnum = obj:getInt("leftnum")
        if(gFamilyTaskInfo.leftnum <= 0)then
            closeFamilyReddotTask()
        end
        Net.updateReward(obj:getObj("dreward"))
        Net.updateReward(obj:getObj("reward"))
        local fexp = obj:getInt("fexp")
        if (fexp>0) then
            gFamilyInfo.iMemexp = gFamilyInfo.iMemexp + fexp
            ShowItemPool:shared():pushItem(OPEN_BOX_FAMILY_DEVOTE, fexp,0)
            EventListener:sharedEventListener():handleEvent(c_event_ui_role)
            EventListener:sharedEventListener():handleEvent(c_event_family_refresh_info)
        end
        local pos = obj:getByte("pos")
        for key,value in ipairs(gFamilyTaskInfo.taskList) do
            if (value.pos == pos) then
                value.taskid = obj:getInt("taskid")
                value.quality = obj:getByte("quality")
                value.jumpid = obj:getInt("jumpid")
                value.npcid = obj:getInt("npcid")
                value.title = obj:getString("title")
                value.step = obj:getInt("step")
                value.target = obj:getInt("target")
                value.info = obj:getString("info")
                value.status = obj:getByte("status")
                value.diamond = obj:getInt("diamond")
                value.type = obj:getByte("type")
                value.reward = {}
                local rArray = obj:getArray("reward1")
                local rArraycnt = rArray:count()
                if (rArraycnt ~= 0) then
                    for j = 0,rArraycnt - 1 do
                        local robj2 = rArray:getObj(j)
                        robj2 = tolua.cast(robj2, "MediaObj")
                        value.reward[j+1] = {}
                        value.reward[j+1].id = robj2:getInt("id")
                        value.reward[j+1].num = robj2:getInt("num")
                    end
                end
                break
            end
        end
        EventListener:sharedEventListener():handleEvent(c_event_family_task_finish)
    end
end
--用钻石立即完成
function Net.sendFamilyTaskDiamondFinish(pos)
    local obj = MediaObj:create()
    obj:setByte("pos",pos)
    Net.sendExtensionMessage(obj,CMD_FAMILY_TASK_DIAMOND_FINISH)
end
function Net.recFamilyTaskDiamondFinish(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyTaskInfo.leftnum = obj:getInt("leftnum")
        if(gFamilyTaskInfo.leftnum <= 0)then
            closeFamilyReddotTask()
        end
        ClientMsgRecv:shared():updateUserInfo(obj:getObj("uvobj"))
        Net.updateReward(obj:getObj("reward"))
        local fexp = obj:getInt("fexp")
        if (fexp>0) then
            gFamilyInfo.iMemexp = gFamilyInfo.iMemexp + fexp
            ShowItemPool:shared():pushItem(OPEN_BOX_FAMILY_DEVOTE, fexp,0)
            EventListener:sharedEventListener():handleEvent(c_event_ui_role)
            EventListener:sharedEventListener():handleEvent(c_event_family_refresh_info)
        end
        local pos = obj:getByte("pos")
        for key,value in ipairs(gFamilyTaskInfo.taskList) do
            if (value.pos == pos) then
                value.taskid = obj:getInt("taskid")
                value.quality = obj:getByte("quality")
                value.jumpid = obj:getInt("jumpid")
                value.npcid = obj:getInt("npcid")
                value.title = obj:getString("title")
                value.step = obj:getInt("step")
                value.target = obj:getInt("target")
                value.info = obj:getString("info")
                value.status = obj:getByte("status")
                value.diamond = obj:getInt("diamond")
                value.type = obj:getByte("type")
                value.reward = {}
                local rArray = obj:getArray("reward1")
                local rArraycnt = rArray:count()
                if (rArraycnt ~= 0) then
                    for j = 0,rArraycnt - 1 do
                        local robj2 = rArray:getObj(j)
                        robj2 = tolua.cast(robj2, "MediaObj")
                        value.reward[j+1] = {}
                        value.reward[j+1].id = robj2:getInt("id")
                        value.reward[j+1].num = robj2:getInt("num")
                        echo("reward.id = "..value.reward[j+1].id.." value.reward[j+1].num="..value.reward[j+1].num)
                    end
                end
                break
            end
        end
        EventListener:sharedEventListener():handleEvent(c_event_family_task_diamond_finish)
    end
end
--刷新
function Net.sendFamilyTaskRefresh()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_TASK_REFRESH)
end
function Net.recFamilyTaskRefresh(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        ClientMsgRecv:shared():updateUserInfo(obj:getObj("uvobj"))
        local listobj = obj:getArray("tlist")
        dealFamilyTaskList(listobj)
        EventListener:sharedEventListener():handleEvent(c_event_family_task_refresh)
    end
end
--更新
function Net.recFamilyTaskUpdate(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local listobj = obj:getArray("tlist")
        local listcnt = listobj:count()
        if (listcnt ~= 0) then
            for i = 0, listcnt - 1 do
                local robj = listobj:getObj(i)
                robj = tolua.cast(robj, "MediaObj")
                local pos = robj:getByte("pos")
                local step = robj:getInt("step")
                local status = robj:getByte("status")
                for key,value in ipairs(gFamilyTaskInfo.taskList) do
                    if (value.pos == pos) then
                        value.step = step
                        value.status = status
                        echo("step = "..step.." status="..status)
                        break
                    end
                end
            end
            EventListener:sharedEventListener():handleEvent(c_event_family_task_update)
        end
    end
end
--
-------#####军团 任务 end

--军团邮件
function Net.sendFamilyMail(title,content)
    local obj = MediaObj:create()
    obj:setString("title",title);
    obj:setString("content",content);
    Net.sendExtensionMessage(obj,"family.mailmessage")
end

function Net.rec_family_mailmessage(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if(ret == 0)then
        gDispatchEvt(EVENT_ID_FAMILY_EMAIL_SUCCESS);
    end

end

function Net.sendGetFamilyMailList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,"family.maillist")
end

function Net.rec_family_maillist(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if(ret == 0)then
        local list = obj:getArray("list")
        Data.mail.familymaillist = {}
        if(list) then
            list=tolua.cast(list,"MediaArray")
            for i=0, list:count()-1 do
                local obj1=tolua.cast(list:getObj(i),"MediaObj")
                local mInfo = {};
                mInfo.eId = obj1:getLong("id");
                mInfo.title = obj1:getString("title");
                mInfo.content = obj1:getString("content");
                mInfo.time = obj1:getInt("time");
                if(obj1:getByte("ifread") == 1) then
                    mInfo.bolRead = true
                else
                    mInfo.bolRead = false
                end
                
                table.insert(Data.mail.familymaillist,mInfo)
            end
        end
        Net.familymail_sort();
        Net.dealRedDot_FamilyMail();
        gDispatchEvt(EVENT_ID_FAMILY_MAIL_LIST);
    end

end

function Net.sendFamilyMailRead(id)
    local obj = MediaObj:create()
    obj:setLong("id",id);
    Net.sendExtensionMessage(obj,"family.mailread")
end

function Net.rec_family_mailread(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if(ret == 0)then
        local eId = obj:getLong("id");
        for key, var in pairs(Data.mail.familymaillist) do
            if(var.eId == eId)then
                var.bolRead = true;
                break;
            end
        end
        Net.dealRedDot_FamilyMail();
        gDispatchEvt(EVENT_ID_FAMILY_MAIL_READ);
    end
end

function Net.sendFamilyMailDel(id)
    local obj = MediaObj:create()
    obj:setLong("id",id);
    Net.sendExtensionMessage(obj,"family.maildele")
end

function Net.rec_family_maildele(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if(ret == 0)then
        local id = obj:getLong("id");
        Net.deleteOneFamilyEmail(id);
        Net.dealRedDot_FamilyMail()
        gDispatchEvt(EVENT_ID_FAMILY_MAIL_DEL);
    end
end

function Net.deleteOneFamilyEmail(eId)
    for key, var in pairs(Data.mail.familymaillist) do
        if(var.eId == eId)then
            table.remove(Data.mail.familymaillist,key)
            break;
        end
    end
end

function Net.dealRedDot_FamilyMail()
    for key, var in pairs(Data.mail.familymaillist) do
        if (not var.bolRead) then
            Data.redpos.bolFamilyMail = true
            return
        end
    end
    Data.redpos.bolFamilyMail = false
    -- EventListener::sharedEventListener()->handleEvent(c_event_redDot_Email);
end

function Net.familymail_sort()
    local function sort(a, b)
        if a.bolRead == b.bolRead then
            return a.time > b.time
        elseif b.bolRead then
            return true
        else
            return false
        end
    end
    table.sort(Data.mail.familymaillist, sort)
end

--周活跃或月活跃
function Net.sendFamilyExpRank(type)
    local obj = MediaObj:create()
    obj:setByte("type",type);
    Net.sendExtensionMessage(obj,"family.wmrank");
end

function Net.rec_family_wmrank(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")

    if ret == 0 then
        local list = obj:getArray("list")
        Data.family.exprank = {};
        if(list) then
            list=tolua.cast(list,"MediaArray")
            for i=0, list:count()-1 do
                local obj1=tolua.cast(list:getObj(i),"MediaObj")
                local mInfo = {};
                mInfo.uid = obj1:getLong("uid");
                mInfo.uname = obj1:getString("uname");
                mInfo.level = obj1:getShort("level");
                mInfo.type = obj1:getByte("type");
                mInfo.data = obj1:getInt("data");
                mInfo.power = obj1:getInt("power");
                mInfo.icon = obj1:getInt("icon");
                -- mInfo.show = Net.parserShowInfo(obj1:getObj("idetail"));
                
                table.insert(Data.family.exprank,mInfo)
            end
        end
        gDispatchEvt(EVENT_ID_RANK_FAMILY_EXP);
    end

end

--军团信息
function Net.sendFamilyGetInfo(callback,panelId)
    local obj = MediaObj:create()
    Net.sendFamilyGetInfoParam=callback
    Net.sendFamilyGetInfoParam1=panelId
    Net.sendExtensionMessage(obj,CMD_FAMILY_GETINFO)
end

function Net.recFamilyGetInfo(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")

    if ret == 0 then
        if(Net.sendFamilyGetInfoParam)then
            Net.sendFamilyGetInfoParam()
        end
        gFamilyInfo.icon        = obj:getInt("icon");
        gFamilyInfo.sNotice     = obj:getString("notice")
        gFamilyInfo.sName       = obj:getString("name")
        gFamilyInfo.iLevel      = obj:getShort("level")
        gFamilyInfo.iMemexp     = obj:getInt("memexp")
        gFamilyInfo.iWood       = obj:getInt("wood")
        gFamilyInfo.iStone      = obj:getInt("stone")
        gFamilyInfo.iFood       = obj:getInt("food")
        gFamilyInfo.iWoodLv     = obj:getShort("woodlv")
        gFamilyInfo.iStoneLv    = obj:getShort("stonelv")
        gFamilyInfo.iAltarlv    = obj:getShort("altarlv")
        gFamilyInfo.iShoplv     = obj:getShort("shoplv")
        gFamilyInfo.iGoldMineLv = obj:getShort("orelv")
        gFamilyInfo.iFoodlv     = obj:getShort("foodlv")
        gFamilyInfo.iTaskLv     = obj:getShort("tasklv")
        gFamilyInfo.fightLv     = obj:getShort("fightlv")
        gFamilyInfo.iSevenlv    = obj:getShort("sevenlv")
        gFamilyInfo.iSpringlv   = obj:getShort("springlv")
        gFamilyInfo.iWoodNum    = obj:getByte("woodnum")
        gFamilyInfo.iStoneNum   = obj:getByte("stonenum")
        gFamilyInfo.sevennum    = obj:getInt("sevennum");
        gFamilyInfo.drinknum    = obj:getInt("drinknum");
        gFamilyInfo.weekexp     = obj:getInt("weekexp");
        gFamilyInfo.remainone   = obj:getBool("remainone");

        gFamilyInfo.sDec        = obj:getString("dec")
        gFamilyInfo.iDistime    = obj:getInt("distime")
        gFamilyInfo.msgnum      = obj:getByte("msgnum")
        gFamilyInfo.iTempTime   = obj:getInt("temptime")
        gFamilyInfo.bNoApply    = obj:getBool("noapply")

        gFamilyInfo.worship     = obj:getByte("worship")

        gFamilyInfo.apptype     = obj:getByte("apptype")
        gFamilyInfo.limitlv     = obj:getShort("limitlv")
        gFamilyInfo.chnametime  = obj:getInt("chnametime")

        gFamilyInfo.bolDoubleRe = obj:getBool("double")

        gFamilyInfo.dayFlv       = obj:getInt("daylv");
        -- gFamilyInfo.dayFExp      = obj:getInt("dayexp");--日活跃度
        -- gFamilyInfo.curFExp      = obj:getInt("exp");--当前可使用活跃度
        -- gFamilyInfo.totalFExp    = obj:getInt("allexp");--历史活跃度
        -- gFamilyInfo.activenum    = obj:getInt("activenum");
        gFamilyInfo.activeBoxs   = Net.parseFamilyActiveBox(obj:getArray("activebox"));
        Net.updateFamilyFExp(obj);
        -- print_lua_table(gFamilyInfo);

        gFamilyMemList = {}
        if obj:containsKey("list") then
            gFamilyMemList = Net.parseFamilyMemList(obj:getArray("list"))
        end

        for key,var in pairs(gFamilyMemList) do
            if var.uid == Data.getCurUserId() then
                gFamilyInfo.iDayExp = var.iDayExp;
                gFamilyInfo.iExp = var.iExp;
                break;
            end
        end

        -- --怪物入侵
        -- if obj:containsKey("monsterinfo") then
        --     echo("monsterinfo")
        --     local monsterobj = obj:getObj("monsterinfo")
        --     updateMonsterInfo(monsterobj)
        -- end
        -- --fixme cp
        -- --createMonsterInfoForTest()

        -- if obj:containsKey("monsterpos") then
        --     echo("monsterpos")
        --     local monsterposobj = obj:getObj("monsterpos")
        --     updateMonsterNodeInfo(monsterposobj)
        -- end

        -- --fixme cp
        -- --createMonsterPos()
        -- --仙泉召唤者信息
        -- updateFamilyCallSpringInfo(obj:getObj("call"))


        -- for i = 1,FAMILY_BUILD_MAXCOUNT do
        --     gFamilyBuildingLv[i] = 1
        -- end

        -- gFamilyBuildingLv[1]= gFamilyInfo.iLevel
        -- gFamilyBuildingLv[2]= gFamilyInfo.iWoodLv
        -- gFamilyBuildingLv[3]=  gFamilyInfo.iStoneLv
        -- gFamilyBuildingLv[4]=  gFamilyInfo.iAltarlv
        -- gFamilyBuildingLv[5]= gFamilyInfo.iShoplv
        -- gFamilyBuildingLv[6]= gFamilyInfo.iTaskLv
        -- gFamilyBuildingLv[7]= gFamilyInfo.iFoodlv
        -- gFamilyBuildingLv[8]= gFamilyInfo.iGoldMineLv
        -- gFamilyBuildingLv[9]= gFamilyInfo.fightLv
        -- gFamilyBuildingLv[10]= gFamilyInfo.iSevenlv
        -- gFamilyBuildingLv[11]= gFamilyInfo.iSpringlv


        -- if(DataBase:shared():getBolCloseModel(CLOSE_FAMILY_BATTLE) == true) then
        --     gFamilyBuildUnlockData[FAMILY_BUILD_INFOSTATION-1] = 9
        -- end
        local isEnterHall = false;
        if Panel.isTopPanel(PANEL_TASK) then
            isEnterHall = true;
        end

        gDispatchEvt(EVENT_ID_FAMILY_HOME);

        if isEnterHall then
            gDispatchEvt(EVENT_ID_FAMILY_ENTERHALL);
        end

        if(Net.sendFamilyGetInfoParam1)then
            Panel.popUpVisible(Net.sendFamilyGetInfoParam1);
        end

        if(obj:containsKey("rename"))then
            local rename = obj:getByte("rename");
            print("ababababa rename = "..rename);
            if(rename == 1)then
                Panel.popUp(PANEL_FAMILY_CHNAME,true);
            end
        end
    end
    local td_param = {}
    td_param['name'] = gFamilyInfo.sName
    td_param['iLevel'] = gFamilyInfo.iLevel
    gLogEvent("family.info",td_param)
end

function Net.updateMyFamilyInfo(obj)
    if obj == nil then
        return;
    end

    obj = tolua.cast(obj, "MediaObj")
    gFamilyMatchInfo.season = obj:getInt("season", -1);
    gFamilyInfo.winId=obj:getLong("winid");
    gFamilyInfo.familyId = obj:getLong("fid");
    gFamilyInfo.iType = obj:getByte("type");
    gFamilyInfo.iCDTime = obj:getInt("leavetime");
    gFamilyInfo.iCDTimeClientTime = os.time();
    gFamilyInfo.iMemexp = obj:getInt("memexp")
    gFamilyInfo.iLevel  = math.max(obj:getShort("lv"),1)

    if(gFamilyInfo.familyId == 0) then
        gFamilySpringInfo.callUid = 0;
    end

end

--军团宣言
function Net.sendFamilyDec(sContent)
    local obj = MediaObj:create()
    obj:setString("dec",sContent)
    Net.sendExtensionMessage(obj,CMD_FAMILY_SET_DECLARATION)
end

function Net.recFamilyDec(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        --更新宣言
        EventListener:sharedEventListener():handleEvent(c_event_family_modify_dec_success)
    end
end

--解散军团
function Net.sendFamilyDismiss()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_DISMISS)
end

function Net.recFamilyDismiss(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyInfo.iDistime = obj:getInt("distime")
        gDispatchEvt(EVENT_ID_FAMILY_DISMISS);
    end

end

function Net.recReceiveFamilyDismiss(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateMyFamilyInfo(obj:getObj("family"));

        Net.closeAllFamilyReddot()

        gDispatchEvt(EVENT_ID_FAMILY_DISMISS_SUCCESS);
    -- EventListener:sharedEventListener():handleEvent(c_event_rec_family_dismiss)
    -- EventListener:sharedEventListener():handleEvent(c_event_reddot_family)

    end
    --  DataBase:shared().m_familyInfo:initInfo()

end

function Net.closeAllFamilyReddot()
    Data.redpos.bolFamilyApply = false
    Data.redpos.bolFamilyMsg = false
    Data.redpos.bolFamilyDyn = false
    Data.redpos.bolFamilyFoodDyn = false
    Data.redpos.bolFamilyTurn = false
    Data.redpos.bolFamilyWood = false
    Data.redpos.bolFamilyStone = false
    Data.redpos.bolFamilyOre = false
    Data.redpos.bolFamilyFood = false
    Data.redpos.bolFamilySteal = false
    Data.redpos.bolFamilyTask = false
    Data.redpos.bolFamilyStage = false
    Data.redpos.bolFamilyShopReward = false
end

--取消解散
function Net.sendFamilyCancelDismiss()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_CANCEL_DISMISS)
end
function Net.recFamilyCancelDismiss(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyInfo.iDistime = 0;
        gDispatchEvt(EVENT_ID_FAMILY_DISMISS);
    end

end

--军团成员列表
function Net.sendFamilyMemberList()

    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_MEMBER_LIST)

end

function Net.rec_family_memlist(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyMemList = {}
        if obj:containsKey("list") then
            gFamilyMemList =  Net.parseFamilyMemList(obj:getArray("list"))
            gDispatchEvt(EVENT_ID_FAMILY_WAR_GET_MEMBER,gFamilyMemList)
        end
    end

end

function Net.parseFamilyMemList( list )

    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            local buddytable = Net.parseFamilyMemObj(buddyObj)
            if buddytable ~= nil then
                table.insert(buddylist,buddytable)
            end
        end
        return buddylist
    end
end

function Net.parseFamilyMemObj( buddyObj )
    buddyObj =tolua.cast(buddyObj,"MediaObj")
    if buddyObj == nil then
        return nil
    end

    --  {
    --    uid           成员用户id
    --    sName     成员用户名称
    --    iLevel      成员用户等级
    --    iCoat       外套时装
    --    iType       成员类型 1-帮主 2-长老 3成员
    --    iPower     战力
    --    iRand       贡献排名
    --    iDayExp   今日贡献
    --    iExp          总贡献
    --    iArena      斗法排名
    --    iLogin        最后登录时间差（0表示在线）
    --    bTemp     是否实习期
    --  }
    local mem = {}
    mem.uid = buddyObj:getLong("uid")
    mem.sName = buddyObj:getString("uname")
    mem.iLevel = buddyObj:getShort("level")
    mem.iCoat = buddyObj:getInt("icon")
    mem.iType = buddyObj:getByte("type")
    mem.iPower=buddyObj:getInt("power")
    mem.iRank = buddyObj:getInt("rank")
    mem.iDayExp = buddyObj:getInt("dayexp")
    mem.iExp = buddyObj:getInt("exp")
    mem.iArena = buddyObj:getInt("arena")
    mem.iLogin = buddyObj:getInt("login")
    mem.bTemp = buddyObj:getBool("temp")
    mem.iVip = buddyObj:getByte("vip")
    mem.show = Net.parserShowInfo(buddyObj:getObj("idetail"));
    mem.iStageFightNum = 0

    return mem

end

function Net.parseFamilyActiveBox(list)

    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            buddyObj =tolua.cast(buddyObj,"MediaObj")
            local buddytable = {};
            buddytable.id = buddyObj:getInt("id");
            buddytable.rec = buddyObj:getBool("rec");
            table.insert(buddylist,buddytable);
        end
        return buddylist
    end

    return nil;

end

--任命
function Net.sendFamilyAppoint(uid,type)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    obj:setByte("type",type)
    Net.sendExtensionMessage(obj,CMD_FAMILY_APPOINT)
end

function Net.recFamilyAppoint(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gDispatchEvt(EVENT_ID_FAMILY_APPOINT_MEM);
        gDispatchEvt(EVENT_ID_FAMILY_CHANGE_TYPE);
    -- EventListener:sharedEventListener():handleEvent(c_event_appoint_mem)
    -- EventListener:sharedEventListener():handleEvent(c_event_change_type_refreshui_infolayer)
    -- EventListener:sharedEventListener():handleEvent(c_event_change_type_refreshui_menulayer)
    end

end





function Net.recReceiveFamilyAppoint(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local type = obj:getByte("type")
        gFamilyInfo.iType = type;
        local word = ""
        if type == 9 then
            word = gGetWords("familyMenuWord.plist","rec_app2")
        else
            local sType = gGetWords("familyMenuWord.plist","title"..type);
            word = gGetWords("familyMenuWord.plist","rec_app",sType);
        -- word = replaceString(word,sType)
        end
        gShowNotice(word);
    -- NotificationLayer:showInfo(word)
    end
    gDispatchEvt(EVENT_ID_FAMILY_CHANGE_TYPE);
-- EventListener:sharedEventListener():handleEvent(c_event_change_type_refreshui_infolayer)
-- EventListener:sharedEventListener():handleEvent(c_event_change_type_refreshui_menulayer)

end

--驱逐
function Net.sendFamilyExpel(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_EXPEL)
end

function Net.recFamilyExpel(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gDispatchEvt(EVENT_ID_FAMILY_EXPEL);
    -- EventListener:sharedEventListener():handleEvent(c_event_expel_mem)
    end
end

function Net.recReceiveFamilyExpel(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local word = gGetWords("familyMenuWord.plist","rec_expel")
        gShowNotice(word);
        --    DataBase:shared().m_familyInfo:initInfo()
        Net.updateMyFamilyInfo(obj:getObj("family"));
        gDispatchEvt(EVENT_ID_FAMILY_EXIT);
    -- ClientMsgRecv:shared():updateFamilyInfoObj(obj:getObj("family"))
    -- EventListener:sharedEventListener():handleEvent(c_event_family_exit)
    end

end

--退出军团
function Net.sendFamilyExit()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_EXIT)
end

function Net.recFamilyExit(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        --    DataBase:shared().m_familyInfo:initInfo()
        Net.updateMyFamilyInfo(obj:getObj("family"));
        gDispatchEvt(EVENT_ID_FAMILY_EXIT);
    -- ClientMsgRecv:shared():updateFamilyInfoObj(obj:getObj("family"))
    -- EventListener:sharedEventListener():handleEvent(c_event_family_exit)
    end
end

--审核列表
function Net.sendFamilyApplyList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_APPLY_LIST)
end

function Net.recFamilyApplyList(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyAppListInfo.curCount = obj:getByte("pass")
        gFamilyAppList = {}
        if obj:containsKey("list") then
            gFamilyAppList = getFamilyApplyList(obj:getArray("list"))
            -- print_lua_table(gFamilyAppList);
            gDispatchEvt(EVENT_ID_FAMILY_APP_LIST);
        end
    end

end

function getFamilyApplyList( list )

    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            local buddytable = getFamilyApplyObj(buddyObj)
            if buddytable ~= nil then
                table.insert(buddylist,buddytable)
            end
        end

        --    --好友排序
        --    local function sortWithLv(buddy1,buddy2)
        --      local lv1 = buddy1.lv
        --      local lv2 = buddy2.lv
        --      if(lv1 > lv2) then
        --        return true
        --      end
        --      return false
        --    end
        --      table.sort(buddylist,sortWithLv)

        return buddylist
    end
end

function getFamilyApplyObj( buddyObj )
    buddyObj =tolua.cast(buddyObj,"MediaObj")
    if buddyObj == nil then
        return nil
    end

    --{
    --  uid
    --  sName
    --  iLevel
    --  iCoat
    --  iPower
    --  iArena
    --  iLogin
    --  iTime   申请时间
    --}

    local mem = {}
    mem.uid = buddyObj:getLong("uid")
    mem.sName = buddyObj:getString("uname")
    mem.iLevel = buddyObj:getShort("level")
    mem.iCoat = buddyObj:getInt("icon")
    mem.iPower=buddyObj:getInt("power")
    mem.iArena = buddyObj:getInt("arena")
    mem.iLogin = buddyObj:getInt("login")
    mem.iTime = buddyObj:getInt("time")
    mem.iVip = buddyObj:getByte("vip")

    return mem

end

--同意
function Net.sendFamilyPass(uid)
    local obj = MediaObj:create()
    Data.family.passUid = uid;
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_PASS)
end

function Net.recFamilyPass(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local mem = Net.parseFamilyMemObj(obj:getObj("mem"))
        if mem ~= nil then
            table.insert(gFamilyMemList,mem)
            -- gDispatchEvt(EVENT_ID_FAMILY_MEM_ADD,mem)
            gFamilyAppListInfo.curCount = gFamilyAppListInfo.curCount + 1
            local uid = mem.uid
            local index = Data.removeFamilyAppWithUid(uid)
            gDispatchEvt(EVENT_ID_FAMILY_APP_REMOVE,{index = index})
        end
        gDispatchEvt(EVENT_ID_FAMILY_APP_LIST);
    elseif ret == 26 then
        local uid = Data.family.passUid;
        local index = Data.removeFamilyAppWithUid(uid);
        gDispatchEvt(EVENT_ID_FAMILY_APP_REMOVE,{index = index});
    elseif ret == 29 then
        Net.sendFamilyApplyList();
    end

end

function Net.recReceiveFamilyPass(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        --    local iFamilyId = obj:getLong("fid")
        --    local iType = obj:getByte("type")
        Net.updateMyFamilyInfo(obj:getObj("family"));
        -- ClientMsgRecv:shared():updateFamilyInfoObj(obj:getObj("family"))
        local word = gGetWords("familyMenuWord.plist","rec_pass")
        gShowNotice(word);
        -- NotificationLayer:showInfo(word)

        if(Panel.getPanelByType(PANEL_FAMILY_SEARCH)) then
            -- Panel.popBackToTag(PANEL_FAMILY_SEARCH);
            Panel.popBackAll();
        end
        -- local pUILayer = tolua.cast(getUILayerWithMapName("ui_jz_liebiao.map"),"UILayer")
        -- if pUILayer ~= nil then
        --     pUILayer:handleClose()
        -- end
    end

end

--拒绝
function Net.sendFamilyRefuse(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_REFUSE)

end

function Net.recFamilyRefuse(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gDispatchEvt(EVENT_ID_FAMILY_APP_REFUSE);
    -- EventListener:sharedEventListener():handleEvent(c_event_refuse_app)
    elseif ret == 29 then
        Net.sendFamilyApplyList();
    end
end

function Net.sendFamilyRefuseAll()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_REFUSE_ALL)

end
function Net.recFamilyRefuseAll(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilyAppList={}
        gDispatchEvt(EVENT_ID_FAMILY_APP_LIST);
    -- EventListener:sharedEventListener():handleEvent(c_event_get_familyapplist)
    end
end

function Net.sendFamilyFight(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_FIGHT)
end

function Net.recFamilyFight(evt)

    print("xxx");
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    print("yyyy");
    local data = obj:getObj("bat")
    local byteArr= data:getByteArray("info")
    gParserGameVideo(byteArr,BATTLE_TYPE_ARENA_LOG)

end


--搜索军团
function Net.sendFamilySearch(iRank,index,sName)
    local obj = MediaObj:create()
    if iRank ~= nil and iRank ~= -1 then
        obj:setInt("rank",iRank)
    end
    if index ~= nil and index ~= -1 then
        obj:setInt("idx",index)
    end
    if(sName ~= nil) then
        obj:setString("name",sName)
    end
    Net.sendExtensionMessage(obj,CMD_FAMILY_SEARCH)
end

function Net.recFamilySearch(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local searchlist = {}
    if obj:containsKey("list") then
        local list = obj:getArray("list")
        for i = 0,list:count()-1 do
            local pObj = list:getObj(i)
            if pObj ~= nil then
                local search_family = {}
                pObj =tolua.cast(pObj,"MediaObj")
                search_family.id = pObj:getLong("id")
                search_family.sName = pObj:getString("name")
                search_family.iLevel = pObj:getShort("level")
                search_family.sMasName = pObj:getString("masname")
                search_family.iMemNum = pObj:getInt("memnum")
                search_family.iPower = pObj:getInt("power")
                search_family.sDec = pObj:getString("dec")
                search_family.iRank = pObj:getInt("rank")
                search_family.bApped = pObj:getBool("apply")
                search_family.bNoNeedApp = pObj:getBool("noapply")
                search_family.icon = pObj:getInt("icon")
                search_family.totalFExp = pObj:getInt("allexp");
                table.insert(searchlist,search_family)
            end
        end
    end

    gDispatchEvt(EVENT_ID_FAMILY_SEARCH,searchlist)

end

function Net.sendFamilyGetFamilyInfo(id)
    local obj = MediaObj:create()
    obj:setLong("id",id);
    Net.sendExtensionMessage(obj,"family.getfamilyinfo");    
end

function Net.rec_family_getfamilyinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local data = {};
        data.id = obj:getLong("id")
        data.sName = obj:getString("name")
        data.iLevel = obj:getShort("level")
        data.sMasName = obj:getString("masname")
        data.iMemNum = obj:getInt("memnum")
        -- data.iPower = obj:getInt("power")
        data.sDec = obj:getString("dec")
        data.iRank = obj:getInt("rank")
        -- data.bApped = obj:getBool("apply")
        -- data.bNoNeedApp = obj:getBool("noapply")
        data.icon = obj:getInt("icon")
        data.totalFExp = obj:getInt("allexp");

        gDispatchEvt(EVENT_ID_RANK_FAMILY_CHECK,data);
    end
end

--建立军团
function Net.sendFamilyCreate(name,icon)
    local obj = MediaObj:create()
    obj:setString("name",name)
    obj:setInt("icon",icon)
    Net.sendExtensionMessage(obj,CMD_FAMILY_CREATE)
end

function Net.recFamilyCreate(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then

        Net.updateReward(obj:getObj("reward"));
        Net.updateMyFamilyInfo(obj:getObj("family"));

        Net.sendFamilyGetInfo();
    end

end

--申请加入军团
function Net.sendFamilyApply(fid)
    local obj = MediaObj:create()
    obj:setLong("id",fid)
    Net.sendExtensionMessage(obj,CMD_FAMILY_APPLY)
end

function Net.recFamilyApply(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then

        --直接加入成功
        if obj:containsKey("family") then
            Net.updateMyFamilyInfo(obj:getObj("family"));
            local word = gGetWords("familyMenuWord.plist","rec_joinin");
            gShowNotice(word);

            Panel.popBackAll();
            Net.sendFamilyGetInfo();
            return;
        end

        local fid = obj:getLong("id")
        -- echo("fid = "..fid)
        -- print_lua_table(gFamilySearchList)
        local index = -1
        for i,value in ipairs(gFamilySearchList) do
            if value.id == fid then
                value.bApped = true
                index = i -1
                break
            end
        end
        -- echo("index ==== "..index)

        if index >= 0 then
            local word = gGetWords("familyMenuWord.plist","app_success");
            gShowNotice(word);
            gDispatchEvt(EVENT_ID_FAMILY_APP_SUCCESS,{index = index,bApped = true})
        end
    end

end

function Net.sendFamilyCancelApply(fid)
    local obj = MediaObj:create()
    obj:setLong("id",fid)
    Net.FamilyCancelApplyId = fid;
    Net.sendExtensionMessage(obj,CMD_FAMILY_CANCEL_APPLY)
end

function Net.recFamilyCancelApply(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 or ret == 9 then
        -- local fid = obj:getLong("id")
        local fid = Net.FamilyCancelApplyId;
        local index = -1
        for i,value in ipairs(gFamilySearchList) do
            if value.id == fid then
                value.bApped = false
                index = i -1
                break
            end
        end
        -- echo("index ==== "..index)
        if index >= 0 then
            gDispatchEvt(EVENT_ID_FAMILY_APP_SUCCESS,{index = index,bApped = false})
        end
    end

end

function Net.sendFamilySetApply()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,CMD_FAMILY_SET_APPLY)
end


--设置公告
function Net.sendFamilyNotice(notice)
    local obj = MediaObj:create()
    obj:setString("content",notice)
    Net.sendExtensionMessage(obj,CMD_FAMILY_SET_NOTICE)
end

function Net.recFamilyNotice(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gDispatchEvt(EVENT_ID_FAMILY_NOTICE_MODIFY_SUCCESS);
        gDispatchEvt(EVENT_ID_FAMILY_NOTICE_REFRESH);
    end
end




--擂鼓
function Net.sendFamilyAddWood(type)
    local obj = MediaObj:create()
    obj:setByte("type",type)
    gFamilyCutType=type
    -- print("sendFamilyAddWood")
    Net.sendExtensionMessage(obj, CMD_FAMILY_ADD_WOOD)
end


function Net.recFamilyAddWood(evt)
    -- print("recFamilyAddWood")
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),2);
        Net.updateFamilyFExp(obj);
        gFamilyInfo.iWoodNum=gFamilyInfo.iWoodNum-1;
        Data.redpos.bolFamilyGu = false;
        gDispatchEvt(EVENT_ID_FAMILY_CUT);
    end
end

--砸金蛋
function Net.sendFamilyEgg(type)
    local obj = MediaObj:create()
    -- obj:setByte("type",type)
    gFamilyCutType=type
    Net.sendExtensionMessage(obj, "family.knockegg");
end

function Net.rec_family_knockegg(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),2);
        Net.updateFamilyFExp(obj)
        gFamilyInfo.iStoneNum=gFamilyInfo.iStoneNum-1;
        Data.redpos.bolFamilyEgg = false;
        gDispatchEvt(EVENT_ID_FAMILY_CUT);
    -- gShowItemPoolLayer:pushOneItem({id=OPEN_BOX_FAMILY_DEVOTE,num=getExp});
    end
end

--by cp
function updateFamilyInfoBlv()
    if gFamilyUpgradeType == 1 then
        gFamilyInfo.iLevel = gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 2 then
        gFamilyInfo.iWoodLv = gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 3 then
        gFamilyInfo.iStoneLv = gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 4 then
        gFamilyInfo.iAltarlv = gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 5 then
        gFamilyInfo.iShoplv =  gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 6 then
        gFamilyInfo.iTaskLv =  gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 7 then
        gFamilyInfo.iFoodlv =  gFamilyBuildingLv[gFamilyUpgradeType]
    elseif gFamilyUpgradeType == 8 then
        gFamilyInfo.iGoldMineLv = gFamilyBuildingLv[gFamilyUpgradeType]
    end

end

--留言板

--发送留言
function Net.sendFamilyMessage(msg, isUpgrade)
    gFamilyMsgBoardIsRemind = isUpgrade
    local obj = MediaObj:create()
    obj:setString("content", msg)
    obj:setBool("upgrade", isUpgrade)

    Net.sendExtensionMessage(obj, CMD_FAMILY_LEAVE_MESSAGE)
end

--发送留言反馈
function Net.recFamilySendMessage(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        if gFamilyMsgBoardIsRemind == false then
            print("send family message success")
            gDispatchEvt(c_event_family_msgboard_send,{})
        else
            local word = getWordWithFile("familyWord.plist","family_message_board_remind_success")
            NotificationLayer:showInfo(word)
        end
        --    elseif ret == ERR_WRONG_STATUS then
        --             local word = getWordWithFile("familyWord.plist","family_message_board_have_remind")
        --             NotificationLayer:showInfo(word)
    end






end

--接收留言
function Net.sendFamilyGetMessage()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_FAMILY_GET_MESSAGE)
end


--接收留言
function Net.recFamilyGetMessage(evt)
    local obj = data.event.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local listobj = obj:getArray("list")
        local listcnt = listobj:count()
        print("list count",listcnt)
        gFamilyMsgBoardData.msglist = {}
        if (listcnt ~= 0) then
            for i = 0, listcnt - 1 do
                local carditem = listobj:getObj(i)
                carditem = tolua.cast(carditem, "MediaObj")
                gFamilyMsgBoardData.msglist[i+1] = {}
                gFamilyMsgBoardData.msglist[i+1].name = carditem:getString("name")
                gFamilyMsgBoardData.msglist[i+1].content = carditem:getString("content")
                gFamilyMsgBoardData.msglist[i+1].time = carditem:getInt("time")

                print("msg list ",gFamilyMsgBoardData.msglist[i+1].name,gFamilyMsgBoardData.msglist[i+1].content,gFamilyMsgBoardData.msglist[i+1].time)
            end
        end


        gDispatchEvt(c_event_family_msgboard_get,{})
    end

end


-------#####军团 众仙泉 start
-- CMD_FAMILY_SPRING_INFO = "family.springinfo";--获取众仙泉界面信息
-- CMD_FAMILY_CALL_SPRING = "family.callspring";--召唤泉水
-- CMD_FAMILY_DRINK_SPRING = "family.drinkspring";--饮用泉水
function Net.sendFamilySpringInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,"family.springinfo")
end
function updateFamilyCallSpringInfo(robj)
    if (robj ~= nil) then
        gFamilySpringInfo.callUid = robj:getLong("uid")
        gFamilySpringInfo.callName = robj:getString("name")
        gFamilySpringInfo.callIcon = robj:getInt("icon")
        gFamilySpringInfo.show = Net.parserShowInfo(robj:getObj("idetail"));
    else
        gFamilySpringInfo.callUid = 0
    end

    if(gMainBgLayer)then
        gMainBgLayer:checkFamilySpringInfo();
    end
    -- print("recFamilySpringInfo======"..gFamilySpringInfo.callUid)
end
function Net.rec_family_springinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilySpringInfo.drink = obj:getByte("drink")--军团饮泉人数
        gFamilyInfo.drinknum = gFamilySpringInfo.drink;
        gFamilySpringInfo.isdrink = obj:getBool("isdrink")--用户今日是否饮过泉水
        -- print("recFamilySpringInfo1"..gFamilySpringInfo.drink..",isdrink="..tostring((gFamilySpringInfo.isdrink==true) and 1 or 0))
        updateFamilyCallSpringInfo(obj:getObj("call"))
    end
    gDispatchEvt(EVENT_ID_FAMILY_SPRING_INIT,ret)
end

function Net.sendFamilyCallSpring()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,"family.callspring")
end
function Net.rec_family_callspring(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),2)
        updateFamilyCallSpringInfo(obj:getObj("call"))
        Net.updateFamilyFExp(obj);
        Data.redpos.bolFamilySpring = false;
        -- local exp = obj:getInt("exp");
        -- Data.updateCurFamilyExp(-exp);
    end
    gDispatchEvt(EVENT_ID_FAMILY_SPRING_CALL,ret)
end

function Net.sendFamilyDrinkSpring()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,"family.drinkspring")
end
function Net.rec_family_drinkspring(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        gFamilySpringInfo.drink = obj:getByte("drink")--军团饮泉人数
        gFamilySpringInfo.isdrink = true
        Net.updateReward(obj:getObj("reward"),2)
        Net.updateFamilyFExp(obj);
        Data.redpos.bolFamilySpring = false;
    end
    gDispatchEvt(EVENT_ID_FAMILY_SPRING_DRINK,ret)
end
-------#####军团 众仙泉 end

--军团膜拜
function Net.sendFamilyWorship(uid)
    local obj = MediaObj:create()
    obj:setLong("uid",uid)
    Net.sendExtensionMessage(obj,"family.worship")
    gLogEventBI('family.worship',{worship_id=tostring(uid)})
end
function Net.rec_family_worship(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),2)
        gFamilyInfo.worship = gFamilyInfo.worship + 1;
        gDispatchEvt(EVENT_ID_FAMILY_MOBAI)
    end
end

--军团七星封魔
-- CMD_FAMILY_SEVEN_INFO = "family.seveninfo" --获取七星封魔信息
-- CMD_FAMILY_SEVEN_JOIN = "family.sevenjoin" --加入七星封魔
function Net.sendFamilySevenInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,"family.seveninfo")
end
function Net.sendFamilySevenJoin()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj,"family.sevenjoin")
    if (TalkingDataGA) then
        gLogEvent("family.sevenjoin")
    end
end
function updateFamilySevenData(data)
    gFamilySevenData.list = {}
    local listobj = data:getArray("list")
    local listcnt = listobj:count()
    if (listcnt ~= 0) then
        for i = 1, listcnt do
            local itemObj = listobj:getObj(i-1)
            itemObj = tolua.cast(itemObj, "MediaObj")
            gFamilySevenData.list[i] = {}
            gFamilySevenData.list[i].userId = itemObj:getLong("uid")
            gFamilySevenData.list[i].userName = itemObj:getString("name")
            gFamilySevenData.list[i].icon = itemObj:getInt("icon")
            gFamilySevenData.list[i].isHelp = itemObj:getBool("help")
            gFamilySevenData.list[i].show = Net.parserShowInfo(itemObj:getObj("idetail"));
        end
    end
    gFamilyInfo.sevennum = listcnt;
    if(gFamilyInfo.sevennum ~= 4)then
        gFamilyInfo.remainone = false;
    end
    return listcnt;
end
function Net.rec_family_seveninfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        updateFamilySevenData(obj)
        gFamilySevenData.isHelp = obj:getBool("help")--自己是不是协助状态
        gFamilySevenData.isInvite = obj:getBool("invite")--是否邀请过

        -- for i = 2, 5 do
        --     gFamilySevenData.list[i] = gFamilySevenData.list[1]
        -- end

        -- EventListener:sharedEventListener():handleEvent(c_event_family_seven_info)
    end
    -- print("================rec_family_seveninfo==========="..ret)
    gDispatchEvt(EVENT_ID_FAMILY_SEVEN_INFO,ret)
end
function Net.rec_family_sevenjoin(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local count = updateFamilySevenData(obj)
        -- Net.updateReward(obj:getObj("reward"),2)

        if (count>=5 and not gFamilySevenData.isHelp) then
            --奖励
            local items = DB.getFamilySevenReward(Data.getCurFamilyLv());
            -- table.insert(items,{id=OPEN_BOX_FAMILY_DEVOTE,num=500});
            gShowItemPoolLayer:pushItems(items);
        end
        Net.updateFamilyFExp(obj);
        Data.redpos.bolFamilySeven = false;
        -- Net.updateReward(obj:getObj("reward"))
        -- EventListener:sharedEventListener():handleEvent(c_event_family_seven_join)
    end
    gDispatchEvt(EVENT_ID_FAMILY_SEVEN_JOIN,ret)
end

--军团设置
CMD_FAMILY_CHANGE_NAME = "family.chname"
CMD_FAMILY_SAVE_SET = "family.saveset"

function Net.sendFamilyChName(name)
    local obj = MediaObj:create()
    obj:setString("name", name)
    Net.sendExtensionMessage(obj, CMD_FAMILY_CHANGE_NAME)
end

function Net.rec_family_chname(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        gFamilyInfo.chnametime  = obj:getInt("time")
        Net.updateReward(obj:getObj("reward"),0)
        gDispatchEvt(EVENT_ID_FAMILY_CH_NAME)
    end
end

function Net.sendFamilySaveSet(icon, appType, limitLv)
    local obj = MediaObj:create()
    obj:setInt("icon", icon)
    obj:setByte("type",appType)
    obj:setShort("lv", limitLv)
    Net.sendExtensionMessage(obj, CMD_FAMILY_SAVE_SET)
end

function Net.rec_family_saveset(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        if not Panel.isOpenPanel(PANEL_FAMILY_MAMAGE) then
            gFamilyInfo.apptype = gFamilyInfo.apptypeCache
            gFamilyInfo.limitlv = gFamilyInfo.limitlvCache
            gFamilyInfo.icon    = gFamilyInfo.iconCache
        end
        gDispatchEvt(EVENT_ID_FAMILY_SAVE_SET)
    end
end


--军团领取活跃宝箱
function Net.sendFamilyActiveBox(boxid)
    local obj = MediaObj:create()
    obj:setInt("id", boxid)
    FamilyHomePanelData.boxid = boxid;
    Net.sendExtensionMessage(obj, "family.recactivebox");    
end
function Net.rec_family_recactivebox(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        Net.updateReward(obj:getObj("reward"),2);
        gDispatchEvt(EVENT_ID_FAMILY_ACTIVEBOX);
    end    
end

--军团升级
function Net.sendFamilyUpgrade()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, "family.upgrade");
end
function Net.rec_family_upgrade(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        gFamilyInfo.iLevel = gFamilyInfo.iLevel+1;
        gFamilyInfo.curFExp = obj:getInt("exp");--当前可使用活跃度
        gDispatchEvt(EVENT_ID_FAMILY_UPGRADE);
    end      
end

--军团活跃度
function Net.updateFamilyFExp(obj)
    --当前可使用活跃度
    if(obj:containsKey("exp"))then
        gFamilyInfo.curFExp = obj:getInt("exp");
    end
    --日活跃度
    if(obj:containsKey("dayexp"))then
        gFamilyInfo.dayFExp = obj:getInt("dayexp");
    end
    --历史活跃度
    if(obj:containsKey("allexp"))then
        gFamilyInfo.totalFExp = obj:getInt("allexp");
    end
    --活跃人数
    if(obj:containsKey("activenum"))then
        gFamilyInfo.activenum = obj:getInt("activenum");
    end
    -- print("gFamilyInfo.totalFExp = "..gFamilyInfo.totalFExp);

    gDispatchEvt(EVENT_ID_FAMILY_ACTIVEBOX);
end

--军团限时商店
function Net.sendFamilyGoodsInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, "family.goodsinfo");
end
function Net.rec_family_goodsinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        local list = Net.parseFamilyGoodsList(obj:getArray("list"));
        local time = obj:getInt("next");
        gDispatchEvt(EVENT_ID_FAMILY_SHOP,{type=2,list=list,time=time});
    end    
end
function Net.parseFamilyGoodsList(list)
    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            buddyObj =tolua.cast(buddyObj,"MediaObj")
            local buddytable = {};
            buddytable.id = buddyObj:getInt("id");
            buddytable.fnum = buddyObj:getInt("fnum");
            buddytable.unum = buddyObj:getInt("unum");
            table.insert(buddylist,buddytable);
        end
        return buddylist
    end
    return nil;    
end
function Net.sendFamilyShop2Buy(id)
    local obj = MediaObj:create()
    obj:setInt("id", id)
    Net.sendExtensionMessage(obj, "family.buygoods");
end
function Net.rec_family_buygoods(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        Net.updateReward(obj:getObj("reward"),2);
        local data = {};
        data.id = obj:getInt("id");
        data.fnum = obj:getInt("fnum");
        data.unum = obj:getInt("unum");
        gDispatchEvt(EVENT_ID_FAMILY_SHOP2_BUY,data);
    end
end

--军团奖励商店
function Net.sendFamilyLvReward()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, "family.lvreward");    
end
function Net.rec_family_lvreward(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        local list = Net.parseFamilyLvRewardList(obj:getArray("list"));
        gDispatchEvt(EVENT_ID_FAMILY_SHOP,{type=3,list=list});
    end    
end
function Net.parseFamilyLvRewardList(list)
    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            buddyObj =tolua.cast(buddyObj,"MediaObj")
            local buddytable = {};
            buddytable.lv = buddyObj:getInt("lv");
            buddytable.num = buddyObj:getInt("num");
            table.insert(buddylist,buddytable);
        end
        return buddylist
    end
    return nil;    
end
function Net.sendFamilyShop3Buy(lv)
    local obj = MediaObj:create()
    obj:setInt("lv", lv);
    ShopPanelData.familyShop3BuyLv = lv;
    Net.sendExtensionMessage(obj, "family.buylvreward");    
end
function Net.rec_family_buylvreward(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        Net.updateReward(obj:getObj("reward"),2);
        local data = {};
        data.lv = ShopPanelData.familyShop3BuyLv;
        gDispatchEvt(EVENT_ID_FAMILY_SHOP3_BUY,data);
    end
end

--军团技能
function Net.sendFamilySkillInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, "family.skillinfo");  
end
function Net.rec_family_skillinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        local list = Net.parseFamilySkillList(obj:getArray("list"));
        gDispatchEvt(EVENT_ID_FAMILY_SKILL,list);
    end    
end
function Net.parseFamilySkillList(list)
    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            buddyObj =tolua.cast(buddyObj,"MediaObj")
            local buddytable = {};
            buddytable.id = buddyObj:getInt("id");
            buddytable.skilllv = buddyObj:getInt("lv");
            buddytable.userskilllv = buddyObj:getInt("ulv");
            table.insert(buddylist,buddytable);
        end
        return buddylist
    end
    return nil;    
end

function Net.sendFamilyUserSkillUpgrade(skillid)
    local obj = MediaObj:create()
    obj:setInt("id",skillid);
    Net.sendExtensionMessage(obj, "family.userskillupgrade");  
end
function Net.rec_family_userskillupgrade(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        Net.updateReward(obj:getObj("reward"),0);
        local data = {};
        data.id = obj:getInt("id");
        data.userskilllv = obj:getInt("lv");
        gDispatchEvt(EVENT_ID_FAMILY_SKILL_LEARN,data);

        local find = false;
        for key,var in pairs(gUserFamilyBuff) do
            if var.id == data.id then
                var.userskilllv = data.userskilllv;
                find = true;
                break;
            end
        end
        if(find==false)then
            table.insert(gUserFamilyBuff,data);
        end
    end
    
    CardPro.setAllCardAttr() 

end


function Net.sendFamilySkillUpgrade(skillid)
    local obj = MediaObj:create()
    obj:setInt("id",skillid);
    Net.sendExtensionMessage(obj, "family.skillupgrade");  
end
function Net.rec_family_skillupgrade(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        Net.updateReward(obj:getObj("reward"),0);
        local data = {};
        data.id = obj:getInt("id");
        data.skilllv = obj:getInt("lv");
        gShowNotice(gGetWords("familyMenuWord.plist","skill_research",data.skilllv));
        Net.updateFamilyFExp(obj);
        gDispatchEvt(EVENT_ID_FAMILY_SKILL_RESEARCH,data);
        gLogEventBI("family_skillupgrade",{skillid=data.id,skilllv=data.skilllv})
    end    
end

function Net.sendFamilyUserSkill()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, "family.userskill");  
end
function Net.rec_family_userskill(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
        local list = Net.parseFamilyUserSkillList(obj:getArray("list"));
        -- print_lua_table(list);
        -- gDispatchEvt(EVENT_ID_FAMILY_SKILL,list);
    end    
end
function Net.parseFamilyUserSkillList(list)
    if(list ~= nil) then
        local buddylist = {}
        for i=0,list:count()-1 do
            local buddyObj = list:getObj(i)
            buddyObj =tolua.cast(buddyObj,"MediaObj")
            local buddytable = {};
            buddytable.id = buddyObj:getInt("id");
            buddytable.userskilllv = buddyObj:getInt("lv");
            if(buddytable.userskilllv > 0)then
                table.insert(buddylist,buddytable);
            end
        end
        return buddylist
    end
    return nil;    
end


--动态
function Net.sendFamilyDynamic()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, "family.dynamic");
end

function Net.rec_family_dynamic(evt)

    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if 0 == ret then
  
        Data.family.dynamic = {};
--      {
--        iType
--        sName
--        parame1
--        iTime
--        rewardList
--      }     

    if obj:containsKey("list") then
      local list = obj:getArray("list");
      for i = 0,list:count()-1 do
        local pObj = list:getObj(i);
        if pObj ~= nil then
          local dynamic = {};
          pObj =tolua.cast(pObj,"MediaObj")
          dynamic.iMemType = pObj:getByte("memtype");
          dynamic.bMemTemp = pObj:getBool("temp");
          dynamic.iType = pObj:getByte("type");
          dynamic.sName = pObj:getString("name");
          dynamic.parame1 = pObj:getInt("param1");
          dynamic.parame2 = pObj:getInt("param2");
          dynamic.iTime = pObj:getInt("time");
          dynamic.iCurrenCy = pObj:getInt("currency");
          dynamic.iValue = pObj:getInt("value");
          dynamic.icon = pObj:getInt("icon");
          dynamic.level = pObj:getInt("level");
          dynamic.price = pObj:getInt("price");
          dynamic.uid = pObj:getLong("uid");
          dynamic.rewardList = {};
          if pObj:containsKey("rewards") then
            local rewards = pObj:getArray("rewards");
            for j = 0,rewards:count()-1 do
              local pRewardObj = rewards:getObj(j);
              if pRewardObj ~= nil then
                pRewardObj = tolua.cast(pRewardObj,"MediaObj");
                local reward_data = {};
                reward_data.id = pRewardObj:getInt("id");
                reward_data.iNum = pRewardObj:getInt("num");
                table.insert(dynamic.rewardList,reward_data);
              end
            end
          end
          table.insert(Data.family.dynamic,dynamic);
        end
      end
    end
    
        --好友排序
    local function sortWithTime(buddy1,buddy2)
      local lv1 = buddy1.iTime;
      local lv2 = buddy2.iTime;
      if(lv1 > lv2) then
        return true;
      end
      return false;
    end
      table.sort(Data.family.dynamic,sortWithTime);
    
    gDispatchEvt(EVENT_ID_FAMILY_DYNAMIC);
    -- EventListener:sharedEventListener():handleEvent(c_event_family_main_dynamic_list);
    -- EventListener:sharedEventListener():handleEvent(c_event_family_dynamic_list);
  end
  
end





--金矿
function Net.sendFamilyOreInfo()
  local obj = MediaObj:create();
  Net.sendExtensionMessage(obj,"family.oreinfo");
end

function Net.rec_family_oreinfo(evt)
  local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
  if ret == 0 then
        gFamilyGoldMineInfo = {};
        gFamilyGoldMineInfo.level = obj:getShort("level");
        -- gFamilyBuildingLv[FAMILY_BUILD_GOLDMINE] = gFamilyGoldMineInfo.level;
        gFamilyGoldMineInfo.shovel1 = obj:getByte("shovel1");
        gFamilyGoldMineInfo.shovel2 = obj:getByte("shovel2");
        gFamilyGoldMineInfo.shovel3 = obj:getByte("shovel3");
        gFamilyGoldMineInfo.crystal = obj:getInt("crystal");
        gFamilyGoldMineInfo.old_crystal = gFamilyGoldMineInfo.crystal;
        gFamilyGoldMineInfo.goldminelist = Net.getFamilyGoldMineList(obj:getArray("list"));
        
       print_lua_table(gFamilyGoldMineInfo);
        -- gDispatchEvt(EVENT_ID_FAMILY_OREINFO);
        Panel.popUpVisible(PANEL_FAMILY_ORE);
  end
end

function Net.getFamilyGoldMineList( list )

  if(list ~= nil) then
    local buddylist = {};
    for i=0,list:count()-1 do
      local buddyObj = list:getObj(i);
      local buddytable = Net.getFamilyGoldMineObj(buddyObj);
      if buddytable ~= nil then
        table.insert(buddylist,buddytable);
      end
    end
    
    return buddylist;
  end
end

function Net.getFamilyGoldMineObj( buddyObj )
  buddyObj =tolua.cast(buddyObj,"MediaObj")
  if buddyObj == nil then
    return nil
  end

  local mem = {};
  mem.number = buddyObj:getByte("number");
  mem.num = buddyObj:getByte("num");
  mem.gold = buddyObj:getInt("gold");
  mem.old_gold = 0;
  mem.gain = buddyObj:getBool("gain");
  
  return mem;
  
end

function Net.sendFamilyOreMining(number)
  local obj = MediaObj:create();
  obj:setByte("number",number);
  print("send number = "..number);
  Net.sendExtensionMessage(obj,"family.oremining");
end

function Net.rec_family_oremining(evt)

  local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
  if ret == 0 then
        gFamilyGoldMineInfo.shovel1 = obj:getByte("shovel1");
        gFamilyGoldMineInfo.shovel2 = obj:getByte("shovel2");
        gFamilyGoldMineInfo.shovel3 = obj:getByte("shovel3");
        gFamilyGoldMineInfo.old_crystal = gFamilyGoldMineInfo.crystal;
        gFamilyGoldMineInfo.crystal = obj:getInt("crystal");
        gFamilyGoldMineInfo.addcry = obj:getBool("addcry");
        gFamilyGoldMineInfo.rate = obj:getInt("rate");
        Net.updateReward(obj:getObj("reward"),2);
        local one_goldmine = Net.getFamilyGoldMineObj(obj:getObj("ore"));

--        echo("update gold mine");
--        print_lua_table(one_goldmine);
        local bFind = false;
        for i,value in ipairs(gFamilyGoldMineInfo.goldminelist) do
          if value.number == one_goldmine.number then
              local old_gold = value.gold;
--                value = one_goldmine;
--                value.old_gold = old_gold;
                bFind = true;
                gFamilyGoldMineInfo.goldminelist[i] = one_goldmine;
                gFamilyGoldMineInfo.goldminelist[i].old_gold = old_gold;
               break;
          end
        end
        
        if bFind == false then
          table.insert(gFamilyGoldMineInfo.goldminelist,one_goldmine);
        end
        
        gDispatchEvt(EVENT_ID_FAMILY_OREWAKUANG,{number=one_goldmine.number});
      -- EventListener:sharedEventListener():handleEvent(c_event_family_goldmine_mining);
      -- EventListener:sharedEventListener():handleEvent(c_event_family_goldmine_refresh_shovelnum);
--      EventListener:sharedEventListener():handleEvent(c_event_ui_role);
  
        if(FamilyOrePanelData.need_dia > 0)then
            -- print("FamilyOrePanelData.need_dia = "..FamilyOrePanelData.need_dia);
            gLogPurchase("family.oremining", 1, FamilyOrePanelData.need_dia);
        end
  end
  
end

function Net.sendFamilyOreGain(number)
  local obj = MediaObj:create();
  obj:setByte("number",number);
  FamilyOrePanelData.number = number;
  Net.sendExtensionMessage(obj,"family.oregain");
end

function Net.rec_family_oregain(evt)

  local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
  if ret == 0 then
    for key,value in ipairs(gFamilyGoldMineInfo.goldminelist) do
        if value.number == FamilyOrePanelData.number then
            value.gain = true;
            break;
        end
    end

     Net.updateReward(obj:getObj("reward"));
     gDispatchEvt(EVENT_ID_FAMILY_OREGET,{number=FamilyOrePanelData.number});
     -- gFamilyInfo.iAddMemexp = obj:getInt("fexp");
     -- gFamilyInfo.iMemexp = gFamilyInfo.iMemexp + gFamilyInfo.iAddMemexp;
     -- gDispatchEvt(EVENT_ID_FAMILY_OREWAKUANG,{number=FamilyOrePanelData.number});
     -- ShowItemPool:shared():pushItem(OPEN_BOX_FAMILY_DEVOTE, gFamilyInfo.iAddMemexp,0);
--     echo("gFamilyInfo.iAddMemexp = "..gFamilyInfo.iAddMemexp);
     -- EventListener:sharedEventListener():handleEvent(c_event_family_goldmine_gain);
     -- EventListener:sharedEventListener():handleEvent(c_event_family_refresh_info);
     -- EventListener:sharedEventListener():handleEvent(c_event_ui_role);
  end
  
end

function Net.sendFamilyOreRank()

  local obj = MediaObj:create();
  Net.sendExtensionMessage(obj,"family.orerank");
  
end

function Net.rec_family_orerank(evt)

  local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
  if ret == 0 then
     
   gFamilyGoldMineRank = {};
    if obj:containsKey("list") then
      local list = obj:getArray("list");
      for i = 0,list:count()-1 do
        local pObj = list:getObj(i);
        if pObj ~= nil then
          local search_family = {};
          pObj =tolua.cast(pObj,"MediaObj")
          search_family.name = pObj:getString("name");
          search_family.num = pObj:getInt("num");
          search_family.luck = pObj:getInt("luck");
          search_family.gold = pObj:getInt("gold");
          search_family.time = pObj:getInt("time");
          table.insert(gFamilyGoldMineRank,search_family);
        end
      end
    end
    
    
        --好友排序
    local function sortWithTime(buddy1,buddy2)
      local lv1 = buddy1.gold;
      local lv2 = buddy2.gold;
      if(lv1 > lv2) then
        return true;
      end
      return false;
    end
      table.sort(gFamilyGoldMineRank,sortWithTime);
          
    Panel.popUp(PANEL_FAMILY_ORE_RECORD);
    -- EventListener:sharedEventListener():handleEvent(c_event_family_goldmine_record);

    
  end
  
end
--军团商店热买列表
CMD_FAMILY_HOTSELL_LIST="family.hslist"
function Net.sendFamilyHotSellList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_FAMILY_HOTSELL_LIST)   
end

function Net.rec_family_hslist(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end


    if obj:containsKey("list") then
        local hostSells = {}
        local list = obj:getArray("list");
        for i = 0,list:count()-1 do
            local hotSellObj = list:getObj(i);
            if hotSellObj ~= nil then
                local hotSellItem = {};
                hotSellObj =tolua.cast(hotSellObj,"MediaObj")
                hotSellItem.dbid = hotSellObj:getLong("dbid")
                hotSellItem.itemid = hotSellObj:getInt("itemid")
                hotSellItem.itemnum = hotSellObj:getInt("itemnum")
                hotSellItem.endtime = hotSellObj:getInt("endtime")
                hotSellItem.curp = hotSellObj:getInt("curp")
                hotSellItem.needp = hotSellObj:getInt("needp")
                hotSellItem.uname = hotSellObj:getString("uname")
                table.insert(hostSells, hotSellItem)
            end
        end

        gDispatchEvt(EVENT_ID_FAMILY_SHOP,{type=4,list=hostSells})
    end
end

--军团商店的加价功能
CMD_FAMILY_HOTSELL_ADDPRICE = "family.hsadd"
function Net.sendFamilyHotSellAddPrice(dbid)
    local obj = MediaObj:create()
    obj:setLong("dbid", dbid)
    Net.sendExtensionMessage(obj, CMD_FAMILY_HOTSELL_ADDPRICE) 
end

function Net.rec_family_hsadd(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Net.updateReward(obj:getObj("reward"),2)

    local hotSellObj = obj:getObj("newinfo")
    if nil ~= hotSellObj then
        hotSellObj =tolua.cast(hotSellObj,"MediaObj")
        local hotSellItem = {};
        hotSellItem.dbid = hotSellObj:getLong("dbid")
        hotSellItem.itemid = hotSellObj:getInt("itemid")
        hotSellItem.itemnum = hotSellObj:getInt("itemnum")
        hotSellItem.endtime = hotSellObj:getInt("endtime")
        hotSellItem.curp = hotSellObj:getInt("curp")
        hotSellItem.needp = hotSellObj:getInt("needp")
        hotSellItem.uname = hotSellObj:getString("uname")
        gDispatchEvt(EVENT_ID_FAMILY_SHOP4_ADD_PRICE,hotSellItem)
    end
end

-- 军团宝物列表
CMD_FAMILY_TREASURE_LIST = "family.trlist"
function Net.sendFamilyTrlist()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_FAMILY_TREASURE_LIST) 
end

function Net.rec_family_trlist(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    if obj:containsKey("list") then
        local treasureList = {}
        local list = obj:getArray("list");
        for i = 0,list:count()-1 do
            local treasureObj = list:getObj(i);
            if treasureObj ~= nil then
                local treasureItem = {};
                treasureObj =tolua.cast(treasureObj,"MediaObj")
                treasureItem.dbid = treasureObj:getLong("dbid")
                treasureItem.type = SHOP_TYPE_FAMILY_5
                treasureItem.itemid = treasureObj:getInt("itemid")
                treasureItem.num = treasureObj:getInt("itemnum")
                -- TODO
                -- treasureItem.limitNum = toint(var.limitcount)
                treasureItem.buyNum   = 0
                treasureItem.price = treasureObj:getInt("curp")
                treasureItem.costType = OPEN_BOX_FAMILY_MONEY
                treasureItem.pos      = treasureItem.dbid
                table.insert(treasureList, treasureItem)
            end
        end

        gDispatchEvt(EVENT_ID_FAMILY_SHOP,{type=5,list=treasureList})
    end
end

-- 军团宝物购买
CMD_FAMILY_TREASURE_BUY = "family.trbuy"
function Net.sendFamilyTreasureBuy(dbid)
    local obj = MediaObj:create()
    -- TODO
    Net.sendFamilyTreasureBuyDbid = dbid
    obj:setLong("dbid", dbid)
    Net.sendExtensionMessage(obj, CMD_FAMILY_TREASURE_BUY) 
end

function Net.rec_family_trbuy(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    gDispatchEvt(EVENT_ID_SHOP_REFRESH, Net.sendFamilyTreasureBuyDbid)--obj:getLong("dbid"))
end


CMD_FAMILY_DONATE_LIST = "family.donlist"
CMD_FAMILY_DONATE_ASK = "family.donask"
CMD_FAMILY_DONATE_DONATE = "family.dondonate"
CMD_FAMILY_DONATE_HELP = "family.donhelp"

function Net.sendFamilyDonateList()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_FAMILY_DONATE_LIST) 
end
function Net.rec_family_donlist(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end

    Data.donateList = {}
    Data.donateList.donNum = obj:getInt("donate")
    Data.donateList.atime = obj:getInt("atime")
    if obj:containsKey("list") then
        Data.donateList.list = {}
        local list = obj:getArray("list");
        for i = 0,list:count()-1 do
            local donateObj = list:getObj(i);
            if donateObj ~= nil then
                local donateItem = {};
                donateObj =tolua.cast(donateObj,"MediaObj")
                donateItem.id = donateObj:getLong("id")
                donateItem.userid = donateObj:getLong("userid")
                donateItem.type = donateObj:getByte("type")
                donateItem.uName = donateObj:getString("name")
                donateItem.itemid = donateObj:getInt("itemid")
                donateItem.itemnum = donateObj:getInt("itemnum")
                donateItem.time = donateObj:getInt("time")
                donateItem.itemtype = donateObj:getByte("itemtype")
                donateItem.donate = donateObj:getInt("donate") -- 给这条捐献次数
                table.insert(Data.donateList.list, donateItem)
            end
        end
        gDispatchEvt(EVENT_ID_FAMILY_DONATE_LIST)
    end

end

function Net.sendFamilyDonateAsk(itemid)
    local obj = MediaObj:create()
    obj:setInt("itemid", itemid)
    Net.sendExtensionMessage(obj, CMD_FAMILY_DONATE_ASK) 
end
function Net.rec_family_donask(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        return
    end
    Data.redpos.bolFamilyDonate = false
    Net.sendFamilyDonateList()

end

function Net.sendFamilyDonateDonate(id)
    local obj = MediaObj:create()
    obj:setLong("id", id)
    Net.sendExtensionMessage(obj, CMD_FAMILY_DONATE_DONATE) 
end
function Net.rec_family_dondonate(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        Net.sendFamilyDonateList()
        return
    end
    Net.updateReward(obj:getObj("reward"),2)
    Net.sendFamilyDonateList()
end

function Net.sendFamilyDonateHelp(id)
    local obj = MediaObj:create()
    obj:setLong("id", id)
    Net.sendExtensionMessage(obj, CMD_FAMILY_DONATE_HELP) 
end
function Net.rec_family_donhelp(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret ~= 0 then
        Net.sendFamilyDonateList()
        return
    end
    gDispatchEvt(EVENT_ID_FAMILY_DONATE_HELP)
end
