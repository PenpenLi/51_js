local DigMinePanel=class("DigMinePanel",UILayer)
function DigMinePanel:ctor(init,rePopUp)
    -- self.appearType = 1
    if(cc.FileUtils:getInstance():isFileExist("packer/images_mine_001.plist"))then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_mine_001.plist")
    end

    if(cc.FileUtils:getInstance():isFileExist("packer/images_bg_007_bg7_.plist"))then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_bg_007_bg7_.plist")
    end

    self:init("ui/ui_dig_mine.map")
    loadFlaXml("b007")
    self:getNode("btn_thumb").__touchend=true
    self.isMove = false
    self.resetLefttime = 0
    self:initBg()
    self:initSchedule()
    self:setSliderPosByScale()
    self:initLabelInfo()
    self:initMptRecoverTime()
    self:initEffectWordPos()
    self:initBtnStatus()
    self:setMptBarDurable()
    self:initPaoPaoShow()
    self:initAtalsBtn()
    self:initScrollConfig()
    self:initIconScroll()

    if init then
        self:initMineDisplay()
    else
        self:initLabelInfo()
        self:checkBtnWorkShopRedPos()
        self:updateBgLayer(rePopUp)
    end
    --TOCHECK,战斗回来要做一下雕像爆炸的效果，以及清除相关信息
    if rePopUp and Battle.win == 1 then
        --TODO 清理雕像
        self.bgLayer:removeStatue(gDigMine.statusFightPos.x,gDigMine.statusFightPos.y)
        --重置一下标记
        Battle.win = 0
        if #gDigMine.statueLightMine ~= 0 then
            self:setTipIconLayout()
            self:lightMine(gDigMine.statueLightMine)
        end
    end
    -- DisplayUtil.setGray(self:getNode("icon_miner"), true)
    Unlock.checkFirstEnter(SYS_MINE);

    if(self:getNode("tip_txt_pickax_num"))then
        self:getNode("tip_txt_pickax_num"):setVisible(gIsZhLanguage());
    end
    self:resetLayOut();
end

function DigMinePanel:initLabelInfo()
    --耐久度
    self:setPickaxInfo()
    --雷管数量
    self:setLabelString("txt_detonator_num",string.format("x%d", Data.getItemNum(ITEM_DETONATOR)))
    --雕像等级
    self:setLabelString("txt_statue_lv", string.format("%s%d",getLvReviewName("LV:"),gDigMine.statusLv))
    --重置按钮的显示
    self:initResetBtn()
    --矿工数
    self:setLabelString("txt_miner", string.format("%d/%d",gDigMine.miner - gDigMine.busyMiner, gDigMine.miner))
end

function DigMinePanel:initBg()
    local panelSize = self:getContentSize()
    local winSize = cc.Director:getInstance():getWinSizeInPixels()
    if gIsAndroid() then
        self:replaceNode("bg_container", cc.Sprite:create("images/ui_digmine/digmine_bg_s.png"))
        local containerSize = self:getNode("bg_container"):getContentSize()
        local scaleX = winSize.width/self:getNode("bg_container"):getContentSize().width
        local scaleY = winSize.height/self:getNode("bg_container"):getContentSize().height
        self.containerScale = math.max(scaleX,scaleY) + 0.1
        self:getNode("bg_container"):setScale( self.containerScale)
    else
        local fla = gCreateFla("b007", 1)
        fla:getBone("bg7_bg_03"):getDisplayManager():setVisible(false)
        fla:getBone("bg7_bg_02"):getDisplayManager():setVisible(false)
        fla:getBone("bg7_01"):getDisplayManager():setVisible(false)
        fla:getBone("bg7_010"):getDisplayManager():setVisible(false)
        self:replaceNode("bg_container", fla)
    end

    local mineMapLayer = MineMapLayer.new(ICON_MINE_WIDTH * gDigMine.xRange, ICON_MINE_HEIGHT * gDigMine.yRange)
    if nil ~= mineMapLayer then
        gDigMine.districtScale = self:getBgScale()
        self.bgLayer = mineMapLayer
        -- if not gDigMine.hasInit then
            -- self.bgLayer:setPosition(cc.p(panelSize.width / 2, 0))
        self.bgLayer:initLayerScale(gDigMine.districtScale)
        self:initBgContainerScale()
        -- end
        self.bgLayer:removeEffectNode()
        self:addChild(self.bgLayer, 0)
        self:addTouchNode(self.bgLayer,"mineBg",nil,nil,0)
        self.bgLeftLimit =  math.floor(gDigMine.districtScale * ICON_MINE_WIDTH * gDigMine.xRange / 2) - gGetScreenWidth() / 2 + panelSize.width / 2
        self.bgBottomLimit = math.floor(gDigMine.districtScale * ICON_MINE_HEIGHT * gDigMine.yRange) -  gGetScreenHeight()
        self.bgTopLimit = -(0 - math.floor((winSize.height - panelSize.height) / 2))
        self.bgRightLimit = panelSize.width / 2 - math.floor(gDigMine.districtScale * ICON_MINE_WIDTH * gDigMine.xRange / 2) + gGetScreenWidth() / 2
    end
end

function DigMinePanel:initSchedule()
    local function update()
        local curServerTime = gGetCurServerTime()
        if self.resetLefttime ~= nil and self.resetLefttime > 0 then
            self.resetLefttime = gDigMine.retime - curServerTime
            self:refreshResetTime()
        end

        if( curServerTime - Data.mptTime > DB.getMiningPointCheckTime())then
            Data.mptTime = curServerTime
            Net.sendSystemRetime(2) --矿区点数
        end

        self:setMptBarDurable()

        -- local shouldLayout = false
        -- if self:getNode("icon_mermaid_buy"):isVisible() then
        --     self:setMermaidBuyIcon()
        --     shouldLayout = true
        -- end

        -- if self:getNode("icon_lucky_wheel"):isVisible() then
        --     self:setLuckyWheelIcon()
        --     shouldLayout = true
        -- end

        -- if self:getNode("icon_black_market"):isVisible() then
        --     self:setBlackMarketIcon()
        --     shouldLayout = true
        -- end

        -- if shouldLayout then
        --     self:getNode("layout_icon"):layout()
        -- end
        if nil ~= self.scroll then
            local bOper = self:setEventTipIcon()
            self:updateMinerTipIcon()
            if bOper then
                self.scroll:layout(false)
            end
        end
    end

    self:scheduleUpdate(update, 1)
end

function DigMinePanel:onTouchBegan(target,touch, event)
    self.isMove = false
    self.sliderMove = false
    local locationInBg = self.bgLayer:convertToNodeSpace(touch:getLocation())
    self:refreshCoordShow(locationInBg)
    -- print("DigMinePanel:onTouchBegan pos is:",self.bgLayer:getPosition())
    return true
end

