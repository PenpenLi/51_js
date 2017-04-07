-- 星宿系统

-- 星宿组信息
ConstellationGroupInfo = class("ConstellationGroupInfo")
function ConstellationGroupInfo:ctor(circleId,groupInfo)
    self.circleId = circleId
    self.actived = gConstellation.isGroupActived(circleId, groupInfo.id)
    self:initBasicInfo(groupInfo)
end

function ConstellationGroupInfo:initBasicInfo(groupInfo)

    self.groupId = groupInfo.id
    self.desc = groupInfo.name
    self.star= groupInfo.star
    self.icons = {}
    for i = 1, 5 do
        if groupInfo["conid"..i] ~= 0 then
            self.icons[groupInfo["conid"..i]] = true
        end
    end

    self.attrType = groupInfo.attr
    self.attrValue = groupInfo.param
end

function ConstellationGroupInfo:hasCard(cardId)
    if self.icons[cardId] then
        return true
    end
    return false
end

--法阵额外特性
CircleAddInfo = class("CircleAddInfo")
function CircleAddInfo:ctor(circleId,sortId,unlock)
    self.circleId = circleId
    self.sortId = sortId
    self.unlock = unlock
    self:initBasicInfo(circleId, sortId)
end

function CircleAddInfo:initBasicInfo(circleId, sortId)
    self.attrInfos = {}
    self.desc = ""
    for _, var in ipairs(circleadd_db) do
        if var.cid == circleId and var.sort == sortId then
            self.desc = var.info
            for i = 1, 5 do
                if var["attr"..i] ~= 0 then
                    table.insert(self.attrInfos, {attr=var["attr"..i], value=var["param"..i]})
                end
            end
        end
    end
end

-- 法阵信息
MagicCircleInfo = class("MagicCircleInfo")
function MagicCircleInfo:ctor(id)
    --法阵id
    self.id = id
    --法阵名称
    self.name = ""
    --法阵描述
    self.desc = ""
    --开启等级
    self.needLv = 0
    --前置法阵ID
    self.preCircleId = 0
    --开启所需前置法阵组数
    self.preCircleGroups = 0
    --是否解锁
    self.isUnlock = false
    --阵法额外属性加成
    self.extraAttrInfos = {}
    --星宿组数，TODO,读表获得，是否要存，还是实时获取,或者只存status?
    self.groupInfos = {}
    --解锁组数
    self.unlockGroupNum = 0

    self:initBasicInfo()
end

function MagicCircleInfo:initBasicInfo()
    local basicInfo = DB.getConstellationCircleInfo(self.id)
    if nil ~= basicInfo then
        self.name = basicInfo.name
        self.desc = basicInfo.info
        self.needLv = basicInfo.needlv
        self.preCircleId = basicInfo.forid
        self.preCircleGroups = basicInfo.neednum
    end

    if self.id <= gConstellation.getActivedMagicCircle() then
        self.isUnlock = true
    end
end

function MagicCircleInfo:setUnlockGroupNum(num)
    self.unlockGroupNum = num
end

function MagicCircleInfo:clear()
    self.extraAttrInfos = {}
    self.groupInfos = {}
    self.unlockGroupNum = 0
end

function MagicCircleInfo:addGroupInfos(groupInfo)
    table.insert(self.groupInfos, groupInfo)
end

function MagicCircleInfo:addExtraAttrInfo(sortId,flag)
    self.extraAttrInfos[sortId] = flag
end

function MagicCircleInfo:getExtraAttrInfo(sortId)
    return self.extraAttrInfos[sortId]
end

function MagicCircleInfo:initGroupInfos()
    local groupInfoDBs = DB.getCircleGroupInfos(self.id)
    for _, groupInfoDB in pairs(groupInfoDBs) do
        local groupInfo = ConstellationGroupInfo.new(self.id,groupInfoDB)
        table.insert(self.groupInfos, groupInfo)
    end
end

function MagicCircleInfo:getGroupInfoById(groupId)
    for _, groupInfo in pairs(self.groupInfos) do
        if groupInfo.groupId == groupId then
            return groupInfo
        end
    end

    return nil
end


