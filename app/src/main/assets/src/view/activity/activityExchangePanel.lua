local ActivityExchangePanel=class("ActivityExchangePanel",UILayer)

function ActivityExchangePanel:ctor(data)

    self:init("ui/ui_hd_fuli_1.map") 
    self.curData=data

    self:getNode("rule_bg"):setVisible(true)
    self:getNode("lab_help"):setVisible(true)
    self:getNode("share_bg"):setVisible(false)
    self:getNode("17_bg"):setVisible(false)
    
    -- self:getNode("scroll").eachLineNum=2
    -- self:getNode("scroll").offsetX=10
    -- self:getNode("scroll").offsetY=12
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    Net.sendActivityExchange(data.actId,true)
end

function ActivityExchangePanel:setData(param)

    self:getNode("scroll"):clear() 
    for key, value in pairs( Data.activityExchangeData.list) do
        local item=ActivityExchangeItem.new()
        item.curActData= self.curData
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    -- print("---"..Data.activityExchangeData.desc)

    self:setRTFString("lab_help","\\w{c=ffecc3}"..Data.activityExchangeData.desc)
    self:getNode("scroll_contain_item"):layout()
    self:getNode("help_bg"):layout()
    
end

function ActivityExchangePanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_EXCHANGE)then
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_EXCHANGE_REC)then
        -- print("1---------EVENT_ID_GET_ACTIVITY_EXCHANGE_REC")
        self:refreshData(param)
    end
end

function ActivityExchangePanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)  
    end
end       

return ActivityExchangePanel