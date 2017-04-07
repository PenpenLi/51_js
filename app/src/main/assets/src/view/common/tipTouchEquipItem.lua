local TipTouchEquipItem=class("TipTouchEquipItem",UILayer)

function TipTouchEquipItem:ctor(itemid)
    self:init("ui/tip_touch_equip.map")

    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid))
    
    if(Icon.isAttrItem(itemid))then
        self:setLabelString("txt_info", DB.getItemAttrDes(itemid))  
        self:setLabelString("txt_name", DB.getItemName(itemid))  
        self:hidePrice();

        self:layout();

        return
    end


    local db,type=DB.getItemData(itemid)

    if(db)then
        self:setLabelString("txt_name",db.name,nil,true)
        self:setLabelString("txt_gold",db.sell_money)
        self:setLabelString("txt_info",DB.getItemAttrDes(itemid))

        if db.sell_money == nil or db.sell_money == 0 then
            self:hidePrice();
        end
    end

    self:layout();
end

function TipTouchEquipItem:layout()
    self:resetLayOut();
    self:resetAdaptNode();

    self:setContentSize(self:getNode("tip_bg"):getContentSize());
end

function TipTouchEquipItem:hidePrice()
    self:getNode("gold_icon"):setVisible(false)
    self:getNode("txt_gold"):setVisible(false)
end

 

return TipTouchEquipItem