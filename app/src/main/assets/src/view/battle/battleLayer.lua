local BattleLayer=class("BattleLayer",UILayer)

gPreLoadFiles={}

SKILL_TARGET_SELF=1   ---实际目标--本身
SKILL_TARGET_OTHER=2   ---实际目标--对方
SKILL_TARGET_ALL=3     ---全屏
SKILL_TARGET_COL_LINE=4   ---贯穿
SKILL_TARGET_ROW_LINE=5  ---横扫

ACTION_TAG_CAMERA=1
ACTION_TAG_SHAKE=2

TOUCH_MIN_FRAME=25
TOUCH_MAX_FRAME=35
TOUCH_MISS_FRAME=45

function BattleLayer:ctor()

    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist")
    self.deadList={}
    self.escapeList={}
    self:init("ui/battle.map")
    self:getNode("btn_skip"):setVisible(false)
    self:getNode("panel_name1"):setVisible(false)
    self:getNode("panel_name2"):setVisible(false)
    self:getNode("btn_close"):setVisible(false)
    self:getNode("layer_mine_atlas_ret"):setVisible(false)
    self.myRoles={}
    self.otherRoles={}
    self.battleActions={}
    self:initBg()
    self.dropBoxNum=0
    self.totalDieNum=0
    self.totalDieNumDelay=0
    self.totalSendDieNum=0
    self.totalReliveNum=0
    self.totalReliveNumDelay=0
    self.curSpeedScale=1
    self.roleLines={}
    self.tmpCount = 1
    self.battleFinish = false
    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)
    self.initX=self:getNode("battle"):getPositionX()
    self.initY=self:getNode("battle"):getPositionY()

    self:getNode("shake_container").initX=self:getNode("shake_container"):getPositionX()
    self:getNode("shake_container").initY=self:getNode("shake_container"):getPositionY()
    self:setPlay()
    self:getNode("battle_data_panel"):setVisible(false)
    self:setLabelString("txt_skip","")
    self:showGroup(Battle.curBattleGroup)

    self:initBattleInfo()


    self:initRole()
    self:showConstellationFla()
    local function updateTime()

        if(self.isFirstUpdate~=true)then
            self.isFirstupdate=true
            self:getNode("reward_icon"):pause()
            self:getNode("icon_box"):pause()
        end

        self:updateBattleInfo()
        self:updateSkillTargetTime()
    end
    self.blackBg=cc.LayerColor:create(cc.c4b(0,0,0,255),winSize.width*2.5,winSize.height*2.5)
    self.blackBg:setPositionY(-winSize.height*2+winSize.height/4)
    self.blackBg:setPositionX( -winSize.width/2)
    self:getNode("role_container"):addChild(self.blackBg)
    self.blackBg:setVisible(false)
    self.blackBg.retainNum=0
    self:getNode("touch_mode"):setVisible(false)

    self:scheduleUpdateWithPriorityLua(updateTime,1)



    for i=1, 5 do
        local oldX,oldY=   self:getNode("icon_group"..i):getPosition()
        self:getNode("icon_group"..i).oldX=oldX
        self:getNode("icon_group"..i).oldY=oldY
    end



    self:getNode("skill_target_panel").oldX=self:getNode("skill_target_panel"):getPositionX()
    self.timeBar=cc.ProgressTimer:create(cc.Sprite:create("images/ui_lingshou/time_di2.png"))
    gAddCenter(self.timeBar,  self:getNode("panel_second"))
    self.timeBar:setScale(0.8)
    self.timeBar:setLocalZOrder(2)

    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        end
    end
    self:registerScriptHandler(onNodeEvent);
    gSetIdleTimerDisabled(true,false)
    --  Unlock.system.battleAuto.guide()

    self.lastDiffTime = nil




end

function BattleLayer:isFirstBattle()
    if(Battle.battleType==BATTLE_TYPE_GUIDE and Net.sendAtlasEnterParam==nil)then
        return true
    end
    return false
end

function BattleLayer:initGuideState()

    if( Battle.battleType==BATTLE_TYPE_ATLAS or Battle.battleType==BATTLE_TYPE_GUIDE )then

        if( Net.sendAtlasEnterParam )then
            local mapid= Net.sendAtlasEnterParam.mapid
            local stageid=Net.sendAtlasEnterParam.stageid
            local type=Net.sendAtlasEnterParam.type
            if( Data.isFirstEnterAtlas( mapid, stageid, type))then
                if(type==0 and mapid==1 )then
                    if(stageid<=1)then
                        self:getNode("btn_speed"):setVisible(false)
                    end

                    if(stageid<=3)then
                        self:getNode("auto_panel"):setVisible(false)
                    end
                end
                self.firstMapid=mapid
                self.firstStageid=stageid
                self.firstType=type
            end
        end
    end

end


function BattleLayer:changeIconType(name,type)
    local btn=self:getNode(name)
    if(btn)then
        if(type==OPEN_BOX_DIAMOND)then
            btn:replaceBone({"icon"},"images/ui_public1/gold.png")
        elseif(type==OPEN_BOX_GOLD)then
            btn:replaceBone({"icon"},"images/ui_public1/coin.png")
        elseif(type==OPEN_BOX_EXP)then
            btn:replaceBone({"icon"},"images/icon/item/20.png")
        elseif(type==OPEN_BOX_PET_SOUL)then
            btn:replaceBone({"icon"},"images/icon/sep_item/90016.png")
        elseif(type==OPEN_BOX_EQUIP_SOUL)then
            btn:replaceBone({"icon"},"images/icon/sep_item/"..OPEN_BOX_EQUIP_SOUL..".png")
        elseif(type==OPEN_BOX_CARDEXP_ITEM)then
            btn:replaceBone({"icon"},"images/icon/sep_item/90017.png")
        elseif(type==OPEN_BOX_FEAT)then
            btn:replaceBone({"icon"},"images/icon/sep_item/95002.png")
        elseif(type==OPEN_BOX_ITEMAWAKE)then
            btn:replaceBone({"icon"},"images/icon/item/42.png")
        end
    end
end


function BattleLayer:initBattleInfo()
    self:getNode("data_panel"):setVisible(false)
    self:getNode("box_panel"):setVisible(false)
    self:getNode("round_panel"):setVisible(false)
    self:getNode("arean_panel"):setVisible(false)

    gPlayMusic("bg/bgm_fight.mp3")
    self:setLabelString("txt_round",  "1/"..MAX_ROUND)
    self:setLabelString("txt_round2",  "1/"..MAX_ROUND)
    self:setLabelString("txt_round3",  "1/"..MAX_ROUND)

    if( Battle.battleType==BATTLE_TYPE_ATLAS_GOLD or
        Battle.battleType==BATTLE_TYPE_ATLAS_EXP or
        Battle.battleType==BATTLE_TYPE_ATLAS_PET or
        Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL or
        Battle.battleType==BATTLE_TYPE_ATLAS_ITEMAWAKE)then
        self:getNode("data_panel"):setVisible(true)

        if( Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL)then
            self:getNode("round_panel"):setVisible(true)
            self:getNode("bar_bg"):setVisible(false)
            self:getNode("txt_round2"):setVisible(false)

        end

        self.stageInfo=DB.getActStageInfoById( Net.sendAtlasEnterParam.type,Net.sendAtlasEnterParam.stageid)
        self:setBattleSkipData("BATTLE_SKIP_ATLAS_ACTIVITY")
    elseif( Battle.battleType==BATTLE_TYPE_ARENA or
        Battle.battleType==BATTLE_TYPE_CAVE_CHALLENGE or
        Battle.battleType==BATTLE_TYPE_ARENA_LOG  or
        Battle.battleType==BATTLE_TYPE_BATH or
        Battle.battleType==BATTLE_TYPE_TRAIN or
        Battle.battleType==BATTLE_TYPE_SERVER_BATTLE or
        Battle.battleType==BATTLE_TYPE_SERVER_BATTLE_LOG or
        Battle.battleType==BATTLE_TYPE_FAMILY_STAGE  )then

        if( Battle.brief and Battle.brief.n1  and string.len(Battle.brief.n1)~=0 )then
            self:getNode("panel_name1"):setVisible(true)
            self:getNode("panel_name2"):setVisible(true)
            self:setLabelString("txt_name1",Battle.brief.n1)
            self:setLabelString("txt_name2",Battle.brief.n2)
        end

        self:getNode("arean_panel"):setVisible(true)
        self:setLabelString("txt_power1",  gBattleData.power1)
        self:setLabelString("txt_power2",  gBattleData.power2)

        if(gBattlePowerDownPercent1>0)then
            self:getNode("icon_down1"):setVisible(true)
            self:setLabelString("txt_down1",gBattlePowerDownPercent1.."%");
        end


        if(gBattlePowerDownPercent2>0)then
            self:getNode("icon_down2"):setVisible(true)
            self:setLabelString("txt_down2",gBattlePowerDownPercent2.."%");
        end

        self:getNode("icon_power1"):setVisible(false)
        self:getNode("icon_power2"):setVisible(false)
        if(gBattleData.power1 and gBattleData.power2)then
            if(gBattleData.power1>=gBattleData.power2)then
                self:getNode("icon_power1"):setVisible(true)
            else
                self:getNode("icon_power2"):setVisible(true)
            end
        end
        if(Battle.battleType==BATTLE_TYPE_ARENA or Battle.battleType==BATTLE_TYPE_CAVE_CHALLENGE)then
            self:setBattleSkipData("BATTLE_SKIP_ARENA")
        elseif(Battle.battleType==BATTLE_TYPE_TRAIN)then
            self:setBattleSkipData("BATTLE_SKIP_DRINK")
        elseif(Battle.battleType==BATTLE_TYPE_BATH)then
            self:setBattleSkipData("BATTLE_SKIP_BATH")
        elseif(Battle.battleType==BATTLE_TYPE_ARENA_LOG or Battle.battleType==BATTLE_TYPE_SERVER_BATTLE_LOG)then
            self:setBattleSkipData("BATTLE_SKIP_LOG")
        elseif(Battle.battleType==BATTLE_TYPE_SERVER_BATTLE)then
            self:setBattleSkipData("BATTLE_SKIP_WORLD_WAR")
            --弹框加暂停
            -- Panel.popUpVisible(PANEL_SERVER_BATTLE_BASIC_INFO,nil,nil,true)
        elseif(Battle.battleType==BATTLE_TYPE_FAMILY_STAGE)then
            self:setBattleSkipData("BATTLE_SKIP_FAMILY_STAGE")
            self:getNode("layout_power1"):setVisible(false)
            self:getNode("layout_power2"):setVisible(false)
            self:getNode("icon_power1"):setVisible(false)
            self:getNode("icon_power2"):setVisible(false)
        end

        self:getNode("layout_power1"):layout()
        self:getNode("layout_power2"):layout()
    elseif( Battle.battleType==BATTLE_TYPE_TOWER)then

        self:setBattleSkipData("BATTLE_SKIP_TREASURE")
        self:getNode("round_panel"):setVisible(true)
    elseif( Battle.battleType==BATTLE_TYPE_CRUSADE)then
        self:getNode("data_panel"):setVisible(true)
        self:setBattleSkipData("BATTLE_SKIP_CRUSADE")
    elseif( Battle.battleType==BATTLE_TYPE_WORLD_BOSS)then
        if(Data.getCurVip()>= DB.getClientParam("BATTLE_SKIP_WORLDBOSS_VIP"))then
            self.skipTotalTime=DB.getClientParam("BATTLE_SKIP_WORLDBOSS_TIME")
            self.skipServerTime=gGetCurServerTime()
        end
        self:getNode("data_panel"):setVisible(true)
        --
    elseif( Battle.battleType==BATTLE_TYPE_MINING_STATUS) then
        -- self:getNode("data_panel"):setVisible(true)
        self:setBattleSkipData("BATTLE_SKIP_MINE_BOSS")
    elseif (Battle.battleType == BATTLE_TYPE_MINING_ATLAS) then
        self:getNode("layer_mine_atlas_ret"):setVisible(true)
        self:getNode("round_panel"):setVisible(true)
        self:initMiningAtalsRetInfo()
    elseif( Battle.battleType==BATTLE_TYPE_CONSTELLATION) then
        self:setBattleSkipData("BATTLE_SKIP_CONSTELLATION")
    else
        if(Net.sendAtlasEnterParam and Net.sendAtlasEnterParam.type==ATLAS_TYPE_BOSS)then
            local status=Data.getAtlasStatus(Net.sendAtlasEnterParam.mapid,Net.sendAtlasEnterParam.stageid,Net.sendAtlasEnterParam.type)
            if(status~=false and  status.num==3)then
                self:setBattleSkipData("BATTLE_SKIP_BOSS_ATLAS")
            end
        end
        self:setLabelString("txt_test",gBattlePowerRate)
        self:getNode("round_panel"):setVisible(true)
        self:getNode("box_panel"):setVisible(true)
        --  self:setBattleSkipData("BATTLE_SKIP_LOG")
    end

    local showSkipBtn = false
    local function isShowSkipBtnType()
        local show = false
        if(Net.sendAtlasEnterParam and (Net.sendAtlasEnterParam.type==0 or Net.sendAtlasEnterParam.type==1))then
            show =true
        end
        if Battle.battleType==BATTLE_TYPE_ATLAS_PET_TOWER then
            show =true
        end
        return show
    end
    if Data.isShowAct81hd() and isShowSkipBtnType() then
        showSkipBtn = true
    end
    if(showSkipBtn == true or gAccount:isGm())then
        self.skipServerTime=gGetCurServerTime()
        self.skipTotalTime=0
        self:getNode("btn_skip"):setVisible(true)

    end
end

function BattleLayer:setBattleSkipData(id)
    local vip,level,time= DB.getBattleSkip(id)
    self.skipTotalTime=time
    self.skipLevel=level
    self.skipVipLevel=vip
    if(gUserInfo.level>=self.skipLevel)then
        self.skipTotalTime=0
        self:getNode("btn_skip"):setVisible(true)
    end

    if(Data.getCurVip() >=self.skipVipLevel)then
        self.skipTotalTime=0
        self:getNode("btn_skip"):setVisible(true)
    end

    if(Module.isClose(SWITCH_VIP))then
        self.skipTotalTime=0
    end
    self.skipServerTime=gGetCurServerTime()
end

function BattleLayer:setBossBarBg()
    -- print("-----------"..gGetCurServerTime())
    local di1 = "images/ui_fight/shilian_headdi1.png"
    local di4 = "images/ui_fight/shilian_headdi4.png"
    local hp = (gFloor2Point(self:getOtherRolesCurHp()/self.totalInitHp2))
    -- local index = 1
    if (hp<=5) then
        self.tmpCount = self.tmpCount + 1
        if (self.tmpCount<5) then
            self:changeTexture("bar_bg",di1);
        elseif (self.tmpCount>=5 and self.tmpCount<10) then
            self:changeTexture("bar_bg",di4);
        else
            self.tmpCount = 0
        end
    else
        self:changeTexture("bar_bg",di1);
    end
end

