
local BathPanel=class("BathPanel",UILayer)

function gEnterBath()

    local enterBath = function()
        Panel.popUp(PANEL_BATH)
    end

    gShowCloud(enterBath);
end

function BathPanel:ctor()
  cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_ui_packer_arena.plist");
  loadFlaXml("wait_xxt");
  loadFlaXml("ui_xiuxian");
  self:init("ui/ui_bath.map") 
  self.layer_roles = self:getNode("layer_roles");
  self.isMainLayerGoldShow = false;
  -- self:initTestData();

  self.effectWidth = self:getNode("flag_effect1"):getContentSize().width;
  self.effectHeight = self:getNode("flag_effect1"):getContentSize().height;
  self:replaceLabelString("txt_tip",Data.bath.gBathCallAddPercent);

  self:initPos();
  -- self:refreshUsers();
  self:refreshInfo();

  local function __update()
    self:updateTime();
  end
  self:scheduleUpdate(__update,1);

  local function onNodeEvent(event)
      if event == "enter" then
          self:onEnter();
      elseif event == "exit" then
          self:onExit();
      end
  end
  self:registerScriptHandler(onNodeEvent);

  Unlock.checkFirstEnter(SYS_BATH);
end

function BathPanel:onEnter()
  self:refreshUsers();
end

function BathPanel:onExit()
  -- print("BathPanel:onExit");
  self:unscheduleUpdateEx();
end

function BathPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
      self:onClose();
    elseif target.touchName == "btn_refresh" then
      Net.sendBathRefUser();
      -- gDispatchEvt(EVENT_ID_BATH_REFUSERS);
    elseif target.touchName == "btn_wash" then
      self:onWash();  
    elseif target.touchName == "btn_rule" then
      gShowRulePanel(SYS_BATH);
    elseif target.touchName == "btn_call" then
      --TODO: 确认界面
      if self:hasCaller() == false then
        local callback = function()
          if NetErr.isDiamondEnough(Data.bath.gBathCallNeedDia) then
            Net.sendBathCall();
            if (TDGAItem) then
                gLogPurchase("call_god_light",1,Data.bath.gBathCallNeedDia)
            end      
          end
        end
        local add_mul = 1
        if (gBathInfo.mul>1) then
           add_mul = gBathInfo.mul
        end
        local word = gGetWords("bathWords.plist","26",Data.bath.gBathCallNeedDia,Data.bath.gBathCallGetRepu,Data.bath.gBathCallAddPercent,Data.bath.gBathCallGetRepuMax);
        gConfirmCancel(word,callback);
      end
    elseif  target.touchName=="btn_exchange"then
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_ARENA)  
    elseif string.find(target.touchName,"pos") then
        local pos = string.find(target.touchName,"pos");
        local index = string.sub(target.touchName,pos+3);
        print("index = "..index);
        -- print_lua_table(self.roles);
        for key,var in pairs(self.roles) do
          if var.index == toint(index) then
            self:onClickRole(var.data);
            break;
          end
        end
    end
end


function  BathPanel:events()
    return {EVENT_ID_BATH_REFUSERS,
            EVENT_ID_BATH_FINISH,
            EVENT_ID_BATH_START,
            EVENT_ID_BATH_CALL}
end

function BathPanel:dealEvent(event,param)

    if(event == EVENT_ID_BATH_REFUSERS) then
      self:disAppearUsers();
    elseif(event == EVENT_ID_BATH_FINISH) then
      self:event_finish();  
    elseif(event == EVENT_ID_BATH_START) then
      self:event_start(); 
    elseif(event == EVENT_ID_BATH_CALL) then
      self:refreshUsers();   
    end
end

function BathPanel:initTestData()

   gBathInfo.type = 0;
   gBathInfo.bathtime = 0;
   gBathInfo.reftype = 1;
   gBathInfo.refnum = 0;
   gBathInfo.bathnum = 0;
   gBathInfo.molestnum = 0;
   gBathInfo.molesttime = 0;
   gBathInfo.attrnum = 2;

   gBathInfo.all_uid = 0;
   gBathInfo.all_name = 0;
   gBathInfo.all_time = 0;

   gBathInfo.list = {};
   for i = 0,100 do
     table.insert(gBathInfo.list,{id = 0,name = "test"..i,type = math.random(1,5),icon = math.random(10001,10030),show = {}});
   end

end

