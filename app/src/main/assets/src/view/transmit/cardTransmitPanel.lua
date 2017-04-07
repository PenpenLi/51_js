local CardTransmitPanel=class("CardTransmitPanel",UILayer)


function CardTransmitPanel:ctor(type)

    self:init("ui/ui_card_transmit.map")
    local card=Data.getUserCardById(type)
    if(card)then
        self:setCard(card,1)
    else
        self:clearCard(1)

    end
    self.isMainLayerMenuShow = false;
end

function CardTransmitPanel:onPopup()

  
end

function CardTransmitPanel:onPopback()

    Scene.clearLazyFunc("transmit_card") 
end


function  CardTransmitPanel:events()
    return { EVENT_ID_REFRESH_TRANSMIT_RESULT}
end


function CardTransmitPanel:dealEvent(event,data)
    if(event==EVENT_ID_REFRESH_TRANSMIT_RESULT)then
        self:clearCard( 1)
    end
end

function  CardTransmitPanel:setCard(card,pos,isPass)
    if(card==nil)then
        return
    end
    local cardid=card.cardid
    self["curCard"..pos]=card
    self:getNode("scroll1"):setVisible(true)
    self:getNode("empty_panel2"):setVisible(false)
    self:getNode("panel_get"):setVisible(true)
    self:setCardData(card,pos)
    self:getNode("panel_card"..pos):setVisible(true)
    self:getNode("empty_panel"..pos):setVisible(false)
end

function  CardTransmitPanel:setCardData(card,pos)
    Scene.clearLazyFunc("transmit_card") 
    self.curData=card
    self.curPos=pos
    local cardDb=DB.getCardById(card.cardid)
    local weaponDb=DB.getWeaponById(cardDb.weaponid)
    Icon.setIcon(card.cardid,self:getNode("card_icon"..pos),card.quality,card.awakeLv);
    CardPro.showStar6(self,card.grade,card.awakeLv)
    gShowRoleName(self,"txt_name",cardDb.name,cardDb.cardid);
    self:setLabelString( "txt_name2",cardDb.name);
    self:setLabelString("txt_lv",card.level)
    self:setLabelString("txt_power",card.power)
    
    local grade=card.grade
    local awakeLv=card.awakeLv
    if(self:getNode("icon_one_star"  ).isSelect)then
        awakeLv=1
        grade=cardDb.evolve
    end

    local newCard=Data.initUserCard(card.cardid,grade)
    self:setLabelString("txt_power2",newCard.power)

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
        local attrName=CardPro.cardPros["attr"..pro]
        self:setLabelString("txt_old_value1_"..key,math.rint(card[attrName]))
        self:setLabelString("txt_new_value1_"..key,math.rint(newCard[attrName]))
    end
    self:resetLayOut()
    
    local  items,gold,point,exp,soulNum,awakeNum=CardPro.recycle(card,self:getNode("icon_one_star"  ).isSelect)

    self:getNode("scroll"):removeAllChildren()
    self:getNode("item_container"):removeAllChildren()
    local item=nil
    if(gold>0)then
        item=DropItem.new()
        item:setData(OPEN_BOX_GOLD)
        item:setNum(gold)
        self:getNode("scroll"):addChild(item)
    end


    if(point>0)then
        item=DropItem.new()
        item:setData(OPEN_BOX_SKILLPOINT)
        item:setNum(point)
        self:getNode("scroll"):addChild(item)
    end

    if(exp>0)then
        item=DropItem.new()
        item:setData(OPEN_BOX_CARDEXP_ITEM)
        item:setNum(exp)
        self:getNode("scroll"):addChild(item)
    end


    if(awakeNum>0)then 
        local item=DropItem.new()
        item:setData(ITEM_AWAKE)
        item:setNum(awakeNum)
        self:getNode("scroll"):addChild(item)
    end
    self:layoutContainer(self:getNode("scroll"),self:getNode("scroll"):getContentSize().height)

    local sortItem={}
    for itemid, num in pairs(items) do
        table.insert(sortItem,{itemid=itemid,num=num})
    end
    gPreSortEquipItem(sortItem)
    table.sort(sortItem,gSortEquipItem) --排序
    
    

    local item=DropItem.new()
    item:setData(card.cardid,0,nil,awakeLv)
    item:setNum(1)
    item:setScale(0.75)  
    item:setPositionY(40) 
    self:getNode("item_container"):addChild(item) 
    
    local node=cc.Node:create()
    item:addChild(node,100)
    node:setPositionX(item:getContentSize().width/2)
    node:setPositionY(-item:getContentSize().height+17)
    CardPro:showNewStar(node, grade,awakeLv)

    local addIdx=0
    if(soulNum>0)then
        addIdx=addIdx+1
        local item=DropItem.new()
        item:setData(card.cardid+ITEM_TYPE_SHARED_PRE)
        item:setNum(soulNum)
        item:setScale(0.75)  
        item:setPositionY(40) 
        item:setPositionX(addIdx*100) 
        self:getNode("item_container"):addChild(item)
    end
   


    

    for var, data in pairs(sortItem) do
        local idx=var+addIdx
        local function setDataLazyCalled()  
            local item=DropItem.new()
            item:setData(data.itemid)
            item:setNum(data.num)
            item:setScale(0.75) 
            item:setPositionX((idx%4)*100)
            item:setPositionY(-math.floor(idx/4)*100+40)
            self:getNode("item_container"):addChild(item)
        end
        if(var>10)then  
            Scene.addLazyFunc(self,setDataLazyCalled,"transmit_card")
        else
            setDataLazyCalled()
        end
    end
    local width=self:getNode("scroll1"):getContentSize().width
    local attrHeight=self:getNode("attr_panel1"):getContentSize().height

    local itemHeight=math.ceil((table.getn(sortItem)+1)/4)*100
    local height=itemHeight+attrHeight
    self:getNode("attr_panel1"):setPositionY(height  )
    self:getNode("item_container"):setPositionY(itemHeight )
    self:getNode("scroll1"):setCheckChildrenVisibleEnable(false)
    self:getNode("scroll1").container:setContentSize(cc.size(width,height))
    self:getNode("scroll1").container:setPositionY(self:getNode("scroll1"):getContentSize().height-height)
    

    self:setLabelString("txt_dia",self:getPrice())