function BattleLayer:updateBattleInfo()
    local showEnemyHp=false
    if( Battle.battleType==BATTLE_TYPE_ATLAS_EXP)then
        self:changeRewardNum(gCalAtlasHpReward(self:getTotalReduceHp(2),self.stageInfo))
        showEnemyHp=true
    elseif(  Battle.battleType==BATTLE_TYPE_ATLAS_GOLD)then
        self:changeRewardNum(gCalAtlasHpReward(self:getTotalReduceHp(2),self.stageInfo))
        showEnemyHp=true
    elseif(  Battle.battleType==BATTLE_TYPE_ATLAS_ITEMAWAKE)then
        self:changeRewardNum(gCalAtlasHpReward(self:getTotalReduceHp(2),self.stageInfo))
        showEnemyHp=true
        --器灵试炼
    elseif(  Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL)then
        self:changeRewardNum(gCalAtlasDeadReward(self.totalDieNumDelay,self.stageInfo))

    elseif( Battle.battleType==BATTLE_TYPE_CRUSADE)then
        self:changeRewardNum(math.floor((self:getTotalReduceHp(2)-self.totalLastHp2)/toint(DB.getClientParam("CRUSADE_DAMAGE_FEATS_RATE"))))
        showEnemyHp=true
    elseif( Battle.battleType==BATTLE_TYPE_WORLD_BOSS)then
        if self.battleFinish == true and Data.worldBossInfo.bosstype == 1 then
            self:changeRewardNum(Data.worldBossInfo.goldReword)
        else
            self:changeRewardNum(gCalWorldBossHpReward(self:getTotalReduceHp(2)-self.totalLastHp2))
        end

        -- showEnemyHp=true

        if (gFloor2Point(self:getOtherRolesCurHp()/self.totalInitHp2)>5) then
            self:setLabelString("txt_total_hp",gFloor2Point(self:getOtherRolesCurHp()/self.totalInitHp2).."%")
        else
            self:setLabelString("txt_total_hp","")
        end
        self:setBarPer("bar_monster",self:getOtherRolesCurHp()/self.totalInitHp2,true)
        self:setBarPerAction("bar_monster2",nil,self:getOtherRolesCurHp()/self.totalInitHp2,nil,true)

        self:setBossBarBg()

    elseif(  Battle.battleType==BATTLE_TYPE_ATLAS_PET)then
        self:changeRewardNum(gCalAtlasDeadReward(self.totalDieNumDelay,self.stageInfo))
        if(self.stageInfo)then
            local maxDieNum=self.stageInfo.itemmax/self.stageInfo.dmgparam
            local remainDieNum=maxDieNum-self.totalDieNum
            if(remainDieNum<0)then
                remainDieNum=0
            end
            self:setLabelString("txt_total_hp",remainDieNum.."/"..maxDieNum)
            self:setBarPer("bar_monster",remainDieNum/maxDieNum,true)
            self:setBarPerAction("bar_monster2",nil,remainDieNum/maxDieNum,nil,true)
        end
    elseif( Battle.battleType==BATTLE_TYPE_ARENA or
        Battle.battleType==BATTLE_TYPE_CAVE_CHALLENGE or
        Battle.battleType==BATTLE_TYPE_ARENA_LOG or
        Battle.battleType==BATTLE_TYPE_BATH or
        Battle.battleType==BATTLE_TYPE_TRAIN or
        Battle.battleType==BATTLE_TYPE_SERVER_BATTLE or
        Battle.battleType==BATTLE_TYPE_SERVER_BATTLE_LOG or
        Battle.battleType==BATTLE_TYPE_FAMILY_STAGE
        )then

        self:setBarPer("bar_out_1",self:getMyRolesCurHp()/self.totalInitHp1,true)
        self:setBarPerAction("bar_in_1",nil,self:getMyRolesCurHp()/self.totalInitHp1,nil,true)

        self:setBarPer("bar_out_2",self:getOtherRolesCurHp()/self.totalInitHp2,false)
        self:setBarPerAction("bar_in_2",nil,self:getOtherRolesCurHp()/self.totalInitHp2,nil,false)
    elseif (Battle.battleType == BATTLE_TYPE_MINING_ATLAS) then
        self:updateMiningAtlasRetInfo()
    end

    if(showEnemyHp)then
        self:setLabelString("txt_total_hp",self:getOtherRolesCurHp().."/"..self.totalInitHp2)
        self:setBarPer("bar_monster",self:getOtherRolesCurHp()/self.totalInitHp2,true)
        self:setBarPerAction("bar_monster2",nil,self:getOtherRolesCurHp()/self.totalInitHp2,nil,true)
    end
end

function BattleLayer:updateSkillTargetTime()
    if(self.skillTargetTime and self.skillTargetTime>0)then
        if(self.skillTargetTime>gGetCurServerTime()-self.skillTargetServerTime)then
            local leftTime=(self.skillTargetTime- ( gGetCurServerTime()-self.skillTargetServerTime) )
            self:setLabelString("txt_time", leftTime )

        else
            if(self.isSelecting)then
                gIsSkinAttack=true
                gBattleSelectRoles={}
                self:unSetSelectMode()
            end
        end
    end

    if( self.skipTotalTime and  self.skipTotalTime>0)then
        self:getNode("btn_skip"):setVisible(true)
        if(self.skipTotalTime>gGetCurServerTime()-self.skipServerTime)then
            local leftTime=(self.skipTotalTime- ( gGetCurServerTime()-self.skipServerTime) )
            self:setLabelString("txt_skip", leftTime )
        else
            self.skipTotalTime=nil
            self:setLabelString("txt_skip", "" )
        end
    else
        self:setLabelString("txt_skip", "" )
    end
end
function BattleLayer:onEnter()
    -- body
    local auto =cc.UserDefault:getInstance():getIntegerForKey("battle_auto",0)
    if(gIsBattleVideo)then
        auto=1
    end
    if(self:isGuideManual())then
        auto=0
    end


    local speed =cc.UserDefault:getInstance():getIntegerForKey("battle_speed",1)
    if(self:isFirstBattle())then
        self:setSpeed(1)
        self:getNode("ui_panel"):setVisible(false)
        if (TDGAMission) then
            gLogMissionBegin("battle_guide")
        end
        self:getNode("btn_close"):setVisible(true)
    else
        self:setSpeed(speed)
    end
    local td_param = {}
    td_param['battle_type'] = tostring(Battle.battleType)
    if(auto==1)then
        self:setAuto()
        gLogEvent("auto_battle",td_param)
    else
        self:setManual()
        gLogEvent("manual_battle",td_param)
    end
    self:initGuideState()
    self:checkPauseStatus();
end

function BattleLayer:changeRewardNum(newNum)
    local curNum= self:getNode("txt_total_reward").curNum
    if(curNum==nil)then
        curNum=-1
    end
    if(curNum==newNum)then
        return
    end
    self:getNode("reward_icon").curAction=""
    self:getNode("reward_icon"):resume()
    self:getNode("reward_icon"):playAction("ui_fight_icontan_icon",nil,nil,0)

    if( Battle.battleType==BATTLE_TYPE_CRUSADE)then
        self:changeIconType("reward_icon",OPEN_BOX_FEAT)
    elseif( Battle.battleType==BATTLE_TYPE_ATLAS_GOLD or Battle.battleType==BATTLE_TYPE_WORLD_BOSS)then
        self:changeIconType("reward_icon",OPEN_BOX_GOLD)
    elseif( Battle.battleType==BATTLE_TYPE_ATLAS_EXP)then
        self:changeIconType("reward_icon",OPEN_BOX_EXP)
    elseif( Battle.battleType==BATTLE_TYPE_ATLAS_PET)then
        self:changeIconType("reward_icon",OPEN_BOX_PET_SOUL)
    elseif( Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL)then
        self:changeIconType("reward_icon",OPEN_BOX_EQUIP_SOUL)
    elseif( Battle.battleType==BATTLE_TYPE_ATLAS_ITEMAWAKE)then
        self:changeIconType("reward_icon",OPEN_BOX_ITEMAWAKE)
    end


    self:getNode("txt_total_reward").curNum=newNum
    self:updateLabelChange("txt_total_reward",curNum,newNum)
end

function BattleLayer:getOtherRolesCurHp()
    local ret=0
    --我方角色
    for key, var in pairs(self.otherRoles) do
        ret=ret+var.bloodNode.curRed
    end

    return ret

end

function BattleLayer:getMyRolesCurHp()
    local ret=0
    --我方角色
    for key, var in pairs(self.myRoles) do
        ret=ret+var.bloodNode.curRed
    end

    return ret

end

function  BattleLayer:initTotalHp()

    self.totalInitHp2=0
    self.totalInitHp1=0

    for key, var in pairs(self.myRoles) do
        self.totalInitHp1=self.totalInitHp1+var.hpInit
    end



    for key, var in pairs(self.otherRoles) do
        self.totalInitHp2=self.totalInitHp2+var.hpInit
    end

    self.totalLastHp1=self:getTotalReduceHp(1)
    self.totalLastHp2=self:getTotalReduceHp(2)

end



function BattleLayer:setSpeed(speed,isShowNotice)

    if isShowNotice == nil then
        isShowNotice = false;
    end

    local speeds={1.2,1.7,2.0}

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then
        speeds={1.2,1.4,1.6}
    end
    speed = Unlock.system.battleSpeedUp.checkSpeed(speed,isShowNotice);
    self:changeTexture("btn_speed","images/ui_fight/x"..speed..".png")
    self.curSpeed=speed
    cc.Director:getInstance():getScheduler():setTimeScale(speeds[speed]*self.curSpeedScale)
    cc.UserDefault:getInstance():setIntegerForKey("battle_speed",speed)
    cc.UserDefault:getInstance():flush()
    self:setPlay()
end

function BattleLayer:setSpeedScale(scale)
    self.curSpeedScale=scale
    self:setSpeed(self.curSpeed)
end

function BattleLayer:getGuideItem(name)
    local params= string.split(name,"_")
    if(toint(params[1])==1)then
        if(self.myRoles[toint(params[2])])then
            return self.myRoles[toint(params[2])].touchNode
        end
    elseif(toint(params[1])==2)then
        if(self.otherRoles[toint(params[2])])then
            return self.otherRoles[toint(params[2])].touchNode

        end
    elseif(name=="touchScaleNode")then
        return self[name]

    end

    return nil
end


function BattleLayer:onOtherRoleDie(role)
    if(Battle.dropNum[Battle.curBattleGroup]==nil or
        Battle.dropedNum[Battle.curBattleGroup]==nil)then
        return
    end

    local remainNum=Battle.dropNum[Battle.curBattleGroup]- Battle.dropedNum[Battle.curBattleGroup]
    if(self:isAllDead(2))then
        role:dropItem(remainNum)
        Battle.dropedNum[Battle.curBattleGroup]=Battle.dropNum[Battle.curBattleGroup]
        return
    end

    local dropNum=getRand(0,remainNum)
    role:dropItem(dropNum)
    Battle.dropedNum[Battle.curBattleGroup]=Battle.dropedNum[Battle.curBattleGroup]+dropNum
end


function BattleLayer:playAppear()
    self:startAppear()
end

function BattleLayer:startAppear()
    self:hideAllBlood()
    if( Battle.battleType==BATTLE_TYPE_ATLAS_PET_TOWER and Battle.curBattleGroup~=1)then
        local function callback()
            self.bg:playAction(self.bg.url)
        end
        self.bg:playAction(self.bg.url.."_change",callback)
        self:shake(10,20,1)
        self:appearSide(2,1)
    else
        self:appearSide(1)
    end

end


function BattleLayer:clearHit()
    -- self:getNode("hit_container"):removeAllChildren()
    self.hitNum=0
end
function BattleLayer:addHit()
    if(self.hitNum==nil)then
        self.hitNum=0
    end
    self.hitNum=self.hitNum+1
    local fla=gCreateFla("ui_coop_togather_hit")
    local numNode= gCreateLabelAtlas("images/ui_num/hit_num.png",60,74,self.hitNum,0,0);
    fla:replaceBoneWithNode({"num"},numNode)


    local children = self:getNode("hit_container"):getChildren()
    if children  then
        for i,v in ipairs(children) do
            if(v:getActionByTag(1)==nil)then
                local action=cc.ScaleTo:create(0.2,0)
                action:setTag(1)
                v:runAction(action)
            end
        end
    end


    self:getNode("hit_container"):addChild(fla)
end

function BattleLayer:playDisappear()
    self:hideAllBlood()
    self.isDisappearing=true
    local  function  onDisAppeared()
        self.isDisappearing=false
        self:nextGroup()
    end


    if( Battle.battleType==BATTLE_TYPE_ATLAS_PET_TOWER)then
        self:runAction(cc.Sequence:create( cc.DelayTime:create(1.0), cc.CallFunc:create(onDisAppeared)))
        return
    end

    local roles=self.myRoles
    local  frontDis=1100


    local delayTime=0
    for key, role in pairs(roles) do
        role:stopMoveAction()
        role.isPauseMove=false
        role:resetRoleState()
        role:playAction(role:getRunActionName())

        local speed=0.9
        if(gCardRunSpeed["r"..role.curCardid])then
            speed=speed*tonum(gCardRunSpeed["r"..role.curCardid])
        end
        role:moveActionByTag(  1/speed,cc.p(role.initX+frontDis,role.initY),nil,3)

        if(1/speed>delayTime)then
            delayTime=1/speed
        end
    end
    self:runAction(cc.Sequence:create( cc.DelayTime:create(delayTime), cc.CallFunc:create(onDisAppeared)))


end







function BattleLayer:nextGroup()
    gResetBattleGroupData()
    self.helpRole=nil
    gBattleData=Battle.enterAtlasNextGroup(Battle.curBattleGroup+1)
    for key, var in pairs(self.myRoles) do
        var.bloodNode:removeFromParent()
        var:removeFromParent()
    end



    for key, var in pairs(self.otherRoles) do
        var.bloodNode:removeFromParent()
        var:removeFromParent()
    end

    self.deadList={}
    self.escapeList={}
    self.battleActions={}
    self:initRole()
    self:startAppear()
    self:showGroup(Battle.curBattleGroup)


end

function BattleLayer:getRoleById(side,id)

    local roles={}
    if(side==1)then
        roles=self.myRoles
    else
        roles=self.otherRoles
    end


    for key, role in pairs(roles) do
        if(role.curCardid==id)then
            return role
        end
    end
    return nil
end

function BattleLayer:playWin(side)
    local roles={}
    if(side==1)then
        roles=self.myRoles
    else
        roles=self.otherRoles
    end


    for key, role in pairs(roles) do
        role:playWin()
    end
end

function BattleLayer:isAllDead(side)
    local roles={}
    if(side==1)then
        roles=self.myRoles
    else
        roles=self.otherRoles
    end


    local isAllDead=true
    for key, role in pairs(roles) do
        if(role:isPet()==false)then

            if(role.isDead~=true  )then
                isAllDead=false
            end
        end
    end


    if isAllDead ==false then
        if side==1 then
            isAllDead = (self:getMyRolesCurHp()==0)
        else
            isAllDead = (self:getOtherRolesCurHp()==0)
        end
        
    end
    return isAllDead

end

local function battleDeadList(sender,data)
    if(data.role)then
        if(data.role.finalHp>0)then
            print(data.role.curPos)
        end
        data.role.isDead=true
        data.role:showDie(nil,ACTION_TAG_DIE_SKIP)
    end
end

local function battlePreEscapeList(sender,data)
    if(data.role)then
        data.role:resetScapeRound(data.role.finalEscape)
    end
end

local function battleEscapeList(sender,data)
    if(data.role)then
        data.role:escape()
    end
end

local function battleEndResult(sender,data)
    print("coming the battleEndResult")
    local allOtherDead=data.self:isAllDead(2)
    if(Battle.curBattleGroup<Battle.maxBattleGroup )then
        if( allOtherDead)then
            Battle.win=1
        else
            Battle.win=0
        end
    else
        if( allOtherDead)then
            Battle.win=1
        else
            Battle.win=0
        end
    end
    data.self:playBattleResetPlayChange()
    -- 军团竞赛副本只win
    if Battle.battleType == BATTLE_TYPE_FAMILY_STAGE then
        Battle.win=1
    elseif(Battle.battleType==BATTLE_TYPE_ARENA or 
        Battle.battleType==BATTLE_TYPE_CAVE_CHALLENGE or
        Battle.battleType==BATTLE_TYPE_TRAIN or
        Battle.battleType==BATTLE_TYPE_BATH or
        Battle.battleType==BATTLE_TYPE_SERVER_BATTLE
        )then
        Battle.win=gBattleData.win
    end
    data.self:updateMiningAtlasRetInfoByEnd()
    data.self:resetRoleZOrder()
    data.self:resetRoleState()
    data.self:clearEffect()
end

local function battlePreEnd(sender,data)
    data.self:setSpeedScale(0.2)
end

local function battlePreEnd2(sender,data)
    data.self:setSpeedScale(1)
end


