local MallPanel=class("MallPanel",UILayer)

function MallPanel:ctor(type)
    self:init("ui/ui_mall.map")

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:getNode("scroll").offsetX=10

    self:getNode("scroll2").eachLineNum=2
    self:getNode("scroll2").offsetX=10
    self:getNode("scroll2").offsetY=12
    self:getNode("scroll2"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)


    self:clear()

    Data.activityRedPosLogin[ACT_TYPE_1001]=false
    RedPoint.setActivityRedpos(ACT_TYPE_1001,false)
    self.curType = 0
    local function _updateShopTime()
        self:updateShopTime();
    end
    self:scheduleUpdate(_updateShopTime,1)
    Net.sendGiftInit()
end
function MallPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end
function MallPanel:updateShopTime()
    -- print("updateShopTime");
    if(self.curType == MALL_TYPE_WEEK)then
        if(Data.activityWeekGiftInfo.refreshTime and Data.activityWeekGiftInfo.refreshTime == gGetCurServerTime())then
            Net.sendActivityWeekGiftInfo()
        end
        local endtime = 0
        if self.weekgift_info then
            endtime = self.weekgift_info.etime 
        end
        local lefttime = endtime - gGetCurServerTime()
        if lefttime < 0 then
            lefttime = 0
        end
        -- 剩余时间超过3个月，不显示剩余时间
        local word = ""
        if lefttime < 90*24*3600 then
            word = gGetWords("labelWords.plist","284",gParserDayHourTime(lefttime))
        end
        if(gCurLanguage == LANGUAGE_EN)then
            word = gGetWords("activityNameWords.plist","64")
        else
            word = word.." "..gGetWords("activityNameWords.plist","64")
        end
        self:setRTFString("txt_time",word)
    elseif(self.curType == MALL_TYPE_VIP_DAY)then
        local endtime = 0
        if self.daygift_info then
            endtime = self.daygift_info.etime 
        end
        local lefttime = endtime - gGetCurServerTime()
        if lefttime < 0 then
            lefttime = 0
        end
        -- 剩余时间超过3个月，不显示剩余时间
        local word = ""
        if lefttime < 90*24*3600 then
            word = gGetWords("labelWords.plist","284",gParserDayHourTime(lefttime))
        end
        self:setRTFString("txt_time",word)
    elseif(self.curType == MALL_TYPE_PAY)then
        local date=gGetCurDay() 
        local time=(24*60*60-date.hour*60*60-date.min*60-date.sec) 
        self:setRTFString("txt_time",gGetWords("labelWords.plist","284",gParserHourTime(time)))
    end 
end
function MallPanel:createMenuItem(type,name)
    local data1 = {}
    data1.name = gGetWords("activityNameWords.plist",name)
    data1.type = type
    local item1=MallMenuItem.new()
    item1:setData(data1)
    item1.onSelectCallback=function(data)
        self:setCurActivity(data)
    end
    item1.name = name;
    return item1
end

function MallPanel:getMenuItemByName(name)
    local allItem = self:getNode("scroll"):getAllItem();
    for key,item in pairs(allItem) do
        if item.name == name then
            return item;
        end
    end
    return nil;
end

function MallPanel:initActivitys()


    self:getNode("scroll"):addItem(self:createMenuItem(MALL_TYPE_PAY,"name_pay_gift"))
    -- VIP 礼包都买过一遍
    if(self:isBuyAll())then
        if(not Module.isClose(MALL_TYPE_WEEK)
            and self.weekgift_info 
            and self.weekgift_info.etime > gGetCurServerTime() )then
            self:getNode("scroll"):addItem(self:createMenuItem(MALL_TYPE_WEEK,"name_week_gift"))
        end
        if(not Module.isClose(SWITCH_VIP))then
            self:getNode("scroll"):addItem(self:createMenuItem(MALL_TYPE_VIP,"name_vip_gift"))
        end
    else
        if(not Module.isClose(SWITCH_VIP))then
            self:getNode("scroll"):addItem(self:createMenuItem(MALL_TYPE_VIP,"name_vip_gift"))
        end
        if(not Module.isClose(MALL_TYPE_WEEK)
            and self.weekgift_info 
            and self.weekgift_info.etime > gGetCurServerTime() )then
            self:getNode("scroll"):addItem(self:createMenuItem(MALL_TYPE_WEEK,"name_week_gift"))
        end
    end

    if(not Module.isClose(SWITCH_VIP) 
        and self.daygift_info 
        and self.daygift_info.etime > gGetCurServerTime() )then
        self:getNode("scroll"):addItem(self:createMenuItem(MALL_TYPE_VIP_DAY,"name_vip_day_gift"))
    end

    self:getNode("scroll"):layout()
    self:selectFirstMenu()
end

function MallPanel:selectFirstMenu()
    if(table.getn(self:getNode("scroll").items)~=0)then
        self:setCurActivity(self:getNode("scroll").items[1].curData)
    end
end

function  MallPanel:setCurActivity(data)
    local type=data.type
    self.curType = type
    if(type == MALL_TYPE_VIP)then
        self:createVipGiftList()
    elseif(type == MALL_TYPE_WEEK)then
        if((Data.activityWeekGiftInfo.list == nil) or table.getn(Data.activityWeekGiftInfo.list) == 0)then
            Net.sendActivityWeekGiftInfo()
        else
            self:createWeekGiftList()
        end
    elseif(type == MALL_TYPE_PAY)then
        self:createPayGiftList()
    elseif(type == MALL_TYPE_VIP_DAY)then
        self:createVipDayGiftList()
    end

    self:refreshSelectItem()
    self:updateShopTime();
