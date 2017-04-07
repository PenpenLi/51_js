local WorldBossPanel=class("WorldBossPanel",UILayer)

function WorldBossPanel:ctor(data)
    --读取合图
    if(cc.FileUtils:getInstance():isFileExist("packer/images_bg_010_bg10_.plist"))then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/images_bg_010_bg10_.plist")
    end
    self:init("ui/ui_shijieboss.map")

    -- self.isMainLayerGoldShow=false
    -- self.isMainLayerCrusadeShow=true

    -- self:setSound(false)
    self:getNode("lay_fight_newboss"):setVisible(false)

    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.data = Data.worldBossInfo
    self.data.refreshPosTime = gGetCurServerTime()
    -- self.data.status = 0
    self.gameStatus = 0 -- 赛前0、时间到未进入1、进入2、进入战败3
    if (self.data.status == 0) then
        self.gameStatus = 0
    elseif (self.data.status == 1) then--从外面进来直接进入战斗界面
        self.gameStatus = 2
    elseif (self.data.status == 2) then
        self.gameStatus = 3
    end
    
    self.refreshTimeValu = 5
    self.bolUpAtt = false--是否有上届击杀
    self.bosBossAttack = false --是否boss攻击状态
    self.posIndex = {}
    self.maxLen = 31
    for i=1,self.maxLen do
        table.insert(self.posIndex,i)
    end
    --洗牌
    local size = #self.data.oldlist
    -- local delete_count = 0
    for k,v in pairs(self.data.oldlist) do
        if (v and v.rank==0) then
            -- delete_count = delete_count + 1
            self.bolUpAtt = true
        end
    end
    size = size - (self.bolUpAtt and 1 or 0)
    ------------测试------------start
    -- for i=size,self.maxLen do
    --     table.insert(self.data.oldlist,self.data.oldlist[1])
    -- end
    -- size = #self.data.oldlist
    -- Data.worldBossInfo.starttime = gGetCurServerTime() + 5
    -- Data.worldBossInfo.iEndNotice = 0
    ------------测试------------end
    local minsize = 20
    if (size<minsize) then
        local tmpIndex = {}
        for i=1,minsize do
            table.insert(tmpIndex,i)
        end
        self:getRandNumber(tmpIndex,minsize)--随机 20
        self.posIndex = {}
        for i=1,self.maxLen do
            if (i<=minsize) then
                table.insert(self.posIndex,tmpIndex[i])
            else
                table.insert(self.posIndex,i)
            end
        end
    else
        self:getRandNumber(self.posIndex,self.maxLen)
    end

    -- print_lua_table(self.posIndex)
 
    --伤害值获得金币 比例
    local goldpro = 100
    local bossd = DB.getBossData(self.data.bosslv)
    if (bossd~=nil) then
        goldpro = bossd.goldpro
    end
    Data.worldBossInfo.goldpro = goldpro

    -- print(self.data.status,self.gameStatus)

    self:setData()

    self:changeTag()

    local function _update()
        self:update()
    end
    self:scheduleUpdate(_update,1)
    self:getNode("btn_rank"):setVisible(not Module.isClose(SWITCH_VIP))
    self:resetLayOut();
end

function WorldBossPanel:onUILayerExit()
    self:unscheduleUpdateEx();
end

function WorldBossPanel:setPos( ... )
    -- body
end

function WorldBossPanel:setSound(bolSound)
    ccs.ArmatureDataManager:getInstance():setSoundPlay(bolSound)
end

function WorldBossPanel:getRandNumber(tb,length)  
    local index = 0 
    local value = 0  
    local median = 0
    local size = #tb
  
    if(size == 0 or 0 == length) then
        return
    end

    for index=1,length do
        value = math.random(1,length)
        median = tb[index]
        tb[index] = tb[value]
        tb[value] = median
    end
end

function WorldBossPanel:getNextAddFightNumTime()
    -- 下次加点剩余时间
    local curTime = gGetCurServerTime() - gGetTimeZoneOffsetToZone8();
    local timeDate = os.date("*t", curTime);

    local minHour = 24
    local nextDay = true
    local nextMinHour = minHour
    local curdaytime = os.time({year=timeDate.year,month=timeDate.month,day=timeDate.day,hour=0})

    for _,dur in pairs(Data.worldBossParam.add_cnum_time) do
        if curdaytime+dur*3600 - curTime >= 0 and dur < minHour then
            minHour = dur
            nextDay = false
        end

        if dur < nextMinHour then
            nextMinHour = dur
        end
    end

    local nxtime = curdaytime
    if nextDay then
        nxtime = nxtime + nextMinHour*3600 + 24*3600
    else
        nxtime = nxtime + minHour*3600
    end

    -- 战斗返回的时间处理
    local logCurTime = 0
    local logNextLeftTime = 0
    if not Data.worldBossInfo.logCurTime then
        logCurTime = curTime
    else
        logCurTime = Data.worldBossInfo.logCurTime
    end
    if not Data.worldBossInfo.logNextLeftTime then
        logNextLeftTime = nxtime - curTime
    else
        logNextLeftTime = Data.worldBossInfo.logNextLeftTime
    end

    Data.worldBossInfo.logCurTime = curTime
    Data.worldBossInfo.logNextLeftTime = nxtime - curTime

    local offset = logNextLeftTime + logCurTime - curTime
    local bAdd = false
    if offset <= 0 then
        bAdd = true
        Data.worldBossInfo.logNextLeftTime = 24*3600
    end

    return nxtime - curTime,bAdd
end

