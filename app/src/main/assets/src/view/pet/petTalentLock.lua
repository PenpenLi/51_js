local PetTalentLock=class("PetTalentLock",UILayer)

function PetTalentLock:ctor(parent,param2)

	self.parent = parent
    self:init("ui/ui_lingshou_tianfusuoding.map")

    self._panelTop=true
    self.isWindow=true
    self.talentLocks={}
    self.talentOpens={}
    self.unlockst=self.parent.curData.unlockst

     for i=1,8 do
        local stidNode = self:getNode("btn_lock"..i)
        local icon_Node = self:getNode("icon_"..i)
        stidNode.cdTime=0
        icon_Node.cdTime=0
        local islock = false
        if (self.parent.curData.stlocks[i]~=nil and self.parent.curData.stlocks[i] == 1) then
            islock = true
        end
        local isOpen = (i<=self.parent.curData.unlockst)
        table.insert(self.talentOpens,isOpen)
        table.insert(self.talentLocks,islock)
    end
    self.init = false
    self:refreshStatus()
end

function PetTalentLock:addSpecTalenUnlock(node)
    if node.isAdd then
        return
    end
    node.isAdd = true
    local lock = cc.Sprite:create("images/ui_atlas/ui/lock.png")
    gRefreshNode(node,lock,cc.p(0.5,0.5),nil,1001)

end

function PetTalentLock:refreshStatus()
	for i=1,8 do
        local stidNode = self:getNode("icon_"..i)
        local itemid=self.parent.curData["stid"..i]
        if self.init==false then
            if itemid>0 then
                local stvar=DB.getSpecialTalentById(itemid)
                self:setLabelString("txt_name"..i,stvar.name)
                Icon.setPetTalentSkillIcon(itemid,stidNode)
            else
                self:setLabelString("txt_name"..i,"")
            end
        end

        if self.talentOpens[i] then
        	local isLock = self.talentLocks[i]
            self:getNode("btn_lock"..i):setVisible(false)
            if itemid>0  then
                self:getNode("btn_lock"..i):setVisible(true)
            end
            if isLock then
                self:changeTexture("btn_lock"..i, "images/ui_lingshou/suon.png")
            else
                self:changeTexture("btn_lock"..i, "images/ui_lingshou/suo1.png")
            end
        else
            self:getNode("btn_lock"..i):setVisible(false)
            self:addSpecTalenUnlock(stidNode)
        end
    end
    self.init =true
end

function PetTalentLock:onTouchBegan(target,touch, event)
    self.beganPos = touch:getLocation()
    if (string.find(target.touchName,"icon_")) then
        local idx=toint(string.gsub(target.touchName,"icon_",""))
        local stid = self.parent.curData["stid"..idx]
        if  self.talentOpens[idx] and stid>0 then
            local stidDB = DB.getSpecialTalentById(stid)
            Panel.popTouchTip(target,TIP_TOUCH_TALENT_SKILL,stidDB) 
        end
    end
end

function PetTalentLock:onTouchMoved(target,touch)
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

function PetTalentLock:onTouchEnded(target)
     Panel.clearTouchTip()
	if  target.touchName=="btn_close"then
        local locks = {}
        local posArray = {}
        for i=1,8 do
            if self.talentOpens[i]==true then
                local lock = 0
                if (self.talentLocks[i]== true) then
                    lock=1
                end
                table.insert(locks,lock)
                table.insert(posArray,i)
            end
        end
         Net.sendPetStlock(self.parent.curData.petid,posArray,locks)
		Panel.popBack(self:getTag())
		
	elseif string.find(target.touchName,"btn_lock") then
        local idx=toint(string.gsub(target.touchName,"btn_lock",""))
        local lockNum=0
        for i=1,8 do
            if self.talentLocks[i] == true then
                lockNum=lockNum+1
            end 
        end
        if self.talentOpens[idx] and self.parent.curData["stid"..idx]>0 then
            if self.talentLocks[idx]then
            	self.talentLocks[idx]=false
                --gShowNotice(gGetWords("petWords.plist","unlock_talent"))
            else
                if lockNum+1 == self.unlockst then
                     gShowNotice(gGetWords("petWords.plist","retain_one_cell"))
                    return
                end

                if lockNum>=PET_LOCKS_NUM then
                    gShowNotice(gGetWords("petWords.plist","full_locks",PET_LOCKS_NUM))
                    return
                end
                self.talentLocks[idx]=true
                --gShowNotice(gGetWords("petWords.pList","lock_talent"))
            end
            self:refreshStatus()
        else
            if self.talentOpens[idx] == false then
                gShowNotice(gGetWords("petWords.plist","unlock_"..idx))
            end

        end
	end

end

return PetTalentLock