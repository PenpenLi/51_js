local ShopPanel=class("ShopPanel",UILayer)
ShopPanelData = {};
ShopPanelData.unlockShopType = 0;
ShopPanelData.shopType = 0;
ShopPanelData.refreshPrice = 0;
ShopPanelData.familyShop3BuyLv = 0;
ShopPanelData.sendId = 0;
ShopPanelData.sendNum = 0;

-- 海底兑换
-- 战功商店
-- 灵玉商店
-- 普通商店
-- 竞技场
-- 军团
-- 跨服
-- 情义值
gShopSequence = {
    {SHOP_TYPE_MINE},
    {SHOP_TYPE_CRUSADE},
    {SHOP_TYPE_PET},
    {SHOP_TYPE_1,SHOP_TYPE_2,SHOP_TYPE_3,SHOP_TYPE_SOUL},
    {SHOP_TYPE_ARENA},
    {SHOP_TYPE_FAMILY_4,SHOP_TYPE_FAMILY_5,SHOP_TYPE_FAMILY,SHOP_TYPE_FAMILY_2,SHOP_TYPE_FAMILY_3},
    {SHOP_TYPE_SERVERBATTLE},
    {SHOP_TYPE_DRAGON},
    {SHOP_TYPE_TOWER1,SHOP_TYPE_TOWER2,SHOP_TYPE_TOWER3,SHOP_TYPE_TOWER4},
    {SHOP_TYPE_EMOTION},
    {SHOP_TYPE_CONSTELLATION},
}

function gGetUnlockShopCount()
    local count = 0;
    for key,shops in pairs(gShopSequence) do
        if(gIsUnlockShop(shops[1]))then
            count = count + 1;
        end
    end
    return count;
end

function gIsUnlockShop(shopType)
    if(shopType == SHOP_TYPE_MINE)then
        return Unlock.isUnlock(SYS_MINE,false);
    elseif(shopType == SHOP_TYPE_CRUSADE) then
        return Unlock.isUnlock(SYS_CRUSADE,false);
    elseif(shopType == SHOP_TYPE_PET) then
        return Unlock.isUnlock(SYS_PET,false);
    elseif(shopType == SHOP_TYPE_1) then
        return true;
    elseif(shopType == SHOP_TYPE_ARENA) then
        return Unlock.isUnlock(SYS_ARENA,false);
    elseif(shopType == SHOP_TYPE_FAMILY or shopType == SHOP_TYPE_FAMILY_4) then
        return Unlock.isUnlock(SYS_FAMILY,false) and Data.hasFamily();
    elseif(shopType == SHOP_TYPE_SERVERBATTLE) then
        return Unlock.isUnlock(SYS_SERVER_BATTLE,false);
    elseif(shopType == SHOP_TYPE_DRAGON)then
        return true;
    elseif(shopType == SHOP_TYPE_TOWER1)then
        return Unlock.isUnlock(SYS_TOWER,false);
    elseif(shopType == SHOP_TYPE_EMOTION)then
        return not Module.isClose(SWITCH_SHOP_EMOTION);
    elseif(shopType == SHOP_TYPE_CONSTELLATION)then
        return Unlock.isUnlock(SYS_CONSTELLATION, false); 
    end
    return true;
end

function gPreShop(curShopType,tag)
    if curShopType == SHOP_TYPE_FAMILY_4 then
        Scene.clearLazyFunc("familyshop4item")
    end
    local curIndex = 0;
    local bFind = false;
    for key,var in pairs(gShopSequence) do
        for idx,shoptype in pairs(var) do
            if shoptype == curShopType then
                curIndex = toint(key);
                bFind = true;
                break;
            end
        end
        if(bFind)then
            break;
        end
    end

    curIndex = curIndex - 1;
    if(curIndex < 1)then
        curIndex = table.count(gShopSequence);
    end

    local shopType = gShopSequence[curIndex][1];
    if(gIsUnlockShop(shopType))then
        Panel.popBack(tag);
        gEnterShop(curIndex);
    else
        gPreShop(shopType,tag)    
    end
    Net.sendCrusadeInfoCallbackBreak=true
end
function gNextShop(curShopType,tag)
    if curShopType == SHOP_TYPE_FAMILY_4 then
        Scene.clearLazyFunc("familyshop4item")
    end
    local curIndex = 0;
    local bFind = false;
    for key,var in pairs(gShopSequence) do
        for idx,shoptype in pairs(var) do
            if shoptype == curShopType then
                curIndex = toint(key);
                bFind = true;
                break;
            end
        end
        if(bFind)then
            break;
        end
    end

    curIndex = curIndex + 1;
    if(curIndex > table.count(gShopSequence))then
        curIndex = 1;
    end

    local shopType = gShopSequence[curIndex][1];
    if(gIsUnlockShop(shopType))then
        Panel.popBack(tag);
        gEnterShop(curIndex);
    else
        gNextShop(shopType,tag)    
    end
    Net.sendCrusadeInfoCallbackBreak=true
end

function gEnterShop(shopIndex)
    -- print("shopIndex = "..shopIndex);
    -- print_lua_table(gShopSequence[shopIndex]);
    local shopType = gShopSequence[shopIndex][1];
    if shopIndex == 6 and (Module.isClose(SWITCH_FAMILY_SHOP4) or gFamilyInfo.iLevel < DB.getFamilyBuildUnlock(11)) then
        shopType = SHOP_TYPE_FAMILY
    end
    -- print("shopType = "..shopType);
    if(shopType ==  SHOP_TYPE_MINE)then
        Panel.popUp(PANLE_MINE_EXCHANGE,true)
        Panel.setMainMoneyType(OPEN_BOX_ENERGY)
    elseif(shopType == SHOP_TYPE_CRUSADE)then
        Panel.popUp(PANEL_CRUSADE_SHOP);
    elseif(shopType == SHOP_TYPE_DRAGON)then
        Panel.popUp(PANEL_SHOP_DRAGON_EXCHANGE);
    else
        Panel.popUp(PANEL_SHOP,shopType);
        
    end
end

