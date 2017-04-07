local MineMapLayer = class("MineMapLayer",function()
    return cc.Node:create()
end)

function MineMapLayer:ctor(width,height)
    if(cc.FileUtils:getInstance():isFileExist("packer/images_mine_001.plist"))then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_mine_001.plist")
    end

    if(cc.FileUtils:getInstance():isFileExist("packer/font.plist"))then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist")
    end
    -- self:changeWidthAndHeight(width,height)
    self:setContentSize(width,height)
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(cc.p(0.5,1))
    self.container = {}
    --x,y累积偏移量
    self.diffX = 0
    self.diffY = 0
    self.showArea = {left = 0, bottom = 0, right = 0,top = 0}
    self.preScale = 1.0
    self.curScale = 1.0
    self:initDigEffectNode()
end

function MineMapLayer:addMine(posX, posY, mine)
    mine:setAnchorPoint(cc.p(0,0))
    mine:setPosition((gDigMine.maxX + posX) * ICON_MINE_WIDTH, (gDigMine.yRange - posY + gDigMine.minY) * ICON_MINE_HEIGHT)
    local zorder = (gDigMine.yRange - posY + gDigMine.minY) * 1000 + gDigMine.maxX + posX
    self:addChild(mine,zorder)
end

function MineMapLayer:initMineInfo(rePopUp)
    -- self.batchNode:removeAllChildren()
    self.container = {}
    self.diffX = 0
    self.diffY = 0
    self.showArea = {left = 0, bottom = 0, right = 0,top = 0}
    self:removeAllChildren()
    self:initDigEffectNode()
    self:initPos(rePopUp)

    local digingOrUnget = false
    local digingOrUngetCount = gDigMine.getDigingOrUngetMineCount()
    if digingOrUngetCount > 0 then
        digingOrUnget = true
    end

    for i = self.showArea.left,self.showArea.right do
        for j = self.showArea.top, self.showArea.bottom do
            local key = string.format("%d_%d", i, j)
            if gDigMine.data[key] ~= nil then
                if digingOrUnget and gDigMine.hasDigingOrUngetInPos(key) then--有正在挖掘的地形或未获取的资源
                    --如果是正在挖的
                    self:processDigEffectDisplay(i,j,key)
                else
                    local mine = self:createSpriteByType(gDigMine.data[key])
                    if nil ~= mine then
                        self.container[key] = mine
                        self:addMine(i, j, mine)
                    end
                end
            else
                self:createUnDigMine(i,j)
            end
        end
    end
end

function MineMapLayer:initPos()
    local parent = self:getParent()
    local contentSize = parent:getContentSize()
    local winSize = cc.Director:getInstance():getWinSizeInPixels()
    local hasDigingOrUngetMine = gDigMine.hasDigingMine() or gDigMine.hasUngetMine()
    local x = 0
    local y = 0
    local middleY = 0
    local middleX = 0
    local digingOrUngetPosKey = gDigMine.getOneDigingOrUngetMine()
    if gDigMine.statusFightPos.x ~= nil then
        digingOrUngetPosKey = string.format("%d_%d",gDigMine.statusFightPos.x,gDigMine.statusFightPos.y)
    end
    if hasDigingOrUngetMine and digingOrUngetPosKey ~= "" then
        local posKey = digingOrUngetPosKey
        local posKeyTable = string.split(posKey,"_")
        local digingOrUngetPosX,digingOrUngetPosY = toint(posKeyTable[1]),toint(posKeyTable[2])
        x = contentSize.width / 2 - digingOrUngetPosX * math.floor(ICON_MINE_WIDTH * self.curScale)
        middleX = digingOrUngetPosX
        if (digingOrUngetPosY - gDigMine.minY + 1) * math.floor(ICON_MINE_HEIGHT * self.curScale) < contentSize.height then
            y = -(0 - math.floor((winSize.height - contentSize.height) / 2))
            middleY = math.floor((contentSize.height / 2) / math.floor(ICON_MINE_HEIGHT * self.curScale)) 
        else
            y = (digingOrUngetPosY - gDigMine.minY + 1) * math.floor(ICON_MINE_HEIGHT * self.curScale) - contentSize.height / 2
            middleY = digingOrUngetPosY
        end
    else
        local recordMiddleX,recordMiddleY = parent:getRecordMiddlePosOfBg()
        if not gDigMine.resetFlag and nil ~= recordMiddleX and nil ~= recordMiddleY then
            x = contentSize.width / 2 - recordMiddleX * math.floor(ICON_MINE_WIDTH * self.curScale)
            middleX = recordMiddleX
            y = (recordMiddleY - gDigMine.minY + 1) * math.floor(ICON_MINE_HEIGHT * self.curScale) - contentSize.height / 2
            middleY = recordMiddleY
        else
            x = contentSize.width / 2 - (math.floor((gDigMine.maxLightXForY + gDigMine.minLightXForY) / 2)) * math.floor(ICON_MINE_WIDTH * self.curScale)
            middleX = math.floor((gDigMine.maxLightXForY + gDigMine.minLightXForY) / 2)
            if (gDigMine.maxLightY - gDigMine.minY + 1) * math.floor(ICON_MINE_HEIGHT * self.curScale) < contentSize.height then
                y = -(0 - math.floor((winSize.height - contentSize.height) / 2))
                middleY = math.floor((contentSize.height / 2) / math.floor(ICON_MINE_HEIGHT * self.curScale)) 
            else
                y = math.floor((gDigMine.maxLightY - gDigMine.minY + 1) * math.floor(ICON_MINE_HEIGHT * self.curScale)) - contentSize.height / 2
                middleY = gDigMine.maxLightY
            end
        end
    end
    -- print("middleX is:",(math.floor((gDigMine.maxLightX + gDigMine.minLightX) / 2)),gDigMine.maxLightX,gDigMine.minLightX) 
    -- print("gDigMine.maxLightX is:", gDigMine.maxLightX, "gDigMine.minLightX is:",gDigMine.minLightX)
    if y <= parent.bgTopLimit then
        y = parent.bgTopLimit
    end

    if y >= parent.bgBottomLimit then
        y = parent.bgBottomLimit
    end

    if x >= parent.bgLeftLimit then
        x = parent.bgLeftLimit
    end

    if x <= parent.bgRightLimit then
        x = parent.bgRightLimit
    end
    self:setPosition(x, y)
    self.orignX = x
    self.orignY = y
    local widthNum = math.floor(winSize.width/math.floor(ICON_MINE_WIDTH * 0.5))
    local heightNum = math.floor(winSize.height/math.floor(ICON_MINE_HEIGHT * 0.5))
    self.showArea.left = middleX - widthNum
    self.showArea.bottom = middleY + heightNum
    self.showArea.right = middleX + widthNum
    self.showArea.top = middleY - heightNum
    if gDigMine.resetFlag then
