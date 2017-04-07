local MineAtlasEndBoxPanel=class("MineAtlasEndBoxPanel",UILayer)

function MineAtlasEndBoxPanel:ctor(mapId)
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_mine_atlas_endbox.map")
    self.mapId = mapId
    self:initPanle()
end

function MineAtlasEndBoxPanel:onTouchEnded(target, touch, event)
    if  target.touchName == "btn_close"then
        self:onClose()
    elseif target.touchName == "btn_get1" or 
           target.touchName == "btn_get2" or 
           target.touchName == "btn_get3" then

        local boxStep = toint(string.sub(target.touchName, string.len("btn_get") + 1))
        if gDigMine.canOpenAtalsBBox(boxStep) then
            Net.sendMiningGetBBox(self.mapId)
            self:onClose()
        end
    end
end

function MineAtlasEndBoxPanel:initPanle()
    local curStars = gDigMine.getStars(self.mapId)
    self:setLabelString("txt_cur_stars", curStars)
    self:getNode("layout_cur_stars"):layout()

    local rewardItems = {}
    for i = 1, 3 do
        rewardItems = DB.getMineAtlasEndBoxReward(self.mapId , i * 10)
        for j = 1, #rewardItems do
            local node = self:getNode(string.format("item%d_%d",i,j))
            node:setVisible(true) 
            local dropNode = DropItem.new()
            dropNode:setData(rewardItems[j].id) 
            dropNode:setNum(rewardItems[j].num)   
            dropNode:setPositionY(node:getContentSize().height)
            node:addChild(dropNode)
        end

        for j = #rewardItems + 1, 4 do
            self:getNode(string.format("item%d_%d",i,j)):setVisible(false)
        end

        self:getNode("layout_items"..i):layout()
    end
    --math.ceil
    local boxStatus = gDigMine.detaiBoxStatus[DETAIL_BOX_STEP3]
    local idx = 0
    if curStars >= 10 and curStars <= 19 then
        idx = 1
    elseif curStars >= 20 and curStars <= 29 then
        idx = 2
    elseif curStars == 30 then
        idx = 3
    end
    for i = 1, 3 do
        if idx == i then
            -- self:getNode("cur_flag"..i):setVisible(true)
            if boxStatus == MINE_ATLAS_BOX_STATUS3 then
                self:setLabelString("txt_get"..i, gGetWords("btnWords.plist", "btn_reward_got"))
                self:setTouchEnable("btn_get"..i,false,true)
            elseif boxStatus == MINE_ATLAS_BOX_STATUS2 then
                self:setTouchEnable("btn_get"..i,true,false)
            else
                self:setTouchEnable("btn_get"..i,false,true)
            end 
        else
            -- self:getNode("cur_flag"..i):setVisible(false)
            self:setTouchEnable("btn_get"..i,false,true)
        end   
    end
end


return MineAtlasEndBoxPanel