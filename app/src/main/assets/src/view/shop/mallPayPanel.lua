local MallPayPanel=class("MallPayPanel",UILayer)

function MallPayPanel:ctor(type)
    self:init("ui/ui_hd_qiandao.map")

    self:replaceRtfString("txt_day_pay", gGiftPay.daymoney)
    local data= DB.getSignIapReward()

    for i=1, 2 do
        local item=data[i]
        -- self:setLabelAtlas("txt_need_pay"..i, item.money)
        self:setLabelString("txt_need_pay"..i, item.money);
        self:getNode("icon_got"..i):setVisible(false)
        if( gGiftPay.idx>=i)then
            self:getNode("icon_got"..i):setVisible(true)
        end

        for j=1, 4 do
            if(self:getNode("icon"..i.."_"..j))then
                self:getNode("icon"..i.."_"..j):setVisible(false)
                if(item["itemnum"..j]>0)then
                    self:getNode("icon"..i.."_"..j):setVisible(true)
                    Icon.setDropItem( self:getNode("icon"..i.."_"..j), item["itemid"..j],item["itemnum"..j])
                end
            end

        end
    end
    if( gGiftPay.idx>=2)then
        self:setRTFString("txt_day_pay",gGetWords("activityNameWords.plist","activity_1001_got"))
    end
    self:resetLayOut()
end



function MallPayPanel:onTouchEnded(target)
    if  target.touchName=="btn_pay"then
        gLogEvent("gift_pay")
        Panel.popUp(PANEL_PAY)
    end
end

return MallPayPanel