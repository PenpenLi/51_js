

function PetExploreActivityPanel:showResult(delayGray)
    loadFlaXml("ui_lingshou_fanpai")
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    local function showGray()
        for i=1,3 do
            DisplayUtil.setGray(self:getNode("hd1_card"..i),true)
        end
        eventData.endFlip = true
    end
    eventData.randIndex = eventData.randIndex or 1
    eventData.indexArray = eventData.indexArray or {}
    self:changeTexture("target_card","images/ui_lingshou/ka"..eventData.randIndex..".png")
    for i=1,3 do
        self:getNode("hd1_card"..i).__touchable=false
        self:getNode("hd1_card"..i):removeAllChildren()
         if i==eventData.clickIdx then
            if eventData.win then
                gAddCenter(gCreateFla("ui_ls_fanpai_v",-1), self:getNode("hd1_card"..i))
            else
                gAddCenter(gCreateFla("ui_ls_fanpai_x",-1), self:getNode("hd1_card"..i))
            end
        end
        eventData.indexArray[i] = eventData.indexArray[i] or 0
        self:changeTexture("hd1_card"..i,"images/ui_lingshou/ka"..eventData.indexArray[i]..".png")
    end
    if delayGray and delayGray ==true then
        local actions = {}
        table.insert(actions,cc.DelayTime:create(0.8))
        table.insert(actions,cc.CallFunc:create(showGray))
        self:getNode("hd1_card"..eventData.clickIdx):runAction(
            cc.Sequence:create(actions)
        )
    else
        showGray()
    end
end


function PetExploreActivityPanel:initCaveCardInfo(param1,param2)
    self:unscheduleUpdateEx()
    for i=1,3 do
        local cardItem = self:getNode("hd1_card"..i)
        cardItem:removeAllChildren()
        cardItem:stopAllActions()
        cardItem:setRotation3D(cc.vec3(0,0,0))
        cardItem:setScale(1)
        cardItem:setOpacity(255)
    end
    self:stopAllActions()
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    eventData.endFlip = false
    if eventData and eventData.status==false then
        self:showResult()
        return
    end
    self.tabCards = {}
    self.shakeidx = 0
    self.bActFinish = false
    self.shakeTime = 0
    self.endtime =0
    self.flopTime = 0.3
    self.showItemsTime = 1.5
    self.clickIdx=1
    for i=1,2 do
        local itemid = Data.petCave.eventCardRewards[(i-1)*2+1]
        local itemnum = Data.petCave.eventCardRewards[(i-1)*2+2]
        Icon.setDropItem(self:getNode("hd1_icon"..i),itemid,itemnum)
    end
    local card2 = self:getNode("hd1_card2")
    card2:removeAllChildren()
    self.indexArray={1,2,3}
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    if eventData.randIndex==nil then
       eventData.randIndex = getRand(1,table.count(self.indexArray))
    end
    self.randIndex = eventData.randIndex
    self:changeTexture("target_card","images/ui_lingshou/ka"..self.randIndex..".png")
    
    if self.curData.status==false then
       return
    end
    local function updateTime() 
        if self.shakeCard then
            self:shakeCard()
        end
    end
    self:beginAction()
    self:scheduleUpdate(updateTime,1)

end


function PetExploreActivityPanel:beginAction()

  for i = 1,3 do
    DisplayUtil.setGray(self:getNode("hd1_card"..i),false)
    self:changeTexture("hd1_card"..i,"images/ui_lingshou/ka0.png")
    local cardItem = self:getNode("hd1_card"..i)
    cardItem.bHadFlop = false
    cardItem.__touchable=false
    table.insert(self.tabCards,cardItem)
  end

    self:showItemsAction()
end

function PetExploreActivityPanel:flopCard(node,playtime,rotation,delaytime,halffunc,endfunc)
    -- 翻牌动画
    playtime = playtime or 0
    delaytime = delaytime or 0
    rotation = rotation or 0

    local actions = {}
    if delaytime > 0 then
        table.insert(actions,cc.DelayTime:create(delaytime))
    end
        
    table.insert(actions,cc.RotateTo:create(playtime,  cc.vec3(0,rotation,0)))
    if halffunc then
        table.insert(actions,cc.CallFunc:create(halffunc))
    end
    
    table.insert(actions,cc.RotateTo:create(playtime,  cc.vec3(0,0,0)))

    if endfunc then
        table.insert(actions,cc.CallFunc:create(endfunc))
    end

    node:runAction(
        cc.Sequence:create(actions)
    )
end


function PetExploreActivityPanel:handleCardsAction()
    -- 洗牌、发牌动画
    for k,v in pairs(self.tabCards) do
        v:removeAllChildren()
        v:setOpacity(0)
    end

    local cardBg = self:getNode("hd1_card2")
    loadFlaXml("ui_lingshou_fanpai")
    local handleCardsFlash=gCreateFla("ui_ls_fanpaidonghua",-1)
    gAddCenter(handleCardsFlash,cardBg)

    --print("动画时间:"..gGetActionTime("ui_fanpaidonghua"))
    local actback= cc.Sequence:create(cc.DelayTime:create(gGetActionTime("ui_ls_fanpaidonghua")),cc.CallFunc:create(self.finishAction))
    self:runAction(actback)