function DigMinePanel:onTouchMoved(target, touch, event)
    local diff = touch:getDelta()
    local offsetX=touch:getDelta().x
    if target.touchName == "btn_thumb" then
        self:processSliderMove(diff.y)
        return 
    end
    if math.abs(diff.x) < 5 and math.abs(diff.y) < 5 then
        return
    end
    -- print("diff x is:",diff.x, "diff y is:",diff.y)
    self.isMove = true
    local currentPosX, currentPosY = self.bgLayer:getPosition()
    diff.x, diff.y = self:checkLighMineLimitForMove(diff.x,diff.y)
    local newPosX = currentPosX + diff.x
    local newPosY = currentPosY + diff.y
    if newPosY <= self.bgTopLimit then
        newPosY = self.bgTopLimit
    end

    if newPosY >= self.bgBottomLimit then
        newPosY = self.bgBottomLimit
    end

    if newPosX >= self.bgLeftLimit then
        newPosX = self.bgLeftLimit
    end

    if newPosX <= self.bgRightLimit then
        newPosX = self.bgRightLimit
    end
    self.bgLayer:setPositionByMove(newPosX, newPosY)
end

function DigMinePanel:onTouchEnded(target, touch, event)
    if self.isMove then
        self.isMove = false
    elseif target.touchName == "btn_close" then
        if self.bgLayer:isExploding() then
            return
        end
        self:onClose()
    elseif target.touchName == "btn_recover" then
        Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true) -- 2-->TOOL_TAG
    elseif target.touchName == "btn_depot" then
        Panel.popUpVisible(PANEL_MINE_DEPOT,1,nil,true) -- 1-->MINE_TAG
    elseif target.touchName == "btn_workshop" then
        -- Panel.popUpVisible(PANEL_MINE_WORKSHOP,nil,nil,true) -- 1-->MINE_TAG
        Net.sendMiningProjInfo()
        -- gDigMine.setTorpedoExploderMines()
        -- self.bgLayer:processTorpedoExplode()
    elseif target.touchName == "btn_reset" then --TODO,先不弹框
        if gDigMine.canReset(MINE_RESET_BY_HAND) then
            gConfirmCancel(gGetWords("labelWords.plist","lab_mine_reset_content"),function()
                Net.sendMiningReset(MINE_RESET_BY_HAND)
            end)
        else
            gShowNotice(gGetWords("labelWords.plist","lab_mine_reset_warning") )
        end
    elseif target.touchName == "btn_scale_sub" then
        gDigMine.districtScale = gDigMine.districtScale - 0.1
        if gDigMine.districtScale < 0.5 then
            gDigMine.districtScale = 0.5
        end
        self.bgLayer:setLayerScale(gDigMine.districtScale)
        self:setSliderPosByScale()
        self:processBgContainerScale()
    elseif target.touchName == "btn_scale_add" then
        gDigMine.districtScale = gDigMine.districtScale + 0.1
        if gDigMine.districtScale > 1.0 then
            gDigMine.districtScale = 1.0
        end
        self.bgLayer:setLayerScale(gDigMine.districtScale)
        self:setSliderPosByScale()
        self:processBgContainerScale()
    -- elseif target.touchName == "btn_showall" then
    --     gDigMine.hasInit = false
    --     Net.sendMiningInfo(1,true)
    elseif  target.touchName=="btn_rule" then
        gShowRulePanel(SYS_MINE)
    elseif target.touchName=="btn_exchange" then
        Net.sendMiningExInfo(false)
    elseif target.touchName == "icon_mermaid_buy" then
        self:clickMermaidBuyIcon()
    elseif target.touchName == "icon_black_market" then
        self:clickBlackMarketIcon()
    elseif target.touchName == "icon_lucky_wheel" then
        self:clickLuckyWheelIcon()
    elseif target.touchName == "btn_mine_atlas" then
        local limLv = DB.getMiningAtlasLvLim()
        if limLv <= Data.getCurLevel() then
            Net.sendMiningChapList()
        else
            gShowNotice(gGetWords("mineWords.plist","txt_lv_unlock_atlas",limLv))
        end
    elseif target.touchName == "btn_buy_miner" then
        Net.sendMiningMinerInfo(1)
    elseif target.touchName == "layer_bottom" then
        --do nothing
    elseif self.sliderMove then
        self:processSlideTouchEnd()
    elseif (not self.bgLayer:isExploding()) and gDigMine.hasUngetMineInPos(self.touchPosX,self.touchPosY) then
        if gDigMine.isSendMiningGet and gDigMine.sendMiningGetTime ~= 0 then
            if gGetCurServerTime() - gDigMine.sendMiningGetTime > 10 then
                gDigMine.isSendMiningGet = false
                gDigMine.sendMiningGetTime = 0
                Net.posOfGetMining = nil
            end
        end
        if (not self.bgLayer:isExploding()) and (not gDigMine.isSendMiningGet) and gDigMine.canGetMine(self.touchPosX,self.touchPosY) then
            self.getMinePosX = self.touchPosX
            self.getMinePosY = self.touchPosY
            -- print("gDigMine.hasUngetMine() coming posX is:", self.touchPosX, "posY is:", self.touchPosY)
            -- local posKey = string.format("%d_%d",self.touchPosX, self.touchPosY)
            -- local tempTest = gDigMine.digingOrUngetInfoList[posKey]
            -- if nil ~= tempTest then
            --     print("temp test id is:",tempTest.itemid, " lefttime is:", tempTest.lefttime)
            -- end
            Net.sendMiningGet(self.touchPosX,self.touchPosY)
        end
    elseif gDigMine.hasDigingMineInPos(self.touchPosX,self.touchPosY) then
            --Do nothing
     elseif (not self.bgLayer:isExploding()) and (not gDigMine.isLimitToDig(self.touchPosX,self.touchPosY)) then--TODO,是否还需要判断正在exploding
        if gDigMine.getMineTypeByPos(self.touchPosX,self.touchPosY) == MINE_STATUE then
            if gDigMine.checkEmpty(self.touchPosX,self.touchPosY) then
                self:setMiddlePosOfDig()
                gDigMine.setstatusFightPos(self.touchPosX,self.touchPosY)
                Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ATLAS_MINING_STATUS)
            else
                gShowNotice(gGetCmdCodeWord(CMD_MINING_EXPLODER,26))
            end
        elseif gDigMine.isEventTerrain(self.touchPosX,self.touchPosY) then
            if gDigMine.checkEmpty(self.touchPosX,self.touchPosY) then
                if self:canDigMine(self.touchPosX,self.touchPosY) then
                    self:setMiddlePosOfDig()
                    gDigMine.setEventTerrainPos(self.touchPosX,self.touchPosY)
                    self:sendMineEventMsg(self.touchPosX,self.touchPosY)
                end
            else
                gShowNotice(gGetCmdCodeWord(CMD_MINING_EXPLODER,26))
            end 
        elseif gDigMine.getMineTypeByPos(self.touchPosX,self.touchPosY) ~= MINE_TERRAIN_TYPE0 and 
                gDigMine.getMineTypeByPos(self.touchPosX,self.touchPosY) ~= nil then
            if gDigMine.checkEmpty(self.touchPosX,self.touchPosY) then
                gDigMine.setDigingPos(self.touchPosX,self.touchPosY)
                local key = string.format("%d_%d",self.touchPosX,self.touchPosY)
                local dTime = DB.getDigingTimeForMine(gDigMine.data[key])
                if gDigMine.isNeedDetonatorForDiging(self.touchPosX,self.touchPosY) then
                    --弹对话框
                    if (not self.bgLayer:isExploding()) and (not Panel.isOpenPanel(PANEL_GET_REWARD)) then
                        local needNums = DB.getDetonatorCostByMine(gDigMine.data[key])
                        local name     = DB.getMineNameByMineType(gDigMine.data[key])
                        if needNums > Data.getItemNum(ITEM_DETONATOR) then
                            gConfirmCancel(gGetWords("labelWords.plist","lab_dig_detonator_num_limit",name,needNums,Data.getItemNum(ITEM_DETONATOR)), function()
                                Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
                            end)
                        else
                            gConfirmCancel(gGetWords("labelWords.plist","lab_mine_use_detonator",needNums,name), function()
                                if gDigMine.data[key] ~= nil and gDigMine.data[key] ~= MINE_TERRAIN_TYPE0 then
                                    Net.sendMiningExploder(self.touchPosX,self.touchPosY)
                                end
                            end)
                        end
                    end
                elseif not self:canDigMine(self.touchPosX,self.touchPosY) then
                    return
                elseif dTime >= 20 * 60 then
                    gConfirmCancel(gGetWords("labelWords.plist","lab_mine_dig_time_limit",DB.getMineNameByMineType(gDigMine.data[key]), gGetTimesDescBySec(dTime)), function()
                        Net.sendMiningDig(self.touchPosX,self.touchPosY)
                    end)
                else
                    self:setMiddlePosOfDig()
                    Net.sendMiningDig(self.touchPosX,self.touchPosY)
                end            
            else
               gShowNotice(gGetCmdCodeWord(CMD_MINING_EXPLODER,26))    
            end
        end
    end
