AttChange={}

AttChange.preShowTime = 0;
AttChange.Data = {};
AttChange.preShowPowerTime = 0;
AttChange.power = {};
AttChange.bolDirty = false
AttChange.aniSpeed = 1;
--通用属性提醒
function AttChange.pushAtt(panelType,wordTab,appearType)
    -- appearType = 0 绑定某个node
    -- appearType = 1 屏幕居中
    -- AttChange.Data.panelType = panelType;
    -- AttChange.Data.appearType = appearType;
    -- AttChange.Data.word = wordTab;
    for key,var in pairs(wordTab) do
        table.insert(AttChange.Data,{panelType=panelType,word = var,appearType = appearType});
    end
    AttChange.bolDirty=true
end

function AttChange.pushAttBaoji(panelType,appearType,word,baojiTimes)
    table.insert(AttChange.Data,{panelType=panelType,word = word,appearType = appearType,baojiTimes = baojiTimes});
    AttChange.bolDirty = true;
end

function AttChange.pushPower(panelType,power_start,power_end)
    -- body
    table.insert(AttChange.power,{panelType=panelType,power_start = power_start,power_end = power_end});
    AttChange.bolDirty = true;
end

function AttChange.update()
    if(AttChange.bolDirty == false)then
        return;
    end
    --att
    local count = table.count(AttChange.Data);
    if count > 0 then
        local curTime = socket.gettime();
        -- print("curTime = "..curTime);
        local diffTime = curTime - AttChange.preShowTime;
        if diffTime >= 0.2/AttChange.aniSpeed then
            -- print("diffTime = "..diffTime);
            -- print_lua_table(AttChange.Data);
            -- AttChange.showAttChange(AttChange.Data.panelType,AttChange.Data.appearType,AttChange.Data.word);
            -- AttChange.preShowTime = curTime + (table.getn(AttChange.Data.word) - 1)*0.2;
            -- AttChange.Data = {};
            AttChange.preShowTime = curTime;
            local isInPanel = AttChange.showAttChange(AttChange.Data[1]);
            table.remove(AttChange.Data,1);
            if not isInPanel then
                AttChange.preShowTime = 0;
                AttChange.update();
            end
        end
    end

    -- --power
    -- AttChange.powerCount = table.getn(AttChange.power);
    -- if AttChange.powerCount > 0 then
    --     local curTime = os.time();
    --     local diffTime = curTime - AttChange.preShowPowerTime;
    --     if diffTime > 0 then
    --         local ret = AttChange.showPowerChange(AttChange.power[1]);
    --         if ret == false then
    --             AttChange.power = {};
    --         else
    --             table.remove(AttChange.power,1);
    --         end
    --         AttChange.preShowPowerTime = curTime;
    --     end
    -- end
    --power
    AttChange.powerCount = table.getn(AttChange.power);
    if AttChange.powerCount > 0 then
        local curTime = os.time();
        local diffTime = curTime - AttChange.preShowPowerTime;
        if true then-- diffTime >= 0 then
            local ret = AttChange.showPowerChange(AttChange.power[1]);
            if ret == false then
                AttChange.power = {};
            else
                table.remove(AttChange.power,1);
            end
            AttChange.preShowPowerTime = curTime;
        end
    end

    -- print("AttChange.update");
    if(count <= 0 and AttChange.powerCount <= 0)then
        AttChange.bolDirty = false;
    end
end

-- function AttChange.showPowerChange(data)

--     local panelType = data.panelType;
--     local power_start = data.power_start;
--     local power_end = data.power_end;
--    local panel=Panel.getPanelByType(panelType);
--     if panel == nil then
--         return false;
--     end

--     local pos = cc.p(panel.mapW/2,-panel.mapH/2);
-- local diffPower = power_end - power_start;

-- if diffPower <= 0 then
--     return;
-- end

--     if panelType == PANEL_CARD_INFO then
-- local node = panel:getNode("txt_power");
-- if node then
--     pos = gGetPositionByAnchorInDesNode(panel,node,cc.p(0.5,0.5));
--     pos.y = pos.y + 30;

--     local function callback()
--         panel:updateLabelChange("txt_power",power_start,power_end);
--     end
--     node:runAction(cc.Sequence:create(
--         -- 1.3/(AttChange.powerCount)
--                     cc.DelayTime:create(0.15),
--                     cc.CallFunc:create(callback)
--                     ));

