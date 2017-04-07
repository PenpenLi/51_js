BattleRole=class("BattleRole", function()
    return cc.Node:create()
end)


ACTION_TAG_MOVE_X=1
ACTION_TAG_MOVE_Y=2
ACTION_TAG_MOVE_FUNC=3

ACTION_TAG_DIE=7
ACTION_TAG_DIE_SKIP=8


local GREEN_COLOR="green_num"
local RED_COLOR="red_num"

function  BattleRole:getWaitActionName()
    return  self.curXmlName.."_wait"
end


function  BattleRole:getAngerActionName()
    return  self.curXmlName.."_nu"
end

function  BattleRole:getBigAttackActionName2()

    return  self.curAttackXmlName.."_attack_b"
end

function  BattleRole:getBigAttackActionName()

    return  self.curXmlName.."_attack_b"
end

function  BattleRole:getCooperateAttackActionName()

    return  self.curAttackXmlName.."_1_attack_b"
end

function  BattleRole:getExtraAttackActionName()
    return  self.curXmlName.."_attack_extra"
end

function  BattleRole:getSmallAttackActionName2()

    if(self:isPet())then
        return  self.curAttackXmlName.."_attack_b"

    else
        return  self.curAttackXmlName.."_attack_s"
    end
end


function  BattleRole:getSmallAttackActionName()

    if(self:isPet())then
        return  self.curXmlName.."_attack_b"

    else
        return  self.curXmlName.."_attack_s"
    end
end
function  BattleRole:getRunActionName()
    if(self:isPet())then
        return  self.curXmlName.."_wait"
    else
        return  self.curXmlName.."_run"
    end
end

function BattleRole:getHurtStateActionName()
    return self.curXmlName.."_hurt"
end


function BattleRole:getHurtWaitStateActionName()
    return self.curXmlName.."_hurt_state"
end


function BattleRole:getDieActionName()
    if(self:isBoss())then
        return self.curXmlName.."_dead"
    else
        return "battle_die"
    end
end

function BattleRole:getReliveAfterDeadActionName()
    return self.curXmlName.."_relive"
end

function  BattleRole:getWinActionName()
    if(self.curPos==PET_POS)then
        return  self.curXmlName.."_wait"
    else
        return  self.curXmlName.."_win"
    end
end


function  BattleRole:getSmallHurtActionName()
    if(self:isBoss())then
        return self.curXmlName.."_hited_all"
    end
    return  self.curXmlName.."_hited_s"
end

function  BattleRole:getUpHurtActionName()
    if(self:isBoss())then
        return self.curXmlName.."_hited_all"
    end
    return  self.curXmlName.."_hited_u"
end

function  BattleRole:getHitToUpActionName()
    if(self:isBoss())then
        return self.curXmlName.."_hited_all"
    end
    return  self.curXmlName.."_hited_tu"
end

function BattleRole:getHitDownActionName()
    if(self:isBoss())then
        return self.curXmlName.."_hited_all"
    end
    return  self.curXmlName.."_hited_d"
end

function  BattleRole:getHitUpDownActionName()
    if(self:isBoss())then
        return self.curXmlName.."_hited_all"
    end
    return  self.curXmlName.."_hited_ud"
end

function  BattleRole:getHitUpScrollActionName()
    if(self:isBoss())then
        return self.curXmlName.."_hited_all"
    end
    return  self.curXmlName.."_hited_ur"
end

function  BattleRole:getUpStandUpActionName()
    if(self:isBoss())then
        return self.curXmlName.."_wait"
    end
    return  self.curXmlName.."_standup_u"
end


function  BattleRole:getDownStandUpActionName()
    if(self:isBoss())then
        return self.curXmlName.."_wait"
    end
    return  self.curXmlName.."_standup_d"
end

function BattleRole:initRepaceActionQueue()
    self.actionReplaceQueue={}
    self.actionReplaceQueue[self:getWaitActionName()]={self:getDieActionName()}


end


--越小优先级越高
function BattleRole:initActionQueue()
    self.actionQueue={}
    self.actionQueue[self:getDieActionName()]=2
    self.actionQueue[self:getCooperateAttackActionName()]=2
    self.actionQueue[self:getBigAttackActionName()]=2
    self.actionQueue[self:getSmallAttackActionName()]=2
    self.actionQueue[self:getExtraAttackActionName()]=2

    self.actionQueue[self:getReliveAfterDeadActionName()]=4
    self.actionQueue[self:getUpStandUpActionName()]=5
    self.actionQueue[self:getDownStandUpActionName()]=6
    self.actionQueue[self:getHitUpDownActionName()]=7
    self.actionQueue[self:getHitDownActionName()]=8


    --空中被击中顺序
    self.actionQueue[self:getHitUpScrollActionName()]=9
    self.actionQueue[self:getUpHurtActionName()]=10
    self.actionQueue[self:getHitToUpActionName()]=11

    self:initRepaceActionQueue()
end

function BattleRole:getActionQueueIndex(action)
    if( self.actionQueue[ action ])then
        return self.actionQueue[ action ]
    else
        return 1000
    end
end

function BattleRole:canReplaceAction(action)
    if(self:isBoss())then
        return true ,1000
    end
    local key1= self:getActionQueueIndex(action)
    if(self.actionReplaceQueue[action])then
        for key, var in pairs(self.actionReplaceQueue[action]) do
            if(var==self.curAction)then
                return true,key1
            end
        end
    end



    local key2= self:getActionQueueIndex(self.curAction)
    return key1<=key2,key1
end


function BattleRole:isPet()
    if(self.curPos==PET_POS)then
        return true
    else
        return false
    end
end

function BattleRole:roleScale()
    local scaleAdd=1
    if(self.scaleAdd~=nil)then
        scaleAdd=self.scaleAdd
    end
    local scale=1
    if(self.curRoleScale~=nil)then
        scale=self.curRoleScale
    end
    if(self:isPet())then
        return PET_SCALE*scale*scaleAdd
    else
        return ROLE_SCALE*scale*scaleAdd
    end
end

function  BattleRole:isBoss()
    if(self.curCardid==11000)then
        return true
    elseif(self.curCardid==12007)then
        return true
    else
        return false
    end
end

function BattleRole:playWin()
    self:playAction(self:getWinActionName())
end


function BattleRole:playNotice(name,delay,scale)
    loadFlaXml("ui_guide")
    if(delay==nil)then
        delay=0
    end
    if(scale==nil)then
        scale=0.8
    end
    local buffEffect=gCreateFlaDelay(delay,name,0,true)
    self.effectNode:setScaleX(self:getScaleX())
    self.effectNode:setScaleY(self:getScaleY())
    buffEffect:setScale(scale)
    buffEffect:setPositionY(10)
    if(self.curSide==1)then
        buffEffect:setPositionX(-10)
    else
        buffEffect:setPositionX(-60)
    end
    self.effectNode:addChild(buffEffect )
    return buffEffect
end

function BattleRole:playRelive(attackData)
    self:addBufferEffect("relive")


    self:playAction(self:getWaitActionName())
    self.display:runAction(cc.FadeIn:create(1.2))
end

function BattleRole:playDie(tag)
    self:clearEffect()
    self:playAction(self:getDieActionName())


    local function callback()
        self:playAction(self:getWaitActionName())
        self:setVisible(false)
    end
    if(tag==nil)then
        tag=ACTION_TAG_DIE
    end
    local dieCallback= cc.Sequence:create(cc.DelayTime:create(gGetActionTime(self:getDieActionName())-0.3),cc.CallFunc:create(callback))
    self:runActionByTag( dieCallback,tag)


end


