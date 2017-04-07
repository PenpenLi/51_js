local CardSelPetItem=class("CardSelPetItem",UILayer)

function CardSelPetItem:ctor(parma1,param2)
	self.parent=parma1
end


function CardSelPetItem:setData(data)

	self.curData=data
	if self.inited~=true then
		self:init("ui/ui_lingshou_xuanzhelingshou_item.map")
	end
    self.inited=true

   	local petdb= DB.getPetById(data.petid)
   	self:setLabelString("txt_name", petdb.name)
   	Icon.setIcon(data.petid,self:getNode("icon"),DB.getItemQuality(data.petid),data.awakeLv)

    local grade = Pet.convertToGrade(self.curData.level);--math.floor((self.curData.level-1)/10)+1;
    grade = math.max(1,grade);
    local level = (self.curData.level-1)%10+1;
    level = math.max(1,level);
    self:replaceLabelString("txt_awakelv",grade,level);

   	-- local talentNum = 0
   	-- for i=1,10 do
   	-- 	if data["stid"..i] and data["stid"..i]>0 then
   	-- 		talentNum=talentNum+1
   	-- 	end
   	-- end
    self:setLabelString("txt_talent","")
    if data.cid>0 then
      local cardDb = DB.getCardById(data.cid);
      self:setLabelString("txt_talent", gGetWords("petWords.plist","possess_to_card",cardDb.name))
      self:setTouchEnableGray("btn_poss", false)
    end
   	
   	self:resetLayOut()
end

function CardSelPetItem:onTouchEnded(target)
	if target.touchName=="btn_poss"then
		self.parent:onClose()
		Net.sendPetPossess(self.curData.petid,self.cardid)
	end

end


return CardSelPetItem