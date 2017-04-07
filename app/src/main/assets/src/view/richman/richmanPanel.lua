local RichmanPanel=class("RichmanPanel",UILayer)

local MOVE_WIDTH=400
local MAX_BLOCK=40
function RichmanPanel:ctor(data)
    self:init("ui/ui_richman.map")
    self:getNode("move_container").oldX=self:getNode("move_container"):getPositionX()
    self:initRolePos()
    self:initData()
    self:setAuto(false)
end

function RichmanPanel:setAuto(isAuto)
    self.isAuto=isAuto
    if(isAuto)then
        self:changeTexture("btn_auto","images/ui_public1/n-di-gou2.png")
        self:setMainLayerTouchEnable(false)
    else
        self:changeTexture("btn_auto","images/ui_public1/n-di-gou1.png")
        self:setMainLayerTouchEnable(true)
    end
end

function RichmanPanel:onPopback()
    self:setMainLayerTouchEnable(true)

end
function RichmanPanel:getBlock(idx)
    local key=(idx+1)
    local ret= self:getNode("block"..key)
    if(ret==nil)then
        key=key%MAX_BLOCK
        ret= self:getNode("block"..key)
    end
    return ret,key-1
end
function RichmanPanel:setMainLayerTouchEnable(enable)
    if nil ~= gMainMoneyLayer then
        gMainMoneyLayer:getNode("panel_money").touchEnable = enable
        gMainMoneyLayer:getNode("panel_menu").touchEnable = enable
    end
end
function RichmanPanel:initRolePos()

    if(self.role==nil)then
        self.role=gCreateRoleFla(Data.getCurIcon(), self:getNode("role_container") ,1,nil,nil,Data.getCurWeapon(),Data.getCurAwake())
        self.role:setScale(0.6)
        local shadow=cc.Sprite:create("images/battle/shade.png")
        shadow:setScaleY(0.5)
        self.role:addChild(shadow)
    end

    for i=1, MAX_BLOCK do
        if(self:getNode("block"..i))then
            self:getNode("block"..i).zorder=self:getNode("block"..i):getLocalZOrder()
            local id= gRichman.posInfo[i]
            local db=DB.getRichmanConfigByType2(id)
            self:changeTexture("block"..i,"images/ui_team/"..db.style..".png")
            self:setTouchEnable("block"..i,false,false)
        end
    end
    self:resetLuck()
end

function RichmanPanel:resetLuck()

    for i=1, MAX_BLOCK do
        self:getNode("block"..i):setLocalZOrder(self:getNode("block"..i).zorder)
        self:setTouchEnable("block"..i,false,false)
    end
    self.isLucking=false
    self:getNode("cover"):setVisible(false)
end

function RichmanPanel:setLuck()
    self.isLucking=true
    self:getNode("cover"):setVisible(true)
    self:getNode("cover"):setLocalZOrder(1)
    local idx=self.curBlockIdx
    for i=1, 6 do
        idx=idx+1
        print(idx)
        local block,idx=self:getBlock(idx)
        block.count=i
        block:setLocalZOrder(100+block.zorder)
        self:setTouchEnable("block"..(idx+1),true,false)
    end


end

function RichmanPanel:initParam(score,rank,actionnum,lucknum)

    if score~=nil then
        self:setLabelString("txt_score",score)
    end
    if rank~=nil then
        self:setLabelString("txt_rank",rank)
    end
    if actionnum~=nil then
        self:setLabelString("txt_num",actionnum)
    end
    if lucknum ~= nil then
        self:setLabelString("txt_luck_num",lucknum)
    end

    
end

function  RichmanPanel:initData()

    self:initParam(gRichman.score,gRichman.rank,gRichman.actionnum,gRichman.lucknum)

    self.curBlockIdx=gRichman.curPos
    local block=self:getBlock( self.curBlockIdx)
    local nextblock=self:getBlock( self.curBlockIdx+1)
    local pos=cc.p(block:getPosition())
    self.role:setPosition(pos)
    self:checkRoleCenter()

    if(nextblock:getPositionX()>=self.role:getPositionX())then
        self.role:setScaleX(0.6)
    else
        self.role:setScaleX(-0.6)
    end


