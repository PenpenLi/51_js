local ActivityArenaPanel=class("ActivityArenaPanel",UILayer)

function ActivityArenaPanel:ctor(data)

    self:init("ui/ui_hd_arena.map")
    self.curData=data

  
end
 

 

return ActivityArenaPanel