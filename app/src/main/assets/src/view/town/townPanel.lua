local TownPanel=class("TownPanel",UILayer)
TowerPanelData = {};
TowerPanelData.winData = {};
TowerPanelData.guideIndex = -1;
local row_offsetW = 66+4;--同行偏移量
local row_offsetH = 42+4;
local col_offsetW = 66+4;--同列偏移量
local col_offsetH = -44-4;

local TOWER_TYPE_1 = 1;--起点
local TOWER_TYPE_2 = 2;--终点
local TOWER_TYPE_3 = 3;--普通格
local TOWER_TYPE_4 = 4;--障碍物
local TOWER_TYPE_5 = 5;--步数
local TOWER_TYPE_6 = 6;--怪物
local TOWER_TYPE_7 = 7;--宝箱
local TOWER_TYPE_8 = 8;--积分
local TOWER_TYPE_9 = 9;--道具
local TOWER_TYPE_10 = 10;--属性(类型_值)
local TOWER_TYPE_11 = 11;--当前积分翻倍
local TOWER_TYPE_12 = 12;--当前步数翻倍

--道具_itemid_数值
-- 9_42_10
--宝箱(类型_boxid_形象)
--形象为负数就会翻转
-- 7_2000_1
--终点翻转
-- 2_-1



local TOWER_TYPE_4_0 = 0;--空格
local TOWER_TYPE_4_1 = 1;--尖刺
local TOWER_TYPE_4_2 = 2;--终点左半边
local TOWER_TYPE_4_3 = 3;--终点右半边
--终点相关4_type type为负数就会翻转


local DIR_UP = 1;
local DIR_DOWN = 2;
local DIR_LEFT = 3;
local DIR_RIGHT = 4;

local gCloseNet = false;
local TAG_ON_NODE = 101;
local TAG_ALL_ATTR_ON_ROLENODE = 102;

local newType = {
    { floor=2,types={5} },
    { floor=3,types={10} },
    { floor=4,types={8} },
    { floor=8,types={12} },
    { floor=28,types={11} },
};

function TownPanel:ctor(isBackFromBattle)

    loadFlaXml("qp_effect");
    loadFlaXml("qp_effect2");
    loadFlaXml("ui_family_war");
    loadFlaXml("qp_bushuhaojin");
    self:init("ui/ui_town.map")
    self:addFullScreenTouchToClose();
    if(isBackFromBattle == nil)then
        isBackFromBattle = false;
    end
    self.isBackFromBattle = isBackFromBattle;
    self.curRow = 0;
    self.curCol = 0;
    self.maxRow = 5;
    self.maxCol = 5;
    self.passFlagNode = {};
    self.flaFlagIndex = 1;
    self.exitRow = 0;
    self.exitCol = 0;
    self.bOpenExit = false;
    self.resetPos = false;
    self.enterNextFloor = false;
    gCloseNet = false;
    -- Data.towerInfo.stage = 2;
    Data.towerInfo.floor = self:getCurFloor();
    self.towerTitleConfig = cc.FileUtils:getInstance():getValueMapFromFile("fightScript/towerTitleConfig.plist")
    -- self:judgeTeamFormation();
    -- self:initTestData();
    self:loadMapWithFloor(Data.towerInfo.floor);
    -- self:showTouchRect();
    Unlock.checkFirstEnter(SYS_TOWER);

end

function TownPanel:getCurFloor()
    return math.floor(Data.towerInfo.stage / 3) + 1;
end

function TownPanel:getMonsterId(index)
    local curFloor = self:getCurFloor();
    local stage = (curFloor-1)*3+index;
    local data = DB.getTowerData(stage);
    return data.mid1;
end

function TownPanel:getGuideItem(name)
    return self:getNode(name)
    -- return nil;
end

function TownPanel:onPopup()
    self.popUpAddAttr = false;
    self:refreshUI();

    -- if(self.isBackFromBattle)then
    --     self.isBackFromBattle = false;
    --     self:backFromBattle();
    -- end
    self:checkBackFromBattle();
end

function TownPanel:loadMapWithFloor(floor)
    if(self.myRoleBgNode)then
        self.myRoleBgNode:removeAllChildren();
    end
    self.role = nil;
    self:readConfig(floor);
    self:initPanel();
end
-- function TownPanel:hideCloseModule()
--     self:getNode("layer_vip"):setVisible(not Module.isClose(SWITCH_VIP));
--     self:getNode("rtf"):setVisible(not Module.isClose(SWITCH_VIP));
--     self:getNode("layer_bar"):setVisible(not Module.isClose(SWITCH_VIP));
-- end

