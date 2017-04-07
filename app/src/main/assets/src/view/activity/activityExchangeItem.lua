local ActivityExchangeItem=class("ActivityExchangeItem",UILayer)

function ActivityExchangeItem:ctor()
    self:init("ui/ui_hd_fuli_item.map")
    self.bolNoItem = false--道具不足
end

function ActivityExchangeItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        if(self.bolNoItem)then
            local sWord = gGetWords("activityNameWords.plist","138")
            gShowNotice(sWord)
            return
        end
        Net.sendActivityExchangeRec(self.curData.idx,self.curActData)
    end
end

function   ActivityExchangeItem:setData(key,data)
    self.curData=data

    -- Icon.setIcon( data.itemidList[2],self:getNode("icon"),DB.getItemQuality(data.itemidList[2]))

    

    -- self:setLabelString("txt_num2",data.numList[2])
    -- self:setLabelString("txt_num",(data.max - data.cur).."/"..data.max)
    -- self:setLabelString("txt_price1", data.numList[1])
    -- self:setLabelString("txt_price2", data.numList2[1])

    local size = #data.itemidList
    -- print("size = "..size)
    -- self.curData.bol_rec = {};
    self.bolNoItem = false
    for i=1,3 do
        -- self.curData.bol_rec[i] = true;
        self:getNode("icon"..i):setVisible(false)
        if (i>1) then
            self:getNode("add"..i):setVisible(false)
        end
        if (size-1>=i) then
            self:getNode("icon"..i):setVisible(true)
            local node=DropItem.new()
            node:setData(data.itemidList[i])
            node:setNum(0)
            node:setPositionY(node:getContentSize().height)
            gAddMapCenter(node, self:getNode("icon"..i))

            if (i>1) then
                self:getNode("add"..i):setVisible(true)
            end

            self:setLabelString("lab_num"..i, data.numInBagList[i].."/"..data.numList[i])
            if (data.numInBagList[i]<data.numList[i]) then
                self:getNode("lab_num"..i):setColor(cc.c3b(209,0,0));
                self.bolNoItem = true
            else
                self:getNode("lab_num"..i):setColor(cc.c3b(52,169,0));
            end

        end
    end

    local node=DropItem.new()
    node:setData(data.itemidList[size])
    node:setNum(data.numList[size])
    node:setPositionY(node:getContentSize().height)
    gAddMapCenter(node, self:getNode("icon"..4))

    local db=DB.getItemData(data.itemidList[size])
    if(db)then
        self:setLabelString("lab_num4",db.name)
    else
        self:setLabelString("lab_num4",gGetWords( "item.plist","item_id_"..data.itemidList[size]))
    end
 -- print("data.cur="..data.cur)
 -- print("data.max="..data.max)
    self:replaceLabelString("txt_num",(data.max - data.cur),data.max);
    if(data.cur>=data.max)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end

    self:getNode("item_lay"):layout()
end

function   ActivityExchangeItem:refreshData()
    self:setData(0,self.curData)
end


return ActivityExchangeItem