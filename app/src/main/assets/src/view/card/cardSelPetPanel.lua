local CardSelPetPanel=class("CardSelPetPanel",UILayer)

function CardSelPetPanel:ctor(parma1,param2)

    self:init("ui/ui_lingshou_xuanzhelingshou.map")

    for k,pet in pairs(gUserPets) do
		local petItem = CardSelPetItem.new(self)
		petItem:setData(pet)
		petItem.cardid=parma1
        petItem.sort=2
        if pet.cid>0 then
            petItem.sort=1
        end
		self:getNode("scroll"):addItem(petItem)
    end
     local function sortCallBack(item1,item2)
          return item1.sort>item2.sort;
    end
    table.sort(self:getNode("scroll").items,sortCallBack);
    self:getNode("scroll"):layout()
end

function CardSelPetPanel:onTouchEnded(target)
	if target.touchName=="btn_close"then
		self:onClose()
	end

end

return CardSelPetPanel