end

function DigMinePanel:refreshCoordShow(locationInBg)
    --TODO
    self.touchPosX = math.floor(locationInBg.x / ICON_MINE_WIDTH) - gDigMine.maxX
    self.touchPosY = gDigMine.maxY - math.floor(locationInBg.y / ICON_MINE_HEIGHT) + gDigMine.minY
    self:setPosLabelInfo(self.touchPosX, self.touchPosY)
    -- print("not scale touchX is:", math.floor(locationInBg.x / ICON_MINE_WIDTH) - gDigMine.maxX, locationInBg.x, gDigMine.maxX)
    -- print("not scale touchY is:", math.floor(locationInBg.x / ICON_MINE_HEIGHT) + gDigMine.minY,locationInBg.y,gDigMine.maxY,gDigMine.minY)

    -- self.touchPosX = math.floor(locationInBg.x / math.floor(ICON_MINE_WIDTH * 0.7)) - gDigMine.maxX
    -- self.touchPosY = gDigMine.maxY - math.floor(locationInBg.y / math.floor(ICON_MINE_HEIGHT*0.7)) + gDigMine.minY
    -- self:getNode("txt_coordinate"):setString(string.format("X:%d Y:%d", self.touchPosX, self.touchPosY))
    -- print("scale touchX is:", math.floor(locationInBg.x / math.floor(ICON_MINE_WIDTH*0.7)) - gDigMine.maxX, locationInBg.x,gDigMine.maxX)
    -- print("scale touchY is:", math.floor(locationInBg.y / math.floor(ICON_MINE_HEIGHT*0.7)) + gDigMine.minY,locationInBg.y,gDigMine.maxY,gDigMine.minY)
end

function DigMinePanel:events()
    return {
                EVENT_ID_MINING_INIT,
                EVENT_ID_MINING_DIG,
                EVENT_ID_MINING_GET,
                EVENT_ID_MINING_EXPLODER,
                EVENT_ID_USER_DATA_UPDATE,
                EVENT_ID_MINING_NEW_PROJ,
                EVENT_ID_MINING_UPDATE,
                EVENT_ID_MINING_PROJINFO,
                EVENT_ID_MINING_FINPROJ,
                EVENT_ID_MINING_EX_INFO,
                EVENT_ID_MINING_RETIME,
                EVENT_ID_MINING_EVENT,
                EVENT_ID_MINING_ICON_REFRESH,
                EVENT_ID_MINING_PICKAX_SUPPLEMENT,
                EVENT_ID_MINING_REFRESH_EXPLODER,
                EVENT_ID_MINING_BUY_MINERS,
                EVENT_ID_MINING_REFRESH_NEWICON,
                EVENT_ID_MINING_CLICK_TIPICON,
            }
end

function DigMinePanel:dealEvent(event,param)
    if event == EVENT_ID_MINING_INIT then
        self:initMineDisplay()
        self:initIconScroll()
    elseif event == EVENT_ID_MINING_DIG then
        self:createWordEffect()
        self:setPickaxInfo()
        self:lightMine(param[1])
        self:setTipIconLayout()
        self:statueTipIconAction()
        self.bgLayer:processDiging(param[2].x, param[2].y)
        self:setMptRecoverTime()
    elseif event == EVENT_ID_MINING_GET then
        self:createWordEffect()
        self:setPickaxInfo()
        self:getMine(param.x, param.y)
    elseif event == EVENT_ID_MINING_EXPLODER then
        --更新雷管数量
        self:setLabelString("txt_detonator_num",string.format("x%d", Data.getItemNum(ITEM_DETONATOR)))
        --处理雷管爆炸效果
        self.bgLayer:processExploder(param[2].x, param[2].y)
        self:lightMine(param[1])
        self:setTipIconLayout()
    elseif event == EVENT_ID_USER_DATA_UPDATE or event == EVENT_ID_MINING_NEW_PROJ then
        self:setLabelString("txt_detonator_num",string.format("x%d", Data.getItemNum(ITEM_DETONATOR)))
        self:setPickaxInfo()
        self:setMptRecoverTime()
    elseif event == EVENT_ID_MINING_UPDATE then
        self:initLabelInfo()
        self:checkBtnWorkShopRedPos()
        self:updateBgLayer()
    elseif event == EVENT_ID_MINING_PROJINFO or event == EVENT_ID_MINING_FINPROJ then
        self:checkBtnWorkShopRedPos()
    elseif event == EVENT_ID_MINING_EX_INFO then
        if not Net.isMiningExPanelOpen then
            Panel.popUpVisible(PANLE_MINE_EXCHANGE,nil,nil,true)
        end
    elseif event == EVENT_ID_MINING_RETIME then
        self:setBarPer("bar_durable", 0)
        self.mptRecoverTime = gDigMine.mptRecoverTime
    elseif event == EVENT_ID_MINING_EVENT then
        self:processEvent(param)
    elseif event == EVENT_ID_MINING_ICON_REFRESH then
        self:refrehIcon(param)
    elseif event == EVENT_ID_MINING_PICKAX_SUPPLEMENT then
        self:setPickaxInfo()
    elseif event == EVENT_ID_MINING_REFRESH_EXPLODER then
        self.bgLayer:refreshExploderFlag(param)
    elseif event == EVENT_ID_MINING_BUY_MINERS then
        self:setLabelString("txt_miner", string.format("%d/%d", gDigMine.miner - gDigMine.busyMiner, gDigMine.miner))
    elseif event == EVENT_ID_MINING_REFRESH_NEWICON then
        self:refreshMinerTipIcon(param)
    elseif event == EVENT_ID_MINING_CLICK_TIPICON then
        self:clickTipIcon(param)
    end
