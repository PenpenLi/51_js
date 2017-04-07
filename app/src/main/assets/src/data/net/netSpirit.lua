
function Net.updateBagSpiritList(evt, isFindOrCall)
    SpiritInfo.clearFindSpiritList()
    local obj = evt.params:getObj("params")
    if obj:containsKey("list") then
        local array = obj:getArray("list")
        if nil ~= array then
            array = tolua.cast(array,"MediaArray")
            for i=1, array:count() do
                local obj2 = array:getObj(i - 1)
                if nil ~= obj2 then
                    obj2 = tolua.cast(obj2, "MediaObj")
                    local spirit = gCreateSpirit(0, 0, 0, 0, 0, 0, 0, 0)
                    spirit.iID = obj2:getLong("id")
                    spirit.iType = obj2:getByte("type")
                    spirit.iAttr = obj2:getByte("attr")
                    spirit.iLV   = obj2:getByte("lv",1)
                    spirit.iExp  = obj2:getInt("exp")
                    spirit.iValue = obj2:getInt("value")
                    spirit.iFType = obj2:getByte("ftype")
                    if isFindOrCall then
                        SpiritInfo.addFindSpiritItem(spirit)
                    end
                    --TODO CHECK
                    if (spirit.iType >= SPIRIT_TYPE.GUI and spirit.iType <= SPIRIT_TYPE.TIAN) or spirit.iType == SPIRIT_TYPE.DOUBLE_ATTR then
                        SpiritInfo.addBagSpiritItem(spirit)
                    elseif spirit.iType == SPIRIT_TYPE.CHIP then
                        -- SpiritInfo.addiFraOne()
                        -- gDispatchEvt(EVENT_ID_GET_ACTIVITY_ALL) 
                    end
                end
            end
        end
    end
end


function Net.updateCardInfoWithSpirit(spiritPos)
    for key, teamInfo in pairs(gUserTeams) do
        -- spiritPos还是除以10，预留四个空位
        local cardID = teamInfo.card[spiritPos/10]
        if 0 ~= cardID then
            local card = Data.getUserCardById(cardid)
            if nil ~= card then
                CardPro.setCardAttr(card)
            end
        end
    end
end

function Net.updateSpiritList(spiritArray)
    for i=0, spiritArray:count()-1 do
        local spiritObj = spiritArray:getObj(i)
        spiritObj = tolua.cast(spiritObj,"MediaObj")
        if nil ~= spiritObj then
            local spirit = {}
            spirit.iID = spiritObj:getLong("id")
            spirit.iType = spiritObj:getByte("type")
            spirit.iAttr = spiritObj:getByte("attr")
            spirit.iLV   = spiritObj:getByte("lv")
            spirit.iExp  = spiritObj:getInt("exp")
            spirit.iPos  = spiritObj:getByte("pos")
            SpiritInfo.addSpiritItem(spirit)
        end
    end
end

--[[
spirit.init 初始化寻仙界面信息
发送参数:
  无:
接收参数:
  |-(byte)ret  接口编码
  |-(byte)type 当前寻仙类型
  |-(ISFSArray)list 背包元神列表
    |-(long)id  数据id
    |-(byte)type 元神类型
    |-(byte)attr 属性(和卡牌属性一致)
    |-(byte)lv   等级
    |-(int)exp   经验
  |-(int)fra     元神碎片数量
  |-(int)exp     经验池数量
  |-(ISFSArray)opens     经验池数量
    |-(byte)pos  位置
    |-(bool)open 是否开启
]]
function Net.sendSpiritInit(initPanelType)
  local obj = MediaObj:create()
  Net.sendInitPanelType = initPanelType
  Net.sendExtensionMessage(obj, CMD_SPIRIT_INIT)
end