function BattleRole:escape()
    if(self.curSide==1)then
        self:setScale(-1)
        self:moveActionByTag(1.0,cc.p(self.initX-700,self.initY),nil,4)
    else
        self:setScale(1)
        self:moveActionByTag(1.0,cc.p(self.initX+700,self.initY),nil,4)
    end
    self.bloodNode:setVisible(false)
    self:playAction(self:getRunActionName())
end

function BattleRole:resetScapeRound(num)
    if(self.escapeNode==nil)then
        return
    end
    self.escapeNode:removeAllChildren()
    local lab= gCreateLabelAtlas("images/ui_num/lv_num.png",36,48,num,-4,0);
    local size=self.escapeNode:getContentSize()
    lab:setPositionX(size.width/2)
    lab:setPositionY(size.height/2-4)
    self.escapeNode:addChild(lab)
    lab:setScale(0)
    lab:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.2,0.7)))
end


function BattleRole:setScapeRound(num)
    local sprite=cc.Sprite:create("images/ui_shilian/clock.png")
    sprite:setPositionY(110)
    sprite:setPositionX(-30)
    sprite:setScaleX(-1)
    self:addChild(sprite,100)
    self.escapeNode=sprite
    self:resetScapeRound(num)
end


function BattleRole:ctor(xmlPath,battleLayer,side,pos,cardid,weaponLv,awakeLv,cards)
    self.curSide=side
    self.curPos=pos
    self.curWeaponLv=weaponLv
    self.curAwakeLv=awakeLv
    self.curCardid=cardid
    self.relivePoint=0
    self.curXmlName=xmlPath
    self.curAttackXmlName=xmlPath
    self.curRoleDatas=cards
    self:initActionQueue()
    self.battleLayer=battleLayer
    self.initZAdd=0
    self.touchNode=cc.Node:create()
    if(self:isBoss())then
        self.touchNode:setContentSize(cc.size(300,450))
    else
        self.touchNode:setContentSize(cc.size(100,150))
    end
    self.touchNode:setVisible(false)
    self.touchNode:setAnchorPoint(cc.p(0.5,0.5))
    self.touchNode:setPositionY(self.touchNode:getContentSize().height/2-40)

    self:addChild(self.touchNode)
    self.bloodNode=BattleRoleBlood.new()
    self.bloodNode.curSide=side
    self.bloodNode.battleLayer=battleLayer
    self.bloodNode:setScale(self:roleScale())
    if(self:isBoss())then
        self.bloodNode:setVisible(false)
    end
    self:addChild(self.bloodNode,-1)

    local card=DB.getCardById(cardid)
    self.cardDb=card

    self.skillNode=cc.Node:create()
    self:addChild(self.skillNode,500)

    self.effectNode=cc.Node:create()
    self:addChild(self.effectNode ,2)


    self.effectBottomNode=cc.Node:create()
    self:addChild(self.effectBottomNode ,-2)
    
    
    self.effectRetainNode=cc.Node:create()
    self:addChild(self.effectRetainNode ,-1)
    


    self.shadow=cc.Sprite:create("images/battle/shade.png")
    self.shadow:setScaleY(0.5)
    self:addChild(self.shadow,-1)

end

function  BattleRole:initData(data)
    self.isDead=false
    self.appearType=data.appearType
    self.bloodNode:setMaxBlue(data.maxRage)
    self.bloodNode:setMaxRed(data.hpInit)
    self.bloodNode:setCurBlue(data.rage,false,0)
    self.bloodNode:setCurRed(data.hp,false,data.hpInit)
    self.bloodNode.container:setScaleX(self:getScaleX())
    self.hpInit=data.hpInit
    self.finalHp=data.hp
    if(data.hp<=0 and self:isPet()~=true)then
        self.isDead=true
        self:setVisible(false)
        self.bloodNode:setVisible(false)

    end

end


function BattleRole:addDieNum(tag)
    if(self.curSide==2)then
        if( Battle.battleType==BATTLE_TYPE_ATLAS_PET or
            Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL )then
            local function  callfunc()
                if(tag==nil)then
                    gBattleLayer.layer.totalDieNumDelay=gBattleLayer.layer.totalDieNumDelay+1
                end
            end
            self:dropPetItem( callfunc)
        end

        if(tag==nil)then
            self.battleLayer.totalDieNum=self.battleLayer.totalDieNum+1
        end
    end
end


function BattleRole:showDie(attackData,tag)

    if( self.reliveAttackData==attackData and attackData~=nil)then
        return
    end
    if(self.isDead==false)then
        return
    end
    self:addDieNum(tag)

    if(self.escapeNode)then
        self.escapeNode:setVisible(false)
    end
    self:playDie(tag)
    self.bloodNode:setVisible(false)
    self.shadow:setVisible(false)
    if(self.onDieCallback)then
        self.onDieCallback()
    end
    self:clearEffect()

end


function BattleRole:showRelive(attackData)
    self.reliveAttackData=attackData
    self.isDead=false
    self.bloodNode:setVisible(true)
    self.shadow:setVisible(true)
    self:setVisible(true)
    self:moveActionByTag(0.2,cc.p(self.initX,self.initY),nil,2)
    self:stopActionByTag( ACTION_TAG_DIE)
    self:playRelive(attackData)
    if(self.curSide==2)then
        self.battleLayer.totalReliveNum=self.battleLayer.totalReliveNum+1
    end
end


function BattleRole:dropPetItem(callfunc)

    local node=nil
    if( Battle.battleType==BATTLE_TYPE_ATLAS_PET  )then
        node= gCreateFla( "battle-lingshoui-penicon-"..getRand(1,3))
    elseif( Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL )then
        node=  gCreateFla( "battle_pingzii_icon_"..getRand(1,3))
    end
    self.battleLayer:addChild(node)
    local initX=self:getPositionX()+getRand(-70,70)
    local initY=self:getPositionY()+getRand(-40,40)
    node:setPosition(self.initX,self.initY)
    node:setLocalZOrder( self.initZ)

    local worldPos= battleLayer:getNode("reward_icon"):convertToWorldSpace(cc.p(0,0))
    worldPos.x=worldPos.x+40
    worldPos.y=worldPos.y+40
    local pos=self.battleLayer:convertToNodeSpace(worldPos)

    local delay=cc.DelayTime:create(60/FLASH_FRAME)
    local moveUp=cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(15/FLASH_FRAME,pos),2.0),cc.FadeOut:create(15/FLASH_FRAME))
    local movedFuc=cc.CallFunc:create(callfunc)
    node:runAction(cc.Sequence:create(delay,moveUp,movedFuc))
end

function BattleRole:dropItem(num)
    for i=1, num do
        local node=cc.Sprite:create("images/ui_fight/box1.png")
        self:getParent():addChild(node)
        local initX=self:getPositionX()+getRand(-170,170)
        local initY=self:getPositionY()+getRand(-80,80)
        node:setPosition(self.initX,self.initY)
        node:setLocalZOrder( self.initZ)
        local function onMoved()
            node:removeFromParent()
            battleLayer:addDropBox()
        end

        local worldPos= battleLayer:getNode("icon_box"):convertToWorldSpace(cc.p(0,0))
        local pos=self:getParent():convertToNodeSpace(worldPos)
        local size= battleLayer:getNode("icon_box"):getContentSize()
        pos.x=pos.x+size.width/2
        pos.y=pos.y+size.height/2
        local moveDown=cc.MoveTo:create(0.2,cc.p(initX,initY))
        local delay=cc.DelayTime:create(1.0)
        local moveUp=cc.MoveTo:create(0.2,pos)
        local movedFuc=cc.CallFunc:create(onMoved)

        node:runAction(cc.Sequence:create(moveDown,delay,moveUp,movedFuc))
    end

