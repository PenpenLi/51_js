local ActivitySignItem=class("ActivitySignItem",UILayer)

function ActivitySignItem:ctor()
    -- self:init("ui/ui_signin_item.map")
    -- self:getNode("btn").__touchend=true
    self:setContentSize(cc.size(108,130));
end

function ActivitySignItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_hd_sign_item.map")

end

function ActivitySignItem:onTouchBegan(target,touch)
    if(self.touch==false)then
        return
    end

    local tip= Panel.popTouchTip(self,TIP_TOUCH_EQUIP_ITEM,self.curData.itemid)
    -- tip:setPositionY(tip:getPositionY()+tip:getContentSize().height)
    self.beganPos = touch:getLocation();
end

function ActivitySignItem:onTouchMoved(target,touch)
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if dis > gMovedDis then
        Panel.clearTouchTip();
    end
end

function ActivitySignItem:onTouchEnded(target) 
    self:onSignin();
    Panel.clearTouchTip();
end

function ActivitySignItem:onSignin()
    local index = self.index;
    if self.signType == 1 then
        --签到
        Net.sendSignSignNew(self.index);
    elseif self.signType == 2 then
        --补签
        local dia = Data.getBuyTimesPrice(Data.signInfo.resignCount+1,"RE_SIGN_DIAMOND","RE_SIGN_COUNT");
        local word = gGetWords("activityNameWords.plist","74",dia);
        local callback = function()
            Net.sendReSignSignNew(self.index);
        end
        gConfirmCancel(word,callback);
    end
    -- if self.bCanSign then
    --     Net.sendSignSign();
    -- end
end

function ActivitySignItem:setLazyData(data,index)  
    if(self.inited==true)then
        return
    end
    self.curData=data;
    self.index = index;
    Scene.addLazyFunc(self,self.setLazyDataCalled,"ActivitysignItem")
end
function ActivitySignItem:setLazyDataCalled()
    self:setData(self.curData,self.index);
end

function ActivitySignItem:setData(data,index)
    self:initPanel();
    self.curData=data
    self.index = index;

    Icon.setIcon( data.itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))
    -- local item = Icon.setDropItem(self:getNode("icon"),data.itemid,0,DB.getItemQuality(data.itemid));
    -- item.selectItemCallback = function()
    --     self:onSignin();
    -- end

    self:getNode("layer_double"):setVisible(false);
    if data.vip > 0 then
        self:getNode("layer_double"):setVisible(true);
        self:replaceLabelString("txt_vip",data.vip);
    end

    self:setLabelString("txt_num",data.num);

    self:refresh();

    -- if(self.curData.itemid == OPEN_BOX_GOLD or self.curData.itemid == OPEN_BOX_DIAMOND)then
    --     self.touch=false
    -- end

end

function ActivitySignItem:refresh()

    self.bCanSign = false;
    self.signType = 0;
    self:getNode("layer_signIn"):setVisible(false);
    self:getNode("flag_resign"):setVisible(false);
    self:getNode("icon"):removeChildByTag(100);
    --status= 0未领取; 1=已领取; 2=时间未到
    local status = Data.signInfo.list[self.index];
    -- print("today = "..Data.signInfo.today);
    -- print("self.index = "..self.index);
    -- print("self.status = "..self.status);
    -- local baseIndex = 0;
    -- if(Data.signInfo.today > 30)then
    --     baseIndex = 30;
    -- end
    local today = Data.getSignTodayThisMonth();
    if(today == self.index and status == 0)then
        --今天未领取
        self.signType = 1;
        local fla=gCreateFla("ui_kuang_xiaoguo",1);
        fla:setTag(100);
        gAddChildInCenterPos(self:getNode("icon"),fla);
    elseif(status == 0)then
        --未领取 补签
        self:getNode("flag_resign"):setVisible(true);
        self.signType = 2;
    elseif(status == 1)then
        --已经签到
        self:getNode("icon"):removeChildByTag(100);
        self:getNode("layer_signIn"):setVisible(true);
    elseif(status == 2)then
        --时间未到

    end

    -- local index = self.index;
    -- local data = self.curData;
    -- --
    -- self.bCanSign = false;
    -- local count = Data.signInfo.count;
    -- local bSigned = Data.signInfo.bolSign;
    -- if (count == index and not bSigned) then
        -- --未签到动作
        -- self.bCanSign = true;

        
        -- local fla=gCreateFla("ui_kuang_xiaoguo",1);
        -- fla:setTag(100);
        -- gAddChildInCenterPos(self:getNode("icon"),fla);

    -- else
        -- --今天已经签到
        -- self:getNode("icon"):removeChildByTag(100);

    -- end

    -- self:getNode("layer_signIn"):setVisible(false);
    -- if(index < Data.signInfo.count) then
    --     self:getNode("layer_signIn"):setVisible(true);

    -- end    
end



return ActivitySignItem