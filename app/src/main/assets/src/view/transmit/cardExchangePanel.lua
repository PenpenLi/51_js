local CardExchangePanel=class("CardExchangePanel",UILayer)


function CardExchangePanel:ctor(type)

    self:init("ui/ui_card_exchange.map")
    local card=Data.getUserCardById(type)

    self:clearCard(1)
    self:clearCard(2)
    self.isMainLayerMenuShow = false; 
    local totalNum=Data.getItemNum(ITEM_ID_EXCHANGE_CARD)
    self:setLabelString("txt_num","("..totalNum.."/0)")
    

end

function CardExchangePanel:onPopup() 

    gMainMoneyLayer:setMoneyType(MONEY_TYPE_ITEM,ITEM_ID_EXCHANGE_CARD);
end

function CardExchangePanel:onPopback()
 
end


function  CardExchangePanel:events() 
    return {EVENT_ID_EXCHANGE_CARD_RESULT}
end


function CardExchangePanel:dealEvent(event,data)
     if(event==EVENT_ID_EXCHANGE_CARD_RESULT)then 
        self:clearCard(1)
        self:clearCard(2)
        gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_success"))
        
      elseif(event==EVENT_ID_ITEM_BUYED)then
        self:initExchangeCardNum()
     end
end

function  CardExchangePanel:setCard(card,pos,isPass)
    if(card==nil)then
        return
    end
    local cardid=card.cardid
    self["curCard"..pos]=card
    self:getNode("scroll"..pos):setVisible(true)
    self:getNode("empty_panel"..pos):setVisible(false)
    self:getNode("panel_get"):setVisible(true)
    self:setCardData(card,pos)
    self:getNode("panel_card"..pos):setVisible(true)
    self:getNode("empty_panel"..pos):setVisible(false)
end

