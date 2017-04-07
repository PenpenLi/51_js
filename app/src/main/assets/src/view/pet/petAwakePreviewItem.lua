local PetAwakePreviewItem=class("PetAwakePreviewItem",UILayer)
 
function PetAwakePreviewItem:ctor( cardid ,lv)
    self:init("ui/ui_petawake_preview_item.map")
    self.petawakeLv = lv
    -- self.curCard=card
    self.cardDb=DB.getCardById(cardid)
    self:showCardFla(cardid)
    -- self:replaceLabelString("txt_level",gParseWeaponLv(lv))

    local isLock=false
    local maxAwake = gGetMaxPetAwakeId(cardid)
    if maxAwake == nil then
        maxAwake = 0
    end
    self:getNode("txt_level"):setVisible(false)
    if(self.petawakeLv  > maxAwake)then 
        isLock=true
        self:getNode("txt_level"):setVisible(true)
    elseif(self.petawakeLv  == 1) then
        self:setLabelString("txt_level",gGetWords("petWords.plist", "lab_wakeup_after"))
    else
        self:setLabelString("txt_level",gGetWords("petWords.plist", "lab_wakeup_before"))
    end

    self:getNode("icon"):setVisible(false) 
    self:getNode("star_contain"):setVisible(false)

    if(isLock)then
        self.fla:setChildShaderName(Shader.FLA_SHADOW_BLACK_SHADER)
        self:setRTFString("txt_level",gGetWords("labelWords.plist","weapon_wait_state"))
    end

    self:resetLayOut()
    self.isLock=isLock
end

function PetAwakePreviewItem:showCardFla(cardid)
    if(self.lastFlaId==cardid)then
        return
    end
    self:parseFlaActions()
    self.lastFlaId=cardid
    local result = loadFlaXml("r"..cardid,nil,self.petawakeLv)
    self:getNode("role_container"):removeAllChildren()
    if(result)then
        local fla=FlashAni.new()
        fla:setPetSkinId(self.petawakeLv) 
        self:getNode("role_container"):addChild(fla)
        self.fla=fla
        self.fla:setScale(0.6)
    end 
    self:nextFlaAction()
end

function PetAwakePreviewItem:onTouchEnded(target)
    if  target.touchName=="btn_next_action"then
        if(self.isLock)then
            return
        end
        self:nextFlaAction()
    end
end
function PetAwakePreviewItem:parseFlaActions()
    self.flaAction={}
    self.curFlaActionIdx=0
    table.insert(self.flaAction,"wait") 
    table.insert(self.flaAction,"attack_b")

end

function PetAwakePreviewItem:nextFlaAction()

    self.curFlaActionIdx=self.curFlaActionIdx+1
    if(self.curFlaActionIdx>table.getn(self.flaAction))then
        self.curFlaActionIdx=1
    end

    self:playFlaAction( self.flaAction[self.curFlaActionIdx])
end

function PetAwakePreviewItem:playFlaAction(action)
    if(self.fla)then
        if(action==nil)then
            action="wait"
        end
        local function onCallBack()
            self.fla:playAction( "r"..self.lastFlaId..Data.getPetSkin(self.grade).."_wait" ,onCallBack)
        end
       
        self.fla:playAction("r"..self.lastFlaId..Data.getPetSkin(self.grade).."_"..action ,onCallBack)
    end
end

return PetAwakePreviewItem

 