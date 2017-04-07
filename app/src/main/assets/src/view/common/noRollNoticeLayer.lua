local NoRollNoticeLayer=class("NoRollNoticeLayer",UILayer)

function NoRollNoticeLayer:ctor()
    self:init("ui/ui_no_roll_notice.map") 
    self:setPos(true)

    self.m_isMessageRolling = false;
    self.m_fDt = 0;
    self.showNotice = nil;

    self.bg = self:getNode("bg")
    self.bg:setVisible(false);
    self.labNotice = self:getNode("lab_notice")
    self.wordBg_w = self:getNode("word_bg"):getContentSize().width;
    self:resetLabPos()
 
    local function _update()
        self:update()
    end

    self:scheduleUpdateWithPriorityLua(_update,1)
end

function NoRollNoticeLayer:setPos(bolMain)
    local winSize=cc.Director:getInstance():getWinSize()
    if (bolMain) then
        self:setPosition((winSize.width - self.mapW)/2+110,winSize.height - (winSize.height - self.mapH))
    else
        self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH))
    end
end

function NoRollNoticeLayer:dealNoticeTime()
    local notFound = true
    local index = 0
    local count = 1
    while notFound do
        count = count + 1;
        if (count>1000) then -- 防止死循环
            notFound = false;
            break;
        end
        local size = table.getn(Data.noRollNoticeList)
        if size == 0 then
            notFound = true;
            break
        end
        index = index + 1;

        local notice = Data.noRollNoticeList[index];
        -- print("notice.endtime=="..notice.endtime..",gGetCurServerTime()="..gGetCurServerTime())
        if (notice.endtime <= gGetCurServerTime()) then
            table.remove(Data.noRollNoticeList, index)
            index = index - 1;
            size = table.getn(Data.noRollNoticeList)
        end

        if (index>=size) then
            notFound = false;
            break;
        end
    end
end

function NoRollNoticeLayer:sortNotice()

    for k,v in pairs(Data.noRollNoticeList) do
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
    table.sort(Data.noRollNoticeList,sort1)

    --寻找播放索引 时间短的
    local tmp_notice_lsit = {}
    self.showNoticeIndex = 1
    -- print("size = "..#Data.rollNoticeList)
    for k,v in pairs(Data.noRollNoticeList) do
        --判断时间
        local time = math.max((v.show_time+v.interval)-gGetCurServerTime(),0)
        v.sorttime = time
        v.key = k
        -- table.insert(tmp_notice_lsit,v)
    end
    local size = #Data.noRollNoticeList
    if (size>0) then
        local sorttime = function(a,b)
            if (a.sorttime == b.sorttime) then
                return a.priority > b.priority
            else
                return a.sorttime<b.sorttime
            end
        end
        table.sort(Data.noRollNoticeList,sorttime)
        -- table.sort(tmp_notice_lsit,sorttime)
        -- self.showNoticeIndex = tmp_notice_lsit[1].key
        -- tmp_notice_lsit = {}
    end

    -- print("self.showNoticeIndex = "..self.showNoticeIndex)
    
    -- print_lua_table(Data.rollNoticeList)
end

function NoRollNoticeLayer:checkNewNotice()
    --去掉超时的消息
    self:dealNoticeTime();
    --排序
    self:sortNotice()

    local size = table.getn(Data.noRollNoticeList)
    -- print("size = "..size)
    if (size>0) then
        self:createOneSysNotice()
    else
        self:reSetRollNotice();
    end
end

function NoRollNoticeLayer:resetLabPos()
    -- self.labNotice:setPositionX(self.wordBg_w)
end

function NoRollNoticeLayer:createOneSysNotice()
    -- print("------createOneSysNotice-----"..notice.content)
    self.m_isMessageRolling = true;
    self.bg:setVisible(true);
    -- self.showNotice = notice;
    self:resetLabPos()
    self:playAction();
    
    self:setOpacity(0);
    self:show();
end

function NoRollNoticeLayer:playAction()

    local size = table.getn(Data.noRollNoticeList)
    if (size<=0) then 
        self:reSetRollNotice()
        return 
    end
    self.showNotice = Data.noRollNoticeList[self.showNoticeIndex]
    -- if self.showNotice.show_time == 0 then
    --     self.showNotice.show_time = gGetCurServerTime() 
    -- end
    self:setRTFString("lab_notice","\\w{c=000000}"..self.showNotice.content)

    -- local function onReSet()
    --     self:resetLabPos()
    -- end

    local seq = cc.Sequence:create(cc.DelayTime:create(self.showNotice.interval), cc.CallFunc:create(function ()
        --去掉超时的消息
        self:dealNoticeTime()
        --排序
        self:sortNotice()

        local size = table.getn(Data.noRollNoticeList)
        if (size>0) then
            self.showNotice = Data.noRollNoticeList[self.showNoticeIndex]
            self:showNextNotice()
        else
            self:reSetRollNotice();
        end        
    end))
    self.labNotice:runAction(seq)
end

function NoRollNoticeLayer:reSetRollNotice()
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



function NoRollNoticeLayer:showNextNotice()

    local size = table.getn(Data.noRollNoticeList)
    if (size>0) then
        table.remove(Data.noRollNoticeList, self.showNoticeIndex)
    end

    size = table.getn(Data.noRollNoticeList)
    -- print("size="..size)
    if (size<=0) then
        self:reSetRollNotice()
        return;
    end

    self:checkNewNotice()
end

function NoRollNoticeLayer:show()
    self:stopAllActions();
    self:setOpacityEnabled(true);    
    self:runAction(cc.Sequence:create(cc.Show:create(),cc.FadeTo:create(0.5,255)));
end

function NoRollNoticeLayer:hide()
    self:stopAllActions();
    self:setOpacityEnabled(true);    
    self:runAction(cc.Sequence:create(cc.FadeTo:create(0.5,0),cc.Hide:create()));    
end

function NoRollNoticeLayer:update()
    if (self.m_isMessageRolling == false) then
        self.m_fDt = self.m_fDt + 1;
        if (self.m_fDt>20) then
            self.m_fDt = 0;
            self:checkNewNotice();
        end
    else
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

return NoRollNoticeLayer