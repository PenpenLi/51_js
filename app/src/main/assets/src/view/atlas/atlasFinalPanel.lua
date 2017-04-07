local AtlasFinalPanel=class("AtlasFinalPanel",UILayer)

local lostStrengthen = cc.FileUtils:getInstance():getValueMapFromFile("fightScript/battleLostStrengthen.plist")

function AtlasFinalPanel:ctor(data,needSkip)
    self:init("ui/battle_resule_fb_win.map")
    print_lua_table(data, 4)
    self.isBlackBgVisible=false
    self.isMainLayerGoldShow=false
    self.isMainLayerMenuShow=false
    data={}
    data.win=Battle.win
    data.gold=0
    data.cardExp=0
    data.exp=0
    data.star=3
    self.needSkip=needSkip
    data.rewardItems={}
    data.battleType = Battle.battleType
    if(Battle.reward.starNum)then
        data.star= Battle.reward.starNum
    end

    if(Battle.reward.shows)then
        if(Battle.reward.shows.items)then
            data.rewardItems=Battle.reward.shows.items
        end


        if(Battle.reward.shows.exp)then
            data.exp=Battle.reward.shows.exp
        end

        if(Battle.reward.shows.cardExp)then
            data.cardExp=Battle.reward.shows.cardExp
        end

        if(Battle.reward.shows.gold)then
            data.gold=Battle.reward.shows.gold
        end
    end


    data.formation={}

    if(Battle.reward.formation)then
        data.formation=Battle.reward.formation
    end

    self.curData = data
    self.showStarTime = 0
    self.showRewardTime = 0
    self.isProcessShowLevUp = false
    self:setWinOrLostShow()
    self:processShowLevUp()

 
    if(  self.touchEnable~=false)then
        local function onCallback()
            self.touchEnable=true
        end
        self.touchEnable=false
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(onCallback)))
    end

    if(self.curData.win == 1 and self.curData.battleType == BATTLE_TYPE_ATLAS and Net.sendAtlasEnterParam.type == 0)then
        -- print("Net.sendAtlasEnterParam.mapid = "..Net.sendAtlasEnterParam.mapid);
        -- print("Net.sendAtlasEnterParam.stageid = "..Net.sendAtlasEnterParam.stageid);
        Unlock.checkUnlockByAtlas(Net.sendAtlasEnterParam.mapid, Net.sendAtlasEnterParam.stageid);
    end

    if(self.curData.battleType == BATTLE_TYPE_ARENA) then
        if Unlock.isUnlock(SYS_CHAT,false) then
            self:getNode("layer_show"):setVisible(true)
        end 
    end

    self:hideCloseModule();

    local function onNodeEvent(event)
        if event == "exit" then
            self:unscheduleUpdateEx()
        end
    end
    self:registerScriptHandler(onNodeEvent); 
end

function AtlasFinalPanel:hideCloseModule()
    if(self:showShare())then
        self:getNode("panel_share"):setVisible(self.curData.win==1 and not Module.isClose(SWITCH_SHARE));
    end
end

function AtlasFinalPanel:showShare()
    self:getNode("panel_share"):setVisible(false);
    -- self.curData.battleType == BATTLE_TYPE_ARENA
    if(self.curData.battleType == BATTLE_TYPE_ATLAS)then
        self:getNode("panel_share"):setVisible(true);
        return true;
    end
    return false;
end

function  AtlasFinalPanel:showStar(num)
    for i=1, 3 do
        local star=self:getNode("star_up"..i)
        if(i<=num)then
            local function playStar()
                local effect = gCreateFla("ui-win-xingxing", -1)
                effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                star:addChild(effect)
            end
            star:runAction( cc.Sequence:create(cc.DelayTime:create(i*0.3), cc.CallFunc:create(playStar)) )
            self.showStarTime = i * 0.3
        end
    end
end


