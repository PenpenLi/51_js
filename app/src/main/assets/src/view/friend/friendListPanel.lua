local FriendListPanel=class("FriendListPanel",UILayer)

FriendListPanel.data = {}
FriendListPanel.data.friend = {}
FriendListPanel.data.friend.uid = 0

function FriendListPanel:ctor()
    self.appearType = 1;
    self:init("ui/ui_friend_list.map")
    self._panelTop=true

    self.scroll = self:getNode("scroll")
    self:createList()
end

function FriendListPanel:onTouchEnded(target)
    if target.touchName=="btn_close" then
        Panel.popBack(self:getTag())
		FriendListPanel.data.friend.uid = 0
    end
end

function FriendListPanel:createList()
	local number = 0
    self.scroll:clear()
    if(gFriend.myFriends) then
	    for key, friend in pairs(gFriend.myFriends) do
	        local item=FriendListItem.new()
	        item:setData(friend)
	        item.selectItemCallback = function (data)
	        	self:choose(data)
	        end
	        self.scroll:addItem(item)
	    end
	    number = table.getn(gFriend.myFriends)
	end
    self.scroll:layout()
    
    self:setLabelString("lab_number",number.."/"..Data.friend.maxFriendCount)
end

function FriendListPanel:choose(friend)
	FriendListPanel.data.friend = friend
    Panel.popBack(self:getTag())
end

return FriendListPanel