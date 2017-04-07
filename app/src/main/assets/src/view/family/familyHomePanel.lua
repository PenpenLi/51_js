
local FamilyHomePanel=class("FamilyHomePanel",UILayer)
FamilyHomePanelData = {};

FAMILY_ENTER_HD     = 1;
FAMILY_ENTER_TUTENG = 2;
FAMILY_ENTER_MAIN   = 3;
FAMILY_ENTER_BATTLE = 4;
FAMILY_ENTER_SHOP   = 5;
FAMILY_ENTER_ORE   = 6;
FAMILY_ENTER_ARENA   = 7;
FAMILY_ENTER_DONATE   = 8;

function Data.getCurFamilyLv()
  return gFamilyInfo.iLevel;
end

function Data.getFamilyLvToday()
  return gFamilyInfo.dayFlv;
  -- return 1;
end

function Data.getFamilyMaxMem(level)
  if(level == nil)then
    level = Data.getCurFamilyLv();
  end
  for key,var in pairs(familyupgrade_db) do
    if(var.id == level) then
      return var.member;
    end
  end
  return 20;
end

function Data.getCurFamilyMemCount()
  return table.getn(gFamilyMemList);
end

function Data.isActiveBoxGet(boxid)
  -- gFamilyInfo.activeBoxs = {};
  for key,var in pairs(gFamilyInfo.activeBoxs) do
    if var.id == boxid then
      return var.rec;
    end
  end
  return false;
end

function Data.getFamilyLvData(level)
  for key,var in pairs(familyupgrade_db) do
    if(var.id == level) then
      return var;
    end
  end
  return nil;  
end

function Data.getFamilyShopRefreshDiscount()
  local data = Data.getFamilyLvData(Data.getCurFamilyLv());
  return data.refdis;
end
function Data.getFamilyShopBugDiscount()
  local data = Data.getFamilyLvData(Data.getCurFamilyLv());
  return data.shopdis;
end
function Data.getFamilySpecialSkilllv()
  local data = Data.getFamilyLvData(Data.getCurFamilyLv());
  return data.skilllvspecial;
end

function Data.getFamilyShop2Data(id)
  for key,var in pairs(familygoods_db) do
    if var.id == id then
      return var;
    end
  end
  return nil;
end
function Data.getFamilyShop3Data(lv)
  for key,var in pairs(familylvreward_db) do
    if var.id == lv then
      return var;
    end
  end
  return nil;
end
function Data.getFamilyShop3Items(lv)
  for key,var in pairs(Data.family.shop3Data) do
    if var.lv == lv then
      return var.items;
    end
  end
  return nil;  
end
function Data.getFamilyUnlockSkill(lv)
  local allSkills = {};
  for key,var in pairs(familyskill_db) do
    if lv == var.unlocklv then
      local skill = {};
      skill.id = var.id;
      skill.buff = DB.getBuffById(var.id);
      table.insert(allSkills,skill);
    end
  end
  return allSkills;  
end

function FamilyHomePanel:ctor(type)
    loadFlaXml("ui_family");
    loadFlaXml("ui_jianzhu");
    loadFlaXml("ui_main_night")
    self:init("ui/ui_family_home.map") 
    self.isBlackBgVisible=false  

    self.donateLv = DB.getClientParam("FAMILY_DONATE_LIMIT_LV",true)

    -- self.scroll_mem = self:getNode("scroll_mem");
    -- self.scroll_module = self:getNode("scroll_module");
    self:initActiveBox();
    self:refreshInfo();
    self:refreshFamilyNotice();
    self:refreshFamilyExp();


    self:getNode("btn_rank"):setVisible(not Module.isClose(SWITCH_VIP))
    self:getNode("btn_others"):setVisible(not Module.isClose(SWITCH_VIP)) 
    -- self:createModuleList();
    -- self:createMemList();
    -- gDispatchEvt(EVENT_ID_FAMILY_REFRESH_BGMEM);

    -- self:initDisTime();
    self:initTempTime();

    Net.sendFamilyChatInit()
    -- --test RTF
    -- local rtf = RTFLayer.new(525);
    -- -- \\i{p=images/icon/head/10001.png;s=0.5}
    -- -- rtf:setString("\\w{c=ffff00;s=20}第二个参数可以指出转换目标串的基数,在这个例子中jdjdjd11\\i{p=images/icon/head/10001.png;s=0.5}\\w{c=ff00ff;s=30}test33");
    -- rtf:setString("亲爱的玩家，您现在正在体验的是\\w{c=ff0000}《乱斗堂》\\安卓版全球首服不删档内测版本。由于当前游戏还处于测试阶段，在游戏过程中可能会出现bug和不稳定的现象，为了让游戏得到更好、更快速的完善，官方希望各位玩家在参与游戏测试时，能将各种BUG情况详细且真实的反馈给我们。");
    -- -- rtf:setString("ababjaljbkajbkajbkajbkajkbjakbjakjb");
    -- rtf:layout();
    -- rtf:setAnchorPoint(cc.p(0.5,0.5));
    -- rtf:setPosition(cc.p(480,-320));
    -- self:addChild(rtf);


  local function __update()
   -- print("update time");

    -- if(self.iDisLeftTime > 0) then
    --   self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
    --   self:refreshDisTime();
    -- end

    if(self.iTempLeftTime > 0) then
      self.iTempLeftTime = gFamilyInfo.iTempTime - gGetCurServerTime();
      self:refreshTempTime();
    end 
    self:refreshHomeBattleInfo();
    self:refreshStageLefttime();
  end
  self:scheduleUpdate(__update,1);    

  gCreateBtnBack(self);
  self:AniBtnChat();
  self:initPos();
  self:createMem();
  self:hideCloseModule();
  self:lockCloseMoudel();
  self:refreshStageStatus()
  self:refreshDonateLockStatus()
end

function FamilyHomePanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function FamilyHomePanel:hideCloseModule()
    self:getNode("btn_chat"):setVisible(not Module.isClose(SWITCH_CHAT));
    if(self:getNode("btn_ore"))then
      self:getNode("btn_ore"):setVisible(not Module.isClose(SWITCH_FAMILY_ORE));
    end
