local TreasureHuntTeamItem=class("TreasureHuntTeamItem",UILayer)

function TreasureHuntTeamItem:ctor(teamInfo)
    self:init("ui/ui_team_room_item.map")
    self.teamInfo = teamInfo
    self:setCaptainId(teamInfo)
    self:isSelfInThisTeam(teamInfo)
    self:setData(teamInfo)
end

function TreasureHuntTeamItem:setData(teamInfo)
   if teamInfo.state == TreasureTeamStatus.none then
        self:setMemberInfo(1, teamInfo.member1)
        self:setMemberInfo(2, teamInfo.member2)
        self:setAttrAddShow(teamInfo.member1, teamInfo.member2)
        self:setStartShow()
        self:setWaitChoosePath()
   elseif teamInfo.state ==  TreasureTeamStatus.wait_start then
        self:setMemberInfo(1, teamInfo.member1)
        self:setMemberInfo(2, teamInfo.member2)

        self:setAttrAddShow(teamInfo.member1, teamInfo.member2)
        self:setStartShow()
        self:setWaitChoosePath()
   elseif teamInfo.state ==  TreasureTeamStatus.wait_choose_path then
        if teamInfo.member1 == nil or teamInfo.member2 == nil or 
            teamInfo.member1.id == 0 or teamInfo.member2.id == 0 then
            return
        end
        self:setMemberInfo(1, teamInfo.member1)
        self:setMemberInfo(2, teamInfo.member2)
        self:setAttrAddShow(teamInfo.member1, teamInfo.member2)
        self:setStartShow()
        self:setWaitChoosePath()
   elseif teamInfo.state ==  TreasureTeamStatus.finding then
        if teamInfo.member1 == nil or 
           teamInfo.member2 == nil or 
           teamInfo.member1.id == 0 or
           teamInfo.member2.id == 0 then
            return
        end

        self:setMemberInfo(1, teamInfo.member1)
        self:setMemberInfo(2, teamInfo.member2)
        self:setAttrAddShow(teamInfo.member1, teamInfo.member2)
        self:setStartShow()
        self:setWaitChoosePath()
   end
end


function TreasureHuntTeamItem:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_start" then 
        Net.sendCrossTreasureCreateMap(gTreasureHunt.getCurHallId(), self.teamInfo.roomId)
    elseif target.touchName=="btn_enter" then
        Net.sendCrotreInitmap(gTreasureHunt.getCurHallId(), self.teamInfo.roomId)
    elseif target.touchName=="btn_join2" or target.touchName=="btn_join1" then
        if self.teamInfo.state == TreasureTeamStatus.none or 
           self.teamInfo.state == TreasureTeamStatus.wait_start then
            local idx =  toint(string.sub(target.touchName, string.len("btn_join") + 1))
            local isLeft = (idx == 1)
            if self.teamInfo.state == TreasureTeamStatus.wait_start then
                -- TODO 完善
                if (isLeft and self.teamInfo.member1 ~= nil) or 
                   (not isLeft and self.teamInfo.member2 ~= nil) then
                end
            end

            Panel.popUp(PANEL_TREASURE_HUNT_CHOOSE_MAP,self.teamInfo, isLeft)
        end
    elseif target.touchName=="btn_leave1" or target.touchName=="btn_leave2" then
        local idx =  toint(string.sub(target.touchName, string.len("btn_leave") + 1))
        local isLeft = (idx == 1)
        Net.sendCroTreExitRoom(gTreasureHunt.getCurHallId(), self.teamInfo.roomId, isLeft)
    elseif target.touchName=="btn_kick1" or target.touchName=="btn_kick2" then
        local idx =  toint(string.sub(target.touchName, string.len("btn_kick") + 1))
        local isLeft = (idx == 1)
        Net.sendCrotreKick(gTreasureHunt.getCurHallId(), self.teamInfo.roomId, isLeft)
    end
end

function TreasureHuntTeamItem:setCaptainId(teamInfo)
    if teamInfo.member1 ~= nil and teamInfo.member1.isCaptain then
        self.captainId = teamInfo.member1.id
    elseif teamInfo.member2 ~= nil and teamInfo.member2.isCaptain then
        self.captainId = teamInfo.member2.id
    end
end

