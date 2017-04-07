-- 封测期间,双倍返还充值元宝
local ActivityDoubleDiaPanel=class("ActivityDoubleDiaPanel",UILayer)

function ActivityDoubleDiaPanel:ctor(data)
    self:init("ui/ui_hd_tongyong1.map")

    self.type = data
    self.diamond = 0
    for key, value in pairs(Data.activityAll) do
        if (value.type == self.type) then
            self.diamond = value.diamond
            break
        end
    end
    
    self:getNode("vip_layer"):setVisible(true)
    self:getNode("txt_info"):setVisible(false)

    self.txt_vip1 = self:getNode("txt_vip1");
	self.txt_vip2 = self:getNode("txt_vip2");
	self.txt_vip3 = self:getNode("txt_vip3");

	self.txt_vip1:setVisible(false)
	self.txt_vip2:setVisible(true)
	self.txt_vip3:setVisible(true)

	local cx,cy = self.txt_vip3:getPosition()
	self.txt_vip3:setPosition(cc.p(cx,cy-24))
    
    self:refreshTxt()
    self:refreshHadPay()
end

function ActivityDoubleDiaPanel:refreshTxt()
	local word = gGetWords("activityNameWords.plist","double_charge_content")
	self.txt_vip2.width = 400
    self:setRTFString("txt_vip2",word)
end

function ActivityDoubleDiaPanel:refreshHadPay()
	local word = gGetWords("activityNameWords.plist","double_charge_tip",self.diamond)
    self:setRTFString("txt_vip3",word)
end

function ActivityDoubleDiaPanel:events()
    return {
        EVENT_ID_USER_DATA_UPDATE
    }
end

function ActivityDoubleDiaPanel:dealEvent(event,param)
    if(event==EVENT_ID_USER_DATA_UPDATE)then
        self:refreshHadPay()
    end
end

function ActivityDoubleDiaPanel:onTouchEnded(target)
    if  target.touchName=="btn_go"then
        Panel.popUp(PANEL_PAY)
    end
end

return ActivityDoubleDiaPanel