-- end
--     elseif panelType == PANEL_PET then
--     end

--     local labWord = gCreateWordLabelTTF("+"..diffPower,gCustomFont,24,cc.c3b(0,255,0));
--     labWord:enableOutline(cc.c4b(50,90,0,255),24*0.1);
--     labWord:setScale(0);
--     -- labWord:setAnchorPoint(cc.p(1,0.5));
--     local time1 = 0.15;
--     local time2 = 0;
--     -- local time1 = 0.2/AttChange.powerCount;
--     -- local time2 = 1/AttChange.powerCount;
--     -- print("time1 = "..time1);
--     -- print("time2 = "..time2);
--     labWord:runAction(cc.Sequence:create(
--                         cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
--                         -- cc.DelayTime:create(time2),
--                         -- cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,100)),cc.ScaleTo:create(0.5,0.0),cc.FadeTo:create(0.5,0)),
--                         cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,100)),cc.FadeTo:create(0.5,0)),
--                         cc.RemoveSelf:create()
--                         ) );
--     labWord:setPosition(pos);
--     panel:addChild(labWord,100);

--     return true;
-- end

-- function AttChange.showAttChange(panelType,appearType,wordTab)
--     -- panelType = data.panelType;
--     -- word = data.word;
--     local panel=Panel.getPanelByType(panelType);
--     if panel == nil then
--         return;
--     end

--     local pos = cc.p(panel.mapW/2,-panel.mapH/2);

--     if appearType == nil or appearType == 0 then
--         if panelType == PANEL_CARD_INFO then
--             local node = panel:getNode("role_container");
--             if node then
--                 pos = gGetPositionInDesNode(panel,node);
--             end
--             pos.y = pos.y + 50;
--         elseif panelType == PANEL_PET then
--             local node = panel:getNode("role_container");
--             if node then
--                 pos = gGetPositionInDesNode(panel,node);
--             end
--         end
--     end

--     for key,var in pairs(wordTab) do
--         local labWord = gCreateWordLabelTTF(var,gCustomFont,24,cc.c3b(0,255,0));
--         labWord:enableOutline(cc.c4b(50,90,0,255),24*0.1);
--         labWord:setScale(0);
--         labWord:runAction(cc.Sequence:create(
--                             cc.DelayTime:create((key-1)*0.2),
--                             cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
--                             -- cc.DelayTime:create(0.5),
--                             cc.MoveBy:create(0.5,cc.p(0,100)),
--                             cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,100)),cc.FadeTo:create(0.5,0)),
--                             cc.RemoveSelf:create()
--                             ) );
--         labWord:setPosition(pos);
--         panel:addChild(labWord,100);
--     end
-- end

function AttChange.showPowerChange(data)
    local panelType = data.panelType;
    local power_start = data.power_start;
    local power_end = data.power_end;
    local panel=Panel.getPanelByType(panelType);
    if panel == nil then
        return;
    end

    local pos = cc.p(panel.mapW/2,-panel.mapH/2);
    local diffPower = power_end - power_start;

    if diffPower == 0 then
        return;
    end
    local diff="+"..diffPower
    local color=cc.c3b(0,255,0)
    -- if appearType == nil or appearType == 0 then
    if panelType == PANEL_CARD_INFO then

        
        local node = panel:getNode("txt_power");
        if node then
            panel = panel:getNode("layer_att_change");
            pos = gGetPositionByAnchorInDesNode(panel,node,cc.p(0.5,0.5));
            pos.y = pos.y + 20;
            local panelUILayer = Panel.getPanelByType(panelType);
            local function callback()
                panelUILayer:updateLabelChange("txt_power",power_start,power_end);
            end
            node:runAction(cc.Sequence:create(
                -- 1.3/(AttChange.powerCount)
                cc.DelayTime:create(0),
                cc.CallFunc:create(callback)
            ));

        end
    elseif panelType == PANEL_PET then
        if(diffPower<0)then
            return
        end
    elseif panelType == PANEL_CARD_WEAPON_RAISE then
        local node = panel:getNode("txt_power_level");
        if node then
            pos = gGetPositionByAnchorInDesNode(panel,node,cc.p(0.5,0.5));
            pos.y = pos.y + 20;
            local function callback()
            end
            node:runAction(cc.Sequence:create(
                cc.DelayTime:create(0),
                cc.CallFunc:create(callback)
            ));

        end
        color=cc.c3b(255,108,239)

    end
    -- end
    if(diffPower<0)then
        diff= diffPower
        color=cc.c3b(255,0,0)
    end
    -- for key,var in pairs(wordTab) do
    local labWord = gCreateWordLabelTTF(diff,gCustomFont,26,color);
    labWord:enableOutline(cc.c4b(50,90,0,255),24*0.1);
    labWord:setScale(0);
    labWord:runAction(cc.Sequence:create(
        -- cc.DelayTime:create((key-1)*0.2),
        cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
        -- cc.DelayTime:create(0.5),
        -- cc.MoveBy:create(0.5,cc.p(0,30)),
        cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(0,30)),cc.FadeTo:create(0.5,0)),
        cc.RemoveSelf:create()
    ) );
    labWord:setPosition(pos);
    panel:addChild(labWord,100);
