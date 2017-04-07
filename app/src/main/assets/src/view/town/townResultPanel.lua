local TownResultPanel=class("TownResultPanel",UILayer)

function TownResultPanel:ctor(isWin,rewardStr)
    -- loadFlaXml("lev_zhanduishengji_zi");
    -- loadFlaXml("lev_zhanduishengji");

    self._panelTop = true;
    self:init("ui/ui_tower_result.map");
    -- self:addFullScreenTouchToClose();

    self.initTime = os.time();
    self.isMainLayerGoldShow=false
    self.isWin = true;
    self.rewardStr = rewardStr;

    self:getNode("layer_win"):setVisible(false);
    self:getNode("layer_lose"):setVisible(false);
    if(self.isWin)then
        self:initWinUI();
    else
        self:initLoseUI();
    end

end

function TownResultPanel:initWinUI()
    self:getNode("layer_win"):setVisible(true);
    -- self:showStar(Data.towerInfo.curFloorStar);
    self:setLabelString("txt_pass_star",Data.towerInfo.floorStar);
    local curFloor = math.floor(Data.towerInfo.stage / 3) + 1;
    self:replaceRtfString("txt_floor",curFloor+1);
    
    local td_param = {}
    td_param['star'] = Data.towerInfo.curFloorStar
    td_param['floor'] = Data.towerInfo.floor
    td_param['power'] = math.ceil(Data.towerInfo.power/5000) * 5000
    gLogEvent("tower_pass",td_param)

    -- self.reward = cjson.decode(self.rewardStr);
    self.reward =Data.towerInfo.floorReward.items
    -- local reward = {};
    -- print_lua_table(self.reward);    
    for i=1,5 do
        self:getNode("reward"..i):setVisible(false);
    end
    local index = 1;
    for key,var in pairs(self.reward) do
        if(self:getNode("reward"..index))then 
            local data = {};
            data.id = toint(var.id);
            data.num = toint(var.num); 
            self:getNode("reward"..index):setVisible(true);
            Icon.setDropItem(self:getNode("reward"..index),data.id,data.num,DB.getItemQuality(data.id));
            index = index + 1; 
        end
    end

    self:resetLayOut();
end

function TownResultPanel:initLoseUI()
    -- print_lua_table(Data.towerInfo.disreward)
    self:getNode("layer_lose"):setVisible(true);
    self:setLabelString("txt_star",Data.towerInfo.tstar);

    local td_param = {}
    td_param['star'] = Data.towerInfo.tstar
    td_param['floor'] = Data.towerInfo.floor
    td_param['power'] = math.ceil(Data.towerInfo.power/5000) * 5000
    gLogEvent("tower_fail",td_param)

    local itemid = Data.towerInfo.disreward.id;
    if(itemid)then
        Icon.setDropItem(self:getNode("icon_gift"),itemid,Data.towerInfo.disreward.num,DB.getItemQuality(itemid));
        self:setLabelString("txt_name",DB.getItemName(itemid));
        self:setLabelString("txt_price1",Data.towerInfo.disreward.pri);
        self:setLabelString("txt_price2",math.floor(Data.towerInfo.disreward.pri*Data.towerInfo.disreward.dis/100));  
    end
    
    self:resetLayOut();  
end

function  TownResultPanel:showStar(num)
    for i=1, 4 do
        local star=self:getNode("star_up"..i)
        if(i<=num)then
            local function playStar()
                local effect = gCreateFla("ui-win-xingxing", -1)
                effect:setPosition(cc.p(star:getContentSize().width / 2, star:getContentSize().height / 2))
                star:addChild(effect)
            end
            star:runAction( cc.Sequence:create(cc.DelayTime:create(i*0.3), cc.CallFunc:create(playStar)) )
            self.showStarTime = i * 0.3
        end
    end
end

function TownResultPanel:onTouchEnded(target)

    -- if os.time() - self.initTime < 1 then
    --     return;
    -- end

    -- target.touchName == "full_close" or 
    if target.touchName == "btn_exit" then
        Data.towerInfo.stage = Data.towerInfo.stage + 1;
        Data.towerInfo.floorReward=nil
        Panel.popBack(self:getTag())
        if(self.isWin)then
            gDispatchEvt(EVENT_ID_TOWER_NEXT_FLOOR);
        end
    elseif target.touchName == "btn_buy" then
        Panel.popBack(self:getTag());
        Net.sendTowerBuydisGift();    
    end

end

return TownResultPanel