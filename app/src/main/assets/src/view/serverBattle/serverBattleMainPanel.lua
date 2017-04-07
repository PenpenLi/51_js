local ServerBattleMainPanel=class("ServerBattleMainPanel",UILayer)

function ServerBattleMainPanel:ctor()
    self:init("ui/ui_serverbattle_main.map")
    local bg = ServerBattleBgPanel.new()
    bg:setAnchorPoint(cc.p(0.5,0.5))
    gAddCenter(bg, self)
    self:initPanel()
    self:setTitleInfo()
    self:setSectionInfo()
    self:setRoleInfo()
    self:setFindNums()
    self:setFindBtn()
    self:initSchedule()
    self:setLogRedpos()

    -- self:processRePopUp()
end

function ServerBattleMainPanel:events()
    return {EVENT_ID_SERVERBATTLE_QUIT,
            EVENT_ID_SERVERBATTLE_MAIN_UPDATE,
            EVENT_ID_SERVERBATTLE_FIND_RIVAL,
            EVENT_ID_SAVE_FORMATION,
            EVENT_ID_SERVERBATTLE_FIND_BUY,
        }
end

function ServerBattleMainPanel:dealEvent(event, param)
    if event == EVENT_ID_SERVERBATTLE_QUIT then
        --TODOD,更新王者排名和段位消息
        self:setSectionInfo()
        self:setFindNums()
    elseif event == EVENT_ID_SERVERBATTLE_MAIN_UPDATE then
        self:setTitleInfo()
        self:setSectionInfo()
        self:setRoleInfo()
        self:setFindNums()
        self:setFindBtn()
    elseif event == EVENT_ID_SERVERBATTLE_FIND_RIVAL then
        self:setFindNums()
    elseif event == EVENT_ID_SAVE_FORMATION then
        -- Net.sendWorldWarGetInfo()
    elseif event == EVENT_ID_SERVERBATTLE_FIND_BUY then
        self:setFindNums()
    end
end

function ServerBattleMainPanel:onTouchBegan(target, touch, event)
    if target.touchName=="btn_lookup_attr" then
        self:getNode("layout_attr"):layout()
        local contentSize = self:getNode("layout_attr"):getContentSize()
        contentSize.width = self:getNode("panel_attr_desc"):getContentSize().width
        contentSize.height = contentSize.height + 22
        self:getNode("panel_attr_desc"):setContentSize(contentSize)
        self:getNode("panel_attr_bg"):setVisible(true)
    elseif target.touchName=="btn_find_rival" then
        local findRivalFla = self:getNode("btn_find_rival_fla")
        findRivalFla.preScaleX=target:getScaleX()
        findRivalFla.preScaleY=target:getScaleY()
        findRivalFla:setScaleX(findRivalFla.preScaleX*0.9)
        findRivalFla:setScaleY(findRivalFla.preScaleY*0.9)
    end
    self.beganPos = touch:getLocation()
end

function ServerBattleMainPanel:onTouchMoved(target, touch, event)
    self.endPos = touch:getLocation()
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y)
    if dis > gMovedDis then
        self:getNode("panel_attr_bg"):setVisible(false)
    end
end

function ServerBattleMainPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_help" then
        gShowRulePanel(SYS_SERVER_BATTLE)
    elseif target.touchName=="btn_reward" then
        Panel.popUpVisible(PANEL_SERVER_BATTLE_REWARD,nil,nil,true)
    elseif target.touchName=="btn_king_rank" then
        Net.sendWorldWarKingRank()
        -- Panel.popUpVisible(PANEL_SERVER_BATTLE_RANK,nil,nil,true)
    elseif target.touchName=="btn_defend_edit" then
        Panel.popUpVisible(PANEL_ATLAS_FORMATION,TEAM_TYPE_WORLD_WAR_DEFEND,nil,true)
    elseif target.touchName=="btn_find_rival" then
        local findRivalFla = self:getNode("btn_find_rival_fla")
        findRivalFla:setScaleX(findRivalFla.preScaleX)
        findRivalFla:setScaleY(findRivalFla.preScaleY)
        if nil == gServerBattle.getSectionSeasonFinTime() then
            gConfirm(gGetWords("serverBattleWords.plist","season_finish"), function()
                self:onClose()
                -- Net.sendWorldWarMatchRecord(KING_RANK_SKY)
            end)
            return
        end
        local formation=Data.getUserTeam(TEAM_TYPE_WORLD_WAR_DEFEND) 
        if (NetErr.isTeamEmpty(formation)) then
            Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_WORLD_WAR_DEFEND)
            gShowNotice(gGetWords("serverBattleWords.plist","layout_defend_tip"))
        else
            if gServerBattle.canFindRival() then
                Panel.popUpVisible(PANEL_SERVER_BATTLE_FIND_RIVAL,nil,nil,true)
            end
        end
    elseif target.touchName=="btn_past_report" then
        Net.sendWorldWarMatchRecord(KING_RANK_SKY)
    elseif target.touchName=="btn_reward_exch" then
        -- Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_SERVERBATTLE,nil,true)
        Net.sendWorldWarInfo()
    elseif target.touchName=="btn_log" then
        Net.sendWorldWarRecord()
    elseif nil ~= target.touchName and string.find(target.touchName, "touch_role") then
        local pos = toint(string.sub(target.touchName, string.len("touch_role") + 1))
        if pos <= #gServerBattle.top5KingRanks then
            Net.sendWorldWarUserInfo(gServerBattle.top5KingRanks[pos].uid)
        end
    elseif target.touchName=="btn_buy" then
        local callback = function(num)
            Net.sendWorldWarFindBuy(num)
        end
        Data.canBuyTimes(VIP_SERVERBATTLE_FIND,true,callback)
    end
    self:getNode("panel_attr_bg"):setVisible(false)
