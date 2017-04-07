local WeaponTransmitCardPanel=class("WeaponTransmitCardPanel",UILayer)


function WeaponTransmitCardPanel:ctor(callback,data)

    self.appearType = 1;
    self:init("ui/ui_weapon_transmit_card.map")
    self:getNode("treasure_layer"):setVisible(false)
    local weapons={}
    self:getNode("scroll").eachLineNum=2
    self.isWindow = true;
    self.hideMainLayerInfo = true;
    Data.sortUserCard()
    local pos=data.pos
    local type=data.type
    if(type==1)then
        self:setLabelString("txt_title",gGetWords("weaponWords.plist","select_pos_"..pos))

    else
        self:setLabelString("txt_title",gGetWords("weaponWords.plist","11"))
    end
    local compairCard=data.card
    for key, card in pairs(gUserCards) do
        local db=DB.getCardById(card.cardid)
        
        if(type==3)then
            if(db and db.extype>0)then
                table.insert(weapons,card)
            end
        else 
            if(db and db.weaponid>0)then
                table.insert(weapons,card)
            end 
        end
    end

    for key, card in pairs(weapons) do
        local item=nil
        if(type==1)then
            item=WeaponTransmitCardItem.new(type)
        else 
            item=CardTransmitCardItem.new(type)
        end
        item.selectItemCallback=function (data)
            if(callback(data)~=false)then
                Panel.popBack(self:getTag())
            end
        end
        item:setData(card,compairCard,pos)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
end


function WeaponTransmitCardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return WeaponTransmitCardPanel