function WorldBossPanel:update()
    -- 获得下个战斗点数倒计时
    if self:getNode("lay_fight_newboss"):isVisible() then
        local lefttime,bAdd = self:getNextAddFightNumTime()
        local str = gParserHourTime(lefttime)
        self:setLabelString("txt_addtime_new",str)

        local addnum = Data.worldBossParam.add_cnum_params[1]
        local max = Data.worldBossParam.add_cnum_params[2]
        local cur = Data.worldBossInfo.fnum

        if bAdd == true and Data.worldBossInfo.fnum < max then
            cur = cur + addnum
        end

        if cur > max and Data.worldBossInfo.fnum < max then
            cur = max
        end

        if cur ~= Data.worldBossInfo.fnum then
            Data.worldBossInfo.fnum = cur
            self:refreshFightNum()
        end

        self:replaceLabelString("txt_addnum_new",addnum)

        self:getNode("txt_addtime_new"):getParent():layout()
    end

    -- print("===="..Data.worldBossInfo.endtime)
    if (Data.worldBossInfo.iEndNotice and (Data.worldBossInfo.iEndNotice==1 or Data.worldBossInfo.iEndNotice==3)) then
        if (Data.worldBossInfo.iEndNotice==1) then
            --播放死亡动作
            self:createBossAction(4)
            Data.worldBossInfo.iEndNotice = 2
            Data.worldBossInfo.ifkill = true

            local function playEnd()
                self:bolBossDead(true)
                Data.worldBossInfo.iEndNotice = 0
            end
            local func = cc.CallFunc:create(playEnd)
            local action=cc.Sequence:create(cc.DelayTime:create(0.9),func)
            self:runAction(action)
        elseif (Data.worldBossInfo.iEndNotice==3) then
            Data.worldBossInfo.iEndNotice = 2
            Data.worldBossInfo.endtime = nil
            Data.worldBossInfo.ifkill = false
            self:bolBossDead(true)
            self:getNode("lab_endtime"):setVisible(false)
            Data.worldBossInfo.endtime = nil
            for i=1,2 do
                self:createEnemyAction(i,0)
            end
            self:createBossAction(0)
        end
        return
    end

    if (Data.worldBossInfo.iEndNotice==2) then return end

    --倒计时
    local time = 0
    local word=0
    if (Data.worldBossInfo.endtime) then
        time = Data.worldBossInfo.endtime-gGetCurServerTime()
        word=gParserHourTime(time);
        self:replaceLabelString("lab_endtime",word);--多久后消失
        if (time<=0) then
            -- self.gameStatus = 0
            -- self:refreshStatus()
            self:getNode("lab_endtime"):setVisible(false)
            Data.worldBossInfo.endtime = nil
        end
    end
    
    if (Data.worldBossInfo.starttime) then
        time = Data.worldBossInfo.starttime-gGetCurServerTime()
        word=gParserHourTime(time);
        self:setLabelString("lab_starttime",word);--多久开始
        if (self.gameStatus == 0 and (time==0)) then--时间到了 进入准备状态
            self.gameStatus = 1
            -- --播放动画
            -- self:moveRole()
            -- self:moveBoss(0.8)
            -- self:refreshStatus()
            --取数据
            Net.sendWorldBossInfo(1)
        end
    end

    --复活倒计时 txt_reset_lefttime
    if (Data.worldBossInfo.fighttime) then
        time = Data.worldBossInfo.fighttime-gGetCurServerTime()
        word=gParserHourTime(time);
        self:setLabelString("txt_reset_lefttime",word);--多久开始
        -- print("time="..time)
        if (time==0) then
            self:getNode("btn_relive"):setVisible(false)
            self:enterFightLayer()
        end
    end

    --刷新数据
    if (self.gameStatus == 2 and Data.worldBossInfo.endtime) then
        local rtime = gGetCurServerTime() - self.data.refreshPosTime
        -- print("rtime="..rtime)
        if (rtime >= self.refreshTimeValu) then
            self.refreshTimeValu = getRand(3,8)
            self.data.refreshPosTime = gGetCurServerTime()
            self.oldHitValue = self.data.hp
            Net.sendWorldBossRefresh()
        end
    end
end

function WorldBossPanel:refreshFightNum()
    local cur = Data.worldBossInfo.fnum
    local max = Data.worldBossParam.add_cnum_params[2]
    self:setLabelString("txt_fight_num",cur.."/"..max)
end

function WorldBossPanel:getRankReward(rank)
    for k,v in pairs(worldbossreward_db) do
        if (rank>=v.minlv and rank<=v.maxlv and self.data.bosstype == v.bosstype) then
            return v
        end
    end
    return nil
end

function WorldBossPanel:playBossHitSound()
    gPlayEffect("sound/bg/bgm_Win.mp3")
end

function WorldBossPanel:refreshStatus()
    self:getNode("layer_enter"):setVisible(false)
    self:getNode("layer_first"):setVisible(false)
    self:getNode("btn_enter"):setVisible(false)--挑战按钮
    self:getNode("lab_starttime"):setVisible(false)--开始时间
    self:getNode("lab_open_time"):setVisible(false)--开启时间点
    self:getNode("layer_wang"):setVisible(false)
    self:getNode("layer_hit"):setVisible(false)
    self:getNode("lay_fight_newboss"):setVisible(false)
    if (self.gameStatus==0) then
        self:getNode("layer_first"):setVisible(true)
        self:getNode("lab_starttime"):setVisible(true)
        self:getNode("lab_open_time"):setVisible(true)
        self:getNode("layer_wang"):setVisible(true)
    elseif (self.gameStatus==1) then
        self:getNode("layer_first"):setVisible(true)
        self:getNode("btn_enter"):setVisible(true)
        self:getNode("layer_wang"):setVisible(true)
        if (not self.bosBossAttack) then
            self:getNode("layer_hit"):setVisible(true)
        end
    elseif (self.gameStatus==2) then
        self:getNode("layer_enter"):setVisible(true)
        if (not self.bosBossAttack) then
            self:getNode("layer_hit"):setVisible(true)
        end
    elseif (self.gameStatus==3) then
        self:getNode("layer_first"):setVisible(true)
        -- self:getNode("layer_enter"):setVisible(true)
    end
