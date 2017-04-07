local Task7DayPanel=class("Task7DayPanel",UILayer)
Task7DayPanel.refreshLabel = false;
function Task7DayPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/new_task/ui_task7day.map")
    -- self:onDay(1);
    self.curDay = 1;
    self.curDayLabel = 1;
    self.init = true;

    self.leftDay = 0;
    self.today = 1;
    self.preDay = 0;
    self.reLayout = true;
    self.preTimeStatue = 0;
    self.leftDay = gGetDayByLeftTime(Data.task7Day.lefttime - gGetCurServerTime());
    self.today = 7 - self.leftDay;
    local function updateTime()
        self.leftDay = gGetDayByLeftTime(Data.task7Day.lefttime - gGetCurServerTime());
        if(self.leftDay > 0)then
            self:replaceLabelString("txt_day",self.leftDay);
            self:getNode("txt_day"):setVisible(true);
            self.preTimeStatue = 1; 
        else
            self:getNode("txt_day"):setVisible(false);
            if(self.preTimeStatue ~= 2)then
                self.reLayout = true;
            end
            self.preTimeStatue = 2; 
        end
        if(Data.task7Day.lefttime>gGetCurServerTime())then
            self:setLabelString("txt_refresh_time2", gParserHourTime(Data.task7Day.lefttime - gGetCurServerTime() - self.leftDay*24*60*60))
        end
        self.today = 7 - self.leftDay;
        if(self.preDay ~= self.today)then
            self.preDay = self.today;

            -- local curDay = self.curDay;
            -- self.curDay = -1;
            -- self:setDayData(curDay);
            self:setTodayFlag();
        end
        -- print("aaaaaa self.today = "..self.today);
        if(self.reLayout)then
            -- print("#############");
            self.reLayout = false;
            self:getNode("layout_time"):layout();
        end
    end
    self:scheduleUpdate(updateTime,1)
    self:getNode("scroll"):layout();

  local function onNodeEvent(event)
      if event == "enter" then
          self:onEnter();
      elseif event == "exit" then
          self:onExit();    
      end
  end
  self:registerScriptHandler(onNodeEvent);

  self:setTodayFlag();
  if(self.today>=4)then
      self:getNode("scroll"):moveItemByIndex(1);
  end

  if(data)then
    self:initPanel(data);
  end
    -- if(table.getn(gGiftBagBuy)==0)then
    --     Net.sendGiftInit()
    -- end
end

function Task7DayPanel:setTodayFlag()
    for i = 1,7 do
        self:getNode("flag_today"..i):setVisible(false);
    end
    self:getNode("flag_today"..self.today):setVisible(true);
end

function Task7DayPanel:onEnter()
    self:onDay(self.today);
end

function Task7DayPanel:onExit()
    self:unscheduleUpdateEx();
end

function Task7DayPanel:onPopback()
    Scene.clearLazyFunc("achieveItem");
end

function Task7DayPanel:onPopup()
    if(not self.init) then
        Net.sendAchieveList(true,true);
        Task7DayPanel.refreshLabel = true;
    end
    self.init = false;
end

function Task7DayPanel:initAchieve()

    if(self.achieve==nil)then
        return
    end

    self.allAchieve = {}
    for key,achieve in pairs(achieve_db)do
        -- if(toint(achieve.achieveid) > 710)then
        for k,achId in pairs(Data.task7Day.taskid) do
            if(toint(achieve.achieveid) == toint(achId)) then
                local data = {};
                data.achieve = achieve;
                -- data.curlv = self.curDayAchieve[index].curlv;
                data.achId = toint(achieve.achieveid);
                data.curp = 0;
                data.canGet = false;--是否可以领取
                data.isGet = true;--是否领取过了
                table.insert(self.allAchieve,data);
            end
        end
    end

    -- print_lua_table(self.achieve);

    for key,ach in pairs(self.achieve)do
        for index,showAch in pairs(self.allAchieve) do
            if(ach.achId == toint(showAch.achId))then

                showAch.curp = ach.curp;

                if(ach.curlv > toint(showAch.achieve.level))then
                    --已领取
                    showAch.isGet = true;
                    -- print("isGet = true");
                    -- print_lua_table(showAch);
                    -- print("isGet = true end---------");
                else
                    showAch.isGet = false;
                end

                if(ach.curlv == toint(showAch.achieve.level))then
                    showAch.canGet = ach.bolGet;
                end

            end
        end
    end

    self.allGifts = {}
    for key,gift in pairs(gift_common_db) do
        if(toint(gift.status) == 77)then
            local ret = {};
            ret.data = gift;
            table.insert(self.allGifts,ret);
        end
    end
    -- print("show self.allGifts -----------")
    -- print_lua_table(self.allGifts);
    -- print("show self.allGifts +++++++++++")

    -- print("show self.allAchieve -----------")
    -- print_lua_table(self.allAchieve);
    -- print("show self.allAchieve +++++++++++")
    -- print_lua_table(self.achieve);

    -- local curDay = self.curDay;
    -- self.curDay = -1;
    -- self:setDayData(curDay);

