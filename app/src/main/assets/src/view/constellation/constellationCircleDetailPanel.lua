local ConstellationCircleDetailPanel=class("ConstellationCircleDetailPanel",UILayer)

function ConstellationCircleDetailPanel:ctor(circleId)
    self:init("ui/ui_constellation_circle_detail.map")
    self:initPanel(circleId)
end

function ConstellationCircleDetailPanel:events()
    return {
            EVENT_ID_CONSTELLATION_ACTIVE_GROUP,
            EVENT_ID_CONSTELLATION_STAR_GROUP
        }
end

function ConstellationCircleDetailPanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_ACTIVE_GROUP then
        self:activeGroup(param)
        self:playActiveFla()
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    elseif event == EVENT_ID_CONSTELLATION_STAR_GROUP then
        self:activeStarGroup(param)
        gDispatchEvt(EVENT_ID_USER_POWER_UPDATE)
    end
end

function ConstellationCircleDetailPanel:onTouchMoved(target,touch, event)
    self.endAttrPos = touch:getLocation()
    local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
    if dis > gMovedDis then
        Panel.clearTouchTip()
    end
end

function ConstellationCircleDetailPanel:onTouchBegan(target,touch, event)
    if target.touchName == "btn_detail_attr" then
        Panel.popTouchTip(self:getNode("btn_detail_attr"),TIP_TOUCH_SOULLIFE_ATTR,nil,{type=2,subtype=2,attr=self.attrMap})
    end

    self.beganAttrPos = touch:getLocation()
end

function ConstellationCircleDetailPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif string.find(target.touchName, "layout_extra_attr") ~= nil then
        local idx = toint(string.sub(target.touchName, string.len("layout_extra_attr") + 1))
        local extraInfo = DB.getConstellationCircleExtraInfo(self.circleId, idx)
        local activedGroupNum = gConstellation.getActivedGroupNum(self.circleId)        
        if extraInfo.unlocknum > activedGroupNum  then
            gShowNotice(gGetWords("noticeWords.plist","circle_extra_attr_active", extraInfo.unlocknum))
        end
    elseif target.touchName == "btn_detail_attr" then
        Panel.clearTouchTip()
    end
end

function ConstellationCircleDetailPanel:initPanel(circleId)
    self.circleId = circleId
    local curName = DB.getConstellationCircleName(circleId)
    self:setLabelString("name_magic_circle", gGetMapWords("ui_constellation_item.plist", "7", curName))
    self:changeTexture("icon_magic_circle", string.format("images/battle/xingzhen_%d.png",circleId))

    self:showExtraAttrInfo()

    -- self:refreshSelectInfo()

    self:showActivedGroupInfo()

    self:initScroll()

    self:showAttrInfo()
end

function ConstellationCircleDetailPanel:refreshSelectInfo()
    for i = 1, 3 do
        if self.selectAttrIdx[i] then
            self:changeTexture("icon_select"..i, "images/ui_public1/gou_2.png")
        else
            self:changeTexture("icon_select"..i, "images/ui_public1/gou_1.png")
        end
    end
end

function ConstellationCircleDetailPanel:initScroll()
    self.scroll = self:getNode("scroll")
    self.scroll:clear()
    local groupInfos = DB.getCircleGroupInfos(self.circleId)
    for k,groupInfo in pairs(groupInfos) do
        groupInfo.sortid = 0
        if  gConstellation.isGroupActived(self.circleId, groupInfo.id) then
            groupInfo.sortid = 0
            if gConstellation.showStarViewLv() then
                local starNum = gConstellation.getStarNumByGroupMap(self.circleId, groupInfo.id)
                if groupInfo.star>0  and groupInfo.star~=starNum then
                    local groupStarInfo= DB.getCircleGroupStar(groupInfo.id,starNum+1)
                    if gConstellation.canStarUpgradeGroup(groupStarInfo) then
                        groupInfo.sortid = 13+starNum
                    else
                        groupInfo.sortid = 8+starNum
                    end
                    
                elseif groupInfo.star>0  and groupInfo.star==starNum then
                    groupInfo.sortid = 1 + starNum
                end
            end
        else
            if  gConstellation.canActiveGroup(groupInfo) then
                groupInfo.sortid = 20
            else
                groupInfo.sortid = 2
            end
        end
        
    end

    table.sort(groupInfos, function(lGroupInfo, rGroupInfo)
            return lGroupInfo.sortid>rGroupInfo.sortid
        end)

    local drawNum = 8 
    for _,var in ipairs(groupInfos) do
        local groupItem = ConstellationGroupItem.new(self.circleId, var.id)
        if drawNum > 0 then
            drawNum = drawNum-1
            groupItem:setData()
        else
            groupItem:setLazyData()
        end
        self.scroll:addItem(groupItem)
    end
    self.scroll:layout()
