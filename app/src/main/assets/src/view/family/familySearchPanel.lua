
local FamilySearchPanel=class("FamilySearchPanel",UILayer)

FAMILY_SEARCH_TYPE_CREATE = 1;
FAMILY_SEARCH_TYPE_OTHER = 2;

function FamilySearchPanel:ctor(type)
    self:init("ui/ui_family_search.map") 
    -- self.isBlackBgVisible=false  
    self.isMainLayerMenuShow = false;
    self:getAllFamily() 

    self.familySearchType = type;
    self.pScrollLayer = self:getNode("scroll");
    self.pScrollLayer.breakTouch = true;
    self.pScrollLayer.scrollBottomCallBack = function()
      self:onMoveDown();
    end
    self.iLastRank = table.getn(gFamilySearchList);
    self.bMoreFamily = true;
  
    self.input = self:getNode("txt_input");
    self.input:setInputMode(6)
    --1 全部军团 2--推荐军团
    self.iCurListType = 1;
    self.selectedIdx = self.iCurListType;
    self:selectBtn("btn_type1");

    -- self:createList();
    gCreateBtnBack(self);
    self:initWithType();
end

function FamilySearchPanel:initWithType()
  if(self.familySearchType == FAMILY_SEARCH_TYPE_CREATE)then
      self:initAppInfo();

      local function onNodeEvent(event)
          if event == "exit" then
            self:onExit();
          end
      end
      self:registerScriptHandler(onNodeEvent);  
  else
      self:getNode("bg_create"):setVisible(false);
      self:getNode("btn_refresh"):setVisible(false);
      self:getNode("layer_app"):setVisible(false);
      self.isBlackBgVisible=true 
  end

  self:resetLayOut();
end

function FamilySearchPanel:initOneSearchFamily(index)
    local data = {};
    
    data.id = 0;
    data.sName = "特么嫁给程序员"..index;
    data.iLevel = math.random(1,99);
    data.sMasName = "啊哈哈";
    data.iMemNum = 10;
    data.iPower = math.random(999,99999);
    data.sDec = "宣言什么的都很费劲覅呃逆vehfijeifjeifjiejfiejfiejfiejifj";
    data.bApped = true;
    data.bNoNeedApp = true;
    --{
--  id
--  sName
--  iLevel
--  sMasName
--  iMemNum
--  iPower
--  sDec
--}
    return data;
end 

function  FamilySearchPanel:events()
    print("FamilySearchPanel:events");
    return {EVENT_ID_FAMILY_SEARCH,
            EVENT_ID_FAMILY_APP_SUCCESS}
end


function FamilySearchPanel:dealEvent(event,param)

  if(event==EVENT_ID_FAMILY_SEARCH)then

    -- local list = {};
    -- for i=1,10 do
    --     local oneFamily = self:initOneSearchFamily(i);
    --     table.insert(list,oneFamily);    
    -- end
    -- param = list;
    -- print_lua_table(param);

    self:updateList(param);
  elseif(event == EVENT_ID_FAMILY_APP_SUCCESS) then
    self:refreshAppFamily(param);    
  end
end

function FamilySearchPanel:initAppInfo()
  self.pLabAppTime = self:getNode("lab_app_time");
  self.pLabAppWord = self:getNode("lab_app_word");
  self.pLabAppTime:setPositionX(self.pLabAppWord:getPositionX() - self.pLabAppWord:getContentSize().width - 5);
  self.pLayerApp = self:getNode("layer_app");


