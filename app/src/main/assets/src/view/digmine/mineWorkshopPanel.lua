local MineWorkshopPanel=class("MineWorkshopPanel",UILayer)

function MineWorkshopPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_mine_workshop.map")
    self:initLabelInfo()
    self:initScrollLayer()
    self:resetLayOut();
    if isBanshuReview() then
        self:getNode("txt_name_y"):setVisible(false)
    end
end

function MineWorkshopPanel:initLabelInfo()
    -- body
    self:setLabelString("txt_pickax_num", gDigMine.getMptFractionStr())
    self:getNode("layout_pickax"):layout()
    self:setLabelString("txt_dig_depth", gDigMine.maxLightY)
    self:setLabelString("txt_detonator_num", string.format("x%d",Data.getItemNum(ITEM_DETONATOR)))
    self:getNode("layout_detonator"):layout()
end

function MineWorkshopPanel:initScrollLayer()
    self.scrollLayer = self:getNode("project_items")
    self.scrollLayer.offsetX = 5
    self.scrollLayer.offsetY = 5
    self.scrollLayer:setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:setScrollLayer()
end
function MineWorkshopPanel:events()
    return { 
                EVENT_ID_MINING_PROJINFO,
                EVENT_ID_MINING_NEW_PROJ,
                EVENT_ID_USER_DATA_UPDATE,
                EVENT_ID_MINING_CANCELPRO,
           }
end

function MineWorkshopPanel:dealEvent(event, param)
    if event == EVENT_ID_MINING_PROJINFO then
        self:setScrollLayer()
    elseif event == EVENT_ID_MINING_NEW_PROJ then
        self:setScrollLayer()
        self:initLabelInfo()
    elseif event == EVENT_ID_USER_DATA_UPDATE then
        self:initLabelInfo()
    elseif event == EVENT_ID_MINING_CANCELPRO then
        self:setScrollLayer()
        self:initLabelInfo()
    end
end

function MineWorkshopPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        self:onClose()
    end
end

function MineWorkshopPanel:onPopup()
    -- Net.sendMiningProjInfo()
end

function MineWorkshopPanel:setScrollLayer()
    self.scrollLayer:clear()
    for i = 1, #gDigMine.projList do
        local projInfo = gDigMine.projList[i]
        local mineProjectItem = MineProjectItem.new(projInfo,i)
        self.scrollLayer:addItem(mineProjectItem)
    end
    self.scrollLayer:layout()
end

return MineWorkshopPanel