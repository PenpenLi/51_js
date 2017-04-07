local ServerArea=class("ServerArea",UILayer)

function ServerArea:ctor()
    self:init("ui/ui_server_area.map")
    self:getNode("icon_pub"):setVisible(false)

end




function ServerArea:onTouchEnded(target)
 
    if( self.onSelectCallback)then
        self.onSelectCallback()
    end
end
 

function ServerArea:setPub(value)
end
function ServerArea:resetSelect()
    self:changeTexture("bg","images/ui_public1/server_button2.png")
end

function ServerArea:select()
    self:changeTexture("bg","images/ui_public1/server_button1.png")
end


function   ServerArea:setData(value)
    self.curData=count  
    
    local tag="S"
    if(value)then
        tag="P"
    end
    
    local num=tag..(self.startIdx-self.startOffset).."~"..(self.endIdx-self.startOffset)
    if isBanshuReview() then
        num=(self.startIdx-self.startOffset).."~"..(self.endIdx-self.startOffset).."服"
    end
    self:setLabelString("txt_num",num)
end



return ServerArea