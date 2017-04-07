local CardAwakePreviewPanel=class("CardAwakePreviewPanel",UILayer)

function CardAwakePreviewPanel:ctor( cardid)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self.isWindow = true;
    self._panelTop = true;

    self:init("ui/ui_cardawake_preview.map")
    local card=Data.getUserCardById(cardid)
    local showTip = false;
    if(card==nil)then
        card = DB.getCardById(cardid);
        card.weaponLv = 0;
        card.awakeLv = 0;
        showTip = true;
    else
        showTip = card.grade < 5;    
    end
    self:getNode("tip"):setVisible(showTip);
    for i=1, 4 do
        local item=CardAwakePreviewItem.new(card,Data.cardAwake.lv[i],Data.cardAwake.lv[i+1])
        item:setPositionY(item:getContentSize().height)
        self:getNode("pos"..i):addChild(item)
    end
    self:resetLayOut()
end


function CardAwakePreviewPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return CardAwakePreviewPanel

 