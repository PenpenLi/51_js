local MallMenuItem=class("MallMenuItem",UILayer)

function MallMenuItem:ctor()
    self:init("ui/ui_mall_icon.map")
end

function MallMenuItem:setSelect(value)
    if(value)then
        self:changeTexture( "bg","images/ui_huodong/icon_di2.png")
    else
        self:changeTexture("bg","images/ui_huodong/icon_di1.png")
    end
end

function MallMenuItem:onTouchEnded(target)
    if(self.onSelectCallback)then
        -- for key, var in pairs(Data.activityRedPosLogin) do
        --     if(key==self.curData.type)then
        --         if (Data.activityRedPosLogin[key]==true) then
        --             Data.activityRedPosLogin[key]=false
        --             RedPoint.setActivityRedpos(key,false)
        --         end
        --     end
        -- end
        self.onSelectCallback(self.curData)
    end
end

function MallMenuItem:changeFla(name)
    if(self.fla)then
        self.fla:removeFromParent()
        self.fla=nil
    end
    loadFlaXml("ui_activity_icon")
    self.fla=gCreateFla(name,1)
    
    self:getNode("fla"):getParent():addChild(self.fla)
    self:getNode("fla"):setVisible(false)
    self.fla:setPosition(self:getNode("fla"):getPosition())
end

function MallMenuItem:setData(data)
    self.curData=data
    local type=self.curData.type
    if(type == MALL_TYPE_VIP)then
        self:changeTexture( "fla","images/ui_huodong/activity_type_vip.png")
    elseif(type == MALL_TYPE_WEEK)then
        self:changeTexture( "fla","images/ui_huodong/activity_type_week.png")
    elseif(type == MALL_TYPE_VIP_DAY)then
        self:changeTexture( "fla","images/ui_huodong/activity_type_vip_everyday.png")
    elseif(type == MALL_TYPE_PAY)then
        self:changeFla(  "ui_activity_icon_"..ACT_TYPE_1001)
    end 
    self:setLabelString("txt_name" , data.name)
end

return MallMenuItem