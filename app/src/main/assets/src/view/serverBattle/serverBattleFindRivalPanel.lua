local ServerBattleFindRivalPanel=class("ServerBattleFindRivalPanel",UILayer)

local FIND_STATE_STEP1  = 0
local FIND_STATE_STEP2 = 1
local FIND_STATE_STEP3 = 2
local FIND_STATE_STEP4 = 3


function ServerBattleFindRivalPanel:ctor()
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_serverbattle_find_rival.map")
    -- gServerBattle.clearRivalInfo()
    self:clearRivalInfos()
    self:initSkipFla()
    self:initPanel()
    self:initSchedule()
    self:initMeInfo()
end

function ServerBattleFindRivalPanel:events()
    return {
            EVENT_ID_SERVERBATTLE_FIND_RIVAL,
        }
end

function ServerBattleFindRivalPanel:dealEvent(event, param)
    if event == EVENT_ID_SERVERBATTLE_FIND_RIVAL then
        -- if #gServerBattle.rivalInfos == 0 then
        --     --弹框重置
        --     gConfirm(gGetWords("serverBattleWords.plist","not_find_rival"), function()
        --         self:onClose()
        --     end)
        -- else
        if param == 0 or param == 30 then
            self:setRivalInfos()
            self:setChangeInfo()
            self.state = FIND_STATE_STEP2
            if self.skipFindFla then
                for i = 1, 3 do
                    self:getNode("icon"..i):setVisible(false)
                    self:getNode("icon_bg"..i):removeChildByTag(300)
                    if self.rivalInfos[i] ~= nil and self.rivalInfos[i].icon ~= nil then
                        local findIcon = cc.Sprite:create()
                        findIcon:setScale(0.95)
                        Icon.setHeadIcon(findIcon,self.rivalInfos[i].icon)
                        gAddChildInCenterPos(self:getNode("icon_bg"..i),findIcon)
                        findIcon:setTag(300)
                        self:setRivalInfoByIdx(i)
                    end
                end
                self:processFlaFinish()
            else
                self:playFla()
            end
        elseif param == 11 then
            gConfirm(gGetWords("serverBattleWords.plist","season_finish"), function()
                self:onClose()
                local serverBattleMainPanle = Panel.getOpenPanel(PANEL_SERVER_BATTLE_MAIN)
                if nil ~= serverBattleMainPanle then
                    serverBattleMainPanle:onClose()
                end
            end)
        end
        -- end
    end 
end

function ServerBattleFindRivalPanel:initSchedule()
    local function update()
        if self.state == FIND_STATE_STEP1 then
            if gGetCurServerTime() >= self.step1EndTime then
                self.state = FIND_STATE_STEP2
                Net.sendWorldWarFind(false)
            end
        elseif self.state == FIND_STATE_STEP3 then
            if gGetCurServerTime() <= self.step3EndTime then
                local leftTime = self.step3EndTime - gGetCurServerTime()
                self:setLabelString("txt_choose_lefttime", leftTime)
            else
                self:unscheduleUpdateEx()
                self:autoChooseRival()
            end
        end
    end
    local curTime = gGetCurServerTime()
    --TODO,获取配制
    self.step1EndTime = curTime + FIND_RIVAL_TIME1
    self.step2EndTime = curTime + FIND_RIVAL_TIME1 + FIND_RIVAL_TIME2
    self:scheduleUpdate(update, 1)
end

function ServerBattleFindRivalPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
    cc.UserDefault:getInstance():setBoolForKey(Data.getCurUserId().."_skipFindRival", self.skipFindFla)
end

function ServerBattleFindRivalPanel:clearRivalInfos()
    for i = 1,3 do
        self:clearRivalInfoByIdx(i)
    end
    self.rivalIds = {}
end

function ServerBattleFindRivalPanel:setRivalInfos()
    local rivalsCount = #gServerBattle.rivalInfos
    self.rivalInfos = {{},{},{}}
    local randomTable = {1,2,3}
    local idx = 1
    if rivalsCount == 1 then
        idx = math.random(3)
        self.rivalInfos[randomTable[idx]] = gServerBattle.rivalInfos[1]
        self.rivalInfos[randomTable[idx]].idx = 1
    elseif rivalsCount == 2 then
        idx = math.random(3)
        self.rivalInfos[randomTable[idx]] = gServerBattle.rivalInfos[1]
        self.rivalInfos[randomTable[idx]].idx = 1
        table.remove(randomTable,idx)
        idx = math.random(2)
        self.rivalInfos[randomTable[idx]] = gServerBattle.rivalInfos[2]
        self.rivalInfos[randomTable[idx]].idx = 2
    elseif rivalsCount == 3 then
        self.rivalInfos = clone(gServerBattle.rivalInfos)
        self.rivalInfos[1].idx = 1
        self.rivalInfos[2].idx = 2
        self.rivalInfos[3].idx = 3
    end
