local WeaponTransmitResultPanel=class("WeaponTransmitResultPanel",UILayer)


function WeaponTransmitResultPanel:ctor(data)

    self.appearType = 1;
    self:init("ui/ui_weapon_transmit_result.map") 
    self:setCardData(data, 1)
    self.hideMainLayerInfo = true; 
    self.isWindow = true;
end

function WeaponTransmitResultPanel:getAttrFlag(attr)
    return CardPro.cardPros["attr"..attr]
end

 

function  WeaponTransmitResultPanel:setCardData(card,pos)

    local cardDb=DB.getCardById(card.cardid)
    self:setLabelString("txt_card_name"..pos,cardDb.name)
    local weaponDb=DB.getWeaponById(cardDb.weaponid)
    self:setLabelString("txt_name"..pos,weaponDb.name)
    Icon.setWeaponIcon(cardDb.weaponid,self:getNode("weapon_icon"..pos) )
    Icon.setIcon(card.cardid,self:getNode("card_icon"..pos),card.quality,card.awakeLv);

    self:replaceLabelString("txt_lv"..pos,gParseWeaponLv( card.weaponLv))
    self:replaceLabelString("txt_value"..pos,CardPro.countWeaponPower(card)) 
    for key, attr in pairs(RaiseAttr) do
        self:setLabelString("txt_attr"..pos.."_"..key,CardPro.getAttrName(attr))
        self:setLabelString("txt_old_value"..pos.."_"..key,card["raise_"..self:getAttrFlag(attr)]) 
        self:getNode("txt_attr"..pos.."_"..key):getParent():layout()
    end
    local width=self:getNode("scroll"..pos):getContentSize().width 
    local attrHeight=self:getNode("attr_panel"..pos):getContentSize().height
    self:getNode("buff_panel"..pos):removeAllChildren()
    local buffHeight=self:getNode("buff_panel"..pos):getContentSize().height-10 
    local weaponMaxLv = card.weaponLv
    if weaponMaxLv<=Data.cardRaiseMaxLevel then
        weaponMaxLv=Data.cardRaiseMaxLevel
    end 
    for key, var in pairs(cardraiselevel_db) do
        if(var.cardid== card.cardid  and var.buffid~=0 and var.level<=weaponMaxLv  )then
            local db=DB.getBuffById(var.buffid) 
            local item=WeaponTransmitBuffItem.new()
            item:setData(db,var,card.weaponLv ,card.weaponLv)
            self:getNode("buff_panel"..pos):addChild(item)
            item:setPositionY(buffHeight+10)
            buffHeight=buffHeight-item:getContentSize().height
        end
    end  
    
    buffHeight=-buffHeight+self:getNode("buff_panel"..pos):getContentSize().height
    local height=buffHeight+attrHeight 
    self:getNode("attr_panel"..pos):setPositionY(height  ) 
    self:getNode("buff_panel"..pos):setPositionY(buffHeight ) 
    self:getNode("scroll"..pos):setCheckChildrenVisibleEnable(false)
    self:getNode("scroll"..pos).container:setContentSize(cc.size(width,height))  
    self:getNode("scroll"..pos).container:setPositionY(self:getNode("scroll"..pos):getContentSize().height-height) 
end
 
function WeaponTransmitResultPanel:onTouchEnded(target)

    if  target.touchName=="btn_close" or target.touchName=="btn_transmit" then
        Panel.popBack(self:getTag()) 
    end
end

return WeaponTransmitResultPanel