
function Net.rec_rec_allbath(evt)
  local obj = evt.params:getObj("params");
  Net.updateAllBathObj(obj:getObj("allbath"));
end

function Net.updateAllBathObj(obj)
    if(obj == nil)then
      return;
    end
    allbath = tolua.cast(obj,"MediaObj");
    gBathInfo.all_uid = allbath:getLong("uid");
    gBathInfo.all_name = allbath:getString("name");
    gBathInfo.all_time = allbath:getInt("time");
    gBathInfo.all_coatid = allbath:getInt("icon");
    gBathInfo.show = Net.parserShowInfo(allbath:getObj("idetail"));
    -- gBathInfo.all_weaponLv = allbath:getInt("wlv");
    
    if(gMainBgLayer)then
      gMainBgLayer:checkBathInfo();
    end  
end

function Net.updateSceneArenaObj(obj)
    if(obj == nil)then
        return;
    end
    local arenaInfo = tolua.cast(obj,"MediaObj");
    gSceneArenaInfo.uid = arenaInfo:getLong("uid");
    gSceneArenaInfo.name = arenaInfo:getString("name"); 
    gSceneArenaInfo.icon = arenaInfo:getInt("icon");
    gSceneArenaInfo.show = Net.parserShowInfo(arenaInfo:getObj("idetail"));

    if(gMainBgLayer)then
      gMainBgLayer:checkArenaInfo();
    end 
   
end


function Net.sendBathGetInfo()
   local obj = MediaObj:create();
   Net.sendExtensionMessage(obj, "bath.getinfo");
 end

 function Net.rec_bath_getinfo(evt)
    local obj = evt.params:getObj("params")
    local ret = obj:getByte("ret");
    if ret == 0 then
      local bath = obj:getObj("bath");
      bath = tolua.cast(bath,"MediaObj");
      gBathInfo.type = bath:getByte("type");
      gBathInfo.bathtime = bath:getInt("bathtime");
      gBathInfo.reftype = bath:getByte("reftype");
      gBathInfo.refnum = bath:getByte("refnum");
      gBathInfo.bathnum = bath:getByte("bathnum");
      gBathInfo.molestnum = bath:getByte("molestnum");
      gBathInfo.molesttime = bath:getInt("molesttime");
      gBathInfo.bemolestnum = bath:getByte("bemolestnum");
      gBathInfo.attrnum = bath:getByte("attrnum");
      
      if obj:containsKey("allbath") then
        local allbath = obj:getObj("allbath");
        Net.updateAllBathObj(allbath)
        -- allbath = tolua.cast(allbath,"MediaObj");
        -- gBathInfo.all_uid = allbath:getLong("uid");
        -- gBathInfo.all_name = allbath:getString("name");
        -- gBathInfo.all_time = allbath:getInt("time");
        -- gBathInfo.all_coatid = allbath:getInt("icon");    
      else
        gBathInfo.all_uid = 0;
        gBathInfo.all_time = 0;
      end

      if (obj:containsKey("mul")) then
          gBathInfo.mul = obj:getInt("mul");
      else
          gBathInfo.mul = 0
      end
      
      
      gBathInfo.list = getBathUserList(obj:getArray("list"));
      
      -- print_lua_table(gBathInfo);
      -- Panel.popUp(PANEL_BATH);
      gEnterBath();
      -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_getinfo); 
      
    end
end              

function getBathUserList(list)
  local bathlist = {}
  if list then
    for i = 0,list:count()-1 do
      local obj = list:getObj(i);
      local bathuser = getBathUser(obj);
      table.insert(bathlist,bathuser);
    end
  end
  
  return bathlist;
                    
end

function getBathUser(obj)
  obj = tolua.cast(obj,"MediaObj");
  local bathuser = {};
  bathuser.id = obj:getLong("id");
  bathuser.name = obj:getString("name");
  bathuser.type = obj:getByte("type");
  bathuser.icon = Data.convertToIcon(obj:getInt("icon"));
  bathuser.show = Net.parserShowInfo(obj:getObj("idetail"));
  return bathuser;
end

 function Net.sendBathRefUser()
   local obj = MediaObj:create();
   Net.sendExtensionMessage(obj, "bath.refuser");
 end
 
