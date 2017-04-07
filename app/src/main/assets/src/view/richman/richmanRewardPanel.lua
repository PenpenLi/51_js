local RichmanRewardPanel=class("RichmanRewardPanel",UILayer)

function RichmanRewardPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true;
    self.isMainLayerGoldShow=false 
    self:init("ui/ui_richman_reward.map")

    self.curData=gRichman.recRewards
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

end



function RichmanRewardPanel:onPopup()
 
    self:showRewards(richmanscorereward_db)

end


function  RichmanRewardPanel:events()
    return {EVENT_ID_RICHMAN_GETREWARD,EVENT_ID_RICHMAN_GETREWARD_ALL}
end



function RichmanRewardPanel:dealEvent(event,param)
    
    if(event==EVENT_ID_RICHMAN_GETREWARD_ALL)then
        self:showRewards(richmanscorereward_db)
    elseif event==EVENT_ID_RICHMAN_GETREWARD then
        local index=param
        local removeItem = self:getNode("scroll").items[index];
        local actEnd = function ()    

            self:getNode("scroll"):layout(false);

            self.touchEnable=true 
            self:sort(richmanscorereward_db)

            local function sortFunc(data1,data2)
                local reward1=data1.curData
                local reward2=data2.curData
                if(reward1.sort==reward2.sort)then
                    return reward1.id<reward2.id 
                else
                    return reward1.sort>reward2.sort
                end
            end
            table.sort(self:getNode("scroll").items,sortFunc); 
            for key, item in pairs(self:getNode("scroll").items) do 
                item:setData(item.curData)  
                item.key=key
                gModifyExistNodeAnchorPoint(item,cc.p(0,0)); 
                item:setScale(1)
            end
            self:getNode("scroll"):layout(false);

        end
        self:getNode("scroll"):setCheckChildrenVisible(true);
        self.touchEnable=false
        local action=cc.Sequence:create(cc.ScaleTo:create(0.25,0),cc.CallFunc:create(actEnd) )
        action:setTag(1)
        removeItem:stopActionByTag(1)
        removeItem:runAction(action);
        local prePos = cc.p(removeItem:getPosition());
        gModifyExistNodeAnchorPoint(removeItem,cc.p(0.5,-0.5));


        local count = table.getn(self:getNode("scroll").items);
        for i = index+1,count do
            local item = self:getNode("scroll").items[i];
            local action=cc.Sequence:create( cc.MoveTo:create(0.2,prePos))
            action:setTag(1)
            item:stopActionByTag(1)
            item:runAction(action);
            prePos = cc.p(item:getPosition());
        end 
 
    end
end

function RichmanRewardPanel:onPopback()
    Scene.clearLazyFunc("rewardItem")
end


function RichmanRewardPanel:sort(rewards)
    Data.redpos.richmanrec =false
    self.recNum=0
    for key, var in pairs(rewards) do
        if(gRichman.recRewards[var.id])then
            var.rec=1
        else
            var.rec=0
        end

        var.idx=var.id-1

        if(gRichman.score>= var.need)then
            var.canrec=1
        else
            var.canrec=0
            var.rec=0
            gRichman.recRewards[var.id]=false
        end 
        
        if(var.rec==1)then
            var.sort=0
        else
            if(var.canrec==1)then
                var.sort=2 
                self.recNum=self.recNum+1
                Data.redpos.richmanrec =true
            else
                var.sort=1
            end
        end 
    end
end


function RichmanRewardPanel:showRewards(rewards)
    Scene.clearLazyFunc("rewardItem");
    self:getNode("scroll"):clear()
    self:sort(rewards)
 
    local level=DB.getClientParam("CRUSADE_REC_ALL_LEVEL")
    if(self.recNum>=2 and gUserInfo.level>=level)then
        self:getNode("panel_onekey"):setVisible(true)
        self:getNode("scroll"):resize(cc.size(600,328))
    else
        self:getNode("panel_onekey"):setVisible(false)
        self:getNode("scroll"):resize(cc.size(600,410))
    end

    local function sortFunc(reward1,reward2)
        if(reward1.sort==reward2.sort)then
            return reward1.id<reward2.id
        else
            return reward1.sort>reward2.sort
        end
    end
    table.sort(rewards,sortFunc);
 
    for key, var in pairs(rewards) do
        local item=RichmanRewardItem.new()
        item.key=key
        if(key<8)then
            item:setData(var)
        else
            item:setLazyData(var)
        end 
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end
end




function RichmanRewardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    
    elseif  target.touchName=="btn_onekey"then
        Net.sendRichmanRewardOneKey() 
    end
end


return RichmanRewardPanel