local LuckWheelRewardPanel=class("LuckWheelRewardPanel",UILayer)

function LuckWheelRewardPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true; 
    self:init("ui/ui_luck_wheel_reward.map")
 
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
 
    self:showReward(turnscore_db)
end
 

function  LuckWheelRewardPanel:events()
    return {EVENT_ID_LUCK_WHEEL_REWARD_REC}
end

 

function LuckWheelRewardPanel:dealEvent(event,param)
    if event==EVENT_ID_LUCK_WHEEL_REWARD_REC then 
        self:showReward(turnscore_db) 
    end
end

function LuckWheelRewardPanel:onPopback()
    Scene.clearLazyFunc("wheelreward")
end


function LuckWheelRewardPanel:sort(reward)
    for key, var in pairs(reward) do
        if(gLuckWheel.rewardRec[var.id])then
            var.rec=1
        else
            var.rec=0
        end

        var.idx=key-1

        var.canrec=0
        if(gLuckWheel.score>= var.need)then
            var.canrec=1 
        end 


        if(var.rec==1)then
            var.sort=0
        else
            if(var.canrec==1)then
                var.sort=2
            else
                var.sort=1
            end
        end

    end
end


function LuckWheelRewardPanel:showReward(rewards)
    Scene.clearLazyFunc("wheelreward");
    self:getNode("scroll"):clear()
 
    self:sort(rewards)


    local function sortReward(item1,item2)
        if(item1.sort==item2.sort)then
            return item1.id<item2.id
        else
            return item1.sort>item2.sort
        end
    end
    table.sort(rewards,sortReward);
    Data.redpos.bolLuckWheelRec=false

    for key, var in pairs(rewards) do
        local item=LuckWheelRewardItem.new()
        item.key=key
        item:setData(var)  
        if(var.canrec==1 and var.rec~=1)then
            Data.redpos.bolLuckWheelRec=true
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end
end




function LuckWheelRewardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end


return LuckWheelRewardPanel