--星宿成就信息,读配制
ConstellationAchieve = class("ConstellationAchieve")
function ConstellationAchieve:ctor(id, unlock)
    self.id = id
    self.unlock = unlock
    self:initBasicInfo(id)
end

function ConstellationAchieve:initBasicInfo(id)
    local info = constellationachieve_db[id]
    if nil == info then
        return
    end

    self.desc = info.name
    self.preAchieve = info.forid
    self.unlockNum = info.unlocknum
    self.needNum = info.neednum
    self.attrInfos = {}
    for i = 1, 5 do
        if info["attr"..i] ~= 0 then
            table.insert(self.attrInfos, {attr=info["attr"..i],value=info["param"..i]})
        end
    end
end

--星宿信息
ConstellationItemInfo = class("ConstellationItemInfo")
function ConstellationItemInfo:ctor(id)
    self.id = id
    --已购买数量
    self.buyNum = 0
    self.num = 0
    self:initBasicInfo(id)
end

function ConstellationItemInfo:initBasicInfo(id)
    for _,var in ipairs(constellation_db) do
        if var.id == id then
            self.star = var.star
            self.needNum = var.neednum
            self.maxNum = var.maxnum
        end
    end
end

function ConstellationItemInfo:setBuyNum(buyNum)
    self.buyNum = buyNum
end

function ConstellationItemInfo:setNum(num)
    self.num = num
end

--星宿系统
gConstellation = {}

function gConstellation.clear()
    -- 选中的法阵索引，用idx或者id
    gConstellation.selCircleId = 0
    --星宿值
    gConstellation.num = 0
    --已激活组合数
    gConstellation.activedGroup = -1
    --法阵消息组
    gConstellation.magicCircleInfos = {}
    --成就信息
    gConstellation.achievementInfos = {}
    --星宿背包
    gConstellation.bags = {}
    --已解锁星宿数
    gConstellation.unlockNum = 0
    --星魂数量
    gConstellation.soulNum = 0
    --已激活的法阵
    gConstellation.activeMagicCircle = 0
    --当前使用的附加属性
    gConstellation.selExtraAddIdx = 0
    --已激活的成就id
    gConstellation.activedAchieveId = 0
    --已激活星宿组集合
    gConstellation.activedGroupMap = {}
     --星数
    gConstellation.starListGroupMap = {}
    --未激活星宿组集合
    gConstellation.unActivedGroups = {}
    --猎星信息
    gConstellation.huntInfo = {}
    ----剩余免费次数
    gConstellation.huntInfo.freeNum = 0
    ----剩余必中三星次数
    gConstellation.huntInfo.bingo = 0
    ---背包是否排过序
    gConstellation.isBagSort = false
    --剩余挑战次数
    gConstellation.leftFightNum = 0
    --挑战次数恢复时间
    gConstellation.leftFightRecoveryTime = 0
    --剩余免费换将次数
    gConstellation.freeLeftChangeNum = 0
    --元宝换将次数
    gConstellation.diaChangeNum = 0
    --要挑战的星宿id
    gConstellation.fightConstellaionId = 0
    --是否有可激活的组合
    gConstellation.groupCanBeAcive = false

    gConstellation.starUnLockLv = -1
    gConstellation.starViewLv = -1
end

function gConstellation.setSelCircleId(id)
    gConstellation.selCircleId = id
end

function gConstellation.getSelCircleId()
    return gConstellation.selCircleId
end

function gConstellation.getStarUnLockLv()
    if gConstellation.starUnLockLv ==-1 then
        gConstellation.starUnLockLv = DB.getClientParam("CONSTELLATION_STAR_OPEN_LV",true)
    end
    return gConstellation.starUnLockLv
end

function gConstellation.showStarViewLv()
    return Data.getCurLevel()>=gConstellation.getStarViewLv()
end


function gConstellation.getStarViewLv()
    if gConstellation.starViewLv ==-1 then
        gConstellation.starViewLv = DB.getClientParam("CONSTELLATION_STAR_VIEW_LV",true)
    end
    return gConstellation.starViewLv
end

function gConstellation.addMagicCircleInfo(info)
    table.insert(gConstellation.magicCircleInfos, info)