--        print("coming step3",math.floor((self.showArea.left + self.showArea.right) / 2),math.floor((self.showArea.top + self.showArea.bottom) / 2))
        self:getParent():setMiddlePosOfDig()
    end
    -- print("self.showArea is:", self.showArea.left,self.showArea.right,widthNum)
    self:getParent():setPosLabelInfo(middleX,middleY)
end

function MineMapLayer:createSpriteByType(mineType)
    if mineType > 50 then
        mineType = mineType - 50
    end

    --TODO,图片路径配制为拼接状态
    local texPath = self:getTexPath(mineType)
    local mine = nil
    if texPath ~= "" then
        mine = gDigMine.createMineSprite(texPath)
        if nil ~= mine then
            self:addTwinkleEffectOrNot(mineType,mine)
        end
    end

    return mine
end

function MineMapLayer:changeMineTex(mine,mineType)
    if nil == mine then
        return
    end
    local texPath = self:getTexPath(mineType)
    if texPath ~= "" then
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(texPath)
        if nil ~= spriteFrame then
            mine:setSpriteFrame(texPath)
        else
            mine:setTexture(texPath)
        end
    end
end

function MineMapLayer:getTexPath(mineType)
    if mineType > 50 then
        mineType = mineType - 50
    end
    local texPath = ""
    --TODO,图片路径配制为拼接状态
    if mineType <= MINE_TERRAIN_TYPE5 then
        texPath = "images/mine/001/terrain_"..mineType..".png"
    elseif MINE_COPPER_FRA == mineType or MINE_COPPER_INTACT == mineType or MINE_COPPER_FLASH == mineType then
        texPath = "images/mine/001/terrain_copper.png"
    elseif MINE_IRON_FRA == mineType or MINE_IRON_INTACT == mineType or MINE_IRON_FLASH == mineType then
        texPath = "images/mine/001/terrain_iron.png"
    elseif MINE_SILVER_FRA == mineType or MINE_SILVER_INTACT == mineType or MINE_SILVER_FLASH == mineType then
        texPath = "images/mine/001/terrain_silver.png"
    elseif MINE_TIN_FRA == mineType or MINE_TIN_INTACT == mineType or MINE_TIN_FLASH == mineType then
        texPath = "images/mine/001/terrain_tin.png"
    elseif MINE_GOLD_FRA == mineType or MINE_GOLD_INTACT == mineType or MINE_GOLD_FLASH == mineType then
        texPath = "images/mine/001/terrain_gold.png"
    elseif MINE_DIAMON == mineType or MINE_DIAMON_FLASH == mineType then
        texPath = "images/mine/001/terrain_diamon.png"
    elseif MINE_XUANTIE == mineType or MINE_XUANTIE_FLASH == mineType then
        texPath = "images/mine/001/terrain_xuntie.png"
    elseif MINE_RED_GEM == mineType or MINE_RED_GEM_FLASH == mineType then
        texPath = "images/mine/001/terrain_red_gem.png"
    elseif MINE_PURPLE_GEM == mineType or MINE_PURPLE_GEM_FLASH == mineType then
        texPath = "images/mine/001/terrain_purple_gem.png"
    elseif MINE_GREEN_GEM == mineType or MINE_GREEN_GEM_FLASH == mineType then
        texPath = "images/mine/001/terrain_green_gem.png"
    elseif MINE_YELLOW_GEM == mineType or MINE_YELLOW_GEM_FLASH == mineType then
        texPath = "images/mine/001/terrain_yellow_gem.png"
    elseif MINE_STATUE == mineType then
        texPath = "images/mine/001/terrain_status.png"
    elseif MINE_EVENT1 == mineType or MINE_EVENT2 == mineType then
        texPath = "images/mine/001/terrain_event1.png"
    elseif MINE_EVENT3 == mineType then
        texPath = "images/mine/001/terrain_event2.png"
    elseif MINE_EVENT4 == mineType then
        texPath = "images/mine/001/terrain_event3.png"
    elseif MINE_EVENT5 == mineType then
        texPath = "images/mine/001/terrain_event4.png"
    elseif MINE_EVENT6 == mineType then
        texPath = "images/mine/001/terrain_event5.png"
    elseif MINE_EVENT7 == mineType then
        texPath = "images/mine/001/terrain_event6.png"
    elseif MINE_EVENT8 == mineType then
        texPath = "images/mine/001/terrain_event7.png"
    elseif MINE_EVENT9 == mineType then
        texPath = "images/mine/001/terrain_event8.png"
    end

    -- if MINE_TERRAIN_TYPE0 == mineType then
    --     texPath = "images/ui_digmine/terrain_0"--"block/lava_crust1.png"
    -- elseif MINE_TERRAIN_TYPE1 == mineType then
    --     texPath = "block/soil2.png"
    -- elseif MINE_TERRAIN_TYPE2 == mineType then
    --     texPath = "block/soil_hard1.png"
    -- elseif MINE_TERRAIN_TYPE3 == mineType then
    --     texPath = "block/rock1.png"
    -- elseif MINE_TERRAIN_TYPE4 == mineType then
    --     texPath = "block/rock_purple_gold.png"
    -- elseif MINE_COPPER_FRA == mineType or MINE_COPPER_INTACT == mineType or MINE_COPPER_FLASH == mineType then
    --     texPath = "block/copper1.png"
    -- elseif MINE_IRON_FRA == mineType or MINE_IRON_INTACT == mineType or MINE_IRON_FLASH == mineType then
    --     texPath = "block/iron1.png"
    -- elseif MINE_SILVER_FRA == mineType or MINE_SILVER_INTACT == mineType or MINE_SILVER_FLASH == mineType then
    --     texPath = "block/silver1.png"
    -- elseif MINE_TIN_FRA == mineType or MINE_TIN_INTACT == mineType or MINE_TIN_FLASH == mineType then
    --     texPath = "block/tin1.png"
    -- elseif MINE_GOLD_FRA == mineType or MINE_GOLD_INTACT == mineType or MINE_GOLD_FLASH == mineType then
    --     texPath = "block/gold1.png"
    -- elseif MINE_DIAMON == mineType or MINE_DIAMON_FLASH == mineType then
    --     texPath = "block/diamond.png"
    -- elseif MINE_XUANTIE == mineType or MINE_XUANTIE_FLASH == mineType then
    --     texPath = "block/iron2.png"
    -- elseif MINE_RED_GEM == mineType or MINE_RED_GEM_FLASH == mineType then
    --     texPath = "block/gem_red.png"
    -- elseif MINE_PURPLE_GEM == mineType or MINE_PURPLE_GEM_FLASH == mineType then
    --     texPath = "block/gem_purple.png"
    -- elseif MINE_GREEN_GEM == mineType or MINE_GREEN_GEM_FLASH == mineType then
    --     texPath = "block/gem_green.png"
    -- elseif MINE_YELLOW_GEM == mineType or MINE_YELLOW_GEM_FLASH == mineType then
    --     texPath = "block/gem_yellow.png"
    -- elseif MINE_STATUE == mineType then
    --     texPath = "block/dark_king.png"
    -- end

    return texPath
