local AtlasWorldBossFinalPanel=class("AtlasWorldBossFinalPanel",UILayer)

function AtlasWorldBossFinalPanel:ctor(data)
    self:init("ui/ui_shijieboss_jiesuan.map")
    self.isBlackBgVisible=false

    if not data or not data.sweep then
        self.sweep = false
    else
        self.sweep = data.sweep
    end
    
    for i=1,4 do
        self:getNode("layer_"..i):setVisible(false)
    end
    local status = 1
    if (Data.worldBossInfo.mykill) then
        status = 2
    -- else --0:未开始 1:进行中 2:已击杀
    --     if (Data.worldBossInfo.status==1) then
    --         status = 1
    --     elseif (Data.worldBossInfo.status==2) then
    --         status = 3
    --     end
    end
    -- print("status==="..status)
    self:getNode("layer_"..status):setVisible(true)
    
    self:setLabelString("txt_gold_reward_"..status, Data.worldBossInfo.goldReword) 
    self:setLabelString("txt_hurt_value_"..status, Data.worldBossInfo.mydamage)--伤害
    
    if self.sweep == true then
        Battle.win = 1
        self:getNode("btn_data"):setVisible(false)
    end

    if 1 == Battle.win then
        self:normalDisplay()
        gPlayEffect("sound/bg/bgm_Win.mp3")
    else
        self:roundFinishDisplay()
        gPlayEffect("sound/bg/bgm_Lose.mp3")
    end
    AudioEngine.setMusicVolume(0.4)
end


function AtlasWorldBossFinalPanel:roundFinishDisplay()
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

-- function AtlasWorldBossFinalPanel:createDropItem(itemid,num)
--     local node = DropItem.new()
--     node:setData(itemid)
--     node:setNum(num)
--     node:setPositionY(node:getContentSize().height)
--     return node
-- end


function AtlasWorldBossFinalPanel:onTouchEnded(target)

    if target.touchName=="btn_get" or target.touchName == "btn_vip_get" then
        
        function endReturn()
            if self.sweep == true then
                Panel.popBack(self:getTag())
            else
                Scene.enterMainScene()
            end
        end

        if Data.worldBossInfo.lkreward then
            Panel.popUp(PANEL_ATLAS_FINAL_REWARD,endReturn)
        else
            endReturn()
        end


    elseif target.touchName=="btn_data" then
        Panel.popUp(PANEL_BATTLE_DATA)
    end

end

function AtlasWorldBossFinalPanel:normalDisplay()
    local blackBg=FlashAni.new()
    local size=self:getContentSize()
    blackBg:playAction("ui_common_cover_purple")
    blackBg:setAnchorPoint(cc.p(0.5, 0.5))
    blackBg:setPosition(cc.p(size.width/2, -size.height/2))
    self:addChild(blackBg, -1)

    self:getNode("panel_final"):setVisible(true)
    self:setNodeAppear("panel_final")
end

return AtlasWorldBossFinalPanel