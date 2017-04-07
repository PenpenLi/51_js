local MineDigEffectNode=class("MineDigEffectNode",UILayer)

local DRILL_NORMAL  = 1
local DRILL_EXPLODER = 2
local DRILL_FIN     = 3
local DRILL_FLA_TAG = 1

function MineDigEffectNode:ctor()
    self:init("ui/ui_mine_dig_effect.map")
    self.endTime = 0
    self.id  = 0
    self.terrainID = 0
    self.isExploding = false
end

function MineDigEffectNode:onTouchEnded(target, touch, event)
    if target.touchName == "btn_detonator" then
        --立即结束需要X个雷管，你当前的雷管数量不足（2），是否需要购买?
        local curNum  = Data.getItemNum(ITEM_DETONATOR)
        local needNum = DB.getDetonatorCostByMine(self.terrainID)
        if curNum < needNum then
            gConfirmCancel(gGetWords("labelWords.plist","lab_detonator_num_limit",needNum,curNum), function()
                Panel.popUpVisible(PANEL_MINE_DEPOT,2,nil,true)
            end)
        else
            local mine,nums = DB.getMineAndNumsByMineType(self.terrainID)
            if nil ~= mine then
                local name = DB.getItemName(mine)
                if nums ~= 0 then
                    name = name.."x"..nums
                end
                gConfirmCancel(gGetWords("labelWords.plist","lab_mine_use_detonator1",needNum,name), function()
                    local key = string.format("%d_%d",self.digingPosX,self.digingPosY)
                    if gDigMine.data[key] ~= nil and gDigMine.data[key] ~= MINE_TERRAIN_TYPE0 then
                        Net.sendMiningExploder(self.digingPosX, self.digingPosY)
                    end
                end)
            end
        end
    end
end

function MineDigEffectNode:initSchedule()
    self:unscheduleUpdateEx()
    self:scheduleUpdate(function ()
        if nil == self.endTime then
            self:unscheduleUpdateEx()
            return
        end

        if self.endTime - gGetCurServerTime() > 0 then
            --显示倒计时
            self:setLabelString("txt_lefttime", gParserHourTime(self.endTime - gGetCurServerTime()))
            if self.drillType == DRILL_NORMAL and self.endTime - gGetCurServerTime() <= 1 then
                --替换钻头动画
                self.drillType = DRILL_EXPLODER
                local fla = gCreateFla("ui_wabao_zuantou_2", 1)
                self:replaceNode("fla_drill",fla)
            end 
        else
            if self.endTime ~= 0 then
                if self.drillType == DRILL_EXPLODER then
                    self:exploderTerrain(self.digingPosX, self.digingPosY)
                end
                self:getNode("txt_lefttime"):setVisible(false)
                self:getNode("btn_detonator"):setVisible(false)
                self.endTime = 0
                self:unscheduleUpdate()
            end
        end
    end, 0.5)
end

function MineDigEffectNode:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end


function MineDigEffectNode:initDetonatorBtn()
    --不同地形的对雷管的需求不同
    if nil == self.endTime then
        self:getNode("btn_detonator"):setVisible(false)
        return
    end

    local num = DB.getDetonatorCostByMine(self.terrainID)
    local finish = self.endTime < gGetCurServerTime()
    if num > 0 and not finish then
        self:getNode("btn_detonator"):setVisible(true)
    else
        self:getNode("btn_detonator"):setVisible(false)
    end
end

function MineDigEffectNode:setData(endTime, id, terrainID,pos)
    self.endTime = endTime
    self.id  = id
    self.terrainID = terrainID
    self.isExploding = false
    loadFlaXml("ui_wabao")
    if nil == self.endTime or self.endTime - gGetCurServerTime() <= 0 then
        self.drillType = DRILL_FIN
        self:setCtrShowByType(DRILL_FIN)
        self:initDetonatorBtn()
--        print("createMineCanGet step1",self.endTime, self.endTime - gGetCurServerTime())
        self:createMineCanGet(gDigMine.digingOrUngetInfo.x,gDigMine.digingOrUngetInfo.y)
        return
    end

    local fla = nil
    if self.endTime - gGetCurServerTime() > 1 then
        self.drillType = DRILL_NORMAL
        fla = gCreateFla("ui_wabao_zuantou", 1)
        self:replaceNode("fla_drill",fla)
        self:setCtrShowByType(DRILL_NORMAL)
        self:initSchedule()
    elseif self.endTime - gGetCurServerTime() > 0 then
        self.drillType = DRILL_EXPLODER
        fla = gCreateFla("ui_wabao_zuantou_2", 1)
        self:replaceNode("fla_drill",fla)
        self:setCtrShowByType(DRILL_EXPLODER)
        self:initSchedule()
    end
    self:initDetonatorBtn()
end

