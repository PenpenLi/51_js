local CrusadeCallItem=class("CrusadeCallItem",UILayer)

function CrusadeCallItem:ctor()
 

end

function CrusadeCallItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_crusade_call_item.map")

end

function CrusadeCallItem:setLazyDataCalled()
    self:setData(self.curData,self.eng)
end


function CrusadeCallItem:setLazyData(data,eng)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    self.eng = eng;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"callItem")
end


function CrusadeCallItem:setData(data,eng)
    self:initPanel()
    self.curData=data 
    eng = eng or 0
    self.eng = eng;

    self:setLabelString("txt_per", eng .."/"..data.need)

    self:setLabelString("txt_info",gGetMapWords("ui_crusade_call_item.plist", "1", data.need))
    
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


function CrusadeCallItem:onTouchEnded(target)
    if(target.touchName=="icon_canrec" and self.curData.canrec==1 and self.curData.rec==0)then
        -- gCrusadeData.featRec.list[self.curData.idx+1]=true
        -- gDispatchEvt(EVENT_ID_CRUSADE_FEAT_REC,self.key)
        Net.sendCrusadeCall(self.curData.idx,self.key)
    end

end


return CrusadeCallItem