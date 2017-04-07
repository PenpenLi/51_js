
local TrainRoomPanel=class("TrainRoomPanel",UILayer)
TrainRoomPanelData = {};
TrainRoomPanelData.info = {};

ROOM_NORMAL = 1;
ROOM_VIP = 2;

function TrainRoomPanel:ctor(data)
  loadFlaXml("ui_xunlian");
  self:init("ui/ui_xunlian_enter.map");
  self.isBlackBgVisible=false  
  self.roomPos = {};
  for i=1,3 do
    local posx = self:getNode("btn_room"..(i+2)):getPositionX();
    table.insert(self.roomPos,posx);
  end
  self:refreshInRoomCount(data);
  self:hideCloseModule();

  Unlock.checkFirstEnter(SYS_TRAINROOM);

  if isBanshuReview() then
    local str = gGetWords("labelWords.plist","lab_exp")
    for i = 1,3 do
      self:setLabelString("txt_expname"..i,str)
    end
  end
end

function TrainRoomPanel:hideCloseModule()
    self:getNode("btn_room2"):setVisible(not Module.isClose(SWITCH_VIP));
    self:getNode("bg_vip_exp"):setVisible(not Module.isClose(SWITCH_VIP));
end

function TrainRoomPanel:checkNewRoom()
    local curRoomOpenId = -1;
    for k,v in pairs(Data.trainroom.roomOpen) do
        if Data.getCurLevel() >= v.minlv and Data.getCurLevel() <= v.maxlv then
            curRoomOpenId = v.roomOpenId;
            
            self:replaceLabelString("txt_tip",v.minlv,v.maxlv);
            break;
        end
    end

    if (curRoomOpenId > 3 and not Data.getSysIsEnter(curRoomOpenId)) then
      Unlock.setSysEnter(curRoomOpenId);
      Story.showStory(161);
    end

end

function TrainRoomPanel:refreshInRoomCount(data)
  self.info = data;
  TrainRoomPanelData.info = data;

  local roomCount = table.getn(self.info) - 2;
  for i = 1,3 do
    self:getNode("btn_room"..(i+2)):setVisible(i<=roomCount);

    if roomCount == 1 then
      self:getNode("btn_room"..(i+2)):setPositionX(self.roomPos[i] + 130);
    elseif roomCount == 2 then
      self:getNode("btn_room"..(i+2)):setPositionX(self.roomPos[i] + 75);
    elseif roomCount == 3 then
      self:getNode("btn_room"..(i+2)):setPositionX(self.roomPos[i]);
    end

  end

  

  self:resetTrainRoomCurNum();
  local maxNum = 1;
  local index = 1;
  for key,var in pairs(self.info) do
    local data = DB.getTrainRoom(var.roomid);
    if data then
      if var.roomid == ROOM_NORMAL or var.roomid == ROOM_VIP then
        self:setLabelString("txt_room_num"..var.roomid,var.num.."/"..maxNum);
        self:setLabelString("txt_exp"..var.roomid,data.getexppercent.."%");
      else
        --local index = math.mod(var.roomid,10);
        maxNum = data.desknum;
        self:setLabelString("txt_room_num"..index+2,var.num.."/"..maxNum);
        self:setLabelString("txt_exp3",data.getexppercent.."%"); 
        index=index+1 
      end
    end
  end 


  self:checkNewRoom();
  self:resetMePosition();
end

function TrainRoomPanel:getRoomId(mapVarIndex)
  return self.info[mapVarIndex].roomid;
end

function TrainRoomPanel:onPopup()
  -- self:resetTrainRoomCurNum();
  -- self:refreshInRoomCount();
  if (TrainRoomPanelData.needRefresh) then
    Net.sendDrinkGetinfo();
  end
end
function TrainRoomPanel:onPushStack()
  -- body
  TrainRoomPanelData.needRefresh = true;
end

--修改普通房间和vip房间的数量
function TrainRoomPanel:resetTrainRoomCurNum()
  for key,var in pairs(self.info) do
    if var.roomid == ROOM_NORMAL or var.roomid == ROOM_VIP then
      var.num = 0;
      if Data.isInTrainRoom(var.roomid) then
        var.num = 1;
      end
    end
  end
end

function TrainRoomPanel:resetMePosition()
  self:getNode("flag_me"):setVisible(false);
  for key,var in pairs(self.info) do
    if Data.isInTrainRoom(var.roomid) then
      local roomEnter = self:getNode("btn_room"..key)
      local pos = cc.p(roomEnter:getPosition());
      pos.x = pos.x + roomEnter:getContentSize().width - 70;
      pos.y = pos.y + roomEnter:getContentSize().height - 70;
      self:getNode("flag_me"):setPosition(pos);
      self:getNode("flag_me"):setVisible(true);
      break;
    end
  end
end

function TrainRoomPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
      self:onClose();
    elseif target.touchName == "btn_rule" then
      gShowRulePanel(SYS_TRAINROOM);    
    elseif target.touchName == "btn_room1" or target.touchName == "btn_room_node_1"    then
      Net.sendDrinkRoominfo(ROOM_NORMAL);
    elseif target.touchName == "btn_room2" or target.touchName == "btn_room_node_2"    then
      if Unlock.isUnlock(SYS_TRAINVIPROOM) then
        Net.sendDrinkRoominfo(ROOM_VIP);
      end
    elseif target.touchName == "btn_room3"  or target.touchName == "btn_room_node_3"    then
      Net.sendDrinkRoominfo(self:getRoomId(3));
    elseif target.touchName == "btn_room4" then
      Net.sendDrinkRoominfo(self:getRoomId(4));
    elseif target.touchName == "btn_room5" then
      Net.sendDrinkRoominfo(self:getRoomId(5));        
    end
end


function  TrainRoomPanel:events()
    return {EVENT_ID_TRAIN_ENTER}
end

function TrainRoomPanel:dealEvent(event,param)

    if(event == EVENT_ID_TRAIN_ENTER) then
      print("EVENT_ID_TRAIN_ENTER");
      self:refreshInRoomCount(param);
    end
end

return TrainRoomPanel