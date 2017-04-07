local CardItem=class("CardItem",UILayer)

function CardItem:ctor()

end

function CardItem:initPanel()
    if(self.inited==true)then
        return
    end

    self.inited=true
    self:init("ui/ui_role_item.map")
    self.touchNode=cc.Node:create()
    self:getNode("star_container"):setVisible(false)
    self.starContainerX= self:getNode("star_container"):getPositionX()

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        end
    end
    self:registerScriptHandler(onNodeEvent);

    self:setTouchCDTime("btn_comp_card",2);

end

function CardItem:onEnter()
    if self.role then
        self.role:pause();
    end
end

function CardItem:setBaseData(hasCard,cardid)
    self.hasCard = hasCard;
    self.curCardid = cardid;
end

-- function  CardItem:playLevelUp()
--     if(self.levelUpEffect==nil)then
--         loadFlaXml("ui_card_exp_effect")
--         self.levelUpEffect=FlashAni.new()
--         gAddCenter(self.levelUpEffect,self:getNode("icon"))
--         self.levelUpEffect:setLocalZOrder(100)
--     end

--     local function callback()
--         self.levelUpEffect:setVisible(false)
--     end
--     self.levelUpEffect.curAction=""
--     self.levelUpEffect:playAction("ui-card-shengji",callback)
--     self.levelUpEffect:setVisible(true)

-- end

-- function  CardItem:playAddEffect()
--     if(self.addEffect==nil)then
--         loadFlaXml("ui_card_exp_effect")
--         self.addEffect=FlashAni.new()
--         gAddCenter(self.addEffect,self:getNode("icon"))
--         self.addEffect:setLocalZOrder(100)
--     end

--     local function callback()
--         self.addEffect:setVisible(false)
--     end

--     self.addEffect.curAction=""
--     self.addEffect:playAction("ui-card-jiacheng",callback)
--     self.addEffect:setVisible(true)

-- end


function  CardItem:setCardBase(_db,weaponLv,awakeLv)
    self.cardDb=_db
    self.weaponLv = weaponLv or 0;
    self.awakeLv = awakeLv or 0;
    self:getNode("flag_super"):setVisible(toint(_db.supercard)== 1);
    if(toint(_db.supercard)== 1)then
        local fla = gCreateFla("card_s_effect",1);
        self:replaceNode("flag_super",fla);
    end
    -- self:showStar(self.cardDb.evolve)
    Icon.setCardCountry(self:getNode("country"),self.cardDb.country);
    
    -- self:setLabelString("txt_name",_db.name,nil,true)
    -- gCreateRoleNameQua(self:getNode("txt_name"),self.cardDb.cardid);
    self:changeTexture("icon_card_type","images/ui_public1/card_type_".._db.type..".png")

    -- self:refreshQua();
    -- Icon.setIcon(self.cardDb.cardid,self:getNode("icon"),card.quality)
    
    self.role = gCreateRoleFla(self.cardDb.cardid, self:getNode("icon"),1.0,false,"r"..self.cardDb.cardid.."_wait",weaponLv,awakeLv);
    Scene.addFlaTextureCache("r"..self.cardDb.cardid.."_wait",weaponLv,awakeLv)
    if self.role then
        self.role:pause();


        for key,var in pairs(CardPanelData.config) do
            if toint(key) == _db.cardid then
                if var.offset then
                    local pos = string.split(var.offset,",");
                    self.role:setPosition(cc.p(self.role:getPositionX() + pos[1],self.role:getPositionY() + pos[2]));
                end

                if var.scale then
                    self.role:setScale(var.scale);
                end
            end
        end
    end



    self:getNode("layer_comp_card"):setVisible(false);
    self:getNode("layer_chip_num"):setVisible(false);
end


function  CardItem:setCardDb(_db,isCache)
    --_db为nil会造成程序中断
    if nil == _db then
        print("_db in setCardBase is nil")
        return
    end
    self:initPanel()
    self:setCardBase(_db)
    self:showStar(_db.evolve);
    self:refreshQua();
    -- self:getNode("equip_panel"):setVisible(false)
    _db.needRefresh = true;
    self:refreshCardDb(_db);

    if(isCache)then
        Scene.addCardItemInCache(_db.cardid,self);
    end
end

