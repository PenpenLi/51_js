local ArenaRankItem=class("ArenaRankItem",UILayer)

function ArenaRankItem:ctor()
    self:init("ui/ui_arena_rank_item.map")
   self:hideCloseModule();
    
end
function ArenaRankItem:hideCloseModule()
    self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
     self:getNode("bg_vip"):setVisible(false);
end  

function ArenaRankItem:onTouchEnded(target)
    -- if (self.type == EVENT_ID_RANK_FAMILY) then return end
    if  target.touchName=="touch"then 
        if (self.type == EVENT_ID_ARENA_RANK) then
            Net.sendArenaCardInfo(self.curData)
        elseif (self.type == EVENT_ID_RANK_FAMILY) then
            Net.sendFamilyGetFamilyInfo(self.curData.id);
        elseif (self.type == EVENT_ID_RANK_CAVE) then   
             Net.sendBuddyTeam(self.curData.id,TEAM_TYPE_CAVE)
        elseif (self.type ~= EVENT_ID_RANK_FAMILY_STAGE_HARM) then   
            Net.sendBuddyTeam(self.curData.id)
        end
    end
end

function ArenaRankItem:setData(data,type,index)
    -- print_lua_table(data)
    self.curData=data
    self:setLabelString("txt_name",data.name)
    self.type = type;

    if (type == EVENT_ID_ARENA_RANK) then
        self:setLabelAtlas("txt_power",data.fight)
    elseif (type == EVENT_ID_RANK_LEVEL) then
        self:setLabelAtlas("txt_power",data.level)
    elseif (type == EVENT_ID_RANK_PET) then
        self:setLabelAtlas("txt_power",data.mapid)
    elseif (type == EVENT_ID_RANK_FAMILY) then
        self:setLabelAtlas("txt_power",data.exp)
    elseif (type == EVENT_ID_RANK_BOSS) then
        self:setLabelAtlas("txt_power",data.price)
    elseif (type == EVENT_ID_RANK_TOWER) then
        self:setLabelAtlas("txt_power",data.maxstar)
    elseif (type == EVENT_ID_RANK_FAMILY_STAGE_HARM) then
        self:setLabelAtlas("txt_power",data.harm)
    elseif (type == EVENT_ID_RANK_CAVE) then
        self:setLabelAtlas("txt_power",data.price)
    end
    local rank = data.rank
    if (type == EVENT_ID_ARENA_RANK) then
        rank = data.rank;
    else
        rank = index;
    end
    
    if (rank>3) then
        self:setLabelAtlas("txt_rank",rank)
        self:getNode("icon_rank"):setVisible(false)
        self:getNode("rank_123"):setVisible(false)
    else
        self:getNode("txt_rank"):setVisible(false)
        self:changeTexture("icon_rank","images/ui_jingji/no."..rank..".png");
    end
    self:replaceLabelString("txt_level",data.level)

    local fname = nil;
    if (data.fname ~= nil) then
        fname = data.fname;
    else
        local sWord = gGetWords("arenaWords.plist","lab_no");
        fname = sWord;
    end
    
    -- print("data.cid="..data.cid)
    -- Icon.setIcon(Data.convertToIcon(data.cid),self:getNode("icon"))

    self:getNode("me"):setVisible(false)

    if (type == EVENT_ID_RANK_FAMILY) then
        self:getNode("bg_vip"):setVisible(false)

        local sWord = gGetWords("arenaWords.plist","14");--军团
        sWord = gReplaceParam(sWord,data.name)
        self:setLabelString("txt_name",sWord)
        -- self:replaceLabelString("txt_name",data.name)

        local sWord1 = gGetWords("arenaWords.plist","14-1");--军团长
        sWord1 = gReplaceParam(sWord1,fname)
        self:setLabelString("txt_fname",sWord1)
        -- self:replaceLabelString("txt_fname",fname)

        -- print_lua_table(data)
        -- print("gFamilyInfo.familyId="..gFamilyInfo.familyId)
        -- print("data.id="..data.id)
        if (data.id == gFamilyInfo.familyId) then
            self:getNode("me"):setVisible(true)
        end

        Icon.setFamilyIcon(self:getNode("icon"),data.cid,data.id);
        -- self:changeTexture("icon","images/ui_family/bp_icon_"..data.cid..".png");
        -- self:getNode("icon"):setScale(1.0)

        self:getNode("icon"):setPositionX(self:getNode("icon"):getPositionX()-18)
        self:getNode("txt_name"):setPositionX(self:getNode("txt_name"):getPositionX()-30)
        self:getNode("txt_fname"):setPositionX(self:getNode("txt_fname"):getPositionX()-30)
    else
        self:setLabelAtlas("txt_vip",data.vip)
        Icon.setHeadIcon(self:getNode("icon"), (data.cid))

        if type == EVENT_ID_RANK_FAMILY_STAGE_HARM then
            self:setLabelString("txt_fname", gGetWords("arenaWords.plist","17",gGetWords("familyMenuWord.plist","title"..data.post)))
        else
            self:replaceLabelString("txt_fname",fname)
        end
        

        if (data.id == Data.getCurUserId()) then
            self:getNode("me"):setVisible(true)
        end
    end
end

return ArenaRankItem