end

function MineMapLayer:lightMine(data,isEvent8)
    if nil == data then
        return
    end

    for i =1 , #data do
        local posX = data[i][1]
        local posY = data[i][2]
        local mine = self:createSpriteByType(data[i][3])
        if nil ~= mine then
            local key  = string.format("%d_%d",posX,posY)
            if nil ~= self.container[key] then
                self.container[key]:setOpacity(16)
                self:changeMineTex(self.container[key], data[i][3])
                local fadeIn = nil
                if isEvent8 then
                    fadeIn = cc.FadeIn:create((math.random(1,99) / 100) * 4)
                else
                    fadeIn = cc.FadeIn:create(math.random(3,7) / 10)
                end
                local easeBackInOutAct2 = cc.EaseExponentialOut:create(fadeIn)
                self.container[key]:runAction(cc.Sequence:create(easeBackInOutAct2))
                --boss出现效果
                if data[i][3] == MINE_STATUE or (data[i][3] >= MINE_EVENT1 and data[i][3] <= MINE_EVENT9) then
                    local bossApear = FlashAni.new()
                    bossApear:playAction("ui_wabao_boss",function ()
                        bossApear:removeFromParent()
                    end,nil,1)
                    local posX,posY = self.container[key]:getPosition()
                    bossApear:setPosition(posX, posY)
                    self:addChild(bossApear, 1000000)
                end
            else
                self.container[key] = mine
                self:addMine(posX, posY, mine)
                self.container[key]:setOpacity(0)
                local fadeIn = cc.FadeIn:create(math.random(4,6) / 10)
                self.container[key]:runAction(fadeIn)
            end
        end
    end
end

