local CardInfoEquipPanel=class("CardInfoEquipPanel",UILayer)

function CardInfoEquipPanel:ctor()
    self:init("ui/ui_card_equip.map")
end




function CardInfoEquipPanel:onTouchEnded(target)
    
    if self.hasCard == false then
        return;
    end

    if(target.touchName=="btn_upgrade")then
        Net.sendEquipUpgrade(self.curCard.cardid,self.curIdx,false) 
    elseif(target.touchName=="btn_upquality")then
        local qua= self.curCard.equipQuas[self.curIdx]
        if(qua>=MAX_EQUIP_QUALITY)then 
            local sWord = gGetWords("noticeWords.plist","equip_quality_full");
            gShowNotice(sWord)
            return  
        end
        Net.sendEquipUpQuality(self.curCard.cardid,self.curIdx)
    elseif(target.touchName=="btn_put")then
        local poses={}
        local totalMoney=0
        for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
            local target=self:getNode("btn_equip"..i)
            if(target.canActivate)then
                table.insert(poses,i)
                totalMoney=totalMoney+target.comMoney 
            end
        end
        if(NetErr.isGoldEnough(totalMoney,true)==false)then
            return
        end
        
        Net.sendEquipActivateOneKey(self.curCard.cardid,self.curIdx,poses)
    elseif  string.find( target.touchName,"btn_equip")  and string.len(target.touchName)==10 then
        local pos=toint(string.sub(target.touchName,10,string.len(target.touchName)))
        if(self.compound==nil)then
            return
        end

        local itemId= self.compound["item"..(pos+1)]
        local data={}
        data.hasActivate=target.hasActivate
        data.canActivate=target.canActivate
        data.cardid=self.curCard.cardid
        data.equipIdx=self.curIdx
        data.activatePos=pos
        data.equipQua=self.curCard.equipQuas[self.curIdx]
        data.equipLv=self.curCard.equipLvs[self.curIdx]
        data.itemid=itemId
        if(data.hasActivate)then
            Panel.popUp(TIP_PANEL_EQUIP_INFO,data)
        elseif(target.canActivate and target.needCom~=true)then
            Panel.popUp(TIP_PANEL_EQUIP_INFO,data)
        else
            Panel.popUp(TIP_PANEL_EQUIP_GET,data)
        end
    end
end

function CardInfoEquipPanel:refreshCardData(card)
    self.curCard=card
    self.cardDb=DB.getCardById(self.curCard.cardid)
end

function CardInfoEquipPanel:setCard(card,idx)
    self:refreshCardData(card);
    -- self.curCard=card
    -- self.cardDb=DB.getCardById(self.curCard.cardid)
    self.curIdx=idx
    local equipId=self.cardDb["equid"..(idx)]
    local qua= self.curCard.equipQuas[idx]
    local equipLv= self.curCard.equipLvs[idx]
    local activate= self.curCard.equipActives[idx]  

    local equipment= DB.getEquipment(equipId,qua)

    if(equipment)then
        self:setLabelString("txt_name",equipment.name)
    end
     
    self:changeTexture("quality_bg","images/ui_pic1/zbk-di"..EFFECT_QUALITY_BG[qua+1]..".png")

    Icon.setEquipmentIcon(equipment.icon,self:getNode("icon"),qua)

    self:refreshPrice(idx);
    -- local gold= DB.getEquipPriceByLevel(equipLv+1)
    -- self:setLabelString("txt_gold",gold)

    self:refreshAttr(idx);
    -- local allAttr, baseAttr=CardPro.getCardEquipUpgradeAttr(   equipId,equipLv,qua)
    -- local actvityAttr= CardPro.getCardEquipActivateAttr(equipId,qua,activate)   
    
    -- local addAttr={}
    -- for key, var in pairs(allAttr) do
    --     if(baseAttr[key]==nil)then
    --         baseAttr[key]=0
    --     end
    --     addAttr[key]=allAttr[key]-baseAttr[key]
    -- end
    
    -- for key, var in pairs(actvityAttr) do
    -- 	if(baseAttr[key]==nil)then
    -- 	   baseAttr[key]=0
    -- 	end
    --     baseAttr[key]=baseAttr[key]+var
    -- end
    
    -- local i=1
    -- for attr, value in pairs(baseAttr) do  
    --     self:setLabelString("lab_attr"..i,CardPro.getAttrName(attr))
    --     if(addAttr[attr] and addAttr[attr]>0)then
    --         self:setLabelString("txt_attr"..i,value)
    --         self:setLabelString("txt_add_attr"..i, "+"..addAttr[attr])
    --         self:getNode("txt_add_attr"..i):setPositionX(self:getNode("txt_attr"..i):getPositionX()+5+self:getNode("txt_attr"..i):getContentSize().width)
    --     else 
    --         self:setLabelString("txt_attr"..i,value)
    --         self:setLabelString("txt_add_attr"..i,"")
    --     end
    --     i=i+1
    -- end
     

    self.compound= DB.getEquCompound(equipId,qua+1)
    if(self.compound)then 
        self:setLabelString("txt_up_gold",self.compound.price_gold) 
        for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
            self:showEquipItem(i,self.compound,activate)
            local node=self:getNode("btn_equip"..i)
            node:setVisible(true)
        end
        self:getNode("panel_max_level"):setVisible(false)
    else
        for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
            local node=self:getNode("btn_equip"..i)
            local plus=self:getNode("btn_plus"..i)
            plus:setVisible(false)
            node:setVisible(false)
            node:removeAllChildren()
        end
        self:getNode("panel_max_level"):setVisible(true)
    end 
    
    self.hasCard = true;
    if(Data.getUserCardById(self.curCard.cardid)==nil)then 
        self.hasCard = false;
    end
    self:getNode("btn_upgrade"):setVisible(self.hasCard) 
    self:getNode("btn_put"):setVisible(self.hasCard) 
    self:getNode("btn_upquality"):setVisible(self.hasCard) 
    self:getNode("btn_upgrade_price"):setVisible(self.hasCard)
    self:getNode("btn_upquality_price"):setVisible(self.hasCard)
    
    if(self.hasCard)then
        --是否升阶
        if(CardPro.canEquipUpQuality(card,idx))then
            self:getNode("btn_upquality"):setVisible(true)
            self:getNode("btn_upquality_price"):setVisible(true)
            self:getNode("btn_put"):setVisible(false)
        else
            self:getNode("btn_upquality"):setVisible(false)
            self:getNode("btn_upquality_price"):setVisible(false)
            self:getNode("btn_put"):setVisible(true)
            
            local canActivite=false
            for i=0, MAX_CARD_EQUIP_COM_NUM-1 do
                local target=self:getNode("btn_equip"..i)
                if(target.canActivate)then
                    canActivite=true
                end
            end
            if(canActivite)then
                self:setTouchEnable("btn_put",true,false)
            else
                self:setTouchEnable("btn_put",false,true)
            end
        end
    end
    
    
