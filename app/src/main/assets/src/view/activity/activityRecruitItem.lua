local ActivityRecruitItem=class("ActivityRecruitItem",UILayer)

function ActivityRecruitItem:ctor()
    self:init("ui/ui_hd_zhaomu2_item.map")
end

function ActivityRecruitItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        if (self.curData.num>0) then
            Net.sendActivityRecruitRec(self.curData.id)
        else
        end
    end
end

function ActivityRecruitItem:setData(key,data)
    self.curData=data

    self:getNode("sign_no"):setVisible(false)
    self:getNode("sign_yes"):setVisible(false)
    self:getNode("btn_get"):setVisible(false)
    self:getNode("layout_bg1"):setVisible(false)

    for i=1,4 do
        local nodeBg = self:getNode("reward"..i)
        if(nodeBg)then nodeBg:setVisible(false) end
    end

    -- print_lua_table(data)

    --取数据
    local rData = DB.getRecruitMateById(data.id)
    if (rData) then
        self:setRTFString("lab_title",rData.content)
        
        if (data.id == 1) then--特殊处理
            self:getNode("layout_bg1"):setVisible(true)
            self:getNode("lab_count"):setVisible(false)
            if (Data.activityRecruitData.finish==0) then
                self:getNode("sign_no"):setVisible(true)
            else
                self:getNode("sign_yes"):setVisible(true)
            end
            return
        end

        local word = gGetWords("activityNameWords.plist","137")
        self:setLabelString("lab_count",word..data.num.."/"..data.rnum)
        if (data.num == 0 and data.rnum>0) then
            self:getNode("sign_no"):setVisible(true)
        else
            self:getNode("btn_get"):setVisible(true)
            if (data.rnum == 0) then
                self:setTouchEnable("btn_get",false,true)
            end
        end
        
        local list = {}
        if (rData.item1 and rData.num1) then table.insert(list,{item=rData.item1,num=rData.num1}) end
        if (rData.item2 and rData.num2) then table.insert(list,{item=rData.item2,num=rData.num2}) end
        if (rData.item3 and rData.num3) then table.insert(list,{item=rData.item3,num=rData.num3}) end
        if (rData.item4 and rData.num4) then table.insert(list,{item=rData.item4,num=rData.num4}) end
        
        for k,v in pairs(list) do
            local nodeBg = self:getNode("reward"..k)
            if(nodeBg)then nodeBg:setVisible(true) end
            local node=DropItem.new()
            local itemid = v.item
            local num = v.num
            node:setData(itemid)
            node:setNum(num)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, nodeBg)
        end
    end
    self:getNode("layout_bg"):layout()
    self:getNode("layout_bg1"):layout()
end

function   ActivityRecruitItem:refreshData()
    self:setData(0,self.curData)
end


return ActivityRecruitItem