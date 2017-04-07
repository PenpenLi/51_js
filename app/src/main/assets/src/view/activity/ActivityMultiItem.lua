local ActivityMultiItem=class("ActivityMultiItem",UILayer)

function ActivityMultiItem:ctor(type)
	self.curActData = nil
    self.touchTable={}
    self.tipTable={}
    self:init("ui/ui_hd_buy2_item.map")
end


function ActivityMultiItem:onTouchBegan(target,touch)
    if(self.touch==false)then
        return
    end
    if self.touchTable[target.touchName]==nil and self.tipTable[target.touchName]~=nil then
        print("====popTouchTip")
        local tip= Panel.popTouchTip(self,TIP_TOUCH_EQUIP_ITEM,self.tipTable[target.touchName])
        self.beganPos = touch:getLocation();
    end
end

function ActivityMultiItem:onTouchMoved(target,touch)
    if self.touchTable[target.touchName]==nil and self.tipTable[target.touchName]~=nil then
        print("====onTouchMoved")
        self.endPos = touch:getLocation();
        local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
        if dis > gMovedDis then
            Panel.clearTouchTip();
        end
    end
end


function ActivityMultiItem:onTouchEnded(target)
    if  target.touchName=="btn_get"then
    	local params = {
    		type=2,
    		items=self.curData.items,
    		actId=self.curActData.actId,
    		detid=self.curData.idx,
            price = self.price,
    		maxNum=self.curData.cnt-self.curData.count
    	}
    	
        if table.count(self.curData.items)==1 then
            Net.sendBuyItem29(self.curActData.actId,self.curData.idx,self.curData.items[1].itemid,1)
        else
            Panel.popUp(PANEL_MULTIITEM_OPEN_BOX,params)
        end
    elseif self.touchTable[target.touchName] ~=nil then
        local itemid = self.touchTable[target.touchName]
        Panel.popUp(PANEL_ACTIVITY_OPEN_BOX,{boxid=itemid})
    end
    Panel.clearTouchTip();
end

function ActivityMultiItem:setData(data)
    self.curData=data
    local itemNum = table.count(self.curData.items)
    self.oldprice = 1
    self.price  = 0
    for k,item in pairs(self.curData.items) do
    	item.itemnum = item.num
    	if item.oldprice then
    		self.oldprice = item.oldprice 
    	end
    	if item.price then
    		self.price = item.price 
    	end
        local quality = DB.getItemQuality(item.itemid);
 		if(quality == nil) then
 			quality = 5
 		end

        local db,type= DB.getItemData(item.itemid)
        if type==ITEMTYPE_BOX and db and db.type == 2 then
            --self:setTouchEnable("icon"..k,true)
            self.touchTable["icon"..k]=item.itemid
        end
        self.tipTable["icon"..k]=item.itemid
        self:setTouchCDTime("icon"..k,0)
        
    	Icon.setIcon(toint(item.itemid),self:getNode("icon"..k),quality,awakeLv)
        local num,needShort = gGetNumForShort(item.num,1000000,false);
        if needShort then
            self:setLabelString("txt_num"..k,num.."w")
        else
            self:setLabelString("txt_num"..k,num)
        end
    	--self:setLabelString("txt_num"..k,item.num)
    	if(DB.getSoulNeedLight(item.itemid))then
            Icon.addSpeEffectForSoul(self:getNode("icon"..k))
        	--:addSpeEffectForSoul();
    	end
    end

    for i=itemNum+1,5 do
    	if self:getNode("or"..i-1) then
    		self:getNode("or"..i-1):setVisible(false)
    	end
    	if self:getNode("icon"..i) then
    		self:getNode("icon"..i):setVisible(false)
    	end
    end
    self:setLabelString("txt_price",self.price)
    local leftAcount = self.curData.cnt-self.curData.count
    self:replaceLabelString("text_count",leftAcount)
    if leftAcount<=0 then
    	self:setTouchEnableGray("btn_get",false)
    end
    local discount=self.price*10/self.oldprice
    if discount>=0 and discount <=10 then
        self:replaceLabelString("txt_discount",  string.format("%1.1f", discount) )
    end
    
    self:resetLayOut()
end

function ActivityMultiItem:refreshData(param)
    self:setData(self.curData)
end


return ActivityMultiItem