end


function BattleRole:setWeaponAwake()
    local maxWeapon= nil
    local maxAwake= nil 
    maxWeapon,maxAwake= gGetMaxWeaponAwakeId(self.curCardid)
    if maxAwake == nil then
        maxAwake = gGetMaxPetAwakeId(self.curCardid)
    end

    self.display:setWeaponId(self.curWeaponLv,maxWeapon)
    if gGetMaxPetAwakeId(self.curCardid) ~= nil then
        self.display:setPetSkinId(self.curAwakeLv)
    else
        self.display:setSkinId(self.curAwakeLv,maxAwake)
    end
        
end

function BattleRole:initDisplay()
    if (self.display ==nil) then
        self.display =FlashAni.new()
        self.display.param=self
        self.display:setScale(self:roleScale())
        self:addChild(self.display)

        local function inCard(cardstr)
            for temp, var in pairs(self.curRoleDatas) do
                if(string.find(cardstr,var.cardid))then
                    return var
                end
            end
            return nil
        end
        

        self:setWeaponAwake()
        
        self.cooperateWeaponLv=0
        self.cooperateAwakeLv=0
        self.cooperateCardid=0

        local hasCooperate=false
        local cardDb=DB.getCardById(self.curCardid)
        if(cardDb)then
            local skillDb=DB.getSkillById(cardDb.skillid2)
            if(skillDb and  skillDb.cooperate_card and  skillDb.cooperate_card~="" )then
                local cooperateRoleData= inCard(skillDb.cooperate_card)
                if(cooperateRoleData)then

                    local maxWeapon2= nil
                    local maxAwake2= nil 
                    maxWeapon2,maxAwake2= gGetMaxWeaponAwakeId(cooperateRoleData.cardid) 
                    
                    self.display:setChildWeaponId("role2",cooperateRoleData.weaponLv,maxWeapon2)
                    self.display:setChildSkinId("role2",cooperateRoleData.awakeLv,maxAwake2)

                    self.cooperateWeaponLv=cooperateRoleData.weaponLv
                    self.cooperateCardid=cooperateRoleData.cardid
                    self.cooperateAwakeLv=cooperateRoleData.awakeLv

                    self.display:setChildWeaponId("role1",self.curWeaponLv,maxWeapon)
                    self.display:setChildSkinId("role1",self.curAwakeLv,maxAwake)
                end
            end
        end

    end

end



local function onActionPlayEndEvent(self,arm, eventType, movmentID)


    if self.curActions~=nil and eventType == ccs. MovementEventType.loopComplete then
        if self.curActionIdx<table.getn(self.curActions) then
            self.curActionIdx= self.curActionIdx+1
            self:playAction(self.curActions[self.curActionIdx])
        end
    end


    if(self.curActionCallBack~=nil)then
        self.curActionCallBack()
    end
end

function BattleRole:createBufferEffect(name,loop,type,parent)
    if(loop==1 and parent:getChildByTag(type)~=nil)then
        return
    end
    local buffEffect=gCreateFla(name,loop)
    if(loop==1)then
        buffEffect:setTag(type)
    end

    if(self:isBoss())then
        buffEffect:setScale(self:roleScale()*BOSS_SCALE)
    else
        buffEffect:setScale(self:roleScale())
    end
    parent:addChild(buffEffect)
    return buffEffect
end

function BattleRole:resetScale()

    if( self.display)then
        self.display:setScale(self:roleScale())
    end
end

function  BattleRole:addBufferEffect(type)
    if(self.isDead)then
        return
    end
    if(type==RESPONSE_TYPE_SPIRIT_CHAIN)then
        self:createBufferEffect( "s061_c_buff",1, type, self.bloodNode.buffContainer)
    elseif(type==RESPONSE_TYPE_STUN)then
        self:createBufferEffect( "other-yunxuan-a",1, type, self.effectNode)
    elseif (type==EFFECT_ATTACK_WATING)then
        self:createBufferEffect( "skillwaiting-top",1, type, self.effectNode)
        --self:createBufferEffect( "skillwaiting-di",1, type, self.effectBottomNode)

    elseif (type==EFFECT_RELIVE_POINT)then
        if(self.relivePoint<=3)then
            self:createBufferEffect( "s009_buff_"..self.relivePoint,1, EFFECT_RELIVE_POINT*10+self.relivePoint, self.effectNode)
        end
    elseif (type==EFFECT_TOUCH_MODE)then
        self:createBufferEffect( "ui_coop_togather_cover",1, type, self.effectNode)
        self:createBufferEffect( "ui_coop_togather_di3",1, type, self.effectBottomNode)

    elseif (type==EFFECT_ATTACK_HOT)then
        self.scaleAdd=2
        self:resetScale()
        self:createBufferEffect( "battle_cooperate_buff",1, type, self.effectNode)
    elseif(type==WORDS_SHOW_HUIXUE)then
        self:createBufferEffect( "s009_a",nil, type, self.effectNode)

    elseif (type=="relive")then
        self:createBufferEffect( "battle_fuhuo",nil, type, self.effectNode)

    elseif (type==RESPONSE_TYPE_REDUCE_HP)then --燃烧
        self:createBufferEffect( "buff_ranshao",1, type, self.effectNode)
    elseif (type==EFFECT_IMMNUE_PHYSICAL_ATTACK)then
        self:createBufferEffect( "buff_fanghuzhao_c",1, type, self.effectNode)
    elseif (type==EFFECT_IMMNUE_MAGIC_ATTACK)then
        self:createBufferEffect( "buff_fanghuzhao_b",1, type, self.effectNode)
    elseif (type==EFFECT_REDUCE_HURT)then
        self:createBufferEffect( "buff_dunpai",1, type, self.effectNode)
    elseif(type==RESPONSE_TYPE_LOCK)then
        self:createBufferEffect( "buff_fengyin",1, type, self.effectNode)
    elseif(type==RESPONSE_TYPE_FROST)then
        self.display:setChildShaderName(Shader.BLUE_SHADER)
        self:createBufferEffect( "s062_a_buff",1, type, self.effectNode)
    elseif(type==RESPONSE_TYPE_FROZEN)then 
        self:createBufferEffect( "s062_b_buff_bingdong",1, type, self.effectNode)
        self.display:pause()
    elseif(type==RESPONSE_TYPE_REDUCE_POWER)then
        self:playAttrChange(Attr_DAMAGE,-1)
        self:createBufferEffect( "buff_down",0, type, self.effectNode)
    elseif(type=="clearbuff")then
        self:createBufferEffect( "battle_qingchu",0, type, self.effectNode)
    elseif(type==RESPONSE_TYPE_RADIATION ) then --受到辐射
        self:createBufferEffect( "s065_c",1, type, self.effectNode)
    elseif(type==RESPONSE_TYPE_SUB_RECOVERY ) then --治疗效果降低
        self:playAttrChange(Attr_RECOVERY_ADD_PERCENT,-1)
    elseif(type==RESPONSE_TYPE_IMMUNE_HARMFUL_BUFF ) then --免疫控制增加
        self:playAttrChange(Attr_IMMUNE_ADD,1)
    elseif (type==RESPONSE_TYPE_REDUCE_HP_RELIVE_FRIEND)then
        self:createBufferEffect( "s067_buff_diguang",0, type, self.effectNode)
    end


end

function BattleRole:clearEffect()
    self.effectBottomNode:removeAllChildren()
    self.effectNode:removeAllChildren()
    self.display:setChildShaderName("ShaderPositionTextureColor_noMVP")
    self.display:resume()
end