local function battleEnd(sender,data)
    --local allDead=data.self:isAllDead(1)


    Battle.logs[Battle.curBattleGroup]=Battle.curLog
    local isShowEnd=false
    local allOtherDead=data.self:isAllDead(2)


    if(Battle.curBattleGroup<Battle.maxBattleGroup )then
        if( allOtherDead)then
            data.self:playDisappear()
        else
            isShowEnd=true
        end
    else
        Battle.curLog.player1 = clone(gGetPlayCardsInfo(1))
        isShowEnd=true
    end


    Battle.curLog.win=Battle.win

    if(data.self:isFirstBattle() )then
        data.self:sendNetMsg(data)
        isShowEnd=false
    end
    if(isShowEnd)then
        data.self.battleFinish = true
        data.self:hideAllBlood()
        cc.Director:getInstance():getScheduler():setTimeScale(1)
        data.self:resetRoleState()
        local function showEnd()
            gSetIdleTimerDisabled(true,true)
            data.self:sendNetMsg(data)
        end
        if(Battle.win==1)then
            GuideData.firstExitAltas(data.self.firstMapid,data.self.firstStageid,data.self.firstType)
            data.self:reFormation()
            data.self:runAction(cc.Sequence:create( cc.DelayTime:create(1.0), cc.CallFunc:create(showEnd)))
        else
            data.self:createBlackBg()
            if data.self:isShowGray() then
                data.self:setGray()
            end
            showEnd()
        end
    end

end

function BattleLayer:reFormation()
    local aliveNum=0
    self:getNode("ui_panel"):setVisible(false)

    local mapBlackBg = self:createBlackBg()

    local cards={}
    for key, role in pairs(self.myRoles) do
        if(role.isDead~=true and key~=PET_POS)then
            aliveNum=aliveNum+1
            table.insert(cards,role)
        end
        if( key==PET_POS)then
            role:setVisible(false)
        end
    end

    local function updateZOrder()
        for key, role in pairs(cards) do
            role:setLocalZOrder(-role:getPositionY())
        end
    end

    mapBlackBg:scheduleUpdateWithPriorityLua(updateZOrder,1)

    local sortCards=clone(cards)

    local function sortCardFunc(card1,card12)
        return card1.dis<card12.dis
    end

    for key=1, aliveNum do
        local node= self:getNode("card"..aliveNum.."_"..key)
        for key, role in pairs(sortCards) do
            local pos1=cc.p(node:getPosition())
            local pos2=cc.p(role:getPosition())
            role.dis=cc.pGetLength(cc.pSub(pos1,pos2))
        end
        table.sort( sortCards,sortCardFunc)
        node.role=sortCards[1]
        table.remove(sortCards,1)
    end


    for key=1, aliveNum do
        local node= self:getNode("card"..aliveNum.."_"..key)
        local role=node.role
        role:playAction(role:getRunActionName())
        local function moved()
            role:playWin()
        end
        if(node)then
            role:stopMoveAction()
            local scaleAction=cc.ScaleTo:create(0.5,0.9)
            role:runAction(scaleAction)
            role.isPauseMove=false
            role:moveActionByTag(0.5,cc.p(node:getPositionX()-80,node:getPositionY()-50), cc.CallFunc:create(moved),4)
        end
    end
    -- self:getNode("panel_card_"..totalNum):setVisible(true)

end

function BattleLayer:getRoleByCardid(cardid)
    for key, role in pairs(self.myRoles) do
        if(role.curCardid==cardid)then
            return role
        end
    end
    return nil
end

function BattleLayer:getStarNum()
    local remainNum=0
    for key, role in pairs(self.myRoles) do
        if(role.isDead~=true and role:isPet()==false)then
            remainNum=remainNum+1
        end
    end
    local deadNum=  Battle.startFightNum-remainNum
    if(deadNum==0)then
        return 3
    elseif(deadNum<=1)then
        return 2
    else
        return 1
    end
end

function BattleLayer:getTotalReduceHp(side)
    if(side==1)then
        return toint(self.totalInitHp1-self:getMyRolesCurHp() )
    else
        return toint(self.totalInitHp2-self:getOtherRolesCurHp())
    end

end

function BattleLayer:getFinalTotalReduceHp(side)
    if(side==1)then
        local ret=0
        --我方角色
        for key, var in pairs(self.myRoles) do
            ret=ret+var.finalHp
        end
        return toint(self.totalInitHp1-ret)
    else
        local ret=0
        for key, var in pairs(self.otherRoles) do
            ret=ret+var.finalHp
        end
        return toint(self.totalInitHp2-ret)
    end

end

function BattleLayer:firstBattleEnd()
    if(TDGAMission)then
        gLogMissionCompleted("battle_guide")
    end
    Scene.firstEnter(2)
    Unlock.setSysUnlock(SYS_CG)
end

function BattleLayer:sendNetMsg(data)
    if(Battle.battleType==BATTLE_TYPE_ARENA or Battle.battleType==BATTLE_TYPE_CAVE_CHALLENGE )then
        Battle.win=gBattleData.win
        Panel.popUp(PANEL_ATLAS_FINAL)

    elseif(Battle.battleType==BATTLE_TYPE_BATH)then
        Battle.win=gBattleData.win
        Panel.popUp(PANEL_ATLAS_FINAL,nil,false)

    elseif(Battle.battleType==BATTLE_TYPE_TRAIN)then
        Battle.win=gBattleData.win
        Panel.popUp(PANEL_ATLAS_FINAL)


    elseif(Battle.battleType==BATTLE_TYPE_ATLAS)then
        Net.sendAtlasFight(self:getStarNum())

    elseif(Battle.battleType==BATTLE_TYPE_ATLAS_GOLD or
           Battle.battleType==BATTLE_TYPE_ATLAS_EXP or
        Battle.battleType==BATTLE_TYPE_ATLAS_ITEMAWAKE )then

        Net.sendActAtlasFight(data.self:getFinalTotalReduceHp(2))

    elseif(Battle.battleType==BATTLE_TYPE_ATLAS_PET )then
        Net.sendActAtlasFight(data.self.totalSendDieNum)

    elseif(Battle.battleType==BATTLE_TYPE_ATLAS_EQUSOUL)then
        if(Battle.win==1 or Battle.curBattleGroup>=Battle.maxBattleGroup )then
            Net.sendActAtlasFight(data.self.totalSendDieNum)
        else
            Panel.popUp(PANEL_ATLAS_FINAL)
        end
    elseif(Battle.battleType==BATTLE_TYPE_ATLAS_PET_TOWER  )then
        Net.sendPetAtlasFight()
    elseif(Battle.battleType==BATTLE_TYPE_GUIDE  )then
        if(self:isFirstBattle())then
            self:firstBattleEnd()
        else
            Battle.win=1
            Net.sendAtlasFight(3,true)
        end

    elseif(Battle.battleType==BATTLE_TYPE_CRUSADE  )then
        Panel.popUp(PANEL_CRUSADE_ATLAS_FINAL )
    elseif(Battle.battleType==BATTLE_TYPE_WORLD_BOSS  )then
        if (Data.worldBossInfo.ifkill) then
            Net.sendWorldBossInfo(3)
        end
        Panel.popUp(PANEL_WORLD_BOSS_FINAL )
    elseif(Battle.battleType==BATTLE_TYPE_MINING_STATUS) then
        Net.sendMiningFight()

    elseif(Battle.battleType==BATTLE_TYPE_ARENA_LOG or Battle.battleType==BATTLE_TYPE_SERVER_BATTLE_LOG) then
        local function playEnd()
            Scene.enterMainScene()
        end
        loadFlaXml("ui_battle_win")

        local coverEffect=self:createCover("ui_tuanzhan_win",{},1,playEnd)
        local winSize=cc.Director:getInstance():getWinSize()
        if(gBattleData.win==1)then
            coverEffect:setPositionX(coverEffect:getPositionX()-winSize.width/4)
        else
            coverEffect:setPositionX(coverEffect:getPositionX()+winSize.width/4)
        end
        self.finalEffect=coverEffect
        self:getNode("battle_data_panel"):setVisible(true)
        self:getNode("cover_cotainer"):setLocalZOrder(3000)
    elseif(Battle.battleType==BATTLE_TYPE_SERVER_BATTLE) then
        Battle.win=gBattleData.win
        Panel.popUpVisible(PANEL_SERVER_BATTLE_FINAL,nil,nil,true)
    elseif(Battle.battleType == BATTLE_TYPE_TOWER) then
        Net.sendTowerFight();
    elseif (Battle.battleType == BATTLE_TYPE_MINING_ATLAS) then
        local starsNum = 0
        if Battle.win == 1 then
            starsNum = self:getMiningAtalsStarNum()
        end
        Net.sendMiningChapterFight(gDigMine.mapId, gDigMine.stageId + 1, starsNum)
    elseif(Battle.battleType==BATTLE_TYPE_CONSTELLATION) then
        Net.sendCircleFight()
    elseif(Battle.battleType == BATTLE_TYPE_FAMILY_STAGE) then
        Battle.win=1
        Panel.popUp(PANEL_ATLAS_FINAL)
    else
        Scene.enterMainScene()
    end
end

function BattleLayer:showGroup(group)

    for i=1, 5 do
        self:getNode("icon_group"..i):setVisible(false)
    end

    local curIcons={}
    if(Battle.maxBattleGroup==1)then
        table.insert(curIcons,5)
    elseif(Battle.maxBattleGroup==2)then
        table.insert(curIcons,3)
        table.insert(curIcons,5)
    elseif(Battle.maxBattleGroup==3)then
        table.insert(curIcons,1)
        table.insert(curIcons,3)
        table.insert(curIcons,5)
    elseif(Battle.maxBattleGroup==4)then
        table.insert(curIcons,1)
        table.insert(curIcons,2)
        table.insert(curIcons,3)
        table.insert(curIcons,5)
    elseif(Battle.maxBattleGroup==5)then
        table.insert(curIcons,1)
        table.insert(curIcons,2)
        table.insert(curIcons,3)
        table.insert(curIcons,4)
        table.insert(curIcons,5)
    end

    for key, i in pairs(curIcons) do
        self:getNode("icon_group"..i):setVisible(true)
        if(key<group)then
            self:changeTexture("icon_group"..i,"images/ui_fight/boss-small-2.png")
        end
    end

    local node=self:getNode("icon_group"..curIcons[group])
    if(node)then
        self:getNode("icon_flag1"):setPositionX(node:getPositionX()-40)
    end


end


function BattleLayer:appearRole(side,pos)
    local role=self:getTargetRole(side,pos)
    if(role==nil)then
        return
    end


    local  function  onAppeared()
        role:playAction(role:getWaitActionName())
        role.bloodNode:setVisible(true)
    end
    role:playAction(role:getRunActionName())
    local funcAction=cc.CallFunc:create(onAppeared)
    role:moveActionByTag(  1,cc.p(role.initX,role.initY) ,funcAction )
end



function BattleLayer:appearSide(side,type)
    local roles={}
    local backDis=0
    local downDis=0
    if(side==1)then
        roles=self.myRoles
        backDis=-700
        if(Battle.appearStoryId)then
            for key, pos in pairs(GUIDE_APPEAR_POS) do
                if(roles[pos])then
                    roles[pos].appearType=2
                end
            end

        end
    else
        roles=self.otherRoles
        backDis=700
    end

    if(type==1)then
        downDis=-850
        backDis=0
    end

    local  function  onAppeared()
        self:playBattleData()
        self:showAllBlood()
        for key, role in pairs(roles) do
            if(role.appearType==2 )then
                role.bloodNode:setVisible(false)
            end
        end
        self:specProcAfterAppeared()
        GuideData.firstEnterAltas(self.firstMapid,self.firstStageid,self.firstType)

    end



    local delayTime=0
    local delayTimeAdd=0
    for key, role in pairs(roles) do
        if(role.appearType==nil or role.appearType==0)then
            role:setPosition(cc.p(role.initX+backDis,role.initY+downDis))
            role:playAction(role:getRunActionName())
            local speed=0.8
            if(gCardRunSpeed["r"..role.curCardid])then
                speed=speed*tonum(gCardRunSpeed["r"..role.curCardid])
            end

            if(type==1)then
                speed=1
            end

            local function onPlayWaiting()
                if(role.appearType==0 and role:isPet()~=true)then
                    role:playNotice("ui_guide_mark",nil,0.6)

                    for key, role in pairs(self.otherRoles) do
                        role:playNotice("ui_guide_mark",nil,0.6)
                    end
                end
                role:playAction(role:getWaitActionName())

            end
            role:moveActionByTag( 1/speed,cc.p(role.initX,role.initY) , cc.CallFunc:create(onPlayWaiting))

            if(1/speed>delayTime)then
                delayTime=1/speed
            end

            if(role.appearType==0)then
                hasNotice=true
                delayTimeAdd=0.6
            end
        elseif(role.appearType==2) then
            role:setPositionX(role.initX+backDis)
        end


    end

    if(delayTime==0)then
        onAppeared()
    else
        self:runAction(cc.Sequence:create( cc.DelayTime:create(delayTime+delayTimeAdd), cc.CallFunc:create(onAppeared)))
    end

end


function BattleLayer:addDropBox()
    self.dropBoxNum=self.dropBoxNum+1
    self:setLabelString("txt_box_num",self.dropBoxNum.." x")
    self:getNode("icon_box").curAction=""
    self:getNode("icon_box"):playAction("ui_fight_icontan_xiangzi",nil,nil,0)
    self:getNode("icon_box"):resume()
end

function BattleLayer:hideAllBlood()

    for key, var in pairs(self.myRoles) do
        var.bloodNode:setVisible(false)
    end
    for key, var in pairs(self.otherRoles) do
        var.bloodNode:setVisible(false)
    end

end


function BattleLayer:showAllBlood()

    for key, var in pairs(self.myRoles) do
        if( var.hpInit~=0 and var.isDead~=true)then
            var.bloodNode:setVisible(true)
        end
    end
    for key, var in pairs(self.otherRoles) do
        if( var.hpInit~=0 and var.isDead~=true and var:isBoss()==false )then
            var.bloodNode:setVisible(true)
        end
    end

end



--初始化地图背景
function BattleLayer:initBg()
    self:getNode("bg_container"):removeAllChildren()
    self.bg=FlashAni.new()
    self.bg.url=gBattleData.bgName
    self.bg:playAction(gBattleData.bgName)
    self:getNode("bg_container"):addChild(self.bg)


    local size=cc.Director:getInstance():getWinSize()
    if(size.width<1024) then
        local scaleTemp=size.width/1024
        self:getNode("battle"):setScale(scaleTemp)
    end

    self.bg:setScale(1.05)

end



--移动镜头
function BattleLayer:moveCameraToRole(pos,scale,time,role)
    self:getNode("battle"):stopActionByTag(ACTION_TAG_CAMERA)
    local scaleNum=scale
    local dis=100*scaleNum
    local px=pos.x
    local py=pos.y
    local winSize=cc.Director:getInstance():getWinSize()
    local scaleTo =cc.EaseOut:create(cc.ScaleTo:create(time ,scaleNum),1)
    local moveTo =cc.EaseOut:create(cc.MoveTo:create(time, cc.p(-px*scaleNum+winSize.width ,-dis-py*scaleNum- winSize.height )),1)

    local action=cc.Spawn:create(scaleTo,moveTo)
    action:setTag(ACTION_TAG_CAMERA)
    self:getNode("battle"):runAction(action)
    self:getNode("bg_front_container"):setVisible(false)
    self:getNode("bg_front_container").cameraRole=role
end

--摄像头重置
function BattleLayer:resetCamera(time,role)
    if(role and   self:getNode("bg_front_container").cameraRole~=role)then
        return false
    end
    print("reset camera")
    self:getNode("battle"):stopActionByTag(ACTION_TAG_CAMERA)
    local scaleTo =cc.EaseOut:create(cc.ScaleTo:create(time, 1),1)
    local moveTo =cc.EaseOut:create(cc.MoveTo:create(time, cc.p( self.initX, self.initY)),1)

    local action=cc.Spawn:create(scaleTo,moveTo)
    action:setTag(ACTION_TAG_CAMERA)
    self:getNode("battle"):runAction(action)

    self:getNode("bg_front_container"):setVisible(true)
    return true
end

