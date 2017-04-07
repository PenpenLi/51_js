local ArenaRankMenuItem=class("ArenaRankMenuItem",UILayer)

function ArenaRankMenuItem:ctor()
    self:init("ui/ui_arena_rank_item1.map")
    self:getNode("sign"):setVisible(false)
end

function ArenaRankMenuItem:setSelect(value)
    if(value)then
        self:changeTexture("btn_1","images/ui_public1/button_s2-1.png")
    else 
        self:changeTexture("btn_1","images/ui_public1/button_s2.png")
    end
    self:getNode("sign"):setVisible(value)
end

function ArenaRankMenuItem:onTouchEnded(target)  
    if(self.onSelectCallback)then
        self.onSelectCallback(self.curData)
   end
end

function ArenaRankMenuItem:setData(data)
    self.curData=data
    self:setLabelString("txt_name",data.name)
end

return ArenaRankMenuItem