end

function PetExploreActivityPanel:finishAction()
    self.bActFinish = true
    for k,v in pairs(self.tabCards) do
        v:removeAllChildren()
        v:setOpacity(255)
        v.__touchable=true
    end
end

function PetExploreActivityPanel:showItemsAction()
    -- 显示所有物品动画
    local cardNum = table.count(self.tabCards)
    for i = 1,cardNum do
        local cardItem = self.tabCards[i]
        local changeRotation=90
        local offsetRotation = 45
        cardItem:setRotation3D(cc.vec3(0,offsetRotation,0))

        local function onMoveFinish()
            self:handleCardsAction()
        end

        local function onMoveHalf()
            

            local child = cardItem:getChildByTag(1000)
            if child==nil then
                local wordBg = cc.Sprite:create()
                wordBg:setTag(1000)
                gAddCenter(wordBg,cardItem)
                cardItem:setTexture("images/ui_lingshou/ka"..i..".png")
            else
                cardItem:removeAllChildren()
                cardItem:setTexture("images/ui_lingshou/ka0.png")
            end
            
            
        end

        local function onMoveEnd()
            local callback = nil
            if i == cardNum then
                callback = onMoveFinish
            end 
            
            self:flopCard(cardItem,self.flopTime,changeRotation,self.showItemsTime,onMoveHalf,callback)
        end
        local playtime = self.flopTime*(changeRotation-offsetRotation)/changeRotation
        self:flopCard(cardItem,playtime,changeRotation-offsetRotation,0,onMoveHalf,onMoveEnd)
    end
end

function PetExploreActivityPanel:shakeCard()
    if self.bActFinish == false then
        return
    end

    self.shakeTime = self.shakeTime + 1

    if self.shakeTime < 2 then
        return
    else 
        self.shakeTime = 0
    end

    local pre_idx = 0
    local next_idx = 0 

    for i = 1,table.count(self.tabCards) do
        local node = self.tabCards[i]
        if node.bHadFlop == false then
            if self.shakeidx < i then
                next_idx = i
                break
            elseif pre_idx == 0 then
                pre_idx = i
            end
        end
    end

    local idx = 0
    if next_idx > 0 then
        idx = next_idx
    elseif pre_idx > 0 then
        idx = pre_idx
    end

    if idx > 0 then
        self.shakeidx = idx
        local card = self.tabCards[idx]
        local actions = {}
        local scaleBy = cc.ScaleBy:create(0.2,1.2)
        table.insert(actions,scaleBy)
        table.insert(actions,scaleBy:reverse())
        card:runAction(cc.Sequence:create(actions))
    end
end

function PetExploreActivityPanel:clickCard(node,index,delayTime,onMoveEnd)
    -- 翻开卡牌,显示道具
    delayTime = delayTime or 0
    local changeRotation = 90
    node.bHadFlop = true
    local icon = nil        
    local function onMoveHalf()
        node:removeAllChildren()
        node:setRotation3D(cc.vec3(0,-180+changeRotation,0))
        node:setTexture("images/ui_lingshou/ka"..index..".png")
    end
            
    self:flopCard(node,self.flopTime,changeRotation,delayTime,onMoveHalf,onMoveEnd)
end

function PetExploreActivityPanel:dealCaveCard(param1,param2)
    local eventData = Data.CaveInfo.eventList[gcurLongId]
    for i=1,3 do
        local cardItem = self:getNode("hd1_card"..i)
        cardItem.__touchable=false
    end
    self:unscheduleUpdateEx()
    local cardItem = self.tabCards[self.clickIdx]
    table.remove(self.tabCards,self.clickIdx)

    local index = self.randIndex
    if eventData.win==false then
        for key,value in pairs(self.indexArray) do
            if value ~=self.randIndex  then
                index = key
                break
            end
        end
    end
    eventData.clickIdx=self.clickIdx
    eventData.randIndex=self.randIndex
    eventData.indexArray={1,2,3}
    table.remove(eventData.indexArray,index)
    table.insert(eventData.indexArray,self.clickIdx,index)

    table.remove(self.indexArray,index)

    self:clickCard(cardItem,index)
    local function onMoveEnd()
        local function func()
            self:showResult(true)
        end
        local actions = {}
        table.insert(actions,cc.DelayTime:create(1))
        table.insert(actions,cc.CallFunc:create(func))
        self:runAction(
            cc.Sequence:create(actions)
        )
    end
    local callbackEnd = nil
    for i=1,2 do
        if i==1 then
            callbackEnd = onMoveEnd
        end
        self:clickCard(self.tabCards[i],self.indexArray[i],self.flopTime*2,callbackEnd)
    end
    
end


