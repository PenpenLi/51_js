local FormationSharePanel=class("FormationSharePanel",UILayer)

function FormationSharePanel:ctor(data)

    self:init("ui/share/ui_share_formation.map")
    self._panelTop = true;
    -- print_lua_table(data);
    self.formationType = data.formationType;
    self.shareType = data.shareType;

    self:getNode("layer_arena"):setVisible(false);
    self:getNode("layer_level"):setVisible(false);
    self:getNode("layer_pettower"):setVisible(false);
    self:getNode("layer_atlas"):setVisible(false);
    if(self.shareType == SHARE_TYPE_ARENA)then
        self:getNode("layer_arena"):setVisible(true);
        self:setLabelString("txt_rank",data.shareData.rank);
    elseif(self.shareType == SHARE_TYPE_LEVEL)then
        self:getNode("layer_level"):setVisible(true);
        self:setLabelAtlas("txt_level",data.shareData.level);
    elseif(self.shareType == SHARE_TYPE_PETTOWER)then
        self:getNode("layer_pettower"):setVisible(true);
        self:setLabelString("txt_floor",data.shareData.floor);
    elseif(self.shareType == SHARE_TYPE_ATLAS)then
        self:getNode("layer_atlas"):setVisible(true);

        print("data.shareData.star = "..data.shareData.star);
        if(data.shareData.star <= 0)then
            self:getNode("layout_star"):setVisible(false);
        else
            for i = 1,3 do
                if(i>data.shareData.star)then
                    self:changeTexture("star_up"..i,"images/ui_public1/star_mid_1.png");
                end
                -- self:getNode("star_up"..i):setVisible(i <= data.shareData.star);
            end    
        end

        local stage=DB.getStageById(data.shareData.mapid,data.shareData.stageid,0);
        if(stage)then
            self:replaceRtfString("txt_atlas",stage.name);
        end
    end

    -- print("formationType = "..self.formationType)
    local temp=Data.getUserTeam(self.formationType)
    if(temp)then
        self.curFormation=clone(temp)
    else
        self.curFormation={}
    end

    -- print_lua_table(self.curFormation);

    local petid = self.curFormation[6]
    if(petid > 0)then
        self.pet = Data.getUserPetById(petid);
        local petDb=DB.getPetById(petid)
        local awakeLv = Pet.getPetAwakeLv(petid)
        -- self:setLabelString("txt_name",petDb.name);
        -- self:setLabelString("txt_tip",petDb.des);
        -- for i=1,6 do
        --     self:getNode("star"..i):setVisible(i<=self.pet.grade);
        -- end

        local conf = {}
        conf["50001"] = {scale = 0.6,pos = cc.p(20,20)}
        conf["50002"] = {scale = 0.6,pos = cc.p(40,20)}
        conf["50003"] = {scale = 0.6,pos = cc.p(20,20)}
        conf["50004"] = {scale = 0.6,pos = cc.p(40,20)}
        conf["50005"] = {scale = 0.6,pos = cc.p(40,20)}

        -- print_lua_table(conf);
        -- print("petid = "..petid);

        local result = loadFlaXml("r"..petid,nil, awakeLv)
        if(result)then
            self.petFla=FlashAni.new()
            self.petFla:setPetSkinId(awakeLv)
            self.petFla:playAction("r"..petid.."_wait")
            self.petFla:setPosition(conf[tostring(petid)].pos);
            self.petFla:setScale(conf[tostring(petid)].scale);
            self:getNode("bg_role"):addChild(self.petFla)
        end

        self:getNode("flag_no_pet"):setVisible(false);
    else
        self:getNode("flag_no_pet"):setVisible(true);
    end

    for key,cardid in pairs(self.curFormation) do
        if toint(key) <= 5 then
            local node = self:getNode("icon"..key);
            local card = Data.getUserCardById(cardid);
            if(card)then
                local data = {};
                data.cid = card.cardid;
                data.lv = card.level;
                data.qlt = card.quality;
                data.gd = card.grade;
                data.awakeLv = card.awakeLv;

                local item = FormationCardItem.new(data);
                node:setOpacity(0);
                gAddChildByAnchorPos(node,item,cc.p(0,1));
            end
        end
    end

    self:countPower();


    self:replaceLabelString("txt_lv",gUserInfo.level);
    self:setLabelString("txt_uname",gUserInfo.name);
    local curServer=gAccount:getCurServer();
    self:setLabelString("txt_server",curServer.name);

    local index = getRand(1,6);
    self:changeTexture("flag_tip","images/ui_share/get_card_word"..index..".png");

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
    gCallFuncDelay(0.3,self,show);

end

function FormationSharePanel:onEnter()
    if self.petFla then
        self.petFla:pause();
    end
end


function  FormationSharePanel:countPower()
    local power=CardPro.countFormation(self.curFormation,self.formationType)
    self:setLabelAtlas("txt_power",power)
end

function  FormationSharePanel:events()
    return {}
end


function FormationSharePanel:dealEvent(event,param)
    -- if(event==EVENT_ID_GIFT_BAG_GOT)then
    --     self:initGift()
    -- end
end

function FormationSharePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_share" then
        gShare(self.shareType);
        -- gShare(self:getNode("content"),"_luan_share_card.png");
    elseif target.touchName=="share1" then
        local data={}
        data.sharePlatform = "sharePlatform1"
        data.desc = gGetWords("shareWords.plist","formationShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share2" then
        local data={}
        data.sharePlatform = "sharePlatform2"
        data.desc = gGetWords("shareWords.plist","formationShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share3" then
        local data={}
        data.sharePlatform = "sharePlatform3"
        data.desc = gGetWords("shareWords.plist","formationShareDesc");
        gShare(self.shareType,data);
    end
end

return FormationSharePanel