RedPoint={}
RedPoint.bolCardDataDirty = false;

RedPoint.menuAnchorPoint = cc.p(0.8,0.8);

function RedPoint.getRedPoint(node)
    local red=cc.Sprite:create("images/ui_public1/gaode-red.png")
    red:setTag(10011)
    red:setLocalZOrder(10011)
    return red
end

function RedPoint.refresh(node,bolRedPot,anchor)
    if bolRedPot then
        RedPoint.add(node,anchor);
    else
        RedPoint.remove(node);
    end
end


function RedPoint.addFightNode(node,offset,time,flaName)
    if(node==nil)then
        return
    end

    local fla= node:getChildByTag(10020)
    if(fla)then
        fla:setVisible(true)
        return
    end
    loadFlaXml("ui_family_war")
    fla=gCreateFla(flaName,1)
    fla:setTag(10020)
    fla:setScale(0.7)
    gSetCameraMask(fla,cc.CameraFlag.USER1)
    gSetDepth2d(fla,true)
    node:addChild(fla)
    fla:setPositionY(offset)
    return fla
end


function RedPoint.addTimeNode(node,time,flaName)
    if(node==nil)then
        return
    end

    local fla= node:getChildByTag(10019)

    if(fla )then
        if(fla.time~=time)then
            local lab= RedPoint.createLabelSprite(time)
            fla.time=time
            RedPoint.changeFlaLabel(fla,lab)
        end
        return fla
    end

    loadFlaXml("ui_main_time")
    fla=gCreateFla(flaName,1)
    fla:setTag(10019)
    node:addChild(fla)
    local lab= RedPoint.createLabelSprite(time)
    fla:setDepth2D(true)
    fla.time=time
    gSetCameraMask(fla,cc.CameraFlag.USER1)
    RedPoint.changeFlaLabel(fla,lab)
    return fla
end

function RedPoint.changeFlaLabel(fla,lab)
    local bone= fla:getBone("time")
    lab:setDepth2D(true)
    gSetCameraMask(lab,cc.CameraFlag.USER1)
    local armature=bone:getChildArmature()
    if(bone)then
        bone:addDisplay(lab,1)
        bone:changeDisplayWithIndex(1, true)
    end

end

function RedPoint.createLabelSprite(txt)
    local ttfConfig = {}
    ttfConfig.fontFilePath = gCustomFont
    ttfConfig.fontSize = 20
    local texture =  cc.Texture2D:new()
    texture:initWithString(txt,ttfConfig);
    local ret=  cc.Sprite:createWithTexture(texture);
    return ret
end
function RedPoint.removeTime(node)
    if(node==nil)then
        return
    end
    local red= node:getChildByTag(10019)
    if(red)then
        red:setVisible(false)
    end
end

function RedPoint.removeFightNode(node)
    if(node==nil)then
        return
    end
    local red= node:getChildByTag(10020)
    if(red)then
        red:setVisible(false)
    end
end

function RedPoint.add(node,anchor)
    if(node==nil)then
        return
    end
    local red= node:getChildByTag(10011)
    if(red==nil)then
        red=RedPoint.getRedPoint(node)
        if anchor then
            gAddChildByAnchorPos(node,red,anchor);
        else
            node:addChild(red)
            local size=node:getContentSize()
            pos.x=  size.width -10
            pos.y= size.height -10
            red:setPosition(pos)
        end
    end
    red:setVisible(true)
    return red
end



function RedPoint.remove(node)
    if(node==nil)then
        return
    end
    local red= node:getChildByTag(10011)
    if(red)then
        red:setVisible(false)
    end
end

function RedPoint.setUILayerPos(red,node)

    local size=node:getContentSize()
    local pos={}
    pos.x=  size.width -10
    pos.y=-10
    red:setPosition(pos)
end

function RedPoint.bolCardData()
    if(RedPoint.bolCardDataDirty==false)then
        return
    end
    RedPoint.bolCardDataDirty=false
    local needEquipUpgade={}
    local needEquipActivate={}
    local needEquipUpquality={}
    local needSkillUpgade={}
    local needUpQuality={}
    local needEvolve={}
    local needRelation={}
    local needAwake = {}
    local needRaise = {}
    local needWeaponUpgrade = {}
    local needTreasure = {}
    local canGet = {}
    local isUnlockWeapon=Unlock.isUnlock(SYS_WEAPON,false)
    local isUnlockTreasure=Unlock.isUnlock(SYS_TREASURE,false)
    local isUnlockSkill=Unlock.isUnlock(SYS_SKILL,false)
    Data.sortUserCard()
    for key, card in pairs(gUserCards) do
        local temp
        if(card.ignore==false)then
            temp = CardPro.hasEquipUpgrade(card);
            if(table.count(temp)~=0)then
                needEquipUpgade[card.cardid]=temp
            end


            temp = CardPro.hasRelationActivate(card);
            if(table.count(temp)~=0)then
                needRelation[card.cardid]=temp
            end


            local temp=CardPro.hasEquipUpQuality(card)
            if(table.count(temp)~=0)then
                needEquipUpquality[card.cardid]=temp
            end

            local temp=CardPro.hasEquipActivate(card)
            if(table.count(temp)~=0)then
                needEquipActivate[card.cardid]=temp
            end


            if(CardPro.canEvolve(card)==true)then
                needEvolve[card.cardid]=true
            end

            if(CardPro.canAwake(card)==true)then
                needAwake[card.cardid]=true
            end


            if(isUnlockWeapon and CardPro.canWeaponUpgrade(card)==true)then
                needWeaponUpgrade[card.cardid]=true
            end


            if(isUnlockSkill and CardPro.hasSkillUpgrade(card)==true)then
                needSkillUpgade[card.cardid]=true
            end



            if(isUnlockTreasure )then
                needTreasure[card.cardid]=CardPro.canTreasureEquip(card)
            end



            if(CardPro.isAllEquipUpgrade(card)==true  and CardPro.canUpQuality(card)==true)then
                needUpQuality[card.cardid]=true
            end
        else
            if(CardPro.canEvolve(card)==true)then
                needEvolve[card.cardid]=true
            end
        end

    end

    for key, card in pairs(card_db) do
        if(card.show==true and card.cardid<10500)then
            local userCard=  Data.getUserCardById(card.cardid)
            if(userCard==nil)then
                card.curSoulNum= Data.getSoulsNumById(card.cardid)
                card.needSoulNum=DB.getNeedInitSoulNum(card.evolve-1)
                if(card.curSoulNum>=card.needSoulNum)then
                    canGet[card.cardid] = true;
                end
            end
        end
    end

    RedPoint.needEquipUpgade=needEquipUpgade
    RedPoint.needEquipActivate=needEquipActivate
    RedPoint.needEquipUpquality=needEquipUpquality
    RedPoint.needSkillUpgade=needSkillUpgade
    RedPoint.needUpQuality=needUpQuality
    RedPoint.needEvolve=needEvolve
    RedPoint.needRelation=needRelation
    RedPoint.needAwake=needAwake
    RedPoint.needRaise=needRaise
    RedPoint.needWeaponUpgrade=needWeaponUpgrade
    RedPoint.needTreasure=needTreasure
    RedPoint.canGet=canGet

end

