local ArenaPanel=class("ArenaPanel",UILayer)
ArenaPanelData = {};
ArenaPanelData.sendUID = 0;

function gShowCloud(callback)
    Scene.setScreenTouchEnable(false);
    loadFlaXml("ui_arena");
    local cloud = gCreateFla("ui_arena_yun",1);
    cloud:setLocalZOrder(10);
    gAddChildInCenterPos(gCurScene,cloud);
    cloud:setAllChildCascadeOpacityEnabled(true);
    cloud:setOpacity(0);
    local actEnd = function()
        Scene.setScreenTouchEnable(true);
    end
    cloud:runAction(cc.Sequence:create(
                        cc.FadeIn:create(0.3),
                        cc.CallFunc:create(callback),
                        cc.FadeOut:create(1.0),
                        cc.CallFunc:create(actEnd),
                        cc.RemoveSelf:create()));    
                        
     
end

function gEnterArena()
    
    local enterArena = function()
        Panel.popUp(PANEL_ARENA)
    end
    gShowCloud(enterArena);

    -- local cloud = gCreateFla("ui_arena_yun_a",0);
    -- cloud:setLocalZOrder(100);
    -- gAddChildInCenterPos(gCurScene,cloud);
    -- gCallFuncDelay(cloud:getActionTime()-1,cloud,enterArena);
    -- local cloudDis = gCreateFlaDelay(cloud:getActionTime()-1.1,"ui_arena_yun_b",1,true);
    -- cloudDis:setLocalZOrder(100);
    -- gAddChildInCenterPos(gCurScene,cloudDis);


    -- local cloud = FlashAniGroup.new();
    -- cloud:addFlashAni("ui_arena_yun_a",false,0,nil,enterArena);
    -- cloud:addFlashAni("ui_arena_yun_b",true,0);
    -- cloud:play();
    -- cloud:setLocalZOrder(100);
    -- gAddChildInCenterPos(gCurScene,cloud);
end

function ArenaPanel:ctor()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_ui_packer_arena.plist");
    self:init("ui/ui_arena.map")

    self.layerCountPos = cc.p(self:getNode("layer_count"):getPosition());
    -- self:getNode("scroll").eachLineNum=1
    -- self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)


    Net.sendArena()
    -- self.isMainLayerGoldShow=false


    local function updateTime()
        -- print("ArenaPanel:updateTime");
        if(gArena.time and gArena.time>0)then
            if(gArena.time>gGetCurServerTime()-gArena.serverTime)then
                self:setLabelString("txt_remain_time", gParserMinTime(gArena.time- ( gGetCurServerTime()-gArena.serverTime) ))
            else
                gArena.time=0
                self:initCount()
            end
        end
    end

    self:scheduleUpdate(updateTime,1)
    self._init = false;
    for i=0,2 do
        self:getNode("boat"..i):setVisible(false);
    end

    self:setTouchCDTime("btn_refresh",1.0);

    Unlock.checkFirstEnter(SYS_ARENA);
    self:getNode("btn_rank"):setVisible(not Module.isClose(SWITCH_VIP))
end

function ArenaPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end


function  ArenaPanel:events()
    return {EVENT_ID_ARENA,
        EVENT_ID_ARENA_RESET_CD,
        EVENT_ID_ARENA_BUY_NUM}
end


function ArenaPanel:dealEvent(event,param)
    if(event==EVENT_ID_ARENA)then
        self:initArena(param)
    elseif(event==EVENT_ID_ARENA_RESET_CD)then
        self.curData.time=0
        self:initCount() 
    elseif(event==EVENT_ID_ARENA_BUY_NUM)then 
        self.curData.count=param
        self:initCount()
    end
end

function ArenaPanel:refreshBoat(index,needAni)

    if needAni then

        local refreshData = function()
            self:refreshBoatData(index);
        end
        local time = 0.35;
        local delaytime = {0,0.1,0.05};
        local boat = self:getNode("boat"..(index-1));
        boat:setAllChildCascadeOpacityEnabled(true);
        if boat:isVisible() == false then
            boat:setOpacity(0);
            boat:runAction(cc.Sequence:create(
                    cc.MoveBy:create(0,cc.p(100,0)),
                    cc.CallFunc:create(refreshData),
                    cc.Show:create(),
                    cc.Spawn:create(
                        cc.FadeIn:create(time),
                        cc.MoveBy:create(time,cc.p(-100,0))
                        )
                ));
        else
            boat:runAction(cc.Sequence:create(
                    cc.Spawn:create(
                        cc.MoveBy:create(time+delaytime[index],cc.p(-100,0)),
                        cc.FadeOut:create(time+delaytime[index])
                        ),
                    cc.MoveBy:create(0,cc.p(200,0)),
                    cc.CallFunc:create(refreshData),
                    cc.Spawn:create(
                        cc.FadeIn:create(time),
                        cc.MoveBy:create(time,cc.p(-100,0))
                        )
                ));    
        end
    else
        self:refreshBoatData(index);
    end
end
function ArenaPanel:refreshBoatData(index)
    -- body
    local var = self.curData.enemys[index]
    self:setLabelAtlas("txt_rank"..(index-1),var.rank);
    self:setLabelString("txt_power"..(index-1),var.price);
    self:setLabelString("txt_name"..(index-1),getLvReviewName("Lv.")..var.level.."  "..var.name);
    
    local fla = gCreateRoleFla(var.cid,self:getNode("bg_role"..(index-1)),0.7,nil,nil,var.show.wlv,var.show.wkn,var.show.halo);
    if fla then
        fla:setScaleX(-0.7);
    end
    -- var.show.hlv = 2;
    if(var.show.hlv)then
        self:getNode("honor_word"..(index-1)):setVisible(var.show.hlv > 0);
        if(var.show.hlv > 0)then
            -- Icon.changeHonorIcon(self:getNode("honor_icon"),var.show.hlv);
            Icon.changeHonorWord(self:getNode("honor_word"..(index-1)),var.show.hlv);
        end
        -- self:resetLayOut();
        self:getNode("layout"..(index-1)):layout();
    end