function BathPanel:refreshInfo()
  local wash_num = Data.bath.gBathNumOneDay - gBathInfo.bathnum;
  self:setLabelString("txt_wash_num",wash_num);

  local flirt_num = Data.bath.gBathMolestNumOneDay - gBathInfo.molestnum;
  self:setLabelString("txt_molest_num",flirt_num);
  
  self.molest_lefttime = gBathInfo.molesttime - gGetCurServerTime();
  if self.molest_lefttime <= 0 then
    self:getNode("bg_time"):setVisible(false);
  else
    self:getNode("bg_time"):setVisible(true);  
  end
    
  self.bath_lefttime = gBathInfo.bathtime - gGetCurServerTime();
  if self.bath_lefttime <= 0 then
    self:getNode("bg_bath_time"):setVisible(false);
    self:setLabelString("lab_btn_bath",gGetWords("bathWords.plist","31"));
  else
    self:getNode("bg_bath_time"):setVisible(true);
    self:setLabelString("lab_btn_bath",gGetWords("bathWords.plist","30"));
  end  


  self.call_lefttime = gBathInfo.all_time - gGetCurServerTime();
  -- self:showCallEffect();
end


function BathPanel:initPos()
  self.iOffsetW = 10;
  self.iOffsetH = 0;
  self.roleW = 110;
  self.roleH = 90;
  self.rand_offsetx = 20;
  self.rand_offsety = 15;
  self.roleCountW = self.layer_roles:getContentSize().width / (self.roleW + self.iOffsetW);
  self.roleCountH = self.layer_roles:getContentSize().height / (self.roleH + self.iOffsetH);
  -- print("self.roleCountW = "..self.roleCountW .. " self.roleCountH = "..self.roleCountH);
  local start_pos = cc.p((self.roleW+self.iOffsetW)/2,
                          self.layer_roles:getContentSize().height - (self.roleH+self.iOffsetH)/2);
  self.role_pos = {};
  -- self.center_pos_count = 0;
  local pos1 =  gGetPositionInDesNode(self.layer_roles,self:getNode("rect1"));
  local size1 = self:getNode("rect1"):getContentSize();
  local rect1 = cc.rect(pos1.x,pos1.y,size1.width,size1.height);

  pos1 =  gGetPositionInDesNode(self.layer_roles,self:getNode("rect2"));
  size1 = self:getNode("rect2"):getContentSize();
  local rect2 = cc.rect(pos1.x,pos1.y,size1.width,size1.height);

  local contentW = self.layer_roles:getContentSize().width;
  local contentH = self.layer_roles:getContentSize().height;
  local pos = {};
  pos.x = start_pos.x;
  pos.y = start_pos.y;
  for i = 1,100 do
    local scale = 1.0;
    if pos.y < contentH/3 then
      scale = 1.2;
    elseif pos.y < contentH/3*2 then
      scale = 1;
    else
      scale = 0.8;
    end    

    local roleW = self.roleW;
    local roleH = self.roleH;
    if(scale < 1)then
      roleW = self.roleW*scale;
      roleH = self.roleH*scale;
    end

    if cc.rectContainsPoint(rect1, pos) == false and cc.rectContainsPoint(rect2, pos) == false then
      local desPos = {};
      desPos.x = pos.x;
      desPos.y = pos.y;
      table.insert(self.role_pos,{pos=desPos,scale=scale});

      -- local node = self:createMounts(1,1);
      -- node:setPosition(pos);
      -- self.layer_roles:addChild(node);
    end

    pos.x = pos.x + (roleW+self.iOffsetW);
    if(pos.x > contentW)then
      pos.x = start_pos.x;
      pos.y = pos.y - (roleH+self.iOffsetH);
    end

    -- print("pos.y = "..pos.y);
    if(pos.y < 0)then
      break;
    end
  end      

  -- print("pos count = "..table.getn(self.role_pos));
  -- for i = 1,self.roleCountW do
  --   for j = 1,self.roleCountH+1 do
  --     local pos = cc.p( start_pos.x + (i-1)*(self.roleW+self.iOffsetW),
  --                       start_pos.y - (j-1)*(self.roleH+self.iOffsetH));
  --     if cc.rectContainsPoint(rect1, pos) == false and cc.rectContainsPoint(rect2, pos) == false then
  --       table.insert(self.role_pos,pos);
  --     end
  --     -- local node = self:createMounts(1,1);
  --     -- node:setPosition(pos);
  --     -- self.layer_roles:addChild(node);
  --   end
  -- end

  -- print_lua_table(self.role_pos);
  -- print("end");  
