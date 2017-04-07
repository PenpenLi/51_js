local ActivityEnargyPanel=class("ActivityEnargyPanel",UILayer)

function ActivityEnargyPanel:ctor(data)
    self:init("ui/ui_hd_baozi.map")
    self.curData=data
    self.count = 0
    self.btnOpenEat = false--开吃
    self.eatTime = 0--剩余时间
    self.iStatusIndex = 0--状态索引
    self.onTouchEnded_time = 0--抬起时间
    self.onTouchBegan_time = 0--按下时间
    self.bolTouchBegan = false--是否在按下状态
    self.fla_baozi = {}--动画
    self.bolCountDown = false --是否倒计时
    self.bolOver = false--是否结束
    self.bolTry = false--是否试用
    self.bolTryTouch = false
    self.iEatActSataus = 0
    self.bolPause = false--是否暂停
    self.eatActSpeed = 1--吃包子速度
    self.count_speed = 0--吃速率

    self.click_num = {}
    local addNum = math.floor(Data.activity.bun_eat_click_max/3)
    for i=1,3 do
        table.insert(self.click_num,addNum*i)
    end

    Data.activityEatBun.click = 0
    
    Net.sendActivityEatBunInfo(data)

    -- loadFlaXml("eat")
    -- loadFlaXml("ui_huodong_chibaozi")

    -- local fla = self:createActBaoZi(1,1)
    -- local fla = self:createActBaoZi(1,2)
    -- local fla = self:createActBaoZi(1,3)

    -- Data.activity.bun_eat_click_max = 20

    self:getNode("layer_rset"):setVisible(true)
    -- self:getNode("layer_eat"):setVisible(false)

    self:setRTFString("lab_help",gGetWords("activityNameWords.plist","125_eat"))
    self:setLabelAtlas("num_time",Data.activity.bun_eat_time);
    self:setData()

    local function _update()
        self:update()
    end
    self:scheduleUpdate(_update,1)

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        elseif event == "exit" then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function ActivityEnargyPanel:onExit()
    self:unscheduleUpdateEx();
    gPlayMusic("bg/bgm_home.mp3")
end

function ActivityEnargyPanel:onEnter()
    self:getNode("reward_icon"):pause()
    -- self:getNode("layer_eat"):pause()
end

function ActivityEnargyPanel:reSetData()
    self:getNode("num_time"):setVisible(true)
    self:setLabelAtlas("num_time",Data.activity.bun_eat_time);
    -- self:getNode("reward_icon"):pause()
end

function ActivityEnargyPanel:overReSet(bolShow)
    self:setBtnTryName(1)
    -- if (not bolShow) then
    --     stopAllActions()
    --     self:getNode("touch_eat_word"):setOpacity(255)
    --     self:getNode("btn_try"):setOpacity(255)
    --     self:getNode("btn_start"):setOpacity(255)
    --     self:getNode("touch_eat_word"):setVisible(true)
    --     self:getNode("btn_try"):setVisible(true)
    --     self:getNode("btn_start"):setVisible(true)
    -- else
        self:show(self:getNode("touch_eat_word"))
        self:show(self:getNode("btn_try"))
        self:show(self:getNode("btn_start"))
    -- end

    self:setData()
end

