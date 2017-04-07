local FoodFightPanel=class("FoodFightPanel",UILayer)

function FoodFightPanel:ctor(data)
    self:init("ui/ui_duoliang_enter.map")

    self:changeTexture("icon_change_cost","images/ui_public1/gold.png")
    self.userlist = {}
    self.tmpLootBuyNum = 0
    self.isUnlock = nil -- 活动是否开启

    -- 显示掠夺次数、换一批
    self:showLootNumAndRef(false)

    for i = 1,4 do
        self:setUserInfo(i,nil)
    end

    Net.sendLootFoodGetInfo()
    
end

function FoodFightPanel:getLeftTime()
    -- 活动结束剩余时间 0:活动结束 >0:活动剩余时间

    local conEndWeekDay = gLootfoodEndDay
    local conEndHour = gLootfoodEndHour
    local conBeginWeedDay = gLootfoodBeginDay
    local conBeginHour = gLootfoodBeginHour
    if conEndWeekDay == 0 then
        conEndWeekDay = 7
    end

    if conBeginWeedDay == 0 then
        conBeginWeedDay = 7
    end

    local beginTime = gGetWeekOneTimeByCur(conBeginWeedDay,conBeginHour)
    local endTime = gGetWeekOneTimeByCur(conEndWeekDay,conEndHour)
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8();

    local leftTime = 0
    local nextBeginTime = 0
    if curTime >= beginTime and curTime<= endTime then
        leftTime = endTime - curTime
        
    else
        if curTime < beginTime then
            nextBeginTime = beginTime - curTime
        else
            nextBeginTime = beginTime - curTime + 7*24*3600
        end
    end

    return leftTime,nextBeginTime
end

function FoodFightPanel:onTouchBegan(target,touch)
    Panel.clearTouchTip();

    if(self.touch==false)then
        return
    end
    
    if self.curData == nil then
        return
    end
    if(target.touchName == "food_icon_touch")then
        self.beganPos = touch:getLocation()
        --Panel.popTouchTip(target,TIP_TOUCH_EQUIP_ITEM,95005) 
        local txt = gGetWords("lootFoodWords.plist","tip_txt_food_info",self.curData.food2,self.curData.food1)
        Panel.popTouchTip(target, TIP_TOUCH_DESC, txt)
        
    end
    
end

function FoodFightPanel:onTouchMoved(target,touch)
    if self.touch==false or  self.beganPos == nil then
        return
    end
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function FoodFightPanel:onTouchEnded(target)
    Panel.clearTouchTip();

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_help" then
        gShowRulePanel(SYS_LOOT_FOOD);
    elseif target.touchName=="btn_achi"then
        if self.curData == nil then
            return
        end
        Net.sendLootfoodAchirecinfo()
    elseif target.touchName=="btn_rank"then
        if self.curData == nil then
            return
        end
        Panel.popUp(PANEL_FOODFIGHT_RANK)
    elseif target.touchName=="btn_buy"then
        if self.curData == nil then
            return
        end
        Data.vip.lootfood.setUsedTimes(self.curData.lootbuy);
        local callback = function(num)
            Net.sendLootfoodBuyloot(num)
        end
        Data.canBuyTimes(VIP_LOOT_FOOD,true,callback);
        
    elseif target.touchName=="btn_record"then
        if self.curData == nil then
            return
        end
        local ret = {}
        --ret.revengenum = self.curData.revengenum
        ret.revengebuy = self.curData.revengebuy
        ret.food1 = self.curData.food1
        ret.food2 = self.curData.food2
        ret.isUnlock = self.isUnlock
        ret.isNeedSend = true
        Panel.popUp(PANEL_FOODFIGHT_RECORD,ret)
    elseif target.touchName == "btn_change"then
        if self.curData == nil then
            return
        end
        if not self.curData then
            return 
        end
        local needGold = self:getRefNeedGold()
        if needGold>0 and NetErr.isDiamondEnough(needGold)==false then
            return
        end

        Net.sendLootfoodRef()
        
    elseif string.find(target.touchName,"icon_group") then
        if self.curData == nil then
            return
        end
        local idx = string.find(target.touchName,"icon_group");
        idx = string.sub(target.touchName,idx+10);
        idx = toint(idx)
        if self.userlist[idx] ~= nil then
            local data = self.userlist[idx]
            if data.loot == 1 then
                gShowNotice(gGetWords("lootFoodWords.plist","loot_had_win"))
                return
            end
            Net.sendLootFoodUserInfo(data.uid,data.sid)
        end
        
    end