function BattleRole:removeBufferEffect(type)
    if(type==RESPONSE_TYPE_FROST)then
        self.display:setChildShaderName("ShaderPositionTextureColor_noMVP")
    elseif(type==RESPONSE_TYPE_FROZEN)then
        self.display:resume() 
    end
    self.effectNode:removeChildByTag(type)
    self.effectNode:stopAllActions()
    self.effectNode:setScale(1)

    self.effectBottomNode:removeChildByTag(type)
    self.effectBottomNode:stopAllActions()
    self.effectBottomNode:setScale(1)
    
    self.bloodNode.buffContainer:removeChildByTag(type)
    self.effectRetainNode:removeChildByTag(type)
    self.effectRetainNode:stopAllActions()
    self.effectRetainNode:setScale(1)
end



function BattleRole:showAttackUp(  backDis,  upDis)
    --打往后飞
    if(self:isBoss())then
        return
    end

    if(self.curSide==1)then
        backDis=-backDis
    end
    self:playAction(self:getHitToUpActionName())
    local moveTime=8/FLASH_FRAME
    if(upDis==nil or upDis==0)then
        upDis=1
    end

    local moveToUp=cc.EaseOut:create(cc.MoveBy:create(moveTime,cc.p(0,toint(upDis))),2)
    local moveToBack=cc.MoveBy:create(moveTime,cc.p(toint(backDis),0))

    self:runActionByTag( moveToUp,ACTION_TAG_MOVE_Y)
    self:runActionByTag( moveToBack,ACTION_TAG_MOVE_X)
    self:stopActionByTag(ACTION_TAG_MOVE_FUNC)
    self._isUp=true
end

function BattleRole:stopMoveAction()

    self:stopActionByTag(ACTION_TAG_MOVE_Y)
    self:stopActionByTag(ACTION_TAG_MOVE_X)

end

function BattleRole:moveActionByTag(moveTime,targetPos,func,level)
    -- self:stopMoveAction()
    local posX,posY= self:getPosition()
    pos.x=targetPos.x-posX
    pos.y=targetPos.y-posY
    local moveToY= cc.MoveBy:create(moveTime,cc.p(0,pos.y))
    local moveToX=cc.MoveBy:create(moveTime,cc.p(pos.x,0))



    if(func==nil)then
        func=cc.CallFunc:create(function()

            end)
    end
    local moveFunc= cc.Sequence:create(cc.DelayTime:create(moveTime),func)
    self:runActionByTag( moveToX,ACTION_TAG_MOVE_X,level)
    self:runActionByTag( moveToY,ACTION_TAG_MOVE_Y,level)
    self:runActionByTag( moveFunc,ACTION_TAG_MOVE_FUNC,level)


end



function BattleRole:runActionByTag(action,tag,level)
    if(self.isPauseMove==true)then
        return
    end
    if(level==nil)then
        level=1
    end
    local lastAction= self:getActionByTag(tag)
    if(lastAction and lastAction.level and lastAction.level>level)then
        return
    end



    self:stopActionByTag(tag)
    action:setTag(tag)
    action.level=level
    self:runAction( action)

end

function BattleRole:showAttackScroll( backDis,  upDis)
    if(self:isBoss())then
        return
    end

    if(backDis) then
        if(self.curSide==1)then
            backDis=-backDis
        end

        local moveTime=12/FLASH_FRAME
        local moveToUp=cc.EaseOut:create(cc.MoveBy:create(moveTime,cc.p(0,upDis)),2)
        local moveToBack=cc.MoveBy:create(moveTime,cc.p(backDis,0))

        self:runActionByTag( moveToUp,ACTION_TAG_MOVE_Y)
        self:runActionByTag( moveToBack,ACTION_TAG_MOVE_X)
        self:stopActionByTag(ACTION_TAG_MOVE_FUNC)
    end
    self:playAction( self:getHitUpScrollActionName())

end


function BattleRole:isScroll()
    return self.curAction==self:getHitUpScrollActionName()
end


function BattleRole:isDowning()
    return self.curAction==self:getHitDownActionName() or
        self.curAction==self:getHitUpDownActionName()

end


function BattleRole:showAttackBackDown( backDis,callback)

    if(self:isBoss())then
        return
    end
    if(backDis==nil)then
        backDis=0
    end
    --打飞趴
    if(self.curSide==1)then
        backDis=-backDis
    end
    self:playAction(self:getHitDownActionName(),nil,0)

    local moveTo=cc.MoveBy:create(9/FLASH_FRAME,cc.p(backDis,0))
    self:runActionByTag( moveTo,ACTION_TAG_MOVE_X)
    self._isUp=false

    local function _callback()
        if(callback)then
            callback()
        end
    end
    local moveFunc= cc.Sequence:create(cc.DelayTime:create(9/FLASH_FRAME),cc.CallFunc:create(_callback))
    self:runActionByTag( moveFunc,ACTION_TAG_MOVE_FUNC)
end

function BattleRole:isUp()
    local posX,posY=self:getPosition()
    return self.initY-posY<0 and self._isUp
end


function BattleRole:isBack()
    local posX,posY=self:getPosition()
    if(self.curSide==1)then
        return posX<self.initX
    else
        return posX>self.initX
    end
end

function BattleRole:showAttackDown( backDis,callback)

    if(self:isBoss())then
        return
    end
    --直接打趴
    if(self.curSide==1)then
        backDis=-backDis
    end
    local moveTime=9/FLASH_FRAME

    if( self:isUp()) then --如果之前被击浮空，现在落地
        local moveTo;

        local posX,posY=self:getPosition()
        local upDis=self.initY-posY
        if(self:isBack()) then

        else
            backDis=self.initX-posX
        end
        self:playAction(self:getHitUpDownActionName(),nil,0)

        local moveToUp=cc.EaseIn:create(cc.MoveBy:create(moveTime,cc.p(0,upDis)),2)
        local moveToBack=cc.MoveBy:create(moveTime,cc.p(backDis,0))

        self:runActionByTag( moveToUp,ACTION_TAG_MOVE_Y)
        self:runActionByTag( moveToBack,ACTION_TAG_MOVE_X)
    else  --直接趴地
        self:playAction(self:getHitDownActionName(),nil,0)

    end
    self._isUp=false


    local function _callback()
        if(callback)then
            callback()
        end
    end

    local moveFunc= cc.Sequence:create(cc.DelayTime:create(moveTime),cc.CallFunc:create(_callback))
    self:runActionByTag( moveFunc,ACTION_TAG_MOVE_FUNC)
end






function BattleRole:setAnimationSpeed(speed)
    self.curAniSpeed=speed
    if(self.display)then
        self.display:getAnimation():setSpeedScale(self.curAniSpeed)
    end
end

function BattleRole:resetAnimationSpeed()
    self.curAniSpeed=nil
    if(self.display)then
        self.display:getAnimation():setSpeedScale(1)
    end
end


function BattleRole:playAction(str,callback,loop)

    local canReplace,key=self:canReplaceAction(str)
    if(canReplace==false)then
        return
    end


    if(type(str)=="function") then
        str(self)
        if self.curActionIdx<table.getn(self.curActions) then
            self.curActionIdx= self.curActionIdx+1
            self:playAction(self.curActions[self.curActionIdx])
        end
        return
    end


    self:initDisplay()

    self.curActionCallBack=callback
    self.curAction=str

    if(key<1000)then
        self.display.curAction=""
    end
    local ret= self.display:playAction(self.curAction,onActionPlayEndEvent,nil,loop)

    if(self.curAniSpeed)then
        self.display:getAnimation():setSpeedScale(self.curAniSpeed)
    end

    return ret
end