function ShopPanel:ctor(type)

    self.touchRefresh = false
    loadFlaXml("ui_shop")
    if type  == nil then
        type = SHOP_TYPE_1;
    end
    self.refreshDiscount = 100;
    self.buyDiscount = 100;
    self.needInitData = false;
    self.isMainLayerMenuShow = false

    if (Data.limit_etime and Data.limit_etime>0) then
        local time = Data.limit_etime - gGetCurServerTime()
        if (time<=0) then
            Data.limit_etime = 0
            gDispatchEvt(EVENT_ID_OPEN_LIMIT_SHOP)
        end
    end
    -- print("type = "..type);
    -- self.curShopType = type;
    -- print("self.curShopType = "..self.curShopType);
    if type == SHOP_TYPE_FAMILY then
        self:init("ui/ui_shop2.map")
        self.needRefresh = true;
        self.scroll = self:getNode("scroll2");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        self.refreshDiscount = Data.getFamilyShopRefreshDiscount();
        self.buyDiscount = Data.getFamilyShopBugDiscount();
        -- Panel.setMainMoneyType(OPEN_BOX_FAMILY_DEVOTE);
        self:setLabelString("shop_title",gGetWords("familyWords.plist","shop"));
        self:showLayersWithNodeVar("layer_family");
        -- self:getNode("layer_family"):setVisible(true);
        -- self:getNode("layer_arena"):setVisible(false);
        -- self:getNode("layer_pet"):setVisible(false);
        -- self:getNode("layer_crusade"):setVisible(false);
        self:initNpc(type) 
        self.isMainLayerMenuShow = false;
        self:getNode("btn_type19"):setVisible(false)
        self:getNode("btn_type20"):setVisible(false)
        self:initFamilyShopReward()
    elseif type == SHOP_TYPE_FAMILY_4 then
        self:init("ui/ui_shop2.map")
        self.needRefresh = true;
        self.scroll = self:getNode("scroll2");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        self:setLabelString("shop_title",gGetWords("familyWords.plist","shop"));
        self:showLayersWithNodeVar("layer_family");
        self:getNode("layer_full"):setVisible(true)
        self:getNode("time_bg"):setVisible(false)
        self:getNode("layer_right"):setVisible(false)
        self:getNode("layer_left"):setVisible(false)
        -- self:initNpc(type) 
        self.isMainLayerMenuShow = false;
        self.needInitData = false;
        self:initFamilyShopReward()
    elseif type == SHOP_TYPE_ARENA then
        self:init("ui/ui_shop2.map")
        self.needRefresh = true;
        self.scroll = self:getNode("scroll2");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        -- Panel.setMainMoneyType(OPEN_BOX_REPU);
        self:showLayersWithNodeVar("layer_arena");
        -- self:getNode("layer_family"):setVisible(false);
        -- self:getNode("layer_arena"):setVisible(true);
        -- self:getNode("layer_pet"):setVisible(false);
        -- self:getNode("layer_crusade"):setVisible(false);
        self:getNode("time_bg2"):setVisible(false);
        self:initNpc(type) 
    elseif type == SHOP_TYPE_PET then
        self:init("ui/ui_shop2.map")
        self.needRefresh = false;
        self.scroll = self:getNode("scroll");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        -- Panel.setMainMoneyType(OPEN_BOX_FAMILY_DEVOTE);
        self:setLabelString("shop_title",gGetWords("petWords.plist","7"));
        self:showLayersWithNodeVar("layer_pet");
        -- self:getNode("layer_family"):setVisible(false);
        -- self:getNode("layer_arena"):setVisible(false);
        -- self:getNode("layer_pet"):setVisible(true);
        -- self:getNode("layer_crusade"):setVisible(false);
    elseif type == SHOP_TYPE_SERVERBATTLE then
        self:init("ui/ui_shop2.map")
        self.needRefresh = true;
        self.scroll = self:getNode("scroll");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        self:setLabelString("shop_title",gGetWords("serverBattleWords.plist","shop_title"));
        self:showLayersWithNodeVar("layer_arena");
        -- self:getNode("layer_family"):setVisible(false);
        -- self:getNode("layer_arena"):setVisible(true);
        -- self:getNode("layer_pet"):setVisible(false);
        -- self:getNode("layer_crusade"):setVisible(false);
        self:getNode("time_bg2"):setVisible(true);
        self:initNpc(type)
        self.needInitData = false;
    elseif type == SHOP_TYPE_TOWER1 then
        self:init("ui/ui_shop2.map")
        self.needRefresh = false;
        self.scroll = self:getNode("scroll");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        -- self:setLabelString("shop_title",gGetWords("serverBattleWords.plist","shop_title"));
        self:showLayersWithNodeVar("layer_tower");
        self.needInitData = false;
    elseif type == SHOP_TYPE_EMOTION then
        self:init("ui/ui_shop2.map")
        self.needRefresh = false;
        self.scroll = self:getNode("scroll");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        -- Panel.setMainMoneyType(OPEN_BOX_EMOTION_MONEY);
        -- self.saveMoneyType = OPEN_BOX_EMOTION_MONEY;
        self:showLayersWithNodeVar("layer_emotion");
        -- self.needInitData = false;
    elseif type == SHOP_TYPE_SNATCH then
        self:init("ui/ui_shop2.map")
        self.needRefresh = false;
        self.scroll = self:getNode("scroll");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self.saveMoneyType = Panel.getMainMoneyType();
        -- Panel.setMainMoneyType(OPEN_BOX_EMOTION_MONEY);
        -- self.saveMoneyType = OPEN_BOX_EMOTION_MONEY;
        self:showLayersWithNodeVar("layer_emotion");
        self:setLabelString("txt_shopname",gGetWords("labelWords.plist","snatch_shop_title"));    

    elseif type == SHOP_TYPE_CONSTELLATION then
        self:init("ui/ui_shop2.map")
        self.needRefresh = true
        self.scroll = self:getNode("scroll2")
        self.scroll.eachLineNum = 2
        self.scroll:setPaddingXY(18,0)
        self.saveMoneyType = Panel.getMainMoneyType()
        self:setLabelString("shop_title",gGetWords("constellationWords.plist","shop_title"))
        self:showLayersWithNodeVar("layer_arena")
        self:getNode("time_bg2"):setVisible(false)
        self:getNode("discount_panel"):setVisible(false)
        self:initNpc(type)
        self.needInitData = true
        if(Data.activityConShopLimitSaleoff.val2)then
            self.refreshDiscount=Data.activityConShopLimitSaleoff.val2
        end
    else
        self:init("ui/ui_shop.map")
        self.needRefresh = true;
        self.scroll = self:getNode("scroll");
        self.scroll.eachLineNum = 2;
        self.scroll:setPaddingXY(18,0);
        self:getNode("role"):setVisible(false) 
        if(Data.activityShopLimitSaleoff.val2)then
            self.refreshDiscount=Data.activityShopLimitSaleoff.val2
        end
    end

    if self.refreshDiscount==0 then
        self.refreshDiscount =100
    end
    if(type==nil)then
        self:getShopData(1)
    else
        self:getShopData(type)
    end

    if self.needRefresh then
        local function _updateShopTime()
            self:updateShopTime();
        end

        self:scheduleUpdate(_updateShopTime,1)
    else
        self:getNode("layer_full"):setVisible(true);
        self:getNode("layer_right"):setVisible(false);
        self:getNode("layer_left"):setVisible(false);
    end

    --特殊处理
    if(type == SHOP_TYPE_SERVERBATTLE)then
        self:getNode("layer_full"):setVisible(true);
        self:getNode("layer_right"):setVisible(false);
        self:getNode("layer_left"):setVisible(false);
    end

    self:getNode("btn_pre"):setVisible(gGetUnlockShopCount() > 1);
    self:getNode("btn_next"):setVisible(gGetUnlockShopCount() > 1);
    if type == SHOP_TYPE_SNATCH then
        self:getNode("btn_pre"):setVisible(false);
        self:getNode("btn_next"):setVisible(false);
    end
    self:hideCloseModule();
end

function ShopPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function ShopPanel:updateShopTime()
    if self.needRefresh == false then
        return;
    end
    
    if(self.curShopType)then
        if (self.curShopType == SHOP_TYPE_FAMILY_2) then
            if(self.familyShop2Data.nextRefreshTime>gGetCurServerTime())then
                self:setLabelString("txt_refresh_time2", gParserHourTime( self.familyShop2Data.nextRefreshTime-gGetCurServerTime()))
            else
                Net.sendFamilyGoodsInfo();
            end
        elseif (self.curShopType == SHOP_TYPE_SERVERBATTLE) then

            if(gShops[self.curShopType].time>gGetCurServerTime())then
                self:setLabelString("txt_refresh_time3", gParserHourTime( gShops[self.curShopType].time-gGetCurServerTime()))
            else
                -- print("refresh +++++ Net.sendWorldWarInfo");
                Net.sendWorldWarInfo();
                --防止重复调用
                gShops[self.curShopType].time = gGetCurServerTime() + 10;
            end
        elseif(Data.limit_stype and Data.limit_stype ==self.curShopType) and (Data.limit_etime and Data.limit_etime>=0) then
            local time = math.max(Data.limit_etime - gGetCurServerTime(),0)
            if (time==0 and Data.limit_etime>0) then
                Data.limit_etime = 0
                gDispatchEvt(EVENT_ID_OPEN_LIMIT_SHOP)
            end
            local bolOpen = false
            if (self.curShopType == SHOP_TYPE_2) then
                bolOpen = Unlock.system.shop2.isOpen
            elseif (self.curShopType == SHOP_TYPE_3) then
                bolOpen = Unlock.system.shop3.isOpen
            end
            if (not bolOpen) then
                self:setLabelString("txt_refresh_time", gParserHourTime(time))
            else
                time = math.max(gShops[self.curShopType].time - gGetCurServerTime(),0)
                self:setLabelString("txt_refresh_time", gParserHourTime(time))
            end
        elseif(gShops[self.curShopType]) and self.curShopType ~= SHOP_TYPE_FAMILY_4 then

            if(gShops[self.curShopType].time>gGetCurServerTime())then
                self:setLabelString("txt_refresh_time", gParserHourTime( gShops[self.curShopType].time-gGetCurServerTime()))

            else
                if(gShops[self.curShopType])then
                    gShops[self.curShopType]=nil
                    Net.sendInitShop(self.curShopType)
                end
            end
        end
    end
end

function ShopPanel:showLayersWithNodeVar(varname)
    self:getNode("layer_family"):setVisible(false);
    self:getNode("layer_arena"):setVisible(false);
    self:getNode("layer_pet"):setVisible(false);
    self:getNode("layer_crusade"):setVisible(false);    
    self:getNode("layer_tower"):setVisible(false);
    self:getNode("layer_emotion"):setVisible(false);

    self:getNode(varname):setVisible(true);    
end

function ShopPanel:initNpc(type)
    self:getNode("role"):setVisible(false)

    if(self.npcIcon)then
        self.npcIcon:removeFromParent()
        self.npcIcon=nil
    end
    local npcIcon = gCreateFla("ui_shopnpc"..type, 1)
    if type==SHOP_TYPE_CONSTELLATION then
        npcIcon = gCreateFla("ui_shopnpc9", 1)
    end
    self.npcIcon=npcIcon
    if( npcIcon)then
        self:getNode("role"):getParent():addChild(npcIcon,-1)
        npcIcon:setPositionX(self:getNode("role"):getPositionX())
        npcIcon:setPositionY(self:getNode("role"):getPositionY()-50)
    end
end

function ShopPanel:hideCloseModule()
    if (self.curShopType <= SHOP_TYPE_3 or self.curShopType == SHOP_TYPE_SOUL) then
        self:getNode("btn_type2"):setVisible(self:bolOpenShop(SHOP_TYPE_2,false,false));
        self:getNode("btn_type3"):setVisible(self:bolOpenShop(SHOP_TYPE_3,false,false));
        -- self:getNode("btn_type2"):setVisible(not Module.isClose(SWITCH_VIP));
        -- self:getNode("btn_type3"):setVisible(not Module.isClose(SWITCH_VIP));
        self:getNode("btn_type9"):setVisible(not Module.isClose(SWITCH_SHOP_SOUL) and Unlock.isUnlock(SYS_SHOP_SOUL,false));
        self:resetLayOut();
    end
end

function ShopPanel:onPopup()
    self:changeMainMoneyType();
end

function ShopPanel:changeMainMoneyType()

    if self.curShopType == SHOP_TYPE_FAMILY or self.curShopType == SHOP_TYPE_FAMILY_2 or self.curShopType == SHOP_TYPE_FAMILY_3 then
        Panel.setMainMoneyType(OPEN_BOX_FAMILY_DEVOTE);
    elseif self.curShopType == SHOP_TYPE_ARENA then
        Panel.setMainMoneyType(OPEN_BOX_REPU);
    elseif self.curShopType == SHOP_TYPE_PET then
        Panel.setMainMoneyType(OPEN_BOX_PETMONEY);
    elseif self.curShopType == SHOP_TYPE_SOUL then
        Panel.setMainMoneyType(OPEN_BOX_SOULMONEY);
    elseif self.curShopType == SHOP_TYPE_SERVERBATTLE then
        Panel.setMainMoneyType(OPEN_BOX_SERVERBATTLE);
    elseif self.curShopType == SHOP_TYPE_EMOTION then
        Panel.setMainMoneyType(OPEN_BOX_EMOTION_MONEY);
    elseif self.curShopType == SHOP_TYPE_SNATCH then
        Panel.setMainMoneyType(OPEN_BOX_SNATCH_MONEY);
    elseif self.curShopType == SHOP_TYPE_TOWER1 or 
            self.curShopType == SHOP_TYPE_TOWER2 or     
            self.curShopType == SHOP_TYPE_TOWER3 or     
            self.curShopType == SHOP_TYPE_TOWER4 then
        Panel.setMainMoneyType(OPEN_BOX_TOWERMONEY);
    elseif self.curShopType == SHOP_TYPE_FAMILY_4 or 
           self.curShopType == SHOP_TYPE_FAMILY_5 then
        Panel.setMainMoneyType(OPEN_BOX_FAMILY_MONEY);
    elseif self.curShopType == SHOP_TYPE_CONSTELLATION then
        Panel.setMainMoneyType(OPEN_BOX_CONSTELLATION_SOUL);
    else    
        Panel.setMainMoneyType(OPEN_BOX_ENERGY);
    end

end

function ShopPanel:onPopBackFromStack()
    if self.saveMoneyType then
        Panel.setMainMoneyType(self.saveMoneyType);
    end
end

function ShopPanel:refreshVipChange()
    if isBanshuReview() and self.mapName == "ui/ui_shop.map" then
        return
    end

    if self.curShopType == SHOP_TYPE_SOUL then
        if (self:getNode("btn_refresh2")) then
            local num = (Data.getMaxUseTimes(VIP_SOULSHOP_REFRESH)-gShops[self.curShopType].refreshTimes)
            if (num>0) then
                self:getNode("btn_refresh2"):setVisible(true)
                local strNum = "("..num..")"
                self:setLabelString("ref2_num",strNum)
                self:getNode("ref2_layout"):layout();
            else
                self:getNode("btn_refresh2"):setVisible(false)
                self:getNode("btn_refresh"):setVisible(true)
            end
        end
    end
end

function  ShopPanel:events()
    return {EVENT_ID_INIT_SHOP,
    EVENT_ID_SHOP_REFRESH,
    EVENT_ID_FAMILY_SHOP,
    EVENT_ID_FAMILY_SHOP2_BUY,
    EVENT_ID_FAMILY_SHOP3_BUY,
    EVENT_ID_TOWER_SHOP_REWARD,
    EVENT_ID_TOWER_SHOP_REWARD_BUY,
    EVENT_ID_FAMILY_SHOP4_ADD_PRICE,
    EVENT_ID_GET_ACTIVITY_VIP_CHANGE}
end


