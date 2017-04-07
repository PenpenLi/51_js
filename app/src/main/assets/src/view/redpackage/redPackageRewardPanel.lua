local RedPackageRainPanel=class("RedPackageRainPanel",UILayer)

function RedPackageRainPanel:ctor(reward)
    self.appearType = 1;
    self.isWindow = true;
    self.hideMainLayerInfo = true;
    self:init("res/ui/ui_red_package_reward.map")

    self:getNode("panel_item"):setVisible(false)
    self:getNode("panel_empty"):setVisible(false)
    self:getNode("icon_gongxi"):setVisible(false)
    self:getNode("icon_light"):setVisible(false)

    local item=reward[1]
    self.reward=reward
    self:replaceRtfString("lab_title",Net.sendActivityLootName)
    if(item==nil)then
        self:getNode("panel_empty"):setVisible(true)
        self:setLabelString("txt_btn",gGetWords("btnWords.plist","btn_confirm"))
    else

        self:getNode("icon_gongxi"):playAction("ui_hongbao_gongxi",nil,nil,0)
        self:getNode("icon_gongxi"):setVisible(true)
        self:getNode("icon_light"):setVisible(true)
        self:getNode("panel_item"):setVisible(true)
        Icon.setIcon(item.id,self:getNode("icon"),DB.getItemQuality(item.id))

        self:setLabelString("txt_num","x"..item.num)
        self:setLabelString("txt_btn",gGetWords("btnWords.plist","btn_get_reward"))
        self:resetLayOut()
    end
end



function RedPackageRainPanel:onTouchEnded(target,touch)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif( target.touchName=="btn_get")then
        if( self.reward)then
            gShowItemPoolLayer:pushItems( self.reward);
        end
        Panel.popBack(self:getTag())

        local panel=Panel.getTopPanel(Panel.popPanels)
        if(panel and panel.__panelType==PANEL_RED_PACKAGE_RAIN)then
            Panel.popBack(panel:getTag())
        end
    end
end


return RedPackageRainPanel