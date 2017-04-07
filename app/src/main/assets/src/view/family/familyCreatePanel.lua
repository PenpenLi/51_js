local FamilyCreatePanel=class("FamilyCreatePanel",UILayer)

function FamilyCreatePanel:ctor(type)
    self:init("ui/ui_family_create.map")
    -- self.isBlackBgVisible=false  

    self:setLabelString("txt_dia",gFamily.createNeedDia);
    self:setLabelString("txt_gold",gFamily.createNeedGold);
    self.icon = 0;
end
 

function  FamilyCreatePanel:events()
    return {}
end


function FamilyCreatePanel:dealEvent(event,param)
   
end

function FamilyCreatePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
    elseif  target.touchName=="btn_set"then
      self:onNew();
    elseif  target.touchName=="btn_icon"then
    	self:onHead();
    end

end

function FamilyCreatePanel:onHead()
  local headPanel = Panel.popUpVisible(PANEL_FAMILY_HEAD);
  headPanel.onChooseIcon = function(idx)
    self:onChooseIcon(idx);
  end
end

function FamilyCreatePanel:onChooseIcon(idx)
  self.icon = idx;
  self:changeTexture("btn_icon","images/ui_family/bp_icon_"..idx..".png");
end

function FamilyCreatePanel:onNew()

  local sText = string.filter(self:getNode("input_name"):getText());

  print("fname = " ..sText);
  if sText=="" then
    local sWord = gGetWords("noticeWords.plist","intput_empty");
    gShowNotice(sWord);
    return;
  end

  if self.icon <= 0 then
    local sWord = gGetWords("familySearchWord.plist","19");
    gShowNotice(sWord);
    return;
  end

  --判断消耗
  local bDiaEnough = NetErr.isDiamondEnough(gFamily.createNeedDia);
  local bGoldEnough = NetErr.isGoldEnough(gFamily.createNeedGold);
  if bDiaEnough == false or bGoldEnough == false then
    return;
  end

  -- closeAllFamilyReddot();
  Net.sendFamilyCreate(sText,self.icon);

end

return FamilyCreatePanel