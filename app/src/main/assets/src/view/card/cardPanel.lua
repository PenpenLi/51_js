local CardPanel=class("CardPanel",UILayer)

CardPanelData = {}
CardPanelData.config = cc.FileUtils:getInstance():getValueMapFromFile("fightScript/roleConfig.plist")


function CardPanel:ctor()
    loadFlaXml("ui_effect");
    self:init("ui/ui_role_di.map")
    self.needShowPopUpAct = true;
    self.isMainLayerGoldShow = false;
    self.btns={
        "btn_all",
        "btn_def",
        "btn_phy_attack",
        "btn_magic_attack",
        "btn_treat"
    }
    self.btnImages={
        {"ui_word/sx_all1.png","ui_word/sx_all2.png"},
        {"ui_word/sx_fang1.png","ui_word/sx_fang2.png"},
        {"ui_word/sx_wu1.png","ui_word/sx_wu2.png"},
        {"ui_word/sx_mo1.png","ui_word/sx_mo2.png"},
        {"ui_word/sx_zhi1.png","ui_word/sx_zhi2.png"}
    }

    self.btnCountrys = {
        "btn_country0",
        "btn_country1",
        "btn_country2",
        "btn_country3",
        "btn_country4",
        "btn_country5",
    }
    self.btnCountryImages = {
        {"ui_public1/country_all_2.png","ui_public1/country_all_1.png"},
        {"ui_public1/country_5_2.png","ui_public1/country_5_1.png"},
        {"ui_public1/country_5_2.png","ui_public1/country_5_1.png"},
        {"ui_public1/country_5_2.png","ui_public1/country_5_1.png"},
        {"ui_public1/country_5_2.png","ui_public1/country_5_1.png"},
        {"ui_public1/country_5_2.png","ui_public1/country_5_1.png"},
    }
    -- self.curPanelType=type

    self:getNode("scroll").eachLineNum=2
    self:getNode("scroll"):setPaddingXY(100,0);


    self.curShowType=0
    self.curCountry = 0;
    self:showType(self.curShowType,self.curCountry)
    self:selectBtn("btn_all",1)
    self:selectCountryBtn("btn_country0",1);

end

function CardPanel:onPopup()

    -- if( self.curPanelType==1)then
    --     self.curShowType=0
    --     self:showType(self.curShowType)
    --     self:selectBtn("btn_all",1)
    --     self.needRfresh = false;
    -- end
    -- self:refreshItem(self.choosedCardId);
    if(self.reCreateList)then
        self:showType(self.curShowType,self.curCountry)
        self.reCreateList = false;
    elseif self.needRfresh then
        -- print(" cardpanel refresh list ");
        local drawNum = 6;
        for key, item in pairs( self:getNode("scroll").items) do
            if(item and item.refreshData)then
                local cacheItem = self:getCardItemInCache(item.curCardid);
                if(cacheItem)then
                    item:refreshData();
                else
                    print("#########re addLazyFunc");
                    if(item.hasCard)then
                        item:setLazyUserCardCallBack();
                    else
                        item:setLazyCardDbCallBack();
                    end
                end
            end
        end
        self.needRfresh = false;
        RedPoint.bolCardViewDirty=true
    end

    self:checkScroll()
end

function CardPanel:checkScroll()
    if(Guide.isCardScrollPause())then
        self:getNode("scroll"):setTouchEnable(false)
    else
        self:getNode("scroll"):setTouchEnable(true)
    end
end

function CardPanel:onPushStack()
    -- body
    self.needRfresh = true;
end

function CardPanel:events()
    return {
        EVENT_ID_CARD_RECURIT,
        EVENT_ID_EQUIP_UPQUALITY,
        EVENT_ID_CARD_UP_QUALITY,
        EVENT_ID_CARD_EVOLVE}
end


function CardPanel:dealEvent(event,param)
    if( event==EVENT_ID_CARD_RECURIT)then
        self.reCreateList = true;
        self.needRfresh = false;
        -- self:showType(self.curShowType)
    elseif(  event==EVENT_ID_EQUIP_UPQUALITY or
        event==EVENT_ID_CARD_UP_QUALITY or
        event==EVENT_ID_CARD_EVOLVE)then
    -- self:refreshItem(param.cardid)
    end
end
function CardPanel:getGuideItem(name)
    local paths= string.split(name,"/") 
    local params= string.split(paths[1],"_")
    if(toint(params[1])==0)then
        local node=self:getItemById(toint(params[2]))
        if(node==nil)then
            if(self.curNoCardCall==nil)then
                self.curNoCardCall=0
            end
            node=  self:getNode("scroll").items[toint(params[2])+self.curNoCardCall] 
        end

        if(node)then
            if(paths[2])then
                return node:getNode(paths[2])
            end
            return node:getNode("bg")
        end
    end
    return nil
end

