local ActivityConsume=class("ActivityConsume",UILayer)

function ActivityConsume:ctor(data) 
    self:init("ui/ui_hd_shenjiang.map") 
    self.curData=data
    Net.sendActivityConsume() 
end


function ActivityConsume:onTouchEnded(target)
    if(target.touchName=="btn_pay")then
        Panel.popUp(PANEL_PAY)
    end 
end




function ActivityConsume:setData(param)

 
end



function ActivityConsume:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)  
    end

end       


return ActivityConsume