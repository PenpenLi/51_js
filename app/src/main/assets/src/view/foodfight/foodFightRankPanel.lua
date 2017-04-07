local FoodFightRankPanel=class("FoodFightRankPanel",UILayer)

function FoodFightRankPanel:ctor()
    self:init("ui/ui_duoliang_rank.map")

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

    self.scrolType = 0
    self.ranks = {}
    self.rewards = {}
    self:selectBtn("btn_type1")

    Net.sendLootfoodRank(Net.LootFoodRank.ver)
end

function FoodFightRankPanel:onMoveDown()
    if (self.iShowIndex>=self.iShowMax) then
        return;
    end

    local scrol = self:getNode("scroll_"..self.scrolType)
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

function FoodFightRankPanel:createRankItem(data)
    local layer = UILayer.new()
    layer:init("ui/ui_arena_rank_item.map")
    layer:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    layer:getNode("bg_vip"):setVisible(false)
    
    layer:setLabelString("txt_name",data.uname)
    layer:setLabelAtlas("txt_power",data.food) --粮草

    local rank = data.rank
    
    if (rank>3) then
        layer:setLabelAtlas("txt_rank",rank)
        layer:getNode("icon_rank"):setVisible(false)
        layer:getNode("rank_123"):setVisible(false)
    else
        layer:getNode("txt_rank"):setVisible(false)
        layer:changeTexture("icon_rank","images/ui_jingji/no."..rank..".png");
    end
    layer:replaceLabelString("txt_level",data.level)

    local fname = nil;
    if (data.fname ~= "") then
        fname = data.fname;
    else
        local sWord = gGetWords("arenaWords.plist","lab_no");
        fname = sWord;
    end

    layer:getNode("me"):setVisible(false)
    layer:setLabelAtlas("txt_vip",data.vip)
    Icon.setHeadIcon(layer:getNode("icon"), (data.icon))

    layer:replaceLabelString("txt_fname",fname)
      
    if (data.uid == Data.getCurUserId()) then
        layer:getNode("me"):setVisible(true)
    end

    return layer
end

function FoodFightRankPanel:createRewardItem(data)
    local layer = UILayer.new()
    layer:init("ui/ui_duoliang_jiangli_item.map")
    
    local list = cjson.decode(data.reward)
    if list == nil then
        return layer
    end

    for i=1,3 do
        if list[i]~= nil then
            local itemid = list[i].id
            local num = list[i].num
            Icon.setDropItem(layer:getNode("icon"..i),itemid,num)
        else
            layer:getNode("icon"..i):setVisible(false)
        end
    end

    if data.rank2-data.rank1 > 1 then
        -- @~@名
        layer:replaceLabelString("txt_info",data.rank1+1,data.rank2)
    else
        -- 第@名
        layer:setLabelString("txt_info",gGetWords("lootFoodWords.plist","rank_name",data.rank2))
    end
    

    return layer
end

function FoodFightRankPanel:showType(type)
    if self.scrolType == type then
        return
    end
    self.scrolType = type

    for i=1,2 do
        self:getNode("scroll_"..i):clear()
        self:getNode("scroll_"..i):getParent():setVisible(false)
    end

    local scrol = self:getNode("scroll_"..self.scrolType)
    scrol:getParent():setVisible(true)

    if type == 1 then
        self.iShowMax = table.getn(self.ranks);
    else
        if table.getn(self.rewards) == 0 then
            self.rewards = Net.getLootfoodRankRewardDb(Data.getCurLevel())
            local rank = 0
            for _,v in pairs(self.rewards) do
                v.rank1 = rank
                v.rank2 = v.rank
                rank = v.rank
            end
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

function FoodFightRankPanel:events()
    return {EVENT_ID_LOOTFOOD_RANK}
end

function FoodFightRankPanel:dealEvent(event,param)
    if(event==EVENT_ID_LOOTFOOD_RANK)then
        self.ranks = Net.LootFoodRank.list;
        self:showType(1)
        if param.rank == 0 then
            local txt_no = gGetWords("trainWords.plist","no_family")
            self:setLabelString("txt_rank",txt_no)
            self:setLabelString("txt_food",txt_no)
        else
            self:setLabelString("txt_rank",param.rank)
            self:setLabelString("txt_food",param.food)
        end
    end
end

function FoodFightRankPanel:resetBtnTexture()
    local btns={ 
        "btn_type1",
        "btn_type2",
    }
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
        self:setTouchEnable(btn,true)
    end
end

function FoodFightRankPanel:selectBtn(btnName)
    self:resetBtnTexture()
    self:changeTexture(btnName,"images/ui_public1/b_biaoqian4.png")
end

function FoodFightRankPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_type1" then
        self:selectBtn("btn_type1")
        self:showType(1)
    elseif  target.touchName=="btn_type2"then
        self:selectBtn("btn_type2")
        self:showType(2)
    end

end

return FoodFightRankPanel