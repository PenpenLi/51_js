local CardUpQualityPanel=class("CardUpQualityPanel",UILayer)

--type 0--升星   1--觉醒
function CardUpQualityPanel:ctor(cardid,type)
    self:init("ui/ui_card_upquality.map")
    self.hideMainLayerInfo=true
    if(type == nil)then
        type = 0;
    end
    self.type = type;
    local card=Data.getUserCardById(cardid)
    self.card=clone(card)
    for key, var in pairs(CardPro.cardPros) do
        self.card[var ]=math.rint( self.card[var ])
    end
    self:roleDisplayAction(cardid)
    card.grade=card.grade - 1
    CardPro.setCardAttr(card)
    self.oldCard = clone(card)

    for key, var in pairs(CardPro.cardPros) do
        self.oldCard[var ]=math.rint( self.oldCard[var ])
    end
    card.grade=card.grade + 1
    CardPro.setCardAttr(card)
    
    local cardDb=DB.getCardById(cardid)
    self:setLabelString("txt_name",cardDb.name,nil,true)

    self:infoPanel(cardid)
    if gIsAndroid()==false then
        self:initShadowRole(cardid,weaponLv,awakeLv)
    end

    local function onNodeEvent(event)
        if event == "enter" then
          self:onEnter()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    self:setAllChildCascadeOpacityEnabled(true)
    self:setOpacity(0)
    self:runAction(cc.FadeIn:create(0.2))
    self._panelTop=true
    self.initTime = socket.gettime()

    self.delay = 2.0;
    local show = function()
        gCreateTouchScreenTip(self);
    end
    gCallFuncDelay(self.delay,self,show);

    self:hideCloseModule();
end

function CardUpQualityPanel:hideCloseModule()
    self:getNode("btn_share"):setVisible(not Module.isClose(SWITCH_SHARE));
end

function CardUpQualityPanel:onEnter()

end

function CardUpQualityPanel:onTouchEnded(target)

    if socket.gettime() - self.initTime < self.delay then
        return
    end

    if target.touchName == "btn_share"then
        Panel.popUpVisible(PANEL_SHARE_NEWCARD,self.card.cardid);  
    else
        Panel.popBack(self:getTag())
    end

end

function CardUpQualityPanel:roleDisplayAction(cardid)
    loadFlaXml("ui_chouka_shengxing")
    local upStarBg = FlashAni.new()
    upStarBg:playAction("ui_shengxing_b", nil, nil, 0)
    upStarBg:setOpacity(0)
    upStarBg:setScale(0.3)
    local bgScale  = cc.ScaleTo:create(0.5, 1.0)
    local bgFadeIn = cc.FadeIn:create(0.5)
    local bgSpawn  = cc.Spawn:create(bgScale, bgFadeIn)
    upStarBg:runAction(bgSpawn)
    self:replaceNode("halo_flag",upStarBg)

    loadFlaXml("r"..cardid)
    local roleNode = gCreateRoleFla(cardid, self:getNode("role_container"),1,nil,nil,self.card.weaponLv,self.card.awakeLv)
    roleNode:setOpacity(0)
    roleNode:setScale(0.3)
    local roleScaleTo  = cc.ScaleTo:create(0.3, 1.0)
    local roleFadeIn = cc.FadeIn:create(0.3)
    local roleSpawn  = cc.Spawn:create(roleScaleTo, roleFadeIn)
    roleNode:runAction(roleSpawn)
    
    local delayFg  = cc.DelayTime:create(0.3)
    local durtime  = 0
    local callFuncFg = cc.CallFunc:create(function()
        local upStarFg = FlashAni.new()
        local flaName = "ui_sx_xingxing";
        if(self.type == 0)then
            flaName = "ui_sx_xingxing";
        elseif(self.type == 1)then
            flaName = "ui_juexing";
        end
        durtime  = upStarFg:playAction(flaName, nil, nil, 0)
        self:replaceNode("up_star_flag",upStarFg)
        self:getNode("up_star_flag"):setVisible(true)
    end)

    local delayLayer = cc.DelayTime:create(2.0)
    local callFuncMove = cc.CallFunc:create(function()
        self:getNode("animation_container"):runAction(cc.EaseBackOut:create(cc.MoveBy:create(0.5, cc.p(-self:getContentSize().width / 4, 0))))
        self:infoPanelAction()
        self:initPanelTxtAction()
    end)

    self:runAction(cc.Sequence:create(delayFg, callFuncFg, delayLayer, callFuncMove))
end

