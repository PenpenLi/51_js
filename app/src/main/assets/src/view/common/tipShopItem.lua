local TipShopItem=class("TipShopItem",UILayer)

function TipShopItem:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/tip_shop_item.map")

    self.discount=100
    if(data.discount)then
        self.discount=data.discount 
    end
    self.hasUnlock = false;
    self.curData=data
    self:setItemId(data.itemid)
end



function TipShopItem:onTouchEnded(target)

    if(target.touchName=="btn_buy")then 
        local price=math.ceil(self.curData.price*self.discount/100)
        if(NetErr.BuyShopItem(self.curData.costType,price)) then
            ShopPanelData.buyPrice = price;
            if (TDGAItem) then
                if(self.curData.costType==OPEN_BOX_DIAMOND)then
                    gLogPurchase(self.itemid,1,price)
                end
            end
            Net.sendBuyShopItem(self.curData.type,{self.curData.pos})
            local td_param = {}
            td_param['price'] = price
            td_param['itemid'] = self.itemid
            td_param['item_name'] = DB.getItemName(self.itemid)
            td_param['type'] = self.curData.type
            gLogEvent("shop.buy",td_param)
            Panel.popBack(self:getTag())
        end

        -- Net.sendBuyShopItem(self.curData.type,self.curData.pos)
        -- Panel.popBack(self:getTag())
    end

end

function TipShopItem:setItemId(itemid)
    itemid = DB.checkReplaceItem(itemid);
    self.itemid=itemid
    
    local num=Data.getItemNum(itemid)
    self.num = num
    self:setLabelString("txt_name",DB.getItemName(itemid)) 
    self:setLabelString("txt_info",DB.getItemAttrDes(itemid))
    self:setLabelString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num",num))
    
    if(self.curData.costType==OPEN_BOX_DIAMOND)then
        Icon.changeDiaIcon(self:getNode("cost_icon"))
    elseif(self.curData.costType==OPEN_BOX_GOLD)then
        Icon.changeGoldIcon(self:getNode("cost_icon"))
    elseif(self.curData.costType==OPEN_BOX_REPU)then
       Icon.changeRepuIcon(self:getNode("cost_icon"))
    elseif(self.curData.costType==OPEN_BOX_FAMILY_DEVOTE)then
       Icon.changeDevoteIcon(self:getNode("cost_icon"))
    elseif(self.curData.costType == OPEN_BOX_SOULMONEY)then
        Icon.changeSoulMoneyIcon(self:getNode("cost_icon"))
    elseif(self.curData.costType == OPEN_BOX_SERVERBATTLE)then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_SERVERBATTLE)
    elseif(self.curData.costType==OPEN_BOX_PETMONEY)then
       Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_PETMONEY)
       if self.curData.pettower > 0 and Data.pet.topFloor < self.curData.pettower then
            self:replaceLabelString("tip_unlock",self.curData.pettower);
            self.hasUnlock = true;
        end
    elseif(self.curData.costType == OPEN_BOX_TOWERMONEY)then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_TOWERMONEY)
    elseif(self.curData.costType == OPEN_BOX_EMOTION_MONEY)then
        Icon.changeEmoneyIcon(self:getNode("cost_icon"))
    elseif(self.curData.costType == OPEN_BOX_FAMILY_MONEY)then
        Icon.setSpeIcon(OPEN_BOX_FAMILY_MONEY,self:getNode("cost_icon"))
    elseif(self.curData.costType == OPEN_BOX_CONSTELLATION_SOUL )then
        Icon.setSpeIcon(OPEN_BOX_CONSTELLATION_SOUL,self:getNode("cost_icon"))
    end

    local shopType = self.curData.type;
    if(shopType == SHOP_TYPE_TOWER1 or shopType == SHOP_TYPE_TOWER2 or shopType == SHOP_TYPE_TOWER3)then
        if(Data.towerInfo.maxstar < self.curData.unlockStar)then
            self:setLabelString("tip_unlock",gGetWords("towerWords.plist","unlockStar",self.curData.unlockStar));
            self.hasUnlock = true;
        end
    end

    self:getNode("tip_unlock"):setVisible(self.hasUnlock);
    self:getNode("btn_buy"):setVisible(not self.hasUnlock);
 
    self:setLabelString("txt_buy_num",gGetWords( "labelWords.plist","lab_buy_num",self.curData.num))
    
    self:setLabelString("txt_price", math.ceil(self.curData.price*self.discount/100))

    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid),DB.getItemQuality(itemid))
    if(DB.getSoulNeedLight(itemid))then
        Icon.addSpeEffectForSoul(self:getNode("icon"));
    end
    self:scrollLayerLayOut();
    self:resetLayOut();
end

return TipShopItem