-- function MineDigEffectNode:onUILayerExit()
--     if nil ~= self.super then
--         self.super:onUILayerExit()
--     end
--     -- print("MineDigEffectNode:onUILayerExit")
--     -- self:unscheduleUpdate()
-- end

function MineDigEffectNode:exploderTerrain(x, y)
    --itemid为0，无东西
    local key = string.format("%d_%d",x, y)
    if self:getParent().container[key] == nil then
        return
    end

    local fla = FlashAni.new()
    local duration = fla:playAction("ui_wabao_shanbai",function()
         fla:removeFromParent()
    end,nil,1)
    self.isExploding = true
    local localZ = self:getParent().container[key]:getLocalZOrder()
    local posX,posY = self:getParent().container[key]:getPosition()
    fla:setPosition(posX,posY)
    self:getParent():addChild(fla,localZ)
    local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
    local delayTime = cc.DelayTime:create(0.3)
    local callFunc  = cc.CallFunc:create(function()
        if nil ~= self:getParent().container[key] then
            self:getParent().container[key]:removeFromParent()
            self:getParent().container[key] = nil
        end
        local flaName = self:getExplodeFlaName(x,y)
        if flaName ~= "" then
            local flaExploder = FlashAni.new()
            flaExploder:playAction(flaName,nil,nil,0)
            self:replaceNode("fla_explode", flaExploder)
            self:getNode("fla_explode"):setVisible(true)
            self:addExploderPaoPaoEffect(flaExploder)
        end
        self:getNode("fla_drill"):setVisible(false)
        self:getNode("fla_drill"):pause()
        if digingOrUngetInfo ~= nil and digingOrUngetInfo.itemid == MINE_TERRAIN_TYPE0 then
            gDigMine.data[key] = MINE_TERRAIN_TYPE0
        end
    end)
    -- print("delayTime2 value is:",digingOrUngetInfo.lefttime,gGetCurServerTime())
    local delayTime2 = cc.DelayTime:create(0.3)
    local callFunc2  = cc.CallFunc:create(function ()
        self.isExploding = false
        if digingOrUngetInfo ~= nil and digingOrUngetInfo.itemid ~= MINE_TERRAIN_TYPE0 then
            print("createMineCanGet step2")
            self:createMineCanGet(x, y)
            digingOrUngetInfo.lefttime = -1
            gDispatchEvt(EVENT_ID_MINING_REFRESH_NEWICON,{iconType=MINE_DIG_ICON5,posX=x, posY=y})
        end
    end)
    self:runAction(cc.Sequence:create(delayTime, callFunc,delayTime2,callFunc2))

    self:getNode("dig_frame"):setVisible(false)
end

function MineDigEffectNode:getExplodeFlaName(x,y)
    local key = string.format("%d_%d",x, y)
    local terrainType = gDigMine.data[key]
    -- print("MineDigEffectNode:getExplodeFlaName is:",terrainType)
    if nil ~= terrainType then
        if (terrainType == MINE_TERRAIN_TYPE1) or 
            (terrainType >= MINE_COPPER_FRA and terrainType <= MINE_IRON_FLASH) then
            return "ui_wabao_shitouzha_lv"
        elseif (terrainType == MINE_TERRAIN_TYPE3) or 
               (terrainType >= MINE_GOLD_FRA and terrainType <= MINE_DIAMON_FLASH) or 
               (terrainType >= MINE_GREEN_GEM and terrainType <= MINE_YELLOW_GEM_FLASH) then
            return "ui_wabao_shitouzha_ahs"
        elseif (terrainType == MINE_TERRAIN_TYPE2) or
               (terrainType >= MINE_SILVER_FRA and terrainType <= MINE_TIN_FLASH) or
               (terrainType >= MINE_XUANTIE and terrainType <= MINE_PURPLE_GEM_FLASH) or
               (terrainType == MINE_STATUE) or 
               (terrainType >= MINE_EVENT1 and terrainType <= MINE_EVENT9) then
            return "ui_wabao_shitouzha_huang"
        elseif terrainType == MINE_TERRAIN_TYPE4 then
            return "ui_wabao_shitouzha_zijin"
        end
    end

    return ""
end

function MineDigEffectNode:createMineIcon(mineType)
    local icon = cc.Sprite:create("images/icon/mine/"..mineType..".png")
    return icon
end

