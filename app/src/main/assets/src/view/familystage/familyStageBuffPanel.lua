local FamilyStageBuffPanel=class("FamilyStageBuffPanel",UILayer)
local FAMILY_STAGE_SET_MAJOR = 1
local FAMILY_STAGE_SET_MINOR = 2
function FamilyStageBuffPanel:ctor(idx, data)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self.isMainLayerGoldShow = false
    self:init("ui/ui_family_stage_buff.map")
    self.selectMajor = data.buff1
    self.selectMinor = data.buff2
    self.panelType = idx
    self:initBuffChoose()
end

function FamilyStageBuffPanel:initBuffChoose()
    if self.panelType == FAMILY_STAGE_SET_MAJOR then
        if self.selectMinor ~= 0 then
            self:getNode("txt_buff_type"..self.selectMinor):setVisible(true)
            self:setLabelString("txt_buff_type"..self.selectMinor, gGetWords("familyWords.plist","txt_minor_buff"))
            self:getNode("icon_choosed"..self.selectMinor):setVisible(true)
        end

        local selectIdx = 0
        if self.selectMajor ~= 0 then
            selectIdx = self.selectMajor
            self:selectBuffInit(self.selectMajor)
        else
            selectIdx = self.selectMinor + 1
            if selectIdx > 5 then
                selectIdx = 1
            end
            self.selectMajo = selectIdx
            self:selectBuffInit(selectIdx)
        end
        self:setLabelString("txt_buff_set", gGetMapWords("ui_family_stage_buff.plist","4"))
        self.onAppearedCallback = function()
            self:adjustChoosePos(selectIdx)
        end
        self.selectType = FAMILY_STAGE_SET_MAJOR
        self.selectIdx = selectIdx
        self:refreshBuffInfo(self.selectIdx)
    else
        if self.selectMajor ~= 0 then
            self:getNode("txt_buff_type"..self.selectMajor):setVisible(true)
            self:setLabelString("txt_buff_type"..self.selectMajor, gGetWords("ui_family_stage_buff.plist","5"))
            self:getNode("icon_choosed"..self.selectMajor):setVisible(true)
        end

        local selectIdx = 0
        if self.selectMinor ~= 0 then
            selectIdx = self.selectMinor
            self:selectBuffInit(self.selectMinor)
        else
            selectIdx = self.selectMajor + 1
            if selectIdx > 5 then
                selectIdx = 1
            end
            self.selectMinor = selectIdx
            self:selectBuffInit(selectIdx)
        end
        self:setLabelString("txt_buff_set", gGetWords("btnWords.plist","btn_set_minor_buff"))

        self.onAppearedCallback = function()
            self:adjustChoosePos(selectIdx)
        end
        self.selectType = FAMILY_STAGE_SET_MINOR
        self.selectIdx = selectIdx
        self:refreshBuffInfo(self.selectIdx)
    end
end

function FamilyStageBuffPanel:selectBuffInit(selectIdx)
    local txtBuffType = gGetMapWords("ui_family_stage_buff.plist","5")
    if self.panelType == FAMILY_STAGE_SET_MINOR then
        txtBuffType = gGetWords("familyWords.plist","txt_minor_buff")
    end
    for i = 1, 5 do
        if selectIdx == i then
            self:setLabelString("txt_buff_type"..i,txtBuffType)
            self:getNode("txt_buff_type"..i):setVisible(true)
        else
            if self.panelType == FAMILY_STAGE_SET_MAJOR then
                if self.selectMinor ~= i then
                    self:getNode("txt_buff_type"..i):setVisible(false) 
                end
            else
                if self.selectMajor ~= i then
                    self:getNode("txt_buff_type"..i):setVisible(false) 
                end
            end
        end
    end   
end


