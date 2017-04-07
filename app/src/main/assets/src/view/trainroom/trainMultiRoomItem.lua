
local TrainMultiRoomItem=class("TrainMultiRoomItem",UILayer)

function TrainMultiRoomItem:ctor(roomid,seatIndex)
    self:init("ui/ui_xunlian_multi_item.map");
    self.roomid = roomid;
    self.seatIndex = seatIndex;
    self:refreshStatus(nil);
    self.isMove = false;

    if isBanshuReview() then
        self:setLabelString("txt_king_des","至尊:经验+20%")
    end
-- if self.seatIndex == ADVANCED_SEAT_INDEX then
--   self:changeTexture("btn_sit","images/ui_xunlian/lun1_s2.png");
-- end
end
function TrainMultiRoomItem:setMultiRoomPanel(panel)
    self.multiRoomPanel = panel;
end

function TrainMultiRoomItem:onUILayerExit()
    self:unscheduleUpdateEx();
end

function TrainMultiRoomItem:refreshStatus(data)
    self.data = data;
    -- print_lua_table(self.data);
    self.hasUser = true;
    self.isMe = false;
    self.isProtecting = false;
    if self.data == nil then
        self.hasUser = false;
    end

    self:getNode("txt_name"):setVisible(self.hasUser);
    self:getNode("bg_power"):setVisible(self.hasUser);
    self:getNode("btn_loot"):setVisible(self.hasUser);
    self:getNode("layer_protect"):setVisible(self.hasUser);
    self:getNode("layer_me"):setVisible(self.hasUser);
    self:getNode("bg_role"):removeAllChildren();
    self:unscheduleUpdate();
    self:unscheduleUpdateEx();
    self.runFla = nil;

    if self.hasUser then
        self:setLabelString("txt_name",getLvReviewName("Lv.")..self.data.lv.." "..self.data.uname);
        self.runFla = gCreateRoleRunFla(Data.convertToIcon(self.data.icon),self:getNode("bg_role"),1.0,false,nil,self.data.show.wlv,self.data.show.wkn,self.data.show.halo);

        self.isMe = self.data.uid == Data.getCurUserId();
        self:getNode("bg_power"):setVisible(not self.isMe);
        self:getNode("layer_me"):setVisible(self.isMe);
        if self.isMe then
            Data.trainroom.myselfInfo.curSeatIndex = self.seatIndex;
            self:refreshGetExp();
            self:changeTexture("btn_loot","images/ui_word/x_hu.png");
        else
            self:setLabelString("txt_power",self.data.power);
            self:changeTexture("btn_loot","images/ui_word/x_qiang.png");
        end

        --保护状态
        self:refreshProtectInfo();

        -- local fla = gCreateFlaDelay(math.random(0,1),"ui_xunlian_b_shuiche1",1);
        local fla = gCreateFla("ui_xunlian_b_shuiche1",1);
        if self.seatIndex == ADVANCED_SEAT_INDEX then
            fla:replaceBone({"shuiche"},"images/ui_xunlian/lun1_s2.png");
            fla:setSpeedScale(3.0);
            self.runFla:setSpeedScale(3.0);
        end
        self:replaceNode("flag_wheel",fla);

        if(data.show.hlv)then
            -- self.data.show.hlv = 2;
            self:getNode("layer_honor"):setVisible(self.data.show.hlv > 0);
            if(self.data.show.hlv > 0)then
                Icon.changeHonorIcon(self:getNode("honor_icon"),self.data.show.hlv);
                Icon.changeHonorWord(self:getNode("honor_word"),self.data.show.hlv);
            end
        end
    else
        local fla = gCreateFlaDelay(math.random(0,1),"ui_xunlian_b_shuiche2",1);
        -- local fla = gCreateFla("ui_xunlian_b_shuiche2",1);
        if self.seatIndex == ADVANCED_SEAT_INDEX then
            fla:replaceBone({"shuiche"},"images/ui_xunlian/lun1_s2.png");
            fla:setSpeedScale(3.0);
        end
        self:replaceNode("flag_wheel",fla);
        self:getNode("layer_honor"):setVisible(false);
    end

    self:getNode("layer_king"):setVisible(self.seatIndex == ADVANCED_SEAT_INDEX);

end

function TrainMultiRoomItem:refreshProtectInfo()
    --保护状态
    self.isProtecting = false;
    if self.data.ptime > gGetCurServerTime() then
        self.isProtecting = true;
    end

    self:getNode("btn_loot"):setVisible(not self.isProtecting);
    self:getNode("layer_protect"):setVisible(self.isProtecting);
    self.runFla:removeChildByTag(100);
    if self.isProtecting then
        --TODO: 护甲效果
        -- buff_dunpai
        -- buff_fanghuzhao_c
        local shield = gCreateFla("buff_fanghuzhao_c",1);
        shield:setTag(100);
        self.runFla:addChild(shield);
        self:changeTexture("flag_protect_left","images/ui_xunlian/baohu_"..(self.data.ptype+1)..".png");
        self:changeTexture("flag_protect_right","images/ui_xunlian/baohu_"..(self.data.ptype+1)..".png");

        self.protect_lefttime = self.data.ptime - gGetCurServerTime();
        self:unscheduleUpdate();
        self:unscheduleUpdateEx();
        local function __update()
            self:updateTime();
        end
        self:scheduleUpdate(__update,1);
    end
end

function TrainMultiRoomItem:updateTime()
    if(self.protect_lefttime > 0) then
        self.protect_lefttime = self.data.ptime - gGetCurServerTime();
        self:refreshProtectTime();
    end
end

function TrainMultiRoomItem:refreshProtectTime()
    local sTime = gParserHourTime(self.protect_lefttime);
    self:setLabelString("txt_time",sTime);

    if (self.protect_lefttime <= 0) then
        self:refreshProtectInfo();
    end

end

function TrainMultiRoomItem:refreshGetExp()
    local exp = Data.getExpInTrainRoom();
    self:setLabelString("txt_exp",exp);
end

function TrainMultiRoomItem:onTouchMoved(target, touch)
    self.multiRoomPanel:onTouchMoved(target,touch);
    local offsetX=touch:getDelta().x;
    if math.abs(offsetX) > 5 then
        self.isMove = true;
    end
end

function TrainMultiRoomItem:onTouchEnded(target)
    if self.isMove then
        self.isMove = false;
        self.multiRoomPanel:onTouchEnded(target);
    else
        if target.touchName=="btn_sit"then
            if self.hasUser == false then
                Data.sendSitDown(self.roomid,self.seatIndex);
            end
        elseif target.touchName == "btn_loot" then
            if self.isMe then
                Panel.popUpVisible(PANEL_TRAINROOM_PROTECT);
            else
                if NetErr.isBelongRoom(self.roomid) and NetErr.DrinkLoot() then
                    self.data.roomid = self.roomid;
                    self.data.seatIndex = self.seatIndex;
                    Panel.popUpVisible(PANEL_TRAINROOM_QIANG,self.data);
                    -- Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_DRINK_LOOT,{roomid=self.roomid,seatIndex=self.seatIndex})

                end
            end
        end
    end

end


-- function  TrainMultiRoomItem:events()
--     return {EVENT_ID_BATH_REFUSERS}
-- end

-- function TrainMultiRoomItem:dealEvent(event,param)

--     if(event == EVENT_ID_BATH_REFUSERS) then
--       self:refreshUsers();
--     end
-- end

return TrainMultiRoomItem