function BattleLayer:clearBlackBg()
    self.blackBg.curSide=-1
    self.blackBg.curPos=-1
    self.blackBg:setVisible(false)
    self.blackBg:stopAllActions()

end


function BattleLayer:clearRoleLine()
    for key, var in pairs(self.roleLines) do
        var:removeFromParent(true)
    end
    self.roleLines={}
end


function BattleLayer:getRoleLine(role)

    if role.curPos==1  or
        role.curPos==2 or
        role.curPos==0 then
        return 1
    end

    if role.curPos==3  or
        role.curPos==4 or
        role.curPos==5 then
        return 2
    end
end

function BattleLayer:createRoleLine(role,targetRole,side)
    if(role==nil or targetRole==nil)then
        return
    end

    local scale=1
    if(self:getRoleLine(role)==self:getRoleLine(targetRole))then
        scale=1.8
    end



    local line=gCreateFla("ui_battle_line",1)
    if(side==role.curSide)then
        line:replaceBone({"Layer 1"},"images/ui_fight/all_line2.png")
    end
    role:getParent():addChild(line,100)
    role.line=line
    line:setScaleY(scale)
    line:setPosition(cc.p(role.initX,role.initY))


    local disX= targetRole.initX-role.initX
    local disY=targetRole.initY-role.initY
    local rotaion=0
    if(disX>0)then
        rotaion=360-math.deg(math.atan( disY/ disX))
    else
        rotaion=180-math.deg(math.atan( disY/disX))
    end
    line:setRotation( rotaion  )
    local dis= getDistance(role.initX,role.initY,targetRole.initX,targetRole.initY)
    line:setScaleX(dis/204)
    table.insert(self.roleLines,line)
end


function BattleLayer:lineRoles(roles,side)
    local poses={0,1,2,5,4,3}
    local temps={}

    for i=0, 5 do
        for key, role in pairs(roles) do
            if(role.curPos==poses[i+1])then
                table.insert(temps,role)
            end
        end
    end


    for key, role in pairs(temps) do
        self:createRoleLine(role,temps[key+1],side)
    end

end

function BattleLayer:unSetBgBlack(time,role)

    if(self.blackBg.curRole~=role)then
        return
    end

    if(time)then
        local function onDisappear()
            self.blackBg:setVisible(false)
        end
        self.blackBg:stopAllActions()
        local action=cc.Sequence:create(cc.FadeOut:create(time),cc.CallFunc:create(onDisappear))
        self.blackBg:runAction(action)
    else

        self.blackBg:setVisible(false)
    end
end



--设置背景黑屏
function BattleLayer:setBgBlack(roles,time,alpha,role)
    if(alpha==nil)then
        alpha=1
    end

    if(roles==nil)then
        return
    end
    --女王出招背景不变暗
    if role.curCardid == 10110 then
        return
    end

    self.blackBg.curRole=role
    self.blackBg:stopAllActions()
    self.blackBg.retainNum=self.blackBg.retainNum+1
    self.blackBg:setOpacity(alpha*255)
    self.blackBg:setVisible(true)
    self.blackBg:setLocalZOrder(100)
    for key, var in pairs(roles) do
        if(var~=self.attackRole or var:getLocalZOrder()<var.initZ*2+101)then
            var:setLocalZOrder(var.initZ*2+101)
        end
    end
end


--设置灰色
function BattleLayer:setGray()
    DisplayUtil.setGray(self,true)

end


--重置灰色
function BattleLayer:resetGray()
    DisplayUtil.setGray(self,false)
end

function BattleLayer:createPetShow(pet)
    local effect=nil
    if(Battle.battleType==BATTLE_TYPE_GUIDE)then
        loadFlaXml("wakeup_show_"..pet.curCardid)
        effect=gCreateFla("wakeup_show_"..pet.curCardid)
    else
        loadFlaXml("skill_show_"..pet.curCardid)
        effect=gCreateFla("skill_show_"..pet.curCardid)
    end
    self:getNode("skill_show_container"):addChild(effect)
end

function BattleLayer:createSkillShow(skill)
    loadFlaXml("skill_show_"..skill.skillid)
    local effect=gCreateFla("skill_show_"..skill.skillid)
    self:getNode("skill_show_container"):addChild(effect)
end

function BattleLayer:setCoverContainerTop()
    self:getNode("cover_cotainer"):setLocalZOrder(800)

end

function BattleLayer:createCover(coverName,roles,loop,playEnd)
    local coverEffect=nil
    local function onPlayEnd(send,data)
        coverEffect:removeFromParent()
        if(playEnd)then
            playEnd()
        end
    end

    coverEffect=FlashAni.new()
    coverEffect:playAction(coverName,onPlayEnd,nil,loop)
    if(gIsInReview())then
        coverEffect:setVisible(false)
    end
    coverEffect:setScale(1.2)
    self:getNode("cover_cotainer"):addChild(coverEffect)
    self:getNode("cover_cotainer"):setLocalZOrder(101)

    if(roles)then
        for key, role in pairs(roles) do
            if(role~=self.attackRole or role:getLocalZOrder()<role.initZ+101)then
                role:setLocalZOrder(role.initZ+101+role.initZAdd)
            end
        end
    end
    return coverEffect
end



function BattleLayer:createHideCover(coverName,roles,loop)
    local   coverEffect=gCreateFla(coverName,loop)
    self:getNode("cover_cotainer"):addChild(coverEffect)
    self:getNode("cover_cotainer"):setLocalZOrder(0)
    for key, role in pairs(self.myRoles) do
        role:setVisible(false)
    end

    for key, role in pairs(self.otherRoles) do
        role:setVisible(false)
    end
    if(roles)then
        for key, role in pairs(roles) do
            if(role.isDead==false )then
                role:setVisible(true)
            end
        end
    end
    return coverEffect
end





function BattleLayer:resetRoleState()

    for key, var in pairs(self.myRoles) do
        var:resetRoleState()
    end
    for key, var in pairs(self.otherRoles) do
        var:resetRoleState()
    end

end


function BattleLayer:clearEffect()

    for key, var in pairs(self.myRoles) do
        var:clearEffect()
    end
    for key, var in pairs(self.otherRoles) do
        var:clearEffect()
    end

end



function BattleLayer:resetRoleZOrder()

    for key, var in pairs(self.myRoles) do
        var:resetZOrder()
    end
    for key, var in pairs(self.otherRoles) do
        var:resetZOrder()
    end

end







function BattleLayer:initSideRole(side,roles,playerCard,playerPet)
    local posSide=""
    if(side==1)then
        posSide="lpos"
    else
        posSide="rpos"
    end
    local headid=0
    --我方角色
    for i=0, 5 do
        self:getNode(posSide..i):removeAllChildren()
        if(playerCard[i])then
            local cardData=playerCard[i]
            if(cardData and cardData.cardid) then
                local formations=nil
                if(side==1)then
                    formations= Battle.myFormation

                    if(Battle.myBattleDamageData[cardData.pos]==nil)then
                        Battle.myBattleDamageData[cardData.pos]=0
                    end

                    if(Battle.myBattleHurtData[cardData.pos]==nil)then
                        Battle.myBattleHurtData[cardData.pos]=0
                    end

                    if(Battle.myBattleRecoverData[cardData.pos]==nil)then
                        Battle.myBattleRecoverData[cardData.pos]=0
                    end
                else
                    if( Battle.otherFormation[Battle.curBattleGroup]==nil)then
                        Battle.otherFormation[Battle.curBattleGroup]={}
                    end

                    formations=Battle.otherFormation[Battle.curBattleGroup]
                    if(Battle.otherBattleRecoverData[ Battle.curBattleGroup]==nil)then
                        Battle.otherBattleRecoverData[ Battle.curBattleGroup]={}
                    end

                    if(Battle.otherBattleDamageData[ Battle.curBattleGroup]==nil)then
                        Battle.otherBattleDamageData[ Battle.curBattleGroup]={}
                    end

                    if(Battle.otherBattleHurtData[ Battle.curBattleGroup]==nil)then
                        Battle.otherBattleHurtData[ Battle.curBattleGroup]={}
                    end
                    Battle.otherBattleRecoverData[ Battle.curBattleGroup][cardData.pos]=0
                    Battle.otherBattleHurtData[ Battle.curBattleGroup][cardData.pos]=0
                    Battle.otherBattleDamageData[ Battle.curBattleGroup][cardData.pos]=0
                end


                if(formations)then
                    formations[cardData.pos]=cardData
                end

                headid=cardData.cardid
                local pos=cardData.pos
                local role=BattleRole.new("r"..cardData.cardid,self,side,pos,cardData.cardid,cardData.weaponLv,cardData.awakeLv,playerCard)
                role.curRoleScale=cardData.roleScale
                self:getNode("role_container"):addChild(role)
                table.insert( roles,pos,role)

                if(side==2)then
                    role:setScaleX(-1)
                    role.onDieCallback=function()
                        self:onOtherRoleDie(role)
                    end
                    if(cardData.escapeRound)then
                        role:setScapeRound(cardData.escapeRound)
                    end
                end

                role:initData(cardData)
                print("cardData.pos is:",cardData.pos,"side is:",posSide)
                local posX,posY=self:getNode(posSide..pos):getPosition()
                local size=self:getNode(posSide..pos):getContentSize()
                role:setInitPos(posX+size.width/2,posY+size.height/2,self:getNode(posSide..pos):getLocalZOrder())
                role:playAction(role:getWaitActionName() )
                self:addTouchNode(role.touchNode,posSide..pos)
                role.touchNode.param=role

            end
        end

    end

    if(playerPet and  DB.getPetById(playerPet.petid))then
        local pos=PET_POS
        if(side==1)then
            Battle.myBattleDamageData[pos]=0
            Battle.myBattleHurtData[pos]=0
            Battle.myBattleRecoverData[pos]=0
            Battle.myFormation[pos]=playerPet
        else
            Battle.otherFormation[Battle.curBattleGroup][pos]=playerPet
            Battle.otherBattleDamageData[ Battle.curBattleGroup][pos]=0
            Battle.otherBattleHurtData[ Battle.curBattleGroup][pos]=0
            Battle.otherBattleRecoverData[ Battle.curBattleGroup][pos]=0
        end
        local role=BattleRole.new("r"..playerPet.petid,self,side,pos,playerPet.petid,nil,Pet.getPetAwakeLvByGrade(playerPet.grade))
        self:getNode("role_container"):addChild(role)
        role:initData({maxRage=2,hpInit=0,hp=0,rage=0,appearType=playerPet.appearType})
        table.insert( roles,pos,role)
        if(side==2)then
            role:setScaleX(-1)
        end
        local posX,posY=self:getNode(posSide..pos):getPosition()
        local size=self:getNode(posSide..pos):getContentSize()
        role:setInitPos(posX+size.width/2,posY+size.height/2,self:getNode(posSide..pos):getLocalZOrder())
        role:playAction(role:getWaitActionName() )
        self:addTouchNode(role.touchNode,posSide..pos)
        role.touchNode.param=role
    end

    if(gBossHead~=0)then
        headid=gBossHead
    end

    if(side==2 and headid~=0)then

        if(cc.FileUtils:getInstance():isFileExist("images/icon/head/"..headid.."_2.png"))then
            self:changeTexture("icon_monster","images/icon/head/"..headid.."_2.png")
        else
            self:changeTexture("icon_monster","images/icon/head/"..headid..".png")
        end
        local card=DB.getCardById(headid)
        if(card)then
            self:setLabelString("txt_monter_name",card.name,nil,true)
        end
    end
end

--初始化角色
function BattleLayer:initRole()

    gcopyTimes = 0
    self.myRoles={}
    self.otherRoles={}
    self:initSideRole(1,self.myRoles,gBattleData.playerCards1,gBattleData.playerPet1)
    self:initSideRole(2,self.otherRoles,gBattleData.playerCards2,gBattleData.playerPet2)
    self:initTotalHp()
end

local function setNextRound(sender,data)
    data.self:setRoundNum(data.curRound)
end

function BattleLayer:setRoundNum(num)
    self:setLabelString("txt_round", num.."/"..MAX_ROUND)
    self:setLabelString("txt_round2", num.."/"..MAX_ROUND)
    self:setLabelString("txt_round3", num.."/"..MAX_ROUND)
    gTDParam.battle_round = num
end


function  BattleLayer:playBattleData()
    self.hasSelectTarget=false
    self.battleActions={}
    self.actionPassTime=0
    if(gBattleData.battleRoundList==nil)then
        return
    end
    local totalRoundNum=table.getn(gBattleData.battleRoundList)



    if(Battle.beganStoryId)then
        self:playStoryAction({activeSide= Battle.beganStoryId,needPlay=true})
        Battle.beganStoryId=nil
    end


    if(Battle.appearStoryId)then
        self:playAppearAction({side= 1,pos=GUIDE_APPEAR_POS})
        self:playStoryAction({activeSide= Battle.appearStoryId,needPlay=true})
        Battle.appearStoryId=nil
    end



    self.finalRound=0
    for key, var in pairs(gBattleData.battleRoundList) do
        if(var.roundIndex>=0) then
            local action=cc.CallFunc:create(setNextRound,{curRound=var.roundIndex+1,totalRound=totalRoundNum,self=self  })
            action.actionPassTime=self.actionPassTime
            table.insert( self.battleActions,action )
            --刷新回合数

            self:playBattleRound(var,gBattleData.battleRoundList[key+1])
            self.finalRound=var.roundIndex+1
        end
    end
    self.actionPassTime=self.actionPassTime+1.0
    --结束
    if(self.hasSelectTarget==false)then
        local action=cc.CallFunc:create(battleEndResult,{ self=self})
        action.actionPassTime=self.actionPassTime
        table.insert( self.battleActions, action  )
        --结束战斗

    end

    if(Battle.curBattleGroup>=Battle.maxBattleGroup and self.hasSelectTarget==false )then
        if(Battle.endStoryId)then
            self:playStoryAction({activeSide= Battle.endStoryId})
            Battle.endStoryId=nil
        end
    end

    --self:playBattleResetPlayChange()

    if(self.hasSelectTarget==false)then
        if(Battle.curBattleGroup==Battle.maxBattleGroup )then
            self.actionPassTime =self.actionPassTime +1.0
        end
        local action= cc.CallFunc:create(battleEnd,{ self=self})
        action.actionPassTime=self.actionPassTime
        table.insert( self.battleActions, action )
        --发送结束请求
    end


    self:playBattleDelayActions(self.battleActions)

    for key, role in pairs(self.myRoles) do
    --  role:resetOldCardid()
    end

    for key, role in pairs(self.otherRoles) do
    --  role:resetOldCardid()
    end
end


function BattleLayer:playBattleResetPlayChange()

    for key, role in pairs(self.myRoles) do
        if role.oldCardid == PAN_MAN and role.isDead~=true then
            role:resetPlayChange()
        end
    end

    for key, role in pairs(self.otherRoles) do
        if role.oldCardid == PAN_MAN and role.isDead~=true then
            role:resetPlayChange()
        end
    end
end


function BattleLayer:playBattleDelayActions(actions)

    local actionDelayTable={}
    for key, var in pairs(actions) do
        table.insert(actionDelayTable, cc.Sequence:create(cc.DelayTime:create(var.actionPassTime), var))
    end


    if(table.getn(actionDelayTable)>1) then
        self:getNode("role_container"):runAction(cc.Spawn:create( actionDelayTable))
    elseif(table.getn(actionDelayTable)==1) then
        self:getNode("role_container"):runAction(actionDelayTable[1])
    end

end

--通过阵营 位置 获取role
function  BattleLayer:getTargetRole(side,pos)
    if pos<0 or pos>7 then
        return nil
    end

    local retRole=nil
    if(side==1) then
        retRole=  self.myRoles[pos]
    elseif(side==2) then
        retRole=  self.otherRoles[pos]
    end


    return retRole
end

--通过cadid 位置 获取role
function  BattleLayer:getTargetRoleById(side,cardid)
    local retRole=nil
    if(side==1) then
        for k,card in pairs(self.myRoles) do
            if card.curCardid == cardid then
                retRole = card
                break
            end
        end
    elseif(side==2) then
        for k,card in pairs(self.otherRoles) do
            if card.curCardid == cardid then
                retRole = card
                break
            end
        end
    end
    return retRole
