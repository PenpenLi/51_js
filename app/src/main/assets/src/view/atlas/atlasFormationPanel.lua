local AtlasFormationPanel=class("AtlasFormationPanel",UILayer)

function AtlasFormationPanel:ctor(type,data)
    self.appearType = 1;
    self:init("ui/ui_atlas_formation.map")
    self.btns={
        "btn_card",
        "btn_pet",
    }

    self.panelType=type

    local temp=Data.getUserTeam(self.panelType)
    if(temp)then
        self.curFormation=clone(temp)
    else
        self.curFormation={}
    end
    self.isFirstEnter=false
    if(NetErr.isTeamEmpty(self.curFormation))then
        self.curFormation= Data.getUserTeam(TEAM_TYPE_ATLAS)
        Data.saveUserTeam(self.panelType,self.curFormation)
        self.curFormation=clone( Data.getUserTeam(TEAM_TYPE_ATLAS))
        self.isFirstEnter=true
    end
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
    self.curData=data
    self:initFormation()
    self:refreshFormation()
    self:countPower()
    self.isMainLayerGoldShow=false
    self.isMainLayerMenuShow=false
    self:getNode("btn_pet"):setVisible(Unlock.isUnlock(SYS_PET,false))

    if(self.panelType ~= TEAM_TYPE_TOWER)then
        Unlock.system.petFormation.checkFirstEnter();
    end

    for i=0, 6 do
        if(self:getNode("shine_pos"..i))then
            self:getNode("shine_pos"..i):setVisible(false)
        end
    end

    if(self.panelType==TEAM_TYPE_ARENA_DEFEND or
        self.panelType==TEAM_TYPE_FAMILY_WAR or
        self.panelType==TEAM_TYPE_WORLD_WAR_DEFEND or
        self.panelType==TEAM_TYPE_WORLD_BOSS or 
        self.panelType==TEAM_TYPE_CROSS_TREASURE)then
        self:getNode("btn_save"):setVisible(true)
        self:getNode("btn_enter"):setVisible(false)
    end


    if(Guide.isGuiding())then
        self:setTouchEnable("btn_close",false)
        local function onCallback()
            self:setTouchEnable("btn_close",true)
        end
        schedule( self:getNode("btn_close"),onCallback,1.5)
    end

    self:getNode("btn_constellation"):setVisible(Unlock.isUnlock(SYS_CONSTELLATION,false))

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

    table.sort(gUserPets,sort2);
    --  self:shinePos(1)

    self:showConstellationFla()
end

function AtlasFormationPanel:onPopback()
    Scene.clearLazyFunc("formation")
end

function AtlasFormationPanel:stopShine()
    for i=0, 6 do
        if(self:getNode("shine_pos"..i))then
            self:getNode("shine_pos"..i):setVisible(false)
            self:getNode("shine_pos"..i):stopAllActions()
        end
    end
end

function AtlasFormationPanel:shinePos(pos)
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

function  AtlasFormationPanel:countPower()
    local power=CardPro.countFormation(self.curFormation,self.panelType)
    self:setLabelAtlas("txt_power",power)


    self:countryIcon()

end




function AtlasFormationPanel:countryIcon()

    self.country=CardPro.getFormationCountry(self.curFormation)
    Icon.changeCountryIcon(self:getNode("icon_country"),self.country)

end

function  AtlasFormationPanel:events()
    return {GUIDE_EVENT_ID_START_FORMATION,GUIDE_EVENT_ID_END_FORMATION,EVENT_ID_CONSTELLATION_ITEM_CHOOSE}
end


function AtlasFormationPanel:dealEvent(event,param)
    if(event==GUIDE_EVENT_ID_START_FORMATION)then
        Guide.hideHand(true)
    elseif(event==GUIDE_EVENT_ID_END_FORMATION)then
        self:getNode("icon_drag"):setVisible(false)
        Guide.showHand()
        self:getNode("icon_drag"):stopAllActions()
        for pos=0, 6 do
            local node=self:getNode("pos"..pos)
            node.isRunAction=false
        end
    elseif(event==EVENT_ID_CONSTELLATION_ITEM_CHOOSE)then
        self:showConstellationFla()
        self:countPower()
    end
end

