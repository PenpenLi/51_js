local TipTreasure=class("TipTreasure",UILayer)

function TipTreasure:ctor(data,panel)
    self.appearType = 1
    local cardid=nil
    if(panel)then 
        cardid=panel.curCardid
        self.panel=panel
    end
    self:init("ui/tip_treasure.map")
    self.cardid=cardid
    self.curData=data
    self:setData(self.curData,self.cardid)
end

function TipTreasure:setData(data,cardid)
    self.cardid=cardid
    self.curData=data

    local card=Data.getUserCardById(cardid)
    local cardDb=DB.getCardById(cardid)
    local treasure=DB.getTreasureById(data.itemid)
    Icon.setIcon(data.itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))
    local suits=DB.getTreasureSuitById(treasure.suitid)

    self:setLabelString("txt_name",treasure.name)
    self:setLabelString("txt_suit_name",suits[1].name)

    if(data.upgradeLevel)then
        self:setLabelString("txt_upgrade_level",data.upgradeLevel)
    else
        self:setLabelString("txt_upgrade_level","0")
    end
    if(data.quenchLevel)then
        self:setLabelString("txt_quench_level",data.quenchLevel)
    else
        self:setLabelString("txt_quench_level","0")
    end
    local baseQua,detailQua = Icon.convertItemDetailQuality(treasure.quality+1);
    self:getNode("txt_suit_name"):setColor(cc.c3b(gQuaColor[baseQua][1],gQuaColor[baseQua][2],gQuaColor[baseQua][3]));



    local camps= string.split(treasure.campid,";")
    local countryName=""
    local activateCountry=false
    local campsCount=table.getn(camps)
    for key, var in pairs(camps) do
        countryName=countryName..gGetWords("cardAttrWords.plist","country_"..var)
        if(key~=campsCount)then
            countryName=countryName..","
        end
        if(cardDb and cardDb.country==toint(var))then
            activateCountry=true
        end
    end
    if(countryName=="")then
        self:setLabelString("txt_country",gGetWords("cardAttrWords.plist","country_99"))
    else
        self:setLabelString("txt_country",countryName)
    end
    for i=1, 3 do
        self:getNode("empty"..i):setVisible(false)
        for j=1, 2 do
            self:setLabelString("txt_"..i.."_attr_"..j,"")
            self:setLabelString("txt_"..i.."_value"..j,"")
            self:setLabelString("txt_"..i.."_extra_attr_"..j,"")
            self:setLabelString("txt_"..i.."_extra_value"..j,"")

            self:getNode("txt_"..i.."_attr_"..j):setColor(cc.c3b(114,114,114))
            self:getNode("txt_"..i.."_value"..j):setColor(cc.c3b(114,114,114))
            self:getNode("txt_"..i.."_extra_attr_"..j):setColor(cc.c3b(114,114,114))
            self:getNode("txt_"..i.."_extra_value"..j):setColor(cc.c3b(114,114,114))
        end
    end
    local suitItems=DB.getTreasureBySuitId(treasure.suitid)
    for key, var in pairs(suitItems) do
        Icon.setIcon(var.id,self:getNode("icon"..key),var.quality)
        self:setLabelString("txt_name"..key,var.name)
    end
    local num=0
    for i=1, 4 do
        DisplayUtil.setGray(self:getNode("icon"..i),true)
        self:getNode("btn_plus"..i):setVisible(false)
        if(self.curData.cardid and self.curData.cardid>0)then
            local otherTreasure=Data.getTreasureBySuit( treasure.suitid,i-1)
            if(otherTreasure)then
                self:getNode("btn_plus"..i):setVisible(true)
                self:getNode("btn_plus"..i).treasure=otherTreasure
            end
        end
        
        if(card)then
            local treasureid=card["treasure"..i]
            if(treasureid~=0)then
                local myTreasure=Data.getTreasureById(treasureid)
                if(myTreasure)then
                    local db=DB.getTreasureById(myTreasure.itemid)
                    if(db.suitid==treasure.suitid)then
                        DisplayUtil.setGray(self:getNode("icon"..i),false)
                        self:getNode("btn_plus"..i):setVisible(false)
                        num=num+1
                    end
                end
            end
        end
    end

    for i=1, num-1 do
        for j=1, 2 do
            if(self:getNode("txt_"..i.."_attr_"..j))then
                self:getNode("txt_"..i.."_attr_"..j):setColor(cc.c3b(255,232,106))
                self:getNode("txt_"..i.."_value"..j):setColor(cc.c3b(0,255,0))
            end

            if(activateCountry)then
                if(self:getNode("txt_"..i.."_extra_attr_"..j))then
                    self:getNode("txt_"..i.."_extra_attr_"..j):setColor(cc.c3b(255,232,106))
                    self:getNode("txt_"..i.."_extra_value"..j):setColor(cc.c3b(0,255,0))
                end
            end
        end
    end




    for i, suit in pairs(suits) do
        self:replaceLabelString("txt_num"..i,suit.num)
        local isEmpty=true
        for j=1, 2 do
            if(suit["attr"..j]~=0)then
                local attr=suit["attr"..j]
                local value=suit["param"..j]
                self:setLabelString("txt_"..i.."_attr_"..j,CardPro.getAttrName(attr))
                self:setLabelString("txt_"..i.."_value"..j,"+"..CardPro.getAttrValue(attr,value))
            end

            if(suit["attr"..j.."_camp"]~=0)then
                local attr=suit["attr"..j.."_camp"]
                local value=suit["param"..j.."_camp"]
                isEmpty=false
                self:setLabelString("txt_"..i.."_extra_attr_"..j,CardPro.getAttrName(attr))
                self:setLabelString("txt_"..i.."_extra_value"..j,"+"..CardPro.getAttrValue(attr,value))

            end
        end

        if(isEmpty)then
            self:getNode("empty"..i):setVisible(true)
        end

    end


    for i=1,3 do
        self:getNode("attr_panel"..i):setVisible(false)
    end
    local addAttr={}
    addAttr.treasure_attr={}
    CardPro.addTreasureBaseAttr(addAttr,treasure)

    if(self.curData.upgradeLevel )then
        CardPro.addTreasureUpgradeAttr(addAttr,self.curData.upgradeLevel,treasure)
        CardPro.addTreasureQuenchAttr(addAttr,self.curData.quenchLevel,treasure)
    end
    
    local temp={}
    for key, var in pairs(addAttr.treasure_attr) do
    	table.insert(temp,{key=key,var=var})
    end
    local function sort(item1,item2)
        return item1.key<item2.key
    end
    
    table.sort(temp,sort)
    
    
    local idx=1
    for key, var in pairs(temp) do
        local key=var.key
        local var=var.var
        if(key~=0)then
            self:getNode("attr_panel"..idx):setVisible(true)
            self:setLabelString("txt_pm_attr"..idx,CardPro.getAttrName(key))
            if(key==Attr_RESIST_DAMAGE)then
                self:getNode("txt_pm_attr"..idx):setColor(cc.c3b(255,0,0))
            end
            
            if(key==Attr_RESIST_DAMAGE and card)then
                self:setLabelString("txt_pm_value"..idx,"+"..math.floor(card.hp*var/250))
            else
                self:setLabelString("txt_pm_value"..idx,"+"..CardPro.getAttrValue(key,var))
            end
            
            idx=idx+1
        end
    end



    self:resetLayOut()

    self:getNode("panel_take_off"):setVisible(false)
    self:getNode("panel_wear"):setVisible(false)
    self:getNode("panel_merge"):setVisible(false)


    if(data.cardid)then
        if(  data.cardid==0)then
            self:getNode("panel_wear"):setVisible(true)
        else
            self:getNode("panel_take_off"):setVisible(true)
        end
    else
        local var=DB.getTowerShopById(self.curData.itemid+ITEM_TYPE_SHARED_PRE)
        if(var)then
            self:setTouchEnable("btn_buy",true,false)
        else
            self:setTouchEnable("btn_buy",false,true)
        end

        if(self.curData.db and self.curData.num)then
            
            if(self.curData.db.com_num1>0)then
                self:getNode("cost_panel"):setVisible(true)
                self:changeTexture("icon_cost","images/icon/item/"..self.curData.db.com_item1..".png")
            else
                self:getNode("cost_panel"):setVisible(false)
            end
            self:getNode("txt_cost").itemid=self.curData.db.com_item1
            local num=Data.getItemNum(self.curData.db.com_item1)
            self:setLabelString("txt_cost", num.."/"..self.curData.db.com_num1) 
            if(self.curData.num>=self.curData.db.com_num and num>=self.curData.db.com_num1)then

                self:setTouchEnableGray("btn_merge",  true)
            else
                self:setTouchEnableGray("btn_merge", false)

            end
            self.mergeType =1
            self.mergeNum =math.floor(self.curData.num/self.curData.db.com_num)
            if self.curData.db.com_num1>0 then
                local miniNum1 = math.floor(num/self.curData.db.com_num1)
                if self.mergeNum > miniNum1 then
                    self.mergeNum=miniNum1
                end
            end
            if (self.mergeNum>=2) then
                self.mergeType=2
            end
            
            if self.mergeType==1 then
                self:setLabelString("txt_merge",gGetWords("treasureWord.plist","merge"))
            else
                self:setLabelString("txt_merge",gGetWords("treasureWord.plist","onekey_merge"))
            end

            self:getNode("panel_merge"):setVisible(true)
        else 
            self:getNode("panel_merge"):setVisible(false)
        end
      
    end

