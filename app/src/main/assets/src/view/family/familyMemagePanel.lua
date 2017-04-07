
local FamilyMemagePanel=class("FamilyMemagePanel",UILayer)

function FamilyMemagePanel:ctor(btnIndex)
  self:init("ui/ui_family_mamage.map")
  self:getNode("lv_limit_input"):setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
  self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
  self.chNameTime = gFamilyInfo.chnametime - gGetCurServerTime();
  local layer_set = self:getNode("layer_set");
  local txt_chname_time = self:getNode("txt_chname_time");
    local function __update()
     -- print("update time = "..self.iDisLeftTime);
      if(self.iDisLeftTime > 0) then
        self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
        self:refreshDisTime();
      end

      if layer_set:isVisible() then
          if self.chNameTime > 0 then
              self.chNameTime = gFamilyInfo.chnametime - gGetCurServerTime();
              self:refreshChNameTime();
          else
              self.chNameTime = 0
              txt_chname_time:setVisible(false)
          end
      end
    end
  self:scheduleUpdate(__update,1); 

  self:refreshBtnDis();


    self.btns={
        "btn_men",
        "btn_notice",
        "btn_update",
        "btn_set",
        "btn_email",
        "btn_dis",
        "btn_quit",
    }

    if(btnIndex == nil)then
      self:selectBtn("btn_men");
    else
      self:selectBtn(self.btns[btnIndex]);      
    end

    self.app_scroll = self:getNode("app_scroll");

    if Data.getCurFamilyType() == 2 then
      self:getNode("btn_quit"):setVisible(true);
      self:getNode("btn_quit"):setPosition(self:getNode("btn_dis"):getPosition());
      -- self:getNode("layer_btns"):setPositionY(self:getNode("layer_btns"):getPositionY() - 20);
    else
      self:getNode("btn_quit"):setVisible(false);
    end

    gCreateBtnBack(self);

    -- self:setTouchEnableGray("layer_btn_update",false);
    -- self:setTouchEnableGray("btn_update",false);
    self:initBtns();
    self:initVarOfSet()
    self:initUpdate();
    self:initNotice();
    self:initEmail();
end

function FamilyMemagePanel:initBtns()
    -- self:setTouchEnableGray("btn_email",false);
    if Data.getCurFamilyType() == 3 then
      self:setTouchEnableGray("btn_notice",false);
      self:setTouchEnableGray("btn_update",false);
      self:setTouchEnableGray("btn_set",false);
      self:setTouchEnableGray("btn_dis",false);
      self:setTouchEnableGray("btn_quit",false);
    else
    end
end

function FamilyMemagePanel:refreshBtnDis()

    self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
    if Data.getCurFamilyType() ~= 1 then
      self:getNode("btn_dis"):setVisible(false);
    end

    if(self.iDisLeftTime > 0) then
      self:setLabelString("txt_btn_dis",gGetWords("familyMenuWord.plist","btn2"));
    else
      self:setLabelString("txt_btn_dis",gGetWords("familyMenuWord.plist","90"));  
    end

    self:onDis();
end
function FamilyMemagePanel:resetBtnTexture()

    for key, btn in pairs(self.btns) do
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end
end
function FamilyMemagePanel:showLayer(name)
    local layers={
        {"btn_men","layer_men"},
        {"btn_notice","layer_notice"},
        {"btn_update","layer_update"},
        {"btn_set","layer_set"},
        {"btn_email","layer_email"},
        {"btn_dis","layer_dis"},
        {"btn_quit","layer_quit"}
    }

    for key, layer in pairs(layers) do
        self:getNode(layer[2]):setVisible(layer[1] == name);
    end

    --TOCHECK input为什么会显示出来
    self:getNode("input"):setVisible(name == "btn_notice")
    self:getNode("lv_limit_input"):setVisible(name == "btn_set")
end

