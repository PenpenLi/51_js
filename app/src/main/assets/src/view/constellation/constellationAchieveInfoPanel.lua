local ConstellationAchieveInfoPanel=class("ConstellationAchieveInfoPanel",UILayer)

function ConstellationAchieveInfoPanel:ctor()
    self:init("ui/ui_constellation_achieve_info.map")
    self:initPanel()
end

function ConstellationAchieveInfoPanel:events()
    return {
            EVENT_ID_CONSTELLATION_ACTIVE_ACHIEVE,
            EVENT_ID_CONSTELLATION_REDPOS_REFRESH,
        }
end

function ConstellationAchieveInfoPanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_ACTIVE_ACHIEVE then
        self:refreshInfo()
        self:refreshScroll()
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    elseif event == EVENT_ID_CONSTELLATION_REDPOS_REFRESH then
        self:showBtnRedpos()
    end
end

function ConstellationAchieveInfoPanel:onTouchMoved(target,touch, event)
    self.endAttrPos = touch:getLocation()
    local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
    if dis > gMovedDis then
        Panel.clearTouchTip()
    end
end

function ConstellationAchieveInfoPanel:onTouchBegan(target,touch, event)
    if target.touchName == "btn_detail_attr" then
        Panel.popTouchTip(self:getNode("btn_detail_attr"),TIP_TOUCH_SOULLIFE_ATTR,nil,{type=2,subtype=3,attr=self.attrMap})
    end

    self.beganAttrPos = touch:getLocation()
end

function ConstellationAchieveInfoPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_active" then
        local toActiveAchieveId = gConstellation.getActivedAchieveId() + 1
        Net.sendCircleLightStar(toActiveAchieveId)
    elseif string.find(target.touchName, "achieve") ~= nil then
        local id = toint(string.sub(target.touchName, string.len("achieve") + 1))
        self:showConstellationNum(id)
    elseif target.touchName=="btn_exchange" then
        Panel.popUpVisible(PANEL_SHOP, SHOP_TYPE_CONSTELLATION)
    elseif target.touchName=="btn_bag" then
        Panel.popUp(PANEL_CONSTELLATION_BAG)
    elseif target.touchName=="btn_hunt" then
        Net.sendCircleHuntInfo()
    elseif target.touchName == "btn_detail_attr" then
        Panel.clearTouchTip()
    end
end

function ConstellationAchieveInfoPanel:initPanel()
    self:initScroll()
    self:refreshInfo()
end

function ConstellationAchieveInfoPanel:showAttrInfo()
    self.attrMap = {}
    local attrMapSize = 0
    local activedAchieveId = gConstellation.getActivedAchieveId()
    for i = 1, activedAchieveId do
        local achieveInfo = DB.getConstellationAchieveInfo(i)
        local attr = achieveInfo.attr1
        local value = achieveInfo.param1
        if self.attrMap[attr] == nil then
            self.attrMap[attr] = value
            attrMapSize = attrMapSize + 1
        else
            self.attrMap[attr] = self.attrMap[attr] + value
        end
    end

    local idx = 1
    for attr, value in pairs(self.attrMap) do
        local attrTitle = gGetWords("cardAttrWords.plist", "attr" .. attr)
        self:setLabelString("attr_title"..idx, attrTitle)
        local formatValue = ""
        if CardPro.isFloatAttr(attr) then
            formatValue = string.format("+%0.1f%%", value)
        else
            formatValue = string.format("+%d", value)
        end
        self:setLabelString("attr_value"..idx, formatValue)
        self:getNode("layout_attr"..idx):layout()
        self:getNode("layout_attr"..idx):setVisible(true)
        idx = idx + 1

        if idx > 4 then
            break
        end
    end

    for i = idx, 4 do
        self:getNode("layout_attr"..i):setVisible(false)
    end

    if attrMapSize > 4 then
        self:getNode("btn_detail_attr"):setVisible(true)
    else
        self:getNode("btn_detail_attr"):setVisible(false)
    end
end

function ConstellationAchieveInfoPanel:showUnlockCondition(id)
    if id > 10 then
        id = 10
    end

    local achieveInfo = DB.getConstellationAchieveInfo(id)
    self:setLabelString("txt_con"..id,achieveInfo.neednum)
    -- local attrTitle = gGetWords("cardAttrWords.plist", "attr" .. achieveInfo.attr1)
    -- local attrValue = achieveInfo.param1
    -- self:setLabelString("txt_attr_title", attrTitle)
    -- self:setLabelString("txt_attr_value", attrValue)
    -- self:getNode("layout_attr"):layout()
end

