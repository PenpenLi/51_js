local ActivityBathDoublePanel=class("ActivityBathDoublePanel",UILayer)

function ActivityBathDoublePanel:ctor(data)


    self:init("ui/ui_hd_tongyong1.map")
    self.curData=data
    -- local time = 100
    -- if (Data.activityAtlasSaleoff.val) then
    -- 	time = Data.activityAtlasSaleoff.val
    -- end
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_bath_double",math.floor(data.param/10)))
    -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivityBathDoublePanel:onTouchEnded(target)
    if  target.touchName=="btn_go"then
        if Unlock.isUnlock(SYS_BATH) then
            Net.sendBathGetInfo();
        end
    end
end


return ActivityBathDoublePanel