function TownPanel:initTestData()
    Data.towerInfo.floor = 2;
    Data.towerInfo.curRow = 1;
    Data.towerInfo.curCol = 1;
    Data.towerInfo.action = 20;
    Data.towerInfo.actioned = {};
    Data.towerInfo.score = 25;
    Data.towerInfo.star = 1;
    Data.towerInfo.tstar = 4;
    Data.towerInfo.reset = 1;
    Data.towerInfo.isEnd = false;
    Data.towerInfo.disreward = {};
    Data.towerInfo.attr = {};
    table.insert(Data.towerInfo.attr,{attr=11,val=20});
    table.insert(Data.towerInfo.attr,{attr=18,val=30});
    table.insert(Data.towerInfo.attr,{attr=17,val=10});
    table.insert(Data.towerInfo.attr,{attr=13,val=5});
    table.insert(Data.towerInfo.attr,{attr=15,val=80});
    table.insert(Data.towerInfo.attr,{attr=16,val=70});
    Data.towerInfo.addattr = {};
    Data.towerInfo.attrnum = 2;
    Data.towerInfo.floormax = 3;

    local sortFunc = function(a,b)
        return toint(a.attr) < toint(b.attr);
    end
    table.sort(Data.towerInfo.attr,sortFunc);
end

function TownPanel:isMaxFloor()
    return Data.towerInfo.stage>=Data.towerInfo.maxFloor*3;
end

function TownPanel:readConfig(floor)
    self.curFloorConfig = DB.getTowerData(floor*3);
    -- self.curFloorConfig = data;
    local data = {};
    self.monsterNodes = {};
    self.powerPanels = {};
    self.exitRow = -1;
    self.exitCol = -1;
    if(data)then


        self.tower_data = {};
        data.content = "4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4_1;4_2;1;6_1;3;6_2;3;6_3;3;2;4;4;4;4;4;4;4_1;4_3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4";
        data.length = 8;
        data.width = 8;
        -- if(floor > Data.towerInfo.maxFloor)then
        --     data.content = "4;3;3;3;4 ;3;4;3;4;3 ;3;3;1;3;3 ;3;4;3;4;3 ;4;3;3;3;4"
        --     data.length = 5;
        --     data.width = 5;
        -- end
        local contents = string.split(data.content,";");
        local index = 0;
        local rowData = {};
        for key,var in pairs(contents) do
            local oneData = {};
            local types = string.split(var,"_");
            local count = #types;
            if(count > 2)then
                oneData.type = toint(types[1]);
                oneData.type2 = toint(types[2]);
                oneData.type3 = toint(types[3]);
            elseif(count > 1)then
                oneData.type = toint(types[1]);
                oneData.type2 = toint(types[2]);
                oneData.type3 = 0;
            else
                oneData.type = toint(var);
                oneData.type2 = 0;
                oneData.type3 = 0;
            end
            -- print("type = "..oneData.type);
            local row = math.floor(index / toint(data.length)) + 1;
            local col = index % toint(data.length) + 1;
            if(oneData.type == TOWER_TYPE_1)then
                self.startRow = row;
                self.startCol = col;
                self.curRow = row;
                self.curCol = col;
            elseif(oneData.type == TOWER_TYPE_2)then
                self.exitRow = row;
                self.exitCol = col;
            end
            oneData.row = row;
            oneData.col = col;
            oneData.isTriggered = self:isTriggered(row,col);
            data.isOpen = false;
            table.insert(rowData,oneData);
            if((index+1) % toint(data.length) == 0)then
                -- local copyRowData = clone(rowData);
                table.insert(self.tower_data,rowData);
                rowData = {};
            end

            index = index + 1;
        end
        -- print("##########");
        -- print_lua_table(data);
        self:createMap();
    end
end

function TownPanel:isTriggered(row,col)
    return false;
end

function TownPanel:isGameEnd()
    if(self:isMaxFloor())then
        return true, gGetWords("towerWords.plist","41")
    end

    if(Data.towerInfo.isEnd)then
        print("isEnd");
        return true, gGetWords("towerWords.plist","43")
    end
    return false
end

function TownPanel:initPanel()


    self:setTouchEnableGray("btn_sweep",true);
    local leftResetTimes = Data.towerInfo.maxResetTimesToday - Data.towerInfo.reset + Data.towerInfo.buyreset;
    self:getNode("btn_reset"):stopAllActions();
    self:getNode("btn_reset"):setRotation(0);
    self:getNode("btn_reset"):setScale(1);
    self.leftResetTimes = leftResetTimes;
    if(Data.towerInfo.stage<=0  and Data.towerInfo.isEnd==false )then
        self:setTouchEnable("btn_reset",false,true)
    else
        self:setTouchEnable("btn_reset",true,false)
    end

    if(leftResetTimes <= 0)then
        leftResetTimes = 0;
        self:setTouchEnableGray("btn_reset",false);
    end
    self:setLabelString("txt_reset_times",leftResetTimes);

    self:getNode("panel_max_floor"):setVisible(false)


    local isEnd,txt=self:isGameEnd()
    if(isEnd)then
        self:getNode("panel_max_floor"):setVisible(true)
        self:setLabelString("txt_max_floor",txt)
    end

    self:refreshUI();

end

