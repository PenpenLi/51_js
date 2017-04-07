local TownSweepItem=class("TownSweepItem",UILayer)

function TownSweepItem:ctor()
    self:init("ui/ui_tower_saodang_item.map")
    self.itemShowTime=0.1
end


function TownSweepItem:setData(data,idx)
    self.curData=data
    -- self:setLabelString("txt_gold",self.curData.gold)
    -- self:setLabelString("txt_money",self.curData.money)
    self:getNode("panel_stage"):setVisible(false)
    self:getNode("panel_floor"):setVisible(false)
    self:setLabelString("txt_star",3);
    if(self.curData.floorStar)then
        self:setLabelString("txt_star2",self.curData.floorStar);
    end
    if(self.curData.floor)then
        self:replaceLabelString("txt_floor",self.curData.floor);
        self:getNode("panel_floor"):setVisible(true)
    else
        local floor=math.ceil(self.curData.stage/3)
        local stage=  self.curData.stage -(floor-1)*3
        self:getNode("panel_stage"):setVisible(true)
        self:replaceLabelString("txt_stage",floor,stage);
    end
    self:initAllItem(data.items);
end

function TownSweepItem:initAllItem(items)
    for i=1, 5 do
        self:getNode("reward_"..i):setVisible(false)
    end
    self.items={}
    local idx=1
    if(items)then 
        for key,item in pairs(items) do
            if(self:getNode("reward_"..idx))then
                self:getNode("reward_"..idx):setVisible(true);
                local dropItem = Icon.setDropItem(self:getNode("reward_"..idx),item.id,item.num);
                dropItem:setOpacity(0);
                gSetCascadeOpacityEnabled(dropItem,true);
                dropItem:setAnchorPoint(cc.p(0.5,-0.5));
                dropItem:setPosition(gGetNodePositionByAnchorPoint(self:getNode("reward_"..idx),cc.p(0.5,0.5)));
                table.insert(self.items,dropItem);
                idx=idx+1
            end
        end
    end

    self:resetLayOut();

end

function TownSweepItem:quickShow()
    for key, item in pairs(self.items) do
        item:setOpacity(255)
        item:setScale(1)
    end
end

function TownSweepItem.show(self,moveTime,items)
    if(items==nil)then
        items=self.items
    end
    if(table.getn(items)==0)then
        return
    end
    for key, item in pairs(items) do
        item:setScale(1.6)
        local fadeIn=   cc.FadeIn:create(self.itemShowTime)
        local scaleTo=cc.EaseBackOut:create( cc.ScaleTo:create(self.itemShowTime,1))
        local delay=   cc.DelayTime:create(self.itemShowTime*(key-1)+moveTime)
        item:runAction( cc.Sequence:create(delay,cc.Spawn:create(fadeIn,scaleTo) ))
    end
end


return TownSweepItem