local ActivityTuanItem=class("ActivityTuanItem",UILayer)

function ActivityTuanItem:ctor(data)
    self:init("ui/ui_hd_tuan_item.map")
    -- self.type = data;
    -- self.key = 0
end

function ActivityTuanItem:onTouchEnded(target)
    if(self.onSelectCallback)then
        self.onSelectCallback(self.curData,self.key)
    end
end

function ActivityTuanItem:setSelect(value)
    self:getNode("select_bg"):setVisible(value)
end

function ActivityTuanItem:setData(key,data)
    self.curData=data
    self.key = key

    local sale = 100
    for k,v in pairs(data.plist) do
        if (data.allnum>=v.num) then
            sale = v.sale
        end
    end

    self:replaceLabelString("lab_zhe",gGetDiscount(sale/10))

    Icon.setIcon(toint(data.itemid),self:getNode("icon"),DB.getItemQuality(data.itemid))
    self:setLabelString("lab_num",data.itemnum)
end

function ActivityTuanItem:refreshData()
    self:setData(self.key,self.curData)
end


return ActivityTuanItem