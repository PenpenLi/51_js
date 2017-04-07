local FamilyShop2Item=class("FamilyShop2Item",UILayer)

function FamilyShop2Item:ctor()
    self:init("ui/ui_family_shop2_item.map")
end

function FamilyShop2Item:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if(gFamilyInfo.isTempMember)then
            gShowCmdNotice("family.buygoods",11);
            return;
        end
        if NetErr.BuyShopItem(self.curData.priceid,self.curData.price) then
            gLogPurchase("family.buygoods", 1, self.curData.price)
            local td_param = {}
            --td_param['id'] = tostring(self.curData.itemid)
            td_param['item_name'] = DB.getItemName(self.curData.itemid)
            td_param['family'] = gFamilyInfo.sName
            gLogEvent("family.buygoods", td_param)
            Net.sendFamilyShop2Buy(self.curData.id);
        end
    end
end


function FamilyShop2Item:setData(data)
    self.curData=data 
    
    Icon.setDropItem(self:getNode("icon"), data.itemid,data.itemnum,DB.getItemQuality(data.itemid))

    -- local db=DB.getItemData(data.itemidList[2])
    local itemName = DB.getItemName(data.itemid)
    if itemName ~= "" then
        self:setLabelString("txt_name",itemName)
    end

    -- self:setLabelString("txt_num2",data.numList[2])
    self:replaceLabelString("txt_num",(data.count - data.fnum),data.count);
    -- self:setLabelString("txt_num",(data.count - data.fnum).."/"..data.count)
    self:setLabelString("txt_price1", data.oldprice)
    self:setLabelString("txt_price2", data.price)
    self:replaceLabelString("txt_num_buy",(data.single - data.unum));

    if(self.curData.priceid==OPEN_BOX_DIAMOND)then
        Icon.changeDiaIcon(self:getNode("money_icon1"))
        Icon.changeDiaIcon(self:getNode("money_icon2"))
    elseif(self.curData.priceid==OPEN_BOX_GOLD)then
        Icon.changeGoldIcon(self:getNode("money_icon1"))
        Icon.changeGoldIcon(self:getNode("money_icon2"))
    elseif(self.curData.priceid==OPEN_BOX_REPU)then
       Icon.changeRepuIcon(self:getNode("money_icon1"))
       Icon.changeRepuIcon(self:getNode("money_icon2"))
    elseif(self.curData.priceid==OPEN_BOX_FAMILY_DEVOTE)then
       Icon.changeDevoteIcon(self:getNode("money_icon1"))
       Icon.changeDevoteIcon(self:getNode("money_icon2"))
   end
 
    if(data.fnum>=data.count or data.unum >= data.single)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end
end

function FamilyShop2Item:refreshData()
    self:setData(self.curData)
end


return FamilyShop2Item