function MineMapLayer:setPositionByMove(x,y)
    -- print("delta x is:",x,"y is:",y)
    --需要简化和重构
    local oldX,oldY = self:getPosition()
    self:setPosition(cc.p(x, y))
    self.diffX = self.diffX + x - oldX
    self.diffY = self.diffY + y - oldY
    if self.diffX < 0 then
        local num = math.floor(math.abs(self.diffX) / math.floor(ICON_MINE_WIDTH * self.curScale))
        if num >= 1 then
            local oldLeft = self.showArea.left
            self.showArea.left = self.showArea.left + num
            for i = oldLeft ,self.showArea.left - 1 do
                for j = self.showArea.top,self.showArea.bottom do
                    local key = string.format("%d_%d",i,j)
                    if self.container[key] ~= nil then
                        self.container[key]:removeFromParent()
                        self.container[key] = nil
                    end
                end
            end

            local oldRight = self.showArea.right
            self.showArea.right = self.showArea.right + num
            for i=oldRight + 1, self.showArea.right do
                for j = self.showArea.top,self.showArea.bottom do
                    local key = string.format("%d_%d",i,j)
                    if gDigMine.data[key] ~= nil then
                        local status =  gDigMine.getMineDigingOrUnget(i,j)
                        if status == 1 or status == 2 then
                            self:processDigEffectDisplay(i,j,key)
                        else
                            local mine = self:createSpriteByType(gDigMine.data[key])
                            if nil ~= mine then
                                if self.container[key] ~= nil then
                                    self.container[key]:removeFromParent()
                                    self.container[key] = nil
                                end
                                self.container[key] = mine
                                self:addMine(i, j, mine)
                            end
                        end
                    else
                        self:createUnDigMine(i,j)
                    end
                end
            end
            self.diffX = self.diffX + num * math.floor(ICON_MINE_WIDTH * self.curScale)
        end
        -- print("width range is:",self.showArea.right - self.showArea.left)
    end

    if self.diffX > 0 then
        local num = math.floor(math.abs(self.diffX) / math.floor(ICON_MINE_WIDTH * self.curScale))
        if num >= 1 then
            local oldRight = self.showArea.right
            self.showArea.right = self.showArea.right - num
            for i = self.showArea.right + 1 , oldRight do
                for j = self.showArea.top,self.showArea.bottom do
                    local key = string.format("%d_%d",i,j)
                    if self.container[key] ~= nil then
                        self.container[key]:removeFromParent()
                        self.container[key] = nil
                    end
                end
            end

            local oldLeft = self.showArea.left
            self.showArea.left = self.showArea.left - num
            for i = self.showArea.left, oldLeft - 1 do
                for j = self.showArea.top,self.showArea.bottom do
                    local key = string.format("%d_%d",i,j)
                    if gDigMine.data[key] ~= nil then
                        local status =  gDigMine.getMineDigingOrUnget(i,j)
                        if status == 1 or status == 2 then
                            self:processDigEffectDisplay(i,j,key)
                        else
                            local mine = self:createSpriteByType(gDigMine.data[key])
                            if nil ~= mine then
                                if self.container[key] ~= nil then
                                    self.container[key]:removeFromParent()
                                    self.container[key] = nil
                                end
                                self.container[key] = mine
                                self:addMine(i, j, mine)
                            end
                        end
                    else
                        self:createUnDigMine(i,j)
                    end
                end
            end
            self.diffX = self.diffX - num * math.floor(ICON_MINE_WIDTH * self.curScale)
        end
        -- print("width range is:",self.showArea.right - self.showArea.left)
    end

    if self.diffY < 0 then
        local num = math.floor(math.abs(self.diffY) / math.floor(ICON_MINE_HEIGHT * self.curScale))
        if num >= 1 then
            local oldBottom = self.showArea.bottom
            self.showArea.bottom = self.showArea.bottom - num
            for j = self.showArea.bottom + 1 , oldBottom do
                for i = self.showArea.left,self.showArea.right do
                    local key = string.format("%d_%d",i,j)
                    if self.container[key] ~= nil then
                        self.container[key]:removeFromParent()
                        self.container[key] = nil
                    end
                end
            end

            local oldTop = self.showArea.top
            self.showArea.top = self.showArea.top - num
            for j = self.showArea.top, oldTop - 1 do
                for i = self.showArea.left,self.showArea.right do
                    local key = string.format("%d_%d",i,j)
                    if gDigMine.data[key] ~= nil then
                        local status =  gDigMine.getMineDigingOrUnget(i,j)
                        if status == 1 or status == 2 then
                            self:processDigEffectDisplay(i,j,key)
                        else
                            local mine = self:createSpriteByType(gDigMine.data[key])
                            if nil ~= mine then
                                if self.container[key] ~= nil then
                                    self.container[key]:removeFromParent()
                                    self.container[key] = nil
                                end
                                self.container[key] = mine
                                self:addMine(i, j, mine)
                            end
                        end
                    else
                        self:createUnDigMine(i,j)
                    end
                end
            end
            self.diffY = self.diffY + num * math.floor(ICON_MINE_HEIGHT * self.curScale)
        end 
        -- print("height range is:",self.showArea.bottom - self.showArea.top,self.showArea.bottom,self.showArea.top)       
    end

    if self.diffY > 0 then
        local num = math.floor(math.abs(self.diffY) / math.floor(ICON_MINE_HEIGHT * self.curScale))
        if num >= 1 then
            local oldTop = self.showArea.top
            self.showArea.top = self.showArea.top + num
            for j = oldTop , self.showArea.top - 1  do
                for i = self.showArea.left,self.showArea.right do
                    local key = string.format("%d_%d",i,j)
                    if self.container[key] ~= nil then
                        self.container[key]:removeFromParent()
                        self.container[key] = nil
                    end
                end
            end

            local oldBottom = self.showArea.bottom
            self.showArea.bottom = self.showArea.bottom + num
            for j = oldBottom + 1, self.showArea.bottom do
                for i = self.showArea.left,self.showArea.right do
                    local key = string.format("%d_%d",i,j)
                    if gDigMine.data[key] ~= nil then
                        local status =  gDigMine.getMineDigingOrUnget(i,j)
                        if status == 1 or status == 2 then
                            self:processDigEffectDisplay(i,j,key)
                        else
                            local mine = self:createSpriteByType(gDigMine.data[key])
                            if nil ~= mine then
                                if self.container[key] ~= nil then
                                    self.container[key]:removeFromParent()
                                    self.container[key] = nil
                                end
                                self.container[key] = mine
                                self:addMine(i, j, mine)
                            end
                        end
                    else
                        self:createUnDigMine(i,j)
                    end
                end
            end
            self.diffY = self.diffY - num * math.floor(ICON_MINE_HEIGHT * self.curScale)
        end
        -- print("height range is:",self.showArea.bottom - self.showArea.top,self.showArea.bottom,self.showArea.top) 
    end
