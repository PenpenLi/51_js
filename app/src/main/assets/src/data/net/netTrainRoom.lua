--[[
drink.getinfo 获取酒店界面信息
发送参数:
  无:
接收参数:
  |-(Array)list  星级房间信息（1星到5星）
    |-(Byte)num  当前人数
    |-(Int)rid  房间id
]]

DRINK_GETINFO = "drink.getinfo"

function Net.sendDrinkGetinfo()
  local obj = MediaObj:create();
  Net.sendExtensionMessage(obj, DRINK_GETINFO);
end


function Net.rec_drink_getinfo(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  local rec_data = {}
  if ret == 0 then
    rec_data.list = {};
    rec_data.haskey_list = obj:containsKey("list");
    local list_ = obj:getArray("list");
    if list_ ~= nil then
      for i = 0,list_:count()-1 do
        local list_obj = list_:getObj(i);
        local list_data = {};
        if list_obj ~= nil then
          list_obj = tolua.cast(list_obj,"MediaObj");
          list_data.num = list_obj:getByte("num");
          list_data.haskey_num = list_obj:containsKey("num");
          list_data.roomid = list_obj:getInt("rid");
          table.insert(rec_data.list,list_data)
        end
      end
    end
    --排序
    local sort = function(room1,room2)
      if room1.roomid < room2.roomid then
        return true;
      end
      return false;
    end

    table.sort(rec_data.list,sort);

    Data.trainroom.roomList = rec_data.list;
    Data.trainroom.myselfInfo.curRoomId = obj:getInt("ridx");
    Data.trainroom.myselfInfo.curEndtime = obj:getInt("endtime");
    -- print_lua_table(rec_data);
    if Panel.isTopPanel(PANEL_TRAINROOM) then
      print("refresh");
      gDispatchEvt(EVENT_ID_TRAIN_ENTER,Data.trainroom.roomList);
    else
      print("enter");
      Panel.popUp(PANEL_TRAINROOM,Data.trainroom.roomList);
    end
  end
-- call_back_rec_drink_getinfo(ret,rec_data);

end



--[[
drink.roominfo 房间信息
发送参数:
  |-(Int)ridx  房间序号
接收参数:
  |-(Int)begintime  起始时间
  |-(Int)endtime  结束时间
  |-(Byte)loot  剩余抢夺次数
  |-(Byte)buy  今日购买次数
  |-(Array)list  酒桌列表（星级房间才会有此信息）
    |-(Byte)didx  酒桌序号（从1开始，1表示至尊酒桌）
    |-(Long)uid  用户ID
    |-(String)uname  用户名称
    |-(Int)icon  用户时装
    |-(Short)lv  用户等级
    |-(Int)power  用户战力
    |-(String)fname  用户家族名称
    |-(Int)ptime  保护结束时间
    |-(Byte)ptype  保护类型
]]

DRINK_ROOMINFO = "drink.roominfo"

function Net.sendDrinkRoominfo(ridx)
  local obj = MediaObj:create();
  obj:setInt("ridx",ridx);
  Net.sendExtensionMessage(obj, DRINK_ROOMINFO);
  TrainRoomPanelData.roomid = ridx;
end


function Net.rec_drink_roominfo(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  local rec_data = {}
  if ret == 0 then
    rec_data.roomid = TrainRoomPanelData.roomid;
    rec_data.begintime = obj:getInt("begintime");
    rec_data.haskey_begintime = obj:containsKey("begintime");
    rec_data.endtime = obj:getInt("endtime");
    rec_data.haskey_endtime = obj:containsKey("endtime");
    rec_data.loot = obj:getByte("loot");
    rec_data.haskey_loot = obj:containsKey("loot");
    rec_data.buy = obj:getByte("buy");
    rec_data.haskey_buy = obj:containsKey("buy");
    rec_data.list = {};
    rec_data.haskey_list = obj:containsKey("list");
    local list_ = obj:getArray("list");
    if list_ ~= nil then
      for i = 0,list_:count()-1 do
        local list_obj = list_:getObj(i);
        local list_data = {};
        if list_obj ~= nil then
          list_data = Net.parserTrainRoomSeat(list_obj);
          table.insert(rec_data.list,list_data)
        end
      end
    end

    Data.trainroom.seatList = rec_data.list;
    Data.updateMyselfInfo(rec_data.begintime,rec_data.endtime,nil,nil,rec_data.buy,rec_data.loot);

    if gMainBgLayer == nil then
        Scene.enterMainScene();
    end

    if TrainRoomPanelData.roomid == ROOM_NORMAL or TrainRoomPanelData.roomid == ROOM_VIP then
      Panel.popUp(PANEL_TRAINROOM_SINGLE,TrainRoomPanelData.roomid);
    else
        if Panel.isOpenPanel(PANEL_TRAINROOM_MULTI) then
          if(TrainRoomPanelData.changeRoom) then
            gDispatchEvt(EVENT_ID_TRAIN_CHANGEROOM);
            TrainRoomPanelData.changeRoom = false;
          else
            gDispatchEvt(EVENT_ID_TRAIN_REFRESH_SEATELIST);
          end
        else
          Panel.popUp(PANEL_TRAINROOM_MULTI,TrainRoomPanelData.roomid);
        end      
    end

  end

  -- call_back_rec_drink_roominfo(ret,rec_data);

end



--[[
drink.drink 喝花酒（客户端需要添加酒桌用户信息，如果该房间其他酒桌有该用户信息，则需要移除）
发送参数:
  |-(Int)ridx  房间序号
  |-(Byte)didx  酒桌序号（从1开始，1表示至尊酒桌）
接收参数:
  |-(Int)begintime  起始时间
  |-(Int)endtime  结束时间
  |-(Obj)desk  该座位已经有人就会下发
]]

DRINK_DRINK = "drink.drink"

function Net.sendDrinkDrink(ridx,didx)
  local obj = MediaObj:create();
  obj:setInt("ridx",ridx);
  obj:setByte("didx",didx);
  Net.sendExtensionMessage(obj, DRINK_DRINK);
  TrainRoomPanelData.roomid = ridx;
  TrainRoomPanelData.seatindex = didx;
  if (TalkingDataGA) then
    gLogEvent("drink.drink")
  end
end


function Net.rec_drink_drink(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  local rec_data = {}
  if ret == 0 then

    if obj:containsKey("desk") then
      -- local seatData = Net.parserTrainRoomSeat(obj:getObj("desk"));
      -- local oldSeatInx,newSeatIndex = Data.addTrainSeat(seatData);
      gShowNotice(gGetWords("trainWords.plist","tip1"));

      -- -- print("oldSeatInx = "..oldSeatInx);
      -- -- print("newSeatIndex = "..newSeatIndex);
      -- if oldSeatInx > 0 then
      --   gDispatchEvt(EVENT_ID_TRAIN_REFRESH_ONESEAT,oldSeatInx);
      -- end
      -- gDispatchEvt(EVENT_ID_TRAIN_REFRESH_ONESEAT,newSeatIndex);
      Net.sendDrinkRoominfo(TrainRoomPanelData.roomid); 
    else

      rec_data.begintime = obj:getInt("begintime");
      rec_data.haskey_begintime = obj:containsKey("begintime");
      rec_data.endtime = obj:getInt("endtime");
      rec_data.haskey_endtime = obj:containsKey("endtime");

      Data.sitdown(TrainRoomPanelData.roomid,TrainRoomPanelData.seatindex);
      Data.updateMyselfInfo(rec_data.begintime,rec_data.endtime);

      gDispatchEvt(EVENT_ID_TRAIN_SIT);
    end
  end

  -- call_back_rec_drink_drink(ret,rec_data);

end

--[[
drink.buy 购买抢夺次数
发送参数:
  无:
接收参数:
  |-(Obj)reward  奖励信息
]]

DRINK_BUY = "drink.buy"

function Net.sendDrinkBuy(num)
  local obj = MediaObj:create();
  obj:setInt("num",num);
  TrainRoomPanelData.buytimes = num;
  Net.sendExtensionMessage(obj, DRINK_BUY);
end


function Net.rec_drink_buy(evt)
local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  local rec_data = {}
  if ret == 0 then
    Net.updateReward(obj:getObj("reward"),0);

    Data.trainroom.myselfInfo.buyTimes = Data.trainroom.myselfInfo.buyTimes + TrainRoomPanelData.buytimes;
    Data.trainroom.myselfInfo.leftLootTimes = Data.trainroom.myselfInfo.leftLootTimes + TrainRoomPanelData.buytimes;

    gDispatchEvt(EVENT_ID_TRAIN_BUY);
  end
-- call_back_rec_drink_buy(ret,rec_data);

end

--[[
drink.end 结束喝酒
发送参数:
  无:
接收参数:
  |-(Obj)reward  奖励信息
]]

DRINK_END = "drink.end"

function Net.sendDrinkEnd()
  local obj = MediaObj:create();
  Net.sendExtensionMessage(obj, DRINK_END);
end


function Net.rec_drink_end(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  local rec_data = {}
  if ret == 0 then
    Net.updateReward(obj:getObj("reward"),2);

    if Data.isInTrainRoom(TrainRoomPanelData.roomid) then
      --清空
      for key,var in pairs(Data.trainroom.seatList) do
        if var.uid == Data.getCurUserId() then
          table.remove(Data.trainroom.seatList,key);
          break;
        end
      end

    end

    Data.updateMyselfInfo(0,0,0,0);
    
    gDispatchEvt(EVENT_ID_TRAIN_SIT);
  end

  -- call_back_rec_drink_end(ret,rec_data);

end


--[[
drink.loot 抢位置
发送参数:
  |-(Byte)ridx  房间序号
  |-(Byte)didx  酒桌序号（从1开始，1表示至尊酒桌）
接收参数:
  |-(Obj)bat  战斗信息（没有战斗信息表示该酒桌没人占领）
  |-(Int)begintime  起始时间
  |-(Int)endtime  结束时间
]]

DRINK_LOOT = "drink.loot"

function Net.sendDrinkLoot(ridx,didx)
  local obj = MediaObj:create();
  obj:setInt("ridx",ridx);
  obj:setByte("didx",didx);
  Net.sendExtensionMessage(obj, DRINK_LOOT);

  TrainRoomPanelData.roomid = ridx;
  TrainRoomPanelData.seatindex = didx;
  if (TalkingDataGA) then
    gLogEvent("drink.loot")
  end
end


function Net.rec_drink_loot(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  -- local rec_data = {}
  if ret == 0 then
    if obj:containsKey("bat") then
      -- Panel.pushRePopupPanel(PANEL_TRAINROOM,Data.trainroom.roomList);
      local func = function()
        Net.sendDrinkRoominfo(TrainRoomPanelData.roomid)
      end
      Panel.pushRePopupPre(func);
      -- Panel.pushRePopupPanel(PANEL_TRAINROOM_MULTI,TrainRoomPanelData.roomid);
      Net.parserBattle(obj:getObj("bat"),BATTLE_TYPE_TRAIN);

      if obj:containsKey("begintime") or obj:containsKey("endtime") then
          --成功抢到位置
          Data.sitdown(TrainRoomPanelData.roomid,TrainRoomPanelData.seatindex);
          Data.updateMyselfInfo(obj:getInt("begintime"),obj:getInt("endtime"));
      
      end
    else
      --没人，可坐下
      gShowNotice(gGetWords("trainWords.plist","info_user_loot_leave"));
      Data.sitdown(TrainRoomPanelData.roomid,TrainRoomPanelData.seatindex);
      Data.updateMyselfInfo(obj:getInt("begintime"),obj:getInt("endtime"));
      gDispatchEvt(EVENT_ID_TRAIN_SIT);
    end
  elseif ret == 25 then
    Net.sendDrinkRoominfo(TrainRoomPanelData.roomid);  
  end


end



--[[
drink.protect 保护
发送参数:
  |-(Byte)type  保护类型 0--1个小时 1--4个小时
接收参数:
  |-(Obj)reward  奖励信息
  |-(Int)ptime  保护结束时间
  |-(Byte)ptype  保护类型
]]

DRINK_PROTECT = "drink.protect"

function Net.sendDrinkProtect(type)
  local obj = MediaObj:create();
  obj:setByte("type",type);
  Net.sendExtensionMessage(obj, DRINK_PROTECT);
end


function Net.rec_drink_protect(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  local rec_data = {}
  if ret == 0 then
    Net.updateReward(obj:getObj("reward"),0);
    rec_data.ptime = obj:getInt("ptime");
    rec_data.haskey_ptime = obj:containsKey("ptime");
    rec_data.ptype = obj:getByte("ptype");
    rec_data.haskey_ptype = obj:containsKey("ptype");

    for key,var in pairs(Data.trainroom.seatList) do
      if var.uid == Data.getCurUserId() then
        var.ptime = rec_data.ptime;
        var.ptype = rec_data.ptype;
        break;
      end
    end

    gDispatchEvt(EVENT_ID_TRAIN_REFRESH_ONESEAT,Data.trainroom.myselfInfo.curSeatIndex);
  elseif ret == 10 then
    Net.sendDrinkRoominfo(TrainRoomPanelData.roomid);
  end

  -- call_back_rec_drink_protect(ret,rec_data);

end






