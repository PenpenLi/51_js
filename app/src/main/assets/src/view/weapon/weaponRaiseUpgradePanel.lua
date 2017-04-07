
function WeaponRaisePanel:showRaideUpgradePanel(cardid,showChange) 
    local card=self.curCard
    local levelData=DB.getCardRaiseByLevel(card.cardid,card.weaponLv+1) 

    self:getNode("txt_need_level"):setVisible(false)
    self.initRate=0
    self:getNode("btn_do_strong"):setVisible(false)
    self:getNode("btn_do_strong2"):setVisible(false)
    self:getNode("panel_need_items"):setVisible(true)
    self:getNode("weapon_gold_panel"):setVisible(true)
    self:getNode("txt_max_level"):setVisible(false)
    if(card.weaponLv<Data.cardRaiseMaxLevel and levelData)then

        for i=1, 5 do
            Icon.setIcon(  levelData["itemid"..i],self:getNode("icon_need"..i))
        end

        for i=1, 4 do
            local maxName=RaiseMaxAttrDbName[i]
            local attrName=RaiseAttrDbName[i]
            local txt=""
            if(levelData[attrName]>0)then
                txt=gGetWords("labelWords.plist","raise_attr_"..i,levelData[attrName])
            else
                txt=gGetWords("labelWords.plist","raise_attr_limit_"..i,levelData[maxName])
            end
            self:setRTFString("txt_limit"..i, txt)
        end

        for i=1, 5 do
            self:getNode("icon_need"..i).itemid=levelData["itemid"..i]
            local cur=Data.getItemNum(levelData["itemid"..i])
            local max=levelData["itemnum"..i]
            self:getNode("txt_need"..i).cur=cur
            self:getNode("txt_need"..i).max=max
            if(max==0)then
                self:getNode("item_container"..i):setVisible(false)
            else
                self:setLabelString("txt_need"..i,cur.."/"..max)
                self:getNode("item_container"..i):setVisible(true)
                if cur>=max then
                    self:getNode("txt_need"..i):setColor(cc.c3b(0,255,0))
                else
                    self:getNode("txt_need"..i):setColor(cc.c3b(255,0,0))
                end
            end
        end

        if(gUserInfo.level<levelData.userlevel)then
            self:getNode("txt_need_level"):setVisible(true)
            self:replaceLabelString("txt_need_level", levelData.userlevel)
            self:getNode("txt_need_level").level=levelData.userlevel
        end


        self:setLabelString("txt_strong_gold",levelData.upgrade_price)
        self:setLabelString("txt_strong_dia",levelData.upgrade_diamond)
        self:getNode("effect_panel1"):setVisible(false)
        self:getNode("effect_panel2"):setVisible(false)
        local buff=DB.getBuffById(levelData.buffid)

        if(buff)then

            self:replaceRtfString("txt_next_level2",gParseWeaponLv(card.weaponLv+1))
            self:getNode("effect_panel2"):setVisible(true)
            self:getNode("btn_do_strong2"):setVisible(true)
            local desc=  gGetBuffDesc(DB.getBuffById(levelData.buffid),1)
            self:setLabelString("txt_next_desc2",gGetWords("labelWords.plist","card_raise_nex_level_desc",desc))
        else
            self:replaceRtfString("txt_next_level1",(card.weaponLv+1)%6)
            self:getNode("effect_panel1"):setVisible(true)
            self:getNode("btn_do_strong"):setVisible(true)
        end

        self.initRate=levelData.rate_init
    else    --满级
        self:getNode("txt_max_level"):setVisible(true)
        self:getNode("panel_need_items"):setVisible(false)
        self:getNode("weapon_gold_panel"):setVisible(false)
        self:setLabelString("txt_next_level","")
        self:setLabelString("txt_strong_gold",0)
        self:setLabelString("txt_strong_dia",0)


        for i=1, 5 do
            self:getNode("icon_need"..i).itemid=nil
            self:setLabelString("txt_need"..i,"0/0")
        end
        self:getNode("effect_panel1"):setVisible(false)
        self:getNode("effect_panel2"):setVisible(false)
    end

    if(self:getNode("txt_strong_dia"):getString()=="0" )then
        self:getNode("weapon_dia_panel"):setVisible(false)
    else
        self:getNode("weapon_dia_panel"):setVisible(true)
    end
    self:changeAddNum(0) 
    self:replaceLabelString("txt_lv", gParseWeaponLv(  self.curCard.weaponLv))
    self:resetLayOut()
