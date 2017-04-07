local CardInfoSkillPanel=class("CardInfoSkillPanel",UILayer)

function CardInfoSkillPanel:ctor()
    self:init("ui/ui_card_skill.map") 
    
    self.skillItems={}
    
    local skillSort={1,0,2,3,4,5,6}
    
    for key, var in pairs(skillSort) do 
        local item=CardSkillItem.new(var) 
        self:getNode("scroll"):addItem(item)   
        table.insert(self.skillItems,item)
    end
    
  
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self:getNode("scroll").offsetY=4
    self:getNode("scroll"):layout()

    self.panel_full_point = self:getNode("panel_full_point");
    self.panel_no_full_point = self:getNode("panel_no_full_point");
    self.panel_empty_point = self:getNode("panel_empty_point");
    self:getNode("btn_quick_skill"):setVisible(false)


    local function onNodeEvent(event)
        if event == "exit" then
            self:onExit();
        elseif event == "enter" then
            self:onEnter();    
        end
    end
    self:registerScriptHandler(onNodeEvent);
    Unlock.checkFirstEnter(SYS_SKILL);
end

function CardInfoSkillPanel:onEnter()
    if(Unlock.isUnlock(SYS_SKILL,false))then
        local function updateSkillPoint()
            -- print("updateSkillPoint");
            self:update();
        end
        self:scheduleUpdate(updateSkillPoint,1)
    else
        self.panel_full_point:setVisible(false)
        self.panel_no_full_point:setVisible(false)
        self.panel_empty_point:setVisible(false) 
    end

end

function CardInfoSkillPanel:onExit()
    print("CardInfoSkillPanel:onUILayerExit");
    self:unscheduleUpdateEx();
end

function CardInfoSkillPanel:update()
    if(self.panel_full_point)then
        self.panel_full_point:setVisible(false)
    end
    self.panel_no_full_point:setVisible(false)
    self.panel_empty_point:setVisible(false) 
    if(gUserInfo.skillPoint==0)then 
        local time=DB.getSkillPointTime()-(gGetCurServerTime()-Data.skillPointTime)
        self.panel_empty_point:setVisible(true)
        self:setRTFString("txt_empty",gGetWords("labelWords.plist","lab_recover_skill_pos",gParserMinTime(time)));
        -- self:setLabelString("txt_empty",gGetWords("labelWords.plist","lab_recover_skill_pos",gParserMinTime(time)))

    elseif(gUserInfo.skillPoint>=Data.vip.skillpot.maxSkillPoint())then
        self.panel_full_point:setVisible(true) 
        self:setRTFString("txt_full",gGetWords("labelWords.plist","lab_full_skill_pos",gUserInfo.skillPoint))
        
        
    else  
        self.panel_no_full_point:setVisible(true)
        local txt=gGetWords("labelWords.plist","lab_cur_skill_pos",gUserInfo.skillPoint)
        self:setRTFString("txt_info",txt)

    end

    self:updateQuickSkillStatus();
end
 

function CardInfoSkillPanel:updateQuickSkillStatus()
    if self.curCard == nil or (Unlock.isUnlock(SYS_SKILL,false)) ==false then
        self:getNode("btn_quick_skill"):setVisible(false)
        return
    end

    local showQuickSkill = false
    local showQuickLv = DB.getClientParam("CARD_SKILL_QUICK_UPGRADE_LV",true);
    for i=0,table.count(self.curCard.skillLvs)-1 do
        local gold,point= DB.getSkillPriceByLevel(self.curCard.skillLvs[i],i)
        if( CardPro.isSkillUnlock(self.curCard,i) 
            and CardPro.canSkillUpgrade(self.curCard,i) 
            and gUserInfo.gold>=gold 
            and gUserInfo.skillPoint>=point
            and  gUserInfo.level>=showQuickLv) then
            showQuickSkill =  true
            break
        end
    end      --todo
    if showQuickSkill then
        self:getNode("btn_quick_skill"):setVisible(true)
    else
        self:getNode("btn_quick_skill"):setVisible(false)
    end
end

function CardInfoSkillPanel:onTouchEnded(target)
    if(target.touchName=="btn_buy")then
        Panel.popUp(PANEL_GLOBAL_BUY,VIP_SKILLPOT);
        -- local callback = function()
        --     Net.sendBuySkillPoint();
        -- end
        -- Data.canBuyTimes(VIP_SKILLPOT,true,callback);
    elseif target.touchName=="btn_quick_skill" then
        Net.sendSkillQuickUpgrade(self.curCard.cardid)
    end
    
  
end



function CardInfoSkillPanel:setCard(card)
    self.curCard=card
    local cardDb=DB.getCardById(self.curCard.cardid) 
     
    for key, skillItem in pairs(self.skillItems) do
        skillItem.curCard=card
        if(skillItem.pos<=1)then
            local data=  DB.getSkillById(cardDb["skillid"..skillItem.pos]) 
            skillItem:setSkill(data,self.curCard.skillLvs[skillItem.pos] ,self.curCard)
    	else
            local data=  DB.getBuffById(cardDb["buffid"..(skillItem.pos-2)]) 
            skillItem:setBuff(data,self.curCard.skillLvs[skillItem.pos] ,self.curCard) 
    	end
    	 
    end
    self:update();
    if(not Guide.isGuiding())then
        self:getNode("scroll"):setTouchEnable(true);
    end
     
end




return CardInfoSkillPanel