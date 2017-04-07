local ActivityExpenseReturnPanel=class("ActivityExpenseReturnPanel",UILayer)

function ActivityExpenseReturnPanel:ctor(data)
    self:init("ui/ui_hd_fuli_1.map") 
    self.curData=data
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- print("self.curData.type = "..self.curData.type)
    self.activityData = nil;

    self:getNode("rule_bg"):setVisible(true)
    self:getNode("lab_help"):setVisible(true)
    self:getNode("share_bg"):setVisible(false)
    self:getNode("17_bg"):setVisible(false)

    if (self.curData.type == ACT_TYPE_2) then
        Net.sendActivityExpenseReturn(data)
    else
        Net.sendActivityPay(data)
    end
    Data.activityActid = self.curData.actId
    print("Data.activityActid="..Data.activityActid)
end

function ActivityExpenseReturnPanel:onPopup()
    -- print("self.curData.type="..self.curData.type)
    if (self.curData.type == ACT_TYPE_2) then
        Net.sendActivityExpenseReturn(self.curData)
    else
        Net.sendActivityPay(self.curData)
    end
end

function ActivityExpenseReturnPanel:sortActList()
    --排序
    for k,v in pairs(self.activityData.list) do
        -- print(k,v)
        local info1 = v.items[1]
        if (self.activityData.var>=info1.num) then
            if (v.rec==false) then--已经领取
                v.sort = 3
            else
                v.sort = 1
            end
        else
            --前往
            v.sort = 2
        end
    end

    local sort1 = function(a,b)
        local info1 = a.items[1]
        local info2 = b.items[1]
        if (a.sort == b.sort) then
            return info1.num < info2.num;
        else
            return a.sort < b.sort
        end
    end
    table.sort( self.activityData.list, sort1 )
end

function ActivityExpenseReturnPanel:setData(param)
    self:getNode("scroll"):clear()
    self.activityData = nil;
    if (self.curData.type == ACT_TYPE_2) then
        self.activityData = Data.activityExpenseReturnData;
    else
        self.activityData = Data.activityPayData;
    end
    --排序
    self:sortActList()
    for key, value in pairs( self.activityData.list) do
        local item=ActivityExpenseReturnItem.new(self.curData.type)
        item.curActData= self.curData
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    -- print("---"..self.activityData.desc)

    self:setRTFString("lab_help",self.activityData.desc)
    self:getNode("scroll_contain_item"):layout()
    self:getNode("help_bg"):layout()
end

function ActivityExpenseReturnPanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_EXPENSE_RETURN )then
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_EXPENSE_RETURN_GET)then
        self:refreshData(param)

    elseif(event==EVENT_ID_GET_ACTIVITY_PAY)then
        self:setData(param)
    elseif(event==EVENT_ID_USER_DATA_UPDATE or event==EVENT_ID_GET_ACTIVITY_PAY_GET )then
        self:refreshData(param)
    end
end

function ActivityExpenseReturnPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end       

return ActivityExpenseReturnPanel