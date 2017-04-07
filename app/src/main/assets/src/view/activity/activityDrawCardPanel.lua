local ActivityDrawCardPanel=class("ActivityDrawCardPanel",UILayer)

function ActivityDrawCardPanel:ctor(data)

    self:init("ui/ui_hd_tongyong1.map") 
    self.curData=data
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_draw_card_saleoff",gGetDiscount(data.param/10)))
  --  Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end
 

function ActivityDrawCardPanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        Panel.popUp(PANEL_DRAW_CARD)
     end
end

return ActivityDrawCardPanel