function CardItem:refreshCardDb(_db)
    local userSoul = Data.getUserSoul(_db.cardid);
    if(userSoul and userSoul.needRefresh)then
        userSoul.needRefresh = false;
        _db.needRefresh = true;
    end
    if(_db.needRefresh == false)then
        return;
    end
    _db.needRefresh = false;
    print("refreshCardDb cardid = ".._db.cardid);
    local curNum= Data.getSoulsNumById(_db.cardid)
    local needNum=DB.getNeedInitSoulNum(_db.evolve-1)
    self.needSoulNum=needNum
    self.curSoulNum=curNum
    self:setLabelString("txt_num",curNum.."/"..needNum)

    local per=curNum/needNum
    self:setBarPer("bar",per)

    -- Icon.setIcon(_db.cardid,self:getNode("icon"))
    self:getNode("txt_lv"):setVisible(false);
    DisplayUtil.setGray(self:getNode("layer_bg"),true)

    -- self:getNode("equip_panel"):setVisible(false)

    --招募
    if(curNum>=needNum)then
        self:getNode("bar_bg"):setVisible(false)
        self:getNode("layer_comp_card"):setVisible(true)
        local fla = gCreateFla("word_zhaomu",1);
        self:replaceNode("btn_comp_card_ani",fla);
    end

end

function  CardItem:setLazyCardDb(_db)
    self.lazyCardDb=_db
    local curNum= Data.getSoulsNumById(_db.cardid)
    local needNum=DB.getNeedInitSoulNum(_db.evolve-1)
    self.needSoulNum=needNum
    self.curSoulNum=curNum
    self:setLazyCardDbCallBack();
end

function CardItem:setLazyCardDbCallBack()
    Scene.addLazyFunc(self,self.setCardDbLazyCalled,"carditem")
end

function  CardItem:setCardDbLazyCalled()
    self:setCardDb(self.lazyCardDb,true)
    gRedposRefreshDirty = true;
end

function  CardItem:setLazyUserCard(card,cardDb)
    self.lazyCard=card
    self.lazyCardDb=cardDb
    self:setLazyUserCardCallBack();
end

function CardItem:setLazyUserCardCallBack()
    Scene.addLazyFunc(self,self.setUserCardLazyCalled,"carditem")
end

function  CardItem:setUserCardLazyCalled()
    --print("setUserCardLazyCalled")
    self:setUserCard(self.lazyCard,self.lazyCardDb,true)
    -- RedPoint.update(true);
    gRedposRefreshDirty = true;
    RedPoint.bolCardViewDirty = true;
end

function  CardItem:setUserCard(card,cardDb,isCache)
    self:initPanel() 
    self:setCardBase(cardDb,card.weaponLv,card.awakeLv)
    card.needRefresh = true;
    self:refreshUserCard(card);
    -- self.curCard=card
    -- self:showStar(self.curCard.grade,self.curCard.awakeLv)
    -- self:refreshSoul();
    -- self:getNode("bar_bg"):setVisible(false)
    -- self:setLabelAtlas("txt_lv",card.level)
    if self.kuangAni == nil then
        self.kuangAni = FlashAni.new();
        self.kuangAni:playActDelay(math.random(1,30),"ui_kapaikuang",1);
        gAddChildByAnchorPos(self:getNode("card_frame"),self.kuangAni,cc.p(0.5,0.5),cc.p(0,0));
    end
    if(isCache)then
        Scene.addCardItemInCache(cardDb.cardid,self);
    end
end

function CardItem:refreshUserCard(card)

    local userSoul = Data.getUserSoul(card.cardid);
    if(userSoul and userSoul.needRefresh)then
        userSoul.needRefresh = false;
        card.needRefresh = true;
    end

    if(card.needRefresh == false)then
        return;
    end
    card.needRefresh = false;
    print("refreshUserCard cardid = "..card.cardid);
    self.curCard=card;
    self:showStar(self.curCard.grade,self.curCard.awakeLv);
    self:refreshSoul();
    self:refreshQua();
    self:getNode("bar_bg"):setVisible(false)
    self:getNode("layer_comp_card"):setVisible(false)
    self:setLabelAtlas("txt_lv",card.level)
    DisplayUtil.setGray(self:getNode("layer_bg"),false)

    if(self.awakeLv ~= self.curCard.awakeLv or self.weaponLv ~= self.curCard.weaponLv)then
        self.weaponLv = self.curCard.weaponLv;
        self.awakeLv = self.curCard.awakeLv;
        self:refreshRole(self.weaponLv,self.awakeLv);
        print("######## refreshRoleFla");
    end
