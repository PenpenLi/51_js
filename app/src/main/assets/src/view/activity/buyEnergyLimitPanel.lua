local BuyEnergyLimitPanel=class("BuyEnergyLimitPanel",UILayer)

function BuyEnergyLimitPanel:ctor(data)

    self:init("ui/ui_hd_tongyong1.map") 
    self.curData=data
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_buy_energy_limit",Data.activityProAdd.value))
  --  Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end
 

function BuyEnergyLimitPanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then 
        Panel.popUpVisible(PANEL_BUY_ENERGY,VIP_DIAMONDHP);
     end
end
 
return BuyEnergyLimitPanel