local ActivityItem=class("ActivityItem",UILayer)

function ActivityItem:ctor()
    self:init("ui/ui_activity_item.map")

end




function ActivityItem:onTouchEnded(target)  

    if(self.curData == nil)then
        return;
    end

    if(not self.isUnlock and not gAccount:isGm())then
        if(self.curData.type == 2)then
            Unlock.isUnlock(SYS_ACT_GOLD,true);
        elseif(self.curData.type == 3)then
            Unlock.isUnlock(SYS_ACT_EXP,true);
        elseif(self.curData.type == 4)then
            Unlock.isUnlock(SYS_ACT_PETSOUL,true);
        elseif(self.curData.type == 11)then
            Unlock.isUnlock(SYS_ACT_EQUSOUL,true);
        elseif(self.curData.type == 16)then
            Unlock.isUnlock(SYS_ACT_ITEM_AWAKE,true);
        end
        return;
    end

    if self.isOpen==false and not gAccount:isGm() then
        self.unlockWord = self.unlockWord or "";
        gShowNotice(self.unlockWord);
        return;
    end 

    if target.touchName == "icon" or target.touchName == "bg" then
        self.onChoosed(self.index,self.curData);
    elseif target.touchName == "bg_btn1" then
        self.onEnter(1,self.curData);
    elseif target.touchName == "bg_btn2" then
        self.onEnter(2,self.curData);
    elseif target.touchName == "bg_btn3" then
        self.onEnter(3,self.curData);
    elseif target.touchName == "bg_btn4" then
        self.onEnter(4,self.curData);
    end

end


function ActivityItem:checkUnlockTimeIsTaday()
    if(self.curData and self.curData.unlockTime > 0)then
        -- print("self.curData.unlockTime = "..self.curData.unlockTime);
        local date= gGetCurDay(self.curData.unlockTime);
        local unlockdate= gGetCurDay(gGetCurServerTime());
        -- print_lua_table(date);
        -- print("------");
        -- print_lua_table(unlockdate);
        if(date.year == unlockdate.year and date.month == unlockdate.month 
            and date.day == unlockdate.day)then
            print("unlock is taoday");
            return true;
        end
    end
    print("unlock is not taoday");
    return false;
end

