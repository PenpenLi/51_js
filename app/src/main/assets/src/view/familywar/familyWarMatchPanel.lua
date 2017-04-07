
local FamilyWarMatchPanel=class("FamilyWarMatchPanel",UILayer)

local TIME8_PRE = 1
local TIME8_DONING = 2
local TIME4_PRE = 3
local TIME4_DONING = 4
local TIME2_PRE = 5
local TIME2_DONING = 6
local TIME1_PRE = 7
local TIME1_DONING = 8
local TIME_FINISH = 9

function FamilyWarMatchPanel:ctor(data)
    self:init("ui/ui_family_war_match.map")
    self:setLabelAtlas("txt_season_num",data.season)
    self.curGround=-1
    self.isMainLayerGoldShow = false;
    self:initTeam(data.list)
    self:checkTimeForFightStatus()
    self:setTimeBarInfo()
    self:resetLayOut()

    cc.UserDefault:getInstance():setIntegerForKey("family.sign"..gUserInfo.id,gFamilyMatchInfo.season)
    cc.UserDefault:getInstance():flush()
end



function FamilyWarMatchPanel:checkTimeForFightStatus()
    local time8 = toint(DB.getFamilyWarMatchTime(8))
    local time4 = toint(DB.getFamilyWarMatchTime(4))
    local time2 = toint(DB.getFamilyWarMatchTime(2))
    local time1 = toint(DB.getFamilyWarMatchTime(1))
    self:setLabelString("txt_time8", string.format("%d:00",time8))
    self:setLabelString("txt_time4", string.format("%d:00",time4))
    self:setLabelString("txt_time2", string.format("%d:00",time2))
    self:setLabelString("txt_time1", string.format("%d:00",time1))

    local curTimeTable = gGetDate("*t", gGetCurServerTime())
    local curWDay = (curTimeTable.wday + 6) % 7
    if curWDay == 0 then
        curWDay = 7
    end

    local matchDay = DB.getFamilyWarMatchDate()
    if matchDay == 0 then
        matchDay = 7
    end

    if(curWDay == matchDay)then

        if (   curTimeTable.hour < time8 - 1) then
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
    else
        self.curStatus = TIME_FINISH
    end
end


function FamilyWarMatchPanel:setTimeBarInfo()
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
end

function FamilyWarMatchPanel:initTeam(list)
    local rounds={}
    for key, var in pairs(list) do
        if(rounds[var.round]==nil)then
            rounds[var.round]={}
        end
        table.insert(rounds[var.round],var)
    end
    self.winerLine={}
    self.curGround=-1
    self:setFamilyState(true)
    self:cleaWinerFlag() 
    self.winFids={}
    self:initRound8(rounds[8])
    self:initRound4(rounds[4])
    self:initRound2(rounds[2])
    self:initRound1(rounds[1])

    self:changeTexture("line1","images/ui_family/match_line1.png")
    self:getNode("winer_panel"):setVisible(false)
    
     
     
    local num=self.curGround/2
    if(table.count(rounds)~=0)then
        for i=0, num-1 do 
            self:changeTexture("v_"..num.."_"..i,"images/ui_family/fighting_di1.png") 
            local fla=gCreateFla("ui_family_bz_combat",1)
            local node=self:getNode("v_"..num.."_"..i)
            fla:setPositionX(node:getContentSize().width/2)
            fla:setPositionY(node:getContentSize().height/2)
            node:addChild(fla) 
            self:setTouchEnable("v_"..num.."_"..i,false,false)
        end

    end
  
    

    self:getNode("btn_family"):setVisible(false)
    for key, var in pairs(self.winFids) do
        if(gFamilyInfo.familyId==var)then
            self:getNode("btn_family"):setVisible(true) 
        end

    end
 
    
    if(rounds[1]  and rounds[1][1] and rounds[1][1] .win1~=-1)then
        self:getNode("btn_family"):setVisible(false)
        self:getNode("winer_panel"):setVisible(true)
        local winFid=rounds[1][1] .fid1
        if(rounds[1][1] .win1==1)then
            self:setLabelString("txt_winner",rounds[1][1] .name1)
        else
            winFid=rounds[1][1] .fid2
            self:setLabelString("txt_winner",rounds[1][1].name2)
        end
        self:changeTexture("line1","images/ui_family/match_line1-1.png")

        if(self.winerLine[winFid])then
            table.insert(self.winerLine[winFid],self:getNode("line1"))
            for key, line in pairs(self.winerLine[winFid]) do
                self:shineLine(line)
            end
        end

    end
    self.rounds=rounds

end


function FamilyWarMatchPanel:cleaWinerFlag()
    for i=0, 15 do
        self:getNode("win_flag"..i):setVisible(false)
    end
end


function FamilyWarMatchPanel:initRound1(rounds)
    self:setLineGray(1,rounds)
end


function FamilyWarMatchPanel:initRound2(rounds)

    self:setLineGray(2,rounds)
end


function FamilyWarMatchPanel:initRound4(rounds)
    self:setLineGray(4,rounds)
end