function MineDigEffectNode:createMineCanGet(x,y)
    local key = string.format("%d_%d",x, y)
    local digingOrUngetItem = gDigMine.digingOrUngetInfoList[key]
    if digingOrUngetItem == nil or digingOrUngetItem.itemid == -1 or 0 == digingOrUngetItem.itemid then
        return
    end

    local mineFla = gCreateFla("ui_wabao_icon_1",1)
    if nil ~= mineFla then
        local containerNode= cc.Node:create()
        containerNode:setAnchorPoint(cc.p(0, 0))
        containerNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + gDigMine.minY) * ICON_MINE_HEIGHT)
        local icon1 = self:createMineIcon(digingOrUngetItem.itemid)
        mineFla:replaceBoneWithNode({"icon1"},icon1)
        local icon2 = self:createMineIcon(digingOrUngetItem.itemid)
        mineFla:replaceBoneWithNode({"icon2"},icon2)
        containerNode:addChild(mineFla)
        self:getParent():addChild(containerNode,1000000)
        local keyMine = self:getParent().container[key]
        if nil ~= keyMine then
            self:getParent().container[key]:removeFromParent()
            self:getParent().container[key] = nil
        end
        self:getParent().container[key] = containerNode
    end
end

function MineDigEffectNode:removeStatus(x,y)
    self:getNode("fla_drill"):setVisible(false)
    self:getNode("fla_drill"):pause()
    self:getNode("fla_explode"):setVisible(false)
    self:getNode("dig_frame"):setVisible(false)
    self:getNode("btn_detonator"):setVisible(false)
    self:getNode("txt_lefttime"):setVisible(false)
    self.isExploding = true
    local key = string.format("%d_%d",x,y)
    local fla = FlashAni.new()
    local duration = fla:playAction("ui_wabao_shanbai",function()
        fla:removeFromParent()
    end,nil,1)
    local localZ = self:getParent().container[key]:getLocalZOrder()
    local posX,posY = self:getParent().container[key]:getPosition()
    fla:setPosition(posX,posY)
    self:getParent():addChild(fla, localZ)

    local delayTime = cc.DelayTime:create(0.3)
    local duration  = 0
    local callFunc  = cc.CallFunc:create(function()
        self:getParent().container[key]:removeFromParent()
        self:getParent().container[key] = nil
        gDigMine.removeStatusPosInfo(gDigMine.statusFightPos.x,gDigMine.statusFightPos.y)
        gDigMine.statusFightPos = {}
        gDigMine.data[key]=MINE_TERRAIN_TYPE0
        local flaExploder = FlashAni.new()
        duration = flaExploder:playAction("ui_wabao_shitouzha_huang",nil,nil,0)
        self:replaceNode("fla_explode", flaExploder)
        self:getNode("fla_explode"):setVisible(true)
        self:addExploderPaoPaoEffect(flaExploder)
        self:getParent():getParent():operateTipIcon(MINE_DIG_ICON1, MINE_DIG_OPE_DEL)
    end)
    local delayTime2 = cc.DelayTime:create(0.8)
    local callFunc2  = cc.CallFunc:create(function()
        self:setVisible(false)
        self.isExploding = false
    end)
    self:runAction(cc.Sequence:create(delayTime,callFunc,delayTime2,callFunc2))
end

function MineDigEffectNode:processExploder(x,y)
    self:getNode("fla_drill"):setVisible(false)
    self:getNode("fla_drill"):pause()
    self:getNode("fla_explode"):setVisible(false)
    self:getNode("dig_frame"):setVisible(false)
    self:getNode("btn_detonator"):setVisible(false)
    self:getNode("txt_lefttime"):setVisible(false)
    self:unscheduleUpdateEx()
    self.endTime = 0
    self.isExploding = true
    self:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
    self:setVisible(true)
    local key = string.format("%d_%d",x,y)
    local fla = FlashAni.new()
    local duration = fla:playAction("ui_wabao_shanbai",function()
        fla:removeFromParent()
    end,nil,1)
    local localZ = self:getParent().container[key]:getLocalZOrder()
    local posX,posY = self:getParent().container[key]:getPosition()
    fla:setPosition(posX,posY)
    self:getParent():addChild(fla, localZ)

    local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
    local delayTime = cc.DelayTime:create(0.3)
    local duration  = 0
    local callFunc  = cc.CallFunc:create(function()
        self:getParent().container[key]:removeFromParent()
        self:getParent().container[key] = nil
       
        if digingOrUngetInfo ~= nil then
            if digingOrUngetInfo.itemid ~= MINE_TERRAIN_TYPE0 then
                self:createMineCanGet(x, y)
                -- digingOrUngetInfo.lefttime = -1
            end
        end

        local flaExploder = FlashAni.new()
        duration = flaExploder:playAction(self:getExplodeFlaName(x,y),nil,nil,0)
        self:replaceNode("fla_explode", flaExploder)
        self:getNode("fla_explode"):setVisible(true)
        self:addExploderPaoPaoEffect(flaExploder)

        local flaExploderEffect = FlashAni.new()
        duration = flaExploder:playAction("ui_wabao_baozha",nil,nil,0)
        self:replaceNode("detonator_effect", flaExploderEffect)
        self:getNode("detonator_effect"):setVisible(true)
        gDigMine.data[key]=MINE_TERRAIN_TYPE0
    end)
    local delayTime2 = cc.DelayTime:create(0.8)
    local callFunc2  = cc.CallFunc:create(function()
        self:setVisible(false)
        if digingOrUngetInfo.itemid == MINE_TERRAIN_TYPE0 then
            Panel.popUpVisible(PANEL_GET_REWARD,gDigMine.explodeReword)
            gDigMine.explodeReword = {}
            gDigMine.digingOrUngetInfoList[key] = nil
            gDigMine.refreshBusyMiners()
        elseif digingOrUngetInfo.itemid ~= nil then
            digingOrUngetInfo.lefttime = -1
            Net.sendMiningGet(x, y)
            gDigMine.isSendMiningGet = true
            gDigMine.sendMiningGetTime = gGetCurServerTime()
        end
        self.isExploding = false
    end)
    self:runAction(cc.Sequence:create(delayTime,callFunc,delayTime2,callFunc2))
