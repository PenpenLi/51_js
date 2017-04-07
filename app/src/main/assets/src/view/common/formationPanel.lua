local FormationPanel =class("FormationPanel",UILayer)

local panelTypeNormal = 0
local panelTypeSeverBattle = 1
local panelTypeTreasureHunt = 2
local panelTypeLootFood = 3

function FormationPanel:ctor(data,panelType)
    self.appearType = 1;
    self._panelTop=true;
    self:init("ui/tip_formation.map")
    self.curData = data;
    self.panelType = panelType
    self:setLabelString("txt_name",data.name)
    if(data.fname == nil or data.fname == "")then
        data.fname = gGetWords("arenaWords.plist","lab_no");
    end
    if data.fname == "" then
        local txt_no = gGetWords("trainWords.plist","no_family")
        self:setLabelString("txt_fname",txt_no)
    else
        self:setLabelString("txt_fname",data.fname)
    end
    
    self:setLabelString("txt_level",data.lv)
    self:setLabelString("txt_win",data.win)
    self:setLabelString("txt_power",data.price)
    self:setLabelString("txt_rank",data.rank)
    if nil ~= data.vip then
        self:setLabelAtlas("txt_vip",data.vip)
    end

    if nil ~= data.sname then
        self:setLabelString("txt_sname", data.sname)
    end

    gCreateRoleFla(Data.convertToIcon(data.icon), self:getNode("bg_role"),0.7,nil,nil,data.show.wlv,data.show.wkn);

    -- data.show.hlv = 2;
    if(data.show.hlv)then
        if(data.show.hlv and data.show.hlv > 0)then
            Icon.changeHonorIcon(self:getNode("honor_icon"),data.show.hlv);
            Icon.changeHonorWord(self:getNode("honor_word"),data.show.hlv);
        end
        self:getNode("layer_honor"):setVisible(data.show.hlv > 0);
    end

    if(data.team.clist)then
        for key,card in pairs(data.team.clist) do
            local node = self:getNode("card"..card.pos);
            local item = FormationCardItem.new(card);
            node:setOpacity(0);
            gAddChildByAnchorPos(node,item,cc.p(0,1));
        end
    end

    if data.team.pid and data.team.pid > 0 then
        local node = self:getNode("card6");
        local item = FormationCardItem.new({isPet=true,cid=data.team.pid,lv=data.team.plv,gd=data.team.pgd,qlt=0,awakeLv=data.team.pawakeLv});
        node:setOpacity(0);
        gAddChildByAnchorPos(node,item,cc.p(0,1));
    end

    -- for key, card in pairs(data.cards) do
    --     local node=self:getNode("card"..(key+1))
    --     local item=AtlasFormationItem.new(2)
    --     node:addChild(item)
    --     item:setData(card)
    --     -- item:setPositionY(node:getContentSize().height)
    -- 

    local inArean = false;
    if Panel.getPanelByType(PANEL_ARENA) then
        inArean = true;
    end

    self:getNode("btn_fight"):setVisible(inArean);
    self:initPanel(panelType);

    self:hideCloseModule();
end
function FormationPanel:hideCloseModule()
    if(self:getNode("bg_vip"):isVisible()) then
        self:getNode("bg_vip"):setVisible(not Module.isClose(SWITCH_VIP));
        self:getNode("bg_vip"):setVisible(false)
    end
end

function FormationPanel:onTouchEnded(target)
    if target.touchName == "btn_fight" then
        if self.panelType == panelTypeLootFood then
            if Net.lootfoodinfo.lootnum < 1 then
                Data.vip.lootfood.setUsedTimes(Net.lootfoodinfo.lootbuy);
                local callback = function(num)
                    Net.sendLootfoodBuyloot(num)
                end
                Data.canBuyTimes(VIP_LOOT_FOOD,true,callback);
                return
            end
            local param = {}
            param.uid = self.curData.uid
            param.sid = self.curData.sid
            Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_LOOT_FOOD,param)
            return
        elseif(NetErr.arenaFight()==false)then
            return
        end 
        local param={}
        param.rank=self.curData.rank
        param.id=self.curData.uid
        param.rid=0
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ARENA_ATTACK,param)
    else
        Panel.popBack(self:getTag())
    end

end

function FormationPanel:initPanel(panelType)
    if panelType == nil then
        panelType = panelTypeNormal
    end

    if panelType == panelTypeSeverBattle then
        self:getNode("title_rank"):setVisible(false)
        self:getNode("txt_rank"):setVisible(false)
        self:getNode("bg_vip"):setVisible(false)
        self:getNode("layer_txt_sname"):setVisible(true)
    elseif panelType == panelTypeTreasureHunt then
        self:getNode("title_rank"):setVisible(false)
        self:getNode("txt_rank"):setVisible(false)
        self:getNode("layer_txt_sname"):setVisible(true)
    elseif panelType == panelTypeLootFood then
        -- 当前排名
        self:setLabelString("title_sname",gGetWords("lootFoodWords.plist","userinfo_rank"))
        self:setLabelString("txt_sname",self.curData.rank)
        self:getNode("title_sname"):getParent():layout()
        -- 战胜可得粮草
        self:setLabelString("title_rank","")
        self:setLabelString("txt_rank",gGetWords("lootFoodWords.plist","userinfo_win_get",self.curData.addfood))
        self:getNode("title_rank"):getParent():layout()

        self:getNode("btn_fight"):setVisible(true)
    else
        self:getNode("title_rank"):setVisible(true)
        self:getNode("txt_rank"):setVisible(true)
        self:getNode("bg_vip"):setVisible(false)
        self:getNode("layer_txt_sname"):setVisible(false)
    end

    if Net.sendBuddyTeamType == TEAM_TYPE_CAVE then
        self:setLabelString("title_rank",gGetWords("arenaWords.plist","teamType"..Net.sendBuddyTeamType))
    end
    self:resetLayOut();
end

return FormationPanel