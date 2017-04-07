local ActivityLoginRewardPanel=class("ActivityLoginRewardPanel",UILayer)

function ActivityLoginRewardPanel:ctor(data)
    self:init("ui/ui_hd_zhongqiu.map") 
    self.curData=data
    local path = "images/ui_huodong/pop_11.png"
    if self.curData.icon then
        path = "images/ui_huodong/pop_11_"..self.curData.icon..".png"
    end
    if cc.FileUtils:getInstance():isFileExist(path) then
        self:changeTexture("bg_activity",path)
    end
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    -- print("self.curData.type = "..self.curData.type)
    self.activityData = nil;

    self:getNode("lab_help"):setVisible(true)

    Net.sendActivityHolidaySignInfo(data)

    Data.activityActid = self.curData.actId
    print("Data.activityActid="..Data.activityActid)
end

function ActivityLoginRewardPanel:onPopup()

end

function ActivityLoginRewardPanel:sortActList()
    --排序
    local curtime = gGetCurServerTime()
    for k,v in pairs(self.activityData.list) do
        
        if (v.cnt>0) then--已经领取
            v.sort = 4
            v.status = 4
        else
            if curtime < v.stime then -- 未达到
                v.sort = 3
                v.status = 3
            elseif curtime>=v.stime and curtime<=v.etime then --领取
                v.sort = 1
                v.status = 1
            else  --过期
                v.sort = 2
                v.status = 2
            end
        end
    end

    local sort1 = function(a,b)
        if (a.sort == b.sort) then
            return a.stime < b.stime;
        else
            return a.sort < b.sort
        end
    end
    table.sort( self.activityData.list, sort1 )
end

function ActivityLoginRewardPanel:setData(param)
    self:getNode("scroll"):clear()
    self.activityData = nil;
    self.activityData = Data.activityHolidaySign;

    --排序
    self:sortActList()
    for key, value in pairs( self.activityData.list) do
        local item=ActivityLoginRewardItem.new(self.curData.actId)
        item.curActData= self.curData
        item:setData(key,value)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    -- print("---"..self.activityData.desc)

    self:setRTFString("lab_help",self.activityData.desc)
    self:getNode("scroll_contain_item"):layout()
end

function ActivityLoginRewardPanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_GETINFO_28 )then
        self:setData(param)
   elseif(event==EVENT_ID_GET_ACTIVITY_28_REC)then
        self:refreshData(param)
    end
end


function ActivityLoginRewardPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end       

return ActivityLoginRewardPanel