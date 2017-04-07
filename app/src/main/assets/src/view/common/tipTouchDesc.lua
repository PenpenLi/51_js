TIP_TOUCH_DESC_FAMILY_BUFF = 1
TIP_TOUCH_DESC_FAMILY_STAGE_REWARDS = 2
TIP_TOUCH_DESC_CONSTELLATION_ACHIEVE = 3

local TipTouchDesc=class("TipTouchDesc",UILayer)

function TipTouchDesc:ctor(data,param2)
    self:init("ui/tip_touch_desc.map")

    if param2 == nil then
        self:setLabelString("txt_info",data)
        local size=self:getNode("txt_info"):getContentSize()
        size.width= self:getNode("tip_bg"):getContentSize().width
        size.height=size.height+30
        size.height = math.max(size.height,90);
        self:getNode("tip_bg"):setContentSize(size) 
    elseif type(param2) == "table" then
        if param2.type == TIP_TOUCH_DESC_FAMILY_BUFF then
            self:showFamilyBuff(param2.data)
        elseif param2.type == TIP_TOUCH_DESC_FAMILY_STAGE_REWARDS then
            self:showFamilyStageRewards(param2.data)
        elseif param2.type == TIP_TOUCH_DESC_CONSTELLATION_ACHIEVE then
            self:showConstellationAchieve(param2.data)
        end
    end
end

function TipTouchDesc:showFamilyBuff(data)
    self:getNode("txt_info"):setVisible(false)
    local countryType = gFamilyStageInfo.buff.major
    if data == 2 then
        countryType = gFamilyStageInfo.buff.minor
    end

    local buffRew = gFamilyStageInfo.buff.rewards
    if buffRew == nil or #buffRew == 0 then
        return
    end


    for _,rewItem in ipairs(buffRew) do
        if rewItem.country == countryType then
            Icon.setIcon(rewItem.id, self:getNode("icon_family_stage_buff"), DB.getItemQuality(rewItem.id))
            if(DB.getSoulNeedLight(rewItem.id))then
                self:getNode("icon_family_stage_buff"):removeChildByTag(100)
                loadFlaXml("ui_kuang_texiao")
                Icon.addSpeEffectForSoul(self:getNode("icon_family_stage_buff"))
            end
            local num = rewItem.num
            if data == 2 then
                num = math.round(num / 2)
            end
            self:setLabelString("txt_family_stage_buff_num", num)
            self:getNode("txt_family_stage_buff_num"):setVisible(true)
            break
        end
    end
    self:getNode("layer_family_stage_buff"):setVisible(true)
end

function TipTouchDesc:showFamilyStageRewards(data)
    self:getNode("txt_info"):setVisible(false)
    local rewards = DB.getFamilyStageRewardsById(data)
    if #rewards == 0 then
        return
    end

    for i,rewardItem in ipairs(rewards) do
        Icon.setIcon(rewardItem.id, self:getNode("icon_family_stage_reward"..i), DB.getItemQuality(rewardItem.id))
        if(ITEM_SUPER_FRA_SHOW == rewardItem.id)then
            self:getNode("icon_family_stage_reward"..i):removeChildByTag(100)
            loadFlaXml("ui_kuang_texiao")
            Icon.addSpeEffectForSoul(self:getNode("icon_family_stage_reward"..i))
        end
        self:setLabelString("txt_family_stage_reward"..i, rewardItem.name)
    end

    self:getNode("layout_family_stage_rewards"):layout()
    self:getNode("layout_family_stage_rewards"):setVisible(true)

    local size=self:getNode("layer_family_stage_rewards"):getContentSize()
    size.width= size.width + 10
    size.height=size.height + 30
    self:getNode("tip_bg"):setContentSize(size)
    self:getNode("tip_bg"):setPosition(self:getNode("layer_family_stage_rewards"):getPosition())
    self:getNode("layer_family_stage_rewards"):setVisible(true)
end

function TipTouchDesc:showConstellationAchieve(data)
    self:getNode("txt_info"):setVisible(false)
    local achieveInfo = DB.getConstellationAchieveInfo(data)
    local attrTitle = gGetWords("cardAttrWords.plist", "attr" .. achieveInfo.attr1)..":"
    if CardPro.isFloatAttr(achieveInfo.attr1) then
        formatValue = string.format("+%0.1f%%", achieveInfo.param1)
    else
        formatValue = string.format("+%d", achieveInfo.param1)
    end
    self:setLabelString("txt_attr", attrTitle)
    self:setLabelString("txt_value", formatValue)
    self:getNode("layout_constellation"):layout()

    local size=self:getNode("layer_constellation_achieve"):getContentSize()
    size.width= size.width + 10
    size.height=size.height + 30
    self:getNode("tip_bg"):setContentSize(size)
    self:getNode("tip_bg"):setPosition(self:getNode("layer_constellation_achieve"):getPosition())
    self:getNode("layer_constellation_achieve"):setVisible(true)
end
 
return TipTouchDesc