end


function CardTransmitPanel:getPrice()
    if(self.curCard1==nil)then
        return 0
    end
    
--[[消耗的元宝 = 卡牌等级消耗 + 卡牌突破等级消耗
卡牌等级消耗 = max（（卡牌等级 - 40） * 10， 0）
突破等级消耗 = 每突破1级 * 20
]]
 
    local param= DB.getClientParam("CARD_RECYCLED_PRICE")
    local params=string.split(param,";")
    local price=math.max((self.curCard1.level - toint(params[1])) * toint(params[2]),0)
    price=price+self.curCard1.quality*toint(params[3]) 
    
    if(self:isCanSoul())then
        price=price+DB.getClientParam("CARD_GRADE_RECYCLE_PRICE")
    end
    return price
end


function CardTransmitPanel:isCanSoul()
    local cardDb=DB.getCardById(self.curCard1.cardid) 
    if(self:getNode("icon_one_star"  ).isSelect and self.curCard1.grade>cardDb.evolve )then
        return true
    end
    
    return false 
end

function CardTransmitPanel:layoutContainer(container,offsetY)

    local children = container:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        local item=children[i + 1]
        item:setScale(0.75)
        item:setPositionX((i%4)*100)
        item:setPositionY(-math.floor(i/4)*100+offsetY)
    end
    return math.ceil(len/4)*100
end
function CardTransmitPanel:getAttrFlag(attr)
    return CardPro.cardPros["attr"..attr]
end


function  CardTransmitPanel:clearCard( pos)
    self:getNode("empty_panel"..pos):setVisible(true)
    self["curCard"..pos]=nil
    self:getNode("panel_card"..pos):setVisible(false)
    self:getNode("scroll"):removeAllChildren()
    self:getNode("item_container"):removeAllChildren()
    self:getNode("panel_get"):setVisible(false)
    self:getNode("scroll1"):setVisible(false)
    self:getNode("empty_panel2"):setVisible(true)
end


function CardTransmitPanel:setOneStar()
    local select=self:getNode("icon_one_star"  ).isSelect

    if(select~=true)then
        self:getNode("icon_one_star" ).isSelect=true
        self:changeTexture("icon_one_star" ,"images/ui_public1/n-di-gou2.png")
    else
        self:getNode("icon_one_star" ).isSelect=false
        self:changeTexture("icon_one_star" ,"images/ui_public1/n-di-gou1.png")
    end
end

function CardTransmitPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())


    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_TRANSMIT_CARD)
        
        
    elseif target.touchName=="icon_one_star_touch"then
        self:setOneStar()
        self:setCardData(self.curData,self.curPos) 
    elseif  target.touchName=="btn_exchange1" or target.touchName=="btn_add1" then
        local function callback(card)
            self:setCard(card,1)
        end

        local data={}
        data.card=nil
        data.pos=1
        data.type=2
        Panel.popUp(PANEL_CARD_WEAPON_TRANSMIT_CARD,callback,data)

    elseif  target.touchName=="btn_transmit"then
        local dia=toint(self:getNode("txt_dia"):getString())
        if(NetErr.isDiamondEnough(dia)==false )then
            return 
        end
        
        if(self.curCard1==nil)then
            gShowNotice(gGetWords("noticeWords.plist","confirm_transmit_card_error2"))
            return
        end

        if(self:getNode("scroll"):getChildrenCount()==0 and
            self:getNode("item_container"):getChildrenCount()==1 )then
            gShowNotice(gGetWords("noticeWords.plist","confirm_transmit_card_error"))
            return
        end


        local function callback()
            Net.sendCardRecycle(self.curCard1.cardid,self:isCanSoul());
            local td_param = {}
            td_param['cardid'] = self.curCard1.cardid
            td_param['cardname'] = DB.getItemName(self.curCard1.cardid)
            td_param['grade'] = self.curCard1.grade
            td_param['cardlv'] = self.curCard1.level
            td_param['price'] = self:getPrice()
            gLogEvent('card.recycle',td_param)
        end
        gConfirmCancel(gGetWords("noticeWords.plist","confirm_transmit_card"),callback)

    end
end

return CardTransmitPanel