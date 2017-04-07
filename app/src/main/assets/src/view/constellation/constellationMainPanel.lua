local ConstellationMainPanel=class("ConstellationMainPanel",UILayer)

function ConstellationMainPanel:ctor(callback)
    self:init("ui/ui_constellation_main.map")
    self:initPanel()
    if callback ~= nil then
        callback()
    end

    if isBanshuUser() then
        self:getNode("btn_hunt"):setVisible(false);
        self:getNode("btn_hunt_des"):setVisible(false);
    end
end

function ConstellationMainPanel:events()
    return {
            EVENT_ID_CONSTELLATION_ACTIVE_CIRCLE,
            EVENT_ID_CONSTELLATION_ACTIVE_GROUP,
            EVENT_ID_CONSTELLATION_ITEM_CHOOSE,
            EVENT_ID_USER_DATA_UPDATE,
            EVENT_ID_CONSTELLATION_REDPOS_REFRESH,
            EVENT_ID_CONSTELLATION_ACTIVE_ACHIEVE,
        }
end

function ConstellationMainPanel:dealEvent(event, param)
    if event == EVENT_ID_CONSTELLATION_ACTIVE_CIRCLE then
        self:activeCircle(param)
    elseif event == EVENT_ID_CONSTELLATION_ACTIVE_GROUP then
        self:refreshActiveGroupInfo(param)
        self:showBtnRedpos()
    elseif event == EVENT_ID_CONSTELLATION_ITEM_CHOOSE then
        self:refreshSelected(param)
    elseif event == EVENT_ID_USER_DATA_UPDATE then
        self:showFightInfo()
        self:showBtnRedpos()
        self:refreshActiveGroupInfo()
        RedPoint.constellation()
    elseif event == EVENT_ID_CONSTELLATION_REDPOS_REFRESH then
        self:showBtnRedpos()
    elseif event == EVENT_ID_CONSTELLATION_ACTIVE_ACHIEVE then
        local activedAchieveId = gConstellation.getActivedAchieveId()
        local size = DB.getConstellationAchieveSize()
        local hasUnActiveAchieve = false
        if activedAchieveId + 1 <= size and gConstellation.canActiveAchieve(activedAchieveId + 1) then
            hasUnActiveAchieve = true
        end
        Data.redpos.circleachieve = hasUnActiveAchieve
        self:showBtnRedpos()
        RedPoint.constellation()    
    end
end

function ConstellationMainPanel:onTouchMoved(target,touch, event)
    self.endAttrPos = touch:getLocation()
    local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
    if dis > gMovedDis then
        Panel.clearTouchTip()
    end
end

function ConstellationMainPanel:onTouchBegan(target,touch, event)
    if target.touchName == "btn_detail_attr" then
        Panel.popTouchTip(self:getNode("btn_detail_attr"),TIP_TOUCH_SOULLIFE_ATTR,nil,{type=2,subtype=1,attr=self.attrMap})
    end

    self.beganAttrPos = touch:getLocation()
end

function ConstellationMainPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_bag" then
        Panel.popUp(PANEL_CONSTELLATION_BAG)
    elseif target.touchName=="btn_achieve"then
        Panel.popUp(PANEL_CONSTELLATION_ACHIEVE_INFO)
    elseif target.touchName=="btn_hunt" then
        Net.sendCircleHuntInfo()
    elseif target.touchName=="btn_fight" then
        Net.sendCircleFightinfo()
        -- local maxNum = DB.getConstellationFightMaxNum()
        -- local fightNum = gConstellation.getFightNum()
        -- if fightNum == maxNum then
        --     gShowNotice(gGetWords("constellationWords.plist","no_enough_fight_num"))
        --     return
        -- end
    elseif target.touchName == "btn_exchange" then
        Panel.popUpVisible(PANEL_SHOP, SHOP_TYPE_CONSTELLATION)
    elseif target.touchName == "btn_detail_attr" then
        Panel.clearTouchTip()
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_CONSTELLATION)
    end
end

function ConstellationMainPanel:initPanel()
    self:initSchedule()

    self:setLabelString("txt_constellation_num", gConstellation.getNum())
    self:setLabelString("txt_actived_num", gConstellation.getTotalActivedGroupNum())

    self.scroll = self:getNode("scroll")
    local count = DB.getConstellationCircleCount()
    for i = 1, count do
        local magicCircleInfo = gConstellation.getMagicCircleInfoById(i)
        if nil == magicCircleInfo then
             magicCircleInfo = MagicCircleInfo.new(i)
             gConstellation.addMagicCircleInfo(magicCircleInfo)
        end

        local item = ConstellationItem.new(magicCircleInfo, 2)
        self.scroll:addItem(item)
    end
    self.scroll:layout()
    if gConstellation.getSelCircleId() == 0 then
        local item = self.scroll:getItem(0)
        if nil ~= item and item.curData.isUnlock then
            item:setSelect(true)
            Net.sendCircleSelecircle(item.curData.id, true)
        end
    else
        self:showAttrInfo()
    end

    self:showFightInfo()
    self:showBtnRedpos()
