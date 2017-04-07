local RedPackagePanel=class("RedPackagePanel",UILayer)

function RedPackagePanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true;
    self.hideMainLayerInfo = true;
    self:init("res/ui/ui_red_package.map")

    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)


    Scene.clearLazyFunc("red_package");
    self:getNode("icon_empty"):setVisible(true)
    self:getNode("scroll"):clear()
    for key, var in pairs(data) do

        local item=RedPackageItem.new()
        if(key<8)then
            item:setData(var)
        else
            item:setLazyData(var)
        end
        local remainTime=var.time-gGetCurServerTime()
        if(var.loot==true)then
            item.sort=1000000+  remainTime
        else
            item.sort= remainTime

        end
        self:getNode("scroll"):addItem(item)
    end
    local function sortFunc(a,b)
        return a.sort>b.sort
    end
    table.sort(self:getNode("scroll").items,sortFunc)
    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    else
        Data.hasRedPack=false
    end


    function updateTime()
        for key, item in pairs(self:getNode("scroll").items) do
            item:updateTime()
        end
        self:replaceLabelString( "txt_max_num", Data.loopPackNum,DB.getClientParam("ACT_REDPACK_LOOT_NUM"))
    end
    self:scheduleUpdateWithPriorityLua(updateTime,1)
    
    
end


function RedPackagePanel:onPopback()
    Scene.clearLazyFunc("red_package")
end


function  RedPackagePanel:events()
    return {EVENT_ID_CRUSADE_FEAT_REC}
end



function RedPackagePanel:dealEvent(event,param)
    if event==EVENT_ID_CRUSADE_FEAT_REC then

    end
end




function RedPackagePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end


return RedPackagePanel