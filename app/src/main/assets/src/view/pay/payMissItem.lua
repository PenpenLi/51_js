local PayMissItem=class("PayMissItem",UILayer)

function PayMissItem:ctor()
    self:init("ui/ui_yyb_pay_item.map")

end

function PayMissItem:onTouchEnded(target) 
    if target.touchName=="btn_del" then
        local onDelete = function ()
    		Net.removeReceipt(self.curOrderData.oid,true)
            gDispatchEvt(EVENT_ID_PAY_DELETE_ORDER_MISS)
        end
        gConfirmCancel(gGetWords("noticeWords.plist","confirm_check_order_delete"),onDelete);
    elseif target.touchName=="btn_miss" then
        local onSendMiss = function ()
            Net.sendCheckOrderMiss(self.curOrderData.oid,self.curOrderData.iapid,true)
        end
        gConfirmCancel(gGetWords("noticeWords.plist","confirm_check_order_miss"),onSendMiss);
    end
end

function PayMissItem:setData(data,orderdata,isRecord)
    self.curData=data
    self.curOrderData=orderdata
    if(data.iapid > 8)then
        self:getNode("icon"):setTexture("images/ui_huodong/g_halo.png")
        self:setLabelString("txt_dia",gGetWords("labelWords.plist","buy_halo"))
        self:getNode("cost_icon"):setVisible(false)
    else
        Icon.setIapIcon( self:getNode("icon"),data.iapid)
        self:setLabelString("txt_dia",data.diamond)
    end
    self:setLabelString("txt_money",data.money.."￥")

    self:getNode("txt_time"):setVisible(isRecord);
    self:getNode("btn_del"):setVisible(isRecord);
    if(isRecord)then
        self:setLabelString("txt_time",gGetYYMMDDHHMMSSByTime(orderdata.time))
    end
end

return PayMissItem