local VipGiftItem=class("VipGiftItem",UILayer)

function VipGiftItem:ctor()
    self:init("ui/ui_gift_item.map")

    self:getNode("txt_limit"):setVisible(false)
    self:getNode("txt_num"):setVisible(false)
    self:getNode("txt_num2"):setVisible(false)

    self:setTouchEnable("btn_get",false,true)
    self.curPirce = 0;
end

function VipGiftItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if gUserInfo.vip >= self.curData.vip then
            if NetErr.isDiamondEnough(self.curPirce) then
                Net.sendGiftBuy(toint(self.curData.boxid))
                if (TDGAItem) then
                    gLogPurchase("vipgift.buy",1,self.curPirce)
                end
            end
        else
            local callback = function ()
                Panel.popUp(PANEL_PAY);
            end
            local needDia = self.curData.charge-gUserInfo.vipsc;
            local word = gGetWords("vipWords.plist","vipTip",needDia,self.curData.vip);
            gConfirmCancel(word,callback);
        end
    elseif(target.touchName=="icon")then
    	Panel.popUpUnVisible(PANEL_GIFT,self.curData)
    end
end

function VipGiftItem:setData(data)
    self.curData=data 

    -- local word= gGetWords("labelWords.plist","lab_upi_vip_box",data.vip)
    -- self:setLabelString("txt_name",word)
    self:setLabelString("txt_name",DB.getItemName(data.boxid))

    if data.boxid == 0 then
        self:getNode("txt_price1"):setVisible(false);
        self:getNode("txt_price2"):setVisible(false);
        self:getNode("btn_get"):setVisible(false);
    else
        local gift=DB.getGiftCommonById(data.boxid)
        if(gift)then
        	Icon.setBoxIcon(23200,self:getNode("icon"))

            self:setLabelString("txt_price1",gift.orliprice)
            self:setLabelString("txt_price2",gift.curprice)
            self.curPirce = gift.curprice;
        end
    end

    self:setBuyNum();
    self:resetLayOut();
end

function VipGiftItem:setBuyNum()
    self:getNode("txt_limit"):setVisible(false)
    local item= Data.getGiftBagBuy(self.curData.boxid)
    if(item and item.num<=0)then
        self:setTouchEnable("btn_get",true,false)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buy"));

        if gUserInfo.vip < self.curData.vip then
            self:getNode("txt_limit"):setVisible(true)
            local word = gGetWords("vipWords.plist","vipGiftBuy",self.curData.vip);
            self:setLabelString("txt_limit",word)
        end
    else
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buyed"));
    end
end

function  VipGiftItem:refreshData(param)
    self:setData(self.curData)
end
return VipGiftItem