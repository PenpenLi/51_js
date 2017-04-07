local ServerBattleMatchRewardItem=class("ServerBattleMatchRewardItem",UILayer)

function ServerBattleMatchRewardItem:ctor(rank,name)
    self:init("ui/ui_serverbattle_rank_item2.map")
    self.groundName = name
    self:initPanel(rank)
end

function ServerBattleMatchRewardItem:initPanel(rank)
    Icon.changeHonorIcon(self:getNode("icon_honor"),rank)
    Icon.changeHonorWord(self:getNode("title_honor"),rank)

    local data = DB.getServerBattleMatchRewardByHonor(rank)
    if nil == data then
        return
    end

    local count = #data.items
    local showIdx = 0
    for i = 1, count  do
        local item = data.items[i]
        if item.num > 0 then
            showIdx = showIdx + 1
            self:getNode("icon_ground"..showIdx):setVisible(true)
            local node = DropItem.new()
            node:setData(item.id)
            node:setNum(item.num)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon_ground"..showIdx))
        end
    end

    for i = showIdx + 1,3 do
        self:getNode("icon_ground"..i):setVisible(false)
    end
    self:getNode("layout_ground_reward"):layout()
    local rangeWords = gGetWords("serverBattleWords.plist","txt_rank_"..self.groundName..data.rank)
    self:setLabelString("txt_rank_rew_title", gGetWords("serverBattleWords.plist","txt_rank_rew_titie",rangeWords))
end

return ServerBattleMatchRewardItem