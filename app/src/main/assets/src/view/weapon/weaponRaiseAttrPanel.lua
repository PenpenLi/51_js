function WeaponRaisePanel:initRaiseAttrPanel()
    if(self.raiseInited==true)then
        return
    end
    self.raiseInited=true
    self:selectRaiseDan(1)
    for key, attr in pairs(RaiseAttr) do
        self:setLabelString("txt_name"..key,CardPro.getAttrName(attr))
    end 
end



function  WeaponRaisePanel:initUpdate()
    self.dt=0
    local function updateShopTime(dt)
        if(self:getNode("btn_raise_panel"):isVisible())then  
            self.dt=self.dt+dt
            if(self.dt>2)then
                self.dt=0
                local idx=getRand(0,100)
                if( idx>20)then
                    idx=idx%4+1
                    self:getNode("dian_effect"..idx):setVisible(true)
                    local function playEnd()
                        self:getNode("dian_effect"..idx):setVisible(false)
                    end
                    self:getNode("dian_effect"..idx).curAction=""
                    self:getNode("dian_effect"..idx):playAction("ui_weapon_dian",playEnd)
                end
            end
        end 
    end
    self:getNode("btn_raise"):scheduleUpdateWithPriorityLua(updateShopTime,1)
end




function WeaponRaisePanel:showRaideAttrPanel(data,cancel,showChange) 
    local card=self.curCard
    self:initRaiseAttrPanel()
    self:refreshRaiseBuff(card,showChange)  
    self:initBatchTime()
    self:initRaiseAttrData(card,showChange)
    self:resetLayOut()
    if(data==nil or data.cardid==0 )then
        self:showRaideEmpty()
        return
    end
    local totalNum=0
    local isAllAdd=true
    for i=1, 4 do
        local cur=card["raise_"..self:getAttrFlag(RaiseAttr[i])]
        local num=data[self:getAttrFlag(RaiseAttr[i]).."Last"]
        local txt=num-cur  
        if(txt==0)then
            txt="+"..txt
            self:getNode("txt_add"..i):setColor(cc.c3b(255,255,255))
        elseif(txt>0)then
            txt="+"..txt
            self:getNode("txt_add"..i):setColor(cc.c3b(0,255,0))
        else
            isAllAdd=false
            self:getNode("txt_add"..i):setColor(cc.c3b(255,0,0))
        end 
        totalNum=totalNum+num
        self:setLabelString("txt_add"..i, txt)
    end

    if(totalNum==0)then
        self:showRaideEmpty()
        return
    end
 


    self:setTouchEnable("btn_cancel",not isAllAdd,isAllAdd) 
    self:getNode("btn_save"):setVisible(true)
    self:getNode("btn_cancel"):setVisible(true)
    self:getNode("btn_do_raise"):setVisible(false)
    self:getNode("btn_raise_time"):setVisible(false)
end


function WeaponRaisePanel:clearParticle()
   --[[ for particle, var in pairs( self.particles ) do
        particle:removeFromParent()
    end
    self.particles={}
    ]]
end
function WeaponRaisePanel:initRaiseAttrData(card,showChange)
  
    local attrMax=Data.getCardRaiseAttrMax(card)
    local hasShowEffec=false
    for key, attr in pairs(RaiseAttr) do
        local max=attrMax[attr]
        local cur=card["raise_"..self:getAttrFlag(attr)]
        self:setLabelString("txt_per"..key,cur.."/"..max)

        if(showChange and self:getNode("txt_per"..key).cur )then
            if(cur>self:getNode("txt_per"..key).cur and self.particles[key]==nil)then
                local particle =  cc.ParticleSystemQuad:create("particle/qp_lizi.plist");
                self.particles[key]=1
                self:getNode("txt_power_exp"):getParent():addChild(particle,100);
                local toWordPos= self:getNode("txt_per"..key):convertToWorldSpace(cc.p(0,0))
                local toPos =self:getNode("txt_power_exp"):getParent():convertToNodeSpace(toWordPos)
                particle:setPosition(toPos)
                local posx,posy=self:getNode("txt_power_exp"):getPosition()
                local function moveEnd()
                    self.particles[key]=nil
                    particle:removeFromParent()
                end
                local function moveFinal()
                    self.particles[key]=nil
                    particle:removeFromParent()
                    loadFlaXml("ui_cuilian")
                    self:getNode("panel_power_raise"):removeChildByTag(99)
                    local effect=gCreateFla("ui_cuilian_effect")
                    effect:setTag(99)
                    gAddCenter(effect,self:getNode("panel_power_raise"))
                end
                local callFunc=nil
                if(hasShowEffec==false)then
                    hasShowEffec=true
                    callFunc=cc.CallFunc:create(moveFinal)
                else
                    callFunc=cc.CallFunc:create(moveEnd)
                end
                particle:runAction(
                    cc.Sequence:create(
                        cc.EaseOut:create(cc.MoveTo:create(0.6,cc.p(posx,posy)),2),
                        callFunc
                    )
                )
            end
        end
        self:getNode("txt_per"..key).cur=cur
        self:getNode("txt_per"..key).max=max
        local size=self:getNode("raise_cup"..key):getContentSize()
        self:getNode("raise_cup"..key).stencil:setContentSize(cc.size(size.width, 125*cur/max))

        self:getNode("pao_effect"..key):setPositionY(-110+125*cur/max)
    end

end


function WeaponRaisePanel:showRaideEmpty() 
    for key, attr in pairs(RaiseAttr) do
        self:setLabelString("txt_add"..key,"")
        self:getNode("txt_add"..key):setColor(cc.c3b(255,255,255))
    end
    self:getNode("btn_save"):setVisible(false)
    self:getNode("btn_cancel"):setVisible(false)
    self:getNode("btn_do_raise"):setVisible(true)
    self:getNode("btn_raise_time"):setVisible(not Module.isClose(SWITCH_VIP));
