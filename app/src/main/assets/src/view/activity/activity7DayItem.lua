local Activity7DayItem=class("Activity7DayItem",UILayer)

function Activity7DayItem:ctor()
    self:init("ui/ui_hd_7day_item.map")

end




function Activity7DayItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
       Net.sendActivity7DayGet(self.curData.boxid)
    end
end

function   Activity7DayItem:refreshData(getIndex)
    local canBeGot = true
    local status = 0;
    if(self.key> gUserInfo.logindaycount)then
        status = -1;
        canBeGot = false
    end

    if(Data.activityLogin7[self.curData.boxid]==1)then
        self.isGet=1
        canBeGot = false
        status = 1;
    else
        self.isGet=0
    end

    gShowBtnStatus(self:getNode("btn_get"),status);

    -- self:getNode("btn_get"):setVisible(true)
    -- self:getNode("flag_unget"):setVisible(false);    
    -- if(self.key> gUserInfo.logindaycount)then
    --     self:getNode("btn_get"):setVisible(false)
    --     self:getNode("flag_unget"):setVisible(true);
    --     canBeGot = false
    -- end


    -- if(Data.activityLogin7[self.curData.boxid]==1)then
    --     self.isGet=1
    --     self:setTouchEnableGray("btn_get",false);
    --     self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_reward_got"))
    --     canBeGot = false
    -- else
    --     self:setTouchEnableGray("btn_get",true); 
    --     self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward"))
    --     self.isGet=0
    -- end
    Data.updateAct7DayCanBeGot(self.key, canBeGot)
end

function   Activity7DayItem:setData(key,data,getIndex)
    self.curData=data 
    self.key=key
    self:setLabelString("txt_day",key)
    
    
    local boxes= DB.getBoxItemById(self.curData.boxid)
     
    for key, box in pairs(boxes) do 
        if(self:getNode("icon_"..key))then
            local node=DropItem.new() 
            node:setData(box.itemid)
            node:setNum(box.itemnum )  
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon_"..key)) 
        
        end
    end
    
    self:refreshData(getIndex)
   
end



return Activity7DayItem