end

function MineMapLayer:getMine(x,y)
    if nil == x or nil == y then
        return
    end
    local key = string.format("%d_%d", x, y)
    for _, effectNode in pairs(self.digEffectNodes) do
        if effectNode.posKey ~= nil and effectNode.posKey == key then
            effectNode.isExploding = false
            effectNode:setVisible(false)
        end
    end

    if self.container[key] ~= nil then
        local posX,posY = self.container[key]:getPosition()
        self.container[key]:removeFromParent()
        self.container[key] = nil
        local disappearFla = FlashAni.new()
        disappearFla:playAction("ui_wabao_icon_2",function ()
            disappearFla:removeFromParent()
        end,nil,1)
        local icon1 = cc.Sprite:create("images/icon/mine/"..gDigMine.digingOrUngetInfoList[key].itemid..".png")
        disappearFla:replaceBoneWithNode({"icon1"},icon1)
        local icon2 = cc.Sprite:create("images/icon/mine/"..gDigMine.digingOrUngetInfoList[key].itemid..".png")
        disappearFla:replaceBoneWithNode({"icon2"},icon2)
        disappearFla:setPosition(posX, posY)
        self:addChild(disappearFla, 1000000)
        if gDigMine.critPoses[key] > 1 then
            self:addCritEffect(posX, posY, gDigMine.critPoses[key])
            gDigMine.critPoses[key] = nil
        end
    end
    gDigMine.removeUngetMineInList(x,y)
    gDigMine.isSendMiningGet = false
    gDigMine.sendMiningGetTime = 0
    gDigMine.data[key] = MINE_TERRAIN_TYPE0
    gDispatchEvt(EVENT_ID_MINING_REFRESH_NEWICON,{iconType=MINE_DIG_ICON5, posX=x, posY=y})
end

function MineMapLayer:setEmptyTex(x,y)
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(self:getTexPath(MINE_TERRAIN_TYPE0))
    if nil ~= spriteFrame then
        local key = string.format("%d_%d", x, y)
        if self.container[key] ~= nil then
            self.container[key]:setTextureRect(spriteFrame:getRect())
        end
    end
end

function MineMapLayer:createUngetMine(itemid)
    local sprite = gDigMine.createMineSprite("images/mine/001/terrain_undig_bg.png")
    
    if nil ~= sprite then
        local icon = cc.Sprite:create("images/icon/mine/"..itemid..".png")
        if nil ~= icon then
            local anchorPoint = icon:getAnchorPoint()
            --TODO
            icon:setAnchorPoint(cc.p(0.32,0.3))
            sprite:addChild(icon,1)
            icon:setPosition(math.floor(117 / 4), math.floor(110 / 4))
        end
    end
    return sprite
end

function MineMapLayer:createUnDigMine(i,j)
    if i >= -gDigMine.xOriRange/2 + 1 and i <= gDigMine.xOriRange/2 and j >=0 and j <= gDigMine.yOriRange - 1 then
        local key = string.format("%d_%d",i,j)
        local mine = gDigMine.createMineSprite("images/mine/001/terrain_undig_bg.png")
        if self.container[key] ~= nil then
            self.container[key]:removeFromParent()
            self.container[key] = nil
        end
        self.container[key] = mine
        self:addMine(i, j, mine)
    end
end

function MineMapLayer:initLayerScale(scale)
    self:setScale(scale)
    self.preScale = scale
    self.curScale = scale
end


function MineMapLayer:setLayerScale(scale)
    if self.curScale == scale then
        return
    end
    self.preScale = self.curScale 
    self.curScale = scale
    local winSize =cc.Director:getInstance():getWinSize()
    local contentSize = self:getParent():getContentSize()
    local selfContentSize = self:getContentSize()
    local worldPos = self:getParent():convertToWorldSpace(cc.p(math.floor(contentSize.width/2), -math.floor(contentSize.height/2)))
    local nodePos  = self:convertToNodeSpace(worldPos)
    local anchorPoint = {x = nodePos.x / selfContentSize.width, y = nodePos.y/selfContentSize.height} 
    -- print("before scale is:",widthNum,heightNum,self.showArea.bottom - self.showArea.top)
    -- self:setAnchorPoint(anchorPoint1)
    gModifyExistNodeAnchorPoint(self,anchorPoint)
    self:layerScaleAction(scale)
end

-----初始化挖掘node
function MineMapLayer:initDigEffectNode()
    local maxCount = DB.getMaxMiners()
    self.digEffectNodes = {}
    for i = 1, maxCount do
        self.digEffectNodes[i] = MineDigEffectNode.new()
        self.digEffectNodes[i]:setAnchorPoint(cc.p(0,0))
        self:addChild(self.digEffectNodes[i], 1000000 + i)
        self.digEffectNodes[i]:setVisible(false)
    end
end

function MineMapLayer:adjustDigEffectNode()
    local x = gDigMine.digingOrUngetInfo.x
    local y = gDigMine.digingOrUngetInfo.y
    -- print("digingOrUngetInfo x is:",x,"y is:",y)
    if nil == self.digEffectNode then
        self:initDigEffectNode()
    end
    local key = string.format("%d_%d",x,y)
    self.digEffectNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
    self.digEffectNode:setData(gDigMine.digingOrUngetInfo.lefttime, gDigMine.digingOrUngetInfo.itemid,gDigMine.data[key])
    self.digEffectNode:setVisible(true)
