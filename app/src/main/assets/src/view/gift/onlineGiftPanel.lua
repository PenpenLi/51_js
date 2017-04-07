local OnlineGiftPanel=class("OnlineGiftPanel",UILayer)

function OnlineGiftPanel:ctor() 
    self.appearType = 1;
    self:init("ui/ui_online_gift1.map")
    self._panelTop = true;
    
    local gift = DB.getOnlineGift();
    
    local boxid = toint(gift[Data.m_onlineInfo.iLv+1]);
    local boxes= DB.getBoxItemById(boxid)
     
    for key, box in pairs(boxes) do 
        if(self:getNode("icon_"..key))then
            local node=DropItem.new() 
            node:setData(box.itemid)
            node:setNum(box.itemnum )  
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon_"..key)) 
        
        end
    end

end

function OnlineGiftPanel:createOneItem(boxid)
    -- body
end

function OnlineGiftPanel:onTouchEnded(target)

    if  target.touchName=="btn_get"then
        if (Data.m_onlineInfo.bolShowRedPoint) then
            Net.sendGiftbagGetOnline();
            Panel.popBack(self:getTag())
        else
            --提示不能领取  online_gift_no_get    noticeWords.plist
            local sWord = gGetWords("noticeWords.plist","online_gift_no_get");
            gShowNotice(sWord)
        end
    elseif  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    end
end

return OnlineGiftPanel