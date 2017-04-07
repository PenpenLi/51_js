local ConstellationSelectCirclePanel=class("ConstellationSelectCirclePanel",UILayer)

function ConstellationSelectCirclePanel:ctor()
    self:init("ui/ui_constellation_select_circle.map")
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:initPanel()
end

function ConstellationSelectCirclePanel:events()
    return {
            EVENT_ID_CONSTELLATION_ITEM_CHOOSE,
            EVENT_ID_CONSTELLATION_ACTIVE_GROUP,
            EVENT_ID_CONSTELLATION_ACTIVE_CIRCLE,
        }
end

function ConstellationSelectCirclePanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_ITEM_CHOOSE then
        self:refreshSelectFlag(param)
    elseif event == EVENT_ID_CONSTELLATION_ACTIVE_CIRCLE then
        self:activeCircle(param)
    elseif event == EVENT_ID_CONSTELLATION_ACTIVE_GROUP then
        local size = self.scroll:getSize()
        for i = 1, size do
            local item = self.scroll:getItem(i - 1)
            if nil ~= item then
                item:refreshActiveGroupInfo(param)
            end
        end
    end
end

function ConstellationSelectCirclePanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    end
end

function ConstellationSelectCirclePanel:initPanel()
    self.scroll = self:getNode("scroll")
    local count = DB.getConstellationCircleCount()
    for i = 1, count do
        local magicCircleInfo = gConstellation.getMagicCircleInfoById(i)
        if nil == magicCircleInfo then
             magicCircleInfo = MagicCircleInfo.new(i)
             gConstellation.addMagicCircleInfo(magicCircleInfo)
        end

        local item = ConstellationItem.new(magicCircleInfo, 1)
        self.scroll:addItem(item)
    end
    self.scroll:layout()
    -- 如果当前没有选中的，默认选择第一项
    if gConstellation.getSelCircleId() == 0 then
        local item = self.scroll:getItem(0)
        if nil ~= item and item.curData.isUnlock then
            item:setSelect(true)
            Net.sendCircleSelecircle(item.curData.id, true)
        end
    end
end

function ConstellationSelectCirclePanel:refreshSelectFlag(param)
    local size = self.scroll:getSize()
    for i = 1, size do
        local item = self.scroll:getItem(i - 1)
        if item.curData.id ~= gConstellation.getSelCircleId() then
            item:setSelect(false)
        end
    end
end

function ConstellationSelectCirclePanel:activeCircle(circleId)
    local size = self.scroll:getSize()
    for i = circleId, size do
        local item = self.scroll:getItem(i - 1)
        if nil ~= item then
            item:refreshUnlock()
        end
    end
end

return ConstellationSelectCirclePanel
