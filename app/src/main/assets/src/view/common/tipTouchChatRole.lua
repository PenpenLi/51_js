local TipTouchChatRole=class("TipTouchChatRole",UILayer)

function TipTouchChatRole:ctor(data)
    self:init("ui/tip_touch_chat_role.map")
    self.curData=data
end



function TipTouchChatRole:onTouchEnded(target)

    if(target.touchName=="btn_fight")then
        if( NetErr.checkPkLevel(self.curData) ==false)then
            return
        end 
        
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_BUDDY_FIGHT,self.curData.uid)
    elseif(target.touchName=="btn_chat")then
        Data.addRecentChatRole(self.curData.uid,self.curData.name,self.curData.icon,self.curData.vip)
        Panel.popUp(PANEL_CHAT,self.curData.uid)
    elseif(target.touchName=="btn_black")then
        Net.sendBuddyBlack(self.curData.uid)
    elseif(target.touchName=="btn_add_friend")then
        local words=gGetWords("labelWords.plist","invite_defalt_words")
        Net.sendBuddyInvite( self.curData.uid,words)
    
    elseif(target.touchName=="btn_view")then 
        Net.sendBuddyTeam(self.curData.uid)
    end
    Panel.clearTouchTip()
end

return TipTouchChatRole