end


function  RichmanPanel:move(num)
    if(self.isMoving==true)then
        return
    end
    self:resetLuck()
    self.isMoving=true
    self.moveNum=num
    self:checkRoleCenter()
    self:moveToNext()
end

function  RichmanPanel:onReach()
    self:checkRoleCenter()

    if( self.movecount>0)then
        gShowNotice(gGetWords("richman.plist","move",self.movecount));
        self.moveNum=self.movecount
        self.movecount=0
        self:moveToNext()
        return
    end
    if(self.rewards)then
        gShowItemPoolLayer:pushItems(self.rewards.items);
        self.rewards=nil
    end

    self.isMoving=false
    self.role:playAction("r"..self.role.cardid.."_wait")



    self:initParam(gRichman.score,gRichman.rank,gRichman.actionnum,gRichman.lucknum)
    
    
    if(self.shopid and self.shopid~=0)then
        local db=DB.getRichmanConfig(self.shopid)
        if(db and db.type1==4)then 
            Panel.popUp(PANEL_RICHMAN_SHOP,self.shopid)
        else 
            self:checkContinue()
        end 
        self.shopid=nil
    elseif(self.eventid and self.eventid~=0)then
        local db=DB.getRichmanConfig(self.eventid)
        if(db and db.type1==5)then 
            Panel.popUp(PANEL_RICHMAN_EVENT,self.eventid)
        else 
            self:checkContinue()
        end 
        self.eventid=nil
    else
        self:checkContinue()
    end


end



function  RichmanPanel:onPopup()
    self:checkContinue()
end

function  RichmanPanel:checkContinue()
    if(self.isAuto and self.isMoving==false)then
        if( gRichman.actionnum>0)then
            Net.sendRichmanAction(0)
        else
            self:setAuto(false)
        end
    end
end
function  RichmanPanel:moveToNext()

    local block,idx=self:getBlock(self.curBlockIdx+1)
    if(idx==1)then
        if(self.firstReward)then
            self.role:playAction("r"..self.role.cardid.."_wait")
            Panel.popUp(PANEL_RICHMAN_PASS,self)
            self.firstReward=nil
            return
        end
    end


    if(self.moveNum==0)then
        self:onReach()
        return
    end
    self.curBlockIdx= self.curBlockIdx+1
    self.moveNum=self.moveNum-1

    self.role:playAction("r"..self.role.cardid.."_run")
    local block,idx=self:getBlock(self.curBlockIdx)
    self.curBlockIdx=idx


    if(block:getPositionX()>=self.role:getPositionX())then
        self.role:setScaleX(0.6)
    else
        self.role:setScaleX(-0.6)
    end


    local function callback()
        self:moveToNext()
    end
    self.role:stopAllActions()
    self.role:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(0.5,cc.p(block:getPosition())),
            cc.CallFunc:create(callback,{})
        )
    )
end


function  RichmanPanel:events()
    return {EVENT_ID_RICHMAN_ACTION,EVENT_ID_RICHMAN_BUYACTION,EVENT_ID_RICHMAN_SHOPBUY}
end



function RichmanPanel:dealEvent(event,param)
    if(event==EVENT_ID_RICHMAN_ACTION)then
        self.rewards=param.rewards
        self.eventid=param.eventid
        self.shopid=param.shopid
        self.movecount=param.movecount
        self.firstReward=param.firstReward

        local function callback()
            self.isMoving=false
            self:move(param.count)
        end

        self.isMoving=true
        self:onShowNum(param.count,callback)
        self:initParam(gRichman.score,gRichman.rank,gRichman.actionnum,nil)

    elseif(event==EVENT_ID_RICHMAN_BUYACTION)then
        self:initParam(gRichman.score,gRichman.rank,gRichman.actionnum,gRichman.lucknum)

    elseif(event==EVENT_ID_RICHMAN_SHOPBUY)then
        self:initParam(gRichman.score,gRichman.rank,gRichman.actionnum,gRichman.lucknum)
    end
