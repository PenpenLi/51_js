local MineExchangeBox=class("MineExchangeBox",UILayer)

function MineExchangeBox:ctor()
    self.appearType = 1;
    self.isMainLayerMenuShow = false
    self._panelTop = true;
    self:init("ui/ui_mine_exchange_box.map")
    Net.sendMiningExAllInfo()

    -- self.curBoxIdx=boxidx
    -- local chapterid=data.mapid
    -- local type=data.type
    -- local chapter=DB.getChapterById(chapterid,type)
    -- if(chapter)then
    --     local needNum= chapter["num"..boxidx]
    --     local boxid= chapter["box"..boxidx]
        
    --     self:setLabelString("txt_need_num",gGetWords("labelWords.plist","lab_get_atlas_reward",needNum))
        
    --     local rewards=DB.getBoxItemById(boxid)
        

    --     for i=1, 3 do
    --         self:getNode("reward"..i):setVisible(false)
    --     end


    --     local idx=1
    --     for key, item in pairs(rewards) do
    --         if(self:getNode("reward"..idx))then

    --             self:getNode("reward"..idx):setVisible(true) 
    --             local node=DropItem.new()
    --             node:setData(item.itemid) 
    --             node:setNum(item.itemnum)   
                
    --             node:setPositionY(node:getContentSize().height)
    --             self:getNode("reward"..idx):addChild(node)
    --             idx=idx+1
            
    --         end
    --     end
        
    --     local curStar=Data.getCurAtlasStar(chapterid,type)
    --     local hasGeted=Data.hasAtlasGetBox(self.curMapid,self.curBoxIdx,self.curDiff);
    --     if(curStar<needNum)then
    --         self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
    --         self:setTouchEnable("btn_get",false,true)
    --     elseif hasGeted then
    --         --已领取
    --         self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
    --         self:setTouchEnable("btn_get",false,true)
    --     end
    -- end
 end

function MineExchangeBox:events()
    return {
            EVENT_ID_MINING_EX_ALL_INFO,
    }
end

function MineExchangeBox:dealEvent(event, param)
    if event == EVENT_ID_MINING_EX_ALL_INFO then
        self:setData()
    end
end

function MineExchangeBox:setData()
    for i=1, 3 do
        self:getNode("reward"..i):setVisible(false)
    end


    local idx=1
    for key, item in pairs(gDigMine.exAllInfo) do
        if(self:getNode("reward"..idx))then

            self:getNode("reward"..idx):setVisible(true) 
            local node=DropItem.new()
            node:setData(item.id) 
            node:setNum(item.num)   
            
            node:setPositionY(node:getContentSize().height)
            self:getNode("reward"..idx):addChild(node)
            idx=idx+1
        end
    end
    
    local status = gDigMine.exAllStatus
    if status == 0  then
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
        self:setTouchEnable("btn_get",false,true)
    elseif status == 2 then
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
        self:setTouchEnable("btn_get",false,true)
    end
end
 

function MineExchangeBox:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose()
    elseif  target.touchName=="btn_get"then
        Net.sendMiningExchangeAll()
        self:onClose()
    end
end


return MineExchangeBox