local ActivityChargeReturnPanel=class("ActivityChargeReturnPanel",UILayer)

function ActivityChargeReturnPanel:ctor(data)
    self:init("ui/ui_hd_chong.map") 
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.curData=data
    Data.activityActid = self.curData.actId
    Net.sendActivityChargeReturn(self.curData)
    self.refresh = false;

end

function ActivityChargeReturnPanel:onPopup()
    Net.sendActivityChargeReturn(self.curData) 
    self.refresh = true;
end

function ActivityChargeReturnPanel:onTouchEnded(target)
end

function ActivityChargeReturnPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_CHARGE_RETURN)then
        if(self.refresh)then
            self:refreshData()
        else
            self:setData()
        end
    elseif(event==EVENT_ID_GET_ACTIVITY_CHARGE_RETURN_GET)then
        self:refreshData()
    end
end

function ActivityChargeReturnPanel:setData()
    self:getNode("scroll"):clear()
    local rewards = Data.activityChargeReturn.list
    for key, value in pairs(rewards) do
        local item=ActivityChargeReturnItem.new()
        item:setData(Data.activityChargeReturn.idx,value.idx)
        self:getNode("scroll"):addItem(item)
    end
    self:sortItem()
    self:getNode("scroll"):layout()
end


function ActivityChargeReturnPanel:sortItem()
    local sortItemFunc = function(a, b)
        local detDataA = Data.getActivityChargeReturnByDetid(a.curData)
        local detDataB = Data.getActivityChargeReturnByDetid(b.curData)
        if(detDataA.iapid < detDataB.iapid)then
            return true
        else
            return false
        end
    end
    table.sort(self:getNode("scroll").items, sortItemFunc)
end

function ActivityChargeReturnPanel:refreshData()
    for key, item in pairs(self:getNode("scroll").items) do
        item:refreshData()
    end
    -- self:sortItem()
    -- self:getNode("scroll"):layout()
end

return ActivityChargeReturnPanel