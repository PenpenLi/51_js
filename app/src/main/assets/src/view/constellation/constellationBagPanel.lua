local ConstellationBagPanel=class("ConstellationBagPanel",UILayer)

function ConstellationBagPanel:ctor()
    self:init("ui/ui_constellation_bag.map")
    self:initPanel()
end

function ConstellationBagPanel:events()
    return {
            EVENT_ID_CONSTELLATION_ITEM_REFRESH,
        }
end

function ConstellationBagPanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_ITEM_REFRESH then
        self:refreshBagItem()
    end
end

function ConstellationBagPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif string.find(target.touchName, "choose_star") ~= nil then
        local idx = toint(string.sub(target.touchName, string.len("choose_star") + 1))
        self.selectFlags[idx]= not self.selectFlags[idx]
        self:setSelectFlags(idx)
        self:refresh()
    elseif target.touchName=="btn_quick_soul" then
        Panel.popUp(PANEL_CONSTELLATION_SOUL)
    end
end

function ConstellationBagPanel:initPanel()
    -- self:setLabelString("txt_unlock_num",string.format("%d/%d",gConstellation.getUnlockNum(),DB.getConstellationsCount()))
    -- self:getNode("layout_unlock"):layout()
    self:setLabelString("txt_soul_num",  gConstellation.getSoulNum())
    self:getNode("layout_soul"):layout()

    self.scroll = self:getNode("scroll")
    self.scroll.eachLineNum = 2

    self.scroll:clear()

    if not gConstellation.isBagSort then
        gConstellation.isBagSort = true
        local idx  = 0
        table.sort(gConstellation.bags, function(lInfo, rInfo)
            idx = idx + 1
            if lInfo.star > rInfo.star then
                return true
            elseif lInfo.star == rInfo.star then
                if lInfo.id > rInfo.id then
                    return true
                end
            end

            return false
        end)
    end
    local drawNum = 8
    for _, bagItem in pairs(gConstellation.bags) do
        local item = ConstellationBagItem.new()
        if(drawNum > 0)then
            drawNum=drawNum-1
            item:setData(bagItem)
        else
            item:setLazyData(bagItem)
        end
        item.selectItemCallback=function(data)
            if data == nil then
                return
            end
            self.curCardid=data.id
            Panel.popUp(PANEL_CONSTELLATION_ITEM_DETAIL,data.id, data.num)
        end
        self.scroll:addItem(item)
    end
    self.scroll:layout()

    self.selectFlags = {false, false, false}
end

function ConstellationBagPanel:setSelectFlags(idx)
    if self.selectFlags[idx] then
        self:changeTexture("choose_star"..idx, "images/ui_public1/gou_1.png")
    else
        self:changeTexture("choose_star"..idx, "images/ui_public1/gou_2.png")
    end
end

function ConstellationBagPanel:refresh()
    self.scroll:clear()
    local filterStar = {}
    for i=1, 3 do
        if self.selectFlags[i] then
            table.insert(filterStar,i)
        end
    end
    local filterSize = #filterStar
    for _, bagItem in pairs(gConstellation.bags) do
        local satisfy = false
        if filterSize == 0 then
            satisfy = true
        end
        for _, starNum in ipairs(filterStar) do
            if bagItem.star ==  starNum then
                satisfy = true
                break
            end
        end

        if satisfy then
            local item = ConstellationBagItem.new()
            item:setData(bagItem)
            item.selectItemCallback=function(data)
                self.curCardid=data.id
                Panel.popUp(PANEL_CONSTELLATION_ITEM_DETAIL,data.id, data.num)
            end
            self.scroll:addItem(item) 
        end
    end
    self.scroll:layout()
end

function ConstellationBagPanel:onPopback()
    Scene.clearLazyFunc("constellationBagItem")
end

function ConstellationBagPanel:refreshBagItem()
    local size = self.scroll:getSize()
    for i = 1, size do
        local item = self.scroll:getItem(i - 1)
        if nil ~= item then
            local soulItem = gConstellation.getBagById(item.curData.id)
            if nil ~= soulItem then
                item:updateNumInfo(soulItem.num)
            end
        end
    end
end

return ConstellationBagPanel