end

function  FoodFightPanel:events()
    return {
            EVENT_ID_LOOTFOOD_GETINFO,
            EVENT_ID_LOOTFOOD_REFRESH,
            EVENT_ID_LOOTFOOD_BUYLOOT,
            EVENT_ID_LOOTFOOD_REVENGE_BUY
        }
end



function FoodFightPanel:dealEvent(event,param)
    if(event==EVENT_ID_LOOTFOOD_GETINFO)then
        self:setData(param)
    elseif(event==EVENT_ID_LOOTFOOD_REFRESH)then
        self.curData.opplist = param.opplist
        self.curData.refnum = param.refnum
        self:refreshChangeNum()
        self:refreshUsers()
    elseif(event==EVENT_ID_LOOTFOOD_BUYLOOT)then
        self.curData.lootnum = param.lootnum
        self.curData.lootbuy = self.curData.lootbuy + param.lootaddbuy
        self:refreshBuyLoot()
    elseif(event==EVENT_ID_LOOTFOOD_REVENGE_BUY)then
        self.curData.revengebuy = self.curData.revengebuy+param
    end
end

function FoodFightPanel:showLootNumAndRef(bshow)
    -- 显示 可掠夺次数、换一批
    self:getNode("btn_buy"):getParent():setVisible(bshow)
    self:getNode("btn_change"):getParent():setVisible(bshow)
    self:getNode("lab_loss_food"):setVisible(bshow)
end

function FoodFightPanel:setData(data)
    self.curData = data
    -- 等级阶段
    self:replaceLabelString("lab_lv_ladder",data.lv1,data.lv2)

    if data.rank == 0 then
        local txt_no = gGetWords("trainWords.plist","no_family")
        self:setRTFString("lab_my_rank",gGetWords("lootFoodWords.plist","cur_rank",txt_no))
    else
        self:setRTFString("lab_my_rank",gGetWords("lootFoodWords.plist","cur_rank",data.rank))
    end
    
    --self:replaceLabelString("lab_lv_pre",data.rank)
    -- 我的粮草
    local myFood = data.food1 + data.food2
    self:setLabelString("lab_my_food",myFood)
    -- 掠夺损失粮草
    local lossFood = math.floor(gLootfoodLootRate*data.food2*0.01)
    self:setRTFString("lab_loss_food",gGetWords("lootFoodWords.plist","loss_food",lossFood))

    -- 刷新次数
    self:refreshChangeNum()

    -- 可夺粮次数:
    self:refreshBuyLoot()

    local function update()
        local leftTime,nextBeginTime = self:getLeftTime()
        local needtime = 0

        if leftTime > 0 then -- 活动结束时间
            self:setLabelString("lefttime_info",gGetWords("lootFoodWords.plist","activity_doing"))
            
            needtime = leftTime

            if self.isUnlock == nil then
                self.isUnlock = true
            elseif self.isUnlock == false then
                -- 未开启的活动，现在开启
                self.isUnlock = true
                Net.sendLootFoodGetInfo()
            end
        else --下次活动开启时间
            self:setLabelString("lefttime_info",gGetWords("lootFoodWords.plist","next_begin_time"))
            needtime = nextBeginTime

            if self.isUnlock == nil then
                self.isUnlock = false
            elseif self.isUnlock == true then
                --  进行中的活动，现在结束
                self.isUnlock = false
                self:showLootNumAndRef(false)
                for i = 1,4 do
                    self:setUserInfo(i,nil)
                end

                Net.sendLootFoodGetInfo()
            end
        end

        local days = math.floor(needtime/(24*3600))
        local daytime = needtime%(24*3600)
        if days > 0 then
            self:setLabelString("txt_left_day", gGetWords("serverBattleWords.plist","txt_lefttime_days",days))
        else
            self:setLabelString("txt_left_day", "")
        end
        self:setLabelString("txt_lefttime", gParserHourTime(daytime))
        self:getNode("layout_lefttime"):layout()
    end

    self:scheduleUpdate(update, 1)

    if self.isUnlock ~= nil then
        self:showLootNumAndRef(self.isUnlock)

        if self.isUnlock == false then
            self.curData.opplist = {}
        end
    end

    -- 用户列表
    self:refreshUsers()
