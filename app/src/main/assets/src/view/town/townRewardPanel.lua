local TownRewardPanel=class("TownRewardPanel",UILayer)

function TownRewardPanel:ctor(rewardStr)

    self._panelTop = true;
    self:init("ui/ui_tower_reward.map");
    -- self:addFullScreenTouchToClose();
    print("rewardStr = "..rewardStr);
    self.reward = cjson.decode(rewardStr);
    table.insert(self.reward,1,{star=3,id=OPEN_BOX_GOLD,num=1})
    table.insert(self.reward,1,{star=6,id=OPEN_BOX_GOLD,num=1})
    table.insert(self.reward,1,{star=9,id=OPEN_BOX_GOLD,num=1})
    for i=1,3 do
        local item = self:createItem(i);
        self:getNode("scroll"):addItem(item);
    end
    self:getNode("scroll"):layout();

end

function TownRewardPanel:createItem(star)
    local uiLayer = UILayer.new();
    uiLayer:init("ui/ui_tower_reward_item.map");
    if(star == 3)then
        uiLayer:setLabelString("txt_star_num",star*3); 
    else
        uiLayer:setLabelString("txt_star_num",(star*3).."-"..(star*3+2)); 
    end
    for i=1,5 do
        uiLayer:getNode("reward_"..i):setVisible(false);
    end
    -- local reward = {};
    local index = 1;
    for key,var in pairs(self.reward) do
        if(toint(var.star) == star*3)then
            local data = {};
            data.id = toint(var.id);
            data.num = toint(var.num);
            -- table.insert(reward,data);

            -- uiLayer:reward_1
            uiLayer:getNode("reward_"..index):setVisible(true);
            local item=Icon.setDropItem(uiLayer:getNode("reward_"..index),data.id,data.num,DB.getItemQuality(data.id));
            index = index + 1;
            if(var.id==OPEN_BOX_GOLD )then
                item:setLabelString("txt_num","?")
            end
            -- break;
        end
    end

    uiLayer:resetLayOut();
    return uiLayer;

end

function TownRewardPanel:onTouchEnded(target)
    -- target.touchName == "full_close" or 
    if target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
    end

end

return TownRewardPanel