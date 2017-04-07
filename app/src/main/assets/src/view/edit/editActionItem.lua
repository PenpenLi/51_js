local EditActionItem=class("EditActionItem",UILayer)

function EditActionItem:ctor()
    self:init("ui/ui_edit_action_item.map")
    local handler = function(event)  
        if(self.editCallback and event=="changed")then
            print(self:getNode("txt_start"):getText())
            self:setFlag(tonum(self:getNode("txt_start"):getText()),tonum(self:getNode("txt_end"):getText()))
            self.editCallback(self.curActionName)
        end
    end  
    self:getNode("txt_start"):registerScriptEditBoxHandler(handler) 
    self:getNode("txt_end"):registerScriptEditBoxHandler(handler) 
end




function EditActionItem:onTouchEnded(target)  
    if( self.onSelectCallback)then
        self.onSelectCallback(self.curActionName)
    end
end

function   EditActionItem:setActionName(name) 
    self.curActionName=name
    self:setLabelString("txt_name",name)
end

function   EditActionItem:setFlag(startFlag,endFlag)  
    self.curData=string.format("%.2f",startFlag)..","..string.format("%.2f",endFlag) 
    self:setData(self.curData)
end



function   EditActionItem:setData(data)  
    self.curData=data
    self.startFlag=0
    self.endFlag=0 
    if(data)then 
        local datas=string.split(data,",")
        self:setLabelString("txt_start",datas[1])
        self:setLabelString("txt_end",datas[2]) 
        
        self.startFlag=tonum(datas[1])
        self.endFlag=tonum(datas[2]) 
    else

        self:setLabelString("txt_start",0)
        self:setLabelString("txt_end",0) 
    end

end



return EditActionItem