end

function gConstellation.getMagicCircleInfoById(idx)
    return gConstellation.magicCircleInfos[idx]
end

function gConstellation.addAchievementInfo(info)
    table.insert(gConstellation.achievementInfos, info)
end

function gConstellation.getAchievementByIdx(idx)
    return gConstellation.achievementInfos[idx]
end

function gConstellation.addBag(info)
    -- gConstellation.bags[info.id]=info
    table.insert(gConstellation.bags, info)
end

function gConstellation.getBagById(id)
    for _,bagItem in ipairs(gConstellation.bags) do
        if bagItem.id == id then
            return bagItem
        end
    end
    return nil
end

function gConstellation.getConstellationItemNum(id)
    local itemInfo = gConstellation.getBagById(id)
    if itemInfo == nil then
        return 0
    end

    return itemInfo.num
end

function gConstellation.setUnlockNum(num)
    gConstellation.unlockNum = num
end

function gConstellation.getUnlockNum()
    return gConstellation.unlockNum
end

function gConstellation.setSoulNum(num)
    gConstellation.soulNum = num
end

function gConstellation.getSoulNum()
    return gConstellation.soulNum
end

function gConstellation.getBagItemNum(id)
    for _,var in ipairs(gConstellation.bags) do
        if var.id == id then
            return var.num
        end
    end

    return 0
end

function gConstellation.setActivedMagicCircle(activedCircle)
    gConstellation.activeMagicCircle = activedCircle
end

function gConstellation.getActivedMagicCircle()
    return gConstellation.activeMagicCircle
end

function gConstellation.setSelExtraAddIx(idx)
    gConstellation.selExtraAddIdx = idx
end

function gConstellation.getSelExtraAddIx()
    return gConstellation.selExtraAddIdx
end

function gConstellation.setActivedAchieveId(id)
    gConstellation.activedAchieveId = id
end

function gConstellation.getActivedAchieveId()
    return gConstellation.activedAchieveId
end

function gConstellation.setNum(num)
    gConstellation.num = num
end

function gConstellation.getNum()
    return gConstellation.num
end

function gConstellation.addActivedGroupMap(circleId, groupId)
    if gConstellation.activedGroupMap[circleId] == nil then
       gConstellation.activedGroupMap[circleId] = {} 
    end
    gConstellation.activedGroupMap[circleId][groupId] = true
    gConstellation.unActivedGroups[groupId]=false
end

function gConstellation.addStarListGroupMap(circleId, groupId,num)
    if gConstellation.starListGroupMap[circleId] == nil then
       gConstellation.starListGroupMap[circleId] = {} 
    end
    gConstellation.starListGroupMap[circleId][groupId] = num
end


function gConstellation.getStarNumByGroupMap(circleId, groupId)
    local num = 0
    if gConstellation.starListGroupMap[circleId] ~= nil then
       num = gConstellation.starListGroupMap[circleId][groupId]
    end
    if num==nil then
        num=0
    end
    return num
end


function gConstellation.getActivedGroupNum(circleId)
    if nil ~= gConstellation.activedGroupMap[circleId] then
        return table.count(gConstellation.activedGroupMap[circleId])
    else
        return 0
    end
end

function gConstellation.getTotalActivedGroupNum()
    if gConstellation.activedGroup == -1 then
        gConstellation.activedGroup = 0
        for _,groupInfos in pairs(gConstellation.activedGroupMap) do
            gConstellation.activedGroup = gConstellation.activedGroup + table.count(groupInfos)
        end
    end
    return gConstellation.activedGroup
end

function gConstellation.isGroupActived(circleId, groupId)
    local isActive = false
    local groupInfos = gConstellation.activedGroupMap[circleId]
    if nil ~= groupInfos then
        if groupInfos[groupId] then
           isActive = true 
        end
    end

    return isActive
end

function gConstellation.updateActivedGroupId(circleId, groupId)
    if gConstellation.activedGroupMap[circleId] == nil then
        gConstellation.activedGroupMap[circleId] = {}
    end

    gConstellation.activedGroupMap[circleId][groupId] = true
    gConstellation.activedGroup = gConstellation.activedGroup + 1
    gConstellation.activeGroupById(groupId)
    gConstellation.unActivedGroups[groupId]=false