end

function ServerBattleFindRivalPanel:clearRivalInfoByIdx(i)
    self:getNode("icon"..i):removeAllChildren()
    local ret=cc.Sprite:create("images/ui_severwar/npc_0.png")
    Icon.setNodeIcon(ret, self:getNode("icon"..i))
    self:getNode("txt_name"..i):setVisible(false)
    self:getNode("layout_power"..i):setVisible(false)
    self:getNode("layout_lv_rank"..i):setVisible(false)
end

function ServerBattleFindRivalPanel:setRivalInfoByIdx(idx)
    local rivalInfo = self.rivalInfos[idx]
    if rivalInfo.uid == nil then
        return
    end
    -- self.rivalIds[idx] = rivalInfo.uid
    -- Icon.setHeadIcon(self:getNode("icon"..idx), rivalInfo.uid )
    self:setLabelString("txt_name"..idx, rivalInfo.uname)
    self:setLabelString("txt_lv"..idx, rivalInfo.lv)
    if rivalInfo.sname == "" then
        self:setLabelString("txt_sname"..idx, gGetWords("serverBattleWords.plist","txt_server_name"))
    else
        self:setLabelString("txt_sname"..idx, rivalInfo.sname)
    end
    local sectionName = DB.getServerBattleSecNameByLv(rivalInfo.sectionLv)
    local sectionType = DB.getServerBattleSecTypeByLv(rivalInfo.sectionLv)
    if sectionType == SERVER_BATTLE_DUAN16 then
        if rivalInfo.rank ~= nil then
            self:setLabelString("txt_rank"..idx, gGetWords("serverBattleWords.plist","txt_rival_king_rank",rivalInfo.rank))
        end  
    else
        self:setLabelString("txt_rank"..idx, sectionName)
    end
    
    self:setLabelString("txt_power"..idx, rivalInfo.power)
    self:getNode("txt_sname"..idx):setVisible(true)
    self:getNode("txt_name"..idx):setVisible(true)
    self:getNode("layout_power"..idx):setVisible(true)
    self:getNode("layout_power"..idx):layout()
    self:getNode("layout_lv_rank"..idx):setVisible(true)
    self:getNode("layout_lv"..idx):layout()
    self:getNode("layout_lv_rank"..idx):layout()
    -- self:setTouchEnable("btn_challenge"..idx, true, false)
end

function ServerBattleFindRivalPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_challenge1" or 
       target.touchName == "btn_challenge2" or
       target.touchName == "btn_challenge3"  then
        local idx = toint(string.sub(target.touchName, string.len("btn_challenge") + 1))
        ---不等于空进入界面
        if nil ~= self.rivalInfos[idx].icon then
            self:processIconChEffect(idx)
            -- self:onClose()
            -- Panel.popUpVisible(PANEL_SERVER_BATTLE_FORMATION,self.rivalInfos[idx].idx,nil,true)
        end
    elseif target.touchName=="btn_cancel" then
        -- if self.state <= FIND_STATE_STEP2 then
            self:onClose()
            if (self.soundId) then
                gStopEffect(self.soundId)
                self.soundId = nil
            end
        -- end
    elseif target.touchName=="btn_change" then
        if self.changePrice >= Data.getCurGold() then
            gShowNotice(gGetWords("noticeWords.plist","no_gold_enough"))
        else
            Net.sendWorldWarFind(true)
            self:resetPanel()
        end
    elseif target.touchName=="check_skip" then
        if self.skipFindFla then
            self:changeTexture("check_skip", "images/ui_public1/n-di-gou1.png")
            self.skipFindFla = false
        else
            self:changeTexture("check_skip", "images/ui_public1/n-di-gou2.png")
            self.skipFindFla = true
        end
    end
end

