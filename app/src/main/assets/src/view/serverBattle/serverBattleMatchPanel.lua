local ServerBattleMatchPanel=class("serverBattleMatchPanel",UILayer)

local TIME8_PRE = 1
local TIME8_DONING = 2
local TIME4_PRE = 3
local TIME4_DONING = 4
local TIME2_PRE = 5
local TIME2_DONING = 6
local TIME1_PRE = 7
local TIME1_DONING = 8
local TIME_FINISH = 9

function ServerBattleMatchPanel:ctor(data,queryType)
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_serverbattle_match.map")
    local bg = ServerBattleBgPanel.new()
    bg:setAnchorPoint(cc.p(0.5,0.5))
    gAddCenter(bg, self)
    self.curRound = 0
    self:setKingRankInfo()
    self:checkTimeForFightStatus()
    self:setTimeBarInfo()
    self:initRivalInfos(data.list)
    if nil ~= queryType then
        if queryType == KING_RANK_GROUND then
            self:selectRankBtn("btn_ground_rank")
        else
            self:selectRankBtn("btn_sky_rank")
        end
    else
        self:selectRankBtn("btn_sky_rank")
    end
    self:resetLayOut();
    -- self:resetAdaptNode();
end

function ServerBattleMatchPanel:events()
    return {
            EVENT_ID_SERVERBATTLE_UPDATE_MATCH,
        }
end

function ServerBattleMatchPanel:dealEvent(event, param)
    if event == EVENT_ID_SERVERBATTLE_UPDATE_MATCH then
        self.curRound = 0
        self:setKingRankInfo()
        self:checkTimeForFightStatus()
        self:setTimeBarInfo()
        self:initRivalInfos(param.list)
    end
end

function ServerBattleMatchPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif string.find(target.touchName,"v_") then
        -- local targetTable = string.split(target.touchName,"_")

        local var = self:getNode(target.touchName).var
        if #var.result == 0 then
            if var.vid ~= 0 then
                local func = function()
                    local serverBattleType = gServerBattle.getServerBattleType()
                    if serverBattleType == SERVER_BATTLE_TYPE1 then
                        local function  callback()
                            if gMainBgLayer == nil then
                                Scene.enterMainScene()
                            end
                            Net.sendWorldWarMatchRecord(gServerBattle.sendMatchType)                 
                        end
                        Net.sendWorldWarGetInfo(callback)
                    elseif serverBattleType == SERVER_BATTLE_TYPE2 then
                        local function callback()
                            if gMainBgLayer == nil then
                                Scene.enterMainScene()
                            end
                        end
                        Net.sendWorldWarMatchRecord(gServerBattle.sendMatchType,callback)
                    -- else
                    --     Scene.enterMainScene()
                    end
                end
                 
                Panel.pushRePopupPre(func)
                Net.sendWorldWarVedio(var.vid, SERVER_BATTLE_RECORD2)
            end
        else
            Panel.popUp(PANEL_SERVER_BATTLE_LOOK_VIDEO, var)
        end
        -- if nil ~= var and #var.result > 0 then
        -- end
    elseif string.find(target.touchName,"uicon") then
        local matchType = self:getNode(target.touchName).matchType
        if nil ~= matchType then
            -- print("send uicon is:",matchType, self:getNode(target.touchName).id,self:getNode(target.touchName).uid)
            Net.sendWorldWarMatchUserInfo(matchType,self:getNode(target.touchName).id,self:getNode(target.touchName).uid)
        end

    elseif target.touchName=="btn_reward_exch" then
        -- Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_SERVERBATTLE,nil,true)
        Net.sendWorldWarInfo()
    elseif target.touchName=="btn_sky_rank" then
        self:selectRankBtn(target.touchName)
        Net.sendWorldWarMatchRecord(KING_RANK_SKY)
    elseif target.touchName=="btn_ground_rank" then
        self:selectRankBtn(target.touchName)
        Net.sendWorldWarMatchRecord(KING_RANK_GROUND)
    elseif target.touchName=="btn_reward" then
        -- Panel.popUpVisible(PANEL_SERVER_BATTLE_REWARD,nil,nil,true)
        Panel.popUpVisible(PANEL_SERVER_BATTLE_RANK,true,nil,true)
    elseif target.touchName == "btn_help" then
        gShowRulePanel(SYS_SERVER_BATTLE)
    end
end

