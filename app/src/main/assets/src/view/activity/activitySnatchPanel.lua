local ActivitySnatchPanel=class("ActivitySnatchPanel",UILayer)

function ActivitySnatchPanel:ctor(data)
    self:init("ui/ui_hd_duobao.map") 
    self.curData=data
    self.curSelectIndex = 0
    self.itemName={}
    Data.activityActid = self.curData.actId
    Net.sendActivitySnatchInfo()

    self.refreshListTime = gGetCurServerTime()

    local function updatePer()
        if gGetCurServerTime() - self.refreshListTime >= 5  then
            self.refreshListTime = gGetCurServerTime()
            Net.sendActivitySnatchInfo()
        end
    end
    self:scheduleUpdateWithPriorityLua(updatePer,1)
    self:getNode("notice_scroll").maxid =0
end

function ActivitySnatchPanel:onPopup()

end

function ActivitySnatchPanel:onTouchEnded(target)
    if(target.touchName=="btn_bet")then
        local value = Data.activitySnatchData.list[self.curSelectIndex]
        local callback = function(num)
            Net.sendActivitySnatch(value.idx,value.curturn,num);
        end
        --  local data = {};
        -- data.type = VIP_ACTIVITY_SNATCH;
        -- data.buyCallback = callback;
        -- Panel.popUpVisible(PANEL_VIP_BUYTIMES,data);
        --Data.setUsedTimes(VIP_ACTIVITY_SNATCH,value.maxunm-value.curnum )
        Data.vip.snatchact.maxUseTimes = value.maxunm-value.curnum
        Data.canBuyTimes(VIP_ACTIVITY_SNATCH,true,callback)
    elseif target.touchName== "btn_change" then
        Panel.popUp(PANEL_SHOP,SHOP_TYPE_SNATCH)
    elseif string.find(target.touchName,"icon") ~= nil then
        local index = toint(string.sub(target.touchName,string.len(target.touchName)))
        self:selectIndex(index)
    elseif target.touchName== "btn_rule" then
        gShowRulePanel(SYS_SNATCH_ACTIVITY);
    end
end

function ActivitySnatchPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function ActivitySnatchPanel:selectIndex(index)
    self.curSelectIndex = index
    for i=1,4 do
        self:getNode("select_ka"..i):setVisible(false)
    end
    local value = Data.activitySnatchData.list[index]
    if value then
        self:getNode("select_ka"..index):setVisible(true)
        self:getNode("role_show"):removeAllChildren()
        self:setLabelString("txt_per",value.curnum.."/"..value.maxunm)
        local per=value.curnum/value.maxunm
        self:setBarPer("bar",per)
        --local itemName = DB.getItemName(value.idx,true)
        self:setLabelString("txt_waitname",value.itemname)
        self:getNode("bg_waits"):setVisible(false)
        self:getNode("item_show"):setVisible(false)
        local itemType = DB.getItemType(value.idx)
        if itemType == ITEMTYPE_CARD_SOUL or itemType == ITEMTYPE_CARD then
            local litemid = value.idx
            if itemType == ITEMTYPE_CARD_SOUL or itemType ==ITEMTYPE_PET_SOUL then
                litemid =litemid-ITEM_TYPE_SHARED_PRE
            end
            local role = gCreateFlaDislpay("r"..litemid.."_wait",1,"r"..litemid.."_wait");
            gAddCenter(role, self:getNode("role_show"))
            local cardDb = DB.getCardById(litemid)
            self:getNode("bg_waits"):setVisible(toint(cardDb.supercard)== 1)
        elseif   itemType ==ITEMTYPE_PET or itemType ==ITEMTYPE_PET_SOUL then
            local litemid = value.idx
            if itemType ==ITEMTYPE_PET_SOUL then
                litemid =litemid-ITEM_TYPE_SHARED_PRE
            end
            local role = gCreateFlaDislpay("r"..litemid.."_wait",1,"r"..litemid);
            role:setScale(0.5)
            gAddCenter(role, self:getNode("role_show"))
            self:getNode("bg_waits"):setVisible(false)
        else
            local litemid = value.idx
            if value.idx>ITEM_TYPE_SHARED_PRE and value.idx<ITEM_TYPE_CONSTELLATION_PRE then
                litemid = litemid -ITEM_TYPE_SHARED_PRE
            end
            self:getNode("item_show"):removeAllChildren()
            self:getNode("item_show"):setVisible(true)
            Icon.setIcon(toint(litemid),self:getNode("item_show"),DB.getItemQuality(toint(litemid)))
        end
        self:getNode("hd_end"..self.curSelectIndex):setVisible(value.curturn+1>value.maxturn)
        self:setTouchEnableGray("btn_bet", not (value.curturn+1>value.maxturn))
    end
