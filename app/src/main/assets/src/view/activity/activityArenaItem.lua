local ActivityArenaItem=class("ActivityArenaItem",UILayer)

function ActivityArenaItem:ctor()
    self:init("ui/ui_hd_arena_item.map")

end




function ActivityArenaItem:onTouchEnded(target)  
    if( self.isOpen==true)then
        Panel.popUp(PANEL_ACTIVITY_TYPE_1,self.curData)
    end
end


function   ActivityArenaItem:setData(data)
    self.curData=data 
 
end



return ActivityArenaItem