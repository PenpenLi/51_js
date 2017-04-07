local FriendListItem=class("FriendListItem",UILayer)

function FriendListItem:ctor()
    self:init("ui/ui_friend_list_item.map")
    self:hideCloseModule();
end

function FriendListItem:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("bg_vip"):setVisible(false)
end

function FriendListItem:onTouchEnded(target)
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData)
    end
end

function FriendListItem:setData(data) 
    self.curData=data
    Icon.setHeadIcon(self:getNode("icon"),data.icon)
    self:setLabelString("txt_name",data.name) 
    self:setLabelString("txt_level",getLvReviewName("Lv")..data.level)
    self:setLabelAtlas("txt_vip",data.vip);
    gShowLoginTime(self,"lab_time",gServerTime-data.login);
end

return FriendListItem