function FamilyStageBuffPanel:onTouchEnded(target, touch, event)
    if target.touchName == "btn_close" then
        -- gDispatchEvt(EVENT_ID_FAMILY_STAGE_SEL_COUNTRY_BUFF, {self.selectMajor, self.selectMinor})
        self:onClose()
    elseif string.find(target.touchName, "icon_buff") ~= nil then
        local idx = toint(string.sub(target.touchName, string.len("icon_buff") + 1))
        if self.panelType == FAMILY_STAGE_SET_MAJOR then
            if self.selectMinor == idx then
                gShowNotice(gGetWords("noticeWords.plist","not_sel_same_buff"))
                return
            end
        else
            if self.selectMajor == idx then
                gShowNotice(gGetWords("noticeWords.plist","not_sel_same_buff"))
                return
            end
        end

        self:selectBuff(idx)
    elseif target.touchName == "btn_buff_set" then
        if self.panelType == FAMILY_STAGE_SET_MAJOR then
            self.selectMajor = self.selectIdx
            -- if self.selectMinor == 0 then
            --     self.selectType = FAMILY_STAGE_SET_MINOR
            --     self:getNode("icon_choosed"..self.selectIdx):setVisible(true)
            --     local selectIdx = self.selectIdx + 1
            --     if selectIdx > 5 then
            --         selectIdx = 1
            --     end
            --     self:selectBuff(selectIdx)
            --     self:setLabelString("txt_buff_set", gGetWords("btnWords.plist","btn_set_minor_buff"))
            -- else
            gDispatchEvt(EVENT_ID_FAMILY_STAGE_SEL_COUNTRY_BUFF, {self.selectMajor, self.selectMinor})
            self:onClose()
            -- end
        else
            self.selectMinor = self.selectIdx
            -- if self.selectMajor == 0 then
            --     self.selectType = FAMILY_STAGE_SET_MAJOR
            --     self:getNode("icon_choosed"..self.selectIdx):setVisible(true)
            --     local selectIdx = self.selectIdx + 1
            --     if selectIdx > 5 then
            --         selectIdx = 1
            --     end
            --     self:selectBuff(selectIdx)
            --     self:setLabelString("txt_buff_set", gGetMapWords("ui_family_stage_buff.plist","4"))
            -- else
            gDispatchEvt(EVENT_ID_FAMILY_STAGE_SEL_COUNTRY_BUFF, {self.selectMajor, self.selectMinor})
                self:onClose()
            -- end
        end
    end
end

function FamilyStageBuffPanel:events()
    return {
        
    }
end

function FamilyStageBuffPanel:dealEvent(event, param)

end

function FamilyStageBuffPanel:refreshBuffInfo(selIdx)
    -- 气血、物攻、物防、魔防
    local basicBuffSelIdx = 0
    local extraBuffSelIdx = 0

    if gFamilyStageInfo.baseAttr ~= nil and #gFamilyStageInfo.baseAttr > 0 then
        local attrName = ""
        local attrVale = ""
        local basicAttrInfo = "" 
        local buffLvInfo = DB.getFamilyStageBuffLvInfo(1)

        if self.selectType == FAMILY_STAGE_SET_MAJOR then
            if self.selectMajor ~= 0 then
                basicBuffSelIdx = self.selectMajor
            else
                basicBuffSelIdx = selIdx
            end 
        else
            if self.selectMajor == 0 then
                basicBuffSelIdx = 0
            else
                basicBuffSelIdx = self.selectMajor
            end
        end

        if basicBuffSelIdx ~= 0 then
            for i,value in ipairs(gFamilyStageInfo.baseAttr) do
                if i ~= 1 then
                    basicAttrInfo = basicAttrInfo .. "、"
                end
                if i == 1 then
                    attrName = gGetWords("cardAttrWords.plist", "attr1")
                elseif i == 2 then
                    attrName = gGetWords("cardAttrWords.plist", "attr3")
                elseif i == 3 then
                    attrName = gGetWords("cardAttrWords.plist", "attr5")
                elseif i == 4 then
                    attrName = gGetWords("cardAttrWords.plist", "attr6")
                end
                self:setLabelString("txt_buff"..i,  string.format("%s+%d",attrName, value * buffLvInfo.percent / 100))
            end

            local buffInfo = DB.getBuffById(DB.getFamilyStageCountryBuff(basicBuffSelIdx))
            if buffInfo ~= nil then
                self:setLabelString("txt_buff5",  string.format("%s%s",gGetWords("cardAttrWords.plist","country_"..basicBuffSelIdx), buffInfo.des))
            end
        else
            self:getNode("txt_buff1"):setVisible(false)
            self:getNode("txt_buff2"):setVisible(false)
            self:getNode("txt_buff3"):setVisible(false)
            self:getNode("txt_buff4"):setVisible(false)
            self:getNode("txt_buff5"):setVisible(false)
        end

        if self.selectType == FAMILY_STAGE_SET_MAJOR then
            if self.selectMinor ~= 0 then
                extraBuffSelIdx = self.selectMinor
            end 
        else
            extraBuffSelIdx = selIdx
        end

        if extraBuffSelIdx ~= 0 then
            buffInfo = DB.getBuffById(DB.getFamilyStageCountryBuff(extraBuffSelIdx))
            local buffAttr2 = string.format("%s%s",gGetWords("cardAttrWords.plist","country_"..extraBuffSelIdx), buffInfo.des)
            self:setLabelString("txt_buff6", buffAttr2)
            self:getNode("txt_buff6"):setVisible(true)
        else
            self:getNode("txt_buff6"):setVisible(false)
        end

        self:getNode("layout_buff_effect"):layout()
    end



    local buffRew = gFamilyStageInfo.buff.rewards
    if buffRew == nil or #buffRew == 0 then
        return
    end

    local rewardIdx = 1
    if basicBuffSelIdx ~= 0 then
        for _,rewItem in ipairs(buffRew) do
            if rewItem.country == basicBuffSelIdx then
                Icon.setIcon(rewItem.id, self:getNode("reward"..rewardIdx), DB.getItemQuality(rewItem.id))
                local num = rewItem.num
                self:setLabelString("txt_reward"..rewardIdx, num)
                if(DB.getSoulNeedLight(rewItem.id))then
                    self:getNode("reward"..rewardIdx):removeChildByTag(100)
                    loadFlaXml("ui_kuang_texiao")
                    Icon.addSpeEffectForSoul(self:getNode("reward"..rewardIdx))
                end
                self:getNode("reward"..rewardIdx):setVisible(true)
                rewardIdx = rewardIdx + 1
            end
        end
    end

    for _,rewItem in ipairs(buffRew) do
        if rewItem.country == extraBuffSelIdx then
            Icon.setIcon(rewItem.id, self:getNode("reward"..rewardIdx), DB.getItemQuality(rewItem.id))
            local num = math.round(rewItem.num / 2) 
            self:setLabelString("txt_reward"..rewardIdx, num)
            if(DB.getSoulNeedLight(rewItem.id))then
                self:getNode("reward"..rewardIdx):removeChildByTag(100)
                loadFlaXml("ui_kuang_texiao")
                Icon.addSpeEffectForSoul(self:getNode("reward"..rewardIdx))
            end
            self:getNode("reward"..rewardIdx):setVisible(true)
            rewardIdx = rewardIdx + 1
        end
    end

    for i = rewardIdx, 2 do
        self:getNode("reward"..i):setVisible(false)
    end
    self:getNode("layout_extra_rewards"):layout()
