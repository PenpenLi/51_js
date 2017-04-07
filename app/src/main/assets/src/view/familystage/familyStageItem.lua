local FamilyStageItem=class("FamilyStageItem",UILayer)
local maxStageProValue = 10000
function FamilyStageItem:ctor(mapId, isSelf)
    self:init("ui/ui_family_race_item.map")
    self:changeTexture("icon_stage", "images/ui_family/s_n"..mapId..".png")
    self.isSelfFamily = isSelf
    local proList = gFamilyStageInfo.otherProLists
    if isSelf then
        proList = gFamilyStageInfo.selfProLists
        self:changeTexture("bg", "images/ui_public1/di-9gong-smallban3.png")
    else
        self:changeTexture("bg", "images/ui_public1/di-9gong-smallban.png")
    end


    local maxPassingStage,maxStageNum = Data.getFamilyMaxAndPassingIdByMapId(mapId,isSelf)
    if maxPassingStage == -1 then
        self:setBarPer("process_bar", 0)
        self:setLabelString("txt_bar", "0%")
        self:getNode("icon_fininsh"):setVisible(false)
        self:getNode("btn_go"):setVisible(isSelf)
        self.detailStageId = mapId * 100 + 1
        self:adjustProIconPos(1)
    else
        local smallStageId = maxPassingStage % 100
        for i = 1, smallStageId do
            if proList[100*mapId + i] == maxStageProValue then
                self:changeTexture("boss_icon"..i, "images/ui_family/s-skill-0.png")
            end
        end

        if maxPassingStage == mapId * 100 + maxStageNum and proList[maxPassingStage] == maxStageProValue then
            self:setBarPer("process_bar", 1)
            self:setLabelString("txt_bar", "100%")
            self:getNode("icon_fininsh"):setVisible(true)
            self:getNode("btn_go"):setVisible(false)
            self:getNode("icon_pro"):setVisible(false)
            self:setTouchEnable("icon_stage", false, false)
        else
            self:getNode("icon_fininsh"):setVisible(false)
            self:getNode("btn_go"):setVisible(true and isSelf)
            if proList[maxPassingStage] == maxStageProValue then
                self.detailStageId = mapId * 100 + (smallStageId + 1)
                self:setBarPer("process_bar", 0)
                self:setLabelString("txt_bar", "0%")
                self:adjustProIconPos(smallStageId + 1)
            else
                self.detailStageId = maxPassingStage
                self:setBarPer("process_bar", proList[maxPassingStage] / maxStageProValue)
                self:setLabelString("txt_bar", string.format("%0.2f%%", proList[maxPassingStage] / 100))
                self:adjustProIconPos(smallStageId)
            end
            
        end
    end

    local power =  math.floor(gFamilyStageInfo.power / DB.getFamilyStagePowerMemNum() * DB.getFamilyStagePowerMapRate(mapId) / 100) 
    self:setLabelString("txt_power", power)
    self:getNode("layout_power"):layout()
end

function FamilyStageItem:onTouchBegan(target,touch, event)
    if target.touchName == "icon_stage" then
        Panel.popTouchTip(self:getNode(target.touchName), TIP_TOUCH_DESC, "", {type=TIP_TOUCH_DESC_FAMILY_STAGE_REWARDS,data=self.detailStageId})
        self.beganAttrPos = touch:getLocation()
    end
end

function FamilyStageItem:onTouchMoved(target,touch, event)
    if self.beganAttrPos ~= nil then
        self.endAttrPos = touch:getLocation()
        local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
        if dis > gMovedDis then
            Panel.clearTouchTip()
        end
    end
end

function FamilyStageItem:onTouchEnded(target, touch, event)
    Panel.clearTouchTip()
    if target.touchName == "btn_go" then
        Net.sendFamilyStageMonster(self.detailStageId)
    end
end

function FamilyStageItem:adjustProIconPos(idx)
    local bossIcon = self:getNode("boss_icon"..idx)
    local contentSize = bossIcon:getContentSize()
    local desNodePos = gGetPositionByAnchorInDesNode(self:getNode("bg"), bossIcon, cc.p(0.0, 0.5))
    if nil ~= bossIcon then
        desNodePos.x = desNodePos.x + contentSize.width * 0.5
        desNodePos.y = desNodePos.y - contentSize.height * 0.5
        self:getNode("icon_pro"):setPosition(cc.p(desNodePos.x,desNodePos.y))
        self:getNode("icon_pro"):setVisible(true)
    end
end


return FamilyStageItem