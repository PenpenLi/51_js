
local TrainMultiRoomPanel=class("TrainMultiRoomPanel",UILayer)
--至尊位
ADVANCED_SEAT_INDEX = 1;

function TrainMultiRoomPanel:ctor(roomid)
	loadFlaXml("battle_buff");
  self:init("ui/ui_xunlian_multi.map");
  self:initRoom(roomid);
  -- self.roomid = roomid;
  -- self:initPos();
  -- self:refreshInfo();
  -- self:refreshRoomName();
  -- self.moveDistance = 0;

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
  
  -- self:setLabelString("txt_exp",Data.getExpPerMin(roomid));
  self:resetLayOut();
  self:resetAdaptNode();
end

function TrainMultiRoomPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function TrainMultiRoomPanel:initRoom(roomid)
  self.roomid = roomid;
  self:initPos();
  self:refreshInfo();
  self:refreshRoomName();
  self:refreshExp();
  self.moveDistance = 0;
end

function TrainMultiRoomPanel:refreshExp()
  	--至尊位置
  	local isAdvancedSeat = false;
	if Data.trainroom.myselfInfo.curRoomId > ROOM_VIP and Data.isInTrainRoom(self.roomid) and
	    Data.trainroom.myselfInfo.curSeatIndex == ADVANCED_SEAT_INDEX then
	    isAdvancedSeat = true;
	end

  	self:setLabelString("txt_exp",Data.getExpPerMin(self.roomid,isAdvancedSeat));  		
end

function TrainMultiRoomPanel:initPos()
	self.layer_pos = self:getNode("layer_pos");
	self.layer_pos_startx = self.layer_pos:getPositionX();
	self.layer_wheels = self:getNode("layer_wheels");
	self.layer_wheels_startx = self.layer_wheels:getPositionX();

	local firstNodePosX = 0;
	local firstNodeToLastNodeDis = 0;
	local roomData = DB.getTrainRoom(self.roomid);
	self.maxNum = roomData.desknum;
	-- self.maxNum = 8;
	self.seats = {};
	for i=1,self.maxNum do
		local node = self:getNode("pos"..i);
		node:removeAllChildren(true);
		if node then
			local uiLayer = TrainMultiRoomItem.new(self.roomid,i);
			uiLayer:setMultiRoomPanel(self);
			uiLayer:refreshStatus(self:getSeatData(i));
			uiLayer:setAnchorPoint(cc.p(0.5,-0.75));
			node:addChild(uiLayer);
			table.insert(self.seats,uiLayer);
			-- local pos = node:getPositionX();
			-- local pos = gGetPositionInDesNode(self.layer_pos:getParent(),node);
			if i == 5 then
				firstNodePosX = node:getPositionX();
			else
				firstNodeToLastNodeDis = node:getPositionX() - firstNodePosX + 100 + uiLayer:getContentSize().width;
			end
		end
	end

	self.layer_pos_endx = self.layer_pos_startx - firstNodeToLastNodeDis + gGetScreenWidth();
	self.layer_wheels_endx = self.layer_wheels_startx - firstNodeToLastNodeDis + gGetScreenWidth();

	-- print("startX = "..self.layer_pos_startx);
	-- print("endX = "..self.layer_pos_endx);
end

function TrainMultiRoomPanel:refreshRoomName()

	local roomCount = table.getn(TrainRoomPanelData.info);
	self.roomIndex = 0;
	for i=3,roomCount do
		if(TrainRoomPanelData.info[i].roomid == self.roomid) then
			self.roomIndex = i;
			break;
		end
	end

	self:replaceLabelString("txt_romm_name",self.roomIndex-2);
end

function TrainMultiRoomPanel:onNextRoom()
	local roomCount = table.getn(TrainRoomPanelData.info);
	-- print("roomIndex = "..self.roomIndex);
	if(self.roomIndex>=roomCount)then
		self.roomIndex = 3;
	else
		self.roomIndex = self.roomIndex + 1;	
	end
	-- print("next roomIndex = "..roomIndex);
	local enterRoomId = TrainRoomPanelData.info[self.roomIndex].roomid;
	TrainRoomPanelData.changeRoom = true;
	-- print("enterRoomId = "..enterRoomId);
	Net.sendDrinkRoominfo(enterRoomId);	