function Net.recSpiritInit(evt)
  local obj = evt.params:getObj("params")
  if(obj:getByte("ret")~=0)then
      return
  end
  SpiritInfo.setiType(obj:getByte("type"))
  SpiritInfo.clearBagSpiritList()
  SpiritInfo.clearFindSpiritList()
  Net.updateBagSpiritList(evt)
  SpiritInfo.sortSpiritBagList()

  -- gDispatchEvt(EVENT_ID_SPIRIT_UPDATE_BAG)
  SpiritInfo.iFra = obj:getInt("fra")
  SpiritInfo.exp  = obj:getInt("exp")
  if obj:containsKey("opens") then
      local array = obj:getArray("opens")
      for i = 1, array:count() do
          local openObj = array:getObj(i - 1)
          if nil ~= openObj then
              openObj = tolua.cast(openObj, "MediaObj")
              SpiritInfo.addOpenInfo(openObj:getByte("pos"), openObj:getBool("open"))
              -- print("opens pos is:", openObj:getByte("pos"), " isOpen is:", openObj:getBool("open"))
          end
      end
  end


  Panel.popUp(PANEL_SOULLIFE_FORMATION,Net.sendInitPanelType)

  -- gDispatchEvt(EVENT_ID_SPIRIT_INIT)
  -- TOCHECK 途径来源
  -- if(getUILayerWithMapName("ui_illustrations_lianjie_di.map")) {
  --       //LoadLayer::addNextLayerInCurScene(Loading_Spirit_Exchange,Loading_OpacityBg);
  --       CCDirector::sharedDirector()->replaceScene(LoadScene::scene(Loading_Spirit));
  -- }else {
  --       EventListener::sharedEventListener()->handleEvent(c_event_spirit_init);
  -- }
end



