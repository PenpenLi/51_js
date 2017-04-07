local ActivityAtlasDoublePanel=class("ActivityAtlasDoublePanel",UILayer)

function ActivityAtlasDoublePanel:ctor(data)

    self:init("ui/ui_hd_tongyong1.map")
 

    self.curData=data
    if data.type == ACT_TYPE_81  then
    	local hdtxt = gGetWords("labelWords.plist","lb_hd_atlas_skip")
    	hdtxt = gReplaceParam(hdtxt,data.param,data.param2)
    	self:setRTFString("txt_info", hdtxt)
    else
    	self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_atlas_double"))
    end
    
   -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end
 

function ActivityAtlasDoublePanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        Panel.popUp(PANEL_ATLAS)
     end
end

return ActivityAtlasDoublePanel