--  self.iAppTime = DataBase:shared().m_familyInfo.iCDTime + os.time();
  self.iAppLeftTime = gFamilyInfo.iCDTime - (os.time() - gFamilyInfo.iCDTimeClientTime);
  self.bHasCdTime = self.iAppLeftTime > 0;
  self.pLayerApp:setVisible(self.bHasCdTime);

  self.update_time = nil;
  if(self.bHasCdTime) then
    -- self.iAppLeftTime = gFamilyInfo.iCDTime;
    self:refresAppTime();

    local function __update()
           -- print("update");
      if(self.iAppLeftTime <= 0) then
        self.bHasCdTime = false;
        self.pLayerApp:setVisible(self.bHasCdTime);
        -- self:unscheduleUpdate();
        self:unscheduleUpdateEx();
        return;
      end
      self.iAppLeftTime = self.iAppLeftTime - 1;
      -- self.iAppLeftTime = gFamilyInfo.iCDTime;
      self:refresAppTime();

    end
    self:scheduleUpdate(__update,1);
    -- local scheduler=cc.Director:getInstance():getScheduler();
    -- self.update_time = scheduler:scheduleScriptFunc(__update,1,false);
  end

end

function FamilySearchPanel:onExit()
    print("onExit")
    -- self.super:onUILayerExit();
    self:unscheduleUpdateEx();
    -- if self.update_time then
    --     cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.update_time)
    -- end
end

function FamilySearchPanel:refresAppTime()
--  if(self.iAppLeftTime == nil) then
--    self.iAppLeftTime = DataBase:shared().m_familyInfo.iCDTime;
--  end
  local sTime = gParserHourTime(self.iAppLeftTime,0);
  self.pLabAppTime:setString(sTime); 
end





function FamilySearchPanel:refreshList()
--  self:resetPage(true);
  gFamilySearchList = {};
  self.bMoreFamily = true;
  self.iLastRank = 0;
  self.pScrollLayer:clear();
  
  self:searchMoreFamily();
  
end

function FamilySearchPanel:searchMoreFamily()
  if self.iCurListType == 1 then
    Net.sendFamilySearch(self.iLastRank);
  elseif self.iCurListType == 2 then
    Net.sendFamilySearch(nil,self.iLastRank);
  end
end

function FamilySearchPanel:onSearch()

  local sText = string.filter(self.input:getText());

  if sText=="" then
    local sWord = gGetWords("noticeWords.plist","intput_empty");
    gShowNotice(sWord);
    return;
  end

  --搜索不能翻页
  self.bMoreFamily = false;
  Net.sendFamilySearch(nil,nil,sText);

  self:setLabelString("txt_refresh",gGetWords("familySearchWord.plist","btn6"));
  self:getNode("btn_refresh"):setVisible(true);
  self:resetLayOut();

end

-- function FamilySearchPanel:onSwitchListType()
--   if self.iCurListType == 1 then
--     self.iCurListType = 2;
--   elseif self.iCurListType == 2 then
--     self.iCurListType = 1;
--   end
--   self:refreshListType();
  
--   self:refreshList();
-- end

function FamilySearchPanel:onGetAllFaimly()
  -- body
  self.iCurListType = 1;
  self:refreshList();

  self:setLabelString("txt_refresh",gGetWords("familySearchWord.plist","btn7"));
  if(self.familySearchType == FAMILY_SEARCH_TYPE_OTHER)then
    self:getNode("btn_refresh"):setVisible(false);
    self:resetLayOut();
  end
end

function FamilySearchPanel:onGetRecommandFaimly()
  -- body
  self.iCurListType = 2;
  self:refreshList();
end

function FamilySearchPanel:onNew()

  if(self.bHasCdTime) then
    local word = gGetWords("familySearchWord.plist","info_app");
    gShowNotice(word);
    return;
  end

    Panel.popUp(PANEL_FAMILY_CREATE);
end

function FamilySearchPanel:updateList(list)
  if self.bMoreFamily then
    --翻页
    -- if table.getn(list) == 0 then
    --   for i=1,5 do
    --     local oneFamily = self:initOneSearchFamily(i);
    --     table.insert(list,oneFamily);    
    --   end
    --   -- list = table.shallowCopy(gFamilySearchList);
    -- end
    if table.getn(list) > 0 then
      self:createMoreFamily(list);
    end
  else
    --搜索名字
    gFamilySearchList = list;
    self:createList();
  end
