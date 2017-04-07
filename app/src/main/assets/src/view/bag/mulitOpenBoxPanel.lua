local MulitOpenBoxPanel=class("MulitOpenBoxPanel",UILayer)

function MulitOpenBoxPanel:ctor(itemid)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self:init("ui/ui_open_box.map")
    self:setItemId(itemid);
    self.buyTimes = 1;
    self:refreshInfo(self.buyTimes);
end
 
function MulitOpenBoxPanel:onTouchEnded(target)
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
    elseif(target.touchName == "btn_open")then
        if(self.itemid==CRUSASH_KEY_ID)then
            Net.sendUseItem(self.itemid, self.buyTimes)
        elseif Data.isMineBagItem(self.itemid) then
            Net.sendMiningOpenBox(self.itemid, self.buyTimes) 
        else
            Net.sendOpenBox(self.itemid,self.buyTimes) 
        end
        Panel.popBack(self:getTag())
    end
end


function MulitOpenBoxPanel:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;
    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function MulitOpenBoxPanel:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.itemNum then
        self.buyTimes = self.itemNum;
    end
    
    if self.buyTimes > DB.getClientParam("ITEM_BOX_OPEN_LIMIT") then
        self.buyTimes = DB.getClientParam("ITEM_BOX_OPEN_LIMIT")
    end
    self:refreshInfo(self.buyTimes);
end

function MulitOpenBoxPanel:refreshInfo(buyTimes)
    self:setLabelAtlas("txt_buy_times",buyTimes); 
    self:resetLayOut();
end

function MulitOpenBoxPanel:setItemId(itemid)
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
    
end

-- function MulitOpenBoxPanel:setData(data,tagType) 
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

 
 
return MulitOpenBoxPanel