end

function DigMinePanel:initMineInfo()
    local panelSize = self:getContentSize()
    -- self.bgLayer:setPosition(cc.p(panelSize.width / 2, 0))
    self.bgLayer:initMineInfo()
end

function DigMinePanel:initResetBtn()
    self.resetLefttime = gDigMine.retime - gGetCurServerTime()
    if self.resetLefttime > 0 then
        self:getNode("panel_reset_left"):setVisible(true)
        self:getNode("txt_normal_reset"):setVisible(false)
    else
        self:getNode("txt_normal_reset"):setVisible(true)
        self:getNode("panel_reset_left"):setVisible(false)
    end
end

function DigMinePanel:refreshResetTime()
    if self.resetLefttime == nil then
        self.resetLefttime = gDigMine.retime - gGetCurServerTime()
    end

    if self.resetLefttime <= 0 then
        self:getNode("txt_normal_reset"):setVisible(true)
        self:getNode("panel_reset_left"):setVisible(false)
    else
        self:setLabelString("txt_reset_lefttime", gParserHourTime(self.resetLefttime))
    end    
end

function DigMinePanel:canDigMine(posX,posY)
    return gDigMine.canDigMine(posX, posY)
end

function DigMinePanel:lightMine(data)
    self.bgLayer:lightMine(data)
end

function DigMinePanel:initMineDisplay()
    self:initMineInfo()
    self:initLabelInfo()
    self:checkBtnWorkShopRedPos()
end

function DigMinePanel:getMine(x, y)
    self.bgLayer:getMine(x,y)
end

function DigMinePanel:setPosLabelInfo(x,y)
    if isBanshuReview() then
        self:getNode("txt_posx"):setString(string.format("横:%d",x))
        self:getNode("txt_posy"):setString(string.format("竖:%d",y))
    else
        self:getNode("txt_posx"):setString(string.format("X:%d",x))
        self:getNode("txt_posy"):setString(string.format("Y:%d",y))
    end
end

function DigMinePanel:setStatueInfo()
    if gDigMine.getStatueCount() ~= 0 then
        self:getNode("icon_statue"):setVisible(true)
        self:setLabelString("txt_statue_num", gDigMine.getStatueCount())
    else
        self:getNode("icon_statue"):setVisible(false)
    end
end

function DigMinePanel:statueTipIconAction()
    if gDigMine.getStatueCount() ~= 0 then
        local actionBy1 = cc.RotateBy:create(0.05 , 5)
        local easeBack1   = cc.EaseIn:create(actionBy1, 1.0)
        -- local tintBy1 = cc.TintBy:create(0.05, -100,-127,-127)
        local tintBy1 = cc.TintTo:create(0.05,200,0,0)
        local spawn1  = cc.Spawn:create(easeBack1,tintBy1)

        local actionBy2 = cc.RotateBy:create(0.1 , -10)
        local easeBack2   = cc.EaseIn:create(actionBy2, 1.0)
        -- local tintBy2 = cc.TintBy:create(0.1, -55,-128,-128)
        local tintBy2 = cc.TintTo:create(0.05,255,0,0)
        local spawn2  = cc.Spawn:create(easeBack2,tintBy2)
        
        local actionBy3 = cc.RotateBy:create(0.05 , 5)
        local easeBack3   = cc.EaseOut:create(actionBy3, 1.0)
        local delayTime = cc.DelayTime:create(0.1)
        -- local tintBy3 = cc.TintBy:create(0.1, 155,255,255)
        local tintBy3 = cc.TintTo:create(0.1, 255,255,255)
        self:getNode("panel_statis_value"):setAllChildCascadeOpacityEnabled(true)
        self:getNode("panel_statis_value"):runAction(cc.Sequence:create(spawn1,spawn2,easeBack3,tintBy3,spawn1:clone(),spawn2:clone(),easeBack3:clone(),delayTime,tintBy3:clone()))
        
        local icon = self:getTipIconByType(MINE_DIG_ICON1)
        if nil ~= icon then
            icon:getNode("icon"):runAction(cc.Sequence:create(spawn1:clone(),spawn2:clone(),easeBack3:clone(),tintBy3:clone(),spawn1:clone(),spawn2:clone(),easeBack3:clone(),delayTime,tintBy3:clone()))
        end
    end
end

function DigMinePanel:adjustMineLayerPosAfterScale()
    local panelSize = self:getContentSize()
    local winSize = cc.Director:getInstance():getWinSizeInPixels()
    self.bgLeftLimit =  math.floor(gDigMine.districtScale * ICON_MINE_WIDTH * gDigMine.xRange / 2) - gGetScreenWidth() / 2 + panelSize.width / 2
    self.bgBottomLimit = math.floor(gDigMine.districtScale * ICON_MINE_HEIGHT * gDigMine.yRange) -  gGetScreenHeight()
    self.bgTopLimit = -(0 - math.floor((winSize.height - panelSize.height) / 2))
    self.bgRightLimit = panelSize.width / 2 - math.floor(gDigMine.districtScale * ICON_MINE_WIDTH * gDigMine.xRange / 2) + gGetScreenWidth() / 2
    local newPosX,newPosY = self.bgLayer:getPosition()
    if newPosY <= self.bgTopLimit then
        print("newPosY is:",newPosY,self.bgTopLimit)
        newPosY = self.bgTopLimit
    end

    if newPosY >= self.bgBottomLimit then
        newPosY = self.bgBottomLimit
    end

    if newPosX >= self.bgLeftLimit then
        newPosX = self.bgLeftLimit
    end

    if newPosX <= self.bgRightLimit then
        newPosX = self.bgRightLimit
    end
    -- self.bgLayer:setPosition(newPosX,newPosY)
    self.bgLayer:setPositionByMove(newPosX, newPosY)
end

function DigMinePanel:setSliderPosByScale()
    self.sliderMove = false
    local rate = (gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)
    local thumbBtn = self:getNode("btn_thumb")
    local posX,posY = thumbBtn:getPosition()
    local thubmSize = thumbBtn:getContentSize()
    local contentSize = self:getNode("panel_slider"):getContentSize()
    posY = (contentSize.height - thubmSize.height) * rate
    self:getNode("btn_thumb"):setPosition(posX,posY)
end

function DigMinePanel:processSliderMove(diffY)
    self.sliderMove = true
    local thumbBtn = self:getNode("btn_thumb")
    local sliderPanel = self:getNode("panel_slider")
    local posX,posY = thumbBtn:getPosition()
    local endPos = posY + diffY
    local sliderPanelSize = sliderPanel:getContentSize()
    local thumbSize = thumbBtn:getContentSize()
    if endPos < 0 then
        endPos = 0
        if gDigMine.districtScale ~= MINE_DISTRICT_MIN_SCALE then
            gDigMine.districtScale = MINE_DISTRICT_MIN_SCALE
            -- self.bgLayer:setLayerScale(gDigMine.districtScale)
        end
        
    elseif endPos > sliderPanelSize.height - (thumbSize.height) then
        if gDigMine.districtScale ~= MINE_DISTRICT_MAX_SCALE then
            gDigMine.districtScale = MINE_DISTRICT_MAX_SCALE
            -- self.bgLayer:setLayerScale(gDigMine.districtScale)
        end
        endPos = sliderPanelSize.height - (thumbSize.height)
    end
    thumbBtn:setPosition(posX, endPos)
