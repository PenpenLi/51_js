
local FamilyContributionPanel=class("FamilyContributionPanel",UILayer)

function FamilyContributionPanel:ctor(type)
  loadFlaXml("ui_family_banggong");
  self.isMainLayerMenuShow = false;
  self:init("ui/ui_family_contribution.map") 
  -- self.scroll = self:getNode("scroll");
  -- self:refreshBtnDis();
  -- self:createList();
  local addDouble = gFamilyInfo.bolDoubleRe and 2 or 1

  for key,value in pairs(gFamilyInfo.contribution) do
    if key <= 3 then
      self:setLabelString("num_fexp"..key,value.getExp*addDouble);
      self:setLabelString("num_exp"..key,value.getFamilyExp);
      if value.constItemId == OPEN_BOX_GOLD then
        self:changeTexture("icon"..key,"images/ui_public1/coin.png");
      end
      self:setLabelString("txt_num"..key,value.costItemNum);
      local index = 1
      for itemid,num in pairs(value.items) do
        self:setLabelString("txt_item"..key.."_"..index, num)
        self:changeTexture("icon_item"..key.."_"..index,"res/images/icon/item/"..itemid..".png");
        index=index+1
      end
    end
  end
  self:refreshTimes();
end

function FamilyContributionPanel:onBtn(data)
  -- body
  -- local param = 40;
  -- gFamilyCutType = data.type;
  -- local showAnchor = {cc.p(0.25,0.6),cc.p(0.5,0.6),cc.p(0.75,0.6)}
  --   gShowItemPoolLayer:pushOneItem({id=OPEN_BOX_FAMILY_DEVOTE,num=param,showAnchor = showAnchor[gFamilyCutType]});
  -- print("data.type = "..data.type);
  -- local fla = gCreateFla("ui_family_bp_gu_"..data.type,-1);
  -- self:replaceNode("drum"..data.type,fla);
  --今日已经贡献过了
  if(gFamilyInfo.iWoodNum<=0) then
    gShowNotice(gGetWords("noticeWords.plist","familytip0"));
    return;
  end
  --TODO: 判断消耗
  if data.constItemId == OPEN_BOX_GOLD then
    if not NetErr.isGoldEnough(data.costItemNum) then
      return;
    end
  elseif data.constItemId == OPEN_BOX_DIAMOND then
    if not NetErr.isDiamondEnough(data.costItemNum) then
      return;
    end  
  end

  local fla = gCreateFla("ui_family_bp_gu_"..data.type,-1);
  self:replaceNode("drum"..data.type,fla);
  if (TDGAItem) then
    if data.constItemId == OPEN_BOX_DIAMOND then
      gLogPurchase("family_contribution",1,data.costItemNum)
    end
  end
  Net.sendFamilyAddWood(data.type) 
end

function FamilyContributionPanel:refreshTimes()
  self:getNode("tip"):setVisible(gFamilyInfo.iWoodNum <= 0);
end

function FamilyContributionPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        self:onClose();
    elseif target.touchName == "touch1" then
        self:onBtn(gFamilyInfo.contribution[1]) 
    elseif target.touchName == "touch2" then
        self:onBtn(gFamilyInfo.contribution[2]) 
    elseif target.touchName == "touch3" then
        self:onBtn(gFamilyInfo.contribution[3])
    end
end


function  FamilyContributionPanel:events()
    return {EVENT_ID_FAMILY_CUT}
end

function FamilyContributionPanel:dealEvent(event,param)

    if(event == EVENT_ID_FAMILY_CUT) then
        self:refreshTimes();  
    end
end

-- function FamilyContributionPanel:onMem()
--   Net.sendFamilyApplyList();
-- end


return FamilyContributionPanel