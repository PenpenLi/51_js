local ActivityWishItem=class("ActivityWishItem",UILayer)

function ActivityWishItem:ctor(data)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/tip_shop_item.map")
    self:setItemId(data)

    local touch = self:getNode("touch_all")
    local winSize=cc.Director:getInstance():getWinSize()
    touch:setContentSize(cc.size(winSize.width,winSize.height))
    touch:setPositionX(touch:getPositionX()-(winSize.width-self:getContentSize().width)/2)
    touch:setPositionY(touch:getPositionY()+(winSize.height-self:getContentSize().height)/2)
end

function ActivityWishItem:onTouchEnded(target)
    if(target.touchName=="btn_buy")then
        if (Data.activityWish.point<=0) then
            local sWord = gGetWords("activityNameWords.plist","31");
            gShowNotice(sWord)
            return
        end
        local size = #Data.activityWish.reward
        if (size>0 and Data.activityWish.point==Data.activityWish.maxPoint) then
            local sWord = gGetWords("activityNameWords.plist","30");
            gShowNotice(sWord)
            return;
        end
        Net.sendWishAddReward(Data.activityWish.iSelectIndex)
        Panel.popBack(self:getTag())
    elseif (target.touchName=="touch_all") then
        Panel.popBack(self:getTag())
    end
end

function ActivityWishItem:setItemId(itemid)
    self.itemid=itemid
    -- print("itemid="..itemid)
    local db,type= DB.getItemData(itemid)
    if(db==nil)then
        return
    end
    local num=Data.getItemNum(itemid)

    self:setLabelString("txt_name",db.name,nil,true) 
    self:setLabelString("txt_info",DB.getItemAttrDes(itemid))
    self:setLabelString("txt_num",gGetWords( "labelWords.plist","lab_reamin_num",num))
    
    self:getNode("txt_buy_num"):setVisible(false);
    self:getNode("txt_price"):setVisible(false);
    self:getNode("cost_icon"):setVisible(false);

    self:setLabelString("lab_btn_name",gGetWords("btnWords.plist","inbox")) 

    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(itemid))
 
    self:resetLayOut();
end

return ActivityWishItem