end

function DigMinePanel:processSlideTouchEnd()
    self.sliderMove = false
    --处理缩放
    local btnThumb = self:getNode("btn_thumb")
    local posX,posY = btnThumb:getPosition()
    local thumbContentSize = btnThumb:getContentSize()
    local panelContentSize = self:getNode("panel_slider"):getContentSize()
    local rate = posY / (panelContentSize.height - thumbContentSize.height)
    gDigMine.districtScale =  rate * (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE) + MINE_DISTRICT_MIN_SCALE
    self.bgLayer:setLayerScale(gDigMine.districtScale)
    self:processBgContainerScale()
end

function DigMinePanel:locateStatue()
    self.bgLayer:locateStatue()
end

function DigMinePanel:checkLighMineLimitForMove(diffX,diffY)
    local wordldPos = nil
    local nodePos   = nil
    local contentSize = self:getContentSize()
    local xLimit    = diffX
    local yLimit    = diffY
    local posX = (gDigMine.maxX + gDigMine.minLightX) * ICON_MINE_WIDTH
    local posY = 0

    local wordldPos = self.bgLayer:convertToWorldSpace(cc.p(posX,posY))
    local nodePos  = self:convertToNodeSpace(wordldPos)
    if nodePos.x + diffX > contentSize.width / 2 then -- +
        xLimit = contentSize.width / 2 - nodePos.x
    end

    posX = (gDigMine.maxX + gDigMine.maxLightX) * ICON_MINE_WIDTH
    wordldPos = self.bgLayer:convertToWorldSpace(cc.p(posX,posY))
    nodePos  = self:convertToNodeSpace(wordldPos)
    if nodePos.x + diffX < contentSize.width / 2 then -- -
        xLimit = -(nodePos.x - contentSize.width / 2) 
    end

    posX = 0
    posY = (gDigMine.yRange - gDigMine.maxLightY + gDigMine.minY) * ICON_MINE_HEIGHT
    wordldPos = self.bgLayer:convertToWorldSpace(cc.p(posX,posY))
    nodePos  = self:convertToNodeSpace(wordldPos)
    if nodePos.y + diffY > -contentSize.height / 2 then
        yLimit = -contentSize.height / 2 - nodePos.y
    end
    return xLimit,yLimit
end

function DigMinePanel:checkBtnWorkShopRedPos()
    if gDigMine.getHasFinProj() then
        RedPoint.add(self:getNode("btn_workshop"),cc.p(0.82,0.77))
        Data.redpos.minep = true
    else
        RedPoint.remove(self:getNode("btn_workshop"))
        Data.redpos.minep = false
    end
end

function DigMinePanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:recordMiddlePosOfBg()
    self:recordBgScale()
    self:unscheduleUpdateEx()
    self.bgLayer:processClose()
    self.bgLayer:clearContainer()
end

function DigMinePanel:updateBgLayer(rePopUp)
    self.bgLayer:updateLayerInfo(rePopUp)
end

function DigMinePanel:getGuideItem(name)
    return self.bgLayer:getGuideItem(name)
end

function DigMinePanel:processBgContainerScale()
    if self.containerScale == nil then
        local scale = ((gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)) * 0.3 + 1.0
        local scaleAct = cc.ScaleTo:create(0.5,scale)
        local easeBackInOutAct = cc.EaseExponentialOut:create(scaleAct)
        self:getNode("bg_container"):runAction(easeBackInOutAct)
    else
        local scale = ((gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)) * 0.3 + self.containerScale
        local scaleAct = cc.ScaleTo:create(0.5,scale)
        local easeBackInOutAct = cc.EaseExponentialOut:create(scaleAct)
        self:getNode("bg_container"):runAction(easeBackInOutAct)
    end

    local scale2 = ((gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)) * 0.4 + 1.0
    local scaleAct2 = cc.ScaleTo:create(0.5,scale2)
    local easeBackInOutAct2 = cc.EaseExponentialOut:create(scaleAct2)
    self:getNode("fish1"):runAction(easeBackInOutAct2)
    for i=2,12 do
        self:getNode("fish"..i):runAction(easeBackInOutAct2:clone())
    end
end

function DigMinePanel:recordMiddlePosOfBg()
    if self.recMiddleX == nil then
        return
    end
    local key  = string.format("%d_mine_pos",gUserInfo.id)
    local posValue = string.format("%d_%d",self.recMiddleX,self.recMiddleY)
    cc.UserDefault:getInstance():setStringForKey(key,posValue)
end

function DigMinePanel:setMiddlePosOfDig()
    gDigMine.resetFlag = false
    self.recMiddleX = math.floor((self.bgLayer.showArea.left + self.bgLayer.showArea.right) / 2)
    self.recMiddleY = math.floor((self.bgLayer.showArea.top + self.bgLayer.showArea.bottom) / 2)
end

function DigMinePanel:getRecordMiddlePosOfBg()
    local key = string.format("%d_mine_pos",gUserInfo.id)
    local posValue = cc.UserDefault:getInstance():getStringForKey(key,"")
    if "" == posValue then
        return nil,nil
    else
        local middlePos = string.split(posValue,"_")
        return toint(middlePos[1]),toint(middlePos[2])
    end
end

function DigMinePanel:setPickaxInfo()
    self:setLabelString("txt_pickax_num", gDigMine.getMptFractionStr())
    self:getNode("panel_pickax_num"):layout()
    -- self:setBarPer("bar_durable",gDigMine.mpt/DB.getMaxMiningPoint(Data.getCurVip()))
end

function DigMinePanel:initMptRecoverTime()
    self.mptRecoverTime = gDigMine.getMptRecoverTime()
    if self.mptRecoverTime == 0 or
        self.mptRecoverTime < gGetCurServerTime() then
        self:setBarPer("bar_durable", 0)
    end                
end

function DigMinePanel:setMptRecoverTime()
    if self.mptRecoverTime == 0 and gDigMine.mpt < DB.getMaxMiningPoint(Data.getCurVip()) then
        Data.mptTime = gGetCurServerTime()
        self.mptRecoverTime = Data.mptTime + DB.getMiningPointCheckTime()
        gDigMine.setMptRecoverTime(self.mptRecoverTime)
    elseif self.mptRecoverTime ~= 0 and gDigMine.mpt >= DB.getMaxMiningPoint(Data.getCurVip()) then
        self.mptRecoverTime = 0
        self:setBarPer("bar_durable", 0)
    end
end