end

function ServerBattleMainPanel:setTitleInfo()
    -- gServerBattle.sectionLv=40
    -- local honor = DB.getHonorIDbySecLv(gServerBattle.sectionLv)
    local honor = gServerBattle.honor 
    if honor ~= 0 then
        self:getNode("layout_title"):setVisible(true)
        self:getNode("panel_attr_bg"):setVisible(false)
        self:getNode("txt_attr1"):setVisible(false)
        self:getNode("txt_attr2"):setVisible(false)
        -- self:setLabelString("txt_title", DB.getHonorTitleByID(honor))
        Icon.changeHonorIcon(self:getNode("honor_icon"),honor)
        Icon.changeHonorWord(self:getNode("honor_word"),honor)
        local buffDesc1,buffDesc2 = DB.getHonorBuffDescByID(honor)
        local idx = 0
        if buffDesc1 ~= "" then
            idx = idx + 1
            self:getNode("txt_attr"..idx):setVisible(true)
            self:setLabelString("txt_attr"..idx, buffDesc1)
        end

        if buffDesc2 ~= "" then
            idx = idx + 1
            self:getNode("txt_attr"..idx):setVisible(true)
            self:setLabelString("txt_attr"..idx, buffDesc2)
        end

        if 0 == idx then
           self:getNode("btn_lookup_attr"):setVisible(false)
        else
            self:getNode("btn_lookup_attr"):setVisible(true)
        end
    else
        self:getNode("layout_title"):setVisible(false)
        self:getNode("btn_lookup_attr"):setVisible(false)
    end
end

function ServerBattleMainPanel:setSectionInfo()
    Icon.setHeadIcon(self:getNode("icon_self"),Data.getCurIconFrame())
    self:setLabelString("txt_self_name", gUserInfo.name)
    if gServerBattle.sectionLv == 0 then
        self:getNode("panel_section_info"):setVisible(false)
        return
    end
    self:getNode("panel_section_info"):setVisible(true)
    Icon.setSecOfSeverBattle(self:getNode("icon_section"),gServerBattle.sectionLv)
    local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
    self:setLabelString("txt_badge_name", secName)
    local sectionType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)

    if sectionType == SERVER_BATTLE_DUAN16 then
        self:getNode("layout_star"):setVisible(false)
        self:getNode("layout_king_rank"):setVisible(true)
        if gServerBattle.kingRank == nil then
            self:getNode("layout_king_rank"):setVisible(false)
        else
            if (gServerBattle.oldKingRank == nil) or 
               (gServerBattle.oldKingRank == gServerBattle.kingRank) then
                self:getNode("txt_old_king_rank"):setVisible(false)
                self:getNode("txt_king_arrow"):setVisible(false)
                self:setLabelAtlas("txt_cur_king_rank", gServerBattle.kingRank)
            else
                self:setLabelAtlas("txt_old_king_rank", gServerBattle.oldSectionLv)
                self:setLabelAtlas("txt_cur_king_rank", gServerBattle.kingRank)
                self:getNode("txt_old_king_rank"):setVisible(true)
                self:getNode("txt_king_arrow"):setVisible(true)
            end
            self:getNode("layout_king_rank"):layout()
        end
    else
        self:getNode("layout_star"):setVisible(true)
        self:getNode("layout_king_rank"):setVisible(false)
        local totoalStars = DB.getServerBattleTotalStarsByLv(sectionType)
        for i = totoalStars + 1,5 do
            self:getNode("icon_star"..i):setVisible(false)
        end
        self:getNode("layout_star"):layout()

        local minLv,maxLv = DB.getServerBattleRangeSecLvByType(sectionType)
        local num = gServerBattle.sectionLv - minLv

        for i=1, totoalStars do
            if i <= num then
                self:changeTexture("icon_star"..i,"images/ui_public1/star1.png")
            else
                self:changeTexture("icon_star"..i,"images/ui_public1/star1-1.png")
            end
        end
    end
    if gServerBattle.winning ~= 0 and sectionType ~= SERVER_BATTLE_DUAN16 then
        self:setLabelAtlas("txt_winning", gServerBattle.winning)
        self:getNode("panel_winning"):setVisible(true)
    else
        self:getNode("panel_winning"):setVisible(false)
    end