end


function Task7DayPanel:setDayData(day,dayLabelIndex)

    if(self.curDay == day)then
        return;
    end

    if(dayLabelIndex == nil)then
        dayLabelIndex = 1;
    end

    self.curDayAchieve = {};
    self.curDay = day;
    
    if(self.allAchieve==nil)then
        return
    end
    
    for key,ach in pairs(self.allAchieve) do
        if (ach.achieve.achieveid % 10 == day) then
            table.insert(self.curDayAchieve,ach);
        end
    end

    --归类
    local class = {};
    local isHas = false;
    for key,ach in pairs(self.curDayAchieve) do
        isHas = false;
        for index,var in pairs(class) do
            if(var == ach.achId)then
                isHas = true;
                break;
            end
        end
        if(not isHas)then
            table.insert(class,ach.achId);
        end
    end
    for key,ach in pairs(self.curDayAchieve) do
        for index,var in pairs(class) do
            if(var == ach.achId)then
                ach.labelIndex = toint(index);
                break;
            end
        end
    end

    local index = 1;
    while(true)do
        if(self:getNode("btn"..index))then
            self:getNode("btn"..index):setVisible(false);
        else
            break;
        end
        index = index + 1;
    end

    local btnIndex = 1;
    for key, achieveid in pairs(class) do
        if(toint(key)<=index-1)then
            self:getNode("btn"..key):setVisible(true);
            local achType = DB.getAchieveType(achieveid);
            self:setLabelString("btn_word"..key,achType.title);
            btnIndex = btnIndex + 1;
        end
    end
    --七日特惠
    if(btnIndex<=index-1)then
        self:getNode("btn"..btnIndex):setVisible(true);
        self:setLabelString("btn_word"..btnIndex,gGetWords("activityNameWords.plist","task7day"));
    end

    self:resetLayOut();
    self.curDayLabel = -1;
    self:onDayLabel(dayLabelIndex);

    self:dealRedDotAchieve();
end