function BattleRole:setInitPos(x,y,z)
    self.initX=x
    self.initY=y
    self.initZ=z
    self:setPosition(x,y)
    self:setLocalZOrder(z)

    self.bloodNode:removeFromParent()
    self:getParent():addChild(self.bloodNode)
    self.bloodNode:setPosition(x,y)
    self.bloodNode:setLocalZOrder(-100+z)
end


function BattleRole:resetRoleState()
    self:setLocalZOrder(self.initZ)
    self.bloodNode:setLocalZOrder(-100+self.initZ)
    self.scaleAdd=1
    self:resetScale()
    if(self.isDead==false)then
        self:setVisible(true)
    end
end

function BattleRole:resetZOrder()
    self.initZAdd=0
    self:setLocalZOrder(self.initZ)
    self.bloodNode:setLocalZOrder(-100+self.initZ)
end


function BattleRole:playActions(actions)

    self.curActions=actions
    self.curActionIdx=1
    self:playAction( self.curActions[self.curActionIdx])


end


function BattleRole:playReliveAfterDead()
    --暂时复活
    self.curAction=""
    self.isDead=false
    self.bloodNode:setVisible(true)
    self.shadow:setVisible(true)
    self:setVisible(true) 
    self:stopMoveAction()
    self:stopActionByTag( ACTION_TAG_DIE)
    local function callback()
        self.curAction=""
        self:playAction(self:getWaitActionName())
    end
    self:playAction(self:getReliveAfterDeadActionName(),callback)
    self:clearEffect()
end

--播放技能
function BattleRole:attack(attackData,targets,skillAfterDead)
    if(skillAfterDead==nil)then
        skillAfterDead=false
    end
    self.curAttackData=attackData
    self.curAttackTargets=targets

    local function callback()
        self.curAction=""
        self:playAction(self:getWaitActionName())
    end
        
    local isCooperateSkill=false
    if(attackData.skillType==1) then
        local skill=DB.getSkillById(attackData.skillId)
        if(self.battleLayer:needShowCooperate(skill ,self) )then
            isCooperateSkill=true
            self:playAction( self:getCooperateAttackActionName(),callback )
        else
            self:playAction(self:getBigAttackActionName(),callback)

        end
    elseif(attackData.skillType==2) then
        self:playAction( self:getExtraAttackActionName(),callback )
    else
        self:playAction( self:getSmallAttackActionName(),callback )
    end

    if(isCooperateSkill~=true)then
        self:moveActionByTag(0.2 ,cc.p(self.initX,self.initY))
    end
end



function BattleRole:showSelected()
    self.bloodNode:showSelected()
end

function BattleRole:showUnSelected()
    self.bloodNode:showUnSelected()
end

function BattleRole:showAttackWaiting()
    self:addBufferEffect(EFFECT_ATTACK_WATING)
    self.bloodNode:showSetSelectMode(0,"skillwaiting-di")
end

function BattleRole:hideAttackWaiting()
    self:removeBufferEffect(EFFECT_ATTACK_WATING)
    self.bloodNode:showUnSetSelectMode()

end

function BattleRole:showSetSelectMode(sameSide)
    self.canSelect=true
    self.touchNode:setVisible(true)
    local effect1=nil
    local effect2=nil
    if(sameSide)then
        effect1=self:createBufferEffect( "battle_select_green_arrow",1, EFFECT_SELECT_MODE, self.effectNode)

    else
        effect1=self:createBufferEffect( "battle_select_red_arrow",1, EFFECT_SELECT_MODE, self.effectNode)

    end
    self.bloodNode:setLocalZOrder(self:getLocalZOrder()-1)
    self.bloodNode:showSetSelectMode(sameSide)
end

function BattleRole:showUnSetSelectMode()

    self.touchNode:setVisible(false)
    self.canSelect=false
    self:removeBufferEffect(EFFECT_SELECT_MODE)
    self:showUnSelected()
    self.bloodNode:showUnSetSelectMode()
end

function  BattleRole:win()
    self:playAction( self:getWinActionName() )
end


function BattleRole:addRage(num)
    self.bloodNode:addBlue(num,true)
end

function  BattleRole:showHited(effectName)

    if(self:isDowning() or self:isScroll()) then

    else
        if(self:isUp()) then
            local actions={}
            self:playAction(self:getUpHurtActionName() )
        else
            self.display.curAction=""
            self:playActions({self:getSmallHurtActionName(),self:getWaitActionName()})
        end
    end

    if(effectName==nil)then
        effectName="washit"
    end

    if(toint(self.curCardid)~= 10511 )then
        local effect=createSkillEffect(self,effectName)
        effect:setLocalZOrder(400)
    end
end



function BattleRole:resetRage()
    self.bloodNode:resetBlue(true)
end


function BattleRole:playFlaWordEffect(fla,num,color)
    local retSprite=FlashAni.new()
    local function removeFromParent()
        retSprite:removeFromParent()
    end

    if(fla==WORDS_SHOW_SANBI) then
        retSprite:playAction("battle-shanbi-zi-1",removeFromParent)
    elseif(fla==WORDS_SHOW_BAOJI) then
        retSprite:playAction("battle-word-b",removeFromParent)
        local word={}
        if(color==GREEN_COLOR)then
            table.insert(word,WORDS_SHOW_BAOJI_RECOVER)
        else
            table.insert(word,WORDS_SHOW_BAOJI)
        end
        retSprite:replaceBoneWithNode({"word"},self:createWordEffect(color,num ,word) )
        retSprite:setScale(0.8)
    end

    if(retSprite)then
        local posX,posY=self:getPosition()
        retSprite:setPosition( posX ,posY )
        self.battleLayer:getNode("word_container"):addChild(retSprite)
    end
end

function  BattleRole:createWordEffect(color,num,words)
    local totalWidth=0
    local totalHeight=0
    local retSprite=   cc.Node:create()
    local wordSprite=nil
    local wordHeight=0
    if(words and words~=0)then
        wordSprite=gCreateWordsSprite(color,words)
        retSprite:addChild(wordSprite)
        wordSprite:setPositionX(totalWidth+wordSprite:getContentSize().width/2)
        wordSprite:setPositionY(0)
        totalWidth=totalWidth+wordSprite:getContentSize().width
        wordHeight=wordSprite:getContentSize().height
    end

    local numSprite=nil
    if(num~=0)then
        numSprite=gCreateNumSprite(color, num)
        local scale=0.7
        if(wordHeight~=0)then
            scale=wordHeight/numSprite:getContentSize().height
        end
        numSprite:setScale(scale)
        numSprite:setPositionX(totalWidth+numSprite:getContentSize().width*scale/2)
        totalWidth=totalWidth+numSprite:getContentSize().width*scale
        retSprite:addChild(numSprite)

    end

    if(wordSprite)then
        wordSprite:setPositionX(wordSprite:getPositionX()-(totalWidth*0.5))
    end

    if(numSprite)then
        numSprite:setPositionX(numSprite:getPositionX()-(totalWidth*0.5))
    end

    retSprite:setCascadeOpacityEnabled(true)
    return retSprite,totalWidth

