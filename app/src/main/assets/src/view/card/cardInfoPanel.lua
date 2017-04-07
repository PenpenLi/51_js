local CardInfoPanel=class("CardInfoPanel",UILayer)

function CardInfoPanel:ctor(param1,param2)
    print("#########CardInfoPanel:ctor");
    loadFlaXml("ui_effect");
    self:init("ui/ui_card_info.map")
    gSetCascadeOpacityEnabled("panel_ignore",true)
    self.isBlackBgVisible=false
    gCreateBtnBack(self);
    self.curEquipIdx=0
    self.hasCard=false
    self.playCardSound = true;
    self.firstPanel=param2
    self:getNode("lock_icon"):setVisible(false)
    self:getNode("lock_icon2"):setVisible(false)
    self:setNodeTouchRectOffset("btn_more",20,20);
    self.muouVars = {
        {"tou","youshou_c","zuoshou_c","shenti_a","shenti_a","youjiao_a","zuojiao_a"},
        {"tou","tou","tou","shenti_a","shen_b","youjiao_c","zuojiao_c"},
        {"tou","shenti_a","shenti_a","youshou_a","youshou_c","zuoshou_a","zuoshou_c"},
        {"tou","tou","youshou_c","zuoshou_c","shenti_a","youjiao_c","zuojiao_c"},
        {"tou","shenti_a","youshou_c","zuoshou_c","youjiao_c","zuojiao_c","shen_b"},
        {"shenti_a","youjiao_c","zuojiao_c","youshou_c","zuoshou_c","tou","tou"},
    }

    self:initWithCardId(param1);
    -- if(param1)then
    --     local idx=1
    --     for key, var in pairs(gUserCards) do
    --         if(var.cardid==param1)then
    --             self.hasCard=true
    --             self.curShowIdx=(idx)
    --             self:showCard(  self.curShowIdx)
    --             break
    --         end
    --         idx=idx+1
    --     end
    -- else
    --     self.hasCard=true
    --     self.curShowIdx=1
    --     self:showCard(  self.curShowIdx)
    -- end

    -- self:getNode("layer_awake"):setVisible(false);
    -- self:getNode("layer_unget"):setVisible(false);
    -- if(self.hasCard==false)then
    --     self:getNode("btn_next"):setVisible(false)
    --     self:getNode("btn_pre"):setVisible(false)
    --     self:getNode("layer_levelup"):setVisible(false)
    --     self:getNode("btn_share"):setVisible(false)
    --     self:getNode("layer_unget"):setVisible(true);
    --     self:getNode("btn_wakeup"):setVisible(false)
    --     self:getNode("btn_evolve"):setVisible(false)
    --     self:getNode("btn_batch_strong"):setVisible(false)
    --     self:getNode("btn_upgrade"):setVisible(false)
    --     self:getNode("btn_treasure"):setVisible(false)
    --     self:setCard(Data.initUserCard(param1))
    -- end

    self.layer_right_pos = cc.p(self:getNode("layer_right"):getPosition());
    self.layer_right_pos.x = self.layer_right_pos.x - 100;
    self:appearAct();
    self:hideCloseModule();
    AttChange.aniSpeed = 1;
-- if(self.hasCard)then

--     self:setUnlockBtn("btn_weapon")
-- else
--     self:getNode("btn_weapon"):setVisible(false)
-- end

-- self:getNode("btn_preview2"):setVisible(isUnlockIdForAwake(self.cardDb.cardid));

end

function CardInfoPanel:initFromCache(param1,param2)
    print("initFromCache");
    -- self.curEquipIdx=0
    self.hasCard=false
    self.playCardSound = true;
    -- if(self.isInAwake)then
    -- self:backCardAwake();
    -- end
    self.isInAwake = false;
    self.isInTreasure = false;
    if(self.treasurePanel)then
        self.treasurePanel:removeFromParent(true);
        self.treasurePanel = nil;
    end
    if(self.layer_right_pos ~= nil)then
        self:getNode("layer_right"):setPosition(cc.p(self.layer_right_pos));
    end
    self:getNode("panel_ignore"):setOpacity(0)
    self:getNode("btn_batch_strong"):setOpacity(255);
    self:getNode("btn_wakeup"):setOpacity(255);
    self:getNode("layer_att_change"):removeAllChildren();
    self:initWithCardId(param1);
    self:initAppearInitPro();
    self:showNodeAppearActs(true);

    self.firstPanel=param2

    self:appearAct();
    self:hideCloseModule();
end

function CardInfoPanel:initWithCardId(cardid)

    self.hasCard = false
    if(cardid)then
        local idx=1
        for key, var in pairs(gUserCards) do
            if(var.cardid==cardid)then
                self.hasCard=true
                self.curShowIdx=(idx)
                self:showCard(  self.curShowIdx)
                break
            end
            idx=idx+1
        end
    else
        self.hasCard=true
        self.curShowIdx=1
        self:showCard(  self.curShowIdx)
    end

    self:getNode("layer_awake"):setVisible(false);
    self:getNode("layer_unget"):setVisible(false);
    self:getNode("btn_next"):setVisible(self.hasCard)
    self:getNode("btn_pre"):setVisible(self.hasCard)
    self:getNode("layer_levelup"):setVisible(self.hasCard)
    self:getNode("btn_share"):setVisible(self.hasCard)
    self:getNode("layer_unget"):setVisible(not self.hasCard);
    self:getNode("btn_wakeup"):setVisible(self.hasCard)
    self:getNode("btn_evolve"):setVisible(self.hasCard)
    self:getNode("btn_batch_strong"):setVisible(self.hasCard)
    self:getNode("btn_upgrade"):setVisible(self.hasCard)
    self:getNode("btn_treasure"):setVisible(self.hasCard)
    self:getNode("btn_weapon"):setVisible(self.hasCard)
    if(self.hasCard==false)then
        self:setCard(Data.initUserCard(cardid))
    else
        self:setUnlockBtn(SYS_WEAPON,"btn_weapon","lock_icon")
        self:setUnlockBtn(SYS_TREASURE,"btn_treasure","lock_icon2")
    end
    self:setVisible(true);
    self:getNode("btn_preview2"):setVisible(isUnlockIdForAwake(cardid));
end

function CardInfoPanel:hideCloseModule()
    if(self.hasCard)then
        self:getNode("btn_share"):setVisible(not Module.isClose(SWITCH_SHARE));
        self:getNode("btn_treasure"):setVisible(not Module.isClose(SWITCH_TREASURE));
        self:getNode("btn_batch_strong"):setVisible(not Module.isClose(SWITCH_VIP));
    end
end

function CardInfoPanel:setUnlockBtn(sys,name,lock)

    local btn=self:getNode(name)
    if Unlock.isUnlock(sys,false) then
        self:getNode(lock):setVisible(false)
        DisplayUtil.setGray(btn,false)
        return
    end
    self:getNode(lock):setVisible(true)
    DisplayUtil.setGray ( btn,true)

end