end
--TODO,完成后删除MineMapLayer:adjustDigEffectNode()
function MineMapLayer:adjustDigEffectNodeEx(x, y, key)
    -- local effectNode = nil
    -- -- local key = string.format("%d_%d",x,y)
    -- for i = 1, maxCount do
    --     effectNode = self.digEffectNodes[i]
    --     if effectNode.posKey ~= nil and effectNode.posKey == key and effectNode:isVisible() and self.container[key] == nil then
    --         effectNode:setDataEx(gDigMine.digingOrUngetInfoList[key].lefttime, gDigMine.digingOrUngetInfoList[key].itemid,gDigMine.data[key],x,y)
    --         break
    --     elseif not effectNode:isVisible() then
    --         effectNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
    --         effectNode:setDataEx(gDigMine.digingOrUngetInfoList[key].lefttime, gDigMine.digingOrUngetInfoList[key].itemid,gDigMine.data[key],x,y)
    --         effectNode.posKey = key
    --         effectNode:setVisible(true)
    --         break
    --     end
    -- end

    local existIdx = -1
    local notVisibleIdx = -1
    for idx, effectNode in pairs(self.digEffectNodes) do
        if effectNode.posKey ~= nil and effectNode.posKey == key and 
           effectNode:isVisible() then
           existIdx = idx
        end

        if not effectNode:isVisible() and notVisibleIdx == -1 then
            notVisibleIdx = idx
        end
    end

    if existIdx ~= -1 then
        if self.container[key] == nil then
            self.digEffectNodes[existIdx]:setDataEx(gDigMine.digingOrUngetInfoList[key].lefttime, gDigMine.digingOrUngetInfoList[key].itemid,gDigMine.data[key],x,y)
        end
        return
    end

    if notVisibleIdx ~= -1 then
        local effectNode = self.digEffectNodes[notVisibleIdx]
        effectNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
        effectNode:setDataEx(gDigMine.digingOrUngetInfoList[key].lefttime, gDigMine.digingOrUngetInfoList[key].itemid,gDigMine.data[key],x,y)
        effectNode.posKey = key
        effectNode:setVisible(true)
    end
end

function MineMapLayer:processDigEffectDisplay(i,j,key)
    if gDigMine.digingOrUngetInfoList[key] ~= nil and gDigMine.digingOrUngetInfoList[key].lefttime > gGetCurServerTime() then
        local mine = self:createSpriteByType(gDigMine.data[key])
        if nil ~= mine then
            self.container[key] = mine
            self:addMine(i, j, mine)
        end
    end

    self:adjustDigEffectNodeEx(i,j,key)
end

function MineMapLayer:processExploder(x,y)
    local key = string.format("%d_%d",x,y)
    local digingOrUngetInfo = gDigMine.digingOrUngetInfoList[key]
    if nil == digingOrUngetInfo then
        return
    end

    local showVisible = true
    if digingOrUngetInfo.itemid == MINE_TERRAIN_TYPE0 then
       showVisible = false 
    end

    for _,effectNode in pairs(self.digEffectNodes) do
        if showVisible then
            if effectNode:isVisible() and 
               effectNode.digingPosX == x and
               effectNode.digingPosY == y then
                    effectNode:processExploder(x,y)
               return
            end
        else
            if not effectNode:isVisible() then
                effectNode:processExploder(x,y)
                effectNode.posKey = string.format("%d_%d",x,y)
                effectNode:setDigPos(x,y)
                effectNode:setVisible(true)
                return
            end
        end
    end
end

function MineMapLayer:addTwinkleEffectOrNot(mineType,mine)
    local lv = gDigMine.getMineTwinkleLv(mineType)
    if lv == MINE_TWINKLE0 then
        return
    end
    local fla = nil
    if lv == MINE_TWINKLE1 then
        fla = gCreateFla("ui_wabao_shitouguang1",1)
    else
        fla = gCreateFla("ui_wabao_shitouguang2",1)
    end
    mine:addChild(fla)
end

function MineMapLayer:isExploding()
    for _,effectNode in pairs(self.digEffectNodes) do
        if effectNode.isExploding then
            return true
        end
    end
    return false
end

function MineMapLayer:removeStatue(x,y)
    -- body
    local key = string.format("%d_%d", x, y)
    if self.container[key] ~= nil then
        -- if nil == self.digEffectNode then
        --     self:initDigEffectNode()
        -- end
        for _,effectNode in pairs(self.digEffectNodes) do
            if not effectNode:isVisible() then
                effectNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
                effectNode:removeStatus(x,y)
                effectNode:setDigPos(x, y)
                effectNode:setVisible(true)
                return
            end
        end
    end
end

function MineMapLayer:layerScaleAction(scale)
    self:stopAllActions()
    local scaleAct = cc.ScaleTo:create(0.5,scale)
    local easeBackInOutAct = cc.EaseExponentialOut:create(scaleAct)
    local callFunc = cc.CallFunc:create(function ()
        gModifyExistNodeAnchorPoint(self,cc.p(0.5,1))
        self:getParent():adjustMineLayerPosAfterScale()
    end )
    self:runAction(cc.Sequence:create(easeBackInOutAct,callFunc))
end