end

function FamilyHomePanel:onPopup()
  self:refreshHDInfo();
  self:refreshWarInfo()
  self:refreshDayOrNight();
  self:refreshHomeSpringInfo();
  self:refreshHomeBattleInfo();
  -- gMsgWinLayer:show();
  self:showBtnChat(true);
  print("FamilyHomePanel:onPopup");
end

function FamilyHomePanel:refreshWarInfo()

    local sign= cc.UserDefault:getInstance():getIntegerForKey("family.sign"..gUserInfo.id,-1)
    if(sign~=gFamilyMatchInfo.season and  gFamilyInfo.iLevel>=UNLCOK_FAMILY_WAR_LEVLE )then
        RedPoint.add(self:getNode("name_war"))
    else
        RedPoint.remove(self:getNode("name_war"))
    end
end

function FamilyHomePanel:onPushStack()
  -- gMsgWinLayer:hide();
end

function FamilyHomePanel:onPopback() 
end

function FamilyHomePanel:initPos()
  self.posNode = {};
  for i=1,20 do
    if(self:getNode("pos"..i)) then
      table.insert(self.posNode,self:getNode("pos"..i));
    end
  end

  local function sortRoleZ(role1,role2)
    local pos1 = cc.p(role1:getPosition());
    local pos2 = cc.p(role2:getPosition());
    if(pos1.y > pos2.y) then
      return true;
    end
    return false;
  end
  
  table.sort(self.posNode,sortRoleZ);
  
  --reorderZ
  local z = 0;
  for key,value in pairs(self.posNode) do
    value:setLocalZOrder(z);
    z = z + 1;
  end
  
end

function FamilyHomePanel:createMem()


  local memCount = table.getn(gFamilyMemList);
  for i,var in ipairs(self.posNode) do
    -- print("i = "..i .. " memCount = "..memCount);
    if i <= memCount then
      local memData = gFamilyMemList[i];
      local role = gCreateRoleFla(Data.convertToIcon(memData.iCoat), var,0.5,nil,nil,memData.show.wlv,memData.show.wkn);
      if(role) then
        if math.random() < 0.5 then
          role:setScaleX(-0.5);
        end
      end
    end
  end

end

function FamilyHomePanel:refreshInfo()
  -- body
  self:setLabelString("txt_name",gFamilyInfo.sName);
  self:setLabelString("txt_lv",getLvReviewName("Lv.")..gFamilyInfo.iLevel);
  
  self:setLabelString("txt_des",gFamilyInfo.sNotice);
  Icon.setFamilyIcon(self:getNode("icon"),gFamilyInfo.icon,gFamilyInfo.familyId);
  -- self:changeTexture("icon","images/ui_family/bp_icon_"..gFamilyInfo.icon..".png");
  
  self:refreshUIWithChangeType();
  -- self:refreshMemCount();
  -- self:setLabelString("txt_fexp",gFamilyInfo.dayFExp);
  -- self:setLabelString("txt_active_num",gFamilyInfo.activenum.."/"..Data.getCurFamilyMemCount());
  self:refreshHomeSpringInfo();
  self:refreshHomeBattleInfo();
  self:refreshDayOrNight();
  self:refreshHDInfo();
  self:resetLayOut();
end

function FamilyHomePanel:refreshDayOrNight()

    local curHour= gGetHourByTime()
    local isNight=false
    if(curHour>=18 or curHour<=6)then
       isNight=true
    else
        isNight=false
    end

    self:getNode("flag_day"):setVisible(not isNight);
    if self:getNode("flag_night") then
      self:getNode("flag_night"):setVisible(isNight);
    else
      self:getNode("flag_day"):setVisible(true);  
    end
    
end

function FamilyHomePanel:refreshHDInfo()
  -- gFamilyInfo.remainone = true;
  self:getNode("tip_hd"):setVisible(gFamilyInfo.remainone);
  local wordWidth = self:getNode("tip_hd_word"):getContentSize().width;
  self:getNode("tip_hd"):setContentSize(cc.size(wordWidth + 10,self:getNode("tip_hd"):getContentSize().height));
end

function FamilyHomePanel:refreshHomeSpringInfo()
    local hasSpring = false;
    if(Data.hasFamily() and gFamilySpringInfo.callUid and gFamilySpringInfo.callUid > 0) then
        hasSpring = true;
    end

    self:getNode("flag_spring"):setVisible(hasSpring)
    self:getNode("flag_spring_call"):setVisible(hasSpring)
    self:getNode("txt_caller"):setVisible(hasSpring)
    if(hasSpring)then
      local icon = gFamilySpringInfo.callIcon;
      local show = gFamilySpringInfo.show;
      local role = gCreateRoleFla(Data.convertToIcon(icon), self:getNode("flag_spring_call"),0.5,nil,nil,show.wlv,show.wkn,show.halo);
      self:setLabelString("txt_caller",gFamilySpringInfo.callName);
    end 
end

function FamilyHomePanel:refreshHomeBattleInfo()
  --TODO: 家族战表现
  RedPoint.familyWarTime=RedPoint.familyWarTime or 0;
  RedPoint.inFamilyWar=RedPoint.inFamilyWar or false;

  local isFighting = RedPoint.inFamilyWar;
  local isCountdown =false
  if (RedPoint.familyWarTime>0) then
      isCountdown=true;--24小时倒计时
  end
  if(isFighting)then
    isCountdown = false;
  end
  if(isCountdown)then
        self:setLabelString("txt_time",gParserHourTime(RedPoint.familyWarTime))
  end
  self:getNode("flag_fight_door"):setVisible(isFighting or isCountdown)
  self:getNode("flag_fight_bin"):setVisible(isFighting or isCountdown)
  self:getNode("flag_fight_smoke"):setVisible(isFighting or isCountdown)
  self:getNode("flag_fighting"):setVisible(isFighting)
  self:getNode("flag_fight_time"):setVisible(isCountdown)