end

function MineDigEffectNode:processDiging(x,y)
    local  key = string.format("%d_%d",x,y)
    local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
    if digingOrUngetInfo == nil then
        return
    end
    loadFlaXml("ui_wabao")
    self.terrainID  = gDigMine.data[key]
    local digingTime = DB.getDigingTimeForMine(self.terrainID)
    self.endTime = gGetCurServerTime() + digingTime
    self.id  = digingOrUngetInfo.itemid
    self.isExploding = false
    local fla = nil
    if digingTime > 1 then
        self.drillType = DRILL_NORMAL
        fla = gCreateFla("ui_wabao_zuantou", 1)
        self:replaceNode("fla_drill",fla)
        self:setCtrShowByType(DRILL_NORMAL)
        self:initSchedule()
        gDigMine.refreshBusyMiners()
        gDispatchEvt(EVENT_ID_MINING_REFRESH_NEWICON,{iconType=MINE_DIG_ICON6, posX=x, posY=y})
    elseif digingTime == 1 then
        self.drillType = DRILL_EXPLODER
        fla = gCreateFla("ui_wabao_zuantou_2", 1)
        self:replaceNode("fla_drill",fla)
        self:setCtrShowByType(DRILL_EXPLODER)
        self:digingOneSecond(x,y)
    end
    self:initDetonatorBtn()
end

function MineDigEffectNode:digingOneSecond(x, y)
    local key = string.format("%d_%d",x, y)
    local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
    if self:getParent().container[key] == nil or digingOrUngetInfo == nil then
        return
    end

    self.isExploding = true
    local delayTime1 = cc.DelayTime:create(0.5)
    local callFunc1 = cc.CallFunc:create(function()
        if nil ~= self:getParent().container[key] then
            local fla = FlashAni.new()
            fla:playAction("ui_wabao_shanbai",function()
                fla:removeFromParent()
            end,nil,1)
            local localZ = self:getParent().container[key]:getLocalZOrder()
            local posX,posY = self:getParent().container[key]:getPosition()
            fla:setPosition(posX,posY)
            self:getParent():addChild(fla,localZ)
        end
    end)

    local delayTime2 = cc.DelayTime:create(0.3)
    local callFunc2 = cc.CallFunc:create(function ()
        local posX,posY = nil, nil
        if nil ~= self:getParent().container[key] then
            posX,posY = self:getParent().container[key]:getPosition()
            local contenSize = self:getParent().container[key]:getContentSize()
            self:getParent().container[key]:removeFromParent()
            self:getParent().container[key] = nil
        end

        local flaName = self:getExplodeFlaName(x,y)
        if flaName ~= "" then
            -- TODO
            local flaExploder = nil
            if digingOrUngetInfo.itemid == MINE_TERRAIN_TYPE0 then
                if posX ~= nil and posY ~= nil then
                    flaExploder = FlashAni.new()
                    flaExploder:playAction(flaName,function()
                        flaExploder:removeFromParent()
                    end, nil,1)
                    flaExploder:setPosition(posX + ICON_MINE_WIDTH / 2 ,posY + ICON_MINE_HEIGHT / 2)
                    self:getParent():addChild(flaExploder, 1000000)
                    self:addExploderPaoPaoEffect(flaExploder)
                end
            else
                flaExploder = gCreateFla(flaName,-1)
                self:replaceNode("fla_explode", flaExploder)
                self:getNode("fla_explode"):setVisible(true)
                self:addExploderPaoPaoEffect(flaExploder)
            end            
        end
        self:getNode("fla_drill"):setVisible(false)
        self:getNode("fla_drill"):pause()
        if digingOrUngetInfo.itemid == MINE_TERRAIN_TYPE0 then
            gDigMine.data[key] = MINE_TERRAIN_TYPE0
        end
    end)
    
    local delayTime3 = cc.DelayTime:create(0.3)
    local callFunc3  = cc.CallFunc:create(function ()
        if digingOrUngetInfo.itemid ~= MINE_TERRAIN_TYPE0 then
            self:createMineCanGet(x,y)
            digingOrUngetInfo.lefttime = -1
            Net.sendMiningGet(x,y)
            gDigMine.isSendMiningGet = true
            gDigMine.sendMiningGetTime = gGetCurServerTime()
        else
            -- print("coming digingOneSecond end key is:",key," lefttime is:",digingOrUngetInfo.lefttime)
            self.isExploding = false
            gDigMine.digingOrUngetInfoList[key] = nil
            self:setVisible(false)
        end
    end)
    self:runAction(cc.Sequence:create(delayTime1, callFunc1,delayTime2,callFunc2,delayTime3,callFunc3))
