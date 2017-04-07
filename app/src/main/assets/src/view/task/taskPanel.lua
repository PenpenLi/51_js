local TaskPanel=class("TaskPanel",UILayer)

TaskPanelData = {};
TaskPanelData.getEnergyTaskIds = {25,26,27};
TaskPanelData.energyTaskId = 0;

function TaskPanel:ctor(type,data)

    self:init("ui/ui_task.map")
    self:getNode("empty_layer"):setVisible(false)
    self:getNode("scroll_achieve").eachLineNum=1
    self:getNode("scroll_achieve"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self:getNode("scroll_task").eachLineNum=1
    self:getNode("scroll_task"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    -- self:getTask()
    self.type = type;
    if type == 1 then
        self:initTask(data);
        self:getTask();
    elseif type == 2 then
        self.achieve = data;
        self:getAchieve();
    end
    -- self.popBack = false;
    TaskPanelData.bNeedRefresh = false;
end

function TaskPanel:onPopback()
    -- self.popBack = true;
    Scene.clearLazyFunc("taskItem");
    Scene.clearLazyFunc("achieveItem");
end

function TaskPanel:onPopup()
    if(TaskPanelData.bNeedRefresh) then
        if self.type == 1 then
            -- self.task = nil;
            Net.sendDayTaskList();
        elseif self.type == 2 then
            -- self.achieve = nil;
            Net.sendAchieveList();
        end
        
        if(not Guide.isInGuiding(GUIDE_ID_ENTER_TASK2))then
            self:getNode("scroll_task"):setTouchEnable(true);
        end
    end
end

function  TaskPanel:initAchieve()

    Scene.clearLazyFunc("taskItem");
    Scene.clearLazyFunc("achieveItem");

    if(self.achieve==nil)then
        return
    end

    self:processUnfinishAppStoreGood()
    local function sortWithLv(buddy1,buddy2)
      if(buddy1.sort > buddy2.sort) then
        return true;
      end
      return false;
    end
    table.sort(self.achieve,sortWithLv);


    self:getNode("scroll_achieve"):clear()
    -- print_lua_table(self.achieve);
    for key, var in pairs(self.achieve) do
        if not self:skipAddAchiveList(var) then
            local item=TaskItem.new()
            if key < 6 then
                item:setAchieveData(var) 
            else
                item:setLazyAchieveData(var) 
            end
            self:getNode("scroll_achieve"):addItem(item)
        end
    end
    self:getNode("scroll_achieve"):layout()
end

function TaskPanel:removeAchieveData( id )
    -- body
    if self.achieve == nil then
        return -1;
    end

    local index = 0;
    for key,var in pairs(self.achieve) do
        if var.achId == id then
            table.remove(self.achieve,key);
            return index;
        end
        index = index + 1;
    end
    return -1;
end

function TaskPanel:removeAchieve(index)
    self:getNode("scroll_achieve"):removeItemByIndex(index);

end

function TaskPanel:addNewAchieve( data )
    -- body
    local item = TaskItem.new();
    item:setAchieveData(data);
    if data.bolGet then
        self:getNode("scroll_achieve"):insertItem(item);
    else
        self:getNode("scroll_achieve"):addItem(item);
    end
    self:getNode("scroll_achieve"):layout();
end

function  TaskPanel:initTask(task)
    if(self.task~=nil)then
        return;
    end
    self.task = task;
    self:filterTask();

    self.totalPoint=0
    self.curPoint=0
    -- self.totalPoint,self.curPoint = self:createTaskList();
    self:countPoint();
    self:initTaskActive();
    self:refreshActiveBar();
end

function TaskPanel:filterTask()

    local filter = {
        {2,SYS_ELITE_ATLAS},
        {4,SYS_ARENA},
        {5,SYS_ARENA},
        {14,SYS_FRIEND},
        {16,SYS_ACT},
        {17,SYS_SKILL},
        {20,SYS_XUNXIAN},
        {28,SYS_TRAINROOM},
        {29,SYS_BATH},
        {30,SYS_FAMILY},
        {31,SYS_PET_TOWER},
        {32,SYS_SERVER_BATTLE},
        {41,SYS_BOSS_ATLAS},
        {43,SYS_TOWER},
    };

    for index,sys in pairs(filter)do
        for key,var in pairs(self.task)do
            if(var.dayid == sys[1] and Unlock.isUnlock(sys[2],false) == false)then
                table.remove(self.task,key);
                break;
            end
        end
    end

end


function TaskPanel:countPoint()
    -- body
    self.curPoint = 0;
    local maxPoint = 0;
    for key, var in pairs(self.task) do
        if(var.status==2)then
            local taskDB=DB.getDayTask(var.dayid)
            if(taskDB)then
                self.curPoint=self.curPoint+taskDB.point
                -- totalPoint=totalPoint+taskDB.point
            end
        end
        if var.dayid == 104 then
            maxPoint = var.curp;
        end
    end

    if self.curPoint < maxPoint then
        self.curPoint = maxPoint;
    end
end

function TaskPanel:initTaskActive()

    self.activeTaskIds = {101,102,103,104};

    local taskDB=DB.getDayTask(self.activeTaskIds[4]);
    if taskDB then
        if self.totalPoint < taskDB.num + 0 then
            self.totalPoint = taskDB.num + 0;
        end
    end
    -- print("totalPoint = "..self.totalPoint);
    self.bar = self:getNode("bar");

    local width = self.bar:getContentSize().width;
    local barStartX = self.bar:getPositionX() - (1-self.bar:getAnchorPoint().x) * width;
    -- print("start x = "..barStartX);
    for key,var in pairs(self.activeTaskIds) do
        local taskDB=DB.getDayTask(var);
        local per = taskDB.num / self.totalPoint;
        -- print("num = "..taskDB.num);
        -- print("per = "..per);
        self:getNode("flag_point"..key):setPositionX(barStartX + per*width);
        self:setLabelString("txt_point"..key,taskDB.num);
    end


end

function TaskPanel:isInTaskActive(taskid)
    for key,var in pairs(self.activeTaskIds) do
        if(var == taskid)then
            return true;
        end
    end
    return false;
end

function TaskPanel:refreshActiveBar()
    -- body
    local per=self.curPoint/self.totalPoint;
    self:setBarPer("bar",per)

    self:setLabelString("txt_curpoint",self.curPoint);

    for key,var in pairs(self.activeTaskIds) do
        for i,value in pairs(self.task) do
            if value.dayid == var then
                if value.status == 2 then
                    self:getNode("btn_box"..key):playAction("ui_atlas_box_3");
                    -- return true;
                    -- self:setTouchEnable("btn_box"..key,false,false);
                elseif value.status == 1 then
                    self:getNode("btn_box"..key):playAction("ui_atlas_box_2");
                    -- return false;    
                end
            end
        end
    end
end

function TaskPanel:sortTask()
    local sortidForComplete = 200;
    local sortidForUnComplete = 50;
    local sortidForEnargy = 100
    local sortidForGeted = 0;
    for key,task in pairs(self.task) do
        if(task.status == 1)then
            task.sortid = sortidForComplete;
            sortidForComplete = sortidForComplete - 1;
        elseif(task.status == 2)then
            task.sortid = sortidForGeted;
            sortidForGeted = sortidForGeted -1;    
        elseif(task.status == 3)then
            task.sortid = sortidForEnargy;
            sortidForEnargy = sortidForEnargy - 1;
        elseif(task.dayid == 15)then
            task.sortid = 51;
        elseif(task.dayid == 44)then
            task.sortid = 80;
        else
            task.sortid = sortidForUnComplete;
            sortidForUnComplete = sortidForUnComplete - 1;    
        end
    end

    if(Guide.isInGuiding(GUIDE_ID_ENTER_TASK1))then
        for key,var in pairs(self.task) do
            if var.dayid == 1 then
                self.task[key].sortid = 1000;
                break;
            end
        end
    end
    
    local function sortWithLv(buddy1,buddy2)
      -- local lv1 = buddy1.status;
      -- local lv2 = buddy2.status;
      if(buddy1.sortid > buddy2.sortid)then
        return true  
      end
      return false;
    end
    table.sort(self.task,sortWithLv);
end

function TaskPanel:createTaskList()
    -- body
    -- print_lua_table(self.task);
    Scene.clearLazyFunc("taskItem");
    Scene.clearLazyFunc("achieveItem");


    self:sortTask();
    -- local function sortWithLv(buddy1,buddy2)
    --   -- local lv1 = buddy1.status;
    --   -- local lv2 = buddy2.status;
    --   if(buddy1.sortid > buddy2.sortid)then
    --     return true  
    --   end
    --   return false;
    -- end
    -- table.sort(self.task,sortWithLv);
    -- print_lua_table(self.task);

    self:getNode("scroll_task"):clear()
    local index = 0;
    for key, var in pairs(self.task) do
        if(var.status~=2 or toint(var.dayid) == 15 or toint(var.dayid) == 21)then
            local taskDB=DB.getDayTask(var.dayid);
            if taskDB and not self:isInTaskActive(var.dayid) then
                local item=TaskItem.new()
                if index < 6 then
                    item:setTaskData(var,taskDB) 
                else
                    item:setLazyTaskData(var,taskDB);
                end
                local bAdd = true;
                if isBanshuUser() then
                    if var.dayid==20 or var.dayid==41 then
                        bAdd = false;
                    end
                end
                if bAdd then
                    self:getNode("scroll_task"):addItem(item)
                    index = index + 1;
                end
                
            end
        end
    end
    self:getNode("scroll_task"):layout()
end

function TaskPanel:completeTask(taskid)

    self:completeDayEnergyTask(taskid);
    -- for key,var in pairs(TaskPanelData.getEnergyTaskIds) do
    --     if var == taskid then
    --         Data.redpos.bolDayEnergy = false;
    --         break;
    --     end
    -- end

    for key,var in pairs(self.task) do
        if var.dayid == taskid then
            var.status = 2;
            local taskDB=DB.getDayTask(taskid);
            self.curPoint=self.curPoint+taskDB.point;
            break;
        end
    end

    for key,var in pairs(self.activeTaskIds) do
        for i,value in pairs(self.task) do
            if value.dayid == var then
                local taskDB=DB.getDayTask(var);
                if value.status == 0 and self.curPoint >= taskDB.num then
                    value.status = 1;
                    value.curp = self.curPoint;
                    break;
                end
            end
        end
    end

    self:refreshActiveBar();
end

function TaskPanel:completeDayEnergyTask(taskid)

    for key,var in pairs(TaskPanelData.getEnergyTaskIds) do
        if var == taskid then
            Data.redpos.bolDayEnergy = false;
            -- print("false");

            local curServerTime = gGetCurServerTime();
            for key,var in pairs(Data.task.getEnergyTime) do
                if (gGetHourByTime(curServerTime) >= toint(var.time[1]) and gGetHourByTime(curServerTime) < toint(var.time[2])) then
                    var.hasGet = not Data.redpos.bolDayEnergy;
                    -- print("get it!");
                end
            end

            break;
        end
    end

    -- print_lua_table(Data.task.getEnergyTime);
end

function TaskPanel:dealRedDot()
    -- body
    for key,var in pairs(self.task) do
        -- print("dayid = "..var.dayid);
        -- print("curp = "..var.curp);
        -- print("status = "..var.status);
        local taskDB=DB.getDayTask(var.dayid);
        -- if(taskDB)then
        --     print("taskDB.num="..taskDB.num)
        -- end
        if(taskDB and var.curp >= taskDB.num and var.status ~= 2 and var.status<3) then
            Data.redpos.bolDayTask = true;
            return;
        end
    end    
    Data.redpos.bolDayTask = false;
    -- print("-------00000000--------")
end

function TaskPanel:dealRedDotAchieve()
    -- body
    for key,var in pairs(self.achieve) do
        if(var.bolGet) then
            Data.redpos.bolAchieve = true;
            return;
        end
    end    
    Data.redpos.bolAchieve = false;
end

function  TaskPanel:getAchieve()
    if(self.achieve==nil)then
        Net.sendAchieveList()
    else
        self:initAchieve()
    end
    self:selectBtn("btn_type2")
    self:getNode("panel_achieve"):setVisible(true)
    self:getNode("panel_task"):setVisible(false)
end


function  TaskPanel:getTask()
    if(self.task==nil)then
        Net.sendDayTaskList()
    else 
        self:createTaskList();
    end
    self:selectBtn("btn_type1")
    self:getNode("panel_achieve"):setVisible(false)
    self:getNode("panel_task"):setVisible(true)
end

function  TaskPanel:events()
    return {
    EVENT_ID_TASK_REFRESH_LIST,
    EVENT_ID_ACHIEVE_LIST,
    EVENT_ID_ACHIEVE_GET,
    EVENT_ID_TASK_GET,
    EVENT_ID_FINISH_APPSTORE_GOOD}
end

function TaskPanel:refreshTaskData(list)
    -- body
    self.task = list;
    self:filterTask();
    self:createTaskList();
end

function TaskPanel:addNewTask(newTask)
    table.insert(self.task,newTask);
    self:createTaskList();
end


function TaskPanel:dealEvent(event,param)
    if(event==EVENT_ID_TASK_REFRESH_LIST)then
        self:refreshTaskData(param);
    elseif(event==EVENT_ID_ACHIEVE_LIST)then
        self.achieve=param
        if(self:getNode("panel_achieve"):isVisible())then
            self:initAchieve()
        end
        self:dealRedDotAchieve();
    elseif(event == EVENT_ID_ACHIEVE_GET) then
        local index = self:removeAchieveData(param.remove_id);
        if param.new_data then
            table.insert(self.achieve,param.new_data);
            self:initAchieve();
            -- self:addNewAchieve(param.new_data);
        else
            self:removeAchieve(index); 
        end
        self:dealRedDotAchieve();
    elseif(event == EVENT_ID_TASK_GET) then
        self:completeTask(param.id);
        if param.newTask then
            table.insert(self.task,param.newTask);
        end
        if param.changeTask then
            for key,var in pairs(self.task) do
                if var.dayid == param.changeTask.dayid then
                    var.status = param.changeTask.status;
                    var.curp = param.changeTask.curp;
                    break;
                end
            end
        end
        self:dealRedDot();
        self:createTaskList();
    elseif(event == EVENT_ID_FINISH_APPSTORE_GOOD) then
        self:setAppStoreGoodFinish()
    end
end



function TaskPanel:resetBtnTexture()
    local btns={
        "btn_type1",
        "btn_type2",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function TaskPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function TaskPanel:onBox(type)
    --四个活跃度活动
    local taskid = {101,102,103,104};
    local taskDB=DB.getDayTask(taskid[type])
    if(taskDB) then
        for key, var in pairs(self.task) do
            if(var.dayid == taskid[type])then
                Panel.popUpVisible(PANEL_TASK_REWARDBOX,taskDB,var.status);
            end
        end
        
    end
    
end

function TaskPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_type1"then
        if(self.type ~= 1)then
            self:getTask()
            self.type = 1;
        end
    elseif  target.touchName=="btn_type2"then
        if(self.type ~= 2)then
            self:getAchieve()
            self.type = 2;
        end
    elseif target.touchName == "btn_box1" then
        self:onBox(1);    
    elseif target.touchName == "btn_box2" then
        self:onBox(2);        
    elseif target.touchName == "btn_box3" then
        self:onBox(3);        
    elseif target.touchName == "btn_box4" then
        self:onBox(4);        
    end
end

function TaskPanel:skipAddAchiveList(achiveData)
    if achiveData.achId == ACHIEVE_ID_APPSTORE_GOOD then
        if  Module.isClose(SWITCH_APPSTORE_GOOD) then
            return true
        end

        if nil ~= gAccount and (gAccount:getPlatformId() ~= CHANNEL_APPSTORE or gAccount:getPlatformId() == CHANNEL_IOS_JIURU or gAccount:getPlatformId() == CHANNEL_IOS_JITUO) then
            return true
        end

        -- local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        -- if targetPlatform ~= cc.PLATFORM_OS_IPHONE and targetPlatform ~= cc.PLATFORM_OS_IPAD then
        --    return true
        -- end
    end

    return false
end

function TaskPanel:processUnfinishAppStoreGood()
    if self.achieve == nil then
        return
    end

    for _,var in pairs(self.achieve) do
        if var.achId == ACHIEVE_ID_APPSTORE_GOOD and var.sort == 0 then
            var.sort = 0.5
            break
        end
    end
end

function TaskPanel:setAppStoreGoodFinish()
    -- body
    local size = self:getNode("scroll_achieve"):getSize()
    for i = 1, size do
        local item = self:getNode("scroll_achieve"):getItem(i - 1)
        if nil ~= item and nil ~= item.curAchieveData and item.curAchieveData.achId == ACHIEVE_ID_APPSTORE_GOOD then
            item:setAppStoreGoodFinish()
        end
    end
end

return TaskPanel