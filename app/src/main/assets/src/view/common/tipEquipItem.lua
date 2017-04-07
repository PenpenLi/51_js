local TipEquipItem=class("TipEquipItem",UILayer)

function TipEquipItem:ctor(data)
    self.appearType = 1
    self:init("ui/tip_equip_info.map")
    self.curData=data
    self:setItemId(data.itemid)
end



function TipEquipItem:onTouchEnded(target)

    if(target.touchName=="btn_equip")then
        if(self.curData.canActivate)then
            Net.sendEquipActivate(self.curData.cardid,self.curData.equipIdx,self.curData.activatePos)
            Panel.popBack(self:getTag())
        end
    elseif(target.touchName=="btn_confirm")then 
        Panel.popBack(self:getTag())
    end

end

function TipEquipItem:setItemId(itemid)
    self.itemid=itemid
    local db,type= DB.getItemData(itemid)
    if(db==nil)then
        return
    end
    local num=Data.getEquipItemNum(itemid)
     

    self:setLabelString("txt_info",CardPro.getEquipAtivateAttrAddDesc(self.curData))  

    self:setLabelString("txt_name",db.name) 
    self:setLabelString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num",num))
    if(self.curData.canActivate)then
        self:getNode("btn_equip"):setVisible(true)
        self:getNode("btn_confirm"):setVisible(false)
    else
        self:getNode("btn_equip"):setVisible(false)
        self:getNode("btn_confirm"):setVisible(true)
    
    end 
     
 

    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid))

    if(not self.curData.hasActivate and   not self.curData.canActivate)then
        DisplayUtil.setGray(self:getNode("icon"),true)
    end
end

return TipEquipItem