end

-- function CardItem:showEquip(idx)
--     local node=self:getNode("equip"..idx)

--     local equipId=self.cardDb["equid"..(idx-1)]
--     local qua= self.curCard.equipQuas[idx-1]


--     local equipment= DB.getEquipment(equipId,qua)
--     if(equipment)then
--         Icon.setEquipmentIcon(equipment.icon,node,qua)
--     end

-- end

function CardItem:refreshData()
    -- print("refreshData");
    if self.curCard then
        self:refreshUserCard(Data.getUserCardById(self.curCard.cardid));
        -- self:setUserCard(self.curCard,self.cardDb)
    elseif(self.cardDb)then
        self:refreshCardDb(self.cardDb);
    end
end

function CardItem:showStar(num,awakeLv)
    CardPro:showStarLeftToRight(self,num,awakeLv)
end

function CardItem:refreshQua()
    gShowRoleName(self,"txt_name",self.cardDb.name,self.cardDb.cardid);
    Icon.setCardBg(self:getNode("bg"),self.cardDb.cardid);
    Icon.setCardNameBg(self:getNode("bg_name"),self.cardDb.cardid);
end

function CardItem:refreshSoul()
    local curSoulNum=Data.getSoulsNumById(self.cardDb.cardid)
    -- local needSoulNum=DB.getNeedSoulNum(self.curCard.grade)
    local needSoulNum=DB.getNeedSoulForAll(self.curCard.grade,self.curCard.cardid,self.curCard.awakeLv)
    gShowLabStringCurAndMax(self,"txt_chip_num",curSoulNum,needSoulNum);
    self:getNode("layer_chip_num"):setVisible(true);    
end

function CardItem:refreshRole(weaponLv,awakeLv)
    local oldPos = cc.p(0,0);
    local oldScale = 1;
    local isSave = false;
    if(self.role)then
        isSave = true;
        oldPos = cc.p(self.role:getPosition());
        oldScale = self.role:getScale();
    end
    self.role = gCreateRoleFla(self.cardDb.cardid, self:getNode("icon"),1.0,false,"r"..self.cardDb.cardid.."_wait",weaponLv,awakeLv);
    self.role:pause();
    Scene.addFlaTextureCache("r"..self.cardDb.cardid.."_wait",weaponLv,awakeLv)

    if(isSave)then
        self.role:setPosition(oldPos);
        self.role:setScale(oldScale);
    end    
end

function CardItem:onTouchEnded(target)

    if(target.touchName=="bg")then

        if self.onChooseCard then
            self.onChooseCard(self.cardDb.cardid);
        end
        -- gModifyExistNodeAnchorPoint(self,cc.p(0.5,-0.5));
        -- self:stopAllActions();
        -- self:setVisible(false);
        -- local item = Scene.cardItemCache[self.cardDb.cardid]
        -- item.touchEnable = false;
        if(not gIsAndroid())then
            local item = CardItem.new();
            item.touchEnable = false;
            if self.curCard then
                item:setUserCard(self.curCard,self.cardDb);
            else
                item:setCardDb(self.cardDb);
            end
            item:setAllChildCascadeOpacityEnabled(true);
            -- item:setAnchorPoint(cc.p(0.5,-0.5));
            item:setPosition(gGetPositionInDesNode(gPanelLayer,self));
            gPanelLayer:addChild(item,100);
            gModifyExistNodeAnchorPoint(item,cc.p(0.5,-0.5));

            local clickEffect = gCreateFla("ui_kapai_dianjiquan");
            clickEffect:setPosition(item:getPosition());
            gPanelLayer:addChild(clickEffect,101);

            -- gAddChildByAnchorPos(item,clickEffect,cc.p(0.5,-0.5),cc.p(0,0));

            item:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.2,1.1),
                cc.Spawn:create(
                    cc.ScaleTo:create(0.3,1.3),
                    -- cc.OrbitCamera:create(0.3,1,0,0,90,0,0),
                    -- cc.RotateTo:create(0.3,  cc.vec3(0,90,0)),
                    cc.FadeOut:create(0.3)
                ),
                cc.RemoveSelf:create()
            )
            );
        end

    elseif(target.touchName=="btn_comp_card")then
        Net.sendCardRecurit(self.cardDb.cardid)

    end

end
return CardItem