local EnergyBuyPanel=class("EnergyBuyPanel",UILayer)

function EnergyBuyPanel:ctor(type)
    self.appearType = 1;
    self.discount=100
    self.isWindow = true;
    self.isMainLayerMenuShow = false;
    self.isMainLayerOtherShow = false;
    self:init("ui/ui_buy_energy_2.map")
    self.vipType = type;
    self:initPanel();
    self:refresh();

end

function EnergyBuyPanel:initPanel()

    local name = gGetWords("vipWords.plist","itemType"..self.vipType);
    self:replaceLabelString("title",name);
    self:replaceLabelString("tip",name);

    if self.vipType == VIP_DIAMONDHP then
        self:changeTexture("icon","images/ui_public1/energy.png");
        if(Data.activityBuyEnergySaleoff.time and gGetCurServerTime()>Data.activityBuyEnergySaleoff.time)then
            Data.activityBuyEnergySaleoff={}
        end 

        if(Data.activityBuyEnergySaleoff.val)then
            self.discount= Data.activityBuyEnergySaleoff.val
        end

        Icon.setIcon(ITEM_HP,self:getNode("icon_bg"));
        self:setLabelString("hp_exchange",Data.buyEnergy.exchangeHp);
        self:refreshItemNum();
    end

end

function EnergyBuyPanel:refreshItemNum()
    self:replaceRtfString("txt_left",Data.getItemNum(ITEM_HP));
end

function EnergyBuyPanel:refresh()

    -- local needDia,rewardEnergy = Data.vip.energy.getBuyPriceAndCount();
    local needDia,rewardEnergy = Data.getBuyPriceAndCount(self.vipType);
    local curTimes = Data.getUsedTimes(self.vipType);
    local maxTimes = Data.getMaxUseTimes(self.vipType);
    local leftTimes = math.max(maxTimes - curTimes,0);

    self.needDia = needDia
    self:setLabelString("txt_num",leftTimes.."/"..maxTimes)
    self:setLabelString("txt_energy",rewardEnergy)
    self:setLabelString("txt_dia",needDia)    

    if(self.discount==100)then
        self:setLabelString("txt_dia2","")
        self:resetLayOut();
    else

        self:setLabelString("txt_dia2","      "..needDia*self.discount/100)     
        self:resetLayOut();
        local line=cc.Sprite:create("images/ui_huodong/redline.png")
        line:setPosition(self:getNode("txt_dia"):getPosition())
        line:setTag(100);
        self:getNode("container"):removeChildByTag(100);
        self:getNode("container"):addChild(line)
    end

end 


function EnergyBuyPanel:events()
    return {
        EVENT_ID_GOLBAL_BUY,
        EVENT_ID_UPDATE_REWORDS_DIRECT,
        EVENT_ID_GET_ACTIVITY_VIP_CHANGE
    }
end

function EnergyBuyPanel:dealEvent(event,param)
    if(event==EVENT_ID_GOLBAL_BUY)then
        self:refresh();
    elseif(event == EVENT_ID_UPDATE_REWORDS_DIRECT)then
        self:refreshItemNum();   
    elseif(event == EVENT_ID_GET_ACTIVITY_VIP_CHANGE)then
        self:refresh()
    end
end

function EnergyBuyPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_buy"then

        -- if self.vipType == VIP_DIAMONDHP then
        --     if(NetErr.isEnergyFull()) then
        --         return;
        --     end
        -- end

        local callback = function() 
            if self.vipType == VIP_DIAMONDHP then
                Net.sendBuyEnergy();
            end
        end
        Data.canBuyTimes(self.vipType,true,callback,self.discount);
    elseif target.touchName == "btn_use" then
        if(Data.getItemNum(ITEM_HP) <= 0) then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_item",DB.getItemName(ITEM_HP)));
            return;
        end
        Data.useItem(ITEM_HP)
        -- if(NetErr.isEnergyFull()) then
        --     return;
        -- end
        -- Net.sendUseItem(ITEM_HP,1)
    end

end

return EnergyBuyPanel