local LuckWheelRewardItem=class("LuckWheelRewardItem",UILayer)

function LuckWheelRewardItem:ctor()
 

end

function LuckWheelRewardItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_luck_wheel_reward_item.map")

end

function LuckWheelRewardItem:setLazyDataCalled()
    self:setData(self.curData)
end


function LuckWheelRewardItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"wheelreward")
end


function LuckWheelRewardItem:setData(data)
    self:initPanel()
    self.curData=data 
    self:setLabelString("txt_name",  DB.getItemName(data.rewardid).."x"..data.num)
    Icon.setIcon(data.rewardid,self:getNode("icon") )

    self:setLabelString("txt_per",gLuckWheel.score .."/"..data.need)
    
    self:replaceLabelString("txt_info",data.need)
    
    self:getNode("icon_reced"):setVisible(false)
    self:getNode("icon_canrec"):setVisible(false)
    self:getNode("panel_num"):setVisible(false)  
    if(data.rec==1)then
        self:getNode("icon_reced"):setVisible(true)
            
    elseif(data.canrec==1)then
        self:getNode("icon_canrec"):setVisible(true)
        
    else
        self:getNode("panel_num"):setVisible(true) 
        self:resetLayOut() 
    end
end


function LuckWheelRewardItem:onTouchEnded(target)
    if(target.touchName=="icon_canrec" and self.curData.canrec==1 and self.curData.rec==0)then 
        Net.sendGetLuckWheelReward(self.curData.id-1)
    end

end


return LuckWheelRewardItem