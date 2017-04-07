local PetSharePanel=class("PetSharePanel",UILayer)

function PetSharePanel:ctor(petid)

    self:init("ui/share/ui_share_getcard.map")
    self._panelTop = true;

    self.pet = Data.getUserPetById(petid);
    local petDb=DB.getPetById(petid)
    self:setLabelString("txt_name",petDb.name);
    self:setLabelString("txt_tip",petDb.des);
    local awakeLv = Pet.getPetAwakeLv(petid)
    if awakeLv > 0 then
        for i=1,6 do
            self:changeTexture("star"..i,"images/ui_share/dia.png")
            self:getNode("star"..i):setVisible(i<=awakeLv)
        end
    else
        for i=1,6 do
            self:getNode("star"..i):setVisible(i<=self.pet.grade);
        end
    end

    self:replaceLabelString("txt_lv",gUserInfo.level);
    self:setLabelString("txt_uname",gUserInfo.name);
    local curServer=gAccount:getCurServer();
    self:setLabelString("txt_server",curServer.name);

    local index = getRand(1,6);
    self:changeTexture("flag_tip","images/ui_share/get_card_word"..index..".png");

    local conf = {}
    conf["50001"] = {scale = 0.7,pos = cc.p(20,-10)}
    conf["50002"] = {scale = 0.7,pos = cc.p(20,-25)}
    conf["50003"] = {scale = 0.7,pos = cc.p(20,-25)}
    conf["50004"] = {scale = 0.7,pos = cc.p(20,-25)}
    conf["50005"] = {scale = 0.7,pos = cc.p(20,-25)}

    -- print_lua_table(conf);
    -- print("petid = "..petid);

    local result = loadFlaXml("r"..petid, nil, awakeLv)
    if(result)then
        self.petFla=FlashAni.new()
        self.petFla:setPetSkinId(awakeLv)
        self.petFla:playAction("r"..petid.."_wait")
        local config = conf[tostring(petid)];
        if(config)then
            self.petFla:setPosition(config.pos);
            self.petFla:setScale(config.scale);
        else
            self.petFla:setPosition(cc.p(20,-25));
            self.petFla:setScale(0.7);
        end
        self:getNode("bg_role"):addChild(self.petFla)
    end

    self:getNode("flag_country"):setVisible(false);

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

function PetSharePanel:onEnter()
    if self.petFla then
        self.petFla:pause();
    end
end

function  PetSharePanel:events()
    return {}
end


function PetSharePanel:dealEvent(event,param)
    -- if(event==EVENT_ID_GIFT_BAG_GOT)then
    --     self:initGift()
    -- end
end

function PetSharePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_share" then
        gShare();
        -- gShare(self:getNode("content"),"_luan_share_card.png");
    elseif target.touchName=="share1" then
        local data={}
        data.sharePlatform = "sharePlatform1"
        data.desc = gGetWords("shareWords.plist","petShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share2" then
        local data={}
        data.sharePlatform = "sharePlatform2"
        data.desc = gGetWords("shareWords.plist","petShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share3" then
        local data={}
        data.sharePlatform = "sharePlatform3"
        data.desc = gGetWords("shareWords.plist","petShareDesc");
        gShare(self.shareType,data);
    end
end

return PetSharePanel