local ShopItem=class("ShopItem",UILayer)

function ShopItem:ctor(discount,curType,curShopType)
    loadFlaXml("ui_kuang_texiao");
    self:init("ui/ui_shop_item.map") 
    self.discount = discount;
    self.curType = curType
    self.curShopType = curShopType
    self.hasLimitBuy = false;
    self.hasOrgPrice = false;
    self.hasSellOut = false;
    self.hasUnlock = false;
end

function ShopItem:shopOverShow()
    --活动结束
    local sWord = gGetWords("shopWords.plist","6");
    gShowNotice(sWord);
end

function ShopItem:dealLimitShop()
    if (self.curShopType == 2) then
        if (Unlock.isUnlock(SYS_SHOP2,false)) then
            return false
        end
    elseif (self.curShopType == 3) then
        if (Unlock.isUnlock(SYS_SHOP3,false)) then
            return false
        end
    end
    if (Data.limit_etime and Data.limit_etime==0 and (Data.limit_stype==self.curShopType)) then
        self:shopOverShow()
        return true
    end
    return false
end

function ShopItem:onTouchEnded(target) 
    if(self.selectItemCallback  and self.hasUnlock==false)then
        self.selectItemCallback(self.curData)
        return
    end
    if(target.touchName=="btn_buy")then 
        if (self:dealLimitShop()) then return end

        if(self.hasLimitBuy and self.curData.limitNum)then
            if(self.curData.limitNum - self.curData.buyNum <= 0)then
                gShowNotice(gGetWords("shopWords.plist","7"));
                return;
            end
        end

        local price=self.curData.price
        if(self.discount and self.discount < 100)then
            price=math.ceil(self.curData.price*self.discount/100)
        end
        if(NetErr.BuyShopItem(self.curData.costType,price)) then
            local function  buy()
                ShopPanelData.buyPrice = price;
                Net.sendBuyShopItem(self.curData.type,{self.curData.pos})
                if (TDGAItem) then
                    if(self.curData.costType==OPEN_BOX_DIAMOND)then
                        gLogPurchase(tostring(self.curData.itemid),1,price)
                    end
                end
                local td_param = {}
                td_param['price'] = price
                td_param['itemid'] = self.curData.itemid
                td_param['item_name'] = DB.getItemName(self.curData.itemid)
                td_param['type'] = self.curData.type
                gLogEvent("shop.buy",td_param)
            end
            --如果是黑市商店，售价>=1000元宝的商品，点击购买时弹二次确认
            if (self.curData.costType==OPEN_BOX_DIAMOND and price>=1000) then
                gConfirmCancel(gGetWords("noticeWords.plist","item_buy",price),buy)
                return
            end
            buy()
        end
    else
        self.curData.discount=self.discount
        Panel.popUp(TIP_PANEL_SHOP_ITEM,self.curData) 
    end

end

