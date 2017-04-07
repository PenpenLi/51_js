
local FamilySevenPanel=class("FamilySevenPanel",UILayer)

function FamilySevenPanel:ctor(type)
    self:init("ui/ui_family_fengmo.map")
    print("FamilySevenPanel init")
    loadFlaXml("ui_family_fengmo")

     self.btn_pos = {};
     self.flag = {};
     self.lab_name = {};
     self.lab_help_bg = {};
     
     for i=1,5 do
      self.btn_pos[i] = self:getNode("btn_pos"..i);
      self.flag[i] = self:getNode("flag"..i);
      self.flag[i]:setVisible(false);
      self.lab_name[i] = self:getNode("lab_name"..i);
      self.lab_name[i]:getParent():setVisible(false);
      self.lab_help_bg[i] = self:getNode("lab_help_bg"..i);
      self.lab_help_bg[i]:setVisible(false);
     end

     self.fire_bg = self:getNode("fire_bg");

    self:setLabelString("txt_fexp",Data.family.sevenFExp);
    self:refreshUi();
end

function  FamilySevenPanel:events()
    return {EVENT_ID_FAMILY_SEVEN_JOIN}
end

function FamilySevenPanel:dealEvent(event,param)
	if(event == EVENT_ID_FAMILY_SEVEN_JOIN) then
        self:eventJoin();
	end
end


function FamilySevenPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "btn_join" then
        self:onJoin();
    elseif target.touchName == "btn_help" then
        self:onHelp();
    end
end

function FamilySevenPanel:onHelp()
    gShowRulePanel(SYS_FAMILY_SEVEN); 
end

function FamilySevenPanel:onJoin()
    local count = table.getn(gFamilySevenData.list);
  --所有人都是协助，不能加入
  if(gFamilySevenData.isHelp == true and count == 4) then

    local isAllHelp = true;
    for i = 1,count do
      if(gFamilySevenData.list[i].isHelp == false)then
        isAllHelp = false;
        break;
      end
    end
    if(isAllHelp)then
      local sWord = gGetWords("familyWords.plist","seven_all_help");
      gShowNotice(sWord)
      return;
    end
  end

  local isCanJoin = true;
  if (gFamilySevenData.isHelp == false) then
    for i = 1,count do
      if(gFamilySevenData.list[i].userId == Data.getCurUserId())then
        isCanJoin = false;
      end
    end
    if (isCanJoin==false and gFamilySevenData.isInvite==false) then
        --邀请
        print("--邀请")
        Net.sendFamilySevenInvite()
        gFamilySevenData.isInvite = true;
        self:setTouchEnableGray("btn_join",false);
        return;
    end
  end
  Net.sendFamilySevenJoin();
end

function FamilySevenPanel:eventInfo()
  local count = table.getn(gFamilySevenData.list);
  local isCanJoin = true;
  -- print("--ten="..table.getn(self.flag))
  for i = 1,5 do
    -- print("--i"..i)
    self.btn_pos[i]:removeAllChildren();
    self.lab_name[i]:getParent():setVisible(false);
    self.lab_help_bg[i]:setVisible(false);
    self.flag[i]:removeAllChildren();
    self.flag[i]:setVisible(false);
    self.flag[i]:stopAllActions();
    -- print("======")
    if(i <= count)then
      gCreateRoleFla(Data.convertToIcon(gFamilySevenData.list[i].icon),self.btn_pos[i],0.7,nil,nil,gFamilySevenData.list[i].show.wlv,gFamilySevenData.list[i].show.wkn,gFamilySevenData.list[i].show.halo);
      -- refreshRoleCoat(self.btn_pos[i], gFamilySevenData.list[i].icon,math.mod(i,2) == 0,0.8,true);
      self.lab_name[i]:getParent():setVisible(true);
      self:setLabelString("lab_name"..i,gFamilySevenData.list[i].userName);
      -- self.lab_name[i]:setString(gFamilySevenData.list[i].userName); 
      if(gFamilySevenData.list[i].isHelp)then
        self.lab_help_bg[i]:setVisible(true);
      end
      self.flag[i]:setVisible(true);

        local upStarBg = gCreateFla("ui_family_fengmo_"..i,1);
        -- self:replaceNode("flag"..i,upStarBg)
        gAddChildInCenterPos(self.flag[i],upStarBg)
      
      if(gFamilySevenData.list[i].userId == Data.getCurUserId())then
        isCanJoin = false;
      end
    end
  end
-- if (isCanJoin==false) then print("isCanJoin=false") end
  -- lab_btn_join
  if (gFamilySevenData.isHelp == true) then--协助者
    print("协助者")
     self:setTouchEnableGray("btn_join",isCanJoin);
  else
     if (isCanJoin == false) then
        if (table.getn(gFamilySevenData.list)>=5) then
            self:setTouchEnableGray("btn_join",isCanJoin);
            return;
        end
        local sWord = gGetWords("btnWords.plist","btn_invite");
         self:setLabelString("lab_btn_join",sWord);
         --如果邀请完
         if (gFamilySevenData.isInvite) then
            print("邀请过")
         else
            print("未邀请过")
         end
         self:setTouchEnableGray("btn_join",not gFamilySevenData.isInvite);
     end
  end
end

function FamilySevenPanel:refreshUi()
    self:eventInfo();
    --人数
    self:setJoinNum();
    self:resetLayOut();
end

function FamilySevenPanel:eventJoin()
    self:refreshUi();
    local count = table.getn(gFamilySevenData.list);
    --完成炼魔
    if(count >= 5) then
        --火特效
        local upStarBg = gCreateFla("ui_family_bg_huo",1);
        self:replaceNode("fire_bg",upStarBg)
    end
end

function FamilySevenPanel:setJoinNum()
    local maxNum = 5
    local joinNum = table.getn(gFamilySevenData.list);
    self:setLabelString("lab_num",joinNum.."/"..maxNum);
end

return FamilySevenPanel