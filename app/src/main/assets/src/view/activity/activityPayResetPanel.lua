local ActivityPayResetPanel=class("ActivityPayResetPanel",UILayer)

function ActivityPayResetPanel:ctor(data)


    self:init("ui/ui_hd_tongyong1.map")
    self.curData=data
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_pay_reset"))
    -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivityPayResetPanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        Panel.popUp(PANEL_PAY)
    end
end


return ActivityPayResetPanel