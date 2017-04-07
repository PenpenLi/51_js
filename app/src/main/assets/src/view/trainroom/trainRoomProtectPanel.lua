
local TrainRoomProtectPanel=class("TrainRoomProtectPanel",UILayer)

function TrainRoomProtectPanel:ctor(roomid)
  self:init("ui/ui_xunlian_baohu.map");
  self:setProtectType(0);

  for i=0,1 do
    local time = Data.trainroom.protectTimes[i+1]/3600;
    self:setLabelAtlas("txt_type"..i,time);
    self:replaceLabelString("tip_type"..i,time);
    self:setLabelString("txt_price"..i,Data.trainroom.protectNeedDias[i+1]);
  end

end

function TrainRoomProtectPanel:setProtectType(type)
  self.protectType = type;
  self:changeTexture("btn_type0","images/ui_public1/n-di-gou1.png");
  self:changeTexture("btn_type1","images/ui_public1/n-di-gou1.png");

  self:changeTexture("btn_type"..type,"images/ui_public1/n-di-gou2.png");
end

function TrainRoomProtectPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
      self:onClose();  
    elseif target.touchName == "btn_type0" then
      self:setProtectType(0);
    elseif target.touchName == "btn_type1" then
      self:setProtectType(1);
    elseif target.touchName == "btn_ok" then
      if NetErr.isDiamondEnough(Data.trainroom.protectNeedDias[self.protectType+1]) then      
        Net.sendDrinkProtect(self.protectType);
        if (TDGAItem) then
          gLogPurchase("training_buy_protect",1,Data.trainroom.protectNeedDias[self.protectType+1])
        end
        self:onClose(); 
      end
    end
end


return TrainRoomProtectPanel