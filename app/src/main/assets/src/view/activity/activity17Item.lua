local Activity17Item=class("Activity17Item",UILayer)

function Activity17Item:ctor(data)
    self:init("ui/ui_hd_tongyong_item.map")
    -- self.type = data;
    -- print("self.type="..self.type)
end

function Activity17Item:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        Net.sendActivity17Rec(Data.activity17Data.idx,self.curData.idx)
    end
end

function   Activity17Item:setData(key,data)
    self.curData=data
    -- print_lua_table(self.curData)
    if (data.items) then
        local title = data.name
        self:setLabelString("lab_title",title)
        self:setLabelString("lab_count",Data.activity17Data.curd.."/"..Data.activity17Data.maxd)

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

        self:getNode("btn_get"):setVisible(false)
        self:getNode("btn_go"):setVisible(false)
        self:getNode("sign_no"):setVisible(false)
        self:getNode("sign_get"):setVisible(false)
        self:getNode("sign_no_open"):setVisible(false)

        --0:未满足条件 1:时间未到 2:可领取 3:已领取
        if (data.status == 0) then
            self:getNode("sign_no"):setVisible(true)
        elseif (data.status == 1) then
            self:getNode("sign_no_open"):setVisible(true)
        elseif (data.status == 2) then
            self:getNode("btn_get"):setVisible(true)
        elseif (data.status == 3) then
            self:getNode("sign_get"):setVisible(true)
        end

        self:getNode("item_lay"):layout()
    end
    
end

function   Activity17Item:refreshData()
    self:setData(0,self.curData)
end


return Activity17Item