end

function BathPanel:disAppearUsers()

  local refreshData = function()
    self:refreshUsers();
  end

  local time = 0.35;
  local delaytime = 0.5;
  local children = self.layer_roles:getChildren() 
  local dis = 0;
  local delay = 0;
  for key,role in pairs(children) do
    dis = math.random(-50,50)
    delay = math.random()/2;
    -- print("delay = ".. delay);
    role:runAction(cc.Sequence:create(
                    cc.DelayTime:create(delay),
                    cc.Spawn:create(
                        cc.MoveBy:create(time,cc.p(-dis,0)),
                        cc.FadeOut:create(time)
                        )));
  end
  gCallFuncDelay(time+delaytime,self,refreshData);

end

function BathPanel:appearUsers()
  -- body
  local time = 0.35;
  local delaytime = 0.5;
  local children = self.layer_roles:getChildren()
  local dis = 0;
  local delay = 0;
  for key,role in pairs(children) do
    dis = math.random(-50,50)
    delay = math.random()/2;
    -- print("delay = ".. delay);
    role:setPositionX(role:getPositionX() + dis);
    role:runAction(cc.Sequence:create(
                    cc.DelayTime:create(delay),
                    cc.Spawn:create(
                        cc.MoveBy:create(time,cc.p(-dis,0)),
                        cc.FadeIn:create(time)
                        )));
  end
end

function BathPanel:refreshUsers()
  -- checkReddotBath();

  -- setFullScreenTouch(true);
  local user_count = table.getn(gBathInfo.list);
  local pos_count = table.getn(self.role_pos);
  if(gIsAndroid())then
    if(user_count > pos_count)then
      user_count = pos_count - 10;
    end
  end
  
  local mySelf = nil;
  for key,role in pairs(gBathInfo.list) do
    if(role.id == Data.getCurUserId())then
      mySelf = role;
      user_count = user_count - 1;
      table.remove(gBathInfo.list,key);
      break;
    end
  end
  --删除
  self.layer_roles:removeAllChildren(true);
  -- self:removeAllTouch();
  
  --取出用户数据
  local rolelist = {};
  print("pos_count = "..pos_count.." user_count = "..user_count);
  local indexs = getRandomArray(pos_count,user_count);
  for i = 1,#indexs do
    local idx = indexs[i];
    table.insert(rolelist,gBathInfo.list[idx]);
  end
  if mySelf then
    table.insert(rolelist,mySelf);
    table.insert(gBathInfo.list,mySelf);
  end
  -- print_lua_table(rolelist);
  
  --随机填充位置，比如50位置取出30个
  local rand_offsetx = self.rand_offsetx;
  local rand_offsety = self.rand_offsetx;
  user_count = table.getn(rolelist);
  local pos;
  -- print("rand_pos");
  local pos_indexs = getRandomArray(user_count,pos_count);
  -- print_lua_table(pos_indexs);
  self.roles = {};
  local contentH = self.layer_roles:getContentSize().height;
  for i = 1,#pos_indexs do
      local pos_idx = pos_indexs[i];
      -- print("pos_idx = "..pos_idx);
      local roledata = rolelist[i];
      if roledata ~= nil then

        local icon = self:createMounts(roledata.type,roledata.icon,roledata.id,roledata.show.wkn);
        local value = self.role_pos[pos_idx].pos;
        local scale = self.role_pos[pos_idx].scale;
        -- pos = value;
        -- print_lua_table(value);
        local offsetScale = scale
        if(offsetScale > 1)then
          offsetScale = 1;
        end
        pos = cc.p(value.x+math.random(-rand_offsetx*offsetScale,rand_offsetx*offsetScale),
                   value.y+math.random(-rand_offsety*offsetScale,rand_offsety*offsetScale));
        -- pos = self.layer_role:convertToNodeSpace(pos);
        local worldpos = self.layer_roles:convertToWorldSpace(pos);
        if(worldpos.y < 60) then
          worldpos.y = 60;
          pos = self.layer_roles:convertToNodeSpace(worldpos);
        end

        icon:setScale(icon:getScale()*scale);
        -- if pos.y < contentH/3 then
        --   icon:setScale(icon:getScale()*1.2);
        -- elseif pos.y < contentH/3*2 then
        --   icon:setScale(icon:getScale()*1);
        -- else
        --   icon:setScale(icon:getScale()*0.8);  
        -- end
        if(math.random() < 0.5 and roledata.id ~= Data.getCurUserId()) then
          icon:setScaleX(-icon:getScaleX());
        end
        icon:setAllChildCascadeOpacityEnabled(true);
        icon:setOpacity(0);
        icon:setPosition(pos);
        icon:setTag(100+i);

        self.layer_roles:addChild(icon);


  -- local node2 = cc.Sprite:create("images/ui_bath/mounts"..roledata.type..".png");
  -- node2:setScale(0.4);
  -- node2:setPosition(pos);
  -- self.layer_roles:addChild(node2);

        table.insert(self.roles,{node = icon,data = roledata,index = pos_idx});
        self:addTouchNode(icon,"pos"..pos_idx,"1");
        end
  end
  
  self:showCallEffect();
  -- local caller = nil;
  -- if gBathInfo.all_uid > 0 then
      
  -- end


  --排序
      local function sortRoleZ(role1,role2)
        local pos1 = cc.p(role1.node:getPosition());
        local pos2 = cc.p(role2.node:getPosition());
        if(pos1.y > pos2.y) then
          return true;
        end
        return false;
      end
      
      table.sort(self.roles,sortRoleZ);
      
      --reorderZ
      local z = 0;
      local node = nil;
      for key,value in pairs(self.roles) do
        node = value.node;
        node:getParent():reorderChild(node,z);
        z = z + 1;
      end

    -- if gBathInfo.all_uid ~= 0 then
    --   self:add_call_effect();
    -- else
    --   self:del_call_effect(); 
    -- end

    self:appearUsers();
