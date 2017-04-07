local AtlasEnterPanel=class("AtlasEnterPanel",UILayer)

function AtlasEnterPanel:ctor(data)
    self:init("ui/ui_atlas_enter.map")
    self.mapid=data.mapid
    self.stageid=data.stageid
    -- 0--代表普通 1--代表精英
    self.type=data.type
    if(self.type==0 and Data.isFirstEnterAtlas(data.mapid,data.stageid,data.type) )then
        local stage= DB.getStageById(data.mapid,data.stageid,10)
        if(stage)then
            self.curStage=stage
        end
    end
    if(self.curStage==nil)then
        self.curStage=DB.getStageById(data.mapid,data.stageid,data.type)
    end
    if(self.curStage)then
        self:setLabelString("txt_name",self.curStage.name)
        self:setLabelString("txt_info",self.curStage.des)

    end

    if(self.curStage.node==0)then
        self:getNode("icon_no_star"):setVisible(true)
        self:hideStar()
    else
        self:getNode("icon_no_star"):setVisible(false)

    end

    self.isFirst=false
    if(self.type==ATLAS_TYPE_BOSS )then
        local status=Data.getAtlasStatus(data.mapid,data.stageid,data.type)
        if(status==false or status.num==0)then
            self.isFirst=true
        end
    end

    local starNum=Data.getAtlasStar(data.mapid,data.stageid,data.type)
    self:showStar(starNum)
    if(starNum==3)then
        self:setTouchEnable("btn_batch_auto",true,false)
        self:setTouchEnable("btn_auto",true,false)
    else
        self:setTouchEnable("btn_batch_auto",false,true)
        self:setTouchEnable("btn_auto",false,true)
    end
    self.isMainLayerMenuShow=false
    self:setLabelString("txt_energy",self.curStage.energy)
    self:showEnemy()
    self:showDropItem()

    self:setLabelString("txt_remain_bat_num","?")
    self:replaceLabelString("btn_txt_batch_auto","?")

    self:hideCloseModule();

    CoreAtlas.EliteFlop.showFlopInAtlasInfoLayer(self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:unscheduleUpdateEx()
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function AtlasEnterPanel:hideCloseModule()
    self:getNode("bg_btn_batch_auto"):setVisible(not Module.isClose(SWITCH_VIP));
    
    if(self.type==ATLAS_TYPE_BOSS )then
        self:getNode("bg_btn_batch_auto"):setVisible(false)
    end
end

function AtlasEnterPanel:onPopup()

    Net.sendAtlasInfo(self.mapid,self.stageid,self.type)
    Unlock.system.sweepone.show();

end



function  AtlasEnterPanel:events()
    return {EVENT_ID_ATLAS_ENTER_INFO,EVENT_ID_ATLAS_BOSS_BUY_TIME}
end

function AtlasEnterPanel:getRemainBatNum()
    if(self.type==ATLAS_TYPE_BOSS)then
        return  self.batNum
    end
    if self.type == 0 then
        return 10;
    end

    local ret= self.batNum
    if(ret>ATLAS_SWEEP_REAMIN_TIME)then
        return ATLAS_SWEEP_REAMIN_TIME
    else
        return ret
    end
end


function AtlasEnterPanel:dealEvent(event,param)
    if(event==EVENT_ID_ATLAS_ENTER_INFO or event==EVENT_ID_ATLAS_BOSS_BUY_TIME)then
        if(param==nil)then
            param={}
        end
        self.batNum=param.batNum
        self.buyNum=param.buyNum

        if(param and param.double==true and self.type==1)then
            self:getNode("txt_double"):setVisible(true)
        end
        local showCount = self.batNum;--self:getRemainBatNum();
        self:replaceLabelString("btn_txt_batch_auto",self:getRemainBatNum())
        if self.type == 0 then
            showCount = gGetWords("labelWords.plist","normalAtlasTimes");
        elseif self.type == ATLAS_TYPE_BOSS then
            showCount =1
            if(self.batNum and self.batNum<=0)then
                showCount =0
            end
        end
        self:setLabelString("txt_remain_bat_num",showCount)

        self:getNode("btn_buy"):setVisible(false);
        if self.type == 1  then
            self:getNode("btn_buy"):setVisible(true);
        end

    end
end


function AtlasEnterPanel:showEnemy()
    local monsters= string.split(self.curStage.team_monster,";")

    for i, monsterid in pairs(monsters) do
        local node=UILayer.new()
        local monsterid=toint(monsterid)
        node:init("ui/ui_enemy_item.map")
        node.starContainerX= node:getNode("star_container"):getPositionX()
        node:setPositionY(node:getContentSize().height)
        self:getNode("enemy"..i):addChild(node)
        Icon.setMonsterIcon(monsterid,node:getNode("icon"))
        local monster=DB.getMonsterById(monsterid)
        local grade=1
        if(monster)then
            grade=monster.grade
        end
        node:getNode("star_container"):setVisible(false)
        --CardPro:showStar(node,grade)
    end
end



function AtlasEnterPanel:showDropItem()
    local idx=1
    local ids=string.split(self.curStage.first_reward,";")
    local nums2=string.split(self.curStage.first_reward_number,";")

    if(self.type==ATLAS_TYPE_BOSS   and  self.isFirst==true)then
        for i, id in pairs(ids) do
            if(self:getNode("reward"..idx))then
                local pSize=self:getNode("reward"..idx):getContentSize()
                local node=DropItem.new()
                node:setData(toint(id))
                node:setPositionY(pSize.height/2+node:getContentSize().height/2)
                node:setPositionX(pSize.width/2-node:getContentSize().width/2)
                self:getNode("reward"..idx):addChild(node)
                node:setLabelString("txt_num",nums2[i])
                idx=idx+1
                local icon=cc.Sprite:create("images/ui_word/first_win.png")
                node:addChild(icon,100)
                pSize=icon:getContentSize()
                icon:setPositionY(-pSize.height/2)
                icon:setPositionX(pSize.width/2)
            end
        end

    end

    local drops= string.split(self.curStage.passrew,";")
    local nums1=string.split(self.curStage.pass_item_num_min,";")
    local nums2=string.split(self.curStage.pass_item_num_max,";")
    for i, dropId in pairs(drops) do
        if(self:getNode("reward"..idx) and toint(dropId)~=0)then
            local pSize=self:getNode("reward"..idx):getContentSize()
            local node=DropItem.new()
            local dropId=toint(dropId)
            node:setData(dropId)
            node:setPositionY(pSize.height/2+node:getContentSize().height/2)
            node:setPositionX(pSize.width/2-node:getContentSize().width/2)
            self:getNode("reward"..idx):addChild(node)
            node:setLabelString("txt_num","")

            if(self.type==ATLAS_TYPE_BOSS )then
                if(nums1[i]==nil)then
                    nums1[i]=0
                end
                if(nums2[i]==nil)then
                    nums2[i]=0
                end
                node:setLabelString("txt_num",nums1[i].."~"..nums2[i])
            end
            idx=idx+1
        end

    end

end



function AtlasEnterPanel:hideStar()
    for i=1, 3 do
        local node=self:getNode("icon_star"..i)
        node:setVisible(false)
    end
end

function AtlasEnterPanel:showStar(num)
    for i=1, 3 do
        local node=self:getNode("icon_star"..i)
        if(i<=num)then
            node:setScale(0.7)
            self:changeTexture("icon_star"..i,"images/ui_public1/star_big.png")
        end
    end

end

function AtlasEnterPanel:isEnoughTimes()

    if self.type == 1 and self:getRemainBatNum()==0 then

        local word=gGetWords("noticeWords.plist","arena_no_time")
        local function onBuyTime()
            self:buyTimes();
        end
        gConfirmAll(word,onBuyTime);
        return false;
    end
    if self.type== ATLAS_TYPE_BOSS then
        if( self:getRemainBatNum()==0) then 
            gShowNotice(gGetWords("noticeWords.plist","atlas_boss_fight_limit_one"))
            return false
        end
        
        if(gAtlas.bossNum<=0)then

            local callback = function(num)
                Net.sendBuyBossNum(num) 
            end
            Data.canBuyTimes(VIP_ATLAS_BOSS_BUY,true,callback);
            return false;

        end
    end
    return true;
end

function AtlasEnterPanel:buyTimes()
    --魔王副本
    if(self.type==ATLAS_TYPE_BOSS)then
        local callback = function(num)
            Net.sendBuyBossNum(num)
        end
        Data.canBuyTimes(VIP_ATLAS_BOSS_BUY,true,callback);

    else
        Data.vip.atlasreset.setUsedTimes(self.buyNum);
        Data.vip.atlasreset.setBuyCount(self.curStage.day_num);

        local callback = function(num)
            Net.sendBuyBatNum(self.mapid, self.stageid, self.type,num)
        end


        if (Data.activityAtlasSaleoff.val) then
            Data.canBuyTimes(VIP_STAGERESET,true,callback,Data.activityAtlasSaleoff.val);
        else
            Data.canBuyTimes(VIP_STAGERESET,true,callback);
        end
    end
end

function AtlasEnterPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_enter"then
        if(NetErr.atlasEnter(self.type,self.mapid,self.stageid)==false)then
            return
        end
        local param={mapid= self.mapid,stageid=self.stageid,type=self.type}
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_ATLAS,param)
    elseif  target.touchName=="btn_batch_auto"then
        if(self.type==ATLAS_TYPE_BOSS)then
            if(Data.getCurVip()<DB.getClientParam("VIP_SWEEP_DEVIL"))then
                gShowNotice(gGetWords("noticeWords.plist","sweep_boss_vip",DB.getClientParam("VIP_SWEEP_DEVIL")))
                return
            end
        end
        if self:isEnoughTimes() then
            if Unlock.isUnlock(SYS_SWEEP,true) then
                Net.sendAtlasSweep( self.mapid, self.stageid, self.type,self:getRemainBatNum())
            end
        end
    elseif  target.touchName=="btn_auto"then
        if(self.type==ATLAS_TYPE_BOSS)then
            if(Data.getCurVip()<DB.getClientParam("VIP_SWEEP_DEVIL"))then
                gShowNotice(gGetWords("noticeWords.plist","sweep_boss_vip",DB.getClientParam("VIP_SWEEP_DEVIL")))
                return
            end
        end
        if self:isEnoughTimes() then
            Net.sendAtlasSweep( self.mapid, self.stageid, self.type,1)
        end
    elseif  target.touchName=="btn_buy"then
        self:buyTimes();
    elseif target.touchName == "btn_flop"then
        --弹出翻牌奖励 map
        Panel.popUpUnVisible(PANEL_ATLAS_ELITE_FLOP,nil,nil,true)
    end
end


return AtlasEnterPanel