function TownPanel:refreshAddedAttr()
    if(Data.towerInfo.attr==nil)then
        return
    end
    -- self:setLabelString("txt_addattr_times",Data.towerInfo.attrnum);
    local count = #Data.towerInfo.attr;
    self:getNode("bg_add_attr"):setVisible(count > 0);

    for key,attr in pairs(Data.towerInfo.attr) do
        for k,val in pairs(TowerAddAttrPanelData.attr) do
            if(val == attr.attr)then
                attr.sortid = toint(k);
                break;
            end
        end
    end
    local sortFunc = function(a,b)
        return toint(a.sortid) < toint(b.sortid);
    end
    table.sort(Data.towerInfo.attr,sortFunc);

    for i=1,6 do
        self:getNode("txt_addattr"..i):setVisible(false);
        if(i<=count)then
            self:getNode("txt_addattr"..i):setVisible(true);
            local var = Data.towerInfo.attr[i];
            self:replaceRtfString("txt_addattr"..i,gGetWords("cardAttrWords.plist","attr"..var.attr),var.val.."%")
        end
    end
    -- self:resetLayOut();
    self:resetAdaptNode();
end

function TownPanel:refreshUI()
    self:setLabelString("txt_floor",Data.towerInfo.floor);
    self:setLabelString("maxstar",Data.towerInfo.maxstar);
    self:setLabelString("curstar",Data.towerInfo.curstar);
    self:setLabelString("leftstar",Data.towerInfo.star);
    self:getNode("btn_reward"):setVisible(not self:isMaxFloor());
    self:refreshAddedAttr();
    self:refreshPushGift();
    self:resetLayOut();
end

function TownPanel:refreshPushGift()
    local hasGift = false;
    if(Data.towerInfo.disreward and Data.towerInfo.disreward.id and Data.towerInfo.disreward.id > 0)then
        hasGift = true;
    end

    self:getNode("btn_push"):setVisible(hasGift);
end

function TownPanel:refreshReset()
    local leftResetTimes = Data.towerInfo.maxResetTimesToday - Data.towerInfo.reset + Data.towerInfo.buyreset;
    if(Data.towerInfo.stage<=0  and Data.towerInfo.isEnd==false)then
        self:setTouchEnableGray("btn_reset",false)
    else
        self:setTouchEnableGray("btn_reset",true)
    end
    if(leftResetTimes <= 0)then
        leftResetTimes = 0;
        self:setTouchEnableGray("btn_reset",false);
    end
    self:setLabelString("txt_reset_times",leftResetTimes);
end


function TownPanel:checkBackFromBattle()
    self.popUpAddAttr = false;
    if(self.isBackFromBattle)then
        self.isBackFromBattle = false;
        self:backFromBattle();
    else
        if(  table.count(Data.towerInfo.addattr)~=0 and self:isMaxFloor()==false)then
            -- Panel.popUp(PANEL_TOWER_ADDATTR);
            self.popUpAddAttr = true;
            local function popUpCall()
                Panel.popUp(PANEL_TOWER_ADDATTR);
            end
            gCallFuncDelay(0.1,self,popUpCall);
        end

    end
end

function TownPanel:backFromBattle()


    if(Data.towerInfo.isEnd)then
        if(Data.towerInfo.disreward.id and Data.towerInfo.disreward.id > 0)then
            local popUpResult = function()
                self.touchEnable = true;
                Panel.popUpVisible(PANEL_TOWER_GIFT);
                if(self.leftResetTimes > 0)then
                    self:setTouchEnable("btn_reset",true,false);
                end
            end
            gCallFuncDelay(time,self,popUpResult);
            if(self.leftResetTimes > 0)then
                self:setTouchEnable("btn_reset",false,false);
            end
        end
    end
    if( Data.towerInfo.floorReward
        and Data.towerInfo.floorReward.items
        and  table.count(Data.towerInfo.floorReward.items)>0)then
        Panel.popUp(PANEL_TOWER_RESULT)
    end
end


function TownPanel:checkPopupGiftPanel()
    if(self.enterNextFloor == false)then
        return;
    end
    if(self:isMaxFloor())then
        if(Data.towerInfo.disreward.id and Data.towerInfo.disreward.id > 0)then
            Panel.popUpVisible(PANEL_TOWER_GIFT);
        end
    end
end

