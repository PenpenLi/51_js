local PetExploreReplaceCoin=class("PetExploreReplaceCoin",UILayer)
function PetExploreReplaceCoin:ctor(parma1,param2)
	self.curData = parma1
    self:init("ui/ui_lingshou_tihuan.map")

    local ret=cc.Sprite:create("images/ui_lingshou/jb_"..self.curData.etype..".png")
	ret:setLocalZOrder(2)
	ret:setTag(100);
	gAddCenter(ret, self:getNode("icon1"))

    local index = 1
    for key,value in pairs(Data.petCave.resetCoinNums) do
    	if Data.CaveInfo.coinreset<value then
    		index =key
    		break;
    	end
    end
    local dia = Data.petCave.resetCoinDiamond[index]
    dia = dia or 0
    if dia==0 then
        self:getNode("txt_free"):setVisible(true)
        self:getNode("const_layout"):setVisible(false)
    else
        self:getNode("txt_free"):setVisible(false)
        self:getNode("const_layout"):setVisible(true)
        if isBanshuUser() then
            self:getNode("const_layout"):setVisible(false)
            self:getNode("btn_replace"):setVisible(false);
        end
    end
    self.dia= dia
    self:setLabelString("txt_dia", dia)

    self:setLabelString("txt_coinname","CoinName"..self.curData.etype, "petWords.plist")

    self:resetLayOut()
end

function PetExploreReplaceCoin:onTouchEnded(target)
	if  target.touchName=="btn_close"then
		Panel.popBack(self:getTag())
	elseif target.touchName=="btn_replace" then
		Net.sendCaveReset(self.curData.pos,self.dia)
		Panel.popBack(self:getTag())
	end

end

return PetExploreReplaceCoin