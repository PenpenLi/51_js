local MainMoneyLayer=class("MainMoneyLayer",UILayer)

local ACTION_TAG_HIDE=1
function MainMoneyLayer:ctor()
    self:init("ui/ui_main_top.map")


    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self:dealEvent(EVENT_ID_USER_DATA_UPDATE)

    self.hideBtns={"btn_hero" ,"btn_weapon","btn_task","btn_constellation" ,"btn_pet","btn_xunxian"}
    self.hideBtnsPos={}
    for key, var in pairs(self.hideBtns) do
        self.hideBtnsPos[var]={x=self:getNode(var):getPositionX(),y=self:getNode(var):getPositionY()}
    end

    self.layerGoldPos = cc.p(self:getNode("panel_money"):getPosition());

    self:setMoneyType(OPEN_BOX_ENERGY);
    self.isUpBtn = false;
    self:upBtns(0)
    self:getNode("panel_red_pack_name"):setVisible(false)

end

function MainMoneyLayer:setMoneyType(type,param)
    if(type==nil)then
        return
    end
    self:resetGoldLayerInfo();
    self.moneyType = type;
    self.moneyParam = param;
    self:refreshLayout();
    self:refreshBtnEnergy();
end

function MainMoneyLayer:refreshLayout()
    if self.moneyType ~= ITEM_SPIRIT_BUY or Module.isClose(SWITCH_DOUBLE_ATTR_SPIRIT) then
        self:getNode("layer_spirit_buy_item"):setVisible(false)
    else
        self:getNode("layer_spirit_buy_item"):setVisible(true)
    end
    
    self:getNode("layout_money"):layout()
end