--卡牌相关红点
function RedPoint.bolCard()
    RedPoint.bolCardData()
    if(RedPoint.bolCardViewDirty==false)then
        return
    end
    Data.redpos.bolHero=false
    RedPoint.bolCardViewDirty=false


    local needEquipUpgade=RedPoint.needEquipUpgade
    local needEquipActivate=RedPoint.needEquipActivate
    local needEquipUpquality=RedPoint.needEquipUpquality
    local needSkillUpgade=RedPoint.needSkillUpgade
    local needUpQuality=RedPoint.needUpQuality
    local needEvolve=RedPoint.needEvolve
    local needRelation=RedPoint.needRelation
    local needAwake=RedPoint.needAwake
    local needRaise=RedPoint.needRaise
    local needWeaponUpgrade=RedPoint.needWeaponUpgrade
    local canGet=RedPoint.canGet
    local needTreasure=  RedPoint.needTreasure


    if(gMainLayer~=nil and gMainMoneyLayer~=nil and gMainMoneyLayer.getNode)then
        if(table.count(needEquipUpgade)~=0 or
            table.count(needSkillUpgade)~=0 or
            table.count(needRelation)~=0 or
            table.count(needAwake)~=0 or
            table.count(needRaise)~=0 or
            table.count(needWeaponUpgrade)~=0 or
            table.count(needTreasure)~=0 or
            table.count(needEvolve)~=0 or
            table.count(needUpQuality)~=0 or
            table.count(needEquipUpquality)~=0 or
            table.count(needEquipActivate)~=0 or
            table.count(canGet)~=0
            )then
            Data.redpos.bolHero = true;
        else
            Data.redpos.bolHero = false;
        end

        if(  table.count(needWeaponUpgrade)~=0 )then
            RedPoint.add(gMainMoneyLayer:getNode("btn_weapon"),RedPoint.menuAnchorPoint)
        else
            RedPoint.remove(gMainMoneyLayer:getNode("btn_weapon"))
        end
    end

    local panel=Panel.getTopPanel(Panel.popPanels)

    if(panel and panel.__panelType==PANEL_CARD)then
        if(panel.haveItems)then
            for key, item in pairs(panel.haveItems) do
                if(item.curCard)then
                    if(needEquipUpgade[item.curCard.cardid]~=nil or
                        needRelation[item.curCard.cardid]~=nil or
                        needAwake[item.curCard.cardid]~=nil or
                        needRaise[item.curCard.cardid]~=nil or
                        needWeaponUpgrade[item.curCard.cardid]~=nil or
                        needTreasure[item.curCard.cardid]~=nil or
                        needSkillUpgade[item.curCard.cardid]==true or
                        needEvolve[item.curCard.cardid]==true  or
                        needUpQuality[item.curCard.cardid]==true  or
                        needEquipUpquality[item.curCard.cardid]~=nil  or
                        needEquipActivate[item.curCard.cardid]~=nil  )then
                        local red=RedPoint.add(item)
                        RedPoint.setUILayerPos(red,item)
                    else
                        RedPoint.remove(item)
                    end
                end
            end
        end

        if(panel.notHaveItems)then
            for key, item in pairs(panel.notHaveItems) do
                if(canGet[item.curCardid]~=nil)then
                    local red=RedPoint.add(item)
                    RedPoint.setUILayerPos(red,item)
                else
                    RedPoint.remove(item)
                end
            end
        end
    end

    if(panel and panel.__panelType==PANEL_CARD_INFO  )then
        if(panel.curCard)then

            local bCurCardUpgrade = CardPro.canOneEquipUpgrade(panel.curCard);
            if Unlock.isUnlock(SYS_QUICKUPGRADE,false) then
                RedPoint.refresh(panel:getNode("btn_batch_strong"),bCurCardUpgrade);
            end

            RedPoint.refresh(panel:getNode("btn_more2"),canGet[panel.curCard.cardid]);

            if(needSkillUpgade[panel.curCard.cardid]==true)then
                RedPoint.add(panel:getNode("btn_skill"))
            else
                RedPoint.remove(panel:getNode("btn_skill"))
            end


            if(needRelation[panel.curCard.cardid])then
                RedPoint.add(panel:getNode("btn_relation"))
            else
                RedPoint.remove(panel:getNode("btn_relation"))
            end

            if(needEvolve[panel.curCard.cardid]==true or needAwake[panel.curCard.cardid] == true)then
                RedPoint.add(panel:getNode("btn_evolve"),cc.p(0.8,0.9))
            else
                RedPoint.remove(panel:getNode("btn_evolve"))
            end


            if(  needRaise[panel.curCard.cardid] == true or needWeaponUpgrade[panel.curCard.cardid] == true )then
                RedPoint.add(panel:getNode("btn_weapon"),cc.p(0.8,0.9))
            else
                RedPoint.remove(panel:getNode("btn_weapon"))
            end

            if(  needTreasure[panel.curCard.cardid] ~=nil )then
                RedPoint.add(panel:getNode("btn_treasure"),cc.p(0.8,0.9))
                if(panel.treasurePanel)then
                    RedPoint.add(panel.treasurePanel:getNode("btn_treasure"),cc.p(0.9,0.9))
                end

                if(panel.treasurePanel )then

                    for i=1, 4 do
                        local treasures=  needTreasure[panel.curCard.cardid][i]
                        if(panel.treasurePanel:getNode("icon_treasure"..i).treasure)then

                            if(table.getn(treasures)>0)then
                                RedPoint.add(panel.treasurePanel:getNode("container"..i),cc.p(1.2,-0.4))

                            else
                                RedPoint.remove(panel.treasurePanel:getNode("container"..i))
                            end
                        else
                            RedPoint.remove(panel.treasurePanel:getNode("container"..i))
                        end

                    end
                    if( panel.treasurePanel.bagPanel and panel.treasurePanel.bagPanel:isVisible())then
                        for key, var in pairs(panel.treasurePanel.bagPanel:getNode("bag_scroll").items) do
                            RedPoint.remove(var:getNode("icon"))
                        end

                        local treasures=needTreasure[panel.curCard.cardid][panel.treasurePanel.lastTreasureIdx]
                        for key, var in pairs(treasures) do
                            local bagItem=panel.treasurePanel:getBagItemById(var.id)
                            if(bagItem)then
                                RedPoint.add(bagItem:getNode("icon"),cc.p(0.85,0.85))
                            end
                        end
                    end

                end
            else
                if(panel.treasurePanel)then
                    RedPoint.remove(panel.treasurePanel:getNode("btn_treasure"))
                    for i=1, 4 do
                        RedPoint.remove(panel.treasurePanel:getNode("container"..i))
                    end
                    if( panel.treasurePanel.bagPanel and panel.treasurePanel.bagPanel:isVisible())then
                        for key, var in pairs(panel.treasurePanel.bagPanel:getNode("bag_scroll").items) do
                            RedPoint.remove(var:getNode("icon"))
                        end
                    end
                end
                RedPoint.remove(panel:getNode("btn_treasure"))
            end
            --[[
            if Data.redpos.bolMaxSkillPoint then
            RedPoint.add(panel:getNode("btn_skill"))
            else
            RedPoint.remove(panel:getNode("btn_skill"))
            end]]

            local equipGrades=needEquipUpgade[panel.curCard.cardid]
            local equipUps=needEquipUpquality[panel.curCard.cardid]
            local equipActivates=needEquipActivate[panel.curCard.cardid]
            -- if needEquipUpquality then
            --     print_lua_table(needEquipUpquality);
            -- end
            for i=0, MAX_CARD_EQUIP_NUM-1 do
                RedPoint.refresh(panel:getNode("equip"..i),
                    (equipGrades and equipGrades[i])
                    or (equipUps and equipUps[i])
                    or (equipActivates and equipActivates[i]));
            end


            if(panel.equipPanel )then

                RedPoint.refresh(panel.equipPanel:getNode("btn_upgrade"),equipGrades and equipGrades[panel.equipPanel.curIdx]);

                if(equipUps and equipUps[panel.equipPanel.curIdx]==true) then
                    RedPoint.add(panel.equipPanel:getNode("btn_upquality"))
                else
                    RedPoint.remove(panel.equipPanel:getNode("btn_upquality"))
                end

                if(equipActivates and equipActivates[panel.equipPanel.curIdx]==true) then
                    RedPoint.add(panel.equipPanel:getNode("btn_put"))
                else
                    RedPoint.remove(panel.equipPanel:getNode("btn_put"))
                end
            end


            if(panel.relationPanel )then
                if(needRelation[panel.curCard.cardid])then
                    for key, item in pairs(panel.relationPanel:getNode("scroll").items) do

                        RedPoint.remove(item:getNode("btn_activate"))
                        if(item.relationData and needRelation[panel.curCard.cardid][item.relationData.id]==1)then
                            RedPoint.add(item:getNode("btn_activate"))
                        end
                    end
                end
            end


            if(needUpQuality[panel.curCard.cardid]==true)then
                RedPoint.add(panel:getNode("btn_wakeup"))
            else
                RedPoint.remove(panel:getNode("btn_wakeup"))
            end
        end
    end


    if(panel and panel.__panelType==PANEL_CARD_WEAPON_RAISE  )then
        for key, item in pairs(panel:getNode("scroll").items) do
            local isNeedRaise=needRaise[item.curData.cardid]
            local isNeedStrong=needWeaponUpgrade[item.curData.cardid]
            if(isNeedRaise   or isNeedStrong )then
                RedPoint.add(item:getNode("icon"))
            else
                RedPoint.remove(item:getNode("icon"))
            end
        end


        local isNeedRaise=needRaise[panel.curCardid]
        local isNeedStrong=needWeaponUpgrade[panel.curCardid]

        if(isNeedRaise)then
            RedPoint.add(panel:getNode("btn_do_raise"))
            RedPoint.add(panel:getNode("btn_raise"))
        else
            RedPoint.remove(panel:getNode("btn_do_raise"))
            RedPoint.remove(panel:getNode("btn_raise"))
        end


        if(isNeedStrong)then
            RedPoint.add(panel:getNode("btn_strong"))
            RedPoint.add(panel:getNode("btn_do_strong"))
        else
            RedPoint.remove(panel:getNode("btn_strong"))
            RedPoint.remove(panel:getNode("btn_do_strong"))
        end


    end
