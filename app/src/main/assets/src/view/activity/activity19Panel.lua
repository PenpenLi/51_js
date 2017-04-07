local Activity19Panel=class("Activity19Panel",UILayer)

function Activity19Panel:ctor(data)
    self:init("ui/ui_hd_tongyong3.map") 
    self.curData=data

    self:getNode("txt_vip2"):setVisible(false)
    self:getNode("sign_no"):setVisible(false)
    self:getNode("btn_get"):setVisible(false)
    self:getNode("reward_bg"):setVisible(false)
    for i=1,4 do
        local nodeBg = self:getNode("reward"..i)
        if(nodeBg)then nodeBg:setVisible(false) end
    end
    Data.activity19Data = {}
    Net.sendActivity19(self.curData,true)
end

function Activity19Panel:onPopup()
    Net.sendActivity19(self.curData,true)
end

function Activity19Panel:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        if (gGetCurServerTime()<Data.activity19Data.begintime) then
            local sWord = gGetWords("activityNameWords.plist","act_19_1")
            gShowNotice(sWord)
            return
        end
        -- if (Data.activity19Data.begintime <= gGetCurServerTime() and Data.activity19Data.endtime >= gGetCurServerTime()) then
            if (Data.activity19Data.recId) then
               Net.sendActivity19Rec(Data.activity19Data.idx,Data.activity19Data.recId)
            end 
        -- else
        --     --提示 活动结束
        --     local sWord = gGetWords("activityNameWords.plist","99")
        --     gShowNotice(sWord)
        -- end
    end
end

function Activity19Panel:setBtn(num)
    local bolShow = false
    if(num>=1)then
        self:setTouchEnableGray("btn_get",false);
        self:setLabelString("btn_lab",gGetWords("btnWords.plist","btn_reward_got"))
    else
        bolShow = true
        self:setTouchEnableGray("btn_get",true); 
        self:setLabelString("btn_lab",gGetWords("btnWords.plist","btn_get_reward"))
    end
    Data.activityRedPosLogin[ACT_TYPE_19]=bolShow
    RedPoint.setActivityRedpos(ACT_TYPE_19,bolShow)
end

function Activity19Panel:setData()
    --时间
    self:getNode("txt_vip2"):setVisible(true)
    local sTime = gParserMonDay(Data.activity19Data.begintime+24*60*60)
    local eTime = gParserMonDay(Data.activity19Data.endtime)
    local strTime = sTime.."~"..eTime
    self:replaceLabelString("txt_vip2",strTime)

    -- self:getNode("sign_no"):setVisible(false)
    self:getNode("btn_get"):setVisible(true)
    self:getNode("reward_bg"):setVisible(true)

    for k,v in pairs(Data.activity19Data.list) do
        Data.activity19Data.recId = v.idx

        local data=  Data.getActivity19id(Data.activity19Data.recId)
        if(data)then
            self:setBtn(data.num)
        end
        -- if (#v.items>0) then
        --     self:getNode("reward_bg"):setVisible(true)
        -- end
        for k2,v2 in pairs(v.items) do
            local nodeBg = self:getNode("reward"..k2)
            if(nodeBg)then
                nodeBg:setVisible(true)
                local node=DropItem.new()
                node:setData(v2.itemid)
                node:setNum(v2.num)
                node:setPositionY(node:getContentSize().height)
                gAddMapCenter(node, nodeBg)
            end
        end
    end
end

function Activity19Panel:dealEvent(event,param)
    -- print("event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_19 )then
        self:setData()
    elseif(event==EVENT_ID_GET_ACTIVITY_19_REC)then
        --按钮暗掉
        local num = param
        self:setBtn(num)
    end
end   

return Activity19Panel