end

function WorldBossPanel:clearImage()
    for i=1,self.maxLen do
        self:getNode("role"..i):removeAllChildren();
        self:getNode("role"..i.."_1"):removeAllChildren();
    end
    for i=1,2 do
        self:getNode("enemy"..i):removeAllChildren();
    end
    self:getNode("boss"):removeAllChildren();
    self:getNode("boss_1"):removeAllChildren();
end

function WorldBossPanel:refreshBossInfo()
    --魔兽头像等级
    local word = nil;
    if(Data.worldBossInfo.bosstype == 0) then
        word = gGetWords("worldBossWords.plist","11");
    else
        word = gGetWords("worldBossWords.plist","dog_name_lv");
    end
    word = gReplaceParam(word,Data.worldBossInfo.bosslv);
    self:setLabelString("txt_monter_name",word);
    --self:replaceLabelString("txt_monter_name",Data.worldBossInfo.bosslv)

    --魔兽下方等级
    self:setLabelString("lab_m_info",word)
end

function WorldBossPanel:setData(runAction,type)
    -- local data = Data.worldBossInfo
    self.data = Data.worldBossInfo
    if (type) then
    else
        type = 0
    end
    
    self:refreshStatus()

    --上届排行
    loadFlaXml("heiren")
    for i=1,3 do
        self:setLabelString("lab_rank_name"..i,"")
        self:getNode("role_bg"..i):removeAllChildren();
        local fla=gCreateFla("heiren_wait",1)
        if (fla) then
            fla:setScale(0.7)
            gAddCenter(fla,self:getNode("role_bg"..i))
        end
        self:getNode("rank_name"..i.."_bg"):setVisible(false)
    end
    
    local path_today1 = "images/ui_boss/jishao.png"
    local path_today2 = "images/ui_boss/jishao_2.png"
    self:changeTexture("up_today",self.bolUpAtt and path_today1 or path_today2);
    -- self:getNode("up_today"):setVisible(self.bolUpAtt)--没有上一届隐藏

    self:setLabelString("lab_taday_name","")
    if (self.gameStatus==0 or self.gameStatus==1) then
        for k,v in pairs(self.data.oldlist) do
            if (v and v.rank>=0) then
                if (v.rank==0) then--上届击杀
                    Icon.setHeadIcon(self:getNode("icon_today"),v.icon);
                    self:setLabelString("lab_taday_name",v.name)
                elseif (v.rank<4) then
                    gCreateRoleFla(Data.convertToIcon(v.icon),self:getNode("role_bg"..v.rank),0.7,true,nil,nil,v.show.wkn and v.show.wkn or nil);
                    self:setLabelString("lab_rank_name"..v.rank,v.name)
                    self:getNode("rank_name"..v.rank.."_bg"):setVisible(true)
                end
            end
        end
    end

    if (self.gameStatus == 0) then
        local openTimeStr = ""
        if self.data.bosstype == 1 then--isNewBossCurDay() then
            openTimeStr = gGetOpenDaysFormateStr(DB.getClientParam("WORLD_BOSS_NEW_DAY"),DB.getClientParam("WORLD_BOSS_NEW_TIME"))
        else
            openTimeStr = gGetOpenDaysFormateStr(DB.getOpenDayOfWorldBoss(),DB.getOpenTimeOfWorldBoss())
        end
        self:setLabelString("lab_open_time",openTimeStr)
    end

    local wordBossNameLv = nil;
    if(Data.worldBossInfo.bosstype == 0) then
        wordBossNameLv = gGetWords("worldBossWords.plist","11");
    else
        wordBossNameLv = gGetWords("worldBossWords.plist","dog_name_lv");
    end
    wordBossNameLv = gReplaceParam(wordBossNameLv,self.data.bosslv);
    
    --self:replaceLabelString("lab_m_info",self.data.bosslv)--魔兽等级
    self:setLabelString("lab_m_info",wordBossNameLv)

    --人物
    if (type==0) then
    for i=1,self.maxLen do
        local index = self.posIndex[i]
        self:getNode("role"..index):removeAllChildren();
        local info = self.data.oldlist[i]
        if (info and info.rank ~= 0) then
            if (runAction) then
            else
                if (self.gameStatus==3) then
                    self:createRoleAction(info,index,3)
                elseif (self.gameStatus==0) then
                    self:createRoleAction(info,index,0)
                else
                    self:createRoleAction(info,index,2)
                end
            end
        end
    end
    end
    --boss
    if (runAction) then
    else
        self:createBossAction(self.gameStatus==0 and 0 or 3)
    end
    --小兵
    self:setEnemy()

    --鼓舞
    local count = math.min(self.data.powernum+1,Data.worldBossParam.power_max)
    -- print("count==========="..count)
    local needDia = Data.worldBossParam.power_need_diamond[count]
    self:setLabelString("lab_gold",needDia)
    self:setLabelString("lab_gold1",needDia)
    local time = Data.worldBossParam.power_max-Data.worldBossInfo.powernum
    local bolFull = (time<=0 and true or false)
    self:getNode("add_full"):setVisible(bolFull)
    self:getNode("add_full1"):setVisible(bolFull)

    --return
    if (self.gameStatus==0 or self.gameStatus==3) then return end

    self:setLabelString("txt_monter_name",wordBossNameLv);
    --self:replaceLabelString("txt_monter_name",self.data.bosslv)--魔兽等级
    --头像
    if (self.data.bossid~=0) then
        if(cc.FileUtils:getInstance():isFileExist("images/icon/head/"..self.data.bossid.."_2.png"))then
            self:changeTexture("icon_monster","images/icon/head/"..self.data.bossid.."_2.png")
        else
            self:changeTexture("icon_monster","images/icon/head/"..self.data.bossid..".png")
        end
    end

    if self.data.bosstype == 0 then
        self:setLabelString("txt_total_hp",gFloor2Point(self.data.hp/self.data.hpmax).."%")
    else
        self:setLabelString("txt_total_hp","")
    end
    -- self:setLabelString("txt_total_hp",self.data.hp.."/"..self.data.hpmax)
    -- self:setBarPer2("bar_monster",self.data.hp,self.data.hpmax)--进度条
    self:setBarPer("bar_monster",self.data.hp/self.data.hpmax,true)
    self:setBarPerAction("bar_monster2",nil,self.data.hp/self.data.hpmax,nil,true)
    self:setBossBarBg()

    -- self:replaceRtfString("lab_att",self.data.attacknum)--已攻击几次
    self:replaceRtfString("lab_add",self.data.powernum*Data.worldBossParam.power)--加成
    -- local damage_add = math.floor((self.data.damage/self.data.hpmax)*100)
    -- if (damage_add>0) then
    --     self:replaceRtfString("lab_all_att",self.data.damage.."（"..gFloor2Point(self.data.damage/self.data.hpmax).."%）")--总伤害
    -- else
    --     self:replaceRtfString("lab_all_att",self.data.damage)--总伤害
    -- end
    
    --排名
    self:getNode("rank_no"):setVisible(false)--空标志
    self:getNode("scroll"):clear()
    local size = #self.data.list
    if (size<=0) then
        self:getNode("rank_no"):setVisible(true)--空标志
    else
        for key, value in pairs(self.data.list) do
            local item=WorldBossItem.new()
            item:setData(value,key)
            self:getNode("scroll"):addItem(item)
        end
        self:getNode("scroll"):layout()
    end

    --排行奖励
    local reward = self:getRankReward(self.data.rank)
    for i=1,3 do
        self:getNode("rew_icon"..i):removeAllChildren();
        self:getNode("rew_icon"..i):setVisible(true)
    end
    if (reward ~= nil and self.data.rank>0) then
        local rnumpro = 1
        local bossd = DB.getBossData(self.data.bosslv)
        if (bossd~=nil) then
            rnumpro = bossd.rnumpro/100
        end
        --获取物品
        if (reward.itemid1>0) then
             Icon.setDropItem(self:getNode("rew_icon1"), (reward.itemid1),math.floor(reward.itemnum1*rnumpro),DB.getItemQuality(reward.itemid1))
        else self:getNode("rew_icon1"):setVisible(false) end
        if (reward.itemid2>0) then
             Icon.setDropItem(self:getNode("rew_icon2"), (reward.itemid2),math.floor(reward.itemnum2),DB.getItemQuality(reward.itemid2))
        else self:getNode("rew_icon2"):setVisible(false) end
        if (reward.itemid3>0) then
             Icon.setDropItem(self:getNode("rew_icon3"), (reward.itemid3),math.floor(reward.itemnum3),DB.getItemQuality(reward.itemid3))
        else self:getNode("rew_icon3"):setVisible(false) end
    end
    --累加输出奖励
    self:getNode("rew_icon4"):removeAllChildren();
    self:getNode("rew_icon4"):setVisible(true)
    local rewgold4 = 0
    if (self.data.allmoney and self.data.allmoney>0) then
        rewgold4 = self.data.allmoney
        -- rewgold4 = math.floor(self.data.allmoney * (0.9 * (350000 / (350000 + self.data.allmoney)) + 0.05))
        -- rewgold4 = math.floor(self.data.damage/(Data.worldBossInfo.goldpro/100))
        Icon.setDropItem(self:getNode("rew_icon4"), (90002),math.floor(rewgold4),DB.getItemQuality(90002))
    end

    --击杀按钮
    self:getNode("btn_relive"):setVisible(false)
    self:getNode("layer_fight"):setVisible(false)
    self:getNode("lay_fight_newboss"):setVisible(false)
    local fighttime =(Data.worldBossInfo.fighttime-gGetCurServerTime());
    -- print()
    if (not self.data.ifkill and self.data.attacknum>0 and fighttime>0 and self.data.bosstype == 0) then --复活按钮
        self:getNode("btn_relive"):setVisible(true)
        -- local size = #Data.worldBossParam.reborn_need_diamond
        -- local index = self.data.attacknum
        -- if (index>size) then
        --     index = size
        -- elseif (index<=0) then
        --     index = 1
        -- end
        self:setLabelString("lab_gold_r",Data.worldBossParam.reborn_need_diamond[self:getNeedDiaIndex()])
        self:getNode("relive_layout"):layout()
    else
        self:enterFightLayer()
    end