function TreasureHuntTeamItem:setMemberInfo(idx, memberInfo)
    --如果成员信息为空或id为0，重置信息区域显示
    if memberInfo == nil or memberInfo.id == 0 then
        self:resetMemberInfo(idx)
        return
    end

    self:getNode("icon_captain"..idx):setVisible(memberInfo.isCaptain)
    self:setLabelString("txt_medal"..idx, memberInfo.safeLv)
    self:getNode("layout_medal"..idx):setVisible(true)
    self:getNode("layout_flag"..idx):layout()
    self:getNode("layout_flag"..idx):setVisible(true)

    Icon.setHeadIcon(self:getNode("icon"..idx), memberInfo.icon)
    self:setLabelString("txt_name"..idx, memberInfo.name)
    self:getNode("txt_name"..idx):setVisible(true)
    self:setLabelString("txt_servername"..idx, memberInfo.serverName)
    self:getNode("txt_servername"..idx):setVisible(true)
    self:changeTexture("treasure_map"..idx, string.format("images/icon/item/%d.png", memberInfo.treasureMap))
    self:getNode("treasure_map"..idx):setVisible(true)
    if (self.teamInfo.state == TreasureTeamStatus.wait_start) then
        if memberInfo.id == Data.getCurUserId() then
            --self:setLabelString("txt_join"..idx, gGetWords("treasureHuntWord.plist","txt_leave_team"))
            self:getNode("btn_join"..idx):setVisible(false)
            self:getNode("btn_leave"..idx):setVisible(true)
            self:getNode("btn_kick"..idx):setVisible(false)
        elseif self.selfInThisTeamFlag then
            if self.captainId == Data.getCurUserId() then
                self:getNode("btn_join"..idx):setVisible(false)
                self:getNode("btn_leave"..idx):setVisible(false)
                self:getNode("btn_kick"..idx):setVisible(true)
            else
                self:getNode("btn_join"..idx):setVisible(false)
                self:getNode("btn_leave"..idx):setVisible(false)
                self:getNode("btn_kick"..idx):setVisible(false)
            end
        else
            self:getNode("btn_join"..idx):setVisible(false)
            self:getNode("btn_leave"..idx):setVisible(false)
            self:getNode("btn_kick"..idx):setVisible(false)
        end
    else
        self:getNode("btn_join"..idx):setVisible(false)
        self:getNode("btn_leave"..idx):setVisible(false)
        self:getNode("btn_kick"..idx):setVisible(false)
    end
end

function TreasureHuntTeamItem:isSelfInThisTeam(teamInfo)
    self.selfInThisTeamFlag = false
    if (teamInfo.member1 ~= nil and teamInfo.member1.id == Data.getCurUserId()) or
       (teamInfo.member2 ~= nil and teamInfo.member2.id == Data.getCurUserId()) then
        self.selfInThisTeamFlag = true
    end
end

function TreasureHuntTeamItem:setAttrAddShow(member1, member2)
    if member1 == nil or member2 == nil then
        self:getNode("txt_attr_add"):setVisible(false)
    else
        self:getNode("txt_attr_add"):setVisible(true)
        if member1.treasureMap == member2.treasureMap then
            self:getNode("txt_attr_add"):setColor(cc.c3b(0,255,0))
        else
            self:getNode("txt_attr_add"):setColor(cc.c3b(170,170,170))
        end
    end
end

function TreasureHuntTeamItem:setWaitStarTime()
    self:unscheduleUpdateEx()
    --如果没有有一边没有人表示正在等待成员加入，如果都有人则表示等待开始
    if self.teamInfo.member1 == nil or self.teamInfo.member2 == nil or
       self.teamInfo.member1.id == 0 or self.teamInfo.member2.id == 0 then
        self:getNode("layer_wait_lefttime"):setVisible(true)
        local lefttime  = self.teamInfo.starEndTime - gGetCurServerTime()
        self:setLabelString("txt_wait_lefttime", gParserMinTime(lefttime))
        self:getNode("txt_wait_lefttime"):setVisible(true)
    else
        if self.selfInThisTeamFlag and self.captainId == Data.getCurUserId() then
            self:getNode("layer_wait_lefttime"):setVisible(false)
        else
            self:getNode("layer_wait_lefttime"):setVisible(true)
        end
    end
    
    self:scheduleUpdate(function()
        local updateLefttime = self.teamInfo.starEndTime - gGetCurServerTime()
        if updateLefttime > 0 then
            self:setLabelString("txt_wait_lefttime", gParserMinTime(updateLefttime))
        else

            -- Net.sendCroTreExitRoom(gTreasureHunt.getCurHallId(), self.teamInfo.roomId)
            self:unscheduleUpdateEx()
        end
        
    end, 1.0)
