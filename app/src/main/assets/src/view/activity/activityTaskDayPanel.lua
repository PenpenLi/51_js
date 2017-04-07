local ActivityTaskDayPanel=class("ActivityTaskDayPanel",UILayer)

function ActivityTaskDayPanel:ctor(data)
    -- self.appearType = 1;
    -- self._panelTop = true;
    self:init("ui/new_task/ui_hd_taskday.map")
    -- self:onDay(1);
    self.curDay = 1;
    -- self.init = true;

    self.leftDay = 0;
    self.today = 1;
    self.preDay = 0;
    self.reLayout = true;
    self.preTimeStatue = 0;
    self:getNode("scroll"):setVisible(false);

  local function onNodeEvent(event)
      if event == "enter" then
          self:onEnter();
      end
  end
  self:registerScriptHandler(onNodeEvent);

  -- self:setTodayFlag();
  -- if(self.today>=4)then
  --     self:getNode("scroll"):moveItemByIndex(1);
  -- end
  Net.sendDaytActList();
    -- self:initPanel();

end

function ActivityTaskDayPanel:setTodayFlag()
    print("self.today = "..self.today);
    for i = 1,7 do
        self:getNode("flag_today"..i):setVisible(false);
    end
    self:getNode("flag_today"..self.today):setVisible(true);
end

function ActivityTaskDayPanel:onEnter()
    self:onDay(self.today);
end

function ActivityTaskDayPanel:onPopback()
    Scene.clearLazyFunc("achieveItem");
end

function ActivityTaskDayPanel:onPopup()
    print("ActivityTaskDayPanel:onPopup");
    -- if(not self.init) then
        Net.sendDaytActList();
    -- end
    -- self.init = false;
end

function ActivityTaskDayPanel:initAchieve()

    self.allTask = {}
    for key,task in pairs(daytaskact_db)do
        local data = {};
        data.task = task;
        -- data.curlv = self.curDayAchieve[index].curlv;
        data.achId = toint(task.achieveid);
        data.curp = 0;
        data.canGet = false;--是否可以领取
        -- data.isGet = false;--是否领取过了
        data.gtime = 0;

        for key,var in pairs(Data.activityDayTasks.list) do
            if(var.day == toint(task.daylimit) and var.id == toint(task.taskid))then
                data.curp = var.curp;
                data.gtime = var.gtime;
            end
        end
        local bAdd = true
        if isBanshuUser() and toint(task.taskid)==20 then
            bAdd = false;
        end

        if bAdd then
            table.insert(self.allTask,data);
        end
    end

    -- print_lua_table(self.allTask);

end


function ActivityTaskDayPanel:setDayData(day)
    -- print("setDayData(day) = "..day);
    if(self.curDay == day)then
        return;
    end

    self.curDayAchieve = {};
    self.curDay = day;
    
    if(self.allTask==nil)then
        return
    end
    
    for key,ach in pairs(self.allTask) do
        if (toint(ach.task.daylimit) % 10 == day) then
            table.insert(self.curDayAchieve,ach);
        end
    end

    self:getNode("scroll_achieve"):clear()
    for key, var in pairs(self.curDayAchieve) do
        local item=ActivityTaskDayItem.new()
        if toint(key) < 6 then
            item:setAchieveData(var,self.today>=self.curDay,self.curDay) 
        else
            item:setLazyAchieveData(var,self.today>=self.curDay,self.curDay) 
        end
        self:getNode("scroll_achieve"):addItem(item)
    end
    self:getNode("scroll_achieve"):layout()

    self:dealRedDotAchieve();
end

