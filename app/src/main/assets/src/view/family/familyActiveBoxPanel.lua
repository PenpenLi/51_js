local FamilyActiveBoxPanel=class("FamilyActiveBoxPanel",UILayer)

function FamilyActiveBoxPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self.boxData = data;
    local des_point = data.fexp;
    local boxid = data.boxid;
    local btnStatus = 0;
    if(data.status == 0) then
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
    elseif data.status == 2 then
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
    end
    self:initReward(boxid);
    self:setLabelString("txt_need_num",gGetWords("familyWords.plist","lab_active_box",des_point));
    
end

function FamilyActiveBoxPanel:initReward(boxid)

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
 

function FamilyActiveBoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
     
    
    elseif  target.touchName=="btn_get"then
        
        Panel.popBack(self:getTag())
        if(gFamilyInfo.isTempMember)then
            gShowCmdNotice("family.recactivebox",11);
            return;
        end
        Net.sendFamilyActiveBox(self.boxData.boxid)
     
    end
end


return FamilyActiveBoxPanel