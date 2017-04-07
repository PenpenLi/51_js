local LevelUpSharePanel=class("LevelUpSharePanel",UILayer)

function LevelUpSharePanel:ctor(data)

    self:init("ui/share/ui_share_levelup.map")
    self._panelTop = true;

    self.formationType = data.formationType;
    self.shareType = data.shareType;

    -- print("formationType = "..self.formationType)
    local temp=Data.getUserTeam(self.formationType)
    if(temp)then
        self.curFormation=clone(temp)
    else
        self.curFormation={}
    end

    self.roles = {};
    for key,cardid in pairs(self.curFormation) do
        if toint(key) <= 5 then
            self.roles[key] = self:createRole(key,cardid);
        end
    end

    self:countPower();


    self:replaceLabelString("txt_lv",gUserInfo.level);
    self:setLabelString("txt_uname",gUserInfo.name);
    local curServer=gAccount:getCurServer();
    self:setLabelString("txt_server",curServer.name);

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

function LevelUpSharePanel:onEnter()
    if self.petFla then
        self.petFla:pause();
    end
end


function  LevelUpSharePanel:countPower()
    local power=CardPro.countFormation(self.curFormation,self.formationType)
    self:setLabelAtlas("txt_power",power)
end

function LevelUpSharePanel:createRole(idx,cardid)

    local card = Data.getUserCardById(cardid);
    if(card == nil)then
        self:getNode("flag_role"..(idx+1)):setVisible(true);
        return;
    end
    
    self:getNode("flag_role"..(idx+1)):setVisible(false);
    local role = gCreateRoleFla(cardid, self:getNode("bg_role"..idx),1.0,false,"r"..cardid.."_wait",card.weaponLv,card.awakeLv);
    if role then

        for key,var in pairs(CardPanelData.config) do
            if toint(key) == cardid then
                if var.offset then
                    local pos = string.split(var.offset,",");
                    role:setPosition(cc.p(role:getPositionX() + pos[1],role:getPositionY() + pos[2]));
                end

                if var.scale then
                    role:setScale(var.scale);
                end
            end
        end

    end

    return role;

end

function  LevelUpSharePanel:events()
    return {}
end


function LevelUpSharePanel:dealEvent(event,param)
    -- if(event==EVENT_ID_GIFT_BAG_GOT)then
    --     self:initGift()
    -- end
end

function LevelUpSharePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_share" then
        gShare(self.shareType);
        -- gShare(self:getNode("content"),"_luan_share_card.png");
    elseif target.touchName=="share1" then
        local data={}
        data.sharePlatform = "sharePlatform1"
        data.desc = gGetWords("shareWords.plist","levelUpShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share2" then
        local data={}
        data.sharePlatform = "sharePlatform2"
        data.desc = gGetWords("shareWords.plist","levelUpShareDesc");
        gShare(self.shareType,data);
    elseif target.touchName=="share3" then
        local data={}
        data.sharePlatform = "sharePlatform3"
        data.desc = gGetWords("shareWords.plist","levelUpShareDesc");
        gShare(self.shareType,data);
    end
end

return LevelUpSharePanel