end


function RichmanPanel:onShowNum(num ,callback)
    local function played()
        self:getNode("effect_sazi"):setVisible(false)
        self:getNode("effect_sazi"):pause()
        callback()
    end

    self:getNode("effect_sazi"):resume()
    self:getNode("effect_sazi"):setVisible(true)
    self:getNode("effect_sazi"):playAction("qp_saizi",played)
    self:getNode("effect_sazi"):replaceBone({"1"},"images/ui_team/t"..num..".png")
end

function RichmanPanel:onTouchBegan(target,touch, event)


    if(target.touchName=="panel_break_bg")then
        self.preLocaltion= touch:getLocation()
    end


end




function RichmanPanel:onTouchMoved(target,touch, event)
    if(target.touchName=="panel_break_bg")then
        local subpos=cc.pSub(touch:getLocation(),self.preLocaltion)
        self.preLocaltion= touch:getLocation()
        local pos=cc.p(self:getNode("move_container"):getPosition())
        pos= cc.pAdd(pos,subpos)
        self:getNode("move_container"):setPositionX(pos.x)

        self:checkMove()
    end

end

function RichmanPanel:checkMove()
    if(self:getNode("move_container"):getPositionX()>self:getNode("move_container").oldX)then
        self:getNode("move_container"):setPositionX(self:getNode("move_container").oldX)
    end
    if(self:getNode("move_container"):getPositionX()<self:getNode("move_container").oldX-MOVE_WIDTH)then
        self:getNode("move_container"):setPositionX(self:getNode("move_container").oldX-MOVE_WIDTH)
    end
end

function RichmanPanel:checkRoleCenter()
    local oldX= self:getNode("move_container"):getPositionX()
    local targetPos= self.role:convertToWorldSpaceAR(cc.p(0,0))
    local size=cc.Director:getInstance():getWinSize()
    local subX=targetPos.x-size.width/2
    self:getNode("move_container"):setPositionX(oldX-subX)
    self:checkMove()
    local targetX= self:getNode("move_container"):getPositionX()
    self:getNode("move_container"):setPositionX(oldX)

    self:getNode("move_container"):stopAllActions()
    self:getNode("move_container"):runAction(
        cc.MoveTo:create(
            0.5,
            cc.p(targetX, self:getNode("move_container"):getPositionY())
        )
    )

end

function RichmanPanel:onBuy()
    Data.vip.richman.setUsedTimes(gRichman.buynum);
    local callback = function(num)
        Net.sendRichmanBuyAction(num)
    end
    Data.canBuyTimes(VIP_RICHMAN,true,callback);
end

function RichmanPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_reward"then
        Net.sendRichmanRewardInfo()

    elseif string.find( target.touchName,"block")then
        self:initParam(gRichman.score,gRichman.rank,gRichman.actionnum,gRichman.lucknum-1)
        self:resetLuck()
        Net.sendRichmanAction(target.count)

    elseif target.touchName =="btn_rule"then
        gShowRulePanel(SYS_RICHMAN);

    elseif  target.touchName=="btn_roll"then
        if(self.isMoving==true)then
            return
        end
        self:resetLuck()
        if(gRichman.actionnum<=0)then
            local callback = function()
                self:onBuy()
            end
            gConfirmCancel(gGetWords("richman.plist","error1"),callback);
            return
        end
        Net.sendRichmanAction(0)
    elseif  target.touchName=="btn_rank"then
        Net.sendRichmanRank()

    elseif  target.touchName=="btn_buy"then
        self:onBuy()

    elseif  target.touchName=="btn_auto"then
        self:setAuto(not self.isAuto)

    elseif  target.touchName=="btn_luck"then
        if(self.isAuto==true or self.isMoving==true)then
            return
        end
        if(self.isLucking==true)then
            self:resetLuck()
        else
            if(gRichman.lucknum<=0)then
                gShowNotice(gGetWords("richman.plist","error2"));
                return
            end
            self:setLuck()
        end
    end

end


return RichmanPanel