local ServerRole=class("ServerRole",UILayer)

function ServerRole:ctor()
    self:init("ui/ui_server_role.map")
    if( gIsInReview())then
        self:getNode("bg_vip"):setVisible(false)
    else 
        self:getNode("bg_vip"):setVisible(true)
    end
end




function ServerRole:onTouchEnded(target)
 
    if( self.onSelectCallback)then
        self.onSelectCallback()
    end
end
 
function   ServerRole:setData(data) 
    self.curData=gAccount:getServerById(data.serverid)
    self.curRoleData=data
    self:setLabelString("txt_name",data.rolename)  
    self:setLabelAtlas("txt_level", data.level)  
    if(self.curData)then
        local showid= self.curData.showid
        if showid == nil then
             showid = self.curData.id
        end 
        if isBanshuReview() then
            self:setLabelString("txt_sname",(showid%1000).."服".."-"..self.curData.name)
        else
            self:setLabelString("txt_sname",gGetServerTag(self.curData)..(showid%1000).."-"..self.curData.name)
        end  
    else
        self:setLabelString("txt_sname","")  
    end
    self:setLabelAtlas("txt_vip",data.vip)  
    if(data.icon)then
     Icon.setHeadIcon(self:getNode("icon"),data.icon);
    end
    --Icon.setCardIcon(toint(data.icon)) 

end



return ServerRole