function   ActivityItem:setData(data,index)
    self.index = index;

    if data == nil then
        self:changeTexture("txt_name","images/ui_word/sl_wait.png");
        -- self:changeTexture("icon","images/ui_shilian/sl_icon_wait.png");
        self:changeTexture("bg","images/ui_shilian/sl_di2.png");
        self:getNode("light"):setVisible(false);
        self:getNode("layer_lock"):setVisible(false);
        self:getNode("bg_opentime"):setVisible(false);
        self:changeNodeToFla("icon","ui_shilian.fla","ui_shilian_icon_wait");
        return;
    end

    self.curData=data;
    self:changeTexture("txt_name","images/ui_word/sl_title"..index..".png");
    -- self:changeTexture("icon","images/ui_shilian/sl_icon"..index..".png");
    self:changeTexture("light","images/ui_shilian/sl_light"..index..".png");

    self:changeNodeToFla("icon","ui_shilian.fla","ui_shilian_icon"..index);
    
    self.isUnlock = false;
    self:getNode("layer_lock"):setVisible(false);
    if(data.type == 2)then
        self.isUnlock = Unlock.isUnlock(SYS_ACT_GOLD,false);
    elseif(data.type == 3)then
        self.isUnlock = Unlock.isUnlock(SYS_ACT_EXP,false);
    elseif(data.type == 4)then
        self.isUnlock = Unlock.isUnlock(SYS_ACT_PETSOUL,false);
    elseif(data.type == 11)then
        self.isUnlock = Unlock.isUnlock(SYS_ACT_EQUSOUL, false);
     elseif(data.type == 16)then
         self.isUnlock = Unlock.isUnlock(SYS_ACT_ITEM_AWAKE, false);
    end
    -- if(not self.isUnlock)then
    --     self:getNode("layer_lock"):setVisible(true);
    -- end

    self.isOpen=false
    self:getNode("bg_opentime"):setVisible(false);
    if(self.isUnlock)then
        -- print("wday = "..gGetCurWDay());
        local curDate = gGetCurDay();
        local curDay = curDate.wday-1;
        if(string.find(data.opentime,curDay) or self:checkUnlockTimeIsTaday())then
            self.isOpen=true
            self:getNode("bg_opentime"):setVisible(false);
        else 
            local days = string.split(data.opentime,";");
            local strDay = "";
            for key,var in pairs(days) do
                local day_key = "num"
                local spl_sym = "." 
                if gCurLanguage == LANGUAGE_EN then
                    day_key = "weekday"
                    spl_sym = ","
                end
                strDay = strDay .. gGetWords("labelWords.plist",day_key..var);
                if(key ~= #days)then
                    strDay = strDay .. spl_sym;
                    -- strDay = strDay .. gGetWords("labelWords.plist","num_symbol");
                end
            end
            self.unlockWord = gGetWords("labelWords.plist","lab_unlock_week",strDay)
            self:setLabelString("txt_tip",self.unlockWord);
            gSetLabelScroll(self:getNode("txt_tip"));
            -- local labTime = gCreateVerticalWord(unlock,gFont,16,cc.c3b(225,225,169),-2);
            -- labTime:setAnchorPoint(cc.p(0.5,1));
            -- gAddChildByAnchorPos(self:getNode("bg_opentime"),labTime,cc.p(0.5,1));
            self.isOpen=false
            self:getNode("bg_opentime"):setVisible(true);
        end
    else
        self:getNode("layer_lock"):setVisible(true);
    end


    for i=1, 4 do
        local data=DB.getActStageInfoById(data.type,i)
        if(data)then
            if(gUserInfo.level<data.level)then
                local unlock = gGetWords("labelWords.plist","lab_unlock_level",data.level)
                self:setLabelString("txt_unlock"..i,unlock)
                self:setTouchEnable("bg_btn"..i,false)
                self:changeTexture("btn"..i,"images/ui_shilian/nandu_di2.png");
            else
                self:changeTexture("btn"..i,"images/ui_shilian/nandu_di1.png");
                self:getNode("icon_unlock"..i):setVisible(false)
                self:setLabelString("txt_unlock"..i,"")
            end
        end
    end

end

function ActivityItem:layout()
    local action = nil;
    local time = 1.5;
    local offset = 10;
    if self.posy == nil then
        self.posy = self:getPositionY();
    else
        self:setPositionY(self.posy);    
    end
    
    if self.index % 2 == 0 then
        self:setPositionY(self:getPositionY() - 20);
        action = cc.Sequence:create( cc.MoveBy:create(time,cc.p(0,offset)),cc.MoveBy:create(time,cc.p(0,-offset)) );
    else
        self:setPositionY(self:getPositionY() + 20);
        action = cc.Sequence:create( cc.MoveBy:create(time,cc.p(0,-offset)),cc.MoveBy:create(time,cc.p(0,offset)) );
    end
    action = cc.RepeatForever:create(action);
    action:setTag(1);
    self:runAction(action);
end

function ActivityItem:stopAction()
    -- body
    self:stopActionByTag(1);
    -- self:stopAllActions();
end

function ActivityItem:choosed()
    local time = 0.1;
    -- self:stopAllActions();
    self:getNode("layer_content"):runAction(
        cc.ScaleTo:create(time,0.8)
        );
    self:getNode("menu"):setVisible(true);
    for i = 1,4 do
        local btn = self:getNode("btn"..i);
        btn:setScaleX(0);
        btn:setScaleY(1);
        btn:runAction(
            cc.Sequence:create(
            cc.DelayTime:create(0.05*(i-1)),
            cc.ScaleTo:create(time,1,1)
            )
        );
    end

    self:getNode("layer_light"):setVisible(true);
    self:getNode("bg_light"):setOpacity(0);
    self:getNode("bg_light"):runAction(cc.FadeTo:create(0.2,255));
end

function ActivityItem:unChoosed()
    local time = 0.1;
    -- self:stopAllActions();
    self:getNode("layer_content"):runAction(
        cc.ScaleTo:create(time,1.0)
        );
    for i = 1,4 do
        local function actionEnd()
            self:getNode("menu"):setVisible(false);
        end
        local btn = self:getNode("btn"..i);
        btn:setScaleX(1);
        btn:setScaleY(1);
        btn:runAction(
            cc.Sequence:create(
            cc.DelayTime:create(0.05*(i-1)),
            cc.ScaleTo:create(time,0,1),
            cc.DelayTime:create(0.2-0.05*(i-1)),
            cc.CallFunc:create(actionEnd)
            )
        );
    end    

    local function lightActionEnd()
        self:getNode("layer_light"):setVisible(false);
    end
    self:getNode("bg_light"):setOpacity(255);
    self:getNode("bg_light"):runAction(
        cc.Sequence:create(
            cc.FadeTo:create(0.2,0),
            cc.CallFunc:create(lightActionEnd)
            )
        
        );

end

return ActivityItem