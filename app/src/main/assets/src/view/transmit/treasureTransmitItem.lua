local TreasureTransmitItem=class("TreasureTransmitItem",UILayer)
function TreasureTransmitItem:ctor()
end

function TreasureTransmitItem:setData(treasureDB)
    self.curData=treasureDB
    self:init("ui/ui_weapon_transmit_mowen_item2.map")
    Icon.setIcon(treasureDB.id,self:getNode("treasure_icon"))
    self:setLabelString("treasure_name",treasureDB.name)

    local country = {}
    local campids = string.split(treasureDB.campid,";")
    for k,v in pairs(campids) do
        table.insert(country,gGetWords("cardAttrWords.plist","country_"..v))
    end
    country = table.concat(country, "、")
    self:setLabelString("treasure_country",country)

end


function TreasureTransmitItem:setCheck(check)
	if check then
		self:changeTexture("btn_check","images/ui_public1/n-di-gou2.png")
	else
	    self:changeTexture("btn_check","images/ui_public1/n-di-gou1.png")
	end    
end
function TreasureTransmitItem:onTouchEnded(target)
	if  target.touchName=="btn_check"then
		if self.selectCallBack then
			self.selectCallBack(self.curData)
		end
    end
end

return TreasureTransmitItem