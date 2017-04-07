local WeaponRaiseVipPanel=class("WeaponRaiseVipPanel",UILayer)



function WeaponRaiseVipPanel:ctor( callback)
    self.appearType = 1;
    self.isMainLayerMenuShow = false;
    self.isWindow = true;
    self:init("ui/ui_weapon_raise_vip.map")

    self.callback=callback
    
    VIP_RAISE_TIME_VIP={}
    VIP_RAISE_TIME_LEVEL={0,60,70}
    local raiseLeveltab = DB.getClientParamToTable("WEAPON_RAISE_LEVEL",true)
    if raiseLeveltab and table.count(raiseLeveltab)==3 then
        VIP_RAISE_TIME_LEVEL = raiseLeveltab
    end
    local temp={}
    for key, var in pairs(vip_db) do
        if(temp[var.raise_21]==nil)then
            temp[var.raise_21]=var.vip
        end
    end
    
    local idx=1
    for key, var in pairs(temp) do
    	VIP_RAISE_TIME_VIP[idx]=var
        idx=idx+1
    end
     
    
   --local a= VIP_RAISE_TIME_VIP

    for i=1, 3 do
        self:setRTFString("raise_time"..i,gGetWords("labelWords.plist","card_raise_time", VIP_RAISE_TIME[i]))
        self:replaceLabelString("raise_vip"..i,VIP_RAISE_TIME_VIP[i],VIP_RAISE_TIME_LEVEL[i])

        if(Data.getCurVip()>=VIP_RAISE_TIME_VIP[i] or Data.getCurLevel() >= VIP_RAISE_TIME_LEVEL[i])then
            self:getNode("raise_vip"..i):setVisible(false) 
        else
            self:getNode("raise_vip"..i):setVisible(true) 

        end
    end

    self:selectVip(1)
end


function WeaponRaiseVipPanel:selectVip(type)
    if(Data.getCurVip()<VIP_RAISE_TIME_VIP[type]) and Data.getCurLevel() < VIP_RAISE_TIME_LEVEL[type] then
        local word=  gGetWords("labelWords.plist","203", VIP_RAISE_TIME_VIP[type],VIP_RAISE_TIME_LEVEL[type])
        gShowNotice(word)
        return
    end
    
    self.curRaiseType=type
    for i=1, 3 do
        self:changeTexture("raise_select_icon"..i,"images/ui_public1/gou_2.png")
    end
    self:changeTexture("raise_select_icon"..type,"images/ui_public1/gou_1.png")
end



function WeaponRaiseVipPanel:onSelectBatchTime(idx)

    if(Data.getCurVip()<VIP_RAISE_TIME_VIP[idx] and Data.getCurLevel() < VIP_RAISE_TIME_LEVEL[idx] )then
        return
    end
    Data.cardRaiseBatchTime=VIP_RAISE_TIME[idx]
    self.callback()
    Panel.popBack(self:getTag())
end


function WeaponRaiseVipPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="touch1"then
        self:selectVip(1)
    elseif  target.touchName=="touch2"then
        self:selectVip(2)
    elseif  target.touchName=="touch3"then
        self:selectVip(3)
    elseif  target.touchName=="btn_get"then
        self:onSelectBatchTime(self.curRaiseType)
        Panel.popBack(self:getTag())

    end
end


return WeaponRaiseVipPanel

 