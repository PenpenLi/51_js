local CardSkillLevelUpPanel=class("CardSkillLevelUpPanel",UILayer)

function CardSkillLevelUpPanel:ctor(oldCard,newCard)
    self.isWindow = true
    self.appearType = 1


    self:init("ui/ui_card_skill_levelup.map") 
    self:addFullScreenTouchToClose();

    local count =0; 
    local cardDb=DB.getCardById(newCard.cardid) 
    --显示有升级的item
    for i=0,table.count(newCard.skillLvs)-1 do
        local difflv = newCard.skillLvs[i] - oldCard.skillLvs[i]
        if difflv>0 then
            local  index = count+1
            local skillData = nil
            if i<=1 then
                skillData=  DB.getSkillById(cardDb["skillid"..i])
                Icon.setIcon(skillData.skillid,self:getNode("icon"..index))
            else
                skillData=  DB.getBuffById(cardDb["buffid"..(i-2)]) 
                Icon.setSkillIcon(skillData.icon,self:getNode("icon"..index))
            end
            self:setLabelString("txt_lv"..index,"lv."..oldCard.skillLvs[i])
            self:setLabelString("txt_lvup"..index,"lv."..newCard.skillLvs[i])
            self:getNode("arrow"..index):setVisible(true)
            self:setLabelString("txt_name"..index,skillData.name)

            if(cardDb and cardDb.skillid2>0 and  i==0 )then
                self:getNode("icon_cooperate"..index):setVisible(true)
            else
                self:getNode("icon_cooperate"..index):setVisible(false)
            end
            count = count +1;
        end
    end

    --隐藏没有升级的item
    for i=0,table.count(newCard.skillLvs)-1 do
        local difflv = newCard.skillLvs[i] - oldCard.skillLvs[i]
        if difflv==0 then
            local  index = count+1
            local skillData = nil
            if i<=1 then
                skillData=  DB.getSkillById(cardDb["skillid"..i])
                Icon.setIcon(skillData.skillid,self:getNode("icon"..index))
            else
                skillData=  DB.getBuffById(cardDb["buffid"..(i-2)]) 
                Icon.setSkillIcon(skillData.icon,self:getNode("icon"..index))
            end
            self:setLabelString("txt_lv"..index,"lv."..oldCard.skillLvs[i])
            self:setLabelString("txt_name"..index,skillData.name)
            self:getNode("arrow"..index):setVisible(false)
            self:getNode("txt_lvup"..index):setVisible(false)
            self:getNode("skill_item"..index):setOpacity(255/2)
            DisplayUtil.setGray(self:getNode("txt_lv"..index),true)
            DisplayUtil.setGray(self:getNode("icon"..index),true)
            self:getNode("icon_cooperate"..index):setVisible(false)
           
            count = count +1;
        end
    end

    local fla = gCreateFla("ui_jingyan_jiantou");
    gAddChildByAnchorPos(self:getNode("power_arrow"),fla,cc.p(0.5,0.5));
    local oldPower=CardPro.countPower(oldCard)
    local newPower=CardPro.countPower(newCard)
    self:setLabelAtlas("txt_power1",oldPower)
    self:setLabelAtlas("txt_power2",oldPower)
    self:resetLayOut()
    local curValue = oldPower
    local step = math.ceil( (newPower - oldPower)/5 );
    function updatePower()
        if( curValue>=newPower)then
            self:unscheduleUpdate()
            curValue = newPower;
        else
            curValue = curValue+step;
        end
        self:setLabelAtlas("txt_power2",curValue)
        if curValue>=newPower then
            self:resetLayOut()
        end
    end
    self:scheduleUpdateWithPriorityLua(updatePower,1)
end

function CardSkillLevelUpPanel:onEnter()


end

function CardSkillLevelUpPanel:onExit()
    -- print("CardInfoSkillPanel:onUILayerExit");
    -- self:unscheduleUpdateEx();
end

function CardSkillLevelUpPanel:onTouchEnded(target)
    if(target.touchName=="full_close")then
        Panel.popBack(self:getTag())
        --AttChange.pushPower(PANEL_CARD_INFO, oldPower,newPower)
        gDispatchEvt(EVENT_ID_SKILL_UPGRADE)
    end
end

return CardSkillLevelUpPanel
