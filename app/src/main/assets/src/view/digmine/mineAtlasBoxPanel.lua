local MineAtlasBoxPanel=class("MineAtlasBoxPanel",UILayer)

function MineAtlasBoxPanel:ctor(mapId,step)
    self.isMainLayerMenuShow = false
    if step == DETAIL_BOX_STEP2 then
        self.isMainLayerGoldShow = true
    else
        self.isMainLayerGoldShow = false
    end
    self:init("ui/ui_mine_atlas_box.map")
    self.mapId = mapId
    self.step   = step
    self:initPanle()
end

function MineAtlasBoxPanel:onTouchEnded(target, touch, event)
    if  target.touchName == "btn_close"then
        self:onClose()
    elseif target.touchName == "btn_get" then

        if self.step == DETAIL_BOX_STEP1 and gDigMine.detaiBoxStatus[DETAIL_BOX_STEP1] == MINE_ATLAS_BOX_STATUS2 then
            Net.sendMiningGetSBox(self.mapId)
        elseif self.step == DETAIL_BOX_STEP4 and gDigMine.detaiBoxStatus[DETAIL_BOX_STEP4] == MINE_ATLAS_BOX_STATUS2 then
            Net.sendMiningGetFBox(self.mapId)
        end
        self:onClose()
    elseif target.touchName == "btn_buy_box" then
        if gDigMine.detaiBoxStatus[DETAIL_BOX_STEP2] == MINE_ATLAS_BOX_STATUS2 and NetErr.isDiamondEnough(gDigMine.mineAtlasEventBox.dia) then
            Net.sendMiningEBoxBuy(self.mapId)
            self:onClose()
        end
    elseif string.find(target.touchName,"btn_bbox") ~= nil then
        local boxStep = toint(string.sub(target.touchName, string.len("btn_bbox") + 1))
        if gDigMine.canOpenAtalsBBox(boxStep) then
            Net.sendMiningGetBBox(self.mapId)
            self:onClose()
        end
    end
end

function MineAtlasBoxPanel:initPanle()
    if self.step ~= DETAIL_BOX_STEP3 then
        self:getNode("layer_box_get"):setVisible(true)
        self:getNode("layer_final_box"):setVisible(false)
        self:showGetOrBuy()
    else
        self:getNode("layer_box_get"):setVisible(false)
        self:getNode("layer_final_box"):setVisible(true)
        self:setFinalBox()
    end

    self:setRewardItem()
end

function MineAtlasBoxPanel:showGetOrBuy()

    self:getNode("layer_buy_box"):setVisible(self.step == DETAIL_BOX_STEP2)
    self:getNode("btn_get"):setVisible(self.step ~= DETAIL_BOX_STEP2)
    self:getNode("txt_need_num"):setVisible(self.step == DETAIL_BOX_STEP1)
    self:getNode("layout_history"):setVisible(self.step == DETAIL_BOX_STEP4)
    self:getNode("txt_first_reward"):setVisible(self.step == DETAIL_BOX_STEP4)
    self:getNode("txt_box2_title"):setVisible(self.step == DETAIL_BOX_STEP2)

    local stars = gDigMine.getStars(self.mapId)
    if self.step == DETAIL_BOX_STEP4 then
        stars = gDigMine.getPerfectBoxStars(self.mapId)
        gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP4, gDigMine.getPerfectBoxStatus(self.mapId))
    end

    -- if stars == MAX_PERFECT_STAR and gDigMine.detaiBoxStatus[DETAIL_BOX_STEP4] == MINE_ATLAS_BOX_STATUS1 then
    --     gDigMine.setDetailBoxStatus(DETAIL_BOX_STEP4, MINE_ATLAS_BOX_STATUS2)
    -- end

    local status = gDigMine.detaiBoxStatus[self.step]
    if self.step == DETAIL_BOX_STEP1 or self.step == DETAIL_BOX_STEP4 then
        if  status == MINE_ATLAS_BOX_STATUS1 or status == MINE_ATLAS_BOX_STATUS3 then
            self:setTouchEnable("btn_get",false,true)
            if status == MINE_ATLAS_BOX_STATUS3 then
                self:setLabelString("txt_get", gGetWords("btnWords.plist", "btn_reward_got"))
            end            
        end
    elseif self.step == DETAIL_BOX_STEP2 then --TOCHECK
        if status == MINE_ATLAS_BOX_STATUS1 or status == MINE_ATLAS_BOX_STATUS3 then
            self:setTouchEnable("btn_buy_box",false,true)
        end
    end

    if self.step == DETAIL_BOX_STEP4 then
        local strStars = string.format("%d/%d",stars, MAX_PERFECT_STAR)
        self:setLabelString("txt_history_star",strStars)
        self:getNode("layout_history"):layout()
    end
