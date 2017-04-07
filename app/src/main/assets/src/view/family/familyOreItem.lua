
local FamilyOreItem=class("FamilyOreItem",UILayer)

function FamilyOreItem:ctor(index,data,isUnlock)
    self:init("ui/ui_family_ore_item.map")
    self.level = Data.getCurFamilyLv();
    self.wakuanging = false;
    self:initInfo(index);
    self.isUnlock = isUnlock;
    if(self.isUnlock)then
        self:refreshKuangLayer(index,data);
    else
        self:initUnlock();
    end
end

function FamilyOreItem:initInfo(index)
    self.index = index;
    self:setLabelAtlas("txt_ore_index",index);
end

function FamilyOreItem:initUnlock()
    self:getNode("layer_info"):setVisible(false);
    self:getNode("flag_ani"):setVisible(false);
    self:getNode("tip_unlock"):setVisible(true);
    DisplayUtil.setGray(self:getNode("bg_kuang"),true);
end

function FamilyOreItem:setData(data)

    if(data == nil or self.isUnlock == false)then
        return;
    end
    -- print(">>>>>>>>>new");
    -- print_lua_table(data);
    -- print(">>>>>>>>>old");
    -- print_lua_table(self.data);
    -- if(self.data.num ~= data.num)then
        self:refreshKuangLayer(self.index,data);
    -- end
end


function FamilyOreItem:refreshKuangLayer(index,data,bFindGold)


    self:getNode("layer_info"):setVisible(true);
    self:getNode("flag_ani"):setVisible(true);
    self:getNode("tip_unlock"):setVisible(false);

    if data == nil then
      data = {};
      data.gold = 0;
      data.num = 0;
      data.gain = false;
    end

    self.index = index;
    self.data = data;

    if self.max_times == nil then
      self.max_times = table.getn(familyoretier_db);
    end

    self:setLabelAtlas("txt_ore_index",index);

    --次数
    local times_index = data.num + 1;
    self:replaceLabelString("txt_left_times",self.max_times - data.num,self.max_times);

    -- --累计金币
    self:getNode("layer_gold"):setVisible(data.gold>0);
    self:setLabelString("txt_gold",data.gold);

    --显示文字
    self:showGoldTip(index,bFindGold);

    --显示按钮
    self:refreshKuangBtn(index,data);

    self:resetAdaptNode();
    self:resetLayOut();
end

function FamilyOreItem:showGoldTip(index,bFindGold)
    self:getNode("txt_tip_bg"):setVisible(self.data.gold > 0 and self.data.num < self.max_times);
    if(self.data.gold > 0 and self.data.num < self.max_times)then
        local cur_gold = self.data.gold;
      local max_next_rate = DB.getFamilyGoldMineMaxNextRate(self.data.num+1)/100.0;
      local max_gold = cur_gold * max_next_rate;
      self:replaceRtfString("txt_tip",max_gold - cur_gold);
      -- local word = getWordWithFile("familyGoldMine.plist","tip3");
      -- word = replaceString(word,intToString(max_gold - cur_gold));
  end
end

