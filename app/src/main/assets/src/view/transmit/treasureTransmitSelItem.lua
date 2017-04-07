local TreasureTransmitSelItem=class("TreasureTransmitSelItem",UILayer)
function TreasureTransmitSelItem:ctor()
end

function TreasureTransmitSelItem:setData(data)
    self.curData=data
    self:init("ui/ui_weapon_transmit_mowen_item.map")

    Icon.setIcon(data.itemid,self:getNode("treasure_icon"))
    local treasureDB = DB.getTreasureById(data.itemid)
    self:setLabelString("treasure_name",treasureDB.name)
    self:setLabelString("treasure_lv",data.upgradeLevel)
    self:setLabelString("treasure_quellv",data.quenchLevel)

    local country = {}
    local campids = string.split(treasureDB.campid,";")
    for k,v in pairs(campids) do
        table.insert(country,gGetWords("cardAttrWords.plist","country_"..v))
    end
    country = table.concat(country, "、")
    self:setLabelString("treasure_country",country)

    CardPro:showStar(self,data.starlv)
end

function  TreasureTransmitSelItem:setDataLazyCalled()
    self:setData(self.lazyData)
end

function  TreasureTransmitSelItem:setLazyData(data)
    self.lazyData=data
    Scene.addLazyFunc(self,self.setDataLazyCalled,"TreasureTransmitSelItem")
end

function TreasureTransmitSelItem:onTouchEnded(target)

    self.selectItemCallback(self.curData)
end
return TreasureTransmitSelItem