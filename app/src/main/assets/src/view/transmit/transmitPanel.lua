local TransmitPanel=class("TransmitPanel",UILayer)


function TransmitPanel:ctor(type)

    self:init("ui/ui_transmit.map")
    self.isMainLayerMenuShow = false;
    self:getNode("lock_icon"):setVisible(false)
    self:getNode("lock_icon2"):setVisible(false)
    if(type and type>0)then 
        self:showCard(type)
    else 
        self:showWeapon()
    end
    self:setUnlockBtn("btn_weapon")
    self:hideCloseModule();
    
    if(Module.isClose(SWITCH_EXCHANGE_CARD))then
        self:getNode("btn_exchange"):setVisible(false)
    end
end

function TransmitPanel:hideCloseModule()
    self:getNode("btn_card_soul"):setVisible(not Module.isClose(SWITCH_CARDSOUL));
end

function TransmitPanel:setUnlockBtn(name,lv)
    if Unlock.isUnlock(SYS_WEAPON,false) then
        return
    end
    local btn=self:getNode(name)
    DisplayUtil.setGray(btn);
    self:getNode("lock_icon"):setVisible(true)
    self:getNode("lock_icon2"):setVisible(true)
    DisplayUtil.setGray ( self:getNode("lock_icon"),false)
    DisplayUtil.setGray ( self:getNode("lock_icon2"),false)
end

function  TransmitPanel:events()
    return {EVENT_ID_REFRESH_TRANSMIT,EVENT_ID_REFRESH_TRANSMIT_RESULT,EVENT_ID_EXCHANGE_CARD_RESULT,EVENT_ID_ITEM_BUYED,EVENT_TREASURE_EXCHANGE}
end

function  TransmitPanel:onPopup()

    if(self.curPanel and  self.curPanel.onPopup )then
        self.curPanel:onPopup()
    end
end

function  TransmitPanel:onPopback()
    if(self.curPanel and  self.curPanel.onPopback )then
        self.curPanel:onPopback()
    end
end

function TransmitPanel:resetBtnTexture()
    local btns={
        "shine4",
        "shine3",
        "shine2",
        "shine1",
    }

    for key, btn in pairs(btns) do 
        self:getNode(btn):setVisible(false)
        self:getNode(btn):stopAllActions()
    end

end
function TransmitPanel:selectBtn(name)
    if Unlock.isUnlock(SYS_WEAPON,false)==false and name=="shine2" then 
        return
    end
    self:resetBtnTexture() 
    self:getNode(name):setVisible(true)
    gShineNode(self:getNode(name))
end


function TransmitPanel:dealEvent(event,data)
    if(self.curPanel)then
        self.curPanel:dealEvent(event,data)
    end
end

function TransmitPanel:clearPanel()
    if(self.curPanel)then
        self.curPanel:removeFromParent()
        self.curPanel=nil
    end
end

function TransmitPanel:showWeapon()
    self:clearPanel()
    self:selectBtn("shine2")
    self.curPanel=WeaponTransmitPanel.new()
    self:addChild( self.curPanel)
    gMainMoneyLayer:setMoneyType(OPEN_BOX_SOULMONEY);
end

function TransmitPanel:showTreasure()
    self:clearPanel()
    self:selectBtn("shine4")
    self.curPanel=TreasureTransmitPanel.new()
    self:addChild( self.curPanel)
    gMainMoneyLayer:setMoneyType(OPEN_BOX_SOULMONEY);
end


function TransmitPanel:showCard(type)
    self:clearPanel()
    self:selectBtn("shine1")
    self.curPanel=CardTransmitPanel.new(type)
    self:addChild( self.curPanel)
    gMainMoneyLayer:setMoneyType(OPEN_BOX_SOULMONEY);
end

function TransmitPanel:showExchange(type)
    self:clearPanel()
    self:selectBtn("shine3")
    self.curPanel=CardExchangePanel.new(type)
    self:addChild( self.curPanel)
    gMainMoneyLayer:setMoneyType(MONEY_TYPE_ITEM,ITEM_ID_EXCHANGE_CARD);
end



function TransmitPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_weapon_soul"then
        if Unlock.isUnlock(SYS_WEAPON) then
            Panel.popUpVisible(PANEL_CARD_WEAPON_EQUIP_SOUL); 
             
        end 
    elseif  target.touchName=="btn_card_soul"then

        Panel.popUp(PANEL_CARD_SOUL) 
    elseif  target.touchName=="btn_weapon"then
        if Unlock.isUnlock(SYS_WEAPON) then
            self:showWeapon()
        end
        self:selectBtn("shine2")
    elseif  target.touchName=="btn_card"then
        self:showCard()
        self:selectBtn("shine1")
    elseif  target.touchName=="btn_exchange"then
        self:showExchange()
        self:selectBtn("shine3")
    elseif  target.touchName=="btn_treasure"then
        self:showTreasure()
        self:selectBtn("shine4")
    end
end

return TransmitPanel