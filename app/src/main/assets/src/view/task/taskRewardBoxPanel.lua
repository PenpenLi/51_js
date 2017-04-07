local TaskRewardBoxPanel=class("TaskRewardBoxPanel",UILayer)

function TaskRewardBoxPanel:ctor(taskDB,status)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self.taskDB = taskDB;
    local des_point = taskDB.num;
    local boxid = taskDB.gtype1;
    local btnStatus = 0;
    if(status == 0) then
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
    elseif status == 2 then
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
    end
    -- gShowBtnStatus(self:getNode("btn_get"),btnStatus);
    self:initReward(boxid);
    self:setLabelString("txt_need_num",gGetWords("labelWords.plist","lab_task_box",des_point));
    
end

function TaskRewardBoxPanel:initReward(boxid)

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
 

function TaskRewardBoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
     
    
    elseif  target.touchName=="btn_get"then
        -- print("id = "..self.taskDB.id);
        Net.sendDayTaskGet(self.taskDB.id);
        -- Net.sendAtlasGetRewinfo(self.curMapid,self.curBoxIdx,self.curDiff)
        Panel.popBack(self:getTag())
     
    end
end


return TaskRewardBoxPanel