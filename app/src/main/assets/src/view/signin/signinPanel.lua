local SigninPanel=class("SigninPanel",UILayer)

SigninPanelData = {};

function SigninPanel:ctor()

    -- self.appearType = 1;
    self:init("ui/ui_signin.map")

    loadFlaXml("ui_kuang_texiao");

  -- self:getNode("scroll").eachLineNum=6
  -- self:getNode("scroll").offsetY=0
  -- self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
  local realtime = gServerTime - gResetDataInDay*60*60;
  local time = gGetDate("*t",realtime);
  local year = time.year;
  local month = time.month;
  self.day = time.day;
  self.sign = DB.getSign(year,month);
  self:setLabelString("txt_title",gGetWords("signWord.plist","title",month));
  -- print_lua_table(self.sign);

  function sortday(data1,data2) 
    if data1.day < data2.day then
        return true;
    end
    return false;
  end
  table.sort(self.sign,sortday);

  self.signVip = DB.getSignVip(year,month);
  table.sort(self.signVip,sortday);

  local reward = DB.getSignReward(year,month);
  for key,var in pairs(Data.signInfo.reward) do
    var.itemid = toint(reward["itemid"..key]);
    var.itemnum = toint(reward["itemnum"..key]);
  end

  self.resetData = false;
  self:initReward();
  self:refreshInfo();
  self.signType = 0;
  self:setSignType(1);

  gCreateBtnBack(self);

end


function SigninPanel:onPopback()
    Scene.clearLazyFunc("signinItem")
    Scene.clearLazyFunc("signinVipItem")
end

function SigninPanel:onPopup()
  -- body
  if self.resetData then
    Net.sendSignInit();
  end
end
function SigninPanel:onPushStack()
  self.resetData = true;
end

function SigninPanel:initReward()
  for key,var in pairs(Data.signInfo.reward) do
    local item = Icon.setDropItem(self:getNode("reward"..key),var.itemid,var.itemnum);
    self:setLabelString("des"..key,DB.getItemName(var.itemid));
    self:setLabelString("count"..key,Data.signInfo.count.."/"..var.day);

    -- if self:canGetReward(key) then
      item.idx = key - 1;
      item.selectItemCallback = function (itemid,index)
        if self:canGetReward(index+1) then
          Net.sendSignGetReward(index);
        end
      end
    -- end
  end
end

function SigninPanel:refreshInfo()
    -- self:setLabelString("txt_cur_count",gGetWords("signWord.plist","sign_count",Data.signInfo.count));
    -- self:setLabelString("txt_total_count",gGetWords("signWord.plist","sign_today",Data.signInfo.totalCount));
  self:refreshTip();   

  for key,var in pairs(Data.signInfo.reward) do
    self:setLabelString("count"..key,Data.signInfo.count.."/"..var.day);
    if self:canGetReward(key) then
      local fla=gCreateFla("ui_kuang_xiaoguo",1);
      fla:setTag(100);
      gAddChildInCenterPos(self:getNode("reward"..key),fla);
    else
      self:getNode("reward"..key):removeChildByTag(100);
    end

    self:getNode("flag_signIn"..key):setVisible(var.bolGet);
  end 
end

function SigninPanel:canGetReward(index)
  local var = Data.signInfo.reward[index];
  if Data.signInfo.count >= var.day and not var.bolGet then
    return true;
  end
  return false;
end

function SigninPanel:refreshTip()

    -- if Data.signInfo.bolSign then
    --     self:setLabelString("txt_tip",gGetWords("signWord.plist","sign_tomorrow",Data.signInfo.dia));
    -- else
    --     self:setLabelString("txt_tip",gGetWords("signWord.plist","sign_today",Data.signInfo.dia));
    -- end
    if self.signType == 1 then
      if Data.signInfo.bolSign then
          self:setLabelString("txt_tip",gGetWords("signWord.plist","signed"));
      else
          self:setLabelString("txt_tip",gGetWords("signWord.plist","unsign"));
      end
    elseif self.signType == 2 then
        self:setLabelString("txt_tip",gGetWords("signWord.plist","vipTip"));
    end

