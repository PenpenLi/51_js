local ConstellationItem=class("ConstellationItem",UILayer)
local ConstellationItemPanelType = {
    -- 选择
    sel = 1,
    -- 详细
    detail = 2,
}

function ConstellationItem:ctor(data, panelType)
    self:init("ui/ui_constellation_item.map")
    self.curData = data
    self:initPanel(panelType)
end

function ConstellationItem:initPanel(panelType)
    self.panelType = panelType
    local curName = DB.getConstellationCircleName(self.curData.id)
    self:changeTexture("icon_magic_circle", string.format("images/battle/xingzhen_%d.png",self.curData.id))
    self:setLabelString("name_magic_circle", gGetMapWords("ui_constellation_item.plist", "7", curName))
    self:refreshUnlock()
    if self.curData.id == gConstellation.getSelCircleId() then
        self.selected = true
    else
        self.selected = false
    end
    self:refreshSelect()

    if panelType == ConstellationItemPanelType.sel then
        self:getNode("txt_lock"):setVisible(false)
    end
end

function ConstellationItem:onTouchEnded(target, touch, event)
    if target.touchName=="icon_choose" then
        self.selected = not self.selected
        self:refreshSelect()
        Net.sendCircleSelecircle(self.curData.id, self.selected)
        -- if self.selected then
        --     gDispatchEvt(EVENT_ID_CONSTELLATION_ITEM_CHOOSE, self.curData.id)
        -- end
    elseif target.touchName=="bg_touch" then
        if self.curData.isUnlock then
            Panel.popUp(PANEL_CONSTELLATION_CIRCLE_DETAIL, self.curData.id)
        end
    end
end

function ConstellationItem:refreshSelect()
    if self.selected then
        self:changeTexture("icon_choose", "images/ui_public1/gou_1.png")
    else
        self:changeTexture("icon_choose", "images/ui_public1/gou_2.png")
    end
end

function ConstellationItem:setSelect(selected)
    self.selected = selected
    self:refreshSelect()
end

function ConstellationItem:refreshUnlock()
    local activeNum = gConstellation.getActivedGroupNum(self.curData.preCircleId)
    if Data.getCurLevel() >= self.curData.needLv and
        activeNum >= self.curData.preCircleGroups then
        self.curData.isUnlock = true
    end
    
    if self.curData.isUnlock then
        self:setLabelString("txt_active_num", string.format("%d/%d",gConstellation.getActivedGroupNum(self.curData.id),DB.getTotalCirceGroupNums(self.curData.id)))
        self:getNode("layer_lock"):setVisible(false)
        self:getNode("layout_active_tips"):setVisible(true)
        self:getNode("txt_lock"):setVisible(false)
        self:refreshRedposShow()
        self:refreshActiveTipAndIcon()
    else
        self:setLabelString("txt_lv_limit", gGetMapWords("ui_constellation_item.plist","2",self.curData.needLv))
        local color = cc.c3b(255, 0, 0)
        if Data.getCurLevel() >= self.curData.needLv then
            color = cc.c3b(0,255,0)
        end
        self:getNode("txt_lv_limit"):setColor(color)

        local preCircleName = DB.getConstellationCircleName(self.curData.preCircleId)
        self:setLabelString("txt_circle_limit", gGetMapWords("ui_constellation_item.plist","3",preCircleName, self.curData.preCircleGroups))
        local activeNum = gConstellation.getActivedGroupNum(self.curData.preCircleId)
        if activeNum >= self.curData.preCircleGroups then
            color = cc.c3b(0,255,0)
        else
            color = cc.c3b(255, 0, 0)
        end
        self:getNode("txt_circle_limit"):setColor(color)

        self:getNode("layout_active_tips"):setVisible(false)
        self:getNode("txt_lock"):setVisible(true)
        self:getNode("icon_choose"):setVisible(false)
    end
end

function ConstellationItem:refreshActiveGroupInfo()
    if self.curData.isUnlock then
        self:setLabelString("txt_active_num", string.format("%d/%d",gConstellation.getActivedGroupNum(self.curData.id),DB.getTotalCirceGroupNums(self.curData.id)))
        self:getNode("layout_active_tips"):setVisible(true)
        self:getNode("layer_lock"):setVisible(false)
        self:getNode("txt_lock"):setVisible(false)
        self:refreshRedposShow()
        self:refreshActiveTipAndIcon()
    else
        -- TODO,切换成解锁状态
    end
end

function ConstellationItem:refreshRedposShow()
    local hasGroupCanBeActived = gConstellation.hasGroupCanbeActived(self.curData.id)
    if hasGroupCanBeActived==false and Data.getCurLevel()>=gConstellation.getStarUnLockLv() then
        hasGroupCanBeActived=gConstellation.hasGroupCanbeStarUpgrade(self.curData.id)
    end
    RedPoint.refresh(self:getNode("bg"), hasGroupCanBeActived, cc.p(0.98, 0.99))
end

function ConstellationItem:refreshActiveTipAndIcon()
    local isAllActive = gConstellation.isAllGroupActived(self.curData.id)
    if isAllActive then
        self:getNode("icon_choose"):setVisible(true)
        self:getNode("layout_active_tip1"):setVisible(false)
        self:getNode("layout_active_tip2"):setVisible(false)
        self:getNode("layout_active_tip3"):setVisible(true)
    else
        self:getNode("icon_choose"):setVisible(false)
        local curNum = gConstellation.getActivedGroupNum(self.curData.id)
        local totalNum = DB.getTotalCirceGroupNums(self.curData.id)
        self:setLabelString("layout_active_tip1", gGetMapWords("ui_constellation_item.plist","11",curNum,totalNum))
        self:getNode("layout_active_tip1"):setVisible(true)
        self:getNode("layout_active_tip2"):setVisible(true)
        self:getNode("layout_active_tip3"):setVisible(false)
        if self.panelType ~= ConstellationItemPanelType.sel then
            self:getNode("layout_active_tip2"):setVisible(false)
        end
    end
    self:getNode("layout_active_tips"):layout()
    self:getNode("layout_icon_tips"):layout()
end

return ConstellationItem