function  AtlasFinalPanel:showWinRewards()
    self:setLabelString("txt_win_gold","+"..self.curData.gold)
    self:setLabelString("txt_win_exp","+"..self.curData.exp)
    if nil ~= gUserInfo.level then
        self:setLabelString("txt_win_lv",getLvReviewName("Lv")..gUserInfo.level)
    end

    if(self.curData.battleType == BATTLE_TYPE_BATH )then
        self:getNode("txt_win_gold"):setVisible(false)
        self:getNode("gold_icon"):setVisible(false)
        
    end

    if nil ~= gUserInfo.exp and nil ~= gUserInfo.level then
        local expData= DB.getUserExpByLevel(gUserInfo.level)
        self:setBarPer("bar_win_exp",gUserInfo.exp/expData.exp)
    end

    for k, cardData in pairs(self.curData.formation) do
        local card = Data.getUserCardById(cardData.cardid)
        if nil ~= card and nil ~= gBattleLayer:getChildren()[1] then
            local role = gBattleLayer:getChildren()[1]:getRoleByCardid(cardData.cardid)
            if nil ~= role then
                local expBar = ExpBar.new()
                local levUp = expBar:setExpInfo(card.level,card.exp,cardData.addExp)
                role:addChild(expBar)
                if levUp then
                    role:addChild(gCreateFla("ui_levelup_guang", -1))
                    role:addChild(gCreateFla("ui_levelup_pai", -1))
                end
            end
        end
    end

    if self.curData.battleType == BATTLE_TYPE_ARENA  then
        for key, item in pairs(self.curData.rewardItems) do
            if not Data.isRewardItemShouldBeSkipped(self.__cname, item.id) or self.needSkip==false then
                local node = DropItem.new()
                node:setData(item.id)
                node:setNum(item.num)
                node:setPositionY(node:getContentSize().height)
                local arenaReward = self:getNode("icon_arena_reward")
                arenaReward:addChild(node)
                arenaReward:setScale(0.6)
                self:setNodeAppear("icon_arena_reward",true)
                break
            end
        end
        
    else
        local idx=1
        local scrollWinItems = self:getNode("scroll_win_items")
        scrollWinItems.itemScale = 0.75
        local offsetX = nil
        local offsetY = nil
        for key, item in pairs(self.curData.rewardItems) do
            if not Data.isRewardItemShouldBeSkipped(self.__cname, item.id)  or self.needSkip==false then
                local node = DropItem.new()
                node:setData(item.id)
                node:setNum(item.num)
                node:setOpacity(0)
                gSetCascadeOpacityEnabled(node,true)
                node:setAnchorPoint(cc.p(0.5, -0.5))
                scrollWinItems:addItem(node)
                if nil == offsetX then
                    offsetX = node:getContentSize().width / 2
                end  
                local type=DB.getItemType(item.id)
                 if(item.num==2  )then
                 	if( type==ITEMTYPE_EQU or type==ITEMTYPE_EQU_SHARED or type==ITEMTYPE_CARD_SOUL)then

                    	local  double=cc.Sprite:create("images/ui_public1/x2.png")
                    	double:setPositionX(double:getContentSize().width/2)
                    	double:setPositionY(-double:getContentSize().height/2)
                    	node:addChild(double,100)
                 	end

                end

                if nil == offsetY then
                    offsetY = node:getContentSize().height / 2
                end

            end
        end

        if nil ~= offsetX and nil ~= offsetY then
            scrollWinItems:setPaddingXY(offsetX * scrollWinItems.itemScale , -offsetY * scrollWinItems.itemScale)
        end
        scrollWinItems:layout()

        local itemBeginShowTime = 0.5 + self.showStarTime
        local itemIntervalTime  = 0.2
        local winItemIndex      = 1
        local winItems          = self:getNode("scroll_win_items").items
        local winItemsCount        = table.count(winItems)
        for key, item in pairs(winItems) do
            item:setScale(0.6)
            local delay   = cc.DelayTime:create(itemBeginShowTime + itemIntervalTime * (key-1))
            local fadeIn  = cc.FadeIn:create(itemIntervalTime)
            local scaleTo1 = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime,0.85))
            local scaleTo2 = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime/2,0.75))
            local effectCallback = cc.CallFunc:create(function ()
                local effect=gCreateFla("ui_win_kuang_guang")
                effect:setAnchorPoint(cc.p(0.5, 0.5))
                local contentSize = item:getContentSize()
                effect:setPosition(contentSize.width  / 2, - contentSize.height / 2)
                item:addChild(effect , 100)
            end)
            item:runAction(cc.Sequence:create(delay,effectCallback, cc.Spawn:create(fadeIn,scaleTo1), scaleTo2 ))
        end

        local maxWinItemIndex = #winItems
        if maxWinItemIndex > 0 then
            self.showRewardTime = itemBeginShowTime + itemIntervalTime * (maxWinItemIndex + 1/2)
        end
    end
end