function TownPanel:initTestMap()
    self.monsterNodes = {};
    self.powerPanels = {};
    self.exitRow = -1;
    self.exitCol = -1;
    -- print_lua_table(self.towerTitleConfig);
    local tower_data = gReadCSVfile("fightScript/towerTestData.csv");
    -- self.tower_data = gReadCSVfile("fightScript/towerTestData.csv");
    self.tower_data = {};
    for m,mValue in pairs(tower_data) do
        local rowData = {};
        for n,nValue in pairs(mValue) do
            local data = {};
            local types = string.split(nValue,"_");
            local count = #types;
            if(count > 2)then
                data.type = toint(types[1]);
                data.type2 = toint(types[2]);
                data.type3 = toint(types[3]);
            elseif(count > 1)then
                data.type = toint(types[1]);
                data.type2 = toint(types[2]);
                data.type3 = 0;
            else
                data.type = toint(nValue);
                data.type2 = 0;
                data.type3 = 0;
            end
            data.isTriggered = false;
            data.isOpen = false;
            -- data.type = toint(nValue);
            table.insert(rowData,data);
            -- self.tower_data[m][n] = toint(nValue);

            if(data.type == TOWER_TYPE_1)then
                self.curRow = m;
                self.curCol = n;
            elseif(data.type == TOWER_TYPE_2)then
                self.exitRow = m;
                self.exitCol = n;     
            end
        end
        table.insert(self.tower_data,rowData);
    end
    -- print_lua_table(self.tower_data);
    -- self.allTowerData = cc.FileUtils:getInstance():getValueMapFromFile("fightScript/towerData.plist");
    -- -- print_lua_table(self.allTowerData);
    -- print("data = "..self.allTowerData["1"].data);
    -- self.tower_data = {}
    -- assert(loadstring("  data= "..self.allTowerData["1"].data))()
    -- -- loadstring(" data = "..self.allTowerData["1"].data)();
    -- print_lua_table(data);
    -- self.tower_data = data;
    -- self.tower_data={
    --     {1,2,3,1,1,7},
    --     {2,1,1,1,1,6},
    --     {3,1,1,1,0,5},
    --     {4,1,1,1,1,1},
    --     {1,1,1,1,1,1},
    -- }

    if(self.myRoleBgNode)then
        self.myRoleBgNode:removeAllChildren();
    end
    self.role = nil;
    self.bOpenExit = false;
end

function TownPanel:createMap()
    local rowCount = table.count(self.tower_data);
    local colCount = table.count(self.tower_data[1]);
    self.maxRow = rowCount;
    self.maxCol = colCount;
    self:getNode("layer_map"):removeAllChildren();
    self.myRoleBgNode = cc.Node:create();
    self:getNode("layer_map"):addChild(self.myRoleBgNode);
    local items = {};
    local node = nil;
    -- local startPos = cc.p(-(colCount*row_offsetW + rowCount*col_offsetW)/2,-(colCount*row_offsetH + rowCount*-col_offsetH)/2);
    local startPos = cc.p(-(colCount*row_offsetW + rowCount*col_offsetW)/2,0);
    -- print();
    local pos = cc.p(0,0);
    -- print_lua_table(startPos);
    for m,mValue in pairs(self.tower_data) do
        pos.x = startPos.x + m*col_offsetW;
        pos.y = startPos.y + m*col_offsetH;
        for n,nValue in pairs(mValue) do
            node = self:createTile(nValue);
            if(node)then
                node:setPosition(pos);
                self:getNode("layer_map"):addChild(node);
                table.insert(items,node);
                self.tower_data[m][n].node = node;
                if(m == self.exitRow and n == self.exitCol)then
                    self:addTouchNode(node,"exit");
                end
            end
            pos.x = pos.x + row_offsetW;
            pos.y = pos.y + row_offsetH;
        end
    end

    local sortFunc = function(a,b)
        if(a:getPositionY() > b:getPositionY())then
            return true;
        end
        return false;
    end
    table.sort(items,sortFunc);

    for key,node in pairs(items) do
        node:setLocalZOrder(toint(key)*5);
    end
    
    -- print_lua_table(self.tower_data);
    self.mapAppear = false;
    -- self:initRole();
    -- self:initMonsterDir();
    -- self:initPowerPanel();
    self:effectMapAppear();
    -- self:effectRoleAppear();
end

