local PayPanel=class("PayPanel",UILayer)

function PayPanel:ctor(type)

    self:init("ui/ui_pay.map")
    
    Data.bolInPayPanel = true

    self:getNode("scroll").eachLineNum=2
    self:getNode("scroll").offsetY=0
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- --排序
    -- for key,var in pairs(iap_db) do
    --     var.sort = 50-var.iapid;
    -- end

    -- if not Data.hasMemberCard(CARD_TYPE_MON) or not Data.hasMemberCard(CARD_TYPE_LIFE) then
    --     for key,var in pairs(iap_db) do
    --         if toint(var.iapid) == CARD_TYPE_MON then
    --             var.sort = 101;
    --         elseif toint(var.iapid) == CARD_TYPE_LIFE then
    --             var.sort = 100;
    --         end
    --     end
    -- end
    -- -- print_lua_table(iap_db);
    -- local sort = function(v1,v2) 
    --     if v1.sort > v2.sort then
    --         return true;
    --     end
    --     return false;
    -- end
    -- table.sort(iap_db,sort);

 
    -- for key, var in pairs(iap_db) do
    --     local item=PayItem.new()
    --     item:setData(var) 
    --     self:getNode("scroll"):addItem(item)
    -- end

    -- self:getNode("scroll"):layout()
    self:refreshData()

    -- Module.handleClose(SWITCH_VIP,self);
    Net.sendIapInfo();
    self:hideCloseModule();
end

function PayPanel:hideCloseModule()
    self:getNode("layer_vip"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("rtf"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("layer_bar"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("btn_check_miss"):setVisible(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT);
end

function PayPanel:createContent()
    --排序
    for key,var in pairs(iap_db) do
        var.sort = 50-var.iapid;
    end

    if not Data.hasMemberCard(CARD_TYPE_MON) or not Data.hasMemberCard(CARD_TYPE_LIFE) then
        for key,var in pairs(iap_db) do
            if toint(var.iapid) == CARD_TYPE_MON then
                var.sort = 101;
            elseif toint(var.iapid) == CARD_TYPE_LIFE then
                var.sort = 100;
            end
        end
    end
    -- print_lua_table(iap_db);
    local sort = function(v1,v2) 
        if v1.sort > v2.sort then
            return true;
        end
        return false;
    end
    table.sort(iap_db,sort);

 
    for key, var in pairs(iap_db) do
        if var.iapid<8 then
            local item=PayItem.new()
            item:setData(var) 
            self:getNode("scroll"):addItem(item)
        end
    end

    self:getNode("scroll"):layout()
    self:refreshData()    
end

function PayPanel:events()
    return {
        EVENT_ID_USER_DATA_UPDATE,
        EVENT_ID_PAY_ENTER,
        EVENT_ID_WILL_ENTER_FOREGROUND
    }
end

function PayPanel:dealEvent(event,param)
    if(event==EVENT_ID_USER_DATA_UPDATE)then
        self:refreshData() 
    elseif(event == EVENT_ID_PAY_ENTER)then
        self:createContent();
    elseif(event == EVENT_ID_WILL_ENTER_FOREGROUND)then
        if(Module.isClose(SWITCH_IAppPayH5) == false and Net.orderId ~= nil and Net.orderId ~= "0")then
            local data={}
            data.result="1"
            data.orderId=Net.orderId
            data.payType="3"
            local str=gAccount:tableToString(data)
            PayItem.onPayCallback(str)
        end
    end
end
function PayPanel:createVipNode(vip)
    local node = cc.Node:create();
    local uilayer = UILayer.new();
    uilayer:init("ui/ui_pay_vip.map"); 
    uilayer.isBlackBgVisible = false
    uilayer.bgVisible =false
    uilayer:setLabelAtlas("txt_vip",vip);
    uilayer:setAnchorPoint(cc.p(0,-1));
    node:addChild(uilayer);
    node:setContentSize(uilayer:getContentSize());
    return node;
end
function PayPanel:refreshData()

    local vipDatas=DB.getVipCharge()

    local vip=gUserInfo.vip
    local isFull=false
    if(vip>=15)then
        vip=14
        isFull=true
    end

    local vipCharge=vipDatas[vip+2] 
    if(vipCharge)then
        local per= gUserInfo.vipsc/vipCharge
        self:setBarPer("bar",per)
        self:setLabelString("txt_per", gUserInfo.vipsc.."/"..vipCharge)

        if isFull then
            local word = gGetWords("vipWords.plist","vipTip3");
            local words = string.split(word,"@");
            local rtf = self:getNode("rtf");
            rtf:clear();
            rtf:addWord(words[1]);
            rtf:addNode(self:createVipNode(gUserInfo.vip));
            rtf:addWord(words[2]);

        else
            local needDia = vipCharge-gUserInfo.vipsc;
            local word = gGetWords("vipWords.plist","vipTip2");
            local words = string.split(word,"@");
            local rtf = self:getNode("rtf");
            rtf:clear();
            rtf:addWord(words[1]);
            rtf:addNode(self:createVipNode(gUserInfo.vip));
            rtf:addWord(words[2]);
            rtf:addImage("images/ui_public1/gold.png",0.4);
            rtf:addWord(needDia,nil,20,cc.c3b(255,255,255));
            rtf:addWord(words[3]);
            rtf:addNode(self:createVipNode(gUserInfo.vip+1));
            rtf:layout();
        end

    -- else
    --     self:setLabelString("txt_need_pay","")
    --     self:setBarPer("bar",0)
    --     self:getNode("icon_need_pay"):setVisible(false)
    --     self:setLabelString("txt_per","")
    --     self:setLabelString("lab_vip_info","") 
    end

    local items = self:getNode("scroll"):getAllItem();
    for k,item in pairs(items) do
        item:refreshBtn();
    end
end


function PayPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Net.sendIapCheckMissOrder()
        Panel.popBack(self:getTag())
        Data.bolInPayPanel = false

    elseif  target.touchName=="btn_vip"then
       
        self:refreshData() 
        local needRefresh = TaskPanelData.bNeedRefresh;
        TaskPanelData.bNeedRefresh = false;
        Panel.popBack(self:getTag(),nil,nil,false)
        Panel.popUp(PANEL_VIP)
        TaskPanelData.bNeedRefresh = needRefresh;
    elseif target.touchName=="btn_check_miss" then
        Panel.popUp(PANEL_PAY_MISS)
    end
end

return PayPanel