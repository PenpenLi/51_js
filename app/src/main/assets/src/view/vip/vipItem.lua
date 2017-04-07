local VipItem=class("VipItem",UILayer)

function VipItem:ctor()
    -- self:init("ui/ui_vip_item.map")
    -- self:setTouchEnable("btn_get",false,true)
    -- self.curPirce = 0;
    self:setContentSize(cc.size(886,380));
end

function VipItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_vip_item.map")
    self:setTouchEnable("btn_get",false,true)
    self.curPirce = 0;

end

function VipItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then
        if gUserInfo.vip >= self.curData.vip then
            if NetErr.isDiamondEnough(self.curPirce) then
                Net.sendGiftBuy(toint(self.curData.boxid))
                if (TDGAItem) then
                    gLogPurchase("vipgift.buy",1,self.curPirce)
                end
            end
        else
            local callback = function ()
                Panel.popUp(PANEL_PAY);
            end
            local needDia = self.curData.charge-gUserInfo.vipsc;
            local word = gGetWords("vipWords.plist","vipTip",needDia,self.curData.vip);
            gConfirmCancel(word,callback);
        end
    end
end



function VipItem:setBuyNum()
    local item= Data.getGiftBagBuy(self.curData.boxid)
    local num = 0;
    if(item)then
        num = item.num;
    end
    if(num<=0)then
        self:setTouchEnable("btn_get",true,false)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buy"));
    else
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buyed"));
    end
end


function VipItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"vipItem")
end
function VipItem:setLazyDataCalled()
    self:setData(self.curData);
end

function   VipItem:setData(data)
    self:initPanel();
    self.curData=data

    local word= gGetWords("labelWords.plist","lab_upi_vip_box",data.vip)
    self:setLabelString("lab_upi_vip_box",word)

    word= gGetWords("labelWords.plist","lab_upi_vip",data.vip)
    self:setLabelString("lab_upi_vip",word)


    self:setLabelString("lab_need_pay",data.charge)

    for i=1,6 do
        self:getNode("item"..i):setVisible(false)
    end
    local items =DB.getBoxItemById( data.boxid)
    local idx=1
    for key, item in pairs(items) do
        if( self:getNode("item"..idx))then
            self:getNode("item"..idx):setVisible(true)
            local node=DropItem.new()
            node:setData(item.itemid)
            node:setNum(item.itemnum)
            node:setPositionY(node:getContentSize().height)
            self:getNode("item"..idx):addChild(node)
        end
        idx=idx+1
    end

    if data.boxid == 0 then
        self:getNode("layer_price1"):setVisible(false);
        self:getNode("layer_price2"):setVisible(false);
        self:getNode("btn_get"):setVisible(false);
    else
        local gift=DB.getGiftCommonById(data.boxid)
        if(gift)then
            self:setLabelString("lab_gift_price1",gift.orliprice)
            self:setLabelString("lab_gift_price2",gift.curprice)
            self.curPirce = gift.curprice;
        end
    end

    local shows=string.split(data.show,";")
    if data.vip > 0 then
        table.insert(shows,100);
    end

    self.totalHeight=0
    self:getNode("container").initY=self:getNode("container"):getPositionY()

    local curShows = {};
    for key, show in pairs(shows) do
        local ret = {};
        ret.type = show;
        ret.sortid = toint(key);
        if(self:isHightLight(show))then
            ret.sortid = 0;
        end
        table.insert(curShows,ret);
    end
    -- print_lua_table(shows);

    local sortFun = function(a1,a2)
        return a1.sortid > a2.sortid;
    end
    table.sort(curShows,sortFun);
    -- print("---------")
    -- print_lua_table(curShows);

    self:getNode("container"):setSortByPosFlag(false);
    for key, show in pairs(curShows) do
        local item=VipItemDetail.new(self)
        item:setData(show.type,data,self:isHightLight(show.type))
        self:getNode("container"):addNode(item);
        -- self:getNode("container"):addChild(item)
        -- item:setPositionY(-item:getContentSize().height*(key-2 ) )

        -- self.totalHeight=item:getContentSize().height+self.totalHeight
    end
    
    self:resetLayOut();
    self.totalHeight = self:getNode("container"):getContentSize().height+10;
    self:setBuyNum();
end

function VipItem:closeAllItemExtend()
    local items = self:getNode("container"):getAllNodes();
    for key,item in pairs(items) do
        if(item)then
            item:setExtend(false);
        end
    end
end

function VipItem:resetContainerSize()
    self:resetLayOut();
    self.totalHeight = self:getNode("container"):getContentSize().height;
    self:resetContainerPos();
end

function VipItem:resetContainerPos(targetY)
    if(targetY == nil)then
        targetY = self:getNode("container"):getPositionY();
    end
    if(targetY<self:getNode("container").initY)then
        targetY=self:getNode("container").initY
    elseif(targetY-self:getNode("container").initY>self.totalHeight-self:getNode("scroll"):getContentSize().height)then
        targetY=self:getNode("container").initY-self:getNode("scroll"):getContentSize().height+self.totalHeight
    end
    self:getNode("container"):setPositionY(targetY)    
end

function VipItem:onTouchMoved(target, touch)
    if(self:getNode("scroll"):getContentSize().height>self.totalHeight)then
        return
    end
    local posY=touch:getDelta().y
    local targetY=self:getNode("container"):getPositionY()+posY
    self:resetContainerPos(targetY);
    -- if(targetY<self:getNode("container").initY)then
    --     targetY=self:getNode("container").initY
    -- elseif(targetY-self:getNode("container").initY>self.totalHeight-self:getNode("scroll"):getContentSize().height)then
    --     targetY=self:getNode("container").initY-self:getNode("scroll"):getContentSize().height+self.totalHeight
    -- end
    -- self:getNode("container"):setPositionY(targetY)
end

function VipItem:isHightLight( show )
    -- body
    local hightlight = string.split(self.curData.highlight,";");
    if hightlight ~= nil then
        for key,var in pairs(hightlight) do
            if var == show then
                return true;
            end
        end
    end
    return false;
end



return VipItem