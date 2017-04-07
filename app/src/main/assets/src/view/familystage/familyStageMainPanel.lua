local FamilyStageMainPanel=class("FamilyStageMainPanel",UILayer)

local PROG_LEAD_NONE = 0
local PROG_LEAD_SELF = 1
local PROG_LEAD_OTHER = 2

function FamilyStageMainPanel:ctor()
    self:init("ui/ui_family_race.map")
    self.isMainLayerMenuShow = false
    self:initPanel()
end

function FamilyStageMainPanel:initPanel()
    gCreateBtnBack(self)
    self:initBuffShow()
    self:initKillInofShow()
    self:setAverPower()
    self:setActiveNum()
    self:initFamilyInfo()
    self:initStageScroll()
    self:initSchedule()
end

function FamilyStageMainPanel:initBuffShow()
    -- 为0表示没有设置buff
    self.hasNoBuff = (gFamilyStageInfo.buff.major ~= nil and gFamilyStageInfo.buff.minor == 0)
    self:getNode("icon_buff_lock1"):setVisible(not self.hasNoBuff)
    self:getNode("icon_buff_lock2"):setVisible(not self.hasNoBuff)
    self:getNode("txt_add_buff_tip"):setVisible(self.hasNoBuff)
    self:getNode("btn_buff_confirm"):setVisible(false)
    self:getNode("layer_buff_up"):setVisible(not self.hasNoBuff)
    if Data.isFamilyStageAllPassed(true) then
        self:setTouchEnable("layer_buff_up", false, true)
    end

    if not self.hasNoBuff then
        -- Icon.changeCountryIcon(self:getNode("btn_buff1"), gFamilyStageInfo.buff.major)
        -- Icon.changeCountryIcon(self:getNode("btn_buff2"), gFamilyStageInfo.buff.minor)
        self:changeTexture("btn_buff1", "images/ui_family/BUFF_"..gFamilyStageInfo.buff.major..".png")
        self:changeTexture("btn_buff2", "images/ui_family/BUFF_"..gFamilyStageInfo.buff.minor..".png")
--        self:setTouchEnable("btn_buff1", false, false)
--        self:setTouchEnable("btn_buff2", false, false)
        self:setBuffUpInfo()
        self.selectcBuff1 = gFamilyStageInfo.buff.major
        self.selectcBuff2 = gFamilyStageInfo.buff.minor
    else
        self.selectcBuff1 = 0
        self.selectcBuff2 = 0
        self:getNode("btn_buff1"):runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(1,0.8)), 
                                                  cc.EaseBackOut:create(cc.ScaleTo:create(1,1)))))
        self:getNode("btn_buff2"):runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(1,0.8)), 
                                                  cc.EaseBackOut:create(cc.ScaleTo:create(1,1)))))
    end   
end

function FamilyStageMainPanel:initKillInofShow()
    self.killScroll = self:getNode("kill_scroll")
    self.killScroll.eachLineNum = 1
    self.killScroll:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    for key, var in pairs(gFamilyStageInfo.kills) do
        local mapId = math.floor(var.stageId / 100)
        local stageId = var.stageId % 100
        local stageInfo = string.format("%d-%d", mapId, stageId)
        local name = var.name
        local itemInfo = ""
        for rewKey,rewItem in pairs(var.rewards) do
            if rewKey ~= 1 then
                itemInfo = itemInfo .. ","
            end
            itemInfo = itemInfo .. string.format("\\\\c{n=%d;s=0.3;v=0",rewItem.id).. "}\\\\*" .. rewItem.num
        end

        local item = RTFLayer.new(self:getNode("kill_scroll"):getContentSize().width-5)
        item:setAnchorPoint(cc.p(0,1))
        item:setDefaultConfig(gFont,20,cc.c3b(255,245,140))
        local word = gGetWords("familyWords.plist","txt_stage_kill_info",name, stageInfo, itemInfo)
        item:setString(word)
        item:layout()
        self.killScroll:addItem(item)

        -- local labelItem = gCreateWordLabelTTF(gGetWords("familyWords.plist","txt_stage_kill_info",stageInfo,name,itemInfo), gCustomFont, 16, cc.c3b(172,64,64), cc.size(220,0),cc.TEXT_ALIGNMENT_LEFT)
        -- labelItem:setAnchorPoint(cc.p(0.0, 1.0))
        -- self.killScroll:addItem(labelItem)
    end
    self.killScroll:layout(true)
end

