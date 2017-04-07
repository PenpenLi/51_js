
local BathDetailPanel=class("BathDetailPanel",UILayer)

function BathDetailPanel:ctor()
  self.appearType = 1;
  self:init("ui/ui_bath_detail.map") 
  self:refreshType();
  self.isMainLayerMenuShow = false;

  for i=1,5 do
    local fla = self:getNode("icon_type"..i);
    -- local role = gCreateFlaDislpay("r"..Data.getCurIcon().."_wait2",1,"r"..Data.getCurIcon().."_wait2");
    local role = cc.Node:create();
    fla:replaceBoneWithNode({"npc"},role);
  end
  self:initItemReward();
end

function BathDetailPanel:initItemReward()
  local itemReward = {}
  for i=1,5 do
    itemReward.rate = 0;
    for key,item in pairs(Data.bath.gBathRewardItems) do
      if toint(item.type) == i then
        itemReward.rate = toint(item.rate);
        itemReward.num = item.num;
        itemReward.id = toint(item.id);
        break;
      end
    end

    if(itemReward.rate == 0)then
      self:getNode("item_bg"..i):setVisible(false);
    else
      self:getNode("item_bg"..i):setVisible(true);
      self:setLabelString("item_num"..i,"x"..itemReward.num);
      if(itemReward.rate >= 100)then
        self:setLabelString("tip_rate"..i,gGetMapWords("ui_bath_detail.plist","4"));
      else
        self:setLabelString("tip_rate"..i,gGetMapWords("ui_bath_detail.plist","3"));
      end
      Icon.changeItemIcon(self:getNode("item_icon"..i),itemReward.id);
    end
  end
  self:resetLayOut();
end

function BathDetailPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
      self:onClose();
    elseif target.touchName == "btn_refresh" then
      self:onRefreshType(false);
    elseif target.touchName == "btn_add" then
      self:onAdd();
    elseif target.touchName == "btn_last" then
      if Data.getItemNum(ITEM_CALL_BATH) == 0 and gIsVipExperTimeOver(VIP_BATH_LAST) then
         return
      end
      if(self:isUnlockCall())then
        self:onRefreshType(true);
      end
    elseif target.touchName == "btn_ok" then
      Net.sendBathStart();
      self:onClose();
    end
end


function  BathDetailPanel:events()
    return {EVENT_ID_BATH_REFRESHTYPE,
            EVENT_ID_BATH_ADDATRR}
end

function BathDetailPanel:dealEvent(event,param)

    if(event == EVENT_ID_BATH_REFRESHTYPE) then
      self:refreshType();
    elseif(event == EVENT_ID_BATH_ADDATRR) then
      self:event_refreshAdd();
    end
end

function BathDetailPanel:onRefreshType(last)
  if last then
    local callback = function()
      if Data.getItemNum(ITEM_CALL_BATH) == 0 and gIsVipExperTimeOver(VIP_BATH_LAST) then
        return
      end
      Net.sendBathRefType(true);
      if (TDGAItem) then
        gLogPurchase("bath_call_last",1,Data.bath.gBathRefreshLastNeedDia)
      end
    end
    local tipInfo = ""
    if Data.getItemNum(ITEM_CALL_BATH) ~= 0 then
        tipInfo = gGetWords("bathWords.plist","50")
    else
        tipInfo = gGetWords("bathWords.plist","35",Data.bath.gBathRefreshLastNeedDia)
    end
    gConfirmCancel(tipInfo,callback);
  else
    local type = self:getRefreshExpendType();
    if type == 1 then
      if NetErr.isDiamondEnough(Data.bath.gBathRefreshNeedDia) == false then
        return;
      end
    end
    Net.sendBathRefType(false);  
  end
end

