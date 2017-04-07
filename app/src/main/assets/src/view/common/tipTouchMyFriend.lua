local TipTouchMyFriend=class("TipTouchMyFriend",UILayer)

function TipTouchMyFriend:ctor(data)
    self:init("ui/tip_touch_my_friend.map")
    self.curData=data
     
end



function TipTouchMyFriend:onTouchEnded(target)
    
    if(target.touchName=="btn_fight")then
        if( NetErr.checkPkLevel(self.curData) ==false)then
            return
        end 
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_BUDDY_FIGHT,self.curData.uid)
    elseif(target.touchName=="btn_chat")then
        Data.addRecentChatRole(self.curData.uid,self.curData.name,self.curData.icon,self.curData.vip)
        Panel.popUp(PANEL_CHAT,self.curData.uid)
    elseif(target.touchName=="btn_view")then 
        Net.sendBuddyTeam(self.curData.uid)
    elseif(target.touchName=="btn_del")then 
        Net.sendBuddyDel(self.curData.uid)
    end
    
    Panel.clearTouchTip()
end

return TipTouchMyFriend