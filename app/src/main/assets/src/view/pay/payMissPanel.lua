local PayMissPanel=class("PayMissPanel",UILayer)

function PayMissPanel:ctor(param)

    self:init("ui/ui_yyb_pay.map")
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:createContent();
end

function PayMissPanel:events()
    return {
        EVENT_ID_PAY_CHECK_ORDER_MISS,
        EVENT_ID_PAY_DELETE_ORDER_MISS
    }
end

function PayMissPanel:dealEvent(event,param)
    if(event==EVENT_ID_PAY_CHECK_ORDER_MISS)then
        self:createContent() 
    elseif(event == EVENT_ID_PAY_DELETE_ORDER_MISS)then
        self:createContent();
    end
end

function PayMissPanel:createContent()
    self:getNode("scroll"):clear();
    local userid = gAccount:getCurRole().userid
    -- local rootjson = cc.UserDefault:getInstance():getStringForKey(userid, "{}")
    -- local rootTable = json.decode(rootjson)
    local serverid = gAccount:getCurRole().serverid
    local platformid = gAccount:getPlatformId()
    for key, var in pairs(iap_db) do
        local isRecord = false;
        -- for keyRecord, varRecord in pairs(rootTable) do
        --     local valueTable = json.decode(varRecord)
        --     if valueTable.serverid == serverid and valueTable.platform == platformid  and toint(var.iapid) == toint(valueTable.iapid) then
        --         local item=PayMissItem.new()
        --         isRecord = true;
        --         item:setData(var,valueTable,isRecord) 
        --         self:getNode("scroll"):addItem(item)
        --         break
        --     end
        -- end
        if(isRecord == false)then
            local isVisible = false;
            if(var.iapid <= 8)then
                if(gIapBuy["iap"..var.iapid]== nil or gIapBuy["iap"..var.iapid] == false or var.buyonetime == 0)then
                    isVisible = true;
                end
            elseif(var.iapid > 8) then
                if(Unlock.isUnlock(SYS_HALO,false))then
                    local size = #Data.halo_price
                    local haloIndex = math.min(size-1,Data.getCurHalo()) + 1
                    if(haloIndex+8 == var.iapid and Data.getCurHalo()<size)then
                        isVisible = true;
                    end
                end
            end

            if(isVisible)then
                local data={}
                data.oid=userid..socket.gettime()
                data.serverid=serverid
                data.userid=userid
                data.platform=platformid
                data.time=gGetCurServerTime()
                data.iapid=var.iapid
                local item=PayMissItem.new()
                item:setData(var,data,isRecord) 
                self:getNode("scroll"):addItem(item)
            end
        end
    end

    self:getNode("scroll"):layout()
end

function PayMissPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return PayMissPanel