function ServerBattleFindRivalPanel:initPanel()
    if gServerBattle.isRivalsEmpty() then
        for  i = 1, 3 do
            local ret=cc.Sprite:create("images/ui_severwar/npc_0.png")
            Icon.setNodeIcon(ret, self:getNode("icon"..i))
            self:getNode("txt_sname"..i):setVisible(false)
            self:getNode("txt_name"..i):setVisible(false)
            self:getNode("layout_power"..i):setVisible(false)
            self:getNode("layout_lv_rank"..i):setVisible(false)
            self:setTouchEnable("btn_challenge"..i, false, true)
            self:getNode("icon"..i):setPosition(gGetNodePositionByAnchorPoint(self:getNode("icon_bg"..i),cc.p(0.5,0.5)))
        end
        self:getNode("txt_choose_lefttime"):setVisible(true)
        self:setLabelString("txt_tip_info", gGetWords("serverBattleWords.plist","txt_finding_rivals"))
        self.state = FIND_STATE_STEP1
        self:setChangeInfo()
        self:setTouchEnable("btn_change", false, true)
    else
        self:setRivalInfos()
        for i = 1, 3 do
            self:getNode("icon"..i):setVisible(false)
            self:getNode("icon_bg"..i):removeChildByTag(300)
            if self.rivalInfos[i] ~= nil and self.rivalInfos[i].icon ~= nil then
                local findIcon = cc.Sprite:create()
                findIcon:setScale(0.95)
                Icon.setHeadIcon(findIcon,self.rivalInfos[i].icon)
                gAddChildInCenterPos(self:getNode("icon_bg"..i),findIcon)
                findIcon:setTag(300)
                self:setRivalInfoByIdx(i)
            end
        end
        self:processFlaFinish()
        self:setChangeInfo()
    end
end

function ServerBattleFindRivalPanel:playFla()
    loadFlaXml("ui_sousuo")

    self.soundId = gPlayEffect("sound/effect/ui_laba_1.mp3",true,true)

    for i=1, 3 do
        self:getNode("icon"..i):setVisible(false)
        self:getNode("icon_bg"..i):removeChildByTag(300)
        local iconFla = nil
        iconFla = gCreateFlaDelayAndCallback(0.5*(i-1),"ui_sousuo_kapai",1, function()
            iconFla:stopAni()
            if self.rivalInfos[i] ~= nil then
                -- self:setRivalInfoByIdx(i)
            end

            if i == 3 then
                self:processFlaFinish()
            end
        end,function()
            if self.rivalInfos[i] ~= nil and self.rivalInfos[i].icon ~= nil then
                local findIcon = cc.Sprite:create()
                findIcon:setScale(0.95)
                Icon.setHeadIcon(findIcon,self.rivalInfos[i].icon)
                iconFla:replaceBoneWithNode({"ka3","head"},findIcon)
                local delayTime = cc.DelayTime:create(3.7)
                local sequence = cc.Sequence:create(delayTime,cc.CallFunc:create(function ()
                    self:setRivalInfoByIdx(i)
                    if (self.soundId) then
                        gStopEffect(self.soundId)
                        self.soundId = nil
                    end
                    gPlayEffect("sound/effect/ui_laba.mp3")
                end))
                self:runAction(sequence)
                self:processFindEffect(i)
            end
        end)
        -- print("self getnode icon",i,self:getNode("icon"..i))
        -- self:replaceNode("icon"..i, iconFla)
        gAddChildInCenterPos(self:getNode("icon_bg"..i),iconFla)

        iconFla:setTag(300)
    end
    self:setLabelString("txt_tip_info", gGetWords("serverBattleWords.plist","txt_began_find"))
    local blinkAction = cc.Blink:create(2, 6)
    self:getNode("txt_tip_info"):runAction(cc.RepeatForever:create(blinkAction))
end

function ServerBattleFindRivalPanel:autoChooseRival()
    local randomIdxes = {}
    local noEmptyIdx = 0
    for i = 1, 3 do
        if self.rivalInfos[i].icon ~= nil then
            noEmptyIdx = noEmptyIdx + 1
            randomIdxes[noEmptyIdx]=i
        end
    end

    local count = #randomIdxes
    if count == 0 then
        return
    end

    local idx = math.random(count)
    self:processIconChEffect(randomIdxes[idx])
end

function ServerBattleFindRivalPanel:processFlaFinish()

    if #gServerBattle.rivalInfos == 0 then
        gConfirm(gGetWords("serverBattleWords.plist","not_find_rival"), function()
            self:onClose()
            if (self.soundId) then
                gStopEffect(self.soundId)
                self.soundId = nil
            end
        end)
        return
    end

    for key,value in pairs(self.rivalInfos) do
        if value ~= nil and value.icon ~= nil then
            self:setTouchEnable("btn_challenge"..key, true, false)
        end
    end
    self.state = FIND_STATE_STEP3
    self:getNode("txt_choose_lefttime"):setVisible(true)
    self.step3EndTime = gGetCurServerTime() + FIND_RIVAL_TIME4
    self:getNode("txt_tip_info"):stopAllActions()
    self:getNode("txt_tip_info"):setVisible(true)
    self:setLabelString("txt_tip_info", gGetWords("serverBattleWords.plist","txt_finish_find"))
    self:setTouchEnable("btn_change", true, false)
