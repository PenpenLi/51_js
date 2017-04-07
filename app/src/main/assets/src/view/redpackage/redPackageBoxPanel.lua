local RedPackageBoxPanel=class("RedPackageBoxPanel",UILayer)

function RedPackageBoxPanel:ctor(reward,data)
    self.appearType = 1;
    self.isWindow = true;
    self.hideMainLayerInfo = true;
    self:init("ui/ui_red_package_box.map")

    self.curData=data
    self:getNode("scroll").eachLineNum=5
    self:getNode("scroll").offsetX=19.4
    self:getNode("scroll").offsetY=18
    self:getNode("scroll").padding=5
    self:getNode("scroll").itemScale=0.95
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    self:setLabelString("txt_name",data.name)
    self:setLabelString("txt_price",data.price)
    self:setRTFString("txt_title",data.title)

    if(data.max-data.num<=0)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end
    self:replaceLabelString("txt_btn",(data.max-data.num))
    for i,var in pairs(reward) do 
        local node = DropItem.new(true);
        node:setData(var.id);
        node:setNum(var.num); 
        self:getNode("scroll"):addItem(node);
    end
    self:getNode("scroll"):layout()
end



function RedPackageBoxPanel:onTouchEnded(target,touch)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
       
    elseif  target.touchName=="btn_get"then
        Panel.popBack(self:getTag()) 
        if(self.curData.callback)then
            self.curData.callback()
        end
    end
end


return RedPackageBoxPanel