end

function CardInfoEquipPanel:refreshPrice(idx)
    local equipLv= self.curCard.equipLvs[idx]
    local gold= DB.getEquipPriceByLevel(equipLv+1)
    self:setLabelString("txt_gold",gold)
end

function CardInfoEquipPanel:refreshAttr(idx)

    --是否能强化
    if(CardPro.canEquipUpgrade(self.curCard,idx))then
        self:setTouchEnable("btn_upgrade",true,false)
    else
        self:setTouchEnable("btn_upgrade",false,true)
    end


    local equipId=self.cardDb["equid"..(idx)]
    local qua= self.curCard.equipQuas[idx]
    local equipLv= self.curCard.equipLvs[idx]
    local activate= self.curCard.equipActives[idx]

    local allAttr, baseAttr=CardPro.getCardEquipUpgradeAttr(   equipId,equipLv,qua)
    local actvityAttr= CardPro.getCardEquipActivateAttr(equipId,qua,activate)   
    
    local addAttr={}
    for key, var in pairs(allAttr) do
        if(baseAttr[key]==nil)then
            baseAttr[key]=0
        end
        addAttr[key]=allAttr[key]-baseAttr[key]
    end
    
    for key, var in pairs(actvityAttr) do
        if(baseAttr[key]==nil)then
           baseAttr[key]=0
        end
        baseAttr[key]=baseAttr[key]+var
    end
    
    local i=1
    for attr, value in pairs(baseAttr) do  
        self:setLabelString("lab_attr"..i,CardPro.getAttrName(attr))
        if(addAttr[attr] and addAttr[attr]>0)then
            self:setLabelString("txt_attr"..i,math.rint(value))
            self:setLabelString("txt_add_attr"..i, "+"..math.rint(addAttr[attr]))
            self:getNode("txt_add_attr"..i):setPositionX(self:getNode("txt_attr"..i):getPositionX()+5+self:getNode("txt_attr"..i):getContentSize().width)
        else 
            self:setLabelString("txt_attr"..i,value)
            self:setLabelString("txt_add_attr"..i,"")
        end
        i=i+1
    end

end

function CardInfoEquipPanel:showEquipItem(idx,compound,activate)
    local node=self:getNode("btn_equip"..idx)
    local plus=self:getNode("btn_plus"..idx)
    node.canActivate=false
    node.hasActivate=false
    node.comMoney=0
    node.needCom=false
    node.canGet = false;--可获取

    local itemid= self.compound["item"..(idx+1)] 
    Icon.setEquipItemIcon(itemid,node)
    plus:setVisible(false) 

    if(CardPro.isEquipItemActivate(activate,idx))then --已经激活
        DisplayUtil.setGray(node,false)
        node.hasActivate=true
    else
        node.canActivate,node.needCom,node.comMoney=CardPro.hasEquipItemShared(itemid)
        node.canGet = Data.canGetForEquip(itemid);
        plus:setVisible(true)
        if(node.needCom)then
            plus:setTexture("images/ui_word/zb_hc.png")
        elseif(node.canActivate)then
            plus:setTexture("images/ui_word/zb_zb.png")
        elseif(node.canGet)then
            plus:setTexture("images/ui_word/zb_qu.png")
        else
            plus:setVisible(false)
            -- plus:setTexture("images/ui_word/zb_qu2.png")
        end
        DisplayUtil.setGray(node,true) 

    end
    
    if(Data.getUserCardById(self.curCard.cardid)==nil)then 
        plus:setVisible(false) 
        self:setTouchEnable(node,false,true) 
    
    end
end


return CardInfoEquipPanel