--[[
spirit.find 寻仙（获得新的元神等级默认为1，经验为0）(列表里有碎片客户端需要更新碎片数量）
发送参数:
  |-(bool)more  是否多次
接收参数:
  |-(byte)ret   接口编码
  |-(byte)type  当前寻仙类型
  |-(ISFSObject)reward  奖励信息
  |-(ISFSArray)list  新增的元神列表
    |-(long)id  数据id
    |-(byte)type 元神类型
    |-(byte)attr 属性(和卡牌属性一致)
    |-(int)value  金钱数值
    |-(byte)ftype 本次寻仙类型
]]

function Net.sendSpiritFind(more)
  local obj = MediaObj:create()
  obj:setBool("more",more)
  Net.sendExtensionMessage(obj, CMD_SPIRIT_FIND)
--TODO
--EventListener::sharedEventListener():handleEvent(c_event_spirit_find_or_call_start)
end


function Net.recSpiritFind(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_SPIRIT_NET_ERROR,{name=CMD_SPIRIT_FIND, ret=obj:getByte("ret")})
        return
    end
    SpiritInfo.setiType(obj:getByte("type"))
    Net.updateBagSpiritList(evt, true)
    gDispatchEvt(EVENT_ID_SPIRIT_FIND)
    Net.updateReward(obj:getObj("reward"))
end



--[[
spirit.call 召唤
发送参数:
  无
接收参数:
  |-(byte)ret   接口编码
  |-(byte)type  当前寻仙类型
  |-(ISFSObject)reward  奖励信息
]]
function Net.sendSpiritCall()
  local obj = MediaObj:create()
  Net.sendExtensionMessage(obj, CMD_SPIRIT_CALL)
end


function Net.recSpiritCall(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_SPIRIT_NET_ERROR,{name=CMD_SPIRIT_CALL, ret=obj:getByte("ret")})
        return
    end
    SpiritInfo.setiType(obj:getByte("type"))
    gDispatchEvt(EVENT_ID_SPIRIT_FIND_TYPE)
    Net.updateReward(obj:getObj("reward"))
end

--[[
spirit.callmore 多次召唤
发送参数:
  无:
接收参数:
  |-(byte)ret  接口编码
  |-(byte)type 当前寻仙类型
  |-(ISFSObject)reward  奖励信息
  |-(ISFSArray)list 新增的元神列表
    |-(long)id  数据id(碎片没有数据ID)
    |-(byte)type 元神类型
    |-(byte)attr 属性(和卡牌属性一致)
    |-(int)value 金钱数值
    |-(byte)ftype 本次寻仙类型  
]]
function Net.sendSpiritCallMore()
  local obj = MediaObj:create()
  Net.sendExtensionMessage(obj, CMD_SPIRIT_CALLMORE)
end


function Net.recSpiritCallMore(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_SPIRIT_NET_ERROR,{name=CMD_SPIRIT_CALLMORE, ret=obj:getByte("ret")})
        return
    end
    SpiritInfo.setiType(obj:getByte("type"))
    Net.updateReward(obj:getObj("reward"),2)
    Net.updateBagSpiritList(evt,true)
    local spirit = gCreateSpirit(0, 0, 0, 0, 0, 0, 0, 0)
    spirit.iID = obj:getInt("itemid")
    spirit.iValue = 1
    SpiritInfo.addFindSpiritItem(spirit)

    gDispatchEvt(EVENT_ID_SPIRIT_CALL_MORE)
end

--[[
spirit.equ 装备元神（客户端自行更新卡牌属性）
发送参数:
  |-(byte)pos 装备位置
  |-(long)id  装备的元神数据ID
接收参数:
  |-(byte)ret  接口编码
  |-(byte)pos  装备位置
  |-(long)id   装备的元神数据ID
]]
function Net.sendSpiritEqu(pos, id)
  local obj = MediaObj:create()
  obj:setByte("pos", pos)
  obj:setLong("id", id)
  Net.sendExtensionMessage(obj, CMD_SPIRIT_EQU)
end


function Net.recSpiritEqu(evt)
  -- checkRelationPre()

  local obj = evt.params:getObj("params")
  if(obj:getByte("ret")~=0)then
      return
  end

  local iPos = obj:getByte("pos")
  local iID = obj:getLong("id")

  local equIdx = SpiritInfo.getSpiritIndexWithPos(iPos)
  local addSpirit = nil
  local removeSpirit = nil
  if equIdx ~= -1 and equIdx <= SpiritInfo.getSpiritSize() then
      local spirit =  SpiritInfo.getSpiritByIdx(equIdx)
      if nil ~= spirit then
          spirit.iPos = 0
          --从装备列表删除
          SpiritInfo.removeSpiritByIdx(equIdx)
          --增加到背包中
          SpiritInfo.addBagSpiritItem(spirit)
          addSpirit = spirit
      end
  end

  local bagIdx = SpiritInfo.getBagSpiritIdxByID(iID)
  if bagIdx ~= -1 and bagIdx <= SpiritInfo.getBagSpiritSize() then
      local spirit = SpiritInfo.getBagSpiritByIdx(bagIdx)
      spirit.iPos = iPos
      --从背包中删除
      SpiritInfo.removeBagSpiritByIdx(bagIdx)
      --增加到装备列表
      SpiritInfo.addSpiritItem(spirit)
      removeSpirit = spirit
      Net.updateCardInfoWithSpirit(iPos)
      gDispatchEvt(EVENT_ID_SPIRIT_EQU, {pos = iPos, add = addSpirit, remove = removeSpirit})
      -- EventListener::sharedEventListener()->handleEvent(c_event_spirit_equ)
      -- checkTeamPrice(1)
      -- //是否激活新缘分
      -- if(GuideManager::shared()->getCurGuideType() <= 0) checkNewRelation()
  end
end


--[[
spirit.upgrade 升级元神（客户端自行更新升级的元神和吞噬的元神信息，如果是升级装备的元神并且升级，则需要更新卡牌属性)
发送参数:
  |-(logn)id  背包升级元神的数据ID
  |-(byte)pos 装备升级元神的位置
  |-(longArray)ids 吞噬的元神数据ID列表
接收参数:
  |-(byte)ret  接口编码
]]
function Net.sendSpiritUpgrade(id, pos, ids)
  local obj = MediaObj:create()
  if (pos > 0) then
      obj:setByte("pos", pos)
  else
      obj:setLong("id", id)
  end

  local vLong2X = vector_long2X_:new_local()
  for i = 1, #ids do
      vLong2X:push_back(ids[i])
  end
  obj:setLongArray("ids", vLong2X)
  Net.sendExtensionMessage(obj, CMD_SPIRIT_UPGRADE)