function TownPanel:createTile(tileData)
    -- print("type = "..type);
    local needRain = false;
    -- if(self.curFloorConfig.type == 1)then
    --     needRain = true;
    -- end
    local custom = "3";
    if(Data.towerInfo.floor <= 10)then
        custom = "3";
    elseif(Data.towerInfo.floor <= 20)then
        custom = "b3";
    elseif(Data.towerInfo.floor <= 30)then
        custom = "c3";
    else
        custom = "d3"  
    end
    if(math.random()>0.8)then
        custom = custom .. "_a.png";
    else
        custom = custom ..".png";    
    end

    local type = tileData.type;
    local type2 = tileData.type2;
    local bFlipX = false;
    if(type == TOWER_TYPE_4 and type2 == TOWER_TYPE_4_0)then
        return nil;
    end

    local node = nil;
    local imagePath = "images/ui_tower/"..type.."_"..type2..".png";
    local configKey = type.."_"..type2;
    if(type2 == 0)then
        imagePath = "images/ui_tower/"..type..".png";
        configKey = type;
    end
    if(type == TOWER_TYPE_1)then
        imagePath = "images/ui_tower/1.png";
    elseif(type == TOWER_TYPE_2)then
        imagePath = "images/ui_tower/1.png";
        configKey = 1;
        if(type2 < 0)then
            bFlipX = true;
        end
    elseif(type == TOWER_TYPE_3)then
        imagePath = "images/ui_tower/"..custom;
    elseif(type == TOWER_TYPE_4)then
        if(type2 == 0)then
            imagePath = "images/ui_tower/4.png";
        else
            imagePath = "images/ui_tower/"..type.."_"..math.abs(type2)..".png";
        end

        if(type2 < 0)then
            bFlipX = true;
            configKey = type.."_"..math.abs(type2);
        end
    -- elseif(type == TOWER_TYPE_5)then
        -- imagePath = "images/ui_tower/5.png";
    elseif(type == TOWER_TYPE_6)then
        --怪物
        local monster = DB.getTowerMonster(type2);
        if(monster)then
            imagePath = "images/ui_tower/f_npc_"..monster.quality..".png";
        else
            imagePath = "images/ui_tower/f_npc_1.png";
        end
        configKey = type;
    elseif(type == TOWER_TYPE_7)then
        imagePath = "images/ui_tower/"..custom;
    elseif(type == TOWER_TYPE_8)then
        imagePath = "images/ui_tower/"..custom;
    elseif(type == TOWER_TYPE_9)then
        imagePath = "images/ui_tower/"..custom;
        configKey = 3;
    else
        imagePath = "images/ui_tower/"..custom;
    end


    node = cc.Sprite:create(imagePath);
    if(node)then
        if(bFlipX)then
            node:setScaleX(-1);
        end
        node:setAnchorPoint(cc.p(0.5,0.66));
        for key,data in pairs(self.towerTitleConfig) do
            if key == tostring(configKey) then
                -- print("key = "..key);
                local anchor = string.split(data.anchor,",");
                node:setAnchorPoint(cc.p(tonum(anchor[1]),tonum(anchor[2])));
                break;
            end
        end
        
        if(needRain)then
            if(type ~= TOWER_TYPE_4)then
                if(math.random() < 0.5)then
                    local flaName = "qp_yushui_a";
                    if(self.flaFlagIndex % 3 == 0)then
                        flaName = "qp_yushui_a";
                    elseif(self.flaFlagIndex % 3 == 1)then
                        flaName = "qp_yushui_b";
                    elseif(self.flaFlagIndex % 3 == 2)then
                        flaName = "qp_yushui_c";
                    end
                    self.flaFlagIndex = self.flaFlagIndex + 1;
                    local fla = gCreateFla(flaName,1);
                    gAddChildByAnchorPos(node,fla,cc.p(0.5,0.5));
                end
            end
        end

        if(not tileData.isTriggered)then
            self:createNodeOnTile(node,tileData);
        end
    end

    return node;
end

function TownPanel:initMonsterUI(parentNode,startNum)
    local layer = UILayer.new();
    layer:init("ui/ui_town_monster.map");
    layer:ignoreAnchorPointForPosition(false);
    layer:setAnchorPoint(cc.p(0.5,-0.5));
    layer:setLocalZOrder(10);
    if(startNum and startNum > 0) then
        layer:getNode("star_parent"):setVisible(true);
        layer:getNode("fightflag"):setVisible(false);
        gAddChildByAnchorPos(parentNode,layer,cc.p(0.5,1.5));
        for i=1,3 do
            if(i>startNum)then
                layer:changeTexture("icon_star"..i,"images/ui_public1/star1-1.png");
            end
            -- layer:getNode("icon_star"..i):setVisible(i <= startNum);
        end
        layer:resetLayOut();
    else
        layer:getNode("star_parent"):setVisible(false);
        layer:getNode("fightflag"):setVisible(true);
        gAddChildByAnchorPos(parentNode,layer,cc.p(0.5,1.5));
    end
end

