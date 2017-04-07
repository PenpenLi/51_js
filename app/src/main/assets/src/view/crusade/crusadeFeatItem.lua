local CrusadeFeatItem=class("CrusadeFeatItem",UILayer)

function CrusadeFeatItem:ctor()
 

end

function CrusadeFeatItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_crusade_feat_item.map")

end

function CrusadeFeatItem:setLazyDataCalled()
    self:setData(self.curData)
end


function CrusadeFeatItem:setLazyData(data)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"featItem")
end


function CrusadeFeatItem:setData(data)
    self:initPanel()
    self.curData=data 
    self:setLabelString("txt_name",  DB.getItemName(data.rewardid).."x"..data.num)
    Icon.setIcon(data.rewardid,self:getNode("icon") )

    self:setLabelString("txt_per", gCrusadeData.feats .."/"..data.need)
    
    self:setLabelString("txt_info",gGetWords("labelWords.plist","need_feat_num",data.need))
    
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


function CrusadeFeatItem:onTouchEnded(target)
    if(target.touchName=="icon_canrec" and self.curData.canrec==1 and self.curData.rec==0)then
        -- gCrusadeData.featRec.list[self.curData.idx+1]=true
        -- gDispatchEvt(EVENT_ID_CRUSADE_FEAT_REC,self.key)
        Net.sendCrusadeRevFeats(self.curData.idx,self.key)
    end

end


return CrusadeFeatItem