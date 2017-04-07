local ServerBattlePreviewPanel=class("ServerBattlePreviewPanel",UILayer)

function ServerBattlePreviewPanel:ctor()
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_server_preview.map")
    Icon.setSecOfSeverBattle(self:getNode("icon_section"),gServerBattle.sectionLv)
    local secName = DB.getServerBattleSecNameByLv(gServerBattle.sectionLv)
    self:setLabelString("txt_sec_name", secName)
    local sectionType = DB.getServerBattleSecTypeByLv(gServerBattle.sectionLv)
    --理论上赛季开始时不可能有王者级
    if sectionType == SERVER_BATTLE_DUAN16 then
        self:getNode("layout_stars"):setVisible(false)
    else
        local totoalStars = DB.getServerBattleTotalStarsByLv(sectionType)
        for i = totoalStars + 1,6 do
            self:getNode("icon_star"..i):setVisible(false)
        end
        local minLv,maxLv = DB.getServerBattleRangeSecLvByType(sectionType)
        local num = gServerBattle.sectionLv - minLv

        for i=1, totoalStars do
            if i <= num then
                self:changeTexture("icon_star"..i,"images/ui_public1/star_mid.png")
            else
                self:changeTexture("icon_star"..i,"images/ui_public1/star_mid_1.png")
            end
        end
        self:getNode("layout_stars"):layout()
    end
end

function ServerBattlePreviewPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_ok" then
        self:onClose()
    end
end

return ServerBattlePreviewPanel