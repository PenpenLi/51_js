local ChatFriendItem=class("ChatFriendItem",UILayer)

function ChatFriendItem:ctor()
    self:init("ui/ui_talk_friend_item.map")
    self:hideCloseModule();
end

function ChatFriendItem:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("bg_vip"):setVisible(false)
end



function ChatFriendItem:onTouchEnded(target,touch,event)
    print ("ChatFriendItem:onTouchEnded~")
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData)
    end
end


function   ChatFriendItem:setData(data)
    print_lua_table(data, 4)
    self.curData=data
    self:setLabelString("txt_name",data.name)
    if(data.icon ~= nil) then
        Icon.setHeadIcon(self:getNode("icon"), data.icon)
    end
    if(data.vip ~= nil) then
        self:setLabelAtlas("txt_vip",data.vip)
    end
    --self.setLabelString("txt_vip",data.vip)
    --Icon.setIcon(data.icon,self:getNode("icon"))
end



return ChatFriendItem