end

function WorldBossPanel:enterFightLayer()
    if self.data.bosstype == 1 and self.gameStatus ~= 0 then
        self:getNode("layer_fight"):setVisible(false)
        self:getNode("lay_fight_newboss"):setVisible(true)
        self:refreshFightNum()
    else
        self:getNode("layer_fight"):setVisible(true)
        self:getNode("lay_fight_newboss"):setVisible(false)
    end
end

function WorldBossPanel:setBossBarBg()

    local di1 = "images/ui_fight/shilian_headdi1.png"
    local di4 = "images/ui_fight/shilian_headdi4.png"
    local hp = (gFloor2Point(self.data.hp/self.data.hpmax))
    local index = 1
    local act = self:getNode("txt_monter_name")
    if (hp<=5) then
        act:stopAllActions()
        local playAction = function()
            index = index + 1
            if (index>2) then
                index = 1
            end
            self:changeTexture("bar_bg",index==1 and di1 or di4);
        end
        act:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.DelayTime:create(0.1),
                    cc.CallFunc:create(playAction))
                ))
        self:setLabelString("txt_total_hp","")
    else
        act:stopAllActions()
        self:changeTexture("bar_bg",di1);
    end
end

function WorldBossPanel:createEnemyAction(index,type)
    local fla = nil
    local node = self:getNode("enemy"..index)
    node:removeAllChildren()
    local icon = Data.convertToIcon(10501)
    local fla=FlashAni.new()
    fla:setSoundPlay(false)
    if (index == 1) then
       fla:setSoundPlay(true)
    end
    fla.actIdx = 1
    local actions={}
    if (type==0) then--待机
        table.insert(actions,"wait")
    elseif(type==1) then
        table.insert(actions,"wait")
        table.insert(actions,"attack_s")
    end
    loadFlaXml("r"..icon)
    local function  playEnd()
        fla.actIdx = (getRand(0,100) <80 and (table.getn(actions)>1 and 2 or 1) or 1)
        fla:playAction("r"..icon.."_"..actions[fla.actIdx],playEnd)
    end
    fla:playAction("r"..icon.."_"..actions[fla.actIdx],playEnd)
    fla:setScale(0.7)
    gAddCenter(fla,node)
    if fla then
        fla:setScaleX(-0.7);
        --加影子
        local shadow=cc.Sprite:create("images/battle/shade_ui.png")
        shadow:setScaleY(0.7)
        fla:addChild(shadow,-1)
    end
