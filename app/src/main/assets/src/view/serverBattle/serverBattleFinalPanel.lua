local ServerBattleFinalPanel=class("ServerBattleFinalPanel",UILayer)

local FINAL_STATE_STAR_NONE = 1
local FINAL_STATE_STAR_UP   = 2
local FINAL_STATE_STAR_DOWN = 3

local FINAL_STATE_SEC_NONE  = 1
local FINAL_STATE_SEC_UP    = 2
local FINAL_STATE_SEC_DOWN  = 3

local FINAL_WIN = 1
local FINAL_LOSE = 2

function ServerBattleFinalPanel:ctor()
    self:init("ui/ui_serverbattle_final.map")
    loadFlaXml("ui_kuafujiesuan")
    self:initStarsPanel()
    -- if self.starsNum ~= 1 then
    --     self:showStar()
    -- end 
end

function ServerBattleFinalPanel:events()
    return {

        }
end

function ServerBattleFinalPanel:dealEvent(event, param)

end

function ServerBattleFinalPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_win_data" then
        Panel.popUp(PANEL_BATTLE_DATA)
    else
        Scene.enterMainScene()
    end
end

function ServerBattleFinalPanel:initStarsPanel()
    --先隐藏连胜图标
    self:getNode("flag_winning"):setVisible(false)
    --获取段位type以及星星
    self.curSecType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)
    self.oldSecType = DB.getServerBattleSecTypeByLv(gServerBattle.oldSectionLv)
    self.resultFlag = Battle.win
    --设置星星数
    self.oldStarsTotalNum = DB.getServerBattleTotalStarsByLv(self.oldSecType)
    self.oldStarsNum = self:getOldStarNums()

    if self.curSecType ~= SERVER_BATTLE_DUAN16 then
        --是否同一段位
        if self.curSecType > self.oldSecType then --晋级
            self:changeTexture("title_result", "images/ui_word/s_win.png")
            self.secState = FINAL_STATE_SEC_UP
            self.starState = FINAL_STATE_STAR_UP
        elseif self.curSecType < self.oldSecType then --降段
            self:changeTexture("title_result", "images/ui_word/s_lose.png")
            self.secState = FINAL_STATE_SEC_DOWN
            self.starState = FINAL_STATE_STAR_DOWN
        else
            self.secState = FINAL_STATE_SEC_NONE
            --是否升星或降星
            if self.resultFlag == 1 then
                self:changeTexture("title_result", "images/ui_word/s_win.png")
                self.starState = FINAL_STATE_STAR_UP
            else
                self:changeTexture("title_result", "images/ui_word/s_lose.png")
                if gServerBattle.sectionLv == gServerBattle.oldSectionLv then
                    self.starState = FINAL_STATE_STAR_NONE 
                else
                    self.starState = FINAL_STATE_STAR_DOWN 
                end
            end
        end
        --设置徽章和名字
        self:setOldSectionInfo()
        self:setOldStarsShow()
        self:processStarsAction()
    else
        --从大师升级到王者
        if gServerBattle.sectionLv > gServerBattle.oldSectionLv then
            self:processNormalToKingRank()
        else
            Icon.setSecOfSeverBattle(self:getNode("icon_section"),gServerBattle.sectionLv)
            local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
            self:setLabelString("txt_section_name", secName)
            if gServerBattle.oldKingRank ~= nil and gServerBattle.oldKingRank <= gServerBattle.kingRank then

            end

            if self.resultFlag == 1 then
                self:changeTexture("title_result", "images/ui_word/s_win.png")           
            else
                self:changeTexture("title_result", "images/ui_word/s_lose.png")  
            end

            self:getNode("panel_stars"):setVisible(false)
            self:getNode("layout_king_rank"):setVisible(true)
            self:processKingRank()
        end
    end
    if self.resultFlag == 1 then
        DisplayUtil.setGray(self:getNode("icon_flag"),false)
    else
        DisplayUtil.setGray(self:getNode("icon_flag"),true) 
    end
