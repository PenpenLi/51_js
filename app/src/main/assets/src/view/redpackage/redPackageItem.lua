local RedPackageItem=class("RedPackageItem",UILayer)

function RedPackageItem:ctor()


end

function RedPackageItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_red_package_item.map")

end

function RedPackageItem:setLazyDataCalled()
    self:setData(self.curData)
end


function RedPackageItem:setLazyData(data)
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"red_package")
end


function RedPackageItem:setData(data)
    self:initPanel()
    self.curData=data
    self:replaceRtfString("txt_name",data.name)

    if(self.curData.loot==true)then

        self:changeTexture("btn","images/ui_public1/button_red_1.png")
        self:setLabelString("txt_btn",gGetWords("redPackage.plist","btn_redpack_loop"))
    else
        self:changeTexture("btn","images/ui_public1/button_blue_1.png")
        self:setLabelString("txt_btn",gGetWords("redPackage.plist","btn_view"))
    end
    self:updateTime()
end

function RedPackageItem:updateTime()
    self:setTouchEnable("txt_btn",true,false)
    if(self.curData.loot==true)then
        if( Data.loopPackNum>=DB.getClientParam("ACT_REDPACK_LOOT_NUM"))then
            self:setTouchEnable("txt_btn",false,true)
        end
    end
    local remainTime=self.curData.time-gGetCurServerTime()
    if(remainTime<=0)then
        remainTime=0
        self:getNode("btn"):setVisible(false)
    end
    self:replaceLabelString("txt_info",gParserMinTime(remainTime))
end

function RedPackageItem:onTouchEnded(target)
    if(self.curData.loot==true)then
        local function callback()
            self.curData.loot=false
            self:setData(self.curData)
        end
        Net.sendActivityLootName=self.curData.name
        Net.sendActivityLoot20(self.curData.id,callback)
    else
        Net.sendActivityRedPackInfo(self.curData.id)
    end
end


return RedPackageItem