
local FamilyOrePanel=class("FamilyOrePanel",UILayer)
FamilyOrePanelData = {};
local maxCrystal = 0

function FamilyOrePanel:ctor()
    self:init("ui/ui_family_ore.map")
    self.isMainLayerMenuShow = false;
    local level = Data.getCurFamilyLv();
    maxCrystal = DB.getFamilyGoldMineMaxCry(level);
    gCreateBtnBack(self);
    Icon.setFamilyIcon(self:getNode("icon"),gFamilyInfo.icon,gFamilyInfo.familyId);
    self:replaceLabelString("txt_family_lv",Data.getCurFamilyLv());
    self:refreshInfo();
    self:createOreList();
end

function FamilyOrePanel:refreshInfo()
    local data = DB.getFamilyGoldMineByLv(Data.getCurFamilyLv());
    if(data == nil)then
        return;
    end
    self:setLabelString("txt_gold",data.price);
    self:setLabelString("txt_cry",string.format("%d/%d",gFamilyGoldMineInfo.crystal,maxCrystal));
    local left_times = data.num1 - gFamilyGoldMineInfo.shovel1;
    if left_times < 0 then
      left_times = 0;
    end
    self:replaceLabelString("txt_shovel",left_times,data.num1);
    self:resetAdaptNode();
end


function FamilyOrePanel:getCry()
     
  --水晶收集满提示 
  if gFamilyGoldMineInfo.old_crystal > gFamilyGoldMineInfo.crystal then
    local word = gGetWords("familyGoldMine.plist","30",maxCrystal);
    gShowNotice(word);
  end
  
  self:setLabelString("txt_cry",string.format("%d/%d",gFamilyGoldMineInfo.crystal,maxCrystal));
end

function FamilyOrePanel:createOreList()
  local level = Data.getCurFamilyLv()
  local  buildData = DB.getFamilyGoldMineByLv(level);
  if buildData then
    self.num_kuang = buildData.max;
  end

  self:getNode("scroll").paddingX = 20;
  self:getNode("scroll").eachLineNum = 2;
  local showKuangNum = self.num_kuang;
  showKuangNum = math.max(3,showKuangNum);
  for i = 0,showKuangNum do
    if(i%2~=0)then
        local space = cc.Node:create();
        space:setContentSize(cc.size(100,40));
        self:getNode("scroll"):addItem(space);
    end

    local item = FamilyOreItem.new(i+1,self:getKuangData(i),i<self.num_kuang);
    self:getNode("scroll"):addItem(item);

    if(i%2==0)then
        local space = cc.Node:create();
        space:setContentSize(cc.size(100,40));
        self:getNode("scroll"):addItem(space);
    end

  end
  self:getNode("scroll"):layout();

end

function FamilyOrePanel:getFamilyOreItem(index)
    local items = self:getNode("scroll"):getAllItem();
    for key,item in pairs(items) do
        if(item.setData and item.index == index)then
            return item;
        end
    end
    return nil;
end

function FamilyOrePanel:refreshAllKuang()
    local items = self:getNode("scroll"):getAllItem();
    for key,item in pairs(items) do
        if(item.setData)then
            item:setData(self:getKuangData(item.index-1));
        end
    end
end

function FamilyOrePanel:refreshOtherKuang(curKuangNum)
    local items = self:getNode("scroll"):getAllItem();
    for key,item in pairs(items) do
        if(item.setData and item.index ~= curKuangNum)then
            item:setData(self:getKuangData(item.index-1));
        end
    end    
end

function FamilyOrePanel:checkAllKuangGet()
  local bGetAll = true;
  for i = 0,self.num_kuang-1 do
      local data = self:getKuangData(i);
      
      if data and data.gain then
      else
        bGetAll = false;  
      end
  end
  
--  if bGetAll then
--    closeFamilyReddotOre();
--  end

  return bGetAll;
end

function FamilyOrePanel:getKuangData(index)
  
  if gFamilyGoldMineInfo.goldminelist == nil  or table.getn(gFamilyGoldMineInfo.goldminelist) == 0 then
    return nil;
  end

  for i,value in ipairs(gFamilyGoldMineInfo.goldminelist) do
    if value.number == index+1 then
      return value;
    end
  end
end

function FamilyOrePanel:onTouchBegan(target,touch, event)
    if target.touchName == "btn_gold" then
        local data = DB.getFamilyGoldMineByLv(Data.getCurFamilyLv())
        if nil ~= data then
            Panel.popTouchTip(self:getNode("btn_gold"), TIP_TOUCH_DESC, gGetWords("familyWords.plist","txt_ore_cry_reward",data.reward))
            self.beganAttrPos = touch:getLocation()
        end
    end
end

function FamilyOrePanel:onTouchMoved(target,touch, event)
    if self.beganAttrPos ~= nil then
        self.endAttrPos = touch:getLocation()
        local dis = getDistance(self.beganAttrPos.x,self.beganAttrPos.y, self.endAttrPos.x,self.endAttrPos.y)
        if dis > gMovedDis then
            Panel.clearTouchTip()
        end
    end
end

function FamilyOrePanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_FAMILY_ORE);
    elseif target.touchName == "btn_record" then
        Net.sendFamilyOreRank();
    elseif(target.touchName=="btn_gold")then
        Panel.clearTouchTip()   
    end

