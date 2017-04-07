local ShopBuyAllPanel=class("ShopBuyAllPanel",UILayer)

function ShopBuyAllPanel:ctor(type,discount)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self:init("ui/ui_shop_allbuy.map");
    self.type = type;
    self.discount=discount
    if(self.discount==nil)then
        self.discount=100
    end
    self:getPrice();
    self.choosedGold = true;
    self.choosedDia = true;
    self.needGold = 0;
    self.needDia = 0;
    self:refresh();
end

function ShopBuyAllPanel:refresh()

    if self.choosedGold then
        self:changeTexture("btn_buygold","images/ui_public1/n-di-gou2.png");
    else
        self:changeTexture("btn_buygold","images/ui_public1/n-di-gou1.png");
    end


    if self.choosedDia then
        self:changeTexture("btn_buydia","images/ui_public1/n-di-gou2.png");
    else
        self:changeTexture("btn_buydia","images/ui_public1/n-di-gou1.png");
    end


    self:getNode("layer_gold"):setVisible(true);   
    self:getNode("layer_dia"):setVisible(true);   
    self:getNode("layer_price"):setVisible(true);
    self.needGold = self.totalGold;
    self.needDia = self.totalDia;
    if self.choosedGold == false and self.choosedDia == false then
        self.needGold = 0;
        self.needDia = 0;
        self:getNode("layer_price"):setVisible(false);
    elseif self.choosedGold == true and self.choosedDia == true then
        self.needGold = self.totalGold;
        self.needDia = self.totalDia;
    elseif self.choosedGold == false then
        self:getNode("layer_gold"):setVisible(false); 
        self.needGold = 0;  
    elseif self.choosedDia == false then
        self:getNode("layer_dia"):setVisible(false);
        self.needDia = 0;      
    end

    self:resetLayOut();
end

function ShopBuyAllPanel:getPrice()
    local totalGold = 0;
    local totalDia = 0;

    for key,item in pairs(gShops[self.type].items) do

        -- if self.choosedGold then
            if (item.costType == OPEN_BOX_GOLD or item.costType == OPEN_BOX_SOULMONEY) and item.num > 0 then
                totalGold = totalGold + math.ceil(item.price*self.discount/100);
            end
        -- end


        -- if self.choosedDia then
            if item.costType == OPEN_BOX_DIAMOND and item.num > 0 then
                totalDia = totalDia +  math.ceil(item.price*self.discount/100);
            end
        -- end
    end

    self.totalGold = totalGold
    self.totalDia =  totalDia
    -- return totalGold,totalDia;

    self:setLabelString("txt_gold",self.totalGold);
    self:setLabelString("txt_dia",self.totalDia);  

    if(self.type == SHOP_TYPE_SOUL)then
        Icon.changeSoulMoneyIcon(self:getNode("icon_gold"));
        self:setLabelString("txt_buygold_tip",gGetWords("shopWords.plist","5"))
    end
end

function ShopBuyAllPanel:getItems()
    self.buyItems = {};
    for key,item in pairs(gShops[self.type].items) do

        if self.choosedGold then
            if (item.costType == OPEN_BOX_GOLD or item.costType == OPEN_BOX_SOULMONEY) and item.num > 0  then
                table.insert(self.buyItems,item.pos);
            end
        end


        if self.choosedDia then
            if item.costType == OPEN_BOX_DIAMOND and item.num > 0  then
                table.insert(self.buyItems,item.pos);
            end
        end
    end    

end

function ShopBuyAllPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_buygold" then
        self.choosedGold = not self.choosedGold;
        self:refresh();    
    elseif target.touchName == "btn_buydia" then
        self.choosedDia = not self.choosedDia;
        self:refresh();    
    elseif  target.touchName=="btn_ok"then

        local canBuy = false;
        if(self.type == SHOP_TYPE_SOUL)then
            canBuy = NetErr.BuyShopItem(OPEN_BOX_DIAMOND,self.needDia) and NetErr.BuyShopItem(OPEN_BOX_SOULMONEY,self.needGold)
        else
            canBuy = NetErr.BuyShopItem(OPEN_BOX_DIAMOND,self.needDia) and NetErr.BuyShopItem(OPEN_BOX_GOLD,self.needGold)
        end
        if canBuy then
            self:getItems();
            -- print_lua_table(self.buyItems);
            Net.sendBuyAll(self.type,self.buyItems);
            if (TDGAItem) then
                gLogPurchase("shop_buy_all_" .. tostring(self.type),1,self.needDia)
            end
            self:onClose();
        end
        -- self:getShopData(SHOP_TYPE_1)
    end
end

return ShopBuyAllPanel