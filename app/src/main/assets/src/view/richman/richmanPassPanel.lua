local RichmanPassPanel=class("RichmanPassPanel",UILayer)

function RichmanPassPanel:ctor(panel)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_richman_pass.map")
    self.panel=panel
    self.items=panel.firstReward.items
    local items=panel.firstReward.items
    if(items)then

        for i=1, 4 do
            self:getNode("icon"..i):setVisible(false)
        end

        for i, var in pairs(items) do
            if(self:getNode("icon"..i))then
                self:getNode("icon"..i):setVisible(true)
                Icon.setDropItem(self:getNode("icon"..i),var.id,var.num)
            end
        end

    end
    self:resetLayOut()
end


function RichmanPassPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        gShowItemPoolLayer:pushItems(self.items);
        local panel=self.panel
        if(panel.moveNum~=0)then
            panel:moveToNext()
        else
            panel.isMoving=false
        end
        self:onClose()

    end
end

return RichmanPassPanel