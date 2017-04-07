local CardTransmitCardItem=class("CardTransmitCardItem",UILayer)


function CardTransmitCardItem:ctor(type)
    self.type=type
    self:init("ui/ui_card_transmit_card_item.map")

end

function CardTransmitCardItem:setData(card,compairCard,pos)
    self.compairCard=compairCard
    local cardDb=DB.getCardById(card.cardid)
    self.pos=pos
    self.curData=card
 
    -- Icon.setIcon(card.cardid,self:getNode("card_icon"))
    Icon.setIcon(card.cardid,self:getNode("card_icon"),nil,self.curData.awakeLv);
    self:setLabelString("txt_name",cardDb.name) 
    self:setLabelString("txt_lv",card.level)
    self:setLabelString("txt_power",card.power)
    if(self.type==3)then
        self:setLabelAtlas("txt_extype",cardDb.extype) 
    else
        self:getNode("txt_extype"):setVisible(false) 
    end
 
    CardPro.showStar6(self,self.curData.grade,self.curData.awakeLv)
  

end


function CardTransmitCardItem:onTouchEnded(target)
 
    self.selectItemCallback(self.curData)
end
return CardTransmitCardItem