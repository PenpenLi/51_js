local GiftPanel=class("GiftPanel",UILayer)

function GiftPanel:ctor(data) 
    self.appearType = 1;
    self:init("ui/ui_gift.map")
    self._panelTop = true;
    self:setData(data)
end

function GiftPanel:setData(data)
    self.curData=data

    self:setLabelString("lab_title",DB.getItemName(data.boxid))

    local items = DB.getBoxItemById(data.boxid)
    local idx=1
    for key, item in pairs(items) do
        if( self:getNode("icon_"..idx))then
            self:getNode("icon_"..idx):setVisible(true)
            local node=DropItem.new()
            node:setData(item.itemid)
            node:setNum(item.itemnum)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon_"..key)) 
        end
        idx=idx+1
    end
    while(self:getNode("icon_"..idx))do
        self:getNode("icon_"..idx):setVisible(false)
        idx=idx+1
    end
    self:resetLayOut()
end

function GiftPanel:onTouchEnded(target)
    -- if  target.touchName=="btn_get"then
    --     if (Data.m_onlineInfo.bolShowRedPoint) then
    --         Net.sendGiftbagGetOnline();
    --         Panel.popBack(self:getTag())
    --     else
    --         --提示不能领取  online_gift_no_get    noticeWords.plist
    --         local sWord = gGetWords("noticeWords.plist","online_gift_no_get");
    --         gShowNotice(sWord)
    --     end
    -- else
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    end
end

return GiftPanel