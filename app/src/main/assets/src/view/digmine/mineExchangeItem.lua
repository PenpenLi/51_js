local MineExchangeItem=class("MineExchangeItem",UILayer)

function MineExchangeItem:ctor()
    self:init("ui/ui_mine_exchange_item.map")
end

function MineExchangeItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        gDigMine.exItemIdx = self.curData.idx
        Net.sendMiningExchange(self.curData.id,self.curData.idx)
    end
end

function   MineExchangeItem:setData(idx,data)
    self.idx = idx
    self.curData = data

    -- Icon.setIcon( data.itemidList[2],self:getNode("icon"),DB.getItemQuality(data.itemidList[2]))

    

    -- self:setLabelString("txt_num2",data.numList[2])
    -- self:setLabelString("txt_num",(data.max - data.cur).."/"..data.max)
    -- self:setLabelString("txt_price1", data.numList[1])
    -- self:setLabelString("txt_price2", data.numList2[1])

    local size = #data.itemInfo  --data.itemidList
    -- self.curData.bol_rec = {};
    for i=1,3 do
        -- self.curData.bol_rec[i] = true;
        self:getNode("icon"..i):setVisible(false)
        if (i>1) then
            self:getNode("add"..i):setVisible(false)
        end

        self:getNode("icon"..i):setVisible(true)
        local node=DropItem.new()
        node:setData(data.itemInfo[i].id)
        node:setNum(0)
        node:setPositionY(node:getContentSize().height)
        gAddMapCenter(node, self:getNode("icon"..i))

        if (i>1) then
            self:getNode("add"..i):setVisible(true)
        end

        self:setLabelString("lab_num"..i, Data.getItemNum(data.itemInfo[i].id).."/"..data.itemInfo[i].num)
        if (Data.getItemNum(data.itemInfo[i].id) < data.itemInfo[i].num) then
            self:getNode("lab_num"..i):setColor(cc.c3b(209,0,0));
        else
            self:getNode("lab_num"..i):setColor(cc.c3b(52,169,0));
        end
    end

    local node=DropItem.new()
    node:setData(data.exitemInfo.id)
    node:setNum(data.exitemInfo.num)
    node:setPositionY(node:getContentSize().height)
    gAddMapCenter(node, self:getNode("icon"..4))

    self:setLabelString("lab_num4",DB.getItemName(data.exitemInfo.id))
 
    self:replaceLabelString("txt_num",data.num,data.maxnum);
    if(data.num>=data.maxnum)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end

    self:getNode("item_lay"):layout()
end

function MineExchangeItem:refreshData()
    self:setData(gDigMine.exItemIdx,self.curData)
end

function MineExchangeItem:addNumOne()
    self.curData.num = self.curData.num + 1
end


return MineExchangeItem