function MainMoneyLayer:refreshBtnEnergy()

    self:getNode("btn_add_energy"):setVisible(true);
    self:getNode("btn_get_energy"):setVisible(true);
    if(self.moneyType == OPEN_BOX_REPU) then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeRepuIcon(self:getNode("btn_eng"));
        self:setLabelString("txt_eng",Data.getCurRepuNum());
    elseif(self.moneyType == OPEN_BOX_CARDEXP_ITEM)then
        Icon.changeCardExoIcon(self:getNode("btn_eng"));
        self:setLabelString("txt_eng",Data.getCurCardExp());
    elseif(self.moneyType == OPEN_BOX_PET_SOUL)then
        Icon.changePetSoulIcon(self:getNode("btn_eng"));
        self:setLabelString("txt_eng",Data.getCurPetSoul());
    elseif(self.moneyType == OPEN_BOX_SOULMONEY)then 
        Icon.changeSoulMoneyIcon(self:getNode("btn_eng"));
        self:setLabelString("txt_eng",Data.getCurSoulMoney());
    elseif(self.moneyType == ITEM_PET_SKILL)then
        Icon.changeItemIcon(self:getNode("btn_eng"),ITEM_PET_SKILL);
        self:setLabelString("txt_eng",Data.getItemNum(ITEM_PET_SKILL));
    elseif(self.moneyType == OPEN_BOX_FAMILY_DEVOTE)then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeDevoteIcon(self:getNode("btn_eng"));
        self:setLabelString("txt_eng",Data.getCurFamilyExp());
    elseif(self.moneyType == OPEN_BOX_PETMONEY)then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),OPEN_BOX_PETMONEY);
        self:setLabelString("txt_eng",Data.getCurPetMoney());
    elseif(self.moneyType == ID_SPIRIT_FRAGMENT) then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),ID_SPIRIT_FRAGMENT);
        self:setLabelString("txt_eng",SpiritInfo.getFraCount());
    elseif(self.moneyType == OPEN_BOX_EQUIP_SOUL) then
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),OPEN_BOX_EQUIP_SOUL);
        self:setLabelString("txt_eng",gUserInfo.equipSoul);
    elseif(self.moneyType == OPEN_BOX_SERVERBATTLE) then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),OPEN_BOX_SERVERBATTLE);
        self:setLabelString("txt_eng",gServerBattle.exp);
    elseif(self.moneyType == OPEN_BOX_DRAGON_BALL) then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),OPEN_BOX_DRAGON_BALL);
        self:setLabelString("txt_eng",Data.drawCard.gball);
    elseif(self.moneyType == OPEN_BOX_TOWERMONEY) then
        -- self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),OPEN_BOX_TOWERMONEY);
        self:setLabelString("txt_eng",gUserInfo.towermoney);
         
    elseif(self.moneyType == OPEN_BOX_EMOTION_MONEY)then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeEmoneyIcon(self:getNode("btn_eng"));
        local emotion = 0
        if (Data.emoney) then
            emotion = Data.emoney
        end
        self:setLabelString("txt_eng",emotion);
    elseif(self.moneyType == OPEN_BOX_SNATCH_MONEY)then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSnatchIcon(self:getNode("btn_eng"));
        local score = Data.getSnatchScore()
        self:setLabelString("txt_eng",score);
    elseif(self.moneyType == MONEY_TYPE_ITEM)then 
        Icon.changeItemIcon( self:getNode("btn_eng"),self.moneyParam);  
        self:setLabelString("txt_eng",Data.getItemNum(self.moneyParam));
        
        if(self.moneyParam==ITEM_ID_EXCHANGE_CARD)then
            self:getNode("btn_add_energy"):setVisible(true);
        else
            self:getNode("btn_add_energy"):setVisible(false);
        end
    elseif(self.moneyType==OPEN_BOX_MINEPOINT)then
        Icon.changeMinePointItemIcon(self:getNode("btn_eng"));  
        self:setLabelString("txt_eng", gDigMine.mpt);
        self:getNode("btn_add_energy"):setVisible(false);
    elseif(self.moneyType==ITEM_SPIRIT_BUY)then
        self:getNode("btn_add_energy"):setVisible(false);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),ID_SPIRIT_FRAGMENT);
        self:setLabelString("txt_eng",SpiritInfo.getFraCount());
        Icon.changeItemIcon(self:getNode("btn_spirit_buy_item"),ITEM_SPIRIT_BUY)
        self:setLabelString("txt_spirit_buy_item",Data.getItemNum(ITEM_SPIRIT_BUY));
    elseif(self.moneyType == ITEM_DRAW_GOLD_BUY)then

        self:getNode("btn_get_gold"):setVisible(false)
        self:getNode("icon_get_gold"):setVisible(false)
        self:getNode("flag_gold_w"):setVisible(false)
        Icon.changeSeqItemIcon(self:getNode("btn_gold"),OPEN_BOX_DRAGON_BALL);
        self:setLabelString("txt_gold",Data.drawCard.gball);
        self:getNode("layout_gold"):layout()


        Icon.changeItemIcon(self:getNode("btn_eng"),ITEM_DRAW_GOLD_BUY)
        self:setLabelString("txt_eng",Data.getItemNum(ITEM_DRAW_GOLD_BUY))
        self:getNode("btn_add_energy"):setVisible(false);
        self:getNode("btn_get_energy"):setVisible(false);
        
        self:getNode("layer_spirit_buy_item"):setVisible(true)
        Icon.changeItemIcon(self:getNode("btn_spirit_buy_item"),ITEM_ID_DRAW_CARD_ONE)
        self:setLabelString("txt_spirit_buy_item",Data.getItemNum(ITEM_ID_DRAW_CARD_ONE))

    elseif(self.moneyType == OPEN_BOX_FAMILY_MONEY)then
        Icon.changeSeqItemIcon(self:getNode("btn_eng"), OPEN_BOX_FAMILY_MONEY)
        self:setLabelString("txt_eng", Data.getCurFamilyMoney())
        self:getNode("btn_add_energy"):setVisible(false)
    elseif(self.moneyType == OPEN_BOX_CONSTELLATION_SOUL)then
        self:getNode("btn_add_energy"):setVisible(true);
        Icon.changeSeqItemIcon(self:getNode("btn_eng"),OPEN_BOX_CONSTELLATION_SOUL);
        self:setLabelString("txt_eng",gConstellation.getSoulNum());
    elseif(self.moneyType == OPEN_BOX_SNATCH_SCORE)then
        Icon.changeSeqItemIcon(self:getNode("btn_eng"), OPEN_BOX_SNATCH_SCORE)
        self:setLabelString("txt_eng", Data.activitySnatchData.score)
        self:getNode("btn_add_energy"):setVisible(false)
    else
        Icon.changeEnergyIcon(self:getNode("btn_eng"));
        self:setLabelString("txt_eng",Data.getCurEnergy().."/"..Data.getMaxEnergy());
    end

