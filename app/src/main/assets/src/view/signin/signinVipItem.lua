local SigninVipItem=class("SigninVipItem",UILayer)

function SigninVipItem:ctor()
    -- self:init("ui/ui_signin_vip_item.map")
    self:setContentSize(cc.size(600,105));
end

function SigninVipItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_signin_vip_item.map")

end

function SigninVipItem:onTouchBegan(target,touch)
    -- if(self.touch==false)then
    --     return
    -- end

    if target.touchName == "icon_1" or target.touchName == "icon_2" or target.touchName == "icon_3" then
        local itemid = 0;
        if target.touchName == "icon_1" then
            itemid = self.curData.itemid1;
        elseif target.touchName == "icon_2" then
            itemid = self.curData.itemid2;
        elseif target.touchName == "icon_3" then
            itemid = self.curData.itemid3;
        end
        local tip= Panel.popTouchTip(self,TIP_TOUCH_EQUIP_ITEM,itemid)
        -- tip:setPositionY(tip:getPositionY()+tip:getContentSize().height)
    end
    self.beganPos = touch:getLocation();
end

function SigninVipItem:onTouchMoved(target,touch)
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function SigninVipItem:onTouchEnded(target) 
    if target.touchName == "btn_get" then
        self:onSignin();
    else

    end
    Panel.clearTouchTip();
end

function SigninVipItem:onSignin()

    if self.bGeted then
        return;
    end
    local index = self.index;
    if self.bCanGet then
        Net.sendSignVip(index-1);
    else
        Panel.popUp(PANEL_PAY);
    end

end

function SigninVipItem:setLazyData(data,index,curDay)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    self.index = index;
    self.curDay = curDay;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"signinVipItem")
end
function SigninVipItem:setLazyDataCalled()
    self:setData(self.curData,self.index,self.curDay);
end

function SigninVipItem:setData(data,index,curDay)
    self:initPanel();
    self.curData=data
    self.index = index;
    self.curDay = curDay;

    for i=1,3 do
        if data["itemid"..i] > 0 then
            Icon.setDropItem(self:getNode("icon_bg"..i),data["itemid"..i],data["num"..i])
        else
            self:getNode("icon_"..i):setVisible(false);
        end
        
    end

    self:setLabelString("txt_day",self.index);
    self:refresh();

    if(self.curData.itemid == OPEN_BOX_GOLD or self.curData.itemid == OPEN_BOX_DIAMOND)then
        self.touch=false
    end

end

function SigninVipItem:refresh()
    local index = self.index;
    local data = self.curData;

    local bCanGet = false;
    local bGeted = false;
    local count = table.getn(Data.signInfo.iaprcd);
    if index > 0 and index <= count and Data.signInfo.iaprcd[index] == 1 then
        bCanGet = true;
    end
    count = table.getn(Data.signInfo.rwdrcd);
    if index > 0 and index <= count and Data.signInfo.rwdrcd[index] == 1 then
        bGeted = true;
    end
    
    local status = 0;
    -- self:getNode("flag_unget"):setVisible(false);
    self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward"));  
    if bGeted then
        status = 1;
        -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_reward_got"));
        -- self:setTouchEnable("btn_get",false,true);
    elseif bCanGet then
        status = 0;
        self:changeTexture("btn_get","images/ui_public1/button_blue_1.png");
        -- self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_get_reward"));
        Data.redpos.bolVipSign = true;
    elseif self.curDay == index then
        status = 0;
        self:setLabelString("txt_get",gGetWords("btnWords.plist","btn_pay"));  
    else
        status = -1;
        -- self:getNode("flag_unget"):setVisible(true);
        -- self:getNode("btn_get"):setVisible(false);
    end
    self.bCanGet = bCanGet;
    self.bGeted = bGeted;
    gShowBtnStatus(self:getNode("btn_get"),status);
end


return SigninVipItem