end

function RedPoint.friend()

    if(Data.redpos.bolBuddyApply or Data.redpos.bolBuddyHp) then
        RedPoint.add(gMainLayer:getNode("btn_friend"),RedPoint.menuAnchorPoint);
    else
        RedPoint.remove(gMainLayer:getNode("btn_friend"));
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if panel.__panelType == PANEL_FRIEND then
            RedPoint.refresh(panel:getNode("btn_add"),Data.redpos.bolBuddyApply);
            RedPoint.refresh(panel:getNode("btn_rec_all"),Data.redpos.bolBuddyHp);
        elseif panel.__panelType == PANEL_FRIEND_ADD then
            RedPoint.refresh(panel:getNode("btn_app"),Data.redpos.bolBuddyApply);
        end
    end

end

function RedPoint.chat()

    local bolChat = Data.redpos.bolChatFriend or Data.redpos.bolChatFamily or Data.redpos.bolChatWorld or Data.redpos.bolChatSystem;
    if(bolChat) then
        RedPoint.add(gMainLayer:getNode("btn_chat"),cc.p(0.75,0.75));
    else
        RedPoint.remove(gMainLayer:getNode("btn_chat"));
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if panel.__panelType == PANEL_FAMILY_HOME then
            RedPoint.refresh(panel:getNode("btn_chat"),bolChat,cc.p(0.75,0.75));
        end

        if panel.__panelType == PANEL_CHAT then
            if (panel.selectedBtn == "btn_friend") then
                Data.redpos.bolChatFriend = false;
            end
            if (panel.selectedBtn == "btn_family") then
                Data.redpos.bolChatFamily = false;
            end
            if (panel.selectedBtn == "btn_world") then
                Data.redpos.bolChatWorld = false;
            end
            if (panel.selectedBtn == "btn_system") then
                Data.redpos.bolChatSystem = false;
            end
            RedPoint.refresh(panel:getNode("btn_friend"),Data.redpos.bolChatFriend);
            RedPoint.refresh(panel:getNode("btn_family"),Data.redpos.bolChatFamily);
            RedPoint.refresh(panel:getNode("btn_world"),Data.redpos.bolChatWorld);
            RedPoint.refresh(panel:getNode("btn_system"),Data.redpos.bolChatSystem);
            local scroll = panel:getNode("friend_scroll")
            for key, item in pairs(scroll.items) do
                if(item:getNode("bg"):isVisible()) then
                    RedPoint.refresh(item:getNode("bg0"),false)
                    if (Data.redpos.bolChatFriendItem ~= nil) then
                        Data.redpos.bolChatFriendItem[item.curData.uid] = false
                    end
                elseif (Data.redpos.bolChatFriendItem ~= nil) then
                    RedPoint.refresh(item:getNode("bg0"),Data.redpos.bolChatFriendItem[item.curData.uid])
                end
            end
            -- RedPoint.refresh(panel:getNode("btn_rec_all"),Data.redpos.bolBuddyHp);
            -- elseif panel.__panelType == PANEL_FRIEND_ADD then
            --     RedPoint.refresh(panel:getNode("btn_app"),Data.redpos.bolBuddyApply);

        end
    end

end

function RedPoint.pet()
    if Unlock.isUnlock(SYS_PET,false) == false then
        return;
    end

    -- local levels=  DB.getClientParam("PET_UNLOCK_LEVEL")
    -- levels =string.split(levels,";")

    -- local ids=  DB.getClientParam("PET_UNLOCK_LIST")
    -- ids=  string.split(ids,";")

    local noUnlockIds={}
    for key, pet in pairs(pet_db) do
        if(pet.show==true and gUserInfo.level>= toint(pet.unlocklevel) and Data.getUserPetById(toint(pet.petid))==nil )then
            local curSoulNum=Data.getPetSoulsNumById(pet.petid);
            -- print("curSoulNum = "..curSoulNum);
            -- print("pet.unlocksoul = "..pet.unlocksoul);
            if(curSoulNum >= toint(pet.unlocksoul))then
                noUnlockIds[toint(pet.petid)]=1
            end
        end
    end

    Data.redpos.bolPetRelationActivate = false
    local relations=DB.getRelationByType(2,1)
    for key, var in pairs(relations) do
        local cards=string.split(var.cardlist,";")
        local relationData={}
        relationData.id=var.relationid
        relationData.level=Data.getRelationLevelById(var.relationid)
        local maxLevel=DB.getMaxRelationLevel(var.relationid)
        local curIconIdx=1
        local activateEnable=false
        local hasAll=true
        local totalStar=0
        for key, cardid in pairs(cards) do
            cardid=toint(cardid)
            local card=Data.getUserPetById(cardid)
            if(card==nil)then
                hasAll=false
            else
                totalStar=totalStar+math.min(card.grade,5);  
            end
            curIconIdx=curIconIdx+1
        end
        if(relationData.level>maxLevel)then
            relationData.level=maxLevel
        end

        if(relationData.level==0 and hasAll)then
            Data.redpos.bolPetRelationActivate = true
            break;
        end
        if(relationData.level<maxLevel)then
            local levelData=DB.getRelationById(var.relationid,relationData.level+1)
            Data.redpos.bolPetRelationActivate=totalStar>=levelData.param and hasAll
            if(Data.redpos.bolPetRelationActivate)then
                break
            end
        end
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(table.count(noUnlockIds)>0 or Data.redpos.bolPetRelationActivate)then
        RedPoint.add(gMainMoneyLayer:getNode("btn_pet"),RedPoint.menuAnchorPoint)


        if(panel) then
            if(table.count(noUnlockIds)>0)then
                if(panel.__panelType == PANEL_PET) then
                    for key, var in pairs(panel:getNode("scroll").items) do
                        if(var.curDBData and noUnlockIds[var.curDBData.petid]==1)then
                            RedPoint.add(var:getNode("unlock_icon"),cc.p(1.5,0.9))
                        else
                            RedPoint.remove(var:getNode("unlock_icon"))
                        end
                    end


                    if(panel.curData and  noUnlockIds[panel.curData.petid]==1 )then
                        RedPoint.add(panel:getNode("btn_unlock"),cc.p(0.9,0.8))
                    else
                        RedPoint.remove(panel:getNode("btn_unlock"))
                    end
                end
            else
                if(panel.__panelType == PANEL_PET) then
                    for key, var in pairs(panel:getNode("scroll").items) do
                        RedPoint.remove(var:getNode("unlock_icon"))
                    end
                    RedPoint.remove(panel:getNode("btn_unlock"))
                end
            end
            if(Data.redpos.bolPetRelationActivate)then
                if(panel.__panelType == PANEL_PET) then
                    RedPoint.add(panel:getNode("btn_relation"),RedPoint.menuAnchorPoint)
                end
            else
                if(panel.__panelType == PANEL_PET) then
                    RedPoint.remove(panel:getNode("btn_relation"))
                end
            end
        end



    else
        if(panel) then
            if(panel.__panelType == PANEL_PET) then
                for key, var in pairs(panel:getNode("scroll").items) do
                    RedPoint.remove(var:getNode("unlock_icon"))
                end
                RedPoint.remove(panel:getNode("btn_unlock"))
                RedPoint.remove(panel:getNode("btn_relation"))
            end
        end
        RedPoint.remove(gMainMoneyLayer:getNode("btn_pet"))
    end
