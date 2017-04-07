local ActivityAtlasResetPanel=class("ActivityAtlasResetPanel",UILayer)

function ActivityAtlasResetPanel:ctor(data)


    self:init("ui/ui_hd_tongyong1.map")
    self.curData=data
    local time = 100
    if (Data.activityAtlasSaleoff.val) then
    	time = Data.activityAtlasSaleoff.val
    end
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_buy_atlas_reset",gGetDiscount(time/10)))
    -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivityAtlasResetPanel:onTouchEnded(target)

    if  target.touchName=="btn_go"then
        if (Unlock.isUnlock(SYS_ELITE_ATLAS)) then
            Panel.popUp(PANEL_ATLAS,{type=1})
        end
    end
end


return ActivityAtlasResetPanel