end

function WorldBossPanel:createBossAction(type)
    local fla = nil
    local node = self:getNode("boss")
    node:removeAllChildren()
    
    local icon = Data.convertToIcon(self.data.bossid)
    local fla=FlashAni.new()
    fla.actIdx = 1
    local actions={}
    if (type==0) then--待机
        table.insert(actions,"wait")
        node = self:getNode("boss_1")
    elseif(type==1) then--走
        table.insert(actions,"run")
    elseif(type==3) then --被击
    --     table.insert(actions,"hited_all")
    --     node = self:getNode("boss_1")
    -- elseif(type==5) then
        table.insert(actions,"wait")
        table.insert(actions,"hited_all")
        table.insert(actions,"attack_b")
        node = self:getNode("boss_1")
        fla.tmp_status = 1
        fla.tmp_count = 0
        fla.actIdx = 1 --待机
    elseif(type==4) then--死亡
        table.insert(actions,"dead")
        node = self:getNode("boss_1")
    else
        table.insert(actions,"attack_b")
        table.insert(actions,"wait")
        node = self:getNode("boss_1")
        fla.actIdx = 2
    end
    node:removeAllChildren()
    
    loadFlaXml("r"..icon)
    local function  playEnd()
        if (type == 3) then
            if (fla.tmp_status == 1) then --待机
                fla.tmp_count = fla.tmp_count + 1
                -- print("1 = fla.tmp_count="..fla.tmp_count)
                if (fla.tmp_count>getRand(1,2)) then
                    fla.tmp_count = 0
                    fla.tmp_status = 2
                    fla.actIdx = 2
                end
            elseif (fla.tmp_status == 2) then --被击败
                fla.tmp_count = fla.tmp_count + 1
                -- print("2 = fla.tmp_count="..fla.tmp_count)
                if (fla.tmp_count>getRand(0,6)) then
                    fla.tmp_count = 0
                    fla.tmp_status = 3
                    fla.actIdx = 3
                    self.bosBossAttack = true
                    --隐藏被击
                    self:getNode("layer_hit"):setVisible(false)
                end
            elseif (fla.tmp_status == 3) then --攻击
                fla.tmp_count = fla.tmp_count + 1
                -- print("3 = fla.tmp_count="..fla.tmp_count)
                if (fla.tmp_count>0) then
                    fla.tmp_count = 0
                    fla.tmp_status = 1
                    fla.actIdx = 1
                    self.bosBossAttack = false
                    self:getNode("layer_hit"):setVisible(true)
                end
            end
        else
            fla.actIdx = (getRand(0,100) <80 and (table.getn(actions)>1 and 2 or 1) or 1)
        end
        fla:playAction("r"..icon.."_"..actions[fla.actIdx],playEnd)
    end
    if (type==4) then
       fla:playAction("r"..icon.."_"..actions[fla.actIdx],nil,nil,0)
    else
       fla:playAction("r"..icon.."_"..actions[fla.actIdx],playEnd)
    end
    fla:setScale(0.7)
    gAddCenter(fla,node)

    if fla then
        fla:setScaleX(-0.7);
        --加影子
        local shadow=cc.Sprite:create("images/battle/shade_ui.png")
        shadow:setScale(3)
        fla:addChild(shadow,-1)
    end
end

