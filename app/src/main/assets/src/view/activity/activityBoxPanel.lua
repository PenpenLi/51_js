local ActivityBoxPanel=class("ActivityBoxPanel",UILayer)

function ActivityBoxPanel:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")
    self.boxData = data;
    local boxid = data.boxid;

    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:getNode("scroll"):setVisible(true)
    self:getNode("rewardlayout"):setVisible(false)
    self:getNode("txt_show"):setVisible(true)
    self:getNode("scroll"):clear()
    self:getNode("scroll"):clear()
    self:initReward(boxid);
    self:setLabelString("txt_need_num",gGetWords("labelWords.plist","box_content"));
    self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_confirm"));
    
end

function ActivityBoxPanel:initReward(boxid)

    local rewards=DB.getBoxItemById(boxid)

    for key, reward in pairs(rewards) do
        local node=DropItem.new(true)
        node:setData(reward.itemid) 
        node:setNum(reward.itemnum)
        self:getNode("scroll"):addItem(node)
    end
    self:getNode("scroll"):setPaddingXY(0,33)
    self:getNode("scroll"):layout()
    
end
 

function ActivityBoxPanel:onTouchEnded(target)
   if  target.touchName=="btn_close" or target.touchName=="btn_get" then
        Panel.popBack(self:getTag())
    end
end


return ActivityBoxPanel