function TownPanel:getStageStar(index)
    if(index <= #Data.towerInfo.stagestar)then
        return Data.towerInfo.stagestar[index];
    end
    return 0;
end

function TownPanel:createNodeOnTile(tileNode,tileData)
    
    local type = tileData.type;
    local type2 = tileData.type2;
    local type3 = tileData.type3;

    if(tileNode == nil)then
        return;
    end

    local node = nil;
    local anchor = tileNode:getAnchorPoint();
    if(type == TOWER_TYPE_2)then
        --终点
        local flaName = ""
        if(self:isOpenExit())then
            flaName = "qp_zhongdianmen_c1";
        else
            flaName = "qp_zhongdianmen_a1";
        end
        node = gCreateFla(flaName,1);
        anchor = cc.p(0.5,0.5);
    elseif(type == TOWER_TYPE_6)then
        --怪物
        if(self.isMaxFloor()) then
            return;
        end
        local monsterId = self:getMonsterId(type2);
        -- print("monsterId = "..monsterId)
        local monster = DB.getTowerMonster(monsterId);
        if(monster)then
            -- local monsterCardId = monster.mid;
            local monster2 = DB.getMonsterById(monster.mid);
            if(monster2)then
                local monsterCardId = monster2.cardid;
                -- print("monsterCardId = "..monsterCardId);
                if(monsterCardId > 0 and not self:isMaxFloor())then
                    -- node = cc.Node:create();
                    -- gCreateRoleFla(monsterCardId,node,0.5);
                    anchor = cc.p(0.5,0.75);
                    -- table.insert(self.monsterNodes,{monsterNode = node,tileNode = tileNode,price = monster.price});
                    local stage = (Data.towerInfo.floor-1)*3+toint(type2);
                    local starNum = self:getStageStar(stage);
                    if(starNum > 0)then
                        node = cc.Sprite:create("images/ui_atlas/ui/ko.png");
                        self:initMonsterUI(tileNode,starNum);
                        anchor = cc.p(0.5,1);
                    elseif(stage == Data.towerInfo.stage+1)then
                        node = cc.Node:create();
                        gCreateRoleFla(monsterCardId,node,0.5);
                        self.vars["monster"] = tileNode;
                        self:addTouchNode(tileNode,"monster",0);
                        self:setNodeTouchRectOffsetWithNode(tileNode,0,50);
                        self:initMonsterUI(tileNode);
                    else
                        node = cc.Node:create();
                        gCreateRoleFla(monsterCardId,node,0.5);
                        DisplayUtil.setGray(node);
                    end

                    if(self:isMaxFloor()) then
                        node:setVisible(false);
                    end

                    -- if((Data.towerInfo.floor-1)*3+toint(type2) == Data.towerInfo.stage+1)then
                    --     self:addTouchNode(tileNode,"monster",0);
                    --     self:setNodeTouchRectOffsetWithNode(tileNode,0,50);
                    --     self:initMonsterUI(tileNode);
                    -- elseif((Data.towerInfo.floor-1)*3+toint(type2) > Data.towerInfo.stage+1)then
                    --     DisplayUtil.setGray(node);
                    -- else
                    --     self:initMonsterUI(tileNode,1);    
                    -- end

                end
            end
        end
    elseif(type == TOWER_TYPE_7)then
        --宝箱
        local boxtype = math.abs(type3);
        if(boxtype == 1)then
            node = gCreateFla("qp_box1_a",1);
            anchor = cc.p(0.5,0.85);
        elseif(boxtype == 2)then
            node = gCreateFla("qp_box2_a",1);
            anchor = cc.p(0.5,0.85);
        elseif(boxtype == 3)then
            node = gCreateFla("qp_box3_a",1);
            anchor = cc.p(0.5,0.5);
        end
        if(type3<0)then
            node:setScaleX(-node:getScaleX());
        end
        -- node = cc.Sprite:create("images/ui_tower/box"..type3..".png");
    elseif(type == TOWER_TYPE_8)then
        local flaName = "qp_icon_star";
        if(self.flaFlagIndex % 3 == 0)then
            flaName = "qp_icon_star";
        elseif(self.flaFlagIndex % 3 == 1)then
            flaName = "qp_icon_star_2";
        end
        self.flaFlagIndex = self.flaFlagIndex + 1;
        node = gCreateFla(flaName,1);
        local replaceSpritePath = "images/ui_tower/score.png";
        node:replaceBone({"icon"},replaceSpritePath);
    elseif(type == TOWER_TYPE_9)then
        -- node = gCreateFlaDelay(math.random()/5,"qp_icon",1);
        local flaName = "qp_icon";
        if(self.flaFlagIndex % 3 == 0)then
            flaName = "qp_icon";
        elseif(self.flaFlagIndex % 3 == 1)then
            flaName = "qp_icon1";
        elseif(self.flaFlagIndex % 3 == 2)then
            flaName = "qp_icon2";
        end
        self.flaFlagIndex = self.flaFlagIndex + 1;
        node = gCreateFla(flaName,1);
        local icon = cc.Node:create();
        Icon.setIcon(type2,icon);
        node:replaceBoneWithNode({"icon"},icon);
    elseif(type == TOWER_TYPE_5)then
        -- node = gCreateFlaDelay(math.random()/5,"qp_icon",1);
        local flaName = "qp_icon_qiu";
        -- local replaceSpritePath = "images/ui_tower/step"..type2..".png";
        node = gCreateFla(flaName,1);
        -- node:replaceBone({"icon"},replaceSpritePath);
        local replaceNode = cc.Sprite:create("images/ui_tower/step0.png");
        local num = gCreateWordLabelTTF(type2,gFont,20,cc.c3b(255,255,255));
        num:enableOutline(cc.c4b(0,0,0,255),20*0.1);
        gAddChildByAnchorPos(replaceNode,num,cc.p(0.85,0.85));
        node:replaceBoneWithNode({"icon"},replaceNode);
        -- node:setScale(0.7);
        anchor = cc.p(0.5,0.85);
    elseif(type == TOWER_TYPE_10)then
        local flaName = "qp_icon_qiu";
        node = gCreateFla(flaName,1);
        local replaceNode = cc.Sprite:create("images/ui_tower/dou.png");
        local num = gCreateWordLabelTTF((type2/100).."%",gFont,20,cc.c3b(255,255,255));
        num:enableOutline(cc.c4b(0,0,0,255),20*0.1);
        gAddChildByAnchorPos(replaceNode,num,cc.p(0.85,0.85));
        node:replaceBoneWithNode({"icon"},replaceNode);
        anchor = cc.p(0.5,0.85);
        -- node = cc.Sprite:create("images/ui_word/all.png");
        -- local labAllAttr = gCreateWordLabelTTF("+"..(type2/100).."%",gFont,20,cc.c3b(120,255,0));
        -- labAllAttr:enableOutline(cc.c4b(0,0,0,255),20*0.1);
        -- gAddChildByAnchorPos(node,labAllAttr,cc.p(0.5,0.25));
    elseif(type == TOWER_TYPE_11)then
        node = cc.Sprite:create("images/ui_tower/score2.png");
        anchor = cc.p(0.47,0.7);
    elseif(type == TOWER_TYPE_12)then
        node = cc.Sprite:create("images/ui_tower/shoes1.png");
        anchor = cc.p(0.47,0.7);
    end

    if(node)then
        node:setTag(TAG_ON_NODE);
        node:setLocalZOrder(1);
        gAddChildByAnchorPos(tileNode,node,anchor);
    end
end

--终点是否开启
function TownPanel:isOpenExit()
    return true;
end

function TownPanel:effectBtnReset()
    local leftResetTimes = Data.towerInfo.maxResetTimesToday - Data.towerInfo.reset;
    if(leftResetTimes > 0)then
        self:getNode("btn_reset"):runAction(cc.RepeatForever:create(
        -- cc.Repeat:create(
            cc.Sequence:create(
                cc.ScaleTo:create(0.1,1.1),
                cc.RotateTo:create(0.05,-5),
                -- cc.Spawn:create(cc.RotateTo:create(0.05,-5),cc.ScaleTo:create(0.05,1.1)),
                cc.RotateTo:create(0.1,5),
                cc.RotateTo:create(0.05,0),
                cc.RotateTo:create(0.05,-5),
                cc.RotateTo:create(0.1,5),
                cc.RotateTo:create(0.05,0),
                cc.ScaleTo:create(0.1,1.0),
                -- cc.Spawn:create(cc.RotateTo:create(0.05,0),cc.ScaleTo:create(0.05,1.0)),
                cc.DelayTime:create(1)
                )
        -- )
        ));
    end    
end

function TownPanel:effectMapAppear()

    local time = 0;
    local dis = 0;
    for row,rowData in pairs(self.tower_data) do
        for col,tileData in pairs(rowData) do
            if(tileData.node)then
                -- dis = cc.pGetDistance(cc.p(tileData.node:getPosition()),cc.p(self.myRoleBgNode:getPosition()));
                -- time = dis * 0.001;
                time = math.random()/2;
                -- time = 0.01*row*col;
                gSetCascadeOpacityEnabled(tileData.node,true);
                tileData.node:setOpacity(0);
                tileData.node:setPositionY(tileData.node:getPositionY() - 300);
                tileData.node:runAction(cc.Sequence:create(
                    cc.DelayTime:create(time),
                    cc.Spawn:create(
                        cc.FadeTo:create(0.5,255),
                        cc.EaseExponentialOut:create(cc.MoveBy:create(0.5,cc.p(0,300)))
                        -- cc.EaseSineInOut:create(cc.MoveBy:create(0.5,cc.p(0,300)))
                        )
                    ));

            end
        end
    end

    gCallFuncDelay(1.0,self,self.effectMapAppearCallback);

end

function TownPanel:effectMapAppearCallback()
    -- self:checkBackFromBattle();
    self:checkPopupGiftPanel();
    self.mapAppear = true;
end

function TownPanel:effectMapDisappear()

    local time = 0;
    local dis = 0;
    for row,rowData in pairs(self.tower_data) do
        for col,tileData in pairs(rowData) do
            if(tileData.node)then
                -- dis = cc.pGetDistance(cc.p(tileData.node:getPosition()),cc.p(self.myRoleBgNode:getPosition()));
                -- time = dis * 0.001;
                time = math.random()/2;
                -- time = 0.01*row*col;
                gSetCascadeOpacityEnabled(tileData.node,true);
                tileData.node:setOpacity(255);
                -- tileData.node:setPositionY(tileData.node:getPositionY() + 300);
                tileData.node:runAction(cc.Sequence:create(
                    cc.DelayTime:create(time),
                    cc.Spawn:create(
                        cc.EaseSineIn:create(cc.FadeTo:create(0.5,0)),
                        -- cc.EaseExponentialOut:create(cc.MoveBy:create(0.5,cc.p(0,-300)))
                        cc.EaseSineIn:create(cc.MoveBy:create(0.5,cc.p(0,-300)))
                        )
                    ));

            end
        end
    end

end

function TownPanel:effectMoveTree()

    local callback = function()
        Data.towerInfo.floor = self:getCurFloor();
        self:loadMapWithFloor(Data.towerInfo.floor);
    end

    self:getNode("layer_tree"):runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.EaseSineInOut:create(cc.MoveBy:create(1.0,cc.p(0,-386*1.5))),
            cc.MoveBy:create(0,cc.p(0,386*1.5)),
            cc.CallFunc:create(callback)
        ));
