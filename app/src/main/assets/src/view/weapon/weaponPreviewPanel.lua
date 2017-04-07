local WeaponPreviewPanel=class("WeaponPreviewPanel",UILayer)



function WeaponPreviewPanel:ctor( cardid)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self.isWindow = true;

    self:init("ui/ui_weapon_preview.map")
    self:getNode("scroll").eachLineNum=2
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    local card=Data.getUserCardById(cardid)
    local weaponMaxLv = card.weaponLv
    if weaponMaxLv<=Data.cardRaiseMaxLevel then
        weaponMaxLv=Data.cardRaiseMaxLevel
    end
    self:replaceLabelString("txt_lv",gParseWeaponLv(card.weaponLv))
    for key, var in pairs(cardraiselevel_db) do
        if(var.cardid== cardid  and var.buffid~=0 and var.level<=weaponMaxLv)then
            local db=DB.getBuffById(var.buffid)
            local item=WeaponTransmitBuffItem.new()
            item:setData(db,var,card.weaponLv,card.weaponLv)
            self:getNode("scroll"):addItem(item)
        end
    end
    self:getNode("scroll"):layout()
     
    for i=1, 4 do 
        local item=WeaponPreviewItem.new(card,WeaponChangeLv[i],WeaponChangeLv[i+1])
        item:setPositionY(item:getContentSize().height)
        self:getNode("pos"..i):addChild(item)
    end
    self:resetLayOut()
end


function WeaponPreviewPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return WeaponPreviewPanel

 