local MineAtlasDetailPanel=class("MineAtlasDetailPanel",UILayer)

function MineAtlasDetailPanel:ctor(mapid)
    self:init("ui/ui_mine_atlas_detail.map")
    self.mapId = mapid
    self.curType = 13
    self:setBg()
    self:setData()
    self:setProItem()
end

function MineAtlasDetailPanel:onTouchEnded(target, touch, event)
    if  target.touchName == "btn_close"then
        self:onClose()
        if Panel.getOpenPanel(PANEL_MINE_ATLAS) == nil then
            Panel.popUpVisible(PANEL_MINE_ATLAS,nil,nil,true)
        end
    elseif string.find(target.touchName,"pos1_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("pos1_") + 1))
        local stageInfo = gDigMine.stageInfos[pos]
        if stageInfo ~= nil then
            if stageInfo.stageId == gDigMine.stageId + 1 then
                Panel.popUpVisible(PANEL_MINE_DRAW_LOTS, self.mapId, stageInfo.stageId)
            end
        end
    elseif string.find(target.touchName,"pos2_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("pos2_") + 1))
        local stageInfo = gDigMine.stageInfos[pos]
        if stageInfo ~= nil then
            if stageInfo.stageId == gDigMine.stageId + 1 then
                Panel.popUpVisible(PANEL_MINE_DRAW_LOTS, self.mapId, stageInfo.stageId)
            end
        end
    elseif string.find(target.touchName,"pos3_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("pos3_") + 1))
        local stageInfo = gDigMine.stageInfos[pos]
        if stageInfo ~= nil then
            if stageInfo.stageId == gDigMine.stageId + 1 then
                Panel.popUpVisible(PANEL_MINE_DRAW_LOTS, self.mapId, stageInfo.stageId)
            end
        end
    elseif string.find(target.touchName,"pos4_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("pos4_") + 1))
        local stageInfo = gDigMine.stageInfos[pos]
        if stageInfo ~= nil then
            if stageInfo.stageId == gDigMine.stageId + 1 then
                Panel.popUpVisible(PANEL_MINE_DRAW_LOTS, self.mapId, stageInfo.stageId)
            end
        end
    elseif string.find(target.touchName,"box1_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("box1_") + 1))
        self:showBoxPanel(pos)
    elseif string.find(target.touchName,"box2_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("box2_") + 1))
        self:showBoxPanel(pos)
    elseif string.find(target.touchName,"box3_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("box3_") + 1))
        self:showBoxPanel(pos)
    elseif string.find(target.touchName,"box4_") ~= nil then
        local pos = toint(string.sub(target.touchName, string.len("box4_") + 1))
        self:showBoxPanel(pos)
    elseif target.touchName == "btn_full_reward" then
        Panel.popUpVisible(PANEL_MINE_ATLAS_BOX,self.mapId,4)
    end
end

function MineAtlasDetailPanel:setBg()
    local winSize = cc.Director:getInstance():getWinSizeInPixels()
    if gIsAndroid() then
        self:replaceNode("bg_container", cc.Sprite:create("images/ui_digmine/digmine_bg_s.png"))
        local containerSize = self:getNode("bg_container"):getContentSize()
        local scaleX = winSize.width/self:getNode("bg_container"):getContentSize().width
        local scaleY = winSize.height/self:getNode("bg_container"):getContentSize().height
        self.containerScale = math.max(scaleX,scaleY) + 0.1
        self:getNode("bg_container"):setScale( self.containerScale)
    else
        loadFlaXml("b007")
        local fla = gCreateFla("b007", 1)
        fla:getBone("bg7_bg_03"):getDisplayManager():setVisible(false)
        fla:getBone("bg7_bg_02"):getDisplayManager():setVisible(false)
        fla:getBone("bg7_01"):getDisplayManager():setVisible(false)
        fla:getBone("bg7_010"):getDisplayManager():setVisible(false)
        self:replaceNode("bg_container", fla)
    end
end

function MineAtlasDetailPanel:setData()
    local count = #gDigMine.stageInfos
    if count == 0 then
        return
    end

    local function  onCheckInsde(touch,event)
        return gCheck3DInsde(touch,event:getCurrentTarget())
    end

    self:getNode("layer_stages1"):setVisible(self.mapId == 1)
    self:getNode("layer_stages2"):setVisible(self.mapId == 2)
    self:getNode("layer_stages3"):setVisible(self.mapId == 3)
    self:getNode("layer_stages4"):setVisible(self.mapId == 4)

    local arrowIdx = 1 
    local stageInfo = nil
    local posNode = nil
    local panelStar = nil
    for i = 1,  count do
        if self:getNode(string.format("pos%d_%d",self.mapId, i)) == nil  then
            break
        end
        stageInfo = gDigMine.stageInfos[i]
        posNode = self:getNode(string.format("pos%d_%d",self.mapId, i))
        -- posNode.__isTouchInside = onCheckInsde
        -- posNode.__convertToWorldPos = gConvertTo3DWorldPos
        posNode.stagePos = i
        panelStar = self:getNode(string.format("panel_star%d_%d",self.mapId, i))

        if i <= gDigMine.stageId then
            if stageInfo.star > 0 then
                for j = 1, 3 do
                    local strKey = string.format("icon_star%d_%d_%d",self.mapId, i,j)
                    local starNode = self:getNode(strKey)
                    if j <= stageInfo.star and starNode ~= nil then
                        self:changeTexture(strKey,"images/ui_public1/star1.png")
                    end
                end
            end
            arrowIdx = arrowIdx + 1
            self:setTouchEnable(string.format("pos%d_%d",self.mapId, i), true, false)
        elseif i == gDigMine.stageId + 1 then
            self:getNode(string.format("panel_star%d_%d",self.mapId, i)):setVisible(true)
            self:setTouchEnable(string.format("pos%d_%d",self.mapId, i), true, false)
        else
            self:setTouchEnable(string.format("pos%d_%d",self.mapId, i), false, true)
            self:getNode(string.format("panel_star%d_%d",self.mapId, i)):setVisible(false)
        end
    end

    if arrowIdx <= count then
        self:setStageId(arrowIdx) 
    elseif arrowIdx > count then
        self:removeArrowFla()
    end

    self:setLabelString("txt_atlas_name", gGetWords("mineWords.plist","txt_atlas_name"..self.mapId))

    self:setBoxStatus()

    self:firstFullStarsShow()
end

function MineAtlasDetailPanel:setStageId(stageId)
    local node = nil
    if self.curArrowIdx ~= nil and self.curArrowIdx ~= stageId then
        node = self:getNode(string.format("pos%d_%d",self.mapId, self.curArrowIdx))
        node:removeChildByTag(99)
    end

    node = self:getNode(string.format("pos%d_%d",self.mapId, stageId))
    if nil ~= node then
        if node.stagePos == stageId then
            loadFlaXml("ui_atlas")
            local arrowFlash = FlashAni.new()
            node:addChild(arrowFlash)
            arrowFlash:setTag(99)
            arrowFlash:setPositionX(node:getContentSize().width / 2)
            arrowFlash:setPositionY(node:getContentSize().height / 8)
            arrowFlash:playAction("ui_atlas_arrow")
            self.curArrowIdx = stageId
        end
    end
end

function MineAtlasDetailPanel:setProItem()
    local proItems = DB.getMineAtlasProRewards(self.mapId)
    if nil == proItems then
        return
    end

    for key,value in pairs(proItems) do
        local item = DropItem.new()
        item:setScale(0.5)
        item:setData(value.id)
        item:setNum(0)
        item:setAnchorPoint(cc.p(0,-0.9))
        self:getNode("reward_icon"..key):addChild(item)
    end
end

function MineAtlasDetailPanel:showBoxPanel(step)
    if step == DETAIL_BOX_STEP2 then
        if (gDigMine.stageId < 6) then
            gShowNotice(gGetWords("mineWords.plist","txt_passed_six_stage"))
            return
        else
            Net.sendMiningEBoxInfo(self.mapId)
            return
        end
    elseif step == DETAIL_BOX_STEP3 then
        Panel.popUpVisible(PANEL_MINE_ATLAS_ENDBOX,self.mapId)
        return
    end
    Panel.popUpVisible(PANEL_MINE_ATLAS_BOX,self.mapId,step)
end

function MineAtlasDetailPanel:events()
    return { EVENT_ID_MINING_ATLAS_SWEEP,EVENT_ID_MINING_REFRESH_GETBOX }
end

function MineAtlasDetailPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_ATLAS_SWEEP then
        self:setData()
    elseif event == EVENT_ID_MINING_REFRESH_GETBOX then
        self:refreshBoxStatus(param)
    end
end

function MineAtlasDetailPanel:setBoxStatus()
    loadFlaXml("ui_wakuang")
    local boxStatus = gDigMine.detaiBoxStatus[1]
    local boxName = "fla_box"..self.mapId.."_1"
    if boxStatus == MINE_ATLAS_BOX_STATUS1 then
        self:getNode(boxName):playAction("ui_haidi_box_yin")
    elseif boxStatus == MINE_ATLAS_BOX_STATUS2 then
        self:getNode(boxName):playAction("ui_haidi_box_yin_a")
    else
        self:getNode(boxName):playAction("ui_haidi_box_yin_b")
    end

    boxStatus = gDigMine.detaiBoxStatus[3]
    boxName = "fla_box"..self.mapId.."_3"
    if boxStatus == MINE_ATLAS_BOX_STATUS1 then
        self:getNode(boxName):playAction("ui_haidi-box_jin")
    elseif boxStatus == MINE_ATLAS_BOX_STATUS2 then
        self:getNode(boxName):playAction("ui_haidi_box_jin_a")
    else
        self:getNode(boxName):playAction("ui_haidi_box_jin_b")
    end

    boxStatus = gDigMine.getPerfectBoxStatus(self.mapId)
    if boxStatus == MINE_ATLAS_BOX_STATUS2 then
        local flaFirstBox = gCreateFla("ui_fight_icontan_xiangzi",1)
        self:replaceNode("btn_full_reward",flaFirstBox)
        self:addTouchNode(flaFirstBox,"btn_full_reward")
    elseif boxStatus == MINE_ATLAS_BOX_STATUS1 then
        --DONOTHING
    else
        self:getNode("layer_first_full_stars"):setVisible(false)
    end

    boxStatus = gDigMine.detaiBoxStatus[2]
    boxName = "box"..self.mapId.."_2"
    if boxStatus == MINE_ATLAS_BOX_STATUS2 then
        local bgFla = gCreateFla("ui_wakuang_star", 1)
        gAddCenter(bgFla, self:getNode(boxName))
        bgFla:setTag(99)
    else
        self:getNode(boxName):removeChildByTag(99)
    end
end

function MineAtlasDetailPanel:firstFullStarsShow()
    local perfectInfo = gDigMine.perfectBoxInfos[self.mapId]
    if nil ~= perfectInfo and perfectInfo.status ~= 2 then
        self:getNode("layer_first_full_stars"):setVisible(true)
    else
        self:getNode("layer_first_full_stars"):setVisible(false)
    end
end

function MineAtlasDetailPanel:removeArrowFla()
    if self.curArrowIdx ~= nil then
        local node = self:getNode(string.format("pos%d_%d",self.mapId, self.curArrowIdx))
        node:removeChildByTag(99)
    end
end

function MineAtlasDetailPanel:refreshBoxStatus(step)
    if step == DETAIL_BOX_STEP1 or step == DETAIL_BOX_STEP3 or step == DETAIL_BOX_STEP2 then
        self:setBoxStatus()
    elseif step == DETAIL_BOX_STEP4 then
        local boxStatus = gDigMine.detaiBoxStatus[step]
        if boxStatus == MINE_ATLAS_BOX_STATUS3 then
            self:getNode("layer_first_full_stars"):setVisible(false)
        end
    end
end

return MineAtlasDetailPanel