function  CardExchangePanel:setCardData(card,pos) 
    self.curData=card
    self.curPos=pos
    
    local otherData=nil
    if(pos==1)then
        otherData=self["curCard2"]
    else
        otherData=self["curCard1"]
    end
    
    if(otherData==nil)then
        otherData=card
    end
    
    local old_soul_num =Data.getSoulsNumById(card.cardid)
    local new_soul_num = Data.getSoulsNumById(otherData.cardid)
    local up = true --绿
    if old_soul_num>=new_soul_num then
        up=false
    end
    for i=1,6 do
        if up then
            self:changeTexture("bg_arrow"..pos.."_"..i,"images/ui_public1/jiantou_green1.png")
        else
            self:changeTexture("bg_arrow"..pos.."_"..i,"images/ui_public1/jiantou_red2.png")
        end
    end

    self:setLabelString("txt_old_soul_num"..pos,old_soul_num)
    self:setLabelColorNum("txt_new_soul_num"..pos,old_soul_num,new_soul_num)
    
    local cardDb=DB.getCardById(card.cardid)
    local weaponDb=DB.getWeaponById(cardDb.weaponid)
    Icon.setIcon(card.cardid,self:getNode("card_icon"..pos),card.quality,card.awakeLv);
    
    local bgStar=self:getNode("star_container"..pos.."_1") 
    CardPro:showNewStar(bgStar,card.grade,card.awakeLv); 
    gShowRoleName(self,"txt_name"..pos.."_1",cardDb.name,cardDb.cardid); 
    self:setLabelString("txt_lv"..pos.."_1",card.level) 
    --self:setLabelString("txt_lv"..pos.."_2",otherData.level) 
    self:setLabelColorNum("txt_lv"..pos.."_2",card.level,otherData.level)

    local newCard=clone(otherData)
    newCard.cardid=card.cardid

    local treasures=Data.getTreasureByCardId(otherData.cardid) 
    local mytreasures=Data.getTreasureByCardId(card.cardid) 
    for key, var in pairs(treasures) do
        var.cardid=card.cardid
    end  
    
    for key, var in pairs(mytreasures) do
        var.cardid=otherData.cardid
    end  
    
    
    CardPro.setCardAttr( newCard)
    
    
    for key, var in pairs(mytreasures) do
        var.cardid=card.cardid
    end   
    
     for key, var in pairs(treasures) do
        var.cardid=otherData.cardid
    end 
    
    
    
    local bgStar=self:getNode("star_container"..pos.."_2") 
    CardPro:showNewStar(bgStar,newCard.grade,newCard.awakeLv); 

    local cardWplv = gParseWeaponLv(card.weaponLv)
    local newcardWplv = gParseWeaponLv(newCard.weaponLv)
    self:setLabelString("txt_old_weapon"..pos,"+"..cardWplv)
    --self:setLabelString("txt_new_weapon"..pos,"+"..newcardWplv) 
    self:setLabelColorNum("txt_new_weapon"..pos,cardWplv,newcardWplv,"+"..newcardWplv)

    local cardPros={
        1 ,
        3,
        5,
        6, 
        7 ,
        8,
        9,
        10 ,
    }


    for key, pro in pairs( cardPros) do
        self:setLabelString("txt_attr1_"..key,CardPro.getAttrName(pro))
        self:setLabelString("txt_newattr1_"..key,CardPro.getAttrName(pro))
        self:setLabelString("txt_attr2_"..key,CardPro.getAttrName(pro))
        self:setLabelString("txt_newattr2_"..key,CardPro.getAttrName(pro))
        
        local attrName=CardPro.cardPros["attr"..pro]
        local old_value = math.rint(card[attrName])
        local new_value = math.rint(newCard[attrName])
        self:setLabelString("txt_old_value"..pos.."_"..key,old_value)
        self:setLabelColorNum("txt_new_value"..pos.."_"..key,old_value,new_value)
        --self:setLabelString("txt_new_value"..pos.."_"..key,math.rint(newCard[attrName]))
    end
    
    for i=0, 1 do
    	 local skill=DB.getSkillById( cardDb["skillid"..i])
         self:setLabelString("txt_skill"..pos.."_"..(i+1),skill.name)
         
         local old_value = card.skillLvs[i]
        local new_value = newCard.skillLvs[i]

        self:setLabelString("txt_old_skill"..pos.."_"..(i+1), card.skillLvs[i])
        --self:setLabelString("txt_new_skill"..pos.."_"..(i+1), newCard.skillLvs[i])
        self:setLabelColorNum("txt_new_skill"..pos.."_"..(i+1),old_value,new_value)
    end
    

    for i=0, 4 do
        local buff=DB.getBuffById( cardDb["buffid"..i])
        self:setLabelString("txt_skill"..pos.."_"..(i+3),buff.name)

        local old_value = card.skillLvs[i+2]
        local new_value = newCard.skillLvs[i+2]

        self:setLabelString("txt_old_skill"..pos.."_"..(i+3), old_value)
        --self:setLabelString("txt_new_skill"..pos.."_"..(i+3), new_value)
        self:setLabelColorNum("txt_new_skill"..pos.."_"..(i+3),old_value,new_value)

    end
    self:resetLayOut()
    
    
    local width=self:getNode("scroll1"):getContentSize().width
    local attrHeight=self:getNode("attr_panel1"):getContentSize().height 

    local height=  attrHeight 
    self:getNode("attr_panel"..pos):setPositionY(height  ) 
    self:getNode("scroll"..pos):setCheckChildrenVisibleEnable(false)
    self:getNode("scroll"..pos).container:setContentSize(cc.size(width,height))
    self:getNode("scroll"..pos).container:setPositionY(self:getNode("scroll"..pos):getContentSize().height-height)
    

    self:setLabelString("txt_dia",self:getPrice())
end


function CardExchangePanel:getPrice()
  
    return 0
end

  
function CardExchangePanel:getAttrFlag(attr)
    return CardPro.cardPros["attr"..attr]