function FamilyMemagePanel:selectBtn(name)
    self.oldSubType     = self.curSubType
    self.curSubType     = name
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
    self:getNode("flag_arrow"):setPositionY(self:getNode(name):getPositionY());

    self:showLayer(name);
    if name=="btn_men"then
      self:onMem();
    elseif  name=="btn_notice"then
      self:onNotice();
    elseif name == "btn_update"then
      self:onUpdate();
    elseif name == "btn_set"then
      self:onSet();
    elseif name == "btn_email"then
      self:onEmail();
    elseif name == "btn_dis"then
      self:onDis();
    elseif name == "btn_quit"then
      self:onQuit();
    end

    if self.curSubType ~= "btn_set" and self.oldSubType == "btn_set" then
        Net.sendFamilySaveSet(self.iconInSet, self.applyTypeInSet, self.limitLvInSet)
    end
end
function FamilyMemagePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
      self:onClose();
    elseif  target.touchName=="btn_men"then
      self:selectBtn(target.touchName);
    elseif  target.touchName=="btn_notice"then
      self:selectBtn(target.touchName);
    elseif target.touchName == "btn_update"then
      self:selectBtn(target.touchName);
    elseif target.touchName == "btn_set"then
      self:selectBtn(target.touchName);
    elseif target.touchName == "btn_email"then
      self:selectBtn(target.touchName);
    elseif target.touchName == "btn_dis"then
      self:selectBtn(target.touchName);
    elseif target.touchName == "btn_quit"then
      self:selectBtn(target.touchName);
    elseif target.touchName == "notice_btn_ok" then
      self:onNoticeOk();  
    elseif target.touchName == "dis_btn_ok" then
      self:onDisBtn();
    elseif target.touchName == "quit_btn_ok" then
      self:onQuitBtn();
    elseif target.touchName == "layer_set_btn_left" then
      self:addApplyType(-1)
    elseif target.touchName == "layer_set_btn_right" then
      self:addApplyType(1)
    elseif target.touchName == "layer_set_btn_left2" then
      self:addLimitLv(-1)
    elseif target.touchName == "layer_set_btn_right2" then
      self:addLimitLv(1)
    elseif target.touchName == "btn_chicon" then
      local headPanel = Panel.popUpVisible(PANEL_FAMILY_HEAD)
      headPanel.onChooseIcon = function(idx)
          self:onChooseIcon(idx)
      end
    elseif target.touchName == "btn_chname" then
        Panel.popUpVisible(PANEL_FAMILY_CHNAME,nil, nil, true)
    elseif target.touchName == "layer_btn_update" then
      if(NetErr.FamilyUpgrade())then
        local needFExp = self.needFExpLevelUp - gFamilyInfo.curFExp;
        if(needFExp>0)then
          gShowCmdNotice("family.upgrade",33);
          return;
        end
        Net.sendFamilyUpgrade();
      end
        -- local needFExp = self.needFExpLevelUp - gFamilyInfo.curFExp;
        -- if(needFExp > )
    elseif target.touchName == "mail_btn_ok" then
      self:onSendEmail();
    end
end


function  FamilyMemagePanel:events()
    return {EVENT_ID_FAMILY_APP_LIST,
            EVENT_ID_FAMILY_DISMISS,
            EVENT_ID_FAMILY_NOTICE_MODIFY_SUCCESS,
            EVENT_ID_FAMILY_APP_REMOVE,
            EVENT_ID_FAMILY_APP_REFUSE,
            EVENT_ID_FAMILY_CH_NAME,
            EVENT_ID_FAMILY_SAVE_SET,
            EVENT_ID_FAMILY_UPGRADE,
            EVENT_ID_FAMILY_EMAIL_SUCCESS
          }
end

function FamilyMemagePanel:dealEvent(event,param)

    if(event == EVENT_ID_FAMILY_APP_LIST) then
        self:refreshAppLayer();
    elseif(event == EVENT_ID_FAMILY_DISMISS) then
        self:refreshBtnDis();    
    elseif(event == EVENT_ID_FAMILY_NOTICE_MODIFY_SUCCESS) then
        gFamilyInfo.sNotice = string.filter(self:getNode("input"):getText());
    elseif(event == EVENT_ID_FAMILY_APP_REMOVE) then
        self:removeFamilyApply(param);  
    elseif event == EVENT_ID_FAMILY_APP_REFUSE then
        self:refuseFamilyApp();
    elseif event == EVENT_ID_FAMILY_CH_NAME then
        self.chNameTime = gFamilyInfo.chnametime
        self:setFamilyName()
    elseif event == EVENT_ID_FAMILY_SAVE_SET then
        self:saveSetInfo()
    elseif event == EVENT_ID_FAMILY_UPGRADE then
        self:initUpdate();
    elseif event == EVENT_ID_FAMILY_EMAIL_SUCCESS then
        self:clearEmail();        
    end