function AtlasFormationPanel:initFormationPos()
    -- body
    for i=3,6 do
        local isUnlock = Unlock.teamPos.isUnlock(i);
        local lock = self:getNode("lock"..i);
        if lock then
            local unlockLevel = toint(gUnlockLevel.posLevel[i-2]);
            self:setLabelString("txt_lock"..i,gGetWords("unlockWords.plist","unlock_tip_pos",unlockLevel));
            lock:setVisible(not isUnlock);
        end
        --[[  if i == 6 then
        self:getNode("icon_pet"):setVisible(isUnlock);
        end]]
    end
end

function AtlasFormationPanel:initFormation()

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
        end
    end
    self:countPower()
end


function AtlasFormationPanel:moveGuideHand(node )
    if(Guide.curClickItem==nil or node==nil)then
        return
    end



    if(self.touchEnable~=false     and node.isRunAction~=true)then
        node.isRunAction=true
        self:getNode("icon_drag"):setVisible(true)
        self:getNode("icon_drag"):stopAllActions()
        local toPos=   node:convertToWorldSpace(cc.p(0,0))
        local size=node:getContentSize()
        toPos=self:getNode("icon_drag"):getParent():convertToNodeSpace(toPos)
        local fromPos=toPos
        toPos.x=toPos.x+size.width/2
        toPos.y=toPos.y+size.height/2

        fromPos=   Guide.curClickItem:convertToWorldSpace(cc.p(0,0))
        fromPos=self:getNode("icon_drag"):getParent():convertToNodeSpace(fromPos)

        local function  callback()
            self:getNode("icon_drag"):setPosition(cc.p(fromPos.x+size.width/2,fromPos.y+size.height/2))
            self:getNode("icon_drag"):stopAllActions()
            self:getNode("icon_drag"):runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(1,toPos),
                    cc.CallFunc:create(callback)
                )
            )
        end
        callback()
    end
end

function AtlasFormationPanel:getItemByCardid(cardid)

    for key, item in pairs( self:getNode("scroll").items) do
        if(item.curCard.cardid==cardid)then
            return item
        end
    end
    return nil
end

function AtlasFormationPanel:getEmptyItem()

    for key, item in pairs( self:getNode("scroll").items) do
        if(item:getNode("icon_selected") and item:getNode("icon_selected"):isVisible()==false)then
            return item
        end
    end
    return nil
end

function AtlasFormationPanel:getGuideItem(name)
    local params= string.split(name,"_")
    if(toint(params[1])==0)then
        local node=  self:getItemByCardid(toint(params[2]))
        if(node)then
            return node:getNode("touch_node")
        end
    elseif(toint(params[1])==1)then
        local node=self:getNode("pos"..params[2])
        self:moveGuideHand(node)
        self:shinePos(params[2])
        self.guideTargetPos=params[2]
        return  node

    elseif(toint(params[1])==2)then
        local node=  self:getEmptyItem()
        if(node)then
            return node:getNode("touch_node")
        end
    end 

    return nil
end


function  AtlasFormationPanel:refreshFormation()
    for key, item in pairs( self:getNode("scroll").items) do
        item:setSelected(false)
    end


    for pos, cardid in pairs(self.curFormation) do
        for key, item in pairs( self:getNode("scroll").items) do
            if(item.curCard.cardid==cardid)then
                item:setSelected(true)
            elseif(item.curCard.petid==cardid)then
                item:setSelected(true)
            end
        end
    end

    --[[ if Unlock.teamPos.isUnlock(PET_POS) then
    if(self.curFormation[PET_POS] and self.curFormation[PET_POS]~=0)then
    self:getNode("icon_pet"):setVisible(false)
    else
    self:getNode("icon_pet"):setVisible(true)
    end
    end]]
end

function AtlasFormationPanel:showType(type)

    Scene.clearLazyFunc("formation")
    self:getNode("scroll"):clear()
    local datas={}
    if(type==0)then
        datas=gUserCards
    else
        datas=gUserPets
    end
    local drawNum=4
    for key, pet in pairs(datas) do
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


