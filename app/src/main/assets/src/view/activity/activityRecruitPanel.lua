local ActivityRecruitPanel=class("ActivityRecruitPanel",UILayer)

function ActivityRecruitPanel:ctor(data)
    self:init("ui/ui_hd_zhaomu1.map") 
    self.curData=data

    self:getNode("layer_1"):setVisible(false)
    self:getNode("layer_2"):setVisible(false)

    self:getNode("scroll_contain_item"):layout()
    self:getNode("help_bg"):layout()

    Net.sendActivityRecruitInfo()
end

function ActivityRecruitPanel:onPopup()
    Net.sendActivityRecruitInfo()
end

function ActivityRecruitPanel:onTouchEnded(target)
    if(target.touchName=="btn_shop")then
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_EMOTION)
    elseif(target.touchName=="btn_share")then
        Net.sendActivityPublish()
    elseif(target.touchName=="btn_help")then
        gShowRulePanel(SYS_ACT_RECRUIT)
    elseif(target.touchName=="btn_get")then
        local uid = string.filter(self:getNode("input_get"):getText())
        local len = string.len(uid);
        if (uid == "" and len==0) then
            local word = gGetWords("activityNameWords.plist","134")
            gShowNotice(word);
            return
        end
        Net.sendActivityRecruit(toint(uid))
    end
end

function ActivityRecruitPanel:setEmotion()
    local emoney = Data.emoney
    self:setLabelString("txp_emotion",emoney)
    self:getNode("layout_bg1"):layout() 
end

function ActivityRecruitPanel:setCount()
    self:replaceRtfString("lab_count",Data.activityRecruitData.count,Data.activity.recruit_max_num)
end

function ActivityRecruitPanel:sortActList()
    --排序
    for k,v in pairs(self.activityData.list) do
        v.sort = 2
        -- print_lua_table(v)
        if (v.num>0 and v.id ~= 1) then
            v.sort = 1
        elseif (v.id == 1 and Data.activityRecruitData.finish==1) then
            v.sort = 3
        elseif (v.rnum==0) then
            v.sort = 3
        end
    end

    local sort1 = function(a,b)
        if (a.sort == b.sort) then
            return a.id < b.id;
        else
            return a.sort < b.sort
        end
    end
    table.sort( self.activityData.list, sort1 )
end

function ActivityRecruitPanel:setData()
    -- print("---ActivityRecruitPanel:setData---")
    --类型判断
    if (Data.activityRecruitData.isrecruit==true) then
        self:getNode("layer_1"):setVisible(false)
        self:getNode("layer_2"):setVisible(true)

        self:setEmotion()
        self:setCount()

        self:getNode("scroll"):clear()
        self.activityData = Data.activityRecruitData;
        --排序
        self:sortActList()
        for key, value in pairs( self.activityData.list) do
            local item=ActivityRecruitItem.new()
            item.curActData= self.curData
            item:setData(key,value)
            self:getNode("scroll"):addItem(item)
        end
        self:getNode("scroll"):layout()

    else
        self:getNode("layer_1"):setVisible(true)
        self:getNode("layer_2"):setVisible(false)

        for i=1,3 do
            local nodeBg = self:getNode("reward"..i)
            if(nodeBg)then nodeBg:setVisible(false) end
        end
        
        local index = 0
        for k,v in pairs(Data.activity.recruit_mate_reward) do
            if (math.mod(k,2) == 1) then
                index = index + 1
                local nodeBg = self:getNode("reward"..index)
                if(nodeBg)then nodeBg:setVisible(true) end
                local node=DropItem.new()
                local itemid = Data.activity.recruit_mate_reward[k]
                local num = Data.activity.recruit_mate_reward[k+1]
                node:setData(itemid)
                node:setNum(num)
                node:setPositionY(node:getContentSize().height)
                gAddMapCenter(node, nodeBg)
            end
        end
        self:getNode("layout_bg"):layout()
    end
end

function ActivityRecruitPanel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_RECRUIT_INFO)then
        self:setData()
    elseif(event==EVENT_ID_GET_ACTIVITY_RECRUIT)then
        self:setEmotion()
        self:setCount()
    elseif(event==EVENT_ID_USER_DATA_UPDATE)then
        self:setEmotion()
    elseif(event==EVENT_ID_GET_ACTIVITY_PUBLISH)then
        -- Panel.popUpUnVisible(PANEL_ACTIVITY_RECRUIT_SHARE,nil,nil,true);
        Panel.popUpVisible(PANEL_ACTIVITY_RECRUIT_SHARE)
    elseif(event==EVENT_ID_GET_ACTIVITY_RECRUIT_REC) then
        self:refreshData(param)
    end
end   

function ActivityRecruitPanel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)
    end
end

return ActivityRecruitPanel