end

function RedPoint.task()

    if Unlock.isUnlock(SYS_TASK,false) == false then
        return;
    end

    if(Data.redpos.bolDayTask or Data.redpos.bolAchieve or Data.redpos.bolDayEnergy) then
        RedPoint.add(gMainMoneyLayer:getNode("btn_task"),RedPoint.menuAnchorPoint)
    else
        RedPoint.remove(gMainMoneyLayer:getNode("btn_task"))
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        --任务&成就
        if(panel.__panelType == PANEL_TASK) then

            RedPoint.refresh(panel:getNode("btn_type1"),Data.redpos.bolDayTask or Data.redpos.bolDayEnergy);
            RedPoint.refresh(panel:getNode("btn_type2"),Data.redpos.bolAchieve);

        end
    end

end

function RedPoint.newTask()

    RedPoint.refresh(gMainLayer:getNode("btn_task"),Data.redpos.bolNewTask,cc.p(0.8,0.9));

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if(panel.__panelType == PANEL_NEWTASK) then
            RedPoint.refresh(panel:getNode("btn_get"),Data.redpos.bolNewTask);
        end
        if(panel.__panelType == PANEL_ATLAS) then
            RedPoint.refresh(panel:getNode("btn_task"),Data.redpos.bolNewTask,cc.p(0.8,0.9));
        end

    end

end

function RedPoint.task7Day()
    RedPoint.refresh(gMainLayer:getNode("btn_task7"),Data.redpos.bolNewTask,cc.p(0.8,0.9));

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if(panel.__panelType == PANEL_TASK7DAY) then
            -- RedPoint.refresh(panel:getNode("btn_get"),Data.redpos.bolNewTask);
            for key,var in pairs(Data.redpos.bol7DayTask) do
                RedPoint.refresh(panel:getNode("day"..key),Data.redpos.bol7DayTask[key]);
            end
            for key,var in pairs(Data.redpos.bol7DayTaskLabel) do
                RedPoint.refresh(panel:getNode("btn"..key),Data.redpos.bol7DayTaskLabel[key]);
            end
        end
    end
end

function RedPoint.mall()

    local isMallRedpos = Data.redpos.vipgift or Data.activityRedPosLogin[ACT_TYPE_1001] or Data.activityRedPosLogin[ACT_TYPE_1002];
    RedPoint.refresh(gMainLayer:getNode("btn_mall"),isMallRedpos,cc.p(0.8,0.9));

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel and panel.__panelType == PANEL_MALL) then
        local item = panel:getMenuItemByName("name_vip_gift");
        if(item)then
            RedPoint.refresh(item:getNode("bg"), Data.redpos.vipgift);
        end

        item = panel:getMenuItemByName("name_vip_day_gift");
        if(item)then
            RedPoint.refresh(item:getNode("bg"), Data.activityRedPosLogin[ACT_TYPE_1002]);
        end
    end

end


function RedPoint.family()


    local hasFamilyHDRedpos = Data.redpos.bolFamilyGu or
        Data.redpos.bolFamilyEgg or
        Data.redpos.bolFamilySeven or
        Data.redpos.bolFamilySpring;

    if(Data.redpos.bolFamilyApply)then
        if(Data.isFamilyManager() == false)then
            Data.redpos.bolFamilyApply = false;
        end
    end

    local hasFamilyRedpos = Data.redpos.bolFamilyApply or hasFamilyHDRedpos or Data.redpos.bolFamilyActive
                            or Data.redpos.bolFamilyOre or Data.redpos.bolFamilyDonate;

    if(Data.hasFamily() == false)then
        hasFamilyRedpos = false;
    end
 
    if gFamilyInfo.iLevel >= DB.getFamilyBuildUnlock(11) and Data.redpos.bolFamilyStage and (not Module.isClose(SWITCH_FAMILY_STAGE)) then
        hasFamilyRedpos = Data.redpos.bolFamilyStage
    end

    --军团
    if gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_FAMILY);
        RedPoint.refresh(bg,hasFamilyRedpos,RedPoint.getBuildTitleAnchor(cc.p(0.5,0.94)));
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        --军团

        if(panel.__panelType == PANEL_FAMILY_HOME) then
            RedPoint.refresh(panel:getNode("btn"),Data.redpos.bolFamilyApply);
            RedPoint.refresh(panel:getNode("name_hd"),hasFamilyHDRedpos,RedPoint.getFamilyBuildAnchor());
            RedPoint.refresh(panel:getNode("name_ore"),Data.redpos.bolFamilyOre,RedPoint.getFamilyBuildAnchor());
            RedPoint.refresh(panel:getNode("icon_donate"),Data.redpos.bolFamilyDonate,RedPoint.getFamilyBuildAnchor());
            if gFamilyInfo.iLevel >= DB.getFamilyBuildUnlock(11) and (not Module.isClose(SWITCH_FAMILY_STAGE)) then
                RedPoint.refresh(panel:getNode("icon_stage"),Data.redpos.bolFamilyStage,cc.p(0.5, 1.0));
            end

            if gFamilyInfo.iType < 10 then
                RedPoint.refresh(panel:getNode("name_shop"),Data.redpos.bolFamilyShopReward,RedPoint.getFamilyBuildAnchor())
            else
                RedPoint.refresh(panel:getNode("name_shop", false))
            end
        end

        if(panel.__panelType == PANEL_FAMILY_MAMAGE) then
            RedPoint.refresh(panel:getNode("btn_men"),Data.redpos.bolFamilyApply);
        end

        if(panel.__panelType == PANEL_FAMILY_HDENTER) then
            local item = panel:getItem(0);
            if(item)then
                RedPoint.refresh(item:getNode("btn_enter"),Data.redpos.bolFamilyGu,cc.p(0.97,0.46));
            end

            local item = panel:getItem(1);
            if(item)then
                RedPoint.refresh(item:getNode("btn_enter"),Data.redpos.bolFamilyEgg,cc.p(0.97,0.46));
            end

            local item = panel:getItem(2);
            if(item)then
                RedPoint.refresh(item:getNode("btn_enter"),Data.redpos.bolFamilySeven,cc.p(0.97,0.46));
            end

            local item = panel:getItem(3);
            if(item)then
                RedPoint.refresh(item:getNode("btn_enter"),Data.redpos.bolFamilySpring,cc.p(0.97,0.46));
            end
        end

        if (panel.__panelType == PANEL_SHOP) and 
           (panel.curShopType == SHOP_TYPE_FAMILY_3)  then
            -- 非实习期
            if Data.hasFamily() and gFamilyInfo.iType < 10 then
                RedPoint.refresh(panel:getNode("btn_type8"),Data.redpos.bolFamilyShopReward,cc.p(0.9, 0.9))
            end
        end
    end

end

function RedPoint.mail()
    --邮件
    if gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_MAIL);
        if(Data.redpos.bolNewMail or Data.redpos.bolBuddyMail or Data.redpos.bolFamilyMail) then
            RedPoint.add(bg,RedPoint.getBuildTitleAnchor());
            gMainBgLayer:setMainVisible(true)
            gMainBgLayer:setBirdFly(true)
        else
            RedPoint.remove(bg);
            gMainBgLayer:setMainVisible(false)
            gMainBgLayer:setBirdFly(false)
        end
    end


    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        --邮件
        if(panel.__panelType == PANEL_MAIL) then
            --系统邮件
            RedPoint.refresh(panel:getNode("btn1"),Data.redpos.bolNewMail);
            --好友邮件
            RedPoint.refresh(panel:getNode("btn2"),Data.redpos.bolBuddyMail);
            --好友邮件  
            RedPoint.refresh(panel:getNode("btn3"),Data.redpos.bolFamilyMail);
        end
    end
end


