local ConstellationAchieveItem=class("ConstellationAchieveItem",UILayer)

function ConstellationAchieveItem:ctor(achieveId)
    self.inited = false
    self.achieveId = achieveId
end

function ConstellationAchieveItem:onTouchBegan(target,touch, event)
    if target.touchName == "touch_bg1" or 
        target.touchName == "touch_bg0" then
        Panel.popTouchTip(self:getNode(target.touchName), TIP_TOUCH_DESC, "", {type=TIP_TOUCH_DESC_CONSTELLATION_ACHIEVE,data=self.achieveId})
        self.beganAttrPos = touch:getLocation()
    end
end

function ConstellationAchieveItem:onTouchMoved(target,touch, event)
    if self.beganAttrPos ~= nil then
        self.endAttrPos = touch:getLocation()
        local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
        if dis > gMovedDis then
            Panel.clearTouchTip()
        end
    end
end

function ConstellationAchieveItem:onTouchEnded(target, touch, event)
    Panel.clearTouchTip()
end

function ConstellationAchieveItem:setData()
    if self.inited then
        return
    end

    self:init("ui/ui_constellation_achieve_item.map")
    local size = DB.getConstellationAchieveSize()
    local isOdd = (self.achieveId % 2 ~= 0)
    self.idx = self.achieveId % 2
    self:getNode("layer_item1"):setVisible(isOdd)
    self:getNode("layer_item0"):setVisible(not isOdd)

    if self.achieveId == size then
        self:getNode("line1"):setVisible(false) 
        self:getNode("line0"):setVisible(false) 
    end

    local achieveInfo = DB.getConstellationAchieveInfo(self.achieveId)
    self:setLabelString("txt_value"..self.idx, achieveInfo.neednum)

    self:refreshInfo()
end

function ConstellationAchieveItem:setLazyData()
    if self.inited then
        return
    end
    Scene.addLazyFunc(self,self.setData,"constellationachieveitem")
end

function ConstellationAchieveItem:refreshInfo()
    loadFlaXml("ui_liexing")
    self:getNode("fla_bg"..self.idx):setVisible(false)
    local activedAchieveId = gConstellation.getActivedAchieveId()
    if self.achieveId <= activedAchieveId then
        DisplayUtil.setGray(self:getNode("achieve"..self.idx),false)
        local fla = gCreateFla("ui_liexing_jihuo_a",1)
        self:replaceNode("achieve"..self.idx,fla)
    elseif self.achieveId == activedAchieveId + 1 and gConstellation.canActiveAchieve(self.achieveId) then
        if gConstellation.canActiveAchieve(self.achieveId) then
           DisplayUtil.setGray(self:getNode("achieve"..self.idx),false)
           local fla = gCreateFla("ui_liexing_jihuo_b",1)
           self:replaceNode("achieve"..self.idx,fla)
        end
    else
        if self.achieveId == activedAchieveId + 1 then
            self:getNode("fla_bg"..self.idx):setVisible(true)
            DisplayUtil.setGray(self:getNode("fla_bg"..self.idx))
        end
        DisplayUtil.setGray(self:getNode("achieve"..self.idx))
    end 
end

return ConstellationAchieveItem