function CardInfoPanel:appearAct()
    self:setNodeAppear("layer_appear1",true);
    self:setNodeAppear("layer_appear2",true);
    self:setNodeAppear("layer_right",true);
    self:setNodeAppear("layer_bg",true);
end


function CardInfoPanel:getGuideItem(name)
    return self.curPanel:getNode(name)
end


function CardInfoPanel:onPopup()
    if(self.curCard)then
        self.lastFlaId=0
        self.playCardSound = false;
        local card=Data.getUserCardById(gCurRaiseCardid)
        if(card)then
            self:setCard(card)
        else
            self:setCard(self.curCard)
        end


        if(self.firstPanel == 10)then
            self.firstPanel = nil;
            self:enterTreasure(2); 
        elseif(self.firstPanel == 11)then
            self.firstPanel = nil;
            self:enterTreasure(3); 
        end
    end
end

function CardInfoPanel:refreshCardData(card)
    self.curCard=card
    if self.curCard.pid==nil then
        self.curCard.pid=0
    end
    gCurRaiseCardid=self.curCard.cardid
    self.cardDb=DB.getCardById(self.curCard.cardid)
end

function CardInfoPanel:setCard(card)
    print("setCard");
    RedPoint.bolCardViewDirty=true
    self:refreshCardData(card);
    -- self.curCard=card
    -- gCurRaiseCardid=self.curCard.cardid
    -- self.cardDb=DB.getCardById(self.curCard.cardid)
    -- self:setLabelString("txt_name",self.cardDb.name,nil,true)
    gShowRoleName(self,"txt_role_name",self.cardDb.name,self.cardDb.cardid,true);
    self:changeTexture("icon_card_type","images/ui_public1/card_type_"..self.cardDb.type..".png")
    Icon.setCardCountry(self:getNode("country"),self.cardDb.country);
    self:getNode("flag_super"):setVisible(toint(self.cardDb.supercard)== 1);
    -- self:getNode("icon_card_type"):setPositionX(self:getNode("txt_role_name"):getPositionX() - self:getNode("txt_role_name"):getContentSize().width/2 - 2);
    self:showCardFla(self.curCard)
    self.curCardid=self.curCard.cardid

    if( self.treasurePanel )then
        if(  self.treasurePanel.curCardid~=self.curCardid)then
            self.treasurePanel:showSelectCard(self.curCardid) 
        end
        gRedposRefreshDirty=true
        Panel.setMainMoneyType(OPEN_BOX_TOWERMONEY)
    end


    self:resetLayOut();

    -- CardPro.showStar6(self,self.curCard.grade,self.curCard.awakeLv)
    -- self:setLabelString("txt_power", self.curCard.power)
    self:refreshPower();
    self:refreshExp();
    self:refreshPetIcon()
    -- --等级
    -- gShowRoleLv(self,"txt_level",self.curCard.level);
    -- -- self:setLabelString("txt_level","Lv."self.curCard.level)
    -- --经验
    -- local maxExp = DB.getCardExpByLevel(self.curCard.level);
    -- self:setLabelString("txt_exp",self.curCard.exp.."/"..maxExp)
    -- self:setBarPer("bar_exp",self.curCard.exp/maxExp);
    self:getNode("btn_cancel_ignore"):setVisible(false)
    self:getNode("btn_ignore"):setVisible(false)
    --碎片
    self:refreshSouls();
    -- local curSoulNum=Data.getSoulsNumById(self.cardDb.cardid)
    -- local needSoulNum=0

    -- if(self.hasCard==true)then
    --     if(self.curCard.ignore)then
    --         self:getNode("btn_ignore"):setVisible(true)
    --     else
    --         self:getNode("btn_cancel_ignore"):setVisible(true)
    --     end
    --     needSoulNum=DB.getNeedSoulForAll(self.curCard.grade,self.curCard.cardid,self.curCard.awakeLv)
    -- else
    --     needSoulNum=DB.getNeedInitSoulNum(self.curCard.grade-1)
    -- end
    -- -- local per=curSoulNum/needSoulNum
    -- self:setBarPer2("bar",curSoulNum,needSoulNum);
    -- self:setBarPer2("bar2",curSoulNum,needSoulNum);
    -- -- self:setLabelString("txt_per",curSoulNum.."/"..needSoulNum)
    -- gShowLabStringCurAndMax(self,"txt_per",curSoulNum,needSoulNum);
    -- gShowLabStringCurAndMax(self,"txt_per2",curSoulNum,needSoulNum);

    -- if(curSoulNum >= needSoulNum) then
    --     self:changeTexture("btn_more2","images/ui_public1/button_blue_1.png");
    --     self:setLabelString("txt_btn_more2",gGetWords("btnWords.plist","123"));
    --     self.canGet = true;
    -- else
    --     self:changeTexture("btn_more2","images/ui_public1/button_red_1.png");
    --     self:setLabelString("txt_btn_more2",gGetWords("btnWords.plist","128"));
    --     self.canGet = false;
    -- end

    --升星
    -- self:setTouchEnableGray("btn_evolve",CardPro.canEvolve(self.curCard));
    -- --觉醒
    -- if(self.curCard.grade >= 5 and Module.isClose(SWITCH_AWAKE) == false)then
    --     self:changeTexture("btn_evolve","images/ui_word/npc_info_awake.png");
    --     self:setTouchEnableGray("btn_evolve",true);
    -- else
    --     --升星
    --     self:changeTexture("btn_evolve","images/ui_word/npc_info_starup.png");
    --     self:setTouchEnableGray("btn_evolve",CardPro.canEvolve(self.curCard));
    -- end

    self:refreshEqu();
    self:refreshStar();
    -- --强化
    -- self:setTouchEnableGray("btn_batch_strong",CardPro.canOneEquipUpgrade(self.curCard));

    -- --升阶
    -- self:setTouchEnableGray("btn_wakeup",CardPro.canUpQuality(self.curCard));

    -- if(self.hasCard == false)then
    --     self:getNode("btn_wakeup"):setVisible(false)
    --     self:getNode("btn_evolve"):setVisible(false)
    --     self:getNode("btn_batch_strong"):setVisible(false)
    --     self:getNode("btn_upgrade"):setVisible(false)
    -- end

    -- self:setLabelString("txt_power",self.curCard.power);

    -- for i=0, MAX_CARD_EQUIP_NUM-1 do
    --     self:showEquip(i)
    -- end


    if(self.curPanel)then
        self.curPanel:setCard(self.curCard,self.curEquipIdx)
        self.curPanel:setOpacityEnabled(true);
    else
        if(self.firstPanel==nil or self.firstPanel==1)then
            self:showProPanel()
        elseif(  self.firstPanel==2)then
            self:showSkillPanel()
        elseif(  self.firstPanel==3)then
            self:showEquipPanel()   
        end
    end

    --最大技能点红点提示
    Data.setMaxSkillPointRedPoint(card,self.hasCard)

    if(self.isInAwake)then
        self:initCardAwake(true);
    end
end

function CardInfoPanel:refreshPower()
    self:setLabelString("txt_power", self.curCard.power)
end

