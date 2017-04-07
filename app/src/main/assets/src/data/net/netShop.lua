
-- -------#####家族 杂货店详细 start
-- function Net.sendFamilyShopInfo()
--    local obj = MediaObj:create();
--    Net.sendExtensionMessage(obj, "family.shopinfo");
-- end

-- function Net.rec_family_shopinfo(evt)
--    local obj = evt.params:getObj("params");
--    local ret = obj:getByte("ret");
--    if ret == 0 then
--         local data = {};
--         data.type = SHOP_TYPE_FAMILY;
--         data.items = {};

--         local listobj = obj:getArray("elist");
--         local listcnt = listobj:count();
--         if(listobj) then
--             for i = 0, listcnt - 1 do
--               local robj = listobj:getObj(i);
--               robj = tolua.cast(robj, "MediaObj");
--               local item = {}; 
--               item.id = robj:getInt("id");  
--               item.itemid = robj:getInt("itemid");
--               item.num = robj:getInt("itemnum");
--               item.leftNum = robj:getInt("num");
--               item.lv = robj:getInt("lv");
--               item.costType = robj:getInt("etype");
--               item.price = robj:getInt("enum");
--               item.pos = robj:getByte("pos");--（1-5）
--               item.type = data.type;
--               table.insert(data.items,item);
--             end
--         end
--         data.time=gGetCurServerTime()+obj:getInt("time")
--         data.refreshTimes = obj:getInt("rnum")--今日手动刷新次数
--         gShops[data.type]=data;
--         gDispatchEvt(EVENT_ID_INIT_SHOP,data);

--    end
-- end
-- -------#####家族 杂货店详细 end

-- -------#####军团 杂货店兑换珍品 start
-- function Net.sendFamilyShopEx(pos)
--     local obj = MediaObj:create()
--     print("pos = "..pos[1]);
--     obj:setByte("pos",pos[1])
--     Net.sendExtensionMessage(obj,"family.shopex")
-- end
-- function Net.recFamilyShopEx(evt)
--     local obj = evt.params:getObj("params")
--     local ret = obj:getByte("ret")
--     if ret == 0 then
--         local pos = obj:getByte("pos")
--         local leftNum = obj:getInt("num")
--         local type = SHOP_TYPE_FAMILY;
--         if(gShops[type])then
--             for key, item in pairs(gShops[type].items) do
--                 if(item.pos==pos)then
--                     item.leftNum=leftNum;
--                     if item.leftNum <= 0 then
--                         item.num = 0;
--                     end
--                     break;
--                 end
--             end
--         end
--         local exp = obj:getInt("exp");
--         Data.updateCurFamilyExp(-exp);
--         Net.updateReward(obj:getObj("reward"),2);
--         gDispatchEvt(EVENT_ID_SHOP_REFRESH);
--     end
-- end
-- -------#####军团 杂货店兑换珍品 end

-- -------#####军团 杂货店珍宝刷新 start
-- function Net.sendFamilyShopRefresh()
--     local obj = MediaObj:create()
--     Net.sendExtensionMessage(obj,"family.shopre");
-- end
-- function Net.rec_family_shopre(evt)
--     local obj = evt.params:getObj("params")
--     local ret = obj:getByte("ret")
--     if ret == 0 then
--         Net.rec_family_shopinfo(evt);
--         local exp = obj:getInt("exp");
--         Data.updateCurFamilyExp(-exp);
--     end
-- end
-- -------#####军团 杂货店珍宝刷新 end

local function processRewardItems(items)
    for _,var in pairs(items) do
        if var.id == ID_SPIRIT_FRAGMENT then
            SpiritInfo.addFra(var.num)
        end
    end
