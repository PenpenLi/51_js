local VipBuyTimesPanel=class("VipBuyTimesPanel",UILayer)

function VipBuyTimesPanel:ctor(data)

    self.appearType = 1;
    self.isMainLayerGoldShow = true;
    self.isMainLayerMenuShow = false;
    -- self._panelTop = true;
    self:init("ui/ui_vip_buytimes.map"); 
    self.bgVisible =false
    -- self.data = data;
    -- self.info = data.info;
    -- self.tip = data.tip;
    self.buyCallback = data.buyCallback;
    self.type = data.type;
    self.discount2= data.discount;
    self.buyTimes = 1;
    self:refreshInfo(self.buyTimes);
    
    
    -- self.price = data.price;

    -- self:setRTFString("txt_info",data.info);
    -- self:setLabelString("txt_tip",data.tip);

    self:setLabelString("txt_name",gGetWords("vipWords.plist","itemType"..self.type));
    if self:isNoneLimit() then
        -- 购买无次数限制
        self.lefttimes = Data.getMaxUseTimes(self.type);
        self:setRTFString("txt_tip",gGetWords("vipWords.plist","vipTimes_forever"))
        self:getNode("txt_tip2"):setVisible(false)
    else
        self.lefttimes = Data.getLeftUseTimes(self.type);
        local maxtimes = Data.getMaxUseTimes(self.type);
        self:replaceRtfString("txt_tip",self.lefttimes,maxtimes);
    end

    if(self.type == VIP_GOLDBOX)then
        self:setLabelString("txt_tip2",gGetWords("vipWords.plist","42"));
    elseif self.type == VIP_BUY_TREASURE_MAP then
        local freeTimes = Data.vip.buyTreasureMap.getFreeBuyNum()
        local useTimes = Data.getUsedTimes(VIP_BUY_TREASURE_MAP)
        local leftFreeTimes = freeTimes - useTimes
        if leftFreeTimes < 0 then
            leftFreeTimes = 0
        end
        self:setLabelString("txt_tip2",gGetWords("vipWords.plist","vipTimes_buy_treasure_map",leftFreeTimes))
    elseif self.type == VIP_ACTIVITY_SNATCH then
        self:setLabelString("txt_name",gGetWords("vipWords.plist","snatch_coin"));
        self:setLabelString("txt_buyname",gGetWords("vipWords.plist","snatch_totalcoin"));
        self:setLabelString("btn_name",gGetWords("vipWords.plist","snatch"));
    end
    
    self:resetLayOut();

    self.touchBegin = false
    self.longPress=false
    self.beginStart = gGetCurServerTime()
    local function updatePer()
        if self.touchBegin==true and gGetCurServerTime() - self.beginStart >= 1  then
            self.longPress=true
            if self.touchName == "btn_sub1" then
                self:subBuyTimes(10);
            elseif self.touchName == "btn_add1" then
                self:addBuyTimes(10);
            end
        end
    end
    self:scheduleUpdateWithPriorityLua(updatePer,1)

end

function VipBuyTimesPanel:isNoneLimit()
    if self.type == VIP_LOOT_FOOD
       or self.type == VIP_LOOT_FOOD_REVENG
       or self.type == VIP_RICHMAN
       or self.type == VIP_ACTIVITY_SNATCH
       --[[or self.type == VIP_WORLD_BOSS_NEW_FIGHT]] then
       return true
    end

    return false
end

function VipBuyTimesPanel:refreshInfo(buyTimes)
    if(Data.activityAtlasSaleoff.time and gGetCurServerTime()>Data.activityAtlasSaleoff.time)then
        Data.activityAtlasSaleoff={}
    end 
    self.discount = 100
    if(Data.activityAtlasSaleoff.val)then
        if (self.discount2) then
            self.discount= Data.activityAtlasSaleoff.val
        end
    end
    -- print("self.discount="..self.discount)

    self:setLabelAtlas("txt_buy_times",buyTimes);
    local price,count = Data.getBuyPriceAndCountMoreTimes(self.type,buyTimes);

    self:setLabelString("txt_dia",price);
    local curPirce = math.ceil(price*self.discount/100);
    if(self.discount==100)then
        self:setLabelString("txt_dia2","")
        self:resetLayOut();
    else
        self:setLabelString("txt_dia2","      "..curPirce)     
        self:resetLayOut();
        local line=cc.Sprite:create("images/ui_huodong/redline.png")
        line:setPosition(self:getNode("txt_dia"):getPosition())
        self:getNode("container"):addChild(line)
    end
    
    self:setLabelString("txt_num","x"..count);
    self.price = curPirce;
end

function VipBuyTimesPanel:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;
    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function VipBuyTimesPanel:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.lefttimes then
        self.buyTimes = self.lefttimes;
    end
    self:refreshInfo(self.buyTimes);
end

function VipBuyTimesPanel:onTouchBegan(target,touch, event)

    if target.touchName == "btn_sub1" or target.touchName == "btn_add1" then
        self.touchBegin = true
        self.touchName = target.touchName
        self.beginStart = gGetCurServerTime()
        self.beganPos = touch:getLocation();
    end
end

function VipBuyTimesPanel:onTouchMoved(target,touch, event)
    if self.touchBegin == true then
        self.endPos = touch:getLocation();
        local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
        if dis > gMovedDis then
            self.touchBegin = false
            self.longPress=false
        end
    end
end

function VipBuyTimesPanel:onTouchEnded(target)

    self.touchBegin = false
    if self.longPress==true then
        self.longPress=false
        return
    end
    
    if  target.touchName=="btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_sub" then
        self:subBuyTimes(1);
    elseif target.touchName == "btn_add" then
        self:addBuyTimes(1);
    elseif target.touchName == "btn_sub1" then
        self:subBuyTimes(10);
    elseif target.touchName == "btn_add1" then
        self:addBuyTimes(10);
    elseif target.touchName=="btn_confirm" then
        if Data.canBuyTimes(self.type,true) == false then
            return
        end
        if NetErr.isDiamondEnough(self.price) then
            if(self.buyCallback)then
                self.buyCallback(self.buyTimes, self.price);
            end
            if (TDGAItem) then
                gLogPurchase("vip_buy_times_"..tostring(self.type),1,self.price)
            end
            Panel.popBack(self:getTag())
        end
    end
end

function VipBuyTimesPanel:refreshVipChange()
    -- 刷新购买次数、价格
    local lefttimes = Data.getLeftUseTimes(self.type);
    if lefttimes > 0 then
        self.lefttimes = lefttimes
        local maxtimes = Data.getMaxUseTimes(self.type);
        self:replaceRtfString("txt_tip",self.lefttimes,maxtimes);

        self:addBuyTimes(0)
    end
end

function VipBuyTimesPanel:events() 
    return {
        EVENT_ID_GET_ACTIVITY_VIP_CHANGE
    }
end

function VipBuyTimesPanel:dealEvent(event,param) 
    if(event==EVENT_ID_GET_ACTIVITY_VIP_CHANGE)then 
        self:refreshVipChange()
    end
end

return VipBuyTimesPanel