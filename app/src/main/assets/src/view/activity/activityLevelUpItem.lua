local ActivityLevelUpItem=class("ActivityLevelUpItem",UILayer)

function ActivityLevelUpItem:ctor()
    self:init("ui/ui_hd_levelup_item.map")

end






function ActivityLevelUpItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        Net.sendActivityLevelUpGet(self.curData.boxid)
    end
end

function   ActivityLevelUpItem:refreshData(getIndex)
    local canBeGot = false
    local status = 0;
    -- self:getNode("btn_get"):setVisible(true)
    -- self:getNode("flag_unget"):setVisible(false);
    if(self.curData.limitpara> gUserInfo.level)then
        -- self:getNode("btn_get"):setVisible(false)
        -- self:getNode("flag_unget"):setVisible(true);
        self.isGet=0
        canBeGot = false
        status = -1;
    elseif(Data.activityLevelUp[self.curData.boxid]==1)then
        -- self:setTouchEnableGray("btn_get",false);
        -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_reward_got"))
        self.isGet=1
        canBeGot = false
        status = 1;
    else
        -- self:setTouchEnableGray("btn_get",true);
        -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward"))
        self.isGet=0
        canBeGot = true;
        status = 0;
    end
    Data.updateActLvUpCanBeGot(self.curData.limitpara,canBeGot)
    gShowBtnStatus(self:getNode("btn_get"),status);
end

function   ActivityLevelUpItem:setData(key,data,getIndex,extra)
    self.curData=data
    self.key=key

    local boxes= DB.getBoxItemById(self.curData.boxid)
    local extraBoxes= DB.getBoxItemById(extra.boxid)

    for key, box in pairs(boxes) do
        if(self:getNode("icon_"..key))then
            local node=DropItem.new()
            node:setData(box.itemid)
            node:setNum(box.itemnum )
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon_"..key))

        end
    end

    if(self:getNode("icon_3") and table.getn(extraBoxes)~=0)then
        local node=DropItem.new()
        node:setData(extraBoxes[1].itemid)
        node:setNum(extraBoxes[1].itemnum )
        node:setPositionY(node:getContentSize().height)
        gAddMapCenter(node, self:getNode("icon_3"))

    end


    self:getNode("icon_time_end"):setVisible( Data.activityLevelUpRemainTime/(24*60*60 )>7)



    self:setLabelString("txt_level",gGetWords("labelWords.plist","lab_hd_level_up_need",self.curData.limitpara))

    self:refreshData(getIndex)

end



return ActivityLevelUpItem