end

function ConstellationCircleDetailPanel:activeGroup(param)
    local size = self.scroll:getSize()
    for i = 1, size do
        local item = self.scroll:getItem(i - 1)
        if item.groupId == param then
            item:activeGroup()
        elseif item.inited then
            item:initPanel()
        end
    end
    self:showActivedGroupInfo()
    self:showAttrInfo()
    self:showExtraAttrInfo()
end

function ConstellationCircleDetailPanel:activeStarGroup(param)
    local size = self.scroll:getSize()
    for i = 1, size do
        local item = self.scroll:getItem(i - 1)
        item:RefreshStarUpgrade()
    end
    self:showActivedGroupInfo()
    self:showAttrInfo()
    self:showExtraAttrInfo()
end


function ConstellationCircleDetailPanel:showAttrInfo()
    self.attrMap = {}
    local attrMapSize = 0
    local groupInfos = gConstellation.getActivedGroupInfos(self.circleId)
    for i,value in pairs(groupInfos) do
        local groupInfo = DB.getConstellationGroupInfo(i)
        if self.attrMap[groupInfo.attr] == nil then
            self.attrMap[groupInfo.attr] = groupInfo.param
            attrMapSize = attrMapSize + 1
        else
            self.attrMap[groupInfo.attr] = self.attrMap[groupInfo.attr] + groupInfo.param 
        end
         -- add Constellation star 
         local starlv = gConstellation.getStarNumByGroupMap(self.circleId, groupInfo.id)
         local starlvInfo = DB.getCircleGroupStar(groupInfo.id,starlv)
         if starlvInfo then
             for i=1,3 do
                local attrtype = starlvInfo["attr"..i]
                if attrtype>0 then
                    if self.attrMap[attrtype] == nil then
                        self.attrMap[attrtype] = starlvInfo["param"..i]
                        attrMapSize = attrMapSize + 1
                    else
                        self.attrMap[attrtype] = self.attrMap[attrtype] + starlvInfo["param"..i]
                    end
                end
            end
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

function ConstellationCircleDetailPanel:showActivedGroupInfo()
    local totalGroups = DB.getTotalCirceGroupNums(self.circleId)
    local activedGroups = gConstellation.getActivedGroupNum(self.circleId)
    self:setLabelString("txt_active_num", string.format("%d/%d",activedGroups,totalGroups))
    self:getNode("layout_active_num"):layout()

    self:setLabelString("txt_constellation_num", gConstellation.getNum())
    self:getNode("layout_constellation_num"):layout()
end

function ConstellationCircleDetailPanel:showExtraAttrInfo()
    local activedGroupNum = gConstellation.getActivedGroupNum(self.circleId)

    for i = 1, 3 do
        local extraInfo = DB.getConstellationCircleExtraInfo(self.circleId, i)
        local buff=DB.getBuffById(extraInfo.bufid)
        if nil ~= buff then
            self:setLabelString("extra_attr_desc"..i, gGetBuffDesc(buff,1))
        end        
        if extraInfo.unlocknum <= activedGroupNum  then
            self:getNode("extra_attr_lock"..i):setVisible(false)
            self:getNode("extra_attr_con"..i):setVisible(false)
            self:getNode("extra_attr_select"..i):setVisible(true)
        else
            self:getNode("extra_attr_select"..i):setVisible(false)
            self:getNode("extra_attr_lock"..i):setVisible(true)
            self:setLabelString("extra_attr_con"..i, string.format("(%d/%d)",activedGroupNum,extraInfo.unlocknum))
            self:getNode("extra_attr_con"..i):setVisible(true)
        end
        self:getNode("layout_extra_attr"..i):layout()
    end

    -- self.selectAttrIdx = {false, false, false}
    -- if gConstellation.getActivedMagicCircle() == self.circleId and 
    --    gConstellation.getSelExtraAddIx() ~= 0 then
    --     self.selectAttrIdx[gConstellation.getSelExtraAddIx()] = true
    -- end
end

function ConstellationCircleDetailPanel:onPopback()
    Scene.clearLazyFunc("constellationGroupItem")
end

function ConstellationCircleDetailPanel:playActiveFla()
    loadFlaXml("ui_liexing")
    local activeFla = FlashAni.new()
    activeFla:playAction("ui_liexing_jihuo", function()
                            activeFla:removeFromParent()
                        end, nil, 1)
    gAddCenter(activeFla, self:getNode("fla_active_pos"))
end

return ConstellationCircleDetailPanel