end

function FoodFightPanel:refreshUsers()
    -- 用户列表
    local curCount = 0
    if self.curData and self.curData.opplist and table.getn(self.curData.opplist) > 0 then
        curCount = table.getn(self.curData.opplist)
    end
    for i = 1,4 do
        if i > curCount then
            self:setUserInfo(i,nil)
        else
            self:setUserInfo(i,self.curData.opplist[i])
        end
    end
end

function FoodFightPanel:refreshChangeNum()
    -- 刷新次数
    local bRefreshFree = true
    local needGold = self:getRefNeedGold()
    if needGold > 0 then
        -- 元宝刷新
        bRefreshFree = false
        self:setLabelString("txt_change_cost",needGold)
    else
        -- 免费刷新
        self:setLabelString("txt_free_value",gLootfoodRefNum-self.curData.refnum)
        self:getNode("layout_free"):layout()
    end

    self:getNode("layout_cost"):setVisible(bRefreshFree==false)
    self:getNode("layout_free"):setVisible(bRefreshFree)
    if isBanshuUser() and bRefreshFree==false then
        self:getNode("layout_cost"):getParent():setVisible(false);
        self:getNode("btn_change"):setVisible(false);
    end
end

function FoodFightPanel:refreshBuyLoot()
    -- 可夺粮次数:
    self:setLabelString("loot_food_num",self.curData.lootnum)
end

function FoodFightPanel:setUserInfo(idx,data)
    --[[ data:
    {
        -- uid 用户ID
        -- sid 服务器ID
        -- uname 用户名称
        -- icon 用户图标
        -- idetail obj 用户图标明细
            -- halo
            -- wlv
            -- wkn
            -- hlv
        -- sname 服务器名称
        -- price 战力
        -- status 状态:0-正常 1-同军团 2-仇人
        -- addfood 可得粮草
        -- loot 是否掠夺(0否 1是)
        -- lv
    }
    ]]
    --data = {}
    --data.addfood = 100
    --data.sname = "new role"
    --data.price = 389898
    --data.status = 2
    self.userlist[idx] = data
    local bShow = false
    if(data)then
        bShow = true
        self:setLabelString("win_get"..idx,data.addfood)
        self:setLabelString("txt_name"..idx,data.sname.."_"..data.uname)
        self:setLabelString("txt_power"..idx,data.price)
        local statusbg = self:getNode("status_bg"..idx)
        if data.status == 0 then
            statusbg:setVisible(false)
        else
            statusbg:setVisible(true)
            if data.status == 1 then
                self:changeTexture("status_bg"..idx,"images/ui_word/team_tuan.png")
            else
                self:changeTexture("status_bg"..idx,"images/ui_word/team_di.png")
            end
        end
        gCreateRoleFla(Data.convertToIcon(data.icon),self:getNode("role_bg"..idx),0.7,nil,nil,data.idetail.wlv,data.idetail.wkn);
    else
        self:getNode("role_bg"..idx):removeAllChildren()
    end

    self:getNode("win_get_bg"..idx):setVisible(bShow)
    self:getNode("role_bg"..idx):setVisible(bShow)
    self:getNode("userinfo_bg"..idx):setVisible(bShow)

    if bShow == false then
        self:getNode("win_flag"..idx):setVisible(bShow)
        self:getNode("status_bg"..idx):setVisible(bShow)
    else
        if data.loot == 1 then
            self:getNode("win_flag"..idx):setVisible(true)
            self:getNode("win_get_bg"..idx):setVisible(false)
        else
            self:getNode("win_flag"..idx):setVisible(false)
        end
    end
end

function FoodFightPanel:getRefNeedGold()
    if self.curData == nil then
        return 0
    end

    if self.curData.refnum+1 <= gLootfoodRefNum then
        return 0
    end

    for k,num in pairs(gLootfoodRefBuyNum) do
        if self.curData.refnum+1-gLootfoodRefNum <= num then
            return gLootfoodRefBuyPrice[k]
        end
    end

    local max = table.getn(gLootfoodRefBuyPrice)
    return gLootfoodRefBuyPrice[max]
end

function FoodFightPanel:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

return FoodFightPanel