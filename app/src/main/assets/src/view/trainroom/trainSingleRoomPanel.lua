
local TrainSingleRoomPanel=class("TrainSingleRoomPanel",UILayer)

function TrainSingleRoomPanel:ctor(roomid)
  self:init("ui/ui_xunlian_single.map");
  self.roomid = roomid;
  self.inRoom = false;
  self:refreshInfo();

  local function __update()
    self:updateTime();
  end
  self:scheduleUpdate(__update,1);


  for i=1,20 do
    local sandbag = self:getNode("sandbag"..i);
    if sandbag then
      local fla = gCreateFlaDelay(math.random(0,5),"ui_xunlian_shabao",1);
      self:replaceNode("sandbag"..i,fla,true);
    end
  end

  self:setLabelString("txt_exp_per",Data.getExpPerMin(roomid));
  self:resetLayOut();
  self:resetAdaptNode();
end

function TrainSingleRoomPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function TrainSingleRoomPanel:refreshInfo()

  local isInRoom = Data.isInTrainRoom(self.roomid);
  self.inRoom = isInRoom;
  self:getNode("txt_name"):setVisible(isInRoom);
  self:getNode("bg_time"):setVisible(Data.isInTraining());
  self:getNode("flag_me"):setVisible(isInRoom);
  self:getNode("bg_exp"):setVisible(isInRoom);

  if isInRoom then
    self:setLabelString("txt_name",getLvReviewName("Lv.")..Data.getCurLevel().." "..Data.getCurName());
    gCreateRoleRunFla(Data.getCurIcon(),self:getNode("bg_role"),1.0,false,nil,Data.getCurWeapon(),Data.getCurAwake(),Data.getCurHalo());
    self:refreshGetExp();

    local fla = gCreateFla("ui_xunlian_a_shuiche1",1);
    self:replaceNode("flag_wheel",fla);
  else
    self:getNode("bg_role"):removeAllChildren();

    local fla = gCreateFla("ui_xunlian_a_shuiche2",1);
    self:replaceNode("flag_wheel",fla);
  end

  self:setLabelString("txt_left_times",Data.trainroom.myselfInfo.leftLootTimes.."/"..Data.trainroom.freeTimesOneDay);
  self.train_lefttime = Data.trainroom.myselfInfo.curEndtime - gGetCurServerTime();
  
  if(Data.isInTraining())then
    self:updateTime();
    self:resetAdaptNode();
    self:resetLayOut();
  end
end

function TrainSingleRoomPanel:refreshGetExp()
  local exp = Data.getExpInTrainRoom();
  self:setLabelString("txt_exp",exp);
end

function TrainSingleRoomPanel:updateTime()

    if(self.train_lefttime > 0) then
      self.train_lefttime = Data.trainroom.myselfInfo.curEndtime - gGetCurServerTime();
      self:refreshTrainTime();
    end

end

function TrainSingleRoomPanel:refreshTrainTime()
  local sTime = gParserHourTime(self.train_lefttime);
  self:setLabelString("txt_time",sTime);

  if (self.train_lefttime <= 0) then
    --TODO: 提示获得的经验
    self:refreshInfo();
  end
end

function TrainSingleRoomPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
      self:onClose();  
    elseif target.touchName == "btn_sit" then
      if self.inRoom == false then
        if self.roomid == ROOM_VIP and Unlock.isUnlock(SYS_TRAINVIPROOM) == false then
          return
        end
        Data.sendSitDown(self.roomid,1);
      end  
    elseif target.touchName == "btn_buy" then
      Data.buyTrainLootTimes();
    elseif target.touchName == "btn_finish" then
      local onOk = function()
        Net.sendDrinkEnd();
      end
      gConfirmCancel(gGetWords("trainWords.plist","info_finish_tip"),onOk)  
    elseif target.touchName == "btn_rule" then
      gShowRulePanel(SYS_TRAINROOM);  
    end
end


function  TrainSingleRoomPanel:events()
    return {EVENT_ID_TRAIN_SIT,EVENT_ID_TRAIN_BUY}
end

function TrainSingleRoomPanel:dealEvent(event,param)

    if(event == EVENT_ID_TRAIN_SIT or event == EVENT_ID_TRAIN_BUY) then
      self:refreshInfo();
    end
end

return TrainSingleRoomPanel