local ServerBattleRewardPanel=class("ServerBattleRewardPanel",UILayer)

function ServerBattleRewardPanel:ctor()
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_serverbattle_reward.map")
    self.scrollLayer = self:getNode("scroll_next_all")
    self:getNode("scroll_next_all").eachLineNum = 1
    self:getNode("scroll_next_all"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:initDetail()
end

function ServerBattleRewardPanel:events()
    return {

        }
end

function ServerBattleRewardPanel:dealEvent(event, param)

end

function ServerBattleRewardPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    end
end

function ServerBattleRewardPanel:initDetail()
    -- gServerBattle.sectionLv   = 52 --段位等级
    -- gServerBattle.kingRank  = 0 --王者排名

    if gServerBattle.sectionLv == 0 then
        self:getNode("panel_cur_sec_lv"):setVisible(false)
        self:getNode("scroll_next_all"):setVisible(false)
    else
        local txtSectionName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
        -- local sectionType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)
        if (gServerBattle.kingRank>0 and gServerBattle.kingRank<=32) then
            gServerBattle.sectionLv = 53
            local rank = DB.getWorldRankIndex(gServerBattle.kingRank) + 1000
            txtSectionName = gGetWords("serverBattleWords.plist","reward_rank"..rank);
        end
        self:setLabelString("txt_sec_name", txtSectionName)
        Icon.setSecOfSeverBattle(self:getNode("icon_section"),gServerBattle.sectionLv)
        local sectionType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)
        if (gServerBattle.kingRank>0) then
            -- gServerBattle.sectionLv = 17
            -- SERVER_BATTLE_DUAN17 = 17 --王者32-11
            -- SERVER_BATTLE_DUAN18 = 18 --王者10-4
            -- SERVER_BATTLE_DUAN19 = 19 --王者3
            -- SERVER_BATTLE_DUAN20 = 20 --王者2
            -- SERVER_BATTLE_DUAN21 = 21 --王者1
            if (gServerBattle.kingRank>=11 and gServerBattle.kingRank<=32) then
                sectionType = SERVER_BATTLE_DUAN17
            elseif (gServerBattle.kingRank>=4 and gServerBattle.kingRank<=10) then
                sectionType = SERVER_BATTLE_DUAN18
            elseif (gServerBattle.kingRank==3) then
                sectionType = SERVER_BATTLE_DUAN19
            elseif (gServerBattle.kingRank==2) then
                sectionType = SERVER_BATTLE_DUAN20
            elseif (gServerBattle.kingRank==1) then
                sectionType = SERVER_BATTLE_DUAN21
            end
        end
        self:setCurSectionDaysAndWeeks(sectionType)
        self:setScrollLayerInfo(sectionType)
    end
end

function ServerBattleRewardPanel:setCurSectionDaysAndWeeks(sectionType)
    -- print("---------lv=="..lv)
    local minLv = DB.getServerBattleRangeSecLvByType(sectionType)
    local rewards = DB.getRewIntroOfServerBattleByLv(minLv)
    if (sectionType >= SERVER_BATTLE_DUAN17) then
        local rank = 0
        if (sectionType == SERVER_BATTLE_DUAN17) then
            rank = 11
        elseif (sectionType == SERVER_BATTLE_DUAN18) then
            rank = 4
        elseif (sectionType == SERVER_BATTLE_DUAN19) then
            rank = 3
        elseif (sectionType == SERVER_BATTLE_DUAN20) then
            rank = 2
        elseif (sectionType == SERVER_BATTLE_DUAN21) then
            rank = 1
        end
        rewards = DB.getWorldRankReByRank(rank)
    end

    local count = #rewards.dayrews
    local showIdx = 0

    for i = 1, count  do
        local item = rewards.dayrews[i]
        if item.num > 0 then
            showIdx = showIdx + 1
            self:getNode("day_icon"..showIdx):setVisible(true)
            local node = DropItem.new()
            node:setData(item.id)
            node:setNum(item.num)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("day_icon"..showIdx))
            -- self:setLabelString("day_icon"..showIdx, item.num)
        end
    end

    for i = showIdx + 1,5 do
        self:getNode("day_icon"..i):setVisible(false)
    end
    self:getNode("layout_day"):layout()

    count = #rewards.weekrews
    showIdx = 0
    for i = 1, count do
            -- self:getNode("sec_icon"..i):setVisible(false)
        local item = rewards.weekrews[i]
        if item.num > 0 then
            showIdx = showIdx + 1
            self:getNode("sec_icon"..showIdx):setVisible(true)
            local node = DropItem.new()
            node:setData(item.id)
            node:setNum(item.num)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("sec_icon"..showIdx))
            -- self:setLabelString("sec_icon"..showIdx, item.num)
        end
    end

    for i = showIdx + 1,5 do
        self:getNode("sec_icon"..i):setVisible(false)
    end

    self:getNode("layout_week"):layout()
end

function ServerBattleRewardPanel:setScrollLayerInfo(sectionType)
    self:getNode("scroll_next_all"):clear()
    local max_show = sectionType + 3
    for i = sectionType + 1, SERVER_BATTLE_DUAN21 do
        local minLv = DB.getServerBattleRangeSecLvByType(i)
        local rewards = DB.getRewIntroOfServerBattleByLv(minLv)
        
        if (i>=SERVER_BATTLE_DUAN17) then
            local rank = 0
            if (i == SERVER_BATTLE_DUAN17) then
                rank = 11
            elseif (i == SERVER_BATTLE_DUAN18) then
                rank = 4
            elseif (i == SERVER_BATTLE_DUAN19) then
                rank = 3
            elseif (i == SERVER_BATTLE_DUAN20) then
                rank = 2
            elseif (i == SERVER_BATTLE_DUAN21) then
                rank = 1
            end
            rewards = DB.getWorldRankReByRank(rank)
        end

        local rewardItem = ServerBattleSecRewardItem.new()
        if i <= max_show then
            rewardItem:setData(rewards)
        else
            rewardItem:setLazyData(rewards)
        end
        self.scrollLayer:addItem(rewardItem)
    end
    self.scrollLayer:layout()
end

return ServerBattleRewardPanel