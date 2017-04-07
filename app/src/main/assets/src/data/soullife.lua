
Spirit = 
{
   -- 数据ID 
   iID = 0,
   --元神类型（0鬼仙 1人仙 2地仙 3神仙 4天仙 5碎片 6金币）
   iType = 0,
   --属性（和卡牌属性一致）
   iAttr = 0,
   --等级
   iLV = 1,
   --经验
   iExp = 0,
   --卡牌上的位置
   iPos = 0,
   --金钱数值
   iValue = 0,
   --本次寻仙类型
   iFType = 0,
}

SpiritInfo = {}
--当前寻仙类型
SpiritInfo.iType = 0
--元神碎片数量（大于0才下发）
SpiritInfo.iFra  = 0
--背包元神列表
SpiritInfo.vBagSpiritList = {}
--寻仙、召唤获得的元神、碎片列表
SpiritInfo.vFindSpiritList = {}
--是否自动选择命魂升级的种类,鬼仙,人仙，地仙，神仙
SpiritInfo.autoChooseFlag = {false, false, false, false}
--装备元神列表
SpiritInfo.vSpiritList = {}
--当前要装备元神的位置
SpiritInfo.curEquSpiritPos = 0
--选中升级的元神ID数组
SpiritInfo.chooseIds  = {}
--当前升级的元神ID
SpiritInfo.upgradeSpiritID = 0
--经验池的值
SpiritInfo.exp = 0
--暴力寻仙花费设置
SpiritInfo.quickCostGold = 0
--装备更换时，是否要显示已装备物品
SpiritInfo.hideEuqiped = true
--每日购买命魂道具次数
SpiritInfo.spiritItemBuyNumsOfDay = 0
--命魂位置开启
SpiritInfo.opens = {}

function SpiritInfo.init()
    SpiritInfo.iType = 0
    SpiritInfo.iFra  = 0
    SpiritInfo.vBagSpiritList = {}
    SpiritInfo.vFindSpiritList = {}
    SpiritInfo.autoChooseFlag = {false, false, false, false}
    SpiritInfo.vSpiritList = {}
    SpiritInfo.curEquSpiritPos = 0
    SpiritInfo.chooseIds  = {}
    SpiritInfo.upgradeSpiritID = 0
    SpiritInfo.exp = 0
    SpiritInfo.quickCostGold = 0
    SpiritInfo.hideEuqiped = true
    SpiritInfo.spiritItemBuyNumsOfDay = 0
    SpiritInfo.opens = {}
end

function SpiritInfo.setiType(itype)
    SpiritInfo.iType = itype
end

function SpiritInfo.getiType()
    return SpiritInfo.iType
end

function SpiritInfo.clearBagSpiritList()
    SpiritInfo.vBagSpiritList = {}
end

function SpiritInfo.clearFindSpiritList()
    SpiritInfo.vFindSpiritList = {}
end

