local RichmanEventPanel=class("RichmanEventPanel",UILayer)

function RichmanEventPanel:ctor(id)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_richman_event.map")

    local db= DB.getRichmanConfig(id) 
    self:setLabelString("txt_event",db.des)
    local item=Icon.setDropItem(self:getNode("icon"),db.item,db.min)
    item:setLabelString("txt_num","")
    self:setLabelString("txt_num","x"..db.min)
    
    self:changeTexture("card","images/ui_team/pop_"..db.icon..".png")
    self:resetLayOut()

    local autoCloseTime = DB.getClientParam("RICHMAN_EVENT_AUTO_CLOSE_TIME")
    local startTime = gGetCurServerTime()
    local function updateTime()
        if gGetCurServerTime()-startTime >=autoCloseTime then
            self:closeAndunSchedule()
        end
    end 

    self:scheduleUpdateWithPriorityLua(updateTime,1)
end
 

function RichmanEventPanel:onTouchEnded(target, touch, event)
   self:closeAndunSchedule()
end
 
function RichmanEventPanel:closeAndunSchedule()
   self:unscheduleUpdate()
    self:onClose()
end

return RichmanEventPanel