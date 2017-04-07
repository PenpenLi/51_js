local PayItem=class("PayItem",UILayer)

function PayItem:ctor()
    self:init("ui/ui_pay_item.map")

end

local lCurData=nil
function PayItem.pay(orderid)
        if(gGetCurPlatform() ~= CHANNEL_ANDROID_GFAN and gGetCurPlatform() ~= CHANNEL_ANDROID_XIANXIA)then
            Scene.showWaiting()
        end
        local data={}
        data.iapid=lCurData.iapid
        data.serveridName= gAccount:getCurServer().name
        data.diamond = lCurData.diamond
        data.present = lCurData.present
        data.roleLevel = Data.getCurLevel()
        data.roleName =  Data.getCurName()
        data.vipLevel = Data.getCurVip()
        data.accountid = gAccount.accountid
        data.curDiamond = Data.getCurDia()
        data.account = gAccount:getAccountName()
        if Module.isClose(SWITCH_Alipay) == false then
            data.payType = "1" --alipay
        elseif Module.isClose(SWITCH_IAppPay) == false then
            data.payType = "2" --iapppay
        elseif Module.isClose(SWITCH_IAppPayH5) == false then
            data.payType = "3" --iapppayH5
        end

        --appstore 爱贝用网页支付
        if(data.payType == "3")then
            local function callback(data)
                local url  = "https://web.iapppay.com/pay/gateway?data="..data.data.."&sign="..data.sign.."&sign_type=RSA"
                PlatformFunc:sharedPlatformFunc():openURL(url)
            end

            local iapdata={}
            iapdata.platform=gAccount:getPlatformId()
            iapdata.oid=orderid
            iapdata.iapid=lCurData.iapid+1
            iapdata.money=lCurData.money
            iapdata.aid=gUserInfo.id
            iapdata.cpprivateinfo=gAccount:getCurRole().serverid.."_"..gAccount:getPlatformId().."_"..gAccount.accountid
            iapdata.cpurl = gAccount:getPackageName()..".pay://"
            gAccount:getIapOrder(iapdata,callback)
        else
            local extra=gAccount:tableToString(data)
            ChannelPro:sharedChannelPro():pay(lCurData.money,orderid,lCurData.productid,gUserInfo.id,gAccount:getCurRole().serverid,extra)
        end
        -- if (TDGAVirtualCurrency) then
        --     TDGAVirtualCurrency:onChargeRequest(orderid, lCurData.productid, lCurData.money, "CNY", lCurData.diamond, "元宝")
            if (gPayInfo == nil) then
                gPayInfo = {}
            end
            gPayInfo[orderid] = lCurData.money
        -- end 
        if (data.iapid==8) then
            Net.sendActivityInvest()
        end

        -- if(gGetCurPlatform() == CHANNEL_ANDROID_TENCENT)then
        --     local userId= gAccount:getCurRole().userid
        --     local serverId =gAccount:getCurRole().serverid
        --     local platformId = gAccount:getPlatformId()
        --     Net.addReceipt("",userId,serverId,platformId,orderid,"","",""..data.iapid)
        -- end
end

--"{\"result\":\"%d\",\"orderId\":\"%s\",\"orderIdsec\":\"%s\",\"receipt\":\"%s\"}"
function PayItem.onPayCallback(strResult)
    print("PayItem.onPayCallback "..strResult)
    Scene.hideWaiting()
    local parseTable =  json.decode(strResult)   
    if ChannelPro ~= nil and parseTable~=nil then
        print("PayItem.onPayCallback 1")
        local platformid = gAccount:getPlatformId()
        --appstore
        if (parseTable.payType == nil or parseTable.payType=="0") and (platformid == CHANNEL_APPSTORE or platformid == CHANNEL_IOS_JIURU or platformid == CHANNEL_IOS_JITUO) then
            print("PayItem.onPayCallback 2")
            if parseTable.result=="0" then
                Net.sendIapCancel(parseTable.orderId)
            elseif parseTable.result=="1" then
                local sign = ""
                if parseTable.sign then
                    sign = parseTable.sign
                end
                Net.sendIapCheckReceipt(parseTable.payurl,parseTable.orderId,parseTable.receipt,sign)
            end
        elseif platformid == CHANNEL_ANDROID_TENCENT then
            print("PayItem.onPayCallback 3")
            if parseTable.result=="1" then
                print("PayItem.onPayCallback 3_1")
                Net.sendCheckOrder(parseTable.orderId,parseTable.iapId)
            else
                print("PayItem.onPayCallback 3_2")
                Net.sendIapCancel(parseTable.orderId)
            --     Net.removeReceipt(parseTable.orderId,true)
            end
        else
            print("PayItem.onPayCallback 4")
            -- print_lua_table(gPayInfo, 4)
            --test only
            -- if (gOnAdPay) then
            --     gOnAdPay(gUserInfo.id, parseTable.orderId, gPayInfo[parseTable.orderId], "CNY", "钻石")
            -- end

            if Net.isCheckingOrder == true then
                Net.iIapCheckCount=0
                return
            end
            Net.sendCheckOrder(parseTable.orderId)
        end
    else

    end