function FamilyStageMainPanel:setAverPower()
    self:setLabelString("txt_aver_power", gFamilyStageInfo.power)
    self:getNode("layout_aver_power"):layout()
end

function FamilyStageMainPanel:setActiveNum()
    self:setLabelString("txt_active_num", gFamilyStageInfo.activeNum)
    self:getNode("layout_active_num"):layout()
end

function FamilyStageMainPanel:initFamilyInfo()
    Icon.setFamilyIcon(self:getNode("family_icon1"),gFamilyInfo.icon,gFamilyInfo.familyId)
    self:setLabelString("txt_family_name1", gFamilyInfo.sName)
    self:setLabelString("txt_family_kill1", gFamilyStageInfo.pro)

    if gFamilyStageInfo.oppInfo.icon ~= nil then
        Icon.setFamilyIcon(self:getNode("family_icon2"), gFamilyStageInfo.oppInfo.icon, gFamilyStageInfo.oppInfo.familyId)
        self:setLabelString("txt_family_name2", gFamilyStageInfo.oppInfo.name)
        self:setLabelString("txt_family_kill2", gFamilyStageInfo.oppInfo.pro)
    else
        self:getNode("bg_family_icon2"):setVisible(false)
        self:getNode("txt_family_name2"):setVisible(false)
        self:getNode("spr_lead_family2"):setVisible(false)
        self:getNode("txt_family_lead2"):setVisible(false)
        self:getNode("flag_sel_family2"):setVisible(false)
        self:getNode("icon_suc2"):setVisible(false)
        self:setTouchEnable("layer_family2", false, false)
    end

    local leadStatus = self:getLeadStatus()
    self:getNode("txt_family_lead1"):setVisible(leadStatus == PROG_LEAD_SELF)
    self:getNode("txt_family_lead2"):setVisible(leadStatus == PROG_LEAD_OTHER)

    local selfAllPassed = Data.isFamilyStageAllPassed(true)
    local otherAllPassed = Data.isFamilyStageAllPassed()

    if selfAllPassed == otherAllPassed then
        if selfAllPassed then
            if gFamilyStageInfo.fightTime < gFamilyStageInfo.oppInfo.fightTime then
                self:getNode("icon_suc1"):setVisible(true)
            elseif gFamilyStageInfo.fightTime > gFamilyStageInfo.oppInfo.fightTime then
                self:getNode("icon_suc2"):setVisible(true)
            end
        end
    else
        self:getNode("icon_suc1"):setVisible(selfAllPassed)
        self:getNode("icon_suc2"):setVisible(otherAllPassed)
    end
end

function FamilyStageMainPanel:initStageScroll()
    self.stageScroll = self:getNode("stage_scroll")
    self.stageScroll.eachLineNum = 1
    self.stageScroll:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:setStageProScroll(true)
end

function FamilyStageMainPanel:setStageProScroll(isSelf)
    self:getNode("flag_sel_family1"):setVisible(isSelf)
    self:getNode("flag_sel_family2"):setVisible(not isSelf)
    self.stageScroll:clear()
    local proList = gFamilyStageInfo.otherProLists
    if isSelf then
        proList = gFamilyStageInfo.selfProLists
    end

    local maxMap = DB.getMaxFamilyStageMaxMapId()
for i = 1, maxMap do
        local stageItem = FamilyStageItem.new(i,isSelf)
        if stageItem:getNode("btn_go"):isVisible() then
            stageItem:setTouchEnable("btn_go", not self.hasNoBuff, self.hasNoBuff)
        end
        self.stageScroll:addItem(stageItem)
    end

    self.stageScroll:layout(true)
end

function FamilyStageMainPanel:onTouchBegan(target,touch, event)
    if target.touchName == "btn_buff1" or target.touchName == "btn_buff2"  then
        if self:getNode("icon_buff_lock1"):isVisible() then
            local idx = toint(string.sub(target.touchName, string.len("btn_buff") + 1))
            Panel.popTouchTip(self:getNode(target.touchName), TIP_TOUCH_DESC, "", {type=TIP_TOUCH_DESC_FAMILY_BUFF,data=idx})
            self.beganAttrPos = touch:getLocation()
        end
    end
end

function FamilyStageMainPanel:onTouchMoved(target,touch, event)
    if self.beganAttrPos ~= nil then
        self.endAttrPos = touch:getLocation()
        local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
        if dis > gMovedDis then
            Panel.clearTouchTip()
        end
    end
end