end


function Net.recSpiritUpgrade(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_SPIRIT_NET_ERROR,{name=CMD_SPIRIT_UPGRADE, ret=obj:getByte("ret")})
        return
    end
    gDispatchEvt(EVENT_ID_SPIRIT_UPGRADE)
end



--[[
spirit.exchange 碎片兑换元神
发送参数:
  |-(Byte)attr 属性
  |-(Byte)attr2 属性
接收参数:
  |-(byte)ret  接口编码
  |-(byte)attr 属性
  |-(ISFSArray)list 新增的元神列表
    |-(long)id  数据id(碎片没有数据ID)
    |-(byte)type 元神类型
    |-(byte)attr 属性(和卡牌属性一致)
]]
function Net.sendSpiritExchange(attr,attr2)
  local obj = MediaObj:create()
  obj:setByte("attr",attr)
  if attr2 ~= nil then
      obj:setByte("attr2",attr2)
  end
  Net.sendExtensionMessage(obj, CMD_SPIRIT_EXCHANGE)
end


function Net.recSpiritExchange(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    SpiritInfo.addFra(-DB.getSpiritExchangeCount())
    Net.updateBagSpiritList(evt)
    Net.updateReward(obj:getObj("reward"),0)
    gDispatchEvt(EVENT_ID_SPIRIT_CHIP_REFRESH)
end

--[[
spirit.breakup 命魂兑换碎片
发送参数:
  |-(long)id 命魂数据ID
接收参数:
  |-(byte)ret 接口编码
  |-(int)fra 碎片总数量
  |-(long)id 命魂数据ID
]]
function Net.sendSpiritBreakUp(ID)
  local obj = MediaObj:create()
  obj:setLong("id",ID)
  Net.sendExtensionMessage(obj, "spirit.breakup")
end


function Net.rec_spirit_breakup(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
    SpiritInfo.setFraCount(obj:getInt("fra"))
    local spiritID = obj:getLong("id")
    SpiritInfo.removeBagSpiritByID(spiritID)
    gDispatchEvt(EVENT_ID_SPIRIT_BREAK_UP,spiritID)
end


--[[
spirit.chpos 交换装备元神
发送参数:
  |-(byte)pos1 装备位置
  |-(byte)pos2 被抢掉的元神位置
接收参数:
  |-(byte)ret 接口编码
  |-(byte)pos1 装备位置
  |-(byte)pos2 被抢掉的元神位置
  |-(ISFSObject)sp 卸回背包的元神
    |-(long)id 数据ID
    |-(byte)type 元神类型
    |-(byte)attr 属性
    |-(byte)lv 等级
    |-(int)exp 经验
  
]]
CMD_SPIRIT_CHANGE_POS = "spirit.chpos"
function Net.sendSpiritChangePos(pos1, pos2)
  local obj = MediaObj:create()
  obj:setByte("pos1",pos1)
  obj:setByte("pos2",pos2) 
  Net.sendExtensionMessage(obj, CMD_SPIRIT_CHANGE_POS)
end


function Net.rec_spirit_chpos(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local pos1 = obj:getByte("pos1")
    local pos2 = obj:getByte("pos2")
    local pos1Spirit = nil
    if obj:containsKey("sp") then
        local spObj = obj:getObj("sp")
        pos1Spirit = gCreateSpirit(spObj:getLong("id"), spObj:getByte("type"), spObj:getByte("attr"), spObj:getByte("lv"), spObj:getInt("exp"), 0, 0, 0)
    end

    gDispatchEvt(EVENT_ID_SPIRIT_CHANGE_POS,{equPos1=pos1,equPos2=pos2, spiritObj=pos1Spirit})
end
--元神批量转换成经验
CMD_SPIRIT_CHANGE_EXP = "spirit.chexp"
function Net.sendSpiritChExp(ids)
  local obj = MediaObj:create()
  local vLong2X = vector_long2X_:new_local()
  for i = 1, #ids do
      vLong2X:push_back(ids[i])
  end
  obj:setLongArray("ids", vLong2X)
  Net.sendExtensionMessage(obj, CMD_SPIRIT_CHANGE_EXP)
end

function Net.rec_spirit_chexp(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_SPIRIT_NET_ERROR,{name=CMD_SPIRIT_CHANGE_EXP, ret=obj:getByte("ret")})
        return
    end
    --TODO,转换的ids和exp
    SpiritInfo.exp = obj:getInt("exp")
    gDispatchEvt(EVENT_ID_SPIRIT_CH_EXP)
end

--用经验池升级元神(用经验池)
CMD_SPIRIT_UPGRADE_NEW = "spirit.upexp"
function Net.sendSpiritUpgradeNew(id, pos)
  local obj = MediaObj:create()
  Net.upgradeNewInfo = {}
  if (pos > 0) then
      obj:setByte("pos", pos)
      Net.upgradeNewInfo.pos = pos
  else
      obj:setLong("id", id)
      Net.upgradeNewInfo.id = id
  end
  Net.sendExtensionMessage(obj, CMD_SPIRIT_UPGRADE_NEW)
end

function Net.rec_spirit_upexp(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    SpiritInfo.exp = obj:getInt("allexp")
    local upgradeInfo = {}
    upgradeInfo.curExp = obj:getInt("curexp")
    upgradeInfo.lev    = obj:getByte("level")
--    SpiritInfo.updateSpiritExpAndLvByPool(upgradeInfo)
    gDispatchEvt(EVENT_ID_SPIRIT_UPGRADE_BY_EXP, upgradeInfo)
end

CMD_SPIRIT_EXCHANGE_EXP = "spirit.exexp"
function Net.sendSpiritExchangeExp()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_SPIRIT_EXCHANGE_EXP)
end

function Net.rec_spirit_exexp(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    SpiritInfo.exp = obj:getInt("curexp")
    local num,addExp = DB.getSoulLifeFraToExpParam()
    SpiritInfo.addFra(-num)
    gDispatchEvt(EVENT_ID_SPIRIT_CHIP_REFRESH)
end


CMD_SPIRIT_FIND_NEW = "spirit.findnew"
function Net.sendSpiritFindNew(gold)
    local obj = MediaObj:create()
    if nil ~= gold then
        obj:setInt("gold",gold)
    end
    Net.sendExtensionMessage(obj, CMD_SPIRIT_FIND_NEW)
end

function Net.rec_spirit_findnew(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        gDispatchEvt(EVENT_ID_SPIRIT_NET_ERROR,{name=CMD_SPIRIT_FIND_NEW, ret=obj:getByte("ret")})
        return
    end
    SpiritInfo.setiType(obj:getByte("type"))
    Net.updateReward(obj:getObj("reward"))
    local curQuickGold = obj:getInt("gold")
    Net.updateBagSpiritList(evt, true)
    gDispatchEvt(EVENT_ID_SPIRIT_UPDATE_QUICK,curQuickGold)
    gLogEvent('spirit.findnew')
end

-- 暴力寻仙
CMD_SPIRIT_BAOLI = "spirit.baoli"
function Net.sendSpiritBaoLi()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_SPIRIT_BAOLI)
end

function Net.rec_spirit_baoli(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    Net.updateReward(obj:getObj("reward"),0)
    
    local spiritItems = {}
    local addExp = obj:getInt("exp") - SpiritInfo.exp
    if addExp > 0 then
      local expSpirit = gCreateSpirit(0, SPIRIT_TYPE.EXP, 0, 0, 0, 0, 0, 0)
      expSpirit.iValue = addExp
      table.insert(spiritItems, expSpirit)
    end

    if obj:containsKey("list") then
        local array = obj:getArray("list")
        if nil ~= array then
            array = tolua.cast(array,"MediaArray")
            for i=1, array:count() do
                local spiritObj = array:getObj(i - 1)
                if nil ~= spiritObj then
                    spiritObj = tolua.cast(spiritObj, "MediaObj")
                    local spirit = gCreateSpirit(0, 0, 0, 0, 0, 0, 0, 0)
                    spirit.iID = spiritObj:getLong("id",0)
                    spirit.iType = spiritObj:getByte("type")
                    spirit.iAttr = spiritObj:getByte("attr",0)
                    spirit.iLV   = spiritObj:getByte("lv",1)
                    spirit.iExp  = spiritObj:getInt("exp",0)
                    spirit.iValue = spiritObj:getInt("value",0)
                    table.insert(spiritItems, spirit)
                end
            end
        end
    end

    gDispatchEvt(EVENT_ID_SPIRIT_BAO_LI, {items=spiritItems, exp=obj:getInt("exp")})
    gLogEvent('spirit.baoli')
end

-- 购买兑换道具
CMD_SPIRIT_BUY_ITEM = "spirit.buyitem"
function Net.sendSpiritBuyItem()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_SPIRIT_BUY_ITEM)
end

function Net.rec_spirit_buyitem(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end
    --TODO
    SpiritInfo.setSpiritItemBuyNumsOfDay(SpiritInfo.getSpiritItemBuyNumsOfDay() + 1)
    Net.updateReward(obj:getObj("reward"),1)
    gDispatchEvt(EVENT_ID_SPIRIT_BUY_ITEM_REFRESH)
end


--命魂商店信息
CMD_SPIRIT_SHOP_INFO = "spirit.shopinfo"
function Net.sendSpiritShopInfo()
    local obj = MediaObj:create()
    Net.sendExtensionMessage(obj, CMD_SPIRIT_SHOP_INFO)
end

function Net.rec_spirit_shopinfo(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    SpiritInfo.setSpiritItemBuyNumsOfDay(obj:getInt("num"))
    Panel.popUpVisible(PANEL_SOULLIFE_FRA_EXCHANGE_PANEL,nil,nil,true)
end

-- 开启格子
CMD_SPIRIT_OPEN = "spirit.open"
function Net.sendSpiritOpen(pos)
    local obj = MediaObj:create()
    Net.sendSpiritOpenPos = pos
    obj:setByte("pos", pos)
    Net.sendExtensionMessage(obj, CMD_SPIRIT_OPEN)
end

function Net.rec_spirit_open(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    Net.updateReward(obj:getObj("reward"),0)
    SpiritInfo.opens[Net.sendSpiritOpenPos] = true
    gDispatchEvt(EVENT_ID_SPIRIT_OPEN_REFRESH,Net.sendSpiritOpenPos)
    local price = DB.getSpiritStartPrice()[Net.sendSpiritOpenPos % 10]
    gLogPurchase("spirit_open", 1, price)
end

--卸载元神(客户端自己更新牌属性)
CMD_SPIRIT_UNLOAD="spirit.unload"
function Net.sendSpiritUnload(pos)
    local obj = MediaObj:create()
    obj:setByte("pos", pos)
    Net.sendExtensionMessage(obj, CMD_SPIRIT_UNLOAD)
end

function Net.rec_spirit_unload(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local pos = obj:getByte("pos")
    gDispatchEvt(EVENT_ID_SPIRIT_UNLOAD,pos)
end

--交换已装备的命魂，用于命魂界面拖去交换
CMD_SPIRIT_EXCHANGE_POS="spirit.exchpos"
function Net.sendSpiritExchangeChangePos(pos1, pos2)
  local obj = MediaObj:create()
  obj:setByte("pos1",pos1)
  obj:setByte("pos2",pos2) 
  Net.sendExtensionMessage(obj, CMD_SPIRIT_EXCHANGE_POS)
end


function Net.rec_spirit_exchpos(evt)
    local obj = evt.params:getObj("params")
    if(obj:getByte("ret")~=0)then
        return
    end

    local pos1 = obj:getByte("pos1")
    local pos2 = obj:getByte("pos2")

    gDispatchEvt(EVENT_ID_SPIRIT_EXCHANGE_POS,{equPos1=pos1,equPos2=pos2})
end