end

function MineDigEffectNode:setCtrShowByType(drillType)
    self:getNode("fla_explode"):setVisible(false)
    self:getNode("detonator_effect"):setVisible(false)
    if drillType == DRILL_NORMAL then
        self:getNode("fla_drill"):setVisible(true)
        self:getNode("fla_drill"):resume()
        self:getNode("txt_lefttime"):setVisible(true)
        self:getNode("dig_frame"):setVisible(true)
    elseif drillType == DRILL_EXPLODER then
        self:getNode("fla_drill"):setVisible(true)
        self:getNode("fla_drill"):resume()
        self:getNode("txt_lefttime"):setVisible(false)
        self:getNode("dig_frame"):setVisible(false)
    elseif drillType == DRILL_FIN then
        self:getNode("fla_drill"):setVisible(false)
        self:getNode("fla_drill"):pause()
        self:getNode("txt_lefttime"):setVisible(false)
        self:getNode("dig_frame"):setVisible(false)
    end
end

function MineDigEffectNode:processClose()
    if self.isExploding then
        self.isExploding = false
        if self.digingPosX ~= nil then
            local key = string.format("%d_%d",self.digingPosX, self.digingPosY)
            if nil ~= self:getParent().container[key] then
                self:getParent().container[key]:removeFromParent()
                self:getParent().container[key] = nil
            end
            local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
            if nil ~= digingOrUngetInfo then 
                if digingOrUngetInfo.itemid ~= MINE_TERRAIN_TYPE0 then
                    self:createMineCanGet(self.digingPosX, self.digingPosY)
                    digingOrUngetInfo.lefttime = -1
                else
                    gDigMine.data[key] = MINE_TERRAIN_TYPE0
                end
            end
        end
        self:setVisible(false)
    end
end

function MineDigEffectNode:getExplodeFlaNameEx(x,y)
    local key = string.format("%d_%d", x, y)
    local terrainType = gDigMine.data[key]
    if nil ~= terrainType then
        if (terrainType == MINE_TERRAIN_TYPE1) or 
            (terrainType >= MINE_COPPER_FRA and terrainType <= MINE_IRON_FLASH) then
            return "ui_wabao_shitouzha_lv"
        elseif (terrainType == MINE_TERRAIN_TYPE3) or 
               (terrainType >= MINE_GOLD_FRA and terrainType <= MINE_DIAMON_FLASH) or 
               (terrainType >= MINE_GREEN_GEM and terrainType <= MINE_YELLOW_GEM_FLASH) then
            return "ui_wabao_shitouzha_ahs"
        elseif (terrainType == MINE_TERRAIN_TYPE2) or
               (terrainType >= MINE_SILVER_FRA and terrainType <= MINE_TIN_FLASH) or
               (terrainType >= MINE_XUANTIE and terrainType <= MINE_PURPLE_GEM_FLASH) or
               (terrainType == MINE_STATUE) or 
               (terrainType >= MINE_EVENT1 and terrainType <= MINE_EVENT9) then
            return "ui_wabao_shitouzha_huang"
        elseif terrainType == MINE_TERRAIN_TYPE4 then
            return "ui_wabao_shitouzha_zijin"
        end
    end

    return ""
end

function MineDigEffectNode:createMineCanGetEx( x, y,itemId)
    local mineFla = gCreateFla("ui_wabao_icon_1",1)
    if nil ~= mineFla then
        local containerNode= cc.Node:create()
        containerNode:setAnchorPoint(cc.p(0, 0))
        containerNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + gDigMine.minY) * ICON_MINE_HEIGHT)
        local icon1 = self:createMineIcon(itemId)
        mineFla:replaceBoneWithNode({"icon1"},icon1)
        local icon2 = self:createMineIcon(itemId)
        mineFla:replaceBoneWithNode({"icon2"},icon2)
        containerNode:addChild(mineFla)
        self:getParent():addChild(containerNode,1000000)
        local key = string.format("%d_%d", x, y)
        local keyMine = self:getParent().container[key]
        if nil ~= keyMine then
            self:getParent().container[key]:removeFromParent()
            self:getParent().container[key] = nil
        end
        self:getParent().container[key] = containerNode
    end   
end

