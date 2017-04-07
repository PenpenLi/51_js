local ShopPanel3=class("ShopPanel3",UILayer)

function ShopPanel3:ctor(type)

    self:init("ui/ui_shop3.map")
    self.isMainLayerMenuShow = false
    self.curShopType = SHOP_TYPE_DRAGON;

    self.scroll = self:getNode("scroll2");
    self.scroll.eachLineNum = 3;
    for key, data in pairs(dragonballshop_db) do
        if(not DB.isReplaceItem(data.cardid))then
            local item=ShopItem3.new()
            item:setData(data)
            self.scroll:addItem(item)
            item.selectItemCallback=function(data)
                self.curCardid=data.cardid
                self:refresh()
            end
        end
    end
    self.scroll:layout()
    self.scroll.items[1]:onTouchEnded(false)

end


function  ShopPanel3:events()
    return {EVENT_ID_DRAW_CARD_EXCHANGE}
end


function ShopPanel3:dealEvent(event,param)
    if(event==EVENT_ID_DRAW_CARD_EXCHANGE)then
        self:refresh()

    end

end

function ShopPanel3:refresh()
    self:setLabelString("txt_dragon_ball",Data.drawCard.gball)
    local cardid=self.curCardid-ITEM_TYPE_SHARED_PRE
    local card=DB.getCardById(cardid)
    local curItem=nil
    for key, item in pairs(self.scroll.items) do
        if(item.curData.cardid==self.curCardid)then
            item:setSelect()
            curItem=item
        else
            item:resetSelect()
        end
        item:refresh()
    end
    self.curItem=curItem
    if(curItem)then
        self:setLabelString("txt_name",card.name)

        local curSoulNum=Data.getSoulsNumById(cardid)
        local needSoulNum=0
        local userCard=Data.getUserCardById(cardid)
        if(userCard)then
            needSoulNum=DB.getNeedSoulForAll(userCard.grade,userCard.cardid,userCard.awakeLv)
            if(needSoulNum==0)then
                self:setRTFString("txt_num",gGetWords("drawCardWords.plist","soul_max",curSoulNum))
            else
                self:setRTFString("txt_num",gGetWords("drawCardWords.plist","soul",curSoulNum,needSoulNum))
            end
        else
            needSoulNum=DB.getNeedInitSoulNum(card.evolve-1)
            self:setRTFString("txt_num",gGetWords("drawCardWords.plist","soul",curSoulNum,needSoulNum))

        end
        
        if(curItem.curData.level>gUserInfo.level)then
            self:setTouchEnable("btn_exchange",false,true)
        else
            self:setTouchEnable("btn_exchange",true,false)
        end


        self:showCardFla(cardid);
        self:setLabelString("txt_price",curItem.curData.price)
    else
        self:setLabelString("txt_name","")
        self:setLabelString("txt_num","")
        self:setLabelString("txt_price","0")

    end
    self:resetLayOut()
end

function ShopPanel3:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_rule"then
        gShowRulePanel(SYS_DRAGON_BALL_EXCHANGE);
    elseif  target.touchName=="btn_exchange"then
        if(self.curItem==nil)then
            return
        end

        if(self.curItem.buyNum>=self.curItem.limitBuy)then
            gShowNotice(gGetWords("noticeWords.plist","error_dragon_exchange1"))
            return
        end

        if(Data.drawCard.gball<self.curItem.curData.price)then
            gShowNotice(gGetWords("noticeWords.plist","error_dragon_exchange2"))
            return
        end
        Net.sendDrawDragonExchange(self.curItem.cardid)
    elseif  target.touchName=="btn_next_action"then

        self:nextFlaAction()
    elseif target.touchName == "btn_pre" then
        gPreShop(self.curShopType,self:getTag());
    elseif target.touchName == "btn_next" then
        gNextShop(self.curShopType,self:getTag()); 
    end
end




function ShopPanel3:showCardFla(cardid) 
    if(self.lastFlaId==cardid)then
        return
    end
    self.cardDb=DB.getCardById(cardid)
    self:parseFlaActions()
    self.lastFlaId=cardid
    self.fla=gCreateRoleFla(cardid, self:getNode("role_container") ,0.8,true)

    self:nextFlaAction()
end

function ShopPanel3:parseFlaActions()
    self.flaAction={}
    self.curFlaActionIdx=0
    local actions=string.split(self.cardDb.actlist,",")
    for key, actionid in pairs(actions) do

        if(actionid=="0")then
            table.insert(self.flaAction,"wait")
        elseif(actionid=="1")then
            table.insert(self.flaAction,"run")
        elseif(actionid=="2")then
            table.insert(self.flaAction,"win")
        elseif(actionid=="3")then
            table.insert(self.flaAction,"attack_s")
        elseif(actionid=="4")then
            table.insert(self.flaAction,"attack_b")
        end
    end

end

function ShopPanel3:nextFlaAction()

    self.curFlaActionIdx=self.curFlaActionIdx+1
    if(self.curFlaActionIdx>table.getn(self.flaAction))then
        self.curFlaActionIdx=1
    end

    self:playFlaAction( self.flaAction[self.curFlaActionIdx])
end

function ShopPanel3:playFlaAction(action)
    if(self.fla)then
        if(action==nil)then
            action="wait"
        end
        local function onCallBack()
            if(action=="run")then
                self.fla:playAction( "r"..self.lastFlaId.."_run" ,onCallBack)
            else
                self.fla:playAction( "r"..self.lastFlaId.."_wait" ,onCallBack)
            end
        end

        if(action=="wait" )then
            if(self.lastSoundId)then
                gStopEffect(self.lastSoundId)
            end
            if isBanshuReview() == false then
                self.lastSoundId= gPlayEffect("sound/card/"..self.cardDb.cardid..".mp3")
            end
        end
        self.fla:playAction("r"..self.lastFlaId.."_"..action ,onCallBack)
    end
end


return ShopPanel3