local RedPackageDetailPanel=class("RedPackageDetailPanel",UILayer)

function RedPackageDetailPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true; 
    self.hideMainLayerInfo = true;
    self:init("ui/ui_red_package_detail.map")

    if(data.icon == 0)then
        self:changeTexture("head_icon","images/icon/head/gm.png");
    else
        Icon.setHeadIcon(self:getNode("head_icon"),data.icon);
    end
    self:replaceRtfString("txt_name",data.name)
    
    local getCount=table.count(data.list)
    self:getNode("txt_time"):setVisible(false)
    self:getNode("txt_time2"):setVisible(false)
    if(getCount>=data.count)then
        self:replaceRtfString("txt_time",data.count,gParserMinTimeStr(data.time)) 
        self:getNode("txt_time"):setVisible(true)
    else
        self:getNode("txt_time2"):setVisible(true)
        self:replaceRtfString("txt_time2",data.count-getCount)
    end

    self:getNode("panel_reward"):setVisible(false)
    self:getNode("no_reward_panel"):setVisible(false)
    if(data.id and data.id>0)then
        self:getNode("panel_reward"):setVisible(true)
        Icon.setIcon(data.id,self:getNode("icon"),DB.getItemQuality(data.id))

        self:setLabelString("txt_num","x"..data.num)
    else

        self:getNode("no_reward_panel"):setVisible(true)
    end
 
    
    
    Scene.clearLazyFunc("red_package_detail"); 
    self:getNode("scroll"):clear() 
    for key, var in pairs(data.list) do 
        local item=RedPackageDetailItem.new()
        if(key<8)then
            item:setData(var)
        else
            item:setLazyData(var)
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    self:resetLayOut()
     
end


function RedPackageDetailPanel:onPopback()
    Scene.clearLazyFunc("red_package_detail")
end




function RedPackageDetailPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end


return RedPackageDetailPanel