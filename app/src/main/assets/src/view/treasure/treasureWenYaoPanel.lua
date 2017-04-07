local TreasureWenYaoPanel=class("TreasureWenYaoPanel",UILayer)

function TreasureWenYaoPanel:ctor(treasure,callback) 
    self:init("ui/ui_treasure_wenyao.map")
    self.treasure = treasure
    self.callback = callback
    for k,buff in pairs(treasure.buffList) do
    	Icon.setBuffIcon(buff.sid,self:getNode("bufficon"..k))
    	self:replaceLabelString("txt_lv"..k,buff.slv)
    end
    self:buffIconSelect("bufficon1")
    local resetDiamond=DB.getClientParam("TREASURE_STAR_SKILL_RESET_DIAMOND",true)
    self:setLabelString("txt_resetdia", resetDiamond)
    
end

function TreasureWenYaoPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
    	self.callback()
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_reset"then
    	local function onOkCallBack()
    		Net.sendTreasureStarSkillre(self.treasure.id)
    	end
    	gConfirmCancel(gGetWords("treasureWord.plist","reset_skill"),onOkCallBack,nil)
    elseif  target.touchName=="btn_upgrade"then
    	Net.sendTreasureStarSkillUp(self.treasure.id,self.treasure.buffList[self.index].sid)
    elseif  string.find(target.touchName,"bufficon") then
    	self:buffIconSelect(target.touchName)
    end
end


function TreasureWenYaoPanel:events()
    return {
        EVENT_ID_WENYAO_UPGRADE,
        EVENT_ID_WENYAO_RESET
    }
end

function TreasureWenYaoPanel:dealEvent(event,data)
	if event == EVENT_ID_WENYAO_UPGRADE then
		self:buffIconSelect("bufficon"..self.index)
	elseif event == EVENT_ID_WENYAO_RESET then
		for k,buff in pairs(self.treasure.buffList) do
	    	Icon.setBuffIcon(buff.sid,self:getNode("bufficon"..k))
	    	self:replaceLabelString("txt_lv"..k,buff.slv)
	    	self:buffIconSelect("bufficon"..self.index)
	    end
	end
	 
end

function TreasureWenYaoPanel:buffIconSelect(touchName)
	local pos = cc.p(self:getNode(touchName):getPosition())
	self:getNode("choose_icon"):setPosition(pos.x, pos.y)
	self.index = toint(string.sub(touchName,-1))
	local buff = self.treasure.buffList[self.index]
	if buff then
		local budffdb = DB.getBuffById(buff.sid)
		local curTreaBuffDB= DB.getTreasureStarBuff(buff.sid,buff.slv)
		local curAttrvalue = 0
		if curTreaBuffDB then
            curAttrvalue = budffdb.attr_value0+budffdb.attr_add_value0*(curTreaBuffDB.valuelevel-1)
        end
        local maxlv=DB.getMaxTreasureStarBuffLv(buff.sid)
        local nextlv = buff.slv+1
        local fulllevel = false
        if nextlv> maxlv then
        	nextlv=maxlv
        	fulllevel = true
        end
        local nextAttrvalue = 0
		local nextTreaBuffDB= DB.getTreasureStarBuff(buff.sid,nextlv)
		if nextTreaBuffDB then
            nextAttrvalue = budffdb.attr_value0+budffdb.attr_add_value0*(nextTreaBuffDB.valuelevel-1)
        end
        local attrid = budffdb.attr_id0
		self:setLabelString("txt_attr",CardPro.getAttrName(attrid)) 
		self:setLabelString("txt_num1","+"..CardPro.getAttrValue(attrid,curAttrvalue))
		self:setLabelString("txt_num2","+"..CardPro.getAttrValue(attrid,nextAttrvalue))
		self:replaceLabelString("txt_maxlv",maxlv)
		self:replaceLabelString("txt_lv"..self.index,buff.slv)
		self:replaceLabelString("txt_nextlv",buff.slv)
		self:setLabelString("txt_upgradedia",self.treasure.starpoint.."/"..nextTreaBuffDB.costpoint)
		self:getNode("txt_upgradedia"):setColor(cc.c3b(0,255,0));
		if self.treasure.starpoint<nextTreaBuffDB.costpoint then
			self:getNode("txt_upgradedia"):setColor(cc.c3b(255,0,0));
		end
		self:setTouchEnableGray("btn_upgrade", not fulllevel)
		if fulllevel then
        	self:setLabelString("txt_upgradedia",gGetWords("treasureWord.plist","full_level"))
        end
	end
	self:resetLayOut()
end

return TreasureWenYaoPanel