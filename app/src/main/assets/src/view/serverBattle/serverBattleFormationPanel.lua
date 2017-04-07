local ServerBattleFormationPanel=class("ServerBattleFormationPanel",UILayer)

function ServerBattleFormationPanel:ctor(idx)
    self.appearType = 1
    self:init("ui/ui_serverbattle_formation.map")
    self.isMainLayerGoldShow=false
    self.isMainLayerMenuShow=false
    self.rivalIdx = idx

    self.btns={
        "btn_card",
        "btn_pet",
    }

    self.panelType=TEAM_TYPE_WORLD_WAR_ATTACK

    local temp=Data.getUserTeam(self.panelType)
    if(temp)then
        self.curFormation=clone(temp)
    else
        self.curFormation={}
    end
    self.isFirstEnter=false
    -- TODO
    -- if(NetErr.isTeamEmpty(self.curFormation))then
    --     self.curFormation= Data.getUserTeam(TEAM_TYPE_ATLAS)
    --     Data.saveUserTeam(self.panelType,self.curFormation)
    --     self.curFormation=clone( Data.getUserTeam(TEAM_TYPE_ATLAS))
    --     self.isFirstEnter=true
    -- end
    Data.sortUserCard()
    for key, cardid in pairs(self.curFormation) do
        if(key==PET_POS  )then
            if(  Data.getUserPetById(cardid)==nil)then
                self.curFormation[key]=0
            end
        elseif(Data.getUserCardById(cardid)==nil)then
            self.curFormation[key]=0
        end
    end


    temp=clone(self.curFormation)

    self:getNode("scroll").eachLineNum=2
    self:getNode("scroll").offsetX=0
    self:getNode("scroll").offsetY=0
    self:getNode("scroll").itemScale=0.89
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:showType(0)
    self:selectBtn("btn_card")

    self:getNode("icon_country").__touchend=true
    --TODO
    -- self.curData=data
    self:initFormation()
    self:refreshFormation()

    for i=0, 6 do
        if(self:getNode("shine_pos"..i))then
            self:getNode("shine_pos"..i):setVisible(false)
        end
    end

    local sort2 = function(pet1,pet2) 
        return pet1.sort > pet2.sort;
    end

    for key, pet in pairs(gUserPets) do
        local db=DB.getPetById(pet.petid)
        local totalLevel=0
        for i=1, 5 do
            totalLevel=totalLevel+ pet["skillLevel"..i]
        end
        pet.sort=pet.grade*20+totalLevel*2
        if(db.quality==5)then
            pet.sort=pet.sort+20 
        end
        pet.sort=pet.sort*100+pet.grade
    end 

    table.sort(gUserPets,sort2)

    self:initRivalInfo(idx)

    self:getNode("btn_constellation"):setVisible(Unlock.isUnlock(SYS_CONSTELLATION,false))
    self:showConstellationFla()
end

function ServerBattleFormationPanel:onPopback()
    Scene.clearLazyFunc("formation")
end

function ServerBattleFormationPanel:stopShine()
    for i=0, 6 do
        if(self:getNode("shine_pos"..i))then
            self:getNode("shine_pos"..i):setVisible(false)
            self:getNode("shine_pos"..i):stopAllActions()
        end
    end
end

function ServerBattleFormationPanel:shinePos(pos)
    if(self:getNode("shine_pos"..pos)  and self:getNode("shine_pos"..pos):isVisible())then
        return
    end

    self:stopShine()

    if(self:getNode("shine_pos"..pos) )then
        self:getNode("shine_pos"..pos):setOpacity(0)
        self:getNode("shine_pos"..pos):setVisible(true)
        local actions={}
        table.insert(actions,cc.FadeTo:create(0.5,155))
        table.insert(actions,cc.FadeTo:create(0.3,0))

        local pAct_repeat =cc.RepeatForever:create(cc.Sequence:create(actions) )
        self:getNode("shine_pos"..pos):runAction(pAct_repeat)
    end
end

function  ServerBattleFormationPanel:countPower()
    local power=CardPro.countFormation(self.curFormation,self.panelType)
    self:setLabelAtlas("txt_lpower",power)
    self:getNode("layout_lpower").items[2] = self:getNode("txt_lpower")
    self:getNode("layout_lpower"):layout()
    self:setLabelAtlas("txt_rpower",gServerBattle.rivalInfos[self.rivalIdx].power)
    self:getNode("layout_rpower").items[2] = self:getNode("txt_rpower")
    self:getNode("layout_rpower"):layout()
    self:getNode("layout_power"):layout()
    self:countryIcon()
