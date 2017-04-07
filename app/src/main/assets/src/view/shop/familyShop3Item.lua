local FamilyShop3Item=class("FamilyShop3Item",UILayer)

function FamilyShop3Item:ctor()
    self:init("ui/ui_family_shop3_item.map")
end

function FamilyShop3Item:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if(gFamilyInfo.isTempMember)then
            gShowCmdNotice("family.buylvreward",11);
            return;
        end
        if(Data.getCurFamilyLv() < self.curData.id) then
            gShowNotice(gGetWords("noticeWords.plist","no_family_level"));
            return;
        end
        if NetErr.BuyShopItem(self.curData.priceid,self.curData.price) then
            Net.sendFamilyShop3Buy(self.curData.id);
        end
    end
end


function FamilyShop3Item:setData(data)
    self.curData=data 
    
    -- Icon.setDropItem(self:getNode("icon"), data.itemid,data.itemnum,DB.getItemQuality(data.itemid))

    -- local db=DB.getItemData(data.itemidList[2])
    -- local itemName = DB.getItemName(data.itemid)
    -- if itemName ~= "" then
    --     self:setLabelString("txt_name",itemName)
    -- end
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
   end

   --data.id就是需求等级
   self:replaceLabelString("txt_desc",data.id);
 
     -- or Data.getCurFamilyLv() < data.id
    if(data.num>=data.count)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end

    self:resetLayOut();
end

function FamilyShop3Item:refreshData()
    self:setData(self.curData)
end


return FamilyShop3Item