end

function ArenaPanel:initArena(data)

    self.curData=data
    gUserInfo.arenarank = data.highrank;
    gUserInfo.rank = data.rank;

    if self._init == true then
        for key,var in pairs(data.enemys) do
            if key <= 3 then
                self:refreshBoat(key,true);
            end
        end
        return;
    end

    self._init = true;
    -- print_lua_table(data.enemys);

    for key,var in pairs(data.enemys) do
        if key <= 3 then
            self:refreshBoat(key,true);
            -- self:setLabelAtlas("txt_rank"..(key-1),var.rank);
            -- self:setLabelString("txt_power"..(key-1),var.price);
            -- self:setLabelString("txt_name"..(key-1),"Lv."..var.level.."  "..var.name);
            -- local fla = gCreateRoleFla(var.cid,self:getNode("bg_role"..(key-1)),0.7);
            -- fla:setScaleX(-0.7);
        end
    end

    self:setLabelString("txt_my_name",getLvReviewName("Lv.")..Data.getCurLevel().."  "..gUserInfo.name);
    
    self:setLabelAtlas("txt_my_rank",data.rank);
    gCreateRoleFla(Data.getCurIcon(),self:getNode("bg_my_role"),0.7,nil,nil,Data.getCurWeapon(),Data.getCurAwake(),Data.getCurHalo());
    
    self:initCount()
    self:setLabelString("txt_clearcd_price",Data.arena.clearCDDia);

end
function  ArenaPanel:initCount()
    if(self.curData == nil)then
        return;
    end
    self:setLabelString("txt_fight_num",self.curData.count.."/"..Data.arena.maxTimes)
    self:getNode("layer_count"):setPosition(self.layerCountPos);
    self:getNode("btn_buy"):setVisible(true)
    self:getNode("btn_refresh"):setVisible(true)
    if self.curData.time ~= 0 then
        self:getNode("btn_refresh"):setVisible(false)
        self:getNode("panel_remain_time"):setVisible(true)
        self:getNode("layer_count"):setPosition(cc.p(self.layerCountPos.x - 120,self.layerCountPos.y));
    else
        self:getNode("panel_remain_time"):setVisible(false)
    end
    -- if(self.curData.count==0)then
    --     self:getNode("btn_refresh"):setVisible(false)
    --     self:getNode("panel_remain_time"):setVisible(false)
    -- elseif(self.curData.time~=0)then
    --     self:getNode("btn_refresh"):setVisible(false)
    --     self:getNode("panel_remain_time"):setVisible(true)
    --     self:getNode("layer_count"):setPosition(cc.p(self.layerCountPos.x - 120,self.layerCountPos.y));
    -- else
    --     self:getNode("btn_refresh"):setVisible(true)
    --     self:getNode("panel_remain_time"):setVisible(false)
    -- end
end

function  ArenaPanel:onPopup()

    local formation=Data.getUserTeam(TEAM_TYPE_ARENA_DEFEND) 
    if(NetErr.isTeamEmpty(formation))then 
        formation=clone(Data.getUserTeam(TEAM_TYPE_ATLAS))
        Data.saveUserTeam(TEAM_TYPE_ARENA_DEFEND,formation)
    end  
    for i=0, MAX_TEAM_NUM-1 do
        local data= nil
        if(i==PET_POS)then
            data=  Data.getUserPetById(formation[i])
        else
            data=  Data.getUserCardById(formation[i])
        end
        local node=self:getNode("pos"..i)
        node:removeAllChildren(true)
        if(data)then
            local item=AtlasFormationItem.new(2)
            node:addChild(item)
            item:setTag(i)
            item:setData(data)
            item:setPositionY(node:getContentSize().height)
             
        end
    end
    local totalPower=CardPro.countFormation(formation,TEAM_TYPE_ARENA_DEFEND)
    self:setLabelString("txt_my_power",totalPower);
end

function ArenaPanel:onTouchEnded(target)
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())

    elseif  target.touchName=="btn_refresh"then
        Net.sendArena()
    elseif  target.touchName=="btn_edit"then
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ARENA_DEFEND)

    elseif  target.touchName=="btn_rank"then
        Panel.popUp(PANEL_ARENA_RANK,2)
    elseif  target.touchName=="btn_log"then
        -- Panel.popUp(PANEL_ARENA_RECORD)
        Net.sendArenaRecord()
    elseif  target.touchName=="btn_rule"then
        Panel.popUp(PANEL_ARENA_RULE)
    elseif  target.touchName=="btn_exchange"then
        Panel.popUpVisible(PANEL_SHOP,SHOP_TYPE_ARENA)
    elseif  target.touchName=="btn_reset_time"then
        Net.sendArenaClearCd()
    elseif  target.touchName=="btn_buy"then
        local callback = function(num)
            Net.sendArenaBuyNum(num);
        end
        Data.canBuyTimes(VIP_ARENA,true,callback);
    elseif target.touchName == "touch_role0" then
        if table.getn(self.curData.enemys) > 0 then
            Net.sendArenaCardInfo(self.curData.enemys[1]);
        end    
    elseif target.touchName == "touch_role1" then
        if table.getn(self.curData.enemys) > 1 then
            Net.sendArenaCardInfo(self.curData.enemys[2]);
        end  
    elseif target.touchName == "touch_role2" then
        if table.getn(self.curData.enemys) > 2 then
            Net.sendArenaCardInfo(self.curData.enemys[3]);
        end          
    end


end



return ArenaPanel