end
--播放加血
function BattleRole:playWordEffect(color,num,scale,words,delay)

    local totalWidth=0
    local retSprite,totalWidth=self:createWordEffect( color,num,words)


    local function removeFromParent()
        retSprite:removeFromParent()
    end


    local function createAction()
        local moveTo= cc.EaseOut:create(cc.MoveBy:create(0.3,cc.p(0,120)),2.5)
        local moveTo2= cc.EaseIn:create(cc.MoveBy:create(0.3,cc.p(0,180)),2.5)
        local moveIn=cc.Spawn:create(cc.FadeIn:create(0.3),moveTo)
        local moveOut=cc.Spawn:create(cc.FadeOut:create(0.3),moveTo2)
        local callFunc=cc.CallFunc:create(removeFromParent)
        local retAction={moveIn,cc.DelayTime:create(0.05),moveOut,callFunc}
        if(delay and delay>0)then
            table.insert(retAction,0,cc.DelayTime:create(delay))
        end
        return cc.Sequence:create(retAction)
    end
    self.battleLayer:getNode("word_container"):addChild(retSprite)
    local posX,posY=self:getPosition()
    retSprite:setScale(scale)
    retSprite:setPosition( posX-(totalWidth*scale*0.5)/2,posY+50)
    retSprite:runAction(createAction())

end




function BattleRole:beforeAction(data,bufferDatas)

    if( bufferDatas.response==RESPONSE_TYPE_ATTR_CHANGE) then   -- 属性变化
        for key, var in pairs(bufferDatas.effectList) do
            self:changeAttr(var.type,var.attr,var.value,var.isCritical)
    end

    elseif( bufferDatas.response==RESPONSE_TYPE_ADD_DAMAGE) then   -- 攻击增加
        self:playAttrChange(Attr_DAMAGE,1)
    elseif( bufferDatas.response==RESPONSE_TYPE_ADD_POWER) then   -- 攻击增加
        self:playAttrChange(Attr_DAMAGE,1)
    end


end

function BattleRole:AttackBuffAction(data,targetData)
    if(targetData.response==RESPONSE_TYPE_IMMUNE_HARMFUL_BUFF)then
        self:addBufferEffect(RESPONSE_TYPE_IMMUNE_HARMFUL_BUFF)
    end 
end

function BattleRole:afterAction(data,targetData)
    if( targetData.response==RESPONSE_TYPE_ATTR_CHANGE) then
        -- 属性变化
        for key, var in pairs(targetData.effectList) do
            self:changeAttr(var.type,var.attr,var.value,var.isCritical)
        end
    elseif( targetData.response==RESPONSE_TYPE_RELIVE) then
        --重生
        self:showRelive(data)
        self:addLife(targetData.damage,false)

    elseif(targetData.response==RESPONSE_TYPE_CLEAR_RELIVE_POINT)then
        self.relivePoint=0
        self:showRemoveBuff(EFFECT_RELIVE_POINT)
    end 
end


function BattleRole:showRemoveBuff(type,effectData,data)
    if( type==RESPONSE_TYPE_STUN_REMOVE)then
        --眩晕解除
        self:removeBufferEffect(RESPONSE_TYPE_STUN)
    elseif( type==RESPONSE_TYPE_SPIRIT_CHAIN+100)then

        local activeSide =data.activeSide
        local activePosition =data.activePosition
        if(self.curPos==activePosition and
            self.curSide==activeSide and
            self.isDead==false )then
            self:playChange(Card_MIKU_SPIRIT)
        end
        self:removeBufferEffect(RESPONSE_TYPE_SPIRIT_CHAIN)
    elseif( type==RESPONSE_TYPE_IMMUNE_REMOVE)then
        --眩晕解除
        if(effectData)then
            if(effectData.attr==Attr_PHYSICAL_ATTACK)then
                self:removeBufferEffect(EFFECT_IMMNUE_PHYSICAL_ATTACK)
            else
                self:removeBufferEffect(EFFECT_IMMNUE_MAGIC_ATTACK)
            end
        else
            self:removeBufferEffect(EFFECT_IMMNUE_PHYSICAL_ATTACK)
            self:removeBufferEffect(EFFECT_IMMNUE_MAGIC_ATTACK)
        end
    elseif(type==RESPONSE_TYPE_ATTR_CHANGE_REMOVE)then
        self:removeBufferEffect(EFFECT_REDUCE_HURT)

    elseif(type==RESPONSE_TYPE_FROZEN_REMOVE or type==RESPONSE_TYPE_FROZEN+100 )then
        self:removeBufferEffect(RESPONSE_TYPE_FROZEN)

    elseif(type== RESPONSE_TYPE_FROST+100)then
        self:removeBufferEffect(RESPONSE_TYPE_FROST)

    elseif(type==EFFECT_RELIVE_POINT)then
        for i=1, 3 do
            self:removeBufferEffect(EFFECT_RELIVE_POINT*10+i)
        end

    elseif(type==RESPONSE_TYPE_LOCK_REMOVE)then--封印解除
        self:removeBufferEffect(RESPONSE_TYPE_LOCK)

    elseif(type==RESPONSE_TYPE_FROST_REMOVE)then
        self:removeBufferEffect(RESPONSE_TYPE_FROST)
         
        
    elseif( type==RESPONSE_TYPE_SHIELD_REMOVE)then-- 护盾解除

        self:removeBufferEffect(RESPONSE_TYPE_SHIELD)
    elseif(type==RESPONSE_TYPE_REDUCE_HP_REMOVE)then-- 每回合扣血解除
        self:removeBufferEffect(RESPONSE_TYPE_REDUCE_HP)
    end
end

function BattleRole:resetOldCardid()
    if(self.oldCardid)then
        self.curXmlName="r"..self.oldCardid
        self.curCardid=self.oldCardid
        
        if self.oldCurWeaponLv then
            self.curWeaponLv = self.oldCurWeaponLv
        end
        if self.oldCurAwakeLv  then
            self.curAwakeLv = self.oldCurAwakeLv 
        end
        self:setWeaponAwake()

        self:initActionQueue()
    end
end

function BattleRole:getCurSkillCardid()
    local curCardid=self.curCardid
    if(curCardid==Card_MIKU)then
        curCardid=Card_MIKU_SPIRIT
    elseif(curCardid==Card_MIKU_SPIRIT)then
        curCardid=Card_MIKU
    end
    return curCardid
end

function BattleRole:changeCardid(carid,weaponLv,awakeLv)
    self.oldCardid =self.curCardid
    self.curXmlName="r"..carid
    self.curCardid=carid

    if weaponLv~=nil then
        self.oldCurWeaponLv = self.curWeaponLv
        self.curWeaponLv = weaponLv
    end
    if awakeLv~=nil then
        self.oldCurAwakeLv = self.curAwakeLv
        self.curAwakeLv = awakeLv
    end
    if weaponLv~=nil or awakeLv~=nil then
        self:setWeaponAwake()
    end
    self:initActionQueue()
end

function BattleRole:changeAttackEventCardid(carid)
    self.curAttackXmlName="r"..carid
end


function BattleRole:playReduceWord(num,critical,words,delay,color)
    if(num==0)then
        return
    end
    if(color==nil)then
        color=RED_COLOR
    end

    if(critical) then
        self:playFlaWordEffect(WORDS_SHOW_BAOJI,"-"..num,color)
    else
        self:playWordEffect(color, "-"..num,1.0,words,delay)
    end
end

function BattleRole:reduceLife(num,critical,words,delay,color)
    self:playReduceWord(num,critical,words,delay,color)
    self.bloodNode:reduceRed(num,true)
end

function BattleRole:addLife(num,critical,words)
    if(num==0)then
        return
    end

    if(critical) then
        self:playFlaWordEffect(WORDS_SHOW_BAOJI,"+"..num,GREEN_COLOR)
    else
        self:playWordEffect(GREEN_COLOR, "+"..num,1.0,words)
    end
    self.bloodNode:addRed(num,true)
end

function BattleRole:resetPlayChange()
    if self.isDead == false then
        local function actionCallBack()
            self:resetOldCardid()
            self:playAction(self:getWaitActionName())
        end
        createSkillEffect(self,"s066_c")
        gCallFuncDelay(6/FLASH_FRAME,self,actionCallBack)
    end