function WorldBossPanel:createRoleAction(info,index,type,bolDelay)
    local fla = nil
    local node = self:getNode("role"..index)
    node:removeAllChildren()
    local delay = nil
    if (bolDelay) then
        delay = bolDelay
    end
    
    local icon = Data.convertToIcon(info.icon)
    loadFlaXml("r"..icon,nil,info.show.wkn) 
    local fla=FlashAni.new()
    if(info.show.wkn)then
        local maxWeapon= nil
        local maxAwake= nil 
        maxWeapon,maxAwake= gGetMaxWeaponAwakeId(icon) 
        fla:setSkinId(info.show.wkn,maxAwake)
    end
    fla:setSoundPlay(false)
    if (math.mod(index,5) == 1) then
       fla:setSoundPlay(true)
    end
    fla.actIdx = 1
    fla.bolOne = true
    local actions={}
    if (type==0) then
        table.insert(actions,"wait")
    elseif(type==1) then
        table.insert(actions,"run")
    elseif(type==3) then --胜利
        table.insert(actions,"win")
        node = self:getNode("role"..index.."_1")
    else
        table.insert(actions,"wait")
        table.insert(actions,"attack_s")
        node = self:getNode("role"..index.."_1")
        fla.actIdx = 2
    end
    node:removeAllChildren()
    
    local function  playEnd()
        fla.actIdx = (getRand(0,100) <80 and (table.getn(actions)>1 and 2 or 1) or 1)
        fla:playAction("r"..icon.."_"..actions[fla.actIdx],playEnd)
    end

    if ((type==0 or type==2) and fla.bolOne and delay==nil) then
        fla.bolOne = false
        local func = cc.CallFunc:create(playEnd)
        local action=cc.Sequence:create(cc.DelayTime:create(0.1*getRand(0,5)+0.01*getRand(0,9)),func)
        fla:runAction(action)
    else
        fla:playAction("r"..icon.."_"..actions[fla.actIdx],playEnd)
    end
    fla:setScale(0.7)
    gAddCenter(fla,node)

    if (fla) then
        --加名字
        local bolMe = (info.userid == Data.getCurUserId() and true or false)
        local labWord = gCreateWordLabelTTF(info.name,gFont,24,bolMe and cc.c3b(96,255,0) or cc.c3b(255,255,255));
        labWord:enableOutline(cc.c4b(0,0,0,255),24*0.1);

        -- labWord:setPositionY(180)
        -- local posx = (labWord:getContentSize().width-node:getContentSize().width)/2
        -- labWord:setPositionX((posx))
        -- labWord:setAnchorPoint(cc.p(0.5,0.5))
        -- fla:addChild(labWord)
        -- gAddCenter(labWord,node)
        node:addChild(labWord)
        labWord:setPositionY(160)
        labWord:setPositionX(node:getContentSize().width/2)

        -- node:addChild(labWord)
        --加me
        if (bolMe) then
            local me=cc.Sprite:create("images/ui_family/ME.png")
            -- me:setPosition(cc.p(0,170));
            -- fla:addChild(me)
            gAddCenter(me,node)
            me:setPositionY(190)
        end
        --add 黑影
        local shadow=cc.Sprite:create("images/battle/shade_ui.png")
        shadow:setScaleY(0.7)
        fla:addChild(shadow,-1)
    end
end

function WorldBossPanel:bossStatus()
    -- if (getRand(0,8)<6) then
    --     self:createBossAction(3)
    -- end
    -- local function onFunc()
    --     self:getNode("boss_1"):stopAllActions()
    --     if (getRand(0,8)<6) then
    --         self:createBossAction(6)
    --     else
    --         self:createBossAction(3)
    --     end
    -- end
    -- local func = cc.CallFunc:create(onFunc)
    -- local action=cc.Sequence:create(cc.DelayTime:create(getRand(0,2)),func)
    -- self:getNode("boss_1"):runAction(action)
end

function WorldBossPanel:moveBoss(time)
    local enemy_posx = -80
    self:getNode("boss"):stopAllActions()
    local enemy_move_left = cc.MoveBy:create(time, cc.p(enemy_posx,0))
    local function onFunc()
        self:getNode("boss"):stopAllActions()
        self:createBossAction(3)
    end
    self:createBossAction(1)
    local func = cc.CallFunc:create(onFunc)
    local action=cc.Sequence:create(enemy_move_left,cc.DelayTime:create(0.2),func)
    self:getNode("boss"):runAction(action)
end

function WorldBossPanel:moveRole()
    -- print("-----------moveRole")
    -- print_lua_table(self.data.oldlist)
    -- self:createRoleAction(info,index,1)
    for i=1,self.maxLen do
        local index = self.posIndex[i]
        -- self:getNode("role"..index):removeAllChildren();
        -- print("index="..index)
        local oldPoint = cc.p(self:getNode("role"..index):getPosition())
        local newPoint = cc.p(self:getNode("role"..index.."_1"):getPosition())
        local info = self.data.oldlist[i]
        if (info and info.rank ~= 0) then
            self:createRoleAction(info,index,1)
            local posw = newPoint.x - oldPoint.x
            -- print("posw = "..posw)
            local function onFunc()--send,data
                -- local index = data.index
                -- local info = data.info
                -- self:getNode("role"..index):stopAllActions()
                self:getNode("role"..index):removeAllChildren();
                self:createRoleAction(info,index,2,true)
            end
            local func = cc.CallFunc:create(onFunc)--,{info=info,index=index}
            local move = cc.MoveTo:create(0.5+posw/1000,newPoint)
            local action=cc.Sequence:create(move,cc.DelayTime:create(0.1),func)
            self:getNode("role"..index):runAction(action)
        end
    end


    local function onFunc()
        --人物
        self:changeTag()
        self:getNode("layer_hit"):setVisible(true)
    end
    local func = cc.CallFunc:create(onFunc)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),func))

    --隐藏网
    self:getNode("layer_wang"):runAction(cc.FadeTo:create(0.4,0))
end

function WorldBossPanel:changeTag()
    local children = self:getNode("layer_role"):getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        local child = children[i + 1]
        if nil ~= child then
            local posy = math.floor(child:getPositionY())
            -- print(posy)
            child:setLocalZOrder(-posy)
        end
    end