end


function TipTreasure:events()
    return {  EVENT_ID_TREASURE_WEAR,EVENT_ID_TREASURE_SHARED_BUY}
end

function TipTreasure:dealEvent(event,data)
    if(event==EVENT_ID_TREASURE_WEAR )then
        self:setData(data.treasure,self.cardid)
    elseif event==EVENT_ID_TREASURE_SHARED_BUY then
        self:setData(self.curData,self.cardid)
    end
end

function TipTreasure:onTouchEnded(target)
    if(target.touchName=="btn_equip")then
        Net.sendTreasureWear(self.cardid,self.curData.id)
        Panel.popBack(self:getTag())
    elseif(string.find(target.touchName,"btn_plus"))then
        Net.sendTreasureWear(self.cardid,target.treasure.id)
        loadFlaXml("ui_card_equip_activate")
        local effect=gCreateFla("ui-card-fangru")
        effect:setLocalZOrder(11)
        gAddCenter(effect,  target:getParent() )
    elseif(target.touchName=="btn_take_off")then
        Net.sendTreasureUnload(self.cardid,self.curData.id)
        Panel.popBack(self:getTag())

    elseif(target.touchName=="btn_upgrade")then
        self.panel:selectTreasureUpgrade()
        Panel.popBack(self:getTag())
    elseif(target.touchName=="btn_shared")then
        Panel.popBack(self:getTag())
        local data=self.curData
        Panel.popUp(PANEL_TREASURE_DECOMPOSE,data)
    elseif(target.touchName=="btn_merge")then
        if(self:getNode("txt_cost").itemid~=0)then
            if(Data.getItemNum(self:getNode("txt_cost").itemid)<toint(self:getNode("txt_cost"):getString()))then
                gShowNotice(gGetWords("treasureWord.plist","no_item",DB.getItemName(self:getNode("txt_cost").itemid)))
                return
            end
        end
        if self.mergeType==1 then
            Net.sendTreasureSyn( self.curData.itemid)
            Panel.popBack(self:getTag())
        else
            Panel.popUp(PANEL_TREASURE_BUYTIMES,self.curData,self.mergeNum)
        end
        

    elseif(target.touchName=="btn_buy")then

        if Unlock.isUnlock(SYS_TOWER)==false then
            return
        end
        local var=DB.getTowerShopById(self.curData.itemid+ITEM_TYPE_SHARED_PRE)
        if(var==nil)then
            return
        end
        local item={}
        item.itemid   = var.itemid;
        item.type     = SHOP_TYPE_TOWER1;
        item.num      = toint(var.num);
        item.limitNum = toint(var.buylimit);
        item.buyNum   = 0;
        item.price    = toint(var.price);
        item.costType = toint(var.ptype);
        item.pos      = var.id;--特殊处理
        item.unlockStar = toint(var.starlimit);

        if(Data.towerInfo.maxstar>=var.starlimit)then
            self:buyItem(item)
        else
            Panel.popUp(TIP_PANEL_SHOP_ITEM,item)
        end

    end
end


function TipTreasure:buyItem(data)
    local temp={}
    temp.itemid=data.itemid
    temp.id=data.id
    temp.costType=data.costType
    temp.price= data.price
    if(data.limitNum and data.limitNum > 0)then
        temp.lefttimes = data.limitNum - data.buyNum;
        temp.hasLimitBuy = true;
        temp.limitNum = data.limitNum;
        temp.buyNum = data.buyNum;
    else
        temp.lefttimes=  math.floor(gUserInfo.towermoney/temp.price)
    end
    if(temp.lefttimes < 0)then
        temp.lefttimes = 0;
    end
    temp.rewardNum=data.num
    temp.buyCallback=function(num)
        if(NetErr.BuyShopItem(data.costType,data.price*num)) then
            ShopPanelData.buyPrice = data.price*num;
            Net.sendBuyShopItem(data.type,{data.pos},num)
        end
    end

    Panel.popUp(PANEL_SHOP_BUY_ITEM,temp)

end

return TipTreasure