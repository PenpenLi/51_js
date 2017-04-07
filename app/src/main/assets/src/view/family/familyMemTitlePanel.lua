local FamilyMemTitlePanel=class("FamilyMemTitlePanel",UILayer)

function FamilyMemTitlePanel:ctor(data)
  self.appearType = 1;
  self:init("ui/ui_family_memtitle.map"); 
  self.data = data;
  self._panelTop = true;
  local decType = data.familyType;
  if(decType == 1)then
    self:getNode("btn0"):setVisible(false)
  elseif(decType == 2)then
    self:getNode("btn1"):setVisible(false)
  elseif(decType == 3)then
    self:getNode("btn2"):setVisible(false)
  elseif(decType == 4)then
    self:getNode("btn3"):setVisible(false)
  elseif(decType == 9)then
    self:getNode("btn4"):setVisible(false)
  end

  local curNumMemType2 = 0;
  local curNumMemType3 = 0;
  local curNumMemType4 = 0;
  for key,mem in pairs(gFamilyMemList) do
    if(mem.iType == 2)then
      curNumMemType2 = curNumMemType2 + 1;
    elseif(mem.iType == 3)then
      curNumMemType3 = curNumMemType3 + 1;
    elseif(mem.iType == 4)then
      curNumMemType4 = curNumMemType4 + 1;
    end
  end

  local data = Data.getFamilyLvData(Data.getCurFamilyLv());
  self:replaceLabelString("num1",curNumMemType2,data.memType2);
  self:replaceLabelString("num2",curNumMemType3,data.memType3);
  self:replaceLabelString("num3",curNumMemType4,data.memType4);

  self:resetAdaptNode();

end


function FamilyMemTitlePanel:onTouchEnded(target)

  if(target.touchName == "btn_close")then
    Panel.popBack(self:getTag());
  elseif(target.touchName == "btn0")then
    self.onAppointToType1(self.data);   
    Panel.popBack(self:getTag());
  elseif(target.touchName == "btn1")then
    self.onAppointToType2(self.data);   
    Panel.popBack(self:getTag());
  elseif(target.touchName == "btn2")then
    self.onAppointToType(self.data,3);   
    Panel.popBack(self:getTag());
  elseif(target.touchName == "btn3")then
    self.onAppointToType(self.data,4);   
    Panel.popBack(self:getTag());
  elseif(target.touchName == "btn4")then
    self.onAppointToType9(self.data);   
    Panel.popBack(self:getTag());
  end

end

return FamilyMemTitlePanel