function ServerBattleMatchPanel:setKingRankInfo()
    local kingRankType = gServerBattle.getKingRankType()
    if kingRankType == KING_RANK_NONE then
        self:getNode("layout_king_rank"):setVisible(false)
        -- self:getNode("btn_defend"):setVisible(false)
        if gServerBattle.kingRank ~= 0 then
            self:setLabelString("txt_my_king_rank", gServerBattle.kingRank)
        else
            self:setLabelString("txt_my_king_rank", gGetWords("serverBattleWords.plist", "no_rank"))
        end
        self:getNode("layout_my_king_rank"):layout()
    else
        self:getNode("layout_king_rank"):setVisible(true)
        -- self:getNode("btn_defend"):setVisible(true)
        self:setLabelString("txt_my_king_rank", gServerBattle.kingRank)
        self:getNode("layout_my_king_rank"):layout()
        self:setLabelString("txt_king_rank_name", gServerBattle.getKingRankName(kingRankType))
        self:getNode("layout_king_rank"):layout() 
    end
end

function ServerBattleMatchPanel:initRivalInfos(list)
    local rounds = {}
    if list ~= nil then
      for _,var in pairs(list) do
          if rounds[var.round] == nil then
              rounds[var.round] = {}
          end
          table.insert(rounds[var.round],var)
      end
    end

    if nil ~= self.winerLine and table.count(self.winerLine) then
        for _,value in pairs(self.winerLine) do
            for _, line in pairs(value) do
                line:stopAllActions()
            end
        end
    end

    self.winerLine = {}
    self.curRound  = 0
    self:setBgStateTex(true)
    self:getNode("txt_match_state"):setVisible(true)
    self:cleaWinerFlag()
    self:initRound8(rounds[8])
    self:initRound4(rounds[4])
    self:initRound2(rounds[2])
    self:initRound1(rounds[1])

    self:changeTexture("line1","images/ui_family/match_line1.png")
    self:getNode("winer_panel"):setVisible(false)

    if gServerBattle.sendMatchType == KING_RANK_GROUND then
        self:changeTexture("icon_head_bg", "images/ui_severwar/z-13.png")
    else
        self:changeTexture("icon_head_bg", "images/ui_severwar/z-13-1.png")
    end

    if(rounds[1] and rounds[1][1] and rounds[1][1].win ~= -1)then
        self:getNode("icon_npc_0"):setVisible(false)
        self:getNode("icon_head"):setVisible(true)
        self:getNode("winer_panel"):setVisible(true)
        local winFid = rounds[1][1].uid1
        local winIcon = rounds[1][1].icon1
        local winName = rounds[1][1].name1
        local winSName = rounds[1][1].sname1
        if(rounds[1][1].win == 1)then
            self:setLabelString("txt_winner",rounds[1][1].name1)
            Icon.setHeadIcon(self:getNode("icon_head"), rounds[1][1].icon1 )
        else
            winFid=rounds[1][1].uid2
            winIcon = rounds[1][1].icon2
            winName = rounds[1][1].name2
            winSName = rounds[1][1].sname2
            self:setLabelString("txt_winner",rounds[1][1].name2)
            Icon.setHeadIcon(self:getNode("icon_head"), rounds[1][1].icon2 )
        end
        self:changeTexture("line1","images/ui_family/match_line1-1.png")
        if(self.winerLine[winFid])then
            table.insert(self.winerLine[winFid],self:getNode("line1"))
            for _, line in pairs(self.winerLine[winFid]) do
                self:shineLine(line)
            end
        end
        print("winName is:",winName,"winSName is:",winSName)
        if nil ~= gServerBattle.sendMatchType and gServerBattle.sendMatchType == KING_RANK_SKY then
            if gServerBattle.lastBattleInfo.icon ~= nil or gServerBattle.lastBattleInfo.icon == 0 then
                gServerBattle.setLastBattleInfo(winIcon,winName,winSName)
            end
        end
        if nil ~= gMainLayer and nil ~= gMainBgLayer then
            gMainBgLayer:setServerBattleInfo()
        end
    else
        self:getNode("icon_npc_0"):setVisible(true)
        self:getNode("icon_head"):setVisible(false)
    end
    self.rounds = rounds
end