function RedPoint.petCave()
    --灵兽探险
    if Unlock.isUnlock(SYS_PET_CAVE,false) == false then
        return
    end
    if gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_PET_CAVE);
        if(Data.redpos.caveevent or Data.redpos.caveachieve or Data.redpos.caveexplore) then
            RedPoint.add(bg,RedPoint.getBuildTitleAnchor());
        else
            RedPoint.remove(bg);
        end
    end
    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if(panel.__panelType == PANNEL_PET_EXPLORE) then
            --事件
            RedPoint.refresh(panel:getNode("btn_event"),Data.redpos.caveevent);
            --成就
            RedPoint.refresh(panel:getNode("btn_archive"),Data.redpos.caveachieve);
            --好友邮件  
            --RedPoint.refresh(panel:getNode("btn_explore"),Data.redpos.bolFamilyMail);
        end
    end
end


function RedPoint.sign()
    RedPoint.refresh(gMainLayer:getNode("btn_sign"),Data.redpos.bolDaySign or Data.redpos.bolVipSign or Data.redpos.bolCntSign);

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if(panel.__panelType == PANEL_SIGNIN) then
            RedPoint.refresh(panel:getNode("btn1"),Data.redpos.bolDaySign);
            RedPoint.refresh(panel:getNode("btn2"),Data.redpos.bolVipSign);
        end
    end
end

function RedPoint.onlineGift()
    RedPoint.refresh(gMainLayer:getNode("btn_online_gift"),Data.m_onlineInfo.bolShowRedPoint);
end

function RedPoint.bag()

    if nil ~= gMainBgLayer then
        local items={}
        for key, var in pairs(gUserItems) do
            if(DB.getItemType(var.itemid)==ITEMTYPE_BOX)then
                local db=DB.getBoxById(var.itemid)
                if nil ~= db then
                    if(db.limittype==0)then
                        items[var.itemid]=var
                    elseif(db.limittype==1 and gUserInfo.level>=db.openlv)then
                        items[var.itemid]=var
                    end
                end
            end
        end
        local count=table.count(items)
        if(count>0)then
            RedPoint.add(gMainLayer:getNode("btn_bag"),cc.p(0.85,0.85))
        else
            RedPoint.remove(gMainLayer:getNode("btn_bag"))

        end

        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel) then
            if panel.__panelType == PANEL_BAG then
                if count>0 then
                    RedPoint.add(panel:getNode("btn_all"),cc.p(0.85,0.85))
                else
                    RedPoint.remove(panel:getNode("btn_all"))
                end

                for key, var in pairs(panel:getNode("scroll").items) do
                    local itemid=0
                    if(var.curData and var.curData.itemid)then
                        itemid= var.curData.itemid
                    end
                    if(var.lazyData and var.lazyData.itemid)then
                        itemid= var.lazyData.itemid
                    end
                    if( items[itemid])then
                        RedPoint.add(var:getNode("icon"),cc.p(0.85,0.85))
                    else
                        RedPoint.remove(var:getNode("icon"))
                    end
                end
            end

        end
    end
end


function RedPoint.luckWheel()
    if(gMainLayer)then

        local item=gMainLayer:getNode("btn_activity_luck_wheel")
        if Data.redpos.bolLuckWheelRec or
            Data.redpos.bolLuckWheelfree0 or
            Data.redpos.bolLuckWheelfree1 then
            RedPoint.add(item,cc.p(0.9,0.9))
        else
            RedPoint.remove(item)
        end

    end
    if nil ~= gMainBgLayer then

        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel) then
            if panel.__panelType == PANEL_ACTIVITY_LUCK_WHEEL then
                if Data.redpos.bolLuckWheelRec then
                    RedPoint.add(panel:getNode("btn_reward"),cc.p(0.85,0.85))
                else
                    RedPoint.remove(panel:getNode("btn_reward"))
                end

                RedPoint.remove(panel:getNode("btn_cost1"))
                
                if Data.redpos.bolLuckWheelfree0 then
                    RedPoint.add(panel:getNode("btn_type1"),cc.p(0.85,0.85))
                    
                    if(panel.curType==1)then
                        RedPoint.add(panel:getNode("btn_cost1"),cc.p(0.85,0.85))
                    end
                else
                    RedPoint.remove(panel:getNode("btn_type1"))
                end
                
                
                if Data.redpos.bolLuckWheelfree1 then
                    RedPoint.add(panel:getNode("btn_type2"),cc.p(0.85,0.85))
                    if(panel.curType==2)then
                        RedPoint.add(panel:getNode("btn_cost1"),cc.p(0.85,0.85))
                    end
                else
                    RedPoint.remove(panel:getNode("btn_type2"))
                end

            end
        end
    end

end



function RedPoint.richman()
    if(gMainLayer)then

        local item=gMainLayer:getNode("btn_richman")
        if Data.redpos.richmanrec  then
            RedPoint.add(item,cc.p(0.9,0.9))
        else
            RedPoint.remove(item)
        end

    end
    if nil ~= gMainBgLayer then

        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel) then
            if panel.__panelType == PANEL_RICHMAN then
                if Data.redpos.richmanrec then
                    RedPoint.add(panel:getNode("btn_reward"),cc.p(0.8,0.8))
                else
                    RedPoint.remove(panel:getNode("btn_reward"))
                end 
            end
        end
    end

end

function RedPoint.crusade()

    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_CRUSADE)
        local name= gMainBgLayer.main3D:getObjNode("main","name"..SYS_CRUSADE)
        local item=gMainBgLayer:getGuideItem("panjun")
        if Data.redpos.bolCrusadeRec or Data.redpos.bolCrusadeNum or Data.redpos.bolCrusadeCall then
            RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
            item:setVisible(true)
            bg:setVisible(true)
            name:setVisible(true)
        else
            RedPoint.remove(bg)
            item:setVisible(false)
            bg:setVisible(false)
            name:setVisible(false)
        end

        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel) then
            if panel.__panelType == PANEL_CRUSADE then
                if Data.redpos.bolCrusadeRec then
                    RedPoint.add(panel:getNode("btn_feats"),cc.p(0.85,0.85))
                else
                    RedPoint.remove(panel:getNode("btn_feats"))
                end
                if Data.redpos.bolCrusadeCall then
                    RedPoint.add(panel:getNode("btn_call"),cc.p(0.85,0.85))
                else
                    RedPoint.remove(panel:getNode("btn_call"))
                end
            end
        end
    end
end

function RedPoint.dragon()
    if Data.redpos.gcNumDragon == nil then
        return
    end

    local showBgRedPoint = false
    local showGoldRedPoint = false
    local showDiaRedPoint = false
    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_CARD)
        -- 金钱
        if Data.drawCard.time ~= nil then
            if Data.drawCard.gold.fnum > 0 then
                local passTime = gGetCurServerTime() - Data.drawCard.time
                if passTime >= Data.drawCard.gold.ftime then
                    showBgRedPoint = true
                    showGoldRedPoint = true
                end
            end
        elseif Data.redpos.gcNumDragon > 0 and Data.redpos.gtFTimeDragon == 0 then
            showBgRedPoint   = true
            showGoldRedPoint = true
        end

        --元宝
        if Data.drawCard.time ~= nil then
            local passTime = gGetCurServerTime() - Data.drawCard.time
            if passTime >= Data.drawCard.diamond.ftime then
                showBgRedPoint = true
                showDiaRedPoint = true
            end
        elseif Data.redpos.dtFTimeDragon == 0 then
            showBgRedPoint   = true
            showDiaRedPoint = true
        end

        if showBgRedPoint then
            RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
        else
            RedPoint.remove(bg)
        end
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        --点将台
        if(panel.__panelType == PANEL_DRAW_CARD) then
            RedPoint.refresh(panel:getNode("btn_buy_gold_one"),showGoldRedPoint)
            RedPoint.refresh(panel:getNode("btn_buy_dia_one"),showDiaRedPoint)
        end
    end
end

