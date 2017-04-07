local ActivityLoginRewardItem=class("ActivityLoginRewardItem",UILayer)

function ActivityLoginRewardItem:ctor(actId)
    self.actId = actId
    self.dia = 0 --补签砖石
    self:init("ui/ui_hd_tongyong_item.map")
end

function ActivityLoginRewardItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        Net.sendActivityHolidaySign(self.actId,self.curData.idx)
    elseif(target.touchName=="btn_go") then
         --补签
        local word = gGetWords("activityNameWords.plist","74",self.dia);
        local callback = function()
            Net.sendActivityHolidaySign(self.actId,self.curData.idx)
        end
        gConfirmCancel(word,callback);
    end
end

function   ActivityLoginRewardItem:setData(key,data)
    self.curData=data

    local activityData = nil;
    activityData = Data.activityHolidaySign;

    if (data.items) then
        local info1 = data.items[1]
        self.dia = info1.p1
        -- print_lua_table(info1)
        local title = gGetWords("activityNameWords.plist","login_reward")
        self:setLabelString("lab_title",gParserMonDay(data.stime)..title)
        -- print("类型="..info1.itemid..",已经完成几次="..activityData.var)

        self:getNode("lab_count"):setVisible(false)
        local size = (#data.items)
        -- print("size = "..size)
        for i=1,5 do
            self:getNode("icon"..i):setVisible(false)
            if (size>=i) then
                self:getNode("icon"..i):setVisible(true)
                local info = data.items[i]
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

        local curtime = gGetCurServerTime()
        if data.status == 4 then
            self:getNode("sign_get"):setVisible(true)
            self:getNode("btn_get"):setVisible(false)
            self:getNode("btn_go"):setVisible(false)
            self:getNode("sign_no_open"):setVisible(false)
        elseif data.status == 1 then
            self:getNode("btn_get"):setVisible(true)
            self:getNode("sign_get"):setVisible(false)
            self:getNode("btn_go"):setVisible(false)
            self:getNode("sign_no_open"):setVisible(false)
            self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_sign")) 
        elseif data.status == 2 then
            self:getNode("btn_get"):setVisible(false)
            self:getNode("sign_get"):setVisible(false)
            self:getNode("btn_go"):setVisible(true)
            self:getNode("sign_no_open"):setVisible(false)
            self:setLabelString("btn_go_txt",gGetWords("btnWords.plist","btn_go_sign"))
        elseif data.status == 3 then
            self:getNode("sign_get"):setVisible(false)
            self:getNode("btn_get"):setVisible(false)
            self:getNode("btn_go"):setVisible(false)
            self:getNode("sign_no_open"):setVisible(true)
        end
        
        self:getNode("item_lay"):layout()
    end
    
end

function   ActivityLoginRewardItem:refreshData()
    self:setData(0,self.curData)
end


return ActivityLoginRewardItem