function DigMinePanel:createWordEffect()
    local oldTxt = self:getNode("txt_pickax_num"):getString()
    local oldValue = toint(string.split(oldTxt,"/")[1])
    local deduceValue = oldValue - gDigMine.mpt
    if deduceValue == 0 then
        return
    end
    local txtNum = string.format("-%d",deduceValue)
    local labelTxt = gCreateWordLabelTTF(txtNum,gCustomFont,24,cc.c3b(255,0,0))
    labelTxt:enableOutline(cc.c4b(0,0,0,255), 24 * 0.1)
    gAddChildInCenterPos(self:getNode("word_effect_pos"), labelTxt)
    --action
    local moveTo= cc.EaseOut:create(cc.MoveBy:create(0.3,cc.p(0,20)),1)
    local moveTo2= cc.EaseIn:create(cc.MoveBy:create(0.3,cc.p(0,20)),1)
    local moveIn=cc.Spawn:create(cc.FadeIn:create(0.3),moveTo)
    local moveOut=cc.Spawn:create(cc.FadeOut:create(0.3),moveTo2)
    local callFunc=cc.CallFunc:create(function ()
        labelTxt:removeFromParent(true)
    end)
    local retAction= {moveIn,cc.DelayTime:create(0.05),moveOut,callFunc}
    labelTxt:runAction(cc.Sequence:create(retAction))
end

function DigMinePanel:initEffectWordPos()
    local effectWordPos = self:getNode("word_effect_pos")
    local pickaxNumPos  = self:getNode("txt_pickax_num")
    local posX,posY = pickaxNumPos:getPosition()
    local contentSize = pickaxNumPos:getContentSize()
    local wordldPos = self:getNode("panel_pickax_num"):convertToWorldSpace(cc.p(posX,posY))
    local nodePos  = self:convertToNodeSpace(wordldPos)
    effectWordPos:setPosition(nodePos.x + (1/2)*contentSize.width, nodePos.y + (1/2)*contentSize.height)
end

function DigMinePanel:initBtnStatus()
    if Module.isClose(SWITCH_VIP) then
        self:getNode("btn_workshop"):setVisible(false)
    end
end

function DigMinePanel:setLayoutIcon()
    -- self:setStatueInfo()
--    self:setMermaidBuyIcon()
--    self:setLuckyWheelIcon()
--    self:setBlackMarketIcon()
--    self:getNode("layout_icon"):layout()
end

function DigMinePanel:processEvent(lightMine)
    if gDigMine.eventTerrainPos.x == nil then
        return
    end

    local terrainType = gDigMine.getMineTypeByPos(gDigMine.eventTerrainPos.x,gDigMine.eventTerrainPos.y)
    if terrainType == nil then
        return
    end

    self:createWordEffect()
    self:setPickaxInfo()
    self:setTipIconLayout()
    self:statueTipIconAction()
    self.bgLayer:processEvent(terrainType, lightMine)
    self:setMptRecoverTime()
end

function DigMinePanel:sendMineEventMsg(x,y)
    local terrainType = gDigMine.getMineTypeByPos(x,y)
    if terrainType == MINE_EVENT1 then
        Net.sendMiningEvent1(x, y)
    elseif terrainType == MINE_EVENT2 then
        Net.sendMiningEvent2(x, y)
    elseif terrainType == MINE_EVENT3 then
        Net.sendMiningEvent3(x, y)
    elseif terrainType == MINE_EVENT5 then
        Net.sendMiningEvent5(x, y)
    elseif terrainType == MINE_EVENT6 or terrainType == MINE_EVENT7 then
        Net.sendMiningEvent67(x, y)
    elseif terrainType == MINE_EVENT8 then
        Net.sendMiningEvent8(x, y)
    elseif terrainType == MINE_EVENT9 then
        Net.sendMiningEvent9(x, y)
    elseif terrainType == MINE_EVENT4 then
        Net.sendMiningEvent4(x, y)
    end
end

function DigMinePanel:refrehIcon(param)
    if param == MINE_EVENT3 then
        if (self:setLuckyWheelTipIcon()) then
            self.scroll:layout(false)
        end
    elseif param == MINE_EVENT9 then
        if (self:setBlackMarketTipIcon()) then
            self.scroll:layout(false)
        end
    end
end

function DigMinePanel:clickMermaidBuyIcon()
    if self:getNode("txt_mermaid_buy_lefttime"):isVisible() then
        Panel.popUpVisible(PANEL_MINE_MERMAID_BUY,nil,nil,true)
    else
        self.bgLayer:locateEventPos(MINE_EVENT2)
    end
end

function DigMinePanel:clickBlackMarketIcon()
    if self:getNode("txt_black_market_lefttime"):isVisible() then
        Panel.popUpVisible(PANEL_MINE_BLACK_MARKET,nil,nil,true)
    else
        self.bgLayer:locateEventPos(MINE_EVENT9)
    end
end

function DigMinePanel:clickLuckyWheelIcon()
    if self:getNode("txt_lucky_wheel_lefttime"):isVisible() then
        Panel.popUpVisible(PANEL_MINE_LUCKY_WHEEL,nil,nil,true)
    else
        self.bgLayer:locateEventPos(MINE_EVENT3)
    end
end

function DigMinePanel:setMptBarDurable()
    if nil ~= self.mptRecoverTime and self.mptRecoverTime ~= 0 then
        if self.mptRecoverTime > gGetCurServerTime() then
            local recoverTime = self.mptRecoverTime - gGetCurServerTime()
            local rate = 1 - (self.mptRecoverTime - gGetCurServerTime()) / DB.getMiningPointCheckTime()
            self:setBarPer("bar_durable", rate)
        end
    end
end

function DigMinePanel:initPaoPaoShow()
    if gIsAndroid() then
        for i = 1, 7 do
            self:getNode(string.format("paopao_%d",i)):pause()
            self:getNode(string.format("paopao_%d",i)):setVisible(false)
        end
    end
end

function DigMinePanel:initBgContainerScale()
    if self.containerScale == nil then
        local scale = ((gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)) * 0.3 + 1.0
        self:getNode("bg_container"):setScale(scale)
    else
        local scale = ((gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)) * 0.3 + self.containerScale
        self:getNode("bg_container"):setScale(scale)
    end

    local scale2 = ((gDigMine.districtScale - MINE_DISTRICT_MIN_SCALE) / (MINE_DISTRICT_MAX_SCALE - MINE_DISTRICT_MIN_SCALE)) * 0.4 + 1.0
    for i=1,12 do
        self:getNode("fish"..i):setScale(scale2)
    end
end

function DigMinePanel:initAtalsBtn()
    if Module.isClose(SWITCH_MINE_ATLAS) then
        self:getNode("btn_mine_atlas"):setVisible(false)
        self:getNode("layout_right_icon"):layout()
        return
    end

    if DB.getMiningAtlasLvLim() > Data.getCurLevel() then
        local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png")
        lock:setScale(0.8)
        gRefreshNode(self:getNode("btn_mine_atlas"),lock,cc.p(0.75,0.45),cc.p(0,40),100)
    end
end

function DigMinePanel:updateMinerTipIcon()
    if table.count(gDigMine.digingOrUngetInfoList) == 0 or self.scroll == nil then
        return false
    end

    local newIconNode = nil
    local posKey = nil
    local digingOrUngetInfo = nil
    local size = self.scroll:getSize()
    for i = 1, size do
        local tipIcon = self.scroll:getItem(i - 1)
        if tipIcon.type == MINE_DIG_ICON6 and tipIcon.extraInfo ~= nil then
            digingOrUngetInfo = gDigMine.digingOrUngetInfoList[tipIcon.extraInfo]
            if nil ~= digingOrUngetInfo and digingOrUngetInfo.lefttime <= gGetCurServerTime() then
                tipIcon:changeTexture("icon", "images/ui_digmine/kuangshi.png")
                tipIcon.type = MINE_DIG_ICON5
            end
        end
    end
