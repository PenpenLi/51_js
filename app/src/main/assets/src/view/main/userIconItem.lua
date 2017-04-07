local UserIconItem=class("UserIconItem",UILayer)

function UserIconItem:ctor()
    self:init("ui/ui_user_icon_item.map")

end




function UserIconItem:onTouchEnded(target) 
    
    -- Panel.popUp(TIP_PANEL_SHOP_ITEM,self.curData)
end


function UserIconItem:setData(data)
    self.data = data;
    self.icon = data.icon;

    local showIcon = self.icon;
    local userCard = Data.getUserCardById(showIcon);
    local awakeLv = 0;
    if(userCard)then
        -- print_lua_table(userCard);
        -- local awakeId = gParseCardAwakeId(userCard.awakeLv);
        -- if(awakeId and awakeId > 0 and isUnlockIdForAwake(self.icon))then
        --     -- showIcon = showIcon.."_a"..gParseCardAwakeId(userCard.awakeLv);
        --     showIcon = showIcon.."_a1";
        -- end
        -- print("showIcon = "..showIcon);
        awakeLv = userCard.awakeLv;
    end
    Icon.setCardIcon(showIcon,self:getNode("bg_icon"),nil,awakeLv);
    -- Icon.setIcon(self.icon,self:getNode("bg_icon"))
    self:getNode("flag_lock"):setVisible(self.data.unlocktype > 1);
end

function UserIconItem:setChoosed(icon)
    self:getNode("choosed"):setVisible(icon == self.icon);
end

function UserIconItem:onTouchEnded(target)

    if  target.touchName=="bg_icon"then
        if self.data.unlocktype == 2 then
            gShowNotice(gGetWords("labelWords.plist","114"));
            return;
        end
        self.onChoosed(self.icon);
    end
end


return UserIconItem