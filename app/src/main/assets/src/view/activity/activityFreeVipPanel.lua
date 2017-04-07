local ActivityFreeVipPanel=class("ActivityFreeVipPanel",UILayer)

function ActivityFreeVipPanel:ctor(data)
    self:init("ui/ui_hd_free_vip.map") 
    self.curData=data
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- print("self.curData.type = "..self.curData.type)
    self.activityData = nil;

    self:setVipLab()
    
    Net.sendActivityFreeVipInfo()
    Data.activityActid = self.curData.actId
end

function ActivityFreeVipPanel:setVipLab()
    self:replaceLabelString("txt_vip",Data.getCurVip())
    local vipDatas=DB.getVipCharge()
    local vip = Data.getCurVip()
    if(vip>=15)then
        vip=14
    end
    local vipCharge=vipDatas[vip+2] 
    if(vipCharge)then
        self:setLabelString("txp_vip2", gUserInfo.vipsc.."/"..vipCharge)
    end
    self:setLabelString("txp_acoin", gUserInfo.acoin)
end

function ActivityFreeVipPanel:onPopup()
    -- print("self.curData.type="..self.curData.type)
    Net.sendActivityFreeVipInfo()
end

function ActivityFreeVipPanel:sortActList()
    --排序
    for k,v in pairs(self.activityData.list) do
        -- print(k,v)
        if (v.rec == 0) then
            v.sort = 2
        elseif (v.rec == 1) then
            v.sort = 1
        elseif (v.rec == 2) then
            v.sort = 3
        end
    end

    local sort1 = function(a,b)
        if (a.sort == b.sort) then
            return a.stall < b.stall;
        else
            return a.sort < b.sort
        end
    end
    table.sort( self.activityData.list, sort1 )
end

function ActivityFreeVipPanel:setData(param)
    self:getNode("scroll"):clear()
    self.activityData = Data.activityFreeVipData;
    --排序
    self:sortActList()
    for key, value in pairs( self.activityData.list) do
        local item=ActivityFreeVipItem.new(self.curData.type)
        item.curActData= self.curData
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    -- print("---"..self.activityData.desc)

    -- self:setRTFString("lab_help",self.activityData.desc)
    -- self:getNode("scroll_contain_item"):layout()
    -- self:getNode("help_bg"):layout()
end

function ActivityFreeVipPanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_23 )then
        self:setData(param)
    elseif(event==EVENT_ID_GET_ACTIVITY_23_REC or event==EVENT_ID_USER_DATA_UPDATE)then
        self:refreshData(param)
        self:setVipLab()
    end
end

function ActivityFreeVipPanel:onTouchEnded(target)
    if(target.touchName=="btn_go")then
        if Unlock.isUnlock(SYS_TASK) then
            Net.sendDayTaskList();
        end
    end
end

function ActivityFreeVipPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end       

return ActivityFreeVipPanel