function SpiritInfo.addFindSpiritItem(spiritItem)
    SpiritInfo.vFindSpiritList[#SpiritInfo.vFindSpiritList + 1] = spiritItem
end

function SpiritInfo.addBagSpiritItem(spiritItem)
    SpiritInfo.vBagSpiritList[#SpiritInfo.vBagSpiritList + 1] = spiritItem
end

function SpiritInfo.getBagSpiritIdxByID(ID)
    for i = 1, #SpiritInfo.vBagSpiritList do
        local spirit = SpiritInfo.vBagSpiritList[i]
        if nil ~= spirit and spirit.iID == ID then
            return i
        end
    end
    return -1
end

function SpiritInfo.getBagSpiritById(ID)
    for i = 1, #SpiritInfo.vBagSpiritList do
        local spirit = SpiritInfo.vBagSpiritList[i]
        if nil ~= spirit and spirit.iID == ID then
            return spirit
        end
    end
    return nil
end

function SpiritInfo.getBagSpiritByIdx(idx)
    return SpiritInfo.vBagSpiritList[idx]
end

function SpiritInfo.getBagSpiritSize()
    return #SpiritInfo.vBagSpiritList
end

function SpiritInfo.removeBagSpiritByIdx(idx)
    table.remove(SpiritInfo.vBagSpiritList, idx)
end

function SpiritInfo.removeBagSpiritByID(ID)
    for i = 1, #SpiritInfo.vBagSpiritList do
        if SpiritInfo.vBagSpiritList[i].iID == ID then
            table.remove(SpiritInfo.vBagSpiritList, i)
            return i
        end
    end
end

function SpiritInfo.getFindSpiritSize()
    return #SpiritInfo.vFindSpiritList
end

function SpiritInfo.getFindSpiritByIdx(idx)
    return SpiritInfo.vFindSpiritList[idx]
end

function SpiritInfo.hasManySpiritInFindSpirit()
    local num = 0
    for k,spirit in pairs(SpiritInfo.vFindSpiritList) do
        if spirit.iType >= SPIRIT_TYPE.GUI and spirit.iType <= SPIRIT_TYPE.TIAN then
            num = num + 1
        end

        if num > 1 then
            return true
        end
    end

    return false
end

function SpiritInfo.addiFraOne()
    SpiritInfo.iFra = SpiritInfo.iFra + 1
end

function SpiritInfo.sortSpiritBagList()
    if #SpiritInfo.vBagSpiritList == 0 then
        return
    end

    table.sort(SpiritInfo.vBagSpiritList, function(lSpirit, rSpirit)
        if lSpirit.iType ~= rSpirit.iType then
            return lSpirit.iType > rSpirit.iType
        else
            if lSpirit.iLV ~= rSpirit.iLV then
                return lSpirit.iLV > rSpirit.iLV
            else
                return lSpirit.iAttr > rSpirit.iAttr
            end
        end
    end)
end

function SpiritInfo.getSpiritIndexWithPos(pos)
    for i = 1, #SpiritInfo.vSpiritList do
        local spirit = SpiritInfo.vSpiritList[i]
        if nil ~= spirit and spirit.iPos == pos then
            return i
        end
    end

    return -1
end

function SpiritInfo.getSpiritSize()
    return #SpiritInfo.vSpiritList
end

function SpiritInfo.getSpiritByIdx(idx)
    -- assert( idx <= #SpiritInfo.vSpiritList, "idx is off normal upper")
    return SpiritInfo.vSpiritList[idx]
end

function SpiritInfo.removeSpiritByIdx(idx)
    -- assert( idx <= #SpiritInfo.vSpiritList, "idx is off normal upper")
    table.remove(SpiritInfo.vSpiritList,idx)
end

function SpiritInfo.addSpiritItem(spiritItem)
    SpiritInfo.vSpiritList[#SpiritInfo.vSpiritList + 1] = spiritItem
end

function SpiritInfo.setSpiritItemByIdx(idx, spirit)
    if idx <= 0 or idx > #SpiritInfo.vSpiritList then
        return
    end
    
    SpiritInfo.vSpiritList[idx] = spirit
end

function SpiritInfo.getSpiritWithPos(pos)
    for i = 1, #SpiritInfo.vSpiritList do
        local spirit = SpiritInfo.vSpiritList[i]
        if nil ~= spirit and spirit.iPos == pos then
            return spirit
        end
    end

    return nil
end

function SpiritInfo.getSpiritByID(ID)
    for i = 1, #SpiritInfo.vSpiritList do
        local spirit = SpiritInfo.vSpiritList[i]
        if nil ~= spirit and spirit.iID == ID then
            return spirit
        end
    end

    return nil
end

function SpiritInfo.clearSpiritList()
    SpiritInfo.vSpiritList = {}
end

function SpiritInfo.addFra(value)
    SpiritInfo.iFra  = SpiritInfo.iFra + value
end

function SpiritInfo.setFraCount(value)
    SpiritInfo.iFra  = value
end

function SpiritInfo.getFraCount()
    return SpiritInfo.iFra 
end

function SpiritInfo.setCurEquSpiritPos(pos)
    SpiritInfo.curEquSpiritPos = pos
end

function SpiritInfo.getCurEquSpiritPos()
    return SpiritInfo.curEquSpiritPos
end

function SpiritInfo.setChooseIds(ids)
    SpiritInfo.chooseIds = ids
end

function SpiritInfo.getChooseIds()
    return SpiritInfo.chooseIds
end

function SpiritInfo.setUpgradeSpiritID(ID)
    SpiritInfo.upgradeSpiritID = ID
end

function SpiritInfo.getUpgradeSpiritID()
    return SpiritInfo.upgradeSpiritID
end

function SpiritInfo.hasEnoughFra()
    if SpiritInfo.iFra >= DB.getSpiritExchangeCount() then
        return true
    end

    return false
end

function SpiritInfo.isFindLimited(findNum)
    if SpiritInfo.getBagSpiritSize() + findNum > DB.getSpiritBagMax() then
        gShowNotice(gGetWords("spiritWord.plist", "bag_maxcount_limit"))
        return true
    end

    return false
end

function SpiritInfo.sortSpiritBagListForEqu()
    if #SpiritInfo.vBagSpiritList == 0 then
        return
    end

    local targetPos = SpiritInfo.getCurEquSpiritPos()
    table.sort(SpiritInfo.vBagSpiritList, function(lSpirit, rSpirit)

        local canBeEquedL = SpiritInfo.spiritCanBeEqued(lSpirit, targetPos)
        local canBeEquedR = SpiritInfo.spiritCanBeEqued(rSpirit, targetPos)
        if canBeEquedL ~= canBeEquedR then
            return canBeEquedL
        elseif lSpirit.iType ~= rSpirit.iType then
            return lSpirit.iLV > rSpirit.iLV
        else
            if lSpirit.iLV ~= rSpirit.iLV then
                return lSpirit.iLV > rSpirit.iLV
            else
                return lSpirit.iAttr > rSpirit.iAttr
            end
        end
    end)
end

function SpiritInfo.spiritCanBeEqued(targetSpirit, targetPos)
    for i = 1, 8 do
        local realPos = math.floor(targetPos/10) * 10 + i
        if targetPos ~= realPos then
            local spirit = SpiritInfo.getSpiritWithPos(realPos)
            if nil ~= spirit then
                local targetSpiritAttr = DB.getSpiritAttr(targetSpirit.iType, targetSpirit.iLV, targetSpirit.iAttr)
                -- print("targetSpirit value is:",targetSpirit.iType, " ", targetSpirit.iLV, " ",targetSpirit.iAttr)
                local curSpiritAttr = DB.getSpiritAttr(spirit.iType, spirit.iLV, spirit.iAttr)
                if (targetSpiritAttr.attr == curSpiritAttr.attr) or
                    (targetSpiritAttr.attr2 == curSpiritAttr.attr) or
                    (targetSpiritAttr.attr == curSpiritAttr.attr2) or
                    (curSpiritAttr.attr2 ~= 0  and targetSpiritAttr.attr2 == curSpiritAttr.attr2) then
                    return false
                end
            end
        end
    end

    return true
end

function SpiritInfo.updateSpiritExpAndLvByPool(params)
    if Net.upgradeNewInfo.id ~= nil then
        local spirit = SpiritInfo.getBagSpiritById(Net.upgradeNewInfo.id )
        if nil ~= spirit then
            spirit.iLV = params.lev
            spirit.iExp = params.curExp
        end
    elseif Net.upgradeNewInfo.pos ~= nil then
        local spirit = SpiritInfo.getSpiritWithPos(Net.upgradeNewInfo.pos)
        if nil ~= spirit then
            spirit.iLV = params.lev
            spirit.iExp = params.curExp
        end
    end
end

function SpiritInfo.checkSpiritExpFull()
    if SpiritInfo.exp >= DB.getMaxSpiritExp() then
        gShowNotice(gGetWords("spiritWord.plist", "spirit_exp_full"))
        return true
    end

    return false
end

function SpiritInfo.setHideEquiped(flag)
    SpiritInfo.hideEuqiped = flag
end

function SpiritInfo.getHideEquiped()
    return SpiritInfo.hideEuqiped
end

function SpiritInfo.setSpiritItemBuyNumsOfDay(nums)
    SpiritInfo.spiritItemBuyNumsOfDay = nums
end

function SpiritInfo.getSpiritItemBuyNumsOfDay()
    return SpiritInfo.spiritItemBuyNumsOfDay
end

function SpiritInfo.addOpenInfo(pos, isOpen)
    SpiritInfo.opens[pos] = isOpen
end

function SpiritInfo.isPosOpen(pos)
    if SpiritInfo.opens[pos] ~= nil then
        return SpiritInfo.opens[pos]
    end
    return false
end

function SpiritInfo.isAttrAddtionPos(pos)
    if pos == 7 or pos == 8 then
        return true
    end
    return false
end

function SpiritInfo.getNeedGoldForSpirit(spiritType)
    local needGold = DB.getNeedGoldForSpirit(spiritType + 1)
    if Data.activeSoullifeSaleoff.val ~= nil then
        needGold = math.floor(needGold * Data.activeSoullifeSaleoff.val / 100)
    end
    return needGold
end

--寻仙类型
SPIRIT_TYPE = 
{
    GUI = 0, --鬼仙(白)
    REN = 1, -- 人仙（绿）
    DI = 2,  --地仙（蓝）
    SHEN = 3,--神仙（紫）
    TIAN = 4,--天仙（橙）
    CHIP = 5,--碎片
    GOLD = 6,--金币
    EXP  = 7,--经验
    DOUBLE_ATTR = 8, --双属性
}

--元神操作类型
SPIRIT_OPERATE_TYPE = 
{
    OPERATE_TYPE_FIND = 0, --寻仙界面操作
    OPERATE_TYPE_SPIRIT = 1, --元神界面操作
    OPERATE_TYPE_EQU = 2, --装备界面操作
}

--命魂详细界面的类型
SOULLIFE_DETAIL_PANEL = 
{
    FORMATION = 0,
    XUNXIAN = 1,
}

--命魂界面类型
SOULLIFE_BAG_TYPE = 
{
    EQU = 0,
    UPGRADE = 1,
}

SOULLIFE_UPGRADE_TYPE =
{
    POOL = 0,
    SOULLIFE = 1,
}

function gCreateSpirit(id, type, attr, lv, exp, pos, value, fType)
    return {   
                iID = id,
                iType = type,
                iAttr = attr,
                iLV = lv,
                iExp = exp,
                iPos = pos,
                iValue = value,
                iFType = fType,
            }
end

function gGetSpiritAttrNameByType(spiritType, attr)
    local name = "";
    if(gIsZhLanguage())then
        name = gGetWords("spiritWord.plist",string.format("spirit_type%d_%d", (spiritType + 1),(spiritType + 1)))
    end
    local isFloatAttr = CardPro.isFloatAttr(attr)
    local briefName = ""
    -- print("attr type is:", attr)
    if isFloatAttr then
        briefName = gGetWords("spiritWord.plist", "attr" .. attr)
    end

    if briefName ~= "" then
        name = briefName .. name
    else
        name = gGetWords("cardAttrWords.plist", "attr" .. attr) .. name
    end

    return name
end

function gCreateSpiritNameColor(iType)
    -- SP_TYPE_GUI = 0, --鬼仙(白)
    -- SP_TYPE_REN = 1, -- 人仙（绿）
    -- SP_TYPE_DI = 2,  --地仙（蓝）
    -- SP_TYPE_SHEN = 3,--神仙（紫）
    -- SP_TYPE_TIAN = 4,--天仙（橙）
    -- SP_TYPE_CHIP = 5,--碎片
    -- GOLD = 6,--金币

    if iType == SPIRIT_TYPE.GUI then
        return cc.c3b(255, 255, 255)
    elseif iType == SPIRIT_TYPE.REN then
        return cc.c3b(54, 255, 0)
    elseif iType == SPIRIT_TYPE.DI then
        return cc.c3b(0, 240, 255)
    elseif iType == SPIRIT_TYPE.SHEN then
        return cc.c3b(255, 63, 226)
    elseif iType == SPIRIT_TYPE.TIAN or iType == SPIRIT_TYPE.CHIP then
        return cc.c3b(255, 138, 0)
    elseif iType == SPIRIT_TYPE.DOUBLE_ATTR then
        return cc.c3b(255, 37, 37)
    else
        return cc.c3b(255, 255, 255)
    end
end

function gIsTheSameSpirit(lSpirit,rSpirit)
    if  lSpirit.iID    == rSpirit.iID    and
        lSpirit.iType  == rSpirit.iType  and
        lSpirit.iAttr  == rSpirit.iAttr  and
        lSpirit.iLV    == rSpirit.iLV    and
        lSpirit.iExp   == rSpirit.iExp   and
        lSpirit.iPos   == rSpirit.iPos   and
        lSpirit.iValue == rSpirit.iValue and
        lSpirit.iFType == rSpirit.iFType then
        return true
    end

    return false
end

function gGetPosNameOfSpirit(iPos)
    if 0 == iPos then
        return ""
    end

    return gGetWords("spiritWord.plist", "spirit_pos_name".. math.floor(iPos / 10))
end

function gGetSpiritAttrNameAndValue(attr,value)
    local attrName = gGetWords("cardAttrWords.plist", "attr" .. attr)
    local attrValue = ""
    if CardPro.isFloatAttr(attr) then
        attrValue = string.format("+%0.1f%%", value)
    else
        attrValue = string.format("+%d", value)
    end

    return attrName,attrValue
end

function gCreateSpiritFla(iType, node)
    loadFlaXml("ui_soullife")
    local spiritType = iType
    if spiritType == SPIRIT_TYPE.DOUBLE_ATTR then
        spiritType = SPIRIT_TYPE.DOUBLE_ATTR - 1
    else
        spiritType = spiritType + 1
    end
    local spiritIcon = gCreateFla("xian_soul_"..spiritType, 1)
    spiritIcon:setScale(0.7)
    return spiritIcon
end