function CardInfoPanel:refreshExp()
    --等级
    gShowRoleLv(self,"txt_level",self.curCard.level);
    -- self:setLabelString("txt_level","Lv."self.curCard.level)
    --经验
    local maxExp = DB.getCardExpByLevel(self.curCard.level);
    self:setLabelString("txt_exp",self.curCard.exp.."/"..maxExp)
    self:setBarPer("bar_exp",self.curCard.exp/maxExp);
end

function CardInfoPanel:refreshEqu()

    for i=0, MAX_CARD_EQUIP_NUM-1 do
        self:showEquip(i)
    end

    --强化
    self:setTouchEnableGray("btn_batch_strong",CardPro.canOneEquipUpgrade(self.curCard));

    --突破
    self:setTouchEnableGray("btn_wakeup",CardPro.canUpQuality(self.curCard));

end

function CardInfoPanel:refreshSouls()
    --碎片
    local curSoulNum=Data.getSoulsNumById(self.cardDb.cardid)
    local needSoulNum=0

    if(self.hasCard==true)then
        if(self.curCard.ignore)then
            self:getNode("btn_ignore"):setVisible(true)
        else
            self:getNode("btn_cancel_ignore"):setVisible(true)
        end
        needSoulNum=DB.getNeedSoulForAll(self.curCard.grade,self.curCard.cardid,self.curCard.awakeLv)
        self:setBarPer2("bar",curSoulNum,needSoulNum);
        gShowLabStringCurAndMax(self,"txt_per",curSoulNum,needSoulNum);
    else
        needSoulNum=DB.getNeedInitSoulNum(self.curCard.grade-1)
        self:setBarPer2("bar2",curSoulNum,needSoulNum);
        gShowLabStringCurAndMax(self,"txt_per2",curSoulNum,needSoulNum);
        if(curSoulNum >= needSoulNum) then
            self:changeTexture("btn_more2","images/ui_public1/button_blue_1.png");
            self:setLabelString("txt_btn_more2",gGetWords("btnWords.plist","123"));
            self.canGet = true;
        else
            self:changeTexture("btn_more2","images/ui_public1/button_red_1.png");
            self:setLabelString("txt_btn_more2",gGetWords("btnWords.plist","128"));
            self.canGet = false;
        end
    end
end

function CardInfoPanel:refreshPetIcon()
    if Data.getCurLevel() >=Data.pet.possessOpenlv then
        self:getNode("btn_possess"):setVisible(true)
        if self.curCard.pid>0 then
            local petinfo = Data.getUserPetById(self.curCard.pid)
            Icon.setIcon(petinfo.petid,self:getNode("btn_possess"),DB.getItemQuality(petinfo.petid),petinfo.awakeLv)
        else
            self:getNode("btn_possess"):removeChildByTag(1)
            self:changeTexture("btn_possess", "images/ui_public1/ka_d1.png")
        end
    else
        self:getNode("btn_possess"):setVisible(false)
    end

end


function CardInfoPanel:refreshStar()
    CardPro.showStar6(self,self.curCard.grade,self.curCard.awakeLv)
    --觉醒
    if(self.curCard.grade >= 5 and Module.isClose(SWITCH_AWAKE) == false)then
        self:changeTexture("btn_evolve","images/ui_word/npc_info_awake.png");
        self:setTouchEnableGray("btn_evolve",true);
    else
        --升星
        self:changeTexture("btn_evolve","images/ui_word/npc_info_starup.png");
        self:setTouchEnableGray("btn_evolve",CardPro.canEvolve(self.curCard));
    end
end

function CardInfoPanel:refreshRightCurPanel()
    if(self.curPanel)then
        self.curPanel:setCard(self.curCard,self.curEquipIdx)
        self.curPanel:setOpacityEnabled(true);
    end
end

function CardInfoPanel:canAwake(card)
    if(self.isInTreasure==true)then
        return true
    end
    if(card.grade >=5 and card.level >= Data.cardAwake.needLv)then
        return true;
    end
    return false;
end

function CardInfoPanel:canPageForAwake()
    local count = 0;
    for key,card in pairs(gUserCards)do
        if(self:canAwake(card))then
            count = count + 1;
        end
    end
    return count > 1;
end

function CardInfoPanel:preAwakeCard()
    self:showAwakeCard(0);
end

function CardInfoPanel:nextAwakeCard()
    self:showAwakeCard(1);
end

--type = 0 上一个    type = 1 下一个
function CardInfoPanel:showAwakeCard(type)
    self.rec_awake_cardid = 0;
    local nextIdx = self.curShowIdx;
    local index = 0;
    while(true) do
        if(type == 1)then
            nextIdx = nextIdx + 1;
            if(nextIdx > table.getn(gUserCards))then
                nextIdx = 1;
            end
        elseif(type == 0)then
            nextIdx = nextIdx - 1;
            if(nextIdx < 1)then
                nextIdx = table.getn(gUserCards);
            end
        end

        local card = gUserCards[nextIdx];
        if(self:canAwake(card))then
            self:showCard(nextIdx);
            break;
        end
        index = index + 1;
        if(index > 100)then
            break;
        end
    end
end

function CardInfoPanel:showCard(idx)
    if(idx>table.getn(gUserCards) )then
        idx=1
    end

    if(idx<1)then
        idx=table.getn(gUserCards)
    end
    self.curShowIdx=idx
    self:setCard(gUserCards[idx])

    if(self.isInAwake and (self.curCard.grade < 5 or self.curCard.level < Data.cardAwake.needLv))then
        self:backCardAwake();
    end

    self:getNode("btn_preview2"):setVisible(isUnlockIdForAwake(self.cardDb.cardid));
end

function CardInfoPanel:showEquip(idx)
    local node=self:getNode("equip"..idx)
    local equipId=self.cardDb["equid"..idx]
    local qua= self.curCard.equipQuas[idx]
    local equipLv= self.curCard.equipLvs[idx]

    local equipment= DB.getEquipment(equipId,qua)

    if(equipLv==0)then
        self:setLabelString("equip_num"..idx,"")
    else
        self:setLabelString("equip_num"..idx,equipLv)
    end
    if(equipment)then
        Icon.setEquipmentIcon(equipment.icon,node,qua)
    end

end

function CardInfoPanel:showCardFla(card,action)
    local cardid=card.cardid
    if(self.lastFlaId==cardid)then
        return
    end
    print("showCardFla");
    self:parseFlaActions()
    self.lastFlaId=cardid
    self.fla=gCreateRoleFla(cardid, self:getNode("role_container") ,1,true,nil,card.weaponLv,card.awakeLv)
    if(card.cache==true)then
        Scene.addFlaTextureCache("r"..cardid,card.weaponLv,card.awakeLv)
    end
    self:nextFlaAction()
end

function CardInfoPanel:parseFlaActions()
    self.flaAction={}
    self.curFlaActionIdx=0
    local actions=string.split(self.cardDb.actlist,",")
    for key, actionid in pairs(actions) do

        if(actionid=="0")then
            table.insert(self.flaAction,"wait")
        elseif(actionid=="1")then
            table.insert(self.flaAction,"run")
        elseif(actionid=="2")then
            table.insert(self.flaAction,"win")
        elseif(actionid=="3")then
            table.insert(self.flaAction,"attack_s")
        elseif(actionid=="4")then
            table.insert(self.flaAction,"attack_b")
        end
    end