function ActivityEnargyPanel:show_over_time()
    local node = self:getNode("layer_down_time")
    node:removeAllChildren()
    node:setVisible(true)

    -- self.bolCountDown = true
    --播放动画
    local function  playEnd()

        node:removeAllChildren()
        node:setVisible(false)

        if (self.bolTry) then
            node:setVisible(true)
            local fla=FlashAni.new()
            if (self.count>=Data.activity.bun_eat_click_max) then
                fla:playAction("ui_huodong_good")
                gPlayEffect("sound/effect/ui_timesus.mp3")
            else
                fla:playAction("ui_huodong_chibaozi_timeover")
                gPlayEffect("sound/effect/ui_timesup.mp3")
            end
            -- fla:stopAni()
            gAddCenter(fla,node)
            --加文字提示
            -- local word = "点击屏幕任意位置返回" --act_eat
            local sWord = gGetWords("activityNameWords.plist","act_eat5")
            local labWord = gCreateWordLabelTTF(sWord,gCustomFont,26,cc.c3b(0,255,0));
            labWord:enableOutline(cc.c4b(0,0,0,255),26*0.1);
            labWord:setPositionY(-80)
            fla:addChild(labWord)

            self.bolTryTouch = true
            self.bolOver = false
            self:getNode("btn_try"):setVisible(false)
            return
        else
            -- if (not self.bolTry) then--发送数据 正式才发
                Net.sendActivityEatBun(self.curData,self.count)
            -- end
        end

        self:overReSet(true)
    end

    local fla=FlashAni.new()

    if (self.count>=Data.activity.bun_eat_click_max) then
        fla:playAction("ui_huodong_good",playEnd)
        gPlayEffect("sound/effect/ui_timesus.mp3")
    else
        fla:playAction("ui_huodong_chibaozi_timeover",playEnd)
        gPlayEffect("sound/effect/ui_timesup.mp3")
    end
    gAddCenter(fla,node)

    gPlayMusic("bg/bgm_home.mp3")

end

function ActivityEnargyPanel:show(node)
    node:stopAllActions();
    -- node:setOpacityEnabled(true);
    node:runAction(cc.Sequence:create(cc.Show:create(),cc.FadeTo:create(0.3,255)));
end

function ActivityEnargyPanel:hide(node)
    node:stopAllActions();
    -- node:setOpacityEnabled(true);    
    node:runAction(cc.Sequence:create(cc.FadeTo:create(0.5,0),cc.Hide:create()));    
end

function ActivityEnargyPanel:timeOver()
    self:getNode("num_time"):setVisible(false)
    self.btnOpenEat = false
    --播放结束动画 时间到了
    self.bolOver = true
    self.eatActSpeed = 1

    self:rsetAct()
    -- self:getNode("layer_rset").curAction=""
    -- self:getNode("layer_rset"):resume()
    -- self:getNode("layer_rset"):playAction("rest")
    -- self:getNode("layer_rset"):setSpeedScale(self.eatActSpeed)
            
    self:show_over_time()
end

function ActivityEnargyPanel:update()
    -- if (self.onTouchEnded_time + 4 == gGetCurServerTime() and self.bolTouchBegan==false) then
    --     --停止动画
    -- end
    if (self.btnOpenEat and not self.bolPause and not self.bolCountDown) then
        --判读点击速度

        --时间倒计时
        local time = self.eatTime - gGetCurServerTime()
        if (time>0) then
            if (self:getNode("num_time"):isVisible()==false) then
                self:getNode("num_time"):setVisible(true)
            end
            self:setLabelAtlas("num_time",time);
        else
            self:timeOver()
        end
    elseif (self.bolOver) then
    end
end

function ActivityEnargyPanel:getAllCount()
    local count = self.count+Data.activityEatBun.click
    if (self.bolTry) then
        return self.count
    end
    return count
end

function ActivityEnargyPanel:setData()
    self:playBarIng()
    --宝箱是否打开
    local index = self:getStatus(self:getAllCount())--到哪个档次
    for i=1,3 do
        if (index>=i) then --打开
            self:getNode("box"..i):playAction("ui_atlas_box_3")
        else
            self:getNode("box"..i):playAction("ui_atlas_box_1")
        end
    end
    --包子状态
    -- self.iStatusIndex = self:getStatus_eff(self:getAllCount())
    self.iStatusIndex = self:getStatus_eff(self.count)
    -- print("self.iStatusIndex====="..self.iStatusIndex)
    self:createActBaoZi(self.iStatusIndex+1,1)
end