function BathDetailPanel:onAdd()
  if gBathInfo.attrnum >= Data.bath.gBathAddPercentTimes then
      gShowNotice(gGetWords("bathWords.plist","29"));
      return;
  end

  local callback = function()
    Net.sendBathAddAttr();
  end
  local lefttimes = Data.bath.gBathAddPercentTimes - gBathInfo.attrnum;
  gConfirmCancel(gGetWords("bathWords.plist","23",Data.bath.gBathAddPercentNeedDia,lefttimes,Data.bath.gBathAddPercentTimes),callback);
end

function BathDetailPanel:refreshType()
  self:refreshChooseGirl();
  self:refreshContent();
  self:refreshCallLayer();
end

function BathDetailPanel:refreshChooseGirl()

  for i=1,5 do
    if gBathInfo.reftype == i then
      -- self:changeTexture("bg"..i,"images/ui_9gong/niudi.png");
      self:getNode("name"..i):setColor(cc.c3b(255,255,143));
      self:getNode("flag_choosed"):setPosition(self:getNode("bg"..i):getPosition());
    
      local refreshEffect = gCreateFla("ui_xiuxian");
      refreshEffect:setPosition(self:getNode("flag_choosed"):getPosition());
      self:getNode("flag_choosed"):getParent():addChild(refreshEffect);
    
      
    else
      -- self:changeTexture("bg"..i,"images/ui_9gong/niudi1.png");
      self:getNode("name"..i):setColor(cc.c3b(255,255,255));
    end
  end
  -- self:getNode("flag_choose"):setPosition(cc.p(self:getNode("icon_type"..gBathInfo.reftype):getPosition()));
  

end

function BathDetailPanel:getRefreshExpendType()
  if gBathInfo.refnum < Data.bath.gBathRefreshOneDay then
    --免费次数
    return 0;
  elseif Data.getItemNum(ITEM_REFRESH_BATH) ~= 0 then
    return 2;
  else
    --钻石消耗
    return 1;
  end
  return 0;
end


function BathDetailPanel:refreshTimes()

  self:getNode("layout_refresh_item"):setVisible(false);
  self:getNode("bg_refresh_icon_dia"):setVisible(false);
  self:getNode("lab_free"):setVisible(false)
  local expendType = self:getRefreshExpendType();
  if expendType == 0 then
    --免费次数
    self:getNode("lab_free"):setVisible(true);
    local lefttimes = Data.bath.gBathRefreshOneDay - gBathInfo.refnum;
    self:setLabelString("lab_free", string.format("%s(%d/%d)",gGetWords("bathWords.plist","22"), lefttimes, Data.bath.gBathRefreshOneDay));
  elseif expendType == 2 then
    self:getNode("layout_refresh_item"):setVisible(true);
    self:getNode("icon_refresh_item"):setVisible(true)
    self:setLabelString("txt_refresh_item", Data.getItemNum(ITEM_REFRESH_BATH));
    self:getNode("layout_refresh_item"):layout()
  elseif expendType == 1 then
    self:getNode("bg_refresh_icon_dia"):setVisible(true);
    self:setLabelString("txt_refresh_icon_dia",Data.bath.gBathRefreshNeedDia);
    if isBanshuReview() then
        self:getNode("bg_refresh_icon_dia"):setVisible(false);
        self:getNode("btn_refresh"):setVisible(false);
        self:getNode("txt_free_bg"):setVisible(false);
    end  
  end

  -- self.refresh_icon_repu:setVisible(false);

  -- if gBathInfo.refnum <  gBathRefreshOneDay then
  --   self.lab_free:setVisible(true);
  --   local num = createNum(gBathRefreshOneDay - gBathInfo.refnum,gBathRefreshOneDay,NUM_STROKE);
  --   num:setAnchorPoint(ccp(0,0.5));
  --   refreshNode(self.lab_free,num,ccp(1.0,0.5),ccp(3,0),100);
  -- else
  --     self.refresh_icon_repu:setVisible(true);
  --   local count = DataBase:shared():getItemCount(ITEM_GIRL_REFRSH);
  --   if count > 0 then
  --     self.refresh_icon_repu:setScale(0.8);
  --     resetSpriteTexture(self.refresh_icon_repu,"images/icons/item/53.png");
  --     local dia = createCNum(1,NUM_STROKE);
  --     dia:setAnchorPoint(ccp(0,0.5));
  --     dia:setScale(0.5);
  --     refreshNode(self.refresh_icon_repu,dia,ccp(1.0,0.5),ccp(-10,0),100);
  --   else
  --     self.refresh_icon_repu:setScale(0.5);
  --     resetSpriteTexture(self.refresh_icon_repu,"images/public_ui/icon_dia.png");
  --     -- self.refresh_icon_repu:setVisible(true);
  --     local dia = createCNum(gBathRefreshNeedDia,NUM_STROKE);
  --     dia:setAnchorPoint(ccp(0,0.5));
  --     dia:setScale(0.8);
  --     refreshNode(self.refresh_icon_repu,dia,ccp(1.0,0.5),ccp(5,0),100);
  --   end

  -- end