end

function CardInfoPanel:nextFlaAction()

    self.curFlaActionIdx=self.curFlaActionIdx+1
    if(self.curFlaActionIdx>table.getn(self.flaAction))then
        self.curFlaActionIdx=1
    end

    self:playFlaAction( self.flaAction[self.curFlaActionIdx])
end

function CardInfoPanel:playFlaAction(action)
    if(self.fla)then
        if(action==nil)then
            action="wait"
        end
        local function onCallBack()
            if(action=="run")then
                self.fla:playAction( "r"..self.lastFlaId.."_run" ,onCallBack)
            else
                self.fla:playAction( "r"..self.lastFlaId.."_wait" ,onCallBack)
            end
            self:addShade();
        end
        if(action=="wait" and self.playCardSound)then
            if(self.lastSoundId)then
                gStopEffect(self.lastSoundId)
            end
            if not Guide.isGuiding() then
                if isBanshuReview() == false then
                    self.lastSoundId= gPlayEffect("sound/card/"..self.curCard.cardid..".mp3")
                end
            end
        end
        self.fla:playAction("r"..self.lastFlaId.."_"..action ,onCallBack)
        self:addShade();
        self.playCardSound = true;
    end
end

function CardInfoPanel:addShade()
    if self.fla:getChildByTag(100) ~= nil then
        return;
    end
    local shadow=cc.Sprite:create("images/battle/shade.png")
    shadow:setScaleY(0.5)
    shadow:setTag(100);
    self.fla:addChild(shadow,-1)
end


function CardInfoPanel:resetBtnTexture()
    local btns={
        "btn_pro",
        "btn_skill",
        "btn_equip",
        "btn_relation"
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end


function CardInfoPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end


function CardInfoPanel:showIgnoreTxt(txt)
    self:setLabelString("txt_ignore",txt)
    self:getNode("panel_ignore"):setOpacity(0)
    self:getNode("panel_ignore"):stopAllActions()
    self:getNode("panel_ignore"):runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(1.0),cc.FadeOut:create(0.3)) )
end

function CardInfoPanel:onTouchEnded(target)

    if target.touchName=="btn_weapon"then
        if Unlock.isUnlock(SYS_WEAPON) then
            Net.sendCardRaiseInfo();
        end
    elseif target.touchName=="btn_treasure"then

        if Unlock.isUnlock(SYS_TREASURE) then
            self:enterTreasure()
        end
        --  Panel.popUpVisible(PANEL_TREASURE)
    elseif target.touchName=="btn_possess" then
        if self.curCard.pid>0 then
             Panel.popUpVisible(PANNEL_PET_TALENT_PROT,self.curCard)
        else
            Panel.popUpVisible(PANNEL_CARD_SELECT_PET,self.curCard.cardid)
        end
        
    elseif target.touchName=="btn_pre" then

        if(self.isInAwake)then
            self:preAwakeCard();
        else
            self:showCard(self.curShowIdx-1)
        end
    elseif  target.touchName=="btn_next" then

        if(self.isInAwake)then
            self:nextAwakeCard();
        else
            self:showCard(self.curShowIdx+1)
        end
    elseif  target.touchName=="btn_cancel_ignore" then
        self:showIgnoreTxt(gGetWords("labelWords.plist","ignore_card"))
        Net.sendCardIngore(self.curCard.cardid,true)
    elseif  target.touchName=="btn_ignore" then
        self:showIgnoreTxt(gGetWords("labelWords.plist","cancel_ignore_card"))
        Net.sendCardIngore(self.curCard.cardid,false)
    elseif  target.touchName=="btn_close"then
        if(Module.isClose(SWITCH_AWAKE))then
            Panel.popBack(self:getTag())
        else
            if(self.isInAwake or self.isInTreasure)then
                self:backCardAwake();
            else
                Panel.popBack(self:getTag())
            end
        end
    elseif  target.touchName=="btn_pro" then
        self:showProPanel()

        -- local data = {};
        -- for i=1,4 do
        --     table.insert(data,"防御+"..math.random(100,200));
        -- end
        -- AttChange.pushAtt(PANEL_CARD_INFO,data);
        -- AttChange.pushPower(PANEL_CARD_INFO,10000,20000);

    elseif  target.touchName=="btn_skill" then
        self:showSkillPanel()

        -- AttChange.pushPower(PANEL_CARD_INFO,10000,20000);

    elseif  target.touchName=="btn_equip" then
        self:showEquipPanel()
    elseif  target.touchName=="btn_relation" then
        self:showRelationPanel()
    elseif  string.find( target.touchName,"equip")  and string.len(target.touchName)==6 then
        self.curEquipIdx=toint(string.sub(target.touchName,6,string.len(target.touchName)))
        self:showEquipPanel()

    elseif  target.touchName=="btn_evolve" then

        if(Module.isClose(SWITCH_AWAKE))then
            Net.sendCardEvolve(self.cardDb.cardid)
        else
            if(self.curCard and self.curCard.grade >= 5)then
                --TODO:进入觉醒
                self:enterCardAwake();
            else
                Net.sendCardEvolve(self.cardDb.cardid)
            end
        end
    elseif  target.touchName=="btn_wakeup" then
        local isAllEquipUpgrade,level = CardPro.isAllEquipUpgrade(self.curCard);
        if(isAllEquipUpgrade==false)then
            gShowNotice(gGetWords("noticeWords.plist","need_equip_upgrade",level ))
            return
        end
        Net.sendCardUpQuality(self.curCard.cardid)
    elseif  target.touchName=="card_touch_node" then
        self:nextFlaAction()
    elseif  target.touchName=="btn_more2" then
        if (self.canGet) then
            Net.sendCardRecurit(self.cardDb.cardid);
            Panel.popBack(self:getTag());
        else
            local data={}
            data.itemid=self.curCard.cardid
            Panel.popUpVisible(PANEL_ATLAS_DROP,data)
        end
    elseif  target.touchName=="btn_more" or target.touchName == "awake_btn_more" then
        local data={}
        data.itemid=self.curCard.cardid
        Panel.popUpVisible(PANEL_ATLAS_DROP,data)
    elseif  target.touchName=="btn_batch_strong" then
        if Unlock.isUnlock(SYS_QUICKUPGRADE,true) then
            Net.sendEquipQuickUpgrade(self.curCard.cardid )
        end
    elseif target.touchName == "btn_upgrade" then
        if self.curCard.level >= Data.getCurLevel() then
            gShowNotice(gGetWords("noticeWords.plist","card_levelup_tip",Data.getCurLevel()));
            return;
        end
        Panel.popUpVisible(PANEL_CARD_LEVELUP,self.curCard);
    elseif target.touchName == "touchName" then
    -- TODO:卡牌类型说明
    elseif target.touchName == "btn_preview" or target.touchName == "btn_preview2" then
        Panel.popUpVisible(PANEL_CARD_AWAKE_PREVIEW,self.cardDb.cardid);
    elseif target.touchName == "btn_awake" then
        --卡牌觉醒
        if(self.playMuouFla)then
            return;
        end
        if(NetErr.CardWaken(self.curCard.awakeData.itemnum,self.cardDb.cardid,self.curCard.awakeData.soulnum,self.curCard.awakeData.goldnum))then
            self.rec_awake_cardid = self.cardDb.cardid;
            self.rec_awake_lv = self.curCard.awakeLv+1;
            Net.sendCardWaken(self.cardDb.cardid)
        end
    elseif target.touchName == "btn_awake_rule" then
        gShowRulePanel(SYS_CARDAWAKE);
    elseif target.touchName == "btn_share"then
        Panel.popUpVisible(PANEL_SHARE_NEWCARD,self.cardDb.cardid);
    elseif target.touchName == "btn_recycle"then
        Panel.popUp(PANEL_TRANSMIT,self.cardDb.cardid)
    end


