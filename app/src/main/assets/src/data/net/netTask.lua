
function Net.sendAchieveList(seven,is7Day,actype)

    local media=MediaObj:create()
    if(seven)then
        media:setBool("seven",seven);
    end
    if actype then
        media:setByte("actype",actype);
    end
    Task7DayPanel.is7Day = false;
    if(is7Day)then
        Task7DayPanel.is7Day = is7Day;
    end
    Net.sendExtensionMessage(media, CMD_ACHIEVE_LIST)
end

function Net.recAchieveList(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local achieveList=obj:getArray("list")
    if(achieveList)then
        achieveList=tolua.cast(achieveList,"MediaArray")
        for i=0, achieveList:count()-1 do
            table.insert(ret,Net.parseAchieveObj(achieveList:getObj(i)))
        end
    end
    if(Task7DayPanel.is7Day)then
        if Panel.isTopPanel(PANEL_TASK7DAY) then
            gDispatchEvt(EVENT_ID_ACHIEVE_LIST,ret)
        else
            gDispatchEvt(EVENT_ID_ENTER_7DAY,ret)
        end
    else
        gDispatchEvt(EVENT_ID_ACHIEVE_LIST,ret)
    end
    Task7DayPanel.is7Day = false;
end


function Net.sendAchieveGet( id)
    local obj=MediaObj:create()
    obj:setInt("id", toint(id))
    Net.sendExtensionMessage(obj, CMD_ACHIEVE_GET)
end


function Net.recAchieveGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")==0)then
        -- return
        Net.updateReward(obj:getObj("reward"),2);
        Net.parseUserInfo(obj:getObj("uvobj"));

        local id = obj:getInt("id");
        local data = {};
        data.remove_id = id;
        if obj:containsKey("new") then
            data.new_data = Net.parseAchieveObj(obj:getObj("new"));
        end
        gDispatchEvt(EVENT_ID_ACHIEVE_GET,data);   
        -- print("recAchieveGet");
        -- print_lua_table(data);     
    end
end

function Net.sendDayTaskList()

    local media=MediaObj:create()
    Net.sendExtensionMessage(media, CMD_DAYTASK_LIST)
end

function Net.recDayTaskList(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    local ret={}
    local taskList=obj:getArray("list")
    if(taskList)then
        taskList=tolua.cast(taskList,"MediaArray")
        for i=0, taskList:count()-1 do
            local task = Net.parseTaskObj(taskList:getObj(i));
            task.sortid = i;
            table.insert(ret,task)
        end

        -- local sortidForComplete = 100;
        -- local sortidForUnComplete = 50;
        -- local sortidForGeted = 0;
        -- for key,task in pairs(ret) do
        --     if(task.status == 1)then
        --         task.sortid = sortidForComplete;
        --         sortidForComplete = sortidForComplete - 1;
        --     elseif(task.status == 2)then
        --         task.sortid = sortidForGeted;
        --         sortidForGeted = sortidForGeted -1;    
        --     elseif(task.dayid == 15)then
        --         task.sortid = 51;
        --     else
        --         task.sortid = sortidForUnComplete;
        --         sortidForUnComplete = sortidForUnComplete - 1;    
        --     end
        -- end
    end

    if Panel.isTopPanel(PANEL_TASK) then
        gDispatchEvt(EVENT_ID_TASK_REFRESH_LIST,ret)
    else
        gDispatchEvt(EVENT_ID_TASK_LIST,ret)
    end
    
    
end



function Net.sendDayTaskGet(id)
    Data.task.pid = id
    local obj=MediaObj:create()
    obj:setInt("id", toint(id))
    Net.sendExtensionMessage(obj, CMD_DAYTASK_GET)
    if (TalkingDataGA) then
        local param = {}
        -- table.insert(param, {id=tostring(self.curActData)})
        param["id"] = tostring(id)
        gLogEvent("daytask_get",param)
    end
end


function Net.recDayTaskGet(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")==0)then
        -- return
        Net.updateReward(obj:getObj("reward"),2);
        Net.parseUserInfo(obj:getObj("uvobj"));
        
        local ret = {}
        ret.id = obj:getInt("id");

        if obj:containsKey("newtask") then
            ret.newTask = Net.parseTaskObj(obj:getObj("newtask"));
        end

        if (obj:containsKey("changetask")) then
            ret.changeTask = Net.parseTaskObj(obj:getObj("changetask"));
        end

        gDispatchEvt(EVENT_ID_TASK_GET,ret); 


    -- int id = obj->getInt("id");
    -- int index = 0;
    -- int size = DataBase::shared()->m_dayTaskInfo.m_vDayTaskList.size();
    -- for(int i = 0;i < size;i++) {
    --     DayTaskOne* oneItem = &DataBase::shared()->m_dayTaskInfo.m_vDayTaskList.at(i);
    --     if (oneItem->dayId == id) {
    --         oneItem->status = 2;
    --         index = i;
    --         break;
    --     }
    -- }
    -- dealRedDot_DayTask();
    -- sortDayTaskList();
    -- updateRewardInfo(obj->getObj("reward"));
    -- updateUserInfo(obj->getObj("uvobj"));
    -- EventListener::sharedEventListener()->handleEvent(c_event_redDot_DayTask);
    -- EventListener::sharedEventListener()->handleEvent(c_event_dayTask_get,(void*)index);

    end
end

CMD_ACHIEVE_FINISH_APPSTORE_GOOD = "achi.fapp"
function Net.sendAchiFapp()
    local obj=MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_ACHIEVE_FINISH_APPSTORE_GOOD)
end

function Net.rec_achi_fapp(evt)
    local obj = evt.params:getObj("params")
    if obj:getByte("ret") ~= 0 then
        return
    end
    Data.appsComment = true
    gDispatchEvt(EVENT_ID_FINISH_APPSTORE_GOOD)
end


