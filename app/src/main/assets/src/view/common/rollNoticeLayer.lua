local RollNoticeLayer=class("RollNoticeLayer",UILayer)

function RollNoticeLayer:ctor()
    self:init("ui/ui_roll_notice.map") 
    self:setPos(true)

    self.m_isMessageRolling = false;
    self.m_fDt = 0;
    self.lab_move_w = 0;
    self.showNotice = nil;
    self.iCount = 0;

    self.bg = self:getNode("bg")
    self.bg:setVisible(false);
    self.labNotice = self:getNode("lab_notice")
    self.wordBg_w = self:getNode("word_bg"):getContentSize().width;
    self:resetLabPos()
    -- self:setRTFString("lab_notice","\\w{c=000000}")
    self.rollTimes = 0;--滚动次数
 
    local function _update()
        self:update()
    end

    self:scheduleUpdateWithPriorityLua(_update,1)
end

function RollNoticeLayer:setPos(bolMain)
    local winSize=cc.Director:getInstance():getWinSize()
    if (bolMain) then
        self:setPosition((winSize.width - self.mapW)/2+110,winSize.height - (winSize.height - self.mapH)/2)
    else
        self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)
    end
end

-- function RollNoticeLayer:events()
--     return {EVENT_ID_SYSTEM_ROLL_NOTICE,}
-- end

-- function RollNoticeLayer:dealEvent(event,param)
--     print("event====="..event)
--     if(event == EVENT_ID_SYSTEM_ROLL_NOTICE) then
--         self:reSetRollNotice()
--     end
-- end

function RollNoticeLayer:dealNoticeTime()
    local notFound = true
    local index = 0
    local count = 1
    while notFound do
        count = count + 1;
        if (count>1000) then -- 防止死循环
            notFound = false;
            break;
        end
        local size = table.getn(Data.rollNoticeList)
        if size == 0 then
            notFound = true;
            break
        end
        index = index + 1;

        local notice = Data.rollNoticeList[index];
        -- print("notice.endtime=="..notice.endtime..",gGetCurServerTime()="..gGetCurServerTime())
        if (notice.endtime <= gGetCurServerTime()) then
            table.remove(Data.rollNoticeList, index)
            index = index - 1;
            size = table.getn(Data.rollNoticeList)
        end

        if (index>=size) then
            notFound = false;
            break;
        end
    end
end