end


function BattleLayer:isGuideTouchMode()
    if(Guide.getCurGuideChain() )then
        if( Guide.curGuideChain.id==GUIDE_ID_COOPERATE_SKILL_4)then
            return true
        end
    end
    return false
end

function BattleLayer:playTouchMode(upRole,downRole)
    self.isTouchMode=true
    cc.Director:getInstance():getScheduler():setTimeScale(1)
    local actions={}

    local isPause=false


    local function onTouchModeEnd()
        if(self.touchScaleNode~=nil)then
            gBattleTouchLevel=0
            self:continueBattle()
        end
    end


    local function onPause2()
        if(isPause)then
            self.touchScaleNode.pausePos=2
            self.touchScaleNode:pause()
            self:getNode("touch_mode"):setVisible(true)
        end
    end


    local function onPause1()
    --[[ if(isPause)then
    self.touchScaleNode.pausePos=1
    self.touchScaleNode:pause()
    end]]

    end

    local actions={}
    local action=cc.Sequence:create(cc.DelayTime:create(TOUCH_MISS_FRAME/FLASH_FRAME),cc.CallFunc:create(onTouchModeEnd))
    table.insert(actions,action)


    action=cc.Sequence:create(cc.DelayTime:create((TOUCH_MAX_FRAME-1)/FLASH_FRAME),cc.CallFunc:create(onPause2))
    table.insert(actions,action)

    action=cc.Sequence:create(cc.DelayTime:create(15/FLASH_FRAME),cc.CallFunc:create(onPause1))
    table.insert(actions,action)

    self.touchScaleNode:runAction( cc.Spawn:create(actions))
    if(self:isGuideTouchMode())then
        self.touchScaleNode.pausePos=0
        isPause=true
    end

end

function BattleLayer:createTouchEffect(upRole,downRole)
    local posX,posY=self.attackRole:getPosition()
    posY=(self.attackRole:getPositionY()+self.helpRole:getPositionY())/2
    local function callback()
        self.touchScaleNode=nil
        self:resetCamera(0.3)
    end
    self.touchScaleNode=gCreateFla(  "ui_coop_togather_di",0,callback )
    self.touchScaleNode:setPosition(cc.p(posX,posY))
    self.touchScaleNode:setLocalZOrder(self.helpRole:getLocalZOrder()-1)
    self:getNode("role_container"):addChild(self.touchScaleNode)


end

function BattleLayer:playPreCooperation(cards,touchLevel)
    local posSide=""
    local otherRole=nil
    self:clearHit()
    self:getNode("ui_panel"):setVisible(false)
    local winSize=cc.Director:getInstance():getWinSize()
    local togatherFla=FlashAni.new()
    togatherFla:setVisible(false)
    self:getNode("role_container"):addChild(togatherFla)
    if(cards[1].curSide==1)then
        posSide="lpos"
        otherRole=self.otherRoles
    else
        posSide="rpos"
        otherRole=self.myRoles
    end



    local upRole=cards[1]
    local downRole=cards[2]

    local coverRoles=clone(otherRole)
    self:setBgBlack(coverRoles,0.2,0.6,upRole)


    upRole:addBufferEffect(EFFECT_TOUCH_MODE)
    downRole:addBufferEffect(EFFECT_TOUCH_MODE)

    local posUpX,posUpY=self:getNode(posSide.."3"):getPosition()
    local posDownX,posDownY=self:getNode(posSide.."5"):getPosition()

    upRole:setLocalZOrder(200)
    downRole:setLocalZOrder(200)

    upRole.curAction=""
    upRole:playAction(upRole:getWaitActionName())
    downRole.curAction=""
    downRole:playAction(downRole:getWaitActionName())

    upRole.display:createShadow(4,2)
    downRole.display:createShadow(4,2)
    local function updateRolePos()
        if(togatherFla.getBone==nil)then
            upRole:unscheduleUpdate()
        end
        local bgX=self.mapW/2

        local pos1=togatherFla:getBone( "card_2_1")
        if(pos1)then
            local box=  pos1:getDisplayManager():getBoundingBox()
            local boxX=box.x
            if(cards[1].curSide==2)then
                boxX=-boxX
            end

            upRole:setPosition(boxX+bgX+togatherFla.offsetX,box.y-winSize.height/2)
        end
        local pos2=togatherFla:getBone( "card_1_1")
        if(pos2)then
            local box=  pos2:getDisplayManager():getBoundingBox()

            local boxX=box.x
            if(cards[1].curSide==2)then
                boxX=-boxX
            end
            downRole:setPosition(boxX+bgX+togatherFla.offsetX,box.y-winSize.height/2)
        end
    end



    local function goTogather()
        local function frameCallback(param,bone ,event)
            if(event=="appear")then
                if(self:isAutoCooperate(upRole))then
                    self:showTouchLevel(touchLevel)
                else
                    self:createTouchEffect(upRole,downRole)
                    self:playTouchMode(upRole,downRole)
                end
                self:shake(4,40,1)
            end
        end

        local function onPlayEnd()
            upRole.isPauseMove=false
            downRole.isPauseMove=false
            togatherFla:removeFromParent(true)
            upRole:unscheduleUpdate()
            upRole.display:clearShadow()
            downRole.display:clearShadow()

            if(self:isGuideTouchMode())then
                self:getNode("touch_mode"):setVisible(false)
            else
                self:getNode("touch_mode"):setVisible(true)
            end

        end
        local time= togatherFla:playAction("ui_coop_togather", onPlayEnd,frameCallback)
        local posX=winSize.width/2
        local posY=-winSize.height/2
        if(upRole.curSide==1)then
            togatherFla.offsetX=-230
            togatherFla:setScaleX(upRole:roleScale())
        else
            togatherFla.offsetX=230
            togatherFla:setScaleX(-upRole:roleScale())
        end
        posX=posX+togatherFla.offsetX
        if(self:isAutoCooperate(upRole)==false)then
            self:moveCameraToRole(cc.p(posX+170,posY-90),1.1,time/2)
        end
        togatherFla:setPosition(posX,posY)
        upRole:scheduleUpdateWithPriorityLua(updateRolePos,1)
        upRole:removeBufferEffect(EFFECT_TOUCH_MODE)
        downRole:removeBufferEffect(EFFECT_TOUCH_MODE)
    end

    local  function  onMoved()
        local togatherWord=FlashAni.new()
        local function onPlayEnd()
            togatherWord:removeFromParent(true)
            goTogather()
        end

        local roles=clone(otherRole)
        table.insert(roles,upRole)
        table.insert(roles,downRole)
        self:createHideCover("ui_coop_cover",roles,1)

        togatherWord:playAction("ui_coop_togather_zi", onPlayEnd)
        self:getNode("skill_show_container"):addChild(togatherWord)
        self:clearBlackBg()

    end
    local funcAction=cc.CallFunc:create(onMoved)
    upRole:moveActionByTag( 0.4 ,cc.p( posUpX,posUpY),funcAction,3)
    downRole:moveActionByTag( 0.4 ,cc.p( posDownX,posDownY),nil,3)
    upRole.isPauseMove=true
    downRole.isPauseMove=true

end


function BattleLayer:showCooperation(touchLevel)
    local ret,cards=self:checkCooperateCard(self.attackRole)
    if(ret)then
        self.helpRole=cards[1]
        table.insert(cards,self.attackRole)
        self:playPreCooperation(cards,touchLevel)
        --self:continueBattle()
    else
        if(self:isAutoCooperate(self.attackRole)==false)then
            self:continueBattle()
        end
    end
end


function BattleLayer:showTouchLevel(level)
    if(level==nil)then
        level=0
    end
    if(level~=0)then
        local levelEffect=FlashAni.new()
        local function callback()
            levelEffect:removeFromParent(true)
        end
        if(level==4)then
            levelEffect:setPositionY(30)
        else
            levelEffect:setPositionY(200)
        end
        levelEffect:playAction("ui_coop_togather_"..level,callback)
        if( self.attackRole:getScaleX()<0)then
            levelEffect:setScaleX(-1)
        end
        self.attackRole:addChild(levelEffect)
    end

end


function BattleLayer:continueBattle()

    if( self.isTouchMode)then
        self:setSpeed(self.curSpeed)
        self.touchLevel=gBattleTouchLevel
        self:showTouchLevel(gBattleTouchLevel)
        self.isTouchMode=false

        self.touchScaleNode=nil
    end
    --如果是引导，不用重新生成战斗数据
    if(Battle.battleType~=BATTLE_TYPE_GUIDE)then
        gBattleData.battleRoundList=gContinueBattle()
    end
    self:playBattleData()
end


function BattleLayer:checkHasCooperateCard(cardid,cards)
    if(gIsBattleVideo)then
        for key, card in pairs(cards) do
            if(card~=nil  and  (not card:hasChange()) and toint(card.curCardid)==toint(cardid))then
                return card
            end
        end

    else
        for key, card in pairs(cards) do
            if(card~=nil  and  (not card:hasChange()) and card.isDead==false  and toint(card.curCardid)==toint(cardid))then
                return card
            end
        end


    end

    return nil
end


function BattleLayer:checkCooperateCard(attacker)

    local card = DB.getCardById(attacker.curCardid)
    local skill =nil
    if(card.skillid2 > 0)then
        skill = DB.getSkillById(card.skillid2)
    end
    if(skill==nil or attacker:hasChange())then
        return false
    end
    local cooperates=string.split(skill.cooperate_card,",")
    local roles={}
    if(attacker.curSide==1)then
        roles=self.myRoles
    else
        roles=self.otherRoles
    end
    local ret={}
    for key, cardid in pairs(cooperates) do
        local card=self:checkHasCooperateCard(cardid,roles)
        if(card)then
            table.insert(ret,card)
        end
    end
    return table.getn(ret) == table.getn(cooperates),ret
end


function BattleLayer:setSelectMode(data)

    local role= data.attackRole
    self.attackRole=role
    if(gIsManualBattle==false)then
        gBattleSelectRoles={}
        data.battle:showCooperation()
        return
    end
    self:resetRoleZOrder()
    role:showAttackWaiting()
    gBattleSelectRoles={}

    self.isSelecting=true
    cc.Director:getInstance():getScheduler():setTimeScale(1)


    if(self:isGuideManual()==false)then
        self.skillTargetTime=12
        self:getNode("target_panel"):setVisible(true)
        local progressTo=cc.ProgressFromTo:create(self.skillTargetTime,100,0)
        self.timeBar:stopAllActions()
        self.timeBar:runAction( progressTo)
        self.skillTargetServerTime=gGetCurServerTime()
    end

    local curCardid=role:getCurSkillCardid()

    local card=DB.getCardById(curCardid)
    local skill=DB.getSkillById(card.skillid0)

    local word= CardPro.getSkillRangeDes(skill)
    local words = string.split(word,"@");
    local rtf = self:getNode("txt_skill_name");
    rtf:clear();
    rtf:addWord(words[1],nil,22,cc.c3b(255,165,64))
    rtf:addWord(gBattleNeedSelectNum,nil,22,cc.c3b(255,255,255))
    rtf:addWord(words[2],nil,22,cc.c3b(255,165,64))




    Icon.setSkillIcon(card.skillid0,self:getNode("icon_skill"))
    local coverRoles=clone(data.targets)
    table.insert(coverRoles,role)
    self:setBgBlack(coverRoles,0.2,0.6,role)
    local side=1
    for key, var in pairs(data.targets) do
        side=var.curSide
        var:showSetSelectMode(role.curSide==var.curSide)
    end

    if(gBattleNeedSelectNum==1)then
        self:clearRoleLine()
        if(gBattleNeedSelectType==SKILL_RANGE_VERTICAL)then
            local splitRoles=self:splitRoleByVertical(data.targets)
            for key, roles in pairs(splitRoles) do
                self:lineRoles(roles,role.curSide)
            end

        elseif(gBattleNeedSelectType==SKILL_RANGE_HORIZONTAL or
            gBattleNeedSelectType == SKILL_RANGE_FRONT_ROW or
            gBattleNeedSelectType ==  SKILL_RANGE_BACK_ROW) then
            if(skill.target_num==3)then
                self:lineRoles(data.targets,role.curSide)
            end
        elseif(gBattleNeedSelectType==SKILL_RANGE_ALL)then
            self:lineRoles(data.targets,role.curSide)
        end
    end


    local posX=self:getNode("skill_target_panel").oldX
    if(side==1)then
        self:getNode("skill_target_panel"):setPositionX(posX-300)
    else
        self:getNode("skill_target_panel"):setPositionX(posX+300)
    end
    Guide.updateGame()

end

function BattleLayer:getRoleByPos(roles,pos)
    for key, var in pairs(roles) do
        if(var.curPos==pos)then
            return var
        end
    end
    return nil
end

function BattleLayer:splitRoleByVertical(roles)
    local role1={self:getRoleByPos(roles,0),self:getRoleByPos(roles,3)}
    local role2={self:getRoleByPos(roles,1),self:getRoleByPos(roles,4)}
    local role3={self:getRoleByPos(roles,2),self:getRoleByPos(roles,5)}

    return {role1,role2,role3}
end

function BattleLayer:isGuideManual()
    if(Battle.battleType==BATTLE_TYPE_GUIDE  )then
        return true
    end
    return false
end

local function onSetSelectMode(sender,data)

    local self=data.battle
    --合体技能前对话
    if(Guide.curGuideChain and Guide.curGuideChain.id==GUIDE_ID_COOPERATE_SKILL_1)then
        local function storyCallback()
            self:setSelectMode(data)
        end
        Story.showStory(87,storyCallback)
    else
        self:setSelectMode(data)
    end
end

function BattleLayer:setAuto()

    if Unlock.isUnlock(SYS_BATTLE_AUTO,false) == false then
        return;
    end

    self:getNode("btn_manual"):setVisible(true)
    self:getNode("btn_auto"):setVisible(false)
    self:getNode("circle"):resume();

    if(self:isGuideManual())then
        gIsManualBattle=true
    else
        gIsManualBattle=false
        if(self.isSelecting)then
            gBattleSelectRoles={}
            self:unSetSelectMode()
        end
    end

    if(gIsBattleVideo==false)then
        cc.UserDefault:getInstance():setIntegerForKey("battle_auto",1)
        cc.UserDefault:getInstance():flush()
    end
end


function BattleLayer:setManual()
    if(gIsBattleVideo and  Battle.battleType~=BATTLE_TYPE_GUIDE  )then
        gShowNotice(gGetWords("noticeWords.plist","not_battle_auto"))
        return
    end
    self:getNode("btn_manual"):setVisible(false)
    self:getNode("btn_auto"):setVisible(true)
    self:getNode("circle"):pause();
    gIsManualBattle=true

    print("setManual")
    cc.UserDefault:getInstance():setIntegerForKey("battle_auto",0)
    cc.UserDefault:getInstance():flush()

end


function BattleLayer:skipRole(roles)
    for key, role in pairs(roles) do
        role:stopAllActions()
        role:clearEffect()
        role.display:clearShadow()
        role:resetRoleState()

        if(role.isDead)then
            role:setVisible(false)
        end
        role.bloodNode:setCurRed(role.finalHp,false,role.hpInit)

        role.skillNode:removeAllChildren()
        role.curAction=""
        role:playAction(role:getWaitActionName())
        role:stopMoveAction()
        role:setPosition(cc.p(role.initX,role.initY))
    end
end

function  BattleLayer:clearBattleScene()



    cc.Director:getInstance():getScheduler():setTimeScale(1)
    self:getNode("role_container"):stopAllActions()
    self:getNode("skill_show_container"):removeAllChildren()
    self:getNode("hit_container"):removeAllChildren()
    self:getNode("cover_cotainer"):removeAllChildren()

    self:getNode("battle"):stopAllActions()
    self:getNode("battle"):setScale(1)
    self:getNode("battle"):setPosition(cc.p(self.initX,self.initY))
    self:clearBlackBg()
    self:clearRoleLine()
    if(self.isSelecting)then
        gIsSkinAttack=true
        gBattleSelectRoles={}
        self:clearSelectMode()
    end
    if(self.touchScaleNode)then
        self.touchScaleNode:stopAllActions()
        self.touchScaleNode:removeFromParent()
        self.touchScaleNode=nil
        self:resetCamera(0.3)
    end