end

function WorldBossPanel:onPopup()
    -- Net.sendWorldBossInfo(true)
end

function WorldBossPanel:onPushStack()
end

function WorldBossPanel:createRedNum(times)
    local layout = LayOutLayer.new(LAYOUT_TYPE_HORIZONTAL,-10);

    cc.SpriteFrameCache:getInstance():addSpriteFrames("packer/font.plist")

    local num = nil
    num = gCreateBattleWord("images/fonts/font_img/red_num/-.png");
    layout:addNode(num);
    --计算
    local strNum = tostring(times)
    local count = strNum:len();
    for i=1,count do
        local numOne = toint(string.sub(strNum,i,i));
        num = gCreateBattleWord("images/fonts/font_img/red_num/"..numOne..".png");
        layout:addNode(num);
    end
    -- end
    layout:layout();
    return layout;
end

function WorldBossPanel:playHitValue()
    --获取伤害值
    local hitvalue = self.oldHitValue - Data.worldBossInfo.hp 
    -- print("hitvalue"..hitvalue)
    if (hitvalue<=0) then return end

    -- self:bossStatus()

    local value = {}
    for i=1,4 do
        local tmpValue = math.floor(getRand(1,hitvalue/4))
        hitvalue = hitvalue - tmpValue
        table.insert(value,tmpValue)
    end
    table.insert(value,hitvalue)
    -- print_lua_table(value)
    local time = 0.5;
    local fontsize = 50
    for i=1,5 do
        local function onFunc()
            local labWord = self:createRedNum(value[i])
            -- local labWord = gCreateWordLabelTTF("-"..value[i],gCustomFont,fontsize,cc.c3b(255,0,0));
            -- labWord:enableOutline(cc.c4b(50,90,0,255),fontsize*0.1);
            labWord:setScale(0);
            labWord:runAction(cc.Sequence:create(
                                cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
                                cc.MoveBy:create(time,cc.p(0,100)),
                                cc.Spawn:create(cc.MoveBy:create(time,cc.p(0,100)),cc.FadeTo:create(time,0)),
                                cc.RemoveSelf:create()
                                ) );
            labWord:setPositionY(labWord:getPositionY()+25*(i-1));
            self:getNode("layer_hit"):addChild(labWord,100+i);
        end
        gCallFuncDelay((i-1)*(0.3+(0.1*getRand(1,4))),self,onFunc)
    end
end

function  WorldBossPanel:events()
    return {EVENT_ID_WORLD_BOSS_PLUS,
    EVENT_ID_WORLD_BOSS_ENTER,
    EVENT_ID_WORLD_BOSS_REBORN,
    EVENT_ID_WORLD_BOSS_REFRESH,
    EVENT_ID_WORLD_BOSS_INFO_REF,
    EVENT_ID_WORLD_BOSS_INFO_REF2,
    EVENT_ID_WORLD_BOSS_END,
    EVENT_ID_WORLD_BOSS_BUY_FIGHT_NUM,
    EVENT_ID_WORLD_BOSS_SWEEP,
    EVENT_ID_WORLD_BOSS_FIGHT
}
end

function WorldBossPanel:dealEvent(event,param)
    if(event==EVENT_ID_WORLD_BOSS_PLUS or event==EVENT_ID_WORLD_BOSS_REBORN)then
        self:setData(true,1)
    elseif (event==EVENT_ID_WORLD_BOSS_ENTER) then
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_WORLD_BOSS)
    elseif (event==EVENT_ID_WORLD_BOSS_REFRESH) then
        if (Data.worldBossInfo.status==2) then
            self.gameStatus = 3
        end
        self:playHitValue()
        self:setData(true)
        --被击动画
    elseif(event==EVENT_ID_WORLD_BOSS_INFO_REF) then
        self.gameStatus = 1
        --播放动画
        self:moveRole()
        self:moveBoss(0.8)
        self:setEnemy()
        self:refreshStatus()
        self:refreshBossInfo()
    elseif(event==EVENT_ID_WORLD_BOSS_INFO_REF2) then
        self.data = Data.worldBossInfo
        self.gameStatus = 0 -- 赛前0、时间到未进入1、进入2、进入战败3
        if (self.data.status == 0) then
            self.gameStatus = 0
        elseif (self.data.status == 1) then--从外面进来直接进入战斗界面
            self.gameStatus = 2
        elseif (self.data.status == 2) then
            self.gameStatus = 3
        end

        for k,v in pairs(self.data.oldlist) do
            if (v and v.rank==0) then
                self.bolUpAtt = true
                -- print("-----------bolUpAtt")
            end
        end
        -- print("----------self.gameStatus="..self.gameStatus)
        -- print("----------self.data.status="..self.data.status)
        -- print_lua_table(self.data)
        self:clearImage()
        self:setData()
    elseif(event==EVENT_ID_WORLD_BOSS_END) then --boss结束
        print("boss over notice")
        self:setLabelString("txt_total_hp","")
        self:setBarPer("bar_monster",0/self.data.hpmax,true)
        self:setBarPerAction("bar_monster2",nil,0/self.data.hpmax,nil,true)
        self:refreshBossInfo()
    elseif(event==EVENT_ID_WORLD_BOSS_BUY_FIGHT_NUM) then
        self:refreshFightNum()
    elseif(event==EVENT_ID_WORLD_BOSS_SWEEP)then
        self.data = Data.worldBossInfo
        self:setData(true)
        Panel.popUp(PANEL_WORLD_BOSS_FINAL,{sweep = true})
    elseif(event==EVENT_ID_WORLD_BOSS_FIGHT)then
        self.refreshFightNum()
    end
end

