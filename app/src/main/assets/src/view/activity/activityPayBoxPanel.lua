local ActivityPayBoxPanel=class("ActivityPayBoxPanel",UILayer)

function ActivityPayBoxPanel:ctor( item,curIdx)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map") 
    
    self.curData=item
    local item1=item.items[1]
    local item2=item.items[2] 
    self.curBoxIdx=item2.itemid 
    local rewards=DB.getBoxItemById(self.curBoxIdx) 
    for i=1, 3 do
        self:getNode("reward"..i):setVisible(false)
    end
    
    self:setLabelString("txt_need_num",gGetWords("labelWords.plist","lb_hd_pay_reward_box",item1.num))

    local idx=1
    for key, item in pairs(rewards) do
        if(self:getNode("reward"..idx))then

            self:getNode("reward"..idx):setVisible(true) 
            local node=DropItem.new()
            node:setData(item.itemid) 
            node:setNum(item.itemnum)   

            node:setPositionY(node:getContentSize().height)
            self:getNode("reward"..idx):addChild(node)
            idx=idx+1

        end
    end
    
    if(Data.activityPayData.list[curIdx].rec==true)then 
        self:setTouchEnable("btn_get",true,false)
    else 
        if( Data.activityPayData.var>=Data.activityPayData.list[curIdx].items[1].num )then
            self:setTouchEnable("btn_get",false,true)
        else
            self:setTouchEnable("btn_get",false,true)
        end
    end   
    
 
    
end
 

function ActivityPayBoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
     
    
    elseif  target.touchName=="btn_get"then
        
        Net.sendActivityPayGet(Data.activityPayData.idx,self.curData.idx,self.curData.items[2].itemid)
        Panel.popBack(self:getTag())
     
    end
end


return ActivityPayBoxPanel

 