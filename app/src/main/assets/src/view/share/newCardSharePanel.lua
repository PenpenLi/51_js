local NewCardSharePanel=class("NewCardSharePanel",UILayer)

function NewCardSharePanel:ctor(cardid,newCard)

    self:init("ui/share/ui_share_getcard.map")
    self._panelTop = true;
    if(newCard == nil)then
        newCard = false;
    end
    print("cardid = "..cardid);
    self.card = Data.getUserCardById(cardid);
    self.cardDb = DB.getCardById(cardid);
    local starNum = self.card.grade;
    local awakeLv = self.card.awakeLv;
    local weaponLv = self.card.weaponLv;
    if(self.card == nil or newCard == true)then
        starNum = self.cardDb.evolve;
        weaponLv = 0;
        awakeLv = 0;
    end
    if(awakeLv == nil)then
        awakeLv = 0;
    end
    self:setLabelString("txt_name",self.cardDb.name);
    self:setLabelString("txt_tip",self.cardDb.mylines);
    self:replaceLabelString("txt_lv",gUserInfo.level);
    self:setLabelString("txt_uname",gUserInfo.name);
    local curServer=gAccount:getCurServer();
    self:setLabelString("txt_server",curServer.name);
    self:changeTexture("flag_country","images/ui_share/country_"..self.cardDb.country..".png");
    local index = getRand(1,6);
    self:changeTexture("flag_tip","images/ui_share/get_card_word"..index..".png");
    if(awakeLv >= 7)then
        local diaNum = math.floor(awakeLv/7);
        for i=1,6 do
            self:changeTexture("star"..i,"images/ui_share/dia.png")
            self:getNode("star"..i):setVisible(i<=diaNum);
        end
    elseif(starNum <= 5)then
        for i=1,6 do
            self:getNode("star"..i):setVisible(i<=starNum);
        end
    end

    self.role = gCreateRoleFla(cardid, self:getNode("bg_role"),1.0,false,"r"..cardid.."_wait",weaponLv,awakeLv);
    if self.role then
        self.role:pause();

        for key,var in pairs(CardPanelData.config) do
            if toint(key) == cardid then
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

    if(self:getNode("share2"))then
        self:getNode("share2"):setVisible(not Module.isClose(SWITCH_SHARE_TWITTER));
    end
    if(self:getNode("share3"))then
        self:getNode("share3"):setVisible(not Module.isClose(SWITCH_SHARE_LINE));
    end

    self:resetLayOut();

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        end
    end
    self:registerScriptHandler(onNodeEvent);

    local node = self:getNode("content");
    local pos = cc.p(node:getPosition());
    local anchor = cc.p(node:getAnchorPoint());
    local show = function()
        print("xxxxx");
        self:setVisible(true);
        node:setScale(1.0);
        node:setPosition(pos);
        node:setAnchorPoint(anchor);
        node:setOpacity(0);
    end
    self:setVisible(false);
    gScreenShotNode(self:getNode("content"),false);
    gCallFuncDelay(0.1,self,show);
end

function NewCardSharePanel:onEnter()
    if self.role then
        self.role:pause();
    end
end

function  NewCardSharePanel:events()
    return {EVENT_ID_GIFT_BAG_GOT}
end


function NewCardSharePanel:dealEvent(event,param)
    if(event==EVENT_ID_GIFT_BAG_GOT)then
        self:initGift()
    end
end

function NewCardSharePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_share" then
        gShare(SHARE_TYPE_CARD);
        -- gShare(self:getNode("content"),"_luan_share_card.png");
    elseif target.touchName=="share1" then
        local data={}
        data.sharePlatform = "sharePlatform1"
        data.desc = gGetWords("shareWords.plist","newCardShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share2" then
        local data={}
        data.sharePlatform = "sharePlatform2"
        data.desc = gGetWords("shareWords.plist","newCardShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share3" then
        local data={}
        data.sharePlatform = "sharePlatform3"
        data.desc = gGetWords("shareWords.plist","newCardShareDesc");
        gShare(self.shareType,data);
    end
end

return NewCardSharePanel