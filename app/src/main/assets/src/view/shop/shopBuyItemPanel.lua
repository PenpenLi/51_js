local ShopBuyItemPanel=class("ShopBuyItemPanel",UILayer)

function ShopBuyItemPanel:ctor(data)

    self.appearType = 1;
    self.isWindow = true;
    self.isMainLayerGoldShow = true;
    self.isMainLayerMenuShow = false;
    -- self._panelTop = true;
    self:init("ui/ui_shop_buy_item.map");
    self.buyTimes=1
    self.lefttimes=data.lefttimes
    self.price=data.price
    self.rewardNum=data.rewardNum
    self.curData=data
    local itemid=data.itemid
    local db,type= DB.getItemData(itemid)
    if(db==nil)then
        return
    end
    self.itemDB=db
    self.buyCallback=data.buyCallback
    local num=Data.getItemNum(itemid)
    self:setLabelString("txt_info",DB.getItemAttrDes(itemid))
    if(DB.getItemType(itemid)==ITEMTYPE_TREASURE_SHARED)then

        self:setRTFString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num2",num.."/"..db.com_num))
    else

        self:setRTFString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num2",num ))
    end
    self:setLabelString("txt_name",self.itemDB.name )
    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid))


    if(DB.getItemType(self.curData.itemid)==ITEMTYPE_TREASURE_SHARED)then
        self:getNode("btn_preview"):setVisible(true)
    else
        self:getNode("btn_preview"):setVisible(false)
    end
    if data.costType == OPEN_BOX_SNATCH_MONEY then
        self:getNode("txt_tip"):setVisible(false)
    end

    if(data.costType==OPEN_BOX_EXPLOIT)then
        Icon.changeExploitIcon(self:getNode("cost_icon"))
        self.isMainLayerGoldShow=false
        self.isMainLayerCrusadeShow=true
    elseif(data.costType==OPEN_BOX_FEAT)then
        Icon.changeFeatIcon(self:getNode("cost_icon"))
        self.isMainLayerGoldShow=false
        self.isMainLayerCrusadeShow=true
    end

    Icon.changeSeqItemIcon(self:getNode("cost_icon"),data.costType)
    self:getNode("limit_buy"):setVisible(data.hasLimitBuy);
    self:refreshInfo(self.buyTimes)
end


function ShopBuyItemPanel:refreshInfo(buyTimes)
    self:setLabelAtlas("txt_buy_times",buyTimes);
    local price=self.price*buyTimes
    self:setLabelString("txt_dia",price);

    self:setLabelString("txt_num2", "x"..(buyTimes*self.rewardNum))
    if(self.curData.hasLimitBuy)then
        self:replaceRtfString("txt_tip",self.curData.lefttimes,self.curData.limitNum);
    end
end

function ShopBuyItemPanel:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;

    if self.buyTimes > self.lefttimes then
        self.buyTimes = self.lefttimes;
    end

    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function ShopBuyItemPanel:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.lefttimes then
        self.buyTimes = self.lefttimes;
    end
    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function ShopBuyItemPanel:onTouchEnded(target)

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
        if(self.curData.hasLimitBuy and self.curData.lefttimes <= 0)then
            gShowNotice(gGetWords("shopWords.plist","7"));
            return;
        end
        self.buyCallback(self.buyTimes);
        Panel.popBack(self:getTag())
    elseif target.touchName=="icon" then
        if(DB.getItemType(self.curData.itemid)==ITEMTYPE_TREASURE_SHARED)then
            local data=clone(self.curData)
            data.itemid=data.itemid-ITEM_TYPE_SHARED_PRE
            local tip=Panel.popUp(TIP_TREASURE,data)
        end
    end
end

return ShopBuyItemPanel