function RedPoint.actAtlas()
    if Data.redpos.actAtlas == nil or #Data.redpos.actAtlas == 0 or Unlock.isUnlock(SYS_ACT,false) == false then
        return
    end

    local showBgRedPoint  = false
    local showGoldActRP =  Data.canShowActAtlasRedPoint(SYS_ACT_GOLD, Data.redpos.actAtlas[1])
    local showExpActRP =   Data.canShowActAtlasRedPoint(SYS_ACT_EXP, Data.redpos.actAtlas[2])
    local showPetSoulActRP = Data.canShowActAtlasRedPoint(SYS_ACT_PETSOUL, Data.redpos.actAtlas[3])
    local showEquSoul      = Data.canShowActAtlasRedPoint(SYS_ACT_EQUSOUL, Data.redpos.actAtlas[4])
    local showItemAwake    = Data.canShowActAtlasRedPoint(SYS_ACT_ITEM_AWAKE, Data.redpos.actAtlas[5])

    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_ACT)
        if showGoldActRP or showExpActRP or showPetSoulActRP or showEquSoul or showItemAwake then
            RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
        else
            RedPoint.remove(bg)
        end
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if(panel.__panelType == PANEL_ACTIVITY) then
            local scrollNode = panel:getNode("scroll")
            if nil ~= scrollNode then
                RedPoint.refresh(scrollNode.items[1]:getNode("panel_title"),showGoldActRP)
                RedPoint.refresh(scrollNode.items[2]:getNode("panel_title"),showExpActRP)
                RedPoint.refresh(scrollNode.items[3]:getNode("panel_title"),showPetSoulActRP)
                RedPoint.refresh(scrollNode.items[4]:getNode("panel_title"),showEquSoul)
                RedPoint.refresh(scrollNode.items[5]:getNode("panel_title"),showItemAwake)
            end
        end
    end
end

function RedPoint.isToday(timestamp)
    local today = gGetDate("*t")
    local secondOfToday = os.time({day=today.day, month=today.month,
        year=today.year, hour=gResetDataInDay, minute=0, second=0})
    if timestamp >= secondOfToday and timestamp < secondOfToday + 24 * 60 * 60 then
        return true
    else
        return false
    end
end

function RedPoint.setActivityRedpos(key,open)
    cc.UserDefault:getInstance():setBoolForKey(Data.getCurUserId().."redpostime"..key, open)
end

function RedPoint.activityRead()
    local redpostime = cc.UserDefault:getInstance():getIntegerForKey(Data.getCurUserId().."redpostime",0)
    -- print("redpostime===="..toint(redpostime))
    if (RedPoint.isToday(toint(redpostime)) == false) then--没有记录或者不是当天
        --记录
        Data.initActivityRedPosLogin()
        for k,v in pairs(Data.activityRedPosLogin) do
            RedPoint.setActivityRedpos(k,true)
        end
        cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."redpostime", gLoginTime)
        -- print("记录-----false")
    else
        for k,v in pairs(Data.activityRedPosLogin) do
            local bolOpen = cc.UserDefault:getInstance():getBoolForKey(Data.getCurUserId().."redpostime"..k,true)
            Data.activityRedPosLogin[k] = bolOpen
        end
        -- print("记录-----true")
    end
end

function RedPoint.activity()
    --活动
    local showBgRedPoint    = false
    local showBgRedPoint_newYear = false
    local showBgRedPoint_holiday = false
    local showBgRedPoint_hefu = false
    local activityShowFlags = {}
    activityShowFlags[ACT_TYPE_113]=false
    activityShowFlags[ACT_TYPE_104]=false
    activityShowFlags[ACT_TYPE_107]=false
    activityShowFlags[ACT_TYPE_108]=false
    --  activityShowFlags[ACTIVITY_TYPE_CONSUME]=false
    activityShowFlags[ACT_TYPE_3]=false
    activityShowFlags[ACT_TYPE_99] = false
    activityShowFlags[ACT_TYPE_116] = false
    activityShowFlags[ACT_TYPE_127] = false

    --每天一次红点处理
    for key, var in pairs(Data.activityRedPosLogin) do
        activityShowFlags[key] =var
        if(var)then
            local panel=Panel.getTopPanel(Panel.popPanels)
            if(panel) then
                if(panel.__panelType == PANEL_ACTIVITY_ALL) then
                    local scrollNode = panel:getNode("scroll")
                    if nil ~= scrollNode and #scrollNode.items > 0 then
                        for _, item in pairs(scrollNode.items) do
                            if (key == item.curData.type) then
                                if (item.curData.param3 == 1) then
                                    showBgRedPoint_newYear = true
                                elseif item.curData.param3 == 2 then
                                    showBgRedPoint_holiday = true
                                elseif item.curData.param3 == 3 then
                                    showBgRedPoint_hefu = true
                                else
                                    showBgRedPoint=true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --登录七天
    if #Data.act7DayCanBeGot > 0 then
        if Data.hasAct7DayCanBeGot() then
            showBgRedPoint = true
            activityShowFlags[ACT_TYPE_113] = true
        end
    elseif Data.redpos.bolLogin7 then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_113] = true
    end

    --月卡终身卡
    if Data.redpos.mlc and ((not Module.isClose(SWITCH_CARD_MONTH)) or (not Module.isClose(SWITCH_CARDYEAR))) then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_108] = true
    end
    --投资理财
    -- if Data.activityInvestBuy then
    --     if Data.hasActInvestCanBeGot() then
    --         showBgRedPoint = true
    --         activityShowFlags[ACT_TYPE_107] = true
    --         if (Data.hasIap(8)) then
    --             activityShowFlags[ACT_TYPE_92] = true
    --         end
    --     end
    -- else
    if Data.redpos.fu then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_107] = true
        if (Data.hasIap(8)) then
            activityShowFlags[ACT_TYPE_92] = true
        end
    end

    --应用宝投资理财
    -- if Data.hasIap(8) then
    --     if Data.hasActInvestCanBeGot() then
    --         showBgRedPoint = true
    --         activityShowFlags[ACT_TYPE_92] = true
    --     end
    -- end

    --等级礼包
    if table.count(Data.actLvUpCanBeGot) > 0 then
        if Data.hasActLvUpCanBeGot() then
            showBgRedPoint = true
            activityShowFlags[ACT_TYPE_104] = true
        end
    elseif Data.redpos.lg then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_104] = true
    end

    --累计充返
    --消费返还
    -- local function getActivityParam3(vid)
    --     for key, value in pairs(Data.activityAll) do
    --         if (value.actId == vid) then
    --             return value.param3
    --         end
    --     end
    --     return 0
    -- end
    if (Data.redpos.act) then
        for k,v in pairs(Data.redpos.act) do
            local id = toint(v)
            showBgRedPoint = true
            activityShowFlags[1000000+id] = true
        end
    end
    --新年活动
    if (Data.redpos.act2) then
        for k,v in pairs(Data.redpos.act2) do
            local id = toint(v)
            showBgRedPoint_newYear = true
            activityShowFlags[1000000+id] = true
        end
    end

     --节日大派送活动
    if (Data.redpos.act3) then
        for k,v in pairs(Data.redpos.act3) do
            local id = toint(v)
            showBgRedPoint_holiday = true
            activityShowFlags[1000000+id] = true
        end
    end

    --合服活动
    if (Data.redpos.act4) then
        for k,v in pairs(Data.redpos.act4) do
            local id = toint(v)
            showBgRedPoint_hefu = true
            activityShowFlags[1000000+id] = true
        end
    end

    --VIP领取，内测使用
    -- if Data.canShowVipGetRedPoint() then
    --     showBgRedPoint = true
    --     activityShowFlags[ACT_TYPE_99] = true
    -- end

    --许愿树
    if (Data.redpos.wish) then
        -- print("wish")
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_116] = true
    end

    if(Data.redpos.act97 and Data.redpos.act97.pt)then
        if Data.redpos.act97.type == 0 then
            showBgRedPoint = true
        elseif Data.redpos.act97.type == 1 then
            showBgRedPoint_newYear = true
        elseif Data.redpos.act97.type == 2 then
            showBgRedPoint_holiday = true
        elseif Data.redpos.act97.type == 3 then
            showBgRedPoint_hefu = true
        end
        
        activityShowFlags[ACT_TYPE_97] = true
    end


    if(Data.redpos.act98 and Data.redpos.act98.pt)then
        if Data.redpos.act98.type == 0 then
            showBgRedPoint = true
        elseif Data.redpos.act98.type == 1 then
            showBgRedPoint_newYear = true
        elseif Data.redpos.act98.type == 2 then
            showBgRedPoint_holiday = true
        elseif Data.redpos.act98.type == 3 then
            showBgRedPoint_hefu = true
        end
        activityShowFlags[ACT_TYPE_98] = true
    end

    --活动N日豪礼
    if (Data.redpos.richday) then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_17] = true
    end

    --签到
    if(Data.redpos.bolDaySign and not Module.isClose(SWITCH_SIGN))then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_127] = true
    end

    --吃包子
    if (Data.redpos.bolDayEnergy and Data.bolOpenEatBunAct) then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_125] = true
    end

    --免费vip
    if (Data.redpos.act23) then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_23] = true
    end

    --新年七天乐
    if (Data.redpos.bolActivityDayTaskCanGet) then
        showBgRedPoint_newYear = true;
        activityShowFlags[ACT_TYPE_95] = true;
    end

    --招募
    if (Data.redpos.act93) then
        showBgRedPoint = true
        activityShowFlags[ACT_TYPE_93] = true
    end

    RedPoint.refresh(gMainLayer:getNode("btn_activity"), showBgRedPoint,cc.p(0.8,0.9))
    RedPoint.refresh(gMainLayer:getNode("btn_activity_new"), showBgRedPoint_newYear,cc.p(0.8,0.9))
    RedPoint.refresh(gMainLayer:getNode("btn_activity_festival"), showBgRedPoint_holiday,cc.p(0.8,0.9))
    RedPoint.refresh(gMainLayer:getNode("btn_activity_hefu"), showBgRedPoint_hefu,cc.p(0.8,0.9))
    
    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if(panel.__panelType == PANEL_ACTIVITY_ALL) then
            local scrollNode = panel:getNode("scroll")
            if nil ~= scrollNode and #scrollNode.items > 0 then
                for _, item in pairs(scrollNode.items) do
                    -- print("item.curData.type="..item.curData.type)
                    if (item.curData.type==ACT_TYPE_2 or item.curData.type==ACT_TYPE_3 or
                        item.curData.type==ACT_TYPE_6 or item.curData.type==ACT_TYPE_15 or
                        item.curData.type==ACT_TYPE_19 or item.curData.type==ACT_TYPE_1 or
                        item.curData.type==ACT_TYPE_7  or item.curData.type==ACT_TYPE_28) then
                        -- print("222item.curData.type="..item.curData.type)
                        -- print_lua_table(activityShowFlags)
                        RedPoint.refresh(item:getNode("bg"), activityShowFlags[1000000+item.curData.actId])
                    else
                        RedPoint.refresh(item:getNode("bg"), activityShowFlags[item.curData.type])
                    end
                end
            end

            --新年七天乐
            if(panel.curPanelType == ACT_TYPE_95 and panel.curPanel)then
                -- print("xxxxx");
                for key,var in pairs(Data.redpos.bolActivityDayTask) do
                    RedPoint.refresh(panel.curPanel:getNode("day"..key),Data.redpos.bolActivityDayTask[key]);
                end
            end
        end
    end