end

function gConstellation.getActivedGroupInfos(circleId)
    if gConstellation.activedGroupMap[circleId] == nil then
        gConstellation.activedGroupMap[circleId] = {}
    end

    return gConstellation.activedGroupMap[circleId]
end

function gConstellation.setLeftFightNum(num)
    gConstellation.leftFightNum = num
end

function gConstellation.getLeftFightNum()
    return gConstellation.leftFightNum
end

function gConstellation.setFreeLeftChangeNum(num)
    gConstellation.freeLeftChangeNum = num
end

function gConstellation.getFreeLeftChangeNum()
    return gConstellation.freeLeftChangeNum
end

function gConstellation.setDiaChangeNum(num)
    gConstellation.diaChangeNum = num
end

function gConstellation.getDiaChangeNum()
    return gConstellation.diaChangeNum
end

function gConstellation.setFightConstellationId(id)
    gConstellation.fightConstellaionId = id
end

function gConstellation.getFightConstellationId()
    return gConstellation.fightConstellaionId
end

function gConstellation.setHuntFreeNum(num)
    gConstellation.huntInfo.freeNum = num
end

function gConstellation.getHuntFreeNum()
    return gConstellation.huntInfo.freeNum
end
-- 猎星必中三星次数
function gConstellation.setHuntBingo(num)
    gConstellation.huntInfo.bingo = num
end

function gConstellation.getHuntBingo()
    return gConstellation.huntInfo.bingo
end

function gConstellation.canActiveAchieve(achieveId)
    local achieveInfo = constellationachieve_db[achieveId]
    if achieveInfo ~= nil and 
       gConstellation.getTotalActivedGroupNum() >= achieveInfo.unlocknum  and
       gConstellation.num >= achieveInfo.neednum then
        return true
    end

    return false
end
-- TOCHECK
function gConstellation.canActiveGroup(groupInfo)
    local canActive = true
    for i = 1, 5 do
        local iconId = groupInfo["conid"..i]
        if iconId ~= 0 then
            local num = gConstellation.getConstellationItemNum(iconId)
            if num == 0 then
                canActive = false
                break
            end
        end
    end

    return canActive
end

-- TOCHECK
function gConstellation.canStarUpgradeGroup(groupStarInfo)
    local canUpgrade = true
    if groupStarInfo then
        for i = 1, 5 do
            local iconId = groupStarInfo["conid"..i]
            if iconId ~= 0 then
                local diffnum = gConstellation.getConstellationItemNum(iconId)-groupStarInfo["connum"..i]
                if diffnum<0 then
                    canUpgrade = false
                    break
                end
            end
        end
    end

    return canUpgrade
end


function gConstellation.hasGroupCanbeActived(circleId)
    local magicCircleInfo = gConstellation.magicCircleInfos[circleId]
    if nil == magicCircleInfo then
        return false
    end

    local groupInfos = DB.getCircleGroupInfos(magicCircleInfo.id)

    for _, groupInfo in pairs(groupInfos) do
        if not gConstellation.isGroupActived(circleId, groupInfo.id) and 
            gConstellation.canActiveGroup(groupInfo) then
            return true
        end
    end

    return false
end

function gConstellation.hasGroupCanbeStarUpgrade(circleId)
    local magicCircleInfo = gConstellation.magicCircleInfos[circleId]
    if nil == magicCircleInfo then
        return false
    end

    local groupInfos = DB.getCircleGroupInfos(magicCircleInfo.id)
    for _, groupInfo in pairs(groupInfos) do
        if gConstellation.isGroupActived(circleId, groupInfo.id)  then
            local starNum = gConstellation.getStarNumByGroupMap(circleId, groupInfo.id)
            if groupInfo.star>0  and groupInfo.star~=starNum then
                local groupStarInfo= DB.getCircleGroupStar(groupInfo.id,starNum+1)
                if gConstellation.canStarUpgradeGroup(groupStarInfo) then
                    return true
                end
            end
        end
    end
    return false
end