end

function CardInfoPanel:events()
    return {
        EVENT_ID_CARD_EVOLVE,
        EVENT_ID_EQUIP_UPGRADE,
        EVENT_ID_EQUIP_UPQUALITY,
        EVENT_ID_CARD_UP_QUALITY,
        EVENT_ID_CARD_QUIKE_EQUIP_UPGRADE,
        EVENT_ID_SKILL_UPGRADE,
        EVENT_ID_EQUIP_MERGE,
        EVENT_ID_SWEEP_ATLAS,
        EVENT_ID_EQUIP_ACTIVATE,
        EVENT_ID_UPDATE_REWORDS,
        EVENT_ID_CARD_AWAKE,
        EVENT_ID_CARD_INGORE,
        EVENT_ID_TREASURE_WEAR,
        EVENT_ID_TREASURE_TAKE_OFF,
        EVENT_ID_TREASURE_MERGE,
        EVENT_ID_TREASURE_DECOMPOSE,
        EVENT_ID_TREASURE_UPGRADE,
        EVENT_ID_TREASURE_QUENCH,
        EVENT_ID_REFRESH_DATA,
        EVENT_ID_TREASURE_SHARED_BUY,
        EVENT_ID_TOWER_SHOP_REWARD_BUY,
        EVENT_ID_TREASURE_RISESTAR,
        EVENT_ID_TREASURE_OKDECOMPOSE,
        EVENT_ID_TREASURE_OKMERGE,
        EVENT_ID_PET_FOR_CARD,
    }
end

function CardInfoPanel:showUpquality()
    loadFlaXml("ui_card_evolve_effect")
    local effect=gCreateFla("ui-card-tupo")
    self:getNode("role_container"):removeChildByTag(88)
    effect:setTag(88)
    gAddCenter(effect,  self:getNode("role_container") )

end

function CardInfoPanel:dealEvent(event,param)

    local card=Data.getUserCardById(gCurRaiseCardid)
    if(self.treasurePanel)then
        self.treasurePanel:dealEvent(event,param)
        self:refreshPower(); 
        if(card)then
            self:refreshCardData(card);
        end
        return;
    end
    if(card)then
        -- self:refreshCardData(card);
        if(event == EVENT_ID_EQUIP_UPGRADE or event == EVENT_ID_CARD_QUIKE_EQUIP_UPGRADE or event == EVENT_ID_EQUIP_ACTIVATE
            or event == EVENT_ID_EQUIP_UPQUALITY or event == EVENT_ID_SKILL_UPGRADE or event == EVENT_ID_CARD_AWAKE
            or event == EVENT_ID_CARD_INGORE)then
            self:refreshCardData(card);
        else
            print("refresh card ");
            self:setCard(card)
        end
    end

    RedPoint.bolCardViewDirty=true
    if(  event==EVENT_ID_CARD_UP_QUALITY )then
        self:showUpquality()
    elseif (event==EVENT_ID_PET_FOR_CARD) then
            --Icon.setIcon(param.petid,self:getNode("btn_possess"),DB.getItemQuality(param.),data.awakeLv)
            local panel = Panel.getOpenPanel(PANNEL_PET_TALENT_PROT) 
            if panel then
                Panel.popBack(panel:getTag())
            end
            self:refreshPetIcon()
           
    elseif(event==EVENT_ID_CARD_INGORE)then

        if(self.curCard.ignore)then
            self:getNode("btn_cancel_ignore"):setVisible(false)
            self:getNode("btn_ignore"):setVisible(true)
        else
            self:getNode("btn_cancel_ignore"):setVisible(true)
            self:getNode("btn_ignore"):setVisible(false)
        end
    elseif(  event==EVENT_ID_CARD_EVOLVE )then
        Panel.popUp(PANEL_CARD_UP_QUALITY,self.curCard.cardid)
    elseif(  event==EVENT_ID_EQUIP_ACTIVATE )then

        self:refreshEqu();
        self:refreshPower();
        self:refreshRightCurPanel();

        loadFlaXml("ui_card_equip_activate")
        local effect=gCreateFla("ui-card-fangru")
        gAddCenter(effect,  self:getNode("equip"..param.pos) )
        if(self.equipPanel)then
            for key, pos in pairs(param.apos) do
                local node=self.curPanel:getNode("btn_equip"..pos)
                local effect=gCreateFla("ui-card-fangru")
                gAddCenter(effect,  node )
            end
        end


    elseif(  event==EVENT_ID_EQUIP_UPGRADE )then
        -- print("EVENT_ID_EQUIP_UPGRADE");
        self:refreshEqu();
        self:refreshPower();

        loadFlaXml("ui_card_equip_activate")
        loadFlaXml("ui_card_equip_upgrade")
        local effect=gCreateFla("ui-card-fangru")
        effect:setTag(999)
        self:getNode("equip"..param):removeChildByTag(999)
        gAddCenter(effect,  self:getNode("equip"..param) )

        if(  self.equipPanel  )then
            self.equipPanel:refreshCardData(self.curCard);
            self.equipPanel:refreshAttr(self.curEquipIdx);
            self.equipPanel:refreshPrice(self.curEquipIdx);
            local node=self.equipPanel:getNode("effect_container")
            local effect=gCreateFla("ui_card_equip_upgrade")
            effect:setTag(999)
            node:removeChildByTag(999)
            gAddCenter(effect,  node )
        end

    elseif(  event==EVENT_ID_EQUIP_UPQUALITY )then
        self:refreshEqu();
        self:refreshPower();
        self:refreshRightCurPanel();

        loadFlaXml("ui_card_equip_activate")
        loadFlaXml("ui_card_equip_upquality")
        local effect=gCreateFla("ui-card-fangru")
        local pos=param.pos
        gAddCenter(effect,  self:getNode("equip"..pos) )

        if(  self.equipPanel  )then
            local node=self.equipPanel:getNode("effect_container")
            local effect=gCreateFla("ui_card_equip_upquality")
            gAddCenter(effect,  node )
        end

    elseif(  event==EVENT_ID_CARD_QUIKE_EQUIP_UPGRADE )then
        -- print("EVENT_ID_CARD_QUIKE_EQUIP_UPGRADE");
        self:refreshEqu();
        self:refreshPower();
        if(  self.equipPanel  )then
            self.equipPanel:refreshCardData(self.curCard);
            self.equipPanel:refreshAttr(self.curEquipIdx);
            self.equipPanel:refreshPrice(self.curEquipIdx);
        end

        loadFlaXml("ui_card_equip_activate")
        loadFlaXml("ui_card_equip_upquality")

        for key, pos in pairs(param.apos) do
            local effect=gCreateFla("ui-card-fangru")
            gAddCenter(effect,  self:getNode("equip"..pos) )
        end

    elseif (event == EVENT_ID_UPDATE_REWORDS) then
        self:setCard(self.curCard);
    elseif (event == EVENT_ID_CARD_AWAKE) then
        self:evtCardAwake(param);
    elseif(event == EVENT_ID_SKILL_UPGRADE)then
        self:refreshRightCurPanel();
        --最大技能点红点提示
        Data.setMaxSkillPointRedPoint(card,self.hasCard)
    elseif(
        event==EVENT_ID_EQUIP_MERGE or
        event==EVENT_ID_CARD_UP_QUALITY    )then
    end

