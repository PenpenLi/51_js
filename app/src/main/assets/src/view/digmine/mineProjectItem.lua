local MineProjectItem=class("MineProjectItem",UILayer)

function MineProjectItem:ctor(projInfo,idx)
    self:init("ui/ui_mine_project_item.map")
    self.idx = idx
    self:initItem(projInfo)
    self:initSchedule()
end

function MineProjectItem:onTouchEnded(target, touch, event)
    if target.touchName == "btn_finish" then
        Net.sendMiningFinishProj(self.depth,self.endTime)
    elseif target.touchName == "btn_new_project" then
        Panel.popUpVisible(PANEL_MINE_NEW_PROJ,nil,nil,true)
    elseif target.touchName == "btn_unlock" then
        -- local idx = gDigMine.getUnlockProjIdx()
        Unlock.isUnlock(_G["SYS_MINE_PROJ"..self.idx] ,true)
    elseif target.touchName == "btn_cancel_pro" then
        local timeValue = gDigMine.getMiningProSettingByValue(self.depth, self.needTime)
        if nil ~= timeValue then
            local tipWord = ""
            if timeValue.bnum == 0 then
                tipWord = gGetWords("labelWords.plist","lab_mine_proj_cancel1",timeValue.dnum)
            else
                tipWord = gGetWords("labelWords.plist","lab_mine_proj_cancel2",timeValue.dnum,timeValue.bnum)
            end

            gConfirmCancel(tipWord, function()
                -- Net.sendMiningCancelPro(self.endTime,self.needTime)
                Net.sendMiningCancelPro(self.endTime)
            end)
        end
    elseif target.touchName == "btn_finish_pro" then
        local leftMin = math.ceil((self.endTime - gGetCurServerTime()) / 60)
        if leftMin < 0 then
            leftMin = 1
        end
        local needDia = math.ceil(leftMin / DB.getMiningImFinishParam())
        if not NetErr.isDiamondEnough() then
            return
        end

        local tipWord = gGetWords("mineWords.plist", "txt_im_finish_project", needDia)
        gConfirmCancel(tipWord, function()
            Net.sendMiningImFinishPro(self.endTime)
        end)
    end
end

function MineProjectItem:initItem(projInfo)
    self.depth      = projInfo.depth
    self.needTime   = projInfo.needTime
    self.endTime    = projInfo.endTime
    self.status = projInfo.status
    if self.status == MINE_PROJ_STATUS_FREE then
        self:getNode("panel_free_project"):setVisible(true)
        self:getNode("panel_dig_project"):setVisible(false)
        self:getNode("panel_lock_project"):setVisible(false)
    elseif self.status == MINE_PROJ_STATUS_FINSIH or self.status == MINE_PROJ_STATUS_DOING or self.status == MINE_PROJ_STATUS_WAIT then
        self:getNode("panel_free_project"):setVisible(false)
        self:getNode("panel_dig_project"):setVisible(true)
        self:getNode("panel_lock_project"):setVisible(false)
        self:initNormalProj()
    elseif self.status == MINE_PROJ_STATUS_LOCK then
        self:getNode("panel_free_project"):setVisible(false)
        self:getNode("panel_dig_project"):setVisible(false)
        self:getNode("panel_lock_project"):setVisible(true)

        local vipLimit = Data.vip["mineProj"..self.idx].getMaxUseTimes()
        self:setLabelString("txt_project_vip_lock", gGetWords("labelWords.plist","lab_project_vip_lock",vipLimit))
    end
end

function MineProjectItem:initNormalProj()
    local terrainTex = "images/ui_digmine/proj_terrain"..self.depth..".png"
    self:changeTexture("icon_terrain",terrainTex)

    local projTimeInfo,depthIdx,timeIdx = gDigMine.getProjTimeInfoByDepth(self.depth,self.needTime)

    if nil ~= projTimeInfo then
        self:setLabelString("txt_ terrain_depth", gGetWords("labelWords.plist","lab_mine_layer_lv"..depthIdx,timeIdx))
    end
    if self.status == MINE_PROJ_STATUS_FINSIH then
        self:getNode("btn_finish"):setVisible(true)
        self:getNode("panel_lefttime"):setVisible(false)
        self:getNode("panel_waitting"):setVisible(false)
    elseif self.status == MINE_PROJ_STATUS_DOING then
        self:getNode("btn_finish"):setVisible(false)
        self:getNode("panel_lefttime"):setVisible(true)
        self.progressTimer = cc.ProgressTimer:create(cc.Sprite:create("images/ui_digmine/shigong.png"))
        -- self.progressTimer:setAnchorPoint(cc.p(0.5,0.5))
        self:getNode("panel_lefttime"):addChild(self.progressTimer)
        self:getNode("bar_lefttime"):setVisible(false)
        self.progressTimer:setPosition(self:getNode("bar_lefttime"):getPosition())
        self.progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.progressTimer:setMidpoint(cc.p(0,0))
        self.progressTimer:setBarChangeRate(cc.p(1, 0))
        self.progressTimer:setPercentage(0)
        self:getNode("panel_waitting"):setVisible(false)
    else
        self:getNode("btn_finish"):setVisible(false)
        self:getNode("panel_lefttime"):setVisible(false)
        self:getNode("panel_waitting"):setVisible(true)
        self:setLabelString("txt_waitting", gGetWords("labelWords.plist","lab_project_waitfor"))
    end
end

function MineProjectItem:initSchedule()
    --是否要实时刷新呢？
    local function update()
        if  self.endTime - gGetCurServerTime() > 0 then
            local leftTime = self.endTime - gGetCurServerTime()
            local rate = 1 - leftTime/ (self.needTime * 60)
            self.progressTimer:setPercentage(math.floor(rate * 100))
            local posX,posY = self.progressTimer:getPosition()
            local contentSize = self.progressTimer:getContentSize()
            local boundingBox = self:getNode("item_drill"):getBoundingBox()
            self:getNode("item_drill"):setPosition(posX + contentSize.width *(rate - 0.5) + math.floor((boundingBox.width / 4)*0.83),posY + math.floor((boundingBox.height / 4)*0.9))
            self:setLabelString("txt_lefttime", gParserHourTime(leftTime))
            self:getNode("txt_lefttime"):enableOutline(cc.c4b(0,0,0,255), 22 * 0.1)
        else
            self.status = MINE_PROJ_STATUS_FINSIH
            self:getNode("btn_finish"):setVisible(true)
            self:getNode("panel_lefttime"):setVisible(false)
            gDigmine.setHasFinProj(true)
            gDispatchEvt(EVENT_ID_MINING_FINPROJ)
            self:unscheduleUpdateEx()
        end
    end

    if self.status == MINE_PROJ_STATUS_DOING then
        self:scheduleUpdate(update, 1)
    end
end

function MineProjectItem:onUILayerExit()
    if nil ~= self.super then
        self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

return MineProjectItem