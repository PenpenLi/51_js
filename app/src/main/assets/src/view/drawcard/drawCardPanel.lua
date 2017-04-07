local DrawCardPanel=class("DrawCardPanel",UILayer)

function DrawCardPanel:ctor(isShowDrawSoul)
    loadFlaXml("ui_kuang_texiao");
    self:init("ui/ui_draw_card.map")

    self.goldFree = false;
    self.diaFree = false;
    self:getNode("saleof_icon"):setVisible(false)

    local isUnlockDrawSoul = Unlock.isUnlock(SYS_DRAWSOUL,false);
    self:getNode("layer_soul"):setVisible(isUnlockDrawSoul);
    if(isUnlockDrawSoul)then
        self:setScrollLayerAdaptive(self:getNode("scroll"),true,0);
        self:getNode("scroll").container:setContentSize(self:getNode("bg"):getContentSize()) 
        if(isShowDrawSoul)then
            local scroll = self:getNode("scroll");
            local newPosX,newPosY = scroll:checkBoard(cc.p(scroll.container:getPositionX()-300,scroll.container:getPositionY()));
            self:getNode("scroll").container:setPositionX(newPosX);
        end
        -- self:getNode("bg"):setPositionX();
    else
        self:getNode("scroll"):setTouchEnable(false);
    end

 

    local function updateDrawTime() 

        if(Data.drawCard.gold==nil)then
            return
        end

        if(self:isVisible()~=true)then 
            return
        end 
        
        self:setLabelString("txt_ball_num",Data.drawCard.gball)
        if(10-Data.drawCard.lucky==1)then 
            self:setRTFString("txt_lucky", gGetWords("labelWords.plist","draw_card_lucky_just"))
        else

            self:replaceRtfString("txt_lucky",10-Data.drawCard.lucky)
        end
        self:setLabelString("txt_gold_ten",DB.getDrawGoldTen())
        self:setLabelString("txt_dia_ten",DB.getDrawDiamondTen())

        self:changeIconType("icon_dia_one",OPEN_BOX_DIAMOND)
        self:changeIconType("icon_dia_ten",OPEN_BOX_DIAMOND)
        self:setLabelString("txt_dia_one",DB.getDrawDiamondOne())


        if(Data.drawCard.gold.ftime )then
            local passTime=gGetCurServerTime()-Data.drawCard.time

            if(passTime>=Data.drawCard.gold.ftime)then
                self:setGoldFreeNum(Data.drawCard.gold.fnum) 
            else
                --金币倒计时
                local word=gGetWords("labelWords.plist","lab_free_time",gParserHourTime(Data.drawCard.gold.ftime-passTime))
                self:setLabelString("txt_gold_info", word)
                self:setLabelString("txt_gold_one",DB.getDrawGoldOne())
            end

        end



        local num=Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)
        if(num>0 or isBanshuReview())then
            self:getNode("icon_dia_one"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_ONE..".png")
            self:setLabelString("txt_dia_one","x"..1)
        end

        local num=Data.getItemNum(ITEM_ID_DRAW_CARD_TEN)
        if(num>0 or isBanshuReview())then
            if num>0 then
                self:getNode("icon_dia_ten"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_TEN..".png")
                self:setLabelString("txt_dia_ten","x"..1)
            else
                self:getNode("icon_dia_ten"):setTexture("images/icon/item/"..ITEM_ID_DRAW_CARD_ONE..".png")
                self:setLabelString("txt_dia_ten","x"..10)
            end
            
        end
        Data.drawCard.freeDia = false
        if(Data.drawCard.diamond.ftime )then
            local passTime=gGetCurServerTime()-Data.drawCard.time

            if(passTime>=Data.drawCard.diamond.ftime)then
                self:setDiaFreeNum(1)
                Data.drawCard.freeDia = true
            else 
                --钻石倒计时
                local word=gGetWords("labelWords.plist","lab_free_time",gParserHourTime(Data.drawCard.diamond.ftime-passTime))
                self:setLabelString("txt_dia_info", word)
            end

        end


        if(Data.drawCard.dct and  Data.drawCard.dct ~=0)then
            self:replaceLabelString("txt_discount",gGetDiscount(Data.drawCard.dct/10))
            self:getNode("txt_discount"):setRotation(-45)
            self:getNode("saleof_icon"):setVisible(true)
        else
            self:getNode("saleof_icon"):setVisible(false)
        end


    end

    self:scheduleUpdate(updateDrawTime,1)

    Net.sendDrawCardList() 

end

function DrawCardPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function DrawCardPanel:setGoldFreeNum(num)

    if(num==0)then 
        self:setLabelString("txt_gold_one",DB.getDrawGoldOne())
    else 
        self:setLabelString("txt_gold_one","lab_free","labelWords.plist") 
        self.goldFree = true;
    end
    self:setLabelString("txt_gold_info",gGetWords("labelWords.plist","lab_free_today",num)) 