end

function ServerBattleFinalPanel:processStarsAction()
    --升星
    if self.starState == FINAL_STATE_STAR_UP then
        --如果已经升段
        if self.secState == FINAL_STATE_SEC_UP then
            --先播升星到满的动画
            local showIdx = 1
            local starPlayTime = 0
            for i = self.oldStarsNum + 1, self.oldStarsTotalNum do
                local star = self:getNode("icon_star"..i)
                star:runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime + showIdx*0.3), cc.CallFunc:create(function ()
                        local effect = gCreateFla("ui_kfjs_zaxing", -1)
                        effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                        star:addChild(effect)
                end)))
                starPlayTime = starPlayTime + 0.2 + 0.3
            end
            --星星面板更新
            local spawn1 = cc.Spawn:create(
                    cc.FadeOut:create(0.3),
                    cc.EaseBackIn:create(cc.ScaleTo:create(0.3,0.1)))

            local spawn2 = cc.Spawn:create(
                    cc.FadeIn:create(0.3),
                    cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1.0)))


            self:getNode("panel_stars"):runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime),spawn1,
                cc.CallFunc:create(function()
                    self:resetStarsPanel()
                end),spawn2))
            starPlayTime = starPlayTime + 0.8

            --播放星星效果
            self.curStarsNum = self:getCurStarNums()
            showIdx = 0
            for i = 1, self.curStarsNum do
                local star = self:getNode("icon_star"..i)
                star:runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime + showIdx*0.3), cc.CallFunc:create(function ()
                        local effect = gCreateFla("ui_kfjs_zaxing", -1)
                        effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                        star:addChild(effect)
                end)))
                showIdx = showIdx + 1
                starPlayTime = starPlayTime + 0.3
            end

            --升段徽章切换
            self:getNode("icon_section"):runAction( cc.Sequence:create(cc.DelayTime:create(starPlayTime),
                cc.CallFunc:create(function ()
                    local iconFla = gCreateFla("ui_kfjs_jinji",-1)
                    local badge1 = cc.Sprite:create()
                    Icon.setSecOfSeverBattle(badge1,gServerBattle.oldSectionLv)
                    local badge2 = cc.Sprite:create()
                    Icon.setSecOfSeverBattle(badge2,gServerBattle.sectionLv)
                    local badge3 = cc.Sprite:create()
                    Icon.setSecOfSeverBattle(badge3,gServerBattle.sectionLv)
                    iconFla:replaceBoneWithNode({"badge1"},badge1)
                    iconFla:replaceBoneWithNode({"badge2"},badge2)
                    iconFla:replaceBoneWithNode({"badge3"},badge3)
                    self:replaceNode("icon_section", iconFla)
                    local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
                    self:setLabelString("txt_section_name", secName)
                end)))

            starPlayTime = starPlayTime + 0.7
            self:processSecUpOrDown(starPlayTime,true)
            starPlayTime = starPlayTime + 0.4
            self:processWinningFlag(starPlayTime)
        elseif self.secState == FINAL_STATE_SEC_NONE then
            local showIdx = 1
            local starPlayTime = 0
            local minLv = DB.getServerBattleRangeSecLvByType(self.curSecType)
            for i = self.oldStarsNum + 1, gServerBattle.sectionLv - minLv do
                local star = self:getNode("icon_star"..i)
                star:runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime + showIdx*0.3), cc.CallFunc:create(function ()
                        local effect = gCreateFla("ui_kfjs_zaxing", -1)
                        effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                        star:addChild(effect)
                end)))
                showIdx = showIdx + 1
                starPlayTime = starPlayTime + 0.3 + 0.5
            end
            self:processWinningFlag(starPlayTime)
        end
    elseif self.starState == FINAL_STATE_STAR_DOWN then
        --如果有降级
        if self.secState == FINAL_STATE_SEC_DOWN then
            --先播降星到满的动画
            local showIdx = 1
            local starPlayTime = 0
            for i = self.oldStarsNum, 1, -1 do
                local star = self:getNode("icon_star"..i)
                star:runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime + showIdx * 0.3), cc.CallFunc:create(function ()
                        self:changeTexture("icon_star"..i, "images/ui_public1/star_mid_1.png")
                        local effect = FlashAni.new()
                        effect:playAction("ui_kfjs_diaoxing", function()
                            effect:removeFromParent()
                        end, nil, 1)
                        effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                        star:addChild(effect)
                end)))
                showIdx = showIdx + 1
                starPlayTime = starPlayTime + 0.3 + 0.9
            end
            if 0 == starPlayTime then
                starPlayTime = 0.5
            end
            --星星面板更新
            local spawn1 = cc.Spawn:create(
                    cc.FadeOut:create(0.2),
                    cc.EaseBackIn:create(cc.ScaleTo:create(0.2,0.1)))

            local spawn2 = cc.Spawn:create(
                    cc.FadeIn:create(0.2),
                    cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1.0)))


            self:getNode("panel_stars"):runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime),spawn1,
                cc.CallFunc:create(function()
                    self:resetStarsPanel()
                    for i = 1, self.curStarsTotalNum do
                        self:changeTexture("icon_star"..i, "images/ui_public1/star_mid.png")
                    end
                end),spawn2))
            starPlayTime = starPlayTime + 0.6

            --播放星星效果
            self.curStarsNum = self:getCurStarNums()
            self.curStarsTotalNum = DB.getServerBattleTotalStarsByLv(self.curSecType)

            showIdx = 1
            for i=self.curStarsTotalNum ,self.curStarsNum + 1,-1 do
                local star = self:getNode("icon_star"..i)
                star:runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime + showIdx * 0.3), cc.CallFunc:create(function ()
                        self:changeTexture("icon_star"..i, "images/ui_public1/star_mid_1.png")
                        local effect = FlashAni.new()
                        effect:playAction("ui_kfjs_diaoxing", function()
                            effect:removeFromParent()
                        end, nil, 1)
                        effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                        star:addChild(effect)
                end)))
                showIdx = showIdx + 1
                starPlayTime = starPlayTime + 0.3 + 0.9
            end

            --升段徽章切换
            self:getNode("icon_section"):runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime),
                cc.CallFunc:create(function ()
                    Icon.setSecOfSeverBattle(self:getNode("icon_section"),gServerBattle.sectionLv)
                    local iconFla = gCreateFla("ui_kfjs_jiangji",-1)
                    local badge2 = cc.Sprite:create()
                    Icon.setSecOfSeverBattle(badge2,gServerBattle.oldSectionLv)
                    local badge1 = cc.Sprite:create()
                    Icon.setSecOfSeverBattle(badge1,gServerBattle.sectionLv)
                    iconFla:replaceBoneWithNode({"badge1"},badge1)
                    iconFla:replaceBoneWithNode({"badge2"},badge2)
                    self:replaceNode("icon_section", iconFla)
                    local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
                    self:setLabelString("txt_section_name", secName)
                end)))
            starPlayTime = starPlayTime + 0.7
            self:processSecUpOrDown(starPlayTime,false)
            starPlayTime = starPlayTime + 0.8
        else
            local showIdx = 1
            local starPlayTime = 0
            local minLv = DB.getServerBattleRangeSecLvByType(self.curSecType)
            local curStarNums = gServerBattle.sectionLv - minLv
            for i = self.oldStarsNum,  curStarNums + 1, -1 do
                local star = self:getNode("icon_star"..i)
                star:runAction(cc.Sequence:create(cc.DelayTime:create(starPlayTime + showIdx*0.3), cc.CallFunc:create(function ()
                        local effect = FlashAni.new()
                        self:changeTexture("icon_star"..i, "images/ui_public1/star_mid_1.png")
                        effect:playAction("ui_kfjs_diaoxing", function()
                            effect:removeFromParent()
                        end, nil, 1)
                        effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                        star:addChild(effect)
                end)))
                showIdx = showIdx + 1
                starPlayTime = starPlayTime + 0.3 + 0.5
            end
        end
    end