end

function ServerBattleMainPanel:setRoleInfo()
    for i = 1, 5 do
        self:getNode("role"..i):removeAllChildren()
    end
    
    local totalNum = table.count(gServerBattle.top5KingRanks)
    --TODO
    if totalNum < 5 then
        loadFlaXml("heiren")
    end

    local actions={}
    table.insert(actions,"wait") 
    table.insert(actions,"win")

    for i = 1, 5 do
        if i <= totalNum then
            local rankInfo = gServerBattle.top5KingRanks[i]
            --TODO
            local roleFla = nil
            if nil ~= rankInfo.show then
                roleFla = gCreateRoleFlaWithActName("",rankInfo.icon%100000,self:getNode("role"..i),0.8,false,nil,rankInfo.show.wlv,rankInfo.show.wkn,rankInfo.show.halo)
            else
                roleFla =gCreateRoleFlaWithActName("",rankInfo.icon%100000,self:getNode("role"..i),0.8,false)
            end
            -- roleFla:playActDelay((i-1) * 0.8 , "r"..roleFla.cardid.."_wait",1)
            -- gAddCenter(roleFla,self:getNode("role"..i))
            if nil ~= roleFla then
                roleFla.actIdx = 1
                local function playEned()
                    if(getRand(0,100)<50)then 
                        roleFla:playAction("r"..roleFla.cardid.."_wait",playEned)
                        return
                    end
                    roleFla.actIdx=roleFla.actIdx+1
                    if(roleFla.actIdx>table.getn(actions))then
                        roleFla.actIdx=1
                    end
                    roleFla:playAction("r"..roleFla.cardid.."_"..actions[roleFla.actIdx],playEned)
                end
                roleFla:playAction("r"..roleFla.cardid.."_"..actions[roleFla.actIdx],playEned)
                -- gAddCenter(roleFla,self:getNode("role"..i))
            end


            self:getNode("txt_name"..i):setVisible(true)
            self:getNode("txt_servername"..i):setVisible(true)
            self:setLabelString("txt_name"..i, rankInfo.uname)
            self:setLabelString("txt_servername"..i, rankInfo.sname)
        else
            local fla=gCreateFla("heiren_wait",1)
            gAddCenter(fla,self:getNode("role"..i))
            self:getNode("txt_name"..i):setVisible(false)
            self:getNode("txt_servername"..i):setVisible(false)
        end
    end
end

function ServerBattleMainPanel:initSchedule()
    self.endTime = gServerBattle.getSectionSeasonFinTime()
    if nil == self.endTime then
        self:getNode("panel_season_lefttime"):setVisible(false)
        -- self:getNode("txt_season_finish"):setVisible(true)
    end

    local function update()
        if self.endTime == nil then
            local curSeasonTime = gServerBattle.getSectionSeasonFinTime()
            if nil ~= curSeasonTime then
                self.endTime = curSeasonTime
                Net.sendWorldWarGetInfo()
            end
            return
        end

        local leftTime = self.endTime - gGetCurServerTime()
        if leftTime > 0 then
            self:parserHourTimeInDay(leftTime)
            -- self:setLabelString("txt_lefttime", gParserHourTime(leftTime))
        else
            self:getNode("panel_season_lefttime"):setVisible(false)
            self:getNode("txt_season_finish"):setVisible(true)
            self:setTouchEnable("btn_find_rival", false, true)
            self.endTime = nil
        end
    end
    self:scheduleUpdate(update, 1)
end

function ServerBattleMainPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
    gServerBattle.hasEnterFight = false
end

function ServerBattleMainPanel:onPopup()
--    cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."serverbattle_rw", 0)
    if self.popUpIntro == nil then
        self:activityRewardIntroPanel()
        self.popUpIntro = true
    end
    self:setTitleInfo()
    self:setSectionInfo()
    self:setRoleInfo()
    self:setFindNums()
    self:setLogRedpos()
    self:processConfirm()
end

