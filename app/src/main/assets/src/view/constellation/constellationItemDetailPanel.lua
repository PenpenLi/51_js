local ConstellationItemDetailPanel=class("ConstellationItemDetailPanel",UILayer)

function ConstellationItemDetailPanel:ctor(id,num)
    self:init("ui/ui_constellation_item_detail.map")
    self:initPanel(id,num)
end

function ConstellationItemDetailPanel:events()
    return {
        }
end

function ConstellationItemDetailPanel:dealEvent(event, param)

end

function ConstellationItemDetailPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_get" then
        Net.sendCircleFightinfo()
    elseif target.touchName=="btn_soul" then
        Panel.popUp(PANEL_CONSTELLATION_SOUL)
    end
end

function ConstellationItemDetailPanel:initPanel(id, num)
    self.id = id
    self.num = num

    Icon.setIcon(id,self:getNode("icon"))
    self:setLabelString("txt_name",DB.getConstellationsItemInfo(id)["name"])
    self:setLabelString("txt_num",gGetMapWords("ui_constellation_item_detail.plist", "1", num))
    self:setRTFString("txt_desc", DB.getItemAttrDes(id))
    self:getNode("desc_scroll"):layout();

    self.scroll = self:getNode("scroll")
    self.scroll.eachLineNum = 3
    if gCurLanguage == LANGUAGE_EN then
        self.scroll.eachLineNum = 1
    end
    -- self.scroll:setPaddingXY(5,5)
    self.scroll.offsetX = 20
    self.scroll:clear()

    local activeNum = 0
    local totalNum  = 0
    for _,magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
        if #magicCircleInfo.groupInfos == 0 then
            magicCircleInfo:initGroupInfos()
        end

        for _, groupInfo in ipairs(magicCircleInfo.groupInfos) do
            if groupInfo:hasCard(id) then
                local color = cc.c3b(255,255,255)
                if groupInfo.actived then
                    color = cc.c3b(255,0,0)
                    activeNum = activeNum + 1
                end
                local labelWord = gCreateWordLabelTTF(groupInfo.desc,gFont,20,color)
                labelWord:setAnchorPoint(cc.p(0, 1))
                self.scroll:addItem(labelWord)
                totalNum = totalNum + 1
            end
        end
    end
    self.scroll:layout()
    self:setLabelString("txt_actived_num", string.format("%d/%d",activeNum,totalNum))
end

return ConstellationItemDetailPanel