function WorldBossPanel:setEnemy()
    for i=1,2 do
        self:createEnemyAction(i,self.gameStatus==0 and 0 or 1)
    end
end

function WorldBossPanel:bolBossDead(show)
    local sWord = nil
    if (Data.worldBossInfo.ifkill) then
        sWord = gGetWords("worldBossWords.plist","bossDead_2",Data.worldBossInfo.kname);
    elseif (Data.worldBossInfo.endtime == nil) then
        sWord = gGetWords("worldBossWords.plist","bossDead_1");
    end
    if (sWord ~= nil) then
        if (show) then
            local function onOk()
                -- self:refreshStatus()
                Net.sendWorldBossInfo(3)
            end
            gConfirm(sWord,onOk)
        end
        return true
    end
    return false
end

function WorldBossPanel:getNeedDiaIndex()
    local size = #Data.worldBossParam.reborn_need_diamond
        local count = self.data.bnum
        -- print("count="..count)
        local index = 1
        for k,v in pairs(Data.worldBossParam.reborn_num) do
            if (count>=v) then
                index = k+1
            end
        end
        
        if (index>size) then
            index = size
        elseif (index<=0) then
            index = 1
        end
    return index
end

function WorldBossPanel:buyFightNum()
    Data.vip.wordbossnew.setUsedTimes(Data.worldBossInfo.buynum);
    local callback = function(num)
        Net.sendWorldBossBuyfnum(num)
    end
    Data.canBuyTimes(VIP_WORLD_BOSS_NEW_FIGHT,true,callback);
end

function WorldBossPanel:onTouchEnded(target)
    if (Data.worldBossInfo.iEndNotice==2) then return end

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_add" or target.touchName == "btn_add1" then
        local time = Data.worldBossParam.power_max-Data.worldBossInfo.powernum
        local count = Data.worldBossInfo.powernum + 1
        -- print("time=="..time)
        if (time<=0) then
            local sWord = gGetWords("worldBossWords.plist","full_add");
            gShowNotice(sWord)
            return--结束
        end
        -- if (self:bolBossDead()) then return end
        local callback = function()
            if (NetErr.isDiamondEnough(Data.worldBossParam.power_need_diamond[count]) == false) then
               return;
            end
            Net.sendWorldBossPlus(1)
        end
        local dia = Data.worldBossParam.power_need_diamond[count]
        local max = Data.worldBossParam.power_max
        gConfirmCancel(gGetWords("worldBossWords.plist","buy_info",dia,Data.worldBossParam.power,time,max),callback)
    -- elseif target.touchName == "btn_add_item" then
    --     local time = Data.worldBossParam.power_max-Data.worldBossInfo.powernum
    --     if (time<=0) then
    --         return--结束
    --     end
    --     local num = Data.getItemNum(ITEM_WORLD_BOSS)
    --     if (num<=0) then
    --         return
    --     end
    --     local callback = function()
    --         Net.sendWorldBossPlus(0)
    --     end
    --     local max = Data.worldBossParam.power_max
    --     gConfirmCancel(gGetWords("worldBossWords.plist","buy_info1",time,max),callback)
    -- elseif target.touchName == "btn_reborn" then
        
    elseif target.touchName == "btn_fight" or target.touchName == "btn_fight_new" then
        if (self:bolBossDead()) then return end
        if self.data.bosstype == 1 and Data.worldBossInfo.fnum < 1 then
            self:buyFightNum()
            return
        end
        Panel.pushRePopupPanel(PANEL_WORLD_BOSS)
        Net.sendWorldBossFight()
        -- Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_WORLD_BOSS)
    elseif target.touchName == "btn_relive" then--复活
        if (self:bolBossDead()) then return end
        -- print("index="..index)
        -- Data.worldBossParam.reborn_num
        local needDia = Data.worldBossParam.reborn_need_diamond[self:getNeedDiaIndex()]
        if (NetErr.isDiamondEnough(needDia) == false) then
            return;
        end
        Net.sendWorldBossReborn()
    elseif target.touchName == "btn_rank" or target.touchName == "btn_rank_new" then
        --Panel.popUpVisible(PANEL_ARENA_RANK,RANK_TYPE_BOSS,nil,true)
        Panel.popUpVisible(PANEL_WORLD_BOSS_RANK,nil,nil,true)
    elseif target.touchName == "btn_reward" then
        --Panel.popUpVisible(PANEL_WORLD_BOSS_REWARD,nil,nil,true)
        Net.sendWorldBossKillRewordInfo()
    elseif target.touchName == "btn_enter" then
        -- self:playHitValue()
        if (self.gameStatus==1) then
            self.gameStatus = 2
            -- self:setData(true)
            Net.sendWorldBossInfo(2)
        end
    elseif target.touchName == "btn_help" then
        gShowRulePanel(SYS_WORLD_BOSS)
        -- self:bossStatus()
        -- self:bolBossDead()
    elseif target.touchName == "btn_for" or target.touchName == "btn_for1" or target.touchName == "btn_for_new" then
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_WORLD_BOSS)
    elseif target.touchName == "btn_buy_new" then
        self:buyFightNum()
    elseif target.touchName == "btn_sweep_new" then
        local needVip = Data.worldBossParam.sweep_vip_lv[1]
        local needLv = Data.worldBossParam.sweep_vip_lv[2]
        if Data.getCurVip() < needVip and Data.getCurLevel() < needLv then
            gShowNotice(gGetWords("unlockWords.plist","unlock_worldboss_new_sweep",needLv,needVip))
            return
        end
        if self.data.bosstype == 1 and Data.worldBossInfo.fnum < 1 then
            self:buyFightNum()
            return
        end

        Net.sendWorldBossSweep()
    end
end


return WorldBossPanel