function FamilyStageMainPanel:onTouchEnded(target, touch, event)
    Panel.clearTouchTip()
    if target.touchName == "btn_buff1" or target.touchName == "btn_buff2" then
        if not self:getNode("icon_buff_lock1"):isVisible() then
            if gFamilyInfo.iType ~= 1 and gFamilyInfo.iType ~= 2 then
                gShowNotice(gGetWords("noticeWords.plist", "set_family_stage_buff_lim"))
                return
            end
            local idx = toint(string.sub(target.touchName, string.len("btn_buff") + 1))
            Panel.popUpVisible(PANEL_FAMILY_STAGE_BUFF,idx,{buff1=self.selectcBuff1, buff2=self.selectcBuff2})
        else
            Panel.clearTouchTip()
        end
    elseif target.touchName == "btn_buff_confirm" then
        if self.selectcBuff1 == 0 or self.selectcBuff2 == 0 then
            return
        end

        Net.sendFamilyStageSetBuff(self.selectcBuff1, self.selectcBuff2)
    elseif target.touchName == "layer_buff_up" then
        Panel.popUpVisible(PANEL_FAMILY_STAGE_BUFF_UP)
    elseif target.touchName == "btn_reward" then
        Panel.popUpVisible(PANEL_FAMILY_STAGE_REWARD)
    elseif target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_look_active" then
        Net.sendFamilyStageUseright()
    elseif target.touchName == "layer_family1" then
        Net.sendFamilyStageProg(gFamilyInfo.familyId)
    elseif target.touchName == "layer_family2" then
        if gFamilyStageInfo.oppInfo.icon ~= nil then
            Net.sendFamilyStageProg(gFamilyStageInfo.oppInfo.familyId)
        end
    elseif target.touchName == "btn_last_info" then
        Net.sendFamilyStageLastRank()
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_FAMILY_STAGE)
    elseif target.touchName == "btn_shop" then
        if Module.isClose(SWITCH_FAMILY_SHOP4) or gFamilyInfo.iLevel < DB.getFamilyBuildUnlock(11) then
            Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY)
        else
            Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY_4)
        end 
    end
end

function FamilyStageMainPanel:events()
    return {
        EVENT_ID_FAMILY_STAGE_REFRESH_INFO,
        EVENT_ID_FAMILY_STAGE_SEL_COUNTRY_BUFF,
        EVENT_ID_FAMILY_STAGE_MAIN_REFRESH,
    }
end

function FamilyStageMainPanel:dealEvent(event, param)
    if event == EVENT_ID_FAMILY_STAGE_REFRESH_INFO then
        self:refreshInfo(param)
    elseif event == EVENT_ID_FAMILY_STAGE_SEL_COUNTRY_BUFF then
        self:setSelCountryBuff(param)
    elseif event == EVENT_ID_FAMILY_STAGE_MAIN_REFRESH then
        self:initPanel()
    end
end

function FamilyStageMainPanel:refreshInfo(refreshType)
    if refreshType == FAMILY_STAGE_REFRESH_PROG_LIST then
        local isSelf = (Net.familyStageQueryFid == gFamilyInfo.familyId)
        self:setStageProScroll(isSelf)
    elseif refreshType == FAMILY_STAGE_REFRESH_SET_BUFF then
        self:getNode("icon_buff_lock1"):setVisible(true)
        self:getNode("icon_buff_lock2"):setVisible(true)
        self:getNode("btn_buff_confirm"):setVisible(false)
        self:getNode("layer_buff_up"):setVisible(true)
        -- self:setTouchEnable("btn_buff1", false, false)
        -- self:setTouchEnable("btn_buff2", false, false)
        self:setBarPer("bar_buff_up", 0)
        self.hasNoBuff = false
        self:refreshStageItemInfo()
        self:setBuffUpInfo()
        Data.setFamilyStageBuffCountry(self.selectcBuff1, self.selectcBuff2)
    elseif refreshType == FAMILY_STAGE_REFRESH_BUFF_UP then
        self:setBuffUpInfo()
    elseif refreshType == FAMILY_STAGE_REFRESH_FIGHT_LIST then
        Panel.popUpVisible(PANEL_FAMILY_STAGE_JOIN)
    end
end