function  AtlasFinalPanel:calculatePerLv(lv,exp,addExp)
    local preLv=lv
    local preExp=exp

    local preExp=exp-addExp
    while(preExp<0)do
        preLv=preLv-1
        local maxExp= DB.getCardExpByLevel(preLv)
        preExp=preExp+maxExp
    end
    return preLv,preExp
end

function AtlasFinalPanel:showExpUp(name,preLv,newLv,preExp,newExp)
    local function checkAdd()
        if(preLv==newLv)then
            local maxExp=DB.getCardExpByLevel(newLv)
            self:setBarPerAction(name,  preExp/maxExp, newExp/maxExp)
        else
            local maxExp=DB.getCardExpByLevel(preLv)
            self:setBarPerAction(name,  preExp/maxExp, 1,checkAdd)
            preExp=0
            preLv=preLv+1
        end
    end
    checkAdd()
end

function AtlasFinalPanel:onTouchEnded(target)
    if target.touchName=="btn_lost_exit" then
        Scene.enterMainScene()
    elseif target.touchName=="btn_win_exit"  then
        -- 精英翻牌奖励
        --[[if CoreAtlas.EliteFlop.checkShowFlop() == true then
            return
        end]]
        if (self.curData.win == 1) and Scene.needLevelup and (not self.isProcessShowLevUp) then
            self.isProcessShowLevUp = true
            self:getNode("ctr_show_levup"):runAction(cc.CallFunc:create(function()
                Scene.showLevelUp = true
            end))

            if(Guide.getCurGuideChain() )then
                if(Guide.curGuideChain.id==GUIDE_ID_ATLAS_SELECT_STAGE2_END )then
                    Guide.dispatch(GUIDE_ID_ATLAS_SELECT_STAGE2_END,1) 
                end
            end
            return
        end
        local battleType=self.curData.battleType
        local atlasType = -1;
        if(Net.sendAtlasEnterParam)then
            atlasType = Net.sendAtlasEnterParam.type;
        end
        Scene.enterMainScene()
        --*******************
        --self被清空，以下代码都不能用self
        --当前通过动画的章节名及相应的文字只配制到第5关，暂时屏蔽第5关以后的通关动画
        if battleType == BATTLE_TYPE_ATLAS  and gAtlas.isShowPassedFlag then
            if Net.sendAtlasEnterParam.mapid <= Data.getMaxAtlasPassedIntro() then
                Panel.popUp(PANEL_ATLAS_COMPLETE, Net.sendAtlasEnterParam.mapid)
            elseif Net.sendAtlasEnterParam.mapid == PRE_ATLAS_XIAMAN_MAPID then
                Panel.popUp(PANEL_ATLAS_COMPLETE_CG, PRE_ATLAS_XIAMAN_MAPID)
            elseif Net.sendAtlasEnterParam.mapid < MAX_ATLAS_NUM then
                local panel = Panel.getPanelByType(PANEL_ATLAS)
                if nil ~= panel then
                    gAtlas.showCharpterOpen = true
                end
            end
        end

        if(battleType == BATTLE_TYPE_ATLAS and atlasType == 0)then
            Unlock.show();
        end

    elseif target.touchName=="btn_data2" or target.touchName=="btn_data" then
        Panel.popUp(PANEL_BATTLE_DATA)
    elseif target.touchName=="btn_win_retry" or target.touchName=="btn_lost_retry" then
        gResetBattleData()
        Panel.popUp(PANEL_ATLAS_ENTER, {mapid=Net.sendAtlasEnterParam.mapid, stageid=Net.sendAtlasEnterParam.stageid,type=Net.sendAtlasEnterParam.type})
    elseif target.touchName == "btn_show" then
        self:showArenaWin()
    elseif target.touchName == "btn_share" then
        if(self.curData.battleType == BATTLE_TYPE_ATLAS)then
            local data = {};
            data.star = self.curData.star;
            data.mapid = Net.sendAtlasEnterParam.mapid;
            data.stageid = Net.sendAtlasEnterParam.stageid;
            Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ATLAS,shareType = SHARE_TYPE_ATLAS,shareData = data});
        elseif(self.curData.battleType == BATTLE_TYPE_ARENA)then
            local data = {};
            data.rank = gUserInfo.rank;
            Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ARENA_ATTACK,shareType = SHARE_TYPE_ARENA,shareData = data}); 
        end
    elseif target.touchName == "btn_flop"then
        --弹出翻牌奖励 map
        local atlasType = -1
        if(Net.sendAtlasEnterParam)then
            atlasType = Net.sendAtlasEnterParam.type
        end
        if(self.curData.battleType == BATTLE_TYPE_ATLAS and atlasType == 1)then
            local left_time = EliteFlop.getFlopEndTime(Net.sendAtlasEnterParam.mapid,
                                                        Net.sendAtlasEnterParam.stageid)
            if left_time > 0 then
                Panel.popUpUnVisible(PANEL_ATLAS_ELITE_FLOP,nil,nil,true)
            end
            
        end
    end 