end

function DigMinePanel:refreshMinerTipIcon(param)
    if param.iconType==MINE_DIG_ICON5 or param.iconType==MINE_DIG_ICON6  then
        local key = string.format("%d_%d",param.posX, param.posY)
        local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
        local newIconNode = nil
        if digingOrUngetInfo ~= nil then
            if param.iconType==MINE_DIG_ICON6 then
                local tipIcon = MineDigIconItem.new()
                tipIcon:setData(MINE_DIG_ICON6)
                tipIcon:setExtraInfo(key)
                local tipIconIdx = self:getTipIconIdx(MINE_DIG_ICON6,digingOrUngetInfo.lefttime)
                self.scroll:addItem(tipIcon,tipIconIdx)
                self.scroll:layout(false)
            elseif param.iconType==MINE_DIG_ICON5 then
                local minerIcon = self:getTipIconByType(MINE_DIG_ICON6, key)
                if nil ~= minerIcon then
                    minerIcon:changeTexture("icon", "images/ui_digmine/kuangshi.png")
                    minerIcon.type=MINE_DIG_ICON5
                end
            end
        else
            local minerIcon = self:getTipIconByType(MINE_DIG_ICON6, key) 
            if nil ~= minerIcon then
                self.scroll:removeItem(minerIcon,false)
                return
            end

            minerIcon = self:getTipIconByType(MINE_DIG_ICON5, key)
            if nil ~= minerIcon then
                self.scroll:removeItem(minerIcon,false)
            end
        end
    end 
end

function DigMinePanel:initScrollConfig()
    self.scroll = self:getNode("scroll")
    self.scroll.eachLineNum = 4
    self.scroll.offsetX = 5
    self.scroll.offsetY = 5
    self.scroll:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scroll.responseLayer = self
end

function DigMinePanel:initIconScroll()
    self.scroll:clear()
    self:setStatueTipIcon()
    self:initMermaidBuyTipIcon()
    self:initLuckyWheelTipIcon()
    self:initBlackMarketTipIcon()
    self:initMinerIcons()
    self.scroll:layout()
end

function DigMinePanel:setStatueTipIcon()
    if gDigMine.getStatueCount() ~= 0 then
        local tipIcon = self:getTipIconByType(MINE_DIG_ICON1)
        if nil == tipIcon then
            local statueIcon = MineDigIconItem.new()
            statueIcon:setData(MINE_DIG_ICON1)
            self.scroll:addItem(statueIcon,0)
            return true
        else
            tipIcon:updateNum()
        end
    end

    return false
end

function DigMinePanel:initMermaidBuyTipIcon()
    if gDigMine.getMineEvent2Count() ~= 0 then
        local tipIcon = MineDigIconItem.new()
        tipIcon:setData(MINE_DIG_ICON2, MINE_DIG_ICON2_1)
        self.scroll:addItem(tipIcon)
    elseif gDigMine.getMermaidBuyLeftTime() > gGetCurServerTime() then
        local tipIcon = MineDigIconItem.new()
        tipIcon:setData(MINE_DIG_ICON2, MINE_DIG_ICON2_2)
        self.scroll:addItem(tipIcon)
    end
end

function DigMinePanel:initLuckyWheelTipIcon()
    if gDigMine.getMineEvent3Count() ~= 0 then
        local tipIcon = MineDigIconItem.new()
        tipIcon:setData(MINE_DIG_ICON3, MINE_DIG_ICON3_1)
        self.scroll:addItem(tipIcon)
    elseif gDigMine.getLuckyWheelLeftTime() > gGetCurServerTime() then
        local tipIcon = MineDigIconItem.new()
        tipIcon:setData(MINE_DIG_ICON3, MINE_DIG_ICON3_2)
        self.scroll:addItem(tipIcon)
    end
end

function DigMinePanel:initBlackMarketTipIcon()
    if gDigMine.getMineEvent9Count() ~= 0 then
        local tipIcon = MineDigIconItem.new()
        tipIcon:setData(MINE_DIG_ICON4, MINE_DIG_ICON4_1)
        self.scroll:addItem(tipIcon)
    elseif gDigMine.getBlackMarketLeftTime() > gGetCurServerTime() then
        local tipIcon = MineDigIconItem.new()
        tipIcon:setData(MINE_DIG_ICON4, MINE_DIG_ICON4_2)
        self.scroll:addItem(tipIcon)
    -- else
    --     gDigMine.setBlackMarketLeftTime(0)
    --     self:getNode("icon_black_market"):setVisible(false)
    end
end

function DigMinePanel:initMinerIcons()
    if table.count(gDigMine.digingOrUngetInfoList) == 0 then
        return
    end
    local minerIcons = {}
    for key, digingOrUngetInfo in pairs(gDigMine.digingOrUngetInfoList) do
        table.insert(minerIcons,{key,digingOrUngetInfo})
    end

    table.sort(minerIcons, function(lInfo, rInfo)
            return lInfo[2].lefttime < rInfo[2].lefttime
        end)

    for i = 1, #minerIcons do
        local tipIcon = MineDigIconItem.new()
        if minerIcons[i][2].lefttime > gGetCurServerTime() then
            tipIcon:setData(MINE_DIG_ICON6)
        else
            tipIcon:setData(MINE_DIG_ICON5)
        end
        tipIcon:setExtraInfo(minerIcons[i][1])
        self.scroll:addItem(tipIcon)
    end
end

function DigMinePanel:clickTipIcon(param)
    if param[1] == MINE_DIG_ICON1 then
        self:locateStatue()
    elseif param[1] == MINE_DIG_ICON2 then
        if param[2] == MINE_DIG_ICON2_1 then
            self.bgLayer:locateEventPos(MINE_EVENT2)
        else
            Panel.popUpVisible(PANEL_MINE_MERMAID_BUY,nil,nil,true)
        end
    elseif param[1] == MINE_DIG_ICON3 then
        if param[2] == MINE_DIG_ICON3_1 then
            self.bgLayer:locateEventPos(MINE_EVENT3)
        else
            Panel.popUpVisible(PANEL_MINE_LUCKY_WHEEL,nil,nil,true)
        end
    elseif param[1] == MINE_DIG_ICON4 then
        if param[2] == MINE_DIG_ICON4_1 then
            self.bgLayer:locateEventPos(MINE_EVENT9)
        else
            Panel.popUpVisible(PANEL_MINE_BLACK_MARKET,nil,nil,true)
        end
    elseif param[1] == MINE_DIG_ICON5 or param[1] == MINE_DIG_ICON6 then
        local posKeyTable = string.split(param[3],"_")
        self.bgLayer:locateDigingOrUngetMine(toint(posKeyTable[1]),toint(posKeyTable[2]))
    end
end

function DigMinePanel:getTipIconByType(iconType, extraInfo)
    local size = self.scroll:getSize()
    for i = 1, size do
        local icon = self.scroll:getItem(i - 1)
        if nil ~= icon and icon.type == iconType then
            if extraInfo == nil then
                return icon
            else
                if icon.type == MINE_DIG_ICON5 and icon.extraInfo == extraInfo then
                    return icon
                elseif icon.type == MINE_DIG_ICON6 and icon.extraInfo == extraInfo then
                    return icon
                end
            end
        end
    end

    return nil