end

function SigninPanel:createList()

    Scene.clearLazyFunc("signinItem")
    Scene.clearLazyFunc("signinVipItem")

    self:getNode("scroll"):clear()
    self:getNode("scroll").eachLineNum=5;
    for key, var in pairs(self.sign) do
        local item=SigninItem.new()
        if key >= Data.signInfo.count-1 and key <= Data.signInfo.count-1+6 then
          item:setData(var,toint(key)-1)
        else
          item:setLazyData(var,toint(key)-1);
        end
        -- item.selectItemCallback=function (data,idx)
        --     self:onSelectItem(data,idx)
        -- end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    if Data.signInfo.bolSign then
      self:getNode("scroll"):moveItemByIndex(Data.signInfo.count-1);
    else
      self:getNode("scroll"):moveItemByIndex(Data.signInfo.count);
    end
end

function SigninPanel:refreshList()
    -- body
    local items = self:getNode("scroll"):getAllItem();
    for key,var in pairs(items) do
        var:refresh();
    end

    self:refreshInfo();
end

function SigninPanel:createVipList()

    Scene.clearLazyFunc("signinItem")
    Scene.clearLazyFunc("signinVipItem")
    
    self:getNode("scroll"):clear();
    self:getNode("scroll").eachLineNum=1;

    for key,var in pairs(self.signVip) do
        local item=SigninVipItem.new()
        if key >= self.day-1 and key <= self.day-1+4 then
          item:setData(var,toint(key),self.day);
        else
          item:setLazyData(var,toint(key),self.day);
        end
        self:getNode("scroll"):addItem(item);
    end
    self:getNode("scroll"):layout();
    self:getNode("scroll"):moveItemByIndex(self.day-1);

end

function  SigninPanel:events()
    return {EVENT_ID_SIGN_IN,
            EVENT_ID_SIGN_REFRESH}
end


function SigninPanel:dealEvent(event,param)
    if(event==EVENT_ID_SIGN_IN or event == EVENT_ID_SIGN_REFRESH)then
      self:refreshList();
    end
end


function SigninPanel:resetBtnTexture()
    local btns={
        "btn1",
        "btn2",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function SigninPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function SigninPanel:setSignType(type)
  if(self.signType == type) then
    return;
  end

  self.signType = type;
  if type == 1 then
      self:selectBtn("btn1");    
      self:createList();
  elseif type == 2 then
      self:selectBtn("btn2");
      self:createVipList(); 
  end
  self:refreshTip();
end

function SigninPanel:onTouchBegan(target,touch)
  if target.touchName == "reward1" or target.touchName == "reward2" or target.touchName == "reward3" then
        local itemid = 0;
        if target.touchName == "reward1" then
            itemid = Data.signInfo.reward[1].itemid;
        elseif target.touchName == "reward2" then
            itemid = Data.signInfo.reward[2].itemid;
        elseif target.touchName == "reward3" then
            itemid = Data.signInfo.reward[3].itemid;
        end
        local tip= Panel.popTouchTip(self:getNode(target.touchName),TIP_TOUCH_EQUIP_ITEM,itemid)
        -- tip:setPositionY(tip:getPositionY()+tip:getContentSize().height)    
    end
end

function SigninPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn1" then
        self:setSignType(1);
    elseif target.touchName == "btn2" then
        self:setSignType(2);
    -- elseif target.touchName == "reward1" then
    --     if self:canGetReward(1) then
    --       Net.sendSignGetReward(0);   
    --     end
    -- elseif target.touchName == "reward2" then
    --     if self:canGetReward(2) then
    --       Net.sendSignGetReward(1);   
    --     end
    -- elseif target.touchName == "reward3" then
    --     if self:canGetReward(3) then
    --       Net.sendSignGetReward(2);   
    --     end
    end
    Panel.clearTouchTip();
end

return SigninPanel