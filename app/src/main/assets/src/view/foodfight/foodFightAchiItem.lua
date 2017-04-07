local FoodFightAchiItem=class("FoodFightAchiItem",UILayer)

function FoodFightAchiItem:ctor()
 

end

function FoodFightAchiItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_crusade_feat_item.map")

end

function FoodFightAchiItem:setLazyDataCalled()
    self:setData(self.curData)
end


function FoodFightAchiItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"featItem")
end


function FoodFightAchiItem:setData(data)
    self:initPanel()
    self.curData=data 
    self:setLabelString("txt_name",  DB.getItemName(data.rewardid).."x"..data.num)
    Icon.setIcon(data.rewardid,self:getNode("icon"))

    self:setLabelString("txt_per", self.curfood .."/"..data.need)
    
    self:setLabelString("txt_info",gGetWords("lootFoodWords.plist","need_food_num",data.need))
    
    self:getNode("icon_reced"):setVisible(false)
    self:getNode("icon_canrec"):setVisible(false)
    self:getNode("panel_num"):setVisible(false)
    if(data.rec==1)then
        self:getNode("icon_reced"):setVisible(true)
            
    elseif(data.canrec==1)then
        self:getNode("icon_canrec"):setVisible(true)
        
    else
        self:getNode("panel_num"):setVisible(true)
        self:changeTexture("sign","images/icon/sep_item/95005.png") 
        self:resetLayOut() 
    end
end


function FoodFightAchiItem:onTouchEnded(target)
    if(target.touchName=="icon_canrec" and self.curData.canrec==1 and self.curData.rec==0)then
        Net.sendLootfoodRecachireward(self.curData.idx)
    end

end


return FoodFightAchiItem