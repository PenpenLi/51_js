local FamilyDonateCardItem=class("FamilyDonateCardItem",UILayer)

function FamilyDonateCardItem:ctor(param)
	loadFlaXml("ui_kuang_texiao");
	self.parent = param
    self:init("ui/ui_family_juanzeng_wujiang_item.map")
    self:setTouchCDTime("icon",0)
end


function FamilyDonateCardItem:onTouchBegan(target,touch)
    if(self.touch==false)then
        return
    end
    if target.touchName=="icon" then
    	print("====popTouchTip")
    	local tip= Panel.popTouchTip(self,TIP_TOUCH_EQUIP_ITEM,self.itemid)
	    self.beganPos = touch:getLocation();
    end
end

function FamilyDonateCardItem:onTouchMoved(target,touch)
	if target.touchName=="icon" then
		print("====onTouchMoved")
	    self.endPos = touch:getLocation();
	    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
	    if dis > gMovedDis then
	        Panel.clearTouchTip();
	    end
	end
end

function FamilyDonateCardItem:onTouchEnded(target)

    if  target.touchName=="btn_beg" then
    	self.parent:onClose()
        Net.sendFamilyDonateAsk(self.itemid)
    end
    print("===clearTouchTip")
    Panel.clearTouchTip();
end


function FamilyDonateCardItem:setData(data,type)
    
    self.curData = data
    self.type  = type
    if self.type == nil then
    	self.type = 1 --  武将碎片
    end
    if 1 == self.type then
    	local curSoulNum=Data.getSoulsNumById(self.curData.cardid)
		local needSoulNum=DB.getNeedSoulForAll(self.curData.grade,self.curData.cardid,self.curData.awakeLv)
		if needSoulNum<=0 then
			needSoulNum = "MAX"
		end
		self:replaceLabelString("txt_num",curSoulNum.."/"..needSoulNum)
	    self.itemid=self.curData.cardid
	    local itemType = DB.getItemType(self.itemid);
	    if(itemType==ITEMTYPE_CARD or itemType == ITEMTYPE_PET)then
	        self.itemid=self.itemid+ITEM_TYPE_SHARED_PRE
	    end
	    Icon.setIcon(self.itemid,self:getNode("icon"),DB.getItemQuality(self.itemid),nil,nil,true)
	    if(DB.getSoulNeedLight(self.itemid))then
        	Icon.addSpeEffectForSoul(self:getNode("icon"));
    	end
	    local cardDb=DB.getCardById(self.curData.cardid);
	    --local itemName = DB.getItemName(self.itemid,true)
	    self:setLabelString("txt_fragname",cardDb.name)
	else --魔纹碎片
		local treasure=DB.getTreasureById(self.curData.itemid)
		local num = 0
		if(self.curData.num )then
        	num = self.curData.num
		end
		self:replaceLabelString("txt_num",num.."/"..treasure.com_num)
		self:setLabelString("txt_fragname",treasure.name)
		self.itemid =self.curData.itemid
	    --if(self.curData.cardid==nil   )then
	    Icon.setIcon(self.itemid,self:getNode("icon"),treasure.quality,nil,true)

	    self.itemid=self.itemid+ITEM_TYPE_SHARED_PRE
    end
    local dbDonateItem  = DB.getFamilyDonateItem(self.itemid)
    self:setLabelString("txt_maxnum",dbDonateItem.max)
    self:getNode("txt_maxnum"):setLocalZOrder(100)
	self:resetLayOut()

end

return FamilyDonateCardItem