function ShopPanel:dealEvent(event,param)
    if(event==EVENT_ID_INIT_SHOP)then
        self:initShopData(param)
    elseif(event == EVENT_ID_SHOP_REFRESH) then
        for key,item in pairs(self.scroll:getAllItem()) do
            item:refresh(param);
        end

        local txt=gGetWords("labelWords.plist","npc_word_"..self.curType.."_2")
        if(string.len(txt)~=0)then
            self:setLabelString("txt_word",txt)
            self:resizeTalkBg()
        end
    elseif(event == EVENT_ID_FAMILY_SHOP) then
        if(param.type == 2)then
            self:initFamilyShop2(param.list,param.time);
        elseif(param.type == 3)then
            self:initFamilyShop3(param.list);
        elseif(param.type == 4)then
            self:initFamilyShop4(param.list)
        elseif(param.type == 5)then
            self:initFamilyShop5(param.list)
        end
    elseif(event == EVENT_ID_FAMILY_SHOP2_BUY) then
        self:evtRefreshShop2Item(param); 
    elseif(event == EVENT_ID_FAMILY_SHOP3_BUY) then
        self:evtRefreshShop3Item(param);
    elseif(event == EVENT_ID_TOWER_SHOP_REWARD)then
        self:initTowerReward(param);  
    elseif(event == EVENT_ID_TOWER_SHOP_REWARD_BUY)then
        self:evtRefreshTowerRewardItem(param);
    elseif(event == EVENT_ID_FAMILY_SHOP4_ADD_PRICE)then
        self:evtRefreshShop4Item(param);  
    elseif(event == EVENT_ID_GET_ACTIVITY_VIP_CHANGE)then
        self:refreshVipChange()             
    end
end

function ShopPanel:isRefreshUnuseDia()
    -- 不用元宝刷新，用刷新令
    if isBanshuReview() then
        if self.curShopType<=SHOP_TYPE_3 or self.curShopType==SHOP_TYPE_SOUL or self.curShopType==SHOP_TYPE_CONSTELLATION then
            return true;
        end
    end
    return false;
end

function ShopPanel:refreshPrice()
    -- txt_refresh_price
    if self.needRefresh == false then
        return;
    end
    local hasRefreshItem = false;
    print("self.curShopType is:",self.curShopType, " refreshTimes is:",gShops[self.curShopType].refreshTimes)
    local times = gShops[self.curShopType].refreshTimes+1;
    self.priceRefresh = 0;

    if (self:getNode("btn_refresh2")) then
        self:getNode("btn_refresh2"):setVisible(false)
    end
    if (self:getNode("refresh2_bg")) then
        self:getNode("refresh2_bg"):setVisible(false)
    end
    self:getNode("btn_refresh"):setVisible(true)

    if self.curShopType <= SHOP_TYPE_3 then
        Icon.changeDiaIcon(self:getNode("refresh_icon"));
        if (self.curShopType==SHOP_TYPE_1) then
            self.priceRefresh = Data.getBuyTimesPrice(times,"SHOP_NORMAL1_REFRESH_PRICE","SHOP_NORMAL1_REFRESH_NUM");
        else
            self.priceRefresh = Data.getBuyTimesPrice(times,"SHOP_COMMON_REFRESH_PRICE","SHOP_COMMON_REFRESH_NUM");
        end
    elseif self.curShopType == SHOP_TYPE_SOUL then

        -- Icon.changeSoulMoneyIcon(self:getNode("refresh_icon"));
        local refreshNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        if(refreshNum > 0)then
            self:changeTexture("refresh_icon","images/icon/item/34.png");
            self.priceRefresh = 1;
            hasRefreshItem = true;
            self:getNode("discount_panel"):setVisible(false);
            if (self:getNode("refresh2_bg")) then
                self:getNode("refresh2_bg"):setVisible(true)
                self:getNode("btn_refresh2"):setVisible(true)
                self:setLabelString("refresh2_num",refreshNum)
            end
            self:getNode("btn_refresh"):setVisible(false)
        else
            Icon.changeDiaIcon(self:getNode("refresh_icon"));
            self.priceRefresh = DB.getClientParam("SHOP_CARDSTAR_REFRESH_PRICE_NEW");
            -- self.priceRefresh = Data.getBuyTimesPrice(times,"SHOP_CARDSTAR_REFRESH_PRICE","SHOP_COMMON_REFRESH_NUM");
        end
        
        if (self:getNode("btn_refresh2")) then
            local num = (Data.getMaxUseTimes(VIP_SOULSHOP_REFRESH)-gShops[self.curShopType].refreshTimes)
            if (num>0) then
                self:getNode("btn_refresh2"):setVisible(true)
                local strNum = "("..num..")"
                self:setLabelString("ref2_num",strNum)
                self:getNode("ref2_layout"):layout();
            else
                self:getNode("btn_refresh2"):setVisible(false)
                self:getNode("btn_refresh"):setVisible(true)
            end
        end

        Data.setUsedTimes(VIP_SOULSHOP_REFRESH,gShops[self.curShopType].refreshTimes);
    elseif self.curShopType == SHOP_TYPE_ARENA then
        Icon.changeRepuIcon(self:getNode("refresh_icon"));
        self.priceRefresh = Data.getBuyTimesPrice(times,"SHOP_ARENA_REFRESH_PRICE","SHOP_ARENA_REFRESH_NUM");
    elseif self.curShopType == SHOP_TYPE_FAMILY then
        Icon.changeDevoteIcon(self:getNode("refresh_icon"));
        self.priceRefresh = Data.getBuyTimesPrice(times,"SHOP_FAMILY_REFRESH_PRICE","SHOP_FAMILY_REFRESH_NUM");
        -- ShopPanelData.refreshPrice = self.priceRefresh;
    elseif self.curShopType == SHOP_TYPE_SERVERBATTLE then
        Icon.changeSeqItemIcon(self:getNode("refresh_icon"),OPEN_BOX_SERVERBATTLE)
        self.priceRefresh = Data.getBuyTimesPrice(times,"WORLD_WAR_SHOP_REFRESH_PRICE","WORLD_WAR_SHOP_REFRESH_NUM");
    elseif self.curShopType == SHOP_TYPE_CONSTELLATION then
        local refreshNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        if(refreshNum > 0)then
            self:changeTexture("refresh_icon","images/icon/item/34.png")
            self.priceRefresh = 1
            hasRefreshItem = true
            if (self:getNode("refresh2_bg")) then
                self:getNode("refresh2_bg"):setVisible(true)
                self:setLabelString("refresh2_num",refreshNum)
            end
        else
            Icon.changeDiaIcon(self:getNode("refresh_icon"));
            self.priceRefresh = DB.getClientParam("CON_SHOP_REFRESH_FIX_PRICE",true)
            -- self.priceRefresh = Data.getBuyTimesPrice(times,"SHOP_CARDSTAR_REFRESH_PRICE","SHOP_COMMON_REFRESH_NUM");
        end
        -- Icon.changeSeqItemIcon(self:getNode("refresh_icon"),OPEN_BOX_CONSTELLATION_SOUL)
        -- self.priceRefresh = Data.getBuyTimesPrice(times,"CON_SHOP_REFRESH_PRICE","CON_SHOP_REFRESH_NUM"); 
    end

    if(hasRefreshItem == false)then
        -- print("before priceRefresh = "..self.priceRefresh);
        -- print("priceRefresh times  = "..times);
        -- print("priceRefresh refreshDiscount  = "..self.refreshDiscount);
        self.priceRefresh = math.ceil(self.priceRefresh * self.refreshDiscount/100);
        -- print("after priceRefresh = "..self.priceRefresh);
        
        if(self.refreshDiscount==100)then
            self:getNode("discount_panel"):setVisible(false)
        else 
            self:replaceLabelString("txt_discount",gGetDiscount(self.refreshDiscount/10));
            self:getNode("discount_panel"):setVisible(true)
        end
    end

    if self:isRefreshUnuseDia() then
        local iItemNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        
        if self.curShopType==SHOP_TYPE_1 and self.priceRefresh==0 then
            --
        elseif self.curShopType==SHOP_TYPE_SOUL and iItemNum<1 then
            self.priceRefresh = 200*self.refreshDiscount/100;
        elseif self.curShopType==SHOP_TYPE_CONSTELLATION and iItemNum<1 then
            self.priceRefresh = 20*self.refreshDiscount/100;
        else
            self.priceRefresh=1;
        end
    end

    self:setLabelString("txt_refresh_price",self.priceRefresh);

    if (self.curShopType==SHOP_TYPE_1 and self.priceRefresh == 0) then
        if (self:getNode("price_bg")) then self:getNode("price_bg"):setVisible(false) end
        if (self:getNode("lab_free_refresh")) then
            self:getNode("lab_free_refresh"):setVisible(true)
            --免费刷新次数
            local num = string.split(DB.getClientParam("SHOP_NORMAL1_REFRESH_NUM"),";")
            Data.toint(num)
            self:replaceRtfString("lab_free_refresh",(num[1]-gShops[self.curShopType].refreshTimes))
        end
    else
        if (self:getNode("price_bg")) then self:getNode("price_bg"):setVisible(true) end
        if (self:getNode("lab_free_refresh")) then
            self:getNode("lab_free_refresh"):setVisible(false)
        end

        if self:isRefreshUnuseDia() then
            --[[if(self:getNode("price_bg")) then self:getNode("price_bg"):setVisible(false) end
            if(self:getNode("price_bg1")) then self:getNode("price_bg1"):setVisible(false) end
            if(self:getNode("discount_panel")) then self:getNode("discount_panel"):setVisible(false) end
            if(self:getNode("btn_refresh2")) then self:getNode("btn_refresh2"):setVisible(false) end
            if(self:getNode("btn_refresh")) then self:getNode("btn_refresh"):setVisible(false) end
            if(self:getNode("btn_refresh_bg")) then self:getNode("btn_refresh_bg"):setVisible(false) end]]
            local iItemNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
            if self.curShopType==SHOP_TYPE_SOUL and iItemNum<1 then
                Icon.changeSeqItemIcon(self:getNode("refresh_icon"),OPEN_BOX_SOULMONEY);
            elseif self.curShopType==SHOP_TYPE_CONSTELLATION and iItemNum<1 then
                Icon.changeSeqItemIcon(self:getNode("refresh_icon"),OPEN_BOX_CONSTELLATION_SOUL);
            else
                Icon.changeItemIcon(self:getNode("refresh_icon"),ITEM_REFRESH_SOULSHOP);
            end
            
        end
    end
    
    if (Data.limit_etime and Data.limit_stype and Data.limit_etime>0 and Data.limit_stype == self.curShopType) then
        local txt=gGetWords("labelWords.plist","lab_left_time")
        self:setLabelString("txt_next_time",txt);
    else
        local txt=gGetWords("labelWords.plist","lab_next_refresh_time")
        self:setLabelString("txt_next_time",txt);
    end
