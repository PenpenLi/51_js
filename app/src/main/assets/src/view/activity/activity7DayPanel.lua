local Activity7DayPanel=class("Activity7DayPanel",UILayer)

function Activity7DayPanel:ctor(data)

    self:init("ui/ui_hd_7day.map")

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.curData=data
    Net.sendActivity7Day()
end



function Activity7DayPanel:setData(param)

    self:getNode("scroll"):clear()
    local rewards=DB.getLogin7Reward()
    for key, value in pairs(rewards) do
        local item=Activity7DayItem.new()
        item:setData(key,value,param)
        self:getNode("scroll"):addItem(item)

    end
    self:sortItem()
    self:getNode("scroll"):layout()

end

function Activity7DayPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_7_DAY)then
        self:setData(param)
    elseif( event==EVENT_ID_GET_ACTIVITY_7_DAY_GET )then
        self:refreshData(param)
    end
end
function Activity7DayPanel:sortItem()

    local sortItemFunc = function(a, b)
        if(a.isGet==b.isGet)then
            return a.key<b.key
        else
            return a.isGet<b.isGet
        end
    end
    table.sort(self:getNode("scroll").items, sortItemFunc)
end


function Activity7DayPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do
        item:refreshData(param)
    end
    self:sortItem()
    self:getNode("scroll"):layout()

end

return Activity7DayPanel