end

function RedPoint.arena()
    local showBgRedPoint = false
    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_ARENA)
        if nil ~= bg then

            if nil ~= gArena.count and nil ~= gArena.time then
                if gArena.count > 0 and (gArena.time == 0 or gArena.time < gGetCurServerTime()- gArena.serverTime) then
                    showBgRedPoint = true
                end
            elseif (nil ~= Data.redpos.ar and Data.redpos.ar.num > 0 and (Data.redpos.ar.time == 0 or Data.redpos.ar.time < gGetCurServerTime()- gArena.serverTime)
                and Unlock.isUnlock(SYS_ARENA,false)) then
                showBgRedPoint = true
            end

            if showBgRedPoint then
                RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
            else
                RedPoint.remove(bg)
            end
        end
    end
end

--命魂红点
function RedPoint.soullife()

    if Unlock.isUnlock(SYS_XUNXIAN,false) == false then
        return;
    end

    if Data.redpos.spirit then
        RedPoint.add(gMainMoneyLayer:getNode("btn_xunxian"),RedPoint.menuAnchorPoint)
    else
        RedPoint.remove(gMainMoneyLayer:getNode("btn_xunxian"))
    end
end

--挖矿红点
function RedPoint.digMine()
    if Unlock.isUnlock(SYS_MINE,false) == false then
        return
    end

    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_MINE)
        if nil ~= bg then
            if Data.redpos.minep then
                RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
            else
                RedPoint.remove(bg)
            end
        end
    end
end





function RedPoint.familyWar()
    if Unlock.isUnlock(SYS_FAMILY,false) == false then
        return
    end

    if Data.hasFamily() == false then
        return
    end
    -- print("RedPoint.familyWar");
    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitleBone(SYS_FAMILY)
        if nil ~= bg then
            --时间
            local mathDay =DB.getFamilyWarMatchDate()
            local curTimeTable = gGetDate("*t", gGetCurServerTime())
            local curWDay = (curTimeTable.wday + 6) % 7

            RedPoint.familyWarTime=0
            RedPoint.inFamilyWar=false

            if((curWDay+1)%7==mathDay)then
                RedPoint.familyWarTime=24*60*60-curTimeTable.hour*60*60-curTimeTable.min*60 -curTimeTable.sec
            end


            if(curWDay==mathDay)then
                local finishHour=toint( DB.getFamilyWarMatchTime(1))
                local remainTime=finishHour*60*60-curTimeTable.hour*60*60-curTimeTable.min*60 -curTimeTable.sec
                if(remainTime>0)then
                    RedPoint.inFamilyWar=true
                end
            end
            if (RedPoint.familyWarTime>0) then
                local red= RedPoint.addTimeNode(bg,gParserHourTime(RedPoint.familyWarTime),"ui_main_time2")
                red:setPositionX(10)
                red:setPositionY(30)
            else
                RedPoint.removeTime(bg)
            end


            if (RedPoint.inFamilyWar) then
                local red= RedPoint.addFightNode(bg,40,"","ui_family_bz_combat")

            else
                RedPoint.removeFightNode(bg)
            end
        end
    end
end



--世界boss
function RedPoint.worldBoss()
    if Unlock.isUnlock(SYS_WORLD_BOSS,false) == false then
        return
    end
    -- print("RedPoint.worldBoss");
    if nil ~= gMainBgLayer then
        if not gMainBgLayer:getBuild("boss"):isVisible() then
            return
        end
        local bg = gMainBgLayer:getBuildTitleBone(SYS_WORLD_BOSS)
        if nil ~= bg and bg:isVisible() then 
            local bolRed = false
            --时间
            local bolTime = false
            --战斗中
            local bolFight = false
            local time = Data.worldBossInfo.starttime-gGetCurServerTime()
            if (Data.worldBossInfo.status) then
                if (Data.worldBossInfo.status==0) then
                    if (time<=60*30 and time>=0) then
                        bolTime = true
                    elseif(time<0) then
                        bolRed = true
                        bolFight = true
                    end
                elseif (Data.worldBossInfo.status==1) then
                    bolFight = true
                end
            end
            -- print("Data.worldBossInfo.status="..Data.worldBossInfo.status)

            if (bolTime) then
                local ret=  RedPoint.addTimeNode(bg, gParserMinTime(time),"ui_main_time")
                ret:setPositionX(5)
                ret:setPositionY(5)
            else
                RedPoint.removeTime(bg)
            end

            if (Data.worldBossInfo.status) then
                if (Data.worldBossInfo.status==1) then
                    bolRed = true
                end
            end
            if bolFight then
                local fight= RedPoint.addFightNode(bg,20,"","ui_family_bz_combat")

                local boss =gMainBgLayer:getBuild("boss")
                if isNewBossCurDay() then
                    loadFlaXml("ui_main_night")
                    boss:playAction("ui_main_bg_boss22_night")
                else
                    boss:playAction("ui_main_bg_boss2_night")
                end
                
            else
                RedPoint.removeFightNode(bg)
                --判断晚上
                local curHour= gGetHourByTime()
                local boss =gMainBgLayer:getBuild("boss")
                if(curHour>=18 or curHour<=6)then
                    isNight=true
                    
                    if isNewBossCurDay() then
                        boss:playAction("ui_main_bg_boss2")
                    else
                        boss:playAction("ui_main_bg_boss1_night")
                    end
                elseif boss:isVisible() == true then
                    -- 白天 世界boss
                    if isNewBossCurDay() then
                        boss:playAction("ui_main_bg_boss2")
                    else
                        boss:playAction("ui_main_bg_boss1")
                    end
                end

            end

            if (bolFight or bolTime) and 
                not gMainBgLayer:getBuild("boss"):isVisible() then
                Data.clearHuntIntervalInfos()
                Data.setHuntIntervalInfos()
                gMainBgLayer:setExploreType(Data.finalHuntIntervalInfos[2].huntId)
            end

            if bolRed then
                RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
                return
            else
                RedPoint.remove(bg)
            end
        end
    end
