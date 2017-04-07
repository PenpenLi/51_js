local TreasureBuyTimes=class("TreasureBuyTimes",UILayer)

function TreasureBuyTimes:ctor(treasure,mergenum) 
    self:init("ui/ui_treasure_buy_times.map")
    self.buyTimes = 2;
    self.itemNum=mergenum
    self:setItemId(treasure)
    self:refreshInfo(self.buyTimes);
end

function TreasureBuyTimes:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_sub" then
        self:subBuyTimes(1);
    elseif target.touchName == "btn_add" then
        self:addBuyTimes(1);
    elseif target.touchName == "btn_sub1" then
        self:subBuyTimes(10);
    elseif target.touchName == "btn_add1" then
        self:addBuyTimes(10);  
    elseif target.touchName == "btn_confirm" then
        Net.sendTreasureoOksyn(self.treasure.itemid,self.buyTimes)
        Panel.popBack(self:getTag())
    end
end


function TreasureBuyTimes:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;
    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function TreasureBuyTimes:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.itemNum then
        self.buyTimes = self.itemNum;
    end
    
    self:refreshInfo(self.buyTimes);
end

function TreasureBuyTimes:refreshInfo(buyTimes)
    self:setLabelAtlas("txt_buy_times",buyTimes); 
    self:resetLayOut();
end


function TreasureBuyTimes:setItemId(treasure)
    self.treasure=treasure

    local treasuredb=DB.getTreasureById(treasure.itemid)
    self.buyTimes=self.itemNum
    self:refreshInfo(self.buyTimes);
    local db,type= DB.getItemData(treasure.itemid)
    if(db==nil)then
        return
    end
    self:setLabelString("txt_name",db.name) 
    self:replaceLabelString("txt_maxnum",self.itemNum)
     
    Icon.setIcon(treasure.itemid,self:getNode("icon"),DB.getItemQuality(treasure.itemid)) 
    
end

return TreasureBuyTimes
