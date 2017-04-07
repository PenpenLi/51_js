local TownSweepPanel=class("TownSweepPanel",UILayer)

function TownSweepPanel:ctor(data)
    self:init("ui/ui_tower_saodang.map")
    self.isMainLayerMenuShow = false;
    self.isMainLayerGoldShow = false;

    self:getNode("scroll"):setCheckChildrenVisibleEnable(false);

    self.curData=data
    self.copyData={}
    self.rewardItems={}
    for key, var in pairs(self.curData) do
        self:addItems(var.items)
        table.insert(self.copyData,var)
    end
    self:initTotalReward();
    local data=self:getNextData()
    self:showRewards(data)
    self.itemShowTime=0.1
    gCreateRoleRunFla(Data.getCurIcon(),self:getNode("bg_my_role"),0.9,nil,nil,Data.getCurWeapon(),Data.getCurAwake());

end


function TownSweepPanel:getLastData()
    local ret={}
    local count=table.getn(self.copyData)
    for i=1, 16 do
        local item=self.copyData[count-i+1]
        if(item==nil)then
            break
        end
        table.insert(ret,1,item)
    end

    return ret
end

function TownSweepPanel:getNextData()
    local ret={}
    self.isEnd=false
    for i=1, 4*4 do
        local item=self.curData[1]
        if(item==nil)then
            self.isEnd=true
            break
        end
        table.insert(ret,item)
        table.remove(self.curData,1)
    end

    if(table.count(self.curData)==0)then
        self.isEnd=true
    end
    return ret
end

function TownSweepPanel:addItems(items)
    if(items)then
        for key, item in pairs(items) do
            if(self.rewardItems[item.id]==nil)then
                self.rewardItems[item.id]=clone(item)
            else
                self.rewardItems[item.id].num=self.rewardItems[item.id].num+item.num
            end
        end
    end
end

function TownSweepPanel:initTotalReward()
    for i=1, 10 do
        self:getNode("reward_"..i):setVisible(false)
    end
    local idx=1
    for key,item in pairs(self.rewardItems) do
        if(self:getNode("reward_"..idx))then
            self:getNode("reward_"..idx):setVisible(true);
            local item=Icon.setDropItem(self:getNode("reward_"..idx),item.id,item.num);
            self:getNode("reward_"..idx):setScale(0.8)
            idx=idx+1
        end
    end
    self:getNode("scroll_contain_item"):layout();
    self:getNode("items_scroll"):layout();
    self:getNode("items_scroll"):setVisible(false);
    self:getNode("txt_tip"):setVisible(true);
    self:getNode("panel_attr"):setVisible(false)

    local items={}

    for key,var in pairs(Data.towerInfo.autoattr) do
        if(items[var.attr]==nil)then
            items[var.attr]=0
        end
        items[var.attr]=items[var.attr]+var.val
    end

    local attrs={}

    for key, var in pairs(items) do
        table.insert(attrs,{attr=key,val=var})
    end
    for i=1, 6 do
        self:getNode("txt_addattr"..i):setVisible(false)
    end
    for key,var in pairs(attrs) do
        if(self:getNode("txt_addattr"..key))then
            local name = gGetWords("cardAttrWords.plist","attr"..var.attr);
            self:setLabelString("txt_addattr"..key,name.."+"..var.val.."%")
            self:getNode("panel_attr"):setVisible(true)
            self:getNode("txt_tip"):setVisible(false);
            self:getNode("txt_addattr"..key):setVisible(true)
        end
    end
    self:resetLayOut();
end

function TownSweepPanel:showTotalReward()
    self:getNode("items_scroll"):setVisible(true);

end

function TownSweepPanel:showRewards(data,hasNext)
    if(data==nil)then
        return
    end


    self:getNode("scroll"):clear()
    for key, var in pairs(data) do
        local item=TownSweepItem.new()
        self:getNode("scroll"):addItem(item)
        item:setData(var,var.floor)
        item:setVisible(false)
    end
    self:getNode("scroll"):layout()
    local moveTime=0.2
    local passTime=0
    for key, item in pairs(self:getNode("scroll").items) do
        local function onMoved()
            item:setVisible(true)
            item:show(moveTime)
            self:getNode("scroll"):moveItemByIndex(key-2,moveTime)
        end
        local func=   cc.CallFunc:create(onMoved)
        local delay=   cc.DelayTime:create(passTime)
        item:runAction( cc.Sequence:create(delay,func ))
        passTime=passTime+moveTime
        passTime=passTime+0.1
        passTime=passTime+table.getn(item.items)*item.itemShowTime
    end


    local function onEnd()
        self.isQuickShow=true
        self:showTotalReward();
        self:sweepEnd();
    end



    local function onNext()
        local data=self:getNextData()
        self:showRewards(data)
    end

    if(self.isEnd )then
        self:getNode("total_panel"):runAction( cc.Sequence:create( cc.DelayTime:create(passTime),cc.CallFunc:create(onEnd) ))
    else
        self:getNode("total_panel"):runAction( cc.Sequence:create( cc.DelayTime:create(passTime),cc.CallFunc:create(onNext) ))
    end


    self:setLabelString("txt_need","")
    self:getNode("txt_need"):setVisible(false)

end

function TownSweepPanel:quickShow()
    if(self.isQuickShow)then
        return
    end
    self.isQuickShow=true

    local data=self:getLastData()
    self:getNode("scroll"):clear()
    for key, var in pairs(data) do
        local item=TownSweepItem.new()
        self:getNode("scroll"):addItem(item)
        item:setData(var,var.floor)
        item:quickShow()
    end
    self:getNode("scroll"):layout()


    self:showTotalReward();
    self:getNode("total_panel"):stopAllActions()
    self:sweepEnd();
end

function TownSweepPanel:sweepEnd()

    self:getNode("txt_need"):setVisible(true)
    self:getNode("att_effect"):removeFromParent();
    self:getNode("att_effect1"):removeFromParent();
    gCreateRoleFla(Data.getCurIcon(),self:getNode("bg_my_role"),0.9,nil,nil,Data.getCurWeapon(),Data.getCurAwake());
    local flaEnd = gCreateFla("ui_saodang_over",-1);
    self:replaceNode("sweep_end",flaEnd);
    self:getNode("scroll").container:setPositionY(0)

    -- if(Data.towerInfo.disreward.id and Data.towerInfo.disreward.id > 0)then
    --     Panel.popUpVisible(PANEL_TOWER_GIFT);
    -- end

end

function TownSweepPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        gDispatchEvt(EVENT_ID_TOWER_RESET,true);
    elseif  target.touchName=="touch_node"then
        self:quickShow()
    end
end

return TownSweepPanel