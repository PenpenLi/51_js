local ActivityChargeReturnItem=class("ActivityChargeReturnItem",UILayer)

function ActivityChargeReturnItem:ctor()
    self:init("ui/ui_hd_chong_item.map")
end

function ActivityChargeReturnItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        self:refreshState()
        if(self.bCanGet)then
            Net.sendActivityChargeReturnGet(self.activityId,self.curData)
        elseif(self.bCanCharge)then
            Panel.popUp(PANEL_PAY);
        end
    end
end

function ActivityChargeReturnItem:refreshState()
    self.bCanGet = false;
    self.bCanCharge = false;
    local detData = Data.getActivityChargeReturnByDetid(self.curData)
    local curValue = detData.num
    local maxValue = detData.max
    local countValue = detData.count
    
    if(curValue >= maxValue) then --领取结束
    elseif(curValue < countValue) then --可领取
        self.bCanGet = true;
    else--引导去充值
        self.bCanCharge = true;
    end
end

function  ActivityChargeReturnItem:refreshData()
    self:refreshState()
    local status = 0;
    if(self.bCanGet)then
        self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward")); 
        self:changeTexture("btn_get","images/ui_public1/button_blue_1.png");
        status = 0;
    elseif(self.bCanCharge)then
        self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_pay")); 
        self:changeTexture("btn_get","images/ui_public1/button_red_1.png"); 
        status = 0;
    else
        status = 1;
    end
    gShowBtnStatus(self:getNode("btn_get"),status)
    local detData = Data.getActivityChargeReturnByDetid(self.curData)
    local curValue = detData.num
    local maxValue = detData.max
    self:setLabelString("txt_count",curValue.."/"..maxValue)
end

function  ActivityChargeReturnItem:setData(activityId,data)
    self.curData=data 
    self.activityId=activityId
    local detData = Data.getActivityChargeReturnByDetid(self.curData)
    
    local items = detData.items
    for i=1, 3 do
        self:getNode("icon_"..i):setVisible(false)
    end
     
    local idx=1
    for key, item in pairs(items) do 
        if(self:getNode("icon_"..key))then
            self:getNode("icon_"..idx):setVisible(true) 
            local node=DropItem.new() 
            node:setData(item.itemid)
            node:setNum(item.num)  
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon_"..idx)) 
            idx=idx+1
        end
    end

    local iapdata = DB.getIapById(detData.iapid)
    if(iapdata) then
        self:setLabelString("txt_desc",gGetWords("activityNameWords.plist","charge_return_item",iapdata.money))
    end

    self:refreshData()
end

return ActivityChargeReturnItem