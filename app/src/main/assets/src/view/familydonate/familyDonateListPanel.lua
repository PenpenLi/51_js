local FamilyDonateListPanel=class("FamilyDonateListPanel",UILayer)

function FamilyDonateListPanel:ctor()
    self:init("ui/ui_family_juanzeng.map")
    self.maxNum = DB.getClientParam("FAMILY_DONATE_NUM_MAX",true)
    self.donateAllAskTime  =0 

    self.donateRestTimes = DB.getClientParamToTable("FAMILY_DONATE_RESET_ASK_TIME",true)
    for i=1,table.count(self.donateRestTimes) do
        if 0 == self.donateRestTimes[i] then
            self.donateRestTimes[i] =24
        end 
    end
    function sortFunc(param1,param2)
        return toint(param1)<toint(param2)
    end
    table.sort(self.donateRestTimes,sortFunc)
    self.passTime = 0
    self.leftTime = 0
    self.refreshListTime = gGetCurServerTime()
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        elseif event == "exit" then
            self:onExit();
        end
    end
    self:getNode("scroll"):clear()
    self:getNode("scroll"):setPaddingXY(2,5)
    self:getNode("scroll").offsetX = 0
    self:getNode("scroll").offsetY = 3
    self:getNode("bg_kong"):setVisible(false)
    self:registerScriptHandler(onNodeEvent);
    Net.sendFamilyDonateList()
end

function FamilyDonateListPanel:onEnter()
    
    local function updatePer()
        if self.passTime>0 then
           self:refreshLeftTime()
        end
        if Panel.isTopPanel(PANEL_FAMILY_DONATE_LIST) then
            if gGetCurServerTime() - self.refreshListTime >= 10  then
                self.refreshListTime = gGetCurServerTime()
                Net.sendFamilyDonateList()
            end
        end
    end
    self:scheduleUpdateWithPriorityLua(updatePer,1)

end

function FamilyDonateListPanel:onExit()
    self:unscheduleUpdate()
end



function FamilyDonateListPanel:onTouchEnded(target)

    if  target.touchName=="btn_beg" then
        if self.leftTime >0 then
            gShowNotice(gGetWords("familyWords.plist","family_cdtime"));
        else
             Panel.popUp(PANEL_FAMILY_DONATE_CARD_FRAG);
         end
    elseif target.touchName=="btn_close" then
       self:onClose();
    elseif target.touchName=="btn_rule" then
       gShowRulePanel(SYS_FAMILY_DONATE);
    end
end

function FamilyDonateListPanel:events()
    return {EVENT_ID_FAMILY_DONATE_LIST,EVENT_ID_FAMILY_DONATE_HELP}
end

function FamilyDonateListPanel:dealEvent(event,param)
    if(event==EVENT_ID_FAMILY_DONATE_LIST)then
        self:setData();
        self.refreshListTime = gGetCurServerTime()
    elseif (event==EVENT_ID_FAMILY_DONATE_HELP) then
         gShowNotice(gGetWords("familyWords.plist","family_help_notice"));
    end
end

function FamilyDonateListPanel:refreshLeftTime()

    self.leftTime = self.donateAllAskTime - (gGetCurServerTime() - self.passTime)
    local lefttime = self.leftTime
    if lefttime < 0 then
        lefttime = 0
    end
    self:setLabelString("txt_time", gParserHourTime(lefttime))
end


function FamilyDonateListPanel:removeDonateListItem(item)
    self:getNode("scroll"):removeItem(item,true)
    self:getNode("scroll"):layout(false)
end


function FamilyDonateListPanel:getItemByData(data)
    for key, item in pairs(self:getNode("scroll").items) do
        if(item.curData.id==data.id)then
            return item
        end
    end
    return nil

end

function FamilyDonateListPanel:setData()
    
    
    if(table.count(Data.donateList.list)<=0) then
        self:getNode("bg_kong"):setVisible(true)
    end

    self.passTime = Data.donateList.atime
    if self.passTime>0 then
        for k,hour in pairs(self.donateRestTimes) do
            self.donateAllAskTime = gGetLeftTimeByTime(self.passTime,hour)
            if self.donateAllAskTime >0 then
                break
            end
        end
    end
       
    self:refreshLeftTime()

    self:setLabelString("txt_num",Data.donateList.donNum.."/"..self.maxNum)

    function donateListItemCallback(item )
        self:removeDonateListItem(item)
    end

    for key, item in pairs(self:getNode("scroll").items) do
        item.del=true
    end

    local curUserid = Data.getCurUserId()
    for i, donateDetail in ipairs(Data.donateList.list) do
        local item=self:getItemByData(donateDetail)
        if item == nil then
            item = FamilyDonateListItem.new()
            item.donateAskTime = donateDetail.time
            item.updateDonateListCallback = donateListItemCallback
            item.sort = 2
            if donateDetail.userid == curUserid then
                item.sort = 1
                item.isMe = true
            end
            item:setData(donateDetail)
            self:getNode("scroll"):addItem(item)
        else
            item.donateAskTime = donateDetail.time
            item:setData(donateDetail)
            item.del=false
        end
    end

    local sortfunc = function(item1,item2)
        if item1.sort == item2.sort then
            return item1.donateAskTime < item2.donateAskTime 
        else
            return item1.sort < item2.sort
        end
    end

    for key, item in pairs(self:getNode("scroll").items) do
        if(item.del==true)then
            self:getNode("scroll"):removeItem(item,false)
        end
    end
    self:getNode("scroll"):sortItems(sortfunc);

    self:getNode("scroll"):layout(false)
end

return FamilyDonateListPanel