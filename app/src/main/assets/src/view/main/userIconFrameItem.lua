local UserIconFrameItem=class("UserIconFrameItem",UILayer)

function UserIconFrameItem:ctor()
    self:init("ui/ui_user_iconframe_item.map")

end




function UserIconFrameItem:onTouchEnded(target) 
    
    -- Panel.popUp(TIP_PANEL_SHOP_ITEM,self.curData)
end


function   UserIconFrameItem:setData(data)
    self.frame=data
    self:changeTexture("bg_icon","images/icon/head/frame"..self.frame..".png");
    local frameConvert = cc.Sprite:create("images/icon/head/frame"..self.frame.."_1.png");
    gRefreshNode(self:getNode("bg_icon"),frameConvert,cc.p(0.5,0.5),cc.p(0,0),100);

    self.isUnlock = true;
    if self.frame == 1 then
        if Data.getCurVip() < UserChangeIconPanel.data.vip then
            self.isUnlock = false;
        end
    elseif self.frame == 2 then
        if Data.getCurArenaRank() == 0 or Data.getCurArenaRank() > UserChangeIconPanel.data.arenaRank then
            self.isUnlock = false;
        end

    end

    self:getNode("flag_lock"):setVisible(not self.isUnlock);

end

function UserIconFrameItem:setChoosed(frame)
    self:getNode("choosed"):setVisible(frame == self.frame);
end

function UserIconFrameItem:onTouchEnded(target)

    if  target.touchName=="bg_icon"then
        local tipWord = nil;
        if not self.isUnlock then
            if self.frame == 1 then
                tipWord = gGetWords("labelWords.plist","frame_unlock"..self.frame,UserChangeIconPanel.data.vip);
                if ((Module.isClose(SWITCH_VIP))) then
                    return;
                end
            elseif self.frame == 2 then
                tipWord = gGetWords("labelWords.plist","frame_unlock"..self.frame,UserChangeIconPanel.data.arenaRank);
            end
            gShowNotice(tipWord);
            return;
        end

        self.onChoosed(self.frame);
    end
end



return UserIconFrameItem