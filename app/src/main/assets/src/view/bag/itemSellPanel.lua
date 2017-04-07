local ItemSellPanel=class("ItemSellPanel",UILayer)

function ItemSellPanel:ctor(itemid)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
   self:init("ui/ui_item_sell.map")
   self:setItemId(itemid);
   self.buyTimes = 1;
   self:refreshInfo(self.buyTimes);
end
 
function ItemSellPanel:onTouchEnded(target)
    if(target.touchName == "btn_close")then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_sub" then
        self:subBuyTimes(1);
    elseif target.touchName == "btn_add" then
        self:addBuyTimes(1);
    elseif target.touchName == "btn_sub1" then
        self:subBuyTimes(10);
    elseif target.touchName == "btn_add1" then
        self:addBuyTimes(10);  
    elseif(target.touchName == "btn_confirm")then
        Net.sendSellItem(self.itemid, self.buyTimes)
        Panel.popBack(self:getTag())
    end
end


function ItemSellPanel:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;
    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function ItemSellPanel:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.itemNum then
        self.buyTimes = self.itemNum;
    end
    self:refreshInfo(self.buyTimes);
end

function ItemSellPanel:refreshInfo(buyTimes)
    self:setLabelAtlas("txt_buy_times",buyTimes);
    self:setLabelString("txt_price_all",self.price*buyTimes);
    self:resetLayOut();
end

function ItemSellPanel:setItemId(itemid)
    self.itemid=itemid
    local db,type= DB.getItemData(itemid)
    if(db==nil)then
        return
    end
    local num=Data.getItemNum(itemid)
    self.itemNum = num; 
    self:setLabelString("txt_name",db.name) 
    self:setRTFString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num2",self.itemNum))
     
    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid))
    self.price = EquipItem.getSellPrice(itemid);
    self:setLabelString("txt_price",self.price);
    
end

-- function ItemSellPanel:setData(data,tagType) 
--     self:initPanel()
--     self.curData=data
--     if(data.itemid==nil)then
--         return
--     end
--     self:setLabelString("txt_num",data.num)
     
--     local itemid=data.itemid
--     if(tagType==5)then
--         itemid=itemid+ITEM_TYPE_SHARED_PRE
--     end
    
--     Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))
    
-- end

 
 
return ItemSellPanel