-- end
end

function AttChange.showAttChange(data)

    -- print("start showAttChange ");
    -- print_lua_table(data);
    -- print("end showAttChange");
    panelType = data.panelType;
    word = data.word;
    local panel=nil
    if(panelType==PANEL_TREASURE)then
        panel=Panel.getPanelByType(PANEL_CARD_INFO);
        if(panel)then
            panel=panel.treasurePanel 
        end
    else
        panel=Panel.getPanelByType(panelType);
    end
    if panel == nil then
        return false;
    end

    local pos = cc.p(panel.mapW/2,-panel.mapH/2);

    if panelType == PANEL_CARD_INFO then
        local node = panel:getNode("layer_att_change");
        if node then
            -- pos = gGetPositionInDesNode(panel,node);
            panel = node;
            pos = cc.p(node:getContentSize().width/2,node:getContentSize().height/2);
        end
    elseif panelType == PANEL_PET then
        local node = panel:getNode("role_container");
        if node then
            pos = gGetPositionInDesNode(panel,node);
        end
    elseif panelType==PANEL_TREASURE then
        local node = panel:getNode("attr_panel");
        if node then
            pos = gGetPositionInDesNode(panel,node);
        end
    end

    local time = 0.5/AttChange.aniSpeed;
    local labWord 
    if(string.find(word,"-"))then
         labWord = gCreateWordLabelTTF(word,gCustomFont,26,cc.c3b(255,0,0));
    
    else
         labWord = gCreateWordLabelTTF(word,gCustomFont,26,cc.c3b(0,255,0));
    end
    
    if data.baojiTimes and data.baojiTimes > 1 then
        -- time = 0.25;
        local layout = gCreateBaojiWord(data.baojiTimes);
        -- local layout = LayOutLayer.new(LAYOUT_TYPE_HORIZONTAL,-10);

        -- local num = gCreateBattleWord("images/fonts/font_img/red_font/baoji.png");
        -- layout:addNode(num);
        -- num = gCreateBattleWord("images/fonts/font_img/red_num/x.png");
        -- layout:addNode(num);
        -- num = gCreateBattleWord("images/fonts/font_img/red_num/"..data.baojiTimes..".png");
        -- layout:addNode(num);
        -- -- layout:addImage("images/fonts/font_img/red_font/baoji.png");
        -- -- layout:addImage("images/fonts/font_img/red_num/x.png");
        -- -- layout:addImage("images/fonts/font_img/red_num/"..data.baojiTimes..".png");
        -- layout:layout();
        layout:setScale(0);
        layout:runAction(cc.Sequence:create(
            -- cc.DelayTime:create((key-1)*1.3),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
            -- cc.DelayTime:create(1),
            cc.MoveBy:create(time,cc.p(0,100)),
            cc.Spawn:create(cc.MoveBy:create(time,cc.p(0,100)),cc.FadeTo:create(time,0)),
            cc.RemoveSelf:create()
        ) );

        layout:setPosition(cc.p(pos.x,pos.y + labWord:getContentSize().height/2+layout:getContentSize().height/2 - 10));
        panel:addChild(layout,100);

    end

    labWord:enableOutline(cc.c4b(50,90,0,255),24*0.1);
    labWord:setScale(0);
    labWord:runAction(cc.Sequence:create(
        cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
        cc.MoveBy:create(time,cc.p(0,100)),
        cc.Spawn:create(cc.MoveBy:create(time,cc.p(0,100)),cc.FadeTo:create(time,0)),
        cc.RemoveSelf:create()
    ) );
    labWord:setPosition(pos);
    panel:addChild(labWord,100);

    return true;
end