end

function MainMoneyLayer:onBtnEnergy()
    if(self.moneyType == OPEN_BOX_REPU) then

    elseif(self.moneyType == OPEN_BOX_CARDEXP_ITEM)then
        Panel.popUpVisible(PANEL_GLOBAL_BUY,VIP_EXP);
    elseif(self.moneyType == OPEN_BOX_PET_SOUL)then
        Panel.popUpVisible(PANEL_GLOBAL_BUY,VIP_BUYPETSOUL);
    elseif(self.moneyType == ITEM_PET_SKILL) then
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_PET);
    elseif(self.moneyType == OPEN_BOX_ENERGY)then
        Panel.popUpVisible(PANEL_BUY_ENERGY,VIP_DIAMONDHP,nil,true);
        self:getNode("panel_money"):setPositionX(self.layerGoldPos.x-100);
    elseif(self.moneyType == OPEN_BOX_EQUIP_SOUL) then
        local data={}
        data.itemid=OPEN_BOX_EQUIP_SOUL
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)    
    elseif(self.moneyType == OPEN_BOX_TOWERMONEY) then
        Panel.popUpVisible(PANEL_GLOBAL_BUY,VIP_TOWERMONEY); 
    elseif(self.moneyType == OPEN_BOX_SOULMONEY)then 
        local data={}
        data.itemid=OPEN_BOX_SOULMONEY
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)   
        
    elseif(self.moneyType == MONEY_TYPE_ITEM)then  
        if(self.moneyParam==ITEM_ID_EXCHANGE_CARD)then
            self:buyItem(self.moneyParam)
        end
    elseif(self.moneyType == OPEN_BOX_CONSTELLATION_SOUL)then
        Panel.popUp(PANEL_CONSTELLATION_SOUL)
    end
end


function MainMoneyLayer:buyItem(itemid) 
    local temp={}
    temp.itemid=itemid 
    temp.costType=OPEN_BOX_DIAMOND
    temp.price=toint(DB.getClientParam("ITEM_"..itemid.."_BUY_PRICE"))
    temp.rewardNum=1
    temp.lefttimes=math.floor(gUserInfo.diamond/temp.price)
    temp.buyCallback=function(num)  
        Net.sendBuyItem(itemid,num) 
    end

    Panel.popUp(PANEL_SHOP_BUY_ITEM,temp)
end

function MainMoneyLayer:onTouchEnded(target)
    Panel.popBackTopPanelByType(PANEL_CHAT)
    if(target.touchName == "btn_menu") then
        if self.isUpBtn == false then
            self:upBtns()
        else
            self:downBtns()
        end
    elseif(target.touchName=="btn_constellation")then
        if Unlock.isUnlock(SYS_CONSTELLATION) then
            Panel.popUp(PANEL_CONSTELLATION_MAIN)
        end
    elseif(target.touchName=="btn_up")then
        self:upBtns()
    elseif(target.touchName=="btn_down")then
        self:downBtns()
    elseif(target.touchName=="btn_hero")then
        Panel.popUp(PANEL_CARD)
    elseif(target.touchName=="btn_piece")then
        Panel.popUp(PANEL_BAG,2)
    elseif(target.touchName=="btn_atlas")then
        Panel.popUp(PANEL_ATLAS)
    elseif(target.touchName=="btn_weapon")then

        if Unlock.isUnlock(SYS_WEAPON) then
            gCurRaiseCardid=nil
            Net.sendCardRaiseInfo();
        end
    elseif(target.touchName=="btn_task")then
        if Unlock.isUnlock(SYS_TASK) then
            self:onTask();
        end
    elseif(target.touchName=="btn_pet")then
        if Unlock.isUnlock(SYS_PET) then
            Panel.popUp(PANEL_PET)
        end
    elseif(target.touchName == "btn_xunxian")then
        if Unlock.isUnlock(SYS_XUNXIAN) then
            Net.sendSpiritInit(0)
        end
    elseif(target.touchName=="btn_daily_task")then
        Panel.popUp(PANEL_ARENA)
    elseif(target.touchName=="btn_shop")then
        Panel.popUp(PANEL_SHOP)
    elseif(target.touchName=="btn_draw_card")then
        Panel.popUp(PANEL_DRAW_CARD)
    elseif(target.touchName=="btn_get_gold")then
        Panel.popUpVisible(PANEL_BUY_GOLD,nil,nil,true)
        self:getNode("panel_money"):setPositionX(self.layerGoldPos.x-100);
    elseif(target.touchName=="btn_get_dia")then
        if not Panel.isOpenPanel(PANEL_PAY) then
            Panel.popUp(PANEL_PAY);
        end
    elseif(target.touchName=="btn_get_energy")then
        self:onBtnEnergy();
    elseif(target.touchName=="btn_red_package")then
        if(self.redPack)then 
            Net.sendActivityLootName=self.redPack.name
            Net.sendActivityLoot20(self.redPack.id)
        end
    elseif(target.touchName == "btn_more")then
        Panel.popUp(PANEL_CRUSADE_BUY_TIME)    
    end