function CardPanel:getItemById(id)
    for key, item in pairs( self:getNode("scroll").items) do
        if(item.curCardid==id)then
            return item
        end

    end
    return nil
end

-- function CardPanel:refreshItem(id)
--     local item=self:getItemById(id)
--     if(item)then
--         item:refreshData()
--     end

-- end

function  CardPanel:isSameType(type,cardid)
    local isSameType=false
    local cardDb=DB.getCardById(cardid)
    if(type==0)then
        isSameType=true
    elseif(type==1 and (cardDb.type==1 or cardDb.type==2) )then

        isSameType=true
    elseif(cardDb.type==type)then
        isSameType=true
    end

    return isSameType
end

function CardPanel:isSameCountry(country,cardid)
    if(country == 0)then
        return true;
    end

    local cardDb=DB.getCardById(cardid);
    if(toint(cardDb.country) == country)then
        return true;
    end

    return false;
end

function CardPanel:getCardItemInCache(cardid)
    return Scene.cardItemCache[cardid];
end

function CardPanel:showType(type,country)
    self:getNode("scroll"):clear()
    self:getNode("scroll").breakTouch = true;
    self.notHaveItems={}
    self.haveItems={}
    self.curShowType=type
    self.curCountry = country;
    local drawNum=6
    -- print("CardPanel:showType");
    Scene.clearLazyFunc("carditem")
    Data.sortUserCard()
    --可招募卡牌
    local noCards={}
    for key, card in pairs(card_db) do
        if(card.show==true and card.show==true and card.isspecial==0 and self:isSameType(type,card.cardid) and self:isSameCountry(country,card.cardid))then
            local userCard=  Data.getUserCardById(card.cardid)
            if(userCard==nil)then
                card.curSoulNum= Data.getSoulsNumById(card.cardid)
                card.needSoulNum=DB.getNeedInitSoulNum(card.evolve-1)
                table.insert(noCards,card)
            end
        end
    end

    local index = 0;
    for key, card in pairs(noCards) do
        if(card.curSoulNum>=card.needSoulNum)then
            local item = self:getCardItemInCache(card.cardid);
            if(item == nil)then
                item = CardItem.new()
                if(drawNum>0)then
                    drawNum=drawNum-1
                    item:setCardDb(card,true)
                else
                    item:setLazyCardDb(card)
                end
                item:setBaseData(false,card.cardid);
                -- item.curCardid=card.cardid
            else
                item:refreshCardDb(card);    
            end
            item.onChooseCard = function ( cardid )
                self:onChooseCard(cardid);
            end
            table.insert(self.notHaveItems,item)
            self:getNode("scroll"):addItem(item)

            index = index + 1;
        end
    end
    
    
    self.curNoCardCall=index

    for key, card in pairs(gUserCards) do
        if(self:isSameType(type,card.cardid) and self:isSameCountry(country,card.cardid))then
            local item = self:getCardItemInCache(card.cardid);
            local userCard=  Data.getUserCardById(card.cardid)
            if(item == nil)then
                item = CardItem.new()
                if(drawNum>0)then
                    drawNum=drawNum-1
                    item:setUserCard(userCard,DB.getCardById(card.cardid),true)
                else
                    item:setLazyUserCard(userCard,DB.getCardById(card.cardid))
                end
                item:setBaseData(true,card.cardid);
                -- item.curCardid=card.cardid
            else
                item:refreshUserCard(userCard);  
            end

            item.onChooseCard = function ( cardid )
                self:onChooseCard(cardid);
            end

            table.insert(self.haveItems,item)
            self:getNode("scroll"):addItem(item)
           

            index = index + 1;
            if(index==8)then
                Scene.addLazyFunc(self,self.setRedDirty,"carditem")
            end
        end
    end
    Scene.addLazyFunc(self,self.setRedDirty,"carditem")
    --补齐
    if math.mod(index,2) ~= 0 then
        local node = cc.Node:create();
        self:getNode("scroll"):addItem(node);
    end

    -- if(self.curPanelType~=1)then

        if table.getn(noCards) > 0 then
            --分割线
            local splitLine = UILayer.new();
            splitLine:init("ui/ui_role_split.map");
            local word = gGetWords("labelWords.plist","roleSplitLine");
            local lab = gCreateVerticalWord(word,gCustomFont,20,cc.c3b(0,0,0),0);
            gAddChildInCenterPos(splitLine:getNode("bg"),lab);
            -- print("width = "..splitLine:getContentSize().width);
            self:getNode("scroll"):addItem(splitLine);
            local node = cc.Node:create();
            node:setContentSize(cc.size(1,265));
            self:getNode("scroll"):addItem(node);
        end
        
        
        
        for key, card in pairs(noCards) do
        	if(card.curSoulNum>=card.needSoulNum)then
                card.sort=1000000 --最前面
            else
                card.sort=card.curSoulNum*1000+card.needSoulNum
        	end
        end
        
        local sortNotHasFunc = function(a, b) 
            return a.sort > b.sort
        end

       table.sort(noCards, sortNotHasFunc)

        for key, card in pairs(noCards) do
            if(card.curSoulNum<card.needSoulNum)then
                local item = self:getCardItemInCache(card.cardid);
                if(item == nil)then
                    item = CardItem.new()
                    if(drawNum>0)then
                        drawNum=drawNum-1
                        item:setCardDb(card,true)
                    else
                        item:setLazyCardDb(card)
                    end
                    item:setBaseData(false,card.cardid);
                    -- item.curCardid=card.cardid
                else
                    item:refreshCardDb(card);  
                end
                item.onChooseCard = function ( cardid )
                    self:onChooseCard(cardid);
                end
                table.insert(self.notHaveItems,item)
                self:getNode("scroll"):addItem(item)
            end
        end

    -- end


    self:getNode("scroll"):layout(true);
    -- self:layout()

    self:getNode("endScroll"):setVisible(self:getNode("scroll"):canScroll());