function ActivityEnargyPanel:getRewards(index)
    -- local rewards = {}
    -- if (index<=0) then
    --     table.insert({itemid=OPEN_BOX_ENERGY,itemnum=0})
    --     return rewards
    -- end
    -- for i=1,index do
    --     local rewards=DB.getBoxItemById(boxid)
    -- end
end

function ActivityEnargyPanel:showReward(index)
    if (self.bolTry) then
        --弹出对话框，提示试玩无奖励
        -- local sWord = "试玩无奖励"
        local sWord = gGetWords("activityNameWords.plist","act_eat4")
        local function onOk()
        end
        gConfirm(sWord,onOk)
        return
    end
    
    Panel.popUpVisible(PANEL_GET_REWARD,Data.activityEatBun.shows)

    -- print("index==="..index)
    -- if (index>0) then
        -- local boxid = Data.activity.bun_box_id[index]
        -- local boxid = Data.activity.bun_box_id[1]
        -- Panel.popUpVisible(PANEL_ACTIVITY_EAT_ENARGY,{rewards=getRewards(index),index=index,status=0},nil,true)
    -- else
        --空
    -- end
end

function ActivityEnargyPanel:openBox(index)
    if (index<=0) then return end
    local status = 0
    local boxid = Data.activity.bun_box_id[index]
    local idx = self:getStatus(self:getAllCount()) -- 0123
    if (index<=idx) then
        status = 2
    end
    Panel.popUpVisible(PANEL_ACTIVITY_EAT_ENARGY,{boxid=boxid,index=index,status=status},nil,true)
end

function ActivityEnargyPanel:openReward(index)
    self:showReward(index)
end

function ActivityEnargyPanel:dealEvent(event,param)
	-- print("event================"..event)
    if(event==EVENT_ID_GET_ACTIVITY_EAT_BUN)then
        -- print("吃到了 吃到了")
        --隐藏时间到了
        --弹出框
        self.bolOver = false
        local index = self:getStatus(Data.activityEatBun.click)--到哪个档次
        self:openReward(index)
        --设置吃过
        self:eatEnargy()
        -- print("end  吃到了 吃到了")
    elseif(event==EVENT_ID_GET_ACTIVITY_EAT_BUN_INFO) then
        --开始
        -- print("---开始----")
        -- Data.activityEatBun.click = 80
        self:setData()
    elseif(event==EVENT_ID_GET_ACTIVITY_EAT_BUN_STATUS) then
        if (Data.activityEatBun.status==0) then
            self.bolTry = false
            self:startGame()
        else
            if (Data.activityEatBun.status==1 or Data.activityEatBun.status==2 or Data.activityEatBun.status==3) then
                local taskTime = Data.task.getEnergyTime[Data.activityEatBun.status]
                local sWord = gGetWords("activityNameWords.plist","act_eat2",taskTime.time[1],taskTime.time[2]);
                gShowNotice(sWord)
            elseif (Data.activityEatBun.status==4) then
                local sWord = gGetWords("activityNameWords.plist","act_eat6");
                gShowNotice(sWord)
            elseif (Data.activityEatBun.status==5) then
                local sWord = gGetWords("activityNameWords.plist","act_eat7");
                gShowNotice(sWord)
            end
        end
    end
end

function ActivityEnargyPanel:playCountDownAction()
    local node = self:getNode("layer_down_time")
    node:removeAllChildren()
    node:setVisible(true)

    self.bolCountDown = true
    --播放动画
    local function  playEnd()
        node:removeAllChildren()
        node:setVisible(false)
        self.bolCountDown = false

        if (self.bolPause==false) then
            self.btnOpenEat = true
            self.eatTime = Data.activity.bun_eat_time + gGetCurServerTime()

            --文字消失
            self:hide(self:getNode("touch_eat_word"))
            -- self:show(self:getNode("btn_try"))
            -- self:setBtnTryName(2)
        else
            self.bolPause = false
            self.eatTime = self.pauseTime + gGetCurServerTime()
            -- self:setBtnTryName(2)
        end
        self:show(self:getNode("btn_try"))
        self:setBtnTryName(2)
    end

    self:hide(self:getNode("btn_try"))
    self:hide(self:getNode("btn_start"))

    local fla=FlashAni.new()
    fla:playAction("ui_huodong_baozi_time",playEnd)
    gAddCenter(fla,node)
    gPlayMusic("bg/bgm_chibaozi.mp3")