end

function BathPanel:createMounts(type,icon,uid,awakeLv)
  -- local node = cc.Sprite:create("images/ui_bath/mounts"..type..".png");
  -- node:setScale(0.4);

  local bg = cc.Node:create();
  bg:setAnchorPoint(cc.p(0.5,0.5));
  bg:ignoreAnchorPointForPosition(false);
  bg:setContentSize(self.roleW,self.roleH);

  local node = gCreateFla("wait_xxt_"..type,1);
  node:setScale(0.4);
  node:setContentSize(self.roleW,self.roleH);

  local role = gCreateFlaDislpay("r"..icon.."_wait2",1,"r"..icon.."_wait2",awakeLv);
  -- if self:hasCaller() then
  --   local effect = cc.Sprite:create("images/ui_bath/x-12.png");
  --   effect:setScale(2.5);
  --   gRefreshNode(role,effect,cc.p(0.5,0),cc.p(0,140),100);
  -- end

  node:replaceBoneWithNode({"npc"},role);

  -- local npc = cc.Node:create();
  -- local fla = gCreateRoleFlaInBath(icon,npc,0.9,false,"r"..icon.."_wait2");
  -- node:replaceBoneWithNode({"npc"},npc);

  local time = math.random(3.0,3.5);
  local offh = math.random(5,10);
  if(math.random()<0.5) then
    offh = -offh;
  end
  bg:runAction(
      cc.RepeatForever:create(
        cc.Sequence:create(
          cc.MoveBy:create(time,cc.p(0,offh)),
          cc.MoveBy:create(time,cc.p(0,-offh))
          )
      )
    );

  if self:hasCaller() then
    local effect = cc.Sprite:create("images/ui_bath/x-12.png");
    effect:setScale(2.5);
    -- gRefreshNode(node,effect,cc.p(0.5,0),cc.p(0,140),100);
    gRefreshNode(node,effect,cc.p(0.5,0.5),cc.p(-30,50),100);
    effect:runAction(
      cc.RepeatForever:create(
        cc.Sequence:create(
          cc.FadeTo:create(3.0,128),
          cc.FadeTo:create(3.0,255)
          )
      )
    );
  end

  node:setTag(100);
  gAddChildInCenterPos(bg,node);
  -- bg:addChild(node);

  if(uid == Data.getCurUserId())then
    local pMeFlag = cc.Sprite:create("images/ui_family/ME.png");
    -- pMeFlag:setScaleX(-pMeFlag:getScaleX());
    pMeFlag:setPosition(cc.p(30,self.roleH+10));
    bg:addChild(pMeFlag);
  end

  return bg;

end