end


function FamilyOrePanel:event_wakuang(kuang_number)
  
  if kuang_number == nil then
    return;
  end
  
  print("kuang_number = "..kuang_number)
  local data = self:getKuangData(kuang_number-1);
  -- local kuangItem = self:getNode("scroll"):getItem(kuang_number-1);
  local kuangItem = self:getFamilyOreItem(kuang_number);
  --test
--  if data == nil then
--    echo("kuang data is nil");
--    data = {};
--    data.old_gold = 8500;
--    data.gold = 8500 * 2;
--    
--    gFamilyGoldMineInfo.rate = 150;    
--    gFamilyGoldMineInfo.crystal = 2;
--    gFamilyGoldMineInfo.old_crystal = 1;
--    gFamilyGoldMineInfo.addcry = true;
--  end

  
  
  if data ~= nil and kuangItem ~= nil then
  
    -- local center_pos = getPositionInDesNode(self,self.kuang[self.index],ccp(0.5,0.5));
--    center_pos.y = center_pos.y + 50;
    -- kuangItem:getNode("flag_ani"):playAction("ui_family_wakuang_a");

    local callback = function()
        self:refreshAllKuang();
    end
    
    --获取的金币 * 倍率
    -- data.gold = 20000;
    -- data.old_gold = 10000;
    local get_gold = math.floor(data.gold - data.old_gold);
    if get_gold > 0 then
        print("get_gold = "..get_gold);
        local pos = gGetPositionByAnchorInDesNode(self,kuangItem:getNode("txt_gold"),cc.p(0,0));
        local labWord = gCreateWordLabelTTF("+"..get_gold,gCustomFont,32,cc.c3b(255,255,255));
        labWord:enableOutline(cc.c4b(0,0,0,255),32*0.1);
        labWord:setScale(0);
        labWord:runAction(cc.Sequence:create(
            cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
            cc.Spawn:create(cc.MoveBy:create(1.0,cc.p(0,30)),cc.FadeTo:create(0.5,0)),
            cc.RemoveSelf:create()
        ) );
        pos = cc.p(pos.x,pos.y-15);
        labWord:setAnchorPoint(cc.p(0,0.5));
        labWord:setPosition(pos);
        self:addChild(labWord,100);

        kuangItem:updateLabelChange("txt_gold",data.old_gold,data.gold,callback);
    end
    --获取的水晶
    
--    local get_cry = gFamilyGoldMineInfo.crystal - gFamilyGoldMineInfo.old_crystal;
    if gFamilyGoldMineInfo.addcry then
        local icon_cry = cc.Sprite:create("images/ui_family/shuijing.png");
        local pos = gGetPositionByAnchorInDesNode(self,kuangItem,cc.p(0.5,-0.2));
        icon_cry:setPosition(pos);
        self:addChild(icon_cry,100);
        local desPos = gGetPositionByAnchorInDesNode(self,self:getNode("btn_gold"),cc.p(0.5,0.5));
        local bezier = {
            cc.p(pos.x+40, pos.y+100),
            cc.p(desPos.x+40, desPos.y-100),
            cc.p(desPos.x, desPos.y),
        }
        local cry_moveend = function()
            self:getCry();
        end
        icon_cry:runAction(cc.Sequence:create(
                cc.EaseSineInOut:create(cc.Spawn:create(cc.BezierTo:create(1.0, bezier),cc.ScaleTo:create(1.0,0.5,0.5))),
                cc.CallFunc:create(cry_moveend),
                cc.RemoveSelf:create()
            ));

    end
  end

end

function  FamilyOrePanel:events()

    return {EVENT_ID_FAMILY_OREWAKUANG,
        EVENT_ID_FAMILY_OREGET
      }
end

function FamilyOrePanel:dealEvent(event,param)
    if(event == EVENT_ID_FAMILY_OREWAKUANG) then
        self:refreshInfo();
        local index = param.number;
        -- local item = self:getNode("scroll"):getItem(index-1);
        local item = self:getFamilyOreItem(index);
        if(item)then
            self:refreshOtherKuang(param.number);
            self:event_wakuang(param.number);
            -- local callback = function()
            --     item:playWaitAni();
            --     -- item:getNode("flag_ani"):playAction("ui_family_wakuang_a");
            -- end
            -- item:playWakuangAni(callback);
            -- local event_wakuang = function()
            --     self:event_wakuang(param.number);
            -- end
            -- item:runAction(cc.Sequence:create(cc.DelayTime:create(1),
            --     cc.CallFunc:create(event_wakuang)));
            -- -- item:setData(self:getKuangData(item.index-1));
        end
        -- self:refreshAllKuang();
    elseif(event == EVENT_ID_FAMILY_OREGET)then

        local index = param.number;
        -- local item = self:getNode("scroll"):getItem(index-1);
        local item = self:getFamilyOreItem(index);
        if(item)then
            item:setData(self:getKuangData(item.index-1));
        end
        -- self:refreshAllKuang();
        
        if self:checkAllKuangGet() then
            Data.redpos.bolFamilyOre = false;
        end
    end
end

return FamilyOrePanel