function MineDigEffectNode:getExplodeFlaNameByType(terrainType)
    if nil ~= terrainType then
        if (terrainType == MINE_TERRAIN_TYPE1) or 
            (terrainType >= MINE_COPPER_FRA and terrainType <= MINE_IRON_FLASH) then
            return "ui_wabao_shitouzha_lv"
        elseif (terrainType == MINE_TERRAIN_TYPE3) or 
               (terrainType >= MINE_GOLD_FRA and terrainType <= MINE_DIAMON_FLASH) or 
               (terrainType >= MINE_GREEN_GEM and terrainType <= MINE_YELLOW_GEM_FLASH) then
            return "ui_wabao_shitouzha_ahs"
        elseif (terrainType == MINE_TERRAIN_TYPE2) or
               (terrainType >= MINE_SILVER_FRA and terrainType <= MINE_TIN_FLASH) or
               (terrainType >= MINE_XUANTIE and terrainType <= MINE_PURPLE_GEM_FLASH) or
               (terrainType == MINE_STATUE) or 
               (terrainType >= MINE_EVENT1 and terrainType <= MINE_EVENT9) then
            return "ui_wabao_shitouzha_huang"
        elseif terrainType == MINE_TERRAIN_TYPE4 then
            return "ui_wabao_shitouzha_zijin"
        end
    end

    return ""
end

function MineDigEffectNode:torpedoMineFly(x,y,id)
    local key = string.format("%d_%d", x, y)
    if self:getParent().container[key] ~= nil then
        local disappearFla = FlashAni.new()
        disappearFla:playAction("ui_wabao_icon_2",function ()
            disappearFla:removeFromParent()
        end,nil,1)
        local icon1 = cc.Sprite:create("images/icon/mine/"..id..".png")
        disappearFla:replaceBoneWithNode({"icon1"},icon1)
        local icon2 = cc.Sprite:create("images/icon/mine/"..id..".png")
        disappearFla:replaceBoneWithNode({"icon2"},icon2)
        local posX,posY = self:getParent().container[key]:getPosition()
        disappearFla:setPosition(posX, posY)
        self:getParent():addChild(disappearFla, 1000000)
        self:getParent().container[key]:removeFromParent()
        self:getParent().container[key] = nil
    end

    if gDigMine.data[key] ~= nil then
        gDigMine.data[key] = MINE_TERRAIN_TYPE0
    end 
end

function MineDigEffectNode:processEventDig(event,lightMine)
    loadFlaXml("ui_wabao")
    self:getNode("btn_detonator"):setVisible(false)
    local x,y =     gDigMine.eventTerrainPos.x,gDigMine.eventTerrainPos.y
    local key = string.format("%d_%d",x,y)
    if self:getParent().container[key] == nil then
        return
    end
    self.endTime = gGetCurServerTime() + 1
    local flaBegin = nil
    self.drillType = DRILL_EXPLODER
    flaBegin = gCreateFla("ui_wabao_zuantou_2", 1)
    self:replaceNode("fla_drill",flaBegin)
    self:setCtrShowByType(DRILL_EXPLODER)

    self.isExploding = true
    local delayTime1 = cc.DelayTime:create(0.5)
    local callFunc1 = cc.CallFunc:create(function()
        if nil ~= self:getParent().container[key] then
            local fla = FlashAni.new()
            fla:playAction("ui_wabao_shanbai",function()
                fla:removeFromParent()
            end,nil,1)
            local localZ = self:getParent().container[key]:getLocalZOrder()
            local posX,posY = self:getParent().container[key]:getPosition()
            fla:setPosition(posX,posY)
            self:getParent():addChild(fla,localZ)
        end
    end)

    local delayTime2 = cc.DelayTime:create(0.3)
    local callFunc2 = cc.CallFunc:create(function ()
        if nil ~= self:getParent().container[key] then
            self:getParent().container[key]:removeFromParent()
            self:getParent().container[key] = nil
        end

        local flaName = self:getExplodeFlaNameEx(x, y)
        if flaName ~= "" then
            local flaExploder = FlashAni.new()
            flaExploder:playAction(flaName,function()
                -- self:setVisible(false)
                flaExploder:stopAni()
            end, nil,1)
            self:replaceNode("fla_explode", flaExploder)
            self:addExploderPaoPaoEffect(flaExploder)
            self:getNode("fla_explode"):setVisible(true)
        end
        self:getNode("fla_drill"):setVisible(false)
        self:getNode("fla_drill"):pause()
        self:removeProcessByEvent(key,event,x,y)
    end)
    
    local delayTime3 = cc.DelayTime:create(0.8)
    local callFunc3  = cc.CallFunc:create(function ()
        self:setVisible(false)
        if event == MINE_EVENT1 then
            self:getParent():lightMine(lightMine)
            Panel.popUpVisible(PANEL_MINE_MERMAID_REWARD,self.digingPosX,self.digingPosY,true)
        elseif event == MINE_EVENT2 then
            self:getParent():lightMine(lightMine)
            Panel.popUpVisible(PANEL_MINE_MERMAID_BUY,self.digingPosX,self.digingPosY,true)
        elseif event == MINE_EVENT3 then
            self:getParent():lightMine(lightMine)
            Panel.popUpVisible(PANEL_MINE_LUCKY_WHEEL,nil,nil,true)
            self.isExploding = false
        elseif event == MINE_EVENT5 then
            self:getParent():lightMine(lightMine)
            Panel.popUpVisible(PANEL_GET_REWARD,gDigMine.eventRewards)
            self.isExploding = false
        elseif event == MINE_EVENT6 or event == MINE_EVENT7 then
            self:processEvent6Or7Ex()
        elseif event == MINE_EVENT8 then
            self:getParent():lightMine(lightMine, true)
            self.isExploding = false
        elseif event == MINE_EVENT9 then
            self:getParent():lightMine(lightMine)
            Panel.popUpVisible(PANEL_MINE_BLACK_MARKET,self.digingPosX,self.digingPosY,true)
        elseif event == MINE_EVENT4 then
            self:getParent():lightMine(lightMine)
            Panel.popUpVisible(PANEL_MINE_PICKAX_SUPPLEMENT,self.digingPosX,self.digingPosY,true)
        end
    end)
    self:runAction(cc.Sequence:create(delayTime1, callFunc1,delayTime2,callFunc2,delayTime3,callFunc3))
