local ActivityEnargyBoxPanel=class("ActivityEnargyBoxPanel",UILayer)

function ActivityEnargyBoxPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self.boxData = data;
    local index = data.index;
    local boxid = data.boxid;
    local btnStatus = 0;
    if(data.status == 0) then--未达成
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
    elseif data.status == 2 then--已经领取
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
    end
    self:initReward(boxid);
    self:setLabelString("txt_need_num",gGetWords("activityNameWords.plist","eat_reward_title",Data.activity.bun_box_click_num[index]));
    
end

function ActivityEnargyBoxPanel:initReward(boxid)

    local rewards=DB.getBoxItemById(boxid)

    for i=1, 3 do
        self:getNode("reward"..i):setVisible(false)
    end

    local idx=1
    for key, item in pairs(rewards) do
        if(self:getNode("reward"..idx))then

            self:getNode("reward"..idx):setVisible(true) 
            local node=DropItem.new()
            node:setData(item.itemid) 
            node:setNum(item.itemnum)   
            
            node:setPositionY(node:getContentSize().height)
            self:getNode("reward"..idx):addChild(node)
            idx=idx+1
        
        end
    end

end
 

function ActivityEnargyBoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_get"then
        -- Net.sendFamilyActiveBox(self.boxData.boxid)
        -- Panel.popBack(self:getTag())
    end
end


return ActivityEnargyBoxPanel