function CardUpQualityPanel:infoPanel()
    self:getNode("down_panel"):setVisible(false);
    self:getNode("awake_panel"):setVisible(false);
    self:getNode("star_container1"):setVisible(false);
    self:getNode("star_container2"):setVisible(false);
    self:getNode("awake_star"):setVisible(false);
    self:getNode("info_panel"):setOpacity(0)
    if(self.type == 0)then
        self:changeTexture("flag_title","images/ui_word/shengxing.png");
        self:getNode("down_panel"):setVisible(true);
        self:setLabelString("txt_hp",self.oldCard.hp)
        self:setLabelString("txt_phy_attack",self.oldCard.physicalAttack) 
        self:setLabelString("txt_toughness",self.oldCard.toughness)
        self:setLabelString("txt_phy_def",self.oldCard.physicalDefend)
        self:setLabelString("txt_magic_def",self.oldCard.magicDefend)
        self:setLabelString("txt_hit",self.oldCard.hit)
        self:setLabelString("txt_dodge",self.oldCard.dodge)
        self:setLabelString("txt_critical",self.oldCard.critical)
        
        for i = 1, 8 do
            local panelTxt = self:getNode("panel_txt"..i)
            if nil ~= panelTxt then
                panelTxt:setOpacity(0)
            end
        end

        self:getNode("star_container1"):setVisible(true);
        self:getNode("star_container2"):setVisible(true);
        local itemShowTime=0.3
        for i=self.card.grade, 5 do
            if(i<=self.card.grade)then
                self:getNode("icon_star"..i):setOpacity(0)
                self:getNode("icon_star"..i):setScale(5)
                self:getNode("icon_star"..i):setVisible(true)
                local fadeIn=   cc.FadeIn:create(0.1)
                local scaleTo=cc.EaseBackOut:create( cc.ScaleTo:create(itemShowTime,1))
                local delay=   cc.DelayTime:create(itemShowTime*(i-1))
                self:getNode("icon_star"..i):runAction( cc.Sequence:create(delay,cc.Spawn:create(fadeIn,scaleTo) ))
            else
                self:getNode("icon_star"..i):setVisible(false)
            end
        end

    elseif(self.type == 1)then
        loadFlaXml("ui_juexing_effect");
        self:changeTexture("flag_title","images/ui_word/wake_ok.png");
        self:getNode("awake_panel"):setVisible(true);
        self:getNode("awake_star"):setVisible(true);
        local itemShowTime=0.3
        local awakeId = gParseCardAwakeDiaNum(self.card.awakeLv);
        print("awakeLv = "..self.card.awakeLv);
        print("awakeId = "..awakeId);
        
        for i=1, 6 do
            self:getNode("icon_dia_bg"..i):setVisible(false)
            self:getNode("icon_dia"..i):setVisible(false)
        end
        local maxid=Data.cardAwake.maxLv/7
        
        for i=1, maxid do
            self:getNode("icon_dia_bg"..i):setVisible(true)
            self:getNode("icon_dia"..i):setVisible(true)
        end
        self:resetLayOut()
        
        for i=awakeId, 6 do
            if(i<=awakeId)then
                self:getNode("icon_dia"..i):setOpacity(0)
                self:getNode("icon_dia"..i):setScale(5)
                self:getNode("icon_dia"..i):setVisible(true)
                local fadeIn=   cc.FadeIn:create(0.1)
                local scaleTo=cc.EaseBackOut:create( cc.ScaleTo:create(itemShowTime,1))
                local delay=   cc.DelayTime:create(itemShowTime*(i-1))
                self:getNode("icon_dia"..i):runAction( cc.Sequence:create(delay,cc.Spawn:create(fadeIn,scaleTo) ))
            else
                self:getNode("icon_dia"..i):setVisible(false)
            end
        end
        local awakeData = DB.getCardAwake(self.card.cardid,self.card.awakeLv);
        local buffid = {"buffid0","buffid1"};
        local value1 = 0;
        local value2 = 0;
        for key,var in pairs(buffid)do
            local buff = DB.getBuffById(awakeData[var]);
            if(buff)then
                if(buff.attr_id0 == 99)then
                    value1 = buff.attr_value0;
                elseif(buff.attr_id0 == 71)then
                    value2 = buff.attr_value0;
                end
            end
        end
        self:setLabelString("txt_awake_hp2","+"..value1.."%")
        self:setLabelString("txt_awake_phy_attack2","+"..value1.."%")
        self:setLabelString("txt_awake_phy_def2","+"..value1.."%")
        self:setLabelString("txt_awake_magic_def2","+"..value1.."%")
        self:setLabelString("txt_awake_hit2","+"..value2.."%")
        for i = 1, 5 do
            local panelTxt = self:getNode("panel_awake_txt"..i)
            if nil ~= panelTxt then
                panelTxt:setOpacity(0)
            end
        end
    end
end