end

function MineDigEffectNode:processEvent6Or7Ex()
    self:stopAllActions()
    local size = #gDigMine.torpedoExploderMines
    if size == 0 then
        self.isExploding = false
        return
    end
    local effectNode = nil
    for i = 1, size do
        local exploderMineInfo = gDigMine.torpedoExploderMines[i]
        local key = string.format("%d_%d", exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, exploderMineInfo.y)
        local mineInfo = self:getParent().container[key]
        if mineInfo ~= nil then
            DisplayUtil.setGray(mineInfo, true)
        end

        effectNode = self:getParent():getDigingMineInPos(key)
        if nil ~= effectNode then
            effectNode:setShowEvent6or7Exploding(key)
        end

        gDigMine.addMineData(exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, exploderMineInfo.y,exploderMineInfo.mineType)
    end

    local delayTime1 = cc.DelayTime:create(0.2)
    local callFunc1  = cc.CallFunc:create(function()
        for i=1, size do
            local exploderMineInfo = gDigMine.torpedoExploderMines[i]
            local key = string.format("%d_%d", exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, exploderMineInfo.y)
            if not (gDigMine.eventTerrainPos.x == exploderMineInfo.x - gDigMine.xOriRange / 2 + 1 and gDigMine.eventTerrainPos.y == exploderMineInfo.y) then
                local localZ    = self:getParent().container[key]:getLocalZOrder()
                local posX,posY = self:getParent().container[key]:getPosition()
                if gDigMine.digingOrUngetInfoList[key] ~= nil then
                    gDigMine.digingOrUngetInfoList[key] = nil
                    gDigMine.refreshBusyMiners()
                    gDispatchEvt(EVENT_ID_MINING_REFRESH_NEWICON,{iconType=MINE_DIG_ICON5, posX=exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, posY=exploderMineInfo.y})
                end 

                if self:getParent().container[key] ~= nil then
                    self:getParent().container[key]:removeFromParent()
                    self:getParent().container[key] = nil
                end
                if exploderMineInfo.id ~= 0 then
                    self:createMineCanGetEx(exploderMineInfo.x - gDigMine.xOriRange / 2 + 1,exploderMineInfo.y,exploderMineInfo.id)
                elseif exploderMineInfo.id == 0 and gDigMine.noEffectedByTorpedo(exploderMineInfo.mineType) 
                    and not (gDigMine.eventTerrainPos.x == exploderMineInfo.x - gDigMine.xOriRange / 2 + 1 and gDigMine.eventTerrainPos.y == exploderMineInfo.y)then
                    local mine = self:getParent():createSpriteByType(exploderMineInfo.mineType)
                    self:getParent().container[key] = mine
                    self:getParent():addMine(exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, exploderMineInfo.y, mine)               
                end

                local flaName = self:getExplodeFlaNameByType(exploderMineInfo.mineType)
                if "" ~= flaName then
                    local flaExploder = FlashAni.new()
                    flaExploder:playAction(flaName,function()
                        flaExploder:removeFromParent()
                    end,nil,0)
                    flaExploder:setPosition(posX,posY)
                    self:getParent():addChild(flaExploder, localZ)
                    self:addExploderPaoPaoEffect(flaExploder)
                    -- print("flaExploder name is: ",flaName, flaExploder:getBone("paopao1"))
                    -- flaExploder:getBone("paopao1"):getDisplayManager():setVisible(false)
                    -- flaExploder:getBone("paopao2"):getDisplayManager():setVisible(false)
                    -- flaExploder:getBone("paopao3"):getDisplayManager():setVisible(false)
                    -- flaExploder:getBone("paopao4"):getDisplayManager():setVisible(false)
                    -- flaExploder:getBone("paopao5"):getDisplayManager():setVisible(false)
                    -- flaExploder:getBone("paopao6"):getDisplayManager():setVisible(false)
                end
            end
        end
    end
    )

    local delayTime2 = cc.DelayTime:create(0.2)
    local callFunc2 = cc.CallFunc:create(function()
        for i = 1, size do
            local exploderMineInfo = gDigMine.torpedoExploderMines[i]
            local key = string.format("%d_%d", exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, exploderMineInfo.y)
            if exploderMineInfo.id ~= 0 then
                self:getParent():getMineByTorpedoExploding(exploderMineInfo.x - gDigMine.xOriRange / 2 + 1, exploderMineInfo.y)
                gShowItemPoolLayer:pushOneItem({id = exploderMineInfo.id, num = exploderMineInfo.num})
            end

            if exploderMineInfo.id == 0 and gDigMine.noEffectedByTorpedo(exploderMineInfo.mineType) 
                and not (gDigMine.eventTerrainPos.x == exploderMineInfo.x - gDigMine.xOriRange / 2 + 1 and gDigMine.eventTerrainPos.y == exploderMineInfo.y) then
                gDigMine.data[key] = exploderMineInfo.mineType
            else
                gDigMine.data[key] = MINE_TERRAIN_TYPE0
            end
        end
        self:getParent():lightMine(gDigMine.torpedoLightMines)
        self.isExploding = false 
        gDigMine.torpedoExploderMines = {}
        gDigMine.torpedoLightMines = {}
        self:setVisible(false)
    end)

    self:runAction(cc.Sequence:create(delayTime1,callFunc1,delayTime2,callFunc2))