function FamilyOreItem:refreshKuangBtn(index,data)

  if data ~= nil then
    --显示按钮
    -- 0---收获  1 --- 探索 2--往下挖 3--两个按钮 4 --已收获
    local status = 0;
    local hasShovel = false;
    local need_dia = 0;
    local times_index = data.num + 1;
    if data.gain then
    --显示已收获
      status = 4;  
    elseif data.num >= self.max_times then
      --显示收获
      status = 0;
    else
      --铲子类型
      local type = DB.getFamilyGoldMineShovelType(times_index);
      local path = {"images/ui_family/tietou.png","images/ui_family/tongtou.png","images/ui_family/jintou.png"};
      -- resetSpriteTexture(icon_type,path[type]);
      self:changeTexture("icon_type",path[type]);
      if type == 0 then
        --显示探索
        status = 1;
      elseif type > 0 then
        if type == 1 then
          hasShovel = self:getLeftShovelTimes(1) > 0;
        elseif type == 2 then
          hasShovel = self:getLeftShovelTimes(2) > 0;
        elseif type == 3 then
          hasShovel = self:getLeftShovelTimes(3) > 0;
        end  
        if hasShovel then
          --往下挖
          status = 2;
        else
          status = 3;
          need_dia = DB.getFamilyGoldMineShovelDia(times_index);
        end
      end
    end
    
    local layer_one = self:getNode("layer_one");
    local layer_one2 = self:getNode("layer_one2");
    local layer_two = self:getNode("layer_two");
    local lab_one = self:getNode("lab_one");
    local lab_two = self:getNode("lab_two_left");
    layer_one:setVisible(false);
    layer_two:setVisible(false);
    layer_one2:setVisible(false);
    if status == 2 then
      layer_one2:setVisible(true);
    elseif status < 3 or status == 4 then
      local key = {"2","1","4","","5"};
      layer_one:setVisible(true);
      layer_two:setVisible(false);

      local word = gGetWords("familyGoldMine.plist",key[status+1]);
      lab_one:setString(word);
    elseif status == 3 then
      layer_one:setVisible(false);
      layer_two:setVisible(true);
      local word = gGetWords("familyGoldMine.plist","2");
      lab_one:setString(word);

      local bg_dia = self:getNode("bg_dia");
      if need_dia > 0 then
        bg_dia:setVisible(true);
        self:setLabelString("txt_need_dia",need_dia);
      else
        bg_dia:setVisible(false);
      end
    end
    self.status = status;
    self.need_dia = need_dia;
    self:setTouchEnableGray("btn_one",true);
    if(self.status == 4)then
        self:setTouchEnableGray("btn_one",false);
        self:getNode("layer_gold"):setVisible(false);
        self:getNode("txt_tip_bg"):setVisible(false);
        self:getNode("layer_left_num"):setVisible(false);
    end
    -- local btnOne = self:getNode("btn_one");
    -- local btnOne2 = self:getNode("btn_one2");
    -- local btnTwo_left = self:getNode("btn_two_left");
    -- local btnTwo_right = self:getNode("btn_two_right");
    -- if status == 4 then
    --   self:setTouchNodeIsEnable(btnOne,false);
    -- elseif status == 0 then
    --     self:setCallFuncNDWithTouchNode(btnOne,self,self.onGet,{index = index,num = data.num});
    -- else
    --     self:setCallFuncNDWithTouchNode(btnOne,self,self.onWakuang,{index = index,dia = need_dia});
    -- end
    -- self:setCallFuncNDWithTouchNode(btnTwo_left,self,self.onGet,{index = index,num = data.num});
    -- self:setCallFuncNDWithTouchNode(btnTwo_right,self,self.onWakuang,{index = index,dia = need_dia});
    -- self:setCallFuncNDWithTouchNode(btnOne2,self,self.onWakuang,{index = index,dia = need_dia});
    
  end
  
end

function FamilyOreItem:getLeftShovelTimes(type)
    local free_times = DB.getFamilyGoldMineShovelFreeTimes(self.level,type);
    local left_times = 0;
    if type == 1 then
      left_times = free_times - gFamilyGoldMineInfo.shovel1;
    elseif type == 2 then
      left_times = free_times - gFamilyGoldMineInfo.shovel2;
    else
      left_times = free_times - gFamilyGoldMineInfo.shovel3;
    end
    return left_times;
end

function FamilyOreItem:onGet()

  if self.wakuanging then
    return;
  end
  
  if self.data.num < self.max_times then
      local word = gGetWords("familyGoldMine.plist","get");
      local func = function()
        self:sendGetCmd();
      end
      gConfirmCancel(word,func);
  else
    self:sendGetCmd();
  end
  
end

function FamilyOreItem:sendGetCmd()
  Net.sendFamilyOreGain(self.index);
end


function FamilyOreItem:onWakuang()
  
  -- if self.ani_ing == nil then
  --   self.ani_ing = false;
  -- end
  
  if self.wakuanging then
    return;
  end
  
  if self.need_dia > 0 then
    local bDiaEnough = NetErr.isDiamondEnough(self.need_dia);
    if bDiaEnough == false then
      return;
    end
  end
  -- gFamilyGoldMineInfo.addcry = true;
  -- gDispatchEvt(EVENT_ID_FAMILY_OREWAKUANG,{number=5});
    self:sendWaCmd();

    FamilyOrePanelData.need_dia = self.need_dia;

  -- self.index = index;
  -- self.ani_ing = true;

  -- self:startWaAni(index);
    
  -- local arr = CCArray:create();
  -- arr:addObject(CCDelayTime:create(2.0));
  -- arr:addObject(CCCallFunc:create(self,self.sendWaCmd));
  -- self:runAction( CCSequence:create(arr));

end

function FamilyOreItem:playWakuangAni(callback)
    self.wakuanging = true;
    self:getNode("flag_ani"):setSpeedScale(1.0);
    self:getNode("flag_ani"):setSpeedScale(2);
    self:getNode("flag_ani"):playAction("ui_family_wakuang_b",callback);
end

function FamilyOreItem:playWaitAni()
    self.wakuanging = false;
    self:getNode("flag_ani"):setSpeedScale(3.0);
    self:getNode("flag_ani"):playAction("ui_family_wakuang_a");
end

function FamilyOreItem:sendWaCmd()
    Net.sendFamilyOreMining(self.index);
end

function FamilyOreItem:onTouchEnded(target)

    if  target.touchName=="btn_one"then
        if(self.status == 0)then
            --收获
            self:onGet();
        else
            --挖矿
            self:onWakuang();
        end
    elseif target.touchName == "btn_one2" or target.touchName == "btn_two_right" then
        --挖矿
        self:onWakuang();
    elseif target.touchName == "btn_two_left" then
        --收获
        self:onGet();        
    end

end

return FamilyOreItem