local TreasureStarDes=class("TreasureStarDes",UILayer)

function TreasureStarDes:ctor(treasure)
    self:init("ui/ui_constellation_group_xingjijiacheng.map")
    local maxStarLv = DB.getMaxTreasureStar(treasure.itemid)

    for i=1,maxStarLv do
        local attrArray = {}
        local nextStarAttrValue= CardPro.getTreasureStarAttr(treasure.itemid,i)
        local nextLevelData=DB.getTreasureStar(treasure.itemid,i)
        for i=1, 2 do
            local attrName = CardPro.getAttrName(nextStarAttrValue[i].attr)
            local attrValue = CardPro.getAttrValue(nextStarAttrValue[i].attr,nextStarAttrValue[i].value)
            table.insert(attrArray,{attrName=attrName,attrValue=attrValue})
        end

        local extattr = gGetMapWords("ui_treasure_shengxing.plist","46",nextLevelData.addpoint)
        local attrValue = ""
        table.insert(attrArray,{attrName=extattr,attrValue=attrValue})

        local extattr = gGetMapWords("ui_treasure_shengxing.plist","45",CardPro.getAttrName(nextLevelData["extra_attr"]))
        local attrValue = CardPro.getAttrValue(nextLevelData["extra_attr"],nextLevelData["extra_value"])
        table.insert(attrArray,{attrName=extattr,attrValue=attrValue})

        local item = TreasureStarDesItem.new(attrArray,i)
        item:setData(treasure.starlv)
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
end

function TreasureStarDes:onTouchEnded(target,touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    end
end

return TreasureStarDes
