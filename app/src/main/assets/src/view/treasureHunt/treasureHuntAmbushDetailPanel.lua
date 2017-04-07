local TreasureHuntAmbushDetailPanel=class("TreasureHuntAmbushDetailPanel",UILayer)

function TreasureHuntAmbushDetailPanel:ctor(terrainInfo, isSelf)
    self:init("ui/ui_treasure_hunt_ambush_detail.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self.terrainInfo = terrainInfo
    self.isSelf = isSelf
    self:initPanel()
end

function TreasureHuntAmbushDetailPanel:initPanel()
    if self.terrainInfo == nil then
        return
    end

    local imagePath = string.format("images/ui_team/dx_%d.png",self.terrainInfo.type)
    self:changeTexture("icon_terrain", imagePath)
    self:setLabelString("txt_terrain_effect", DB.getTreasureHuntTerrainEffct(self.terrainInfo.type))
    self:getNode("layout_terrain"):layout()

    imagePath=string.format("images/ui_team/weather_%d.png",self.terrainInfo.weather)
    self:changeTexture("icon_weather", imagePath)
    self:setLabelString("txt_weather_effect", DB.getTreasureHuntWeatherEffct(self.terrainInfo.weather))
    self:getNode("layout_weather"):layout()

    imagePath=string.format("images/ui_team/daytime_%d.png",self.terrainInfo.time)
    self:changeTexture("icon_daytime", imagePath)
    local timeEffect = DB.getTreasureHuntTimeEffect(self.terrainInfo.time)
    local timeEffectInfo = ""

    if self.terrainInfo.time == TerrainTimeType.day then
        timeEffectInfo = gGetWords("treasureHuntWord.plist", "day_effect0", timeEffect[1])
    else
        timeEffectInfo = gGetWords("treasureHuntWord.plist", "day_effect1", timeEffect[2],timeEffect[1])
    end
    self:setLabelString("txt_daytime_effect", timeEffectInfo)
    self:getNode("layout_daytime"):layout()

    if self.terrainInfo.ambushId == 0 then
        self:getNode("btn_ambush"):setVisible(not isSelf)
        self:getNode("btn_leave"):setVisible(false)
        self:getNode("icon"):removeChildByTag(1)
        self:getNode("icon"):removeChildByTag(100)
        self:getNode("icon"):setTexture("images/ui_public1/ka_d1.png")
        self:setLabelString("txt_name", "")
        self:setLabelString("txt_servername", "")
    else
        self:getNode("btn_ambush"):setVisible(false)
        self:getNode("btn_leave"):setVisible(self.terrainInfo.ambushId == Data.getCurUserId())
        Icon.setHeadIcon(self:getNode("icon"), self.terrainInfo.ambushIcon)
        self:setLabelString("txt_name", self.terrainInfo.ambushName)
        self:setLabelString("txt_servername", self.terrainInfo.ambushServerName)
    end
end

function TreasureHuntAmbushDetailPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="icon" then
        if self.terrainInfo.ambushId ~= 0 then
            Net.sendCrotreUserInfo(self.terrainInfo.ambushId)
        end
    elseif target.touchName=="btn_ambush" then
        Net.sendCrotreLurk(gTreasureHunt.detailMapInfo.groupId, gTreasureHunt.detailMapInfo.roomId, self.terrainInfo.stage)
    elseif target.touchName=="btn_leave" then
        if self.terrainInfo.ambushId == Data.getCurUserId() then
            Net.sendCrotreLeftlurk(gTreasureHunt.detailMapInfo.groupId, gTreasureHunt.detailMapInfo.roomId, self.terrainInfo.stage)
        end
    end
end

function TreasureHuntAmbushDetailPanel:events( ... )
    return {
        EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH,
    }
end

function TreasureHuntAmbushDetailPanel:dealEvent(event, param)
    if event == EVENT_ID_TREASURE_HUNT_REFRESH_AMBUSH then
        if gTreasureHunt.detailMapInfo.groupId == param.groupId and
            gTreasureHunt.detailMapInfo.roomId  == param.roomId and 
            self.terrainInfo.stage == param.ambushStage then

            if param.ambushJoin then 
                Icon.setHeadIcon(self:getNode("icon"), param.ambushIcon)
                self:setLabelString("txt_name", param.ambushName)
                self:setLabelString("txt_servername", param.ambushServerName)
                self:getNode("btn_ambush"):setVisible(false)
                self:getNode("btn_leave"):setVisible(param.ambushId == Data.getCurUserId())
            else
                self:getNode("icon"):removeChildByTag(1)
                self:getNode("icon"):removeChildByTag(100)
                self:getNode("icon"):setTexture("images/ui_public1/ka_d1.png")
                self:setLabelString("txt_name", "")
                self:setLabelString("txt_servername", "")
                self:getNode("btn_ambush"):setVisible(not self.isSelf)
                self:getNode("btn_leave"):setVisible(false)
            end
            -- self:refreshTerrainInfo(param)
        end
    end
end

function TreasureHuntAmbushDetailPanel:refreshTerrainInfo(param)
    self.terrainInfo.ambushId = param.ambushId
    self.terrainInfo.ambushIcon = param.ambushIcon
    self.terrainInfo.ambushName = param.ambushName
    self.terrainInfo.ambushServerName = param.ambushServerName
end


return TreasureHuntAmbushDetailPanel