end

function AtlasFinalPanel:showArenaWin() 
    local index = math.mod(Battle.brief.vid,5) + 1
    local sWord = gGetWords("arenaWords.plist","winword" .. index);
    Net.sendArenaBrief(sWord,Battle.brief.n1, Battle.brief.n2, Battle.brief.vid)
    self:setTouchEnableGray("btn_show",false)
    sWord = gGetWords("arenaWords.plist","showoff");
    gShowNotice(sWord)
end 

function AtlasFinalPanel:setWinOrLostShow()
    if(self.curData.win==1)then
        self:getNode("panel_lost"):setVisible(false)
        self:getNode("panel_lost_title"):setVisible(false)
        self:getNode("panel_lose_red"):setVisible(false)
        self:getNode("panel_win"):setVisible(true)
        self:getNode("panel_win_title"):setVisible(true)
        self:setNodeAppear("panel_win_title")
        self:getNode("scroll_win_items"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self:showBtn(true)
        self:showArenaRewardOrNot()
        self:showWinStarTitle()
        self:showWinRewards()
        gPlayEffect("sound/bg/bgm_Win.mp3")
    else
        self:getNode("panel_lost"):setVisible(true)
        self:setNodeAppear("panel_lost")
        self:getNode("panel_lost_title"):setVisible(true)
        self:setNodeAppear("panel_lost_title")
        self:getNode("panel_lose_red"):setVisible(true)
        self:getNode("panel_win"):setVisible(false)
        self:getNode("panel_win_title"):setVisible(false)
        self:getNode("scroll_lost_items"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self:getNode("panel_share"):setVisible(false);
        self:showBtn(false)
        -- self:showTowerLost();
        self:showLostStrengthen()
        gPlayEffect("sound/bg/bgm_Lose.mp3")
    end
    AudioEngine.setMusicVolume(0.4)


end

function AtlasFinalPanel:showBtn(win)
    local retryName = "panel_win_retry"
    if not win then
        retryName = "panel_lost_retry"
    end

    if self.curData.battleType ~= BATTLE_TYPE_ATLAS then
        self:getNode(retryName):setVisible(false)
    else
        if self:isAtlasBigStage() then
            self:getNode(retryName):setVisible(true)
        else
            self:getNode(retryName):setVisible(false)
        end
    end
end

function AtlasFinalPanel:showTowerLost()

    if(self.curData.battleType == BATTLE_TYPE_TOWER)then

        self:setLabelString("txt_tower_result_tip",gGetWords("towerWords.plist","condition"..TowerPanelData.winData.wintype,TowerPanelData.winData.winval));
        -- self:getNode("bg_normal_lost"):setVisible(false);
        -- self:getNode("scroll_lost_items"):setVisible(false);
        self:getNode("tower_panel"):setVisible(true);

        -- self:setLabelString("txt_star",Data.towerInfo.tstar);
        -- local itemid = Data.towerInfo.disreward.id;
        -- if(itemid)then
        --     Icon.setDropItem(self:getNode("icon_gift"),itemid,Data.towerInfo.disreward.num,DB.getItemQuality(itemid));
        --     self:setLabelString("txt_name",DB.getItemName(itemid));
        --     self:setLabelString("txt_price1",Data.towerInfo.disreward.pri);
        --     self:setLabelString("txt_price2",math.floor(Data.towerInfo.disreward.pri*Data.towerInfo.disreward.dis/100));  
        -- end
        -- self:resetLayOut();  

    end
end

function AtlasFinalPanel:showLostStrengthen()
    local scrollStengthen = self:getNode("scroll_lost_items")
    local offsetX  = nil
    local offsetY  = nil
    scrollStengthen.itemScale = 1.0
    for k, v in pairs(lostStrengthen) do
        if gUserInfo.level >= toint(v.lev) then
            local node = LostStrengthenItem.new()
            node:setData(k, toint(v.itemid), v.desc)
            node:setAnchorPoint(cc.p(0.5, -0.5))
            node:setOpacity(0)
            gSetCascadeOpacityEnabled(node,true)
            scrollStengthen:addItem(node)
            if nil == offsetX then
                local isGuid = cc.UserDefault:getInstance():getBoolForKey("lostGuidFla"..gAccount.accountid,false)
                if isGuid == false then
                    loadFlaXml("ui_guide")
                    local lostGuidFla = gCreateFla("ui_guide_circle",1)
                    gAddChildByAnchorPos(node,lostGuidFla,cc.p(0.5, -0.5),cc.p(0,10))
                    cc.UserDefault:getInstance():setBoolForKey("lostGuidFla"..gAccount.accountid,true)
                end
                offsetX = node:getContentSize().width / 2
            end

            if nil == offsetY then
                offsetY = node:getContentSize().height / 2
            end
        end
    end
    if nil ~= offsetX and nil ~= offsetY then
        scrollStengthen:setPaddingXY(offsetX * scrollStengthen.itemScale , -offsetY * scrollStengthen.itemScale)
    end
    scrollStengthen:layout()

    local itemBeginShowTime = 0.5
    local itemIntervalTime  = 0.2
    for key, item in pairs(self:getNode("scroll_lost_items").items) do
        item:setScale(0.9)
        local delay   = cc.DelayTime:create(itemBeginShowTime + itemIntervalTime * (key-1))
        local fadeIn  = cc.FadeIn:create(itemIntervalTime)
        local scaleTo1 = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime,1.1))
        local scaleTo2 = cc.EaseBackOut:create(cc.ScaleTo:create(itemIntervalTime / 2,1.0))
        -- local effectCallback = cc.CallFunc:create(function ()
        --     local effect=gCreateFla("ui_win_kuang_guang")
        --     item:addChild(effect)
        -- end)
        item:runAction(cc.Sequence:create(delay, cc.Spawn:create(fadeIn,scaleTo1), scaleTo2))
    end
