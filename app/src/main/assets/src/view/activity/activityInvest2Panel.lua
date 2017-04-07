local ActivityInvest2Panel=class("ActivityInvest2Panel",UILayer)

function ActivityInvest2Panel:ctor(data)

    self:init("ui/ui_hd_6bei.map")
    self.curData=data

    -- self:replaceLabelString("txt_vip",gUserInfo.vip)
    -- self:replaceLabelString("txt_vip_tip",Data.getCanBuyTimesVip(VIP_FUND));
    -- self:replaceRtfString("txt_buy",Data.activity.fundNeedDia);

    Data.bolNewInvest = true
    Net.sendActivityInvest()
end

function ActivityInvest2Panel:onPopup()
    Net.sendActivityInvest()
end

function ActivityInvest2Panel:onTouchEnded(target)

    if  target.touchName=="btn_pay"then 
        Panel.popUp(PANEL_PAY)
    elseif  target.touchName=="btn_buy"then
        -- Panel.popUp(PANEL_PAY)
        -- Net.sendIapBuy(8)
        for key, var in pairs(iap_db) do
            if var.iapid==8 then
                PayItem.IapBuy(var)
                break
            end
        end
        -- if Unlock.isUnlock(SYS_FUND,true) then
        --     if NetErr.isDiamondEnough(Data.activity.fundNeedDia) then
        --         Net.sendActivityInvestBuy()
        --         if (TDGAItem) then
        --             gLogPurchase("investment_buy",1,Data.activity.fundNeedDia)
        --         end
        --     end
        -- else
        --     local function onOk() 
        --         Panel.popUp(PANEL_PAY)
        --     end 
        --     gConfirmCancel(gGetWords("spiritWord.plist","quick_vip_limit"),onOk)
        -- end
    end
end

function ActivityInvest2Panel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_INVEST2)then
        -- if(self.allPanel)then
        --    self.allPanel:showTime({type = ACT_TYPE_92});
        -- end
        self:setData(param)

    elseif(event==EVENT_ID_GET_ACTIVITY_INVEST2_GET or event==EVENT_ID_USER_DATA_UPDATE or event==EVENT_ID_GET_ACTIVITY_INVEST2_BUY)then
        -- if(self.allPanel)then
        --   self.allPanel:showTime({type = ACT_TYPE_92});
        -- end
        self:refreshData(param) 
    end
     
end


function ActivityInvest2Panel:setData(param)

    self:getNode("scroll"):clear()
    local lvs,dias,dia=DB.getActivityInvest()
    local id1s,id2s,num1s,num2s = DB.getActivityInvest2()
    for key, value in pairs(lvs) do
        local item=ActivityInvest2Item.new() 
        item.key=key
        item:setData({lv=toint(lvs[key]),dia=toint(dias[key]),id1=toint(id1s[key]),id2=toint(id2s[key]),num1=toint(num1s[key]),num2=toint(num2s[key])})
        self:getNode("scroll"):addItem(item) 
    end
    self:sortItem()
    self:getNode("scroll"):layout()
    self:refreshPanel()
    
end

function ActivityInvest2Panel:refreshPanel()
    local totalDia=0
    local getDia=0

    for key, item in pairs(self:getNode("scroll").items) do  
        if(item.isGet==1)then
            getDia=getDia+item.dia
        end
        totalDia=totalDia+item.dia
 
    end

    if (Data.activityInvestBuy) then
        self:setTouchEnable("btn_buy",false,true)
    end
    -- self:replaceRtfString("txt_get",totalDia);

    -- self:getNode("panel_buy"):setVisible(Data.activityInvestBuy)
    -- self:getNode("panel_no_buy"):setVisible(not Data.activityInvestBuy)


    -- self:setLabelString("txt_get_num",gGetWords("labelWords.plist","lb_touzi_get",getDia))
    -- self:setLabelString("txt_remain_num",gGetWords("labelWords.plist","lb_touzi_remain",totalDia-getDia))
end

function ActivityInvest2Panel:sortItem()

    local sortItemFunc = function(a, b)
        if(a.isGet==b.isGet)then
            return a.key<b.key
        else
            return a.isGet<b.isGet
        end
    end
    table.sort(self:getNode("scroll").items, sortItemFunc)
end

function ActivityInvest2Panel:refreshData(param)
    for key, item in pairs(self:getNode("scroll").items) do 
        item:refreshData(param)  
    end
    

    if(Data.activityInvestBuy==true)then
        self:setTouchEnable("btn_buy",false,true)
    end

    self:sortItem()
    self:getNode("scroll"):layout()
    self:refreshPanel()
    self:replaceLabelString("txt_vip",gUserInfo.vip);
end       

return ActivityInvest2Panel