end

function FamilySearchPanel:createList()

  self.pScrollLayer:clear();
  self:createFamilyList(gFamilySearchList);

end

function FamilySearchPanel:createMoreFamily(list)
  
  for key,value in ipairs(list) do
    table.insert(gFamilySearchList,value);
  end
  
  self.iLastRank = table.getn(gFamilySearchList);
  -- print("last rank = "..self.iLastRank);
  
  self:createFamilyList(list);
  
end

function FamilySearchPanel:createFamilyList(list)

  local count = table.getn(self.pScrollLayer:getAllItem());
  for key,value in ipairs(list) do
    local item = self:createOneFamily(value,key);
    self.pScrollLayer:addItem(item);
  end
  self.pScrollLayer:layout(count==0);
  -- self.pScrollLayer:moveItemByIndex(count-1,0.5);
  
end

function FamilySearchPanel:createOneFamily(data,index)
    local item=FamilySearchItem.new(self.familySearchType);
    item:setData(data, index);
    item.selectItemCallback=function (data,idx)
        self:onApp(data,idx);
    end

    if(self.familySearchType == FAMILY_SEARCH_TYPE_OTHER)then
      item:setBtnCheck();
    end
    return item;
end

function FamilySearchPanel:onApp(data)

  if(self.familySearchType == FAMILY_SEARCH_TYPE_OTHER)then
    Panel.popUpVisible(PANEL_FAMILY_OTHERFAMILYINFO,data);
  else
    if(self.bHasCdTime) then
      local word = gGetWords("familySearchWord.plist","info_app");
      gShowNotice(word);
      return;
    end
    
    if(data.bApped and data.bNoNeedApp == false) then
      --撤销
      Net.sendFamilyCancelApply(data.id);
      return;
    end
    
    Net.sendFamilyApply(data.id);
  end
end

function FamilySearchPanel:onMoveDown()

  if self.bMoreFamily then
    print("move down last rank = "..self.iLastRank);
    self:searchMoreFamily();
  end
  
end

function FamilySearchPanel:refreshAppFamily(data)
  -- print("index = "..data.index);
  print_lua_table(data);
  print("refreshAppFamily");

  local item = self.pScrollLayer:getItem(data.index);
  if(item ~= nil) then
    
    local pLabApp = item:getNode("txt_btn_word");

    local bApped = data.bApped;
    -- print("bApped = "..bApped);
    if bApped then
        local word = gGetWords("familySearchWord.plist","btn3");
        pLabApp:setString(word);
    else
        local word = gGetWords("familySearchWord.plist","btn1");
        pLabApp:setString(word);
    end
    
  end
end


function FamilySearchPanel:resetBtnTexture()
    local btns={
        "btn_type1",
        "btn_type2",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian2.png")
    end
end

function FamilySearchPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian2-1.png")
end

function FamilySearchPanel:getPushFamily() 
    self.lastRank=0
    Net.sendFamilySearch(self.lastRank)

end



function FamilySearchPanel:getAllFamily()
    gFamilySearchList = {};
    self.lastRank=0
    Net.sendFamilySearch(self.lastRank)
end

function FamilySearchPanel:onClose()
    -- body
    Panel.popBack(self:getTag())
end

function FamilySearchPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
      if(self.familySearchType == FAMILY_SEARCH_TYPE_CREATE) then
        Panel.popBackAll()
      else
        Panel.popBack(self:getTag());
      end
    elseif  target.touchName=="btn_type1"then
        self:selectBtn(target.touchName);
        self:onGetAllFaimly();
    elseif  target.touchName=="btn_type2"then
        self:selectBtn(target.touchName);
        self:onGetRecommandFaimly();
    elseif target.touchName == "btn_create"then
        self:onNew();    
    elseif target.touchName == "btn_search"then
        self:onSearch();
    elseif target.touchName == "btn_refresh"then
        self:onGetAllFaimly();
    end
end
 

return FamilySearchPanel