function FamilyStageMainPanel:setSelCountryBuff(param)
    self.selectcBuff1 = param[1]
    self.selectcBuff2 = param[2]
    if self.selectcBuff1 ~= 0 then
        self:getNode("btn_buff1"):stopAllActions()
        self:getNode("btn_buff1"):setScale(1)
        self:changeTexture("btn_buff1", "images/ui_family/BUFF_"..param[1]..".png")
    end

    if self.selectcBuff2 ~= 0 then
        self:getNode("btn_buff2"):stopAllActions()
        self:getNode("btn_buff2"):setScale(1)
        self:changeTexture("btn_buff2", "images/ui_family/BUFF_"..param[2]..".png")
    end
    
    self:getNode("layer_buff_up"):setVisible(false)
    if self.selectcBuff2 ~= 0 and self.selectcBuff1 ~= 0 then
        self:getNode("btn_buff_confirm"):setVisible(true)
        self:getNode("txt_add_buff_tip"):setVisible(false)
    end
end

function FamilyStageMainPanel:onUILayerExit()
    self:unscheduleUpdateEx()
end

function FamilyStageMainPanel:initSchedule()
    self:unscheduleUpdateEx()
    local stagePhase, lefttime = Data.getFamilyStagePhase()
    self:setLabelString("txt_stage_lefttime", gParserHourTime(lefttime))
    if lefttime > 0 then
        self:scheduleUpdate(function(dt)
            local stagePhaseUpdate, lefttimeUpdate = Data.getFamilyStagePhase()
            local strLefttime = gParserHourTime(lefttimeUpdate)
            self:setLabelString("txt_stage_lefttime", strLefttime)
            if lefttimeUpdate == 0 then
                self:unscheduleUpdateEx()
                -- TODO
            end
        end, 1)
    end
end

function FamilyStageMainPanel:getLeadStatus()
    local leadStatus = PROG_LEAD_NONE
    local selfLead = false
    local otherLead = false

    if gFamilyStageInfo.oppInfo.pro ~= nil then
        selfLead = gFamilyStageInfo.pro > gFamilyStageInfo.oppInfo.pro
        otherLead = gFamilyStageInfo.pro > gFamilyStageInfo.oppInfo.pro
    else
        selfLead = gFamilyStageInfo.pro > 0 
    end


    if selfLead then
        leadStatus = PROG_LEAD_SELF
    elseif otherLead then
        leadStatus = PROG_LEAD_OTHER
    else
        local selfProg = 0
        local otherProg = 0
        for _,value1 in pairs(gFamilyStageInfo.selfProLists) do
            selfProg = selfProg + value1
        end

        if gFamilyStageInfo.otherProLists ~= nil then
            for _,value2 in pairs(gFamilyStageInfo.otherProLists) do
                otherProg = otherProg + value2
            end
        end

        if selfProg > otherProg then
            leadStatus = PROG_LEAD_SELF
        elseif selfProg < otherProg then
            leadStatus = PROG_LEAD_OTHER
        end
    end

    return leadStatus
end

function FamilyStageMainPanel:refreshStageItemInfo()
    local size = self.stageScroll:getSize()
    for i = 1, size do
        local stageItem = self.stageScroll:getItem(i - 1)
        if nil ~= stageItem then
            stageItem:setTouchEnable("btn_go", not self.hasNoBuff, self.hasNoBuff)
        end
    end
end

function FamilyStageMainPanel:setBuffUpInfo()
        local curLv  = gFamilyStageInfo.buff.lv
        local curExp = gFamilyStageInfo.buff.exp
        local curBuffLvInfo = DB.getFamilyStageBuffLvInfo(curLv)
        local lastLvFullExp = 0
        local lastBuffLvInfo = DB.getFamilyStageBuffLvInfo(curLv - 1)
        if nil ~= lastBuffLvInfo then
            lastLvFullExp = lastBuffLvInfo.exp
        end
        local curRate = (curExp - lastLvFullExp) / (curBuffLvInfo.exp - lastLvFullExp)
        if curLv == DB.getFamilyStageBuffMaxLv() then
            self:setBarPer("bar_buff_up", 0)
            self:setLabelString("txt_buff_up", "MAX")
            self:getNode("txt_buff_up"):setColor(cc.c3b(255, 0, 0))
            self:setTouchEnable("layer_buff_up", false, true)
        else
            self:setBarPer("bar_buff_up", curRate)
            self:setLabelString("txt_buff_up", string.format("%d/%d",curExp - lastLvFullExp,curBuffLvInfo.exp - lastLvFullExp))
        end
        self:setLabelString("txt_buff_up_lv", curLv) 
end



return FamilyStageMainPanel