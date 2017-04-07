local AtlasRewardBoxPanel=class("AtlasRewardBoxPanel",UILayer)

function AtlasRewardBoxPanel:ctor(data,boxidx)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self.curMapid=data.mapid
    self.curDiff=data.type
    self.curBoxIdx=boxidx
    local chapterid=data.mapid
    local type=data.type
    local chapter=DB.getChapterById(chapterid,type)
    if(chapter)then
        local needNum= chapter["num"..boxidx]
        local boxid= chapter["box"..boxidx]
        
        self:setLabelString("txt_need_num",gGetWords("labelWords.plist","lab_get_atlas_reward",needNum))
        
        local rewards=DB.getBoxItemById(boxid)
        

        for i=1, 3 do
            self:getNode("reward"..i):setVisible(false)
        end


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
        
        local curStar=Data.getCurAtlasStar(chapterid,type)
        local hasGeted=Data.hasAtlasGetBox(self.curMapid,self.curBoxIdx,self.curDiff);
        if(curStar<needNum)then
            self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
            self:setTouchEnable("btn_get",false,true)
        elseif hasGeted then
            --已领取
            self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
            self:setTouchEnable("btn_get",false,true)
        end
    end
 

end
 

function AtlasRewardBoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
     
    
    elseif  target.touchName=="btn_get"then
        Net.sendAtlasGetRewinfo(self.curMapid,self.curBoxIdx,self.curDiff)
        Panel.popBack(self:getTag())
     
    end
end


return AtlasRewardBoxPanel