end


function DrawCardPanel:setDiaFreeNum(num)
    self:setLabelString("txt_dia_one","lab_free","labelWords.plist") 
    self:setLabelString("txt_dia_info", "")
    if isBanshuReview() == false then
        self:changeIconType("icon_dia_one",OPEN_BOX_DIAMOND)
    end
    self.diaFree = true;
end

function DrawCardPanel:refreshSoulInfo()
    if(Data.drawCard.soul)then
        for i=1,4 do
            local itemid = Data.drawCard.soul["soul"..i]
            local item = Icon.setDropItem(self:getNode("soul"..i),toint("1"..itemid),0);
            -- if(DB.getSoulNeedLight(("1"..itemid)))then
            --     item:addSpeEffectForSoul();
            -- end
        end
        self:setLabelString("txt_soul_refresh",Data.drawCardParams.price_soul_refresh);
        self:setLabelString("txt_soul",Data.drawCardParams.price_soul_buy);
    end    
    self:refreshSoulLuck();
end

function DrawCardPanel:refreshSoulLuck()

    if(Data.drawCard.soulluck >= Data.drawCardParams.maxLuck)then
        self:getNode("soul_luckbox"):playAction("ui_atlas_box_2");
    else
        self:getNode("soul_luckbox"):playAction("ui_atlas_box_1");
    end    
end

function DrawCardPanel:events()
    return {EVENT_ID_DRAW_CARD_LIST,EVENT_ID_DRAW_GET_LUCKBOX};
end

function DrawCardPanel:dealEvent(event,param)

    if(event == EVENT_ID_DRAW_CARD_LIST) then
        self:refreshSoulInfo();
    elseif(event == EVENT_ID_DRAW_GET_LUCKBOX)then
        self:refreshSoulLuck();
    end
end


function DrawCardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_dragon_ball"then
        Panel.popUp(PANEL_SHOP_DRAGON_EXCHANGE)
    elseif  target.touchName=="btn_buy_gold_one"then
        if NetErr.isDrawCardEnough(0,0)  then 
            Panel.pushRePopupPanel(PANEL_DRAW_CARD)
            Net.sendDrawCard(0,0)
            self.goldFree = false;
        end
    elseif  target.touchName=="btn_buy_gold_ten"then
        if NetErr.isDrawCardEnough(0,1)  then  
            Panel.pushRePopupPanel(PANEL_DRAW_CARD)
            Net.sendDrawCard(0,1)
        end

    elseif  target.touchName=="btn_buy_dia_one"then
        -- if isBanshuReview() then
        --     if Data.getItemNum(ITEM_ID_DRAW_CARD_ONE) > 0 or self.diaFree == true then
        --     else
        --         gShowNotice(gGetWords("noticeWords.plist","no_draw_senior_item"))
        --         return
        --     end
        -- end
        if NetErr.isDrawCardEnough(1,0)  then 
            Panel.pushRePopupPanel(PANEL_DRAW_CARD)
            Net.sendDrawCard(1,0)
            self.diaFree = false;
        end

    elseif  target.touchName=="btn_buy_dia_ten"then
        -- if isBanshuReview() then
        --     if Data.getItemNum(ITEM_ID_DRAW_CARD_TEN) > 0 or Data.getItemNum(ITEM_ID_DRAW_CARD_ONE)>10 then
        --     else

        --         gShowNotice(gGetWords("noticeWords.plist","no_draw_senior_item"))
        --         return
        --     end
        -- end
        if NetErr.isDrawCardEnough(1,1)  then 
            Panel.pushRePopupPanel(PANEL_DRAW_CARD)
            Net.sendDrawCard(1,1)
        end
    elseif target.touchName == "btn_refresh_soul" then
        if gIsVipExperTimeOver(VIP_DRAWCARD_SOUL) then
            return
        end
        if NetErr.isDiamondEnough(Data.drawCardParams.price_soul_refresh) then
            Net.sendDrawSoulRefresh();
        end
    elseif target.touchName == "btn_buy_soul" then
        if gIsVipExperTimeOver(VIP_DRAWCARD_SOUL) then
            return
        end
        if NetErr.isDiamondEnough(Data.drawCardParams.price_soul_buy) then
            Panel.pushRePopupPanel(PANEL_DRAW_CARD)
            Net.sendDrawSoulBuy()
        end
    elseif target.touchName == "btn_check" then
        Panel.popUpVisible(PANEL_SOULLIST);
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_DRAWSOUL);
    elseif target.touchName == "soul_luckbox" then
        Panel.popUpVisible(PANEL_DRAWCARDBOX);         
    end

end


return DrawCardPanel