end

function FamilyHomePanel:refreshUIWithChangeType()
  self:getNode("btn"):setVisible(Data.isFamilyManager() or Data.getCurFamilyType()==3);
  -- if Data.isFamilyManager() then
  --   self:changeTexture("btn","images/ui_word/family_guanli.png");
  -- else
  --   self:changeTexture("btn","images/ui_word/family_tui.png");
  -- end
end

function FamilyHomePanel:refreshMemCount()
  self:setLabelString("txt_mem",table.getn(gFamilyMemList).."/20");
end

function FamilyHomePanel:refreshFamilyNotice()
  -- print("refresh notice = "..gFamilyInfo.sNotice);
  -- gFamilyInfo.sNotice = gFamilyInfo.sNotice .. "112234556";
  self:setLabelString("txt_notice",gFamilyInfo.sNotice);
  gSetLabelScroll(self:getNode("txt_notice"));
end

function FamilyHomePanel:refreshFamilyExp()
  -- self:setLabelString("txt_day_exp",gFamilyInfo.iDayExp);
  -- self:setLabelString("txt_exp",gFamilyInfo.iExp);
  self:setLabelString("txt_fexp",gFamilyInfo.weekexp);
end

function FamilyHomePanel:showBtnChat(visible)
    if (Module.isClose(SWITCH_CHAT)) then
        return;
    end
    local node = self:getNode("btn_chat")
    self:setNodeTouchRectOffset("btn_chat", 30,30)
    node:setVisible(visible);
    if(self.msgWin)then
      self.msgWin:setVisible(visible);
    end
end

function FamilyHomePanel:AniBtnChat()
    local node = self:getNode("btn_chat")
    local ret=FlashAni.new()
    local size=node:getContentSize()
    local width=size.width
    local height=size.height
    ret:setPositionX(6)
    ret:setPositionY(height/2)
    node:addChild(ret,0,1)
    ret:playAction("ui_munu_dian")
end

function FamilyHomePanel:initActiveBox()

  self.totalPoint = 0;
  for key,var in pairs(familyactive_db) do
    if var.level == Data.getFamilyLvToday() and self.totalPoint < var.fexp then
      self.totalPoint = var.fexp;
    end
  end

  -- print("totalPoint = "..totalPoint);

  self.bar = self:getNode("fexp_bar");

  local width = self.bar:getContentSize().width;
  -- local barStartX = self.bar:getPositionX() - (1-self.bar:getAnchorPoint().x) * width;
  local barStartX = 5;
    -- print("start x = "..barStartX);
  local index = 1; 
  self.activeBoxData = {};
  for key,var in pairs(familyactive_db) do
      if var.level == Data.getFamilyLvToday() then
        local per = var.fexp / self.totalPoint;
        self:getNode("flag_point"..index):setPositionX(barStartX + per*width);
        self:setLabelString("txt_active_num"..index,var.fexp);
        var.index = index;
        var.status = 0;
        index = index + 1;
        table.insert(self.activeBoxData,var);
      end
  end

  self:refreshActiveBar();
end


function FamilyHomePanel:refreshActiveBar()
    -- body
    -- gFamilyInfo.dayFExp = 450;
    local per=gFamilyInfo.dayFExp/self.totalPoint;
    self:setBarPer("fexp_bar",per)

    self:setLabelString("txt_fexp2",gFamilyInfo.dayFExp);
    self:setLabelString("txt_active_num",gFamilyInfo.activenum.."/"..Data.getCurFamilyMemCount());

    Data.redpos.bolFamilyActive = false;
    for key,var in pairs(self.activeBoxData) do
        if(gFamilyInfo.dayFExp >= var.fexp) then
          --达到活跃值可领取
            if(Data.isActiveBoxGet(var.boxid)) then
              --已领取
              self:getNode("box"..key):playAction("ui_atlas_box_3");
              var.status = 2;
            else
              --未领取
              self:getNode("box"..key):playAction("ui_atlas_box_2");
              var.status = 1;
              Data.redpos.bolFamilyActive = true;
            end
        else
          --未达到活跃值
          var.status = 0;
        end
    end

    self:resetLayOut();

end


function FamilyHomePanel:onActiveBox(index)
    --四个活跃度活动
    -- print_lua_table(self.activeBoxData);
    for key,var in pairs(self.activeBoxData) do
        if(var.index == index) then
          Panel.popUpVisible(PANEL_FAMILY_ACTIVEBOX,var);
        end
    end
end

function FamilyHomePanel:evtHandleActiveBox()
    for key,var in pairs(gFamilyInfo.activeBoxs) do
        if var.id == FamilyHomePanelData.boxid then
          FamilyHomePanelData.boxid = -1;
          var.rec = true;
          break;
        end
    end

    self:refreshActiveBar();
end

function FamilyHomePanel:refreshFamilyExpInMemList()
  -- local items = self.scroll_mem:getAllItem();
  -- for key,item in pairs(items) do
  --   item:refreshExp();
  -- end
end

function FamilyHomePanel:initTempTime()
  self.flag_temp = self:getNode("flag_temp");
  self.pLabTempTime = self:getNode("lab_temp_time");
  self.iTempLeftTime = gFamilyInfo.iTempTime - gGetCurServerTime();

  if (gFamilyInfo.iTempTime > 0) then
    self.flag_temp:setVisible(true);
    gFamilyInfo.isTempMember = true;
  else
    self.flag_temp:setVisible(false);
    gFamilyInfo.isTempMember = false;
  end
  
  -- self:setCallFuncWithTouchNode(self.flag_temp,self,self.onHelpFroTemp);
end

function FamilyHomePanel:refreshTempTime()
  local sTime = gParserHourTime(self.iTempLeftTime,0);
  self.pLabTempTime:setString(sTime); 
  -- self:setLabelString("txt_refresh_time", gParserHourTime( gShops[self.curShopType].time-gGetCurServerTime()))

  if (self.iTempLeftTime <= 0) then
    self.flag_temp:setVisible(false);
    gFamilyInfo.isTempMember = false;
  end
