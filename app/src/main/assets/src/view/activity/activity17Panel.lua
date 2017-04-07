local Activity17Panel=class("Activity17Panel",UILayer)

function Activity17Panel:ctor(data)
    self:init("ui/ui_hd_fuli_1.map") 
    self.curData=data
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- print("self.curData.type = "..self.curData.type)
    self.activityData = nil;

    self:getNode("rule_bg"):setVisible(false)
    self:getNode("lab_help"):setVisible(false)
    self:getNode("share_bg"):setVisible(false)
    self:getNode("17_bg"):setVisible(true)

    Net.sendActivity17(self.curData,true)
end

function Activity17Panel:onPopup()
    Net.sendActivity17(self.curData,true)
end

function Activity17Panel:onTouchEnded(target)
    if(target.touchName=="btn_pay")then
        if not Panel.isOpenPanel(PANEL_PAY) then
            Panel.popUp(PANEL_PAY);
        end
    end
end

function Activity17Panel:sortActList()
    --排序
    -- print_lua_table(self.activityData.list)
    for k,v in pairs(self.activityData.list) do
        -- v.sort = 5
        -- v.key = k
        --0:未满足条件 1:时间未到 2:可领取 3:已领取
        if (v.status == 0) then
            v.sort = 2
        elseif (v.status == 1) then
            v.sort = 3
        elseif (v.status == 2) then
            v.sort = 1
        elseif (v.status == 3) then
            v.sort = 4
        end
    end

    -- print_lua_table(self.activityData.list)

    local sort1 = function(a,b)
        if (a.sort == b.sort) then
            return a.cnt < b.cnt
        else
            return a.sort < b.sort
        end
    end
    table.sort( self.activityData.list, sort1)

    -- print_lua_table(self.activityData.list)
end

function Activity17Panel:setData(param)
    self:getNode("scroll"):clear()
    self.activityData = Data.activity17Data
    --排序
    self:sortActList()

    for key, value in pairs( self.activityData.list) do
        local item = Activity17Item.new()
        item.curActData= self.curData
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()

    -- print("self.activityData.desc="..self.activityData.desc)
    local word = gGetWords("activityNameWords.plist","22",Data.activity17Data.maxd)
    self:setRTFString("txt_content",word)
    self:setLabelString("txt_pay_per",Data.activity17Data.curd.."/"..Data.activity17Data.maxd)

    self:getNode("lab_over"):setVisible(false)
    self:getNode("dia_bg"):setVisible(true)
    self:getNode("dia_bg"):layout()
    if (Data.activity17Data.endtime<gGetCurServerTime()) then
       self:getNode("lab_over"):setVisible(true)
       self:getNode("dia_bg"):setVisible(false)
    end
    
    self:resetLayOut();
    self:getNode("scroll_content"):layout();
end

function Activity17Panel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_17 )then
        if(self.allPanel)then
          self.allPanel:showTime({type = ACT_TYPE_17});
        end
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_17_REC)then
        self:refreshData(param)
    end
end

function Activity17Panel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end       

return Activity17Panel