end

function ServerBattleFinalPanel:getOldStarNums()
    local minLv,maxLv = DB.getServerBattleRangeSecLvByType(self.oldSecType)
    return gServerBattle.oldSectionLv - minLv
end

function ServerBattleFinalPanel:getCurStarNums()
    local minLv,maxLv = DB.getServerBattleRangeSecLvByType(self.curSecType)
    return gServerBattle.sectionLv - minLv
end

function ServerBattleFinalPanel:resetStarsPanel()
    --设置星星数
    self.curStarsTotalNum = DB.getServerBattleTotalStarsByLv(self.curSecType)
    self.curStarsNum = self:getCurStarNums()
    if self.curSecType == SERVER_BATTLE_DUAN16 then
        self:getNode("panel_stars"):setVisible(false)
        self.curStarsTotalNum = 0
        self.curStarsNum = 0
    else
        self:getNode("panel_stars"):setVisible(true)
        for i = 1, 6 do
            self:getNode("icon_star"..i):removeAllChildren()
            if i <= self.curStarsTotalNum then
                self:getNode("icon_star"..i):setVisible(true)
                self:changeTexture("icon_star"..i, "images/ui_public1/star_mid_1.png")
            -- elseif i <= self.starsNum then
            --     self:changeTexture("icon_star"..i, "images/ui_public1/star_mid_1.png")
            elseif i > self.curStarsTotalNum then
                self:getNode("icon_star"..i):setVisible(false)
            end
        end
        self:getNode("panel_stars"):layout()
    end
