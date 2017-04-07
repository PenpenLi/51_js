local ActivitySaleOffLimitPanel=class("ActivitySaleOffLimitPanel",UILayer)

function ActivitySaleOffLimitPanel:ctor(data)

    self:init("ui/ui_hd_tongyong1.map")


    self.curData=data
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_saleoff_limit",gGetDiscount(data.param/10),gGetDiscount(data.param2/10)))
    -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivitySaleOffLimitPanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        if Unlock.isUnlock(SYS_SHOP) then
            Panel.popUp(PANEL_SHOP,SHOP_TYPE_1)
        end
        
    end
end

return ActivitySaleOffLimitPanel