end




function WeaponRaisePanel:refreshRaiseBuff(card,showChange)
    local power= CardPro.countWeaponPower(card)
    local powerData=DB.getCardRaisePower(power)
    local totalPower=0
    local nextLevel=1
    if(powerData)then
        self:replaceLabelString("txt_power_level",powerData.level)
        nextLevel=powerData.level+1
    else
        self:replaceLabelString("txt_power_level",0)
    end
    local nextPowerData=DB.getCardRaisePowerByLevel(nextLevel)
    if(nextPowerData==nil)then
        totalPower=powerData.power
    else
        totalPower=nextPowerData.power
    end


    local function changePower(target,data)
        AttChange.pushPower(PANEL_CARD_WEAPON_RAISE, data.power1,data.power2)
    end


    local function changeLevel()
        loadFlaXml("ui_cuilian")
        self:getNode("panel_power_raise"):removeChildByTag(99)
        local effect=gCreateFla("ui_cuilian_shengji")
        effect:setTag(99)
        gAddCenter(effect,self:getNode("panel_power_raise"))
    end


    if(showChange  )then
        self:getNode("bar_power"):stopAllActions()
        if(self.lastLevel~=nextLevel)then
            self:getNode("bar_power"):runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(1.0),
                    cc.CallFunc:create(changeLevel)
                ))
        end

        if(  self.lastPower~=nil)then
            self:getNode("bar_power"):runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(0.6),
                    cc.CallFunc:create(changePower,{power1=self.lastPower,power2=power})
                ))
        end
    end
    self.lastPower=power
    self.lastLevel=nextLevel

    self:setLabelString("txt_power_exp",power.."/"..totalPower)
    self:setBarPer("bar_power",power/totalPower)

end

function WeaponRaisePanel:initBatchTime()

    local danNums=DB.getRaiseNeedDan()
    for key, var in pairs(danNums) do
        self:getNode("raise_dan_panel"..key).danNum=var
        self:getNode("raise_dan_panel"..key).goldNum=0
        self:getNode("raise_dan_panel"..key).diaNum=0
        self:setLabelString("txt_dan"..key,var*Data.cardRaiseBatchTime)
    end

    self:setRTFString("txt_raise_time",gGetWords("labelWords.plist","card_raise_time", Data.cardRaiseBatchTime))
    self:setLabelString("txt_raise_gold",DB.getRaiseCardNeedGold(self.curCard)*Data.cardRaiseBatchTime)
    self:setLabelString("txt_raise_dia",DB.getRaiseNeedDia()*Data.cardRaiseBatchTime)

    self:getNode("raise_dan_panel2").goldNum=DB.getRaiseCardNeedGold(self.curCard)*Data.cardRaiseBatchTime
    self:getNode("raise_dan_panel3").diaNum=DB.getRaiseNeedDia()*Data.cardRaiseBatchTime
    self:resetLayOut()
end

function  WeaponRaisePanel:doRaise(target) 
    if(self.curCardid==nil)then
        return
    end
    if(self.curRaiseType==nil)then
        return
    end
    if Data.cardRaiseBatchTime > 1 then
        local temp={}
        for key, var in pairs(vip_db) do
            if(temp[var.raise_21]==nil)then
                temp[var.raise_21]=var.vip
            end
        end

        local vipRaiseNeeds = {}
        local idx=1
        for key, var in pairs(temp) do
            vipRaiseNeeds[idx]=var
            idx=idx+1
        end

        VIP_RAISE_TIME_LEVEL={0,60,70}
        local raiseLeveltab = DB.getClientParamToTable("WEAPON_RAISE_LEVEL",true)
        if raiseLeveltab and table.count(raiseLeveltab)==3 then
            VIP_RAISE_TIME_LEVEL = raiseLeveltab
        end

        local needVip=0
        local needLevel = 0
        for key, var in pairs(VIP_RAISE_TIME) do
            if Data.cardRaiseBatchTime == var then
                needVip = vipRaiseNeeds[key]
                needLevel = VIP_RAISE_TIME_LEVEL[key]
                break
            end
        end
    
        if Data.getCurVip() < needVip and Data.getCurLevel() <needLevel then
            local txt = gGetCmdCodeWord("act.getreward88",27)
            txt = txt..","..gGetWords("activityNameWords.plist","act_timeover")
            gShowNotice(txt)
            return
        end
    end

    local node=self:getNode("raise_dan_panel"..self.curRaiseType)

    if(NetErr.isGoldEnough(node.goldNum)==false)then
        return
    end
    if(NetErr.isDiamondEnough(node.diaNum)==false)then
        return
    end
    if(NetErr.isEquipSoulEnough(node.danNum*Data.cardRaiseBatchTime)==false)then
        return
    end
    isFull=true
    for key=1, 4 do
        if(self:getNode("txt_per"..key).cur<self:getNode("txt_per"..key).max)then
            isFull=false
        end
    end
    if(isFull)then
        gShowNotice(gGetWords("noticeWords.plist","card_raise_full"))
        return
    end

    if (node.diaNum > 0) then
        gLogPurchase("card.raise", 1, node.diaNum)
    end

    Net.sendCardRaise(self.curCardid,self.curRaiseType-1,Data.cardRaiseBatchTime)
end

function WeaponRaisePanel:selectRaiseDan(type)
    self.curRaiseType=type
    for i=1, 3 do
        self:changeTexture("raise_select_icon"..i,"images/ui_public1/gou_2.png")
    end
    self:changeTexture("raise_select_icon"..type,"images/ui_public1/gou_1.png")
end