end


function  MallPanel:refreshSelectItem()
    for key, item in pairs(self:getNode("scroll").items) do
        if(item.curData.type==self.curType)then
            item:setSelect(true)
        else
            item:setSelect(false)
        end
    end
end

function  MallPanel:events()
    return
        {
            EVENT_ID_GIFT_GIFT_INIT,
            EVENT_ID_GIFT_BAG_GOT,
            EVENT_ID_GET_ACTIVITY_WEEK_GIFT,
            EVENT_ID_GET_ACTIVITY_WEEK_GIFT_GET
        }
end


function MallPanel:dealEvent(event,param)
    if(event==EVENT_ID_GIFT_GIFT_INIT)then
        if param then
            for k,v in pairs(param) do
                if v.type == 86 then
                -- vip周礼包
                self.weekgift_info = v
                elseif v.type == 87 then
                -- vip日礼包
                self.daygift_info = v
                end
            end
        end
        self:initActivitys()
        self:selectFirstMenu()
        self:updateShopTime();
    elseif(event==EVENT_ID_GIFT_BAG_GOT)then
        if(table.getn(self:getNode("scroll2").items) > 0)then
            self:refreshData(param) 
        end
    elseif(event==EVENT_ID_GET_ACTIVITY_WEEK_GIFT)then
        self:createWeekGiftList()
    elseif(event==EVENT_ID_GET_ACTIVITY_WEEK_GIFT_GET)then
        self:refreshData(param)
    end
end

function MallPanel:onPopup()
end

function MallPanel:isBuyAll()
    for key, var in pairs(vip_db) do
        local item= Data.getGiftBagBuy(var.boxid)
        if(item and item.num<=0)then
            return false
        end
    end
    return true
end



function MallPanel:sortVipGiftList()
    local sortItemFunc = function(a, b)
        local itemA= Data.getGiftBagBuy(a.curData.boxid)
        local itemB= Data.getGiftBagBuy(b.curData.boxid)
        local numA = 0
        local numB = 0
        if(itemA)then
            numA = itemA.num
        end
        if(itemB)then
            numB = itemB.num
        end

        if(numA == numB)then
            if(a.curData.vip < b.curData.vip)then
                return true
            else
                return false
            end
        else
            if(numA < numB)then
                return true
            else
                return false
            end
        end
    end
    table.sort(self:getNode("scroll2").items, sortItemFunc)
end

function MallPanel:clear()

    self:getNode("txt_desc"):setVisible(false)
    self:getNode("time_bg"):setVisible(false)
    self:getNode("scroll2"):clear()
    self:getNode("container"):removeAllChildren()
end

function MallPanel:createPayGiftList()
    self:clear()
    self.curType = MALL_TYPE_PAY
    self:getNode("time_bg"):setVisible(true)
    self:refreshSelectItem()
    local item=MallPayPanel.new()
    self:getNode("container"):addChild(item)
end

function MallPanel:createVipGiftList()
    self:clear()
    self.curType = MALL_TYPE_VIP
    self:refreshSelectItem()
    for key, var in pairs(vip_db) do
        local item=VipGiftItem.new()
        item:setData(var)
        self:getNode("scroll2"):addItem(item)
    end
    self:sortVipGiftList();
    self:getNode("scroll2"):layout()
end

function MallPanel:createVipDayGiftList()
    self:clear()
    self.curType = MALL_TYPE_VIP_DAY
    self:refreshSelectItem()

    local endtime = 0
    if self.daygift_info then
        endtime = self.daygift_info.etime 
    end
    local lefttime = endtime - gGetCurServerTime()
    if lefttime < 0 then
        lefttime = 0
    end
    -- 剩余时间超过3个月，不显示剩余时间
    if lefttime < 90*24*3600 then
        self:getNode("time_bg"):setVisible(true)
    end

    

    Data.activityRedPosLogin[ACT_TYPE_1002]=false
    RedPoint.setActivityRedpos(ACT_TYPE_1002,false)
    
    -- gPrintLuaTable = true;
    -- print("----------------------")
    local gift=DB.getVipDayGift()
    for key, var in pairs(gift) do
        local item=VipDayGiftItem.new()
        item:setData(var)
        self:getNode("scroll2"):addItem(item)
        item.endtime = self.daygift_info.etime
    end
    self:sortVipGiftList();
    self:getNode("scroll2"):layout()
end

function MallPanel:createWeekGiftList()
    self:clear()
    self.curType = MALL_TYPE_WEEK
    self:refreshSelectItem()
    self:getNode("txt_desc"):setVisible(true)
    self:getNode("time_bg"):setVisible(true)
    for key, var in pairs(Data.activityWeekGiftInfo.list) do
        local item=WeekGiftItem.new()
        item:setData(var)
        self:getNode("scroll2"):addItem(item)
        item.endtime = self.weekgift_info.etime
    end
    self:getNode("scroll2"):layout()
end


function MallPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

function MallPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll2").items) do
        item:refreshData(param)
    end
end

return MallPanel