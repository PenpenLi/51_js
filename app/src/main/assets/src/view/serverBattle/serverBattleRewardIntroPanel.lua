local ServerBattleRewardIntroPanel=class("ServerBattleRewardIntroPanel",UILayer)

local SEASON_REWARD_TAG  = "btn_season_reward"
local SECTION_REWARD_TAG = "btn_section_reward"

function ServerBattleRewardIntroPanel:ctor()
    self:init("ui/ui_serverbattle_reward_intro.map")
    self.scrollLayer = self:getNode("scroll_reward")
    self.scrollLayer:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tag = ""
    self:selectBtn(SEASON_REWARD_TAG)
    self.sectionRewardInfo = nil
end

function ServerBattleRewardIntroPanel:events()
    return {

        }
end

function ServerBattleRewardIntroPanel:dealEvent(event, param)

end

function ServerBattleRewardIntroPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName==SEASON_REWARD_TAG or target.touchName==SECTION_REWARD_TAG then
        self:selectBtn(target.touchName)
    end
end

function ServerBattleRewardIntroPanel:selectBtn(tag)
    if self.tag == tag then
        return
    end
    self.tag = tag
    self:resetBtnTex()
    self:changeTexture(tag,"images/ui_public1/b_biaoqian4.png")
    self:setInfoByTag(tag)
end

function ServerBattleRewardIntroPanel:resetBtnTex()
    local btns={
        "btn_season_reward",
        "btn_section_reward",
    }

    for _, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function ServerBattleRewardIntroPanel:setInfoByTag(tag)
    if tag == SEASON_REWARD_TAG then
        self:getNode("panel_season_reward"):setVisible(true)
        self:getNode("panel_section_reward"):setVisible(false)
        self:setLabelString("season_reward_title", gGetWords("serverBattleWords.plist","season_reward_title"))
        self:showSeasonRewardInfo()
    elseif tag == SECTION_REWARD_TAG then
        self:getNode("panel_season_reward"):setVisible(false)
        self:getNode("panel_section_reward"):setVisible(true)
        self:showSectionRewardInfo()
    end
end

function ServerBattleRewardIntroPanel:showSeasonRewardInfo()
    --TODO
    local seasonReward = cjson.decode(gGetWords("serverBattleWords.plist","season_week_rew"))
    local count = #seasonReward
    local showIdx = 0
    for i = 1, count do
        local item = seasonReward[i]
        if item.num > 0 then
            showIdx = showIdx + 1
            local node=DropItem.new()
            node:setData(item.id)
            node:setNum(0)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon"..showIdx))
            self:setLabelString("lab_num"..showIdx, item.num)
            if showIdx > 1 then
                self:getNode("add"..showIdx):setVisible(true)
            end
        end
    end

    for i = showIdx + 1,4 do
        self:getNode("icon"..i):setVisible(false)
        self:getNode("add"..i):setVisible(false)
    end

    self:getNode("layout_reward"):layout()
end

function ServerBattleRewardIntroPanel:showSectionRewardInfo()
    --TODO,读取数据,lazyfun
    Scene.clearLazyFunc("section_reward_info")
    if self.sectionRewardInfo == nil then
        self.sectionRewardInfo = DB.getRewIntroOfServerBattle()
    end
    -- local list = {{secName="gold1",dayItems={{id=60,num=3},{id=61,num=3},{id=62,num=3}},secItems={{id=63,num=3},{id=64,num=3},{id=65,num=3}}},
    --               {secName="gold2",dayItems={{id=62,num=3},{id=63,num=3},{id=63,num=3}},secItems={{id=65,num=3},{id=67,num=3},{id=65,num=3}}}}
    self.scrollLayer:clear()
    local max_show = 4
    for i = 1, SERVER_BATTLE_DUAN16 do
        local minLv = DB.getServerBattleRangeSecLvByType(i)
        local rewards = DB.getRewIntroOfServerBattleByLv(minLv)
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

function ServerBattleRewardIntroPanel:onPopback()
    Scene.clearLazyFunc("section_reward_info")
end




return ServerBattleRewardIntroPanel