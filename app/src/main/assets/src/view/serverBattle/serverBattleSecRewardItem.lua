local ServerBattleSecRewardItem=class("ServerBattleSecRewardItem",UILayer)

function ServerBattleSecRewardItem:ctor()
        
end

function ServerBattleSecRewardItem:setData(data)
    self:init("ui/ui_serverbattle_section_reward_item.map")
    local sectionName = DB.getServerBattleSecNameByLv(data.secLv)
    if (data.secLv>1000) then
        sectionName = gGetWords("serverBattleWords.plist","reward_rank"..data.secLv);
    end
    self:setLabelString("txt_sec_name", sectionName)
    local count = #data.dayrews
    local showIdx = 0
    Icon.setSecOfSeverBattle(self:getNode("icon_section"),data.secLv)
    for i = 1, count  do
        local item = data.dayrews[i]
        if item.num > 0 then
            showIdx = showIdx + 1
            self:getNode("day_icon"..showIdx):setVisible(true)
            local node = DropItem.new()
            node:setData(item.id)
            node:setNum(item.num)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("day_icon"..showIdx))
            -- self:setLabelString("day_num"..showIdx, item.num)
        end
    end

    for i = showIdx + 1,4 do
        self:getNode("day_icon"..i):setVisible(false)
    end
    self:getNode("layout_day"):layout()

    count = #data.weekrews
    showIdx = 0
    for i = 1, count do
            -- self:getNode("sec_icon"..i):setVisible(false)
        local item = data.weekrews[i]
        if item.num > 0 then
            showIdx = showIdx + 1
            self:getNode("sec_icon"..showIdx):setVisible(true)
            local node = DropItem.new()
            node:setData(item.id)
            node:setNum(item.num)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("sec_icon"..showIdx))
            -- self:setLabelString("sec_num"..showIdx, item.num)
        end
    end

    for i = showIdx + 1,4 do
        self:getNode("sec_icon"..i):setVisible(false)
    end

    self:getNode("layout_week"):layout()
end

function  ServerBattleSecRewardItem:setLazyData(data)
    self.lazyData=data
    Scene.addLazyFunc(self,function()
        if self ~= nil and self.setData ~= nil then
            self:setData(self.lazyData)
        end
    end,"section_reward_info")
end

return ServerBattleSecRewardItem