end

function ServerBattleFindRivalPanel:processFindEffect(idx)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function()
        local huohuaFla = gCreateFla("ui_sousuo_huohua",1)
        gAddChildInCenterPos(self:getNode("icon_bg"..idx),huohuaFla)
        huohuaFla:setTag(999)
    end),cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
        self:getNode("icon_bg"..idx):removeChildByTag(999)
    end))))
end

function ServerBattleFindRivalPanel:processIconChEffect(idx)
    for i = 1,3 do
        self:setTouchEnable("btn_challenge"..i, false, true)
    end
    self:setTouchEnable("btn_change", false, true)
    self:setTouchEnable("btn_cancel", false, true)
    local chooseFla = gCreateFla("ui_sousuo_xuanzhongkuang")
    gAddChildInCenterPos(self:getNode("icon_ch_effect"..idx),chooseFla)
    self:getNode("icon_ch_effect"..idx):runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
            self:onClose()
            if (self.soundId) then
                gStopEffect(self.soundId)
                self.soundId = nil
            end
            Panel.popUpVisible(PANEL_SERVER_BATTLE_FORMATION,self.rivalInfos[idx].idx,nil,true)
    end)))
end

function ServerBattleFindRivalPanel:setChangeInfo()
    local freeChangeNum = DB.getServerBattleChangeFree()
    local isFree = gServerBattle.changeNum < freeChangeNum
    self:getNode("layout_free"):setVisible(isFree)
    self:getNode("layout_cost"):setVisible(not isFree)
    if not isFree then
        self.changePrice = Data.getBuyTimesPrice(gServerBattle.changeNum - freeChangeNum + 1,"WORLD_WAR_CHANGE_PRICE","WORLD_WAR_CHANGE_PRICE_NUM")
        self:setLabelString("txt_change_cost", self.changePrice)
        self:getNode("layout_cost"):layout()
    else
        self.changePrice = 0
        self:setLabelString("txt_free_value",string.format("%d/%d",freeChangeNum - gServerBattle.changeNum,DB.getServerBattleChangeFree()))
        self:getNode("layout_free"):layout()
    end
end

function ServerBattleFindRivalPanel:resetPanel()
    for  i = 1, 3 do
        local ret=cc.Sprite:create("images/ui_severwar/npc_0.png")
        Icon.setNodeIcon(ret, self:getNode("icon"..i))
        self:getNode("txt_sname"..i):setVisible(false)
        self:getNode("txt_name"..i):setVisible(false)
        self:getNode("layout_power"..i):setVisible(false)
        self:getNode("layout_lv_rank"..i):setVisible(false)
        self:setTouchEnable("btn_challenge"..i, false, true)
        self:getNode("icon"..i):setPosition(gGetNodePositionByAnchorPoint(self:getNode("icon_bg"..i),cc.p(0.5,0.5)))
    end
    self:setLabelString("txt_choose_lefttime", 20)
    self:setLabelString("txt_tip_info", gGetWords("serverBattleWords.plist","txt_finding_rivals"))
    self.state = FIND_STATE_STEP2
    self:setChangeInfo()
    self:setTouchEnable("btn_change", false, true)
end

function ServerBattleFindRivalPanel:initMeInfo()
    Icon.setHeadIcon(self:getNode("icon_me"),Data.getCurIconFrame())
    local attackFormation=Data.getUserTeam(TEAM_TYPE_WORLD_WAR_ATTACK)
    local power=CardPro.countFormation(attackFormation,TEAM_TYPE_WORLD_WAR_ATTACK)
    self:setLabelString("txt_me_power", power)
    self:getNode("layout_me_power"):layout()

    if gServerBattle.kingRank > 0 then
        self:setLabelString("txt_me_rank", gServerBattle.kingRank)
    else
        local noRankTxt = gGetWords("serverBattleWords.plist","no_rank")
        self:setLabelString("txt_me_rank", noRankTxt)
    end
    self:getNode("layout_me_rank"):layout()
end

function ServerBattleFindRivalPanel:initSkipFla()
    local skipFindFla = cc.UserDefault:getInstance():getBoolForKey(Data.getCurUserId().."_skipFindRival", false)
    if skipFindFla then
        self:changeTexture("check_skip", "images/ui_public1/n-di-gou2.png")
        self.skipFindFla = true
    else
        self:changeTexture("check_skip", "images/ui_public1/n-di-gou1.png")
        self.skipFindFla = false
    end
end

return ServerBattleFindRivalPanel