function ConstellationAchieveInfoPanel:showActivedBtn()
    local activedAchieveId = gConstellation.getActivedAchieveId()
    if self.hasUnActiveAchieve then
        self:setTouchEnable("btn_active", true, false)
    else
        self:setTouchEnable("btn_active", false, true)
    end 
end

function ConstellationAchieveInfoPanel:showBtnRedpos()
    if Data.redpos.constellationhunt then
        RedPoint.add(self:getNode("btn_hunt"), cc.p(0.8,0.8))
    else
        RedPoint.remove(self:getNode("btn_hunt"))
    end
end

function ConstellationAchieveInfoPanel:showConstellationNum(id)
    local size = DB.getConstellationAchieveSize()
    if id > size then
        id = size
    end

    local achieveInfo = DB.getConstellationAchieveInfo(id)
    self:setLabelString("txt_constellation_num", string.format("%d/%d", gConstellation.getNum(),achieveInfo.neednum))
    if gConstellation.getNum() > achieveInfo.neednum then
        self:getNode("txt_constellation_num"):setColor(cc.c3b(0,255,0))
        self:getNode("title_constellation_num"):setColor(cc.c3b(0,255,0))
    else
        self:getNode("txt_constellation_num"):setColor(cc.c3b(255,0,0))
        self:getNode("title_constellation_num"):setColor(cc.c3b(0,255,0))
    end
    self:getNode("layout_constellation_num"):layout()

    local attrTitle = gGetWords("cardAttrWords.plist", "attr" .. achieveInfo.attr1)..":"
    if CardPro.isFloatAttr(achieveInfo.attr1) then
        formatValue = string.format("+%0.1f%%", achieveInfo.param1)
    else
        formatValue = string.format("+%d", achieveInfo.param1)
    end
    self:setLabelString("txt_cur_attr", attrTitle)
    self:setLabelString("txt_cur_attr_value", formatValue)
    self:getNode("layout_cur_attr"):layout()
end

function ConstellationAchieveInfoPanel:onPopback()
    Scene.clearLazyFunc("constellationachieveitem")
end

function ConstellationAchieveInfoPanel:initScroll()
    self.scroll = self:getNode("scroll")
    self.scroll:clear()
    self.scroll.paddingX = 90

    local size = DB.getConstellationAchieveSize()
    local activedAchieveId = gConstellation.getActivedAchieveId()
    local drawNum = 20
    local referItem = ConstellationAchieveItem.new(1)
    referItem:setData()
    self.scroll.itemWidth = referItem:getContentSize().width

    for i = 1, size do
        local item = ConstellationAchieveItem.new(i)
        if i >= activedAchieveId - 5 and i <= activedAchieveId + 5 then
            item:setData()
        else
            item:setLazyData()
        end
        -- if drawNum > 0 then
        --     drawNum = drawNum - 1
        --     
        -- else
        --     
        -- end
        self.scroll:addItem(item) 
    end 
    self.scroll:layout()

    local winSize=cc.Director:getInstance():getWinSizeInPixels()
    local containNum = math.floor(winSize.width / self.scroll.itemWidth)

    if activedAchieveId > containNum / 2 then
        self.scroll:moveItemByIndex(activedAchieveId - math.floor(containNum / 2))
    end 
end

function ConstellationAchieveInfoPanel:refreshInfo()
    local activedAchieveId = gConstellation.getActivedAchieveId()
    local size = DB.getConstellationAchieveSize()
    self.hasUnActiveAchieve = false
    if activedAchieveId + 1 <= size and gConstellation.canActiveAchieve(activedAchieveId + 1) then
        self.hasUnActiveAchieve = true
    end

    self:showAttrInfo()

    self:showActivedBtn()

    self:showBtnRedpos()

    self:showConstellationNum(activedAchieveId + 1)

    Data.redpos.circleachieve = self.hasUnActiveAchieve
    RedPoint.constellation()
end

function ConstellationAchieveInfoPanel:refreshScroll()
    local size = DB.getConstellationAchieveSize()
    local activedAchieveId = gConstellation.getActivedAchieveId()
    local curItem = self.scroll:getItem(activedAchieveId - 1)
    curItem:refreshInfo()

    if activedAchieveId + 1 <= size then
        curItem = self.scroll:getItem(activedAchieveId)
        curItem:refreshInfo()
    end

    local winSize=cc.Director:getInstance():getWinSizeInPixels()
    local containNum = math.floor(winSize.width / self.scroll.itemWidth)
    if activedAchieveId > containNum / 2 then
        self.scroll:moveItemByIndex(activedAchieveId - math.floor(containNum / 2), 0.8)
    end 
end

return ConstellationAchieveInfoPanel