end
--情义商店
function Net.sendShopEmotionInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "shop.emotion");   
end
function Net.rec_shop_emotion(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local items = {};
        local list=obj:getArray("list")
        if(list)then
            for i=0,list:count()-1 do
                local itemObj = list:getObj(i);
                itemObj = tolua.cast(itemObj,"MediaObj");
                local item = {};
                item.pos = itemObj:getInt("id");
                item.count = itemObj:getInt("count");
                -- item.count = 10;
                table.insert(items,item);
            end
            -- print(">>>>>>")
            -- print_lua_table(items);
            -- print("<<<<<<<")
            -- print_lua_table(gShops[SHOP_TYPE_EMOTION].items);
        end
        Data.emoney = obj:getInt("emoney");
        for key,item in pairs(gShops[SHOP_TYPE_EMOTION].items)do
            for index,var in pairs(items) do
                if(toint(item.pos) == var.pos)then
                    item.buyNum = var.count;
                    -- print("buyNum = "..item.buyNum);
                    -- if(item.buyNum >= item.limitNum)then
                    --     item.num = 0;
                    -- end
                end
            end
        end
        local data = gShops[SHOP_TYPE_EMOTION];
        gDispatchEvt(EVENT_ID_INIT_SHOP,data)
    end
    gDispatchEvt(EVENT_ID_USER_DATA_UPDATE)
end


--跨服商店
function Net.sendWorldWarInfo()
    local media=MediaObj:create()
    Net.sendExtensionMessage(media, "worwar.shopinfo");   
end

function Net.rec_worwar_shopinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local nextRefreshTime = obj:getInt("next");
        local items = {};
        local list=obj:getArray("list")
        if(list)then
            for i=0,list:count()-1 do
                local itemObj = list:getObj(i);
                itemObj = tolua.cast(itemObj,"MediaObj");
                local item = {};
                item.id = itemObj:getInt("id");
                item.num = itemObj:getInt("unum");
                table.insert(items,item);
            end
        end

        -- print_lua_table(items);

        gShops[SHOP_TYPE_SERVERBATTLE].time = nextRefreshTime;
        for key,item in pairs(gShops[SHOP_TYPE_SERVERBATTLE].items)do
            for index,var in pairs(items) do
                if(item.pos == var.id)then
                    item.buyNum = var.num;
                    -- -- print("item.buyNum = "..item.buyNum);
                    -- -- print("item.limitNum = "..item.limitNum);
                    if(item.buyNum >= item.limitNum)then
                        item.num = 0;
                    else
                        local shopItem = DB.getServerBattleShopItem(item.itemid)
                        if nil ~= shopItem then
                            item.num = shopItem.itemnum
                        end
                    end
                    break;
                end
            end
        end
        local data = gShops[SHOP_TYPE_SERVERBATTLE];
        -- gDispatchEvt(EVENT_ID_INIT_SHOP,data);
        if Panel.getOpenPanel(PANEL_SHOP) ~= nil then
            gDispatchEvt(EVENT_ID_INIT_SHOP,data)
        else
            Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_SERVERBATTLE,nil,true)
        end
    end     
end

function Net.sendWorldWarBuy(id)
    local media=MediaObj:create()
    media:setInt("id",id);
    -- print("sendWorldWarBuy id = "..id);
    Net.sendExtensionMessage(media, "worwar.shopbuy");  
end
function Net.rec_worwar_shopbuy(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),2);
        local itemid = obj:getInt("id");
        local num = obj:getInt("unum");
        for key,item in pairs(gShops[SHOP_TYPE_SERVERBATTLE].items)do
            if(item.pos == itemid)then
                item.buyNum = num;
                if(item.buyNum >= item.limitNum)then
                    item.num = 0;
                end
                break;
            end
        end

        gDispatchEvt(EVENT_ID_SHOP_REFRESH);
    end    
end

function Net.sendEmotionShopBuy(id)
    local media=MediaObj:create()
    media:setInt("id",id);
    ShopPanelData.sendId = toint(id);
    -- ShopPanelData.sendNum = num;
    Net.sendExtensionMessage(media, "shop.emobuy");  
