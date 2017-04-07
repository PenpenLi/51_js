
local FamilyExpRankPanel=class("FamilyExpRankPanel",UILayer)

function FamilyExpRankPanel:ctor()
    -- self.appearType = 1;
    self:init("ui/ui_family_exprank.map") 
    self.isMainLayerMenuShow = false;
    self.curType = -1;
    self:selectBtn("btn_type1");
    self:sendRank(0);
end


function  FamilyExpRankPanel:events()
    return {EVENT_ID_RANK_FAMILY_EXP}
end


function FamilyExpRankPanel:dealEvent(event,param)

  if(event==EVENT_ID_RANK_FAMILY_EXP)then
    self:createList(); 
  end
end

function FamilyExpRankPanel:createList()

  if(self.curType == 0)then
    self:setLabelString("txt_exp",gGetWords("familyMenuWord.plist","110"));
  elseif(self.curType == 1)then
    self:setLabelString("txt_exp",gGetWords("familyMenuWord.plist","111"));
  end 
  self:getNode("scroll"):clear();
  for key,value in ipairs(Data.family.exprank) do
    local item = FamilyExpRankItem.new(value);
    self:getNode("scroll"):addItem(item);
  end
  self:getNode("scroll"):layout();
  
end

function FamilyExpRankPanel:resetBtnTexture()
    local btns={
        "btn_type1",
        "btn_type2",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian4-1.png")
    end
end

function FamilyExpRankPanel:selectBtn(name)

    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/b_biaoqian4.png")
end

function FamilyExpRankPanel:sendRank(type)
    if(self.curType == type)then
      return;
    end
    self.curType = type;
    Net.sendFamilyExpRank(self.curType);
end

function FamilyExpRankPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag());
    elseif  target.touchName=="btn_type1"then
        self:selectBtn(target.touchName);
        self:sendRank(0);
    elseif  target.touchName=="btn_type2"then
        self:selectBtn(target.touchName);
        self:sendRank(1);
    end
end
 

return FamilyExpRankPanel