function Task7DayPanel:setDayLabelData(index)


    if(self.curDayLabel == index)then
        return;
    end
    self.curDayLabel = index;

    local curShowAchieve = {};
    for key,achieve in pairs(self.curDayAchieve) do
        if(achieve.labelIndex == index)then
            table.insert(curShowAchieve,achieve);
        end
    end

    if(#curShowAchieve <= 0)then
        self:setDayLabelDataForGift();
        return;
    end

    --排序
    for key,var in pairs(curShowAchieve) do
        if(var.canGet)then
            var.sortid = 0;
        elseif(var.isGet)then
            var.sortid = 100;
        else
            var.sortid = toint(var.achieve.level);
        end
    end

    local sortFun = function(a1,a2)
        if(a1.sortid<a2.sortid)then
            return true;
        end
        return false;
    end
    table.sort(curShowAchieve,sortFun);

    self:getNode("scroll_achieve"):clear()
    -- print("setDayLabelData --------");
    -- print_lua_table(curShowAchieve);
    -- print("setDayLabelData ++++++++");
    for key, var in pairs(curShowAchieve) do
        -- print("key = "..key);
        -- print_lua_table(var);
        local item=Task7DayItem.new()
        if toint(key) < 6 then
            item:setAchieveData(var,self.today>=self.curDay,self.curDay) 
        else
            item:setLazyAchieveData(var,self.today>=self.curDay,self.curDay) 
        end
        self:getNode("scroll_achieve"):addItem(item)
    end
    self:getNode("scroll_achieve"):layout()

end

function Task7DayPanel:setDayLabelDataForGift()

    local showGift = {};
    for key,gift in pairs(self.allGifts) do
        if(toint(gift.data.limitpara) == self.curDay - 1)then
            table.insert(showGift,gift);
        end
    end

    local sortFun = function(a1,a2)
        return a1.data.sortid < a2.data.sortid;
    end
    table.sort(showGift,sortFun);


    self:getNode("scroll_achieve"):clear()
    for key, var in pairs(showGift) do
        local item=Task7DayItem.new();
        item:setGiftData(var,self.today>=self.curDay,self.curDay);
        self:getNode("scroll_achieve"):addItem(item);
    end
    self:getNode("scroll_achieve"):layout()

end

function Task7DayPanel:refreshGiftList()
    local items = self:getNode("scroll_achieve"):getAllItem();
    for key,item in pairs(items) do
        item:setBuyNum();
    end
end

function Task7DayPanel:removeAchieveData( id )
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

function Task7DayPanel:removeAchieve(index)
    self:getNode("scroll_achieve"):removeItemByIndex(index);

end

function Task7DayPanel:addNewAchieve( data )
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

function Task7DayPanel:dealRedDotAchieve()
    -- body
    Data.redpos.bolNewTask = false;

    for key,var in pairs(Data.redpos.bol7DayTask) do
        -- var = false;
        Data.redpos.bol7DayTask[key] = false;
    end
    local index = -1;
    for key,ach in pairs(self.allAchieve) do
        if(ach.canGet and not ach.isGet) then
            index = ach.achId % 10;
            if(self.today >= index)then
                Data.redpos.bol7DayTask[index] = true;
                Data.redpos.bolNewTask = true;
            end
        end
    end

    for key,var in pairs(Data.redpos.bol7DayTaskLabel) do
        -- var = false;
        Data.redpos.bol7DayTaskLabel[key] = false;
    end
    -- print_lua_table(self.curDayAchieve);
    -- print_lua_table(Data.redpos.bol7DayTaskLabel);
    for key,ach in pairs(self.curDayAchieve) do
        if(ach.canGet and not ach.isGet) then
            index = ach.achId % 10;
            if(self.today >= index)then
                Data.redpos.bol7DayTaskLabel[ach.labelIndex] = true;
                Data.redpos.bolNewTask = true;
            end
        end
    end

end

function Task7DayPanel:refreshCurDay(dayLabelIndex)
    local curDay = self.curDay;
    self.curDay = -1;
    self:setDayData(curDay,dayLabelIndex);    
end

function Task7DayPanel:refreshCurDayLabel()
    local curDayLabel = self.curDayLabel;
    self.curDayLabel = -1;
    self:onDayLabel(curDayLabel);    
end

function Task7DayPanel:initPanel(param)
    self.achieve=param
    self:initAchieve();
    if(Task7DayPanel.refreshLabel)then
        -- self:refreshCurDayLabel();
        local curDayLabel = self.curDayLabel;
        self.curDayLabel = -1;
        self:refreshCurDay(curDayLabel);
    else
        self:refreshCurDay();
    end
    Task7DayPanel.refreshLabel = false;    
end

function  Task7DayPanel:events()
    return {
    EVENT_ID_ACHIEVE_LIST,
    EVENT_ID_ACHIEVE_GET,
    EVENT_ID_GIFT_BAG_GOT
    }
end

function Task7DayPanel:dealEvent(event,param)
    if(event==EVENT_ID_ACHIEVE_LIST)then
        self:initPanel(param);

    elseif(event == EVENT_ID_ACHIEVE_GET) then
        -- print("param -----");
        -- print_lua_table(param);
        -- print("param +++++");

        local index = self:removeAchieveData(param.remove_id);
        if param.new_data then
            table.insert(self.achieve,param.new_data);
        end
        self:initAchieve();
        self:refreshCurDay(self.curDayLabel);
        -- self:refreshCurDayLabel();
    elseif(event == EVENT_ID_GIFT_BAG_GOT)then
        self:refreshGiftList();
    end
end

function Task7DayPanel:resetBtnTexture()
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

function Task7DayPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture(name,"images/ui_public1/button_s2-1.png")
end

function Task7DayPanel:onDay(day)
    self:setDayData(day);
    self:selectBtn("day"..day)

    for i=1,7 do
        self:getNode("flag_arrow"..i):setVisible(false);
    end
    self:getNode("flag_arrow"..day):setVisible(true);
    -- local pos = cc.p(gGetPositionByAnchorInDesNode(self:getNode("flag_arrow"):getParent(),self:getNode("day"..day),cc.p(1.0,0.5)));
    -- self:getNode("flag_arrow"):setPositionY(pos.y);    
end

function Task7DayPanel:resetBtnLabelTexture()
    local btns={
        "btn1",
        "btn2",
        "btn3",
        "btn4",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end

function Task7DayPanel:selectBtnLabel(name)

    self:resetBtnLabelTexture()
    self:changeTexture(name,"images/ui_public1/b_biaoqian1-1.png")
end
function Task7DayPanel:onDayLabel(index)
    self:setDayLabelData(index);
    self:selectBtnLabel("btn"..index)    
end

function Task7DayPanel:onTouchEnded(target)

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
    elseif target.touchName == "btn1"then
        self:onDayLabel(1);
    elseif target.touchName == "btn2"then
        self:onDayLabel(2);
    elseif target.touchName == "btn3"then
        self:onDayLabel(3);
    elseif target.touchName == "btn4"then
        self:onDayLabel(4);    
    end
end

return Task7DayPanel