end

function TreasureHuntTeamItem:onUILayerExit()
    self:unscheduleUpdateEx()
end

function TreasureHuntTeamItem:setStartShow()
    self:getNode("btn_start"):setVisible(false)
    if self.teamInfo.state ==  TreasureTeamStatus.none then
        self:getNode("layer_wait_lefttime"):setVisible(false)
    elseif self.teamInfo.state ==  TreasureTeamStatus.wait_start then
        if  self.teamInfo.member1 == nil or 
            self.teamInfo.member2 == nil or 
            self.teamInfo.member1.id == 0 or 
            self.teamInfo.member2.id == 0 then 
            self:setLabelString("txt_wait_title", gGetMapWords("ui_team_room_item.plist","8"))
            self:setWaitStarTime()
        else
            if self.selfInThisTeamFlag and self.captainId == Data.getCurUserId() then
                self:setLabelString("txt_start", gGetMapWords("ui_team_room_item.plist","4"))
                self:getNode("btn_start"):setVisible(true)
            else
                self:setLabelString("txt_wait_title", gGetWords("treasureHuntWord.plist","txt_wait_title"))
            end
            self:getNode("txt_wait_lefttime"):setVisible(false)
            self:getNode("layer_wait_lefttime"):setVisible(true)
            self:setWaitStarTime()           
        end
    elseif self.teamInfo.state ==  TreasureTeamStatus.wait_choose_path or
           self.teamInfo.state ==  TreasureTeamStatus.finding then
        self:getNode("btn_start"):setVisible(false)
        self:getNode("layer_wait_lefttime"):setVisible(false)
    end
end

function TreasureHuntTeamItem:setWaitChoosePath()
    if self.teamInfo.state ==  TreasureTeamStatus.wait_start or
       self.teamInfo.state ==  TreasureTeamStatus.none then
        self:getNode("layer_escort"):setVisible(false)
        self:getNode("txt_escorting"):setVisible(false)
        return
    end

    self:unscheduleUpdateEx()
    self:getNode("layer_escort"):setVisible(true)
    self:setLabelString("txt_escort", self.teamInfo.mapInfo.ambushNum)
    if self.teamInfo.state ==  TreasureTeamStatus.wait_choose_path then
        self:getNode("txt_escorting"):setVisible(false)
        self:getNode("layout_choose_path_time"):setVisible(true)
        self:getNode("txt_stage_tip"):setVisible(false)
        local lefttime = self.teamInfo.mapInfo.createTime + DB.getTreasureHuntFightTime1() - gGetCurServerTime()
        if lefttime > 0  then
            self:setLabelString("txt_choose_path_time", gParserMinTime(lefttime))
            self:getNode("layout_choose_path_time"):layout()
            self:scheduleUpdate(function ()
                local updateLefttime = self.teamInfo.mapInfo.createTime + DB.getTreasureHuntFightTime1() - gGetCurServerTime()
                if updateLefttime > 0 then
                    self:setLabelString("txt_choose_path_time", gParserMinTime(updateLefttime))
                    self:getNode("layout_choose_path_time"):layout()
                end
            end, 1.0)
        end
    elseif self.teamInfo.state ==  TreasureTeamStatus.finding then
        self:getNode("txt_escorting"):setVisible(true)
        self:getNode("layout_choose_path_time"):setVisible(false)
        self:getNode("txt_stage_tip"):setVisible(true)
        if self.teamInfo.mapInfo.endTime == nil then
            return
        end

        local stageTip = gTreasureHunt.getHuntFightTimeTip(self.teamInfo.mapInfo.road, self.teamInfo.mapInfo.endTime)
        self:setLabelString("txt_stage_tip", stageTip)

        self:scheduleUpdate(function()
            local updateStageTip = gTreasureHunt.getHuntFightTimeTip(self.teamInfo.mapInfo.road, self.teamInfo.mapInfo.endTime)
            self:setLabelString("txt_stage_tip", updateStageTip)
        end, 1.0)
    end