function ServerBattleMatchPanel:setBgStateTex(win)
    local connectLetter = ""
    if gServerBattle.sendMatchType == KING_RANK_GROUND then
        connectLetter = "x"
    else
        connectLetter = "y"
    end
    for i=0, 15 do
        if(win)then
            if(i<=7)then
                self:changeTexture("fbg"..i,"images/ui_family/world_"..connectLetter.."1.png")
            else
                self:changeTexture("fbg"..i,"images/ui_family/world_"..connectLetter.."2.png")
            end
            self:getNode("txt_name"..i):setColor(cc.c3b(255,255,255))
        else
            if(i<=7)then
                self:changeTexture("fbg"..i,"images/ui_family/world_t1-1.png")
            else
                self:changeTexture("fbg"..i,"images/ui_family/world_t2-1.png")
            end
            self:getNode("txt_name"..i):setColor(cc.c3b(151,151,151))
        end
    end
end

function ServerBattleMatchPanel:cleaWinerFlag()
    for i=0, 15 do
        self:getNode("win_flag"..i):setVisible(false)
    end
end

function ServerBattleMatchPanel:initRound8(rounds)
    for i=0, 15 do
        self:setLabelString("txt_name"..i,"")
        self:getNode("uicon"..i):setVisible(false)
    end

    if nil == rounds then
       self:setLineGray(8,rounds)
    else
      for _, var in pairs(rounds) do
          self:setLabelString("txt_name"..var.groupId*2,var.name1)
          self:setLabelString("txt_name"..(var.groupId*2+1),var.name2)
          self:getNode("txt_name"..var.groupId*2).uid=var.uid1
          self:getNode("txt_name"..(var.groupId*2+1)).uid=var.uid2

          if var.name1 ~= "" then
              self:getNode("uicon"..var.groupId*2):setVisible(true)
              self:getNode("uicon"..var.groupId*2).matchType = gServerBattle.sendMatchType
              self:getNode("uicon"..var.groupId*2).id = var.id
              self:getNode("uicon"..var.groupId*2).uid = var.uid1
          end

          if var.name2 ~= "" then
              self:getNode("uicon"..(var.groupId*2+1)):setVisible(true)
              self:getNode("uicon"..(var.groupId*2+1)).matchType = gServerBattle.sendMatchType
              self:getNode("uicon"..(var.groupId*2+1)).id = var.id
              self:getNode("uicon"..(var.groupId*2+1)).uid = var.uid2
          end
          Icon.setHeadIcon(self:getNode("uicon"..var.groupId*2),var.icon1)
          Icon.setHeadIcon(self:getNode("uicon"..(var.groupId*2+1)),var.icon2)
      end
      self:setLineGray(8,rounds)
    end
end

function ServerBattleMatchPanel:initRound4(rounds)
    self:setLineGray(4,rounds) 
end

function ServerBattleMatchPanel:initRound2(rounds)
    self:setLineGray(2,rounds)
end

function ServerBattleMatchPanel:initRound1(rounds)
    self:setLineGray(1,rounds)
end

function ServerBattleMatchPanel:setLineGray(num, rounds)
    --播放按钮处理
    for i=0, num-1 do
        self:setTouchEnable("v_"..num.."_"..i,false,true)
        self:getNode("txt_"..num.."_"..i):setVisible(false)
        self:changeTexture("v_"..num.."_"..i,"images/ui_public1/play.png") 
        self:getNode("v_"..num.."_"..i):removeChildByTag(99)
    end
    --线性图显示
    for i=0, num*2-1 do
        self:changeTexture("line"..num.."_"..i,"images/ui_family/match_line"..num..".png")
    end

    --处理回合
    if nil ~= rounds then
        --1/8,1/4赛
        self:getNode("txt_match_state"):setVisible(true)
        -- self:setLabelString("txt_match_state",gGetWords("familyWords.plist","family_war_state_"..num))
        local isFightIng = true
        self:cleaWinerFlag()
        for _, var in pairs(rounds) do
            self:getNode("v_"..num.."_"..var.groupId).id=var.id
            self:getNode("v_"..num.."_"..var.groupId).var=var
            if(var.win == -1)then
                if self.curStatus == TIME8_DONING or self.curStatus == TIME4_DONING or 
                    self.curStatus == TIME2_DONING or self.curStatus == TIME1_DONING then
                    loadFlaXml("ui_family_war")
                    self:changeTexture("v_"..num.."_"..var.groupId,"images/ui_family/fighting_di1.png")
                    local fla=gCreateFla("ui_family_bz_combat",1)
                    local node=self:getNode("v_"..num.."_"..var.groupId)
                    fla:setPositionX(node:getContentSize().width/2)
                    fla:setPositionY(node:getContentSize().height/2)
                    fla:setTag(99)
                    node:addChild(fla)
                    self:setTouchEnable("v_"..num.."_"..var.groupId,false,false)
                else
                    self:setTouchEnable("v_"..num.."_"..var.groupId,false,true)
                end
                isFightIng = true
                self:getNode("txt_"..num.."_"..var.groupId):setVisible(false)
            elseif(var.win == 1)then
                self:setServerBattleLineWin(var,1,num,"line"..num.."_"..(var.groupId*2))
                isFightIng = false
            else
                self:setServerBattleLineWin(var,2,num,"line"..num.."_"..(var.groupId*2+1))
                isFightIng = false
            end
        end
    end
