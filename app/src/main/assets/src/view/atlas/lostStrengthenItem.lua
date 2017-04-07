local LostStrengthenItem=class("LostStrengthenItem",UILayer)

function LostStrengthenItem:ctor()
    self:init("ui/battle_resule_guide.map")
end

function LostStrengthenItem:onTouchEnded(target)
    if self.type == "recruit" then
        Panel.clearRepopup();
        Scene.checkAndCreateMoneyLayer()
        Scene.enterMainScene()
        Panel.popUp(PANEL_DRAW_CARD)
    elseif self.type == "equipStrengthen" or self.type == "starUp" or self.type == "skillUp" then
        Scene.checkAndCreateMoneyLayer()
        Panel.popUp(PANEL_CARD)
    elseif self.type == "petTrain" then
        Scene.checkAndCreateMoneyLayer()
        if Unlock.isUnlock(SYS_PET) then
            Panel.popUp(PANEL_PET)
        end
    end
end
 
function   LostStrengthenItem:setData(type, itemid, desc)  
    self.type = type
    Icon.setIcon(itemid,self:getNode("icon"))
    self:setLabelString("txt_info", desc)
end 
 
return LostStrengthenItem