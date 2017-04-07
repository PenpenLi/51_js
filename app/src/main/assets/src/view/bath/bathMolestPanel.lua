
local BathMolestPanel=class("BathMolestPanel",UILayer)

function BathMolestPanel:ctor(data)
    self.appearType = 1;
    self:init("ui/ui_bath_molest.map")
    self.user = data;
    -- print_lua_table(self.user);
    -- self:setLabelString("txt_last_icon_dia",Data.bath.gBathRefreshLastNeedDia);

    self:setLabelString("txt_level",data.level);
    self:setLabelString("txt_power",data.power);
    if data.fname ~= "" then
        self:setLabelString("txt_family",data.fname);
    end
    self:setLabelString("txt_name",data.name);
    self:setLabelString("txt_times",data.bemolestnum.."/"..Data.bath.gBathMolestTimes);
    -- self:setLabelString("txt_gold_num",math.floor(Data.bath.gBathRewardGold[data.type] * (Data.bath.gBathRewardPercent/100.0)));
    local repu = Data.bath.gBathRewardRepu[data.type];
    local gold = Data.bath.gBathRewardGold2[data.type] * data.level + Data.bath.gBathRewardGold[data.type];
    local rewardAdd = self:getVipReward();
    if(rewardAdd > 0)then
        repu = repu + math.floor(repu*rewardAdd/100);
        gold = gold + math.floor(gold*rewardAdd/100);
    end
    local add_mul = 1
    if (gBathInfo.mul>1) then
       add_mul = gBathInfo.mul
    end
    self:setLabelString("txt_repu_num",math.floor(repu * (Data.bath.gBathRewardPercent/100.0))*add_mul);
    self:setLabelString("txt_gold_num",math.floor(gold * (Data.bath.gBathRewardPercent/100.0))*add_mul);
    self:setTouchEnableGray("btn0",data.uid ~= Data.getCurUserId());

    gCreateRoleFla(Data.convertToIcon(data.icon),self:getNode("bg_role"),1.0,nil,nil,data.show.wlv,data.show.wkn);

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

function BathMolestPanel:getVipReward()
    local vipData = DB.getVip(self.user.vip);
    return DB.getVipValue(vipData,VIP_BATH_REWARD);
end

function BathMolestPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "btn0" then

        if gBathInfo.molesttime - gGetCurServerTime() > 0 then
            gShowCmdNotice("bath.molest",11);
            return;
        end
        if( self.user.bemolestnum >= Data.bath.gBathMolestTimes)then
            gShowCmdNotice("bath.molest",8);
            return;
        end
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_BATH_MOLEST,self.user.uid)
    end
end

return BathMolestPanel