end

-- function FamilyHomePanel:initDisTime()
--   self.layer_dis = self:getNode("layer_dis");
--   self.pLabDisTime = self:getNode("lab_dis_time");
--   self.pLabDisWord = self:getNode("lab_dis_word");
--   self.pLabDisWord:setPositionX(self.pLabDisTime:getPositionX() + self.pLabDisTime:getContentSize().width+5);
--   self.btn_cancel_dis = self:getNode("btn_cancel_dis");
--   -- local type = Data.getCurFamilyType();
--   -- if type == 1 or type == 2 then
--   --   self:setTouchNodeIsEnable(self.btn_cancel_dis,true);
--   --   self:setCallFuncWithTouchNode(self.btn_cancel_dis,self,self.onCancelDis);
--   -- else
--   --   self:setTouchNodeIsEnable(self.btn_cancel_dis,false);
--   -- end
--   self:handleDisInfo();
-- end

function FamilyHomePanel:onCancelDis()
  sendFamilyCancelDismiss();
end

-- function FamilyHomePanel:handleDisInfo()

--   self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
--   --echo("leftime = "..self.iDisLeftTime);
--   if(self.iDisLeftTime > 0) then
--     self.layer_dis:setVisible(true);
--     -- self.btnHelp:setPositionY(self.layer_dis:getPositionY() - 70);
--   else
--     gFamilyInfo.iDistime = 0;
--     self.layer_dis:setVisible(false);
--     -- self.btnHelp:setPositionY(self.layer_dis:getPositionY());
--   end
--   -- self:refreshTouchRect();
-- end

function FamilyHomePanel:familyDiss()

  local function onBtnOK()
    self:exitFamily();
  end
  gConfirm(gGetWords("familyMenuWord.plist","dis_warning"),onBtnOK);

  self.layer_dis:setVisible(false);
end

function FamilyHomePanel:exitFamily()
  -- echo("exitFamily");
  Panel.popBackAll();
  -- EventListener:sharedEventListener():handleEvent(c_event_family_exit);
end

-- function FamilyHomePanel:refreshDisTime()
  
--   if(self.iDisLeftTime == nil) then
--     self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
--   end
--   local sTime = gParserHourTime(self.iDisLeftTime,0);
--   self.pLabDisTime:setString(sTime); 
  
-- end


function FamilyHomePanel:createModuleList()
  -- scroll_module
  self.scroll_module:clear();
  for key,data in pairs(gFamilyInfo.module) do
    local item=FamilyModuleItem.new();
    item:setData(data);
    item.onClick=function (data)
        self:onClickModule(data);
    end
    self.scroll_module:addItem(item);   
  end
  self.scroll_module:layout(true);
end

function FamilyHomePanel:onClickModule(data)

  if data.id == FAMILY_TYPE_CONTRIBUTION then
    self:onContribution();
  elseif data.id == FAMILY_TYPE_SHOP then
    self:onShop();  
  elseif data.id == FAMILY_TYPE_TASK then
    self:onTask();  
  end
  
end

function FamilyHomePanel:onContribution()
  Panel.popUp(PANEL_FAMILY_HDENTER);
end

function FamilyHomePanel:onShop()
    if Module.isClose(SWITCH_FAMILY_SHOP4) or gFamilyInfo.iLevel < DB.getFamilyBuildUnlock(11) then
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY)
    else
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY_4)
    end
    
end

function FamilyHomePanel:onTask()
    Net.sendFamilySpringInfo()
end

function FamilyHomePanel:enterFamilySpring()
    Panel.popUp(PANEL_FAMILY_SPRING);
end

function FamilyHomePanel:enterFamilySeven()
    print("enterFamilySeven---------")
    Panel.popUp(PANEL_FAMILY_SEVEN);
end

function FamilyHomePanel:enterHall()
    Panel.popUpVisible(PANEL_FAMILY_HALL,self);
end


function FamilyHomePanel:onModuleEnter(enterId)
  print("enterId = "..enterId);
  if(enterId == 1) then
    --活动
    local fla = gCreateFla("ui_jz_ac");
    gAddChildInCenterPos(self:getNode("btn_hd"),fla);
    -- fla:setSpeedScale(2.0);
    local enter = function()
      Panel.popUp(PANEL_FAMILY_HDENTER);
    end
    gCallFuncDelay(0.1,self:getNode("btn_hd"),enter);
  elseif(enterId == 2) then
    --图腾
    local fla = gCreateFla("ui_jz_draw");
    gAddChildInCenterPos(self:getNode("btn_tuteng"),fla);
    local enter = function()
      Panel.popUpVisible(PANEL_FAMILY_SKILL);
    end
    gCallFuncDelay(0.1,self:getNode("btn_tuteng"),enter);    
  elseif(enterId == 3) then
    --大厅
    local fla = gCreateFla("ui_jz_hall");
    gAddChildInCenterPos(self:getNode("btn_main"),fla);
    local enter = function()
      self:enterHall();
      -- Panel.popUpVisible(PANEL_FAMILY_HALL,self);
    end
    gCallFuncDelay(0.1,self:getNode("btn_main"),enter);      
  elseif(enterId == 4) then
    --军团战
    local fla = gCreateFla("ui_jz_fight");
    gAddChildInCenterPos(self:getNode("flag_battle"),fla);

        Net.sendFamilyMatchInfo()
    --gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"));
  elseif(enterId == 5) then
    --商店
    local fla = gCreateFla("ui_jz_shop");
    gAddChildInCenterPos(self:getNode("btn_shop"),fla);
    local enter = function()
        if Module.isClose(SWITCH_FAMILY_SHOP4) or gFamilyInfo.iLevel < DB.getFamilyBuildUnlock(11) then
            Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY)
        else
            Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY_4)
        end
    end
    gCallFuncDelay(0.1,self:getNode("btn_shop"),enter); 
  elseif(enterId == FAMILY_ENTER_ORE) then
    --挖矿
    local fla = gCreateFla("ui_jz_wakuang");
    gAddChildInCenterPos(self:getNode("btn_ore"),fla);
    local enter = function()
      Net.sendFamilyOreInfo()
      -- Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_FAMILY)
    end
    gCallFuncDelay(0.1,self:getNode("btn_ore"),enter);     
  elseif(enterId == FAMILY_ENTER_ARENA) then
    -- 军团竞技
    local fla = gCreateFla("ui_jz_fuben");
    gAddChildInCenterPos(self:getNode("btn_stage"),fla);
    local enter = function()

        local stagePhase, lefttime = Data.getFamilyStagePhase()
        if stagePhase == FAMILY_STAGE_NONE then
            gShowNotice(gGetWords("noticeWords.plist","no_family_stage_fight_time"))
            return
        end

        local lv = DB.getFamilyBuildUnlock(11)
        if gFamilyInfo.iLevel < lv then
            gShowNotice(gGetWords("familyWords.plist","family_war_sign_fail1",lv))
        else
            Net.sendFamilyStageInfo()
        end
    end
    gCallFuncDelay(0.1,self:getNode("btn_stage"),enter);     
  elseif (enterId == FAMILY_ENTER_DONATE)   then
      if  Data.getCurLevel() < self.donateLv then
          gShowNotice(gGetWords("familyWords.plist","family_donate_lock"))
        return
      end
      Panel.popUp(PANEL_FAMILY_DONATE_LIST);
  end