function gConstellation.initBagItems()
    for _, item in ipairs(constellation_db) do
        local bagItem = ConstellationItemInfo.new(item.id)
        if nil ~= bagItem then
            gConstellation.addBag(bagItem)
        end
    end
end

function gConstellation.getGroupInfosContainItem(itemId)
    for _, magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
        local groupInfos = DB.getCircleGroupInfos(magicCircleInfo.id)
        for _, groupInfo in pairs(groupInfos) do
            
        end
    end
end

function gConstellation.getConstellationFightBuyPrice()

    local price = Data.getBuyTimesPrice(gConstellation.diaChangeNum,"CONSTELLATION_CHANGE_FIGHTER_BUY_PRICE","CONSTELLATION_CHANGE_FIGHTER_BUY_NUM")
    if price == 0 then
        price = DB.getClientParamToTable("CONSTELLATION_CHANGE_FIGHTER_BUY_PRICE",true)[1]
    end

    return price 
end

function gConstellation.setLeftFightRecoveryTime(time)
    gConstellation.leftFightRecoveryTime = time
end

function gConstellation.getLeftFightRecoveryTime()
    return gConstellation.leftFightRecoveryTime
end

function gConstellation.updateGroupCanBeActive()
    local size = DB.getConstellationCircleCount()
    local activedCircle = gConstellation.getActivedMagicCircle()
    for i = 1, size do
        if i <= activedCircle then
            local groupInfos = DB.getCircleGroupInfos(i)
            for _, groupInfo in pairs(groupInfos) do
                if not gConstellation.isGroupActived(i, groupInfo.id) and 
                    gConstellation.canActiveGroup(groupInfo) then
                    gConstellation.groupCanBeAcive = true
                    return
                end
            end
        end
    end

    gConstellation.groupCanBeAcive = false
end

function gConstellation.getItemNeedType(itemId)
    local hasLackItemCount = 0
    for groupid,var in pairs(gConstellation.unActivedGroups) do
        if var then
            local groupInfo = DB.getConstellationGroupInfo(groupid)
            local circleId = groupInfo.cid
            local activedCircle = gConstellation.getActivedMagicCircle()
            if circleId <= activedCircle then
                local hasLackItem = false
                local isEmergencyItem = false
                local itemIdAndNum = {}
                for i = 1, 5 do
                    local tmpItemId = groupInfo["conid"..i]
                    if tmpItemId ~= 0 then  
                        itemIdAndNum[tmpItemId] = gConstellation.getConstellationItemNum(tmpItemId)
                        if tmpItemId == itemId and  itemIdAndNum[tmpItemId] == 0 then
                            hasLackItem = true
                            hasLackItemCount = hasLackItemCount + 1
                        end
                    end
                end

                if hasLackItem then
                    isEmergencyItem = true
                    for key,var in pairs(itemIdAndNum) do
                        if key ~= itemId and var == 0 then
                            isEmergencyItem = false
                            break
                        end
                    end
                end

                if isEmergencyItem then
                    return 2
                end
            end
        end
    end

    if gConstellation.showStarViewLv() then
        --升星星宿差一个
        local size = DB.getConstellationCircleCount()
        local activedCircle = gConstellation.getActivedMagicCircle()
        for i = 1, size do
            if i <= activedCircle then
                local groupInfos = gConstellation.getActivedGroupInfos(i)
                for groupid,value in pairs(groupInfos) do
                    local starlv =gConstellation.getStarNumByGroupMap(i, groupid)
                    local groupInfo = DB.getConstellationGroupInfo(groupid)
                    if groupInfo.star>0 and starlv ~= groupInfo.star then --可升星

                            local itemIdAndNum ={}
                            local groupStarInfo = DB.getCircleGroupStar(groupid,starlv+1)
                             for k = 1, 5 do
                                if groupStarInfo then
                                    local tmpItemId = groupStarInfo["conid"..k]
                                    if tmpItemId ~= 0 then  
                                        local diffnum = gConstellation.getConstellationItemNum(tmpItemId)-groupStarInfo["connum"..k]
                                        if diffnum<0 then
                                            itemIdAndNum[tmpItemId] = diffnum
                                        end
                                        
                                    end
                                end
                            end
                            if table.count(itemIdAndNum)==1 then
                                for key,num in pairs(itemIdAndNum) do
                                    if key == itemId and  num == -1 then
                                        return 3
                                    end
                                end
                            end
                    end
                   
                end
            end
        end
    end
    

    if hasLackItemCount ~= 0 then
        return 1
    end

    return 0