end

 
function ActivityEnargyPanel:startGame()
    self.bolPause = false
    self.count = 0
    self.iEatActSataus = 0
    self.eatActSpeed = 1
    self:setData()
    self:playBarIng()
    self:playCountDownAction()--倒计时321
end

function ActivityEnargyPanel:getStatus(count)
    local index = 0
    for i=1,3 do
        if (count >= Data.activity.bun_box_click_num[i]) then
            --播放动画
            index = i
            -- break
        end
    end
    return index
end

function ActivityEnargyPanel:getStatus_eff(count)
    local index = 0
    for i=1,3 do
            if (count >= math.floor(self.click_num[i]-10)) then
        -- if (count >= math.floor(Data.activity.bun_box_click_num[i]-10)) then
            --播放动画
            index = i
        end
    end
    return index
end

function ActivityEnargyPanel:setBtnTryName(type)
    local sWord = nil
    if (type == 1) then
        sWord = gGetWords("activityNameWords.plist","72")
    elseif (type == 2) then
        sWord = gGetWords("activityNameWords.plist","72-1")
    elseif (type == 3) then
        sWord = gGetWords("activityNameWords.plist","72-2")
    end
    if (sWord == nil) then
        return
    end

    self:getNode("btn_try_lab"):setString(sWord)
end

