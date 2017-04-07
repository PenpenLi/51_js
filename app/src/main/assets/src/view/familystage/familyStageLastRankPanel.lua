local FamilyStageLastRankPanel=class("FamilyStageLastRankPanel",UILayer)

function FamilyStageLastRankPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_family_stage_last_rank.map")
    self:initPanel()
end

function FamilyStageLastRankPanel:initPanel()
    Icon.setFamilyIcon(self:getNode("icon1"),gFamilyInfo.icon,gFamilyInfo.familyId)
    self:setLabelString("txt_name1", gFamilyInfo.sName)

    if gFamilyStageInfo.otherLastProg.icon == 0 and gFamilyStageInfo.otherLastProg.name == "" then
        self:getNode("icon_suc2"):setVisible(false)
        self:getNode("spr_bg_icon2"):setVisible(false)
        self:getNode("txt_name2"):setVisible(false)
        self:getNode("icon_suc2"):setVisible(false)
    else
        Icon.setFamilyIcon(self:getNode("icon2"),gFamilyStageInfo.otherLastProg.icon)
        self:setLabelString("txt_name2", gFamilyStageInfo.otherLastProg.name)
    end

    if gFamilyStageInfo.lastWinFlag then
        self:changeTexture("icon_suc2", "images/ui_jingji/shibai.png")
    else
        self:changeTexture("icon_suc1", "images/ui_jingji/shibai.png")
    end

    self:initScroll()
end

function FamilyStageLastRankPanel:initScroll()
    self.scroll1 = self:getNode("scroll1")
    self.scroll1.eachLineNum = 1
    self.scroll1:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scroll1:clear()

    table.sort(gFamilyStageInfo.selfLastInfos, function (lMem, rMem)
        return lMem.num > rMem.num
    end)

    for idx, info in ipairs(gFamilyStageInfo.selfLastInfos) do
        local item = FamilyStageLastRankItem.new(idx,info)
        self.scroll1:addItem(item)
    end
    self.scroll1:layout(true)

    self.scroll2 = self:getNode("scroll2")
    self.scroll2.eachLineNum = 1
    self.scroll2:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.scroll2:clear()

    if #gFamilyStageInfo.otherLastInfos == 0 then
        return
    end
    table.sort(gFamilyStageInfo.otherLastInfos, function (lMem, rMem)
        return lMem.num > rMem.num
    end)
    
    for idx, info in ipairs(gFamilyStageInfo.otherLastInfos) do
        local item = FamilyStageLastRankItem.new(idx,info)
        self.scroll2:addItem(item)
    end
    self.scroll2:layout(true)
end

function FamilyStageLastRankPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    end
end

function FamilyStageLastRankPanel:events()
    return {
        
    }
end

function FamilyStageLastRankPanel:dealEvent(event, param)

end

return FamilyStageLastRankPanel