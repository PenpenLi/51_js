local ActivityRankItem=class("ActivityRankItem",UILayer)

function ActivityRankItem:ctor(actData,myRank)
    self:init("ui/ui_hd_rank_item.map")
    self.curActData = actData
    self.myRank = myRank
end

function ActivityRankItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        Net.sendGetActivityRankReward(self.curActData.actId, self.curData.idx)
    end
end

function ActivityRankItem:setData(key,data)
    self.curData = data

    local size = #data.itemidList
    for i = 1, 4 do
        local nodeBg = self:getNode("reward"..i)
        if(nodeBg)then nodeBg:setVisible(false) end
    end

    if data.rank1 ~= data.rank2 then
        self:setLabelString("lab_title", gGetMapWords("ui_hd_rank_item.plist", "1", string.format("%d~%d",data.rank1, data.rank2)))
    else
        self:setLabelString("lab_title", gGetMapWords("ui_hd_rank_item.plist", "1", data.rank1)) 
    end

    for i, itemId in ipairs(data.itemidList) do
        local nodeBg = self:getNode("reward"..i)
        nodeBg:setVisible(true)
        local dropItem = DropItem.new()
        dropItem:setData(itemId)
        dropItem:setNum(data.numList[i])
        dropItem:setPositionY(dropItem:getContentSize().height)
        gAddMapCenter(dropItem, nodeBg)
    end

    self:getNode("layout_bg"):layout()

    self:refreshStatus()
end

function ActivityRankItem:refreshStatus()

    if self.endTime ~= nil and self.endTime > gGetCurServerTime() then
        self:getNode("btn_get"):setVisible(false)
        self:getNode("sign_no"):setVisible(true)
        self:getNode("sign_yes"):setVisible(false)
        return
    end

    if self.curData.rec then
        self:getNode("btn_get"):setVisible(false)
        self:getNode("sign_no"):setVisible(false)
        self:getNode("sign_yes"):setVisible(true)
    elseif self.myRank >= self.curData.rank1 and self.myRank <= self.curData.rank2 then
        self:getNode("btn_get"):setVisible(true)
        self:getNode("sign_no"):setVisible(false)
        self:getNode("sign_yes"):setVisible(false)
    else
        self:getNode("btn_get"):setVisible(false)
        self:getNode("sign_no"):setVisible(true)
        self:getNode("sign_yes"):setVisible(false)
    end
end

function ActivityRankItem:setGotStatus()
    self.curData.rec = true
    self:refreshStatus()
end

function ActivityRankItem:setEndTime(endTime)
    self.endTime = endTime
end

return ActivityRankItem