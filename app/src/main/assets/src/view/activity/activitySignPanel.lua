local ActivitSignPanel=class("ActivitSignPanel",UILayer)

function Data.getSignTodayThisMonth()
  return (Data.signInfo.today-1)%30+1;
end

function ActivitSignPanel:ctor()
    self:init("ui/ui_hd_sign.map")
    loadFlaXml("ui_kuang_texiao");

    Net.sendSignInitNew();
    -- Data.signInfo.today = 2;
    -- Data.signInfo.list = {};
    -- Data.signInfo.count = 0;
    -- table.insert(Data.signInfo.list,0);
    -- table.insert(Data.signInfo.list,0);
    -- for i=3,30 do
    --     table.insert(Data.signInfo.list,2);
    -- end

    -- self:initPanel();

    -- self.curDay = 1;
    -- Data.signInfo.count = 1;

    -- self.sign = DB.getSignData(self.curDay);

      -- function sortday(data1,data2) 
      --   if data1.id < data2.id then
      --       return true;
      --   end
      --   return false;
      -- end
      -- table.sort(self.sign,sortday);
      -- self:createList();

      -- --累计签到奖励
      -- local reward = DB.getSignRewardData(self.curDay);
      -- for key,var in pairs(Data.signInfo.reward) do
      --   var.itemid = toint(reward["itemid"..key]);
      --   var.itemnum = toint(reward["itemnum"..key]);
      -- end
      -- self:initReward();
end

function ActivitSignPanel:initPanel()
    self.sign = DB.getSignData(Data.signInfo.today);
    function sortday(data1,data2) 
        if data1.id < data2.id then
            return true;
        end
        return false;
    end
    table.sort(self.sign,sortday);
    self:createList();


    --累计签到奖励
    local reward = DB.getSignRewardData(Data.signInfo.today);
    for key,var in pairs(Data.signInfo.reward) do
        var.itemid = toint(reward["itemid"..key]);
        var.itemnum = toint(reward["itemnum"..key]);
    end
    self:initReward();    
end


function ActivitSignPanel:onPopup()

end

function ActivitSignPanel:onPopback()
    print("ActivitSignPanel:onPopback");
    Scene.clearLazyFunc("ActivitysignItem")
    Panel.clearTouchTip();
end

function ActivitSignPanel:initReward()
  for key,var in pairs(Data.signInfo.reward) do
    local item = Icon.setDropItem(self:getNode("reward"..key),var.itemid,var.itemnum);
    self:setLabelString("des"..key,DB.getItemName(var.itemid));
    self:setLabelString("count"..key,Data.signInfo.count.."/"..var.day);

    -- if self:canGetReward(key) then
      item.idx = key;
      item.selectItemCallback = function (itemid,index)
        if self:canGetReward(index) then
          -- Net.sendSignGetReward(index);
          Net.sendSignGetRewardNew(index)
        end
      end
    -- end
  end
end


function ActivitSignPanel:refreshInfo()
  -- self:refreshTip();   
  -- print("11111111");
  -- print_lua_table(Data.signInfo.reward);
  -- print("222222222");
  for key,var in pairs(Data.signInfo.reward) do
    self:setLabelString("count"..key,Data.signInfo.count.."/"..var.day);
    self:getNode("reward"..key):removeChildByTag(100);
    if self:canGetReward(key) then
      local fla=gCreateFla("ui_kuang_xiaoguo",1);
      fla:setTag(100);
      fla:setLocalZOrder(10);
      gAddChildInCenterPos(self:getNode("reward"..key),fla);
    -- else
      -- self:getNode("reward"..key):removeChildByTag(100);
    end

    self:getNode("flag_signIn"..key):setVisible(var.bolGet);
  end 
end

function ActivitSignPanel:createList()

    Scene.clearLazyFunc("signinItem")

    self:getNode("scroll"):clear()
    self:getNode("scroll").eachLineNum=6;
    for key, var in pairs(self.sign) do
        local item=ActivitySignItem.new()
        if key >= Data.signInfo.count-1 and key <= Data.signInfo.count-1+6 then
          item:setData(var,toint(key))
        else
          item:setLazyData(var,toint(key));
        end
        self:getNode("scroll"):addItem(item)
    end

    self:getNode("scroll"):layout()
    self:refreshInfo();
    -- if Data.signInfo.bolSign then
    --   self:getNode("scroll"):moveItemByIndex(Data.signInfo.count-1);
    -- else
    --   self:getNode("scroll"):moveItemByIndex(Data.signInfo.count);
    -- end

    local today = Data.getSignTodayThisMonth();
    -- if(today > 30)then
      -- today = today - 30;
    -- end
    self:getNode("scroll"):moveItemByIndex(today-1);
    self:getNode("scroll"):setCheckChildrenVisibleEnable(false);
end

function ActivitSignPanel:refreshList()
    -- body
    local items = self:getNode("scroll"):getAllItem();
    for key,var in pairs(items) do
        var:refresh();
    end

    self:refreshInfo();
end

function ActivitSignPanel:canGetReward(index)
  local var = Data.signInfo.reward[index];
  if Data.signInfo.count >= var.day and not var.bolGet then
    return true;
  end
  return false;
end

function ActivitSignPanel:dealEvent(event,param)
    if(event == EVENT_ID_GET_ACTIVITY_SIGNINFO)then
        self:initPanel();
        if(self.allPanel)then
           self.allPanel:showTime({type = ACT_TYPE_127});
        end
    elseif(event == EVENT_ID_GET_ACTIVITY_SIGNREFRESH)then
        self:refreshList();
    end
    -- if(event==EVENT_ID_SIGN_IN or event == EVENT_ID_SIGN_REFRESH)then
    --   self:refreshList();
    -- end
end

function ActivitSignPanel:onTouchBegan(target,touch)
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

function ActivitSignPanel:onTouchEnded(target)
    Panel.clearTouchTip();
end

return ActivitSignPanel