end

function ShopPanel:enoughRefresh()
    -- 版署单独处理
    if self:isRefreshUnuseDia() then
        local refreshNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        if refreshNum>0 then
            return true;
        end

        local itemName = ""
        if self.curShopType==SHOP_TYPE_SOUL then
            refreshNum = Data.getItemNum(OPEN_BOX_SOULMONEY);
            itemName = DB.getItemName(OPEN_BOX_SOULMONEY);
        elseif self.curShopType==SHOP_TYPE_CONSTELLATION then
            refreshNum = Data.getItemNum(OPEN_BOX_CONSTELLATION_SOUL);
            itemName = DB.getItemName(OPEN_BOX_CONSTELLATION_SOUL);
        else
            itemName = DB.getItemName(ITEM_REFRESH_SOULSHOP);
        end

        if refreshNum>=self.priceRefresh then
            return true;
        end

        gShowNotice(itemName.."不足");

        return false;
    end

    -- 原先的流程
    if self.curShopType <= SHOP_TYPE_3 then
        return NetErr.BuyShopItem(OPEN_BOX_DIAMOND,self.priceRefresh);
    elseif self.curShopType == SHOP_TYPE_SOUL then

        local refreshNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        Data.vip.soulshoprefresh.setUseRefreshItem(refreshNum > 0);
        local canBuy = Data.canBuyTimes(VIP_SOULSHOP_REFRESH,true,nil,self.refreshDiscount);
        if(canBuy == false)then
            return false;
        end
        
        if(refreshNum > 0)then
            return true;
        end
        return NetErr.BuyShopItem(OPEN_BOX_DIAMOND,self.priceRefresh);
    elseif self.curShopType == SHOP_TYPE_ARENA then
        return NetErr.BuyShopItem(OPEN_BOX_REPU,self.priceRefresh);
    elseif self.curShopType == SHOP_TYPE_FAMILY then
        return NetErr.BuyShopItem(OPEN_BOX_FAMILY_DEVOTE,self.priceRefresh);
    elseif self.curShopType == SHOP_TYPE_SERVERBATTLE then
        return NetErr.BuyShopItem(OPEN_BOX_SERVERBATTLE,self.priceRefresh);
    elseif self.curShopType == SHOP_TYPE_CONSTELLATION then
        local refreshNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        if(refreshNum > 0)then
            if refreshNum >= self.priceRefresh then
                return true
            end
        end
        return NetErr.BuyShopItem(OPEN_BOX_DIAMOND,self.priceRefresh);
    end


    return true;
end

function ShopPanel:resizeTalkBg()

    local size=self:getNode("txt_word"):getContentSize()
    size.height=self:getNode("talk_bg"):getContentSize().height
    size.width=size.width+30
    self:getNode("talk_bg"):setContentSize(size)
    self:getNode("talk_bg"):setVisible(true);
end

