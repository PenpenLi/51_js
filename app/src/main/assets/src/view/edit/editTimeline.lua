local EditTimeline=class("EditTimeline",UILayer)

function EditTimeline:ctor()
    self:init("ui/ui_edit_time_line.map")

end




function EditTimeline:onTouchEnded(target)  
    if( self.onSelectCallback)then
        self.onSelectCallback(self.curData)
    end
end


function   EditTimeline:setData(data)  
    self.curData=data
  
end



return EditTimeline