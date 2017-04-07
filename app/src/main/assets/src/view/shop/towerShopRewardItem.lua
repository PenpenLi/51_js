local TowerShopRewardItem=class("TowerShopRewardItem",UILayer)

function TowerShopRewardItem:ctor()
    self:init("ui/ui_tower_shop_item4.map")
end

function TowerShopRewardItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if(Data.towerInfo.maxstar < self.curData.id) then
            gShowNotice(gGetWords("noticeWords.plist","no_tower_star"));
            return;
        end
        if NetErr.BuyShopItem(self.curData.priceid,self.curData.price) then
            Net.sendTowerBuyReward(self.curData.id);
        end
    end
end


function TowerShopRewardItem:setData(data)
    self.curData=data 
    
    for i=1,3 do
        self:getNode("icon_"..i):setVisible(false);
    end
    -- print_lua_table(data.items);
    for key,var in pairs(data.items) do
        self:getNode("icon_"..key):setVisible(true);
        local item = Icon.setDropItem(self:getNode("icon_"..key),var.id,var.num,DB.getItemQuality(var.id))
        self:getNode("icon_"..key):setOpacity(255);
    end

    self:replaceLabelString("txt_num",data.num,data.count);
    self:setLabelString("txt_price", data.price)

    if(self.curData.priceid==OPEN_BOX_DIAMOND)then
        Icon.changeDiaIcon(self:getNode("money_icon"))
    elseif(self.curData.priceid==OPEN_BOX_GOLD)then
        Icon.changeGoldIcon(self:getNode("money_icon"))
    elseif(self.curData.priceid==OPEN_BOX_REPU)then
        Icon.changeRepuIcon(self:getNode("money_icon"))
    elseif(self.curData.priceid==OPEN_BOX_FAMILY_DEVOTE)then
        Icon.changeDevoteIcon(self:getNode("money_icon"))
    elseif(self.curData.priceid==OPEN_BOX_TOWERMONEY)then
        Icon.changeSeqItemIcon(self:getNode("money_icon"),OPEN_BOX_TOWERMONEY);
       -- Icon.changeDevoteIcon(self:getNode("money_icon"))
    end

   --data.id就是需求星数
   self:replaceLabelString("txt_desc",data.id);
 
     -- or Data.getCurFamilyLv() < data.id
    if(data.num>=data.count)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end

    self:resetLayOut();
end

function TowerShopRewardItem:refreshData(data)
    -- self:setData(self.curData)
    self:replaceLabelString("txt_num",data.num,data.count);
    if(data.num>=data.count)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end
end


return TowerShopRewardItem