end

function CardInfoPanel:hideAllPanel()
    self.proPanel=nil
    self.skillPanel=nil
    self.equipPanel=nil
    self.relationPanel=nil
    self.curPanel=nil
    self:getNode("panels"):removeAllChildren()

end

function CardInfoPanel:showProPanel()
    self:selectBtn( "btn_pro")
    if self.proPanel then
        self.proPanel:setCard(self.curCard)
        return
    end
    self:hideAllPanel()
    self.proPanel=CardInfoProPanel.new()
    self.proPanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.proPanel)
    self.curPanel=self.proPanel
    self.curPanel:setCard(self.curCard)
    self.curPanel:setOpacityEnabled(true);
end


function CardInfoPanel:showSkillPanel()
    self:selectBtn( "btn_skill")
    if self.skillPanel then
        self.skillPanel:setCard(self.curCard)
        return
    end

    self:hideAllPanel()
    self.skillPanel=CardInfoSkillPanel.new()
    self.skillPanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.skillPanel)
    self.curPanel=self.skillPanel
    self.curPanel:setCard(self.curCard)
    self.curPanel:setOpacityEnabled(true);
end

function CardInfoPanel:showEquipPanel()
    self:selectBtn( "btn_equip")
    self:showEquipChoose()
    RedPoint.bolCardViewDirty=true
    if self.equipPanel then
        self.equipPanel:setCard(self.curCard, self.curEquipIdx)
        return
    end
    self:hideAllPanel()
    self.equipPanel=CardInfoEquipPanel.new()
    self.equipPanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.equipPanel)
    self.curPanel=self.equipPanel
    self.curPanel:setCard(self.curCard, self.curEquipIdx)
    self.curPanel:setOpacityEnabled(true);
end

function CardInfoPanel:showEquipChoose()
    local equip=self:getNode("equip"..self.curEquipIdx)
    if(equip)then
        local posx,posy=equip:getPosition()
        self:getNode("choose_icon"):setPosition(cc.p(posx,posy))
    end
end

function CardInfoPanel:showRelationPanel()
    self:selectBtn( "btn_relation")
    RedPoint.bolCardViewDirty=true
    if self.relationPanel then
        self.relationPanel:setCard(self.curCard)
        return
    end

    self:hideAllPanel()
    self.relationPanel=CardInfoRelationPanel.new()
    self.relationPanel:setPositionY(self:getNode("panels"):getContentSize().height);
    self:getNode("panels"):addChild(self.relationPanel)
    self.curPanel=self.relationPanel
    self.curPanel:setCard(self.curCard)
    self.curPanel:setOpacityEnabled(true);
end