end


function ServerBattleFormationPanel:countryIcon()
    local country={}
    local supercard=0
    for key, var in pairs(self.curFormation) do
        local card=DB.getCardById(var)
        if(card)then
            if(country[card.country]==nil)then
                country[card.country]=0
            end
            country[card.country]=country[card.country]+1

            if(card.supercard==1)then
                supercard=supercard+1
            end
        end
    end

    self.country=0
    if(supercard>=3)then
        self.country=30
    end

    if(self.country==0)then 
        for key, var in pairs(country) do
            if(var>=4)then
                self.country=key
                break
            end
        end

    end

    if(self.country==0)then 
        for key, var in pairs(country) do
            if(var>=3)then
                self.country=13
                break
            end
        end
    end
    
    Icon.changeCountryIcon(self:getNode("icon_country"),self.country)

end

function  ServerBattleFormationPanel:events()
    return {EVENT_ID_SERVERBATTLE_QUIT,
            EVENT_ID_SERVERBATTLE_SEC_MATCH_END,
            EVENT_ID_CONSTELLATION_ITEM_CHOOSE,
    }
end


function ServerBattleFormationPanel:dealEvent(event,param)
    if(event==EVENT_ID_SERVERBATTLE_QUIT)then
        self:onClose()
    elseif(event==EVENT_ID_SERVERBATTLE_SEC_MATCH_END)then
        if param == 11 then
            self:onClose()
            local mainSeverBattlePanel = Panel.getOpenPanel(PANEL_SERVER_BATTLE_MAIN)
            if nil ~= mainSeverBattlePanel then
                mainSeverBattlePanel:onClose()
            end
        end
    elseif(event==EVENT_ID_CONSTELLATION_ITEM_CHOOSE)then
        self:showConstellationFla()
    end
end

function ServerBattleFormationPanel:initFormationPos()
    --TODO,no use
    -- for i=3,6 do
    --     local isUnlock = Unlock.teamPos.isUnlock(i);
    --     local lock = self:getNode("lock"..i);
    --     if lock then
    --         local unlockLevel = toint(gUnlockLevel.posLevel[i-2]);
    --         self:setLabelString("txt_lock"..i,gGetWords("unlockWords.plist","unlock_tip_pos",unlockLevel));
    --         lock:setVisible(not isUnlock);
    --     end
    -- end
end

function ServerBattleFormationPanel:initFormation()

    self:initFormationPos();
    local formation=self.curFormation
    for key, cardid in pairs(self.curFormation) do
        local data=nil
        if(key==PET_POS)then
            data=  Data.getUserPetById(cardid)
        else
            data=  Data.getUserCardById(cardid)
        end

        if(data)then
            local node=self:getNode("pos"..key)
            local item=AtlasFormationRole.new(2)
            node:addChild(item)
            item:setTag(key)
            item:setData(data)
            item:setPositionY(node:getContentSize().height)
            item:setPositionX(node:getContentSize().width/2-self:getNode("pos4"):getContentSize().width/2)
            item.selectItemCallback=function (touchPos,cardid)
                self:onCancelCard(touchPos,cardid,item:getTag())
            end
            item.moveItemCallback=function (touchPos,cardid)
                self:onMoveCard(touchPos,cardid,item:getTag())
            end
            -- item:setScale(0.8)
        end
    end

    self:countPower()
end

function ServerBattleFormationPanel:getItemByCardid(cardid)
    for _, item in pairs( self:getNode("scroll").items) do
        if(item.curCard.cardid==cardid)then
            return item
        end
    end
    return nil
end

function  ServerBattleFormationPanel:refreshFormation()
    for _, item in pairs( self:getNode("scroll").items) do
        item:setSelected(false)
    end


    for _, cardid in pairs(self.curFormation) do
        for _, item in pairs( self:getNode("scroll").items) do
            if(item.curCard.cardid==cardid)then
                item:setSelected(true)
            elseif(item.curCard.petid==cardid)then
                item:setSelected(true)
            end
        end
    end
    self:countPower()
end