end

function RedPoint.notice()
    RedPoint.refresh(gMainLayer:getNode("btn_notice"),Data.redpos.bolNotice);
end

--商店
function RedPoint.shop()
    if Unlock.isUnlock(SYS_SHOP,false) == false then
        return
    end
    -- print("RedPoint.shop");
    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitleBone(SYS_SHOP)
        if nil ~= bg then
            -- Data.limit_etime = gGetCurServerTime() + 1000
            if (Data.limit_etime and Data.limit_etime>0) then
                local bolTime = false
                local time = math.max(Data.limit_etime - gGetCurServerTime(),0)
                if (time>0) then
                    local ret=  RedPoint.addTimeNode(bg, gParserHourTime(time),"ui_main_time2")
                    ret:setPositionX(-170)
                    ret:setPositionY(5)
                else
                    if (time<=0) then
                        Data.limit_etime = 0
                        gDispatchEvt(EVENT_ID_OPEN_LIMIT_SHOP)
                    end
                    RedPoint.removeTime(bg)
                end
            else
                RedPoint.removeTime(bg)
            end
        end
    end
end

--图腾&幻灵守卫
function RedPoint.familySkill()
    
    if(nil ~= gMainLayer)then
        if(Unlock.isUnlock(SYS_HALO,false))then
            local isUnlockGuide = Data.getSysIsUnlock(SYS_HALO);
            local needRedpos = not isUnlockGuide;
            RedPoint.refresh(gMainLayer:getNode("btn_family_skill"),needRedpos);
            local panel=Panel.getTopPanel(Panel.popPanels)
            if(panel) then
                if(panel.__panelType == PANEL_HALO) then
                    RedPoint.refresh(panel:getNode("btn_huanl"),needRedpos);
                end
            end
        end
    end

end

function RedPoint.lootfood()
    if nil ~= gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_LOOT_FOOD)
        if bg~=nil and bg:isVisible() then
        end
        if Data.redpos.lootfoodrec then
            RedPoint.add(bg,RedPoint.getBuildTitleAnchor())
        else
            RedPoint.remove(bg)
        end

        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel) then
            if panel.__panelType == PANEL_FOODFIGHT_MAIN then
                if Data.redpos.lootfoodrec then
                    RedPoint.add(panel:getNode("btn_achi"),cc.p(0.85,0.85))
                else
                    RedPoint.remove(panel:getNode("btn_achi"))
                end

                if Data.redpos.lootfoodrecord then
                    RedPoint.add(panel:getNode("btn_record"),cc.p(0.85,0.85))
                else
                    RedPoint.remove(panel:getNode("btn_record"))
                end
            end

            if panel.__panelType == PANEL_HUNT then
                for i = 0, 4 do
                    if panel.redDotBg[i] then
                        local redDotBg = panel.redDotBg[i].bg
                        -- 跨服夺粮
                        if nil ~= redDotBg then
                            if redDotBg.type == 3 and Data.redpos.lootfoodrec then
                                RedPoint.add(redDotBg,cc.p(0.94,-0.18))
                            else
                                RedPoint.remove(redDotBg)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 星宿红点
function RedPoint.constellation()
    if Unlock.isUnlock(SYS_CONSTELLATION,false) == false then
        return
    end

    if(gMainLayer==nil or gMainMoneyLayer==nil )then
        return
    end
    -- body
    if nil ~= gMainBgLayer then
        if gConstellation.groupCanBeAcive or 
           gConstellation.getHuntFreeNum() > 0 or
           gConstellation.getLeftFightNum() > 0 or
           Data.redpos.circleachieve or 
           Data.redpos.constellationstar or
           Data.redpos.constellationhunt then
            RedPoint.add(gMainMoneyLayer:getNode("btn_constellation"),RedPoint.menuAnchorPoint)
        else
            RedPoint.remove(gMainMoneyLayer:getNode("btn_constellation"))
        end
    end
end

function RedPoint.newboss()
    if nil == gMainBgLayer then
        return
    end

    local panel=Panel.getTopPanel(Panel.popPanels)
    if(panel) then
        if panel.__panelType == PANEL_WORLD_BOSS then
            if Data.redpos.newbosskillrec then
                RedPoint.add(panel:getNode("btn_reward"),cc.p(0.85,0.85))
            else
                RedPoint.remove(panel:getNode("btn_reward"))
            end
        end
    end
end

function RedPoint.updateGame()
    if(gMainLayer and gMainMoneyLayer )then
        RedPoint.worldBoss()
        RedPoint.familyWar()
        RedPoint.shop()
    end
end

function RedPoint.update()
    -- RedPoint.updateGame()
    RedPoint.updateRedDirty()
end

function RedPoint.getBuildTitleAnchor(anchorPoint)
    local anchor = anchorPoint;
    if(anchor == nil)then
        anchor = cc.p(0.5,1.0);
    end
    if(gIsHorizontal)then
        -- print("1111111");
        anchor = cc.p(0,0.5);
    end
    -- print(">>>>>>>>>>")
    -- print_lua_table(anchor);
    -- print("<<<<<<<<<<")
    return anchor;
end

function RedPoint.getFamilyBuildAnchor(anchorPoint)
    local anchor = anchorPoint;
    if(anchor == nil)then
        anchor = cc.p(0.5,1.0);
    end
    if(gIsHorizontal)then
        anchor = cc.p(0,0.5);
    end
    return anchor;
end

function RedPoint.updateRedDirty()


    if(gRedposRefreshDirty == false)then
        return;
    end
    gRedposRefreshDirty = false;


    RedPoint.bolCard()
    if(gMainLayer==nil or gMainMoneyLayer==nil )then
        return
    end

    if Unlock.isUnlock(SYS_TASK,false) == false then
        Data.redpos.bolDayTask = false;
        Data.redpos.bolAchieve = false;
        Data.redpos.bolDayEnergy = false;
    end

    if(Data.redpos.bolHero or
        Data.redpos.bolDayTask or Data.redpos.bolAchieve
        or Data.redpos.bolDayEnergy) then
        RedPoint.add(gMainMoneyLayer:getNode("btn_menu"),cc.p(0,0.8))
    else
        RedPoint.remove(gMainMoneyLayer:getNode("btn_menu"))
    end

    if(Data.redpos.bolHero) then
        RedPoint.add(gMainMoneyLayer:getNode("btn_hero"),RedPoint.menuAnchorPoint)
    else
        RedPoint.remove(gMainMoneyLayer:getNode("btn_hero"))
    end

    --卧龙窟
    if gMainBgLayer then
        local bg = gMainBgLayer:getBuildTitle(SYS_PET_TOWER);
        RedPoint.refresh(bg,Data.redpos.swp,RedPoint.getBuildTitleAnchor());
    end

    --邮件
    RedPoint.mail();
    --军团
    RedPoint.family();
    --任务
    RedPoint.task();
    RedPoint.pet();
    --好友
    RedPoint.friend();
    --签到
    RedPoint.sign();
    --聊天
    RedPoint:chat();
    --点将台
    RedPoint.dragon()
    --试炼
    RedPoint.actAtlas()
    --活动
    RedPoint.activity()
    --竞技场
    -- RedPoint.arena()
    --在线礼包
    RedPoint.onlineGift()
    RedPoint.crusade()
    RedPoint.luckWheel()
    RedPoint.richman()
    --公告
    RedPoint.notice()
    --命魂
    RedPoint.soullife()
    --挖矿
    RedPoint.digMine()
    --新手任务
    RedPoint.newTask();
    --七日任务
    RedPoint.task7Day();
    RedPoint.familySkill();
    RedPoint.mall();
    RedPoint.bag()
    RedPoint.lootfood()
    RedPoint.constellation()
    RedPoint.newboss()

    RedPoint.petCave()
end