function ActivityEnargyPanel:onTouchEnded(target)
    if (self.bolCountDown) then return end
    if (self.bolOver) then return end
    -- print("count="..self.count)
    -- if (target.touchName=="btn_touch") then

    if (self.bolTryTouch) then
        if target.touchName=="btn_touch" then
            self.bolTryTouch = false
            local node = self:getNode("layer_down_time")
            node:removeAllChildren()
            node:setVisible(false)
            self.bolTry = false
            self.count = 0
            self:overReSet(false)
        end
        return
    end

    -- end
    --计算时间 超过几秒结束动画
    if (self.btnOpenEat) then
        -- self.onTouchEnded_time = gGetCurServerTime()
        self.bolTouchBegan = false

        if target.touchName=="btn_try" then
            if (self.bolPause==false) then
                self.bolPause = true
                self:setBtnTryName(3)--继续
                self.pauseTime = self.eatTime - gGetCurServerTime()
            else
                --继续
                -- self:setBtnTryName(true)
                self:playCountDownAction()
            end
        end

        return
    end

    if  target.touchName=="btn_start" then
        if Unlock.isUnlock(SYS_TASK) then
            if(NetErr.isEnergyFull()) then
                return;
            end

            --发送数据
            Net.sendActivityEatBunStatus()
            
            --判断是否能吃
            -- local hasGet = false
            -- local curServerTime = gGetCurServerTime();
            -- local curHour = gGetHourByTime(curServerTime)
            -- local hasGetTime = false--是否是时间点 提示用
            -- local index = 1--第几阶段 提示用
            
            -- for key,var in pairs(Data.task.getEnergyTime) do
            --     -- print("curHour=="..curHour..",time["..key.."]="..toint(var.time[1]))
            --     if (curHour >= toint(var.time[1]) and curHour < toint(var.time[2])) then
            --     --     hasGet = var.hasGet
            --         hasGetTime = true
            --     end
            --     if (curHour >= toint(var.time[1])) then
            --         index = key
            --     end
            -- end

            -- if (index==1) then
            --     hasGet = Data.activityEatBun.eat1
            -- elseif (index==2) then
            --     hasGet = Data.activityEatBun.eat2
            -- elseif (index==3) then
            --     hasGet = Data.activityEatBun.eat3
            -- end

            -- -- print("-----------index="..index)

            -- if (not hasGet and hasGetTime) then--还没吃过
            --     self.bolTry = false
            --     self:startGame()
            -- else

            --     local taskTime = Data.task.getEnergyTime[index]
            --     local taskTime1 = Data.task.getEnergyTime[1]
            --     -- print_lua_table(taskTime1)
            --     if (curHour>=toint(taskTime1.time[1])) then
            --         if (index<3) then
            --             taskTime = Data.task.getEnergyTime[index+1]
            --         else
            --             taskTime = Data.task.getEnergyTime[1]
            --         end
            --     end
            --     if (hasGetTime and hasGet) then--已经吃过
            --         -- print("index="..index)
            --         -- local sWord = "已撸过了，请在@：00~@:00时间点内，再来撸吧！"
            --         --判断时间 提示不一样
            --         local sWord = nil
            --         if (index<3) then
            --             sWord = gGetWords("activityNameWords.plist","act_eat1",taskTime.time[1],taskTime.time[2]);
            --         else
            --             --判断明天是否还有活动
            --             print_lua_table(self.curData)
            --             if (self.curData.endtime) then
            --                 -- local time = 1
            --                 local leftDay = gGetDayByLeftTime(self.curData.endtime - gGetCurServerTime());
            --                 if (leftDay>0) then--明天有活动
            --                     sWord = gGetWords("activityNameWords.plist","act_eat6");
            --                 else
            --                     --活动结束
            --                     sWord = gGetWords("activityNameWords.plist","act_eat7");
            --                 end
            --             else
            --                 sWord = gGetWords("activityNameWords.plist","act_eat7");
            --             end
            --         end
            --         gShowNotice(sWord)
            --     else--还没到点
            --         -- local sWord = "活动在@：00~@:00内开始"
            --         local sWord = gGetWords("activityNameWords.plist","act_eat2",taskTime.time[1],taskTime.time[2]);
            --         gShowNotice(sWord)
            --     end
            -- end
        end
    elseif target.touchName=="btn_try" then
        self.bolTry = true
        self:startGame()
    elseif target.touchName=="box1" then
        self:openBox(1)
    elseif target.touchName=="box2" then
        self:openBox(2)
    elseif target.touchName=="box3" then
        self:openBox(3)
    elseif target.touchName=="btn_touch" then
        --提示几点按钮吃
        -- local sWord = "先点击“开始”或“试玩”按钮，才开始游戏！"
        local sWord = gGetWords("activityNameWords.plist","act_eat3")
        gShowNotice(sWord)
    end
end

function ActivityEnargyPanel:onTouchBegan(target)
    if (self.bolCountDown) then return end
    if (self.bolOver) then return end
    if (self.bolTryTouch) then return end
    if (self.bolPause) then return end
    -- body

    -- self:playBaoziAct()
    -- and self.btnOpenEat
    if (target.touchName=="btn_touch" and self.btnOpenEat) then--区域里面
        self.count = self.count + 1
        self.bolTouchBegan = true
        local dec = os.clock()-self.onTouchBegan_time
        -- print(dec)
        if (dec<0.06) then
            self.eatActSpeed = self.eatActSpeed + (0.1-dec)
            self.eatActSpeed = math.min(self.eatActSpeed,2.5)
        elseif (dec>=0.06 and dec<=1) then
            self.eatActSpeed = self.eatActSpeed - 0.1
            self.eatActSpeed = math.max(self.eatActSpeed,1)
        elseif (dec>1 and dec<=2) then
            self.eatActSpeed = self.eatActSpeed - 0.2
            self.eatActSpeed = math.max(self.eatActSpeed,1)
        elseif (dec>2) then
            self.eatActSpeed = 1
        end
        self.onTouchBegan_time = os.clock()

        local tmp_count = self.count--self:getAllCount()

        for i=1,3 do
            if (self:getAllCount() == Data.activity.bun_box_click_num[i]) then
                --播放箱子打开效果
                self:getNode("box"..i).curAction=""
                self:getNode("box"..i):resume()
                self:getNode("box"..i):playAction("ui_atlas_box_4",nil,nil,0)
            end
            if (tmp_count == self.click_num[i]) then
                self.iStatusIndex = i
            elseif (tmp_count == math.floor(self.click_num[i]-10)) then
                --播放包子效果
                self:createActBaoZi(self.iStatusIndex+1,2)
            end
        end
        -- print("-----="..self.count)
        
        --动画
        self:playRoleAct()
        --飘起包子
        self:playBaoziAct()
        --设置精度条
        self:playBarIng()

        --如果超过最大值 直接提示结果 你好快啊
        if (self.count>=Data.activity.bun_eat_click_max) then
            self:timeOver()
        end
    end
