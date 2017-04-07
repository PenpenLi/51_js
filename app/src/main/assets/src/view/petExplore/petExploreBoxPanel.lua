local PetExploreBoxPanel=class("PetExploreBoxPanel",UILayer)

function PetExploreBoxPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self.curData = data
    self:getNode("scroll"):setVisible(false)
    self:getNode("rewardlayout"):setVisible(true)
    self:getNode("txt_ratedes"):setVisible(true)
    self:getNode("rate_layout"):setVisible(true)

    self:setLabelString("txt_rateshow","+"..data.rate/100)
    if data.rate==0 then
        self:getNode("txt_rateshow"):setVisible(false)
    end
    self:initReward(data.id);

    
     self:setLabelString("txt_need_num",gGetWords("petWords.plist","full_coin"));

     self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_get_reward"));
    if(data.fillNum<9)then
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
        self:setTouchEnable("btn_get",false,true)
    elseif data.hasGeted then
        --已领取
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
        self:setTouchEnable("btn_get",false,true)
    end
    self:resetLayOut()
end

function PetExploreBoxPanel:initReward(id)
    local caveBoxdb =DB.getCaveBoxById(id)
    if caveBoxdb then
        local rewards={}
        for i=1,3 do
            if caveBoxdb["item"..i]>0 then
                table.insert(rewards,{itemid=caveBoxdb["item"..i],itemnum=caveBoxdb["num"..i]})
            end
        end
        local index=1
        for key, reward in pairs(rewards) do
            Icon.setDropItem(self:getNode("reward"..index),reward.itemid,reward.itemnum)
            index=index+1
        end
        for i=index,3 do
            self:getNode("reward"..i):setVisible(false)
        end
    end


end
 

function PetExploreBoxPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_get"then
        Net.sendCaveBoxReward(self.curData.id)
        Panel.popBack(self:getTag())
    end
end


return PetExploreBoxPanel