end

function ServerBattleFinalPanel:processKingRank()
    if gServerBattle.kingRank == nil then
        self:getNode("layout_king_rank"):setVisible(false)
    else
        if (gServerBattle.oldKingRank == nil) or (gServerBattle.oldKingRank == 0) then
            self:getNode("txt_old_king_rank"):setVisible(false)
            self:getNode("txt_king_arrow"):setVisible(false)
            self:setLabelAtlas("txt_cur_king_rank", gServerBattle.kingRank)
            self:getNode("layout_king_rank"):layout()
        else
            self:setLabelAtlas("txt_old_king_rank", gServerBattle.oldKingRank)
            self:setLabelAtlas("txt_cur_king_rank", gServerBattle.oldKingRank)
            self:getNode("txt_old_king_rank"):setVisible(true)
            self:getNode("txt_king_arrow"):setVisible(true)
            self:getNode("layout_king_rank"):layout()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function( ... )
                self:scheduleKingRank()
            end)))
        end
    end
end

--处理连胜
function ServerBattleFinalPanel:processWinningFlag(delayTime)
    if gServerBattle.winning ~= 0 then
        if nil == self.oldSecType or
           self.curSecType ~= SERVER_BATTLE_DUAN16 or
           self.curSecType == SERVER_BATTLE_DUAN16 and self.curSecType ~= self.oldSecType then            
           self:getNode("flag_winning"):runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function()
                    local winningFla = FlashAni.new()
                    winningFla:playAction("ui_kfjs_liansheng", function ()
                        winningFla:playAction("ui_kfjs_liansheng2")
                        local labNum2 = gCreateLabelAtlas("images/ui_num/hit_num.png",60,74,gServerBattle.winning,-3,0)
                        winningFla:replaceBoneWithNode({"shuzi"},labNum2)
                    end, nil, 1)
                    local labNum = gCreateLabelAtlas("images/ui_num/hit_num.png",60,74,gServerBattle.winning,-3,0)
                    winningFla:replaceBoneWithNode({"shuzi"},labNum)
                    self:replaceNode("flag_winning", winningFla)
           end)))
        end
    end
end

