local CardLevelUpPanel=class("CardLevelUpPanel",UILayer)

CardLevelUpPanelData = {};
CardLevelUpPanelData.desLv = 0;
CardLevelUpPanelData.desExp = 0;

function CardLevelUpPanel:ctor(userCard)
    loadFlaXml("ui_win");
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self:init("ui/ui_role_levelup.map");

    self.curCard = userCard;
    self.showCurLv = self.curCard.level;
    self.showNextLv = self.curCard.level+1;
    self.showCurExp = self.curCard.exp;
    self.showLeftExp = gUserInfo.cexp;

    CardLevelUpPanelData.desLv = self.showCurLv;
    CardLevelUpPanelData.desExp = self.showCurExp;

    CardPro.showStar6(self,self.curCard.grade,self.curCard.awakeLv);
    gCreateRoleFla(self.curCard.cardid, self:getNode("icon"),1,nil,nil,self.curCard.weaponLv,self.curCard.awakeLv);

    self:refresh();

    self.leveluping = false;
    self.aniFrame = 60;
    -- local function update()
    --     self:updateExp();
    -- end
    -- self:scheduleUpdateWithPriorityLua(update,1)
end

function CardLevelUpPanel:updateExp()
    -- body
    if self.leveluping == true then
        return;
    end

    -- print("dealEvent self.showCurLv = "..self.showCurLv);
    -- print("self.showCurExp = "..self.showCurExp);
    -- print_lua_table(CardLevelUpPanelData);

    if (CardLevelUpPanelData.desLv > self.showCurLv) or 
        (CardLevelUpPanelData.desLv == self.showCurLv and CardLevelUpPanelData.desExp > self.showCurExp) then
        -- print("dealEvent self.showCurLv = "..self.showCurLv);
        -- print("self.showCurExp = "..self.showCurExp);
        -- print_lua_table(CardLevelUpPanelData);
        self:startLevelUp();
    end
end



function CardLevelUpPanel:refresh()

    self:setLabelAtlas("txt_cur_lv",self.showCurLv);
    self:setLabelAtlas("txt_next_lv",self.showCurLv+1);
    --经验
    local maxExp = DB.getCardExpByLevel(self.curCard.level);
    self:setLabelString("txt_exp",self.showCurExp.."/"..maxExp)
    self:setBarPer("exp_bar",self.showCurExp/maxExp);


    local maxExp = DB.getCardExpByLevel(self.showCurLv);
    local needExp = maxExp - self.showCurExp;
    self:setLabelString("txt_next_exp",needExp)
    self:setLabelString("txt_left_exp",self.showLeftExp)

    self.canLevelUpCount = self:getCanLevelUpCount();
    self:replaceLabelString("txt_upgrade_more",self.canLevelUpCount);
    -- if self.canLevelUpCount <= 1 then
    --     self:setTouchEnableGray("btn_upgrade_more",false);
    --     self:replaceLabelString("txt_upgrade_more",1);
    -- else
    --     self:setTouchEnableGray("btn_upgrade_more",true);    
    --     self:replaceLabelString("txt_upgrade_more",self.canLevelUpCount);
    -- end

end

function CardLevelUpPanel:getCanLevelUpCount()
    local count = 0;
    count = Data.getCurLevel() - self.curCard.level;

    -- local level = self.curCard.level;
    -- local nextExp = 0;
    -- local leftExp = gUserInfo.cexp;
    -- while leftExp > 0 do
    --     nextExp = DB.getCardExpByLevel(level);
    --     if nextExp <= 0 then
    --         break;
    --     end
    --     if leftExp < nextExp then
    --         break;
    --     else
    --         leftExp = leftExp - nextExp;
    --         count = count + 1;
    --         level = level + 1;
    --     end
    -- end

    if count > 10 then
        count = 10;
    elseif count < 1 then
        count = 1;    
    end
    return count;
end

function CardLevelUpPanel:getNeedExp(levelupCount)
    local exp = 0;
    local level = self.curCard.level;
    local nextExp = 0;
    local curExp = self.curCard.exp;
    local needExp = 0;
    local leftExp = gUserInfo.cexp;
    for i=0,levelupCount-1 do
        nextExp = DB.getCardExpByLevel(level+i);
        needExp = nextExp - curExp;
        exp = exp + needExp;
        curExp = 0;

    end

    if exp > gUserInfo.cexp then
        exp = gUserInfo.cexp;
    end

    return exp;
end

