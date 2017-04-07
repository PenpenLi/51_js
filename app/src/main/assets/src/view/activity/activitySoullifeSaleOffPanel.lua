local ActivitySoullifeSaleOffPanel=class("ActivitySoullifeSaleOffPanel",UILayer)

function ActivitySoullifeSaleOffPanel:ctor(data)

    self:init("ui/ui_hd_tongyong1.map")


    self.curData=data
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_soullife_saleoff",gGetDiscount(data.param/10)))
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivitySoullifeSaleOffPanel:onTouchEnded(target)

    if target.touchName=="btn_go"then
        if Unlock.isUnlock(SYS_XUNXIAN,true) then
            Net.sendSpiritInit(1)
        end
    end
end

return ActivitySoullifeSaleOffPanel