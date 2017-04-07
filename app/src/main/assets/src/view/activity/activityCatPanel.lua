local ActivityCatPanel=class("ActivityCatPanel",UILayer)

function ActivityCatPanel:ctor(data)
    self:init("ui/ui_hd_miao.map")
    self.curData=data

    loadFlaXml("ui_touzhu")

    self.maxNum = table.getn(Data.activity.cat_diamond_price)

    self.numBg = {};
    self.num = {};
    for i=1,5 do
        self.numBg[i] = self:getNode("num_bg"..i);
        self.num[i] = self:getNode("num"..i);
    end

    self.actBg = self:getNode("act_bg");
    
    self:refreshUi();
    self:resetBtn();
end


function ActivityCatPanel:dealEvent(event,param)
    -- print("ActivityCatPanel event="..event)
    if(event==EVENT_ID_GET_ACTIVITY_CAT)then
        self:eventCat(param);
    end
end

function ActivityCatPanel:onTouchEnded(target)
    if target.touchName=="btn_get" then
        self:onGet();
    end
end

function ActivityCatPanel:getLv()
    return math.min(Data.activityCat.lv+1,self.maxNum);
end

function ActivityCatPanel:onGet()
    if (NetErr.isDiamondEnough(Data.activity.cat_diamond_price[self:getLv()]) == false) then
        return;
    end

    Net.sendGiftbagGetBet()
    -- gDispatchEvt(EVENT_ID_GET_ACTIVITY_CAT,{ret = 0})
    self:setTouchEnableGray("btn_get",false);
end

function ActivityCatPanel:playAct()
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

function ActivityCatPanel:playActOver()
    --发光效果
    local fla = gCreateFla("ui_touzhu_shanguang");
    self.actBg:removeAllChildren();
    gAddChildInCenterPos(self.actBg,fla)

    self:resetBtn();
    self:refreshUi();
end

function ActivityCatPanel:eventCat(param)
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

function ActivityCatPanel:resetBtn()
    if (Data.activityCat.lv<self.maxNum) then
        self:setTouchEnableGray("btn_get",true);
    else
        self:setTouchEnableGray("btn_get",false);
    end
end

function ActivityCatPanel:showItems()
    --飘物品
    gShowItemPoolLayer:clearItems();
    local items = {};
    table.insert(items,{id=OPEN_BOX_DIAMOND,num=Data.activityCat.getdmd});
    gShowItemPoolLayer:pushItems(items);
end

function ActivityCatPanel:setLeftNum()
    local num = self.maxNum-Data.activityCat.lv;
    -- print("num="..num..",self.maxNum="..self.maxNum..",Data.activityCat.lv="..Data.activityCat.lv)
    self:replaceLabelString("lab_num",num);
end

function ActivityCatPanel:refreshUi()
    self:setLeftNum();
    -- print("------------")
    -- print_lua_table(Data.activity.cat_diamond_max);

    self:replaceRtfString("lab_getdmd",Data.activity.cat_diamond_max[self:getLv()]);
    self:setLabelString("lab_dia",Data.activity.cat_diamond_price[self:getLv()]);
end


return ActivityCatPanel