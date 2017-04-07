local NewCardPanel=class("NewCardPanel",UILayer)
local uiControlDelayTime = 1.3
local newCardPanelType =
    {
        NEW_CARD = 0,
        CARD_TO_SOUL = 1
    }

function NewCardPanel:ctor(item,callback)
    self:init("ui/ui_get_new_card.map")
    self.isBlackBgVisible=false
    self.hideMainLayerInfo=true
    self.callback=callback
    local cardid = 0;
    local isSoulID = math.floor(item.id  / 100000)
    if isSoulID == 1 then
        cardid = item.id % 100000
        self.type = newCardPanelType.CARD_TO_SOUL
    else
        cardid=item.id
        self.type = newCardPanelType.NEW_CARD
    end
    loadFlaXml("ui_chouka")
    loadFlaXml("r"..cardid)

    local cardDb=DB.getCardById(cardid)
    CardPro.showStar6(self,cardDb.evolve)
    self:setLabelString("txt_name",cardDb.name, nil, true)
    self:initTitle(item.num)
    self:loadBgFla()
    self:roleAppearAction(cardid)
    
    if gIsAndroid()==false then
        self:roleShadowAction(cardid)
    end
    self.cardid = cardid;

    self._panelTop=true

    if Guide.isForceGuiding() then
        if cardid == 10030 then
            gPlayTeachSound("v45.wav",true);
        elseif cardid == GUID_CARDID then
            gPlayTeachSound("v46.wav",true);
        end
    end

    self.initTime = socket.gettime()

    self.delay = 1.5;
    local show = function()
        gCreateTouchScreenTip(self);
    end
    gCallFuncDelay(self.delay,self,show);
    self:hideCloseModule();
end

function NewCardPanel:hideCloseModule()
    local platform = gGetCurPlatform();
    if  platform == CHANNEL_ANDROI_EFUNENCN or platform == CHANNEL_ANDROI_EFUNENCN_LY or platform == CHANNEL_IOS_EFUN_CN_EN then
        self:getNode("btn_share"):setVisible(false)
        self:getNode("btn_share2"):setVisible(not Guide.isGuiding() and not Module.isClose(SWITCH_SHARE));
    else
        self:getNode("btn_share"):setVisible(not Guide.isGuiding() and not Module.isClose(SWITCH_SHARE));
        self:getNode("btn_share2"):setVisible(false)
    end
end

function NewCardPanel:onUILayerExit()
    if nil ~= self.super then
        self.super:onUILayerExit()
    end

    if nil ~= self.lastSoundId then
        gStopEffect(self.lastSoundId)
    end
end

-- function NewCardPanel:onPopback()
--     if(self.callback)then
--         self.callback()
--     end
-- end


function NewCardPanel:onTouchEnded(target)
    if socket.gettime() - self.initTime < self.delay then
        return
    end
    print("target.touchName = "..target.touchName);
    if target.touchName == "btn_share" or target.touchName == "btn_share2" then
        Panel.popUpVisible(PANEL_SHARE_NEWCARD,self.cardid,true);

    elseif  target.touchName=="level_up_bg"then

        if(self.callback)then
            self.callback()
        end

        local stackPanel = Panel.getTopPanel(Panel.popStack)
        if nil ~= stackPanel and stackPanel.__panelType == PANEL_CARD then
            stackPanel:setNeedRfresh(false)
        end
        local cardid = self.cardid
        local panelType = self.type
        Panel.popBack(self:getTag())
        if panelType == newCardPanelType.NEW_CARD and 
           Data.shouldCommentAppStore(APPSTORE_COMMENT_NEWCARD,cardid) then
           Panel.popUpVisible(PANEL_APPSTORE_CONFIRM,APPSTORE_COMMENT_NEWCARD,nil,true)
        end
    end
end

function NewCardPanel:roleAppearAction(cardid)
    local role = gCreateFla("r"..cardid.."_wait",1)
    local shadow=cc.Sprite:create("images/battle/shade.png")
    if nil ~= shadow then
        shadow:setScaleY(0.5)
        role:addChild(shadow,-1)
    end
    role:setOpacity(0)
    role:setScale(0.7)
    local panelSize = self:getContentSize()
    role:setPosition(cc.p(panelSize.width / 2, -panelSize.height * 0.7))
    self:addChild(role, 3)

    local delay  = cc.DelayTime:create(1)
    local callFunc = cc.CallFunc:create(function () 
            if not Guide.isForceGuiding() then
                if nil ~= self.lastSoundId then
                    gStopEffect(self.lastSoundId)
                end
                if isBanshuReview() == false then
                    self.lastSoundId = gPlayEffect("sound/card/"..cardid..".mp3")
                end
            end
    end)
    local fadeTo = cc.FadeTo:create(0.05, 0.2)
    local scaleTo = cc.ScaleTo:create(0.05, 1.0)
    local spawn   = cc.Spawn:create(fadeTo, scaleTo)
    local moveBy  = cc.MoveBy:create(0.15, cc.p(0, panelSize.height * 0.07))
    local fadeIn = cc.FadeIn:create(0.15)
    local easeBackOut = cc.EaseBackOut:create(moveBy)
    local spawn2 = cc.Spawn:create(fadeIn, easeBackOut)
    role:runAction(cc.Sequence:create(delay, callFunc, spawn, spawn2))
