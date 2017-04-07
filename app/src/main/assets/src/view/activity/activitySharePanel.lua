local ActivitySharePanel=class("ActivitySharePanel",UILayer)

function ActivitySharePanel:ctor(data)
    self:init("ui/ui_hd_fuli_1.map") 
    self.curData=data
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- print("self.curData.type = "..self.curData.type)
    self.activityData = nil;

    self:getNode("rule_bg"):setVisible(false)
    self:getNode("lab_help"):setVisible(false)
    self:getNode("share_bg"):setVisible(true)
    self:getNode("17_bg"):setVisible(false)

    Net.sendActivityShareGetInfo()
end

function ActivitySharePanel:onPopup()
    Net.sendActivityShareGetInfo()
end

function ActivitySharePanel:sortActList()
    --排序
    for k,v in pairs(self.activityData.list) do
        v.sort = 5
        if (not v.achieve) then --未达成
            v.sort = 3
        else
            if (v.finish and v.share) then 
                if (not v.rec) then
                    v.sort = 1--可领取
                else
                    v.sort = 4--已领完
                end
            else
                if (not v.share) then
                    if (v.id == 3) then
                        if (v.plan>=v.request) then
                            v.sort = 2--可分享
                        else
                            v.sort = 3
                        end
                    else
                        v.sort = 2--可分享
                    end
                else
                    v.sort = 3
                end
            end
        end
    end

    local sort1 = function(a,b)
        if (a.sort == b.sort) then
            return a.id < a.id
        else
            return a.sort < b.sort
        end
    end
    table.sort( self.activityData.list, sort1 )
end

function ActivitySharePanel:setData(param)
    self:getNode("scroll"):clear()
    self.activityData = Data.activityShare
    --排序
    self:sortActList()
    for key, value in pairs( self.activityData.list) do
        local item = ActivityShareItem.new()
        -- local item=ActivityExpenseReturnItem.new(self.curData.type)
        item.curActData= self.curData
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()

    -- self:setRTFString("lab_help",self.activityData.desc)
end

function ActivitySharePanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_SHARE_GET_INFO )then
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_SHARE_REC)then
        self:refreshData(param)
    end
end

function ActivitySharePanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end       

return ActivitySharePanel