function AtlasFormationPanel:resetBtnTexture()


    for key, btn in pairs(self.btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end
end

function AtlasFormationPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end

function AtlasFormationPanel:onTouchEnded(target)

    Panel.clearTouchTip()
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_card"then
        self:showType(0)
        self:selectBtn( target.touchName)
    elseif  target.touchName=="btn_pet"then
        self:showType(1)
        self:selectBtn( target.touchName)

        --[[  elseif target.touchName=="btn_all"then
        self:showType(0)
        self:selectBtn( target.touchName)
        elseif target.touchName=="btn_def"then
        self:showType(1)
        self:selectBtn( target.touchName)
        elseif target.touchName=="btn_phy_attack"then
        self:showType(CARD_TYPE_PHY_ATTACK)
        self:selectBtn( target.touchName)
        elseif target.touchName=="btn_magic_attack"then
        self:showType(CARD_TYPE_MAGIC_ATTACK)
        self:selectBtn( target.touchName)
        elseif target.touchName=="btn_treat"then
        self:showType(CARD_TYPE_TREAT)
        self:selectBtn( target.touchName)
        ]]
    elseif target.touchName == "btn_one" then
        self:autoFormation();
    elseif target.touchName == "btn_constellation" then
        Panel.popUp(PANEL_CONSTELLATION_SEL_CIRCLE)
    elseif target.touchName=="btn_enter" or  target.touchName=="btn_save" then
        if(NetErr.saveTeam(self.curFormation)==false)then
            return
        end
        Data.saveUserTeam(self.panelType,self.curFormation)

        if(self.panelType==TEAM_TYPE_ATLAS)then
            Panel.pushRePopupPanel(PANEL_ATLAS,{mapid=self.curData.mapid,stageid=self.curData.mapid,type=self.curData.type})

            Net.sendAtlasEnter(self.curData.mapid,self.curData.stageid,self.curData.type,self.curFormation)

        elseif(self.panelType==TEAM_TYPE_ATLAS_PET_TOWER)then

            -- Panel.pushRePopupPanel(PANEL_PET_TOWER)
            local func = function()
                Net.sendPetAtlasInfo();
            end
            Panel.pushRePopupPre(func);
            Net.sendPetAtlasEnter(self.curData)


        elseif(self.panelType==TEAM_TYPE_BATH_MOLEST)then
            Net.sendBathMolest(self.curData);

        elseif(self.panelType==TEAM_TYPE_DRINK_LOOT)then
            Net.sendDrinkLoot(self.curData.roomid,self.curData.seatIndex);


        elseif(self.panelType==TEAM_TYPE_FAMILY_FIGHT)then
            Net.sendFamilyFight(self.curData);

        elseif(self.panelType==TEAM_TYPE_BUDDY_FIGHT)then
            Net.sendBuddyFight(self.curData)

        elseif(self.panelType==TEAM_TYPE_ATLAS_CRUSADE)then
            local func = function()
                Net.sendCrusadeInfo();
            end
            Panel.pushRePopupPre(func);

            Net.sendCrusadeFight(self.curData.id,self.curData.type)
        elseif(
            self.panelType==TEAM_TYPE_ATLAS_ACT_GOLD or
            self.panelType==TEAM_TYPE_ATLAS_ACT_EXP or
            self.panelType==TEAM_TYPE_ATLAS_ACT_PET or
            self.panelType==TEAM_TYPE_ATLAS_ACT_EQUSOUL or
            self.panelType==TEAM_TYPE_ATLAS_ACT_ITEMAWAKE
            )then
            Panel.pushRePopupPanel(PANEL_ACTIVITY)
            Net.sendActAtlasEnter(self.curData.stageid,self.curData.type )

        elseif(self.panelType==TEAM_TYPE_ARENA_ATTACK)then
            Panel.pushRePopupPanel(PANEL_ARENA)
            Net.sendArenaChallenge(self.curData.rank,self.curData.id,self.curData.rid)
        elseif(self.panelType==TEAM_TYPE_ATLAS_MINING_STATUS)then
            Panel.pushRePopupPanel(PANEL_DIG_MINE,false,true)
            Battle.win = 0
            Net.sendMiningEnter()
            -- elseif(self.panelType==TEAM_TYPE_WORLD_BOSS)then
            --     Panel.pushRePopupPanel(PANEL_WORLD_BOSS)
            --     Net.sendWorldBossFight()
         elseif(self.panelType == TEAM_TYPE_TOWER)then
            Panel.pushRePopupPanel(PANEL_TOWER,true)
            Net.sendTowerFightEnter();
            Guide.clearGuide();
        elseif(self.panelType == TEAM_TYPE_CAVE)then
            Panel.pushRePopupPanel(PANNEL_PET_EXPLORE)
            Panel.pushRePopupPanel(PANNEL_PET_EXPLORE_HD,{id=self.curData.dbid})
            Net.sendCaveEvent5fight(self.curData.dbid,self.curData.index);
            Guide.clearGuide();
        -- Net.sendTowerAction(self.curData.row,self.curData.col);
        elseif self.panelType == TEAM_TYPE_ATLAS_MINING then
            -- Panel.pushRePopupPanel(PANEL_MINE_ATLAS_DETAIL, self.curData.mapId)
            local func1 = function()
                if gMainBgLayer == nil then
                    Scene.enterMainScene()
                end
                Net.sendMiningChapList(function(  )
                    Panel.popUp(PANEL_MINE_ATLAS_DETAIL, gDigMine.mapId)
                end ) 
            end
            local func2 = function()
                gDigMine.processSendInitMsg(func1)
            end
            Panel.pushRePopupPre(func2)
            Net.sendChapterEnter(self.curData.mapId, self.curData.stageId)
        elseif self.panelType == TEAM_TYPE_FAMILY_STAGE then
            local func = function()
                local function  callback()
                    if gMainBgLayer == nil then
                        Scene.enterMainScene()
                    end
                    Net.sendFamilyStageInfo()               
                end
                Net.sendFamilyGetInfo(callback)
            end
            Panel.pushRePopupPre(func)
            local buffList = DB.getFamilyFightBuff()
            Net.sendFamilyStageFight(self.curData.stageId, self.curData.buffId)
        elseif self.panelType == TEAM_TYPE_LOOT_FOOD then
            Panel.pushRePopupPanel(PANEL_FOODFIGHT_MAIN)
            Net.sendLootfoodFight(self.curData.uid,self.curData.sid)
        elseif self.panelType == TEAM_TYPE_LOOT_FOOD_REVENGE then
            local ret = {}
            --ret.revengenum = self.curData.revengenum
            ret.revengebuy = self.curData.revengebuy
            ret.food1 = self.curData.food1
            ret.food2 = self.curData.food2
            ret.isUnlock = self.curData.isUnlock
            ret.isNeedSend = false

            Panel.pushRePopupPanel(PANEL_FOODFIGHT_MAIN)
            Panel.pushRePopupPanel(PANEL_FOODFIGHT_RECORD,ret)
            Net.sendLootfoodRevenge(self.curData.id)
        elseif(self.panelType==TEAM_TYPE_CONSTELLATION)then
            Panel.pushRePopupPanel(PANEL_CONSTELLATION_MAIN, function()
                    if gConstellation.getLeftFightNum() > 0 then
                        Net.sendCircleFightinfo()
                    end
                end
            )

            Battle.win = 0
            Net.sendCircleFightEnter()
        end
        Panel.popBack(self:getTag())
    end

end

function AtlasFormationPanel:autoFormation()

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

    self.curFormation={}
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


    local userPets =  gUserPets
    if(table.count(userPets)~=0)then
        if(userPets[1] )then
            self:setPosCardId(PET_POS,userPets[1].petid);
        end
    end


end

function AtlasFormationPanel:setPosCardId(pos ,cardid)
    local node=  self:getNode("pos"..pos)
    if(node==nil)then
        return
    end
    if(cardid==0 or cardid==nil)then
        self.curFormation[pos]=0
        node:removeAllChildren()
        self:refreshFormation()
        self:countPower()
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
    self:countPower()
end


function AtlasFormationPanel:onCancelCard(touchPos,cardid,oldPos)
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

function AtlasFormationPanel:onMoveCard(touchPos,cardid)
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


function AtlasFormationPanel:onSelectCard(touchPos,cardid)
    self.selectedCardId=cardid
    local pos=  self:getPosItem(touchPos)
    local isUnlock = Unlock.teamPos.isUnlock(pos)
    if(pos~=-1 and self.guideTargetPos and isUnlock)then
        pos=toint(self.guideTargetPos)
    end

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



function AtlasFormationPanel:onTouchBegan(target)
    if(target.touchName=="icon_country")then
        local   tip= Panel.popTouchTip(target,TIP_TOUCH_COUNTRY_INFO,self.country)
    end

end


function AtlasFormationPanel:getPosItem(pos)
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

function AtlasFormationPanel:showConstellationFla()
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




return AtlasFormationPanel