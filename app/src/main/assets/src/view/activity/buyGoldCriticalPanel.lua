local BuyGoldCriticalPanel=class("BuyGoldCriticalPanel",UILayer)

function BuyGoldCriticalPanel:ctor(data)

    self:init("ui/ui_hd_tongyong1.map") 
    self.curData=data
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_buy_gold_critical"))
  --  Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end
 

function BuyGoldCriticalPanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        Panel.popUp(PANEL_BUY_GOLD)
     end
end

return BuyGoldCriticalPanel