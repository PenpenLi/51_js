local ArenaRecordItem=class("ArenaRecordItem",UILayer)

function ArenaRecordItem:ctor(recordType)
    self.recordType = recordType
end
  

function ArenaRecordItem:onTouchEnded(target)
    if  target.touchName=="btn_replay"then
        if self.recordType == ARENA_RECORD_TYPE then
            Panel.pushRePopupPanel(PANEL_ARENA) 
            Net.sendArenaVideo(self.curData.vid,self.curData.id)
        elseif self.recordType == SERVERBATTLE_RECORD_TYPE then
            -- TODO
            Panel.pushRePopupPanel(PANEL_SERVER_BATTLE_MAIN) 
            Net.sendWorldWarVedio(self.curData.vid,SERVER_BATTLE_RECORD1)
        end
    end
end

function ArenaRecordItem:setData(data)
    self:init("ui/ui_arena_record_item.map")
    if self.recordType == ARENA_RECORD_TYPE then
        self:setArenaData(data)
    elseif self.recordType == SERVERBATTLE_RECORD_TYPE then
        self:setServerBattleData(data)
    end
end

function ArenaRecordItem:setArenaData(data)
    self.curData=data
    self:setLabelString("txt_name",data.name)
    self:replaceLabelString("txt_level",data.level)
    self:setLabelString("txt_rank",data.rank)
    -- print("data.rank="..data.rank)
    self:replaceLabelString("txt_pw",data.pw)
    self:getNode("layout_stars"):setVisible(false)
    if(data.rank<0)then
        self:getNode("icon_up"):setVisible(false)
        self:getNode("icon_down"):setVisible(true)
        self:getNode("txt_rank"):setColor(cc.c3b(137,7,4));
    elseif (data.rank==0) then
        self:getNode("icon_up"):setVisible(false)
        self:getNode("icon_down"):setVisible(false)
        local sWord = gGetWords("arenaWords.plist","rank_no");
        self:setLabelString("txt_rank",sWord)
    else
        self:getNode("icon_up"):setVisible(true)
        self:getNode("icon_down"):setVisible(false)
        self:getNode("txt_rank"):setColor(cc.c3b(60,121,0));
    end

    if (data.win == 1) then
        self:changeTexture("win","images/ui_jingji/shengli.png");
    else
        self:changeTexture("win","images/ui_jingji/shibai.png");
    end

    local timeword = getTimeDiff(data.time);
    self:setLabelString("txt_time",timeword);
    
    -- print("data.cid="..data.cid)
    -- Icon.setIcon(Data.convertToIcon(data.cid),self:getNode("icon2"))
    -- Icon.setIcon(Data.getCurIconFrame(),self:getNode("icon1"))

    if (not data.atk) then
        self:getNode("icon_atk"):setScaleX(-1);
        -- self:getNode("icon_atk"):setRotation(180)
    end

    Icon.setHeadIcon(self:getNode("icon2"), (data.cid))
    Icon.setHeadIcon(self:getNode("icon1"), Data.getCurIconFrame())
end

function ArenaRecordItem:setServerBattleData(data)
    self.curData=data
    self:getNode("icon_up"):setVisible(false)
    self:getNode("icon_down"):setVisible(false)
    self:getNode("txt_rank"):setVisible(false)
    self:getNode("icon_section"):setVisible(true)
    self:setLabelString("txt_name",data.name)
    self:replaceLabelString("txt_level",data.level)
    self:replaceLabelString("txt_pw",data.pw)
    if (data.win == 1) then
        self:changeTexture("win","images/ui_jingji/shengli.png")
    else
        self:changeTexture("win","images/ui_jingji/shibai.png")
    end

    local timeword = getTimeDiff(data.time);
    self:setLabelString("txt_time",timeword)
    if (not data.atk) then
        self:getNode("icon_atk"):setScaleX(-1);
        -- self:getNode("icon_atk"):setRotation(180)
    end

    Icon.setHeadIcon(self:getNode("icon2"), (data.cid))
    Icon.setHeadIcon(self:getNode("icon1"), Data.getCurIconFrame())
    if nil == data.sectionLv or 0 == data.sectionLv then
        self:getNode("icon_section"):setVisible(false)
    else
        Icon.setSecOfSeverBattle(self:getNode("icon_section"),data.sectionLv)
    end

    self:setServerBattleStars(data.sectionLv,data.rank)
end

function  ArenaRecordItem:setLazyData(data)
    self.lazyData=data
    if self.recordType == ARENA_RECORD_TYPE then
        Scene.addLazyFunc(self,function()
            self:setData(self.lazyData)
        end,"arenaRecordItem")
    else
        Scene.addLazyFunc(self,function()
            self:setData(self.lazyData)
        end,"serverbattleRecordItem")
    end
end

function ArenaRecordItem:setServerBattleStars(secLev,rank)
    local secType = DB.getServerBattleSecTypeByLv(secLev)
    if secType == SERVER_BATTLE_DUAN16 then
        self:getNode("layout_stars"):setVisible(false)
        if rank > 0 then
            local labNum = gCreateLabelAtlas("images/ui_num/lv_num.png",36,48,rank,-4,0)
            gAddCenter(labNum, self:getNode("icon_section"))
        end
    else
        local totoalStars = DB.getServerBattleTotalStarsByLv(secType)
        for i = totoalStars + 1, 6 do
            self:getNode("icon_star"..i):setVisible(false)
        end
        local minLv,maxLv   = DB.getServerBattleRangeSecLvByType(secType)
        local noEmptyNum    = secLev - minLv
        for i = 1, totoalStars do
            if i <= noEmptyNum then
                self:changeTexture("icon_star"..i, "images/ui_public1/star_mid.png")
            else
                self:changeTexture("icon_star"..i,"images/ui_public1/star_mid_1.png")
            end
        end
        self:getNode("layout_stars"):layout()
        self:getNode("layout_stars"):setVisible(true)
    end
end

return ArenaRecordItem