end

function AtlasFinalPanel:showWinStarTitle()
    if self:isAtlasBigStage() then
        self:getNode("panel_win_big_title"):setVisible(true)
        self:setNodeAppear("panel_win_big_title")
        self:getNode("panel_win_small_title"):setVisible(false)
        self:showStar(self.curData.star)
    else
        self:getNode("panel_win_big_title"):setVisible(false)
        self:getNode("panel_win_small_title"):setVisible(true)
        self:setNodeAppear("panel_win_small_title")
    end
end

function AtlasFinalPanel:isAtlasBigStage()
    if self.curData.battleType ~= BATTLE_TYPE_ATLAS and self.curData.battleType ~= BATTLE_TYPE_MINING_ATLAS then
        return false
    end

    if self.curData.battleType == BATTLE_TYPE_MINING_ATLAS then
        return true
    end
    
   

    local curStage=DB.getStageById(Net.sendAtlasEnterParam.mapid,Net.sendAtlasEnterParam.stageid,Net.sendAtlasEnterParam.type)
    if nil == curStage then
        return false
    end

    if curStage.node == 0 then
        return false
    end
    if curStage.islast ==2 then 
        return false
    end
    return true
end

function AtlasFinalPanel:showArenaRewardOrNot()
    if self.curData.battleType == BATTLE_TYPE_ARENA then
        self:getNode("icon_arena_reward"):setScale(0.75)
        self:getNode("icon_arena_reward"):setVisible(true)
        self:getNode("scroll_win_items"):setVisible(false)
    else
        self:getNode("icon_arena_reward"):setVisible(false)
        self:getNode("scroll_win_items"):setVisible(true)
    end
end

function AtlasFinalPanel:processShowLevUp()
    if (self.curData.win == 1) and (Scene.needLevelup --[[or CoreAtlas.EliteFlop.bNeedEliteFlop]]) then
        local minMaxTime = 1.3
        -- local maxTime = math.max(self.showStarTime, self.showRewardTime)
        local maxTime = self.showRewardTime + self.showStarTime
        if maxTime >= 2 then
            maxTime = maxTime - 0.4
        elseif maxTime >= 2.6 then
            maxTime = maxTime - 0.8
        end

        if maxTime < minMaxTime then
            maxTime = minMaxTime
        end


        local delay   = cc.DelayTime:create(maxTime)
        self:getNode("ctr_show_levup"):runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
            -- 精英翻牌奖励
            --[[if CoreAtlas.EliteFlop.checkShowFlop() == true then
                return
            end]]
            if not self.isProcessShowLevUp then
                Scene.showLevelUp = true
            end
        end)))
    end
end


return AtlasFinalPanel