function ActivityTaskDayPanel:dealRedDotAchieve()
    -- body
    Data.redpos.bolActivityDayTaskCanGet = false;

    for key,var in pairs(Data.redpos.bolActivityDayTask) do
        -- var = false;
        Data.redpos.bolActivityDayTask[key] = false;
    end
    local index = -1;
    for key,ach in pairs(self.allTask) do
        if(ach.curp >= ach.task.num and ach.gtime <= 0) then
            index = ach.task.daylimit;
            if(self.today >= index)then
                Data.redpos.bolActivityDayTask[index] = true;
                Data.redpos.bolActivityDayTaskCanGet = true;
            end
        end
    end

    -- for key,var in pairs(Data.redpos.bol7DayTaskLabel) do
    --     -- var = false;
    --     Data.redpos.bol7DayTaskLabel[key] = false;
    -- end
    -- -- print_lua_table(self.curDayAchieve);
    -- -- print_lua_table(Data.redpos.bol7DayTaskLabel);
    -- for key,ach in pairs(self.curDayAchieve) do
    --     if(ach.canGet and not ach.isGet) then
    --         index = ach.achId % 10;
    --         if(self.today >= index)then
    --             Data.redpos.bol7DayTaskLabel[ach.labelIndex] = true;
    --             Data.redpos.bolNewTask = true;
    --         end
    --     end
    -- end

end

function ActivityTaskDayPanel:refreshCurDay()
    local curDay = self.curDay;
    self.curDay = -1;
    self:setDayData(curDay);    
end

function ActivityTaskDayPanel:refreshTodayFlag()

    self:getNode("scroll"):layout();
    self:getNode("scroll"):setVisible(true);

    self.today = Data.activityDayTasks.today;
    if(self.today == 0)then
        self.today = 7;
    end
    -- print("today = "..self.today);

    if(self.today>7)then
        self.today = 7;
    end

    self:setTodayFlag();
    if(self.today>=4)then
      self:getNode("scroll"):moveItemByIndex(1);
    end

    self.curDay = self.today;
    self:onDay(self.today);
end

function ActivityTaskDayPanel:initPanel()

    self:refreshTodayFlag();

    self:initAchieve();

    self:refreshCurDay();

end

-- function  ActivityTaskDayPanel:events()
--     return {
--     EVENT_ID_REFRESH_ACTIVITY_DAYTASK,
--     EVENT_ID_GET_ACTIVITY_DAYTASK
--     }
-- end

function ActivityTaskDayPanel:dealEvent(event,param)
    if(event==EVENT_ID_REFRESH_ACTIVITY_DAYTASK)then
        self:initPanel();

    elseif(event == EVENT_ID_GET_ACTIVITY_DAYTASK) then
        self:initAchieve();
        self:refreshCurDay();
        -- self:refreshCurDayLabel();
    end
end

function ActivityTaskDayPanel:resetBtnTexture()
    local btns={
        "day1",
        "day2",
        "day3",
        "day4",
        "day5",
        "day6",
        "day7",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end
end

function ActivityTaskDayPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture(name,"images/ui_public1/button_s2-1.png")
end

function ActivityTaskDayPanel:onDay(day)
    self:setDayData(day);
    self:selectBtn("day"..day)

    for i=1,7 do
        self:getNode("flag_arrow"..i):setVisible(false);
    end
    self:getNode("flag_arrow"..day):setVisible(true);
    -- local pos = cc.p(gGetPositionByAnchorInDesNode(self:getNode("flag_arrow"):getParent(),self:getNode("day"..day),cc.p(1.0,0.5)));
    -- self:getNode("flag_arrow"):setPositionY(pos.y);    
end

function ActivityTaskDayPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="day1"then
        self:onDay(1);
    elseif  target.touchName=="day2"then
        self:onDay(2);
    elseif  target.touchName=="day3"then
        self:onDay(3);
    elseif  target.touchName=="day4"then
        self:onDay(4);
    elseif  target.touchName=="day5"then
        self:onDay(5);
    elseif  target.touchName=="day6"then
        self:onDay(6);
    elseif  target.touchName=="day7"then
        self:onDay(7);   
    end
end

return ActivityTaskDayPanel