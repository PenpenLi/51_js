local TipTouchCooperateSkill=class("TipTouchCooperateSkill",UILayer)

function TipTouchCooperateSkill:ctor(data,skill2)
    self:init("ui/tip_touch_skill_cooperate.map")
    local level=data.lv
    local data=data.data
    self:setLabelString("txt_name",data.name) 
    
    if(data.skillid)then
        self:setLabelString("txt_info",gGetSkillDesc(data,level))   
    else
        self:setLabelString("txt_info",gGetBuffDesc(data,level))   
    end
    
    local skillDb=DB.getSkillById(skill2)
    if(skillDb==nil)then
        return 
    end
    self:setLabelString("txt_name2",skillDb.name)  
    self:setLabelString("txt_info2",gGetSkillDesc(skillDb,level))   
    
    local cardNames=""
    if( skillDb.cooperate_card~="")then
        local cards=  string.split(skillDb.cooperate_card,",")
        for key, cardid in pairs(cards) do
        	 local card= DB.getCardById(toint(cardid))
             cardNames=cardNames..""..card.name 
        end
    end
    
    
    self:setRTFString("txt_cooperate",gGetWords("labelWords.plist","cooperate_with",cardNames))  

    self:resetLayOut()
    local size=self:getNode("layout"):getContentSize()
    size.width= self:getNode("tip_bg"):getContentSize().width
    size.height=size.height+30
    self:getNode("tip_bg"):setContentSize(size)
    self:setContentSize(size);
end


 
return TipTouchCooperateSkill