end

-- function FamilyHomePanel:createMemList()

--   --排序
-- --  local function sortWithOnLine(mem1,mem2)
-- --    local lv1 = mem1.iLogin;
-- --    local lv2 = mem2.iLogin;
-- --    if(lv1 < lv2) then
-- --      return true;
-- --    end
-- --    return false;
-- --  end
-- --  table.sort(gFamilyMemList,sortWithOnLine);
  
--   local function sortWithType(mem1,mem2)
--     local lv1 = mem1.iLogin;
--     local lv2 = mem2.iLogin;

--     if mem1.iLogin ~=0 and mem2.iLogin ~= 0 then
--       if mem1.iType == 9 and mem2.iType == 9 then
--         if mem1.iLogin < mem2.iLogin then
--           return true;
--         end
--       elseif mem1.iType < mem2.iType then
--         return true;
--       end
--     else
--       if mem1.iLogin < mem2.iLogin then
--         return true;
--       end
--     end
    
-- --    if mem1.iLogin < mem2.iLogin then
-- --      return true;
-- --    elseif mem1.iLogin ~=0 and mem2.iLogin ~= 0 then
-- --      if mem1.iType < mem2.iType then
-- --        return true;
-- --      else
-- --        return false;  
-- --      end
-- --    else
-- --      return false;  
-- --    end

--     return false;
--   end
--   table.sort(gFamilyMemList,sortWithType);
  
--   local cur_data = {};
--   for key,value in ipairs(gFamilyMemList) do
--     if value.uid == Data.getCurUserId() then
-- --      echo("key = "..key);
--       cur_data = value;
--       table.remove(gFamilyMemList,key);
--       table.insert(gFamilyMemList,1,cur_data);
--       break;
--     end
--   end

--   self.scroll_mem:clear();
--   for key,value in ipairs(gFamilyMemList) do
--     local item = self:createOneMem(value);
--     self.scroll_mem:addItem(item);

--   end
--   self.scroll_mem:layout(true);

-- end


function FamilyHomePanel:createOneMem(data)
    local item=FamilyMemItem.new();
    item:setData(data);
    item.onCheck=function (data)
        self:onCheck(data);
    end
    return item;
end

function FamilyHomePanel:addFamilyMem(data)
    local item = self:createOneMem(data);

    self.scroll_mem:addItem(item);
    self.scroll_mem:layout(true);
end

function FamilyHomePanel:removeFamilyMem(index)
--  local index = data.index;
  if(index >= 0) then
    self.scroll_mem:removeItemByIndex(index);
    self:refreshMemCount();
  end  
end

function FamilyHomePanel:expelFamilyMem()
  -- local index = Data.removeFamilyMemWithUid(self.send_uid);
  -- self:removeFamilyMem(index);
  
  self.menu:onClose();
  
end

function FamilyHomePanel:appontFamilyMem()

  -- for key,value in ipairs(gFamilyMemList) do  
  --   if value.uid == self.send_uid then
  --     value.iType = self.send_type;
  --     break;
  --   end
  -- end
  
  -- if self.send_type == 1 and Data.getCurFamilyType() == 1 then
  --   --自己变为普通成员
  --   gFamilyInfo.iType = 9;

  --   for key,var in pairs(gFamilyMemList) do
  --       if var.uid == Data.getCurUserId() then
  --         var.iType = 9;
  --         break;
  --       end
  --   end

  -- end
  
  -- self:createMemList();
  -- -- self.menu2:onClose();
  self.menu:onClose();
end

