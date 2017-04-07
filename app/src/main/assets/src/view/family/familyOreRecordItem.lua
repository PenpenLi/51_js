
local FamilyOreRecordItem=class("FamilyOreRecordItem",UILayer)

function FamilyOreRecordItem:ctor(data)
    self:init("ui/ui_family_record_item.map")

-- search_family.name = pObj:getString("name");
--           search_family.num = pObj:getInt("num");
--           search_family.luck = pObj:getInt("luck");
--           search_family.gold = pObj:getInt("gold");
--           search_family.time = pObj:getInt("time");

    self:setLabelString("txt_name",data.name);
    self:setLabelString("txt_wakuang_times",data.num);
    self:setLabelString("txt_cry_num",data.luck);
    self:setLabelString("txt_gold",data.gold);
    -- self:setLabelString("txt_gold",data.time);
    -- gShowLoginTime(self,"txt_login_time",gGetCurServerTime() - data.time,false);
    local loginTime = gGetCurServerTime() - data.time;
    self:getNode("txt_login_time"):setVisible(false);
    self:getNode("txt_login_time2"):setVisible(false);
    if(loginTime == 0)then
      self:getNode("txt_login_time2"):setVisible(true);
    else
      self:getNode("txt_login_time"):setVisible(true);
      local word = getTimeDiff(loginTime);
      self:setLabelString("txt_login_time",word);
    end
end

return FamilyOreRecordItem