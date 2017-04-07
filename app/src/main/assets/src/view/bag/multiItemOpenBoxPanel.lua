local MultiItemOpenBoxPanel=class("MultiItemOpenBoxPanel",UILayer)

function MultiItemOpenBoxPanel:ctor(data)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self:init("ui/ui_tool_buytimes.map")
    self:getNode("scroll"):clear()
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    -- self:getNode("scroll"):setPaddingXY(2,5)
    -- self:getNode("scroll").offsetX = 0
    -- self:getNode("scroll").offsetY = 3

    self.maxNum =0
    self.curData = data
    if self.curData.type == 1  then
        self:getNode("container"):setVisible(false)
        self:getNode("container_times"):setVisible(false)
        self:setBoxItemById(self.curData.boxid);
    else
        self:getNode("container"):setVisible(true)
        self:getNode("container_times"):setVisible(true)
        self:setLabelString("txt_times",self.curData.maxNum)
        self:setLabelString("txt_dia",self.curData.price)
        self.maxNum =self.curData.maxNum
        self:setItems(self.curData.items);
    end
    self:resetLayOut()
    self.buyTimes = 1;
    self:refreshInfo(self.buyTimes);
end
 
function MultiItemOpenBoxPanel:onTouchEnded(target)
    if(target.touchName == "btn_close")then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_sub" then
        self:subBuyTimes(1);
    elseif target.touchName == "btn_add" then
        self:addBuyTimes(1);
    elseif target.touchName == "btn_sub1" then
        self:subBuyTimes(10);
    elseif target.touchName == "btn_add1" then
        self:addBuyTimes(10);  
    elseif(target.touchName == "btn_confirm")then
        if self.curData.type == 1 then
            Net.sendOpenBox(self.curData.boxid,self.buyTimes,self.selItem.curData)
        else
             Net.sendBuyItem29(self.curData.actId,self.curData.detid,self.selItem.curData,self.buyTimes)
        end
        
        
        Panel.popBack(self:getTag())
    end
end


function MultiItemOpenBoxPanel:subBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes - offsetTimes;
    if self.buyTimes < 1 then
        self.buyTimes = 1;
    end
    self:refreshInfo(self.buyTimes);
end

function MultiItemOpenBoxPanel:addBuyTimes(offsetTimes)
    self.buyTimes = self.buyTimes + offsetTimes;
    if self.buyTimes > self.maxNum then
        self.buyTimes = self.maxNum;
    end
    
    if self.buyTimes > DB.getClientParam("ITEM_BOX_OPEN_LIMIT") then
        self.buyTimes = DB.getClientParam("ITEM_BOX_OPEN_LIMIT")
    end
    self:refreshInfo(self.buyTimes);
end

function MultiItemOpenBoxPanel:refreshInfo(buyTimes)
    if self.curData.type ~= 1  then
        self:setLabelString("txt_times",self.maxNum-buyTimes)
    end
    
    self:setLabelAtlas("txt_buy_times",buyTimes); 
    self:resetLayOut();
end

function MultiItemOpenBoxPanel:setSelectItem(index)
    for k,item in pairs(self:getNode("scroll").items) do
        if item.index== index then
            item:changeBtnSelectTexture(true)
            self.selItem = item
        else
            item:changeBtnSelectTexture(false)
        end
    end
end

function MultiItemOpenBoxPanel:setBoxItemById(boxid)
    local db,type= DB.getItemData(boxid)
    if(db==nil)then
        return
    end
    local num=Data.getItemNum(boxid)
    self.maxNum = num; 
    local boxItems = DB.getBoxItemById(boxid)
    self:setItems(boxItems)   
end

function MultiItemOpenBoxPanel:setItems(boxItems)

    local function selectCallBack(index)
        self:setSelectItem(index)
    end
    local  index = 1
    for k,item in pairs(boxItems) do
        local node=MulitItemBox.new() 
        node:setData(item.itemid)
        node:setNum(item.itemnum)
        node.selectCallBack = selectCallBack
        node.index = index
        index = index +1
        self:getNode("scroll"):addItem(node)
    end
    self:setSelectItem(1)
    self:getNode("scroll"):layout()
    
end

return MultiItemOpenBoxPanel