function FamilyHomePanel:onCheck(data)
  print("show menu");

  --  if(self.menu ~= nil)then
  --    self.menu:setVisible(true);
  --    return;
  --  end
  
  if (data.uid == Data.getCurUserId()) then
    self:onQuitFamily(node,data);
    return;
  end
  local iType = data.iType;
  if(data.bTemp) then
    iType = 10;
  end
  self.menu = Panel.popUpVisible(PANEL_DYNAMIC_MENU,
    {uid=data.uid,name=data.sName,lv=data.iLevel,vip=data.iVip,coat=data.iCoat,loginTime=data.iLogin,familyType=iType,show = data.show});
  -- self.menu = DynamicMenuPanel.new({name=data.sName,lv=data.iLevel,vip=data.iVip,coat=data.iCoat,loginTime=data.iLogin,familyType=iType});
  -- local size=cc.Director:getInstance():getWinSize()
  -- self.menu:setPosition((size.width - self.menu.mapW)/2,(size.height - (size.height - self.menu.mapH)/2));
  -- gPanelLayer:addChild(self.menu,100);

  if self.menu ~= nil then
    -- self.menu.data = data;
    -- self.menu:setName(data.sName);


    if(data.uid == Data.getCurUserId()) then
      local pBtn4 = self.menu:addBtn(gGetWords("familyMenuWord.plist","btn1"),"btn_exit");
      -- self.menu:setCallFuncNDWithTouchNode(pBtn4,self,self.onQuitFamily,data);    
    else
      local iType = Data.getCurFamilyType();
      if(iType == 1) then
      
        if data.bTemp == false then

          -- local decType = data.iType;
          -- if(decType == 2)then
          --   local pBtn1 = self.menu:addBtn(gGetWords("familyMenuWord.plist","dyn_menu0"),"btn_app_type1");
          --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn1,self,self.onAppointToType1,data);
          --   local pBtn2 = self.menu:addBtn(gGetWords("familyMenuWord.plist","dyn_menu2"),"btn_app_type9");
          --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn2,self,self.onAppointToType9,data);
          -- elseif(decType == 9)then
          --   local pBtn1 = self.menu:addBtn(gGetWords("familyMenuWord.plist","dyn_menu0"),"btn_app_type1");
          --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn1,self,self.onAppointToType1,data);
          --   local pBtn2 = self.menu:addBtn(gGetWords("familyMenuWord.plist","dyn_menu1"),"btn_app_type2");
          --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn2,self,self.onAppointToType2,data);
          -- -- else
          -- end

          local pBtn1 = self.menu:addBtn(gGetWords("familyMenuWord.plist","menu_mem_btn1"),"btn_app");
          -- self.menu:setCallFuncNDWithTouchNode(pBtn1,self,self.onAppoint,data);
        end
        
        local pBtn2 = self.menu:addBtn(gGetWords("familyMenuWord.plist","menu_mem_btn2"),"btn_expel");
        -- self.menu:setCallFuncNDWithTouchNode(pBtn2,self,self.onExpel,data);
      elseif iType == 2 then
        local decType = data.iType;
        if decType == 9 then
          local pBtn2 = self.menu:addBtn(gGetWords("familyMenuWord.plist","menu_mem_btn2"),"btn_expel");
          -- self.menu:setCallFuncNDWithTouchNode(pBtn2,self,self.onExpel,data);
        end
      else
      end
      local pBtn1 = self.menu:addBtn(gGetWords("familyMenuWord.plist","menu_btn6"),"btn_add_friend");
      -- self.menu:setCallFuncNDWithTouchNode(pBtn1,self,self.onAddFriend,data);
      local pBtn2 = self.menu:addBtn(gGetWords("familyMenuWord.plist","menu_btn2"),"btn_fight");
      -- self.menu:setCallFuncNDWithTouchNode(pBtn2,self,self.onFight,data);
      local pBtn3 = self.menu:addBtn(gGetWords("familyMenuWord.plist","menu_btn0"),"btn_formation");
      -- self.menu:setCallFuncNDWithTouchNode(pBtn3,self,self.onFormation,data);
    end


    self.menu.onAppointToType1 = function(data)
      self:onAppointToType1(data);
    end
    self.menu.onAppointToType2 = function(data)
      self:onAppointToType2(data);
    end
    self.menu.onAppointToType9 = function(data)
      self:onAppointToType9(data);
    end


    self.menu.onExit = function ()
      self:onQuitFamily();
    end

    self.menu.onApp = function(data)
      self:onAppoint(data);
    end

    self.menu.onExpel = function(data)
      self:onExpel(data);
    end

    self.menu.onAddFriend = function(data)
      self:onAddFriend(data);
    end

    self.menu.onFight = function(data)
      self:onFight(data);
    end

    self.menu.onFormation = function(data)
      self:onFormation(data);
    end

  end
end


function FamilyHomePanel:onQuitFamily()
  -- local word = getWordWithFile("familyMenuWord.plist","exit_family");
  -- NotificationLayer:showConfirmCallFun_lua(word,self,self.handleFamilyExit);
  gConfirmCancel(gGetWords("familyMenuWord.plist","exit_family"),self.handleFamilyExit);
end

function FamilyHomePanel:handleFamilyExit()
  Net.sendFamilyExit();
end

function FamilyHomePanel:onAppoint(data)
  print("onAppoint");
  local iType = Data.getCurFamilyType();
  local decType = data.familyType;
--  if(self.menu ~= nil)then
--    self.menu:setVisible(false);
--  end

  self.menu2 = Panel.popUp(PANEL_FAMILY_MEMTITLE,data);
  if(self.menu2)then
    -- self.menu2 = DynamicMenuPanel.new();
    -- local size=cc.Director:getInstance():getWinSize()
    -- self.menu2:setPosition((size.width - self.menu.mapW)/2,(size.height - (size.height - self.menu.mapH)/2))
    -- gPanelLayer:addChild(self.menu2,100);
    -- self.menu2:setParentMenu(self.menu);
    -- -- self.menu2.data = data;
    -- if(decType == 2)then
    --   local pBtn1 = self.menu2:addBtn(gGetWords("familyMenuWord.plist","title1"),"btn_app_type1");
    --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn1,self,self.onAppointToType1,data);
    --   local pBtn2 = self.menu2:addBtn(gGetWords("familyMenuWord.plist","title9"),"btn_app_type9");
    --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn2,self,self.onAppointToType9,data);
    -- elseif(decType == 9)then
    --   local pBtn1 = self.menu2:addBtn(gGetWords("familyMenuWord.plist","title1"),"btn_app_type1");
    --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn1,self,self.onAppointToType1,data);
    --   local pBtn2 = self.menu2:addBtn(gGetWords("familyMenuWord.plist","title2"),"btn_app_type2");
    --   -- self.menu2:setCallFuncNDWithTouchNode(pBtn2,self,self.onAppointToType2,data);
    -- else
    -- end

      self.menu2.onAppointToType1 = function(data)
        self:onAppointToType1(data);
      end
      self.menu2.onAppointToType2 = function(data)
        self:onAppointToType2(data);
      end
      self.menu2.onAppointToType9 = function(data)
        self:onAppointToType9(data);
      end
      self.menu2.onAppointToType = function(data,type)
        self:onAppointToType(data,type);
      end
  end