function RollNoticeLayer:sortNotice()

    for k,v in pairs(Data.rollNoticeList) do
        if (v.userid == Data.getCurUserId()) then
            v.sort = 2
        else
            v.sort = 1
        end
    end

    local sort1 = function(a,b)
        if (a.priority == b.priority) then
            if (a.sort==b.sort) then
                return a.insertTime < b.insertTime
            else
                return a.sort > b.sort
            end
        else
            return a.priority > b.priority
        end
    end
    table.sort(Data.rollNoticeList,sort1)

    --寻找播放索引 时间短的
    local tmp_notice_lsit = {}
    self.showNoticeIndex = 1
    -- print("size = "..#Data.rollNoticeList)
    for k,v in pairs(Data.rollNoticeList) do
        --判断时间
        local time = math.max((v.show_time+v.interval)-gGetCurServerTime(),0)
        v.sorttime = time
        v.key = k
        -- table.insert(tmp_notice_lsit,v)
    end
    local size = #Data.rollNoticeList
    if (size>0) then
        local sorttime = function(a,b)
            if (a.sorttime == b.sorttime) then
                return a.priority > b.priority
            else
                return a.sorttime<b.sorttime
            end
        end
        table.sort(Data.rollNoticeList,sorttime)
        -- table.sort(tmp_notice_lsit,sorttime)
        -- self.showNoticeIndex = tmp_notice_lsit[1].key
        -- tmp_notice_lsit = {}
    end

    -- print("self.showNoticeIndex = "..self.showNoticeIndex)
    
    -- print_lua_table(Data.rollNoticeList)
end

function RollNoticeLayer:checkNewNotice()
    --去掉超时的消息
    self:dealNoticeTime();
    --排序
    self:sortNotice()

    local size = table.getn(Data.rollNoticeList)
    -- print("size = "..size)
    if (size>0) then
        self:createOneSysNotice()
    else
        self:reSetRollNotice();
    end
end

function RollNoticeLayer:resetLabPos()
    self.labNotice:setPositionX(self.wordBg_w)
end

function RollNoticeLayer:createOneSysNotice()
    -- print("------createOneSysNotice-----"..notice.content)
    self.m_isMessageRolling = true;
    self.bg:setVisible(true);
    -- self.showNotice = notice;
    self:resetLabPos()
    self:playAction();
    
    self:setOpacity(0);
    self:show();
end

function RollNoticeLayer:playAction()
    -- self:sortNotice()
    local size = table.getn(Data.rollNoticeList)
    if (size<=0) then 
        self:reSetRollNotice()
        return 
    end
    self.showNotice = Data.rollNoticeList[self.showNoticeIndex]
    self:setRTFString("lab_notice","\\w{c=000000}"..self.showNotice.content)
    -- self:setLabelString("lab_notice",self.showNotice.content)
    self.lab_move_w = (self.labNotice:getContentSize().width+self.wordBg_w);

    local function onReSet()
        self:resetLabPos()
    end

    local move_feed = self.lab_move_w/50;--根据长度调整移动速度
    self.labNotice:stopAllActions()
    local timeScale=cc.Director:getInstance():getScheduler():getTimeScale()  
    move_feed = move_feed *timeScale
    local move_left = cc.MoveBy:create(move_feed, cc.p(-self.lab_move_w,0))
    local reset_pos = cc.CallFunc:create(onReSet)
    local actions={}
    table.insert(actions,move_left)
    table.insert(actions,reset_pos)

    local function onFunc()
        self.showNotice.show_time = gGetCurServerTime()
        if (self.showNotice.num ~= -100) then
            self.showNotice.num = self.showNotice.num - 1;
            if (self.showNotice.num<1) then--次数没了
                if (table.getn(Data.rollNoticeList)>0) then
                table.remove(Data.rollNoticeList, self.showNoticeIndex)
                end
            end
        end
        --去掉超时的消息
        self:dealNoticeTime();
        --排序
        self:sortNotice()

        local size = table.getn(Data.rollNoticeList)
        if (size>0) then
            self.showNotice = Data.rollNoticeList[self.showNoticeIndex]
            self:showNextNotice()
        else
            self:reSetRollNotice();
        end
    end

    local p_repeat =cc.Repeat:create(cc.Sequence:create(actions), 1)
    local func = cc.CallFunc:create(onFunc)
    local action=cc.Sequence:create(p_repeat,func)
    self.labNotice:runAction(action)
end

function RollNoticeLayer:reSetRollNotice()
    -- print("---------------reSetRollNotice------------")
    if (self.labNotice) then self.labNotice:stopAllActions() end
    -- if (self.bg) then 
    --     self.bg:setVisible(false) 
    -- end
    self.m_isMessageRolling = false;
    self.m_fDt = 0;
    self.showNotice = nil;
    self:hide();
end



function RollNoticeLayer:showNextNotice()
    if (self.showNotice.endtime <= gGetCurServerTime()) then--时间到
        local size = table.getn(Data.rollNoticeList)
        if (size>0) then
            table.remove(Data.rollNoticeList, self.showNoticeIndex)
        end
    else
        -- print("self.showNotice.num=="..self.showNotice.num)
        if(self.showNotice.num == -100)then
            --无限次数滚动
            local playAction = function()
                self:show();
                self:playAction();
            end
            self:hide();
            local dtime = (self.showNotice.show_time+self.showNotice.interval)-gGetCurServerTime()
            local delayTime = math.max(dtime,1)
            -- print("delayTime = "..delayTime)
            self.bg:runAction(cc.Sequence:create(
                    cc.DelayTime:create(delayTime),
                    cc.CallFunc:create(playAction)
                ));
            return;
        else
            -- self.showNotice.num = self.showNotice.num - 1;
            -- if (self.showNotice.num<1) then--次数没了
            --     table.remove(Data.rollNoticeList, self.showNoticeIndex)
            -- else
                --还有循环次数
                -- self:playAction();
                local playAction = function()
                    -- self:show();
                    self:playAction();
                end

                local dtime = (self.showNotice.show_time+self.showNotice.interval)-gGetCurServerTime()
                local delayTime = math.max(dtime,1)

                -- self:hide();
                self.bg:runAction(cc.Sequence:create(
                        cc.DelayTime:create(delayTime),
                        cc.CallFunc:create(playAction)
                    ));

                return;
            -- end
        end
    end

    local size = table.getn(Data.rollNoticeList)
    -- print("size="..size)
    if (size<=0) then
        --结束
        -- print("结束")
        self:reSetRollNotice()
        return;
    end

    self:checkNewNotice()
end

function RollNoticeLayer:show()
    self:stopAllActions();
    self:setOpacityEnabled(true);    
    self:runAction(cc.Sequence:create(cc.Show:create(),cc.FadeTo:create(0.5,255)));
end

function RollNoticeLayer:hide()
    self:stopAllActions();
    self:setOpacityEnabled(true);    
    self:runAction(cc.Sequence:create(cc.FadeTo:create(0.5,0),cc.Hide:create()));    
end

function RollNoticeLayer:update()
    if (self.m_isMessageRolling == false) then
        self.m_fDt = self.m_fDt + 1;
        if (self.m_fDt>20) then
            self.m_fDt = 0;

            -- local notice = {}
            -- notice = {}
            -- notice.userid = 10020000001969
            -- notice.insertTime = 71.264651
            -- notice.content = "xm52  +1"
            -- notice.num = 1;
            -- notice.endtime = gGetCurServerTime() + 13000;
            -- notice.priority = 100
            -- notice.pos = 0;
            -- notice.show_time = 0
            -- notice.interval = 55
            -- table.insert(Data.rollNoticeList,notice)

            -- notice = {}
            -- notice.userid = 10020000001969
            -- notice.insertTime = 71.449747
            -- notice.content = "xm52  +2"
            -- notice.num = 1;
            -- notice.endtime = gGetCurServerTime() + 13000;
            -- notice.priority = 100
            -- notice.pos = 0;
            -- notice.show_time = 0
            -- notice.interval = 55
            -- table.insert(Data.rollNoticeList,notice)

            -- notice = {}
            -- notice.userid = 10020000001969
            -- notice.insertTime = 71.822069
            -- notice.content = "xm52  +3"
            -- notice.num = 1;
            -- notice.endtime = gGetCurServerTime() + 13000;
            -- notice.priority = 100
            -- notice.pos = 0;
            -- notice.show_time = 0
            -- notice.interval = 1
            -- table.insert(Data.rollNoticeList,notice)

            -- notice = {}
            -- notice.userid = 10020000002123
            -- notice.insertTime = 72.884227
            -- notice.content = "xm36 +1"
            -- notice.num = 1;
            -- notice.endtime = gGetCurServerTime() + 3000;
            -- notice.priority = 110
            -- notice.pos = 0;
            -- notice.show_time = 0
            -- notice.interval = 1
            -- table.insert(Data.rollNoticeList,notice)

            -- notice = {}
            -- notice.userid = 10020000002123
            -- notice.insertTime = 72.984227
            -- notice.content = "xm36 +2"
            -- notice.num = 1;
            -- notice.endtime = gGetCurServerTime() + 3000;
            -- notice.priority = 110
            -- notice.pos = 0;
            -- notice.show_time = 0
            -- notice.interval = 1
            -- table.insert(Data.rollNoticeList,notice)

            -- table.sort(Data.rollNoticeList,function(a,b) return a.priority>b.priority end) --从大到小排序

            self:checkNewNotice();
            
        end
    else
        --显示
        -- print("----------显示")
        if (self.showNotice) then
            if (Data.bolInPayPanel==true and Panel.getOpenPanel(PANEL_PAY) and Panel.isTopPanel(PANEL_PAY) and gAccount:getPlatformId() == CHANNEL_ANDROID_TENCENT) then
                if (self.bg:isVisible()) then
                    self.bg:setVisible(false);
                end
                return
            end
            if (Data.bolInBattle == true) then
                -- print("在战斗中"..self.showNotice.pos)
                if (self.showNotice.pos ~= 0) then
                    if (self.bg:isVisible()) then
                        self.bg:setVisible(false);
                    end
                else--1
                    if (not self.bg:isVisible()) then
                        self:setOpacity(255);
                        self.bg:setVisible(true);
                    end
                end
            else
                if (not self.bg:isVisible()) then
                    self:setOpacity(255);
                    self.bg:setVisible(true);
                end
            end
        end
    end
end

return RollNoticeLayer