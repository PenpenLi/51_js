local WeekGiftItem=class("WeekGiftItem",UILayer)

function WeekGiftItem:ctor()
    self:init("ui/ui_gift_item.map")
    self:setTouchEnable("btn_get",false,true)
    self:getNode("txt_num2"):setVisible(false)
    self.curPirce = 0;
end

function WeekGiftItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if self.endtime and self.endtime < gGetCurServerTime() then
            gShowNotice(gGetWords("activityNameWords.plist","act_timeover"))
            return
        end
        
        if (self:getMax() > self.curData.unum) then
            if NetErr.BuyShopItem(self.curData.priceid,self.curData.price) then
                Net.sendActivityBuyWeekGif(toint(self.curData.idx))
            end
        end
    elseif(target.touchName=="icon")then
    	Panel.popUpUnVisible(PANEL_GIFT,self.curData)
    end
end

function WeekGiftItem:setData(data)
    self.curData=data 

    self:setLabelString("txt_name",DB.getItemName(data.boxid))

    local itemType = DB.getItemType(data.boxid)

    self:setLabelString("txt_price1",data.oldprice)
    self:setLabelString("txt_price2",data.price)

    local numInfo =  string.format("%d/%d", data.unum, self:getMax())
    self:getNode("txt_num"):setString(numInfo)
    --宝箱类型
    if(itemType == ITEMTYPE_BOX) then        
        Icon.setBoxIcon(data.boxid,self:getNode("icon"))
        if(data.itemnum > 1)then
            self:getNode("txt_num2"):setVisible(true)
            self:setLabelString("txt_num2",data.itemnum)
        end
    else
        self:setTouchEnable("icon",false,false)
        Icon.setDropItem(self:getNode("icon"), data.boxid,data.itemnum,DB.getItemQuality(data.boxid))
    end

    if(data.priceid==OPEN_BOX_DIAMOND)then
        Icon.changeDiaIcon(self:getNode("cost_icon"))
        Icon.changeDiaIcon(self:getNode("cost_icon2"))
    elseif(data.priceid==OPEN_BOX_EXPLOIT)then
        Icon.changeExploitIcon(self:getNode("cost_icon"))
        Icon.changeExploitIcon(self:getNode("cost_icon2"))
    elseif(data.priceid==OPEN_BOX_FEAT)then
        Icon.changeFeatIcon(self:getNode("cost_icon"))
        Icon.changeFeatIcon(self:getNode("cost_icon2"))
    elseif(data.priceid==OPEN_BOX_GOLD)then
        Icon.changeGoldIcon(self:getNode("cost_icon"))
        Icon.changeGoldIcon(self:getNode("cost_icon2"))
    elseif(data.priceid==OPEN_BOX_REPU)then
        Icon.changeRepuIcon(self:getNode("cost_icon"))
        Icon.changeRepuIcon(self:getNode("cost_icon2")) 
    elseif(data.priceid==OPEN_BOX_FAMILY_DEVOTE)then
        Icon.changeDevoteIcon(self:getNode("cost_icon"))
        Icon.changeDevoteIcon(self:getNode("cost_icon2"))
    elseif(data.priceid==OPEN_BOX_PETMONEY)then
        Icon.changeSeqItemIcon(self:getNode("cost_icon"),OPEN_BOX_PETMONEY)
        Icon.changeSeqItemIcon(self:getNode("cost_icon2"),OPEN_BOX_PETMONEY)
    end

    self:setBuyNum();
    self:resetLayOut();
end

function WeekGiftItem:setBuyNum()
    if(self:getMax() > self.curData.unum)then
        self:setTouchEnable("btn_get",true,false)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buy"));
    else
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","btn_buyed"));
    end
end

function WeekGiftItem:refreshData(param)
    if(self.curData.idx == param)then
        self:setData(self.curData)
    end
end

function WeekGiftItem:getMax()
    if(self.curData.maxlist ~= nil and table.getn(self.curData.maxlist) > Data.getCurVip()) then
        return toint(self.curData.maxlist[Data.getCurVip()+1])
    end
    return 0
end
return WeekGiftItem