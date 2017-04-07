local AtlasBoxNoticeItem=class("AtlasBoxNoticeItem",UILayer)

function AtlasBoxNoticeItem:ctor(type)
    self.curType=type
    self:init("ui/ui_atlas_box_notice_item.map")


end

function AtlasBoxNoticeItem:setData(data)
    self.curData=data

    --chapter=chapter,mapid=mapid,boxid=i,get=1
    self:replaceLabelString("txt_title",data.mapid,data.chapter.name,data.boxid)
    self:getNode("btn_get"):setVisible(false)    
    self:getNode("btn_goto"):setVisible(false)
    
    
    self.sort=data.get*100000+(1000-data.mapid*10+data.boxid)

    if(data.get==1)then
        self:getNode("btn_box"):playAction("ui_atlas_box_2") 
        self:getNode("btn_get"):setVisible(true)
    else
        self:getNode("btn_box"):playAction("ui_atlas_box_1") 
        self:getNode("btn_goto"):setVisible(true)

    end

    local boxid= data.chapter["box"..data.boxid] 
    local rewards=DB.getBoxItemById(boxid)
    for i=1, 3 do
        if(rewards[i]==0)then
            self:getNode("reward_panel"..i):setVisible(false)
        else
            self:getNode("reward_panel"..i):setVisible(true)

            Icon.setIcon(rewards[i].itemid, self:getNode("icon_reward"..i),DB.getItemQuality(rewards[i].itemid)) 
            self:setLabelString("txt_reward_num"..i,rewards[i].itemnum)
        end
    end

end

function AtlasBoxNoticeItem:onTouchEnded(target)
    if(target.touchName=="btn_get")then 
        Net.sendAtlasGetRewinfo(self.curData.mapid,self.curData.boxid,self.curData.type)
    elseif(target.touchName=="btn_goto")then  
        local mapid=self.curData.mapid
        Panel.popBack(self.panel:getTag())
        gDispatchEvt(EVENT_ID_ATLAS_SET_MAPID,mapid-1) 
    end
end


return AtlasBoxNoticeItem