end

function NewCardPanel:roleShadowAction(cardid)
    local panelSize = self:getContentSize()
    local roleShadowFla = gCreateFla("r"..cardid.."_wait", 1)
    roleShadowFla:setChildShaderName(Shader.FLA_SHADOW_SHADER)
    roleShadowFla:pause()
    local rectFla = roleShadowFla:getBoundingBox()
    roleShadowFla:setAnchorPoint(cc.p(0, 0))
    roleShadowFla:setPosition(0-rectFla.x, 0-rectFla.y)

    local roleRenderTexture = cc.RenderTexture:create(math.ceil(rectFla.width), math.ceil(rectFla.height))
    roleRenderTexture:setAnchorPoint(cc.p(0,0))
    roleRenderTexture:setPosition(0, 0)
    roleRenderTexture:beginWithClear(0, 0, 0, 0)
    roleShadowFla:visit()
    roleRenderTexture:endToLua()

    local lRoleShadowSprite = cc.Sprite:createWithTexture(roleRenderTexture:getSprite():getTexture())
    lRoleShadowSprite:getTexture():setAntiAliasTexParameters()
    lRoleShadowSprite:setAnchorPoint(cc.p(0.5,0))
    lRoleShadowSprite:setFlippedY(true)
    lRoleShadowSprite:setOpacity(120) --178
    lRoleShadowSprite:setScale(2.7)
    self:getNode("l_shadow_role"):setPosition(-panelSize.width * 0.7, -panelSize.height * 0.85)
    gAddCenter(lRoleShadowSprite,self:getNode("l_shadow_role"))


    local rRoleShadowSprite = cc.Sprite:createWithTexture(lRoleShadowSprite:getTexture())
    rRoleShadowSprite:getTexture():setAntiAliasTexParameters()
    rRoleShadowSprite:setAnchorPoint(cc.p(0.5,0))
    rRoleShadowSprite:setFlippedY(true)
    rRoleShadowSprite:setOpacity(120) --178
    rRoleShadowSprite:setScale(2.7)
    rRoleShadowSprite:setRotation3D(cc.vec3(0,-180,0))
    self:getNode("r_shadow_role"):setPosition(panelSize.width * 1.7, -panelSize.height * 0.85)
    gAddCenter(rRoleShadowSprite,self:getNode("r_shadow_role"))


    local delay = cc.DelayTime:create(uiControlDelayTime)
    local show  = cc.Show:create()

    local lMove = cc.MoveBy:create(0.3, cc.p(panelSize.width * 0.7 , 0))
    local lEaseBackOut = cc.EaseBackOut:create(lMove)
    lRoleShadowSprite:runAction(cc.Sequence:create(delay, show, lEaseBackOut))

    local rMove = cc.MoveBy:create(0.3, cc.p(-panelSize.width * 0.7, 0))
    local rEaseBackOut = cc.EaseBackOut:create(rMove)
    rRoleShadowSprite:runAction(cc.Sequence:create(delay, show, rEaseBackOut))
end

function NewCardPanel:loadBgFla()
    local aniGroup = FlashAniGroup.new()
    aniGroup:addFlashAni("ui_chouka",true,0,nil)
    aniGroup:addFlashAni("ui_chouka_b",false,0,nil)
    aniGroup:play()
    self:replaceNode("halo_flag",aniGroup)

    local lightRay = gCreateFla("ui_chouka_baixian", -1)
    lightRay:setAnchorPoint(cc.p(0.5, 0.5))
    gAddCenter(lightRay,self:getNode("lightRay_container"))
end

function NewCardPanel:initTitle(num)
    if self.type == newCardPanelType.CARD_TO_SOUL then
        self:getNode("panel_soul_card"):setVisible(true)
        self:getNode("panel_new_card"):setVisible(false)
        self:setRTFString("txt_soul_card", gGetWords("labelWords.plist","lab_get_souls_by_card",num))
    else
        self:getNode("panel_soul_card"):setVisible(false)
        self:getNode("panel_new_card"):setVisible(true)
    end
end

function NewCardPanel:processAppStoreComment(type,cardid)
    if (type == newCardPanelType.NEW_CARD) and 
       (gUserInfo.vipsc > 0) and 
       (not Data.appsComment) and 
       (cardid == 10013) then
       --弹框
    end
end

return NewCardPanel