end

function DigMinePanel:operateTipIcon(iconType, oper)
    if iconType == MINE_DIG_ICON1 and oper == MINE_DIG_OPE_DEL then
        local tipIcon = self:getTipIconByType(MINE_DIG_ICON1)
        if tipIcon ~= nil then
            if gDigMine.getStatueCount() == 0 then
                self.scroll:removeItem(tipIcon,false)
            else
                tipIcon:updateNum()
            end
        end
    end
end

function DigMinePanel:setTipIconLayout()
    local addStatue = self:setStatueTipIcon()
    local hasEventOper = self:setEventTipIcon()
    -- print("addStatue is:",addStatue," hasEventOper is:",hasEventOper)
    if addStatue or hasEventOper then
        self:getNode("scroll"):layout(false)
    end
end

function DigMinePanel:setEventTipIcon()
    local hasOper1 = self:setMermaidBuyTipIcon()
    local hasOper2 = self:setLuckyWheelTipIcon()
    local hasOper3 = self:setBlackMarketTipIcon()
    return hasOper1 or hasOper2 or hasOper3
end

function DigMinePanel:setMermaidBuyTipIcon()
    local tipIcon = self:getTipIconByType(MINE_DIG_ICON2)
    if nil ~= tipIcon then
        if tipIcon.subType == MINE_DIG_ICON2_1  and gDigMine.getMermaidBuyLeftTime() > gGetCurServerTime()then
            tipIcon.subType = MINE_DIG_ICON2_2
            tipIcon:initTxtShow(MINE_DIG_ICON2, MINE_DIG_ICON2_2)
            return false
        elseif tipIcon.subType == MINE_DIG_ICON2_2 then
            if gDigMine.getMermaidBuyLeftTime() <= gGetCurServerTime() then
                gDigMine.setMermaidBuyLeftTime(0)
                self.scroll:removeItem(tipIcon,false)
                return true
            else
                tipIcon:updateLefttime()
            end
        end
    else
        if gDigMine.getMineEvent2Count() ~= 0 then
            local tipIcon = MineDigIconItem.new()
            tipIcon:setData(MINE_DIG_ICON2, MINE_DIG_ICON2_1)
            local tipIconIdx = self:getTipIconIdx(MINE_DIG_ICON1)
            self.scroll:addItem(tipIcon, tipIconIdx)
            return true
        end
    end

    return false
end

function DigMinePanel:setLuckyWheelTipIcon()
    local tipIcon = self:getTipIconByType(MINE_DIG_ICON3)
    if nil ~= tipIcon then
        if tipIcon.subType == MINE_DIG_ICON3_1  and gDigMine.getLuckyWheelLeftTime() > gGetCurServerTime() then
            tipIcon.subType = MINE_DIG_ICON3_2
            tipIcon:initTxtShow(MINE_DIG_ICON3, MINE_DIG_ICON3_2)
            return false
        elseif tipIcon.subType == MINE_DIG_ICON3_2 then
            if gDigMine.getLuckyWheelLeftTime() <= gGetCurServerTime() then
                gDigMine.setLuckyWheelLeftTime(0)
                self.scroll:removeItem(tipIcon,false)
                return true
            else
                tipIcon:updateLefttime()
            end
        end
    else
        if gDigMine.getMineEvent3Count() ~= 0 then
            local tipIcon = MineDigIconItem.new()
            tipIcon:setData(MINE_DIG_ICON3, MINE_DIG_ICON3_1)
            local tipIconIdx = self:getTipIconIdx(MINE_DIG_ICON2)
            self.scroll:addItem(tipIcon, tipIconIdx)
            return true
        end
    end
    return false
end

function DigMinePanel:setBlackMarketTipIcon()
    local tipIcon = self:getTipIconByType(MINE_DIG_ICON4)
    if nil ~= tipIcon then
        if tipIcon.subType == MINE_DIG_ICON4_1  and gDigMine.getBlackMarketLeftTime() > gGetCurServerTime() then
            tipIcon.subType = MINE_DIG_ICON4_2
            tipIcon:initTxtShow(MINE_DIG_ICON4, MINE_DIG_ICON4_2)
            return false
        elseif tipIcon.subType == MINE_DIG_ICON4_2 then
            if gDigMine.getBlackMarketLeftTime() <= gGetCurServerTime() then
                gDigMine.setBlackMarketLeftTime(0)
                self.scroll:removeItem(tipIcon,false)
                return true
            else
                tipIcon:updateLefttime()
            end
        end
    else
        if gDigMine.getMineEvent9Count() ~= 0 then
            local tipIcon = MineDigIconItem.new()
            tipIcon:setData(MINE_DIG_ICON4, MINE_DIG_ICON4_1)
            local tipIconIdx = self:getTipIconIdx(MINE_DIG_ICON3)
            self.scroll:addItem(tipIcon,tipIconIdx)
            return true
        end
    end
    return false
end

function DigMinePanel:getTipIconIdx(iconType, param)
    local size = self.scroll:getSize()
    local tipIcon = nil
    local tipIdxes = {}
    local tipIcon6Leftimes = {}
    local digingOrUngetInfo = nil
    for i = 1, size do
        tipIcon = self.scroll:getItem(i - 1)
        if tipIcon.type <= iconType then
            table.insert(tipIdxes, i)
            if tipIcon.type == MINE_DIG_ICON6 then
                digingOrUngetInfo = gDigMine.digingOrUngetInfoList[tipIcon.extraInfo]
                if nil ~= digingOrUngetInfo then
                    table.insert(tipIcon6Leftimes, {idx=i, lefttime=digingOrUngetInfo.lefttime})
                end
            end
        end
    end

    local leftimesSize = #tipIcon6Leftimes
    local tipIdxesSize = #tipIdxes
    if  leftimesSize ~= 0 then
        for i = 1, leftimesSize do
            if tipIcon6Leftimes[i].lefttime > param then
                return tipIcon6Leftimes[i].idx - 1
            end
        end
    elseif  tipIdxesSize ~= 0 then
        return tipIdxes[tipIdxesSize]
    else
        return 0
    end    
end

function DigMinePanel:recordBgScale()
    local key  = string.format("%d_mine_scale",gUserInfo.id)
    cc.UserDefault:getInstance():setFloatForKey(key,gDigMine.districtScale)
end

function DigMinePanel:getBgScale()
    local key  = string.format("%d_mine_scale",gUserInfo.id)
    local value = cc.UserDefault:getInstance():getFloatForKey(key)
    if value == 0.0 then
        value = 0.7
    end
    return value
end


--function DigMinePanel:onPopup()
--  if nil ~= self.bgLayer and not self.bgLayer:isVisible() then
----      print("come in on Popup")
----      self.bgLayer:setVisible(true)
--  end
--end
--function DigMinePanel:onPushStack()
--  if nil ~= self.bgLayer and self.bgLayer:isVisible() then
--      self.bgLayer:setVisible(false)
--  end
--end

return DigMinePanel