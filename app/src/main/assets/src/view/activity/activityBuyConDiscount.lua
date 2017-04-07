local ActivityBuyConDiscount=class("ActivityBuyConDiscount",UILayer)

function ActivityBuyConDiscount:ctor(data)

    self:init("ui/ui_hd_tongyong1.map")


    self.curData=data
    if data.param~=0 and data.param2==0 then
    	self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_constellation_saleoff_2",gGetDiscount(data.param/10)))
    elseif data.param==0 and data.param2~=0 then
    	self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_constellation_saleoff_3",gGetDiscount(data.param2/10)))
    else
    	self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_constellation_saleoff_1",gGetDiscount(data.param/10),gGetDiscount(data.param2/10)))
    end
    
    -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivityBuyConDiscount:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        Panel.popUpVisible(PANEL_SHOP, SHOP_TYPE_CONSTELLATION)
    end
end

return ActivityBuyConDiscount