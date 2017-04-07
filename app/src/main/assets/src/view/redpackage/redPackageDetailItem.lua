local RedPackageDetailItem=class("RedPackageDetailItem",UILayer)

function RedPackageDetailItem:ctor()


end

function RedPackageDetailItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_red_package_detail_item.map")

end

function RedPackageDetailItem:setLazyDataCalled()
    self:setData(self.curData)
end


function RedPackageDetailItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"red_package_detail")
end


function RedPackageDetailItem:setData(data)
    self:initPanel()
    self.curData=data 
    Icon.setHeadIcon(self:getNode("head_icon"),data.icon);
    self:setLabelString("txt_name",data.name)
    Icon.setIcon(data.id,self:getNode("icon"),DB.getItemQuality(data.id))
    self:setLabelString("txt_num","")
    self:setLabelString("txt_itemname","")

    self:setLabelString("txt_num","x"..data.num) 
    self:resetLayOut()
end
 


return RedPackageDetailItem