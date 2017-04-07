local ActivityTuanRewardPanel=class("ActivityTuanRewardPanel",UILayer)

function ActivityTuanRewardPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true;
    self.isMainLayerGoldShow=false
    -- self.isMainLayerCrusadeShow=true
    self:init("ui/ui_crusade_feat.map")

    self.curData=Data.activityTuanRewardData
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    local sWord = gGetWords("labelWords.plist","224-1");
    self:setLabelString("lab_title",sWord)

    sWord = gGetWords("labelWords.plist","226-1");
    self:setLabelString("lab_word",sWord)

    sWord = gGetWords("labelWords.plist","228-1");
    self:setLabelString("lab_reward",sWord)

    self:getNode("panel_onekey"):setVisible(false)
    self:getNode("scroll"):resize(cc.size(600,410))
end

function ActivityTuanRewardPanel:getGroupBuyReward()
    local ret={}
    for key, var in pairs(groupbuyreward_db) do
        table.insert(ret,var)
    end
    return ret
end

function ActivityTuanRewardPanel:onPopup()
    local feats=self:getGroupBuyReward()--DB.getCrusadeFeatByLevel(self.curData.level)
    -- print_lua_table(feats)
    self:showFeats(feats)
end

function  ActivityTuanRewardPanel:events()
    return {EVENT_ID_GET_ACTIVITY_TUAN_REWARD_GET}
end

function ActivityTuanRewardPanel:dealEvent(event,param)
    if event==EVENT_ID_GET_ACTIVITY_TUAN_REWARD_GET then
        local index=param
        local removeItem = self:getNode("scroll").items[index];
        -- print("index----------"..index)
        local actEnd = function ()    
            self:getNode("scroll"):layout(false);
            self.touchEnable=true
            local feats=self:getGroupBuyReward()
            self:sort(feats)
            local function sortFeat(data1,data2)
                local feat1=data1.curData
                local feat2=data2.curData
                if(feat1.sort==feat2.sort)then
                    return feat1.id<feat2.id 
                else
                    return feat1.sort>feat2.sort
                end
            end
            table.sort(self:getNode("scroll").items,sortFeat);
            Data.redpos.bolTuanRewardRec=false
            for key, item in pairs(self:getNode("scroll").items) do 
                item:setData(item.curData) 
                if(item.curData.canrec==1 and item.curData.rec~=1)then
                    Data.redpos.bolTuanRewardRec=true
                end 
                item.key=key
                gModifyExistNodeAnchorPoint(item,cc.p(0,0)); 
                item:setScale(1)
            end
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

function ActivityTuanRewardPanel:onPopback()
    -- Scene.clearLazyFunc("featItem")
end


function ActivityTuanRewardPanel:sort(feats)
    for key, var in pairs(feats) do
        if(self.curData.list[key])then
            var.rec=1
        else
            var.rec=0
        end

        var.idx=key-1

        if(Data.activityTuanData.score>= var.need)then
            var.canrec=1
        else
            var.canrec=0
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

function ActivityTuanRewardPanel:showFeats(feats)
    -- Scene.clearLazyFunc("featItem");
    -- print_lua_table(feats)

    self:getNode("scroll"):clear()
    self:sort(feats)
    local function sortFeat(feat1,feat2)
        if(feat1.sort==feat2.sort)then
            return feat1.id<feat2.id
        else
            return feat1.sort>feat2.sort
        end
    end
    -- print("------------------")
    table.sort(feats,sortFeat);

    -- print_lua_table(feats)

    Data.redpos.bolTuanRewardRec=false
    for key, var in pairs(feats) do
        local item=ActivityTuanRewardItem.new()
        item.key=key
        -- if(key<8)then
            item:setData(var)
        -- else
        --     item:setLazyData(var)
        -- end
        if(var.canrec==1 and var.rec~=1)then
            Data.redpos.bolTuanRewardRec=true
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end
end

function ActivityTuanRewardPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return ActivityTuanRewardPanel