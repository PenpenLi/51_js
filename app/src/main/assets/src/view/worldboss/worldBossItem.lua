local WorldBossItem=class("WorldBossItem",UILayer)

function WorldBossItem:ctor()
    self:init("ui/ui_world_boss_item.map")
end

function WorldBossItem:setData(data,key)
    -- print_lua_table(data)
    -- self.curData=data
    self:setLabelString("lab_rank",data.rank)
    self:setLabelString("lab_name",data.name)
    -- self:setLabelString("lab_name","赛龙舟塞龙舟")
    -- self:setLabelString("lab_att",data.damage)
    if Data.worldBossInfo.bosstype == 0 then
        self:setLabelString("lab_att",data.damage.."（"..gFloor2Point(data.damage/Data.worldBossInfo.hpmax).."%）")
    else
        self:setLabelString("lab_att",data.damage)
    end

    local bolMe = (data.userid == Data.getCurUserId() and true or false)
    self:getNode("me"):setVisible(bolMe)
    
    -- print_lua_table(data)
    --颜色判断
    if (key == 1) then
    	self:getNode("lab_rank"):setColor(cc.c3b(255,0,0))
    	self:getNode("lab_name"):setColor(cc.c3b(255,0,0))
    	self:getNode("lab_att"):setColor(cc.c3b(255,0,0))
    elseif (key == 2) then
    	self:getNode("lab_rank"):setColor(cc.c3b(255,132,0))
    	self:getNode("lab_name"):setColor(cc.c3b(255,132,0))
    	self:getNode("lab_att"):setColor(cc.c3b(255,132,0))
    elseif (key == 3) then
    	self:getNode("lab_rank"):setColor(cc.c3b(255,216,0))
    	self:getNode("lab_name"):setColor(cc.c3b(255,216,0))
    	self:getNode("lab_att"):setColor(cc.c3b(255,216,0))
    end
end

return WorldBossItem