local ActivityRedPackagePanel=class("ActivityRedPackagePanel",UILayer)
ActivityRedPackagePanelData = {}
function ActivityRedPackagePanel:ctor(data)

    self:init("ui/ui_hd_red_package.map") 
    self.curData=data
 

    Net.sendActivityGetInfo20(data.actId) 
end


function ActivityRedPackagePanel:setData(rewards)


    self:getNode("scroll"):clear() 
    for key, value in pairs(rewards) do
        local item=ActivityRedPackageItem.new()
        item.key=key
        item:setData( self.curData,value)
        self:getNode("scroll"):addItem(item)

    end 
    self:getNode("scroll"):layout()

end

function ActivityRedPackagePanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_RED_PACKAGE)then
            self:setData(param.list)
     
    end
end
 
 

return ActivityRedPackagePanel