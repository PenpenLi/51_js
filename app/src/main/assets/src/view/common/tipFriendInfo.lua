local TipFriendInfo=class("TipFriendInfo",UILayer)

function TipFriendInfo:ctor(data)
    self:init("ui/tip_friend_info.map")

    self:setLabelString("txt_name",data.name)
    self:setLabelString("txt_level",data.level)
    self:setLabelString("txt_win",data.win)
    self:setLabelString("txt_power",data.price)
    self:setLabelString("txt_rank",data.rank)
    Icon.setIcon( data.cid,self:getNode("icon"))

    for key, card in pairs(data.cards) do
        if(card.cardid~=0)then
            local node=self:getNode("card"..(key+1))
            local item=AtlasFormationItem.new(2)
            node:addChild(item)
            item:setData(card)
            item:setPositionY(node:getContentSize().height) 
        end
    end
end


function TipFriendInfo:onTouchEnded(target)
    Panel.popBack(self:getTag())

end

return TipFriendInfo