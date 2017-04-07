local ServerBattleRankPanel=class("ServerBattleRankPanel",UILayer)

function ServerBattleRankPanel:ctor(showKingFight)
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_serverbattle_rank.map")
    self.scrollLayer = self:getNode("scroll_rank")
    if showKingFight then
        self:getNode("btn_king_rank"):setVisible(false)
        self:getNode("btn_king_fight"):setVisible(false)
        self:showKingFight()
        self:getNode("layout_my_rank"):setVisible(false)
    else
        self:selectBtn("btn_king_rank")
        self:getNode("layout_my_rank"):setVisible(true)
        self:showKingRank()
    end
    self:getNode("scroll_ground").eachLineNum = 1
    self:getNode("scroll_ground"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll_sky").eachLineNum = 1
    self:getNode("scroll_sky"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)

end

function ServerBattleRankPanel:events()
    return {

        }
end

function ServerBattleRankPanel:dealEvent(event, param)

end

function ServerBattleRankPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_king_rank" then
        self:selectBtn("btn_king_rank")
        self:showKingRank()
    elseif target.touchName=="btn_king_fight" then
        self:selectBtn("btn_king_fight")
        self:showKingFight()
    end
end

function ServerBattleRankPanel:updateScrollLayer(list)
--    self.scrollLayer:clear()
--    for key,value in ipairs(list) do
--        local item = self:createRankItem(value,key)
--        self.scrollLayer:addItem(item)
--    end
--    self.scrollLayer:layout()
end

function ServerBattleRankPanel:createRankItem(value,idx)
    local item = ServerBattleRankItem.new(value,idx)
    item.selectItemCallback=function (data,idx)
        -- self:onApp(data,idx);
    end
    return item
end

function ServerBattleRankPanel:selectBtn(name)
    self:resetBtnTex()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function ServerBattleRankPanel:resetBtnTex()
    local btns={
        "btn_king_rank",
        "btn_king_fight",
    }

    for _, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function ServerBattleRankPanel:showKingRank()
    Scene.clearLazyFunc("serverbattlerankitem")
    self:getNode("panel_king_rank"):setVisible(true)
    self:getNode("panel_king_fight"):setVisible(false)

    -- --TODO
    -- for i = 1,10 do
    --     local kingRankInfo = {}
    --     kingRankInfo.uid = 1111111
    --     kingRankInfo.uname = "xxxx"..i
    --     kingRankInfo.sname = "adafasf"..i
    --     if i ~= 5 and i ~= 8 then
    --         kingRankInfo.fname = "familyid"..i
    --     end
    --     kingRankInfo.icon  = 10001 + i
    --     kingRankInfo.level = 10
    --     kingRankInfo.vip   = 4
    --     kingRankInfo.power = 12132332
    --     kingRankInfo.rank  = i
    --     gServerBattle.addKingRanks(kingRankInfo)
    -- end

    self.scrollLayer:clear()
    local count = #gServerBattle.kingRanks
    if count == 0 then
        self:getNode("scroll_rank"):setVisible(false)
        self:getNode("layer_null"):setVisible(true)
        self:getNode("layout_my_rank"):setVisible(false)
        return
    end

    self:getNode("scroll_rank"):setVisible(true)
    self:getNode("layer_null"):setVisible(false)
    self:getNode("layout_my_rank"):setVisible(true)
    for i=1,#gServerBattle.kingRanks do
        local rankInfo = gServerBattle.kingRanks[i]
        local item = ServerBattleRankItem.new()

        if(i < 8)then
            item:setData(rankInfo)
        else
            item:setLazyData(rankInfo)
        end
        self.scrollLayer:addItem(item)
    end
    self.scrollLayer:layout()

    self:setMyRankInfo()
end

function ServerBattleRankPanel:showKingFight()
    self:getNode("panel_king_rank"):setVisible(false)
    self:getNode("panel_king_fight"):setVisible(true)

    self:getNode("scroll_ground"):clear()
    self:getNode("scroll_sky"):clear()

    for i = 1, 5 do
        local item = ServerBattleMatchRewardItem.new(i,"sky")
        self:getNode("scroll_sky"):addItem(item)
    end

    for i = 6, 9 do
        local item = ServerBattleMatchRewardItem.new(i,"ground")
        self:getNode("scroll_ground"):addItem(item)
    end

    self:getNode("scroll_ground"):layout()
    self:getNode("scroll_sky"):layout()

    -- local groundReward = DB.getServerBattleMatchReward(KING_RANK_GROUND,1)
    -- local count = #groundReward.items
    -- local showIdx = 0
    -- for i = 1, count  do
    --     local item = groundReward.items[i]
    --     if item.num > 0 then
    --         showIdx = showIdx + 1
    --         self:getNode("icon_ground"..showIdx):setVisible(true)
    --         local node = DropItem.new()
    --         node:setData(item.id)
    --         node:setNum(0)
    --         node:setPositionY(node:getContentSize().height)
    --         gAddMapCenter(node, self:getNode("icon_ground"..showIdx))
    --         self:setLabelString("txt_ground_num"..showIdx, item.num)
    --     end
    -- end

    -- for i = showIdx + 1,4 do
    --     self:getNode("icon_ground"..i):setVisible(false)
    -- end
    -- self:getNode("layout_ground_reward"):layout()

    -- local skyReward    = DB.getServerBattleMatchReward(KING_RANK_SKY,1)
    -- count = #skyReward.items
    -- showIdx = 0

    -- for i = 1, count  do
    --     local item = skyReward.items[i]
    --     if item.num > 0 then
    --         showIdx = showIdx + 1
    --         self:getNode("icon_sky"..showIdx):setVisible(true)
    --         local node = DropItem.new()
    --         node:setData(item.id)
    --         node:setNum(0)
    --         node:setPositionY(node:getContentSize().height)
    --         gAddMapCenter(node, self:getNode("icon_sky"..showIdx))
    --         self:setLabelString("txt_sky_num"..showIdx, item.num)
    --     end
    -- end

    -- for i = showIdx + 1,4 do
    --     self:getNode("icon_sky"..i):setVisible(false)
    -- end
    -- self:getNode("layout_sky_reward"):layout()
end

function ServerBattleRankPanel:onPopback()
    Scene.clearLazyFunc("serverbattlerankitem")
end

function ServerBattleRankPanel:setMyRankInfo()
    if gServerBattle.kingRank > 0 then
        self:setLabelString("txt_rank", gServerBattle.kingRank)
    else
        local noRankTxt = gGetWords("serverBattleWords.plist","no_rank")
        self:setLabelString("txt_rank", noRankTxt)
    end
    self:getNode("layout_my_rank"):layout()
end
return ServerBattleRankPanel