end

function FamilyHomePanel:onAppointToType1(data)

  local word = gGetWords("familyMenuWord.plist","family_warning1");
  local function onOk()
    self:handleAppointToType1();
  end 
  gConfirmCancel(word,onOk);
  
  print("onAppointToType1");
  self.send_uid = data.uid;
  self.send_type = 1;
--  sendFamilyAppoint(self.send_uid,self.send_type);
end

function FamilyHomePanel:handleAppointToType1()
  print("onAppointToType1");
  Net.sendFamilyAppoint(self.send_uid,self.send_type);
end


function FamilyHomePanel:onAppointToType2(data)
  print("onAppointToType2");
  self:onAppointToType(data,2);
  -- self.send_uid = data.uid;
  -- self.send_type = 2;
  -- Net.sendFamilyAppoint(self.send_uid,self.send_type);
end

function FamilyHomePanel:onAppointToType9(data)
  print("onAppointToType9");
  self:onAppointToType(data,9);
  -- self.send_uid = data.uid;
  -- self.send_type = 9;
  -- Net.sendFamilyAppoint(self.send_uid,self.send_type);
end

function FamilyHomePanel:onAppointToType(data,type)
  self.send_uid = data.uid;
  self.send_type = type;
  Net.sendFamilyAppoint(self.send_uid,self.send_type);
end

function FamilyHomePanel:onExpel(data)

  local word = gGetWords("familyMenuWord.plist","family_warning2");
  -- NotificationLayer:showConfirmCallFun_lua(word,self,self.handleExpel);
  local function onOk()
    self:handleExpel();
  end  
  gConfirmCancel(word,onOk);
  
--  echo("onExpel");
  self.send_uid = data.uid;
--  sendFamilyExpel(self.send_uid);
end

function FamilyHomePanel:handleExpel()
  print("onExpel id = "..self.send_uid);
  Net.sendFamilyExpel(self.send_uid);
end

function FamilyHomePanel:onAddFriend(data)
--  echo("onAddFriend");
  
    local sContent = gGetWords("friendWords.plist.plist","default_invite");
    Net.sendBuddyInvite(data.uid,sContent);
--  sendBuddyDel(data.uid);
end

function FamilyHomePanel:onFight(data)
  -- Panel.pushRePopupPanel(PANEL_FAMILY_BG)
  if(not NetErr.checkFight(data.lv))then
    return;
  end
  
  Panel.pushRePopupPanel(PANEL_FAMILY_HOME)
  Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_FAMILY_FIGHT,data.uid)
 
end

function FamilyHomePanel:onFormation(data)
  Net.sendBuddyTeam(data.uid);
end

function  FamilyHomePanel:events()

    return {EVENT_ID_FAMILY_NOTICE_REFRESH,
            EVENT_ID_FAMILY_DISMISS,
            EVENT_ID_FAMILY_DISMISS_SUCCESS,
            EVENT_ID_FAMILY_MEM_ADD,
            EVENT_ID_FAMILY_EXIT,
          EVENT_ID_FAMILY_EXPEL,
          EVENT_ID_FAMILY_APPOINT_MEM,
          EVENT_ID_FAMILY_CHANGE_TYPE,
          EVENT_ID_FAMILY_REFRESH_INFO,
        EVENT_ID_FAMILY_SPRING_INIT,
        EVENT_ID_FAMILY_SEVEN_INFO,
        EVENT_ID_FAMILY_APP_LIST,
        EVENT_ID_FAMILY_SAVE_SET,
        EVENT_ID_FAMILY_ENTER,
        EVENT_ID_FAMILY_ACTIVEBOX,
        EVENT_ID_FAMILY_ENTERHALL,
        EVENT_ID_NEW_CHAT,
        EVENT_ID_INIT_FAMILY_CHAT,
        EVENT_ID_FAMILY_UPGRADE,
      }
end

function FamilyHomePanel:dealEvent(event,param)
print("FamilyHomePanel event="..event)
    if(event == EVENT_ID_FAMILY_NOTICE_REFRESH) then
      self:refreshFamilyNotice();  
    elseif event == EVENT_ID_FAMILY_DISMISS then
      -- self:handleDisInfo();  
    elseif event == EVENT_ID_FAMILY_DISMISS_SUCCESS then
      self:familyDiss();  
    elseif event == EVENT_ID_FAMILY_MEM_ADD then
      self:addFamilyMem(param);
    elseif event == EVENT_ID_FAMILY_EXIT then
      self:exitFamily();
    elseif event == EVENT_ID_FAMILY_EXPEL then
      self:expelFamilyMem();
    elseif event == EVENT_ID_FAMILY_APPOINT_MEM then
      self:appontFamilyMem();
    elseif event == EVENT_ID_FAMILY_CHANGE_TYPE then
      self:refreshUIWithChangeType();
    elseif event == EVENT_ID_FAMILY_REFRESH_INFO then
      self:refreshFamilyExp();
      -- self:refreshFamilyExpInMemList();
    elseif event == EVENT_ID_FAMILY_SPRING_INIT then
      self:enterFamilySpring();
    elseif event == EVENT_ID_FAMILY_SEVEN_INFO then
      self:enterFamilySeven();
    elseif event == EVENT_ID_FAMILY_APP_LIST then
      self:refreshMemCount();
    elseif event == EVENT_ID_FAMILY_SAVE_SET then
      self:refreshInfo()
    elseif event == EVENT_ID_FAMILY_ENTER then
      self:onModuleEnter(param);  
    elseif event == EVENT_ID_FAMILY_ACTIVEBOX then
      self:evtHandleActiveBox();  
    elseif event == EVENT_ID_FAMILY_ENTERHALL then
      self:enterHall();    
    elseif(event == EVENT_ID_NEW_CHAT)then
        self.msgWin:dealEvent(event,param);  
    elseif(event == EVENT_ID_INIT_FAMILY_CHAT) then
        self.msgWin = MsgWinLayer.new(2);
        self.msgWin:setAnchorPoint(cc.p(0,-1));
        self:getNode("layer_msg"):addChild(self.msgWin);
    elseif(event==EVENT_ID_FAMILY_UPGRADE)then
        self:refreshStageStatus()
    end
