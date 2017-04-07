local PetTalentBookPanel=class("PetTalentBookPanel",UILayer)

function PetTalentBookPanel:ctor(parma1,param2)

    self:init("ui/ui_lingshou_tianfudaquan.map")

    self._panelTop=true
    self.isWindow=true
    self.specTalentBook={}
    self.normalTalentBook={}
    local allTalentBook = DB.getPetSpecialTalentBook()
    for k,vars in pairs(allTalentBook) do
    	if vars[1].petid>0 then
    		table.insert(self.specTalentBook,vars)
    	else
    		table.insert(self.normalTalentBook,vars)
    	end
    end
    self:selectTalentBook("btn_spectal")
end

function PetTalentBookPanel:selectTalentBook(touchName)
	local btns = {"btn_spectal","btn_normaltal"}
	for k,btn in pairs(btns) do
		self:changeTexture(btn, "images/ui_public1/b_biaoqian1.png")
		self:getNode(btn.."_des"):setVisible(false)
	end
	self:changeTexture(touchName,"images/ui_public1/b_biaoqian1-1.png")
	self:getNode(touchName.."_des"):setVisible(true)
	local drawNum = 6
	Scene.clearLazyFunc("PetTalentBookItem")
	self:getNode("scroll"):clear()
	if touchName=="btn_normaltal" then
		for k,var in pairs(self.normalTalentBook) do
			local bookItem = PetTalentBookItem.new()
			if drawNum>0 then
				bookItem:setData(var)
			else
				bookItem:setLazyData(var)
			end
			drawNum=drawNum-1
			self:getNode("scroll"):addItem(bookItem)
		end
	else
		for k,var in pairs(self.specTalentBook) do
			local bookItem = PetTalentBookItem.new()
			if drawNum>0 then
				bookItem:setData(var)
			else
				bookItem:setLazyData(var)
			end
			drawNum=drawNum-1
			self:getNode("scroll"):addItem(bookItem)
		end
	end
	self:getNode("scroll"):layout()
end



function PetTalentBookPanel:onTouchEnded(target)
	if  target.touchName=="btn_close"then
		Panel.popBack(self:getTag())
	elseif target.touchName=="btn_normaltal" or target.touchName=="btn_spectal" then
		self:selectTalentBook(target.touchName)
	end

end

return PetTalentBookPanel