end

function TrainMultiRoomPanel:onPreRoom()
	local roomCount = table.getn(TrainRoomPanelData.info);
	-- print("roomIndex = "..self.roomIndex);
	if(self.roomIndex<=3)then
		self.roomIndex = roomCount;
	else
		self.roomIndex = self.roomIndex - 1;	
	end
	-- print("next roomIndex = "..roomIndex);
	local enterRoomId = TrainRoomPanelData.info[self.roomIndex].roomid;
	TrainRoomPanelData.changeRoom = true;
	print("enterRoomId = "..enterRoomId);
	Net.sendDrinkRoominfo(enterRoomId);	
end

function TrainMultiRoomPanel:refreshPosInfo()
	for i=1,self.maxNum do
		self:refreshPosInfoWithSeatIndex(i);
		-- local data = self:getSeatData(i);
		-- self.seats[i]:refreshStatus(data);
	end
	self:refreshExp();
end

function TrainMultiRoomPanel:refreshPosInfoWithSeatIndex(seatIndex)
	if seatIndex > 0 then
		local data = self:getSeatData(seatIndex);
		self.seats[seatIndex]:refreshStatus(data);
	end
end

function TrainMultiRoomPanel:getSeatData(seatIndex)
	for key,var in pairs(Data.trainroom.seatList) do
		if var.didx == seatIndex then
			return var;
		end
	end
	return nil;
end

function TrainMultiRoomPanel:refreshInfo()

  local isInRoom = Data.isInTrainRoom(self.roomid);
  self.inRoom = isInRoom;
  self:getNode("bg_time"):setVisible(Data.isInTraining());

  self:setLabelString("txt_left_times",Data.trainroom.myselfInfo.leftLootTimes.."/"..Data.trainroom.freeTimesOneDay);
  self.train_lefttime = Data.trainroom.myselfInfo.curEndtime - gGetCurServerTime();

	if(Data.isInTraining())then
	    self:updateTime();
	    self:resetAdaptNode();
	    self:resetLayOut();
	end
end
function TrainMultiRoomPanel:updateTime()

    if(self.train_lefttime > 0) then
      self.train_lefttime = Data.trainroom.myselfInfo.curEndtime - gGetCurServerTime();
      self:refreshTrainTime();
    end

end

function TrainMultiRoomPanel:refreshTrainTime()
  local sTime = gParserHourTime(self.train_lefttime);
  self:setLabelString("txt_time",sTime);

  if (self.train_lefttime <= 0) then
    --TODO: 提示获得的经验
    self:refreshInfo();
  end
end

function TrainMultiRoomPanel:moveLayer(offsetX)
	-- print("offsetX = "..offsetX);
	self:moveLayerPos(offsetX);

	if self:checkBorder() == false then
		self:moveLayerWheels(offsetX*0.5);
	end

end

function TrainMultiRoomPanel:moveLayerPos(offsetX)
	local newPosX = self.layer_pos:getPositionX()+offsetX;
	if newPosX > self.layer_pos_startx then
		newPosX = self.layer_pos_startx;
		-- print("start");
	elseif newPosX < self.layer_pos_endx then
		newPosX = self.layer_pos_endx;	
		-- print("end");
	end
	self.layer_pos:setPositionX(newPosX);	
end
function TrainMultiRoomPanel:moveLayerWheels(offsetX)
	local newPosX = self.layer_wheels:getPositionX()+offsetX;
	if newPosX > self.layer_wheels_startx then
		newPosX = self.layer_wheels_startx;
		-- print("start");
	elseif newPosX < self.layer_wheels_endx then
		newPosX = self.layer_wheels_endx;	
		-- print("end");
	end
	self.layer_wheels:setPositionX(newPosX);	
