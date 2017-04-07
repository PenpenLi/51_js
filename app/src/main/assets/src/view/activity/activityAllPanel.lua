local ActivityAllPanel=class("ActivityAllPanel",UILayer)

function ActivityAllPanel:ctor(data)

    self:init("ui/ui_hd_di.map")

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:getNode("scroll").offsetX=10

    self:getNode("time_bg"):setVisible(false);
    
    if (data and data.type) then
        self.type = data.type
        if (data.icon) then
            self.icon = data.icon
        end
    elseif (data and data.bolNewYear) then
        self.bolNewYear = data.bolNewYear
    elseif (data and data.bolFestival) then
        self.bolFestival = data.bolFestival
    elseif (data and data.bolHefu) then
        self.bolHefu = data.bolHefu
    end

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);

    if (data and data.bolRank) then
        self.bolRank = data.bolRank
        Net.sendActivityAll(1)
    else
        Net.sendActivityAll()
    end
end

function ActivityAllPanel:onExit()
    self:unscheduleUpdateEx()
    self:onUILayerExit()
end

function ActivityAllPanel:isInIgnore(aname)
    for i=1, 4 do
        local name= gGetWords("activityNameWords.plist","appstore_ingore_title"..i)
        if(name==aname and aname~="")then
            return true
        end
    end
    return false
end

function ActivityAllPanel:isInLimit(aname)
    for i=1, 4 do
        local name= gGetWords("activityNameWords.plist","appstore_limit_title"..i)
        if(name==aname and aname~="")then
            return true
        end
    end
    return false
end


function ActivityAllPanel:initActivitys()

    local function Activity(value)
        if(value.name=="" and gGetWords("activityNameWords.plist","name"..value.type))then
            if (value.param>=100) then value.param = math.floor(value.param/10) end --倍数
            local showParam = value.param/10;
            if(value.type == ACT_TYPE_114)then
                showParam = gGetDiscount(value.param/10);
            end
            value.name=gGetWords("activityNameWords.plist","name"..value.type,showParam)
        end
        local item=ActivityMenuItem.new()
        item:setData(value)
        item.onSelectCallback=function (data)
            if(self:isInLimit(data.name) and  gNoticeAppstoreUpdate())then
                return
            end
            self:setCurActivity(data)
        end
        self:getNode("scroll"):addItem(item)
    end
    for key, value in pairs(Data.activityAll) do
        local ignore=false
        if(self:isInIgnore(value.name) and  not gIsShowUpdateActivity())then
            ignore=true
        end
        if(ignore==false)then
            if (self.bolNewYear) then
                if (1==value.param3) then
                    Activity(value)
                end
            elseif (self.bolFestival) then
                if (2==value.param3) then
                    Activity(value)
                end
            elseif (self.bolHefu) then
                if (3==value.param3) then
                    Activity(value)
                end
            else
                if (value.param3<=0) then
                    Activity(value)
                end
            end
        end
    end
    self:getNode("scroll"):layout()

    local size = table.getn(self:getNode("scroll").items)
    if(size~=0)then
        local index = 1
        if (self.type) then
            index = 1
            if (self.icon) then
                index = self:getActTypeIndex(self.type,self.icon)
            else
                index = self:getActTypeIndex(self.type)
            end
            if (index>size) then
                index = 1
            end
        end
        self:setCurActivity(self:getNode("scroll").items[index].curData)

        if (index>4) then
            local tmpIndex = index-4
            local itemWidth=self:getNode("scroll").itemWidth
            local offsetX=0--self:getNode("scroll").offsetX
            self:getNode("scroll").container:setPositionX(-(offsetX+itemWidth)*tmpIndex)
        end
    else
        if (self.bolNewYear or self.bolFestival or self.bolHefu or self.bolRank) then
            --提示活动结束
            local sWord = gGetWords("activityNameWords.plist","act_eat7");
            local function onOk()
                if self.bolNewYear then
                    gDispatchEvt(EVENT_ID_SHOW_ACTIVITY_NEWYER,1)
                elseif self.bolFestival then
                    gDispatchEvt(EVENT_ID_SHOW_ACTIVITY_FESTIVAL,1)
                elseif self.bolHefu then
                    gDispatchEvt(EVENT_ID_SHOW_ACTIVITY_HEFU,1)
                else
                    gDispatchEvt(EVENT_ID_SHOW_ACTIVITY_RANK)
                end
                Panel.popBack(self:getTag())
            end
            gConfirm(sWord,onOk)
        end
    end
