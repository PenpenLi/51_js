local ActivityInvestItem=class("ActivityInvestItem",UILayer)

function ActivityInvestItem:ctor()
    self:init("ui/ui_hd_touzi_item.map")

end




function ActivityInvestItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        Net.sendActivityInvestGet(self.curData.lv)
    end
end


function   ActivityInvestItem:setData(data)
    self.curData=data
    self:refreshData(data)
end

function   ActivityInvestItem:refreshData(data)
    self.dia=self.curData.dia
    self.isGet=0
    local canBeGot = false
    local status = 0;
    -- self:getNode("btn_get"):setVisible(true)
    -- self:getNode("flag_unget"):setVisible(false);
    if(Data.activityInvestBuy==false or gUserInfo.level<toint(self.curData.lv))then
        -- self:getNode("btn_get"):setVisible(false)
        -- self:getNode("flag_unget"):setVisible(true);
        status = -1;
    else
        if(Data.activityInvestReward[toint(self.curData.lv)]==1)then 
            self.isGet=1
            status = 1;
            -- self:setTouchEnableGray("btn_get",false);
            -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_reward_got"))
        else
            -- self:setTouchEnableGray("btn_get",true);
            -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward"))
            canBeGot = true
            status = 0;
        end
    end
    gShowBtnStatus(self:getNode("btn_get"),status);
    self:setLabelString("txt_info",gGetWords("labelWords.plist","lab_hd_touzi_info",self.curData.lv,self.curData.dia))
    Data.updateActInvestCanBeGot(self.curData.lv, canBeGot)
end

return ActivityInvestItem
