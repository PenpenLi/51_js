local FormationCardItem=class("FormationCardItem",UILayer)

function FormationCardItem:ctor(data)
    self:init("ui/ui_formation_item.map")
    self:getNode("icon_selected"):setVisible(false)
    self:getNode("touch_node"):setVisible(false)
    self.starContainerX= self:getNode("star_container"):getPositionX()
    self:setData(data);
end

function FormationCardItem:setData(data)

    if data.isPet then
        self:getNode("icon_card_type"):setVisible(false)
        data.qlt=DB.getItemQuality(data.cid)
        data.awakeLv = Pet.getPetAwakeLvByGrade(data.gd)
    end

    self:setLabelString("txt_level",data.lv);
    CardPro:showStar(self,data.gd,data.awakeLv,-10); 
    Icon.setIcon(data.cid,self:getNode("icon"),data.qlt,data.awakeLv);

    self.cardDb=DB.getCardById(data.cid)
    if(self.cardDb==nil)then
        return
    end
    self:changeTexture("icon_card_type","images/ui_public1/card_type_"..self.cardDb.type..".png")

end


return FormationCardItem