end


-----审核列表
function FamilyMemagePanel:onMem()
  Net.sendFamilyApplyList();
end
function FamilyMemagePanel:refreshAppLayer()
  self:setLabelString("app_txt_count",table.getn(gFamilyMemList).."/"..Data.getFamilyMaxMem());
  self:refreshAppList();
end
function FamilyMemagePanel:refreshAppList()

  self.app_scroll:clear();
  for key,value in ipairs(gFamilyAppList) do
    local item = self:createOneApply(value,key);
    self.app_scroll:addItem(item);
  end
  self.app_scroll:layout(true);
  self:dealRedDotAppList();

end

function FamilyMemagePanel:createOneApply(data,index)
    local item=FamilyApplyItem.new();
    item:setData(data, index);
    item.onAgree = function(data)
      self:onAgree(data);
    end
    item.onRefuse = function(data)
      self:onRefuse(data);
    end
    return item;
end


function FamilyMemagePanel:onAgree(data)
  Net.sendFamilyPass(data.uid);
end

function FamilyMemagePanel:onRefuse(data)
  self.send_uid = data.uid;
  Net.sendFamilyRefuse(data.uid);
end

function FamilyMemagePanel:removeFamilyApply(data)
  local index = data.index;
  if(index >= 0) then
    self.app_scroll:removeItemByIndex(index);
    -- self:refreshBtn();
    -- self:closeFamilyApply();
    self:dealRedDotAppList();
  end
end

function FamilyMemagePanel:refuseFamilyApp()
  local index = Data.removeFamilyAppWithUid(self.send_uid);
  if(index >= 0) then
    self.app_scroll:removeItemByIndex(index);
    -- self:refreshBtn();
    -- self:closeFamilyApply();
    self:dealRedDotAppList();
  end
end

function FamilyMemagePanel:dealRedDotAppList()
  local count = table.getn(gFamilyAppList);
  print("count = "..count);
  if count <= 0 then
    Data.redpos.bolFamilyApply = false;
  end
end




-----修改公告
function FamilyMemagePanel:initNotice()

    local function onEditCallback(name, sender)
        if(name=="changed")then
            self:textChanged()
        end
    end
    self:getNode("input"):registerScriptEditBoxHandler(onEditCallback)

end

function FamilyMemagePanel:onNotice()
  self:getNode("input"):setText(gFamilyInfo.sNotice);
  -- self:setLabelString("notice_txt_tip",gGetWords("noticeWords.plist","jz_notice",gFamilyNoticeCount));
  self:textChanged();
end 

function FamilyMemagePanel:textChanged()
    gRefreshLeftCount(self:getNode("notice_txt_tip"),gFamilyNoticeCount,string.filter(self:getNode("input"):getText()));
end

function FamilyMemagePanel:onNoticeOk()
    local sText = string.filter(self:getNode("input"):getText());

    if sText=="" then
        local sWord = gGetWords("noticeWords.plist","intput_empty");
        gShowNotice(sWord);
        return;
    end

    Net.sendFamilyNotice(sText);
end

--军团升级
function FamilyMemagePanel:initUpdate()
  -- body
  self:setLabelString("txt_cur_fexp",gFamilyInfo.curFExp);
  self:setLabelString("txt_total_fexp",gFamilyInfo.totalFExp);
  --当前等级
  self:replaceLabelString("txt_cur_lv",Data.getCurFamilyLv());
  local curLvData = Data.getFamilyLvData(Data.getCurFamilyLv());
  self.needFExpLevelUp = curLvData.fexp;
  self:createUpdateAllItem(self:getNode("cur_lv_scroll"),curLvData,Data.getCurFamilyLv());
  self:setLabelString("txt_need_fexp",self.needFExpLevelUp);

  --下个等级
  local nextLvData = Data.getFamilyLvData(Data.getCurFamilyLv()+1);
  if(nextLvData == nil)then
    self:getNode("bg_next_lv_tip"):setVisible(false);
  else
    local needFExp = self.needFExpLevelUp - gFamilyInfo.curFExp;
    self:getNode("txt_need_fexp_tip"):setVisible(needFExp>0);
    if(needFExp > 0)then
      self:replaceRtfString("txt_need_fexp_tip",needFExp);
    end
    self:replaceLabelString("txt_next_lv",Data.getCurFamilyLv()+1);
    self:createUpdateAllItem(self:getNode("next_lv_scroll"),nextLvData,Data.getCurFamilyLv()+1);
  end

  self:resetLayOut();
