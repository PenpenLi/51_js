local ArenaRankPanel=class("ArenaRankPanel",UILayer)

function ArenaRankPanel:ctor(type)
    self:init("ui/ui_arena_rank.map")
    self._panelTop = true;
    -- print("type="..type);
   
    self:getNode("scroll").eachLineNum=1 
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll").scrollBottomCallBack = function()
       self:onMoveDown();
    end
    self.iShowIndex = 0;
    self.iShowMax = 100;
    self.iShowSize = 10;
    self.ranks = nil;
    self.event = nil;

    self:getNode("scroll_menu"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_iSelectIndex = type;
    self.type = -1;
    self:initMenu();
    
    -- self:replaceLabelString("txt_rank",gUserInfo.arenarank)
 
    -- Net.sendArenaRank(1)
    self:hideCloseModule();
end

function ArenaRankPanel:hideCloseModule()
    self:getNode("btn_share"):setVisible(self:isShowShare() and not Module.isClose(SWITCH_SHARE));
end
-- RANK_TYPE_LEVEL    = 1 --等级排行
-- RANK_TYPE_ARENA    = 2 --竞技场排行
-- RANK_TYPE_PET      = 3 --灵兽排行
-- RANK_TYPE_FAMILY   = 4 --军团排行
-- RANK_TYPE_BOSS   = 5 --世界boss排行
-- RANK_TYPE_TOWER   = 6 --无尽之塔排行
-- RANK_TYPE_PETCAVE   = 6 --灵兽探险排行

function ArenaRankPanel:menuIsClose(menus,mode,type)
    if Module.isClose(mode) then
        for key, var in pairs(menus) do 
            if (var.type == type) then
                table.remove(menus,key)
                break
            end
        end
    end
end

function ArenaRankPanel:initMenu()
    self:getNode("scroll_menu"):clear()
    local menus={
{ type=RANK_TYPE_LEVEL , name=gGetWords("arenaWords.plist","name1") ,},
{ type=RANK_TYPE_ARENA , name=gGetWords("arenaWords.plist","name2") ,},
{ type=RANK_TYPE_PET , name=gGetWords("arenaWords.plist","name3") ,},
{ type=RANK_TYPE_FAMILY , name=gGetWords("arenaWords.plist","name4") ,},
{ type=RANK_TYPE_BOSS , name=gGetWords("arenaWords.plist","name5") ,},
{ type=RANK_TYPE_TOWER , name=gGetWords("arenaWords.plist","name6") ,},
{ type=RANK_TYPE_PETCAVE , name=gGetWords("arenaWords.plist","name7") ,},
}

-- if Module.isClose(SWITCH_WORLD_BOSS) then
--     for key, var in pairs(menus) do 
--         if (var.type == RANK_TYPE_BOSS) then
--             table.remove(menus,key)
--             break
--         end
--     end
-- end

self:menuIsClose(menus,SWITCH_WORLD_BOSS,RANK_TYPE_BOSS)
self:menuIsClose(menus,SWITCH_TOWER,RANK_TYPE_TOWER)



    for key, var in pairs(menus) do 
       local item=ArenaRankMenuItem.new()
       item:setData(var)
       item.onSelectCallback=function (data)
            self:setCurMenu(data)
       end
       self:getNode("scroll_menu"):addItem(item)
    end
    self:setCurMenu(self:getNode("scroll_menu").items[self.m_iSelectIndex].curData)
    self:getNode("scroll_menu"):layout()
    self:getNode("scroll_menu"):moveItemByIndex(self.m_iSelectIndex-1)
end

function ArenaRankPanel:setCurMenu(data)
    if (self.type == data.type) then 
        return;
    end
    -- print("menu index = "..data.type)
    for key, item in pairs(self:getNode("scroll_menu").items) do
        if(item.curData.type==data.type)then
           item:setSelect(true)
        else 
           item:setSelect(false)
        end
    end

    if (data.type == RANK_TYPE_LEVEL) then
        Net.sendRankLevel(0)
    elseif (data.type == RANK_TYPE_ARENA) then
        Net.sendArenaRank(1)
    elseif (data.type == RANK_TYPE_PET) then
        Net.sendRankPetstage(0)
    elseif (data.type == RANK_TYPE_FAMILY) then
        Net.sendRankFamily(0)
    elseif (data.type == RANK_TYPE_BOSS) then
        Net.sendRankWorldBoss()
    elseif (data.type == RANK_TYPE_TOWER) then
        Net.sendRankTower(0)
    elseif (data.type == RANK_TYPE_PETCAVE) then
        Net.sendRankCave(0)
    end
    self.type = data.type;

    if(not Module.isClose(SWITCH_SHARE))then
        self:getNode("btn_share"):setVisible(self:isShowShare());
    end    
end

function ArenaRankPanel:isShowShare()
    if(self.type == RANK_TYPE_LEVEL or self.type == RANK_TYPE_ARENA or self.type == RANK_TYPE_PET)then
        return true;
    end
    return false;
end

function  ArenaRankPanel:events()
    return {EVENT_ID_ARENA_RANK,EVENT_ID_RANK_PET,EVENT_ID_RANK_LEVEL,EVENT_ID_RANK_FAMILY,
    EVENT_ID_RANK_BOSS,EVENT_ID_RANK_FAMILY_CHECK,EVENT_ID_RANK_TOWER,EVENT_ID_RANK_CAVE}
end


function ArenaRankPanel:dealEvent(event,param)
    -- print("-----------------event="..event)
    if(event==EVENT_ID_ARENA_RANK or 
        event==EVENT_ID_RANK_PET or 
        event==EVENT_ID_RANK_LEVEL or 
        event==EVENT_ID_RANK_FAMILY or
        event==EVENT_ID_RANK_BOSS or 
        event==EVENT_ID_RANK_TOWER or
        event==EVENT_ID_RANK_CAVE)then
        self:initRankArena(param,event)
    elseif(event==EVENT_ID_RANK_FAMILY_CHECK)then
        Panel.popUpVisible(PANEL_FAMILY_OTHERFAMILYINFO,param);
    end
end


function ArenaRankPanel:initRankArena(data,event)
    self:getNode("scroll"):clear()
    
    local infoWord = "";
    local infoWord_pw = "";
    local infoWord_uf = gGetWords("arenaWords.plist","11");
    local rank = 0
    local pw = -1;
    self.shareData = {};
    if (event == EVENT_ID_ARENA_RANK) then
        infoWord = gGetWords("arenaWords.plist","13");
        self:getNode("txt_pw"):setVisible(false);
        rank = data.rank+1;
        table.sort(data.ranks,function(a,b) return a.rank<b.rank end) --从小到大排序
        self.shareData.rank = rank;
    elseif (event == EVENT_ID_RANK_LEVEL) then
        infoWord = gGetWords("arenaWords.plist","13-1");
        rank = data.rank;
        pw = data.level;
        infoWord_pw = gGetWords("arenaWords.plist","12-2",pw);
        self:getNode("txt_pw"):setVisible(true);
        self.shareData.level = pw;
    elseif (event == EVENT_ID_RANK_PET) then
        infoWord = gGetWords("arenaWords.plist","13-2");
        rank = data.rank;
        pw = data.stage;
        if (pw>0) then
            infoWord_pw = gGetWords("arenaWords.plist","12-3",pw);
        else
            infoWord_pw = gGetWords("arenaWords.plist","12-4");
        end
        self:getNode("txt_pw"):setVisible(true);
        self.shareData.rank = rank;
        self.shareData.floor = pw;
    elseif (event == EVENT_ID_RANK_FAMILY) then
        rank = data.rank;
        pw = data.exp;

        infoWord = gGetWords("arenaWords.plist","13-3");
        infoWord_uf = gGetWords("arenaWords.plist","11-1");
        self:getNode("txt_pw"):setVisible(true);
        if (pw>0) then
            infoWord_pw = gGetWords("arenaWords.plist","12-5",pw);
        else
            infoWord_pw = gGetWords("arenaWords.plist","12-6");
        end
    elseif (event == EVENT_ID_RANK_BOSS) then
        rank = data.rank;
        pw = data.price;
        infoWord = gGetWords("arenaWords.plist","13-4");
        self:getNode("txt_pw"):setVisible(true);
        if (pw>0) then
            infoWord_pw = gGetWords("arenaWords.plist","12-7",pw);
        else
            infoWord_pw = gGetWords("arenaWords.plist","12-8");
        end
    elseif (event == EVENT_ID_RANK_TOWER) then
        rank = data.rank;
        pw = data.star;
        infoWord = gGetWords("arenaWords.plist","13-5");
        self:getNode("txt_pw"):setVisible(true);
        if (pw>0) then
            infoWord_pw = gGetWords("arenaWords.plist","12-9",pw);
        else
            infoWord_pw = gGetWords("arenaWords.plist","12-9-1");
        end
    elseif (event == EVENT_ID_RANK_CAVE) then
        rank = data.rank;
        pw = data.price;
        infoWord = gGetWords("arenaWords.plist","13-6");
        self:getNode("txt_pw"):setVisible(true);
        if (pw>0) then
            infoWord_pw = gGetWords("arenaWords.plist","12-7",pw);
        else
            infoWord_pw = gGetWords("arenaWords.plist","12-8");
        end
    end
    self:setLabelString("txt_uf",infoWord_uf)
    self:setLabelString("txt_info",infoWord)

    if(rank<=0)then
        self:replaceLabelString("txt_rank",gGetWords("arenaWords.plist","lab_no"))
    else
        self:replaceLabelString("txt_rank",rank)
    end
    self:setLabelString("txt_pw",infoWord_pw)

    self.ranks = data.ranks;
    self.iShowMax = table.getn(self.ranks);
    self.iShowIndex = 0;
    self.event = event;
    self:onMoveDown();

    -- for key, var in pairs(data.ranks) do 
    --    local item=ArenaRankItem.new()
    --    item:setData(var,event,key)
    --    self:getNode("scroll"):addItem(item)
    -- end
    -- self:getNode("scroll"):layout()
end

function ArenaRankPanel:onMoveDown()
    -- print("self.iShowIndex="..self.iShowIndex)
    -- print("self.iShowMax="..self.iShowMax)
    -- print("self.iShowSize="..self.iShowSize)
    if (self.iShowIndex>=self.iShowMax) then
        return;
    end
    -- print("self.iShowIndex="..self.iShowIndex)
    for i=1+self.iShowIndex,self.iShowSize+self.iShowIndex do
        local key = i
        if (key<=table.getn(self.ranks)) then
            local var = self.ranks[key]
            local item=ArenaRankItem.new()
            item:setData(var,self.event,key)
            self:getNode("scroll"):addItem(item)
        end
    end
    self:getNode("scroll"):layout(self.iShowIndex==0)
    self.iShowIndex = self.iShowIndex + self.iShowSize;
    self.iShowIndex = math.min(self.iShowIndex,self.iShowMax)

    -- for key, var in pairs(data.ranks) do 
    --    local item=ArenaRankItem.new()
    --    item:setData(var,event,key)
    --    self:getNode("scroll"):addItem(item)
    -- end
    -- self:getNode("scroll"):layout()
end

function ArenaRankPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())  
    elseif target.touchName == "btn_share" then
        if (self.type == RANK_TYPE_LEVEL) then
            Panel.popUpVisible(PANEL_SHARE_LEVELUP,{formationType = TEAM_TYPE_ATLAS,shareType = SHARE_TYPE_LEVEL});  
        elseif (self.type == RANK_TYPE_ARENA) then
            Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ARENA_DEFEND,shareType = SHARE_TYPE_ARENA,shareData = self.shareData});  
        elseif (self.type == RANK_TYPE_PET) then
            Panel.popUpVisible(PANEL_SHARE_FORMATION,{formationType = TEAM_TYPE_ATLAS_PET_TOWER,shareType = SHARE_TYPE_PETTOWER,shareData = self.shareData});  
        elseif (self.type == RANK_TYPE_FAMILY) then
        elseif (self.type == RANK_TYPE_BOSS) then
        elseif (self.type == RANK_TYPE_PETCAVE) then  
            Panel.popUpVisible(PANEL_SHARE_LEVELUP,{formationType = TEAM_TYPE_CAVE,shareType = SHARE_TYPE_LEVEL});    
        end    
    end
end
 


return ArenaRankPanel