end

function ActivitySnatchPanel:setData(param)

    for key, value in pairs( Data.activitySnatchData.list) do
        self:getNode("select_ka"..key):setVisible(false)
        --local itemName = DB.getItemName(value.idx,true)
        self:setLabelString("txt_name"..key,value.itemname)
        local itemid = value.idx
        self.itemName[itemid]=value.itemname
        Icon.setIcon(itemid,self:getNode("icon"..key),DB.getItemQuality(itemid),nil,nil,true)
        self:setLabelString("txt_num"..key,value.itemnum)
        local cardDb = DB.getCardById(value.idx)
        self:getNode("bg_s"..key):setVisible(false)
        self:getNode("hd_end"..key):setVisible(value.curturn+1>value.maxturn)
    end
 
end


function ActivitySnatchPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_SNATCH_INFO )then
        self.refreshListTime = gGetCurServerTime()
        if self.curSelectIndex == 0 then
            self.curSelectIndex =1
            self:setData(param)
            self:selectIndex(self.curSelectIndex)
        end
        local value = Data.activitySnatchData.list[self.curSelectIndex]
        self:refreshData(value)
        self:initNoticeRewardPanel(Data.activitySnatchData.nlist)
    elseif (event==EVENT_ID_GET_ACTIVITY_SNATCH_UPDATESCORE )then
         gShowNotice(gGetWords("noticeWords.plist","snatch_success_tip",param));
    end
end

function ActivitySnatchPanel:refreshData(value)
    if value then
        self:setLabelString("txt_per",value.curnum.."/"..value.maxunm)
        local per=value.curnum/value.maxunm
        self:setBarPer("bar",per)
        self:getNode("hd_end"..self.curSelectIndex):setVisible(value.curturn+1>value.maxturn)
        self:setTouchEnableGray("btn_bet", not (value.curturn+1>value.maxturn))
    end

    self:setLabelString("txt_score",Data.activitySnatchData.score)

end       

function ActivitySnatchPanel:initNoticeRewardPanel(items)

    local  hasadd = false
    for key, var in pairs(items) do
        if self:getNode("notice_scroll").maxid < var.id then
            hasadd = true
            self:getNode("notice_scroll").maxid = var.id

            local item = RTFLayer.new(self:getNode("notice_scroll"):getContentSize().width-5);
            item:setAnchorPoint(cc.p(0,1))
            local quality=DB.getItemQuality(var.itemid)

            if(var.itemid==0 or quality==nil )then
                quality=5
            end
            local itemname = DB.getItemName(var.itemid)
            if self.itemName[var.itemid] ~=nil then
                itemname = self.itemName[var.itemid]
            end
            local color=gGetItemQualityColor(quality)
            color=gParseRgbNum(227,113,255)
            item:setDefaultConfig(gFont,16,cc.c3b(255,69,69));
            local word=""
            if var.type==nil or var.type == 0 then
                word=gGetWords("activityNameWords.plist","snatch_notice",
                gParseRgbNum(255,234,0),
                var.name,
                gParseRgbNum(255,255,255),
                itemname,
                var.itemnum)
            else
                word=gGetWords("activityNameWords.plist","snatch_notice1",
                gParseRgbNum(255,234,0),
                var.name,
                gParseRgbNum(255,255,255),
                var.money,
                color, 
                itemname,
                var.itemnum)
                
            end
            
            item:setString(word);
            item:layout();
            self:getNode("notice_scroll"):addItem(item)
        end
    end
    if hasadd then
        self:getNode("notice_scroll"):layout()
        local containerSize=self:getNode("notice_scroll").container:getContentSize()
        local viewSize=self:getNode("notice_scroll").viewSize
        if(viewSize.height<containerSize.height)then
            self:getNode("notice_scroll").container:setPositionY(0)
        end
    end

end

return ActivitySnatchPanel