end
function FamilyMemagePanel:createUpdateAllItem(scroll,updateData,lv)
    scroll:clear();
    local item = self:createUpdateItem(1,updateData.member);
    scroll:addItem(item);
    if(updateData.refdis < 100)then
      item = self:createUpdateItem(2,gGetDiscount(updateData.refdis/10));
      scroll:addItem(item);
    end
    if(updateData.shopdis < 100)then
      item = self:createUpdateItem(3,gGetDiscount(updateData.shopdis/10));
      scroll:addItem(item);
    end
    item = self:createUpdateItem(4,updateData.skilllv);
    scroll:addItem(item);
    local allSkills = Data.getFamilyUnlockSkill(lv);
    if(allSkills)then
      for key,newSkill in pairs(allSkills) do
        item = self:createUpdateItem(5,newSkill.buff.name);
        local icon = cc.Sprite:create("images/icon/skill/"..newSkill.buff.icon..".png");
        gAddChildByAnchorPos(item:getNode("icon"),icon,cc.p(0.5,0.5))
        scroll:addItem(item);
      end
    end
    if(updateData.fight > 0)then
      item = self:createUpdateItem(6,updateData.fight);
      scroll:addItem(item);
    end
    item = self:createUpdateItem(7,updateData.ore);
    scroll:addItem(item);
    if(updateData.skilllvspecial > 0)then
      item = self:createUpdateItem(8,updateData.skilllvspecial);
      scroll:addItem(item);
    end
    if(updateData.memType2 and updateData.memType2>0)then
      local item = self:createUpdateItem(9,updateData.memType2);
      scroll:addItem(item);
    end
    if(updateData.memType3 and updateData.memType3>0)then
      local item = self:createUpdateItem(10,updateData.memType3);
      scroll:addItem(item);
    end
    if(updateData.memType4 and updateData.memType4>0)then
      local item = self:createUpdateItem(11,updateData.memType4);
      scroll:addItem(item);
    end
    scroll:layout();  
end
function FamilyMemagePanel:createUpdateItem(type,value)
  --type 1--成员人数 2--商店刷 3--商店购买 4--技能研究等级上限 5--解锁新技能 6--参加军团战 7--金矿数量 8--特殊图腾
  --9 副团长 10--长老 11-先锋
  local item = UILayer.new();
  item:init("ui/ui_family_update_item.map");
  item:changeTexture("icon","images/ui_family/level_icon_0"..type..".png");
  item:setLabelString("txt_content",gGetWords("familyMenuWord.plist","update"..type,value));
  return item;
end
function FamilyMemagePanel:onUpdate()

end 

function FamilyMemagePanel:onSet()
    self:setInfo()
end 

function FamilyMemagePanel:clearEmail()
  self:getNode("mail_title_input"):setText("");
  self:getNode("mail_content_input"):setText("");
  self:emailTextChanged();
end

