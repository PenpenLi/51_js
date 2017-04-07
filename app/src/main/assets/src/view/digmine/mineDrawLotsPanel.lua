local MineDrawLotsPanel=class("MineDrawLotsPanel",UILayer)

function MineDrawLotsPanel:ctor(mapId, stageId)
    self.isMainLayerMenuShow = false
    self:init("ui/ui_mine_draw_lots.map")
    self.isDrawing = false
    self.mapId = mapId
    self.stageId = stageId
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnterLayer()
        elseif event == "exit" then
            self:onUILayerExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
    self:initLabelInfo()
    self:setAutoBtnStatus()
end

function MineDrawLotsPanel:onTouchEnded(target, touch, event)
    if self.isDrawing then
        return
    end

    if  target.touchName == "btn_close"then
        self:onClose()
    elseif target.touchName == "btn_enter"then
        if gDigMine.drawLotsIdx == 0 then
            gShowNotice(gGetWords("mineWords.plist", "txt_draw_lot_first"))
            return
        end

        if self:isMinePicxLim() then
            return
        end

        gDigMine.checkMineAtlasTeam()

        if gDigMine.drawLotsIdx == MINE_ATLAS_DRAW_LOT_RET7 then
            Net.sendMiningChapterSweep(self.mapId, self.stageId)
            self:onClose()
        else
            local formationData = {mapId = self.mapId, stageId = self.stageId}
            Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ATLAS_MINING, formationData)
        end
    elseif target.touchName == "fla_draw_lots" then
        if gDigMine.drawLotsIdx == 0 then
            Net.sendChapDraw(self.mapId, self.stageId)
        end
    elseif target.touchName == "btn_auto" then
        local formation = Data.getUserTeam(TEAM_TYPE_ATLAS_MINING)
        if table.count(formation) == 0 then
            gDigMine.checkMineAtlasTeam()
            formation = Data.getUserTeam(TEAM_TYPE_ATLAS)
        end
        local curPower = CardPro.countFormation(formation,TEAM_TYPE_ATLAS_MINING)
        if curPower >= self.power then
            if self:isMinePicxLim() then
                return
            end
            Net.sendMiningChapterSweep(self.mapId, self.stageId)
            self:onClose()
        else
            gShowNotice(gGetWords("mineWords.plist","txt_atlas_power_limit"))
        end
    end
end

function MineDrawLotsPanel:setDrawing(flag)
    self.isDrawing = flag
end

function MineDrawLotsPanel:onEnterLayer()
    if gDigMine.drawLotsIdx == 0 then
        -- cc.Device:setAccelerometerEnabled(true)

        -- local function accelerometerListener(event,x,y,z,timestamp)
        --     if self.isDrawing then
        --         return
        --     end

        --     if math.abs(x) > 2 or math.abs(y) > 2 or math.abs(z) > 2 then
        --         self.isDrawing = true
        --         local rotaion1 = cc.RotateBy:create(0.05, 30)
        --         local rotaion2 = rotaion1:reverse()
        --         local  action = cc.Sequence:create( rotaion1, rotaion2); 
        --         self:getNode("fla_draw_lots"):runAction( cc.RepeatForever:create(action))
        --         Net.sendChapDraw(self.mapId, self.stageId)
        --     end
        -- end

        -- local listerner  = cc.EventListenerAcceleration:create(accelerometerListener)
        -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self)
    end
end

function MineDrawLotsPanel:onUILayerExit()
   if nil ~= self.super then
       self.super:onUILayerExit()
   end

   cc.Device:setAccelerometerEnabled(false)
end

function MineDrawLotsPanel:events()
    return { EVENT_ID_MINING_DRAW_LOTS}
end

function MineDrawLotsPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_DRAW_LOTS then
        self:getNode("txt_draw_tip"):setVisible(false)
        self:getNode("fla_draw_lots"):stopAllActions()
        local flaName = gDigMine.getDrawLotsFlaByIdx()
        if "" ~= flaName then
           self:processDrawLotsResult(flaName)
           self:showGreenProFla()
        end
        -- self:showDrawLotsResult()
    end
end

