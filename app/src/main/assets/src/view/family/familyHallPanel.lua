local FamilyHallPanel=class("FamilyHallPanel",UILayer)

function FamilyHallPanel:ctor(familyHome)
    self:init("ui/ui_family_hall.map")
    -- self.isBlackBgVisible=false  
    self.isMainLayerMenuShow = false;
    self.familyHome = familyHome;
    gCreateBtnBack(self);
    self.scroll_mem = self:getNode("scroll_mem");
    -- self.scroll_mem.eachLineNum = 3;
    self:createMemList();

    self:setLabelString("txt_name",gFamilyInfo.sName);
    self:setLabelString("txt_lv",getLvReviewName("Lv.")..gFamilyInfo.iLevel);
    Icon.setFamilyIcon(self:getNode("icon"),gFamilyInfo.icon,gFamilyInfo.familyId);
    -- self:changeTexture("icon","images/ui_family/bp_icon_"..gFamilyInfo.icon..".png");
    self:refreshMemCount();
    self:setLabelString("txt_fexp",gFamilyInfo.dayFExp);
    self:setLabelString("txt_active_num",gFamilyInfo.activenum.."/"..Data.getCurFamilyMemCount());
    self:resetLayOut();

    self:getNode("btn_notice"):setVisible(Data.isFamilyManager());
end

function FamilyHallPanel:refreshMemCount()
  self:setLabelString("txt_mem",Data.getCurFamilyMemCount().."/"..Data.getFamilyMaxMem());
end

function FamilyHallPanel:onPopup()
  self:setLabelString("txt_notice",gFamilyInfo.sNotice);
end

function  FamilyHallPanel:events()
    return {EVENT_ID_FAMILY_APPOINT_MEM,EVENT_ID_FAMILY_EXPEL}
end


function FamilyHallPanel:dealEvent(event,param)
    if event == EVENT_ID_FAMILY_APPOINT_MEM then
      self:appontFamilyMem();
    elseif event == EVENT_ID_FAMILY_EXPEL then
      self:expelFamilyMem();
    end
end

function FamilyHallPanel:appontFamilyMem()

  for key,value in ipairs(gFamilyMemList) do  
    if value.uid == self.familyHome.send_uid then
      value.iType = self.familyHome.send_type;
      break;
    end
  end
  
  if self.familyHome.send_type == 1 and Data.getCurFamilyType() == 1 then
    --自己变为普通成员
    gFamilyInfo.iType = 9;

    for key,var in pairs(gFamilyMemList) do
        if var.uid == Data.getCurUserId() then
          var.iType = 9;
          break;
        end
    end

  end
  
  self:createMemList();

end

function FamilyHallPanel:removeFamilyMem(index)
--  local index = data.index;
  if(index >= 0) then
    self.scroll_mem:removeItemByIndex(index);
    self:refreshMemCount();
  end  
end

function FamilyHallPanel:expelFamilyMem()
  local index = Data.removeFamilyMemWithUid(self.familyHome.send_uid);
  self:removeFamilyMem(index);
end


function FamilyHallPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    elseif target.touchName == "btn_notice" then
        Panel.popUpVisible(PANEL_FAMILY_MAMAGE,2);
    elseif target.touchName == "btn_view" then
        Panel.popUpVisible(PANEL_FAMILY_EXPRANK);
    end

end


function FamilyHallPanel:createMemList()

  --排序
  
  -- for key,mem in pairs(gFamilyMemList) do
  --   mem.iDayExp = math.random(1,100);
  -- end
  
  for key,mem in pairs(gFamilyMemList) do
    mem.day = 0;
    if(mem.iLogin ~= 0)then

      local min = mem.iLogin / 60 ;
      local hour = min / 60;
      local day = hour / 24;
      -- mem.day = day;
      mem.day = math.floor(day);
      mem.sortid = 0*100000000 + (10000000 - mem.iLogin);
    else
      mem.sortid = 1*100000000 + (10-mem.iType)*10000000 + mem.iDayExp*1000 + mem.iLevel;
    end

    -- print("mem.day = "..mem.day);
  end

  -- print("1111111111");
  -- print_lua_table(gFamilyMemList);
  
  local function sortWithType(mem1,mem2)

    return mem1.sortid > mem2.sortid;
    -- if(mem1 == nil or mem2 == nil)then
    --   return false;
    -- end

    -- if mem1.iLogin ~=0 and mem2.iLogin ~= 0 then
    --   --离线
    --   -- print("@@@@@ mem1 day = "..mem1.day);
    --   -- print("@@@@@ mem2 day = "..mem2.day);
    --   if mem1.day < 1 and mem2.day < 1 then
    --     -- print("11111 mem1 day = "..mem1.day);
    --     -- print("11111 mem2 day = "..mem2.day);
    --     if(mem1.iLogin < mem2.iLogin)then
    --       return true;
    --     end
    --   elseif mem1.day < mem2.day then
    --     -- print("22222 mem1 day = "..mem1.day);
    --     -- print("22222 mem2 day = "..mem2.day);
    --     return true;
    --   elseif mem1.day == mem2.day then
    --     -- print("mem1 day = "..mem1.day);
    --     -- print("mem2 day = "..mem2.day);
    --     -- print("mem1 iDayExp = "..mem1.iDayExp);
    --     -- print("mem2 iDayExp = "..mem2.iDayExp);
    --     if(mem1.iDayExp > mem2.iDayExp) then
    --       -- print("change");
    --       return true;
    --     end 
    --   end
    -- elseif(mem1.iLogin == 0 and mem2.iLogin == 0) then
    --   --在线
    --   if mem1.iDayExp > mem2.iDayExp then
    --     return true;
    --   elseif mem1.iType < mem2.iType then
    --     return true;
    --   end
    -- else
    --   if mem1.iLogin < mem2.iLogin then
    --     return true;
    --   end
    -- end

    -- return false;
  end

  -- local function sortWithType(mem1,mem2)
  --   local lv1 = mem1.iLogin;
  --   local lv2 = mem2.iLogin;

  --   if mem1.iLogin ~=0 and mem2.iLogin ~= 0 then
  --     if mem1.iType == 9 and mem2.iType == 9 then
  --       if mem1.iLogin < mem2.iLogin then
  --         return true;
  --       end
  --     elseif mem1.iType < mem2.iType then
  --       return true;
  --     end
  --   else
  --     if mem1.iLogin < mem2.iLogin then
  --       return true;
  --     end
  --   end

  --   return false;
  -- end
  table.sort(gFamilyMemList,sortWithType);
  
  local cur_data = {};
  for key,value in ipairs(gFamilyMemList) do
    if value.uid == Data.getCurUserId() then
--      echo("key = "..key);
      cur_data = value;
      table.remove(gFamilyMemList,key);
      table.insert(gFamilyMemList,1,cur_data);
      break;
    end
  end

  self.scroll_mem:clear();
  for key,value in ipairs(gFamilyMemList) do
    local item = self:createOneMem(value);
    self.scroll_mem:addItem(item);

  end
  self.scroll_mem:layout(true);

end


function FamilyHallPanel:createOneMem(data)
    local item=FamilyMemItem.new();
    item:setData(data);
    item.onCheck=function (data)
        self.familyHome:onCheck(data);
    end
    return item;
end

return FamilyHallPanel