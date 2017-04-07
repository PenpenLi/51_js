local VipDayGiftItem=class("VipDayGiftItem",UILayer)

function VipDayGiftItem:ctor()
    self:init("ui/ui_gift_item.map")

    self:getNode("txt_limit"):setVisible(false)
    self:getNode("txt_num"):setVisible(false)
    self:getNode("txt_num2"):setVisible(false)

    self:setTouchEnable("btn_get",false,true)
    self.curPirce = 0;
end

function VipDayGiftItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if self.endtime and self.endtime < gGetCurServerTime() then
            gShowNotice(gGetWords("activityNameWords.plist","act_timeover"))
            return
        end
        
        if Data.getCurVip() >= self.curData.vip then
            if NetErr.isDiamondEnough(self.curPirce) then
                Net.sendGiftBuy(toint(self.curData.boxid))
                if (TDGAItem) then
                    gLogPurchase("vip_day_gift.buy",1,self.curPirce)
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

function VipDayGiftItem:setData(data)
    self.curData=data 
    self.curData.vip = data.limitpara
    local vipDatas=DB.getVipCharge()
    self.curData.charge = vipDatas[self.curData.vip+1]

    -- print_lua_table(self.curData)
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
        	Icon.setBoxIcon(20167,self:getNode("icon"))

            self:setLabelString("txt_price1",gift.orliprice)
            self:setLabelString("txt_price2",gift.curprice)
            self.curPirce = gift.curprice;
        end
    end

    self:setBuyNum();
    self:resetLayOut();
end

function VipDayGiftItem:setBuyNum()
    self:getNode("txt_limit"):setVisible(false)
    -- print("self.curData.boxid="..self.curData.boxid)
    local item= Data.getGiftBagBuy(self.curData.boxid)
    print_lua_table(item)
    if(item and item.num<=0)then
        self:setTouchEnable("btn_get",true,false)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buy"));

        if Data.getCurVip() < self.curData.vip then
            self:getNode("txt_limit"):setVisible(true)
            local word = gGetWords("vipWords.plist","vipGiftBuy",self.curData.vip);
            self:setLabelString("txt_limit",word)
        end
    else
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buyed"));
    end
end

function  VipDayGiftItem:refreshData(param)
    self:setData(self.curData)
end
return VipDayGiftItem