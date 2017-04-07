local ActivityFamilyActPanel=class("ActivityFamilyActPanel",UILayer)

function ActivityFamilyActPanel:ctor(data)


    self:init("ui/ui_hd_tongyong1.map")
    self.curData=data
    -- local time = 100
    -- if (Data.activityAtlasSaleoff.val) then
    -- 	time = Data.activityAtlasSaleoff.val
    -- end
    self:setRTFString("txt_info", gGetWords("labelWords.plist","lb_hd_family_act"))
    -- Net.sendActivityTxt(data)
    self:getNode("vip_layer"):setVisible(false)
    self:getNode("txt_info"):setVisible(true)
end


function ActivityFamilyActPanel:onTouchEnded(target)
    if  target.touchName=="btn_go"then
        if Unlock.isUnlock(SYS_FAMILY) then
            -- self:onFamily();
            if gFamilyInfo.familyId == 0 then
                -- Net.sendFamilySearch(0);
                Panel.popUpUnVisible(PANEL_FAMILY_BG);
                Panel.popUpVisible(PANEL_FAMILY_SEARCH,1);
            else
                Net.sendFamilyGetInfo();
            end
        end
    end
end


return ActivityFamilyActPanel