function CardLevelUpPanel:startLevelUp()
    -- print("startLevelUp");
    -- print("self.showCurLv = "..self.showCurLv);
    -- print("CardLevelUpPanelData.desLv = "..CardLevelUpPanelData.desLv);
    if self.showCurLv < CardLevelUpPanelData.desLv then
        self.leveluping = true;
        local function callback()
            self:levelUp();
        end
        local desExp = DB.getCardExpByLevel(self.showCurLv);
        local frame = (desExp - self.showCurExp) / desExp * self.aniFrame;
        self:updateBarPer("exp_bar","txt_exp",self.showCurExp,desExp,desExp,frame,callback);
    elseif self.showCurLv == CardLevelUpPanelData.desLv and self.showCurExp < CardLevelUpPanelData.desExp then
        self.leveluping = true;
        local maxExp = DB.getCardExpByLevel(self.showCurLv);
        local frame = (CardLevelUpPanelData.desExp - self.showCurExp) / maxExp * self.aniFrame;
        local function callback()
            self.leveluping = false;
            self.showCurLv = CardLevelUpPanelData.desLv;
            self.showCurExp = CardLevelUpPanelData.desExp;
            self.showLeftExp = gUserInfo.cexp;
            self:refresh();
            -- print("end startLevelUp")
        end
        self:updateBarPer("exp_bar","txt_exp",self.showCurExp,CardLevelUpPanelData.desExp,maxExp,frame,callback);
    else
       self.leveluping = false; 
    end

end

function CardLevelUpPanel:levelUp()
    -- print("levelUpCallBack");
    local needExp = DB.getCardExpByLevel(self.showCurLv) - self.showCurExp;
    self.showLeftExp = self.showLeftExp - needExp;

    self.showCurLv = self.showCurLv + 1;
    -- self.showNextLv = self.showCurLv + 1;
    self.showCurExp = 0;
    self:refresh();

    -- self:setLabelAtlas("txt_cur_lv",self.showCurLv);
    -- self:setLabelAtlas("txt_next_lv",self.showCurLv+1);
    -- --经验
    -- local maxExp = DB.getCardExpByLevel(self.showCurLv);
    -- self:setLabelString("txt_exp",self.showCurExp.."/"..maxExp)
    -- self:setBarPer("exp_bar",self.showCurExp/maxExp);


    local fla = gCreateFla("ui_jingyan_jiantou");
    gAddChildByAnchorPos(self:getNode("txt_next_lv"),fla,cc.p(0.5,0.5));

    if CardLevelUpPanelData.desLv == self.showCurLv then
        local levelupFla = gCreateFla("ui_levelup_guang");
        levelupFla:setLocalZOrder(-1);
        gAddChildByAnchorPos(self:getNode("icon"),levelupFla,cc.p(0.5,0.5));
    end

    self:startLevelUp();
end

function CardLevelUpPanel:onTouchEnded(target)
    if(target.touchName == "btn_close")then
        Panel.popBack(self:getTag())
    elseif(target.touchName == "btn_buy") then
        if self.leveluping == true then
            return;
        end
        Panel.popUp(PANEL_GLOBAL_BUY,VIP_EXP)   
    elseif(target.touchName=="btn_upgrade")then

        if self.leveluping == true then
            return;
        end
        -- gDispatchEvt(EVENT_ID_UPDATE_REWORDS)

        if NetErr.CardExpUpgrade(self.curCard.level) then
            self:sendCardExpUpgrade(1);
            -- local needExp = self:getNeedExp(1);
            -- if(needExp < 0)then
            --     Net.sendRefreshData();
            --     Panel.popBack(self:getTag())
            --     return;
            -- end
            -- Net.sendCardExpUpgrade(self.curCard.cardid,needExp);
        end
    elseif(target.touchName=="btn_upgrade_more")then

        if self.leveluping == true then
            return;
        end

        -- self:getNeedExp(self.canLevelUpCount)
        if NetErr.CardExpUpgrade(self.curCard.level) then
            self:sendCardExpUpgrade(self.canLevelUpCount);
            -- Net.sendCardExpUpgrade(self.curCard.cardid,self:getNeedExp(self.canLevelUpCount));
        end
    end

end

function CardLevelUpPanel:sendCardExpUpgrade(levelUpCount)
    local needExp = self:getNeedExp(levelUpCount);
    if(needExp < 0)then
        gShowNotice(gGetWords("noticeWords.plist","data_error"));
        Net.sendRefreshData();
        Panel.popBack(self:getTag());
        return;
    end
    Net.sendCardExpUpgrade(self.curCard.cardid,needExp);
end

function  CardLevelUpPanel:events()
    return {EVENT_ID_UPDATE_REWORDS,
            EVENT_ID_GOLBAL_BUY}
end


function CardLevelUpPanel:dealEvent(event,param)
    if(event==EVENT_ID_UPDATE_REWORDS)then

        -- CardLevelUpPanelData.desLv = self.showCurLv+5;
        -- CardLevelUpPanelData.desExp = 10;
        CardLevelUpPanelData.desLv = self.curCard.level;
        CardLevelUpPanelData.desExp = self.curCard.exp;

        if CardLevelUpPanelData.desLv - self.showCurLv > 1 then
            self.aniFrame = 30;
            -- self.aniFrame = 60 / (CardLevelUpPanelData.desLv - self.showCurLv);
        else
            self.aniFrame = 60;  
        end

        -- self:refresh();

        -- if self.leveluping == false then
            self:startLevelUp();
        -- end
    elseif event == EVENT_ID_GOLBAL_BUY then
        self.showLeftExp = gUserInfo.cexp;
        self:setLabelString("txt_left_exp",self.showLeftExp)    
    end
end

return CardLevelUpPanel