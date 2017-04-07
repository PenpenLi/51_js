local TreasurePanel=class("TreasurePanel",UILayer)


local treasureDropItems={ 70005, 70006,70007, 70008  }

function TreasurePanel:ctor(cardid,cardPanel) 
    self:init("ui/ui_treasure.map")
    self.cardPanel=cardPanel
    self:selectBtn("btn_treasure")
    self:initBagPanel()
    self:showSelectCard(cardid)
    self:initCardAttrData()
    self:cardHasTreasureInBag()

    self:getNode("container1"):setRotation3D(cc.vec3(0,-120,0))
    self:getNode("container3"):setRotation3D(cc.vec3(0,-120,0))
    self:getNode("container2"):setRotation3D(cc.vec3(0,-90,0))
    self:getNode("container4"):setRotation3D(cc.vec3(0,-90,0))
    for i=1, 4 do
        self:getNode("container"..i):runAction(cc.RotateTo:create(0.3,cc.vec3(0,0,0)))
    end
    cardPanel.touchEnable=false
    self:getNode("choose_icon"):setVisible(false)
    local function callback() 
        self:getNode("choose_icon"):setVisible(true)  
        cardPanel.touchEnable=true
    end
    Panel.setMainMoneyType(OPEN_BOX_TOWERMONEY)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(callback)))
end


function TreasurePanel:clearPanel()
    if(self.bagPanel)then
        self.bagPanel:setVisible(false)
    end
    if(self.upgradePanel)then
        self.upgradePanel:setVisible(false)
    end
    if(self.quenchPanel)then
        self.quenchPanel:setVisible(false)
    end
    if(self.riseStarPanel)then
        self.riseStarPanel:setVisible(false)
    end
    Scene.clearLazyFunc("bag") 
end

function TreasurePanel:disapper()
    self:clearPanel()
    self:removeFromParent() 
    Panel.setMainMoneyType(OPEN_BOX_CARDEXP_ITEM)
end

function TreasurePanel:showEffect(node)
    loadFlaXml("ui_card_equip_upgrade")
    local effect=gCreateFla("ui_card_equip_upgrade")
    effect:setTag(999)
    node:removeChildByTag(999)
    gAddCenter(effect,  node )

end


function TreasurePanel:showMasterEffect(word,lv)
    local node=self:getNode("master_panel")
    loadFlaXml("ui_jinglian")
    local effect=gCreateFla("ui_jinglian_hengtiao")
    effect:setTag(999)
    node:removeChildByTag(999)
    gAddCenter(effect,  node )



    local labWord = gCreateWordLabelTTF(word,gCustomFont,26,cc.c3b(0,0,0));
    local numWord = gCreateWordLabelTTF(getLvReviewName("Lv")..lv,gCustomFont,26,cc.c3b(255,255,255));
    local node=cc.Node:create()
    local totalWidth=labWord:getContentSize().width+numWord:getContentSize().width
    local startX=-totalWidth/2+labWord:getContentSize().width/2
    labWord:setPositionX(startX)
    numWord:setPositionX(startX+labWord:getContentSize().width-20)
    node:addChild(labWord)
    node:addChild(numWord)
    effect:replaceBoneWithNode({"word","word"},node )

end



function TreasurePanel:onSelectTreasure(data)
    local tip=Panel.popUp(TIP_TREASURE,data,self) 
end


function TreasurePanel:showTreasureInfo()  
    for i=1, 4 do 
        local treasure= self:getNode("icon_treasure"..i).treasure
        if(treasure)then
            self:replaceLabelString("txt_qlevel"..i,treasure.quenchLevel)
            self:setLabelString("txt_level"..i,getLvReviewName("Lv.")..treasure.upgradeLevel)

            local treasureDb=DB.getTreasureById(treasure.itemid)
            local needExp=self:getQuenchNeedExp(treasure.quenchLevel+1,treasureDb)
            local per=0
            if(needExp~=0)then
                per=  treasure.quenchExp/needExp
            end
            self:setBarPer("bar_exp"..i,per)
            self:getNode("bar_container"..i):setVisible(true)
            self:getNode("bg_star"..i):setVisible(true)
            for j=1,6 do
                self:getNode("icon_star_"..i..j):setVisible(treasure.starlv>=j)
            end
            self:getNode("bg_star"..i):layout()
        else 
            self:getNode("bg_star"..i):setVisible(false)
            self:setLabelString("txt_qlevel"..i,"")
            self:setLabelString("txt_level"..i,"")
            self:getNode("bar_container"..i):setVisible(false) 
        end
   end


end