function ServerBattleFormationPanel:showType(type)

    Scene.clearLazyFunc("formation")
    self:getNode("scroll"):clear()
    local datas={}
    if(type==0)then
        datas=gUserCards
    else
        datas=gUserPets
    end
    local drawNum=4
    for _, pet in pairs(datas) do
        local item=AtlasFormationItem.new(1)
        if(drawNum>0)then
            drawNum=drawNum-1
            item:setData(pet)
        else
            item:setLazyData(pet)
        end
        item.selectItemCallback=function (touchPos,cardid)
            self:onSelectCard(touchPos,cardid)
        end
        item.moveItemCallback=function (touchPos,cardid)
            self:onMoveCard(touchPos,cardid)
        end
        self:getNode("scroll"):addItem(item)
    end

    self:refreshFormation()
    self:getNode("scroll"):layout()
end


function ServerBattleFormationPanel:resetBtnTexture()
    for _, btn in pairs(self.btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end

function ServerBattleFormationPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end

function ServerBattleFormationPanel:onTouchEnded(target)
    Panel.clearTouchTip()
    if target.touchName=="btn_close"then
       gConfirmCancel(gGetWords("serverBattleWords.plist","quit_serverbattle"), function()
            Net.sendWorldWarQuit()
            self:onClose()
       end ) 
    elseif  target.touchName=="btn_card"then
        self:showType(0)
        self:selectBtn( target.touchName)
    elseif  target.touchName=="btn_pet"then
        self:showType(1)
        self:selectBtn( target.touchName)
    elseif target.touchName == "btn_one" then
        self:autoFormation();
    elseif target.touchName=="btn_enter" then
        if(NetErr.saveTeam(self.curFormation)==false)then
            return
        end
        Data.saveUserTeam(self.panelType,self.curFormation)
        -- Panel.pushRePopupPanel(PANEL_SERVER_BATTLE_MAIN)
        local func = function()
            local function  callback()
                if gMainBgLayer == nil then
                    Scene.enterMainScene()
                end
            end
            Net.sendWorldWarGetInfo(callback)
        end
        Panel.pushRePopupPre(func)
        Net.sendWorldWarFight(gServerBattle.rivalInfos[self.rivalIdx].uid)
    elseif target.touchName == "btn_constellation" then
        Panel.popUp(PANEL_CONSTELLATION_SEL_CIRCLE)
    end

end

function ServerBattleFormationPanel:autoFormation()

    local userCards = clone(gUserCards);
    local sort = function(card1,card2)
        if card1.power > card2.power then
            return true;
        end
        return false;
    end
    table.sort(userCards,sort);
    -- local powerCards = {};

    for pos=0, 6 do
        local node= self:getNode("pos"..pos)
        node:removeAllChildren()
    end

    for key, card in pairs(userCards) do
        if key > 6 then
            break;
        end
        -- table.insert(powerCards,card);
        local pos = key - 1;
        if pos ~= PET_POS and not Unlock.teamPos.isUnlock(pos,false) then
            break;
        end
        self:setPosCardId(pos,card.cardid);
    end


    local userPets = gUserPets;
    if(table.count(userPets)~=0)then
        if(userPets[1] )then
            self:setPosCardId(PET_POS,userPets[1].petid);
        end
    end


end

function ServerBattleFormationPanel:setPosCardId(pos ,cardid)
    local node=  self:getNode("pos"..pos)
    if(node==nil)then
        return
    end
    if(cardid==0 or cardid==nil)then
        self.curFormation[pos]=0
        node:removeAllChildren()
        self:refreshFormation()
        return
    end

    self.curFormation[pos]=cardid
    local data=nil
    if(pos==PET_POS)then
        data=  Data.getUserPetById(cardid)
    else
        data=  Data.getUserCardById(cardid)
    end
    if(data==nil)then
        return
    end
    node:removeAllChildren()
    local item=AtlasFormationRole.new(2)
    node:addChild(item)
    item:setTag(pos)
    item:setData(data)
    item:setPositionY(node:getContentSize().height)
    item:setPositionX(node:getContentSize().width/2-self:getNode("pos4"):getContentSize().width/2)

    item.selectItemCallback=function (touchPos,cardid)
        self:onCancelCard(touchPos,cardid,item:getTag())
    end
    item.moveItemCallback=function (touchPos,cardid)
        self:onMoveCard(touchPos,cardid)
    end
    self:refreshFormation()
end


function ServerBattleFormationPanel:onCancelCard(touchPos,cardid,oldPos)
    local pos=  self:getPosItem(touchPos)
    self:stopShine()
    local isUnlock = Unlock.teamPos.isUnlock(pos)
    if(isUnlock==false)then
        return
    end


    if(DB.getItemType(cardid)==ITEMTYPE_PET and pos~=PET_POS and pos~=-1)then
        return
    elseif(DB.getItemType(cardid)==ITEMTYPE_CARD and pos==PET_POS)then
        return

    end
    self.selectedCardId=cardid
    if(pos~=-1)then
        if(pos==PET_POS)then
            return
        end
        self:setPosCardId(oldPos, self.curFormation[pos])
        self:setPosCardId(pos,self.selectedCardId)
    else
        self:setPosCardId(oldPos,0)
    end
end

function ServerBattleFormationPanel:onMoveCard(touchPos,cardid)
    local pos=  self:getPosItem(touchPos)

    local isUnlock = Unlock.teamPos.isUnlock(pos)
    if(isUnlock==false)then
        return
    end


    if(DB.getItemType(cardid)==ITEMTYPE_PET and pos~=PET_POS  )then
        self:stopShine()
        return
    elseif(DB.getItemType(cardid)==ITEMTYPE_CARD and pos==PET_POS)then
        self:stopShine()
        return

    end
    self:shinePos(pos)

end


function ServerBattleFormationPanel:onSelectCard(touchPos,cardid)
    self.selectedCardId=cardid
    local pos=  self:getPosItem(touchPos)

    self:stopShine()
    if(pos==-1)then
        if(Guide.curDragToItem  )then
            Guide.dispatch(Guide.curGuideChain.id,1)
        end
        return false
    end
    if(Guide.curDragToItem)then
        if(   self:getNode("pos"..pos)~=Guide.curDragToItem)then
            Guide.dispatch(Guide.curGuideChain.id,1)
            return
        end
    end
    local isUnlock = Unlock.teamPos.isUnlock(pos)
    if(isUnlock==false)then
        return
    end

    if(DB.getItemType(cardid)==ITEMTYPE_PET and pos==PET_POS)then
        self:setPosCardId(pos,self.selectedCardId)

    elseif(DB.getItemType(cardid)==ITEMTYPE_CARD and pos~=PET_POS)then

        self:setPosCardId(pos,self.selectedCardId)
        --播放人物音效
        if(self.lastSoundId)then
            gStopEffect(self.lastSoundId)
        end
        if isBanshuReview() == false then
            self.lastSoundId = gPlayEffect("sound/card/"..self.selectedCardId..".mp3")
        end
    end


end



function ServerBattleFormationPanel:onTouchBegan(target)
    if(target.touchName=="icon_country")then
        local   tip= Panel.popTouchTip(target,TIP_TOUCH_COUNTRY_INFO,self.country)
    end

end


function ServerBattleFormationPanel:getPosItem(pos)
    local dis=0
    for i=0, 6 do
        local itemPos= self:getNode("pos"..i):convertToWorldSpace(cc.p(0,0))
        local size= self:getNode("pos"..i):getContentSize()
        if(pos.x>itemPos.x -dis and
            pos.x<itemPos.x+size.width +dis and
            pos.y>itemPos.y -dis and
            pos.y<itemPos.y+size.height +dis
            )then
            return i
        end

    end

    return -1

end

function ServerBattleFormationPanel:initRivalInfo(idx)
    local rivalInfo = gServerBattle.rivalInfos[idx]
    -- print("rivalInfo team size is:", #rivalInfo.teamInfo)
    for key, cardInfo in pairs(rivalInfo.teamInfo) do
        local data =  DB.getCardById(cardInfo.cardid)
        if(data)then
            local node=self:getNode("rival_pos"..(key-1))
            local item=AtlasFormationRole.new(2)
            local card = {}
            card.cardid  = cardInfo.cardid
            card.weaponLv = cardInfo.weaponLv
            card.awakeLv  = cardInfo.awakeLv
            node:addChild(item)
            item:setTag(key)
            item:setData(card)
            item:setRotation3D(cc.vec3(0,-180,0))
            item:setPositionY(node:getContentSize().height)
            item:setPositionX(node:getContentSize().width * 1.1)
        end
    end
end

function ServerBattleFormationPanel:showConstellationFla()
    local selCircleId = gConstellation.getSelCircleId()
    if selCircleId ~= nil and selCircleId ~= 0 then
        local isAllActive = gConstellation.isAllGroupActived(selCircleId)
        if isAllActive then
            loadFlaXml("ui_xingzhen")
            local fla = gCreateFla("xingzhen_"..selCircleId,1)
            fla:setScale(0.85)
            self:replaceNode("fla_constellation",fla)
            self:getNode("layer_constellation"):setVisible(true)
        end
    else
        self:getNode("layer_constellation"):setVisible(false)
    end
end

return ServerBattleFormationPanel