local FamilyChNamePanel=class("FamilyChNamePanel",UILayer)
local maxNameLength = 14
local minNameLength = 4
function FamilyChNamePanel:ctor(isFree)
    self.appearType = 1
    self.isMainLayerMenuShow = false
    self:init("ui/ui_family_chname.map")  
    self:setLabelString("input_name",gFamilyInfo.sName);
    self:setLabelString("txt_dia",gFamily.createNeedDia)
    self:getNode("input_name"):setMaxLength(maxNameLength)
    self.icon = 0

    if(isFree == nil)then
        isFree = false;
    end
    self.isFree = isFree;
    if(self.isFree)then
        self:getNode("btn_close"):setVisible(false);
        self:getNode("icon_dia"):setVisible(false);
        self:getNode("txt_dia"):setVisible(false);
    end

    self:resetLayOut();
end
 

function  FamilyChNamePanel:events()
    return { EVENT_ID_FAMILY_CH_NAME}
end


function FamilyChNamePanel:dealEvent(event,param)
   if EVENT_ID_FAMILY_CH_NAME == event then
      gFamilyInfo.sName = string.filter(self:getNode("input_name"):getText())
      self:onClose()
      local panel = Panel.getPanelByType(PANEL_FAMILY_MAMAGE)
      if nil ~= panel then
          panel:chNameSucess()
      end
   end
end

function FamilyChNamePanel:onTouchEnded(target)
    if target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_confirm" then
        self:onConfirm()
    end
end

function FamilyChNamePanel:onConfirm()

  local sText = string.filter(self:getNode("input_name"):getText())

  print("fname = " ..sText)
  if sText == "" then
      local sWord = gGetWords("noticeWords.plist","intput_empty")
      gShowNotice(sWord)
      return
  end

  -- local length = string.utf8len(sText)
  -- if length < minNameLength then
  --     local sWord = gGetWords("noticeWords.plist","name_length_less")
  --     gShowNotice(sWord)
  --     return
  -- end

  local changeNamePrice = DB.getClientParam("FAMILY_CHANGE_NAME_PRICE")
  if "" == changeNamePrice then
    changeNamePrice = 200
  end
  if(self.isFree)then
    changeNamePrice = 0;
  end
  local bDiaEnough = NetErr.isDiamondEnough(changeNamePrice)
  if false == bDiaEnough then
      return
  end

  Net.sendFamilyChName(sText)
end

return FamilyChNamePanel