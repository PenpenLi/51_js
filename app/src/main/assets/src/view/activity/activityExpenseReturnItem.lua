local ActivityExpenseReturnItem=class("ActivityExpenseReturnItem",UILayer)

function ActivityExpenseReturnItem:ctor(data)
    self:init("ui/ui_hd_tongyong_item.map")
    self.type = data;
    -- print("self.type="..self.type)
end

function ActivityExpenseReturnItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        if (self.curData.rec==true) then
            if (self.type == ACT_TYPE_2) then
                Net.sendActivityExpenseReturnGet(Data.activityExpenseReturnData.idx,self.curData.idx)
            else
                Net.sendActivityPayGet(Data.activityPayData.idx,self.curData.idx)
            end
        end
    elseif(target.touchName=="btn_go") then
        if (self.type == ACT_TYPE_3) then
            -- print("-----------")
            if not Panel.isOpenPanel(PANEL_PAY) then
                Panel.popUp(PANEL_PAY);
            end
            return;
        end
        local info1 = self.curData.items[1]
        --判断类型
        if (info1.itemid==ACT_CONSUME_TYPE_SWEEP_ELITE or info1.itemid==ACT_CONSUME_TYPE_STAGE_BUY) then--精英副本扫荡次数--购买副本战斗次数
            if (Unlock.isUnlock(SYS_ELITE_ATLAS)) then
               Panel.popUp(PANEL_ATLAS,{type=1})
            end
        elseif (info1.itemid==ACT_CONSUME_TYPE_ARENA_ALL) then--竞技场战斗次数
            if Unlock.isUnlock(SYS_ARENA) then
               gEnterArena()
            end
        elseif (info1.itemid==ACT_CONSUME_TYPE_CRUSADE) then--叛军战斗次数
            if Unlock.isUnlock(SYS_CRUSADE) then
                Net.sendCrusadeInfo()
            end
        elseif (info1.itemid==ACT_CONSUME_TYPE_DRAW_DIAMOND_TEN) then--元宝十连抽次数
            Panel.popUp(PANEL_DRAW_CARD)
        elseif (info1.itemid==ACT_CONSUME_TYPE_BUY_HP) then--购买体力次数
            Panel.popUp(PANEL_BUY_ENERGY,VIP_DIAMONDHP)
        elseif (info1.itemid==ACT_CONSUME_TYPE_TURNGOLD_NUM) then--点石成金次数
            Panel.popUp(PANEL_BUY_GOLD)
        elseif (info1.itemid==ACT_CONSUME_TYPE_SPIRIT_FIND or info1.itemid==ACT_CONSUME_TYPE_SPIRIT_CALL) then --寻仙次数
            if Unlock.isUnlock(SYS_XUNXIAN) then
                Net.sendSpiritInit(0)
            end
        elseif (info1.itemid==ACT_CONSUME_TYPE_MINING_FIGHT or info1.itemid==ACT_CONSUME_TYPE_MINING or
                info1.itemid==ACT_CONSUME_TYPE_MINING_1 or info1.itemid==ACT_CONSUME_TYPE_MINING_2 or
                info1.itemid==ACT_CONSUME_TYPE_MINING_3 or info1.itemid==ACT_CONSUME_TYPE_MINING_4 or
                info1.itemid==ACT_CONSUME_TYPE_MINING_5 ) then --寻仙次数
--             ACT_CONSUME_TYPE_MINING_FIGHT = 26--;// 累计挑战海底怪物
-- ACT_CONSUME_TYPE_MINING = 27--;// 累计挖矿次数
-- ACT_CONSUME_TYPE_MINING_1 = 28--;// 累计挖铜矿次数
-- ACT_CONSUME_TYPE_MINING_2 = 29--;// 累计挖铁矿次数
-- ACT_CONSUME_TYPE_MINING_3 = 30--;// 累计挖银矿次数
-- ACT_CONSUME_TYPE_MINING_4 = 31--;// 累计挖锡矿次数
-- ACT_CONSUME_TYPE_MINING_5 = 32--;// 累计挖金矿次数
            if Unlock.isUnlock(SYS_MINE) then
                gDigMine.processSendInitMsg()
            end
        end
    end
end

function   ActivityExpenseReturnItem:setData(key,data)
    self.curData=data

    local activityData = nil;
    if (self.type == ACT_TYPE_2) then
        activityData = Data.activityExpenseReturnData;
    else
        activityData = Data.activityPayData;
    end

    -- print_lua_table(data)

    if (data.items) then
        local info1 = data.items[1]
        -- print_lua_table(info1)
        local title = nil;
        -- print("info1.itemid = "..info1.itemid)
        if (self.type == ACT_TYPE_3) then
            title = gGetWords("activityNameWords.plist","title3_type",info1.num)
        else
            title = gGetWords("activityNameWords.plist","title2_type_"..info1.itemid,info1.num)
        end
        self:setLabelString("lab_title",title)
        -- print("类型="..info1.itemid..",已经完成几次="..activityData.var)

        self:setLabelString("lab_count",activityData.var.."/"..info1.num)

        local size = (#data.items)
        -- print("size = "..size)
        for i=1,5 do
            self:getNode("icon"..i):setVisible(false)
            if (size-1>=i) then
                self:getNode("icon"..i):setVisible(true)
                local info = data.items[i+1]
                -- print("info.num="..info.num)
                -- Icon.setDropItem(self:getNode("icon"..i),info.itemid,info.num)
                local node=DropItem.new() 
                node:setData(info.itemid)
                node:setNum(info.num)  
                node:setPositionY(node:getContentSize().height)
                gAddMapCenter(node, self:getNode("icon"..i)) 
            end
        end

        self:getNode("sign_get"):setVisible(false)
        if (activityData.var>=info1.num) then
            self:getNode("btn_get"):setVisible(true)
            self:getNode("btn_go"):setVisible(false)
            
            if (data.rec==false) then--已经领取
                self:getNode("btn_get"):setVisible(false)
                self:getNode("sign_get"):setVisible(true)
                -- self:setTouchEnable("btn_get",false,true)
                -- self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
            else
                -- self:setTouchEnable("btn_get",true,false)
                -- self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_get_reward")) 
            end
        else
            self:getNode("btn_get"):setVisible(false)
            self:getNode("btn_go"):setVisible(true)
            --btn_go_txt
            if (self.curData.type == ACT_TYPE_3) then
                self:setLabelString("btn_go_txt",gGetWords("btnWords.plist","btn_pay")) 
            else
                --判断类型
                if ((info1.itemid==ACT_CONSUME_TYPE_DIAMOND) or (info1.itemid==ACT_CONSUME_TYPE_ENERGY or (info1.itemid==ACT_CONSUME_TYPE_SIGN)) or (info1.itemid==ACT_CONSUME_TYPE_LOGIN)) then
                    self:getNode("sign_no"):setVisible(true)
                    self:getNode("btn_go"):setVisible(false)
                end
            end
        end

        self:getNode("item_lay"):layout()
    end
    
end

function   ActivityExpenseReturnItem:refreshData()
    self:setData(0,self.curData)
end


return ActivityExpenseReturnItem