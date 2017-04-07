local WeaponTransmitPanel=class("WeaponTransmitPanel",UILayer)


function WeaponTransmitPanel:ctor()

    self:init("ui/ui_weapon_transmit.map")
    self:getNode("treasure_layer"):setVisible(false)
    self:getNode("arrow_layer1"):setVisible(false)
    self:getNode("arrow_layer2"):setVisible(true)
    self:clearCard( 1)
    self:clearCard( 2)
    self.isMainLayerMenuShow = false;
end

function  WeaponTransmitPanel:setCard(card,pos,isPass)
    if(card==nil)then
        return
    end
    local cardid=card.cardid
    local otherPos=3-pos
    self["curCard"..pos]=card

    -- if(self.curCard1 and self.curCard2 )then 
    --     if(isPass==nil   and self.curCard2.weaponLv>=self.curCard1.weaponLv  )then
    --         self:clearCard(2)
    --         gShowNotice(gGetWords("noticeWords.plist","error_transmit_lv"))
    --     end
    -- end
     
    if(self.curCard1 and self.curCard2 )then 
        if(self.curCard1.cardid==self.curCard2.cardid )then
            self:clearCard(otherPos)
        end        
    end
    

    if(self.curCard1 and self.curCard2 )then 
        self:getNode("panel_get"):setVisible(true)
        local dia = (gParseWeaponLv(self.curCard1.weaponLv)+gParseWeaponLv(self.curCard2.weaponLv))*100
        self:setLabelString("txt_dia",dia)

        -- local raiseData1 =DB.getCardRaiseByLevel(self.curCard1.cardid,self.curCard2.weaponLv)
        -- local raiseData2 =DB.getCardRaiseByLevel(self.curCard2.cardid,self.curCard1.weaponLv)

        -- self:setLabelString("txt_transmit_name1",gGetWords("weaponWords.plist","30",raiseData1.userlevel))
        -- self:setLabelString("txt_transmit_name2", gGetWords("weaponWords.plist","30",raiseData2.userlevel))
    end
    
    local otherCard=self["curCard"..otherPos]
    local cloneCard=clone(otherCard)
    if(cloneCard==nil)then
        cloneCard=clone(card)
    end
    -- if(pos==1)then
    --     cloneCard.weaponLv=0
    --     for key, attr in pairs(RaiseAttr) do
    --         cloneCard["raise_"..self:getAttrFlag(attr)]=0
    --     end
    -- end
    self:setCardData(card,cloneCard,pos)
    self:getNode("panel_card"..pos):setVisible(true)
    self:getNode("empty_panel"..pos):setVisible(false)
end

function  WeaponTransmitPanel:setCardData(card,otherCard,pos)

    local cardDb=DB.getCardById(card.cardid)
    self:setLabelString("txt_card_name"..pos,cardDb.name)
    local weaponDb=DB.getWeaponById(cardDb.weaponid)
    self:setLabelString("txt_name"..pos,weaponDb.name)
    
    local maxWeaponId=nil
    local maxAwakeId=nil
    maxWeaponId,maxAwakeId= gGetMaxWeaponAwakeId(card.cardid)
    local weaponid=gParseWeaponId( card.weaponLv ,maxWeaponId)
    if(weaponid and weaponid>=2)then
        weaponid= weaponDb.weaponid.."_"..weaponid
    else
        weaponid= weaponDb.weaponid
    end


    Icon.setWeaponIcon(weaponid,self:getNode("weapon_icon"..pos))
    Icon.setIcon(card.cardid,self:getNode("card_icon"..pos),card.quality,card.awakeLv);

    local Power1 = CardPro.countWeaponPower(card)
    local Power2 = CardPro.countWeaponPower(otherCard)
    local wplv1 = gParseWeaponLv(card.weaponLv)
    local wplv2 = gParseWeaponLv(otherCard.weaponLv)

    self:setLabelString("txt_lv"..pos.."_1",wplv1)
    self:setLabelColorNum("txt_lv"..pos.."_2",wplv1,wplv2)
    self:setLabelString("txt_value"..pos.."_1",Power1)
    self:setLabelColorNum("txt_value"..pos.."_2",Power1,Power2)

     if wplv1>=wplv2 then
        self:changeTexture("bg_attar_arrow"..pos.."_"..1, "images/ui_public1/jiantou_red2.png")
    else
        self:changeTexture("bg_attar_arrow"..pos.."_"..1, "images/ui_public1/jiantou_green1.png")
    end
    for i=2,3 do
        if Power1>=Power2 then
            self:changeTexture("bg_attar_arrow"..pos.."_"..i, "images/ui_public1/jiantou_red2.png")
        else
            self:changeTexture("bg_attar_arrow"..pos.."_"..i, "images/ui_public1/jiantou_green1.png")
        end
    end
    for key, attr in pairs(RaiseAttr) do
        self:setLabelString("txt_attr"..pos.."_"..key,CardPro.getAttrName(attr))
        self:setLabelString("txt_newattr"..pos.."_"..key,CardPro.getAttrName(attr))

        local old_value = card["raise_"..self:getAttrFlag(attr)]
        local new_value = otherCard["raise_"..self:getAttrFlag(attr)]

        self:setLabelString("txt_old_value"..pos.."_"..key,old_value)
        self:setLabelColorNum("txt_new_value"..pos.."_"..key,old_value,new_value)
    end
    local width=self:getNode("scroll"..pos):getContentSize().width
    local attrHeight=self:getNode("attr_panel"..pos):getContentSize().height
    -- self:getNode("buff_panel"..pos):removeAllChildren()
    self:getNode("buff_panel"..pos):clear()
    local buffHeight=0

    local weaponMaxLv = card.weaponLv
    if weaponMaxLv<=Data.cardRaiseMaxLevel then
        weaponMaxLv=Data.cardRaiseMaxLevel
    end
    for key, var in pairs(cardraiselevel_db) do
        if(var.cardid== card.cardid  and var.buffid~=0 and var.level<=weaponMaxLv )then
            local db=DB.getBuffById(var.buffid)
            local item=WeaponTransmitBuffItem.new()
            item:setData(db,var,card.weaponLv ,otherCard.weaponLv)
            item:setPositionY(1000-toint(var.level));
            self:getNode("buff_panel"..pos):addNode(item)
            -- self:getNode("buff_panel"..pos):addChild(item)
            -- item:setPositionY(buffHeight+item:getContentSize().height+10)
            -- buffHeight=buffHeight-item:getContentSize().height
        end
    end
    -- self:getNode("buff_panel"..pos):setSortByPosFlag(false);
    print("pos "..pos);
    self:getNode("buff_panel"..pos):layout();
    buffHeight=self:getNode("buff_panel"..pos):getContentSize().height;
    -- buffHeight=-buffHeight
    local height=buffHeight+attrHeight
    self:getNode("attr_panel"..pos):setPositionY(height  )
    self:getNode("buff_panel"..pos):setPositionY(buffHeight )
    self:getNode("scroll"..pos):setCheckChildrenVisibleEnable(false)
    self:getNode("scroll"..pos).container:setContentSize(cc.size(width,height))
    self:getNode("scroll"..pos).container:setPositionY(self:getNode("scroll"..pos):getContentSize().height-height)
    self:resetLayOut();