function CardUpQualityPanel:infoPanelAction()
    local fadeIn = cc.FadeIn:create(0.2)
    local moveBy = cc.MoveBy:create(0.2, cc.p( self:getContentSize().width / 15, 0))
    local easeBackOut = cc.EaseBackOut:create(moveBy)
    local spawn  = cc.Spawn:create(fadeIn, easeBackOut)
    self:getNode("info_panel"):runAction(spawn)
end

function CardUpQualityPanel:initShadowRole(cardid,weaponLv,awakeLv)
    local panelSize = self:getContentSize()
    -- local roleShadowFla = gCreateFla("r"..cardid.."_wait")
    local node = cc.Node:create();
    local roleShadowFla = gCreateRoleFla(cardid,node,1.0,false,nil,weaponLv,awakeLv);
    roleShadowFla:setChildShaderName(Shader.FLA_SHADOW_SHADER)
    roleShadowFla:pause()
    local rect = roleShadowFla:getBoundingBox()
    roleShadowFla:setAnchorPoint(cc.p(0, 0))
    roleShadowFla:setPosition(0-rect.x, 0-rect.y)
    local roleRenderTexture = cc.RenderTexture:create(math.ceil(rect.width), math.ceil(rect.height))
    roleRenderTexture:beginWithClear(0, 0, 0, 0)
    roleShadowFla:visit()
    roleRenderTexture:endToLua()

    local lRoleShadowSprite = cc.Sprite:createWithTexture(roleRenderTexture:getSprite():getTexture())
    lRoleShadowSprite:getTexture():setAntiAliasTexParameters()
    lRoleShadowSprite:setAnchorPoint(cc.p(0.5,0))
    lRoleShadowSprite:setFlippedY(true)
    lRoleShadowSprite:setOpacity(120) --178
    lRoleShadowSprite:setScale(2.7)
    self:getNode("l_shadow_role"):setPosition(panelSize.width * 0.05, -panelSize.height * 0.85)
    gAddCenter(lRoleShadowSprite,self:getNode("l_shadow_role"))


    local rRoleShadowSprite = cc.Sprite:createWithTexture(lRoleShadowSprite:getTexture())
    rRoleShadowSprite:getTexture():setAntiAliasTexParameters()
    rRoleShadowSprite:setAnchorPoint(cc.p(0.5,0))
    rRoleShadowSprite:setFlippedY(true)
    rRoleShadowSprite:setOpacity(120) --178
    rRoleShadowSprite:setScale(2.7)
    rRoleShadowSprite:setRotation3D(cc.vec3(0,-180,0))
    self:getNode("r_shadow_role"):setPosition(panelSize.width * 0.95, -panelSize.height * 0.85)
    gAddCenter(rRoleShadowSprite,self:getNode("r_shadow_role"))
end

function CardUpQualityPanel:initPanelTxtAction()
    local delay = 0.1
    local inteval = 0.1
    if(self.type == 0)then
        --升星
        for i = 1, 8 do
            local panelTxt = self:getNode("panel_txt"..i)
            if nil ~= panelTxt then
                local delayTime = cc.DelayTime:create((i-1) * delay)
                local callfun   = cc.CallFunc:create(function()                        
                    self:updateLabelAction(i, self.oldCard, self.card)
                end)
                local fadeIn    = cc.FadeIn:create(inteval)
                panelTxt:runAction(cc.Sequence:create(delayTime, callfun, fadeIn))
            end
        end
    elseif self.type == 1 then
        --觉醒
        for i = 1, 5 do
            local panelTxt = self:getNode("panel_awake_txt"..i)
            if nil ~= panelTxt then
                local delayTime = cc.DelayTime:create((i-1) * delay)
                local fadeIn    = cc.FadeIn:create(inteval)
                panelTxt:runAction(cc.Sequence:create(delayTime, fadeIn))
            end
        end
    end
end

function CardUpQualityPanel:updateLabelAction(i, oldCard, card)
    if i == 1 then
        self:updateLabelChange("txt_hp2",oldCard.hp,card.hp)
    elseif i == 2 then
        self:updateLabelChange("txt_phy_attack2",oldCard.physicalAttack,card.physicalAttack)
    elseif i == 3 then
        self:updateLabelChange("txt_phy_def2",oldCard.physicalDefend,card.physicalDefend)
    elseif i == 4 then
        self:updateLabelChange("txt_magic_def2",oldCard.magicDefend,card.magicDefend)
    elseif i == 5 then
        self:updateLabelChange("txt_hit2",oldCard.hit,card.hit)
    elseif i == 6 then
        self:updateLabelChange("txt_dodge2",oldCard.dodge,card.dodge)
    elseif i == 7 then
        self:updateLabelChange("txt_critical2",oldCard.critical,card.critical)
    elseif i == 8 then
        self:updateLabelChange("txt_toughness2",oldCard.toughness ,card.toughness)
    end
end



return CardUpQualityPanel