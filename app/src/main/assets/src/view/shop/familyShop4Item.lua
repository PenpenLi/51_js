local FamilyShop4Item=class("FamilyShop4Item",UILayer)

function FamilyShop4Item:ctor(idx)
    self.idx = idx
end

function FamilyShop4Item:initSchedule()
    self:scheduleUpdate(function()
        local lefttime = self.endtime - gGetCurServerTime()
        if lefttime > 0 then
            self:setLabelString("txt_lefttime", gParserHourTime(lefttime))
        else
            self:setLabelString("txt_lefttime", gGetWords("shopWords.plist","9"))
            self:unscheduleUpdateEx()
        end
        self:getNode("layout_lefttime"):layout()
    end, 1) 
end

function FamilyShop4Item:initPanel()
    if (self.inited ~= nil) and (not self.inited) then
        return
    end

    self.inited = true
    self:init("ui/ui_family_shop4_item.map")
end


function FamilyShop4Item:setData(data)
    self:initPanel()
    self.curData=data 
    -- print_lua_table(data.items);

    local item = Icon.setDropItem(self:getNode("icon"),data.itemid,data.itemnum,DB.getItemQuality(data.itemid))
    self:getNode("icon"):setOpacity(255);

    self:setLabelString("txt_cur_price", data.curp)
    self:getNode("layout_cur_price"):layout()

    --倒计时显示
    self.endtime = data.endtime
    self:initSchedule()
    --出价人
    if data.uname ~= "" then
        self:setLabelString("txt_uname", data.uname)
        self:getNode("layout_cur_uname"):layout()
        self:getNode("layout_cur_uname"):setVisible(true)
        if data.uname == Data.getCurName() then
            self:getNode("icon_me"):setVisible(true)
        end
    else
        self:getNode("layout_cur_uname"):setVisible(false)
    end

    --此次出价
    self:setLabelString("txt_need_price", data.needp)
    self:getNode("layout_need_price"):layout()
end

function FamilyShop4Item:refreshData(data,idx)
    self:setData(self.curData)
end

function FamilyShop4Item:onUILayerExit()
    if self.super ~= nil then
       self.super:onUILayerExit()
    end
    self:unscheduleUpdateEx()
end

function FamilyShop4Item:onTouchEnded(target,touch, event)
    if target.touchName=="btn_add_price" then
        if (Data.getCurFamilyMoney() < self.curData.needp) then
            gShowNotice(gGetWords("noticeWords.plist","no_enough_famoney"))
            return
        end
        Net.sendFamilyHotSellAddPrice(self.curData.dbid)
    end 
end

function  FamilyShop4Item:setDataLazyCalled()
    self:setData(self.lazyData)
end

function  FamilyShop4Item:setLazyData(data)
    self.lazyData=data 
    Scene.addLazyFunc(self,self.setDataLazyCalled,"familyshop4item")
end

return FamilyShop4Item