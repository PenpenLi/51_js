local MineMermaidBuyPanel=class("MineMermaidBuyPanel",UILayer)

function MineMermaidBuyPanel:ctor(_x,_y)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_mine_mermaid_buy.map")
    self:initPanel()
    self.onAppearedCallback = function()
        gDispatchEvt(EVENT_ID_MINING_REFRESH_EXPLODER,{x = _x,y = _y})
    end
end

function MineMermaidBuyPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_look_later" then
        self:onClose()
    elseif target.touchName == "btn_buy" then
        if self:isTimeOut() then
            self:onClose()
        else
            Net.sendMiningEvent2Buy()
        end
    end
end

function MineMermaidBuyPanel:initPanel()
    --TODO,setItem
    local size = #gDigMine.mermaidBuyItems
    if size ~= 0 then
        for i = 1, size do
            if gDigMine.mermaidBuyItems[i].id ~= 0 then
                local node=DropItem.new() 
                node:setData(gDigMine.mermaidBuyItems[i].id)
                node:setNum(gDigMine.mermaidBuyItems[i].num )  
                node:setPositionY(node:getContentSize().height)
                gAddMapCenter(node, self:getNode("icon"..i))
            else
                self:getNode("icon"..i):setVisible(false)
            end
        end
    end

    self:getNode("layout_icon"):layout()

    self:setLabelString("txt_original_value", gDigMine.event2ExtraInfo.oriPrice)
    self:getNode("layout_original"):layout()

    self:setLabelString("txt_discount_value", gDigMine.event2ExtraInfo.disPrice)
    self:getNode("layout_discount"):layout()

    self:initSchedule()
end

function MineMermaidBuyPanel:initSchedule()
    if gDigMine.getMermaidBuyLeftTime() > 0 then
        local function update()
            if gDigMine.getMermaidBuyLeftTime() > gGetCurServerTime() then
                local minTime = gParserMinTimeEx(gDigMine.getMermaidBuyLeftTime() - gGetCurServerTime())
                self:setLabelString("txt_lefttime_value", minTime)
                self:getNode("layout_lefttime"):layout()
            else
                gDigMine.setMermaidBuyLeftTime(0)
                self:setLabelString("txt_lefttime_value", "00:00")
                self:getNode("layout_lefttime"):layout()
                self:unscheduleUpdateEx()
            end
        end
        self:scheduleUpdate(update, 1)
    else
        self:setLabelString("txt_lefttime_value", "00:00")
        self:getNode("layout_lefttime"):layout()
    end
end

function MineMermaidBuyPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

function MineMermaidBuyPanel:isTimeOut()
    if gDigMine.getMermaidBuyLeftTime() <= gGetCurServerTime() then
        gShowNotice(gGetWords("labelWords.plist","lab_mermaid_buy_timeout"))
        return true
    end
    return false
end

function MineMermaidBuyPanel:events()
    return {EVENT_ID_MINING_MERMAIDBUY_SUC}
end

function MineMermaidBuyPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_MERMAIDBUY_SUC then
        gDigMine.mermaidBuyItems = {}
        self:onClose()
    end
end

return MineMermaidBuyPanel