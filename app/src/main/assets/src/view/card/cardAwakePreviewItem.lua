local CardAwakePreviewItem=class("CardAwakePreviewItem",UILayer)
 
function isUnlockIdForAwake(id)

    local maxWeapon= nil
    local maxAwake= nil
    
    maxWeapon,maxAwake= gGetMaxWeaponAwakeId(id)
    
    if(maxAwake)then
        return maxAwake>=1
    else
        return false
    end
end

 

function CardAwakePreviewItem:ctor( card ,lv,nextlv)

    self:init("ui/ui_cardawake_preview_item.map")
    self.cardawakeLv = lv;
    -- self.curCard=card
    self.cardDb=DB.getCardById(card.cardid)
    self:showCardFla(card)
    -- self:replaceLabelString("txt_level",gParseWeaponLv(lv))
    if(nextlv==nil)then
        nextlv=10000
    end
    local isLock=false

    local maxWeapon= nil
    local maxAwake= nil 
    maxWeapon,maxAwake= gGetMaxWeaponAwakeId(card.cardid) 
    
    if(Data.cardAwake.lv[maxAwake+2] and lv>=Data.cardAwake.lv[maxAwake+2])then  
           isLock=true 
    else
        self:setLabelString("txt_level","")
    end

    self:getNode("icon"):setVisible(false) 
    self:getNode("star_contain"):setVisible(false);
    if(gParseCardAwakeLv(card.awakeLv)>=gParseCardAwakeLv(lv) and gParseCardAwakeLv(card.awakeLv)<gParseCardAwakeLv(nextlv))then
        self:setRTFString("txt_level",gGetWords("labelWords.plist","weapon_cur_state"))
        self:getNode("icon"):setVisible(true)
    elseif(gParseCardAwakeLv(card.awakeLv)<gParseCardAwakeLv(lv) and isLock == false) then
        CardPro:showNewStar(self:getNode("star_contain"),5,lv);
        self:getNode("star_contain"):setVisible(true);
        self:setRTFString("txt_level",gGetWords("labelWords.plist","274"))
    end

    if(isLock)then
        self.fla:setChildShaderName(Shader.FLA_SHADOW_BLACK_SHADER)
        self:setRTFString("txt_level",gGetWords("labelWords.plist","weapon_wait_state"))
    end

    self:resetLayOut();
    self.isLock=isLock
end

function CardAwakePreviewItem:showCardFla(card,action)
    local cardid=card.cardid
    if(self.lastFlaId==cardid)then
        return
    end
    self:parseFlaActions()
    self.lastFlaId=cardid
    self.fla=gCreateRoleFla(cardid, self:getNode("role_container") ,0.6,true,nil,card.weaponLv,self.cardawakeLv)

    self:nextFlaAction()
end

function CardAwakePreviewItem:onTouchEnded(target)
    if  target.touchName=="btn_next_action"then
        if(self.isLock)then
            return
        end
        self:nextFlaAction()
    end
end
function CardAwakePreviewItem:parseFlaActions()
    self.flaAction={}
    self.curFlaActionIdx=0
    local actions=string.split(self.cardDb.actlist,",")
    for key, actionid in pairs(actions) do

        if(actionid=="0")then
            table.insert(self.flaAction,"wait")
        elseif(actionid=="1")then
            table.insert(self.flaAction,"run")
        elseif(actionid=="2")then
            table.insert(self.flaAction,"win")
        elseif(actionid=="3")then
            table.insert(self.flaAction,"attack_s")
        elseif(actionid=="4")then
            table.insert(self.flaAction,"attack_b")
        end
    end

end

function CardAwakePreviewItem:nextFlaAction()

    self.curFlaActionIdx=self.curFlaActionIdx+1
    if(self.curFlaActionIdx>table.getn(self.flaAction))then
        self.curFlaActionIdx=1
    end

    self:playFlaAction( self.flaAction[self.curFlaActionIdx])
end

function CardAwakePreviewItem:playFlaAction(action)
    if(self.fla)then
        if(action==nil)then
            action="wait"
        end
        local function onCallBack()
            if(action=="run")then
                self.fla:playAction( "r"..self.lastFlaId.."_run" ,onCallBack)
            else
                self.fla:playAction( "r"..self.lastFlaId.."_wait" ,onCallBack)
            end
        end
       
        self.fla:playAction("r"..self.lastFlaId.."_"..action ,onCallBack)
    end
end

return CardAwakePreviewItem

 