--显示佛光效果
function BathPanel:showCallEffect()

  local hasCaller = self:hasCaller();

  self:getNode("layer_light"):setVisible(hasCaller);
  self:getNode("flag_effect1"):setVisible(hasCaller);
  self:getNode("flag_effect2"):setVisible(hasCaller);
  self:getNode("txt_tip"):setVisible(hasCaller);
  self:setTouchEnable("btn_call",not hasCaller,false);
  if hasCaller then
    self:setLabelString("txt_name",gBathInfo.all_name);
    self:setNodeAppear("flag_effect2",true);
    self.call_lefttime = gBathInfo.all_time - gGetCurServerTime();
  else
    for key,var in pairs(self.roles) do
      if var.node then
        local icon = var.node:getChildByTag(100);
        if(icon) then
          icon:removeChildByTag(100);
        end
      end
    end
  end

end

function BathPanel:hasCaller()
  if gBathInfo.all_uid > 0 and gBathInfo.all_time > gGetCurServerTime() then
    return true;
  end
  return false;
end

function BathPanel:onClickRole(data)
  print("uid = "..data.id);

  -- -- data.id = 0;
  -- if data.id == 0 then
  --   local word = getWordWithFile("bath.plist","43");
  --   word = replaceString(word,data.name);
  --   NotificationLayer:showInfo(word);
  --   return;
  -- end

  Net.sendBathUserInfo(data.id);
  
--  popLayer(LOADING_WASH_DETAIL,Loading_OpacityBg,data);
end

function BathPanel:onWash()

    if self.bath_lefttime <= 0 then
      local left_time = Data.bath.gBathNumOneDay - gBathInfo.bathnum;
      if left_time <= 0 then
        gShowCmdNotice("bath.start",14);
        return;
      end

      Panel.popUpVisible(PANEL_BATH_DETAIL);
    else
      local onFinish = function()
        self:onFinishWash();
      end
        gConfirmCancel(gGetWords("bathWords.plist","33",Data.bath.gBathFinish),onFinish);
    end    
end

function BathPanel:onFinishWash()
  if NetErr.isDiamondEnough(Data.bath.gBathFinish) then
    Net.sendBathFinish();
  end
end
function BathPanel:event_start()
  self:refreshInfo();
  self:refreshUsers();
  -- setFullScreenTouch(false);
  -- playCloudAni(self.pBg,self.pBg.refreshUsers);
  
end
function BathPanel:event_finish()
  self:onBathEnd();
  self:refreshUsers();
  -- setFullScreenTouch(false);
  -- playCloudAni(self.pBg,self.pBg.refreshUsers);
  
end

function BathPanel:updateTime()
    -- print("BathPanel:updateTime");
    if(self.bath_lefttime > 0) then
      self.bath_lefttime = gBathInfo.bathtime - gGetCurServerTime();
      self:refreshBathTime();
    end

    if(self.molest_lefttime > 0) then
      self.molest_lefttime = gBathInfo.molesttime - gGetCurServerTime();
      self:refreshMolestTime();
    end

    if(self.call_lefttime > 0) then
      self.call_lefttime = gBathInfo.all_time - gGetCurServerTime();
      self:refreshCallTime();
    end
end

function BathPanel:refreshBathTime()

  local sTime = gParserHourTime(self.bath_lefttime);
  self:setLabelString("lab_bath_time",sTime);

  if (self.bath_lefttime <= 0) then
    self:onBathEnd();
  end
  
end

function BathPanel:onBathEnd()
    --修炼结束
    self:getNode("bg_bath_time"):setVisible(false);
    self:setLabelString("lab_btn_bath",gGetWords("bathWords.plist","31"));

    --提示获得物品
--    ShowItemPool:shared():showItems();
    
    --重置相关数据
    gBathInfo.reftype = 1;
    gBathInfo.bathtime = 0;
    gBathInfo.attrnum = 0;
    
    for key,role in pairs(gBathInfo.list) do
      if(role.id == Data.getCurUserId())then
        table.remove(gBathInfo.list,key);
        break;
      end
    end
end

function BathPanel:refreshMolestTime()

  local sTime = gParserHourTime(self.molest_lefttime);
  self:setLabelString("lab_molest_time",sTime);

  if (self.molest_lefttime <= 0) then
    self:getNode("bg_time"):setVisible(false);
    gBathInfo.molesttime = 0;
  end
  
end

function BathPanel:refreshCallTime()
  local percent = self.call_lefttime/Data.bath.gBathCallTime;
  local effectNode = self:getNode("flag_effect1");
  -- print("percent = "..percent);
  effectNode:setTextureRect(cc.rect(0,self.effectHeight*(1-percent),self.effectWidth,self.effectHeight*percent));

  if self.call_lefttime <= 0 then
    self:showCallEffect();
  end
end

return BathPanel