end


function WeaponTransmitPanel:getAttrFlag(attr)
    return CardPro.cardPros["attr"..attr]
end


function  WeaponTransmitPanel:clearCard( pos)
    if(pos==1)then
        self:setLabelString("txt_dia",0)
    end
    self:getNode("empty_panel"..pos):setVisible(true)
    self["curCard"..pos]=nil
    self:getNode("panel_card"..pos):setVisible(false)
    self:getNode("panel_get"):setVisible(false)
    self:setLabelString("txt_transmit_name1",gGetWords("weaponWords.plist","5"))
    self:setLabelString("txt_transmit_name2", gGetWords("weaponWords.plist","6"))
end

function  WeaponTransmitPanel:events()
    return {EVENT_ID_REFRESH_TRANSMIT,EVENT_ID_REFRESH_TRANSMIT_RESULT}
end


function WeaponTransmitPanel:dealEvent(event,data)
    if(event==EVENT_ID_REFRESH_TRANSMIT)then
        local card1=self.curCard1.cardid
        local card2=self.curCard2.cardid
        self:setCard(Data.getUserCardById(card1),1,true)
        self:setCard(Data.getUserCardById(card2),2,true)
    elseif(event==EVENT_ID_REFRESH_TRANSMIT_RESULT)then
        self:clearCard( 1)
        self:clearCard( 2)
    end
end

function  WeaponTransmitPanel:getCurPrice()
    return toint(self:getNode("txt_dia"):getString())
end

function WeaponTransmitPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        
         
    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_WEAPON_TRANSFORM)
    elseif  target.touchName=="btn_exchange2" or  target.touchName=="btn_add2"   then
        local function callback(card)
            self:setCard(card,2)
            self:setCard(self.curCard1,1)
        end
        local data={}
        data.card=self.curCard1
        data.pos=2
        data.type=1
        Panel.popUp(PANEL_CARD_WEAPON_TRANSMIT_CARD,callback,data)
    elseif  target.touchName=="btn_exchange1" or target.touchName=="btn_add1" then
        local function callback(card)
            self:setCard(card,1)
            self:setCard(self.curCard2,2)
        end

        local data={}
        data.card=nil
        data.pos=1
        data.type=1
        Panel.popUp(PANEL_CARD_WEAPON_TRANSMIT_CARD,callback,data)

    elseif  target.touchName=="btn_transmit"then
        if(NetErr.transmitCard(self.curCard1,self.curCard2) )then
            local function callback()
                Net.sendCardWpexTransmit(self.curCard1.cardid,self.curCard2.cardid)
                local td_param = {}
                td_param['card1'] = self.curCard1.cardid
                td_param['card2'] = self.curCard2.cardid
                td_param['price'] = self:getCurPrice()
                gLogEvent('card.transmit',td_param)
            end
            gConfirmCancel(gGetWords("noticeWords.plist","confirm_transmit",self:getCurPrice()),callback)
        end
    end
end

return WeaponTransmitPanel