function MineMapLayer:locateStatue()
    if gDigMine.getStatueCount() == 0 then
        return
    end

    -- print("befor container size is:",table.count(self.container))

    local statueInfo = string.split(gDigMine.getAStatueInfo(),"_")
    local idxX = toint(statueInfo[1])
    local idxY = toint(statueInfo[2])
    local posX = (gDigMine.maxX + idxX) * ICON_MINE_WIDTH
    local posY = (gDigMine.yRange - idxY + gDigMine.minY) * ICON_MINE_HEIGHT
    local wordldPos = self:convertToWorldSpace(cc.p(posX,posY))
    local nodePos  = self:getParent():convertToNodeSpace(wordldPos)
    local contentSize = self:getParent():getContentSize()
    if nodePos.x < 0 or nodePos.x > contentSize.width or nodePos.y > 0 or nodePos.y < -contentSize.height then
        local middleX = math.floor((self.showArea.right - self.showArea.left)/2 + self.showArea.left)
        local middleY = math.floor((self.showArea.bottom - self.showArea.top)/2 + self.showArea.top)
        local diffX   = (middleX - idxX) * ICON_MINE_WIDTH * self.curScale
        local diffY   = (idxY - middleY) * ICON_MINE_HEIGHT * self.curScale

        local currentPosX, currentPosY = self:getPosition()
        local newPosX = currentPosX + diffX
        local newPosY = currentPosY + diffY
        if newPosY <= self:getParent().bgTopLimit then
            newPosY = self:getParent().bgTopLimit
        end

        if newPosY >= self:getParent().bgBottomLimit then
            newPosY = self:getParent().bgBottomLimit
        end

        if newPosX >= self:getParent().bgLeftLimit then
            newPosX = self:getParent().bgLeftLimit
        end

        if newPosX <= self:getParent().bgRightLimit then
            newPosX = self:getParent().bgRightLimit
        end
        self:setPositionByMove(newPosX, newPosY)
    end
end
-- TODO
function MineMapLayer:processDiging(x, y)
    if x == nil or y == nil then
        return
    end

    for _, effectNode in pairs(self.digEffectNodes) do
        if not effectNode:isVisible() then
            effectNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
            effectNode:processDiging(x,y)
            effectNode.posKey = string.format("%d_%d",x,y)
            effectNode:setDigPos(x, y)
            effectNode:setVisible(true)
            break
        end
    end
end

function MineMapLayer:processClose()
    -- if self.digEffectNode ~= nil then
    --     self.digEffectNode:processClose()
    -- end
    for _,effectNode in pairs(self.digEffectNodes) do
        effectNode:processClose()
    end
end

function MineMapLayer:updateLayerInfo(rePopUp)
    for _, effectNode in pairs(self.digEffectNodes) do
        if effectNode:isVisible() then
            effectNode:initSchedule()
        end
    end

    for _,item in pairs(self.container) do
        if nil ~= item then
            item:removeFromParent()
        end
    end
    self:initMineInfo(rePopUp)  
end

function MineMapLayer:getGuideItem(name)
    local guideItem = self.container[name]
    if nil ~= guideItem then
        -- guideItem.__convertToWorldPos = function ()
        --     local posInfo = string.split(name,"_")
        --     local idxX = toint(posInfo[1])
        --     local idxY = toint(posInfo[2])
        --     local posX = (gDigMine.maxX + idxX) * ICON_MINE_WIDTH
        --     local posY = (gDigMine.yRange - (idxY-1) + gDigMine.minY) * ICON_MINE_HEIGHT
        --     return self:convertToWorldSpace(cc.p(posX,posY))
        -- end

        guideItem.__getContentSize = function ()
            return {width = ICON_MINE_WIDTH * self.curScale, height = ICON_MINE_HEIGHT * self.curScale}
        end
    end
    self:getParent():addTouchNode(guideItem,"mine_guide",nil,nil,1)
    return self.container[name]
end

function MineMapLayer:clearContainer()
    for _, mine in pairs(self.container) do
        if nil ~= mine then
            mine:removeFromParent(true)
        end
    end
    self.container = {}
end

function MineMapLayer:removeEffectNode()
    -- if self.digEffectNode ~= nil then
    --     self.digEffectNode:removeFromParent(true)
    --     self.digEffectNode = nil
    -- end
    for _, effectNode in pairs(self.digEffectNodes) do
        effectNode:unscheduleUpdateEx()
        effectNode:setVisible(false)
    end
end

function MineMapLayer:getMineByTorpedoExploding(x, y)
    local key = string.format("%d_%d", x, y)
    for _, effectNode in pairs(self.digEffectNodes) do
        if effectNode.digingPosX == x and effectNode.digingPosY == y then
            effectNode:setVisible(false)
        end
    end
    local itemid = gDigMine.getTorpedoExploderMineID(x,y)
    if self.container[key] ~= nil and itemid ~= MINE_TERRAIN_TYPE0 then
        local disappearFla = FlashAni.new()
        disappearFla:playAction("ui_wabao_icon_2",function ()
            disappearFla:removeFromParent()
        end,nil,1)
        
        local icon1 = cc.Sprite:create("images/icon/mine/"..itemid..".png")
        disappearFla:replaceBoneWithNode({"icon1"},icon1)
        local icon2 = cc.Sprite:create("images/icon/mine/"..itemid..".png")
        disappearFla:replaceBoneWithNode({"icon2"},icon2)
        local posX,posY = self.container[key]:getPosition()
        disappearFla:setPosition(posX, posY)
        self:addChild(disappearFla, 1000000)
        self.container[key]:removeFromParent()
        self.container[key] = nil
    end
    gDigMine.data[key] = MINE_TERRAIN_TYPE0    
end


function MineMapLayer:processEvent(eventType, lightMine)
    local x,y = gDigMine.eventTerrainPos.x,gDigMine.eventTerrainPos.y
    for _, effectNode in pairs(self.digEffectNodes) do
        if not effectNode:isVisible() then
            effectNode:setPosition((gDigMine.maxX + x) * ICON_MINE_WIDTH, (gDigMine.yRange - y + 1 + gDigMine.minY) * ICON_MINE_HEIGHT)
            effectNode:processEventDig(eventType, lightMine)
            effectNode.posKey = string.format("%d_%d", x, y)
            effectNode:setDigPos(x, y)
            effectNode:setVisible(true)
            break
        end
    end