end


function  CardExchangePanel:clearCard( pos) 
    self["curCard"..pos]=nil 
    self:getNode("panel_get"):setVisible(false)
    self:getNode("panel_card"..pos):setVisible(false)
    self:getNode("empty_panel"..pos):setVisible(true)
    self:getNode("btn_exchange"..pos):setVisible(false)
end

 
function CardExchangePanel:initExchangeCardNum()
    local db=DB.getCardById(self["curCard1"].cardid)
    local data=DB.getClientParamToTable("CARD_EXCHANGE_ITEM_NUM"..db.extype) 

    local awakeLv= math.floor(self["curCard1"].awakeLv/7); 
    local needNum=toint(data[awakeLv+1])
    local totalNum=Data.getItemNum(ITEM_ID_EXCHANGE_CARD)
    self:setLabelString("txt_num",needNum)

    if(totalNum>=needNum)then

        self:getNode("btn_transmit").isEnough=true
    else
        self:getNode("btn_transmit").isEnough=false
    end
end

function CardExchangePanel:checkCondition(card1,card2)

   


    if(card1 and card2  )then
        if(card1.cardid==card2.cardid)then
            gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error7"))
            return false
        end
        local db1=DB.getCardById(card1.cardid)
        local db2=DB.getCardById(card2.cardid)
        
        if(db1.extype~=db2.extype)then
            gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error4"))
            return false
        end
        
        if(card2.grade<db1.evolve)then
            gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error5"))
            return false
        end
        
        if( math.floor(card2.awakeLv/7)>math.floor(card1.awakeLv/7))then
            gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error6"))
            return false
        end
    end
    
    return true
    
end

function CardExchangePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())


    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_EXCHANGE_CARD)
        
         
    elseif  target.touchName=="btn_exchange1"  or target.touchName=="btn_add1"   then
        local function callback(card)
          
            if(card)then 
                if(card.grade<5)then 
                    gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error3"))
                    return false 
                end
            end

            self.curCard1=card
            self:setCard(card,1) 
            self:clearCard(2)
            self:initExchangeCardNum()
            self:getNode("btn_exchange1"):setVisible(true)
        end

        local data={}
        data.card=nil
        data.pos=1
        data.type=3
        Panel.popUp(PANEL_CARD_WEAPON_TRANSMIT_CARD,callback,data)
    
    elseif  target.touchName=="btn_exchange2" or target.touchName=="btn_add2"     then
        local function callback(card) 
            if(self.curCard1==nil)then 
                gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error8"))
                return false
            end
            if(self:checkCondition(self.curCard1,card)==false)then
                return false  
            end

            self.curCard2=card
            self:setCard(card,2)
            
            if(self.curCard1)then
                self:setCard(self.curCard1,1)
            end
            self:getNode("btn_exchange2"):setVisible(true)

        end

        local data={}
        data.card=nil
        data.pos=2
        data.type=3
        Panel.popUp(PANEL_CARD_WEAPON_TRANSMIT_CARD,callback,data)

    elseif  target.touchName=="btn_transmit"then
      
        if(self.curCard1==nil)then
            gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error1"))
            return
        end
        
        if(self.curCard2==nil)then
            gShowNotice(gGetWords("noticeWords.plist","confirm_exchange_card_error2"))
            return
        end
    
        if(target.isEnough==false)then
            local function callback()
                gDispatchEvt(EVENT_ID_BUY_ITEM,EVENT_ID_BUY_ITEM)
            end
            gConfirmCancel(gGetWords("noticeWords.plist","confirm_exchange_card_error9"),callback)
            return 
        end

 
        local function callback()
            Net.sendCardExchange(self.curCard1.cardid,self.curCard2.cardid); 
        end
        gConfirmCancel(gGetWords("noticeWords.plist","confirm_exchange_card"),callback)

    end
end
 

return CardExchangePanel