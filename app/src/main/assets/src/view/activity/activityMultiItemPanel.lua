local ActivityMultiItemPanel=class("ActivityMultiItemPanel",UILayer)

function ActivityMultiItemPanel:ctor(data)
	self.curData=data
    self:init("ui/ui_hd_daoju.map")

    self:getNode("scroll"):clear()
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    Net.sendActivityGetInfo29(data)
end



function ActivityMultiItemPanel:onTouchEnded(target)

end

function ActivityMultiItemPanel:sortItem()
    for k,item in pairs(self:getNode("scroll").items) do
        if item.curData.cnt-item.curData.count == 0 then
            item.sort=1
        else
            item.sort=0
        end
    end

    local sortfunc = function(item1,item2)
        if item1.sort == item2.sort then
            return item1.curData.idx < item2.curData.idx
        else
            return item1.sort < item2.sort
        end
    end
    self:getNode("scroll"):sortItems(sortfunc);
end

function ActivityMultiItemPanel:setData(param)
    self:getNode("scroll"):clear()
    self.activityData = nil;
    self.activityData = Data.activityInfo29;

    for key, value in pairs( self.activityData.list) do
        local item=ActivityMultiItem.new(self.curData.actId)
        item.curActData= self.curData
        item:setData(value)
        self:getNode("scroll"):addItem(item)
    end
    self:sortItem()
    self:getNode("scroll"):layout()
end

function ActivityMultiItemPanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_GETINFO_29 )then
        self:setData(param)
   elseif(event==EVENT_ID_GET_ACTIVITY_29_REC)then
        self:refreshData(param)
    end
end

function ActivityMultiItemPanel:refreshData(param)
    self:sortItem()
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end 

return ActivityMultiItemPanel