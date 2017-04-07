local PetCaveTaskPanel=class("PetCaveTaskPanel",UILayer)

function PetCaveTaskPanel:ctor(data)
    self:init("ui/ui_task.map")
    self:getNode("scroll_achieve").eachLineNum=1
    self:getNode("scroll_achieve"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.achieve = data;

    self:getNode("empty_layer"):setVisible(false)
    self:getNode("btn_type1"):setVisible(false)
    self:changeTexture("btn_type2","images/ui_public1/b_biaoqian4.png")
    self:resetLayOut()

    self:getAchieve();
end

function PetCaveTaskPanel:onPopback()
    Scene.clearLazyFunc("caveAchieveItem");
end

function PetCaveTaskPanel:onPopup()
end

function  PetCaveTaskPanel:initAchieve()

    Scene.clearLazyFunc("caveAchieveItem");
    if(self.achieve==nil)then
        self:getNode("empty_layer"):setVisible(true)
        return
    end
    local function sortWithLv(buddy1,buddy2)
      if(buddy1.sort > buddy2.sort) then
        return true;
      end
      return false;
    end

    self:getNode("empty_layer"):setVisible(table.count(self.achieve)==0)

    table.sort(self.achieve,sortWithLv);

    self:getNode("scroll_achieve"):clear()
    -- print_lua_table(self.achieve);
    for key, var in pairs(self.achieve) do
        local item=TaskItem.new()
        if key < 6 then
            item:setAchieveData(var) 
        else
            item:setLazyAchieveData(var) 
        end
        self:getNode("scroll_achieve"):addItem(item)
    end
    self:getNode("scroll_achieve"):layout()
end

function PetCaveTaskPanel:removeAchieveData( id )
    -- body
    if self.achieve == nil then
        return -1;
    end

    local index = 0;
    for key,var in pairs(self.achieve) do
        if var.achId == id then
            table.remove(self.achieve,key);
            return index;
        end
        index = index + 1;
    end
    return -1;
end

function PetCaveTaskPanel:removeAchieve(index)
    self:getNode("scroll_achieve"):removeItemByIndex(index);

end

function PetCaveTaskPanel:dealRedDotAchieve()
    -- body
    for key,var in pairs(self.achieve) do
        if(var.bolGet) then
            Data.redpos.bolAchieve = true;
            return;
        end
    end    
    Data.redpos.bolAchieve = false;
end

function  PetCaveTaskPanel:getAchieve()
    if(self.achieve==nil)then
        Net.sendAchieveList(nil,nil,2)
    else
        self:initAchieve()
    end
    self:getNode("panel_achieve"):setVisible(true)
    self:getNode("panel_task"):setVisible(false)
end

function  PetCaveTaskPanel:events()
    return {
    EVENT_ID_ACHIEVE_LIST,
    EVENT_ID_ACHIEVE_GET}
end

function PetCaveTaskPanel:dealEvent(event,param)
   if(event==EVENT_ID_ACHIEVE_LIST)then
        self.achieve=param
        if(self:getNode("panel_achieve"):isVisible())then
            self:initAchieve()
        end
       -- self:dealRedDotAchieve();
    elseif(event == EVENT_ID_ACHIEVE_GET) then
        local index = self:removeAchieveData(param.remove_id);
        if param.new_data then
            table.insert(self.achieve,param.new_data);
            self:initAchieve();
            -- self:addNewAchieve(param.new_data);
        else
            self:removeAchieve(index); 
        end
        --self:dealRedDotAchieve();
    end
end

function PetCaveTaskPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())     
    end
end

return PetCaveTaskPanel