function ShopItem:setData(data)
    -- print_lua_table(data);
    self.curData=data
    data.itemid = DB.checkReplaceItem(data.itemid);
    local db=DB.getItemData(data.itemid)
    Icon.setIcon(data.itemid,self:getNode("icon"),DB.getItemQuality(data.itemid)) 
    if(DB.getSoulNeedLight(data.itemid))then
        Icon.addSpeEffectForSoul(self:getNode("icon"));
    end
    self:setLabelString("txt_name",DB.getItemName(data.itemid))

    if(data.costType==OPEN_BOX_DIAMOND)then
        Icon.changeDiaIcon(self:getNode("cost_icon"))
        Icon.changeDiaIcon(self:getNode("cost_icon2"))
    elseif(data.costType==OPEN_BOX_EXPLOIT)then
        Icon.changeExploitIcon(self:getNode("cost_icon"))
        Icon.changeExploitIcon(self:getNode("cost_icon2"))
    elseif(data.costType==OPEN_BOX_FEAT)then
        Icon.changeFeatIcon(self:getNode("cost_icon"))
        Icon.changeFeatIcon(self:getNode("cost_icon2"))
    elseif(data.costType==OPEN_BOX_GOLD)then
        Icon.changeGoldIcon(self:getNode("cost_icon"))
        Icon.changeGoldIcon(self:getNode("cost_icon2"))
    elseif(data.costType==OPEN_BOX_REPU)then
        Icon.changeRepuIcon(self:getNode("cost_icon"))
        Icon.changeRepuIcon(self:getNode("cost_icon2")) 
    elseif(data.costType==OPEN_BOX_FAMILY_DEVOTE)then
        Icon.changeDevoteIcon(self:getNode("cost_icon"))
        Icon.changeDevoteIcon(self:getNode("cost_icon2"))
    elseif(data.costType == OPEN_BOX_SOULMONEY)then
        Icon.changeSoulMoneyIcon(self:getNode("cost_icon"))
        Icon.changeSoulMoneyIcon(self:getNode("cost_icon2"))
    elseif(data.costType == OPEN_BOX_SERVERBATTLE)then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_SERVERBATTLE)
        Icon.changeSeqItemIcon(self:getNode("cost_icon2"),OPEN_BOX_SERVERBATTLE) 
    elseif(data.costType==OPEN_BOX_PETMONEY)then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_PETMONEY)
        Icon.changeSeqItemIcon(self:getNode("cost_icon2"),OPEN_BOX_PETMONEY)
        -- print("data.pettower = "..data.pettower);
        -- print("Data.pet.topFloor = "..Data.pet.topFloor);
        if data.pettower > 0 and Data.pet.topFloor < data.pettower then
            self:replaceLabelString("tip_unlock",data.pettower);
            self.hasUnlock = true;
        end
    elseif(data.costType == OPEN_BOX_TOWERMONEY)then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_TOWERMONEY)
        Icon.changeSeqItemIcon(self:getNode("cost_icon2"),OPEN_BOX_TOWERMONEY)
    elseif(data.costType == OPEN_BOX_EMOTION_MONEY)then
        Icon.changeEmoneyIcon(self:getNode("cost_icon"))
        Icon.changeEmoneyIcon(self:getNode("cost_icon2"))
    elseif(data.costType == OPEN_BOX_SNATCH_MONEY)then
        Icon.changeSnatchIcon(self:getNode("cost_icon"))
        Icon.changeSnatchIcon(self:getNode("cost_icon2"))

    elseif(data.costType == OPEN_BOX_FAMILY_MONEY)then
        Icon.setSpeIcon(OPEN_BOX_FAMILY_MONEY,self:getNode("cost_icon"))
        Icon.setSpeIcon(OPEN_BOX_FAMILY_MONEY,self:getNode("cost_icon2"))
    elseif(data.costType == OPEN_BOX_CONSTELLATION_SOUL) then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_CONSTELLATION_SOUL)
        Icon.changeSeqItemIcon(self:getNode("cost_icon2"),OPEN_BOX_CONSTELLATION_SOUL)
    end

    if(self.curShopType == SHOP_TYPE_TOWER1 or self.curShopType == SHOP_TYPE_TOWER2 or self.curShopType == SHOP_TYPE_TOWER3)then
        if(Data.towerInfo.maxstar < data.unlockStar)then
            self:setLabelString("tip_unlock",gGetWords("towerWords.plist","unlockStar",data.unlockStar));
            -- self:replaceLabelString("tip_unlock",data.unlockStar);
            self.hasUnlock = true;
        end
    end
    self:setLabelString("txt_price2",data.price)
    if(data.num>1 or self.curShopType == SHOP_TYPE_CONSTELLATION)then
        self:setLabelString("txt_num",data.num)
    else
        self:setLabelString("txt_num","")
    end

    if data.costType ==OPEN_BOX_SNATCH_MONEY then
        self:setLabelString("txt_num",data.itemnum)
    end
    self.num = data.num

    if(self.hasLimitBuy and data.limitNum)then
        self:replaceLabelString("txt_limit_num",(data.limitNum - data.buyNum),data.limitNum);
    end

    if(self.discount and self.discount < 100)then

        self:setLabelString("txt_price",math.ceil(data.price*self.discount/100))
        self:getNode("txt_discount"):setRotation(-45)
        self:replaceLabelString("txt_discount",gGetDiscount(self.discount/10))
        self:getNode("flag_discount"):setVisible(true); 
        self.hasOrgPrice=true
    else
        self:setLabelString("txt_price",data.price)
        self:getNode("flag_discount"):setVisible(false); 
    end
    self:getNode("bg_limit"):setVisible(self.hasLimitBuy);
    self:getNode("tip_unlock"):setVisible(self.hasUnlock);
    self:getNode("btn_buy"):setVisible(true);

    if(self.hasOrgPrice or self.hasUnlock)then
        self:getNode("layer_up"):setPositionY(self:getNode("layer_up"):getPositionY() + 7);
        self:getNode("layer_icon"):setPositionY(self:getNode("layer_icon"):getPositionY() + 5);
    end
    
    self:refresh();
    self:resetLayOut();
end

function ShopItem:refresh(param)
    self:refreshEmergencyFlag();
    if(self.curData.num <= 0)then
        self.hasSellOut = true;
    end

    if param ~= nil and param == self.curData.pos and
        self.curShopType == SHOP_TYPE_FAMILY_5 then
        self.hasSellOut = true
    end

    self:getNode("flag_sell_out"):setVisible(self.hasSellOut);

    if(self.hasSellOut)then
        self:setTouchEnable("touch_node",false);
        self:getNode("btn_buy"):setVisible(false);
        self:getNode("flag_sell_out"):setVisible(true);
        self:getNode("icon"):removeChildByTag(100);
        DisplayUtil.setGray(self:getNode("icon"),true);
        if  self.curData.costType ~=OPEN_BOX_SNATCH_MONEY then
            self:setLabelString("txt_num","")
        end
    elseif(self.hasUnlock)then
        self:getNode("btn_buy"):setVisible(false);
    end

    if(self.hasLimitBuy and self.curData.limitNum)then
        self:replaceLabelString("txt_limit_num",(self.curData.limitNum - self.curData.buyNum),self.curData.limitNum);
    end

end

function ShopItem:refreshEmergencyFlag()
    -- 星魂兑换商店，显示急需
    if (self.curShopType == SHOP_TYPE_CONSTELLATION) then
        local itemNeedType = gConstellation.getItemNeedType(self.curData.itemid)
        if  itemNeedType == 2 then
            self:changeTexture("flag_emergency", "images/ui_word/need.png")
            self:getNode("flag_emergency"):setVisible(true)
        elseif itemNeedType == 1 then
            self:changeTexture("flag_emergency", "images/ui_word/need1.png")
            self:getNode("flag_emergency"):setVisible(true)
        elseif itemNeedType == 3 then
            self:changeTexture("flag_emergency", "images/ui_word/shengxingzi.png")
            self:getNode("flag_emergency"):setVisible(true)
        else
            self:getNode("flag_emergency"):setVisible(false)
        end
    elseif (self.curShopType == SHOP_TYPE_SOUL) then
        local itemType=DB.getItemType(self.curData.itemid)
        if itemType == ITEMTYPE_CARD_SOUL then
            self:changeTexture("flag_emergency", "images/ui_word/need1.png")
            self:getNode("flag_emergency"):setVisible(Data.isCardTop6(self.curData.itemid - ITEM_TYPE_SHARED_PRE ))
        end
    end    
end



return ShopItem