function ShopPanel:initShopData(param)

    -- --排序
    -- --武将碎片、道具、材料、材料碎片 进行排序。
    -- for key,item in pairs(param.items) do
    --     item.itemType = DB.getItemType(item.itemid);
    --     item.sort = 10;
    --     if item.itemType == ITEMTYPE_CARD_SOUL then
    --         item.sort = 0;
    --     elseif item.itemType == ITEMTYPE_ITEM then
    --         item.sort = 1;
    --     elseif item.itemType == ITEMTYPE_EQU then
    --         item.sort = 2;
    --     elseif item.itemType == ITEMTYPE_EQU_SHARED then
    --         item.sort = 3;
    --     end
    -- end

    -- local sortfunc = function(item1,item2)
    --     if item1.sort < item2.sort then
    --         return true;
    --     end
    --     return false;
    -- end

    -- table.sort(param.items,sortfunc);

    -- print_lua_table(param);
    self.needInitData = false;

    local discount=nil
    if(param.type==1 or
        param.type==2 or
        param.type==3 or
        param.type==SHOP_TYPE_SOUL)then

        if(Data.activityShopLimitSaleoff.time and gGetCurServerTime()>Data.activityShopLimitSaleoff.time)then
            Data.activityShopLimitSaleoff={}
        end

        if(   Data.activityShopLimitSaleoff.val)then
            discount=Data.activityShopLimitSaleoff.val
        end
        self:initNpc(param.type)
        self:changeMainMoneyType();
    elseif param.type == SHOP_TYPE_CONSTELLATION then
        if(Data.activityConShopLimitSaleoff.time and gGetCurServerTime()>Data.activityConShopLimitSaleoff.time)then
            Data.activityConShopLimitSaleoff={}
        end
        if(Data.activityConShopLimitSaleoff.val)then
            discount=Data.activityConShopLimitSaleoff.val
        end
    else
        discount = self.buyDiscount;
    end
    self.discount=discount

    if(self.curType)then
        local txt=gGetWords("labelWords.plist","npc_word_"..self.curType.."_1")
        if(string.len(txt)~=0)then
            self:setLabelString("txt_word",txt)
            self:resizeTalkBg()
        end

        if(self.curType == SHOP_TYPE_FAMILY) then
            self:initFamilyShop1();
        elseif(self.curType == SHOP_TYPE_TOWER1 or self.curType == SHOP_TYPE_TOWER2 or self.curType == SHOP_TYPE_TOWER3) then
            self:initTowerShop();   
        end
    end


    if param.type then
        if(param.type == SHOP_TYPE_TOWER1)then
            self:selectBtn("tower_btn_type1");
        elseif(param.type == SHOP_TYPE_TOWER2)then
            self:selectBtn("tower_btn_type2");
        elseif(param.type == SHOP_TYPE_TOWER3)then
            self:selectBtn("tower_btn_type3");
        elseif(param.type == SHOP_TYPE_TOWER4)then
            self:selectBtn("tower_btn_type4");
        else
            self:selectBtn("btn_type"..param.type)
        end

        if self.curShopType ~= param.type then
            print("change shop type = "..param.type);
            self.curType = param.type;
            self.curShopType = param.type;
        end
        
    end
    if param.time then
        -- self:setLabelString("txt_refresh_time",param.time)
        self:updateShopTime();
    end

    if self.curShopType == SHOP_TYPE_SOUL then
        Data.sortUserCard()
    end
    self.scroll:clear()
    -- self.curShopType=param.type
    local showItems=param.items
    for key, var in pairs(showItems) do
        local item=ShopItem.new(discount,self.curType,self.curShopType)

        if(var.limitNum and var.limitNum > 1)then
            item.hasLimitBuy = true;
        end
        
        item:setData(var)

        --不刷新采用一种购买方式
        if(self.needRefresh==false and self.curShopType ~= SHOP_TYPE_SERVERBATTLE and self.curShopType ~= SHOP_TYPE_EMOTION )then
            item.selectItemCallback=function (data,idx)
                self:onSelectItem(data,idx)
            end
        end

        self.scroll:addItem(item)
    end

    self.scroll:layout()

    --self:showTipRefresh()

    self:refreshPrice();
end

function ShopPanel:showTipRefresh()
    local tipEmergency = false
    if (self.curShopType == SHOP_TYPE_CONSTELLATION) then
        for key,item in pairs(self.scroll:getAllItem()) do
            local itemNeedType = gConstellation.getItemNeedType(item.curData.itemid)
            if  itemNeedType == 2 then
                tipEmergency = true
                break
            end
        end
    end

     if self.touchRefresh == true and tipEmergency then
        local function onOk()
            Net.sendRefreshShop(self.curShopType)
        end
        gConfirmCancel(gGetWords("shopWords.plist","need_shop_item"),onOk)
        return true
    end
    return false
end


-- function ShopPanel:onSelectItem(data,idx)
--     self.itemid=data.itemid
--     self.selectedIdx=idx

-- end


function ShopPanel:getShopData(type)

    if self.curShopType == type then
        return;
    end
    self.curType = type;
    self.curShopType = type;
    print("self.curType="..self.curType)
    -- print("self.curShopType="..self.curShopType)
    
    if(gShops[type]==nil or self.needInitData == true)then
        Net.sendInitShop(type)
    elseif(type == SHOP_TYPE_FAMILY_4)then
        Net.sendFamilyHotSellList()
        self:selectBtn("btn_type"..type)
    elseif(type == SHOP_TYPE_TOWER1)then
        Net.sendTowerShopInfo();
    elseif(type == SHOP_TYPE_EMOTION) then
        Net.sendShopEmotionInfo()
    elseif(type == SHOP_TYPE_SNATCH) then
        Net.sendActivitySnaShopInfo()
    else
        self:initShopData(gShops[type])
    end
end

function ShopPanel:resetBtnTexture()
    local btns={
        "btn_type1",
        "btn_type2",
        "btn_type3",
        "btn_type5",
        "btn_type7",
        "btn_type8",
        "btn_type9",
        "tower_btn_type1",
        "tower_btn_type2",
        "tower_btn_type3",
        "tower_btn_type4",
        "btn_type19",
        "btn_type20",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function ShopPanel:selectBtn(name)

    -- print("name = "..name);
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end


function ShopPanel:getLeftTime(type,price)
    if(type==OPEN_BOX_PETMONEY)then
        return math.floor(Data.getCurPetMoney()/price)
    elseif(type == OPEN_BOX_DIAMOND)then
        return math.floor(Data.getCurDia()/price)    
    elseif(type == OPEN_BOX_GOLD)then
        return math.floor(Data.getCurGold()/price)   
    elseif(type == OPEN_BOX_TOWERMONEY)then
        return math.floor(gUserInfo.towermoney/price)    
    end
    return 0
end

function ShopPanel:initFamilyShop1()
    self.curShopType = SHOP_TYPE_FAMILY;
    self:getNode("layer_full"):setVisible(false);
    self:getNode("time_bg"):setVisible(false);
    self:getNode("layer_right"):setVisible(true);
    self:getNode("layer_left"):setVisible(true);
    self:getNode("btn_hotsell_refresh"):setVisible(false);
    self:getNode("layer_null"):setVisible(false);
    self.scroll = self:getNode("scroll2");
    self.scroll.eachLineNum = 2;
    self.scroll:setPaddingXY(18,0);
    self:changeMainMoneyType()
    self:initNpc(SHOP_TYPE_FAMILY)
end

function ShopPanel:initFamilyShop2(list,nextRefreshTime)
    self.curShopType = SHOP_TYPE_FAMILY_2;
    self:getNode("layer_full"):setVisible(true);
    self:getNode("time_bg"):setVisible(true); 
    self:getNode("layer_right"):setVisible(false);
    self:getNode("layer_left"):setVisible(false);
    self:getNode("btn_hotsell_refresh"):setVisible(false);
    self:getNode("layer_null"):setVisible(false);
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL);
    self:getNode("scroll").eachLineNum = 2;
    self:getNode("scroll"):setPaddingXY(0,0);
    self:getNode("scroll"):clear();
    self.familyShop2Data = {};
    self.familyShop2Data.list = {};
    self.familyShop2Data.nextRefreshTime = nextRefreshTime;
    for key,var in pairs(list) do
        local data = Data.getFamilyShop2Data(var.id);
        data.fnum = var.fnum;
        data.unum = var.unum;
        local item = FamilyShop2Item.new();
        item:setData(data);
        self:getNode("scroll"):addItem(item);
        table.insert(self.familyShop2Data.list,data);
    end
    self:getNode("scroll"):layout();
    self:changeMainMoneyType()
end

function ShopPanel:evtRefreshShop2Item(data)
    for key,var in pairs(self.familyShop2Data.list) do
        if data.id == var.id then
            var.fnum = data.fnum;
            var.unum = data.unum;
            local item = self:getNode("scroll"):getItem(key-1);
            item:setData(var);
            break;
        end
    end
end

function ShopPanel:initFamilyShop3(list)
    self.curShopType = SHOP_TYPE_FAMILY_3;
    self:getNode("layer_full"):setVisible(true);
    self:getNode("time_bg"):setVisible(false); 
    self:getNode("layer_right"):setVisible(false);
    self:getNode("layer_left"):setVisible(false);
    self:getNode("btn_hotsell_refresh"):setVisible(false);
    self:getNode("layer_null"):setVisible(false);
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL);
    self:getNode("scroll").eachLineNum = 1;
    self:getNode("scroll"):setPaddingXY(0,0);
    self:getNode("scroll"):clear();
    self.familyShop3Data = {};
    self.familyShop3Data.list = {};
    -- print_lua_table(list);
    for key,var in pairs(familylvreward_db) do
        var.num = 0;
        for k,v in pairs(list) do
            if v.lv == var.id then
                var.num = v.num;
            end
        end
        var.items = Data.getFamilyShop3Items(var.id);
        local item = FamilyShop3Item.new();
        item:setData(var);
        self:getNode("scroll"):addItem(item);
        table.insert(self.familyShop3Data.list,var);
    end
    self:getNode("scroll"):layout();
    self:changeMainMoneyType()
