local AtlasCrusadeFinalPanel=class("AtlasCrusadeFinalPanel",UILayer)

function AtlasCrusadeFinalPanel:ctor(hp,dnum)
    self:init("ui/battle_resule_shilian.map")
    self.isBlackBgVisible=false
    self:getNode("panel_gold_double"):setVisible(false)
    self:getNode("panel_vip_get"):setVisible(false)
    self:getNode("txt_gold_reward"):setVisible(false)
    self:getNode("icon_gold_reward"):setVisible(false)

    self:setLabelString("txt_user_lv",getLvReviewName("Lv")..gUserInfo.level)
    
    local expData= DB.getUserExpByLevel(gUserInfo.level)
    self:setBarPer("bar_user_exp",gUserInfo.exp/expData.exp)
    self:getNode("panel_exp_reward"):setVisible(true)
    local txtInfo = gGetWords("labelWords.plist","lab_actatlas_hurt_title")
    self:setLabelString("txt_hurt_title", txtInfo)
    self:setLabelString("txt_hurt_value", gCrusadeData.reward.damage)

    txtInfo = gGetWords("labelWords.plist","lab_actatlas_item_reward_title")
    self:setLabelString("txt_rewards_title", txtInfo)

    self:getNode("icon_exp_reward1"):setVisible(false)
    self:getNode("icon_exp_reward4"):setVisible(false)

    self:getNode("icon_exp_reward2"):addChild(self:createDropItem(OPEN_BOX_FEAT,gCrusadeData.reward.feats))
    self:getNode("icon_exp_reward3"):addChild(self:createDropItem(OPEN_BOX_EXPLOIT,gCrusadeData.reward.exploits))

    if 1 == Battle.win then
        self:normalDisplay()
        gPlayEffect("sound/bg/bgm_Win.mp3")
    else
        self:roundFinishDisplay()
        gPlayEffect("sound/bg/bgm_Lose.mp3")
    end
    AudioEngine.setMusicVolume(0.4)
end


function AtlasCrusadeFinalPanel:roundFinishDisplay()
    loadFlaXml("ui_huihejieshu")
    self:getNode("panel_final"):setVisible(false)
    local huihejieshu_a = FlashAni.new()
    local durTime_a = huihejieshu_a:playAction("ui_huihejieshu_a", nil ,nil, 0)
    self:getNode("panel_huihe_finish"):addChild(huihejieshu_a)
    local huihejieshu_b_refer = FlashAni.new()
    local durTime_refer = huihejieshu_b_refer:playAction("ui_huihejieshu_b", nil ,nil, 0)
    local durTime_b     = 0
    local showPanel = false
    gCallFuncDelay(durTime_a, self, function ()
        if nil ~= huihejieshu_a then
            huihejieshu_a:removeFromParent()
        end

        local huihejieshu_b = FlashAni.new()
        huihejieshu_b:playAction("ui_huihejieshu_b", function()
            durTime_b = durTime_b + durTime_refer
            if (durTime_b > 20 * durTime_refer)  and (not showPanel) then
                showPanel = true
                self:normalDisplay()
            end
        end, nil, 1)
        self:getNode("panel_huihe_finish"):addChild(huihejieshu_b)
    end)
end

function AtlasCrusadeFinalPanel:createDropItem(itemid,num)
    local node = DropItem.new()
    node:setData(itemid)
    node:setNum(num)
    node:setPositionY(node:getContentSize().height)
    return node
end


function AtlasCrusadeFinalPanel:onTouchEnded(target)

    if target.touchName=="btn_get" or target.touchName == "btn_vip_get" then

        Scene.enterMainScene()
    elseif target.touchName=="btn_data" then
        Panel.popUp(PANEL_BATTLE_DATA)

    end

end

function AtlasCrusadeFinalPanel:normalDisplay()
    local blackBg=FlashAni.new()
    local size=self:getContentSize()
    blackBg:playAction("ui_common_cover_purple")
    blackBg:setAnchorPoint(cc.p(0.5, 0.5))
    blackBg:setPosition(cc.p(size.width/2, -size.height/2))
    self:addChild(blackBg, -1)

    self:getNode("panel_final"):setVisible(true)
    self:setNodeAppear("panel_final")
end

return AtlasCrusadeFinalPanel