end

function MainMoneyLayer:enterTask(listdata)
    -- body
    Panel.popUp(PANEL_TASK,1,listdata)
end
function MainMoneyLayer:onTask()
    Net.sendDayTaskList();
end
function MainMoneyLayer:callWhenPopPanel()

    self:getNode("panel_money"):setPositionX(self.layerGoldPos.x-100);

    self:upBtns(0)


end
function MainMoneyLayer:reFreshCrudeData()
    if(self:getNode("panel_cru_money"):isVisible() and gCrusadeData and gCrusadeData.crunum)then
        self:setLabelString("txt_exploits",gCrusadeData.exploits)
        self:setLabelString("txt_feats",gCrusadeData.feats)
        local maxNum=DB.getClientParam("CRUSADE_TOKEN_SHOW_MAX")
        self:setLabelString("txt_num", gCrusadeData.crunum.."/"..maxNum) 
        self:resetLayOut();
    end
end


function MainMoneyLayer:callWhenPopBackPanel()

    self:getNode("panel_money"):setPositionX(self.layerGoldPos.x);

    self:setMoneyType(OPEN_BOX_ENERGY);
    self:getNode("panel_menu"):setVisible(true)
end


function MainMoneyLayer:events()
    return {
        EVENT_ID_USER_DATA_UPDATE,
        EVENT_ID_TASK_LIST, 
        EVENT_ID_GET_ACTIVITY_NEW_PACKAGE,
        EVENT_ID_GET_ACTIVITY_LOOP_PACKAGE,
        EVENT_ID_CRUSADE_BUY,
        EVENT_ID_ITEM_BUYED,
        EVENT_ID_BUY_ITEM
    }
end


function MainMoneyLayer:dealEvent(event,param)
    if(event==EVENT_ID_USER_DATA_UPDATE)then
        self:setLabelString("txt_dia",gUserInfo.diamond)
        local num,needShort = gGetCurGoldNumForShort();
        self:setLabelString("txt_gold",num);
        self:getNode("flag_gold_w"):setVisible(needShort);
        self:getNode("layout_gold"):layout();
        -- gShowCurGoldShortNum(self,"txt_gold");
        self:refreshBtnEnergy();
        self:reFreshCrudeData()
    elseif(event == EVENT_ID_TASK_LIST) then
        self:enterTask(param);
        
    elseif(event==EVENT_ID_ITEM_BUYED)then
        self:refreshBtnEnergy(); 
    elseif(event==EVENT_ID_BUY_ITEM)then 
        self:buyItem(ITEM_ID_EXCHANGE_CARD)

    elseif(event == EVENT_ID_GET_ACTIVITY_NEW_PACKAGE) then 
        self:getNode("panel_red_pack_name"):setVisible(true)
        self.redPack=param
        self:replaceLabelString("txt_red_pack_name",param.name)
        self:getNode("panel_red_pack_name"):stopAllActions()
        
        local function onTiming()
            self:getNode("panel_red_pack_name"):setVisible(false)
            self.redPack=nil  
        end
        self:getNode("panel_red_pack_name"):runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(onTiming,{}))) 
    elseif(event == EVENT_ID_GET_ACTIVITY_LOOP_PACKAGE) then 
        self:getNode("panel_red_pack_name"):setVisible(false) 
        self.redPack=nil
    end
