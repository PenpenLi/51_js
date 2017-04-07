local FamilyStageJoinPanel=class("FamilyStageJoinPanel",UILayer)

function FamilyStageJoinPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_family_stage_join.map")
    self:initPanel()
end


function FamilyStageJoinPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    end
end

function FamilyStageJoinPanel:initPanel()
    self.scroll = self:getNode("scroll")
    self.scroll.eachLineNum = 1
    self.scroll:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.scroll:clear()

    table.sort(gFamilyMemList, function (lMem, rMem)
        if lMem.iType == rMem.iType then
            if lMem.iStageFightNum == rMem.iStageFightNum then
                return lMem.iPower > rMem.iPower
            else
                return lMem.iStageFightNum < rMem.iStageFightNum
            end
        else
            return lMem.iType < rMem.iType
        end
    end)

    for _, memInfo in ipairs(gFamilyMemList) do
        local memItem = FamilyStageJoinItem.new(memInfo)
        self.scroll:addItem(memItem)
    end
    self.scroll:layout(true)
    self:setLabelString("txt_active_num", string.format("%d/%d", gFamilyStageInfo.activeNum,#gFamilyMemList))
    self:getNode("layout_acitve"):layout()
end

function FamilyStageJoinPanel:events()
    return {
        
    }
end

function FamilyStageJoinPanel:dealEvent(event, param)

end

return FamilyStageJoinPanel