end

function TownPanel:evtNextFloor()
    self.enterNextFloor = true;
    -- Net.resetTowerInfoEnterNext();

    self:effectMoveTree();
    self:effectMapDisappear();
end

function TownPanel:events()
    return {
        EVENT_ID_TOWER_ACTION,
        EVENT_ID_TOWER_NEXT_FLOOR,
        EVENT_ID_TOWER_RESET,
        EVENT_ID_TOWER_FIGHT,
        EVENT_ID_TOWER_BUY_GIFT,
        EVENT_ID_TOWER_BUY_RESET
    }
end

function TownPanel:dealEvent(event,param)
    if(event==EVENT_ID_TOWER_ACTION)then
        -- self:evtWalk();
        self:evtTowerAction();
    elseif(event == EVENT_ID_TOWER_FIGHT) then
        self:evtWalk();
    elseif(event == EVENT_ID_TOWER_NEXT_FLOOR) then
        self:evtNextFloor();
    elseif(event == EVENT_ID_TOWER_RESET)then
        if(param)then
            self.enterNextFloor = true;
        end
        Data.towerInfo.floor = self:getCurFloor();
        self:loadMapWithFloor(Data.towerInfo.floor);
    elseif(event == EVENT_ID_TOWER_BUY_GIFT)then
        self:refreshPushGift();
    elseif(event == EVENT_ID_TOWER_BUY_RESET)then
        self:refreshReset();
    end
