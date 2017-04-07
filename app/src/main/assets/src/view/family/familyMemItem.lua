local FamilyMemItem=class("FamilyMemItem",UILayer)

function FamilyMemItem:ctor()
   
end

function FamilyMemItem:initPanel() 
    self:init("ui/ui_family_mem_item.map");
    self:getNode("bg_vip"):setVisible(false)
end

function FamilyMemItem:onTouchEnded(target)

	print("target name = "..target.touchName);

  if(target.touchName == "icon_bg")then
    self.onCheck(self.curData);
  elseif (target.touchName == "btn_mobai") then
    if (self.curData.uid == Data.getCurUserId()) then
      if(Data.getCurFamilyType() == 1)then
        Panel.popUpVisible(PANEL_FAMILY_MAMAGE);
      else
        self:onQuitFamily();
      end
    else
      gFamilyInfo.mobai_uid = self.curData.uid;
      gFamilyInfo.mobai_uname = self.curData.sName
      Panel.popUpVisible(PANEL_FAMILY_MOBAI,nil,nil,true)
    end
  end
  
   -- if(self.selectItemCallback)then
   --      self.selectItemCallback(self.curData,self.idx)
   -- end
end

function FamilyMemItem:onQuitFamily()
  gConfirmCancel(gGetWords("familyMenuWord.plist","exit_family"),self.handleFamilyExit);
end

function FamilyMemItem:handleFamilyExit()
  Net.sendFamilyExit();
end

function FamilyMemItem:setData(data) 
    self:initPanel();
    self.curData=data;

  if data.uid == Data.getCurUserId() then
    local pMeFlag = cc.Sprite:create("images/ui_family/ME.png");
    pMeFlag:setAnchorPoint(cc.p(1.0,0));
    pMeFlag:setPosition(40,-35);
    self:addChild(pMeFlag,10);
  end

    self:setLabelString("lab_name",data.sName);
    local iType = data.iType;
    if data.bTemp == true then
      iType = 10;
    end
    
    self:setLabelString("lab_mem",gGetWords("familyMenuWord.plist","title"..iType));
    if(iType == 1 or iType == 2 or iType == 3)then
      -- self:getNode("lab_mem"):setColor(cc.c3b());
    elseif(iType == 10)then
      self:getNode("lab_mem"):setColor(cc.c3b(73,85,198));
    else  
      self:getNode("lab_mem"):setColor(cc.c3b(161,70,63));
    end
    self:setLabelString("lab_vip","vip:"..data.iVip);
    self:setLabelString("lab_lv",getLvReviewName("Lv.")..data.iLevel);
    self:setLabelAtlas("txt_vip",data.iVip);
    -- self:setLabelString("txt_gongx_rank",data.iRank);
    -- self:setLabelString("txt_day_exp",data.iDayExp);
    -- self:setLabelString("txt_all_exp",data.iExp);
    self:refreshExp();

    -- if data.iLogin == 0 then
    --   self:setLabelString("lab_time",gGetWords("familyMenuWord.plist","menu_mem5"));
    --   self:getNode("lab_time"):setColor(cc.c3b(174,251,52));
    -- else
    --   local word = getTimeDiff(data.iLogin);
    --   word = word .. gGetWords("familyMenuWord.plist","login");
    --   self:setLabelString("lab_time",word);
    --   self:getNode("lab_time"):setColor(cc.c3b(160,140,128));
    -- end
    gShowLoginTime(self,"lab_time",data.iLogin);

    Icon.setHeadIcon(self:getNode("icon_bg"),data.iCoat)

    if(data.uid == Data.getCurUserId()) then
      -- Data.isFamilyManager()
      self:changeTexture("btn_mobai","images/ui_public1/button_s4.png");
      if(iType == 1)then
        self:setLabelString("txt_btn",gGetWords("familyMenuWord.plist","91"))
        self:getNode("txt_btn"):setColor(cc.c3b(244,222,128));
      else
        self:setLabelString("txt_btn",gGetWords("familyMenuWord.plist","92"))
        self:getNode("txt_btn"):setColor(cc.c3b(170,96,56));
      end
      self:setTouchEnable("icon_bg",false,false);
      -- self:setTouchEnableGray("btn_mobai",false);
    end
    -- if(data.uid == Data.getCurUserId() and data.iType == 1) then
    --   self:setTouchEnable("icon_bg",false,true);
    -- elseif(data.uid == Data.getCurUserId()) then
    --   self:setLabelString("txt_btn",gGetWords("familyMenuWord.plist","btn1"));
    -- else
    -- end
    -- Icon.setIcon(data.iCoat,self:getNode("icon_bg"))
    self:resetLayOut();
end

function FamilyMemItem:refreshExp()
  self:setLabelString("txt_day_exp",self.curData.iDayExp);
end


return FamilyMemItem