end

function ServerBattleMatchPanel:setServerBattleLineWin(var,pos,num,line)
    local lastPos=1
    if(pos==1)then
        lastPos=2
    end

    local winUid=var["uid"..pos]
    local lostUid=var["uid"..lastPos]
    local result=var["result"]
    if num == 8 then
        self:setServerBattleLost(lostUid,true)
    end
    self:setFlagVisibleByName(var["name"..pos],true)
    if(var.uid1 ~= 0 and var.uid2 ~= 0)then
        self:setTouchEnable("v_"..num.."_"..var.groupId,true,false)
        if #result ~= 0 then
            local winNum = 0
            local lostNum = 0
            for _,var in ipairs(result) do
                if var.win == 1 then
                    winNum = winNum + 1
                else
                    lostNum = lostNum + 1
                end
            end
            local varName = "txt_"..num.."_"..var.groupId
            self:setLabelString(varName, string.format("%d:%d",winNum,lostNum))
            self:getNode(varName):setVisible(true)
        end
    end
    if self.winerLine[winUid] == nil then
        self.winerLine[winUid] = {}
    end

    self:changeTexture(line,"images/ui_family/match_line"..num.."-1.png")
    table.insert(self.winerLine[winUid],self:getNode(line) )
    self:getNode("v_"..num.."_"..var.groupId).winer = winUid
end

function ServerBattleMatchPanel:setServerBattleLost(uid, visible)
    -- local connectLetter = ""
    -- if gServerBattle.sendMatchType == KING_RANK_GROUND then
    --     connectLetter = "x"
    -- else
    --     connectLetter = "y"
    -- end

    for i=0, 15 do
        if(self:getNode("txt_name"..i).uid == uid)then
            if(i<=7)then
                -- self:changeTexture("fbg"..i,"images/ui_family/world_"..connectLetter.."1.png")
                self:changeTexture("fbg"..i,"images/ui_family/world_t1-1.png")
            else
                -- self:changeTexture("fbg"..i,"images/ui_family/world_"..connectLetter.."2.png")
                self:changeTexture("fbg"..i,"images/ui_family/world_t2-1.png")
            end
            self:getNode("txt_name"..i):setColor(cc.c3b(151,151,151))
        end
    end
end

function ServerBattleMatchPanel:setFlagVisibleByName(name,visible)
    for i=0, 15 do
        if(self:getNode("win_flag"..i).name==name)then
            self:getNode("win_flag"..i):setVisible(false)
        end
    end
    return nil
end

function ServerBattleMatchPanel:shineLine(line)

    line:stopAllActions()
    local actions={}
    table.insert(actions,cc.FadeTo:create(0.3,100))
    table.insert(actions,cc.FadeTo:create(0.3,255))

    local actRepeat = cc.RepeatForever:create(cc.Sequence:create(actions) )
    line:runAction(actRepeat)
end