end

function BattleLayer:checkSkipBattle()
    if(self.isDisappearing)then
        return false
    end

    if(self:getNode("txt_skip"):getString()=="")then
        return true
    end


    if( Battle.battleType~=BATTLE_TYPE_WORLD_BOSS)then
        gShowNotice(gGetWords("noticeWords.plist","skip_battle_limint",self.skipLevel,self.skipVipLevel ))
    end


    return false
end

function BattleLayer:skipBattle()


    if(self:checkSkipBattle()==false)then
        return
    end

    if(table.getn(self.battleActions)==0)then
        return
    end
    self:setSpeedScale(1)
    self:setSpeed(self.curSpeed)
    if(gIsBattleVideo==false  )then

        self:clearBattleScene()
        gIsAutoBattle =true
        gBattleData.battleRoundList=gContinueBattle()
        if(gBattleData.battleRoundList)then
            self:playBattleData()
        end
        gIsAutoBattle=false

    end
    self:clearBattleScene()
    self:getNode("ui_panel"):setVisible(true)
    self:skipRole(self.myRoles)
    self:skipRole(self.otherRoles)

    self.battleActions={}
    local list=self.deadList
    self.actionPassTime=0
    local deadTime=0
    for key, var in pairs(list) do
        var.bloodNode:setVisible(false)
        if(var.isDead~=true)then
            local action=cc.CallFunc:create(battleDeadList,{ role=var})
            action.actionPassTime=self.actionPassTime+deadTime
            table.insert( self.battleActions, action  )
            deadTime=deadTime+0.2
        end
    end

    local escapeTime=0
    list=self.otherRoles
    local escaptRole=nil
    for key, var in pairs(list) do
        if(var.finalEscape )then
            local action=cc.CallFunc:create(battlePreEscapeList,{ role=var})
            action.actionPassTime=self.actionPassTime
            table.insert( self.battleActions, action  )

            if(var.finalEscape==0)then
                escaptRole=var
            end
        end
    end

    if(escaptRole)then
        local action=cc.CallFunc:create(battleEscapeList,{ role=escaptRole})
        action.actionPassTime=self.actionPassTime+1.5
        table.insert( self.battleActions, action  )
        escapeTime=2.0
    end


    self:setRoundNum(self.finalRound)
    self.actionPassTime=self.actionPassTime+deadTime+escapeTime

    local action=cc.CallFunc:create(battleEndResult,{ self=self})
    action.actionPassTime=self.actionPassTime
    table.insert( self.battleActions, action  )

    if(Battle.curBattleGroup==Battle.maxBattleGroup )then
        self.actionPassTime =self.actionPassTime +1.0
    end
    local action= cc.CallFunc:create(battleEnd,{ self=self})
    action.actionPassTime=self.actionPassTime
    table.insert( self.battleActions, action )
    self:playBattleDelayActions(self.battleActions)
    self.battleActions={}

    self.totalDieNum=self.totalSendDieNum
    self.totalDieNumDelay=self.totalSendDieNum

    print("totalDieNum die"..self.totalDieNum)
    self:setSpeed(self.curSpeed)



end

function BattleLayer:checkPauseStatus()
    print("Battle.battleType = "..Battle.battleType);
    print("TowerPanelData.guideIndex = "..TowerPanelData.guideIndex);
    if(Battle.battleType==BATTLE_TYPE_TOWER and TowerPanelData.guideIndex > 0)then
        self:getNode("btn_pause"):setVisible(false);
    end
end

function BattleLayer:setPause()
    if(self.skillTargetTime and self.skillTargetTime>0)then
        self.pauseServerTime=gGetCurServerTime()
    else
        self.pauseServerTime=nil
    end
    --   self:getNode("btn_play"):setVisible(true)
    self:getNode("btn_pause"):setVisible(false)
    self:getNode("role_container"):pause()
    self:pause()
    self.isPause=true
    gPauseAllFla(self)

    for key, role in pairs(self.myRoles) do
        role:pause()
    end

    for key, role in pairs(self.otherRoles) do
        role:pause()
    end

    if(self.timeBar)then
        self.timeBar:pause()
    end
end

function BattleLayer:setPlay()
    print("setPlay");
    if(self.pauseServerTime and self.skillTargetTime and self.skillTargetTime>0)then
        self.skillTargetServerTime=self.skillTargetServerTime+ (gGetCurServerTime()-self.pauseServerTime)
    end
    -- self:getNode("btn_play"):setVisible(false)
    self:getNode("btn_pause"):setVisible(true)
    self:getNode("role_container"):resume()
    gResumeAllFla(self)
    self.isPause=false
    self:resume()

    for key, role in pairs(self.myRoles) do
        role:resume()
    end

    for key, role in pairs(self.otherRoles) do
        role:resume()
    end

    if(self.timeBar)then
        self.timeBar:resume()
    end
    self:checkPauseStatus();
end


function BattleLayer:onTouchEnded(data)
    local target=data.param

    if( data.touchName=="btn_speed")then
        self:setSpeed(self.curSpeed+1,true)
    elseif( data.touchName=="icon_box")then


    elseif data.touchName=="btn_data" then
        if(self.finalEffect)then
            self.finalEffect:removeFromParent()
            self.finalEffect=nil
        end
        Panel.popUp(PANEL_BATTLE_DATA,true)
    elseif data.touchName=="btn_pause" then

        self:setPause()
        Panel.popUp(PANEL_BATTLE_PAUSE,self)
    elseif data.touchName=="btn_play" then


        self:setPlay()
    elseif data.touchName=="btn_auto" then

        if Unlock.isUnlock(SYS_BATTLE_AUTO,true) then
            self:setAuto()
        end
        self:setPlay()

    elseif data.touchName=="btn_manual" then
        self:setManual()

    elseif data.touchName=="touch_mode" then
        if(self.touchScaleNode and self.touchScaleNode.pausePos)then
            if(self.touchScaleNode.pausePos==0)then
                return
            end

            if(self.touchScaleNode.pausePos==2)then
                self.touchScaleNode:resume()
            end
        end

        if(self.isTouchMode and self.touchScaleNode and  ( gIsBattleVideo==false or self:isGuideManual()))then
            local curFrame=   self.touchScaleNode:getAnimation():getCurrentFrameIndex()
            print("curFrame "..curFrame)
            if(curFrame<=TOUCH_MIN_FRAME)then
                gBattleTouchLevel=1
            elseif(curFrame>TOUCH_MAX_FRAME and curFrame<TOUCH_MISS_FRAME)then
                local per= ( curFrame- TOUCH_MAX_FRAME)/(TOUCH_MISS_FRAME-TOUCH_MAX_FRAME)
                gBattleTouchLevel=5-math.ceil(per*4)
            else
                local per= ( curFrame- TOUCH_MIN_FRAME)/(TOUCH_MAX_FRAME-TOUCH_MIN_FRAME)
                gBattleTouchLevel=math.ceil(per*4)
            end

            if(gBattleTouchLevel<1)then
                gBattleTouchLevel=1
            end


            if(gBattleTouchLevel>4)then
                gBattleTouchLevel=4
            end
            if(gBattleTouchLevel==4)then
                self:shake(3,40,1)
            end
            self:continueBattle()
        end

    elseif data.touchName=="skin" then
        if(self.isSelecting)then
            gIsSkinAttack=true
            gBattleSelectRoles={}
            self:unSetSelectMode()
        end
    elseif(data.touchName=="btn_skip")   then
        self:skipBattle()

    elseif data.touchName=="btn_close" then
        self:getNode("btn_close"):setVisible(false)
        self:skipBattle()
        self:firstBattleEnd()
    elseif(self.isSelecting and gBattleNeedSelectNum and gBattleNeedSelectNum>0) then
        if(target.canSelect==true)then
            local pos= target.curPos
            for key, var in pairs(gBattleSelectRoles) do
                if(var==idx) then
                    return
                end
            end
            target:showUnSetSelectMode()
            target:showSelected()
            table.insert(gBattleSelectRoles, pos)
            if( table.getn(gBattleSelectRoles)>= gBattleNeedSelectNum or
                table.getn(gBattleSelectRoles)>=table.getn(gBattleSelectRolesRange)) then
                self:unSetSelectMode()
            end
        end

    end

end


function BattleLayer:clearSelectMode()
    gBattleNeedSelectNum=0
    self.skillTargetTime=0
    self.isSelecting=false
    self.attackRole:hideAttackWaiting()
    self:clearRoleLine()
    self:setSpeed(self.curSpeed)
    local scheduleHandler
    local function unSetRoleSelectMode()
        for key, var in pairs(self.myRoles) do
            var:showUnSetSelectMode()
        end
        for key, var in pairs(self.otherRoles) do
            var:showUnSetSelectMode()
        end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleHandler)
    end
    scheduleHandler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(unSetRoleSelectMode, 0.5, false)

    self:getNode("target_panel"):setVisible(false)
    self:clearBlackBg()
end

function BattleLayer:unSetSelectMode()

    self:clearSelectMode()
    if(gIsSkinAttack)then
        self:continueBattle()
    else
        self:showCooperation()
    end

end



function BattleLayer:shake(time,offset,dir)
    local iMoveOffset=offset
    local iMoveTimes=time

    self:getNode("shake_container"):setPosition(cc.p(self:getNode("shake_container").initX,self:getNode("shake_container").initY))
    self:getNode("shake_container"):stopActionByTag(ACTION_TAG_SHAKE)

    local pAct_move_up = cc.MoveBy:create(0.025, cc.p(0,iMoveOffset))
    local pAct_reverse_move_up = pAct_move_up:reverse()
    local pAct_move_left = cc.MoveBy:create(0.025, cc.p(iMoveOffset,0))
    local pAct_reverse_move_left = pAct_move_left:reverse()
    local actions={}
    if(dir==1)then
        table.insert(actions,pAct_move_up)
        table.insert(actions,pAct_reverse_move_up)
        table.insert(actions,pAct_move_left)
        table.insert(actions,pAct_reverse_move_left)
    elseif(dir==2)then
        table.insert(actions,pAct_move_left)
        table.insert(actions,pAct_reverse_move_left)
    else
        table.insert(actions,pAct_move_up)
        table.insert(actions,pAct_reverse_move_up)

    end

    local pAct_repeat =cc.Repeat:create(cc.Sequence:create(actions), iMoveTimes)
    local action=cc.Sequence:create(pAct_repeat )
    action:setTag(ACTION_TAG_SHAKE)
    self:getNode("shake_container"):runAction(action)

end


function BattleLayer:getOtherSide(side)
    if( side==1) then
        return 2
    else
        return 1
    end
end



function BattleLayer:getNextAction(key,actions,nextRound)
    for i=key, table.getn(actions) do
        local nextAction=actions[i]
        if(nextAction.actionType==ACTION_TYPE_SKILL or nextAction.actionType==ACTION_TYPE_NORMAL)then
            return nextAction
        end
    end

    if(nextRound and nextRound.actions)then
        for i=1, table.getn(nextRound.actions) do
            local nextAction=nextRound.actions[i]
            if(nextAction.actionType==ACTION_TYPE_SKILL or nextAction.actionType==ACTION_TYPE_NORMAL)then
                return nextAction
            end
        end
    end
    return nil
end


function BattleLayer:playBattleRound(data,nextRound)
    for key, var in pairs(data.actions) do
        if(Battle.battleType==BATTLE_TYPE_GUIDE)then
            data.actions[key]=nil
        end
        if(var.actionType==ACTION_TYPE_SKILL or var.actionType==ACTION_TYPE_NORMAL)then
            local nextAction=self:getNextAction(key+1,data.actions,nextRound)
            self:playSkillAction(var,nextAction,false)
        elseif(var.actionType==ACTION_TYPE_SKILL_AFTER_DIE)then
            --self.actionPassTime=self.actionPassTime+25/30
            self:playReliveAfterDeadAction(var)
            local nextAction=self:getNextAction(key+1,data.actions,nextRound)
            self:playSkillAction(var,nextAction,true)
            
        elseif(var.actionType==ACTION_TYPE_REMOVE_BUFF)then
            self:playRemoveBuffAction(var)
        elseif(var.actionType==ACTION_TYPE_ROUND_REMOVE_BUFF)then
            self:playRoundRemoveBuffAction(var)    
        elseif(var.actionType==ACTION_TYPE_REDUCE_HP)then
            self:playReduceHpAction(var)
        elseif(var.actionType==ACTION_TYPE_RECOVER_FRIEND_AFTER_DIE)then
            self:playRecoverFriendHpAction(var)
        elseif(var.actionType==ACTION_TYPE_EXPLODE)then
            print("自爆")
        elseif(var.actionType==ACTION_TYPE_ROUND_BUFF)then
            self:playAddBuffAction(var)

        elseif(var.actionType==ACTION_TYPE_CHANGE_STATUS)then
            self:playChangeStatusAction(var)

        elseif(var.actionType==ACTION_TYPE_SELECT_TARGET)then
            self.hasSelectTarget=true
            self:playSelectTargetAction(var)
        elseif(var.actionType==ACTION_TYPE_SELECT_TARGET_GUIDE)then
            self.hasSelectTarget=true
            self:playSelectTargetGuideAction(var)
            return
        elseif(var.actionType==ACTION_TYPE_APPEARANCE)then
            self:playAppearBuffAction(var)
        elseif(var.actionType==ACTION_TYPE_DISPATCH_GUIDE)then
            self:playDispatchGuideAction(var)

        elseif(var.actionType==ACTION_TYPE_ADD_DELAY_TIME)then

            self.actionPassTime=self.actionPassTime+var.delayTime/20
        elseif(var.actionType==ACTION_TYPE_SHOW_FACE)then

            self:playShowFaceAction(var)

        elseif(var.actionType==ACTION_TYPE_STORY)then
            --播放对话
            local storyId=var.activeSide
            if(self:isRoleStory(storyId)==false)then
                self:playStoryAction(var)
                local delayTimeNum=10/FLASH_FRAME
                local action=cc.DelayTime:create(delayTimeNum)
                action.actionPassTime=self.actionPassTime
                table.insert(self.battleActions,action)
                self.actionPassTime=self.actionPassTime+delayTimeNum
            else
                self:playRoleStoryAction(var)
            end
        elseif(var.actionType==ACTION_TYPE_APPEAR)then
            self:playAppearAction(var)
        elseif(var.actionType==ACTION_TYPE_HURT)then
            self:playHurtAction(var)
        elseif(var.actionType==ACTION_TYPE_CHANGE)then
            self:playChangeAction(var)

        elseif(var.actionType==ACTION_TYPE_PREPAIR_ESCAPE)then
            self:playPrepareEscapeAction(var)

        elseif(var.actionType==ACTION_TYPE_ESCAPE)then
            self:playEscapeAction(var)
        end


    end
end


