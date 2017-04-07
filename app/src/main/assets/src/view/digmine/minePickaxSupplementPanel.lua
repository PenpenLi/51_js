local MinePickaxSupplementPanel=class("MinePickaxSupplementPanel",UILayer)

function MinePickaxSupplementPanel:ctor(_x,_y)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_mine_pickax_supplement.map")
    self:initPointerAction()
    self.supplementNums = 0
    self:setLabelInfo()
    self.canClickToSupplement = true
    self:getNode("container"):setVisible(false)
    self.onAppearedCallback = function()
        gDispatchEvt(EVENT_ID_MINING_REFRESH_EXPLODER,{x = _x,y = _y})
    end
end

function MinePickaxSupplementPanel:onTouchBegan(target,touch, event)
    if target.touchName ~= "btn_close" then
        if self:getNode("container"):isVisible() then
            -- gShowNotice(gGetWords("noticeWords.plist","has_pickax_reward_items"))
            self:getRewards()
            return
        end
        if not self:checkCondition() then
            return
        end
        if self.canClickToSupplement then
            self.canClickToSupplement = false
            self:getNode("btn_pointer"):stopAllActions()
            loadFlaXml("ui_zhizhen")
            local stall,effectIdx = self:getStall()
            local pointerFla = FlashAni.new()
            pointerFla:playAction("ui_digmine_zhizhen",function ()
                pointerFla:removeFromParent()
                self:getNode("btn_pointer"):setVisible(true)
                self:getNode("effect_container"..effectIdx):removeChildByTag(99)
            end,nil,1)
            self:getNode("btn_pointer"):setVisible(false)
            pointerFla:setPosition(self:getNode("btn_pointer"):getPosition())
            self:getNode("btn_supplement_bar"):addChild(pointerFla)
            self:createSelectAreaEffect(effectIdx)
            local delay = cc.DelayTime:create(0.5)
            local callFunc = cc.CallFunc:create(function()
                Net.sendMiningEvent4Elec(stall)
            end )
            self:runAction(cc.Sequence:create(delay,callFunc))
        end
    end
end

function MinePickaxSupplementPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        if self:getNode("container"):isVisible() then
            gShowNotice(gGetWords("noticeWords.plist","has_pickax_reward_items"))
            return
        end

        if gDigMine.getPickaxSupplementNums() < DB.getMiningEvent4FreeNums() then
            gConfirmCancel(gGetWords("noticeWords.plist","has_pickax_supplement", DB.getMiningEvent4FreeNums() - gDigMine.getPickaxSupplementNums()), function()
                self:onClose()
                gDigMine.setPickaxSupplementNums(0)
            end)
        else
            self:onClose()
            gDigMine.setPickaxSupplementNums(0)
        end
    end
end

function MinePickaxSupplementPanel:events()
    return { EVENT_ID_MINING_PICKAX_SUPPLEMENT }
end

function MinePickaxSupplementPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_PICKAX_SUPPLEMENT then
        -- local posX, posY = self:getNode("btn_pointer"):getPosition()
        -- local contentSize = self:getNode("btn_supplement_bar"):getContentSize()
        if gDigMine.eventRewards.items ~= nil and #gDigMine.eventRewards.items > 0 then
            self.supplementNums = self.supplementNums + gDigMine.eventRewards.items[1].num
            self:setLabelInfo()
            self:rewardShow()
        end
    end
end

function MinePickaxSupplementPanel:initPointerAction()
    local supplementNums = gDigMine.getPickaxSupplementNums()
    local pointerContenSize = self:getNode("btn_pointer"):getBoundingBox()
    local contentSize = self:getNode("btn_supplement_bar"):getContentSize()
    local time = 1
    if supplementNums == 1 then
        time = 0.6
    elseif supplementNums == 2 then
        time = 0.3
    end
    local moveBy = cc.MoveBy:create(time,cc.p(contentSize.width - pointerContenSize.width,0))
    local move_ease = cc.EaseCircleActionInOut:create(moveBy:clone())
    local move_ease_back = move_ease:reverse()
    -- local seq = cc.Sequence:create(moveBy,move_ease_back)
    local seq = cc.Sequence:create(moveBy,moveBy:reverse())
    self:getNode("btn_pointer"):runAction(cc.RepeatForever:create(seq))
end

function MinePickaxSupplementPanel:getStall()
    local posX, posY = self:getNode("btn_pointer"):getPosition()
    local contentSize = self:getNode("btn_supplement_bar"):getContentSize()
    local rate = posX / contentSize.width
    -- print("posX is:",posX," width is:",contentSize.width, " rate is:",rate)
    if rate >= 0.45 and rate < 0.55 then
        return 3,1
    elseif (rate >= 0.3 and rate < 0.45) then
        return 2,2
    elseif (rate >= 0.55 and rate < 0.7) then
        return 2,4
    elseif (rate >= 0.7 and rate < 1) then
        return 1,5
    else
        return 1,3
    end
end

function MinePickaxSupplementPanel:checkCondition()
    if gDigMine.getPickaxSupplementNums() >= DB.getMiningEvent4FreeNums() then
        gShowNotice(gGetWords("noticeWords.plist","no_pickax_supplement"))
        return false
    end

    return true
