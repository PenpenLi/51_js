local ActivityCatNewPanel=class("ActivityCatNewPanel",UILayer)

function ActivityCatNewPanel:ctor()
    self:init("ui/ui_hd_miao_new.map")
    -- self.curData=data

    loadFlaXml("ui_touzhu")

    self.maxNum = table.getn(Data.activity.cat_diamond_price)

    self.numBg = {};
    self.num = {};
    for i=1,5 do
        self.numBg[i] = self:getNode("num_bg"..i);
        self.num[i] = self:getNode("num"..i);
    end

    self.actBg = self:getNode("act_bg");
    self:replaceRtfString("scroll_contain_item0",self.maxNum)
    
    self:refreshUi();
    self:resetBtn();

    self.endTime = Data.activityCat.lefttime
    if(self.endTime >= gGetCurServerTime())then
        -- print("@@@@@@@");
        local function updateTime()
            self.leftDay = gGetDayByLeftTime(self.endTime - gGetCurServerTime());
            -- print("self.leftDay = "..self.leftDay);
            if(self.leftDay > 0)then
                self:replaceLabelString("txt_day",self.leftDay);
                self:getNode("txt_day"):setVisible(true);
                self.preTimeStatue = 1; 
            else
                self:getNode("txt_day"):setVisible(false);
                if(self.preTimeStatue ~= 2)then
                    self.reLayout = true;
                end
                self.preTimeStatue = 2; 
            end
            if(self.endTime>gGetCurServerTime())then
                self:setLabelString("txt_refresh_time2", gParserHourTime(self.endTime - gGetCurServerTime() - self.leftDay*24*60*60))
            end
            if(self.reLayout)then
                -- print("#############");
                self.reLayout = false;
                self:getNode("layout_time"):layout();
            end
        end
        self:scheduleUpdate(updateTime,1)
    end

    self:getNode("help_bg"):layout();
end

function ActivityCatNewPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function  ActivityCatNewPanel:events()
    return
        {
            EVENT_ID_GET_ACTIVITY_CAT,
        }
end

function ActivityCatNewPanel:dealEvent(event,param)
    -- print("ActivityCatPanel event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_CAT)then
        self:eventCat(param);
    end
end

function ActivityCatNewPanel:onTouchEnded(target)
    if target.touchName=="btn_get" then
        self:onGet();
    elseif target.touchName=="btn_close" then
        Panel.popBack(self:getTag()) 
    end
end

function ActivityCatNewPanel:getLv()
    return math.min(Data.activityCat.lv+1,self.maxNum);
end

function ActivityCatNewPanel:onGet()
    if (NetErr.isDiamondEnough(Data.activity.cat_diamond_price[self:getLv()]) == false) then
        return;
    end

    Net.sendGiftbagGetBet()
    -- gDispatchEvt(EVENT_ID_GET_ACTIVITY_CAT,{ret = 0})
    self:setTouchEnableGray("btn_get",false);
end

function ActivityCatNewPanel:playAct()
    for i=1,5 do
        self.num[i]:setVisible(true);
    end
    --判断几位数
    -- Data.activityCat.getdmd = 57624;
    local strNum = tostring(Data.activityCat.getdmd)
    local count = strNum:len();
    -- print("count="..count);
    for i=1,count do
        local numOne = toint(string.sub(strNum,count-i+1,count-i+1));
        -- print("numOne="..numOne);

        -- self.num[i]:runAction(cc.Sequence:create(
        --     cc.DelayTime:create(0.5*(i-1)),
        --     cc.Hide:create()
        -- ));
        self.num[i]:setVisible(false);

        self.numBg[i]:removeChildByTag(300);
        local num =nil
        
        local function onPlay()
            for i=7, 12 do
                local newNum = numOne;
                if (i==7) then
                    newNum = newNum - 2;
                    if (newNum<0) then
                        newNum = newNum + 10;
                    end
                elseif (i==8) then
                    newNum = newNum - 1;
                    if (newNum<0) then
                        newNum = newNum + 10;
                    end
                end
                local node9 = gCreateLabelAtlas("images/ui_num/big-num3.png",52,84,newNum,-3,0)
                num:replaceBoneWithNode({"shuzi"..(i==12 and 0 or i)},node9); 
            end
        end
        
        num=gCreateFlaDelay(0.5*(i-1),"ui_touzhu_shuzi",0,nil,onPlay);
        
        gAddChildInCenterPos(self.numBg[i],num)
        num:setTag(300);
    end
    gCallFuncDelay(count*0.5+3.5, self, self.playActOver)
    gCallFuncDelay(count*0.5+3.5+0.5, self, self.showItems)
end

function ActivityCatNewPanel:playActOver()
    --发光效果
    local fla = gCreateFla("ui_touzhu_shanguang");
    self.actBg:removeAllChildren();
    gAddChildInCenterPos(self.actBg,fla)

    self:resetBtn();
    self:refreshUi();
end

function ActivityCatNewPanel:eventCat(param)
    local ret = param.ret;
    -- print("ret = "..ret)
    if (ret ~= 0) then
        self:resetBtn();
        return;
    end
    self:setLeftNum();
    --开始播放动画
    self:playAct();
end

function ActivityCatNewPanel:resetBtn()
    if (Data.activityCat.lv<self.maxNum) then
        self:setTouchEnableGray("btn_get",true);
    else
        self:setTouchEnableGray("btn_get",false);
    end
end

function ActivityCatNewPanel:showItems()
    --飘物品
    gShowItemPoolLayer:clearItems();
    local items = {};
    table.insert(items,{id=OPEN_BOX_DIAMOND,num=Data.activityCat.getdmd});
    gShowItemPoolLayer:pushItems(items);
end

function ActivityCatNewPanel:setLeftNum()
    local num = self.maxNum-Data.activityCat.lv;
    -- print("num="..num..",self.maxNum="..self.maxNum..",Data.activityCat.lv="..Data.activityCat.lv)
    self:replaceLabelString("lab_num",num);
end

function ActivityCatNewPanel:refreshUi()
    self:setLeftNum();
    -- print("------------")
    -- print_lua_table(Data.activity.cat_diamond_max);

    self:replaceRtfString("lab_getdmd",Data.activity.cat_diamond_max[self:getLv()]);
    self:setLabelString("lab_dia",Data.activity.cat_diamond_price[self:getLv()]);
end


return ActivityCatNewPanel