function MineDrawLotsPanel:processDrawLotsResult(flaName)
    loadFlaXml("ui_haidan")
    self:getNode("fla_draw_lots"):playAction(flaName,function()
        self:getNode("fla_draw_lots"):stopAni()
        local action = cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,-20)),cc.MoveBy:create(1.5,cc.p(0,20)))
        self:getNode("fla_draw_lots"):runAction(cc.RepeatForever:create(action))
    end,nil,1)
end

function MineDrawLotsPanel:showDrawLotsResult()
    self:setLabelString("txt_draw_result", DB.getMineStageDrawDesc(gDigMine.drawLotsIdx))
    self:getNode("txt_draw_result"):setVisible(true)
    self:getNode("txt_draw_ret_tip"):setVisible(true)
end

function MineDrawLotsPanel:showGreenProFla()
    local fla = gCreateFla("ui_handan_lvguang")
    gAddCenter(fla, self:getNode("layer_result_display"))
    local delay1 = cc.DelayTime:create(0.3)
    local callFunc = cc.CallFunc:create(function()
        self:showDrawLotsResult()
    end)
    self:runAction(cc.Sequence:create(delay1,callFunc))
end

function MineDrawLotsPanel:initLabelInfo( )
    self.curStage = DB.getStageById(self.mapId, self.stageId,13)
    gDigMine.atlasRets = {}
    gDigMine.atlasRets.types = string.split(self.curStage.first_reward,";")
    for i = 1, #gDigMine.atlasRets.types do
        gDigMine.atlasRets.types[i] = toint(gDigMine.atlasRets.types[i])
    end

    gDigMine.atlasRets.values = string.split(self.curStage.first_reward_number,";")
    for i = 1, #gDigMine.atlasRets.values do
        gDigMine.atlasRets.values[i] = toint(gDigMine.atlasRets.values[i])
    end
    local desc = ""
    for i = 1, #gDigMine.atlasRets.types do
        desc  = gDigMine.getDrawLotDesc(toint(gDigMine.atlasRets.types[i]),toint(gDigMine.atlasRets.values[i]))
        self:setLabelString("txt_result"..i, desc)
    end

    self:setLabelString("txt_mine_picx_value", self.curStage.energy)
    self:getNode("layout_mine_picx_value"):layout()

    self.power = self.curStage.power
    self:setLabelString("txt_power", self.power)
    self:getNode("layout_power"):layout()
    if gDigMine.drawLotsIdx > 0 then
        self:getNode("txt_draw_tip"):setVisible(false)
        self:setLabelString("txt_draw_result", DB.getMineStageDrawDesc(gDigMine.drawLotsIdx))
        self:getNode("txt_draw_result"):setVisible(true)
        self:getNode("txt_draw_ret_tip"):setVisible(true)
        gDigMine.mapId = self.mapId
        local flaName = gDigMine.getDrawLotsFlaByIdx()
        if "" ~= flaName then
            self:processDrawLotsResult(flaName)
        end
    else
        self:getNode("txt_draw_tip"):setVisible(true)
        self:getNode("txt_draw_result"):setVisible(false)
        self:getNode("txt_draw_ret_tip"):setVisible(false)
    end

    local mapName = gGetWords("mineWords.plist","txt_atlas_name"..self.mapId)
    mapName = mapName .. "-"..self.stageId
    self:setLabelString("txt_atlas_name", mapName)
end

function MineDrawLotsPanel:isMinePicxLim()
    if self.curStage.energy > gDigMine.mpt then
        gConfirmCancel(gGetWords("labelWords.plist","lab_pickax_num_limit"), function()
            Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
        end)
        return true
    end
    return false
end

function MineDrawLotsPanel:setAutoBtnStatus()
    local formation = Data.getUserTeam(TEAM_TYPE_ATLAS_MINING)
    if table.count(formation) == 0 then
        gDigMine.checkMineAtlasTeam()
        formation = Data.getUserTeam(TEAM_TYPE_ATLAS)
    end
    local curPower = CardPro.countFormation(formation,TEAM_TYPE_ATLAS_MINING)
    if  curPower < self.power then
        self:setTouchEnableGray("btn_auto", false)
        self:getNode("txt_power"):setColor(cc.c3b(255,0,0))
    end
end

return MineDrawLotsPanel