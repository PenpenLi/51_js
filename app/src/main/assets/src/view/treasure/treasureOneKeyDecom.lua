local TreasureOneKeyDecom=class("TreasureOneKeyDecom",UILayer)

function TreasureOneKeyDecom:ctor() 
    self:init("ui/ui_treasure_equip_soul.map")
    self:getNode("scroll").eachLineNum=5
    self:getNode("scroll").offsetX=1
    self:initSelData()
end


function TreasureOneKeyDecom:initSelData()
	self.curShowItems = {}
    for key, var in pairs(gUserTreasure) do
    	if(var.cardid==0 and self.curShowItems[var.id]==nil )then
            self.curShowItems[var.id]=var
        end
    end
    for i=1,4 do
    	self:setNodeStatus("icon_quality"..i,false)
    	self:setNodeStatus("icon_type"..i,false)
    end
    self.qualitys={}
    self.types={}
    self.qualitys[QUALITY1]=false
    self.qualitys[QUALITY3]=false
    self.qualitys[QUALITY5]=false
    self.qualitys[QUALITY8]=false
    for i=0,3 do
    	self.types[i]=false
    end
    self:initTreasureItem(self.types,self.qualitys)
end

--quality== QUALITY2 or quality== QUALITY4 or quality== QUALITY6 or quality== QUALITY9

function TreasureOneKeyDecom:initTreasureItem(types,qulitys)

	self:getNode("scroll"):clear()
	local card=Data.getUserCardById(self.curCardid)
	local drawNum=20
    for key, var in pairs(self.curShowItems) do
    	local treasure=DB.getTreasureById(var.itemid)
    	local quality = toint(treasure.quality)
    	local ttype = toint(treasure.type)
    	if(types[ttype]~=nil and qulitys[quality]~=nil )then
	       local item=TreasureEquipSoulItem.new()
	        item.idx=key
	        item.type=ttype
	        item.quality=quality
	        if(drawNum>0)then
	            drawNum=drawNum-1
	            item:setData(var)
	        else
	            item:setLazyData(var)
	        end
	        item.selectItemCallback=function ()
	            self.isDirty=true
	            self:updateMergeBtnStatus()
	        end
	        self:getNode("scroll"):addItem(item)
    	end
    end
    self:resortBag() 
    self:getNode("scroll"):layout()
    self:setTouchEnableGray("btn_decom",false)
end

function TreasureOneKeyDecom:resortBag() 
    for key, var in pairs(self:getNode("scroll").items) do
        local curType=3- var.curData.db.type
        var.tmpSort=curType+var.curData.db.quality*1000+var.curData.starlv*100000
    end

    local function sortFunc(item1,item2)
        return item1.tmpSort>item2.tmpSort
    end
    table.sort(self:getNode("scroll").items,sortFunc)
end

function TreasureOneKeyDecom:updateMergeBtnStatus()
	local enableTouch = false
	for key, item in pairs(self:getNode("scroll").items) do
        if(item.curSelectNum>0)then
            enableTouch = true
            break
        end
    end
    self:setTouchEnableGray("btn_decom",enableTouch)
end

function TreasureOneKeyDecom:setNodeStatus(name,isSel)
	if isSel then
		self:changeTexture(name,"images/ui_public1/n-di-gou2.png")
	else
		self:changeTexture(name,"images/ui_public1/n-di-gou1.png")
	end
	
end

function TreasureOneKeyDecom:events()
	return {EVENT_ID_TREASURE_OKDECOMPOSE}
end

function TreasureOneKeyDecom:dealEvent(event,data)
	if event==EVENT_ID_TREASURE_OKDECOMPOSE then
		self:initSelData()
	end
end

function TreasureOneKeyDecom:selectTreasureItem(types,qulitys)

	local tmpTypes = clone(types)
	local tmpQulitys = clone(qulitys)

    local typseNoAllSelStauts = false
    if types[0]==false and types[1]==false and types[2]==false and types[3]==false then
    	typseNoAllSelStauts = true
    end

    local qualityNoAllSelStauts = false
    if qulitys[QUALITY1]==false and qulitys[QUALITY3]==false and qulitys[QUALITY5]==false and qulitys[QUALITY8]==false then
    	qualityNoAllSelStauts = true
    end

    if typseNoAllSelStauts==false and qualityNoAllSelStauts==true then
    	for key,value in pairs(tmpQulitys) do
			tmpQulitys[key] = true 
		end
    end
    if typseNoAllSelStauts==true and qualityNoAllSelStauts==false then
    	for key,value in pairs(tmpTypes) do
			tmpTypes[key] = true 
		end
    end

    for key, item in pairs(self:getNode("scroll").items) do
        if(tmpTypes[item.type]==true and tmpQulitys[item.quality]==true )then
            item:setRemainNum(0)
        else
            item:setUnSelect()
        end        
    end
    self:updateMergeBtnStatus()
end


function TreasureOneKeyDecom:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_decom"then
    	local listItems = {}
    	for key, item in pairs(self:getNode("scroll").items) do
            if(item.curSelectNum>0)then
                table.insert(listItems,item.curData)
            end
        end
    	Panel.popUp(PANEL_TREASURE_OKDECOM_PANEL,listItems)

    elseif target.touchName and string.find(target.touchName,"check_trea") then
    	local index = toint(string.sub(target.touchName,-1))-1
    	self.types[index] = not self.types[index]
    	self:setNodeStatus("icon_type"..index+1,self.types[index])
    	self:selectTreasureItem(self.types,self.qualitys)
    elseif target.touchName and string.find(target.touchName,"check_quality") then
    	local index = toint(string.sub(target.touchName,-1))
    	if index==1 then
    		self.qualitys[QUALITY1]= not self.qualitys[QUALITY1]
    		self:setNodeStatus("icon_quality1",self.qualitys[QUALITY1])
    	elseif index==2 then
    		self.qualitys[QUALITY8]= not self.qualitys[QUALITY8]
    		self:setNodeStatus("icon_quality2",self.qualitys[QUALITY8])
    	elseif index==3 then
    		self.qualitys[QUALITY5]= not self.qualitys[QUALITY5]
    		self:setNodeStatus("icon_quality3",self.qualitys[QUALITY5])
    	elseif index==4 then
    		self.qualitys[QUALITY3]= not self.qualitys[QUALITY3]
	    	self:setNodeStatus("icon_quality4",self.qualitys[QUALITY3])
    	end
    	self:selectTreasureItem(self.types,self.qualitys)
    	
    end
end

return TreasureOneKeyDecom