local WorldBossRewardItem=class("WorldBossRewardItem",UILayer)

function WorldBossRewardItem:ctor()
end

function WorldBossRewardItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_shijieboss_jiangli_item.map")

end

function WorldBossRewardItem:setLazyDataCalled()
    self:setData(self.curData)
end


function WorldBossRewardItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"featItem")
end


function WorldBossRewardItem:setData(data)
    self:initPanel()
    self.curData=data 

    self:replaceLabelString("lab_boss_lv",data.level)
    self:replaceLabelString("lab_prog",self.level.."/"..data.level)

    if data.itemid1 and data.itemid1 > 0 then
        Icon.setDropItem(self:getNode("icon1"),data.itemid1,data.itemnum1)
    else
        self:getNode("icon1"):setVisible(false)
    end
    
    if data.itemid2 and data.itemid2 > 0 then
        Icon.setDropItem(self:getNode("icon2"),data.itemid2,data.itemnum2)
    else
        self:getNode("icon2"):setVisible(false)
    end

    if data.itemid3 and data.itemid3 > 0 then
        Icon.setDropItem(self:getNode("icon3"),data.itemid3,data.itemnum3)
    else
        self:getNode("icon3"):setVisible(false)
    end

    self:getNode("icon_reced"):setVisible(false)
    self:getNode("icon_canrec"):setVisible(false)
    self:getNode("icon_unreach"):setVisible(false)
    if(data.rec==1)then
        self:getNode("icon_reced"):setVisible(true)
            
    elseif(data.canrec==1)then
        self:getNode("icon_canrec"):setVisible(true)
        
    else
        self:getNode("icon_unreach"):setVisible(true)
    end
end


function WorldBossRewardItem:onTouchEnded(target)
    if(target.touchName=="icon_canrec" and self.curData.canrec==1 and self.curData.rec==0)then
        Net.sendWorldBossGetKillReward(self.curData.idx)
    end

end

return WorldBossRewardItem