end

function TreasureHuntTeamItem:refreshItemInfo(param)
    -- 左边设置左边的成员
    if param.isLeft then
        if self.teamInfo.member1 == nil then
            self.teamInfo.member1 = TreasureHuntMember.new()
        end

        self.teamInfo.member1.id = param.uid
        self.teamInfo.member1.name = param.name
        self.teamInfo.member1.isCaptain = (param.uid == param.captainId)
        self.teamInfo.member1.serverName = param.sname
        self.teamInfo.member1.treasureMap = param.map
        self.teamInfo.member1.safeLv = param.safelv
        self.teamInfo.member1.icon = param.icon
    else
        if self.teamInfo.member2 == nil then
            self.teamInfo.member2 = TreasureHuntMember.new()
        end

        self.teamInfo.member2.id = param.uid
        self.teamInfo.member2.name = param.name
        self.teamInfo.member2.isCaptain = (param.uid == param.captainId)
        self.teamInfo.member2.serverName = param.sname
        self.teamInfo.member2.treasureMap = param.map
        self.teamInfo.member2.safeLv = param.safelv
        self.teamInfo.member2.icon = param.icon
    end

    self.teamInfo.state = param.state
    self.teamInfo.roomId = param.roomId
    self.teamInfo.starEndTime = param.starEndTime

    self:setCaptainId(self.teamInfo)
    self:isSelfInThisTeam(self.teamInfo)
    self:setData(self.teamInfo)
end

function TreasureHuntTeamItem:oneLeaveTeam(param)
    -- 左边设置左边的成员
    if param.isLeft then
        self.teamInfo.member1 = nil
        if self.teamInfo.member2 ~= nil and 
           self.teamInfo.member2.id == param.captainId then
           self.teamInfo.member2.isCaptain = true
        end
    else
        self.teamInfo.member2 = nil
        if self.teamInfo.member1 ~= nil and 
           self.teamInfo.member1.id == param.captainId then
           self.teamInfo.member1.isCaptain = true
        end
    end

    self.teamInfo.state = param.state
    self.teamInfo.roomId = param.roomId
    self.teamInfo.starEndTime = param.starEndTime

    self:setCaptainId(self.teamInfo)
    self:isSelfInThisTeam(self.teamInfo)
    self:setData(self.teamInfo)    
end

function TreasureHuntTeamItem:resetMemberInfo(idx)
    self:getNode("icon_captain"..idx):setVisible(false)
    self:getNode("layout_medal"..idx):setVisible(false)
    self:getNode("layout_flag"..idx):setVisible(false)
    self:getNode("icon"..idx):removeChildByTag(1)
    self:getNode("icon"..idx):removeChildByTag(100)
    self:getNode("icon"..idx):setTexture("images/ui_public1/ka_d1.png")
    self:getNode("txt_name"..idx):setVisible(false)
    self:getNode("txt_servername"..idx):setVisible(false)
    self:getNode("treasure_map"..idx):setVisible(false)
    self:getNode("btn_join"..idx):setVisible(true)
    self:getNode("btn_leave"..idx):setVisible(false)
    self:getNode("btn_kick"..idx):setVisible(false)
end

function TreasureHuntTeamItem:refreshAmbushInfo(param)
    self:setLabelString("txt_escort", param.ambushNum)
    self.teamInfo.mapInfo.ambushNum = param.ambushNum
end

function TreasureHuntTeamItem:refreshTeamChoosePath(param)
    self.teamInfo.state = param.state
    print("ChoosePath self.teamInfo.state is:",self.teamInfo.state)
    self.teamInfo.mapInfo.createTime = param.mapCreateTime
    self:setData(self.teamInfo)
end

function TreasureHuntTeamItem:refreshTeamBeginFight(param)
    self.teamInfo.state = param.state
    print("BeginFight self.teamInfo.state is:",self.teamInfo.state)
    self.teamInfo.mapInfo.endTime = param.etime
    self.teamInfo.mapInfo.road = param.road
    self:setData(self.teamInfo)
end

function TreasureHuntTeamItem:clearTeamInfo(param)
    self.teamInfo:resetData()
    self.teamInfo.roomId = param.roomId
    self:unscheduleUpdateEx()
    self:setData(self.teamInfo)
end

return TreasureHuntTeamItem