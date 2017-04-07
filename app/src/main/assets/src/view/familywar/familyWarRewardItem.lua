local FamilyWarRewardItem=class("FamilyWarRewardItem",UILayer)

function FamilyWarRewardItem:ctor(type)
    if(type==2)then
        self:init("ui/ui_family_war_reward_item2.map"); 
    else 
        self:init("ui/ui_family_war_reward_item.map");
    end
    for i=1, 4 do
        if(self:getNode("icon"..i))then
            self:getNode("icon"..i):setVisible(false)
        end
    end 
end




function FamilyWarRewardItem:setIndex(idx)
    if(idx==nil)then
        return nil
    end
    if(idx<=2)then
        self:getNode("txt_num"):setVisible(false)
        self:changeTexture("bg","images/ui_word/family_no"..idx..".png")
    else
        self:setLabelAtlas("txt_num",idx)
    end
end

function FamilyWarRewardItem:setData1(data)
    self.curData=data; 
    self:changeTexture("icon","images/ui_word/family_p0.png")
    self:getNode("icon1"):setVisible(true)
    Icon.setDropItem(self:getNode("icon1"),OPEN_BOX_FAMILY_EXP,data.value)
    self:getNode("icon1"):setOpacity(255)
end


function FamilyWarRewardItem:setData2(data)
    self.curData=data; 
    self:changeTexture("icon","images/ui_word/family_kill_"..data.wincount..".png")
    self:replaceLabelString("txt_info2",data.wincount)
    for i=1, 4 do
        if(data["itemid"..i]>0)then
            self:getNode("icon"..i):setVisible(true)
            Icon.setDropItem(self:getNode("icon"..i),data["itemid"..i],data["itemnum"..i])
            self:getNode("icon"..i):setOpacity(255)
        end
    end
end

--个人奖励
function FamilyWarRewardItem:setData0(data)
    self.curData=data;  
    self:changeTexture("icon","images/ui_word/family_p"..(data.wincount%10)..".png")
    for i=1, 4 do
        if(data["itemid"..i]>0)then
            self:getNode("icon"..i):setVisible(true)
            local item= Icon.setDropItem(self:getNode("icon"..i),data["itemid"..i],data["itemnum"..i])
            self:getNode("icon"..i):setOpacity(255)
        end
    end
end

return FamilyWarRewardItem