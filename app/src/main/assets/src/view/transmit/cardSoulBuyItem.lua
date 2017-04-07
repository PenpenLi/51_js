local CardSoulBuyItem=class("CardSoulBuyItem",UILayer)

function CardSoulBuyItem:ctor()

end

function CardSoulBuyItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_card_soul_buy.map")
end



function CardSoulBuyItem:onTouchEnded(target)
    local temp={}
    temp.itemid=self.curData.itemid
    temp.costType=OPEN_BOX_SOULMONEY
    temp.lefttimes = self.curData.bbnum
    local card=DB.getCardById(temp.itemid-ITEM_TYPE_SHARED_PRE)
    temp.price=0
    temp.rewardNum=1
    if(card)then
        temp.price= DB.getClientParamToTable("CARD_SOUL_BUYBACK_PRICE")[card.evolve] 
    end
    temp.buyCallback=function(num)
        if(temp.price*num>Data.getCurSoulMoney())then
            gShowNotice(gGetWords("cardsoul.plist","no_soulmoney"))
            return
        end
        Net.sendCardSoulBuy(temp.itemid-ITEM_TYPE_SHARED_PRE,num)
    end
    Panel.popUp(PANEL_SHOP_BUY_ITEM,temp)
end
function  CardSoulBuyItem:setDataLazyCalled()
    self:setData(self.lazyData,self.lazyTagType)
end

function  CardSoulBuyItem:setLazyData(data,tagType)
    self.lazyData=data
    self.curData=data
    Scene.addLazyFunc(self,self.setDataLazyCalled,"equipSoul")
end



function   CardSoulBuyItem:setData(data,tagType)
    self:initPanel()
    self.curData=data
    local itemid=data.itemid
    self:setLabelString("txt_num",data.bbnum)
    Icon.setIcon(itemid,self:getNode("icon"),5)

end



return CardSoulBuyItem