end

--此方法只适合固定活动
function ActivityAllPanel:getActTypeIndex(type,icon)
    if (icon) then
        for k,v in pairs(self:getNode("scroll").items) do
            if (v.curData.type == type and v.curData.icon == icon) then
                return k
            end
        end
    end
    for k,v in pairs(self:getNode("scroll").items) do
        if (v.curData.type == type) then
            return k
        end
    end
    return 1
end

function  ActivityAllPanel:events()
    return
        {
            EVENT_ID_GET_ACTIVITY_ALL,
            EVENT_ID_GET_ACTIVITY_7_DAY,
            EVENT_ID_GET_ACTIVITY_7_DAY_GET,
            EVENT_ID_GET_ACTIVITY_LEVEL_UP,
            EVENT_ID_GET_ACTIVITY_LEVEL_UP_GET,
            EVENT_ID_GET_ACTIVITY_INVEST,
            EVENT_ID_GET_ACTIVITY_INVEST_GET,
            EVENT_ID_GET_ACTIVITY_INVEST_BUY,
            EVENT_ID_GET_ACTIVITY_INVEST2,
            EVENT_ID_GET_ACTIVITY_INVEST2_GET,
            EVENT_ID_GET_ACTIVITY_INVEST2_BUY,
            EVENT_ID_GET_ACTIVITY_SALEOFF,
            EVENT_ID_GET_ACTIVITY_SALEOFF_BUY,
            EVENT_ID_GET_ACTIVITY_EXPENSE_RETURN,
            EVENT_ID_GET_ACTIVITY_EXPENSE_RETURN_GET,
            EVENT_ID_GET_ACTIVITY_PAY,
            EVENT_ID_GET_ACTIVITY_PAY_GET,
            EVENT_ID_GET_ACTIVITY_CHARGE_RETURN,
            EVENT_ID_GET_ACTIVITY_CHARGE_RETURN_GET,
            EVENT_ID_USER_DATA_UPDATE,
            EVENT_ID_GET_ACTIVITY_TXT,
            EVENT_ID_GET_ACTIVITY_CAT,
            EVENT_ID_GET_ACTIVITY_VIP,
            EVENT_ID_GET_ACTIVITY_WISH,
            EVENT_ID_GET_ACTIVITY_WISH_ADD_REWARD,
            EVENT_ID_GET_ACTIVITY_WISH_REC_REWARD,
            EVENT_ID_GET_ACTIVITY_WISH_REFRESH,
            EVENT_ID_GET_ACTIVITY_EXCHANGE,
            EVENT_ID_GET_ACTIVITY_EXCHANGE_REC,
            EVENT_ID_GET_ACTIVITY_TUAN,
            EVENT_ID_GET_ACTIVITY_TUAN_GET,
            EVENT_ID_GET_ACTIVITY_SHARE_GET_INFO,
            EVENT_ID_GET_ACTIVITY_SHARE_REC,
            EVENT_ID_GET_ACTIVITY_EAT_BUN,
            EVENT_ID_GET_ACTIVITY_EAT_BUN_INFO,
            EVENT_ID_GET_ACTIVITY_EAT_BUN_STATUS,
            EVENT_ID_GET_ACTIVITY_SIGNINFO,
            EVENT_ID_GET_ACTIVITY_SIGNREFRESH,
            EVENT_ID_GET_ACTIVITY_17,
            EVENT_ID_GET_ACTIVITY_17_REC,
            EVENT_ID_GET_ACTIVITY_19,
            EVENT_ID_GET_ACTIVITY_19_REC,
            EVENT_ID_GET_ACTIVITY_97_GETINFO ,
            EVENT_ID_GET_ACTIVITY_97_BOXREWARD ,
            EVENT_ID_GET_ACTIVITY_97_DAYREWARD ,
            EVENT_ID_GET_ACTIVITY_96,
            EVENT_ID_GET_ACTIVITY_RED_PACKAGE,
            EVENT_ID_REFRESH_ACTIVITY_DAYTASK,
            EVENT_ID_GET_ACTIVITY_DAYTASK,
            EVENT_ID_GET_ACTIVITY_23,
            EVENT_ID_GET_ACTIVITY_23_REC,
            EVENT_ID_GET_ACTIVITY_26,
            EVENT_ID_GET_ACTIVITY_26_REC,
            EVENT_ID_GET_ACTIVITY_RECRUIT_INFO,
            EVENT_ID_GET_ACTIVITY_RECRUIT,
            EVENT_ID_GET_ACTIVITY_RECRUIT_REC,
            EVENT_ID_GET_ACTIVITY_PUBLISH,
            EVENT_ID_GET_ACTIVITY_VIPEXP_INFO,
            EVENT_ID_GET_ACTIVITY_VIPEXP_GETVIP,
            EVENT_ID_GET_ACTIVITY_VIPEXP_GETRWD,
            EVENT_ID_GET_ACTIVITY_10,
            EVENT_ID_GET_ACTIVITY_10_REC,
            EVENT_ID_GET_ACTIVITY_GETINFO_28,
            EVENT_ID_GET_ACTIVITY_28_REC,
            EVENT_ID_GET_ACTIVITY_SNATCH_INFO,
            EVENT_ID_GET_ACTIVITY_SNATCH_UPDATESCORE,
            EVENT_ID_GET_ACTIVITY_GETINFO_29,
            EVENT_ID_GET_ACTIVITY_29_REC,

        }