end

function ActivityEnargyPanel:bolReset()
    -- print("gGetCurServerTime()="..os.clock())
    -- print("self.onTouchBegan_time="..self.onTouchBegan_time)
    if (os.clock() - self.onTouchBegan_time >= 0.1 or self.bolTouchBegan==false) then
        return true
    else
        return false
    end
end

function ActivityEnargyPanel:rsetAct()
    
    local function  playEnd()
        self:rsetAct()
    end

    self:getNode("layer_rset").curAction=""
    self:getNode("layer_rset"):resume()
    self:getNode("layer_rset"):playAction("rest",self.playEnd)
    self:getNode("layer_rset"):setSpeedScale(self.eatActSpeed)

    -- print("待机==时间速度="..self.eatActSpeed)
    if (self.eatActSpeed>1) then
        self.eatActSpeed = self.eatActSpeed - 0.1
        self.eatActSpeed = math.max(self.eatActSpeed,1)
    else
        self.eatActSpeed = 1
    end
end

function ActivityEnargyPanel:playRoleAct()
    local function  playEnd()
        self:getNode("layer_rset").curAction=""
        self:getNode("layer_rset"):resume()
        if (self:bolReset()) then
            self:rsetAct()
            -- self:getNode("layer_rset"):playAction("rest")
            -- self:getNode("layer_rset"):setSpeedScale(self.eatActSpeed)
            -- print("待机")
            self.iEatActSataus = 0
        else
            local function playEnd2()
                self.iEatActSataus = 0
                if (self:bolReset()) then
                    self:rsetAct()
                    -- self:getNode("layer_rset"):playAction("rest")
                    -- self:getNode("layer_rset"):setSpeedScale(self.eatActSpeed)
                else
                    self:playRoleAct()
                end
            end
            self:getNode("layer_rset"):playAction("eat_2",playEnd2)
            self:getNode("layer_rset"):setSpeedScale(self.eatActSpeed)
            -- print("吃点2")
        end
    end
    if (self.iEatActSataus == 0) then
        self.iEatActSataus = 1
        self:getNode("layer_rset").curAction=""
        self:getNode("layer_rset"):resume()
        self:getNode("layer_rset"):playAction("eat_1",playEnd)
        self:getNode("layer_rset"):setSpeedScale(self.eatActSpeed)
        -- print("吃点1")
    end
end

