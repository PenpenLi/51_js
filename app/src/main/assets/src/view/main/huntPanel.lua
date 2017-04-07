local HuntPanel=class("HuntPanel",UILayer)

local worldBossHuntIdx = 1
local treasureHuntIdx = 2
local lootFoodHuntIdx = 3
local waitIdx = 99
local itemWaitNone = 0
local itemWaitOpen = 1
local itemOpenCountDown = 2
local itemDoingCountDown =3
local itemTag = 100

function HuntPanel:ctor()
    self.appearType = 1;
    self:init("ui/ui_team_bg.map")
    self.redDotBg = {}
    self:initItemPosAndScale()
    self:initShowIdx()
    self:setItemShow()
    self.isMove = false
end

function HuntPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

function HuntPanel:onTouchMoved(target, touch, event)
    if self.isMove then
        return
    end

    local offsetX=touch:getDelta().x
    if math.abs(offsetX) > 5 then
        self.isMove = true
        self:scrollItem(offsetX > 0)
    end
end

function HuntPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    end
end

function HuntPanel:events()
    return {
        EVENT_ID_WORLD_BOSS_INFO,
    }
end

function HuntPanel:dealEvent(event, param)
    if event == EVENT_ID_WORLD_BOSS_INFO then
        Panel.popUp(PANEL_WORLD_BOSS)
    end
end

function HuntPanel:initShowIdx()
    self.showIdx = {}
    self.showIdx[0] = #Data.finalHuntIntervalInfos
    local max = #HUNT_ID_MAP+1
    for i = 1, max-1 do
        self.showIdx[i] = i
    end

    if #Data.finalHuntIntervalInfos >= max then
        self.showIdx[max] = max
    else
        self.showIdx[max] = 1
    end
end

function HuntPanel:setItemShow()
    -- #Data.finalHuntIntervalInfos
    self.huntItems = {}
    local max = #HUNT_ID_MAP
    -- 超过两个，补一个到后面去
    -- 只有两个，不滑动，只需显示两个
    if max > 2 then
        max = max+1
    end

    for i = 0, max do
        local obj = Data.finalHuntIntervalInfos[self.showIdx[i]]
        local item = HuntItem.new(obj,i, self)
        item:setTag(itemTag)
        item:setAnchorPoint(cc.p(0.5,-0.5))
        if i == 2 then
            item:setScale(1.08)
        else
            item:setScale(0.95)
        end
        item:setPosition(self.initItemPos[i].x, self.initItemPos[i].y)
        self:addChild(item)
        self.huntItems[i] = item

        self.redDotBg[i] = {}
        self.redDotBg[i].bg = item
    end
end

function HuntPanel:initItemPosAndScale()
    self.initItemPos = {}
    self.initScale   = {}
    self.itemIdx = {}
    local max = #HUNT_ID_MAP+1

    for i = 0, max do
        self.initItemPos[i] = {}
        self.itemIdx[i] = i
        self.initItemPos[i].x,self.initItemPos[i].y = self:getNode("pos"..i):getPosition()
        if i == 2 then
            self.initScale[i] = 1.08
        else
            self.initScale[i] = 0.95
        end
    end
end

function HuntPanel:scrollItem(isRight)
    local max = #HUNT_ID_MAP + 1
    if max < 4 then
        self.isMove = false
        return
    end

    local oldShowIdX = clone(self.showIdx)
    -- for i= 0, 4 do
    --     print("oldShowIdX idx is:",oldShowIdX[i])
    -- end

    if isRight then
        for i = 4 , 0, -1 do
            if i ~= 0 then
                self.showIdx[i] = self.showIdx[i - 1]
            else
                -- 第一条
                if self.showIdx[i] == 1 then
                    self.showIdx[i] = #Data.finalHuntIntervalInfos
                else
                    self.showIdx[i] = self.showIdx[i] - 1
                    if self.showIdx[i] == 0 then
                        self.showIdx[i] = #Data.finalHuntIntervalInfos
                    end
                end
            end
        end
    else
        for i = 0, 4 do
            if i ~= 4 then
                self.showIdx[i] = self.showIdx[i+1]
            else
                if self.showIdx[i] == #Data.finalHuntIntervalInfos then
                    self.showIdx[i] = 1
                else
                    self.showIdx[i] = self.showIdx[i] + 1
                end
            end
        end
    end

    -- for i= 0, 4 do
    --     print("showIdx idx is:",self.showIdx[i])
    -- end

    local fTime = 0.3
    local oldItemIdx = clone(self.itemIdx)

    -- for i= 0, 4 do
    --     print("oldItemIdx idx is:",oldItemIdx[i])
    -- end

    for i = 0, 4 do
        local moveToIdx = 0
        if isRight then
            moveToIdx = i + 1
        else
            moveToIdx = i - 1
        end

        if moveToIdx <= 4 and moveToIdx >= 0 then
            local moveAct = cc.MoveTo:create(fTime, self.initItemPos[moveToIdx])
            local scaleAct = cc.ScaleTo:create(fTime, self.initScale[moveToIdx])
            local spawn = cc.Spawn:create(moveAct, scaleAct)
            self.huntItems[oldItemIdx[i]]:runAction(spawn)
            -- print("moveToIdx idx is:",moveToIdx, " oldItemIdx is:", oldItemIdx[i])
            self.itemIdx[moveToIdx] = oldItemIdx[i]
        elseif moveToIdx > 4 then
            self.huntItems[oldItemIdx[i]]:setPosition(self.initItemPos[0].x, self.initItemPos[0].y)
            -- print("showIdx idx is:", 0, " oldShowIdX:", oldShowIdX[4])
            self.huntItems[oldItemIdx[i]]:refreshItemInfo(Data.finalHuntIntervalInfos[self.showIdx[0]])
            -- print("moveToIdx idx is:",0, " oldItemIdx is:", oldItemIdx[4])
            self.itemIdx[0] = oldItemIdx[4]
        elseif moveToIdx < 0 then
            self.huntItems[oldItemIdx[i]]:setPosition(self.initItemPos[4].x, self.initItemPos[4].y)
            -- print("showIdx idx is:", 4, " oldShowIdX is:", oldShowIdX[0])
            self.huntItems[oldItemIdx[i]]:refreshItemInfo(Data.finalHuntIntervalInfos[self.showIdx[4]])
            -- print("moveToIdx idx is:", 4, " oldItemIdx is:", oldItemIdx[0])
            self.itemIdx[4] = oldItemIdx[0]
        end
    end

    local delayAct = cc.DelayTime:create(fTime)
    local callFunc = cc.CallFunc:create(function()
        self.isMove = false
    end)
    self:runAction(cc.Sequence:create(delayAct, callFunc))
end

return HuntPanel