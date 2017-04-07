local ActivitySaleOffPanel=class("ActivitySaleOffPanel",UILayer)

function ActivitySaleOffPanel:ctor(data)

    self:init("ui/ui_hd_saleoff.map") 
    self.curData=data
    self:getNode("scroll").eachLineNum=2
    self:getNode("scroll").offsetX=10
    self:getNode("scroll").offsetY=12
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    Net.sendActivitySaleOff(data)
end
 




function ActivitySaleOffPanel:setData(param)

    self:getNode("scroll"):clear() 
    for key, value in pairs( Data.activitySaleOffData.list) do
        local item=ActivitySaleOffItem.new()
        item.curActData= self.curData
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)

    end
    self:getNode("scroll"):layout()

end

function ActivitySaleOffPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_SALEOFF)then
        self:setData(param)

    elseif(event==EVENT_ID_GET_ACTIVITY_SALEOFF_BUY)then
        self:refreshData(param)

    end
end

function ActivitySaleOffPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)  
    end

end       

return ActivitySaleOffPanel