-- 可翻牌副本列表
local AtlasEliteFlopTabPanel=class("AtlasEliteFlopTabPanel",UILayer)

function AtlasEliteFlopTabPanel:ctor(data)
    self:init("ui/ui_atlas_box_notice.map")
    self.tab_atlas = data
    self.scrol_items = {}

    local title = gGetWords("eliteFlopWord.plist","flop_tab_title")
    self:getNode("lab_title"):setString(title)

    self:createScrol()

    local function updateTime()
        self:refreshScrol()
    end
    self:scheduleUpdate(updateTime,1)

    local function onNodeEvent(event)
        if event == "exit" then
            self:unscheduleUpdateEx()
        end
    end
    self:registerScriptHandler(onNodeEvent); 
end

function AtlasEliteFlopTabPanel:onTouchEnded(target)
    if target.touchName=="btn_close" then
        -- 没有牌可翻了
        if table.getn(self.tab_atlas) == 0 then
            local layer = Panel.getOpenPanel(PANEL_ATLAS)
            if layer then
                layer:getNode("btn_flop"):setVisible(false)
            end
        end
        Panel.popBack(self:getTag())
    end
    
end

function AtlasEliteFlopTabPanel:onMoveDown()
    if (self.iShowIndex>=self.iShowMax) then
        return;
    end
    
    local scrol = self:getNode("scroll")
    for i=1+self.iShowIndex,self.iShowSize+self.iShowIndex do
        local key = i
        if (key<=table.getn(self.tab_atlas)) then
            
            local item = self.tab_atlas[i]
            local mid = item.mid
            local sid = item.sid
            --print("副本:"..mid.."-"..sid)
            local chapter=DB.getChapterById(mid, 1)
            if(chapter)then
                local layer = AtlasEliteFlopTabItem.new()
                local sWord = gGetWords("eliteFlopWord.plist","flop_tab_item_title",
                    gParseZnNum(mid),
                    chapter.name,
                    sid)
                layer:getNode("txt_title"):setString(sWord)
                scrol:addItem(layer)
                layer.itemdata = item
                table.insert(self.scrol_items,layer)

                local cur_server_time = gGetCurServerTime()
                if item.endtime > 0 then
                    local time = item.endtime - cur_server_time
                    if time < 0 then time = 0 end

                    layer:getNode("lab_time"):setString(gParserHourTime(time))
                    layer:getNode("btn_get"):setVisible(true)
                    layer:getNode("btn_goto"):setVisible(false)
                else
                    layer:getNode("btn_get"):setVisible(false)
                    layer:getNode("btn_goto"):setVisible(true)
                end

                self:setItemStatus(layer)
            end
        end
    end
   
    scrol:layout(self.iShowIndex==0)
    self.iShowIndex = self.iShowIndex + self.iShowSize;
    self.iShowIndex = math.min(self.iShowIndex,self.iShowMax)
end

function AtlasEliteFlopTabPanel:createScrol()
    local scrol = self:getNode("scroll")
    scrol.breakTouch = true
    scrol.scrollBottomCallBack = function()
       self:onMoveDown();
    end
    self.iShowIndex = 0;
    self.iShowMax = 100;
    self.iShowSize = 10;
    self:onMoveDown()
end

function AtlasEliteFlopTabPanel:removeScrol(mid,sid)
    -- body
    local remove_idx = 0
    for i = 1,table.getn(self.tab_atlas) do
        if self.tab_atlas[i].mid == mid and self.tab_atlas[i].sid == sid then
            remove_idx = i
            break
        end
    end
    if remove_idx > 0 then
        table.remove(self.tab_atlas,remove_idx)
        table.remove(self.scrol_items,remove_idx)
        local scrol = self:getNode("scroll")
        scrol:removeItemByIndex(remove_idx-1,false)
    end
end

function AtlasEliteFlopTabPanel:refreshScrol()
    local del_items = {}
    for k,v in pairs(self.scrol_items) do
        local data = v.itemdata
        local cur_server_time = gGetCurServerTime()
        if data.num == 5 then
            table.insert(del_items,{mid=data.mid,sid=data.sid})
        elseif  data.endtime > 0 and data.endtime < cur_server_time then
            table.insert(del_items,{mid=data.mid,sid=data.sid})
        elseif data.endtime > cur_server_time then
            -- 还在翻牌时间内
            v:getNode("to_flop_bg"):setVisible(true)
            v:getNode("to_atlas_bg"):setVisible(false)
            local time = data.endtime - cur_server_time
            v:getNode("lab_time"):setString(gParserHourTime(time))
        end
    end
    for k,v in pairs(del_items) do
        -- 副本翻牌到期 移除
            self:removeScrol(v.mid,v.sid)
    end
end

function AtlasEliteFlopTabPanel:setItemStatus(itemLayer)
    local data = itemLayer.itemdata
    local db_items = CoreAtlas.EliteFlop.getDataItems(data.mid,data.sid)
   
    if db_items then 
        local order = {}
        local bHadFlop = false
        if data.num > 0 and data.list and data.list:size() > 0 then
            bHadFlop = true
        end
        -- 筛选出未翻牌
        for i = 1,5 do
            local bItemHadFlop = false
            if bHadFlop then
                for j = 1,data.list:size() do
                    if data.list[j-1] == i then
                        bItemHadFlop = true 
                        break
                    end
                end
            end
            if bItemHadFlop == false then
                table.insert(order,{idx = i,flop = false})
            end
        end
        --合并已翻牌的序号到最后
        if bHadFlop == true then
            for i = 1,data.list:size() do
                table.insert(order,{idx = data.list[i-1],flop = true})
            end
        end
        --显示
        for i = 1,5 do
            itemLayer:getNode("icon"..i):removeAllChildren()
            local idx = order[i].idx
            local flop = order[i].flop
            local item = db_items[idx]
            if item then
                local icon=DropItem.new()
                icon:setData(item.itemid,DB.getItemQuality(item.itemid))
                icon:setNum(item.num)
                icon:setAnchorPoint(cc.p(0.5,0.5))
                --icon.touch = false
                gAddChildByAnchorPos(itemLayer:getNode("icon"..i),icon,cc.p(0.5,0.5),cc.p(0,icon:getContentSize().height))
                if flop then
                    Icon.setGetFlag(itemLayer:getNode("icon"..i),true)
                end
                
            end
        end
    end
    
end

function AtlasEliteFlopTabPanel:refreshAtlasStatus(mid,sid)
    -- 刷新对应副本信息
    for k,v in pairs(self.scrol_items) do
        local data = v.itemdata
        if data.mid == mid and data.sid == sid then
            if data.num < 5 and
                data.endtime > 0 and 
                data.endtime > gGetCurServerTime() then
                local info = CoreAtlas.EliteFlop.getFlopInfo(mid,sid)
                if info then
                    data.num = info.num
                    data.list = info.list
                end
                self:setItemStatus(v)
                --if data.num == 5 then
                    --self:removeScrol(data.mid,data.sid)
                --end
            end

            return
        end
    end
end

return AtlasEliteFlopTabPanel
