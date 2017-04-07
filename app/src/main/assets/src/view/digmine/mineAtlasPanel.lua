local MineAtlasPanel=class("MineAtlasPanel",UILayer)

function MineAtlasPanel:ctor()
    self:init("ui/ui_mine_atlas.map")
    self.scroll = self:getNode("scroll")
    self.scroll.paddingX = 60
    self.scroll:setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    local num = DB.getMineAtlasChapterNum()
    local itemContentSize = nil
    for i = 1, num do
        local item = MineAtlasItem.new(i)
        self.scroll:addItem(item)
    end
    self.scroll:layout()

    if(Module.isClose(SWITCH_VIP))then
        self:getNode("layer_leftime"):setVisible(false)
    end

    self:setLabelInfo()
end

function MineAtlasPanel:onTouchEnded(target, touch, event)
    if  target.touchName == "btn_close" then
        self:onClose()
    elseif target.touchName == "btn_reset" then
        if gDigMine.mapId == 0 then
            gShowNotice(gGetWords("mineWords.plist","notice_no_reset_atlas"))
            return
        else
            if Data.canBuyTimes(VIP_MINING_ATLAS_RESET,false) then
                local price = Data.vip.miningAtlasReset.getBuyPriceAndCount()
                if price == 0 then
                    gConfirmCancel(gGetWords("mineWords.plist","txt_reset_nums"), function()
                        --TODO
                        if gIsVipExperTimeOver(VIP_MINING_ATLAS_RESET) then
                            return
                        end
                        Net.sendMiningChapreset(gDigMine.mapId)
                    end)
                else
                    gConfirmCancel(gGetWords("mineWords.plist","txt_atlas_reset_dia",price), function()
                        --TODO
                        if gIsVipExperTimeOver(VIP_MINING_ATLAS_RESET) then
                            return
                        end
                        if NetErr.isDiamondEnough(price) then
                            Net.sendMiningChapreset(gDigMine.mapId)
                        end
                    end)
                end
            else
                Panel.popUpVisible(PANEL_VIP_NOTICE,false);
            end
        end
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_MINE_ATLAS)
    end
end

function MineAtlasPanel:setLabelInfo()
    self:setLabelString("txt_mastery", gDigMine.mastery)
    self:getNode("layout_mastery"):layout()
    self:setLabelString("txt_leftnum", Data.getLeftUseTimes(VIP_MINING_ATLAS_RESET))
    self:getNode("layout_leftnum"):layout()
end

function MineAtlasPanel:refreshVipChange()
    self:setLabelInfo()
end

function MineAtlasPanel:events()
    return { EVENT_ID_MINING_ATLAS_REFRESH,
            EVENT_ID_MINING_REFRESH_GETBOX,
            EVENT_ID_MINING_ATLAS_SWEEP,
            EVENT_ID_GET_ACTIVITY_VIP_CHANGE
        }
end

function MineAtlasPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_ATLAS_REFRESH then
        self.scroll:clear()
        local num = DB.getMineAtlasChapterNum()
        for i = 1, num do
            local item = MineAtlasItem.new(i)
            self.scroll:addItem(item)
        end
        self.scroll:layout()
        self:setLabelInfo()
    elseif event == EVENT_ID_MINING_REFRESH_GETBOX and param == DETAIL_BOX_STEP4 then
        if Net.sendMiningGetFBoxMapId ~= nil then
            local item = self.scroll:getItem(Net.sendMiningGetFBoxMapId - 1)
            if nil ~= item then
                item:setBoxShow()
            end
        end
    elseif event == EVENT_ID_MINING_ATLAS_SWEEP then
        local item = self.scroll:getItem(gDigMine.mapId - 1)
        if nil ~= item then
            item:setBoxShow()
            item:setArrowShow()
        end
    elseif event == EVENT_ID_GET_ACTIVITY_VIP_CHANGE then
        self:refreshVipChange()
    end
end

return MineAtlasPanel