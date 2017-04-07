
local TrainRoomQiangPanel=class("TrainRoomQiangPanel",UILayer)

function TrainRoomQiangPanel:ctor(data)
    self.appearType = 1;
    self:init("ui/ui_xunlian_qiang.map")
    self.user = data;
    -- self.roomid = roomid;
    -- self.seatIndex = seatIndex;
    -- print_lua_table(self.user);
    -- self:setLabelString("txt_last_icon_dia",Data.bath.gBathRefreshLastNeedDia);

    self:setLabelString("txt_level",data.lv);
    self:setLabelString("txt_power",data.power);
    if data.fname ~= "" then
        self:setLabelString("txt_family",data.fname);
    end
    self:setLabelString("txt_name",data.uname);
    self:setTouchEnableGray("btn0",data.uid ~= Data.getCurUserId());

    gCreateRoleFla(Data.convertToIcon(data.icon),self:getNode("bg_role"),1.0,nil,nil,data.show.wlv,data.show.wkn,data.show.halo);

    if(data.show.hlv)then
        -- data.show.hlv = 2;
        self:getNode("layer_honor"):setVisible(data.show.hlv > 0);
        if(data.show.hlv > 0)then
            Icon.changeHonorIcon(self:getNode("honor_icon"),data.show.hlv);
            Icon.changeHonorWord(self:getNode("honor_word"),data.show.hlv);
        end
    end

    self:resetLayOut();
end

function TrainRoomQiangPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "btn0" then

        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_DRINK_LOOT,{roomid=self.user.roomid,seatIndex=self.user.seatIndex})
        -- if gBathInfo.molesttime - gGetCurServerTime() > 0 then
        --     gShowCmdNotice("bath.molest",11);
        --     return;
        -- end
        -- if( self.user.bemolestnum >= Data.bath.gBathMolestTimes)then
        --     gShowCmdNotice("bath.molest",8);
        --     return;
        -- end
        -- Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_BATH_MOLEST,self.user.uid)
    end
end

return TrainRoomQiangPanel