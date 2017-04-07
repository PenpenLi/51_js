local RichmanRankReward=class("RichmanRankReward",UILayer)

function RichmanRankReward:ctor()
    self:init("ui/ui_richman_rank_reward.map")

end

function RichmanRankReward:onTouchEnded(target)

end

function RichmanRankReward:setData(data,preData,index)


    if(data.rank>=6 and preData)then 
        self:replaceLabelString("txt_rank",(preData.rank+1).."~"..data.rank)
    else
        self:replaceLabelString("txt_rank",data.rank) 
    end
    

    for i=1, 5 do
        self:getNode("icon"..i):setVisible(false)
    end


    local rewards= cjson.decode(data.reward);
    for i, var in pairs(rewards) do
        self:getNode("icon"..i):setVisible(true)
        Icon.setDropItem(self:getNode("icon"..i),var.id,var.num)
    end

end

return RichmanRankReward