local PetExploreRateBook=class("PetExploreRateBook",UILayer)
function PetExploreRateBook:ctor(parma1,param2)
    self:init("ui/ui_lingshouhuodong_777.map")
    self:addFullScreenTouchToClose()
    for i=1,4 do
    	self:replaceLabelString("txt_rate"..i,Data.petCave.chessMuls[i]/100)
    end
    self:resetLayOut()
end

function PetExploreRateBook:onTouchEnded(target)
	if  target.touchName=="full_close"then
		Panel.popBack(self:getTag())
	end

end

return PetExploreRateBook