end

function ActivityAllPanel:showTime(param)
    -- print("------showTime------")
    self:unscheduleUpdateEx();
    self:setLabelString("txt_time","")
    self:getNode("time_bg"):setVisible(false);
    self:getNode("layout_time"):setSortByPosFlag(false);
    self.endTime = 0;
    if(param.type == ACT_TYPE_127 and Data.signInfo.today)then
        local leftDay = 30 - Data.getSignTodayThisMonth();
        -- if(Data.signInfo.today > 30)then
        --     leftDay = 60 - Data.signInfo.today;
        -- else
        --     leftDay = 30 - Data.signInfo.today;
        -- end
        -- print("leftDay = "..leftDay);
        -- print("gGetLeftTimeToday = "..gGetLeftTimeToday());
        param.endtime = gGetCurServerTime() + leftDay*24*60*60 + gGetLeftTimeToday();
        self.endTime = param.endtime;
        self:setLabelString("txt_flag_time",gGetWords("labelWords.plist","286"));
    elseif (param.type == ACT_TYPE_17 and Data.activity17Data) then
        if (Data.activity17Data.endtime>=gGetCurServerTime()) then--有充值时间
            param.endtime = Data.activity17Data.endtime
            self:setLabelString("txt_flag_time",gGetWords("labelWords.plist","289"));
        else
            self:setLabelString("txt_flag_time",gGetWords("labelWords.plist","289-1"));
            local actData = Data.getActivityByType(ACT_TYPE_17)
            if (actData and actData.endtime) then
                param.endtime = actData.endtime
            end
        end
    else
        self:setLabelString("txt_flag_time",gGetWords("labelWords.plist","285"));
    end
    if(param and param.begintime and param.endtime)then
        self:getNode("time_bg"):setVisible(true)
        -- local txt=gGetWords("labelWords.plist","lb_hd_activity_time",gParserDay(param.begintime),gParserDay(param.endtime))
        -- self:setLabelString("txt_time",txt)
        if(param.begintime <= gGetCurServerTime())then
            self.endTime = param.endtime;
        end
    elseif (param and param.endtime) then
        self:getNode("time_bg"):setVisible(true)
        -- local txt=gGetWords("labelWords.plist","lb_hd_activity_time_left",gParserDay(param.endtime))
        -- self:setLabelString("txt_time",txt)
        self.endTime = param.endtime;
    end
    
    self.leftDay = 0;
    self.reLayout = true;
    self.preTimeStatue = 0;
    self.preLeftDay = 0;
    if(self.endTime >= gGetCurServerTime())then
        -- print("@@@@@@@");
        local function updateTime()
            self.leftDay = gGetDayByLeftTime(self.endTime - gGetCurServerTime());
            -- print("self.leftDay = "..self.leftDay);
            if(self.leftDay > 0)then
                if(self.leftDay ~= self.preLeftDay)then
                    self.preLeftDay = self.leftDay;
                    self:replaceLabelString("txt_day",self.leftDay);
                    self:getNode("txt_day"):setVisible(true);
                end
                self.preTimeStatue = 1;
            else
                self:getNode("txt_day"):setVisible(false);
                if(self.preTimeStatue ~= 2)then
                    self.reLayout = true;
                end
                self.preTimeStatue = 2;
            end
            if(self.endTime>=gGetCurServerTime())then
                self:setLabelString("txt_refresh_time2", gParserHourTime(self.endTime - gGetCurServerTime() - self.leftDay*24*60*60))
                local time = math.max(self.endTime-gGetCurServerTime(),0)
                if (time==0) then
                    self.endTime = 0
                    self:setOverTime()
                    self.reLayout = true;
                end
            end
            if(self.reLayout)then
                print("#############");
                self.reLayout = false;
                self:getNode("layout_time"):layout();
            end
        end
        self:scheduleUpdate(updateTime,1)
    else
        if (param.type == ACT_TYPE_92) then
            self:getNode("time_bg"):setVisible(false)
        else
            self:setOverTime()
        end
    end

    self:getNode("layout_time"):layout();
    self:resetAdaptNode();
