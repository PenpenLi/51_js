local EditObjItem=class("EditObjItem",UILayer)

function EditObjItem:ctor()
    self:init("ui/ui_edit_item.map")

end




function EditObjItem:onTouchEnded(target)  
    if( self.onSelectCallback)then
        self.onSelectCallback(self.curData)
    end
end


function   EditObjItem:setData(data)  
    self.curData=data
    if(data.id)then 
        self:setLabelString("txt_name",data.id)
    elseif(data.skillName)then 
        self:setLabelString("txt_name",data.skillName)
    elseif(data.getName)then 
        self:setLabelString("txt_name",data:getName())
    elseif(data.cardid)then 
        self:setLabelString("txt_name",data.cardid)
    else 
        self:setLabelString("txt_name",data)
    end

end



return EditObjItem