end

function BathDetailPanel:refreshContent()

  self:refreshTimes();
  
  local girl_type = gBathInfo.reftype;
  local add_mul = 1
  if (gBathInfo.mul>1) then
     add_mul = gBathInfo.mul
  end
  self:replaceLabelString("txt_time",Data.bath.gBathRewardTimes[girl_type]/60);

  -- self:setLabelString("txt_gold_num",Data.bath.gBathRewardGold[girl_type]*add_mul);
  local repu = Data.bath.gBathRewardRepu[girl_type];
  local gold = Data.bath.gBathRewardGold2[girl_type] * Data.getCurLevel() + Data.bath.gBathRewardGold[girl_type];
  local rewardAdd = self:getVipReward();
  if(rewardAdd > 0)then
    repu = repu + math.floor(repu*rewardAdd/100);
    gold = gold + math.floor(gold*rewardAdd/100);
  end
  self:setLabelString("txt_repu_num",repu*add_mul);
  self:setLabelString("txt_gold_num",gold*add_mul);

  self:event_refreshAdd();

  self:setTouchEnableGray("btn_refresh",girl_type ~= 5);
  self:setTouchEnableGray("btn_last",girl_type ~= 5);

  -- gBathInfo.mul = 1
  for i=1,2 do
      self:getNode("double_sign"..i):setVisible(gBathInfo.mul>1);
      if (gBathInfo.mul>1) then
         self:replaceLabelString("lab_double"..i,gBathInfo.mul);
      end
  end
end

function BathDetailPanel:event_refreshAdd()

  self:setLabelString("txt_power_num",gBathInfo.attrnum*Data.bath.gBathAddPercent.."%"); 
  
end

function BathDetailPanel:event_refreshGirl()
  self:refreshChooseGirl();
  self:refreshContent();
end


function BathDetailPanel:isUnlockCall()
  if(Data.getItemNum(ITEM_CALL_BATH) ~= 0) then
      return true
  end

  if(Module.isClose(SWITCH_VIP))then
    return false;
  end
  local needVip = Data.getCanBuyTimesVip(VIP_BATH_LAST);
  if Data.getCurVip() >= needVip then
    return true;
  end

  return false;
end

function BathDetailPanel:getVipReward()
    local vipData = DB.getVip(Data.getCurVip());
    return DB.getVipValue(vipData,VIP_BATH_REWARD);
end

function BathDetailPanel:refreshCallLayer()
    if self:isUnlockCall() then
        local showCallItem = (Data.getItemNum(ITEM_CALL_BATH) ~= 0)
        if showCallItem then
          self:setLabelString("txt_call_item_num",Data.getItemNum(ITEM_CALL_BATH));
        else
          self:setLabelString("txt_last_icon_dia",Data.bath.gBathRefreshLastNeedDia);
        end
        self:getNode("layout_call_dia"):setVisible(not showCallItem)
        self:getNode("layout_call_item"):setVisible(showCallItem)

        self:getNode("layer_call"):setVisible(true);
    else
        self:getNode("layer_call"):setVisible(false);
    end
end



return BathDetailPanel