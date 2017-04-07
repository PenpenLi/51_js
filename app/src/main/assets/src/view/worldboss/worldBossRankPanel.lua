local WorldBossRankPanel=class("WorldBossRankPanel",UILayer)

function WorldBossRankPanel:ctor()
    self:init("ui/ui_new_wboss_rank.map")

    for i=1,2 do
        self:getNode("scroll_"..i).breakTouch = true
        self:getNode("scroll_"..i).eachLineNum=1 
        self:getNode("scroll_"..i):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self:getNode("scroll_"..i).scrollBottomCallBack = function()
            self:onMoveDown();
        end
    end
    
    self.iShowIndex = 0;
    self.iShowMax = 100;
    self.iShowSize = 10;

    self:getNode("txt_rank"):getParent():setVisible(false)
    self:getNode("txt_food"):getParent():setVisible(false)
    self:setLabelString("txt_info",gGetWords("arenaWords.plist","13-4"))

    self.scrolType = 0
    self.ranks = {}
    self.rewards = {}
    self:selectBtn("btn_type1")

end

function WorldBossRankPanel:onPopup()
    Net.sendRankWorldBoss()
end

function WorldBossRankPanel:onMoveDown()
    if (self.iShowIndex>=self.iShowMax) then
        return;
    end

    local scrol = nil;
    if self.scrolType == 1 then
        scrol = self:getNode("scroll_1");
    else
        scrol = self:getNode("scroll_2");
    end
    local list = nil
    for i=1+self.iShowIndex,self.iShowSize+self.iShowIndex do
        local key = i
        if self.scrolType == 1 then
            list = self.ranks
            if (key<=table.getn(list)) then
                local var = list[key]
                var.rank = key
                local item = self:createRankItem(var)
                scrol:addItem(item)
            end
        else
            list = self.rewards
            if (key<=table.getn(list)) then
                local var = list[key]
                local item=self:createRewardItem(var)
                scrol:addItem(item)
            end
        end
        
    end
    scrol:layout(self.iShowIndex==0)
    self.iShowIndex = self.iShowIndex + self.iShowSize;
    self.iShowIndex = math.min(self.iShowIndex,self.iShowMax)
end

function WorldBossRankPanel:createRankItem(data)
    local item=ArenaRankItem.new()
    item:setData(data,EVENT_ID_RANK_BOSS,data.rank)

    return item
end

function WorldBossRankPanel:createRewardItem(data)
    local layer = UILayer.new()
    layer:init("ui/ui_duoliang_jiangli_item.map")

    if (data.minlv>0) then
        local rank = data.minlv
        if (data.minlv ~= data.maxlv) then
            -- @~@名
            layer:replaceLabelString("txt_info",data.minlv,data.maxlv)
        else
            -- 第@名
            layer:setLabelString("txt_info",gGetWords("lootFoodWords.plist","rank_name",rank))
        end
    else
        local sWord = gGetWords("worldBossWords.plist","9");
        layer:setLabelString("txt_info",sWord)
    end

    local rnumpro = 1
    local bossd = DB.getBossData(Data.worldBossInfo.bosslv)
    if (bossd~=nil) then
        rnumpro = bossd.rnumpro/100
    end
    if (data.itemid1>0) then
        Icon.setDropItem(layer:getNode("icon1"), (data.itemid1),data.itemnum1*rnumpro,DB.getItemQuality(data.itemid1))
    else layer:getNode("icon1"):setVisible(false) end
    if (data.itemid2>0) then
        Icon.setDropItem(layer:getNode("icon2"), (data.itemid2),data.itemnum2,DB.getItemQuality(data.itemid2))
    else layer:getNode("icon2"):setVisible(false) end
    if (data.itemid3>0) then
        Icon.setDropItem(layer:getNode("icon3"), (data.itemid3),data.itemnum3,DB.getItemQuality(data.itemid3))
    else layer:getNode("icon3"):setVisible(false) end

    return layer
end

function WorldBossRankPanel:showType(type)
    if self.scrolType == type then
        return
    end
    self.scrolType = type

    for i=1,2 do
        self:getNode("scroll_"..i):clear()
        self:getNode("scroll_"..i):getParent():setVisible(false)
    end

    local scrol = nil
    if(type == 1) then
        scrol = self:getNode("scroll_1")
    else 
        scrol = self:getNode("scroll_2")
    end
    scrol:getParent():setVisible(true)


    if type == 1 then
        self.iShowMax = table.getn(self.ranks);
    else
        local showBossType = 0;
        self.rewards = {};
        if(type == 3) then showBossType = 1; end;
        if table.getn(self.rewards) == 0 then
            local db_list = {}
            for k,v in pairs(worldbossreward_db) do
                if showBossType == v.bosstype then
                    table.insert(db_list,v)
                end
            end
            self.rewards = db_list
            table.sort(self.rewards,function(a,b) return a.id<b.id end) --从小到大排序
        end
        self.iShowMax = table.getn(self.rewards);
    end

    if self.iShowMax > 0 then
        self:getNode("space_layer"):setVisible(false)
    else
        self:getNode("space_layer"):setVisible(true)
    end
    self.iShowIndex = 0;
    self:onMoveDown();
end

function WorldBossRankPanel:events()
    return {EVENT_ID_RANK_BOSS}
end

function WorldBossRankPanel:dealEvent(event,param)
    if(event==EVENT_ID_RANK_BOSS)then
        self.ranks = param.ranks;
        self:showType(1)
        if(param.islast == true) then
            self:setLabelString("txt_rank_name",gGetWords("worldBossWords.plist","rank_pre"))
        else
            self:setLabelString("txt_rank_name",gGetWords("worldBossWords.plist","rank_cur"))
        end
        --[[if param.rank == 0 then
            local txt_no = gGetWords("trainWords.plist","no_family")
            self:setLabelString("txt_rank",txt_no)
            self:setLabelString("txt_food",txt_no)
        else
            self:setLabelString("txt_rank",param.rank)
            self:setLabelString("txt_food",param.food)
        end]]
    end
end

function WorldBossRankPanel:resetBtnTexture()
    local btns={ 
        "btn_type1",
        "btn_type2",
        "btn_type3",
    }
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
        self:setTouchEnable(btn,true)
    end
end

function WorldBossRankPanel:selectBtn(btnName)
    self:resetBtnTexture()
    self:changeTexture(btnName,"images/ui_public1/b_biaoqian4.png")
end

function WorldBossRankPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_type1" then
        self:selectBtn("btn_type1")
        self:showType(1)
    elseif  target.touchName=="btn_type2"then
        self:selectBtn("btn_type2")
        self:showType(2)
    elseif  target.touchName=="btn_type3"then
        self:selectBtn("btn_type3")
        self:showType(3)
    end

end

return WorldBossRankPanel