function ServerBattleFinalPanel:processNormalToKingRank()
    self:setOldSectionInfo()
    self:setOldStarsShow()

    local starPlayTime = 0
    starPlayTime = self:playStarUp(self.oldStarsTotalNum ,starPlayTime)

    --星星面板更新
    starPlayTime = self:playPanelActToKingRank(true,starPlayTime)
    --升段徽章切换
    self:playSecUpToKingRank(starPlayTime)
    starPlayTime = starPlayTime + 2.0
    self:processWinningFlag(starPlayTime)
end

function ServerBattleFinalPanel:setOldStarsShow()
    self:getNode("panel_stars"):setVisible(true)
    self:getNode("layout_king_rank"):setVisible(false)
    for i = 1, 6 do
        if i <= self.oldStarsNum then
            self:changeTexture("icon_star"..i, "images/ui_public1/star_mid.png")
        elseif i > self.oldStarsTotalNum then
            self:getNode("icon_star"..i):setVisible(false)
        end
    end
    self:getNode("panel_stars"):layout()
end

function ServerBattleFinalPanel:setOldSectionInfo()
    --设置徽章和名字
    Icon.setSecOfSeverBattle(self:getNode("icon_section"),gServerBattle.oldSectionLv)
    local secName = DB.getServerBattleSecNameByLv(gServerBattle.oldSectionLv)
    self:setLabelString("txt_section_name", secName)
end

function ServerBattleFinalPanel:playStarUp(endIdx,starPlayTime)
    local showIdx = 1
    local elapseTime = starPlayTime
    for i = self.oldStarsNum + 1, endIdx do
        local star = self:getNode("icon_star"..i)
        star:runAction(cc.Sequence:create(cc.DelayTime:create(elapseTime + showIdx*0.3), cc.CallFunc:create(function ()
                local effect = gCreateFla("ui_kfjs_zaxing", -1)
                effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                star:addChild(effect)
        end)))
        elapseTime = elapseTime + 0.5
    end
    return elapseTime
end

function ServerBattleFinalPanel:playSecUp(starPlayTime)
    self:getNode("icon_section"):runAction( cc.Sequence:create(cc.DelayTime:create(starPlayTime),
        cc.CallFunc:create(function ()
            local iconFla = gCreateFla("ui_kfjs_jinji",-1)
            local badge1 = cc.Sprite:create()
            Icon.setSecOfSeverBattle(badge1,gServerBattle.oldSectionLv)
            local badge2 = cc.Sprite:create()
            Icon.setSecOfSeverBattle(badge2,gServerBattle.sectionLv)
            local badge3 = cc.Sprite:create()
            Icon.setSecOfSeverBattle(badge3,gServerBattle.sectionLv)
            iconFla:replaceBoneWithNode({"badge1"},badge1)
            iconFla:replaceBoneWithNode({"badge2"},badge2)
            iconFla:replaceBoneWithNode({"badge3"},badge3)
            self:replaceNode("icon_section", iconFla)
            local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
            self:setLabelString("txt_section_name", secName)
        end)))
end

function ServerBattleFinalPanel:playPanelActToKingRank(isToRankPanel,starPlayTime)
    local elapseTime = starPlayTime
    local spawn1 = cc.Spawn:create(
            cc.FadeOut:create(0.3),
            cc.EaseBackIn:create(cc.ScaleTo:create(0.3,0.1)))

    local spawn2 = cc.Spawn:create(
            cc.FadeIn:create(0.3),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1.0)))

    self:getNode("panel_stars"):runAction(cc.Sequence:create(cc.DelayTime:create(elapseTime),spawn1,
        cc.CallFunc:create(function()
            self:getNode("panel_stars"):setVisible(false)
            self:getNode("layout_king_rank"):setOpacity(0)
            self:getNode("layout_king_rank"):setScale(0.1)
            self:getNode("layout_king_rank"):setVisible(true)
        end)))

    elapseTime = elapseTime + 0.4

    if isToRankPanel then
        self:getNode("layout_king_rank"):runAction(cc.Sequence:create(cc.DelayTime:create(elapseTime), cc.CallFunc:create(function()
            if gServerBattle.oldKingRank == nil then
                gServerBattle.oldKingRank = 0
            end
            self:getNode("txt_old_king_rank"):setVisible(true)
            self:getNode("txt_king_arrow"):setVisible(true)
            self:setLabelAtlas("txt_cur_king_rank", gServerBattle.oldKingRank)
            self:getNode("layout_king_rank"):layout()
            self:scheduleKingRank()
        end), spawn2))
        elapseTime = elapseTime + 1.0
    end

    return elapseTime
