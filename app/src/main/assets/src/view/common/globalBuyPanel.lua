local GlobalBuyPanel=class("GlobalBuyPanel",UILayer)

function GlobalBuyPanel:ctor(type)
    self.appearType = 1;
    self.discount=100
    self.isWindow = true;
    self.isMainLayerMenuShow = false;
    self.isMainLayerOtherShow = false;
    self:init("ui/ui_buy_energy.map")
    self.vipType = type;
    self:initPanel();
    self:refresh();

end

function GlobalBuyPanel:initPanel()

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
    elseif self.vipType == VIP_EXP then
        self:changeTexture("icon","images/icon/sep_item/90017.png");
    elseif self.vipType == VIP_BUYPETSOUL then
        self:changeTexture("icon","images/icon/sep_item/90016.png");
    elseif self.vipType == VIP_SKILLPOT then
        self:changeTexture("icon","images/icon/sep_item/90015.png");
    elseif self.vipType == VIP_TOWERMONEY then
        self:changeTexture("icon","images/icon/sep_item/90024.png");
    end

    local types = {VIP_DIAMONDHP,VIP_EXP,VIP_BUYPETSOUL,VIP_SKILLPOT,VIP_TOWERMONEY};
    for key,var in pairs(types) do
        local icon = self:getNode("icon_content"..var);
        if icon then
            icon:setVisible(var == self.vipType);
        end
    end

end

function GlobalBuyPanel:refresh()

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
        self:getNode("container"):addChild(line)
    end

end 

function GlobalBuyPanel:refreshVipChange()
    local curTimes = Data.getUsedTimes(self.vipType);
    local maxTimes = Data.getMaxUseTimes(self.vipType);
    local leftTimes = math.max(maxTimes - curTimes,0);

    self:setLabelString("txt_num",leftTimes.."/"..maxTimes)
end

function GlobalBuyPanel:events()
    return {
        EVENT_ID_GOLBAL_BUY,
        EVENT_ID_GET_ACTIVITY_VIP_CHANGE
    }
end

function GlobalBuyPanel:dealEvent(event,param)
    if(event==EVENT_ID_GOLBAL_BUY)then
        self:refresh();
    elseif(event == EVENT_ID_GET_ACTIVITY_VIP_CHANGE)then
        self:refreshVipChange()
    end
end

function GlobalBuyPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_buy"then

        if self.vipType == VIP_DIAMONDHP then
            if(NetErr.isEnergyFull()) then
                return;
            end
        end

        local callback = function() 
            if self.vipType == VIP_DIAMONDHP then
                Net.sendBuyEnergy();
            elseif self.vipType == VIP_EXP then
                Net.sendBuyExp();
            elseif self.vipType == VIP_BUYPETSOUL then
                Net.sendBuyPetSoul();
            elseif self.vipType == VIP_SKILLPOT then
                Net.sendBuySkillPoint();
            elseif self.vipType == VIP_TOWERMONEY then
                Net.sendBuyTowerMoney();
            end
        end
        Data.canBuyTimes(self.vipType,true,callback,self.discount);
    end

end

return GlobalBuyPanel