function FamilyWarMatchPanel:setLineGray(num,rounds)

    for i=0, num-1 do
        self:setTouchEnable("v_"..num.."_"..i,false,true)
        self:changeTexture("v_"..num.."_"..i,"images/ui_public1/play.png")
        self:getNode("v_"..num.."_"..i):removeAllChildren()

    end



    for i=0, num*2-1 do
        self:changeTexture("line"..num.."_"..i,"images/ui_family/match_line"..num..".png")
    end
    if(rounds)then
        self:setLabelString("txt_match_state2",gGetWords("familyWords.plist","family_war_state_"..num))
        self:cleaWinerFlag()
        for key, var in pairs(rounds) do
            self:getNode("v_"..num.."_"..var.groupId).id=var.id
            self:getNode("v_"..num.."_"..var.groupId).var=var
            if(var.win1==-1)then
            elseif(var.win1==1)then
                self.curGround=num
                self:setFamilyLineWin(var,1,num,"line"..num.."_"..(var.groupId*2))
            else
                self.curGround=num
                self:setFamilyLineWin(var,2,num,"line"..num.."_"..(var.groupId*2+1))
            end
        end 
    end
end

function  FamilyWarMatchPanel:shineLine(line)

    line:stopAllActions()
    local actions={}
    table.insert(actions,cc.FadeTo:create(0.3,100))
    table.insert(actions,cc.FadeTo:create(0.3,255))

    local pAct_repeat =cc.RepeatForever:create(cc.Sequence:create(actions) )
    line:runAction(pAct_repeat)
end

function FamilyWarMatchPanel:setFamilyLineWin(var,pos,num,line)
    local lastPos=1
    if(pos==1)then
        lastPos=2
    end
    local winFid=var["fid"..pos]
    local lostFid=var["fid"..lastPos]
    if(num==8)then
        self:setFamilyLost(lostFid,true)
    end 
    
    self:setFlagVisibleByName(var["name"..pos],true)
    if(var.fid1~=0 and var.fid2~=0)then
        self:setTouchEnable("v_"..num.."_"..var.groupId,true,false)
    end
    if( self.winerLine[winFid]==nil)then
        self.winerLine[winFid]={}
    end
    self:changeTexture(line,"images/ui_family/match_line"..num.."-1.png")
    table.insert(self.winerLine[winFid],self:getNode(line) )
    self:getNode("v_"..num.."_"..var.groupId).winer=winFid

end

function FamilyWarMatchPanel:initRound8(rounds)

    for i=0, 15 do
        self:setLabelString("txt_name"..i,"")
        self:getNode("ficon"..i):setVisible(false)
    end

    self.curGround=16
    if(rounds==nil)then
        rounds={} 
    end
    for key, var in pairs(rounds) do
        self:setLabelString("txt_name"..var.groupId*2,var.name1)
        self:setLabelString("txt_name"..(var.groupId*2+1),var.name2)
        self:getNode("txt_name"..var.groupId*2).fid=var.fid1
        self:getNode("txt_name"..(var.groupId*2+1)).fid=var.fid2

        table.insert(self.winFids,var.fid1)
        table.insert(self.winFids,var.fid2)
        self:getNode("ficon"..var.groupId*2):setVisible(true)
        self:getNode("ficon"..(var.groupId*2+1)):setVisible(true)
        Icon.setFamilyIcon(self:getNode("ficon"..var.groupId*2),var.icon1)
        Icon.setFamilyIcon(self:getNode("ficon"..(var.groupId*2+1)),var.icon2)

    end
    self:setLineGray(8,rounds)
 
end

function FamilyWarMatchPanel:setFamilyState(win)
    for i=0, 15 do
        if(win)then
            if(i<=7)then
                self:changeTexture("fbg"..i,"images/ui_family/world_t1.png")
            else
                self:changeTexture("fbg"..i,"images/ui_family/world_t2.png")
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

function FamilyWarMatchPanel:setFamilyLost(fid,visible)
    for i=0, 15 do
        if(self:getNode("txt_name"..i).fid==fid)then
            if(i<=7)then
                self:changeTexture("fbg"..i,"images/ui_family/world_t1-1.png")
            else
                self:changeTexture("fbg"..i,"images/ui_family/world_t2-1.png")
            end
            self:getNode("txt_name"..i):setColor(cc.c3b(151,151,151))
        end
    end
end

function FamilyWarMatchPanel:setFlagVisibleByName(name,visible)
    for i=0, 15 do
        if(self:getNode("win_flag"..i).name==name)then
            self:getNode("win_flag"..i):setVisible(false)
        end
    end
    return nil
end

function FamilyWarMatchPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();

    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_FAMILY_WAR)
    elseif  target.touchName=="btn_reward"then
        Panel.popUp(PANEL_FAMILY_WAR_REWARD)
    elseif(target.touchName=="btn_support")then
        local list=self.rounds[self.curGround]
        if(list==nil)then
            list={}
        end
      --  Panel.popUp(PANEL_FAMILY_WAR_SUPPORT,list)

    elseif  target.touchName=="btn_family"then 
        Net.sendFamilyTeamInfo(gFamilyInfo.familyId)
    elseif  string.find(target.touchName,"v_")then
        local temp=string.split(target.touchName,"_")
             local var=target.var
            Net.sendFamilyMatchDetail(target.id)
            Net.sendFamilyMatchDetailParam=target.var
       
    end
end


return FamilyWarMatchPanel