end


function MainMoneyLayer:downBtns(time)
    if(self.isUpBtn==false)then
        return
    end
    self.isUpBtn=false
    if(time==nil) then
        time=0.15
    end
    self:changeNodeToFla("btn_down","ui_muen","ui_main_menu_b",false,0);
    -- self:getNode("btn_down"):setVisible(false)
    -- self:getNode("btn_up"):setVisible(true)


    for key, var in pairs(self.hideBtns) do
        local node=self:getNode(var)
        node:stopAllActions()
        local pos=self.hideBtnsPos[var]
        node:setVisible(true)
        local fadeIn=cc.EaseOut:create(cc.FadeIn:create(time),2.5)
        local moveUp=cc.EaseOut:create(cc.MoveTo:create(time,pos ),2.5)
        node:runAction( cc.Spawn:create(fadeIn,moveUp) )
    end

    local bgMenu = self:getNode("bg_menu");
    bgMenu:setOpacity(0);
    bgMenu:runAction(
        cc.Spawn:create(
            cc.FadeIn:create(time),
            cc.ScaleTo:create(time,1,gGetScreenHeight()/bgMenu:getContentSize().height)
        )
    );

end

function MainMoneyLayer:upBtns(time)
    if(self.isUpBtn==true)then
        return
    end
    self.isUpBtn=true
    if(time==nil) then
        time=0.15
    end

    local aniGroup2 = FlashAniGroup.new();
    aniGroup2:addFlashAni("ui_main_menu_c",true);
    aniGroup2:addFlashAni("ui_main_menu_a",false);
    aniGroup2:play();
    self:replaceNode("btn_down",aniGroup2);

    -- self:changeNodeToFla("btn_down","ui_muen","ui_main_menu_c",false,0);

    -- self:getNode("btn_down"):setVisible(true)
    -- self:getNode("btn_up"):setVisible(false)



    for key, var in pairs(self.hideBtns) do
        local node=self:getNode(var)
        node:stopAllActions()
        if(time==0)then
            node:setPosition(cc.p(node:getPositionX(),0))
            node:setVisible(false)
        else
            local function onMoveReach()
                node:setVisible(false)
            end
            local fadeOut=cc.EaseOut:create(cc.FadeOut:create(time),2.5)
            local moveUp=cc.EaseOut:create(cc.MoveTo:create(time,cc.p(node:getPositionX(),0)) ,2.5)
            local callFunc=cc.CallFunc:create(onMoveReach)
            node:runAction(cc.Sequence:create(cc.Spawn:create(fadeOut,moveUp),callFunc))
        end
    end

    local bgMenu = self:getNode("bg_menu");
    bgMenu:setOpacity(255);
    bgMenu:runAction(
        cc.Spawn:create(
            cc.FadeOut:create(time),
            cc.ScaleTo:create(time,1,0)
        )
    );
end

function MainMoneyLayer:refreshSpiritBuyItem()
    self:setLabelString("txt_spirit_buy_item",Data.getItemNum(ITEM_SPIRIT_BUY));
end

function MainMoneyLayer:resetGoldLayerInfo(type)
    if self.moneyType == ITEM_DRAW_GOLD_BUY and type~=ITEM_DRAW_GOLD_BUY then


        self:getNode("btn_get_gold"):setVisible(true)
        self:getNode("icon_get_gold"):setVisible(true)
        Icon.changeSeqItemIcon(self:getNode("btn_gold"),OPEN_BOX_GOLD)
        local num,needShort = gGetCurGoldNumForShort();
        self:setLabelString("txt_gold",num);
        self:getNode("flag_gold_w"):setVisible(needShort);
        self:getNode("layout_gold"):layout();
    end
end

return MainMoneyLayer