local ActivityRedPackageItem=class("ActivityRedPackageItem",UILayer)

function ActivityRedPackageItem:ctor()
    self:init("ui/ui_hd_red_package_item.map")

end





function ActivityRedPackageItem:buyBox()
    if(  NetErr.isDiamondEnough(self.curPrice))then
        local function callback()
            self.curData.num=self.curData.num+1
            self:refresh()
        end
        Net.sendActivityRec20(self.activityData.actId,self.curData.detid,callback)
    end
end

function ActivityRedPackageItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        self:buyBox()
    elseif(target.touchName=="btn_view")then
        local function callback(ret)
            for key, var in pairs(ret) do
                var.id=var.itemid
                var.num=var.itemnum
            end

            local data={}
            data.max=self.curData.max
            data.num=self.curData.num
            data.name=self.curData.boxName
            data.price=self.curPrice
            if(self.key==3)then
                data.title=gGetWords("redPackage.plist","12")
            else
                data.title=gGetWords("redPackage.plist","10")
            end
            data.callback=function()
                self:buyBox()
            end
            Panel.popUpVisible(PANEL_RED_PACKAGE_BOX,ret,data)
        end
        Net.sendActivityBoxInfo(self.curData.boxid,callback)
    end
end


function   ActivityRedPackageItem:refresh()
    local data=  self.curData
    if(data.max-data.num<=0)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end
    self:replaceLabelString("txt_btn",(data.max-data.num))

end


function   ActivityRedPackageItem:setData(activityData,data )
    self.curData=data
    self.activityData=activityData

    self:getNode("panel_not_red_package"):setVisible(false)
    self:getNode("panel_red_package"):setVisible(false)
    if(self.key==3)then 
        self:changeTexture("red_bg","images/ui_huodong/redbag_2.png")
        self:getNode("panel_red_package"):setVisible(true)
    else 
        self:changeTexture("red_bg","images/ui_huodong/zhi_9g.png")
        self:getNode("panel_not_red_package"):setVisible(true)
    end

    local item1=data.items[1]
    self:setLabelString("txt_name",data.boxName)
    self.curPrice=data.price
    self:setLabelString("txt_price",data.price)
    
    self:getNode("icon"):playAction("ui_hongbao_libao"..self.key) 
    self:refresh()

    for i=1, 3 do
        self:getNode("icon_"..i):setVisible(false)
    end
    for key, var in pairs(data.items) do
        if( self:getNode("icon_"..(key)))then
            Icon.setDropItem(self:getNode("icon_"..(key)),var.id,var.num,DB.getItemQuality(var.id))
            self:getNode("icon_"..(key)):setVisible(true)
        end
    end

    self:resetLayOut()
end



return ActivityRedPackageItem