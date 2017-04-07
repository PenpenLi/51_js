local SoullifeBaoliRewardPanel=class("SoullifeBaoliRewardPanel",UILayer)

function SoullifeBaoliRewardPanel:ctor(previousPanel, param)
    self.appearType = 1
    self:init("ui/ui_soullife_baoli_reward.map")
    self._panelTop=true
    self.ignoreGuide = true
    self.previousPanel = previousPanel
    self.childTagTable = {}
    self.bgContentOriSize = self:getNode("bg_content"):getContentSize()
    self.lineContentScaleX= self:getNode("line_up"):getScaleX()
    self.oriUpPosY = self:getNode("up"):getPositionY()
    self.oriDownPosY = self:getNode("down"):getPositionY()
    local costBaoLi = DB.getBaoLiSpiritCost()
    local isShowDiscount = false
    if Data.activeSoullifeSaleoff.val ~= nil then
        costBaoLi = math.floor(costBaoLi * Data.activeSoullifeSaleoff.val / 100)
        local disCount = Data.activeSoullifeSaleoff.val / 10
        self:setLabelString("txt_discount", gGetMapWords("ui_soullife_baoli_reward.plist","3",disCount))
        self:getNode("flag_discount"):setVisible(true)
        isShowDiscount = true
    else
        self:getNode("flag_discount"):setVisible(false)
    end
    if costBaoLi >= 10000 then
        costBaoLi = string.format("%dW",math.floor(costBaoLi / 10000))
    end

    if isShowDiscount then
        costBaoLi = string.format("\\\\w{c=00ff00;s=20}%s",costBaoLi)
    end

    self:setRTFString("txt_again", gGetWords("spiritWord.plist","spirit_baoli_again",costBaoLi))
    self:updateData(param)
    
    -- local delay = cc.DelayTime:create(2)
    -- local callFunc = cc.CallFunc:create(function()
    --     if self.previousPanel ~= nil then
    --         self.previousPanel:updateBaoLiResult(self.data)
    --     end
    --     self:onClose()
    -- end)
    -- self:runAction(cc.Sequence:create(delay, callFunc))
end

function SoullifeBaoliRewardPanel:onTouchEnded(target,touch, event)
    if target.touchName=="btn_close" then
        if self.previousPanel ~= nil and self.data ~= nil then
            self.previousPanel:updateBaoLiResult(self.data)
        end
        self:onClose()
    elseif target.touchName=="btn_again" then
        local lvLimit = DB.getClientParam("SPIRIT_BAOLI_OPEN_LV")   
        if Data.getCurLevel() < lvLimit and gIsVipExperTimeOver(VIP_SPIRIT_VIOLENCE) then
            return
        end

        local costBaoLi = DB.getBaoLiSpiritCost()
        local showDiscount = false
        if Data.activeSoullifeSaleoff.val ~= nil then
            if Data.activeSoullifeSaleoff.time > gGetCurServerTime() then
                costBaoLi = math.floor(costBaoLi * Data.activeSoullifeSaleoff.val / 100)
                showDiscount = true
            else
                Data.activeSoullifeSaleoff.time = nil
                Data.activeSoullifeSaleoff.val = nil
            end
        end

        self:getNode("flag_discount"):setVisible(showDiscount)
        local strCostBaoLi = costBaoLi
        if strCostBaoLi >= 10000 then
            strCostBaoLi = string.format("%dW",math.floor(costBaoLi / 10000))
        end

        if showDiscount then
            strCostBaoLi = string.format("\\\\w{c=00ff00;s=20}%s",strCostBaoLi)
        end

        self:setRTFString("txt_again", gGetWords("spiritWord.plist","spirit_baoli_again",strCostBaoLi))

        if not Data.isGoldEnough(costBaoLi) then
            NetErr.noEnoughGold();
            return
        end

        if self.previousPanel ~= nil and self.data ~= nil then
            self.previousPanel:updateBaoLiResult(self.data)
            self.data = nil
        end

        if SpiritInfo.getBagSpiritSize() >= DB.getSpiritBagMax() then
            gShowNotice(gGetWords("spiritWord.plist", "bag_maxcount_limit"))
            return
        end

        Net.sendSpiritBaoLi()
    end
end

function SoullifeBaoliRewardPanel:updateData(param)
    self.bg_content = self:getNode("bg_content")
    self.data = param
    for _,var in ipairs(self.childTagTable) do
        self.bg_content:removeChildByTag(var)
    end

    self.childTagTable = {}

    local itemSpaceW = 150
    local itemSpaceH = 150
    local size = clone(self.bgContentOriSize)
    local count = table.getn(param.items)
    local offW = 200
    local offH = 100
    if count <= 3 then
        self.bg_content:setContentSize(size)
        self:getNode("line_up"):setScaleX(self.lineContentScaleX)
        self:getNode("line_down"):setScaleX(self.lineContentScaleX)
        self:getNode("up"):setPositionY(self.oriUpPosY);
        self:getNode("down"):setPositionY(self.oriDownPosY);
    elseif count > 3 then
        size.width = size.width + offW;
        self.bg_content:setContentSize(size.width,size.height);
        self.line_up = self:getNode("line_up");
        local scaleX = self.lineContentScaleX;
        self.line_up:setScaleX(scaleX + offW/self.line_up:getContentSize().width);
        self.line_down = self:getNode("line_down");
        self.line_down:setScaleX(scaleX + offW/self.line_down:getContentSize().width);
    end
    local posX = size.width/2 - itemSpaceW*0.5*(count-1);
    local posY = size.height/2;
    
    if count > 5 then
        local row = math.floor((count-1) / 5);
        if row > 1 then
            offH = 50;
            itemSpaceH = 120;
        end
        if row > 2 then
            row = 2;
        end
        offH = row * offH;
        size.height = size.height + offH;
        self.bg_content:setContentSize(size.width,size.height);
        posX = size.width/2 - itemSpaceW*0.5*(5-1);
        posY = size.height/2 + itemSpaceH*0.5*(row);  
        self:getNode("up"):setPositionY(self:getNode("up"):getPositionY() + offH/2);
        self:getNode("down"):setPositionY(self:getNode("down"):getPositionY() - offH/2);
    end

    local spiritItem = nil
    local tag = 1
    for i, spirit in pairs(param.items) do
        local indexW = (i-1) % 5;
        local indexH = math.floor((i-1) / 5);
        if spirit.iType == SPIRIT_TYPE.EXP then
            spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, i, false)
            spiritItem:setItem()
            spiritItem:setNameTxt(spirit.iValue)
        else
            spiritItem = XunXianItem.new(spirit, SPIRIT_OPERATE_TYPE.OPERATE_TYPE_FIND, i, true)
            spiritItem:setItem()
            if spirit.iType == SPIRIT_TYPE.CHIP then
                spiritItem:setNameTxt(gGetWords("item.plist","item_id_69999"))
                spiritItem:setLvTxt(spirit.iValue)
            end
        end
        spiritItem:setPosition(cc.p(posX+indexW*itemSpaceW - spiritItem:getContentSize().width/2,
            posY-indexH*itemSpaceH+spiritItem:getContentSize().height/2));
        self.bg_content:addChild(spiritItem);
        spiritItem:setTag(tag)
        table.insert(self.childTagTable,tag)
        tag = tag + 1
    end
end

return SoullifeBaoliRewardPanel