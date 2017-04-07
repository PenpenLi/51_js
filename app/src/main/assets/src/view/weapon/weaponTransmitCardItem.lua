local WeaponTransmitCardItem=class("WeaponTransmitCardItem",UILayer)


function WeaponTransmitCardItem:ctor(type)

    self:init("ui/ui_weapon_transmit_card_item.map")

end

function WeaponTransmitCardItem:setData(card,compairCard,pos)
    self.compairCard=compairCard
    local cardDb=DB.getCardById(card.cardid)

    self.curData=card
    self.pos=pos

    local weaponDb=DB.getWeaponById(cardDb.weaponid)

    local maxWeaponId=nil
    local maxAwakeId=nil
    maxWeaponId,maxAwakeId= gGetMaxWeaponAwakeId(card.cardid)
    local weaponid=gParseWeaponId( card.weaponLv ,maxWeaponId)
    if(weaponid and weaponid>=2)then
        weaponid= weaponDb.weaponid.."_"..weaponid
    else
        weaponid= weaponDb.weaponid
    end
    
    Icon.setWeaponIcon(weaponid,self:getNode("weapon_icon") )
    Icon.setIcon(card.cardid,self:getNode("card_icon"),card.quality,card.awakeLv);
    if(weaponDb)then
        self:setLabelString("txt_name",weaponDb.name)
    end
    self:replaceLabelString("txt_lv",gParseWeaponLv(card.weaponLv))
    self:replaceLabelString("txt_value",CardPro.countWeaponPower(card))


    CardPro.showStar6(self,self.curData.grade,self.curData.awakeLv)
end


function WeaponTransmitCardItem:onTouchEnded(target)
    if(self.compairCard)then
        -- if( self.compairCard.weaponLv <= self.curData.weaponLv )then
        --     gShowNotice(gGetWords("noticeWords.plist","error_transmit_lv"))
        --     return
        -- end 
    else
        -- if(self.curData.weaponLv ==0)then 
        --     gShowNotice(gGetWords("noticeWords.plist","error_transmit_level"))
        --     return
        -- end
    end

    self.selectItemCallback(self.curData)
end
return WeaponTransmitCardItem