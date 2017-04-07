local ActivityTuanRewardItem=class("ActivityTuanRewardItem",UILayer)

function ActivityTuanRewardItem:ctor()
 

end

function ActivityTuanRewardItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_crusade_feat_item.map")

end

-- function ActivityTuanRewardItem:setLazyDataCalled()
--     self:setData(self.curData)
-- end


-- function ActivityTuanRewardItem:setLazyData(data)  
--     if(self.inited==true)then
--         return
--     end
--     self.curData=data;
--     Scene.addLazyFunc(self,self.setLazyDataCalled,"featItem")
-- end


function ActivityTuanRewardItem:setData(data)
    self:initPanel()
    self.curData=data 
    self:setLabelString("txt_name",  DB.getItemName(data.rewardid).."x"..data.num)
    -- Icon.setIcon(data.rewardid,self:getNode("icon") )
    Icon.setDropItem(self:getNode("icon"), (data.rewardid),0,DB.getItemQuality(data.rewardid))

    self:setLabelString("txt_per", Data.activityTuanData.score .."/"..data.need)
    
    self:setLabelString("txt_info",gGetWords("labelWords.plist","need_feat_num1",data.need))
    
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
        
        self:changeTexture("sign","images/ui_huodong/jifen.png")
    end
end


function ActivityTuanRewardItem:onTouchEnded(target)
    if(target.touchName=="icon_canrec" and self.curData.canrec==1 and self.curData.rec==0)then
        print(self.curData.idx,self.key)
        Net.sendActivityTuanRewardGet(Data.activityTuanData.idx,self.curData.idx,self.key)
    end

end


return ActivityTuanRewardItem