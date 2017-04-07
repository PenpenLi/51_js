local PetTalentProtPanel=class("PetTalentProtPanel",UILayer)

function PetTalentProtPanel:ctor(parma1,param2)
	self.curData=parma1
	self._panelTop=true
    self:init("ui/ui_lingshou_tianfuhuyou.map")

    self:replaceLabelString("txt_des",Data.pet.possessAddRate)
    self:getNode("poss_layer"):setVisible(false)
    self.petInfo = Data.getUserPetById(self.curData.pid)
    for i=1,8 do
    	local stid = self.petInfo["stid"..i]
    	if stid>0 then
    		Icon.setPetTalentSkillIcon(stid,self:getNode("icon_talent"..i))
    	end
        local isOpen = (i<=self.petInfo.unlockst)
        if isOpen==false then
            local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png")
            lock:setLocalZOrder(1001)
            gRefreshNode(node,lock,cc.p(0.5,0.5),nil,1001)
        end
    end
    local attrAdd={}
    local isWakedup = self.petInfo.grade > 5
    local petDBInfo= DB.getPetById(self.petInfo.petid)
    for key, var in pairs(pet_upgrade_db) do
        if(var.petid==self.petInfo.petid and var.level<=self.petInfo.level)then
            if(attrAdd[var.attr_id]==nil)then
                attrAdd[var.attr_id]=0
            end
            local attr_value = var.attr_value
            if isWakedup then
                attr_value = var.attr_value * (1 + petDBInfo.wakeup_attrpercent / 100)
            end
            attrAdd[var.attr_id]=attrAdd[var.attr_id]+attr_value;
        end
    end
    local attrs={Attr_HP,Attr_PHYSICAL_ATTACK,Attr_PHYSICAL_DEFEND,Attr_MAGIC_DEFEND}
    local db=DB.getPetById(self.petInfo.petid)
    if(db and (db["attr_value_grade"..self.petInfo.grade] or isWakedup))then
        local addStr=    db["attr_value_grade"..self.petInfo.grade];
        if isWakedup then
            addStr=db["attr_value_grade5"];
        end
        local addData = string.split(addStr,";");
        for key, var in pairs(attrs) do
            if(attrAdd[var]==nil)then
                attrAdd[var]=0
            end
            if isWakedup then
                addData[key] = addData[key] * (1 + petDBInfo.wakeup_attrpercent / 100)
            end
            attrAdd[var]=attrAdd[var]+addData[key]
        end
    end


    local rate = Data.pet.possessAddRate/100
    
    for key, attr in pairs(attrs) do
        local addAttr=0
        if(attrAdd[attr]~=nil)then
            addAttr=math.floor(attrAdd[attr])
        end
        self:setLabelString("txt_attr"..attr,"")
        self:setLabelString("txt_add_attr"..attr, "+"..math.rint(addAttr*rate))
    end


    Icon.setIcon(self.curData.cardid,self:getNode("icon_card"),self.curData.quality,self.curData.awakeLv)
    Icon.setIcon(self.curData.pid,self:getNode("icon_pet"),nil,self.petInfo.awakeLv)
    self:resetLayOut()
end


function PetTalentProtPanel:onTouchBegan(target,touch, event)
    self.beganPos = touch:getLocation()
    if (string.find(target.touchName,"icon_talent")) then
        local idx=toint(string.gsub(target.touchName,"icon_talent",""))
        local stid = self.petInfo["stid"..idx]
        if stid and stid>0 then
            local stidDB = DB.getSpecialTalentById(stid)
            Panel.popTouchTip(target,TIP_TOUCH_TALENT_SKILL,stidDB) 
        end
    end
end


function PetTalentProtPanel:onTouchMoved(target,touch)
    local offsetX=touch:getDelta().x;
    local offsetY=touch:getDelta().y;
    if(math.sqrt(offsetX*offsetX+offsetY*offsetY)>5)then
        self.isMoved=true
    end
    if(self.isMoved)then
        self:unscheduleUpdate()
    end
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function PetTalentProtPanel:onTouchEnded(target)
     Panel.clearTouchTip()
	if  target.touchName=="btn_close"then
		Panel.popBack(self:getTag())
	elseif target.touchName=="btn_falloff"then
		Net.sendPetPossunload(self.curData.cardid)
		self:onClose()
	elseif target.touchName=="btn_change"then
		Panel.popUp(PANNEL_CARD_SELECT_PET,self.curData.cardid)
	end

end


return PetTalentProtPanel