--初始化觉醒
function CardInfoPanel:initCardAwake(refreshCardFla)
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.1)
    if(self.hasCard == false) then
        return;
    end

    if(refreshCardFla)then
        self.lastFlaId = 0;
    end
    self.playCardSound = false;
    self:showCardFla(self.curCard)

    --累计汇总属性
    local proSets = {};
    for i=1,self.curCard.awakeLv do
        local data = DB.getCardAwake(self.curCard.cardid,i);
        local buff = self:getCardAwakeBuff(data.buffid0);
        if(buff)then
            if(proSets[buff.attr_id0] == nil)then
                proSets[buff.attr_id0] = {};
                proSets[buff.attr_id0].value = 0;
                proSets[buff.attr_id0].attType = buff.attr_id0;
                proSets[buff.attr_id0].des = buff.des;
            end
            proSets[buff.attr_id0].value = proSets[buff.attr_id0].value + buff.attr_value0;
        end

        local buff = self:getCardAwakeBuff(data.buffid1);
        if(buff)then
            if(proSets[buff.attr_id0] == nil)then
                proSets[buff.attr_id0] = {};
                proSets[buff.attr_id0].value = 0;
                proSets[buff.attr_id0].attType = buff.attr_id0;
                proSets[buff.attr_id0].des = buff.des;
            end
            proSets[buff.attr_id0].value = proSets[buff.attr_id0].value + buff.attr_value0;
        end
    end

    if(proSets[Attr_BASE_ATTR_PERCENT])then
        --加气血，攻击，物防，魔防四条属性
        local attrs = {Attr_HP_PERCENT,Attr_PHYSICAL_ATTACK_PERCENT,Attr_PHYSICAL_DEFEND_PERCENT,Attr_MAGIC_DEFEND_PERCENT};
        for key,var in pairs(attrs)do
            if(proSets[var] == nil)then
                proSets[var] = {};
                proSets[buff.attr_id0].value = 0;
                proSets[buff.attr_id0].attType = var;
                proSets[buff.attr_id0].des = "";
            end
            proSets[var].value = proSets[var].value + proSets[Attr_BASE_ATTR_PERCENT].value;
        end
    end
    proSets[Attr_BASE_ATTR_PERCENT] = nil;

    for i=1,10 do
        self:getNode("txt_awake_dec"..i):setVisible(false);
    end
    local index = 1;
    for key,var in pairs(proSets) do
        self:getNode("txt_awake_dec"..index):setVisible(true);
        self:setRTFString("txt_awake_dec"..index,self:getCardAwakeBuffDes(var.attType,var.value,var.des));
        index = index + 1;
    end

    local isAwakeLvFull = false;
    if(self.curCard.awakeLv >= Data.cardAwake.maxLv)then
        isAwakeLvFull = true;
    end
    self:setTouchEnableGray("btn_awake",not isAwakeLvFull);


    --下一级觉醒数据
    local nextAwakeLv = self.curCard.awakeLv+1;
    if(isAwakeLvFull)then
        nextAwakeLv = Data.cardAwake.maxLv;
    end
    self.curCard.awakeData = DB.getCardAwake(self.curCard.cardid,nextAwakeLv);
    if(self.curCard.awakeData == nil)then
        return;
    end
    local diaNum = math.floor(self.curCard.awakeLv/7);
    diaNum = math.min(diaNum,math.floor(Data.cardAwake.maxLv/7)-1);
    -- for i=1,7 do
    --     local data = DB.getCardAwake(self.curCard.cardid,diaNum*7+i);
    --     self:setLabelString("awake_name"..i,data.name);
    -- end

    --碎片
    local curSoulNum=Data.getSoulsNumById(self.cardDb.cardid)
    local needSoulNum=self.curCard.awakeData.soulnum
    if(isAwakeLvFull)then
        needSoulNum = 0;
    end

    self:setBarPer2("awake_bar_soul",curSoulNum,needSoulNum);
    gShowLabStringCurAndMax(self,"awake_txt_soul",curSoulNum,needSoulNum);

    --需要的觉醒丹和金币
    self:setLabelString("awake_item_num",Data.getItemNum(ITEM_AWAKE).."/"..self.curCard.awakeData.itemnum);
    self:setLabelString("awake_gold",self.curCard.awakeData.goldnum);

    --觉醒阶段
    local awakeLv = self.curCard.awakeLv % 7;
    --木偶
    -- diaNum = 5;
    if(self.muouFlaIndex == nil)then
        self.muouFlaIndex = 0;
    end
    if(self.muouFlaIndex ~= diaNum + 1)then
        if(not self:isWillAwake())then
            self:changeMuou(diaNum+1);
        end
    end
    local callback = function()
        if(self.muouFla)then
            if(self.rec_awake_cardid == self.curCard.cardid and self.rec_awake_lv == self.curCard.awakeLv)then
                --点亮效果
                print("xxxxxxx");
                local activeNo = awakeLv;
                if(self:isWillAwake())then
                    activeNo = 7;
                end
                self:activeMuouOneEffect(activeNo);

            else
                print("yyyyyy");
                self:refreshMuouAll(awakeLv);

            end

        end
    end
    gCallFuncDelay(0.1,self,callback);

    self:setLabelString("awake_name_next",self.curCard.awakeData.name)
    if(isAwakeLvFull)then
        self:setLabelString("txt_next_level1",gGetWords("labelWords.plist","cardawake_fulllv"));
        self:getNode("awake_name_next"):setVisible(false);
    else
        self:setLabelString("txt_next_level1",gGetWords("labelWords.plist","275"));
        self:getNode("awake_name_next"):setVisible(true);
    end
    if(awakeLv == 6)then
        self:setLabelString("txt_btn_awake",gGetWords("btnWords.plist","138"))
    else
        self:setLabelString("txt_btn_awake",gGetWords("btnWords.plist","137"))
    end


    --激活下一级加成
    self:getNode("txt_limit1"):setVisible(false);
    if(isAwakeLvFull==false)then
        local buff = self:getCardAwakeBuff(self.curCard.awakeData.buffid0);
        if(buff)then
            self:setRTFString("txt_limit1",self:getCardAwakeBuffDes(buff.attr_id0,buff.attr_value0,buff.des));
            self:getNode("txt_limit1"):setVisible(true);
        end
        self:getNode("txt_limit2"):setVisible(false);
        local buff = self:getCardAwakeBuff(self.curCard.awakeData.buffid1);
        if(buff)then
            self:setRTFString("txt_limit2",self:getCardAwakeBuffDes(buff.attr_id0,buff.attr_value0,buff.des));
            self:getNode("txt_limit2"):setVisible(true);
        end
    end

    self:resetLayOut();

-- self:getNode("effect_panel1"):layout();
end

function CardInfoPanel:changeMuou(muouIndex)
    self.muouFlaIndex = muouIndex;
    self.muouFla = gCreateFla("ui_cardawake_muou"..(muouIndex),1);
    if(self.muouFla)then
        self:getNode("awake_muou"):removeAllChildren();
        gAddCenter(self.muouFla,self:getNode("awake_muou"));
    end
    self:changeTexture("awake_cur_name","images/ui_word/mai_y_"..self.muouFlaIndex..".png");
end

function CardInfoPanel:isWillAwake()
    if(self.rec_awake_cardid == self.curCard.cardid and self.rec_awake_lv == self.curCard.awakeLv)then
        return self.rec_awake_lv % 7 == 0;
    end
    return false;
end

function CardInfoPanel:activeMuouOneEffect(awakeLv)

    local node = gCreateFlaDislpay("ui_muouxiaoguo_b",0);

    local yuan = cc.Sprite:create("images/ui_cardawake/p_"..self.muouFlaIndex..".png");
    local num = gCreateWordLabelTTF(awakeLv,gFont,20,cc.c3b(0,0,0));
    gAddCenter(num,yuan);
    gReplaceBoneWithNode(node,{"yuan"},yuan)
    self.muouFla:replaceBoneWithNode({"muou",self.muouVars[self.muouFlaIndex][awakeLv],tostring(awakeLv)},node);
    local willAwake = self:isWillAwake();
    self.rec_awake_cardid = 0;
    self.rec_awake_lv = -1;


    --下一级
    local playNext = function()
        -- print("11111");
        if(willAwake)then
            -- print("22222");
            --TODO:觉醒切换木偶
            local curDiaNum = self:getCurAwakeDia();
            self:changeMuou(curDiaNum+1);
            self:refreshMuouAll(0);

            Panel.popUp(PANEL_CARD_UP_QUALITY,self.curCard.cardid,1)
        else
            -- print("33333");
            local node = gCreateFlaDislpay("ui_muouxiaoguo_a",1);
            local yuan = cc.Sprite:create("images/ui_cardawake/p_0.png");
            local num = gCreateWordLabelTTF(awakeLv+1,gFont,20,cc.c3b(0,0,0));
            gAddCenter(num,yuan);
            gReplaceBoneWithNode(node,{"yuan"},yuan)
            self.muouFla:replaceBoneWithNode({"muou",self.muouVars[self.muouFlaIndex][awakeLv+1],tostring(awakeLv+1)},node);
        end
        self.playMuouFla = false;
    end
    gCallFuncDelay(1,self,playNext);
end

function CardInfoPanel:refreshMuouAll(awakeLv)
    local isAwakeLvFull = false;
    if(self.curCard.awakeLv >= Data.cardAwake.maxLv)then
        isAwakeLvFull = true;
    end
    for i=1,7 do
        local node = nil;
        if(i <= awakeLv or isAwakeLvFull)then

            node = cc.Sprite:create("images/ui_cardawake/p_"..(self.muouFlaIndex)..".png");
            local num = gCreateWordLabelTTF(i,gFont,20,cc.c3b(0,0,0));
            gAddCenter(num,node);
        else

            if(i == awakeLv + 1)then
                node = gCreateFlaDislpay("ui_muouxiaoguo_a",1);
                local yuan = cc.Sprite:create("images/ui_cardawake/p_0.png");
                local num = gCreateWordLabelTTF(i,gFont,20,cc.c3b(0,0,0));
                gAddCenter(num,yuan);
                gReplaceBoneWithNode(node,{"yuan"},yuan)
            else
                node = cc.Sprite:create("images/ui_cardawake/p_0.png");
                local num = gCreateWordLabelTTF(i,gFont,20,cc.c3b(0,0,0));
                gAddCenter(num,node);
            end
        end
        self.muouFla:replaceBoneWithNode({"muou",self.muouVars[self.muouFlaIndex][i],tostring(i)},node);
    end
