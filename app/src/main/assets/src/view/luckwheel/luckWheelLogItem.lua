local LuckWheelLogItem=class("LuckWheelLogItem",UILayer)

function LuckWheelLogItem:ctor()


end

function LuckWheelLogItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_luck_wheel_log_item.map")

end

function LuckWheelLogItem:setLazyDataCalled()
    self:setData(self.curData)
end


function LuckWheelLogItem:setLazyData(data)
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"wheellog")
end 


function LuckWheelLogItem:setData(var)
    self:initPanel()
    local quality=DB.getItemQuality(var.id)
    local color=gGetItemQualityColor(quality)
    color=gParseRgbNum(color.r,color.g,color.b) 
    local word=gGetWords("luckyWheel.plist","9",color,DB.getItemName(var.id),var.num)
    self:setRTFString("txt_info",word)
end


return LuckWheelLogItem