end
function Net.rec_shop_emobuy(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        local rewardRet = Net.updateReward(obj:getObj("reward"),2);
        processRewardItems(rewardRet.items)
        local itemid = obj:getInt("id");
        local num = obj:getInt("count");
        -- print("--------itemid="..itemid)
        -- print("--------num="..num)
        for key,item in pairs(gShops[SHOP_TYPE_EMOTION].items)do
            if(toint(item.pos) == ShopPanelData.sendId)then
                -- item.buyNum = num;
                item.buyNum = item.buyNum+1;
--              无limitNum
--                if(item.buyNum >= item.limitNum)then
--                    item.num = 0;
--                end
                break;
            end
        end
        -- print_lua_table(gShops[SHOP_TYPE_EMOTION].items)
        gDispatchEvt(EVENT_ID_SHOP_REFRESH);
    end    
end

--灵兽商店购买
function Net.sendPetShopBuy(id,num)
    local media=MediaObj:create()
    media:setInt("id",id[1])
    media:setInt("num",num)
    ShopPanelData.sendId = id[1];
    ShopPanelData.sendNum = num;
    -- Net.sendBuyShopItemParam={ type=type,poses=poses}
    Net.sendExtensionMessage(media, "pet.shopbuy")     
end

function Net.rec_pet_shopbuy(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret")
    if ret == 0 then
        Net.updateReward(obj:getObj("reward"),2) 

        --更新限购值
        for key,item in pairs(gShops[SHOP_TYPE_PET].items)do
            if(item.pos == ShopPanelData.sendId)then
                item.buyNum = item.buyNum + ShopPanelData.sendNum;
                break;
            end
        end

        gDispatchEvt(EVENT_ID_SHOP_REFRESH);
    end    
end

--商店购买
function Net.sendBuyShopItem(type,poses,num)
    
    if type <= SHOP_TYPE_3 or type == SHOP_TYPE_SOUL or 
       type == SHOP_TYPE_CONSTELLATION then
        Net.sendBuyAll(type,poses)
    elseif type == SHOP_TYPE_PET then
        Net.sendPetShopBuy(poses,num);  
    elseif type == SHOP_TYPE_SERVERBATTLE then
        Net.sendWorldWarBuy(poses[1]);
    elseif type == SHOP_TYPE_TOWER1 then
        Net.sendTowerShopBuy(poses[1],num);     
    elseif type == SHOP_TYPE_EMOTION then
        Net.sendEmotionShopBuy(poses[1])
    elseif type == SHOP_TYPE_FAMILY_5 then
        Net.sendFamilyTreasureBuy(poses[1])
     elseif type == SHOP_TYPE_SNATCH then
        Net.sendActivitySnaBuy(poses[1],num)
    else
        local media=MediaObj:create()
        media:setByte("type",type)
        media:setByte("pos",poses[1])

        -- local vector_int_ = vector_int_:new_local() 
        -- for key, pos in pairs(poses) do
        --     vector_int_:push_back(pos)
        -- end
        -- media:setIntArray("poslist",vector_int_)

        Net.sendBuyShopItemParam={ type=type,poses=poses}
        Net.sendExtensionMessage(media, CMD_SHOP_BUY)
    end
end


function Net.recBuyShopItem(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    local type=obj:getByte("type")
    if(gShops[type])then
        for key, item in pairs(gShops[type].items) do
            for k,pos in pairs(Net.sendBuyShopItemParam.poses) do
                if(item.pos==pos)then
                    item.num=0
                end
            end
        end
    end

    -- if type == SHOP_TYPE_FAMILY then
    --     Data.updateCurFamilyExp(-ShopPanelData.buyPrice);
    -- end

    Net.updateReward(obj:getObj("reward"),2) 
    gDispatchEvt(EVENT_ID_SHOP_REFRESH);
    Net.sendBuyShopItemParam=nil
end

function Net.sendBuyAll(type,poses)
    local media=MediaObj:create()
    media:setByte("type",type)
    -- media:setByte("pos",poses[1])

    local vector_int_ = vector_int_:new_local() 
    for key, pos in pairs(poses) do
        vector_int_:push_back(pos)
    end
    media:setIntArray("poslist",vector_int_)

    Net.sendBuyShopItemParam={ type=type,poses=poses}
    Net.sendExtensionMessage(media, "shop.buyall");
end

function Net.rec_shop_buyall(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end


    local type=obj:getByte("type")
    if(gShops[type])then
        for key, item in pairs(gShops[type].items) do
            for k,pos in pairs(Net.sendBuyShopItemParam.poses) do
                if(item.pos==pos)then
                    item.num=0
                end
            end
        end
    end

    Net.updateReward(obj:getObj("reward"),2) 
    gDispatchEvt(EVENT_ID_SHOP_REFRESH);
    Net.sendBuyShopItemParam=nil
end

--商店刷新
function Net.sendRefreshShop(type)
    -- if type == SHOP_TYPE_FAMILY then
        -- Net.sendFamilyShopRefresh();
    -- else
        local media=MediaObj:create()
        media:setByte("type",type)
        ShopPanelData.shopType = type;
        Net.sendExtensionMessage(media, CMD_SHOP_REFRESH)
    -- end   
end


function Net.recRefreshShop(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    -- Net.parseUserInfo(obj:getObj("uvobj"))
    Net.updateReward(obj:getObj("reward"));

    -- if ShopPanelData.shopType == SHOP_TYPE_FAMILY then
    --     Data.updateCurFamilyExp(-ShopPanelData.refreshPrice);
    -- end

    Net.recInitShop(evt)
end

--商店信息
function Net.sendInitShop(type)

    if type == SHOP_TYPE_SERVERBATTLE then
        Net.sendWorldWarInfo();   
    else
        local media=MediaObj:create()
        media:setByte("type",type)
        print("Net.sendInitShop")
        Net.sendExtensionMessage(media, CMD_SHOP_INIT)
    end

end


function Net.recInitShop(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local ret={}
    ret.type=obj:getByte("type")
    ret.items={}
    local idArray=obj:getIntArray("ids")
    local colNum=5
    if(idArray)then
        for i=0, idArray:size()/colNum-1 do
            local item={}
            item.itemid=idArray[i*colNum]
            item.type=ret.type
            item.num=idArray[i*colNum+2]
            item.price=idArray[i*colNum+3]
            item.costType=idArray[i*colNum+4]
            item.pos=i
            table.insert(  ret.items,item)
        end
    end 
    ret.refreshTimes=obj:getInt("flush") 
    ret.time=gGetCurServerTime()+obj:getInt("time")
    gShops[ret.type]= ret
    gShops[ret.type].items = Data.shopSort(ret.items);
    gDispatchEvt(EVENT_ID_INIT_SHOP,ret)
    
end



--出售
function Net.sendSellItem(itemid,num)
    local media=MediaObj:create()
    media:setInt("itemid",itemid)
    media:setInt("num",num) 
    Net.sendExtensionMessage(media, CMD_ITEM_SELL)
end


function Net.recSellItem(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),2) 
    gDispatchEvt(EVENT_ID_UPDATE_REWORDS)
end




 

--解锁商店
function Net.sendShopUnlock(type)
    local media=MediaObj:create()
    ShopPanelData.unlockShopType = type;
    media:setByte("type",type) 
    Net.sendExtensionMessage(media, "shop.unlock");
end

function Net.rec_shop_unlock(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end 
    Net.parserVipBuy(obj:getObj("vipbn"))
    Net.updateReward(obj:getObj("reward")) 
    if ShopPanelData.unlockShopType == SHOP_TYPE_2 then
        Net.sendInitShop(SHOP_TYPE_2)
    elseif ShopPanelData.unlockShopType == SHOP_TYPE_3 then
        Net.sendInitShop(SHOP_TYPE_3)
    end
end


 
function Net.sendBuyItem(id,num)
    local media=MediaObj:create() 
    media:setInt("id",id) 
    media:setInt("num",num) 
    Net.sendExtensionMessage(media, "item.buyitem");
end

function Net.rec_item_buyitem(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end  
    Net.updateReward(obj:getObj("reward")) 
    Net.updateMmBuyList(obj)
    gDispatchEvt(EVENT_ID_ITEM_BUYED)
end