function TreasurePanel:showSelectCard(cardid)
    self.curCardid=cardid

    for i=1, 4 do
        self:changeTexture("icon_treasure"..i,"images/ui_public1/ka_d1.png")
        self:getNode("icon_treasure"..i):removeAllChildren()
    end

    local card=Data.getUserCardById(cardid)
    for i=1, 4 do
        local treasure=Data.getTreasureById(card["treasure"..i])
        self:getNode("icon_treasure"..i).treasure=treasure
        if(treasure)then
            local quality=DB.getItemQuality(treasure.itemid)
            self:changeTexture("icon_bg"..i,"images/ui_public1/tt_"..(quality+1)..".png")
            Icon.setIcon(treasure.itemid,self:getNode("icon_treasure"..i),quality)
            local sprite=self:getNode("icon_treasure"..i):getChildByTag(1)
            if(sprite)then
                sprite:setScale(0.8)
                sprite:setPositionY(sprite:getPositionY()+8)
            end
        else
            self:changeTexture("icon_bg"..i,"images/ui_public1/tt_2.png")
        end
    end
    
    self:showTreasureInfo()
    if(self.lastTreasureIdx==nil)then
        self:onSelectTreasureIcon(1)
    else
        self:onSelectTreasureIcon(self.lastTreasureIdx)
    end 
    self:initCardAttrData() 
    self:cardHasTreasureInBag()
    self:checkPlusScale()

   self:getNode("lock_node"):setVisible(not Unlock.isUnlock(SYS_TREASURE_RISESTAR,false))

end

function TreasurePanel:resetBtnTexture()
    local btns={
        "btn_treasure",
        "btn_quench",
        "btn_upgrade",
        "btn_star",
    }
    self:clearPanel()
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end

end

function TreasurePanel:selectBtn(name)
    self:getNode("btn_okeydecom"):setVisible(false)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end

function TreasurePanel:addTreasureItem(data)

    local item=TreasureBagItem.new()
    item:setData(data)
    item.selectItemCallback=function (data)
        self:onSelectTreasure(data)
    end
    self.bagPanel:getNode("bag_scroll"):addItem(item)

end

function TreasurePanel:dealEvent(event,data)

    if(event==EVENT_ID_TREASURE_WEAR)then
        self:showSelectCard(self.curCardid)
        for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
            if(var.curData.id==data.treasure.id)then
                self.bagPanel:getNode("bag_scroll"):removeItem(var,false)
                break
            end
        end
        if(data.oldTreasure)then
            self:addTreasureItem(data.oldTreasure)
        end
        self:selectBagBtn()
      
    elseif(event==EVENT_ID_TOWER_SHOP_REWARD_BUY)then
        self.bagInited=false   
        self:selectBagBtn() 
        
    elseif(event==EVENT_ID_TREASURE_TAKE_OFF or event==EVENT_ID_TREASURE_MERGE)then
        if(event==EVENT_ID_TREASURE_MERGE)then
            self:checkReduceEmptyItem()
            for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
                var:setRemainNum()
            end
        end
        self:showSelectCard(self.curCardid) 
        self:addTreasureItem(data)
        self:selectBagBtn()
    elseif (event==EVENT_ID_TREASURE_OKMERGE) then
        Panel.popBack(Panel.getPanelByType(TIP_TREASURE):getTag())
        self:checkReduceEmptyItem()
        for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
            var:setRemainNum()
        end
        self:showSelectCard(self.curCardid)
        for k,item in pairs(data) do
            self:addTreasureItem(item)
        end
        self:selectBagBtn() 
    elseif(event==EVENT_ID_TREASURE_SHARED_BUY)then 
        self.bagInited=false   
        self:selectBagBtn() 
    elseif(event==EVENT_ID_TREASURE_DECOMPOSE)then
        for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
            var:setRemainNum()
            if(var.curData.id==data.id)then
                self.bagPanel:getNode("bag_scroll"):removeItem(var,false)
            end
        end
        self:selectBagBtn()
    elseif(event==EVENT_ID_TREASURE_OKDECOMPOSE)then
        local deltable = {}
        for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
            if(data[var.curData.id]~=nil)then
                table.insert(deltable,var)
            end
            var:setRemainNum()
        end
        for k,var in pairs(deltable) do
            self.bagPanel:getNode("bag_scroll"):removeItem(var,false)
        end
        self:selectBagBtn()
    elseif(event==EVENT_ID_TREASURE_UPGRADE)then
        if(self.upgradePanel)then
            self:initUpgradeData(true)
            self:showEffect(self.upgradePanel:getNode("effect_container"))
        end
        if(self.cardPanel)then
            self.cardPanel:showUpquality()
        end
    elseif(event==EVENT_ID_TREASURE_QUENCH)then
         self:showSelectCard(self.curCardid)
    elseif (event==EVENT_ID_TREASURE_RISESTAR) then
        self:checkReduceEmptyItem()
        if self.riseStarPanel then
           self:initRiseStarData(true)
        end
    end
    RedPoint.bolCardViewDirty=true
    RedPoint.bolCardDataDirty=true
    gRedposRefreshDirty=true
end


