local CardInfoRelationPanel=class("CardInfoRelationPanel",UILayer)

function CardInfoRelationPanel:ctor()
    self:init("ui/ui_card_relation.map")

    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll"):layout()
    self:getNode("scroll").offsetY=4
    
end




function CardInfoRelationPanel:onTouchEnded(target)



end

function CardInfoRelationPanel:setCard(card)
    self.curCard=card 
    local relations=DB.getRelationByCardId(card.cardid)
     
    self:getNode("scroll"):clear()
    for key, var in pairs(relations) do
        local item=CardInfoRelationItem.new()
        item:setData(var)
        self:getNode("scroll"):addItem(item)
        
        if(item.activateEnable)then
            item.sort=100+key
        else
            item.sort=key
        end
         
    end


    local function sort(item1,item2) 
        return item1.sort>item2.sort
    end
     
    table.sort(self:getNode("scroll").items,sort) 
    self:getNode("scroll"):layout() 
    self.curCardid=card.cardid
  
end



return CardInfoRelationPanel