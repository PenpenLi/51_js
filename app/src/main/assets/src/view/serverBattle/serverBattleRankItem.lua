local ServerBattleRankItem=class("ServerBattleRankItem",UILayer)

function ServerBattleRankItem:ctor()
    
end
function ServerBattleRankItem:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP))
    self:getNode("bg_vip"):setVisible(false)
end  

function ServerBattleRankItem:onTouchEnded(target)
    -- if (self.type == EVENT_ID_RANK_FAMILY) then return end
    -- if  target.touchName=="touch"then 
    --     if (self.type == EVENT_ID_ARENA_RANK) then
    --         Net.sendArenaCardInfo(self.curData)
    --     else
    --         Net.sendBuddyTeam(self.curData.id)
    --     end
    -- end
end

function ServerBattleRankItem:setData(data)

    self:init("ui/ui_serverbattle_rank_item.map")
    self:hideCloseModule()
    self.curData=data
    self.type = type
    self:setLabelString("txt_name",data.uname)
    self:setLabelAtlas("txt_power",data.power)

    local rank = data.rank
    if (rank>3) then
        self:setLabelAtlas("txt_rank",rank)
        self:getNode("icon_rank"):setVisible(false)
        self:getNode("rank_123"):setVisible(false)
    else
        self:getNode("txt_rank"):setVisible(false)
        self:changeTexture("icon_rank","images/ui_jingji/no."..rank..".png")
    end
    self:replaceLabelString("txt_level",data.level)

    local fname = nil
    if (data.fname ~= nil) then
        fname = data.fname
    else
        local sWord = gGetWords("arenaWords.plist","lab_no")
        fname = sWord
    end
    
    self:getNode("me"):setVisible(false)

    self:setLabelAtlas("txt_vip",data.vip)
    Icon.setHeadIcon(self:getNode("icon"), (data.icon))
    -- self:replaceLabelString("txt_fname",fname)

    if (data.id == Data.getCurUserId()) then
        self:getNode("me"):setVisible(true)
    end

    self:setLabelString("txt_sname", data.sname)

    if rank <=16 then
        self:changeTexture("icon_rank_ground", "images/ui_word/s_bang_tian.png")
    elseif rank <= 32 then
        self:changeTexture("icon_rank_ground", "images/ui_word/s_bang_di.png")
    else
        self:getNode("icon_rank_ground"):setVisible(false)
    end
end

function  ServerBattleRankItem:setLazyData(data)
    self.lazyData=data
    Scene.addLazyFunc(self,function()
        self:setData(self.lazyData)
    end,"serverbattlerankitem")
end

return ServerBattleRankItem