end

function BattleRole:playChangeToEnemy(cardid,weaponLv,awakeLv)

    self.isDead=false
    self:setVisible(true)
    local function actionCallBack()
        self:changeCardid(cardid,weaponLv,awakeLv)
        self:playAction(self:getWaitActionName())
    end

    local iconFla = nil
    local selNode = nil
    local function finishCallback()
        iconFla:stopAni()
        selNode:removeFromParent()
        createSkillEffect(self,"s066_c")
        gCallFuncDelay(6/FLASH_FRAME,self,actionCallBack)
    end
    local function startCallback()
        local findIcon = cc.Sprite:create()
            findIcon:setScale(0.8)
            local lawakeLv = awakeLv or 0
            Icon.setHeadIcon(findIcon,lawakeLv*10000000+cardid)
            iconFla:replaceBoneWithNode({"ka3","head"},findIcon)
    end

    iconFla = gCreateFlaDelayAndCallback(0,"s066_touxiang",1, finishCallback ,startCallback)
    --iconFla:setScale(self:roleScale())

    local stencil = cc.LayerColor:create(cc.c4b(255,255,255,50),150,120);
    selNode = cc.ClippingNode:create();
    selNode:setStencil(stencil);
    selNode:setContentSize(cc.size(150,120));
    selNode:ignoreAnchorPointForPosition(false)
    selNode:setAnchorPoint(cc.p(0.5,0.5))
    selNode:setScale(self:roleScale())
    selNode:setPosition(0,self.display:getBoundingBox().height+20)

    gAddChildInCenterPos(selNode,iconFla)

    self.skillNode:addChild(selNode,500)
    --gCallFuncDelay()
    --createSkillEffect(self,"s066_touxiang")
    --gCallFuncDelay(6/FLASH_FRAME,self,actionCallBack)
    --self:playAction("s066_c",actionCallBack)
    self:setPosition(self.initX,self.initY)
    self.shadow:setVisible(true)

end


function BattleRole:playChange(cardid)

    self.isDead=false
    self:setVisible(true)
    self:changeCardid(cardid)
    self:playActions( {self.curXmlName.."_zhaohuan",self:getWaitActionName()})
    self:setPosition(self.initX,self.initY)
    self.shadow:setVisible(true)

end

--变身
function BattleRole:hasChange()
    if self.oldCardid == nil or self.oldCardid==0 or self.oldCardid == self.curCardid then
         return false
    end
    return true
end

function BattleRole:playChangeBoss(cardid)
    local function callback()
        self:changeCardid(cardid)
        self.initX =self.initX-70
        self.initY =self.initY-70
        self.bloodNode:setVisible(false)
        self:setPosition(self.initX,self.initY)
        self:playActions({self.curXmlName.."_zhaohuan",self:getWaitActionName()})
        self.battleLayer:shake(9,50,1)
        self.oldCardid=cardid
    end

    self.battleLayer:createCover("s022-zhaohuan-quanping",{self})

    self:playAction( self.curXmlName.."_zhaohuan",callback)
    self:setPosition(self.initX,self.initY)

end

--血量改变
function BattleRole:changeHpAttr(type,value,critical)
    if(value==0)then
        return
    end
    if(type==EFFECT_TYPE_ATTR_ADD)then
        self.bloodNode:addRed(value,true)
    elseif(type==EFFECT_TYPE_ATTR_REDUCE)then
        self.bloodNode:reduceRed(value,true)
    elseif(type==EFFECT_TYPE_DAMAGE)then
        self.bloodNode:reduceRed(value,true)
    end

    local color=RED_COLOR
    local attrType=""
    local words=0
    if(type==EFFECT_TYPE_ATTR_ADD) then
        color=GREEN_COLOR
        value="+"..value
    else
        value="-"..value
    end

    if(critical)then
        self:playFlaWordEffect(WORDS_SHOW_BAOJI,value,color)
    else
        self:playWordEffect(color, value,1.0 )
    end

end

function BattleRole:playAttrChange(attr,type)
    local word=CardPro.getAttrName(attr)
    if(word==nil)then
        word=""
    end
    local color=cc.c3b(255,0,0)

    if(type>0)then
        color=cc.c3b(0,255,0)
    end

    local labWord = gCreateWordLabelTTF(word,gCustomFont,26,color);
    labWord:enableOutline(cc.c4b(50,90,0,255),24*0.1);
    local effect=nil
    local function playEnd()
        labWord:removeFromParent()
    end

    local function updateWordPos()

        local pos1=effect:getBone( "word")
        if(pos1)then
            local box=  pos1:getDisplayManager():getBoundingBox()
            local boxX=box.x
            labWord:setPosition(boxX ,box.y+100)
        end
    end

    if(type>0)then
        effect=  gCreateFla("battle_up",0,playEnd)
    else
        effect=  gCreateFla("battle_down",0,playEnd)
    end

    effect:setPositionY(100)
    if(self:getScaleX()<0)then
        effect:setScaleX(-effect:getScaleX())
        labWord:setScaleX(-labWord:getScaleX())
    end
    effect:scheduleUpdateWithPriorityLua(updateWordPos,1)
    self:addChild(labWord)
    self:addChild(effect)
    effect:replaceBoneWithNode({"word"},cc.Node:create())

end


function BattleRole:setSkipRelive(value)
    self.finalHp=value
end

function BattleRole:setSkipHp(value,attackRole)
    local preValue=self.finalHp
    self.finalHp=self.finalHp+value


    if(self.finalHp> self.hpInit)then
        self.finalHp= self.hpInit
    end

    if(self.finalHp<0)then
        self.finalHp= 0
    end
    value=self.finalHp-preValue

    local datas=nil
    if(self.curSide==1)then
        if(value>=0)then
            datas=  Battle.myBattleRecoverData
        else
            datas=Battle.myBattleHurtData
        end
    else
        if(value>=0)then
            datas=Battle.otherBattleRecoverData[ Battle.curBattleGroup]
        else
            datas=Battle.otherBattleHurtData[ Battle.curBattleGroup]
        end

    end

    if(attackRole and value<0  )then
        local damages=nil
        if(attackRole.curSide==1)then
            damages=  Battle.myBattleDamageData
        else
            damages=Battle.otherBattleDamageData[ Battle.curBattleGroup]
        end
        damages[attackRole.curPos]= damages[attackRole.curPos]-value
    end


    if(datas)then
        if(datas[self.curPos]==nil)then
            datas[self.curPos]=0
        end
        if(value>0)then
            datas[self.curPos]= datas[self.curPos]+value
        else
            datas[self.curPos]= datas[self.curPos]-value
        end
    end


end

function BattleRole:setSkipChangeAttr(effectData,attackeRole)
    if(effectData==nil)then
        return
    end
    local attr=effectData.attr
    local type=effectData.type
    local value=effectData.value

    if( attr==Attr_HP) then
        if(type==EFFECT_TYPE_ATTR_ADD)then
            self:setSkipHp(value,attackeRole)
        elseif(type==EFFECT_TYPE_ATTR_REDUCE)then
            self:setSkipHp(-value,attackeRole)
        elseif(type==EFFECT_TYPE_DAMAGE)then
            self:setSkipHp(-value,attackeRole)
        end
    end


end