end

function MinePickaxSupplementPanel:setLabelInfo()
    local maxNums = DB.getMiningEvent4FreeNums()
    self:setLabelString("txt_left_count", string.format("%d/%d",maxNums - gDigMine.getPickaxSupplementNums(),maxNums))
    self:getNode("layout_left_count"):layout()
    self:setLabelString("txt_pickax_info", string.format("+%d",self.supplementNums))
    self:getNode("layout_pickax"):layout()
end

function MinePickaxSupplementPanel:rewardShow()
    if gDigMine.eventRewards.items == nil or #gDigMine.eventRewards.items == 0 then
        self.canClickToSupplement = true
        return
    end

    local item = gDigMine.eventRewards.items[1]
    local itemName = DB.getItemName(item.id)
    local node=DropItem.new()
    node:setData(item.id,5)
    node:setNum(item.num)
    node:setTag(99)
    node:setPositionY(node:getContentSize().height)
    node.touch = false
    node.isSelect = false
    gAddMapCenter(node, self:getNode("container"))
    node.selectItemCallback = function()
        self:getRewards()
    end
    -- node.preSelectItemCallback = function()
    --     if node.isSelect then
    --         return
    --     end
    --     self:getNode("icon_bg"):setVisible(false)
    --     loadFlaXml("ui_zhuanpan")
    --     if gDigMine.eventRewards.items ~= nil and #gDigMine.eventRewards.items > 0 then
    --         local getFla = FlashAni.new()
    --         getFla:playAction("ui_zhuanpan_huode",function ()
    --             -- getFla:removeFromParent()
    --             self:getNode("container"):removeChildByTag(99)
    --             self:getNode("container"):setVisible(false)
    --             gDigMine.eventRewards = {}
    --             if gDigMine.getPickaxSupplementNums() >= DB.getMiningEvent4FreeNums() then
    --                 self:onClose()
    --                 gDigMine.setPickaxSupplementNums(0)
    --             else
    --                 self.canClickToSupplement = true
    --                 self:resetPointerAction()
    --             end
    --         end,nil,1)

    --         local itemIcon = cc.Sprite:create("images/ui_digmine/dianzuana.png")
    --         getFla:replaceBoneWithNode({"wupin","icon"},itemIcon)
    --         -- self:replaceNode("icon",getFla)
    --         self:getNode("container"):getChildByTag(99):replaceNode("icon",getFla)
    --         self:getNode("container"):getChildByTag(99):setNum(0)
    --     end
    --     node.isSelect = true
    -- end

    local moveBy = cc.MoveBy:create(0.8,cc.p(0,10))
    local moveByBack = moveBy:reverse()
    local actRepeat =cc.RepeatForever:create(cc.Sequence:create(moveBy,moveByBack))
    self:getNode("container"):runAction(actRepeat)
    self:getNode("container"):setVisible(true)
    self:getNode("icon_bg"):setVisible(true)
end

function MinePickaxSupplementPanel:resetPointerAction()
    local pointerContenSize = self:getNode("btn_pointer"):getBoundingBox()
    local posX, posY = self:getNode("btn_pointer"):getPosition()
    self:getNode("btn_pointer"):setPosition(cc.p(pointerContenSize.width / 2,posY))
    if gDigMine.getPickaxSupplementNums() < DB.getMiningEvent4FreeNums() then
        self:initPointerAction()
    end
end

function MinePickaxSupplementPanel:createSelectAreaEffect(idx)
    local areaEffectFla = gCreateFla("ui_digmine_keducao"..idx,1)
    areaEffectFla:setTag(99)
    self:getNode("effect_container"..idx):addChild(areaEffectFla)
end

function MinePickaxSupplementPanel:getRewards()
    local node = self:getNode("container"):getChildByTag(99)
    if node == nil then
        self.canClickToSupplement = true
        return
    end

    if node.isSelect then
        self.canClickToSupplement = true
        return
    end
    self:getNode("icon_bg"):setVisible(false)
    loadFlaXml("ui_zhuanpan")
    if gDigMine.eventRewards.items ~= nil and #gDigMine.eventRewards.items > 0 then
        local getFla = FlashAni.new()
        getFla:playAction("ui_zhuanpan_huode",function ()
            -- getFla:removeFromParent()
            self:getNode("container"):removeChildByTag(99)
            self:getNode("container"):setVisible(false)
            gDigMine.eventRewards = {}
            -- if gDigMine.getPickaxSupplementNums() >= DB.getMiningEvent4FreeNums() then
            --     self:onClose()
            --     gDigMine.setPickaxSupplementNums(0)
            -- else
            self.canClickToSupplement = true
            self:resetPointerAction()
            -- end
        end,nil,1)

        local itemIcon = cc.Sprite:create("images/ui_digmine/dianzuana.png")
        getFla:replaceBoneWithNode({"wupin","icon"},itemIcon)
        -- self:replaceNode("icon",getFla)
        self:getNode("container"):getChildByTag(99):replaceNode("icon",getFla)
        self:getNode("container"):getChildByTag(99):setNum(0)
    end
    node.isSelect = true
end

return MinePickaxSupplementPanel