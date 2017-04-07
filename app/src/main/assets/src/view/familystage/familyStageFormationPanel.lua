local FamilyStageFormationPanel=class("FamilyStageFormationPanel",UILayer)

function FamilyStageFormationPanel:ctor(stageId)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_family_stage_formation.map")
    self:initBuffScroll()
    self:initMonstFormation()
    self:setFightNum()
    -- self.buffIdx = -1
    self.stageId = stageId
end


function FamilyStageFormationPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_fight" then
        if self.buffIdx == -1 then
            gShowNotice(gGetWords("noticeWords.plist","family_stage_no_choose_buff"))
            return
        end

        if DB.getFamilyStageFightNum() == gFamilyStageInfo.fightNum then
            gShowNotice(gGetWords("noticeWords.plist","no_family_stage_fight_num"))
            return
        end

        local buffList = DB.getFamilyFightBuff()
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_FAMILY_STAGE,{stageId=self.stageId,buffId=buffList[self.buffIdx]})
    elseif target.touchName == "btn_hurt_rank" then
        Net.sendFamilyStageHarmRank(self.stageId)
    elseif target.touchName == "btn_lookup" then
        Net.sendFamilyStageFightList(self.stageId)
    end
end

function FamilyStageFormationPanel:events()
    return {
        EVENT_ID_FAMILY_STAGE_CHOOSE_BUFF,
    }
end

function FamilyStageFormationPanel:dealEvent(event, param)
    if event == EVENT_ID_FAMILY_STAGE_CHOOSE_BUFF then
        self:refreshBuffScroll(param)
    end
end

function FamilyStageFormationPanel:initBuffScroll()
    self.buffScroll = self:getNode("scroll")
    self.buffScroll.eachLineNum = 1
    self.buffScroll:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    local buffList = DB.getFamilyFightBuff()
    for i,buffid in ipairs(buffList) do
        local buffItem = FamilyStageBuffItem.new(buffid,i)
        self.buffScroll:addItem(buffItem)
    end
    self.buffScroll:layout()
    self:refreshBuffScroll({1, true})
end

function FamilyStageFormationPanel:initMonstFormation()
    for key, enemyItem in pairs(gFamilyStageInfo.monsters) do
        local node=UILayer.new()
        node:init("ui/ui_enemy_item.map")
        node.starContainerX= node:getNode("star_container"):getPositionX()
        node:setPositionY(node:getContentSize().height)
        self:getNode("card"..(key - 1)):addChild(node)
        if enemyItem.id ~= 0 then
            Icon.setMonsterIcon(enemyItem.id,node:getNode("icon"))
            local curHpRate = enemyItem.hp / enemyItem.thp
            self:setLabelString("txt_hp"..(key - 1), string.format("%0.2f%%", curHpRate*100))
            self:setBarPer("bar_hp"..(key - 1), curHpRate)
            if (curHpRate == 0) then
                gAddChildInCenterPos(self:getNode("card"..(key - 1)), cc.Sprite:create("images/ui_family/X.png"), 5)
                DisplayUtil.setGray(node)
            end
        else
            self:getNode("layer_bar"..(key - 1)):setVisible(false)
        end
        node:getNode("star_container"):setVisible(false)
    end
end

function FamilyStageFormationPanel:refreshBuffScroll(param)
    self.buffIdx = param[1]
    if not param[2] then
        self.buffIdx = -1
    end
    local size = self.buffScroll:getSize()
    for i = 1, size do
        local item = self.buffScroll:getItem(i - 1)
        if param[2] then
            item:changeTexByChoose(self.buffIdx == i)
        else
            item:changeTexByChoose(false)
        end
    end
end

function FamilyStageFormationPanel:setFightNum()
    local maxFightNum = DB.getFamilyStageFightNum()
    self:setLabelString("txt_fight_num", string.format("%d/%d", maxFightNum - gFamilyStageInfo.fightNum, maxFightNum))
    self:getNode("layout_fight_num"):layout()
end

return FamilyStageFormationPanel
