local CardSkillItem=class("CardSkillItem",UILayer)

function CardSkillItem:ctor(pos)
    self:init("ui/ui_card_skill_item.map")
    self.pos=pos
    self:getNode("icon").__touchend=true
    self:setTouchCDTime("btn_upgrade",0);
end

function CardSkillItem:onTouchBegan(target)
    if(target.touchName=="icon")then
        local tip=nil
        local db=DB.getCardById(self.curCard.cardid)
        if(db and db.skillid2>0 and  self.pos==0 )then
            local skill1={data=self.curData,lv=self.curLv}
            local skill2=db.skillid2 
            tip= Panel.popTouchTip(self,TIP_TOUCH_COOPERATE_SKILL,skill1,skill2,cc.p(0,0.5),cc.p(1.0,-0.5))
        else
            tip= Panel.popTouchTip(self,TIP_TOUCH_SKILL,self.curData,self.curLv,cc.p(0,0.5),cc.p(1.0,-0.5))
           
        end
        
        if(CardPro.isSkillUnlock( self.curCard, self.pos))then  
            local canUpgrade,level=CardPro.canSkillUpgrade(self.curCard,self.pos)
            -- local txt= gGetWords("labelWords.plist","skill_level_limit",level)
            -- tip:setLabelString("txt_limit",txt)
            tip:replaceLabelString("txt_limit",level);
            if(canUpgrade)then
                tip:getNode("txt_limit"):setColor(cc.c3b(0,255,0))
            else
                tip:getNode("txt_limit"):setColor(cc.c3b(255,0,0))
            end
        else
            tip:getNode("txt_limit"):setColor(cc.c3b(255,0,0))
            tip:setLabelString("txt_limit",self:getUnlockTxt())
        end
        -- if(tip)then
        --     tip:setPositionX(tip:getPositionX()-tip:getContentSize().width)
        -- end
    end
end

function CardSkillItem:onTouchEnded(target)
    if(target.touchName=="btn_upgrade")then
        Net.sendSkillUpgrade(self.curCard.cardid,self.pos)
    elseif(target.touchName=="icon")then
        Panel.clearTouchTip()
    end
end

function CardSkillItem:getUnlockTxt()

    local quality=CardPro.getSkillUnlockQuality(self.curCard, self.pos)
    local qualityTxt=gGetWords("cardAttrWords.plist","quality"..quality)
    local txt= gGetWords("labelWords.plist","lab_skill_unlock",qualityTxt)
    return txt
end
function CardSkillItem:setBase(data,lv)
    self.curLv=lv
    local price,point,consType=  DB.getSkillPriceByLevel(lv,self.pos)
    self:setLabelString("txt_name",data.name)
    self:setLabelString("txt_lv",getLvReviewName("Lv.")..lv)
    self:setLabelString("txt_gold",price)
    self:setLabelString("txt_point",point)
    
    Icon.changeSeqItemIcon(self:getNode("icon_const"),consType) 


    if(CardPro.isSkillUnlock( self.curCard, self.pos))then
        self:getNode("normal_panel"):setVisible(true)
        self:getNode("lock_panel"):setVisible(false)
        DisplayUtil.setGray(self:getNode("icon"),false)
        DisplayUtil.setGray(self:getNode("bg_name"),false)
        

        if(CardPro.canSkillUpgrade(self.curCard,self.pos))then
            self:setTouchEnable("btn_upgrade",true,false)
        else
            self:setTouchEnable("btn_upgrade",false,true)
        end
        
    else 
        local txt=self:getUnlockTxt()
        self:setLabelString("txt_unlock",txt)
        self:getNode("normal_panel"):setVisible(false)
        self:getNode("lock_panel"):setVisible(true)
        DisplayUtil.setGray(self:getNode("icon"),true)
        DisplayUtil.setGray(self:getNode("bg_name"),true)

    end

    if(Data.getUserCardById(self.curCard.cardid)==nil or Unlock.isUnlock(SYS_SKILL,false) == false)then 
        self:getNode("btn_upgrade"):setVisible(false) 
    else
        self:getNode("btn_upgrade"):setVisible(true) 
    end

    self:resetLayOut();
end

function  CardSkillItem:setBuff(buffDb,lv,card)
    self:getNode("icon_cooperate"):setVisible(false)
    if(buffDb==nil)then
        return
    end
    self.curCard=card
    self.curData=buffDb
    Icon.setSkillIcon(buffDb.icon,self:getNode("icon"))
    self:setBase(buffDb,lv)
end

function  CardSkillItem:setSkill(skillDb,lv,card)
    self:getNode("icon_cooperate"):setVisible(false)
    if(skillDb==nil)then
        return
    end
    self.curCard=card
    self.curData=skillDb
    Icon.setIcon(skillDb.skillid,self:getNode("icon"))
    self:setBase(skillDb,lv)

    local db=DB.getCardById(self.curCard.cardid)
    if(db and db.skillid2>0 and  self.pos==0 )then
        self:getNode("icon_cooperate"):setVisible(true)
    end
end


return CardSkillItem