end

function PayItem.IapBuy(data)
        lCurData = data
        Net.sendIapBuy(data.iapid)
end

function PayItem:onTouchEnded(target) 

   
    if(self:getNode("btn_pay").__touchable==true)then--target.touchName=="btn_pay")then
        if(Module.isClose(SWITCH_PAY))then
            gShowNotice(gGetWords("vipWords.plist","41"));
            return;
        end
        if APPSTOREMODE == GUESTMODE and not Module.isClose(SWITCH_VIP) then
            gShowNotice(gGetWords("noticeWords.plist", "bind_pay_error"))
            Panel.popUpUnVisible(PANEL_WX_BIND,nil,nil,true)
            return
        end
        if(gNoticeAppstoreUpdate())then
            return
        end
        lCurData = self.curData
        Net.sendIapBuy(self.curData.iapid)
    end
end

 

function   PayItem:setData(data)
    self.curData=data
    Icon.setIapIcon( self:getNode("icon"),data.iapid)
    self:setLabelString("txt_dia",data.diamond)
    self:setLabelString("txt_money",data.money..gGetWords("labelWords.plist","money_symbol"))
    
    -- self:getNode("present_icon"):setVisible(false)
 
   
    self:refreshBtn();
end

function PayItem:refreshBtn()

    self:getNode("txt_present"):setVisible(false)
    if self.curData.iapid == CARD_TYPE_MON or self.curData.iapid == CARD_TYPE_LIFE then
        local dia = 0;
        if self.curData.iapid == CARD_TYPE_MON then
            dia = DB.getDiaForMonthCard();
        elseif self.curData.iapid == CARD_TYPE_LIFE then
            dia = DB.getDiaForLifeCard();
        end

        self:getNode("txt_present"):setVisible(true)
        local word= gGetWords("labelWords.plist","lab_card_pay",dia);
        self:setRTFString("txt_present",word)

    elseif(self.curData.present_first>0 and (gIapBuy["iap"..self.curData.iapid] == nil or gIapBuy["iap"..self.curData.iapid] == false))then
        self:getNode("txt_present"):setVisible(true)
        -- self:getNode("present_icon"):setVisible(true)

        local word= gGetWords("labelWords.plist","lab_up_preset_fisrt",self.curData.present_first)
        self:setRTFString("txt_present",word)
    elseif(self.curData.present>0)then 
        self:getNode("txt_present"):setVisible(true)
        -- self:getNode("present_icon"):setVisible(true)

        local word= gGetWords("labelWords.plist","lab_up_preset",self.curData.present)
        self:setRTFString("txt_present",word)
    end


    if self.curData.iapid == CARD_TYPE_MON then
        local buyed = Data.hasMemberCard(self.curData.iapid); 
        if buyed then
            self:setLabelString("txt_money",gGetWords("btnWords.plist","btn_buy_again"));
            local word=  gGetWords("labelWords.plist","lb_hd_card_time1",gParserDay( gIapBuy["mctime"])) 
            self:setRTFString("txt_present",word)
        end 
    elseif self.curData.iapid == CARD_TYPE_LIFE then
        local buyed = Data.hasMemberCard(self.curData.iapid);
        
        if buyed then
            self:setTouchEnable("btn_pay",false,true);
            self:setLabelString("txt_money",gGetWords("btnWords.plist","btn_buyed"));
            self:getNode("flag_recommend"):setVisible(false);
        end
    else
        if self.curData.present_first>0 then
            if(  gIapBuy["iap"..self.curData.iapid] )then
                self:getNode("flag_recommend"):setVisible(false);
            end
        else 
            self:getNode("flag_recommend"):setVisible(false);
        end
    end

  
end



return PayItem