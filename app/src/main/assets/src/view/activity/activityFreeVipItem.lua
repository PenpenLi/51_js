local ActivityFreeVipItem=class("ActivityFreeVipItem",UILayer)

function ActivityFreeVipItem:ctor(data)
    self:init("ui/ui_hd_freevip_item.map")
    self.type = data;
    -- print("self.type="..self.type)
end

function ActivityFreeVipItem:onTouchEnded(target)
    if(target.touchName=="btn_ex")then
        if (self.curData.rec==1) then
            Net.sendActivityFreeVipRec(self.curData.stall)
        elseif (self.curData.rec==0 and Data.getCurVip()>=self.curData.stall - 1) then
            --提示活跃度不足
            local sWord = gGetWords("activityNameWords.plist","freevip");
            gShowNotice(sWord)
        end
    end
end

function   ActivityFreeVipItem:setData(key,data)
    self.curData=data

    self:getNode("lab_ex"):setVisible(true)
    self:replaceLabelString("lab_ex",data.stall - 1)

    self:getNode("lab_acoin2"):setVisible(true)
    self:setLabelString("lab_acoin2","0/1")

    
    local node=DropItem.new()
    node:setData(Data.activity.free_vip_item_id[data.stall])
    node:setNum(0)
    node:setPositionY(node:getContentSize().height)
    gAddMapCenter(node, self:getNode("icon")) 
    
    self:setLabelString("lab_acoin",Data.activity.free_vip_need_acoin[data.stall])
    self:replaceLabelString("lab_title",Data.activity.free_vip_rec_vipscore[data.stall])

    if (data.rec==0) then--不可领
        self:setLabelString("btn_ex_lab",gGetWords("btnWords.plist","btn_exchange"));
        if (Data.getCurVip()>=data.stall - 1) then
            self:setTouchEnable("btn_ex",true,false)
            self:getNode("lab_ex"):setVisible(false)
        else
            self:setTouchEnable("btn_ex",false,true)
            self:getNode("lab_acoin2"):setVisible(false)
        end
    elseif (data.rec==1) then--可领
        self:setLabelString("btn_ex_lab",gGetWords("btnWords.plist","btn_exchange"));
        self:setTouchEnable("btn_ex",true,false)
        self:getNode("lab_ex"):setVisible(false)
    elseif (data.rec==2) then--已领
        self:setLabelString("btn_ex_lab",gGetWords("btnWords.plist","btn_exchange_ok"));
        self:setTouchEnable("btn_ex",false,true)
        self:setLabelString("lab_acoin2","1/1")
        self:getNode("lab_ex"):setVisible(false)
    end
end

function   ActivityFreeVipItem:refreshData()
    self:setData(0,self.curData)
end


return ActivityFreeVipItem