end

function MineAtlasBoxPanel:setRewardItem()
    if self.step == DETAIL_BOX_STEP1 then
        local rewards = DB.getMineAtlasBoxRewards(self.mapId,self.step)
        if nil ~= rewards then
            for idx, reward in pairs(rewards) do
                self:getNode("reward"..idx):setVisible(true) 
                local node=DropItem.new()
                node:setData(reward.id) 
                node:setNum(reward.num)   
                
                node:setPositionY(node:getContentSize().height)
                self:getNode("reward"..idx):addChild(node)
            end
        end
    elseif self.step == DETAIL_BOX_STEP4 then
        local rewards = DB.getMineAtlasFullRewards(self.mapId,self.step)
        if nil ~= rewards then
            for idx, reward in pairs(rewards) do
                self:getNode("reward"..idx):setVisible(true) 
                local node=DropItem.new()
                node:setData(reward.id) 
                node:setNum(reward.num)   
                
                node:setPositionY(node:getContentSize().height)
                self:getNode("reward"..idx):addChild(node)
            end
        end
    elseif self.step == DETAIL_BOX_STEP2 then
        local itemIdx = 0
        for idx, reward in pairs(gDigMine.mineAtlasEventBox.items) do
            if reward.id ~= 0 then
                self:getNode("reward"..idx):setVisible(true) 
                local node=DropItem.new()
                node:setData(reward.id) 
                node:setNum(reward.num)
                node:setPositionY(node:getContentSize().height)
                self:getNode("reward"..idx):addChild(node)
                itemIdx = itemIdx + 1
            end
        end

        for i = itemIdx + 1,4 do
            self:getNode("reward"..i):setVisible(false)
        end

        self:getNode("layout_reward"):layout()

        self:setLabelString("txt_event_box_dia", gGetWords("mineWords.plist", "txt_buy_box_dia",gDigMine.mineAtlasEventBox.dia))
    end
end

function MineAtlasBoxPanel:setFinalBox()
    local curStars = gDigMine.getStars(gDigMine.mapId)
    self:setLabelString("txt_cur_stars", curStars)
    self:getNode("layout_cur_stars"):layout()
    local posRate = curStars / MAX_PERFECT_STAR
    local posX,posY = self:getNode("flag_cur_stars"):getPosition()
    local contentSize = self:getNode("bar"):getContentSize()
    if posRate == 0 then
        posX = contentSize.width * 0.05
    elseif posRate == 1 then
        posX = contentSize.width * 0.95
    else
        posX = contentSize.width * posRate
    end
    self:getNode("flag_cur_stars"):setPosition(posX, posY)
    local boxStatus = gDigMine.detaiBoxStatus[DETAIL_BOX_STEP3]
    local idx = math.floor(curStars / (MAX_PERFECT_STAR/3))
    loadFlaXml("ui_atlas")
    for i=1, 3 do
        if i ~= idx then
            self:getNode("btn_bbox"..i):playAction("ui_atlas_box_1")
        else
            if boxStatus == 2 then
                self:getNode("btn_bbox"..i):playAction("ui_atlas_box_3")
            else
                self:getNode("btn_bbox"..i):playAction("ui_atlas_box_2")
            end
        end
    end
end

return MineAtlasBoxPanel