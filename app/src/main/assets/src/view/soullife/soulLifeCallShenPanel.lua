local SoulLifeCallShenPanel=class("SoulLifeCallShenPanel",UILayer)

function SoulLifeCallShenPanel:ctor()
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_soullife_call_shen.map")
    self:initPanel()
end

function SoulLifeCallShenPanel:initPanel()
    local callShenItemNum = Data.getItemNum(ITEM_SPIRIT_CALL)
    self:getNode("txt_own"):setString(tostring(callShenItemNum))

    local maxSpiritCount = DB.getMaxSpiritCount()
    local callDia        = DB.getSpiritCallDia()
    if callShenItemNum > 0 then
        self:getNode("icon_item_one"):setVisible(true)
        self:getNode("icon_dia_one"):setVisible(false)
        self:getNode("txt_one"):setString("1")
    else
        self:getNode("icon_item_one"):setVisible(false)
        self:getNode("icon_dia_one"):setVisible(true)
        self:getNode("txt_one"):setString(tostring(callDia))
    end

    if callShenItemNum >= maxSpiritCount or isBanshuReview() then
        self:getNode("icon_item_ten"):setVisible(true)
        self:getNode("icon_dia_ten"):setVisible(false)
        self:getNode("txt_ten"):setString(tostring(maxSpiritCount))
    else
        self:getNode("icon_item_ten"):setVisible(false)
        self:getNode("icon_dia_ten"):setVisible(true)
        self:getNode("txt_ten"):setString(tostring(maxSpiritCount * callDia))
    end

    self:initRoleShow()
end

function SoulLifeCallShenPanel:onTouchEnded(target,touch, event)
    local callShenItemNum = Data.getItemNum(ITEM_SPIRIT_CALL)
    local maxSpiritCount = DB.getMaxSpiritCount()
    local callDia        = DB.getSpiritCallDia()
    
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName=="btn_one" then
        self:onClose()
        Net.sendSpiritCall()
        if (TDGAItem) then
            if (callShenItemNum == 0) then
                gLogPurchase("spirit_call_shen_one",1,callDia)
            end
        end
    elseif target.touchName=="btn_ten" then
        if isBanshuReview() then
            if callShenItemNum < maxSpiritCount then
                gShowNotice(gGetWords("noticeWords.plist","no_sprite_call"))
                return
            end
        end
        self:onClose()
        Net.sendSpiritCallMore()
        if (TDGAItem) then
            if (callShenItemNum < maxSpiritCount) then
                gLogPurchase("spirit_call_shen_ten",1,maxSpiritCount * callDia)
            end
        end
    end
end

function SoulLifeCallShenPanel:initRoleShow()
    local shenRole = self:getNode("role_shen")
    local aniName = string.format("xian_npc%d_%d", SPIRIT_TYPE.GUI + 1, 2)
    local shenFla = gCreateFla(aniName, 1)
    shenFla:replaceBone({"shell"},string.format("images/ui_soullife/xian_npc%d_1.png", SPIRIT_TYPE.SHEN + 1))
    shenFla:replaceBone({"head"},string.format("images/ui_soullife/xian_npc%d_2.png", SPIRIT_TYPE.SHEN + 1))
    shenFla:replaceBone({"foot_3"},string.format("images/ui_soullife/xian_npc%d_3.png", SPIRIT_TYPE.SHEN + 1))
    shenFla:replaceBone({"foot_30"},string.format("images/ui_soullife/xian_npc%d_3.png", SPIRIT_TYPE.SHEN + 1))
    shenFla:replaceBone({"foot_31"},string.format("images/ui_soullife/xian_npc%d_3.png", SPIRIT_TYPE.SHEN + 1))
    gAddChildInCenterPos(shenRole, shenFla)

    local tianRole = self:getNode("role_tian")
    aniName = string.format("xian_npc%d_%d", SPIRIT_TYPE.TIAN + 1, 2)
    local tianFla = gCreateFla(aniName, 1)
    tianFla:setRotation3D(cc.vec3(0,-180,0))
    gAddChildInCenterPos(tianRole, tianFla)

end

return SoulLifeCallShenPanel