end

function FamilyStageBuffPanel:selectBuff(idx)
    local txtBuffType = gGetMapWords("ui_family_stage_buff.plist","5")
    if self.selectType == FAMILY_STAGE_SET_MINOR then
        txtBuffType = gGetWords("familyWords.plist","txt_minor_buff")
        self.selectMinor = idx
    else
        self.selectMajor = idx
    end

    for i = 1, 5 do
        if idx == i then
            self:setLabelString("txt_buff_type"..i, txtBuffType)
            self:getNode("txt_buff_type"..i):setVisible(true)
        else
            if self.selectType == FAMILY_STAGE_SET_MAJOR then
                if self.selectMinor ~= i then
                    self:getNode("txt_buff_type"..i):setVisible(false) 
                end
            else
                if self.selectMajor ~= i then
                    self:getNode("txt_buff_type"..i):setVisible(false) 
                end
            end
        end
    end

    self.selectIdx = idx
    self:refreshBuffInfo(self.selectIdx)
    self:adjustChoosePos(idx)
end

function FamilyStageBuffPanel:refrehBtnInfo()
    if self.selectMajor == 0 then
        self:setLabelString("txt_buff_set", gGetMapWords("ui_family_stage_buff.plist","4"))
    elseif self.selectMinor == 0 then
        self:getNode("icon_choosed"..self.selectIdx):setVisible(true)
        local selectIdx = self.selectIdx + 1
        if selectIdx > 5 then
            selectIdx = 1
        end
        self:selectBuff(selectIdx)
        self:setLabelString("txt_buff_set", gGetWords("btnWords.plist","btn_set_minor_buff"))
    end
end

function FamilyStageBuffPanel:adjustChoosePos(idx)
    local countryIcon = self:getNode("buff_bg"..idx)
    local contentSize = countryIcon:getContentSize()
    local desNodePos = gGetPositionByAnchorInDesNode(self:getNode("buff_panel_bg"), countryIcon, cc.p(0.5, 0.5))
    if nil ~= countryIcon then
        self:getNode("icon_choose"):setPosition(cc.p(desNodePos.x,desNodePos.y))
    end
end

return FamilyStageBuffPanel