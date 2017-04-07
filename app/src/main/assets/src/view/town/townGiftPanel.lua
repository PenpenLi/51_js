local TowerGiftPanel=class("TowerGiftPanel",UILayer)

function TowerGiftPanel:ctor(closeCallback)

    self._panelTop = true;
    self.appearType = 1;
    self:init("ui/ui_tower_gift.map");
    self:addFullScreenTouchToClose();
    self.isMainLayerGoldShow=false
    self:initPanel();
    self.closeCallback = closeCallback;

end

function TowerGiftPanel:initPanel()
    self:setLabelString("txt_star",Data.towerInfo.curstar);
    self.price = 0;
    local itemid = Data.towerInfo.disreward.id;
    if(itemid)then
        if gCurLanguage == LANGUAGE_EN then
            self:replaceLabelString("txt_dis",100-Data.towerInfo.disreward.dis);
        else
            self:replaceLabelString("txt_dis",Data.towerInfo.disreward.dis/10);
        end
        
        Icon.setDropItem(self:getNode("icon_gift"),itemid,Data.towerInfo.disreward.num,DB.getItemQuality(itemid));
        self:setLabelString("txt_name",DB.getItemName(itemid));
        self:setLabelString("txt_price1",Data.towerInfo.disreward.pri*Data.towerInfo.disreward.num);
        self.price = math.floor(Data.towerInfo.disreward.pri*Data.towerInfo.disreward.num*Data.towerInfo.disreward.dis/100);
        self:setLabelString("txt_price2",self.price);  
        
        self:resetLayOut();  
    end
end

function TowerGiftPanel:onTouchEnded(target)

    -- if os.time() - self.initTime < 1 then
    --     return;
    -- end

    -- target.touchName == "full_close" or 
    if target.touchName == "full_close" or target.touchName == "btn_exit" then
        Panel.popBack(self:getTag())
        if(self.closeCallback)then
            self.closeCallback();
        end
    elseif target.touchName == "btn_buy" then
        if(NetErr.isDiamondEnough(self.price))then
            Panel.popBack(self:getTag());
            Net.sendTowerBuydisGift();
            gTDParam.tower_gift_price = self.price
            if(self.closeCallback)then
                self.closeCallback();
            end    
        end
    end

end

return TowerGiftPanel