function ServerBattleMainPanel:activityRewardIntroPanel()
    local  serverbattleSeason = cc.UserDefault:getInstance():getIntegerForKey(Data.getCurUserId().."serverbattle_ss",0)
    if serverbattleSeason == 0 then
        cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."serverbattle_ss", gServerBattle.season)
    elseif gServerBattle.season > serverbattleSeason then
        cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."serverbattle_ss", gServerBattle.season)
        if gServerBattle.sectionLv > 1 then
            cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."serverbattle_rw", os.time())
            Panel.popUpVisible(PANEL_SERVER_BATTLE_PREVIEW,nil,nil,true)
            return
        end
    end
    -- print("serverbattleRwTime is",serverbattleRwTime)
    local serverbattleRwTime = cc.UserDefault:getInstance():getIntegerForKey(Data.getCurUserId().."serverbattle_rw",0)
    if (RedPoint.isToday(toint(serverbattleRwTime)) == false) then--没有记录或者不是当天
        --记录并弹框
        cc.UserDefault:getInstance():setIntegerForKey(Data.getCurUserId().."serverbattle_rw", os.time())
        -- Panel.popUpVisible(PANEL_SERVER_BATTLE_REWARD_INTRO,nil,nil,true)
        Panel.popUpVisible(PANEL_SERVER_BATTLE_REWARD,nil,nil,true)
    end
end

function ServerBattleMainPanel.isToday(timestamp)
    local today = gGetDate("*t")
    local secondOfToday = os.time({day=today.day, month=today.month,
        year=today.year, hour=gResetDataInDay, minute=0, second=0})
    if timestamp >= secondOfToday and timestamp < secondOfToday + 24 * 60 * 60 then
        return true
    else
        return false
    end
end

function ServerBattleMainPanel:setFindNums()
    local sectionType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)
    local visible = (sectionType == SERVER_BATTLE_DUAN16)
    self:getNode("btn_buy"):setVisible(visible)
    if visible then
        self:getNode("btn_buy"):setVisible(not Module.isClose(SWITCH_VIP))
    end
    local maxTimes = DB.getMaxFindNumsOfSeverBattle()
    -- print("setFindNums gServerBattle.totalLeftFindNum is:",gServerBattle.totalLeftFindNum)
    self:setLabelString("txt_find_nums", string.format("%d/%d", gServerBattle.totalLeftFindNum, maxTimes))
    self:getNode("layout_find_nums"):layout()
    self:getNode("layout_find_nums"):setVisible(true)
end

function ServerBattleMainPanel:initPanel()
    self:setLabelString("txt_season", gServerBattle.season)
    self:getNode("layout_season"):layout()
    if gServerBattle.season == 1 then
        self:setTouchEnable("btn_past_report", false, true)
    end
end

function ServerBattleMainPanel:processRePopUp()
    if nil ~= Net.sendWorldWarGetInfoFunc then
        Net.sendWorldWarGetInfoFunc()
        Net.sendWorldWarGetInfoFunc = nil
    end
end

function ServerBattleMainPanel:parserHourTimeInDay(time)
    local function minNum(num)
        if(num<10)then
            return "0"..num
        end
        return num
    end
    local hour= math.floor(time/3600)
    local min=math.floor((time%3600)/60)
    local sec=time%60
    local days = math.floor(hour / 24)
    hour = hour % 24
    if days > 0 then
        self:getNode("txt_left_day"):setVisible(true)
        self:setLabelString("txt_left_day", gGetWords("serverBattleWords.plist","txt_lefttime_days",days))
        self:setLabelString("txt_lefttime", minNum(hour)..":"..minNum(min))
    else
        self:getNode("txt_left_day"):setVisible(false)
        self:setLabelString("txt_lefttime", minNum(hour)..":"..minNum(min)..":"..minNum(sec))
    end

    self:getNode("layout_lefttime"):layout()
end

function ServerBattleMainPanel:setFindBtn()
    if gServerBattle.hasEnterFight then
        self:setTouchEnable("btn_find_rival", false, false)
        self:getNode("btn_find_rival"):runAction(cc.Sequence:create( cc.DelayTime:create(1.0),cc.CallFunc:create(function( ... )
            self:setTouchEnable("btn_find_rival", true, false)
            gServerBattle.hasEnterFight = false
        end)))
    end
end

function ServerBattleMainPanel:setLogRedpos()
    if Data.redpos.warlose then
        RedPoint.add(self:getNode("btn_log"))
    else
        RedPoint.remove(self:getNode("btn_log"))
    end
end

function ServerBattleMainPanel:processConfirm()
    if gConfirmLayer ~= nil and gConfirmLayer:isVisible() then
        local confirmLayer = gConfirmLayer:getChildByTag(CONFIRM_CHILD_TAG)
        if nil ~= confirmLayer then
            confirmLayer:onClose()
        end
    end
end

return ServerBattleMainPanel
