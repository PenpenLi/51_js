local richmanShopPanel=class("richmanShopPanel",UILayer)

function richmanShopPanel:ctor(id)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_richman_shop.map")
 
    local db= DB.getRichmanConfig(id)
    if(db)then

        for i=1, 3 do
            self:getNode("icon"..i):setVisible(false)
        end


        local rewards= cjson.decode(db.item);
        for i, var in pairs(rewards) do
            if(self:getNode("icon"..i))then
                self:getNode("icon"..i):setVisible(true)
                Icon.setDropItem(self:getNode("icon"..i),var.id,var.num)
            end
        end

        self:setLabelString("txt_price1",db.min)
        self:setLabelString("txt_price2",db.max)
    end
end
 

function richmanShopPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
        
    elseif(target.touchName=="btn_buy")then
        Net.sendRichmanShopBuy()
        self:onClose()
    end
end
 
return richmanShopPanel