function BattleLayer:playHurtAction(data)
    local params=data
    params.battleLayer=self
    local role=self:getTargetRole(data.activeSide,data.activePosition)

    local lastTime=30/FLASH_FRAME
    local action=cc.Sequence:create({
        cc.CallFunc:create(onPlayHurtActionCallBack,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    --变身
    table.insert( self.battleActions, action )

    self.actionPassTime=self.actionPassTime+lastTime
end


function BattleLayer:playChangeAction(data)
    local params=data
    params.battleLayer=self
    params.isBoss=true
    local role=self:getTargetRole(data.activeSide,data.activePosition)
    role:changeAttackEventCardid(data.targetPosition)

    local lastTime=200/FLASH_FRAME
    if(data.activeSide==1)then
        lastTime=60/FLASH_FRAME
        params.isBoss=false
    end
    local action=cc.Sequence:create({
        cc.CallFunc:create(onPlayChangeCallBack,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    --变身
    table.insert( self.battleActions, action )

    self.actionPassTime=self.actionPassTime+lastTime
end

function BattleLayer:playReliveAfterDeadAction(data)
    
    local attackRole=self:getTargetRole(data.activeSide,data.activePosition)
    local params=data
    params.battleLayer=self
    params.attackRole = attackRole
    local action = cc.CallFunc:create(onRoleReliveAfterDeadCallBack,params)
    action.actionPassTime=self.lastDiffTime

    table.insert(self.battleActions, action )
    self.actionPassTime=self.actionPassTime+gGetFlaAnimationDuring(attackRole:getReliveAfterDeadActionName())
end



function BattleLayer:playEscapeAction(data)
    local params=data
    params.battleLayer=self
    local role=self:getTargetRole(data.activeSide,data.activePosition)
    local lastTime=40/FLASH_FRAME
    local action=cc.Sequence:create({
        cc.CallFunc:create(onPlayEscapeCallBack,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    table.insert( self.battleActions, action )
    self.actionPassTime=self.actionPassTime+lastTime
end


function BattleLayer:playPrepareEscapeAction(data)
    local params=data
    params.battleLayer=self
    local role=self:getTargetRole(data.activeSide,data.activePosition)
    role.finalEscape=data.skillId


    local lastTime=15/FLASH_FRAME
    local action=cc.Sequence:create({
        cc.CallFunc:create(onPlayPrepareEscapeCallBack,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    table.insert( self.battleActions, action )
    self.actionPassTime=self.actionPassTime+lastTime
end


function BattleLayer:playAppearAction(data)
    local params={}
    params.battleLayer=self
    params.pos=data.pos
    params.side=data.side
    local time=0

    for key, pos in pairs(params.pos) do
        local role=self:getTargetRole(params.side,toint(pos))
        if(role~=nil)then
            if(time<gGetActionTime(role:getRunActionName()))then
                time=gGetActionTime(role:getRunActionName())
            end
        end
    end

    local lastTime=1.5
    local action= cc.Sequence:create({
        cc.CallFunc:create(onPlayAppearCallBack,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    table.insert( self.battleActions,action)
    --播放出场
    self.actionPassTime= self.actionPassTime+lastTime

end

function BattleLayer:isRoleStory(id)
    local story=Story.getStory(toint(id))
    if(story and story.talks[1] and  toint(story.talks[1].dialogbg)==1)then
        return true
    end

    return false
end



function BattleLayer:playRoleStoryAction(data)
    local params={}
    params.battleLayer=self
    params.storyId=data.activeSide

    local lastTime=1.5
    local action=cc.Sequence:create({
        cc.CallFunc:create(onPlayRoleStoryCallBack,params),
        cc.DelayTime:create(lastTime),
    })

    action.actionPassTime= self.actionPassTime
    --播放对话
    table.insert( self.battleActions, action)
    self.actionPassTime= self.actionPassTime+lastTime


end


function BattleLayer:playStoryAction(data)
    local params={}
    params.battleLayer=self
    params.storyId=data.activeSide
    params.needPlay=data.needPlay

    local lastTime=0.2
    if(toint(params.storyId)==43)then
        self.actionPassTime= self.actionPassTime+3.5
    end

    local action=cc.Sequence:create({
        cc.CallFunc:create(onPlayStoryCallBack,params),
        cc.DelayTime:create(lastTime),
    })

    action.actionPassTime= self.actionPassTime
    --播放对话
    table.insert( self.battleActions, action)
    self.actionPassTime= self.actionPassTime+lastTime


end


function BattleLayer:playReduceHpAction(data)
    local params={}
    local targetRoles={}
    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local targetData=data.targets[1]

    if(targetData==nil)then
        return
    end
    params.targetRole=self:getTargetRole(activeSide,targetData.position)
    params.targetData=targetData
    params.effectData=targetData.effectList[1]
    local action=cc.Sequence:create({  cc.CallFunc:create(onRoleRemoveHpCallBack,params),cc.DelayTime:create(0.5)})
    action.actionPassTime= self.actionPassTime
    self.actionPassTime=self.actionPassTime+10/FLASH_FRAME

    if(params.targetData and params.targetRole)then
        params.targetRole:setSkipHp(-params.targetData.damage)

        if( targetData.isDead)then
            self:addDeadRole( params.targetRole)
        end
    end
    --播放每回合掉血
    table.insert( self.battleActions,action)
end


function BattleLayer:playRecoverFriendHpAction(data)
    local targetRoles={}
    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition

    for key, targetData in pairs(data.targets) do
        local params={}
        if(targetData==nil)then
            return
        end
        params.targetRole=self:getTargetRole(activeSide,targetData.position)
        params.targetData=targetData
        params.effectData=targetData.effectList[1]
        local action=cc.Sequence:create({  cc.CallFunc:create(onRoleRecoverFriendHpCallBack,params),cc.DelayTime:create(0.5)})
        action.actionPassTime= self.actionPassTime
        --播放给好友加血
        table.insert( self.battleActions,action)
        if(params.targetData and  params.targetRole)then
            params.targetRole:setSkipHp(params.targetData.damage)
        end
    end
end


function BattleLayer:playAddBuffAction(data)
    local targetRoles={}
    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local responses={}
    local lastTime=0
    for key, var in pairs(data.targets) do
        if(var.isEnemy) then
            table.insert(responses,var.response)
            table.insert( targetRoles,self:getTargetRole(self:getOtherSide(activeSide),var.position))
        else
            table.insert(responses,var.response)
            table.insert( targetRoles,self:getTargetRole(activeSide,var.position))
        end


    end
    for key, var in pairs(targetRoles) do
        local params={}
        params.targetRole=targetRoles[key]
        params.data=data
        params.response=responses[key]
        params.targets=data.targets
        params.targetData = data.targets[key]
        local action=cc.Sequence:create({ cc.CallFunc:create(onRoleAddBuffCallBack,params)})
        action.actionPassTime= self.actionPassTime
        table.insert( self.battleActions,action)

    end
    --播放移除buff
    self.actionPassTime=self.actionPassTime+lastTime

end

function BattleLayer:playRemoveBuffAction(data)
    local targetRoles={}
    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local responses={}
    local lastTime=0
    for key, var in pairs(data.targets) do
        if(var.isEnemy) then
            table.insert(responses,var.response)
            table.insert( targetRoles,self:getTargetRole(self:getOtherSide(activeSide),var.position))
        else
            table.insert(responses,var.response)
            table.insert( targetRoles,self:getTargetRole(activeSide,var.position))
        end


    end
    for key, var in pairs(targetRoles) do
        local params={}
        params.targetRole=targetRoles[key]
        params.data=data
        params.response=responses[key]
        params.targets=data.targets
        params.targetData = data.targets[key]
        local action=cc.Sequence:create({ cc.CallFunc:create(onRoleRemoveBuffCallBack,params)})
        action.actionPassTime= self.actionPassTime
        table.insert( self.battleActions,action)

        if(params.response==RESPONSE_TYPE_SPIRIT_CHAIN + 100 and
            params.targetRole.curPos==activePosition and
            params.targetRole.curSide==activeSide)then
            lastTime=2.2
            params.targetRole:changeAttackEventCardid(Card_MIKU_SPIRIT)
        end
    end
    --播放移除buff
    self.actionPassTime=self.actionPassTime+lastTime
end


function BattleLayer:playRoundRemoveBuffAction(data)
    local targetRoles={}
    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local responses={}
    local lastTime=0
    for key, var in pairs(data.targets) do
        if(var.isEnemy) then
            table.insert(responses,var.response)
            table.insert( targetRoles,self:getTargetRole(self:getOtherSide(activeSide),var.position))
        else
            table.insert(responses,var.response)
            table.insert( targetRoles,self:getTargetRole(activeSide,var.position))
        end
    end
    local attackRole = self:getTargetRole(activePosition,targetPosition)
    for key, var in pairs(targetRoles) do
        local params={}
        params.targetRole=targetRoles[key]
        params.data=data
        params.targets=data.targets
        params.attackRole=attackRole
        params.targetData = data.targets[key]
        local action=cc.Sequence:create({ cc.CallFunc:create(onRoleAttackRemoveBuffCallBack,params)})
        action.actionPassTime= self.actionPassTime
        table.insert( self.battleActions,action)
    end
    --播放移除buff
    self.actionPassTime=self.actionPassTime+lastTime
end

function BattleLayer:isAfterTarget(target)
    if(target.response==RESPONSE_TYPE_RELIVE)then --复活
        return true
    elseif(target.response==RESPONSE_TYPE_CLEAR_RELIVE_POINT)then
        return true
    elseif(target.response==RESPONSE_TYPE_ATTR_CHANGE)then --改变属性
        return true
    end

    return false
end


function BattleLayer:playShowFaceAction(data)

    local function showFace(target,data)
        for key, role in pairs(self.myRoles) do
            if(role:isPet()==false)then
                if(data.faceid==1)then
                    role:playNotice("ui_guide_mark",nil,0.6)
                else
                    role:playNotice("ui_zhenji_biaoqing")
                end
            end
        end
    end

    local lastTime=0.6
    local action= cc.Sequence:create({
        cc.CallFunc:create(showFace,data),
    })
    action.actionPassTime= self.actionPassTime
    table.insert( self.battleActions,action)
    self.actionPassTime= self.actionPassTime+lastTime
end


function BattleLayer:playDispatchGuideAction(data)

    local function dispathGuide(target,data)
        local group=Guide.guideGroup["group"..data.guideid]

        Guide.changeStack()
        for key, guideid in pairs(group) do
            Guide.dispatch(guideid)
        end
        Guide.resetStack()

        if(data.needPause==1)then
            self:setPause()
        end
    end

    local lastTime=0.6
    local action= cc.Sequence:create({
        cc.CallFunc:create(dispathGuide,data),
    })
    action.actionPassTime= self.actionPassTime
    table.insert( self.battleActions,action)
    self.actionPassTime= self.actionPassTime+lastTime
end

function BattleLayer:playSelectTargetGuideAction(data)
    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local targetRoles={}
    local attackRole=self:getTargetRole(activeSide,activePosition)

    for key, var in pairs(data.targets) do
        table.insert( targetRoles,self:getTargetRole(self:getOtherSide(activeSide),var.position))
    end


    local function dispathGuide(target,data)
        local group=Guide.guideGroup["group"..data.guideid]

        Guide.changeStack()
        for key, guideid in pairs(group) do
            Guide.dispatch(guideid)
        end
        Guide.resetStack()
    end
    gBattleNeedSelectNum=data.needSelectNum
    gBattleNeedSelectType=data.selectType
    gBattleSelectRolesRange=targetRoles
    local params={
        battleLayer=self,
        attackRole=attackRole,
        attackData=data,
        targets=targetRoles,
        guideid=data.guideid,
        battle=self
    }

    local lastTime=0.2
    local action= cc.Sequence:create({
        cc.CallFunc:create(dispathGuide,params),
        cc.CallFunc:create(onSetSelectMode,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    --播放选择对手
    table.insert( self.battleActions,action)
    self.actionPassTime= self.actionPassTime+lastTime
end

function BattleLayer:playSelectTargetAction(data)

    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local skillId= data.skillId
    local targetRoles={}
    local attackRole=self:getTargetRole(activeSide,activePosition)

    for key, var in pairs(gBattleSelectRolesRange) do
        local role=nil
        if(data.isEnemy )then
            role= self:getTargetRole(self:getOtherSide(activeSide),var)
        else
            role= self:getTargetRole( activeSide,var)

        end
        table.insert(targetRoles,role )
    end


    local params={
        battleLayer=self,
        attackRole=attackRole,
        attackData=data,
        targets=targetRoles,
        battle=self
    }

    local lastTime=0.2
    local action= cc.Sequence:create({
        cc.CallFunc:create(onSetSelectMode,params),
        cc.DelayTime:create(lastTime),
    })
    action.actionPassTime= self.actionPassTime
    --播放选择对手
    table.insert( self.battleActions,action)
    self.actionPassTime= self.actionPassTime+lastTime



end
function BattleLayer:needShowCooperate(skill,attackRole)
    if(skill and
        skill.cooperate_card~=""and
        --self:checkCooperateCard(attackRole) and
        gHasFlaAnimationData(attackRole:getCooperateAttackActionName()) )then
        return true
    end
    return false
end

function BattleLayer:isRelationNextAction(attacker,targets,data,curData)

    if(Battle.battleType==BATTLE_TYPE_GUIDE)then
        return 2
    end

    for key, target in pairs(curData.targets) do
        if(target.response==RESPONSE_TYPE_RELIVE)then --复活
            return 2
        end
    end


    if(data==nil)then
        return 1
    end


    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local attackRole=self:getTargetRole(activeSide,activePosition)



    return 0

end

function BattleLayer:playChangeStatusAction(data,nextData)

    local activePosition =data.activePosition
    local activeSide =data.activeSide

    local curTarget=self:getTargetRole(activeSide,activePosition)
    curTarget:changeAttackEventCardid(Card_MIKU_SPIRIT)
    local action
    local params={}
    params.cardid=Card_MIKU_SPIRIT
    params.targetRole=curTarget
    local  action=cc.Sequence:create({
        cc.CallFunc:create(onPlayChangeStatusCallBack,params),
        cc.DelayTime:create(1.0),
    })
    action.actionPassTime= self.actionPassTime
    self.actionPassTime =self.actionPassTime +1.0
    table.insert( self.battleActions, action)

end


function BattleLayer:playAppearBuffAction(data,nextData)

    local actionType = data.actionType
    local activeSide =data.activeSide
    local  showChange = false
    local copyheroTime = 0
    for key, var in pairs(data.targets) do
        local curTarget=nil
        if(var.isEnemy) then
            curTarget=self:getTargetRole(self:getOtherSide(activeSide),var.position)
        else
            curTarget=self:getTargetRole(activeSide,var.position)
        end

        local action
        local params=clone(var)
        params.targetRole=curTarget
        if(var.response==RESPONSE_TYPE_SPIRIT_CHAIN)then
            action=cc.Sequence:create({
                cc.CallFunc:create(onPlaySpiritChainCallBack,params),
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(onPlaySpiritChainGetCallBack,params),
            })
            action.actionPassTime= self.actionPassTime
            self.actionPassTime= self.actionPassTime+1.0
        elseif(var.response==RESPONSE_TYPE_SPIRIT_CHAIN_GET)then
            action=cc.Sequence:create({
                cc.CallFunc:create(onPlaySpiritChainGetCallBack,params),
                cc.DelayTime:create(1.0),
            })
            action.actionPassTime= self.actionPassTime
        elseif(var.response==RESPONSE_TYPE_RADIATION)then
            action=cc.Sequence:create({
                cc.CallFunc:create(onPlayRadiationCallBack,params),
                cc.DelayTime:create(1.0),
            })
            action.actionPassTime= self.actionPassTime
        elseif(var.response==RESPONSE_TYPE_COPY_HERO)then

            copyheroTime = gGetFlaAnimationDuring("s066_touxiang") +gGetFlaAnimationDuring("s066_c")+0.2

            local copyCard = self:getTargetRoleById(self:getOtherSide(activeSide),params.copyCardId)

            params.targetRole:changeAttackEventCardid(params.copyCardId)
            if copyCard then
                params.weaponLv=copyCard.curWeaponLv
                params.awakeLv=copyCard.curAwakeLv
            end
            
            action=cc.Sequence:create({
                cc.CallFunc:create(onPlayChangeHeroCallBack,params),
                cc.DelayTime:create(1.0),
            })
            self.actionPassTime = self.actionPassTime -gcopyTimes*copyheroTime
            action.actionPassTime= self.actionPassTime+0.5
            gcopyTimes = gcopyTimes +1
            showChange =true
        end

        if(action)then
            table.insert( self.battleActions, action)
        end
    end
    if showChange then
        self.actionPassTime  =self.actionPassTime + copyheroTime
    else
        self.actionPassTime  =self.actionPassTime  +0.5
    end
    
end

function BattleLayer:playSkillAction(data,nextData,skillAfterDead)

    local actionType = data.actionType
    local activeSide =data.activeSide
    local activePosition =data.activePosition
    local targetPosition = data.targetPosition
    local skillId= data.skillId
    local queueAction=-1
    local nextTargetRole=nil
    if(skillId and skillId>100000)then
        skillId=math.floor(data.skillId/100)
        queueAction=data.skillId%100
        if(nextData)then
            nextTargetRole=self:getTargetRole( self:getOtherSide(nextData.activeSide) ,nextData.targetPosition)
        end
    end

    data.afterTargets={}
    local relationTargets={}


    local realTargetPos=targetPosition
    local attackRole=self:getTargetRole(activeSide,activePosition)

    local targetRole=self:getTargetRole(self:getOtherSide(activeSide),realTargetPos)
    local targetRoles={}
    local afterTargetRoles={}
    local bufferRoles={}

    if(targetRole==nil)then
        targetRole=self:getTargetRole( activeSide ,realTargetPos)
    end

    local dieRole={}
    for key, var in pairs(data.targets) do
        local curTarget=nil
        if(var.isEnemy) then
            curTarget=self:getTargetRole(self:getOtherSide(activeSide),var.position)
        else
            curTarget=self:getTargetRole(activeSide,var.position)
        end

        if(self:isAfterTarget(var))then
            table.insert( data.afterTargets,var)
            table.insert( afterTargetRoles,curTarget)
        else
            targetRoles[key]=curTarget
        end
        table.insert( relationTargets,curTarget)

        if(var and var.isDead)then
            self:addDeadRole( curTarget)
            if(curTarget.curSide==2)then
                dieRole[curTarget.curPos]=1
            end
            if curTarget.curXmlName=="r10108" then
                self.lastDiffTime = 0
            end
        elseif(var.response==RESPONSE_TYPE_RELIVE)then --复活
            self:removeDeadRole( curTarget)
            curTarget:setSkipRelive(var.damage)
        end

    end


    for key, var in pairs(data.buffTargets) do
        local curTarget=nil
        if(var.isEnemy) then
            curTarget=self:getTargetRole(self:getOtherSide(activeSide),var.position)
        else
            curTarget=self:getTargetRole(activeSide,var.position)
        end

        table.insert( bufferRoles,curTarget)
        table.insert( relationTargets,curTarget)
        if(var and var.isDead)then
            self:addDeadRole( curTarget)
            if(curTarget.curSide==2)then
                dieRole[curTarget.curPos]=1
            end
        elseif(var.response==RESPONSE_TYPE_RELIVE)then --复活
            self:removeDeadRole( curTarget)
            curTarget:setSkipRelive(var.damage)
        end
    end

    self.totalSendDieNum=self.totalSendDieNum+table.count(dieRole)


    if  table.count(targetRoles)==0 and queueAction==-1 then
        return
    end



    local params={
        battleLayer=self,
        attackRole=attackRole,
        targetPos={x=targetRole.initX,y= targetRole.initY},
        attackData=data,
        afterTargets=afterTargetRoles,
        targets=targetRoles,
        targetRole=targetRole,
        nextTargetRole=nextTargetRole,
        battle=self,
        skillAfterDead=skillAfterDead
    }


    local bufferParams={
        battleLayer=self,
        attackRole=attackRole,
        targetPos={x=targetRole:getPositionX(),y= targetRole:getPositionY()},
        attackData=data,
        targets=bufferRoles,
        battle=self
    }

    gParseBeforeActionBuff(self,bufferParams)
    local actions={}
    if(queueAction<=0)then
        table.insert(actions, cc.CallFunc:create(onRoleStartAttackCallBack,params) )
    end

    local attackName=""
    local showSkill=nil
    local isCooperateSkill=false
    if(data.skillType==1) then --大招时间
        local skill=DB.getSkillById(data.skillId)
        if( self:needShowCooperate(skill,attackRole))then
            attackName=attackRole:getCooperateAttackActionName()
            attackRole.cooperateCardid=toint(skill.cooperate_card)
            isCooperateSkill=true
        else
            attackName=attackRole:getBigAttackActionName2()
        end

    elseif(data.skillType==2) then --附加技能
        attackName=attackRole:getExtraAttackActionName()
    else
        attackName=attackRole:getSmallAttackActionName2()
    end

    if(isCooperateSkill and self:isAutoCooperate(attackRole))then
        local action= cc.CallFunc:create(onCooperateCallBack,params)
        action.actionPassTime=self.actionPassTime
        table.insert( self.battleActions, action)
        self.actionPassTime=self.actionPassTime+0.4+gGetFlaAnimationDuring("ui_coop_togather_zi")+gGetFlaAnimationDuring("ui_coop_togather")

    end

    if(attackRole:isPet() and data.skillType~=2)then
        showSkill=attackRole
    end

    params.relationNextAttacker= self:isRelationNextAction(attackRole,relationTargets,nextData,data)


    if(isCooperateSkill)then
        local touchLevel=0

        if(gIsBattleVideo)then
            if( data  and data.targets[1] and  data.targets[1].damage)then
                touchLevel=(data.targets[1].damage%3)+2
            end
            if(Battle.battleType==BATTLE_TYPE_GUIDE)then
                touchLevel=4
            end
        else
            if(attackRole.curSide==2)then
                touchLevel=4
                --敌方合体技都是4
            else
                touchLevel=self.touchLevel
            end
        end

        if(touchLevel~=4)then
            params.passSpeed=true
            params.passCover=true
        end
        params.touchLevel=touchLevel
        if(params.relationNextAttacker==0)then
            params.relationNextAttacker=1
        end
    end


    local duration,skillDuring,attackDuring= gParseAttackAction(skillId,attackName,params,actions,queueAction)

    if(queueAction<=0)then
        local actionEnd=cc.Sequence:create(cc.DelayTime:create(duration),cc.CallFunc:create(onRoleActionEnd,params))
        table.insert(actions,actionEnd)
    end
    if(isCooperateSkill)then
        local skillEnd=cc.Sequence:create(cc.DelayTime:create(skillDuring),cc.CallFunc:create(onRoleSkillActionEnd,params))
        table.insert(actions,skillEnd)
    end
    local action=nil
    if(showSkill and  activeSide==1)then
        local playAction=cc.CallFunc:create(onPlayerSkillShow,{attackRole=attackRole,skill= showSkill})
        local showTime=35/FLASH_FRAME
        if(Battle.battleType==BATTLE_TYPE_GUIDE  )then
            local angerTime=gGetActionTime(attackRole:getAngerActionName())+0.2
            local playEndAction=cc.CallFunc:create(onPlayerSkillShowEnd,{attackRole=attackRole,skill= showSkill})
            action= cc.Sequence:create(cc.Sequence:create(playAction, cc.DelayTime:create(showTime),playEndAction,cc.DelayTime:create(angerTime)),cc.Spawn:create( actions))
            showTime=showTime+angerTime
        else
            action= cc.Sequence:create(cc.Sequence:create(playAction, cc.DelayTime:create(showTime)),cc.Spawn:create( actions))
        end
        duration=duration+ showTime
    else
        action=cc.Spawn:create( actions)
    end
    if(action)then

        action.actionPassTime=self.actionPassTime
        
        
        
        if self.lastDiffTime == 0 then
            self.lastDiffTime = self.actionPassTime+attackDuring
            if(skillId==GUOJIA_SKILL_ID)then 
                self.lastDiffTime = self.actionPassTime+duration-0.2
            end
        end

        --出手的录像
        table.insert( self.battleActions, action )
        self.actionPassTime=self.actionPassTime+duration

        if(isCooperateSkill and self:isAutoCooperate(attackRole))then
            self.actionPassTime=self.actionPassTime+0.4
        end
    end

end

function BattleLayer:isAutoCooperate(role)
    if(gIsBattleVideo and gIsManualBattle==false)then
        return true
    end



    if(role.curSide==2)then
        return true
    end
    return false
end

function BattleLayer:removeDeadRole(role)
    if(role==nil)then
        return
    end
    for key, var in pairs(self.deadList) do
        if(var==role)then
            table.remove(self.deadList,key)
            return
        end
    end
end

function BattleLayer:addDeadRole(role)
    if(role==nil)then
        return
    end

    self:removeDeadRole(role)
    table.insert(self.deadList,role)
end


function BattleLayer:createBlackBg()
    local mapBlackBg=UILayer:new()
    mapBlackBg:init("ui/battle_resule_bg.map")
    mapBlackBg:setScaleX(1.02)
    mapBlackBg:setPosition(( - mapBlackBg.mapW)/2, (    mapBlackBg.mapH)/2)
    self:getNode("bg_container"):addChild(mapBlackBg)
    return mapBlackBg
end

function BattleLayer:isShowGray()

    if(Battle.battleType==BATTLE_TYPE_ARENA_LOG or Battle.battleType==BATTLE_TYPE_SERVER_BATTLE_LOG)then
        return false
    end

    if Battle.battleType ~= BATTLE_TYPE_ATLAS_GOLD and
        Battle.battleType ~= BATTLE_TYPE_ATLAS_EXP and
        Battle.battleType ~= BATTLE_TYPE_ATLAS_PET and
        Battle.battleType ~= BATTLE_TYPE_ATLAS_EQUSOUL and
        Battle.battleType ~= BATTLE_TYPE_ATLAS_ITEMAWAKE  then
        return true
    end

    return false
end

function BattleLayer:specProcAfterAppeared()
    --TODO
    if Battle.battleType==BATTLE_TYPE_SERVER_BATTLE then
    -- self:setPause()
    -- Panel.popUpVisible(PANEL_SERVER_BATTLE_BASIC_INFO,self,nil,true)
    end
end

function BattleLayer:initMiningAtalsRetInfo()
    if Battle.battleType ~= BATTLE_TYPE_MINING_ATLAS then
        return
    end

    if table.count(gDigMine.atlasRets) == 0 or gDigMine.atlasRets.types == nil then
        return
    end

    self.miningAtlasRets = {true, true, true}

    for idx,retType in pairs(gDigMine.atlasRets.types) do
        local desc  = gDigMine.getDrawLotDesc(toint(gDigMine.atlasRets.types[idx]),toint(gDigMine.atlasRets.values[idx]))
        self:setLabelString("mine_atlas_ret_txt"..idx, desc)
        if retType == MINE_ATLAS_RET_CONDITION1 then
            self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
        elseif retType == MINE_ATLAS_RET_CONDITION2 then
            self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
        elseif retType == MINE_ATLAS_RET_CONDITION3 then
            self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-kong1.png")
            self.miningAtlasRets[idx] = false
        elseif retType == MINE_ATLAS_RET_CONDITION4 then
            if self:hasTheCountryInMySide(gDigMine.atlasRets.values[idx]) then
                self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                self.miningAtlasRets[idx] = false
            else
                self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
            end
        elseif retType == MINE_ATLAS_RET_CONDITION5 then
            self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-kong1.png")
            self.miningAtlasRets[idx] = false
        elseif retType == MINE_ATLAS_RET_CONDITION6 then
            --所有英雄血量
            self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
        elseif retType == MINE_ATLAS_RET_CONDITION7 then
            self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
            self.miningAtlasRets[idx] = false
        end
        self:getNode("layout_mine_atlas_ret"..idx):layout()
    end
end

function BattleLayer:updateMiningAtlasRetInfo()
    if Battle.battleType ~= BATTLE_TYPE_MINING_ATLAS then
        return
    end

    if table.count(gDigMine.atlasRets) == 0 or gDigMine.atlasRets.types == nil then
        return
    end

    for idx,retType in pairs(gDigMine.atlasRets.types) do
        if retType == MINE_ATLAS_RET_CONDITION1 then
            local curHpRate = (self:getMyRolesCurHp() / self.totalInitHp1) * 100
            if curHpRate < gDigMine.atlasRets.values[idx] and self.miningAtlasRets[idx] then
                self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                self.miningAtlasRets[idx] = false
            end
        elseif retType == MINE_ATLAS_RET_CONDITION2 then
            local deadNum = 0
            for _, role in pairs(self.myRoles) do
                if(role.isDead and (not role:isPet())) then
                    deadNum = deadNum + 1
                end
            end

            if deadNum >= gDigMine.atlasRets.values[idx] and self.miningAtlasRets[idx] then
                self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                self.miningAtlasRets[idx] = false
            end
        elseif retType == MINE_ATLAS_RET_CONDITION4 then
            if self.miningAtlasRets[idx] and self:hasTheCountryInMySide(gDigMine.atlasRets.values[idx]) then
                self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                self.miningAtlasRets[idx] = false
            end
        elseif retType == MINE_ATLAS_RET_CONDITION6 then
            local hasLowHp = false
            for _, role in pairs(self.myRoles) do
                if not role:isPet() then
                    if role.bloodNode.curRed*100/role.bloodNode.maxRed < gDigMine.atlasRets.values[idx] then
                        hasLowHp = true
                        break
                    end
                end
            end

            if hasLowHp and self.miningAtlasRets[idx] then
                self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                self.miningAtlasRets[idx] = false
            end
        elseif retType == MINE_ATLAS_RET_CONDITION7 then
            if not self.miningAtlasRets[idx] then
                local count = self:getCountryNumsByRoles(self.myRoles)
                if count >= toint(gDigMine.atlasRets.values[idx]) then
                    self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
                    self.miningAtlasRets[idx] = true
                end
            end
        end
    end
end

function BattleLayer:getMiningAtalsStarNum()
    local starNum = 0
    for _,var in pairs(self.miningAtlasRets) do
        if var then
            starNum = starNum + 1
        end
    end

    return starNum
end

function BattleLayer:hasTheCountryInMySide(country)
    for _,role in pairs(self.myRoles) do
        local card = DB.getCardById(role.curCardid)
        if (nil ~= card) then
            if card.country == country then
                return true
            end
        end
    end

    return false
end

function BattleLayer:updateMiningAtlasRetInfoByEnd()
    if Battle.battleType ~= BATTLE_TYPE_MINING_ATLAS then
        return
    end

    if Battle.curBattleGroup == Battle.maxBattleGroup then
        for idx,retType in pairs(gDigMine.atlasRets.types) do
            if retType == MINE_ATLAS_RET_CONDITION3 then
                if self:isAllDead(2) and not self.miningAtlasRets[idx] then
                    self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
                    self.miningAtlasRets[idx] = true
                else
                    self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                    self.miningAtlasRets[idx] = false
                end
            elseif retType == MINE_ATLAS_RET_CONDITION5 then
                if self:isAllDead(2) and gDigMine.atlasRets.values[idx] >= self.finalRound and not self.miningAtlasRets[idx] then
                    self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-gou2.png")
                    self.miningAtlasRets[idx] = true
                else
                    self:changeTexture("mine_atlas_ret_flag"..idx, "images/ui_public1/n-di-x.png")
                    self.miningAtlasRets[idx] = false
                end
            end
        end
    end
end

function BattleLayer:getCountryNumsByRoles(roles)
    local country={}
    for _, role in pairs(roles) do
        local card = DB.getCardById(role.curCardid)
        if nil ~= card then
            if country[card.country] == nil then
                country[card.country]=0
            end

            country[card.country]=country[card.country]+1
        end
    end

    return table.count(country)
end

function BattleLayer:showConstellationFla()

    if gBattleData.circleId1 ~= nil then
        loadFlaXml("ui_xingzhen")
        local fla = gCreateFla("xingzhen_"..gBattleData.circleId1,1)
        self:replaceNode("fla_constellation1",fla)
        self:getNode("layer_constellation1"):setVisible(true)
    else
        local selCircleId = gConstellation.getSelCircleId()
        if selCircleId ~= nil and selCircleId ~= 0 then
            local isAllActive = gConstellation.isAllGroupActived(selCircleId)
            if isAllActive then
                loadFlaXml("ui_xingzhen")
                local fla = gCreateFla("xingzhen_"..selCircleId,1)
                self:replaceNode("fla_constellation1",fla)
                self:getNode("layer_constellation1"):setVisible(true)
            end
        end
    end

    if gBattleData.circleId2 ~= nil and gBattleData.circleId2 ~= 0 then
        loadFlaXml("ui_xingzhen")
        local fla = gCreateFla("xingzhen_"..gBattleData.circleId2,1)
        self:replaceNode("fla_constellation2",fla)
        self:getNode("layer_constellation2"):setVisible(true)
    end
end



return BattleLayer