end

function MineDigEffectNode:removeProcessByEvent(key,event,x,y)
    if event == MINE_EVENT2 then
        gDigMine.removeMineEvent2PosInfo(x, y)
        gDigMine.mineEvent2PosInfo = {}
    elseif event == MINE_EVENT3 then
        gDigMine.removeMineEvent3PosInfo(x, y)
        gDigMine.mineEvent3PosInfo = {}
    elseif event == MINE_EVENT9 then
        gDigMine.removeMineEvent9PosInfo(x, y)
        gDigMine.mineEvent9PosInfo = {}
    end
    gDigMine.data[key]=MINE_TERRAIN_TYPE0
end

function MineDigEffectNode:addExploderPaoPaoEffect(parent)
    if gIsAndroid() or parent == nil  then
        return
    end

    local paopao = gCreateFla("ui_baozha_paopao")
    if nil ~= paopao then
        parent:addChild(paopao, -1)
    end
end

function MineDigEffectNode:setDataEx(endTime, id, terrainID,x,y)
    self.endTime = endTime
    self.id  = id
    self.terrainID = terrainID
    self.isExploding = false
    self:setDigPos(x,y)
    loadFlaXml("ui_wabao")
    if nil == self.endTime or self.endTime - gGetCurServerTime() <= 0 then
        self.drillType = DRILL_FIN
        self:setCtrShowByType(DRILL_FIN)
        self:initDetonatorBtn()
        self:createMineCanGet(x,y)
        return
    end

    local fla = nil
    if self.endTime - gGetCurServerTime() > 1 then
        self.drillType = DRILL_NORMAL
        fla = gCreateFla("ui_wabao_zuantou", 1)
        self:replaceNode("fla_drill",fla)
        self:setCtrShowByType(DRILL_NORMAL)
        self:initSchedule()
    elseif self.endTime - gGetCurServerTime() > 0 then
        self.drillType = DRILL_EXPLODER
        fla = gCreateFla("ui_wabao_zuantou_2", 1)
        self:replaceNode("fla_drill",fla)
        self:setCtrShowByType(DRILL_EXPLODER)
        self:initSchedule()
    end
    self:initDetonatorBtn()
end

function MineDigEffectNode:setDigPos(x, y)
    self.digingPosX = x
    self.digingPosY = y
end

function MineDigEffectNode:setShowEvent6or7Exploding()
    self:getNode("fla_drill"):setVisible(false)
    self:getNode("fla_drill"):pause()
    self:getNode("fla_explode"):setVisible(false)
    self:getNode("dig_frame"):setVisible(false)
    self:getNode("btn_detonator"):setVisible(false)
    self:getNode("txt_lefttime"):setVisible(false)
    self:unscheduleUpdateEx()
    self.endTime = 0
    self:setVisible(false)
end

return MineDigEffectNode