function ServerBattleMatchPanel:setTimeBarInfo()
    self:getNode("txt_match_state"):clear()
    if self.curStatus == TIME_FINISH then
        self:setBarPer("bar", 1)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_finish"))
        self:getNode("fla_timer"):stopAni()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME8_PRE then
        self:setBarPer("bar", 0)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_pre_process",gGetWords("familyWords.plist","family_war_state_8")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME8_DONING then
        self:setBarPer("bar", 0)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_in_process_of",gGetWords("familyWords.plist","family_war_state_8")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME4_PRE then
        self:setBarPer("bar", 0.25)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_pre_process",gGetWords("familyWords.plist","family_war_state_4")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME4_DONING then
        self:setBarPer("bar", 0.25)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_in_process_of",gGetWords("familyWords.plist","family_war_state_4")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME2_PRE then
        self:setBarPer("bar", 0.5)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_pre_process",gGetWords("familyWords.plist","family_war_state_2")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME2_DONING then
        self:setBarPer("bar", 0.5)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_in_process_of",gGetWords("familyWords.plist","family_war_state_2")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME1_PRE then
        self:setBarPer("bar", 0.75)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_pre_process",gGetWords("familyWords.plist","family_war_state_1")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    elseif self.curStatus == TIME1_DONING then
        self:setBarPer("bar", 0.75)
        self:setLabelString("txt_match_state",gGetWords("serverBattleWords.plist","txt_in_process_of",gGetWords("familyWords.plist","family_war_state_1")))
        self:getNode("fla_timer"):resume()
        self:getNode("layout_state_time"):setVisible(true)
    end
    self:getNode("txt_match_state"):layout()
    self:getNode("layout_state_time"):layout()
end

function ServerBattleMatchPanel:selectRankBtn(name)
    self:resetRankBtnTexture()
    if(name == "btn_ground_rank")then
        self:changeTexture(name,"images/ui_severwar/button2.png")
    else
        self:changeTexture(name,"images/ui_severwar/button2_1.png")
    end
end

function ServerBattleMatchPanel:resetRankBtnTexture()
    -- local btns={
    --     "btn_sky_rank",
    --     "btn_ground_rank",
    -- }
    -- for _, btn in pairs(btns) do
    --     self:changeTexture(btn,"images/ui_severwar/button1.png")
    -- end

    self:changeTexture("btn_ground_rank","images/ui_severwar/button1.png")
    self:changeTexture("btn_sky_rank","images/ui_severwar/button1_1.png")
end

function ServerBattleMatchPanel:checkTimeForFightStatus()
    local time8 = toint(DB.getServerBattleMatchTime(8))
    local time4 = toint(DB.getServerBattleMatchTime(4))
    local time2 = toint(DB.getServerBattleMatchTime(2))
    local time1 = toint(DB.getServerBattleMatchTime(1))
    self:setLabelString("txt_time8", string.format("%d:00",time8))
    self:setLabelString("txt_time4", string.format("%d:00",time4))
    self:setLabelString("txt_time2", string.format("%d:00",time2))
    self:setLabelString("txt_time1", string.format("%d:00",time1))

    local conEndWeekDay,conEndTime = DB.getServerBattleEndTime()
    if conEndWeekDay == 0 then
        conEndWeekDay = 7
    end 
    local curTimeTable = gGetDate("*t", gGetCurServerTime())
    local curWDay = (curTimeTable.wday + 6) % 7
    if curWDay == 0 then
        curWDay = 7
    end 

    local matchDay = DB.getServerBattleMatchDate()
    if matchDay == 0 then
        matchDay = 7
    end
    
    if curWDay < conEndWeekDay or (curWDay == conEndWeekDay and curTimeTable.hour < conEndTime)then
        self.curStatus = TIME_FINISH
    elseif (matchDay > conEndWeekDay and curWDay == conEndWeekDay and curTimeTable.hour >= conEndTime) or 
          (curWDay == matchDay and curTimeTable.hour < time8 - 1) then
        self.curStatus = TIME8_PRE
    elseif (curWDay == matchDay and curTimeTable.hour >= time8 - 1) and curTimeTable.hour < time8 then
        self.curStatus = TIME8_DONING
    elseif curTimeTable.hour >= time8 and curTimeTable.hour < time4 - 1 then
        self.curStatus = TIME4_PRE
    elseif curTimeTable.hour >= time4 - 1 and curTimeTable.hour < time4 then
        self.curStatus = TIME4_DONING
    elseif curTimeTable.hour >= time4  and curTimeTable.hour < time2 - 1 then
        self.curStatus = TIME2_PRE
    elseif curTimeTable.hour >= time2 - 1  and curTimeTable.hour < time2 then
        self.curStatus = TIME2_DONING
    elseif curTimeTable.hour >= time2 and curTimeTable.hour < time1 - 1 then
        self.curStatus = TIME1_PRE
    elseif curTimeTable.hour >= time1 - 1 and curTimeTable.hour < time1 then
        self.curStatus = TIME1_DONING
    else
        self.curStatus = TIME_FINISH
    end
end

return ServerBattleMatchPanel