function BattleRole:changeAttr(type,attr,value,critical)


    if( attr==Attr_HP) then
        self:changeHpAttr(type,value,critical)
        return
    end

    if(attr==Attr_HURT_DOWN)then
        if(type==EFFECT_TYPE_ATTR_ADD)then
            self:addBufferEffect(EFFECT_REDUCE_HURT)
        end
    end

    if(attr==Attr_RAGE)then
        if(type==EFFECT_TYPE_ATTR_ADD)then
            self.bloodNode:addBlue(value,true)
        elseif(type==EFFECT_TYPE_ATTR_REDUCE)then
            self.bloodNode:reduceBlue(value,true)
        end
    end

    if(attr==Attr_RELIVE_POINT)then
        self.relivePoint=self.relivePoint+1
        self:addBufferEffect(EFFECT_RELIVE_POINT)
    end


    local dir=-1
    if(type==EFFECT_TYPE_ATTR_ADD) then
        dir=1
    end
    self:playAttrChange(attr,dir)
end

--闪避
function BattleRole:attackedDodge()
    self:showHited()
    self:playFlaWordEffect(WORDS_SHOW_SANBI)

end

--免疫
function BattleRole:attackedImmune(targetData)
    if(targetData.effectList[1])then
        if(targetData.effectList[1].attr==Attr_PHYSICAL_ATTACK)then
            self:addBufferEffect(EFFECT_IMMNUE_PHYSICAL_ATTACK)
        else
            self:addBufferEffect(EFFECT_IMMNUE_MAGIC_ATTACK)
        end
    end
end

--反伤
function BattleRole:attackedReboundDamage( effectData,targetData,attacker,data)
    attacker:reduceLife(targetData.damage,false,{WORDS_SHOW_FANSHANG},nil,"white_num")
    attacker.isDead=targetData.isDead
    attacker:showDie(data.attackData)
end

--回血
function BattleRole:attackedRecovery( effectData,targetData,attacker,data)
    if(effectData)then
        self:addBufferEffect(WORDS_SHOW_HUIXUE)
        self:addLife(effectData.value,effectData.isCritical,{})
    end
end

function BattleRole:attackedSpiritChain(data)
    self:reduceLife(data.damage,false,{})
    if(self.isDead==false)then
        self.isDead=data.isDead
    end 
    self:showDie(data)
end

function BattleRole:attackedRadiation(data)
    self:reduceLife(data.damage,false,{})
    if(self.isDead==false)then
        self.isDead=data.isDead
    end 
    self:showDie(data)
end

function BattleRole:attackedSuck(data)

    self:addLife(data.damage,false,{})
end

--卡牌执行减伤攻击事件
function BattleRole:attackedResist()

end

function BattleRole:talk(word,delayTime,lastTime)
    if(self.talkPanel)then
        self.talkPanel:removeFromParent()
        self.talkPanel=nil
    end

    self.talkPanel=BattleTalk.new()
    self.talkPanel:setVisible(false)
    self.talkPanel:showWord(word)
    self.talkPanel:setPositionY(100)
    self.talkPanel:setPositionX(60)
    self:addChild(self.talkPanel)

    local function showfunc()
        self.talkPanel:setVisible(true)
    end



    local function callfunc()
        self.talkPanel:removeFromParent()
        self.talkPanel=nil
    end

    if(lastTime==nil)then
        lastTime=60/FLASH_FRAME
    end

    local delay=cc.DelayTime:create(lastTime)
    local hideFunc=cc.CallFunc:create(callfunc)
    local showFunc=cc.CallFunc:create(showfunc)
    if(delayTime==nil)then
        delayTime=0
    end
    self.talkPanel:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime) ,showFunc,delay,hideFunc))
end


--卡牌执行加盾攻击事件
function BattleRole:attackedShield()

end


function BattleRole:attacked( effectData,targetData,attacker,data,showHit)

    local attackIdx=data.attackIdx
    local attackMaxNum=data.attackMaxNum
    DisplayUtil.setGray(self,false)
 

    --------需要扣血
    if( targetData.response==RESPONSE_TYPE_SUB_RECOVERY or
        targetData.response==RESPONSE_TYPE_NOTHING or
        targetData.response==RESPONSE_TYPE_STUN or
        targetData.response==RESPONSE_TYPE_LOCK or
        targetData.response==RESPONSE_TYPE_FROST or
        targetData.response==RESPONSE_TYPE_FROZEN or 
        targetData.response==RESPONSE_TYPE_FROZEN_BROKEN or   
        targetData.response==RESPONSE_TYPE_IMMUNE or
        targetData.response==RESPONSE_TYPE_ADD_DAMAGE or
        targetData.response==RESPONSE_TYPE_REDUCE_POWER or
        targetData.response==RESPONSE_TYPE_REDUCE_HP or
        targetData.response==RESPONSE_TYPE_REDUCE_HP_RELIVE_FRIEND)then --被击包括,晕眩,封印

        self.isDead=targetData.isDead

        if(targetData.isEnemy and showHit~=false)then
            self:showHited()

        end

        if(targetData.response~=RESPONSE_TYPE_IMMUNE)then
            if(effectData  )then
                self:changeAttr(effectData.type,effectData.attr,effectData.value,effectData.isCritical)
            end
        else
            local effect=nil
            if(targetData.responseRound==Attr_PHYSICAL_ATTACK)then
                effect= self:createBufferEffect( "ui_buff_wulimianyi",0, type, self.effectNode)
            elseif(targetData.responseRound==Attr_MAGIC_ATTACK)then
                effect= self:createBufferEffect( "ui_buff_mofamianyi",0, type, self.effectNode)
            end
            if(effect)then
                effect:setPositionY(100)
            end
            if(effect and self.curSide==2)then
                effect:setScaleX(-effect:getScaleX())
            end
        end

        if(attackIdx==attackMaxNum)then
            if(data.isAttackDown==false)then
                self:showDie(data.attackData)
            end

            if targetData.response==RESPONSE_TYPE_SUB_RECOVERY then
                self:addBufferEffect(RESPONSE_TYPE_SUB_RECOVERY)
            end
            if(targetData.response==RESPONSE_TYPE_STUN )then
                self:playWordEffect(GREEN_COLOR, 0,1,{})
                self:addBufferEffect(RESPONSE_TYPE_STUN)
            elseif(targetData.response==RESPONSE_TYPE_REDUCE_HP)then
                self:addBufferEffect(RESPONSE_TYPE_REDUCE_HP) 
            elseif(targetData.response==RESPONSE_TYPE_REDUCE_HP_RELIVE_FRIEND)then
                self:addBufferEffect(RESPONSE_TYPE_REDUCE_HP_RELIVE_FRIEND) 
            elseif(targetData.response==RESPONSE_TYPE_ADD_DAMAGE)then
                self:addBufferEffect(RESPONSE_TYPE_ADD_DAMAGE)
            elseif(targetData.response==RESPONSE_TYPE_REDUCE_POWER)then
                self:addBufferEffect(RESPONSE_TYPE_REDUCE_POWER)

            elseif(targetData.response==RESPONSE_TYPE_SHIELD)then
                self:addBufferEffect(RESPONSE_TYPE_SHIELD)
            elseif(targetData.response==RESPONSE_TYPE_LOCK)then
                self:addBufferEffect(RESPONSE_TYPE_LOCK)
            elseif(targetData.response==RESPONSE_TYPE_FROST)then
                self:addBufferEffect(RESPONSE_TYPE_FROST)
            elseif(targetData.response==RESPONSE_TYPE_FROZEN)then
                self:removeBufferEffect(RESPONSE_TYPE_FROST) 
                self:addBufferEffect(RESPONSE_TYPE_FROZEN)
            elseif(targetData.response==RESPONSE_TYPE_FROZEN_BROKEN)then
                self:removeBufferEffect(RESPONSE_TYPE_FROZEN )  
            end
        end

    end

end




return BattleRole