end

function CardPanel:setRedDirty()
    RedPoint.bolCardViewDirty=true

end
function CardPanel:onChooseCard(cardid)

    -- local items = self:getNode("scroll"):getAllItem();
    -- for key,var in pairs(items) do
    --     var:setAllChildCascadeOpacityEnabled(true);
    --     var:runAction(cc.FadeOut:create(1.0));
    -- end
    -- self:getNode("scroll"):setAllChildCascadeOpacityEnabled(true);
    -- self:getNode("scroll"):runAction(cc.FadeIn:create(0.5));
    self.choosedCardId = cardid;
    Panel.popUp(PANEL_CARD_INFO,cardid)
end

function CardPanel:hideAllBtn()
    for key, btn in pairs(self.btns) do
        self:getNode(btn):setVisible(false)
    end


end

function CardPanel:resetBtnTexture()
    for key, btn in pairs(self.btns) do
        self:changeTexture(btn,"images/"..self.btnImages[key][2])
    end
end

function CardPanel:selectBtn(name,index)
    self:resetBtnTexture()
    self:changeTexture( name,"images/"..self.btnImages[index][1])
end

function CardPanel:resetBtnCountryTexture()
    for key, btn in pairs(self.btnCountrys) do
        self:changeTexture(btn,"images/"..self.btnCountryImages[key][2])
    end
end

function CardPanel:selectCountryBtn(name,index)
    self:resetBtnCountryTexture()
    self:changeTexture( name,"images/"..self.btnCountryImages[index][1])
end

--会导致马上进入一张卡牌后面未加载完
-- function CardPanel:onPopback()
--     print("CardPanel:onPopback");
--     Scene.clearLazyFunc("carditem")
-- end

function CardPanel:onPopBackFromStack()
    -- print(" CardPanel:onPopBackFromStack");
    Scene.clearLazyFunc("carditem")
end

function CardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        CardPro.sendEatExp()

    elseif target.touchName=="btn_all"then
        self:showType(0,self.curCountry)
        self:selectBtn( target.touchName,1)
    elseif target.touchName=="btn_def"then
        self:showType(1,self.curCountry)
        self:selectBtn( target.touchName,2)
    elseif target.touchName=="btn_phy_attack"then
        self:showType(CARD_TYPE_PHY_ATTACK,self.curCountry)
        self:selectBtn( target.touchName,3)
    elseif target.touchName=="btn_magic_attack"then
        self:showType(CARD_TYPE_MAGIC_ATTACK,self.curCountry)
        self:selectBtn( target.touchName,4)
    elseif target.touchName=="btn_treat"then
        self:showType(CARD_TYPE_TREAT,self.curCountry)
        self:selectBtn( target.touchName,5)
    elseif target.touchName == "btn_country0" then
        self:showType(self.curShowType,0)
        self:selectCountryBtn( target.touchName,1)    
    elseif target.touchName == "btn_country1" then
        self:showType(self.curShowType,1)
        self:selectCountryBtn( target.touchName,2)    
    elseif target.touchName == "btn_country2" then
        self:showType(self.curShowType,2)
        self:selectCountryBtn( target.touchName,3)    
    elseif target.touchName == "btn_country3" then
        self:showType(self.curShowType,3)
        self:selectCountryBtn( target.touchName,4)    
    elseif target.touchName == "btn_country4" then
        self:showType(self.curShowType,4)
        self:selectCountryBtn( target.touchName,5)    
    elseif target.touchName == "btn_country5" then
        self:showType(self.curShowType,5)
        self:selectCountryBtn( target.touchName,6)  
    end
end

function CardPanel:setNeedRfresh(flag)
    print("CardPanel:setNeedRfresh",flag)
    -- self.needRfresh = flag
end

return CardPanel