function FamilyMemagePanel:initEmail()

    local function onEditCallback(name, sender)
        if(name=="changed")then
            self:emailTextChanged()
        end
    end
    self:getNode("mail_content_input"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("mail_title_input"):registerScriptEditBoxHandler(onEditCallback)

    -- self:getNode("mail_content_input"):setMaxLength(gFamilyEamilContentCount);
    -- self:getNode("mail_title_input"):setMaxLength(gFamilyEamilTitleCount);
end

function FamilyMemagePanel:emailTextChanged()
  gRefreshLeftCount(self:getNode("mail_txt_tip"),gFamilyEamilContentCount,string.filter(self:getNode("mail_content_input"):getText()));
  gRefreshLeftCount(self:getNode("mail_txt_title_tip"),gFamilyEamilTitleCount,string.filter(self:getNode("mail_title_input"):getText()));
end

function FamilyMemagePanel:onEmail()
  self:emailTextChanged();
end

function FamilyMemagePanel:onSendEmail()
  local title = self:getNode("mail_title_input"):getText();
  local content = self:getNode("mail_content_input"):getText();
  if(title == "")then
    gShowNotice(gGetWords("familyWords.plist","family_mail1"));
    return;
  end
  if(content == "")then
    gShowNotice(gGetWords("familyWords.plist","family_mail2"));
    return;
  end
  Net.sendFamilyMail(title,content);
end

----解散军团
function FamilyMemagePanel:onDis()
  if(self.iDisLeftTime > 0) then
    -- self:setLabelString("dis_txt_content",gGetWords("familyMenuWord.plist","menu_cance_dis"));
    self:refreshDisTime();
    self:setLabelString("dis_txt_btn",gGetWords("familyMenuWord.plist","menu_dis_btn3"));
  else
    self:setLabelString("dis_txt_content",gGetWords("familyMenuWord.plist","menu_dis"));
    self:setLabelString("dis_txt_btn",gGetWords("familyMenuWord.plist","menu_dis_btn2"));
  end
end
function FamilyMemagePanel:refreshDisTime()
  -- print("refreshDisTime");
  if(self.iDisLeftTime == nil) then
    self.iDisLeftTime = gFamilyInfo.iDistime - gGetCurServerTime();
  end
  local sTime = gParserHourTime(self.iDisLeftTime,0);
  self:setLabelString("dis_txt_content",gGetWords("familyMenuWord.plist","menu_cance_dis",sTime));
  -- self.pLabDisTime:setString(sTime); 
  
end
function FamilyMemagePanel:onDisBtn()
  if(gFamilyInfo.iDistime > 0) then
    Net.sendFamilyCancelDismiss();
  else
    Net.sendFamilyDismiss();
  end 
end

--退出家族
function FamilyMemagePanel:onQuit()

end
function FamilyMemagePanel:onQuitBtn()
  Net.sendFamilyExit();
end

--家族设置
function FamilyMemagePanel:setInfo()
    self:addLimitLv(0)
    self:addApplyType(0)
    self:changeTexture("icon_family","images/ui_family/bp_icon_"..self.iconInSet..".png")
    self:setFamilyName()
end

function FamilyMemagePanel:setFamilyName()
    self:setLabelString("txt_family_name", gFamilyInfo.sName)
    if Panel.isOpenPanel(PANEL_FAMILY_HOME) then
        local homePanel = Panel.getOpenPanel(PANEL_FAMILY_HOME)
        if nil ~= homePanel then
            homePanel:refreshInfo()
        end
    end
end

function FamilyMemagePanel:refreshChNameTime()
  if self.chNameTime == nil then
      self.chNameTime = gFamilyInfo.chnametime - gGetCurServerTime()
  end

  if self.chNameTime <= 0 then
      self:getNode("txt_chname_time"):setVisible(false)
      self:setTouchEnableGray("btn_chname",true)
      gFamilyInfo.chnametime = 0
      return
  else
      self:setTouchEnableGray("btn_chname",false)
  end
  self:getNode("txt_chname_time"):setVisible(true)

  local hour = math.floor(self.chNameTime/3600)
  if hour > 0 then
      self:setLabelString("txt_chname_time",gGetWords("familyMenuWord.plist","ch_name_hour",hour))
  else
      local min  = math.floor((self.chNameTime%3600)/60)
      if min > 0 then
          self:setLabelString("txt_chname_time",gGetWords("familyMenuWord.plist","ch_name_min",min))
      else
          local sec  = self.chNameTime%60
          self:setLabelString("txt_chname_time",gGetWords("familyMenuWord.plist","ch_name_sec",sec))
      end
  end  
end

function FamilyMemagePanel:addApplyType(num)
    self.applyTypeInSet = self.applyTypeInSet + num
    self:setLabelString("txt_apply_type", "apply_type".. self.applyTypeInSet, "familyMenuWord.plist")
    if self.applyTypeInSet == FAMILY_APPLY_REFUSE then
        self:setTouchEnableGray("layer_set_btn_right",false)
    elseif self.applyTypeInSet == FAMILY_APPLY_NEED_VERIFY then
        self:setTouchEnableGray("layer_set_btn_left",false)
    else
        self:setTouchEnableGray("layer_set_btn_right",true)
        self:setTouchEnableGray("layer_set_btn_left",true)
    end
end

function FamilyMemagePanel:addLimitLv(num)
    if 0 ~= num then
        self.limitLvInSet = toint(self:getNode("lv_limit_input"):getText())
    end
    self.limitLvInSet = self.limitLvInSet + num
    if self.limitLvInSet <= gUnlockLevel[Unlock.system.family.unlockType] then
        self.limitLvInSet = gUnlockLevel[Unlock.system.family.unlockType]
        self:setTouchEnableGray("layer_set_btn_left2",false)
    elseif self.limitLvInSet >= DB.getCardMaxLevel() then
        self.limitLvInSet = DB.getCardMaxLevel()
        self:setTouchEnableGray("layer_set_btn_right2",false)
    else
        self:setTouchEnableGray("layer_set_btn_left2",true)
        self:setTouchEnableGray("layer_set_btn_right2",true)
    end
    self:getNode("lv_limit_input"):setText(tostring(self.limitLvInSet))
end

function FamilyMemagePanel:onChooseIcon(idx)
    self.iconInSet = idx
    self:changeTexture("icon_family","images/ui_family/bp_icon_"..idx..".png")
end

function FamilyMemagePanel:saveSetInfo()
    gFamilyInfo.apptype     = self.applyTypeInSet
    gFamilyInfo.limitlv     = self.limitLvInSet
    if gFamilyInfo.icon ~= self.iconInSet then
        gFamilyInfo.icon = self.iconInSet
        if Panel.isOpenPanel(PANEL_FAMILY_HOME) then
            local homePanel = Panel.getOpenPanel(PANEL_FAMILY_HOME)
            if nil ~= homePanel then
                homePanel:refreshInfo()
            end
        end
    end
end

function FamilyMemagePanel:limitLvTxtEnded()
    local limitInput = self:getNode("lv_limit_input")
    local changeLv = toint(limitInput:getText())
    if changeLv < gUnlockLevel[Unlock.system.family.unlockType] then
        limitInput:setText(tostring(gUnlockLevel[Unlock.system.family.unlockType]))
        self:setTouchEnableGray("layer_set_btn_left2",false)
    elseif changeLv > DB.getCardMaxLevel() then
        limitInput:setText(tostring(DB.getCardMaxLevel()))
        self:setTouchEnableGray("layer_set_btn_right2",false)
    else
        self:setTouchEnableGray("layer_set_btn_left2",true)
        self:setTouchEnableGray("layer_set_btn_right2",true)
    end
    self.limitLvInSet = toint(limitInput:getText())
end

function FamilyMemagePanel:initVarOfSet()
    -- if 2 == Data.getCurFamilyType() then
    --     self:setTouchEnabbtn_setleGray("btn_set",false)
    --     return
    -- end

    self.applyTypeInSet = gFamilyInfo.apptype
    if gFamilyInfo.limitlv < gUnlockLevel[Unlock.system.family.unlockType] then
        self.limitLvInSet = gUnlockLevel[Unlock.system.family.unlockType]
    else
        self.limitLvInSet = gFamilyInfo.limitlv
    end
    self.iconInSet      = gFamilyInfo.icon
    self.oldSubType     = nil
    self.curSubType     = nil
    local function onEditCallback(name, sender)
        if name=="ended" then
            self:limitLvTxtEnded()
        end
    end
    self:getNode("lv_limit_input"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("lv_limit_input"):setMaxLength(4)
end

function FamilyMemagePanel:onUILayerExit()
    self:unscheduleUpdateEx();

    self:unscheduleUpdate()

    if self.curSubType ~= nil and self.curSubType == "btn_set" then
        gFamilyInfo.apptypeCache     = self.applyTypeInSet
        gFamilyInfo.limitlvCache     = self.limitLvInSet
        gFamilyInfo.iconCache        = self.iconInSet
        Net.sendFamilySaveSet(self.iconInSet, self.applyTypeInSet, self.limitLvInSet)
    end
end

function FamilyMemagePanel:chNameSucess()
    self.chNameTime = gFamilyInfo.chnametime
    self:setFamilyName()
end

return FamilyMemagePanel