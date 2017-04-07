local MineNewProjPanel=class("MineNewProjPanel",UILayer)

function MineNewProjPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_mine_new_project.map")
    self:initInfo()
end

function MineNewProjPanel:initInfo()
    self.depthIdx = 1
    self.timeIdx  = 1
    self:setProjLabelInfo()
    self:setRewardIcon()
    self:setSelectDepthPos()
    self:setSelectTimePos()
    self:setMinerInfo()
    if isBanshuReview() then
        self:getNode("txt_name_y"):setVisible(false)
    end
end

function MineNewProjPanel:events()
    return {
            EVENT_ID_USER_DATA_UPDATE,
    }
end

function MineNewProjPanel:dealEvent(event,param)
    if event == EVENT_ID_USER_DATA_UPDATE then
        self:setProjLabelInfo()
    end
end

function MineNewProjPanel:onTouchBegan(target, touch, event)
    if nil == target.touchName then
        return true
    end

    if target.touchName == "reward_icon1" or target.touchName == "reward_icon2" or target.touchName == "reward_icon3" then
        local rewardItems = gDigMine.getMiningProRewards(self.depthIdx)
        if nil ~= rewardItems then
            local idx = toint(string.sub(target.touchName, string.len("reward_icon") + 1))
            Panel.popTouchTip(target,TIP_TOUCH_EQUIP_ITEM,toint(rewardItems[idx]))
        end
    end
    self.beganPos = touch:getLocation()
    return true
end

function MineNewProjPanel:onTouchMoved(target, touch, event)
    self.endPos = touch:getLocation()
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y)
    if dis > gMovedDis then
        Panel.clearTouchTip()
    end
end


function MineNewProjPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "depth1" or target.touchName == "depth2" or target.touchName == "depth3" or target.touchName == "depth4" then
        local selectIdx = toint(string.sub(target.touchName, string.len("depth")+1))
        if selectIdx ~= self.depthIdx then
            self.depthIdx = selectIdx
            self:setProjLabelInfo()
            self:setSelectDepthPos()
            self:setRewardIcon()
        end
    elseif target.touchName == "time1" or target.touchName == "time2" or target.touchName == "time3" then
        local selectIdx = toint(string.sub(target.touchName, string.len("time")+1))
        if selectIdx ~= self.timeIdx then
            self.timeIdx = selectIdx
            self:setProjLabelInfo()
            self:setSelectTimePos()
        end
    elseif target.touchName == "btn_cancel" then
        self:onClose()
    elseif target.touchName == "btn_ok" then
        local depth = gDigMine.getMiningProDepth(self.depthIdx)
        local setting = gDigMine.getMiningProSetting(self.depthIdx,self.timeIdx)
        if nil ~= setting and gDigMine.canNewProj(depth,setting.time) then
            Net.sendMiningNewProj(depth,setting.time)
            self:onClose()
        end
    end
    Panel.clearTouchTip()
end

function MineNewProjPanel:setRewardIcon()
    local rewardItems = gDigMine.getMiningProRewards(self.depthIdx)
    if nil ~= rewardItems then
        for idx,itemid in pairs(rewardItems) do
            Icon.setIcon(toint(itemid),self:getNode("reward_icon"..toint(idx)))
        end
    end
end

function MineNewProjPanel:setProjLabelInfo()
    -- local projTimeData = gDigMine.getProjTimeInfoByDepth(self.depthIdx,self.timeIdx)
    if Module.isClose(SWITCH_VIP) then
        self:getNode("txt_vip6"):setVisible(false)
    else
        if Data.getCurVip() >= 6 then
            self:getNode("txt_vip6"):setVisible(true)
        else
            self:getNode("txt_vip6"):setVisible(false)
        end
    end
    self:setLabelString("txt_dig_depth",gDigMine.maxLightY)
    local projSetting = gDigMine.getMiningProSetting(self.depthIdx,self.timeIdx)
    if nil ~= projSetting then
        self:setLabelString("txt_proj_name", gGetWords("labelWords.plist","lab_mine_layer_lv"..self.depthIdx,self.timeIdx))
        self:setLabelString("txt_proj_desc", gGetWords("labelWords.plist","lab_mine_layer_desc",projSetting.min,projSetting.max))
        local masteryAddValue = math.floor(projSetting.dnum * DB.getMiningProjAddMastery() / 100)
        self:setLabelString("txt_mastery_add", gGetWords("mineWords.plist","txt_mastery_add_pro",masteryAddValue))
        self:setLabelString("txt_pickaxe_num", string.format("%d/%d",gDigMine.mpt,projSetting.dnum))
        if gDigMine.mpt < projSetting.dnum then
            self:getNode("txt_pickaxe_num"):setColor(cc.c3b(255, 30, 30))
        else
            self:getNode("txt_pickaxe_num"):setColor(cc.c3b(255, 255, 255))
        end

        self:setLabelString("txt_detonator_num",string.format("%d/%d",Data.getItemNum(ITEM_DETONATOR), projSetting.bnum))
        if Data.getItemNum(ITEM_DETONATOR) < projSetting.bnum then
            self:getNode("txt_detonator_num"):setColor(cc.c3b(255, 30, 30))
        else
            self:getNode("txt_detonator_num"):setColor(cc.c3b(255, 255, 255))
        end

        if projSetting.bnum == 0 then
            self:getNode("icon_detonator"):setVisible(false)
        else
            self:getNode("icon_detonator"):setVisible(true)
        end

        self:getNode("item_lay"):layout()
    end
end

function MineNewProjPanel:setSelectDepthPos()
    local selectX,selectY= self:getNode("depth"..self.depthIdx):getPosition()
    self:getNode("depth_select"):setPosition(selectX, selectY)
end

function MineNewProjPanel:setSelectTimePos()
    self:resetBtnTexture()
    self:changeTexture("time"..self.timeIdx,"images/ui_public1/guangniu.png")
    local selectX,selectY = self:getNode("time"..self.timeIdx):getPosition()
    local contentSize = self:getNode("time"..self.timeIdx):getContentSize()
    self:getNode("time_select_tri"):setPosition(selectX - contentSize.width/2,selectY)
end

function MineNewProjPanel:resetBtnTexture()
    local btns={
        "time1",
        "time2",
        "time3",
    }

    for _, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/button_s.png")
    end
end

function MineNewProjPanel:setMinerInfo()
    local critParam = DB.getNewProjCritParam(gDigMine.miner - 1)
    if critParam == -1 then
        self:getNode("txt_mastery_add_res"):setVisible(false)
        self:getNode("txt_mastery_value"):setVisible(false)
        return
    end

    self:setLabelString("txt_mastery_add_res", gGetWords("mineWords.plist","txt_mastery_add_res",critParam))
    self:setLabelString("txt_mastery_value", gGetWords("mineWords.plist","txt_mastery_value_proj",gDigMine.miner))
    self:getNode("txt_mastery_add_res"):setVisible(true)
    self:getNode("txt_mastery_value"):setVisible(true)
end

return MineNewProjPanel