end

function ServerBattleFinalPanel:processSecUpOrDown(starTime, up)    
    self:getNode("title_result"):runAction(cc.Sequence:create(cc.DelayTime:create(starTime), cc.CallFunc:create(function()
        local titleFlag = nil
        if up then
            titleFlag = gCreateFla("ui_kfjs_qiehuanzi1",-1)
        else
            titleFlag = gCreateFla("ui_kfjs_qiehuanzi2",-1)
        end 
        self:replaceNode("title_result", titleFlag)
    end)))
end

function ServerBattleFinalPanel:playSecUpToKingRank(starPlayTime)
    self:getNode("icon_section"):runAction( cc.Sequence:create(cc.DelayTime:create(starPlayTime),
        cc.CallFunc:create(function ()
            local iconFla = gCreateFla("ui_kfjs_wangzhe",-1)
            local badge1 = cc.Sprite:create()
            Icon.setSecOfSeverBattle(badge1,gServerBattle.oldSectionLv)
            iconFla:replaceBoneWithNode({"badge1"},badge1)
            self:replaceNode("icon_section", iconFla)
            local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
            self:setLabelString("txt_section_name", secName)
        end)))
end

function ServerBattleFinalPanel:scheduleKingRank()
    self.recordKingRank = gServerBattle.oldKingRank
    local isKingRankUp = gServerBattle.kingRank < gServerBattle.oldKingRank
    local isSectToKingRank = (gServerBattle.oldKingRank == 0) and gServerBattle.kingRank > 0
    self:unscheduleUpdate()
    if math.abs(gServerBattle.kingRank - gServerBattle.oldKingRank) > 50 then
        local step = math.ceil( (gServerBattle.kingRank - gServerBattle.oldKingRank)/30)
        local curValue = gServerBattle.oldKingRank
        local function update(dt)
            if isSectToKingRank or (not isKingRankUp) then
                if curValue >= gServerBattle.kingRank then
                    curValue = gServerBattle.kingRank
                    self:setLabelAtlas("txt_cur_king_rank",curValue)
                    if isSectToKingRank then
                        local labelAtlas = self:getNode("txt_cur_king_rank")
                        local labelEffect = FlashAni.new()
                        labelEffect:playAction("ui_kfjs_duanwei_guang", function()
                            -- print("coming the ui_kfjs_duanwei_guang")
                            labelEffect:removeFromParent()
                        end, nil, 1)
                        gAddCenter(labelEffect, labelAtlas)
                    end 
                    self:unscheduleUpdate()
                else
                    curValue = curValue + step
                    if curValue >= gServerBattle.kingRank then
                        curValue = gServerBattle.kingRank
                    end
                    self:setLabelAtlas("txt_cur_king_rank",curValue)
                end
                
                -- self:getNode("layout_king_rank"):layout()
            else
                if curValue <= gServerBattle.kingRank then
                    curValue = gServerBattle.kingRank
                    self:setLabelAtlas("txt_cur_king_rank",curValue)
                    local labelEffect = FlashAni.new()
                    labelEffect:playAction("ui_kfjs_duanwei_guang", function()
                            labelEffect:removeFromParent()
                    end, nil, 1)
                    gAddCenter(labelEffect, self:getNode("txt_cur_king_rank"))
                    self:unscheduleUpdate()
                else
                    curValue = curValue + step
                    if curValue <= gServerBattle.kingRank then
                        curValue = gServerBattle.kingRank
                    end
                    self:setLabelAtlas("txt_cur_king_rank",curValue)
                end
                -- self:getNode("layout_king_rank"):layout()
            end
        end
        self:scheduleUpdateWithPriorityLua(update, 1)
    elseif math.abs(gServerBattle.kingRank - gServerBattle.oldKingRank) > 15 then
        local step = 0
        local function update(dt)
            step = step + dt
            if step >= 0.015 then
                if isSectToKingRank or (not isKingRankUp) then
                    self.recordKingRank = self.recordKingRank + 1
                    if self.recordKingRank <= gServerBattle.kingRank then
                        self:setLabelAtlas("txt_cur_king_rank", self.recordKingRank)
                        self:getNode("layout_king_rank"):layout()
                    else
                        if isSectToKingRank then            
                            local labelAtlas = self:getNode("txt_cur_king_rank")
                            local labelEffect = FlashAni.new()
                            labelEffect:playAction("ui_kfjs_duanwei_guang", function()
                                labelEffect:removeFromParent()
                            end, nil, 1)
                            gAddCenter(labelEffect, labelAtlas)
                        end
                        self:unscheduleUpdate()
                    end
                else
                    self.recordKingRank = self.recordKingRank - 1
                    if self.recordKingRank >= gServerBattle.kingRank then
                        self:setLabelAtlas("txt_cur_king_rank", self.recordKingRank)
                        -- self:getNode("layout_king_rank"):layout()
                    else           
                        local labelAtlas = self:getNode("txt_cur_king_rank")
                        -- self:getNode("layout_king_rank"):layout()
                        local labelEffect = FlashAni.new()
                        labelEffect:playAction("ui_kfjs_duanwei_guang", function()
                            labelEffect:removeFromParent()
                        end, nil, 1)
                        gAddCenter(labelEffect, labelAtlas)
                        self:unscheduleUpdate()
                    end
                end
                step = 0
            end
        end
        self:scheduleUpdateWithPriorityLua(update, 1)
    else
        local step = 0
        local function update(dt)
            step = step + dt
            if step >= 0.03 then
                if isSectToKingRank or (not isKingRankUp) then
                    self.recordKingRank = self.recordKingRank + 1
                    if self.recordKingRank <= gServerBattle.kingRank then
                        self:setLabelAtlas("txt_cur_king_rank", self.recordKingRank)
                        self:getNode("layout_king_rank"):layout()
                    else
                        if isSectToKingRank then            
                            local labelAtlas = self:getNode("txt_cur_king_rank")
                            local labelEffect = FlashAni.new()
                            labelEffect:playAction("ui_kfjs_duanwei_guang", function()
                                labelEffect:removeFromParent()
                            end, nil, 1)
                            gAddCenter(labelEffect, labelAtlas)
                        end
                        self:unscheduleUpdate()
                    end
                else
                    self.recordKingRank = self.recordKingRank - 1
                    if self.recordKingRank >= gServerBattle.kingRank then
                        self:setLabelAtlas("txt_cur_king_rank", self.recordKingRank)
                        -- self:getNode("layout_king_rank"):layout()
                    else           
                        local labelAtlas = self:getNode("txt_cur_king_rank")
                        -- self:getNode("layout_king_rank"):layout()
                        local labelEffect = FlashAni.new()
                        labelEffect:playAction("ui_kfjs_duanwei_guang", function()
                            labelEffect:removeFromParent()
                        end, nil, 1)
                        gAddCenter(labelEffect, labelAtlas)
                        self:unscheduleUpdate()
                    end
                end
                step = 0
            end
        end
        self:scheduleUpdateWithPriorityLua(update, 1)
    end
end

function ServerBattleFinalPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdate()
end

return ServerBattleFinalPanel