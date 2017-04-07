local BuyGoldPanel=class("BuyGoldPanel",UILayer)

function BuyGoldPanel:ctor(type)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist");
    self.appearType = 1;
    self:init("ui/ui_buy_gold.map")

    self.isWindow = true;
    self.isMainLayerMenuShow = false;
    self.isMainLayerOtherShow = false;
    self.bolTen = false;
    self.count = 1;
    self.ten = 10;
    -- Net.sendInitBuyGold()
    self:refresh();
end

function  BuyGoldPanel:events()
    return {EVENT_ID_INIT_BUY_GOLD,EVENT_ID_GET_ACTIVITY_VIP_CHANGE}
end

function BuyGoldPanel:refresh()
    self.maxCount = Data.getMaxUseTimes(VIP_STONEGOLD);
    self.curCount = self.maxCount - Data.getUsedTimes(VIP_STONEGOLD);
    self.ten = math.min(self.curCount,10);
    self:setLabelString("txt_num",self.curCount.."/"..self.maxCount);
    self.needDia = Data.getBuyGoldNeedDia(self.count);
    self.gold = Data.getBuyGoldReward(self.count);

    self:setLabelString("txt_gold",self.gold)
    self:setLabelString("txt_dia",self.needDia)

    self:getNode("sign_ten"):setVisible(self.bolTen)
    self:replaceLabelString("txt_count",self.ten);

    if (self.curCount<=0) then
        self:setTouchEnableGray("btn_buy_one",false);
    end

    self:resetLayOut();
end

function BuyGoldPanel:dealEvent(event,param)
    if(event==EVENT_ID_INIT_BUY_GOLD)then
        -- print("1-------------------------------------------------")
        -- print_lua_table(param);
        -- print("2-------------------------------------------------")
        self:refresh();
        self:getNode("gold_image"):setOpacity(40);
        self:createAct(param);
    elseif(event==EVENT_ID_GET_ACTIVITY_VIP_CHANGE)then
        self:refresh()
    end
end

function BuyGoldPanel:createAct(param)
    for k,v in pairs(param) do
        print(k,v)

        local gold = {gold = self.data[k].gold*v,times = v}
        --飘起物品
        local function actionGold(sender,data)
            local items = {};
            table.insert(items,{id=OPEN_BOX_GOLD,num=data.gold,baojiTimes=data.times})
            gShowItemPoolLayer:pushItems(items);
        end

        local list = {key = k,var = v}

        --列表
        local function actionList(sender,data)
            self:creatList(data);
        end

        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5*(k-1)),
            cc.CallFunc:create(actionGold,gold),
            -- cc.DelayTime:create(0.5*(k-1)),
            cc.CallFunc:create(actionList,list)
        ));
    end
end

function BuyGoldPanel:creatList(data)
    local item = BuyGoldItem.new(data.var,self.data[data.key],data.key);
    self:getNode("scroll"):addItem(item);
    item.click = function(index)
        self:onClick(index);
    end
    self:getNode("scroll"):layout();
    self:getNode("scroll").container:setPositionY(0)
end

function BuyGoldPanel:setData()
    self.data = {};
    local needDia = 0;
    local gold = 0;
    local tmpData = {};
    -- print("self.count="..self.count)
    for i=1,self.count do
        local needDia2 = Data.getBuyGoldNeedDia(i);
        local gold2 = Data.getBuyGoldReward(i);
        if (i>1) then
            needDia = Data.getBuyGoldNeedDia(i-1);
            gold = Data.getBuyGoldReward(i-1);
        end
        tmpData = {};
        tmpData.needDia = needDia2 - needDia;
        tmpData.gold = gold2 - gold;
        -- print("i="..i..",dia="..tmpData.needDia..",gold="..tmpData.gold)
        table.insert(self.data,tmpData)
    end
    -- print_lua_table(self.data)
end

function BuyGoldPanel:dealBuy()
    self:setData();
    if (not self.bolTen) then
        Data.vip.stonegold.setPrice(self.needDia);
        Data.vip.stonegold.setBuyCount(self.gold);
        if (NetErr.isDiamondEnough(self.needDia) == false) then
            return;
        end
        local callback = function()
            Net.sendBuyGold(false);
            if (TDGAItem) then
                gLogPurchase("buygold_one",1,self.needDia)
            end
        end
        Data.canBuyTimes(VIP_STONEGOLD,true,callback);
    else
        -- self.needDia = Data.getBuyGoldNeedDia(self.count);
        -- self.gold = Data.getBuyGoldReward(self.count);
        if (NetErr.isDiamondEnough(self.needDia) == false) then
            return;
        end
        local callback = function()
            Net.sendBuyGold(true);
            if (TDGAItem) then
                gLogPurchase("buygold_ten",1,self.needDia)
            end
        end
        Data.canBuyTimes(VIP_STONEGOLD,true,callback);
    end
end

function BuyGoldPanel:dealSign()
    if self.bolTen then self.bolTen = false else self.bolTen = true end
    if (not self.bolTen) then
        self.count = 1;
    else
        self.count = math.min(self.curCount,10)
        self.ten = self.count;
    end
    self:refresh();
end

function BuyGoldPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_buy_one"then
        self:dealBuy();
    elseif  target.touchName=="btn_sign"then
        self:dealSign();
    end

end

return BuyGoldPanel