function Net.rec_bath_refuser(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
      gBathInfo.list = getBathUserList(obj:getArray("list"));
      
      if obj:containsKey("allbath") then
        local allbath = obj:getObj("allbath");
        Net.updateAllBathObj(allbath);
        -- allbath = tolua.cast(allbath,"MediaObj");
        -- gBathInfo.all_uid = allbath:getLong("uid");
        -- gBathInfo.all_name = allbath:getString("name");
        -- gBathInfo.all_time = allbath:getInt("time");
        -- gBathInfo.all_coatid = allbath:getInt("icon");        
      else
        gBathInfo.all_uid = 0;
      end

      gDispatchEvt(EVENT_ID_BATH_REFUSERS);
      -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_refreshuser); 
    end
end

 function Net.sendBathFinish()
   local obj = MediaObj:create();
   Net.sendExtensionMessage(obj, "bath.finish");
 end
 
function Net.rec_bath_finish(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
      Net.updateReward(obj:getObj("reward"),2);
      gBathInfo.bathtime = 0;
      gBathInfo.reftype = 1;
      for i,value in pairs(gBathInfo.list) do
        if value.id == Data.getCurUserId() then
          table.remove(gBathInfo.list, i);
          break;
        end
      end
      gDispatchEvt(EVENT_ID_BATH_FINISH);
    end
end

 function Net.sendBathRefType(last)
    local obj = MediaObj:create();
    obj:setBool("last",last);
    Data.bath.gBathRefTypeLast = last
    Net.sendExtensionMessage(obj, "bath.reftype");
 end
 
function Net.rec_bath_reftype(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
      gBathInfo.reftype = obj:getByte("reftype");
      Net.updateReward(obj:getObj("reward"),0);
      
      if Data.bath.gBathRefTypeLast == false then
        gBathInfo.refnum = gBathInfo.refnum+1;
      end
      gDispatchEvt(EVENT_ID_BATH_REFRESHTYPE);
      -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_refresh_girl_type); 
      
    end
end

 function Net.sendBathAddAttr()
   local obj = MediaObj:create();
   Net.sendExtensionMessage(obj, "bath.addattr");
 end
 
function Net.rec_bath_addattr(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
      Net.updateReward(obj:getObj("reward"),0);
      
      gBathInfo.attrnum = gBathInfo.attrnum + 1;
      gDispatchEvt(EVENT_ID_BATH_ADDATRR);
    end
end

 function Net.sendBathUserInfo(uid)
   local obj = MediaObj:create();
   obj:setLong("uid",uid);
   Net.sendExtensionMessage(obj, "bath.userinfo");
 end
 
function Net.rec_bath_userinfo(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
      local user = {};
      user.uid = obj:getLong("uid");
      user.name = obj:getString("name");
      user.type = obj:getByte("type");
      user.level = obj:getShort("level");
      user.power = obj:getInt("power");
      user.bemolestnum = obj:getByte("bemolestnum");
      user.fname = obj:getString("fname");
      user.icon = obj:getInt("icon");
      user.vip = obj:getByte("vip"); 
      user.show = Net.parserShowInfo(obj:getObj("idetail"));
      
      Panel.popUpVisible(PANEL_BATH_MOLEST,user);
      -- gDispatchEvt(EVENT_ID_BATH_GETUSERINFO,user);
      -- EventListener:sharedEventListener():handleLuaEvent(c_event_activity_bath_userinfo,user);
    elseif ret == 12 then
      Net.sendBathRefUser();
      -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_refreshuser);   
    end
end

 function Net.sendBathMolest(uid)
   local obj = MediaObj:create();
   obj:setLong("uid",uid);
   Net.sendExtensionMessage(obj, "bath.molest");

   if (TalkingDataGA) then
    gLogEvent("bath.rob")
   end
 end
 
function Net.rec_bath_molest(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
        -- ClientMsgRecv:shared():updateBattleInfo(obj:getObj("bat"));
        -- ClientMsgRecv:shared():updateRewardInfo(obj:getObj("reward"),true);
        gBathInfo.molestnum = gBathInfo.molestnum + 1;
        gBathInfo.molesttime = obj:getInt("molesttime");
        local rewards=Net.updateReward(obj:getObj("reward"),0);
        Panel.pushRePopupPanel(PANEL_BATH);
        Net.parserBattle(obj:getObj("bat"),BATTLE_TYPE_BATH);
        Battle.reward.shows=rewards 
        -- EventListener:sharedEventListener():handleEvent(c_event_enter_battle);
    elseif ret == 12 then
        Net.sendBathRefUser();
    -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_refreshuser);   
    end
end

 function Net.sendBathCall()
   local obj = MediaObj:create();
   Net.sendExtensionMessage(obj, "bath.call");
 end
 
function Net.rec_bath_call(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  if ret == 0 then
    Net.updateReward(obj:getObj("reward"),2);
    
    if obj:containsKey("allbath") then
      local allbath = obj:getObj("allbath");
      Net.updateAllBathObj(allbath)
      -- allbath = tolua.cast(allbath,"MediaObj");
      -- gBathInfo.all_uid = allbath:getLong("uid");
      -- gBathInfo.all_name = allbath:getString("name");
      -- gBathInfo.all_time = allbath:getInt("time");    
      -- gBathInfo.all_coatid = allbath:getInt("icon");    
    else
      gBathInfo.all_uid = 0;
    end

    gDispatchEvt(EVENT_ID_BATH_CALL);
    -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_call);
    
  end
end

 function Net.sendBathMolestList()
   local obj = MediaObj:create();
   Net.sendExtensionMessage(obj, "bath.molestlist");
 end
 
function Net.rec_bath_molestlist(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  if ret == 0 then
      local list = obj:getArray("list");
      if list then
        gBathMolestList = {};
        for i = 0,list:count()-1 do
          local one_obj = list:getObj(i);
          one_obj = tolua.cast(one_obj,"MediaObj");
          local record = {};
          record.name = one_obj:getString("name");
          record.level = one_obj:getShort("level");
          record.coatid = one_obj:getInt("icon");
          record.gold = one_obj:getInt("gold");
          record.repu = one_obj:getInt("repu");
          record.time = one_obj:getInt("time");
          record.vid = one_obj:getLong("vid");
          table.insert(gBathMolestList,record);
        end
        
            --好友排序
      local function sortWithTime(buddy1,buddy2)
        local time1 = buddy1.time;
        local time2 = buddy2.time;
        if(time1 > time2) then
          return true;
        end
        return false;
      end
      table.sort(gBathMolestList,sortWithTime);

      gDispatchEvt(EVENT_ID_BATH_RECORD_LIST);
      -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_enter_record);
        
      end
--          ClientMsgRecv:shared():updateRewardInfo(obj:getObj("reward"));
    
  end
end


 function Net.sendBathVedio(battleid)
    local obj = MediaObj:create();
    obj:setLong("id",battleid);
    Net.sendExtensionMessage(obj, "bath.vedio");
 end
 
function Net.rec_bath_vedio(evt)
  local obj = evt.params:getObj("params");
  local ret = obj:getByte("ret");
  if ret == 0 then
    Net.parserBattle(obj:getObj("bat"),BATTLE_TYPE_BATH);
    -- ClientMsgRecv:shared():updateBattleInfo(obj:getObj("bat"),true);
    
    -- EventListener:sharedEventListener():handleEvent(c_event_enter_battle);
    
  end
end

 function Net.sendBathStart()
    local obj = MediaObj:create();
    Net.sendExtensionMessage(obj, "bath.start");
    if (TalkingDataGA) then
      gLogEvent("bath.start")
    end
 end
 
function Net.rec_bath_start(evt)
    local obj = evt.params:getObj("params");
    local ret = obj:getByte("ret");
    if ret == 0 then
        local bathuser = {};
        bathuser.id = Data.getCurUserId();
        bathuser.name = Data.getCurName();
        bathuser.type = gBathInfo.reftype;
        bathuser.icon = Data.getCurIcon();
        bathuser.show = {};
        bathuser.show.wlv = Data.getCurWeapon();
        bathuser.show.wkn = Data.getCurAwake();
        table.insert(gBathInfo.list,bathuser);
        gBathInfo.bathnum = gBathInfo.bathnum + 1;
        gBathInfo.bathtime = obj:getInt("bathtime");
        gDispatchEvt(EVENT_ID_BATH_START);
        -- EventListener:sharedEventListener():handleEvent(c_event_activity_bath_event_start); 
    end
end