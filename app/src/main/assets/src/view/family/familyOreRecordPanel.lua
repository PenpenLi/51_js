
local FamilyOreRecordPanel=class("FamilyOreRecordPanel",UILayer)

function FamilyOreRecordPanel:ctor()
    self:init("ui/ui_family_record.map")
    self.isMainLayerMenuShow = false;
    self:createList();
end

function FamilyOreRecordPanel:createList()

  for key,rec in pairs(gFamilyGoldMineRank) do
    local item = FamilyOreRecordItem.new(rec);
    self:getNode("scroll"):addItem(item);
  end
  self:getNode("scroll"):layout();

end

function FamilyOreRecordPanel:onTouchEnded(target)

    if target.touchName=="btn_close"then
        self:onClose();
    end

end

return FamilyOreRecordPanel