end

function CardInfoPanel:getCurAwakeDia()
    local diaNum = math.floor(self.curCard.awakeLv/7);
    diaNum = math.min(diaNum,math.floor(Data.cardAwake.maxLv/7)-1);
    return diaNum;
end

function CardInfoPanel:getCardAwakeBuff(buffid)
    if(buffid > 0)then
        return DB.getBuffById(buffid);
    end
    return nil;
end

function CardInfoPanel:getCardAwakeBuffDes(attType,value,des)
    -- return gReplaceParam(des,value);
    local word = gGetWords("cardAttrWords.plist","attr"..attType);
    if(word == "")then
        word = "attType"..attType;
    end
    return (word .. "\\w{c=4eff00}+"..value.."%\\");
-- return gReplaceParam(des,"\\w{c=4eff00}+"..value.."%\\"..des);
end

function CardInfoPanel:evtCardAwake(card)

    -- local time1 = os.clock();
    self.playMuouFla = true;
    --换装效果
    local isAwake = false;
    for key,data in pairs(Data.cardAwake.lv)do
        if(data == card.awakeLv)then
            isAwake = true;
            break;
        end
    end
    if(isAwake)then
        local effect=gCreateFla("ui-card-tupo")
        gAddCenter(effect,  self:getNode("awake_effect") )
        -- Panel.popUp(PANEL_CARD_UP_QUALITY,self.curCard.cardid,1)
    else
        local effect=gCreateFla("ui_levelup_guang")
        gAddCenter(effect,  self:getNode("awake_effect") )
    end
    -- local time2 = os.clock();
    -- print("1111111evtCardAwake time offset = "..(time2-time1));
    -- self:setCard(card);
    self:initCardAwake(isAwake);
    -- local time3 = os.clock();
    -- print("222222evtCardAwake time offset = "..(time3-time2));
    self:refreshSouls();
    self:refreshStar();
    if(self.proPanel)then
        self.proPanel:setCard(self.curCard);
    end
    -- local time4 = os.clock();
    -- print("333333evtCardAwake time offset = "..(time4-time3));
end


function CardInfoPanel:enterTreasure(type)
    self.isInTreasure=true
    self:enterCardDetail()

    self.treasurePanel=TreasurePanel.new(self.curCardid,self)
    self:addChild(self.treasurePanel)
    
    if(type==2)then
        self.treasurePanel:onTouchEnded(self.treasurePanel:getNode("btn_upgrade"))
    elseif(type==3)then
        self.treasurePanel:onTouchEnded(self.treasurePanel:getNode("btn_quench"))
    end
end


function CardInfoPanel:enterCardDetail()
    local canPage = self:canPageForAwake();
    self:getNode("btn_pre"):setVisible(canPage);
    self:getNode("btn_next"):setVisible(canPage);
    self:getNode("layer_appear1"):runAction(cc.Sequence:create(
        cc.FadeTo:create(0.2,0),
        cc.Hide:create()
    ));
    self:getNode("btn_batch_strong"):runAction(cc.Sequence:create(
        cc.FadeTo:create(0.2,0),
        cc.Hide:create()
    ));


    if(self.layer_right_pos == nil)then
        self.layer_right_pos = cc.p(self:getNode("layer_right"):getPosition());
    end
    if(self.awake_area2_pos == nil)then
        self.awake_area2_pos = cc.p(self:getNode("awake_area2"):getPosition());
    end
    self:getNode("layer_right"):runAction(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(0.2,cc.p(self.layer_right_pos.x+100,self.layer_right_pos.y)),
                cc.FadeTo:create(0.2,0)
            ),
            cc.Hide:create()
        ));


    self:getNode("btn_wakeup"):runAction(cc.Sequence:create(
        cc.FadeTo:create(0.2,0),
        cc.Hide:create()
    ));
end
--进入觉醒
function CardInfoPanel:enterCardAwake()
    if(self.hasCard == false) then
        return;
    end

    if(toint(self.curCard.level) < toint(Data.cardAwake.needLv))then
        gShowNotice(gGetWords("noticeWords.plist","card_awake_tip",Data.cardAwake.needLv));
        return;
    end

    self.rec_awake_cardid = 0;
    loadFlaXml("ui_cardawake");
    loadFlaXml("ui_card_evolve_effect");
    loadFlaXml("ui_win");



    self:enterCardDetail()
    self.isInAwake = true;
    self:initCardAwake();




    self:getNode("layer_awake"):setVisible(true);
    self:getNode("awake_area1"):setAllChildCascadeOpacityEnabled(true);
    self:getNode("awake_area1"):setOpacity(0);
    self:getNode("awake_area1"):runAction(cc.FadeTo:create(0.2,255));
    self:getNode("awake_area2"):setAllChildCascadeOpacityEnabled(true);
    self:getNode("awake_area2"):setOpacity(0);
    self:getNode("awake_area2"):setPositionX(self.awake_area2_pos.x + 100);
    self:getNode("awake_area2"):runAction(cc.Spawn:create(
        cc.MoveTo:create(0.2,self.awake_area2_pos),
        cc.FadeTo:create(0.2,255)
    ));
end

--从觉醒中放回
function CardInfoPanel:backCardAwake()
    self.isInAwake = false;
    self.isInTreasure=false
    self:getNode("btn_pre"):setVisible(true);
    self:getNode("btn_next"):setVisible(true);
    self:getNode("layer_appear1"):runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.FadeTo:create(0.2,255)
    ));

    if(self.treasurePanel)then
        self.treasurePanel:disapper()
        self.treasurePanel=nil 
        if self.proPanel then
            self.proPanel:setCard(self.curCard) 
        end
    end
    self:getNode("btn_batch_strong"):runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.FadeTo:create(0.2,255)
    ));
    self:getNode("btn_wakeup"):runAction(cc.Sequence:create(
        cc.Show:create(),
        cc.FadeTo:create(0.2,255)
    ));
    self:getNode("layer_right"):runAction(
        cc.Sequence:create(
            cc.Show:create(),
            cc.Spawn:create(
                cc.MoveTo:create(0.2,self.layer_right_pos),
                cc.FadeTo:create(0.2,255)
            )
        ));

    self:getNode("layer_awake"):runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.Hide:create()
    ));
    self:getNode("awake_area1"):setAllChildCascadeOpacityEnabled(true);
    self:getNode("awake_area1"):runAction(cc.FadeTo:create(0.2,0));
    self:getNode("awake_area2"):setAllChildCascadeOpacityEnabled(true);
    self:getNode("awake_area2"):runAction(cc.Spawn:create(
        cc.MoveTo:create(0.2,cc.p(self.awake_area2_pos.x+100,self.awake_area2_pos.y)),
        cc.FadeTo:create(0.2,0)
    ));

end

return CardInfoPanel