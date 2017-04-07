local ActivityInvestPanel=class("ActivityInvestPanel",UILayer)

function ActivityInvestPanel:ctor(data)

    self:init("ui/ui_hd_touzi.map")
    self.curData=data

    self:replaceLabelString("txt_vip",gUserInfo.vip)
    self:replaceLabelString("txt_vip_tip",Data.getCanBuyTimesVip(VIP_FUND));
    self:replaceRtfString("txt_buy",Data.activity.fundNeedDia);
    
    Data.bolNewInvest = false
    Net.sendActivityInvest()
end


function ActivityInvestPanel:onTouchEnded(target)

    if  target.touchName=="btn_pay"then 
        Panel.popUp(PANEL_PAY)
    elseif  target.touchName=="btn_buy"then
        if Unlock.isUnlock(SYS_FUND,true) then
            if NetErr.isDiamondEnough(Data.activity.fundNeedDia) then
                Net.sendActivityInvestBuy()
                if (TDGAItem) then
                    gLogPurchase("investment_buy",1,Data.activity.fundNeedDia)
                end
            end
        else
            local function onOk() 
                Panel.popUp(PANEL_PAY)
            end 
            gConfirmCancel(gGetWords("spiritWord.plist","quick_vip_limit"),onOk)
        end
    end
end

function ActivityInvestPanel:dealEvent(event,param)
    if(event==EVENT_ID_GET_ACTIVITY_INVEST)then
        self:setData(param)

    elseif(event==EVENT_ID_GET_ACTIVITY_INVEST_GET or event==EVENT_ID_USER_DATA_UPDATE or event==EVENT_ID_GET_ACTIVITY_INVEST_BUY)then
        self:refreshData(param) 
    end
     
end


function ActivityInvestPanel:setData(param)

    self:getNode("scroll"):clear()
    local lvs,dias,dia=DB.getActivityInvest()
    for key, value in pairs(lvs) do
        local item=ActivityInvestItem.new() 
        item.key=key
        item:setData({lv=lvs[key],dia=dias[key]})
        self:getNode("scroll"):addItem(item) 
    end
    self:sortItem()
    self:getNode("scroll"):layout()
    self:refreshPanel()
    
end

function ActivityInvestPanel:refreshPanel()
    local totalDia=0
    local getDia=0

    for key, item in pairs(self:getNode("scroll").items) do  
        if(item.isGet==1)then
            getDia=getDia+item.dia
        end
        totalDia=totalDia+item.dia
 
    end
    self:replaceRtfString("txt_buy",Data.activity.fundNeedDia,totalDia);
    -- self:replaceRtfString("txt_get",totalDia);

    self:getNode("panel_buy"):setVisible(Data.activityInvestBuy)
    self:getNode("panel_no_buy"):setVisible(not Data.activityInvestBuy)


    self:setLabelString("txt_get_num",gGetWords("labelWords.plist","lb_touzi_get",getDia))
    self:setLabelString("txt_remain_num",gGetWords("labelWords.plist","lb_touzi_remain",totalDia-getDia))
end

function ActivityInvestPanel:sortItem()

    local sortItemFunc = function(a, b)
        if(a.isGet==b.isGet)then
            return a.key<b.key
        else
            return a.isGet<b.isGet
        end
    end
    table.sort(self:getNode("scroll").items, sortItemFunc)
end

function ActivityInvestPanel:refreshData(param)
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

return ActivityInvestPanel