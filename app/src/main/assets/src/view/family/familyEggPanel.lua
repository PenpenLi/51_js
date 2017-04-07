
local FamilyEggPanel=class("FamilyEggPanel",UILayer)

function FamilyEggPanel:ctor()
  self.isMainLayerMenuShow = false;
  self:init("ui/ui_family_zadan.map") 

  self:setLabelString("txt_fexp",Data.family.eggFExp);
  self:refreshTimes();
end

function FamilyEggPanel:onBtn(index)
  -- body
  -- local param = 40;
  -- gFamilyCutType = data.type;
  -- local showAnchor = {cc.p(0.25,0.6),cc.p(0.5,0.6),cc.p(0.75,0.6)}
  --   gShowItemPoolLayer:pushOneItem({id=OPEN_BOX_FAMILY_DEVOTE,num=param,showAnchor = showAnchor[gFamilyCutType]});

  -- self:showGetItem(index);

  --今日已经砸蛋过了
  if(gFamilyInfo.iStoneNum<=0) then
    gShowNotice(gGetWords("noticeWords.plist","51"));
    return;
  end
  Net.sendFamilyEgg(index);
end

function FamilyEggPanel:showGetItem(index)
  -- local item = {id=OPEN_BOX_FAMILY_DEVOTE,num=12345}
  local count = table.getn(gShowItemPoolLayer.itemStack);
  if count <= 0 then
    return;
  end

  local item = gShowItemPoolLayer.itemStack[1];
  gShowItemPoolLayer:clearItems();

  local fla = gCreateFla("ui_family_egg",-1);
  local rtf = RTFLayer.new();
  local node = DropItem.new();
  node:setData(item.id);
  node:setNum(0);
  node:setAnchorPoint(cc.p(0.5,-0.5));
  node:setOpacityEnabled(true);
  local icon = cc.Node:create();
  icon:setCascadeOpacityEnabled(true);
  icon:setContentSize(node:getContentSize());
  icon:setScale(0.36);
  gAddChildByAnchorPos(icon,node,cc.p(0.5,0.5));
  rtf:addNode(icon);
  local name = DB.getItemName(item.id);
  rtf:addWord(name.."x"..item.num);
  rtf:layout();
  fla:replaceBoneWithNode({"icon"},rtf);

  self:replaceNode("egg"..index,fla);

  local flaLight = gCreateFla("ui_family_topguang");
  local egg = self:getNode("egg"..index);
  gAddChildByAnchorPos(egg:getParent(),flaLight,cc.p(0,0),cc.p(egg:getPosition()));
  -- gAddChildInCenterPos(self:getNode("egg"..index),flaLight);
end

function FamilyEggPanel:refreshTimes()
  self:getNode("tip"):setVisible(gFamilyInfo.iStoneNum <= 0);
end

function FamilyEggPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "touch1" then
        self:onBtn(1) 
    elseif target.touchName == "touch2" then
        self:onBtn(2) 
    elseif target.touchName == "touch3" then
        self:onBtn(3)
    elseif target.touchName == "touch4" then
        self:onBtn(4) 
    elseif target.touchName == "touch5" then
        self:onBtn(5)
    end
end


function  FamilyEggPanel:events()
    return {EVENT_ID_FAMILY_CUT}
end

function FamilyEggPanel:dealEvent(event,param)

    if(event == EVENT_ID_FAMILY_CUT) then
        self:showGetItem(gFamilyCutType);
        self:refreshTimes();  
    end
end

-- function FamilyEggPanel:onMem()
--   Net.sendFamilyApplyList();
-- end


return FamilyEggPanel