end


function TrainMultiRoomPanel:deaccelerateMoveing()

    -- print("self.moveDistance = "..self.moveDistance);
    if self.stopSchedule and self.stopSchedule == true then
        -- print("stop");
        self.moveDistance = 0;
        self.layer_pos:unscheduleUpdate()
    end

    self.moveDistance = self.moveDistance * 0.9;
    self:moveLayer(self.moveDistance);

    if self:checkBorder() or math.abs(self.moveDistance) <= 0.5 then
        self.moveDistance = 0;
        self.layer_pos:unscheduleUpdate()
    end

end


function TrainMultiRoomPanel:checkBorder()
	local posX = self.layer_pos:getPositionX();
	if posX >= self.layer_pos_startx then
		posX = self.layer_pos_startx;
		print("start");
		return true;
	elseif posX <= self.layer_pos_endx then
		posX = self.layer_pos_endx;	
		print("end");
		return true;
	end
	return false;
end

function TrainMultiRoomPanel:onTouchBegan(target, touch)
	self.stopSchedule = true;
    return true;
end

function TrainMultiRoomPanel:onTouchMoved(target, touch)

	-- print("onTouchMoved");
    local offsetX=touch:getDelta().x;

    if math.abs(offsetX) > 3 then
        self.moveDistance = offsetX * 0.8;
    end

    self:moveLayer(offsetX);
end

function TrainMultiRoomPanel:onTouchEnded(target)

	self.stopSchedule = false;
    if target.touchName=="btn_close"then
      self:onClose(); 
    elseif target.touchName == "btn_buy" then
		Data.buyTrainLootTimes();
    elseif target.touchName == "btn_finish" then
	    local onOk = function()
	      Net.sendDrinkEnd();
        end
        gConfirmCancel(gGetWords("trainWords.plist","info_finish_tip"),onOk)    
    elseif target.touchName == "btn_rule" then
    	gShowRulePanel(SYS_TRAINROOM);
    elseif target.touchName == "btn_next" then
    	self:onNextRoom();
    elseif target.touchName == "btn_pre" then
    	self:onPreRoom();
    elseif math.abs(self.moveDistance) > 0 then
        local updateMoving = function()
            self:deaccelerateMoveing();
        end
        self.layer_pos:scheduleUpdateWithPriorityLua(updateMoving,1)  
    end
end

function  TrainMultiRoomPanel:events()
    return {EVENT_ID_TRAIN_SIT,
    		EVENT_ID_TRAIN_BUY,
    		EVENT_ID_TRAIN_PROTECT,
    		EVENT_ID_TRAIN_REFRESH_SEATELIST,
    		EVENT_ID_TRAIN_REFRESH_ONESEAT,
    		EVENT_ID_TRAIN_CHANGEROOM}
end

function TrainMultiRoomPanel:dealEvent(event,param)

    if(event == EVENT_ID_TRAIN_BUY) then
      self:refreshInfo();
    elseif event == EVENT_ID_TRAIN_SIT then
	  self:refreshPosInfo();
      self:refreshInfo();
    elseif event == EVENT_ID_TRAIN_REFRESH_ONESEAT then
      self:refreshPosInfoWithSeatIndex(param);
    elseif event == EVENT_ID_TRAIN_REFRESH_SEATELIST then
      self:refreshPosInfo();
    elseif event == EVENT_ID_TRAIN_CHANGEROOM then
    	-- TrainRoomPanelData.needRefresh = false;
    	-- self:onClose();
    	-- Panel.popUp(PANEL_TRAINROOM_MULTI,TrainRoomPanelData.roomid);
    	-- TrainRoomPanelData.needRefresh = true;


		self.layer_pos:setPositionX(self.layer_pos_startx);
		self.layer_wheels:setPositionX(self.layer_wheels_startx);
		self:initRoom(TrainRoomPanelData.roomid);

    end
end

return TrainMultiRoomPanel