end

function WeaponRaisePanel:changeAddNum(num)
    local maxRate=100
    self:setTouchEnable("btn_add",true,false)
    self:setTouchEnable("btn_add2",true,false)
    self:setTouchEnable("btn_sub",true,false)
    self:setTouchEnable("btn_sub2",true,false)

    self.curAddRage=self.curAddRage+num
    if(self.curAddRage>=maxRate-self.initRate)then
        self.curAddRage=maxRate-self.initRate
    end
    if(self.curAddRage<0)then
        self.curAddRage=0
    end

    if(self.curAddRage+self.initRate>=100)then
        self:setTouchEnable("btn_add",false,true)
        self:setTouchEnable("btn_add2",false,true)
    end
    if(self.curAddRage==0)then
        self:setTouchEnable("btn_sub",false,true)
        self:setTouchEnable("btn_sub2",false,true)
    end

    self:setLabelString("txt_add_rate",gGetWords("labelWords.plist","txt_raise_rate_add",self.curAddRage+self.initRate))
end

 
function WeaponRaisePanel:onTouchBegan(target)
    if(target.touchName=="panel_power_raise")then
        tip= Panel.popTouchTip(self,TIP_TOUCH_RAISE,self.curCardid,nil,cc.p(0.5,0.5),cc.p(1.0,-0.5))
    end
end

function WeaponRaisePanel:dealUpgradeEvent(event,data) 
    local function  playEnd()
        self:showRaideUpgradePanel(data.id,true) 
        if(data.ret==true)then
            local card=Data.getUserCardById(data.id)
            if((card.weaponLv-1)%6==5)then
                self:showWeaponEffect()
                gShowNotice(gGetWords("noticeWords.plist","weapon_level_success2"))
            else
                gShowNotice(gGetWords("noticeWords.plist","weapon_level_success"))
            end
        else
            local card=Data.getUserCardById(data.id)
            if(card.weaponLv%6==5)then
                gShowNotice(gGetWords("noticeWords.plist","weapon_level_fail2"))
            else
                gShowNotice(gGetWords("noticeWords.plist","weapon_level_fail"))
            end
        end
        self:getNode("strong_effect"):playAction("ui_qianghua_normalcy")
        self:setTouchEnable("btn_do_strong",true,false)
        self:setTouchEnable("btn_do_strong2",true,false)
    end


    self:getNode("strong_effect"):setVisible(true)
    self:getNode("strong_effect").curAction=""
    if(data.ret==true)then
        if(getRand(0,100)>50)then
            self:getNode("strong_effect"):playAction("ui_qianghua_win_1",playEnd)
        else
            self:getNode("strong_effect"):playAction("ui_qianghua_win_2",playEnd) 
        end
    else
        self:getNode("strong_effect"):playAction("ui_qianghua_lose",playEnd)
    end

end

function WeaponRaisePanel:doUpgrade(target,event)
    if(NetErr.isGoldEnough(toint(self:getNode("txt_strong_gold"):getString()))==false)then
        return
    end
    if(NetErr.isDiamondEnough(toint(self:getNode("txt_strong_dia"):getString()))==false)then
        return
    end

    isFull=true
    for key=1, 5 do
        if(self:getNode("txt_need"..key).cur<self:getNode("txt_need"..key).max)then
            isFull=false
        end
    end
    if(isFull==false)then
        gShowNotice(gGetWords("noticeWords.plist","card_raise_no_items"))
        return
    end

    if(self:getNode("txt_need_level"):isVisible())then
        gShowNotice(gGetWords("noticeWords.plist","weapon_need_level",self:getNode("txt_need_level").level))
        return
    end


    local function sendNetMsg()

        self:setTouchEnable("btn_do_strong",false,true)
        self:setTouchEnable("btn_do_strong2",false,true)
        Net.sendCardRaiseUpgrade(self.curCardid,self.curAddRage)
    end


    local function onOk()
        sendNetMsg()
    end
    local card=Data.getUserCardById(self.curCardid)
    local check=false 

    if(check==false)then
        sendNetMsg()
    end

end