end

function gConstellation.activeGroupById(groupId)
    for _, magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
        local groupInfo = magicCircleInfo:getGroupInfoById(groupId)
        if nil ~= groupInfo then
            groupInfo.actived = true
            break
        end
    end
end
-- TOCHECK,性能
function gConstellation.getAttrAddValue(attr)
    local attrAdd = 0
    for _,magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
        if magicCircleInfo.isUnlock then
            local groupInfos = gConstellation.getActivedGroupInfos(magicCircleInfo.id)
            for i,value in pairs(groupInfos) do
                local groupInfo = DB.getConstellationGroupInfo(i)
                if groupInfo.attr == attr then
                    attrAdd = attrAdd + attr
                end
            end
        end
    end
    return attrAdd
end

function gConstellation.getGroupAndAchieveValue(attr)
    local retValue = 0
    local size = DB.getConstellationCircleCount()
    local activedCircle = gConstellation.getActivedMagicCircle()
    for i = 1, size do
        if i <= activedCircle then
            local groupInfos = gConstellation.getActivedGroupInfos(i)
            for i,value in pairs(groupInfos) do
                local groupInfo = DB.getConstellationGroupInfo(i)
                if groupInfo.attr == attr and groupInfo.param > 0 then
                    retValue = retValue + groupInfo.param
                end
            end
        end
    end


    local activedAchieveId = gConstellation.getActivedAchieveId()
    for i = 1, activedAchieveId do
        local achieveInfo = DB.getConstellationAchieveInfo(i)
        if achieveInfo.attr1 == attr then
            retValue = retValue + achieveInfo.attr1
        end
    end

    return retValue
end

function gConstellation.isAllGroupActived(circleId)
    local activedCircle = gConstellation.getActivedMagicCircle()
    if circleId > activedCircle then
        return false
    end

    local activedCount = gConstellation.getActivedGroupNum(circleId)
    local totalCount = DB.getTotalCirceGroupNums(circleId)
    return activedCount == totalCount
end

function gConstellation.showGroupActivedNum(num, groupId)
    local groupInfo = DB.getConstellationGroupInfo(groupId)
    if nil == groupInfo then
        return
    end

    local table_data = {}
    table_data.attr = groupInfo.attr
    table_data.value = groupInfo.param
    table_data.add = 0

    if num ~= 0 then
        table_data.exAttr = {}
        table_data.exAttr.type = 1
        table_data.exAttr.value = num
    end

    local petNotice = PetNoticePanel.new(table_data)
    petNotice:setAnchorPoint(cc.p(0.5,-0.5))
    gAddChildByAnchorPos(gShowItemPoolLayer,petNotice,cc.p(0.5,0.5))
end


function gConstellation.showGroupStarNum(num, groupId,starLv)
    local groupStarInfo = DB.getCircleGroupStar(groupId,starLv)
    if nil == groupStarInfo then
        return
    end

    local table_data = {}
    for i=1,3 do
        local attrtype = groupStarInfo["attr"..i]
        if attrtype>0 then
            local attrValue = groupStarInfo["param"..i]
            table_data["attr"..i]=attrtype
            table_data["value"..i]=attrValue
            table_data["add"..i]=0
        end
    end
    if num ~= 0 then
        table_data.exAttr = {}
        table_data.exAttr.type = 1
        table_data.exAttr.value = num
    end

    local petNotice = PetNoticePanel.new(table_data)
    petNotice:setAnchorPoint(cc.p(0.5,-0.5))
    gAddChildByAnchorPos(gShowItemPoolLayer,petNotice,cc.p(0.5,0.5))
end



function gConstellation.initUnActivedGroups()
    gConstellation.unActivedGroups = {}
    for key, var in pairs(constellationgroup_db) do
        gConstellation.unActivedGroups[key] = true
    end
end