end

function FamilyHomePanel:onTouchEnded(target)
    Panel.popBackTopPanelByType(PANEL_CHAT)
    -- print("FamilyHomePanel:onTouchEnded name = "..target.touchName);
    if  target.touchName=="btn_close"then
        Panel.popBackAll();
    elseif target.touchName == "btn"then
        self:onMemage();    
    elseif target.touchName=="btn_hd"then
        self:onModuleEnter(FAMILY_ENTER_HD);
    elseif target.touchName == "btn_tuteng"then
        self:onModuleEnter(FAMILY_ENTER_TUTENG);
    elseif target.touchName == "btn_main"then
        self:onModuleEnter(FAMILY_ENTER_MAIN);
    elseif target.touchName == "btn_battle"then
        self:onModuleEnter(FAMILY_ENTER_BATTLE);
    elseif target.touchName == "btn_shop"then
        self:onModuleEnter(FAMILY_ENTER_SHOP);
    elseif target.touchName == "btn_ore"then
        self:onModuleEnter(FAMILY_ENTER_ORE);
    elseif target.touchName == "btn_stage"then
        if Module.isClose(SWITCH_FAMILY_STAGE) then
            gShowNotice(gGetWords("unlockWords.plist","unlock_tip2"))
            return
        end
        self:onModuleEnter(FAMILY_ENTER_ARENA);
    elseif target.touchName== "btn_donate" then
        self:onModuleEnter(FAMILY_ENTER_DONATE);
    elseif target.touchName == "btn_others"then
        Panel.popUpVisible(PANEL_FAMILY_SEARCH,2);
    elseif target.touchName == "btn_rank"then
        Panel.popUp(PANEL_ARENA_RANK,4);
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_FAMILY);
    elseif target.touchName == "btn_dynamic"then
        Panel.popUpVisible(PANEL_FAMILY_DYNAMIC);                
    elseif target.touchName == "box1" then
        self:onActiveBox(1);    
    elseif target.touchName == "box2" then
        self:onActiveBox(2);        
    elseif target.touchName == "box3" then
        self:onActiveBox(3);        
    elseif target.touchName == "box4" then
        self:onActiveBox(4);
    elseif(target.touchName=="btn_chat")then
        Panel.popUpVisible(PANEL_CHAT,1,{curType = 3},true)
        self:showBtnChat(false);
        -- gMsgWinLayer:hide()
    elseif(target.touchName == "btn_spring")then
      Net.sendFamilySpringInfo();
    end
end

function FamilyHomePanel:onMemage()
  if Data.isFamilyManager() or Data.getCurFamilyType()==3 then
    Panel.popUpVisible(PANEL_FAMILY_MAMAGE);
  -- else
    -- self:onQuitFamily();
  end
end

function FamilyHomePanel:lockCloseMoudel()
    if Module.isClose(SWITCH_FAMILY_STAGE) then
        self:lockMoudel(SWITCH_FAMILY_STAGE)
    end
end

function FamilyHomePanel:lockMoudel(moudel)
    if moudel == SWITCH_FAMILY_STAGE then
        local lock = cc.Sprite:create("images/ui_public1/small_lock.png")
        local node = self:getNode("icon_stage")
        local nodeContentSize = node:getContentSize()
        local lockContentSize = lock:getContentSize()
        gRefreshNode(self:getNode("icon_stage"), lock, cc.p(0.5,0.5),cc.p(0,nodeContentSize.height / 2 + lockContentSize.height * 0.3),100)
        self:getNode("layer_stage_lefttime"):setVisible(false)
    end
end

function FamilyHomePanel:refreshDonateLockStatus()
  if Module.isClose(SWITCH_FAMILY_DONATE) then
      self:getNode("btn_donate"):setVisible(false)
      return        
  end
  if Data.getCurLevel() < self.donateLv then
      local lock = cc.Sprite:create("images/ui_public1/small_lock.png")
      local node = self:getNode("icon_donate")
      local nodeContentSize = node:getContentSize()
      local lockContentSize = lock:getContentSize()
      gRefreshNode(self:getNode("icon_donate"), lock, cc.p(0.5,0.5),cc.p(0,nodeContentSize.height / 2 + lockContentSize.height * 0.3),100)
  end

end

function FamilyHomePanel:refreshStageStatus()
    if Module.isClose(SWITCH_FAMILY_STAGE) then
        return
    end
    
    local lv = DB.getFamilyBuildUnlock(11)
    -- self:getNode("layer_stage_lefttime"):setRotation3D(cc.vec3(0,-20,0))
    if gFamilyInfo.iLevel < lv then
        self:lockMoudel(SWITCH_FAMILY_STAGE)
        self:getNode("layer_stage_lefttime"):setVisible(false)
        return
    else
        self:getNode("icon_stage"):removeChildByTag(100)
        self:getNode("layer_stage_lefttime"):setVisible(true)
    end

    self:refreshStageLefttime()
end

function FamilyHomePanel:refreshStageLefttime()
    if not self:getNode("layer_stage_lefttime"):isVisible() then
        return
    end

    local stagePhase, lefttime = Data.getFamilyStagePhase()
    local titleStageTime = ""
    if stagePhase == FAMILY_STAGE_NONE then
        self:getNode("layer_stage_wait"):setVisible(true)
        self:setLabelString("txt_stage_lefttime",gParserHourTime(lefttime))
        self:getNode("flag_stage_fight"):setVisible(false)
    else
        self:getNode("layer_stage_wait"):setVisible(false)
        self:getNode("flag_stage_fight"):setVisible(true)
    end
end

 

return FamilyHomePanel