end

function ActivityAllPanel:setOverTime()
    self:getNode("txt_day"):setVisible(false);
    self:setLabelString("txt_flag_time","");
    local strWord = gGetWords("activityNameWords.plist","act_eat7")
    self:setLabelString("txt_refresh_time2",strWord)--活动已结束
end

function ActivityAllPanel:dealEvent(event,param)
    -- print("ActivityAllPanel event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_ALL)then
        self:initActivitys()
        return
    end
    if (event ~= EVENT_ID_GET_ACTIVITY_CAT and event ~= EVENT_ID_USER_DATA_UPDATE) then
    -- self:showTime(param)
    end

    if( self.curPanel and self.curPanel.dealEvent)then
        self.curPanel.allPanel = self;
        self.curPanel:dealEvent(event,param)
    end


    if(event==EVENT_ID_GET_ACTIVITY_WISH)then
        self:showTime(self.curPanel.curData)
    end


end


function ActivityAllPanel:onPopup()
    if(self.curPanel and self.curPanel.onPopup)then
        self.curPanel:onPopup()
    end
end

function ActivityAllPanel:onPopback()
    if(self.curPanel and self.curPanel.onPopback)then
        self.curPanel:onPopback()
    end
end

function ActivityAllPanel:createActivity(type,data)
    if(type==ACT_TYPE_83)then
        return ActivitySoullifeSaleOffPanel.new(data)
    elseif(type==ACT_TYPE_30)then
        return ActivityBuyConDiscount.new(data)
    elseif(type==ACT_TYPE_113)then
        return Activity7DayPanel.new(data)
    elseif(type==ACT_TYPE_104)then
        return ActivityLevelUpPanel.new(data)
    elseif(type==ACT_TYPE_107)then
        return ActivityInvestPanel.new(data)
    elseif(type==ACT_TYPE_92)then
        return ActivityInvest2Panel.new(data)
    elseif(type==ACT_TYPE_7)then
        return ActivitySaleOffPanel.new(data)
    elseif(type==ACT_TYPE_26)then
        return ActivityXiaoChuGiftPanel.new(data)
    elseif(type==ACT_TYPE_29)then
         return ActivityMultiItemPanel.new(data)
    elseif(type==ACT_TYPE_108)then
        return ActivityIapCard.new(data)
    elseif(type==ACT_TYPE_8)then
        return ActivityCatPanel.new(data)
    elseif(type==ACTIVITY_TYPE_CONSUME)then
        return ActivityConsumePanel.new(data)
    elseif(type==ACT_TYPE_3)then
        if (data.icon == 3) then
            return ActivityPayPanel.new(data)
        else
            return ActivityExpenseReturnPanel.new(data)
        end
    elseif(type==ACT_TYPE_6)then
        return ActivityChargeReturnPanel.new(data)
    elseif(type==ACT_TYPE_115 or type==ACT_TYPE_81 )then
        return ActivityAtlasDoublePanel.new(data)
    elseif(type==ACT_TYPE_114)then
        return ActivityDrawCardPanel.new(data)
    elseif(type==ACT_TYPE_99)then
        return ActivityVipPanel.new(data)
    elseif(type==ACT_TYPE_116)then
        return ActivityWishPanel.new(data)
    elseif(type==ACT_TYPE_117)then
        return ActivityBuyGoldCriticalPanel.new(data)
    elseif(type==ACT_TYPE_118)then
        return ActivityBuyEnergyLimitPanel.new(data)
    elseif(type==ACT_TYPE_121)then
        return ActivityPayResetPanel.new(data)
    elseif(type==ACT_TYPE_119)then
        return ActivityBuyEnergySaleOffPanel.new(data)
    elseif(type==ACT_TYPE_120)then
        return ActivitySaleOffLimitPanel.new(data)
    elseif(type==ACT_TYPE_1)then
        return ActivityExchangePanel.new(data)
    elseif(type==ACT_TYPE_2)then
        return ActivityExpenseReturnPanel.new(data)
    elseif(type==ACT_TYPE_122)then
        return ActivityAtlasResetPanel.new(data)
    elseif(type==ACT_TYPE_15)then
        return ActivityTuanPanel.new(data)
    elseif(type==ACT_TYPE_82)then
        return ActivitySnatchPanel.new(data)
    elseif(type==ACT_TYPE_123)then
        return ActivityBathDoublePanel.new(data)
    elseif(type==ACT_TYPE_124)then
        return ActivityFamilyActPanel.new(data)
    elseif(type==ACT_TYPE_125)then
        return ActivityEnargyPanel.new(data)
    elseif(type==ACT_TYPE_126) then
        return ActivitySharePanel.new(data)
            -- return ActivitySignPanel.new(data);
    elseif(type==ACT_TYPE_127)then
        return ActivitySignPanel.new(data);
    elseif (type==ACT_TYPE_28) then
        return ActivityLoginRewardPanel.new(data);
    elseif(type==ACT_TYPE_17)then
        return Activity17Panel.new(data);
    elseif(type==ACT_TYPE_97)then
        return ActivitySign7Panel.new(ACT_TYPE_97);
    elseif(type==ACT_TYPE_98)then
        return ActivitySign7Panel.new(ACT_TYPE_98);
    elseif(type==ACT_TYPE_96)then
        return ActivityNewYearEnergyPanel.new(data);
    elseif(type==ACT_TYPE_95)then
        return ActivityTaskDayPanel.new(data);
    elseif(type==ACT_TYPE_19)then
        return Activity19Panel.new(data);
    elseif(type==ACT_TYPE_20)then
        return ActivityRedPackagePanel.new(data);
    elseif(type==ACT_TYPE_94)then
        return ActivityDoubleDiaPanel.new(ACT_TYPE_94)
    elseif(type==ACT_TYPE_23)then
        return ActivityFreeVipPanel.new(data)
    elseif(type==ACT_TYPE_93)then
        return ActivityRecruitPanel.new(data)
    elseif(type==ACT_TYPE_88)then
        return ActivityVipExperiencePanel.new(data)
    elseif(type==ACT_TYPE_89)then
        return ActivityItemDropPanel.new(data)
    elseif(type==ACT_TYPE_11 or type==ACT_TYPE_13 or type==ACT_TYPE_27) then
        return ActivityRankPanel.new(data)
    end
end


function  ActivityAllPanel:setCurActivity(data)

    if(self.curPanel and self.curPanel.onPopback)then
        self.curPanel:onPopback()
    end

    local type=data.type
    print("type="..type)
    local panel=self:createActivity(type,data)
    self:getNode("container"):removeAllChildren()
    if(panel)then
        self:getNode("container"):addChild(panel)
        if(panel.showTime)then
            panel:showTime(data)
        end
    end

    self:showTime(data)
    for key, item in pairs(self:getNode("scroll").items) do
        if(item.curData.type==type and item.curData.actId ==data.actId)then
            item:setSelect(true)
        else
            item:setSelect(false)
        end
    end
    self.curPanelType=type
    self.curPanel=panel
end


function ActivityAllPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return ActivityAllPanel