local ActivityInvest2Item=class("ActivityInvest2Item",UILayer)

function ActivityInvest2Item:ctor()
    self:init("ui/ui_hd_zhaomu2_item.map")
    
    self:getNode("layout_bg1"):setVisible(false)
    self:getNode("lab_count"):setVisible(false)
    self:getNode("sign_no"):setVisible(false)
    self:getNode("sign_yes"):setVisible(false)

    for i=1,4 do
        local nodeBg = self:getNode("reward"..i)
        if(nodeBg)then nodeBg:setVisible(false) end
    end

end




function ActivityInvest2Item:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        Net.sendActivityInvestGet(self.curData.lv)
    end
end


function   ActivityInvest2Item:setData(data)
    self.curData=data
    self:refreshData(data)
end

function   ActivityInvest2Item:refreshData(data)
    -- print_lua_table(self.curData)
    self.dia=self.curData.dia
    self.isGet=0
    local canBeGot = false
    local status = 0;
    -- self:getNode("btn_get"):setVisible(true)
    -- self:getNode("flag_unget"):setVisible(false);
    if(Data.activityInvestBuy==false or gUserInfo.level<toint(self.curData.lv))then
        -- self:getNode("btn_get"):setVisible(false)
        -- self:getNode("flag_unget"):setVisible(true);
        status = -1;
    else
        if(Data.activityInvestReward[toint(self.curData.lv)]==1)then 
            self.isGet=1
            status = 1;
            -- self:setTouchEnableGray("btn_get",false);
            -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_reward_got"))
        else
            -- self:setTouchEnableGray("btn_get",true);
            -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward"))
            canBeGot = true
            status = 0;
        end
    end
    gShowBtnStatus(self:getNode("btn_get"),status);

    local word = ""
    if (toint(self.curData.lv) == 0) then
        word = gGetWords("labelWords.plist","lab_hd_touzi_info0")
    else
        word = gGetWords("labelWords.plist","lab_hd_touzi_info1",self.curData.lv)
    end
    self:setRTFString("lab_title",word)


    local list = {}
    table.insert(list,{item=OPEN_BOX_DIAMOND,num=self.curData.dia})
    if (self.curData.id1 and self.curData.id1>0) then
        table.insert(list,{item=self.curData.id1,num=self.curData.num1})
    end
    if (self.curData.id2 and self.curData.id2>0) then
        table.insert(list,{item=self.curData.id2,num=self.curData.num2})
    end
    -- if (rData.item1 and rData.num1) then table.insert(list,{item=rData.item1,num=rData.num1}) end
    -- if (rData.item2 and rData.num2) then table.insert(list,{item=rData.item2,num=rData.num2}) end
    -- if (rData.item3 and rData.num3) then table.insert(list,{item=rData.item3,num=rData.num3}) end
    
    for k,v in pairs(list) do
        local nodeBg = self:getNode("reward"..k)
        if(nodeBg)then nodeBg:setVisible(true) end
        local node=DropItem.new()
        local itemid = v.item
        local num = v.num
        node:setData(itemid)
        node:setNum(num)
        node:setPositionY(node:getContentSize().height)
        gAddMapCenter(node, nodeBg)
    end


    -- self:setLabelString("lab_title",gGetWords("labelWords.plist","lab_hd_touzi_info",self.curData.lv,self.curData.dia))
    Data.updateActInvestCanBeGot(self.curData.lv, canBeGot)
end

return ActivityInvest2Item