function TreasurePanel:onSelectTreasureIcon(idx)

    if(idx)then
        self.lastTreasureIdx=idx
        self.lastTreasure=self:getNode("icon_treasure"..idx).treasure
        local posx,posy=self:getNode("container"..idx):getPosition()
        self:getNode("choose_icon"):setPosition(cc.p(posx,posy-102))
        if(self.upgradePanel)then
            self:initUpgradeData()
        end


        if(self.quenchPanel)then
            self:initQuenchData()
        end

        if self.riseStarPanel then
           self:initRiseStarData()
        end
        if(self.bagPanel and self.bagPanel:isVisible())then
            self:changeBagType()
        end
    end
    
    
    for i=1, 4 do
        local plus= self:getNode("btn_preview"..i)
        if(plus)then
            plus:setVisible(false)
            plus:stopAllActions()
        end
        
    end
    if(self.lastTreasure)then
        local plus= self:getNode("btn_preview"..idx)
        if(plus)then
            --self:scalePlusAction("btn_preview"..idx)
            plus:setVisible(true)
        end
    end
end

function TreasurePanel:cardHasTreasureInBag()
    local card=Data.getUserCardById(self.curCardid)
    for i=1, 4 do
        local plus= self:getNode("btn_plus"..i)
        plus:setVisible(false)
        self:getNode("txt_plus"..i):setVisible(false)
        plus.hasEquip=false
        plus.canMerge=false
        if(card["treasure"..i]==0)then
            plus:setVisible(true)
            self:getNode("txt_plus"..i):setVisible(true)
            local hasEquip,canMerge=self:hasTreasureInBag(i)
            plus.hasEquip=hasEquip
            plus.canMerge=canMerge
            if(hasEquip)then
                plus:setTexture("images/ui_public1/+big_green.png")
                self:getNode("txt_plus"..i):setColor(cc.c3b(0,255,0))
                self:setLabelString("txt_plus"..i,gGetWords("treasureWord.plist","12"))
            elseif(canMerge)then
                plus:setTexture("images/ui_public1/+big_yellow.png")
                self:getNode("txt_plus"..i):setColor(cc.c3b(254,155,0))
                self:setLabelString("txt_plus"..i,gGetWords("treasureWord.plist","13"))
            else
                plus:setTexture("images/ui_public1/+big_yellow.png")
                self:getNode("txt_plus"..i):setColor(cc.c3b(254,155,0))
                self:setLabelString("txt_plus"..i,gGetWords("treasureWord.plist","14"))
            end


        end

    end

end

function TreasurePanel:selectBagBtn()

    self:selectBtn("btn_treasure")
    self:initBagPanel()
    self:initCardAttrData()
    self:changeBagType() 
    self:checkPlusScale()
    for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
        var:setRemainNum()
    end
    if table.count(self.bagPanel:getNode("bag_scroll").items)>0 then
        self:getNode("btn_okeydecom"):setVisible(true)
    end
end

function TreasurePanel:stopPlusAction()
    for i=1, 4 do
        self:getNode("btn_plus"..i):stopAllActions()
        self:getNode("btn_plus"..i):setScale(0.7)
    end
end

function TreasurePanel:scalePlusAction(name)
    self:stopPlusAction()
    local action=cc.RepeatForever:create(
        cc.Sequence:create(
            cc.Spawn:create(  cc.ScaleTo:create(0.4,1))  ,
            cc.Spawn:create(   cc.ScaleTo:create(0.4,0.7))
        )
    )
    self:getNode(name):runAction(action)
end

function TreasurePanel:checkPlusScale()
    if(self.lastTreasureIdx==nil)then
        return
    end
    self:stopPlusAction()
    local idx=self.lastTreasureIdx
    local plus= self:getNode("btn_plus"..idx) 
    if( plus.hasEquip==true and   self.bagPanel:isVisible()==true )then
    else
        self:scalePlusAction("btn_plus"..idx)
    end
end

function TreasurePanel:selectTreasureUpgrade()


    self:selectBtn("btn_upgrade")
    self:initUpgradePanel() 
    self:checkPlusScale()
end

function TreasurePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_treasure"then
        self:selectBagBtn()
    elseif  target.touchName=="btn_quench"then
        self:selectBtn(target.touchName)
        self:initQuenchPanel() 
        self:checkPlusScale()
    elseif  target.touchName=="btn_upgrade"then
        self:selectTreasureUpgrade()
    elseif  target.touchName=="btn_star"then
        if not Unlock.isUnlock(SYS_TREASURE_RISESTAR,true)  then
            return
        end

        self:selectBtn(target.touchName)
        self:initRiseStarPanel() 
        self:checkPlusScale()
    elseif target.touchName=="btn_okeydecom" then
    Panel.popUp(PANEL_TREASURE_ONEKEYDECOM)
    elseif string.find(target.touchName,"icon_bg")then
        local idx= toint(string.gsub(target.touchName,"icon_bg",""))
        local card=Data.getUserCardById(self.curCardid)
        local myTreasure=Data.getTreasureById( card["treasure"..idx])
        if( self.lastTreasureIdx==idx)then
            if(myTreasure)then
                Panel.popUp(TIP_TREASURE,myTreasure,self)
            else

                self:selectBagBtn()

                if(self:hasTreasureInBag(idx)==false)then
                    local data={}
                    data.itemid=treasureDropItems[idx]
                    Panel.popUpVisible(PANEL_ATLAS_DROP,data)
                end
            end
        end
        self:onSelectTreasureIcon(idx)
        self:checkPlusScale()

    end
end

return TreasurePanel