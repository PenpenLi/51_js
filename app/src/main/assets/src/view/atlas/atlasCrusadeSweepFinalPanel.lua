local AtlasCrusadeSweepFinalPanel=class("AtlasCrusadeSweepFinalPanel",UILayer)

function AtlasCrusadeSweepFinalPanel:ctor(data)
    self:init("ui/battle_resule_shilian_2.map")

    self:setLabelString("txt_user_lv",getLvReviewName("Lv")..gUserInfo.level)
    local expData= DB.getUserExpByLevel(gUserInfo.level)
    self:setBarPer("bar_user_exp",gUserInfo.exp/expData.exp)
    

    local dnum =0-- data.dNum
    local index = 1
    for k,reward in pairs(data.rewardlist) do
        local node=AtlasCrusadeSweepItem.new() 
        node:setData(reward,dnum,self)
        node:setNum(index)
        index = index +1 
        --node.selectCallBack = selectCallBack
        self:getNode("scroll"):addItem(node)
    end
    self:setLabelString("txt_user_exp","+"..data.exp)
    self:getNode("scroll"):layout()
    self.showRewardTime=0.9
    self.isProcessShowLevUp=false
    self:normalDisplay()
end

function  AtlasCrusadeSweepFinalPanel:events()
    return {EVENT_ID_ACT_FINAL_SWEEP_DOUBLE}
end

function AtlasCrusadeSweepFinalPanel:dealEvent(event,param)
    if(event==EVENT_ID_ACT_FINAL_SWEEP_DOUBLE)then
        for k,item in pairs(self:getNode("scroll").items) do
            item:dealEvent(event,param)
        end
    end
end


function AtlasCrusadeSweepFinalPanel:showItemReward()
    local  idtype = OPEN_BOX_GOLD
    local  rewardGold = 0
    for k,item in pairs(self:getNode("scroll").items) do
        if item.curData.battleType == BATTLE_TYPE_ATLAS_GOLD then
            rewardGold = rewardGold+ math.floor(item.curData.gold * item.double)
            idtype = OPEN_BOX_GOLD
        elseif item.curData.battleType == BATTLE_TYPE_ATLAS_ITEMAWAKE then
            rewardGold = rewardGold+  math.floor(item.curData.itemAwake * item.double)
            idtype = OPEN_BOX_ITEMAWAKE
        elseif item.curData.battleType == BATTLE_TYPE_ATLAS_EXP then
            rewardGold = rewardGold+  math.floor(item.curData.cardExpItem * item.double)
            idtype = OPEN_BOX_CARDEXP_ITEM
        elseif item.curData.battleType == BATTLE_TYPE_ATLAS_PET then
            rewardGold = rewardGold+ math.floor(item.curData.soulItem * item.double)
            idtype = OPEN_BOX_PET_SOUL
        elseif item.curData.battleType == BATTLE_TYPE_ATLAS_EQUSOUL then
            rewardGold = rewardGold + math.floor(item.curData.equSoul * item.double)
            idtype = OPEN_BOX_EQUIP_SOUL
        end
    end
    gShowItemPoolLayer:pushOneItem({id = idtype,num = rewardGold})
   
end

function AtlasCrusadeSweepFinalPanel:processShowLevUp()
    if Scene.needLevelup then
        local delay   = cc.DelayTime:create(self.showRewardTime)
        self:getNode("ctr_show_levup"):runAction(cc.Sequence:create(delay, cc.CallFunc:create(function()
            if not self.isProcessShowLevUp then
                Scene.showLevelUp = true
            end
        end))) 
    end 
end

function AtlasCrusadeSweepFinalPanel:normalDisplay()
    local blackBg=FlashAni.new()
    local size=self:getContentSize()
    blackBg:playAction("ui_common_cover_purple")
    blackBg:setAnchorPoint(cc.p(0.5, 0.5))
    blackBg:setPosition(cc.p(size.width/2, -size.height/2))
    self:addChild(blackBg, -1)
    self:processShowLevUp()

end

function AtlasCrusadeSweepFinalPanel:onTouchEnded(target)

    if target.touchName=="btn_get" or target.touchName == "btn_vip_get" then
        if (not self.isProcessShowLevUp) and Scene.needLevelup  then
            self.isProcessShowLevUp = true
            self:getNode("ctr_show_levup"):runAction(cc.CallFunc:create(function()
                Scene.showLevelUp = true
            end))
            return
        end
        self:showItemReward()
        Panel.popBack(self:getTag())
    end

end


return AtlasCrusadeSweepFinalPanel