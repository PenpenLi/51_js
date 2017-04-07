local PetGoldRewardItem=class("PetGoldRewardItem",UILayer)

function PetGoldRewardItem:ctor(parma1,param2)

    self:init("ui/ui_lingshouhuodong_zhuye_item1.map")
end

function  PetGoldRewardItem:setData(data)
    self:setLabelString("txt_direction", "direction_"..data.dir, "labelWords.plist")
    self:setLabelString("txt_addrate", "+"..data.rate/100)
    if data.etype==0 then
    	self:getNode("icon_gold"):setVisible(false)
    	self:getNode("txt_num"):setVisible(false)
    else
    	self:changeTexture("icon_gold", "images/ui_lingshou/jb_"..data.etype..".png")
    end
    
    self:resetLayOut()
end

return PetGoldRewardItem