end

function MineMapLayer:refreshExploderFlag(posTable)
    if posTable.x == nil then
        return
    end

    for _, effectNode in pairs(self.digEffectNodes) do
        if effectNode.digingPosX == posTable.x and
           effectNode.digingPosY == posTable.y then
           effectNode.isExploding = false
           return
        end
    end
end

function MineMapLayer:locateEventPos(event)
    if gDigMine.getMineEventCount(event) == 0 then
        return
    end

    local mineInfoKey = gDigMine.getMineEventInfo(event)
    if nil == mineInfoKey then
        return
    end

    local mineInfo = string.split(mineInfoKey,"_")
    local idxX = toint(mineInfo[1])
    local idxY = toint(mineInfo[2])
    local posX = (gDigMine.maxX + idxX) * ICON_MINE_WIDTH
    local posY = (gDigMine.yRange - idxY + gDigMine.minY) * ICON_MINE_HEIGHT
    local wordldPos = self:convertToWorldSpace(cc.p(posX,posY))
    local nodePos  = self:getParent():convertToNodeSpace(wordldPos)
    local contentSize = self:getParent():getContentSize()
    if nodePos.x < 0 or nodePos.x > contentSize.width or nodePos.y > 0 or nodePos.y < -contentSize.height then
        local middleX = math.floor((self.showArea.right - self.showArea.left)/2 + self.showArea.left)
        local middleY = math.floor((self.showArea.bottom - self.showArea.top)/2 + self.showArea.top)
        local diffX   = (middleX - idxX) * ICON_MINE_WIDTH * self.curScale
        local diffY   = (idxY - middleY) * ICON_MINE_HEIGHT * self.curScale

        local currentPosX, currentPosY = self:getPosition()
        local newPosX = currentPosX + diffX
        local newPosY = currentPosY + diffY
        if newPosY <= self:getParent().bgTopLimit then
            newPosY = self:getParent().bgTopLimit
        end

        if newPosY >= self:getParent().bgBottomLimit then
            newPosY = self:getParent().bgBottomLimit
        end

        if newPosX >= self:getParent().bgLeftLimit then
            newPosX = self:getParent().bgLeftLimit
        end

        if newPosX <= self:getParent().bgRightLimit then
            newPosX = self:getParent().bgRightLimit
        end
        self:setPositionByMove(newPosX, newPosY)
    end
end

function MineMapLayer:addCritEffect(x, y, critNum)
    -- loadFlaXml("ui_wakuang")
    -- local critEffect = FlashAni.new()
    -- critEffect:playAction("ui_wakuang_word_baoji",function ()
    --     critEffect:removeFromParent()
    -- end,nil,1)
    -- critEffect:setPosition(x+ICON_MINE_WIDTH/2, y+ICON_MINE_HEIGHT/2)
    -- self:addChild(critEffect,1000010)
    local time = 0.5
    local layout = gCreateBaojiWord(critNum)
    layout:setScale(0);
    layout:runAction(cc.Sequence:create(
        cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
        cc.MoveBy:create(time,cc.p(0,100)),
        cc.Spawn:create(cc.MoveBy:create(time,cc.p(0,100)),cc.FadeTo:create(time,0)),
        cc.RemoveSelf:create()
    ) );

    layout:setPosition(x+ICON_MINE_WIDTH/2, y+ICON_MINE_HEIGHT/2)
    self:addChild(layout,1000010)
end

function MineMapLayer:locateDigingOrUngetMine(x,y)
    local posX = (gDigMine.maxX + x) * ICON_MINE_WIDTH
    local posY = (gDigMine.yRange - y + gDigMine.minY) * ICON_MINE_HEIGHT
    local wordldPos = self:convertToWorldSpace(cc.p(posX,posY))
    local nodePos  = self:getParent():convertToNodeSpace(wordldPos)
    local contentSize = self:getParent():getContentSize()
    if nodePos.x < 0 or nodePos.x > contentSize.width or nodePos.y > 0 or nodePos.y < -contentSize.height then
        local middleX = math.floor((self.showArea.right - self.showArea.left)/2 + self.showArea.left)
        local middleY = math.floor((self.showArea.bottom - self.showArea.top)/2 + self.showArea.top)
        local diffX   = (middleX - x) * ICON_MINE_WIDTH * self.curScale
        local diffY   = (y - middleY) * ICON_MINE_HEIGHT * self.curScale

        local currentPosX, currentPosY = self:getPosition()
        local newPosX = currentPosX + diffX
        local newPosY = currentPosY + diffY
        if newPosY <= self:getParent().bgTopLimit then
            newPosY = self:getParent().bgTopLimit
        end

        if newPosY >= self:getParent().bgBottomLimit then
            newPosY = self:getParent().bgBottomLimit
        end

        if newPosX >= self:getParent().bgLeftLimit then
            newPosX = self:getParent().bgLeftLimit
        end

        if newPosX <= self:getParent().bgRightLimit then
            newPosX = self:getParent().bgRightLimit
        end
        self:setPositionByMove(newPosX, newPosY)
    end
end

function MineMapLayer:getDigingMineInPos(posKey)
    for _, effectNode in pairs(self.digEffectNodes) do
        if effectNode:isVisible() and effectNode.posKey ~= nil and effectNode.posKey == posKey then
            return effectNode
        end
    end

    return nil
end

return MineMapLayer