function ActivityEnargyPanel:playBaoziAct()
    --包子动态
    local function  playEnd()
        gPlayEffect("sound/effect/ui_baozi.mp3")
        self:getNode("reward_icon").curAction=""
        self:getNode("reward_icon"):resume()
        self:getNode("reward_icon"):playAction("ui_huodong_baozi_tan",nil,nil,0)
    end

    --飘包子
    local actbg = self:getNode("layer_baozi_get")
    local endPoint = gGetPositionByAnchorInDesNode(actbg,self:getNode("reward_icon"),cc.p(0,0))
    endPoint.x = endPoint.x - 25
    endPoint.y = endPoint.y - 15
    local startPoint = gGetPositionByAnchorInDesNode(actbg,self:getNode("layer_baozi"),cc.p(0.5,0.5))
    
    if (getRand(1,2)==1) then
        startPoint.x = startPoint.x + getRand(1,20)
        startPoint.y = startPoint.y + getRand(1,20)
    end

    local xxxx = 100+getRand(1,150)
    local yyyy = 100+getRand(1,150)
    local bezier = {}

    if (getRand(1,2)==2) then
        if (getRand(1,2)==1) then
            xxxx = 100+getRand(1,getRand(1,100)+30)
            yyyy = 100+getRand(1,getRand(1,100)+30)
        end
        
        bezier = {
            cc.p(startPoint.x - xxxx, startPoint.y),
            cc.p(endPoint.x + yyyy, endPoint.y),
            cc.p(endPoint.x, endPoint.y),
        }
    else
        if (getRand(1,5)==5) then
            xxxx = 100+getRand(1,50)
            yyyy = 100+getRand(1,20)
            bezier = {
                cc.p(startPoint.x - xxxx, startPoint.y + yyyy),
                cc.p(endPoint.x + xxxx, endPoint.y),
                cc.p(endPoint.x, endPoint.y),
            }
        else
            if (getRand(1,2)==1) then
                xxxx = 30+getRand(1,getRand(1,100))
                yyyy = 30+getRand(1,getRand(1,100))
            else
                if (getRand(1,2)==1) then
                    xxxx = 100+getRand(1,50)
                    yyyy = 100+getRand(1,20)
                end
            end
            bezier = {
                cc.p(startPoint.x - xxxx, startPoint.y),
                cc.p(endPoint.x, endPoint.y - yyyy),
                cc.p(endPoint.x, endPoint.y),
            }
        end
    end

    local bezierForward = cc.BezierBy:create(0.5, bezier)
    local imageBaozi = cc.Sprite:create("images/ui_public1/energy.png")
    imageBaozi:setScale(0.5)

    local func = cc.CallFunc:create(playEnd)
    local seq = cc.Sequence:create(bezierForward,func,cc.RemoveSelf:create())
    imageBaozi:runAction(seq)
    gAddCenter(imageBaozi,actbg)
end

function ActivityEnargyPanel:playBarIng()
    local max = Data.activity.bun_box_click_num[3]
    local per= (self:getAllCount())/max
    self:setBarPer("fexp_bar",per)
    self:setLabelString("count",self.count)
end

--status  1:开始就停止  2播完停止  3播完跳到下一帧停止
function ActivityEnargyPanel:createActBaoZi(type,status)
    local fla = nil
    local node = self:getNode("layer_baozi")
    node:removeAllChildren()
    local fla=FlashAni.new()
    local actions = {}
    if(type==1) then
        table.insert(actions,"baozi_1")
    elseif(type==2) then
        table.insert(actions,"baozi_2")
    elseif(type==3) then
        table.insert(actions,"baozi_3")
    else
        table.insert(actions,"baozi_4")
    end
    -- print("type = "..type)

    if (status==1) then
        fla:playAction(actions[1])
        fla:stopAni()
    elseif (status==2) then
        local function  playEnd()
            fla:stopAni()
        end
        fla:playAction(actions[1],playEnd)
    elseif (status==3) then
        local function  playEnd()
            if (type<3) then
                self:createActBaoZi(type+1,2)
            else
                fla:stopAni()
            end
        end
        fla:playAction(actions[1],playEnd)
    end

    gAddCenter(fla,node)



    return fla
end

function ActivityEnargyPanel:eatEnargy()
    Data.redpos.bolDayEnergy = false
    local curServerTime = gGetCurServerTime();
    for key,var in pairs(Data.task.getEnergyTime) do
        if (gGetHourByTime(curServerTime) >= toint(var.time[1]) and gGetHourByTime(curServerTime) <= toint(var.time[2])) then
            var.hasGet = not Data.redpos.bolDayEnergy;
        end
    end
end

return ActivityEnargyPanel