end

function TownPanel:onTouchEnded(target)

    if(self.popUpAddAttr)then
        return;
    end

    if  target.touchName=="btn_close"then
        if(Guide.isGuiding())then
            return;
        end
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_sweep" then
        if(Guide.isGuiding())then
            return;
        end
        if(self.isBackFromBattle or self.mapAppear == false)then
            return;
        end
        if(self:isMaxFloor())then
            gShowNotice(gGetWords("towerWords.plist","35"));
            return;
        end
        if(Data.towerInfo.isEnd)then
            gShowNotice(gGetWords("towerWords.plist","31"));
            return;
        end
        Net.sendTowerSweep();
    elseif target.touchName == "btn_sweep_one" then
        if(Guide.isGuiding())then
            return;
        end
        if(self.isBackFromBattle or self.mapAppear == false)then
            return;
        end
        if(self:isMaxFloor())then
            gShowNotice(gGetWords("towerWords.plist","35"));
            return;
        end
        if(Data.towerInfo.isEnd)then
            gShowNotice(gGetWords("towerWords.plist","31"));
            return;
        end
        local desStage = math.floor(math.floor(Data.towerInfo.maxstar * Data.towerInfo.sweepPercent/100)/3);
        -- local desFloor = math.floor((math.floor(Data.towerInfo.maxstar * Data.towerInfo.sweepPercent/100))/9);
        -- if(desStage <= Data.towerInfo.stage)then
        --     gShowNotice(gGetWords("towerWords.plist","46"));
        --     return;
        -- end
        local callback = function()
            Net.sendTowerSweep(true);
        end
        local desFloor = math.floor(desStage / 3) + 1;
        local stageIndex = desStage % 3 + 1;
        gConfirmCancel(gGetWords("towerWords.plist","45",Data.towerInfo.maxstar,desFloor,stageIndex),callback);
        
    elseif target.touchName == "btn_reset" then
        if(Guide.isGuiding())then
            return;
        end
        if(self.isBackFromBattle or self.mapAppear == false)then
            return;
        end
        local callback = function()
            Net.sendTowerReset();
        end
        gConfirmCancel(gGetWords("towerWords.plist","33"),callback);
    elseif target.touchName == "btn_exchange" then
        if(Guide.isGuiding())then
            return;
        end
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_TOWER1);
    elseif target.touchName == "btn_reward" then
        if(Guide.isGuiding())then
            return;
        end
        Panel.popUpVisible(PANEL_TOWER_REWARD,self.curFloorConfig.reward);        
    elseif target.touchName == "btn_rule" then
        if(Guide.isGuiding())then
            return;
        end
        gShowRulePanel(SYS_TOWER);
    elseif target.touchName == "btn_push" then
        if(Guide.isGuiding())then
            return;
        end
        Panel.popUpVisible(PANEL_TOWER_GIFT); 

    elseif target.touchName == "btn_rank" then
        if(Guide.isGuiding())then
            return;
        end
        Panel.popUp(PANEL_ARENA_RANK,RANK_TYPE_TOWER);
    elseif target.touchName == "btn_addattr" then
        if(Guide.isGuiding())then
            return;
        end
        if(Data.towerInfo.isEnd)then
            gShowNotice(gGetWords("towerWords.plist","30"));
            return;
        end
        if(self:isMaxFloor())then
            gShowNotice(gGetWords("towerWords.plist","34"));
            return;
        end
        Panel.popUpVisible(PANEL_TOWER_ADDATTR);
    elseif target.touchName == "monster" then
        local gameEnd,txt = self:isGameEnd()
        if(not gameEnd)then
            Panel.popUp(PANEL_TOWER_DIFF,Data.towerInfo.stage);        
        end
    elseif target.touchName == "btn_add_times" then
        Data.vip.townReset.setUsedTimes(Data.towerInfo.buyreset);
        local callback = function(num)
            Net.sendTownBuyReset(num)
        end
        Data.canBuyTimes(VIP_TOWN_RESET_TIMES,true,callback);
    end
end


return TownPanel