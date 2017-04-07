local ActivityLevelUpPanel=class("ActivityLevelUpPanel",UILayer)
ActivityLevelUpPanelData = {}
function ActivityLevelUpPanel:ctor(data)

    self:init("ui/ui_hd_levelup.map") 
    self.curData=data

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    Net.sendActivityLevelUp()
end


function ActivityLevelUpPanel:setData(param)


    self:getNode("scroll"):clear()
    local rewards=DB.getLevelUpReward()
    local extraReward=DB.getLevelUpExtraReward()
    for key, value in pairs(rewards) do
        local item=ActivityLevelUpItem.new()
        item:setData(key,value,param,extraReward[key])
        self:getNode("scroll"):addItem(item)

    end
    self:sortItem()
    self:getNode("scroll"):layout()

end

function ActivityLevelUpPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_LEVEL_UP)then
            self:setData(param)
    
    elseif(event==EVENT_ID_GET_ACTIVITY_LEVEL_UP_GET)then
          self:refreshData(param)
        
    end
end

function ActivityLevelUpPanel:sortItem()

    local sortItemFunc = function(a, b)
        if(a.isGet==b.isGet)then
            return a.key<b.key
        else
            return a.isGet<b.isGet
        end
    end
    table.sort(self:getNode("scroll").items, sortItemFunc)
end

function ActivityLevelUpPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do
        item:refreshData(param)
    end
    self:sortItem()
    self:getNode("scroll"):layout()

end


return ActivityLevelUpPanel