end

function ShopPanel:evtRefreshShop3Item(data)
    for key,var in pairs(self.familyShop3Data.list) do
        if data.lv == var.id then
            var.num = var.num + 1;
            local item = self:getNode("scroll"):getItem(key-1);
            item:setData(var);
            break;
        end
    end
    self:checkFamilyShop3RedPos()
end

function ShopPanel:initTowerShop()
    self.scroll:setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
    self.scroll.eachLineNum = 2;
    self.scroll:setPaddingXY(18,0);
end

function ShopPanel:initTowerReward(list)
    self.curShopType = SHOP_TYPE_TOWER4;
    -- self:getNode("layer_full"):setVisible(true);
    -- self:getNode("time_bg"):setVisible(false); 
    -- self:getNode("layer_right"):setVisible(false);
    -- self:getNode("layer_left"):setVisible(false);
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL);
    self:getNode("scroll").eachLineNum = 1;
    self:getNode("scroll"):clear();
    self.scroll:setPaddingXY(0,0);
    self.towerRewardData = {};
    self.towerRewardData.list = {};
    -- print_lua_table(list);
    for key,var in pairs(townreward_db) do
        var.num = 0;
        for k,v in pairs(list) do
            if v.star == toint(var.id) then
                var.num = v.buyedNum;
                break;
            end
        end
        var.items = cjson.decode(var.reward);
        local item = TowerShopRewardItem.new();
        item:setData(var);
        self:getNode("scroll"):addItem(item);
        table.insert(self.towerRewardData.list,var);
    end
    self:getNode("scroll"):layout();    
end

function ShopPanel:evtRefreshTowerRewardItem(data)
    for key,var in pairs(self.towerRewardData.list) do
        if toint(data.id) == toint(var.id) then
            var.num = var.num + 1;
            local item = self:getNode("scroll"):getItem(key-1);
            item:refreshData(var);
            break;
        end
    end    
end

function ShopPanel:onSelectItem(data,idx)
    local temp={}
    temp.itemid=data.itemid
    temp.id=data.id
    temp.costType=data.costType
    if(data.limitNum and data.limitNum > 0)then
        temp.lefttimes = data.limitNum - data.buyNum;
        temp.hasLimitBuy = true;
        temp.limitNum = data.limitNum;
        temp.buyNum = data.buyNum;
    else
        temp.lefttimes= self:getLeftTime(data.costType,data.price)
    end
    if(temp.lefttimes < 0)then
        temp.lefttimes = 0;
    end
    temp.price= data.price
    temp.rewardNum=data.num
    if temp.costType == OPEN_BOX_SNATCH_MONEY  then
       temp.rewardNum=data.itemnum
    end
    temp.buyCallback=function(num)
        if(NetErr.BuyShopItem(data.costType,data.price*num)) then
            ShopPanelData.buyPrice = data.price*num;
            Net.sendBuyShopItem(data.type,{data.pos},num)
            local td_param = {}
            td_param['price'] = ShopPanelData.buyPrice
            td_param['itemid'] = data.itemid
            td_param['item_name'] = DB.getItemName(data.itemid)
            td_param['type'] = data.type
            gLogEvent("shop.buy",td_param)
        end
    end
    if(NetErr.BuyShopItem(data.costType,data.price)) then
        Panel.popUp(PANEL_SHOP_BUY_ITEM,temp)
    end
end

function ShopPanel:shopOverShow()
    --活动结束
    local sWord = gGetWords("shopWords.plist","6");
    gShowNotice(sWord);
end

function ShopPanel:dealLimitShop()
    if (self.curShopType == 2) then
        if (Unlock.isUnlock(SYS_SHOP2,false)) then
            return false
        end
    elseif (self.curShopType == 3) then
        if (Unlock.isUnlock(SYS_SHOP3,false)) then
            return false
        end
    end
    if (Data.limit_etime and Data.limit_etime==0 and (Data.limit_stype==self.curShopType)) then
        self:shopOverShow()
        return true
    end
    return false
end

function ShopPanel:bolOpenShop(type,show,isbtn)
    if Module.isClose(SWITCH_VIP) then
        return false
    end
    if (type == SHOP_TYPE_2) then
        if (Data.limit_etime and Data.limit_stype and Data.limit_etime>0 and Data.limit_stype==type) then
            return true
        end
        if (isbtn) then
            if (Unlock.isUnlock(SYS_SHOP2,show)) then
                return true
            end
            -- if (Data.limit_etime and Data.limit_etime ==0 and Data.limit_stype==type) then
            --     self:shopOverShow()
            --     return true
            -- end
        else
            local needVip = Data.getCanBuyTimesVip(VIP_SHOP2);
            if Data.getCurVip() >= needVip then return true end
        end
    elseif (type == SHOP_TYPE_3) then
        if (Data.limit_etime and Data.limit_stype and Data.limit_etime>0 and Data.limit_stype==type) then
            return true
        end
        if (isbtn) then
            if (Unlock.isUnlock(SYS_SHOP3,show)) then
                return true
            end
            -- if (Data.limit_etime and Data.limit_etime ==0 and Data.limit_stype==type) then
            --     self:shopOverShow()
            --     return true
            -- end
        else
            local needVip = Data.getCanBuyTimesVip(VIP_SHOP3);
            if Data.getCurVip() >= needVip then return true end
        end
    end
    return false
end

function ShopPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Scene.clearLazyFunc("familyshop4item")
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_type1"then
        self:getShopData(SHOP_TYPE_1)
    elseif  target.touchName=="btn_type2"then
        if self:bolOpenShop(SHOP_TYPE_2,true,true) then
            self:getShopData(SHOP_TYPE_2)
        end
    elseif  target.touchName=="btn_type3"then
        if self:bolOpenShop(SHOP_TYPE_3,true,true) then
            self:getShopData(SHOP_TYPE_3)
        end
    elseif target.touchName == "btn_type9"then
        if Unlock.isUnlock(SYS_SHOP_SOUL,true) then
            self:getShopData(SHOP_TYPE_SOUL)
        end
    elseif target.touchName == "tower_btn_type1"then
        if Unlock.isUnlock(SYS_TOWER,false) then
            self:getShopData(SHOP_TYPE_TOWER1)
            -- Net.sendTowerShopInfo();
        end 
    elseif target.touchName == "tower_btn_type2"then
        if Unlock.isUnlock(SYS_TOWER,false) then
            self:getShopData(SHOP_TYPE_TOWER2)
        end 
    elseif target.touchName == "tower_btn_type3"then
        if Unlock.isUnlock(SYS_TOWER,false) then
            self:getShopData(SHOP_TYPE_TOWER3)
        end 
    elseif target.touchName == "tower_btn_type4"then
        if Unlock.isUnlock(SYS_TOWER,false) then
            Net.sendTowerRewardInfo();
            self:selectBtn("tower_btn_type4");
        end    
    elseif  target.touchName=="btn_refresh" or target.touchName=="btn_refresh2"then
        if (self:dealLimitShop()) then return end
        -- local refreshNum = Data.getItemNum(ITEM_REFRESH_SOULSHOP);
        -- if (refreshNum>0 and self.curShopType==SHOP_TYPE_SOUL) then
        --     Net.sendRefreshShop(self.curShopType)
        --     return
        -- end
        if self:enoughRefresh()then
            self.touchRefresh = true
            if self:showTipRefresh() then
                return
            end
            
            local canBuy = true
            if (self.curShopType==SHOP_TYPE_SOUL) then

                local vip = Data.getCanBuyTimesVip(VIP_SOULSHOP_REFRESH);
                if Data.judgeTimes(VIP_SOULSHOP_REFRESH)==false and  Data.getCurVip()>=vip then
                    Panel.popUpVisible(PANEL_VIP_NOTICE,true);
                    return
                end
            end
            if canBuy then
                Net.sendRefreshShop(self.curShopType)
            end

            
            --self.priceRefresh
            if (TDGAItem) then
                if self.curShopType <= SHOP_TYPE_3 then
                    gLogPurchase("refresh_shop_"..tostring(self.curShopType),1,self.priceRefresh)
                end
            end
        end
    elseif target.touchName == "btn_type5" then
        Scene.clearLazyFunc("familyshop4item")
        self.refreshDiscount = Data.getFamilyShopRefreshDiscount();
        self.buyDiscount = Data.getFamilyShopBugDiscount();
        self:getShopData(SHOP_TYPE_FAMILY);
    elseif target.touchName == "btn_type7" then
        -- self:getShopData(SHOP_TYPE_FAMILY_2);
        Scene.clearLazyFunc("familyshop4item")
        Net.sendFamilyGoodsInfo();
        self:selectBtn("btn_type7");
    elseif target.touchName == "btn_type8" then
        -- self:getShopData(SHOP_TYPE_FAMILY_3);
        Scene.clearLazyFunc("familyshop4item")    
        Net.sendFamilyLvReward();
        self:selectBtn("btn_type8");    
    elseif target.touchName == "btn_buy_all" then
        if (self:dealLimitShop()) then return end
        Panel.popUpVisible(PANEL_SHOP_BUYALL,self.curShopType,self.discount);
    elseif target.touchName == "btn_pre" then
        self.touchRefresh = false
        gPreShop(self.curShopType,self:getTag());
    elseif target.touchName == "btn_next" then
        self.touchRefresh = false
        gNextShop(self.curShopType,self:getTag());
    elseif target.touchName == "btn_type19" then
        Scene.clearLazyFunc("familyshop4item")
        Net.sendFamilyHotSellList();
        self:selectBtn("btn_type19");
    elseif target.touchName == "btn_type20" then
        Scene.clearLazyFunc("familyshop4item")
        Net.sendFamilyTrlist()
        self:selectBtn("btn_type20");
    elseif target.touchName == "btn_hotsell_refresh" then
        Scene.clearLazyFunc("familyshop4item")
        Net.sendFamilyHotSellList(); 
    end
end

function ShopPanel:initFamilyShop4(list)
    self.curShopType = SHOP_TYPE_FAMILY_4
    self:getNode("layer_full"):setVisible(true)
    self:getNode("time_bg"):setVisible(false)
    self:getNode("layer_right"):setVisible(false)
    self:getNode("layer_left"):setVisible(false)
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll"):setPaddingXY(0,0)
    self:getNode("scroll").eachLineNum = 1
    self:getNode("scroll"):clear()
    self:getNode("btn_hotsell_refresh"):setVisible(true)
    self.familyShop4DataList = {}
    self:changeMainMoneyType()
    if #list == 0 then
        self:getNode("layer_null"):setVisible(true);
    else
        self:getNode("layer_null"):setVisible(false);
    end
    table.sort(list, function(lItem, rItem)
        if lItem.uname == Data.getCurName() and rItem.uname == Data.getCurName() then
            if lItem.endtime < rItem.endtime then
                return true
            end
        end

        if lItem.uname == Data.getCurName() and rItem.uname ~= Data.getCurName() then
            return true
        end

        if lItem.uname ~= Data.getCurName() and rItem.uname == Data.getCurName() then
            return false
        end

        if lItem.uname ~= "" and rItem.uname ~= "" then
            if lItem.endtime < rItem.endtime then
                return true
            end
        end

        if lItem.uname ~= "" and rItem.uname == ""then
            return true
        end

        if lItem.uname == "" and rItem.uname ~= ""then
            return false
        end

        if lItem.endtime < rItem.endtime then
            return true
        end

        return false
    end)

    local drawNum=4
    for key, hotSellItem in pairs(list) do
        local item=FamilyShop4Item.new(key)
        if drawNum > 0 then
            drawNum = drawNum-1
            item:setData(hotSellItem)
        else
            item:setLazyData(hotSellItem)
        end
        self:getNode("scroll"):addItem(item)
        self.familyShop4DataList[hotSellItem.dbid] = item
    end
    self:getNode("scroll"):layout();
end

function ShopPanel:initFamilyShop5(list)
    self.curShopType = SHOP_TYPE_FAMILY_5
    self:getNode("layer_full"):setVisible(true)
    self:getNode("time_bg"):setVisible(false)
    self:getNode("layer_right"):setVisible(false)
    self:getNode("layer_left"):setVisible(false)
    self:getNode("btn_hotsell_refresh"):setVisible(false)
    self.scroll = self:getNode("scroll")
    self.scroll:clear()
    self.scroll:setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.scroll.eachLineNum = 2
    self.scroll:setPaddingXY(40,0)
    self:changeMainMoneyType()
    if #list == 0 then
        self:getNode("layer_null"):setVisible(true);
    else
        self:getNode("layer_null"):setVisible(false);
    end

    local showItems=list
    local index = 0
    for key, var in pairs(showItems) do
        local item=ShopItem.new(100,self.curType,self.curShopType)
        item.hasLimitBuy = false
        item:setData(var)
        --TODO
        -- if(self.needRefresh==false and self.curShopType ~= SHOP_TYPE_SERVERBATTLE and self.curShopType ~= SHOP_TYPE_EMOTION)then
        --     item.selectItemCallback=function (data,idx)
        --         self:onSelectItem(data,idx)
        --     end
        -- end

        self.scroll:addItem(item)
        index = index + 1
    end

    if math.mod(index,2) ~= 0 then
        local node = cc.Node:create()
        self.scroll:addItem(node)
    end

    self.scroll:layout()
end

function ShopPanel:evtRefreshShop4Item(param)
    local hotSellItem = self.familyShop4DataList[param.dbid]
    if hotSellItem ~= nil then
        hotSellItem:setData(param,hotSellItem.idx)
    end
end

function ShopPanel:initFamilyShopReward()
    if gFamilyInfo.iType < 10 then
        RedPoint.refresh(self:getNode("btn_type8"),Data.redpos.bolFamilyShopReward,RedPoint.getFamilyBuildAnchor(cc.p(0.85, 0.85)))
    end
end

function ShopPanel:checkFamilyShop3RedPos()
    local redPos = false
    if gFamilyInfo.iType < 10 then
        for key,var in pairs(self.familyShop3Data.list) do
            if (gFamilyInfo.iLevel >= var.id) and 
                (var.num < var.count) and
                (Data.getCurFamilyExp() >= var.price) then
                redPos = true
                break
            end
        end
    end
    Data.redpos.bolFamilyShopReward = redPos
    RedPoint.refresh(self:getNode("btn_type8"),Data.redpos.bolFamilyShopReward,RedPoint.getFamilyBuildAnchor(cc.p(0.85, 0.85)))
end

return ShopPanel