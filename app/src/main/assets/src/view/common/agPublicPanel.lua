local AdvertisePanel=class("AdvertisePanel",UILayer)

function AdvertisePanel:ctor(idx)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_agpublic_info.map")
    self.idx = idx
    self:setAdvertiseByIdx(idx)
end

function AdvertisePanel:setAdvertiseByIdx(idx)
    
    if idx > Data.getAdvertisesCount() then
        return
    end

    local advertiseInfo = Data.getAdvertiseByIdx(idx)
    if nil == advertiseInfo then
        return
    end

    self:getNode("layer_ad1"):setVisible(advertiseInfo.aid == 1)
    self:getNode("layer_ad2"):setVisible(advertiseInfo.aid == 2)
    self:getNode("layer_ad3"):setVisible(advertiseInfo.aid == 3)

    if advertiseInfo.aid == 1 then
        self:setLabelString("txt_gold_need", advertiseInfo.param2)
        self:getNode("layout_ad1_top"):layout()
        self:showCard()
        if advertiseInfo.endTime > gGetCurServerTime() then
            self:setLefttime(advertiseInfo.endTime)
        else
            self:setOverTime()
        end
    else
        self:getNode("layout_time"):setVisible(false)
    end
end

function AdvertisePanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_recharge" then
        -- Panel.popUp(PANEL_PAY)
        self:onClose()
        self.recharge = true
        Panel.popUp(PANEL_ACTIVITY_ALL,{type=ACT_TYPE_3,icon=3})
    end
end

function AdvertisePanel:setLefttime(endTime)
    self.endTime = endTime
    self.leftDay = 0
    self.reLayout = true
    self.preTimeStatue = 0
    self.preLeftDay = 0
    local function updateTime()
        self.leftDay = gGetDayByLeftTime(self.endTime - gGetCurServerTime())
        -- print("self.leftDay = "..self.leftDay)
        if(self.leftDay > 0)then
            if(self.leftDay ~= self.preLeftDay)then
                self.preLeftDay = self.leftDay
                self:replaceLabelString("txt_day",self.leftDay)
                self:getNode("txt_day"):setVisible(true)
            end
            self.preTimeStatue = 1
        else
            self:getNode("txt_day"):setVisible(false)
            if(self.preTimeStatue ~= 2)then
                self.reLayout = true
            end
            self.preTimeStatue = 2
        end
        if(self.endTime >= gGetCurServerTime())then
            self:setLabelString("txt_refresh_time2", gParserHourTime(self.endTime - gGetCurServerTime() - self.leftDay*24*60*60))
            local time = math.max(self.endTime-gGetCurServerTime(),0)
            if (time==0) then
                self.endTime = 0
                self:setOverTime()
                self.reLayout = true
            end
        end
        if(self.reLayout)then
            self.reLayout = false
            self:getNode("layout_time"):layout()
        end
    end
    self:scheduleUpdate(updateTime,1)
end

function AdvertisePanel:setOverTime()
    self:getNode("txt_day"):setVisible(false)
    self:setLabelString("txt_flag_time","")
    local strWord = gGetWords("activityNameWords.plist","act_eat7")
    self:setLabelString("txt_refresh_time2",strWord)
    self:getNode("layout_time"):layout()
    self:unscheduleUpdateEx()
end

function AdvertisePanel:onUILayerExit()
    if nil ~= self.super then
        self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
    if self.recharge then
        Data.clearAdvertises()
    elseif self.idx < Data.getAdvertisesCount() then
        Panel.popUp(PANEL_ADVERTISE,self.idx + 1,nil,true,true)
    else
        Data.clearAdvertises()
    end
end

function AdvertisePanel:showCard()
    local cardIDS = {110001,110003,110015}
    for i  = 1, 3 do
        -- local item= Data.activityPayData.list[3].items[i] 
        local cardID = cardIDS[i]
        if (DB.getItemType(cardID) == ITEMTYPE_CARD_SOUL) then
            cardID = cardID - ITEM_TYPE_SHARED_PRE
        end
        local card=DB.getCardById(cardID)
        if nil ~= card then
            self:refreshCard(i,card)
        end
    end
end

function AdvertisePanel:refreshCard(idx,card)
    local uilayer = self:getNode("layer"..idx);
    if uilayer == nil then
        return
    end
    uilayer:setVisible(true)

    local name = gCreateVerticalWord(card.name,gCustomFont,20,cc.c3b(255,255,255),-2)
    uilayer:replaceNode("txt_name",name);
    if(idx == 1)then
        if(uilayer:getNode("icon"):getScaleX()>0)then
            uilayer:getNode("icon"):setScaleX(-uilayer:getNode("icon"):getScaleX());
        end
    end
    
    local actions={ }
    table.insert(actions,"wait") 
    table.insert(actions,"attack_s")
    table.insert(actions,"win")
   
    local role=FlashAni.new()
    loadFlaXml("r"..card.cardid)
    local function  playEnd() 
        if(getRand(0,100)<50)then 
            role:playAction("r"..card.cardid.."_wait",playEnd)
            return
        end
        role.actIdx=role.actIdx+1
        if(role.actIdx>table.getn(actions))then
            role.actIdx=1
        end
        role:playAction("r"..card.cardid.."_"..actions[role.actIdx],playEnd)
    end 
    role.actIdx=1
    role:playAction("r"..card.cardid.."_"..actions[role.actIdx],playEnd)
    uilayer:getNode("icon"):removeAllChildren()
    gAddCenter(role,uilayer:getNode("icon")) 
    
    Icon.setCardCountry(uilayer:getNode("country"),card.country);

end

return AdvertisePanel