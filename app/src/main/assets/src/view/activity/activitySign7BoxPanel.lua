local ActivitySign7BoxPanel=class("ActivitySign7BoxPanel",UILayer)

function ActivitySign7BoxPanel:ctor(rewards,data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_atlas_box.map")



    for i=1, 3 do
        self:getNode("reward"..i):setVisible(false)
    end


    if(data.status == 0) then--未达成
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_cant_get")) 
    elseif data.status == 2 then--已经领取
        self:setTouchEnable("btn_get",false,true)
        self:setLabelString("btn_txt",gGetWords("btnWords.plist","btn_reward_got"));
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
    self.curData=data
    self:setLabelString("txt_need_num",data.title);



end


function ActivitySign7BoxPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

 
    elseif  target.touchName=="btn_get"then
        if(self.curData.callback)then
            self.curData.callback()
        end
        Panel.popBack(self:getTag())
        
    end
end


return ActivitySign7BoxPanel