end

function ConstellationMainPanel:activeCircle(circleId)
    local size = self.scroll:getSize()
    for i = circleId, size do
        local item = self.scroll:getItem(i - 1)
        if nil ~= item then
            item:refreshUnlock()
        end
    end
end

function ConstellationMainPanel:refreshActiveGroupInfo(param)
    self:setLabelString("txt_constellation_num", gConstellation.getNum())
    self:setLabelString("txt_actived_num", gConstellation.getTotalActivedGroupNum())

    local size = self.scroll:getSize()
    for i = 1, size do
        local item = self.scroll:getItem(i - 1)
        if nil ~= item then
            item:refreshActiveGroupInfo(param)
        end
    end
    
    self:showAttrInfo()
end

function ConstellationMainPanel:refreshSelected(param)
    local size = self.scroll:getSize()
    for i = 1, size do
        local item = self.scroll:getItem(i - 1)
        if item.curData.id ~= param then
            item:setSelect(false)
        end
    end

    self:showAttrInfo()
end

function ConstellationMainPanel:showAttrInfo()
    self.attrMap = {}
    local attrMapSize = 0
    for _,magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
        if magicCircleInfo.isUnlock then
            local groupInfos = gConstellation.getActivedGroupInfos(magicCircleInfo.id)
            for i,value in pairs(groupInfos) do
                local groupInfo = DB.getConstellationGroupInfo(i)
                if self.attrMap[groupInfo.attr] == nil then
                    self.attrMap[groupInfo.attr] = groupInfo.param
                    attrMapSize = attrMapSize + 1
                else
                    self.attrMap[groupInfo.attr] = self.attrMap[groupInfo.attr] + groupInfo.param 
                end

                 local starlv = gConstellation.getStarNumByGroupMap(groupInfo.cid, groupInfo.id)
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

function ConstellationMainPanel:showFightInfo()
    local maxNum = DB.getConstellationFightMaxNum()
    local fightLeftNum = gConstellation.getLeftFightNum()
    self:setLabelString("txt_fight_num", string.format("%d/%d",fightLeftNum, maxNum))
    if fightLeftNum == 0 then
        self:setTouchEnable("btn_fight", false, true)
    else
        self:setTouchEnable("btn_fight", true, false)
    end
end

function ConstellationMainPanel:initSchedule()
    -- local function update()
    --     local curServerTime = gGetCurServerTime()
    --     local lastRecoveryTime = gConstellation.getLeftFightRecoveryTime()
    --     local fightRecoveryTime = DB.getConstellationFightRecovery()
    --     if(curServerTime - lastRecoveryTime > fightRecoveryTime and
    --         gConstellation.getLeftFightNum() ~= DB.getConstellationFightMaxNum())then
    --         -- gConstellation.setLeftFightRecoveryTime(curServerTime)
    --         Net.sendSystemRetime(4) --挑战恢复时间
    --     end

    --     if gConstellation.getLeftFightNum() < DB.getConstellationFightMaxNum() then
    --         local leftTime = lastRecoveryTime + fightRecoveryTime - curServerTime
    --         if leftTime < 0 then
    --             leftTime = 0
    --         end
    --         self:setLabelString("txt_recover_time", gParserHourTime(leftTime))
    --         self:getNode("layout_recover_time"):layout()
    --         self:getNode("layout_recover_time"):setVisible(true)
    --     else
    --         self:getNode("layout_recover_time"):setVisible(false)
    --     end
    -- end

    -- self:scheduleUpdate(update, 1)
end

function ConstellationMainPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

function ConstellationMainPanel:showBtnRedpos()
    if Data.redpos.circleachieve then
        RedPoint.add(self:getNode("btn_achieve"), cc.p(0.8,0.8))
    else
        RedPoint.remove(self:getNode("btn_achieve"))
    end

    if Data.redpos.constellationhunt then
        RedPoint.add(self:getNode("btn_hunt"), cc.p(0.95,0.83))
    else
        RedPoint.remove(self:getNode("btn_hunt"))
    end

    if gConstellation.getLeftFightNum() > 0 then
        RedPoint.add(self:getNode("btn_fight"), cc.p(0.95,0.83))
    else
        RedPoint.remove(self:getNode("btn_fight"))
    end
end

return ConstellationMainPanel
