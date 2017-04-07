local richmanRankItem=class("richmanRankItem",UILayer)

function richmanRankItem:ctor()
    self:init("ui/ui_richman_rank_item.map")
    self:getNode("bg_vip"):setVisible(false)

end

function richmanRankItem:onTouchEnded(target)

end

function richmanRankItem:setData(data,index)
    -- print_lua_table(data)
    self.curData=data
    self:setLabelString("txt_name",data.username)
    self.type = type;

    self:setLabelAtlas("txt_power",data.score)

    local  rank = data.rank; 
    if (rank>3) then
        self:setLabelAtlas("txt_rank",rank)
        self:getNode("icon_rank"):setVisible(false)
        self:getNode("rank_123"):setVisible(false)
    else
        self:getNode("txt_rank"):setVisible(false)
        self:changeTexture("icon_rank","images/ui_jingji/no."..rank..".png");
    end
    self:replaceLabelString("txt_level",data.level)
 
    
    if(data.fname=="")then
        data.fname=gGetWords("weaponWords.plist","empty")
    end


    if (data.id == Data.getCurUserId()) then
        self:getNode("me"):setVisible(true)
    else
        self:getNode("me"):setVisible(false)
    end
    self:setLabelAtlas("txt_vip",data.vip)
    Icon.setHeadIcon(self:getNode("icon"), (data.icon)) 
    self:replaceLabelString("txt_fname", data.fname)
 
end

return richmanRankItem