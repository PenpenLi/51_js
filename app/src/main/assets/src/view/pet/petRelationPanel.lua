local PetRelationPanel=class("PetRelationPanel",UILayer)

function PetRelationPanel:ctor()
    self:init("ui/ui_lingshou_tujian.map")

    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:getNode("scroll"):layout()
    self:getNode("scroll").offsetY=4
    self:initList();
end

function PetRelationPanel:events()
    return {EVENT_ID_PET_NEW_RELATION}
end

function PetRelationPanel:dealEvent(event,param)
    if(event == EVENT_ID_PET_NEW_RELATION)then
        for key, item in pairs(self:getNode("scroll").items) do
            item:refreshData(param)
        end
    end
end

function PetRelationPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

function PetRelationPanel:initList()
    -- self.curCard=card 
    local relations=DB.getRelationByType(2,1)
     
    self:getNode("scroll"):clear()
    for key, var in pairs(relations) do
        local item=PetRelationItem.new()
        item:setData(var)
        self:getNode("scroll"):addItem(item)
        
        -- if(item.activateEnable)then
        --     item.sort=100+key
        -- else
        --     item.sort=key
        -- end
         
    end


    local function sort(item1,item2) 
        return item1.sort>item2.sort
    end
     
    table.sort(self:getNode("scroll").items,sort) 
    self:getNode("scroll"):layout() 
    -- self.curCardid=card.cardid
  
end



return PetRelationPanel