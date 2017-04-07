-- 免费vip体验
local ActivityVipExperiencePanel=class("ActivityVipExperiencePanel",UILayer)

function ActivityVipExperiencePanel:ctor(data)
    self:init("ui/ui_hd_free_vip2.map")

    Net.sendActivityVipExperienceInfo()
end

function ActivityVipExperiencePanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function ActivityVipExperiencePanel:refresh()
    self:setLabelString("lab_vip","VIP"..self.data.vip)
    self:getNode("lab_vip"):getParent():layout()
    
    self:setRTFString("lab_help",gGetWords("activityNameWords.plist","vip_experience_help",self.data.vip
        ,self.data.vip
        ,self.data.vip))
    local size = table.getn(self.data.ids)/2
    for i = 1,4  do
        if i > size then
            self:getNode("icon"..i):setVisible(false)
        else
            self:getNode("icon"..i):setVisible(true)

            local idx = i*2-1
            local itemid = self.data.ids[idx]
            local itemnum = self.data.ids[idx+1]
            local icon=DropItem.new()
            icon:setData(itemid,DB.getItemQuality(itemid))
            icon:setNum(itemnum)
            icon:setAnchorPoint(cc.p(0.5,0.5))
            --icon.touch = false
            gAddChildByAnchorPos(self:getNode("icon"..i),icon,cc.p(0.5,0.5),cc.p(0,icon:getContentSize().height))
        end
        
    end
end

function ActivityVipExperiencePanel:isVipOwn()
    local owned = false
    if Data.getCurVip() >= self.data.vip or
        self.data.isget == true then
        owned = true
    end
    return owned
end

function ActivityVipExperiencePanel:refreshEndTime()
    -- 免费vip到期时间
    if self.data.isget == true then
        local function updateTime()
            if not self.data then
                return
            end
            
            local lefttime = self.data.remaintime - gGetCurServerTime()
            if lefttime <= 0 then
                lefttime = 0
                self:unscheduleUpdateEx()
            end
            local leftDay = gGetDayByLeftTime(lefttime)
            
            self:replaceLabelString("lab_leftday",leftDay)
            self:setLabelString("lab_lefthour",gParserHourTime(lefttime-24*60*60*leftDay))
            
            self:getNode("lab_lefthour"):getParent():layout()
        end

        local curtime = gGetCurServerTime()
        
        if self.data.remaintime > 0 and self.data.remaintime > curtime then
            self:scheduleUpdate(updateTime,1)
        end
        updateTime()
        self:getNode("lefttime_bg"):setVisible(true)
        self:setLabelString("lab_vip_dec",gGetWords("activityNameWords.plist","vip_exper_endtime"))
    else
        self:setLabelString("lab_vip_dec",gGetWords("activityNameWords.plist","vip_exper_dec",self.data.time,self.data.vip))
    end

    if self:isVipOwn() == true then
        self:setLabelString("lab_vip_get_status",gGetWords("btnWords.plist","btn_owned"))
        self:setTouchEnableGray("btn_vip_get",false)
    else
        if self.data.endtime < gGetCurServerTime() then
            self:setLabelString("lab_vip_get_status",gGetWords("btnWords.plist","btn_timeover"))
            self:setTouchEnableGray("btn_vip_get",false)
        else
            self:setLabelString("lab_vip_get_status",gGetWords("btnWords.plist","btn_get_reward"))
            self:setTouchEnableGray("btn_vip_get",true)
        end
        
    end
end

function ActivityVipExperiencePanel:refreshReward()
    if self.data.isgetrwd == true then
        self:getNode("btn_rwd_get_status0"):setVisible(false)
        self:getNode("btn_rwd_get_status1"):setVisible(true)
        self:setTouchEnableGray("btn_rwd_get",false)
    else
        -- 活动过期
        if self.data.endtime < gGetCurServerTime() then
            self:getNode("btn_rwd_get_status0"):setVisible(true)
            self:getNode("btn_rwd_get_status1"):setVisible(false)
            self:setTouchEnableGray("btn_rwd_get",false)
            self:setLabelString("btn_rwd_get_status0",gGetWords("btnWords.plist","btn_timeover"))
        else
            self:getNode("btn_rwd_get_status0"):setVisible(true)
            self:getNode("btn_rwd_get_status1"):setVisible(false)
            self:setTouchEnableGray("btn_rwd_get",true)

            if gUserInfo.vip < self.data.vip then
                -- 充值
                self:setLabelString("btn_rwd_get_status0",gGetWords("btnWords.plist","btn_pay"))
            else
                self:setLabelString("btn_rwd_get_status0",gGetWords("btnWords.plist","btn_get_reward"))
            end
        end
        
    end

    self:setLabelString("lab_rwd_dec",gGetWords("activityNameWords.plist","vip_exper_reward_dec",self.data.vip))
    self:replaceLabelString("lab_curvip",gUserInfo.vip)
end

function ActivityVipExperiencePanel:events() 
    return {
        EVENT_ID_GET_ACTIVITY_VIPEXP_INFO,
        EVENT_ID_GET_ACTIVITY_VIPEXP_GETVIP,
        EVENT_ID_GET_ACTIVITY_VIPEXP_GETRWD,
        EVENT_ID_USER_DATA_UPDATE
    }
end

function ActivityVipExperiencePanel:dealEvent(event,param) 
    if(event==EVENT_ID_GET_ACTIVITY_VIPEXP_INFO)then 
        self.data = param
        self:refresh()
        self:refreshEndTime()
        self:refreshReward()
    elseif(event==EVENT_ID_GET_ACTIVITY_VIPEXP_GETVIP)then
        self.data.isget = true
        self.data.remaintime = param.remaintime
        gUserInfo.fevip_vip = self.data.vip
        gUserInfo.fevip_endtime = param.remaintime

        self:refreshEndTime()

        Data.updateVipData()
        gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
    elseif(event==EVENT_ID_GET_ACTIVITY_VIPEXP_GETRWD)then
        self.data.isgetrwd = true
        self:refreshReward()
    elseif(event==EVENT_ID_USER_DATA_UPDATE)then
        self:refreshEndTime()
        self:refreshReward()
    end
end

function ActivityVipExperiencePanel:onTouchEnded(target)
    if  target.touchName=="btn_vip_dec"then
        Panel.popUp(PANEL_VIP)
    elseif target.touchName=="btn_vip_get"then
        if not self.data then
            return
        end

        if self.data.endtime < gGetCurServerTime() then
            gShowNotice(gGetWords("activityNameWords.plist","act_timeover"))
            return
        end

        if self:isVipOwn() == true then
            return
        end
        
        if self.data.isget == true then
            return
        end

        Net.sendActivityVipExperienceGetVip()
    elseif target.touchName=="btn_rwd_get" then
        if not self.data then
            return
        end

        if self.data.endtime < gGetCurServerTime() then
            gShowNotice(gGetWords("activityNameWords.plist","act_timeover"))
            return
        end

        if self.data.isgetrwd == true then
            return
        end

        if gUserInfo.vip < self.data.vip then
            Panel.popUp(PANEL_PAY)
        else
            Net.sendActivityVipExperienceGetRwd()
        end
        
    end
end

return ActivityVipExperiencePanel