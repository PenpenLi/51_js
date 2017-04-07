local TaskItem=class("TaskItem",UILayer)

function TaskItem:ctor()
    -- self:init("ui/ui_task_item.map")
    self:setContentSize(cc.size(830,122));
end


function TaskItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_task_item.map")

end


function TaskItem:onTouchEnded(target)
    if(target.touchName=="btn_goto")then
        if nil ~= self.curAchieveData and self.curAchieveData.achId == ACHIEVE_ID_APPSTORE_GOOD then
            Data.openAppStoreCommentURL()
            Net.sendAchiFapp()
        elseif(self.curTaskData)then
            self:gotoTask(self.curTaskData.dayid)  
        end
    elseif(target.touchName == "btn_get") then
        -- PlatformFunc:sharedPlatformFunc():openURL("itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1049602254")
        self:onGo();  
    end
end

function gGotoTask(id)
    if(id == 1) then
        Panel.popUp(PANEL_ATLAS)
    elseif(id==2)then
        if Unlock.isUnlock(SYS_ELITE_ATLAS)then
            Panel.popUp(PANEL_ATLAS,{type=1})
        end
    elseif(id==3)then
        Panel.popUp(PANEL_BUY_GOLD)
    elseif(id==4 or id==5)then
        if Unlock.isUnlock(SYS_ARENA) then
            Panel.popUp(PANEL_ARENA)
        end
    elseif(id==7 or id == 24)then
        Panel.popUp(PANEL_DRAW_CARD)
    elseif(id==11 or id == 35)then
        Panel.popUp(PANEL_DRAW_CARD)
    elseif(id==14)then
        Panel.popUp(PANEL_FRIEND)
    elseif(id==15)then
        --月卡
        Panel.popUp(PANEL_PAY)
    elseif(id == 16) then
        if(Unlock.isUnlock(SYS_ACT))then
            Panel.popUp(PANEL_ACTIVITY)   
        end
    elseif(id==17)then
        Panel.popUp(PANEL_CARD_INFO,nil,2)
    elseif(id==18)then
        Panel.popUp(PANEL_CARD_INFO,nil,3)
    elseif(id == 20)then
        if Unlock.isUnlock(SYS_XUNXIAN)then
            Net.sendSpiritInit(1)
        end
    elseif(id==23)then
        Panel.popUp(PANEL_BUY_ENERGY,VIP_DIAMONDHP)
    elseif(id == 28 or id == 39)then
        if Unlock.isUnlock(SYS_TRAINROOM) then
            Net.sendDrinkGetinfo();
        end
    elseif(id == 29 or id == 36)then
        if Unlock.isUnlock(SYS_BATH) then
            Net.sendBathGetInfo();
        end
    elseif(id == 30)then
        Net.sendFamilyGetInfo();
    elseif(id == 31)then
        if Unlock.isUnlock(SYS_PET_TOWER) then
            Net.sendPetAtlasInfo()
        end
    elseif(id == 32)then
        if Unlock.isUnlock(SYS_SERVER_BATTLE) then
            local serverBattleType = gServerBattle.getServerBattleType()
            if serverBattleType == SERVER_BATTLE_TYPE1 then
                gServerBattle.checkTeamInfo()
                Net.sendWorldWarGetInfo()
            elseif serverBattleType == SERVER_BATTLE_TYPE2 then
                Net.sendWorldWarMatchRecord(KING_RANK_SKY)
            -- else
            --     gShowNotice(gGetWords("serverBattleWords.plist","txt_rank_no_open"))
            end
        end
    elseif(id == 33 or id == 42)then
        --神器淬炼
        if Unlock.isUnlock(SYS_WEAPON) then
            gCurRaiseCardid=nil
            Net.sendCardRaiseInfo(2);
        end   
    elseif(id == 34)then
        --熔炼材料3次
        Panel.popUp( PANEL_CARD_WEAPON_EQUIP_SOUL) 
    elseif(id == 38)then
        --叛军
        if Unlock.isUnlock(SYS_CRUSADE) then
            Net.sendCrusadeInfo()
        end    
    elseif(id == 40 or id == 37)then
        --军团封魔 or 擂鼓
        if Unlock.isUnlock(SYS_FAMILY) then
            Net.sendFamilyGetInfo(nil,PANEL_FAMILY_HDENTER);
        end    
    elseif(id == 41)then
        if(Unlock.isUnlock(SYS_BOSS_ATLAS)) then
            Panel.popUp(PANEL_ATLAS,{type=7})
        end
    elseif(id == 43)then
        if(Unlock.isUnlock(SYS_TOWER))then
            -- Net.sendTowerEnter();
            Net.sendTownGetinfo()
        end          
    end    
end

function TaskItem:gotoTask(id)
    if(id == 25 or id == 26 or id == 27)then
        --吃包子
        TaskPanelData.energyTaskId = id;
        self:toActivityEat()
    else
        gGotoTask(id);
    end
    TaskPanelData.bNeedRefresh = true;
end

function TaskItem:toActivityEat()
    if (self.curTaskData.status==3) then--补吃体力
        if NetErr.isDiamondEnough(Data.buyEnergy.reeat_diamond) and
           (not NetErr.isEnergyFull()) then
            Net.sendDaytEnergyEat(self.curTaskData.dayid)
        end
    elseif (Data.bolOpenEatBunAct) then
        Panel.popUp(PANEL_ACTIVITY_ALL,{type=ACT_TYPE_125})
    end
end

function TaskItem:isEacBunAct()
    local isGetEnergy = false;
    for key,var in pairs(TaskPanelData.getEnergyTaskIds) do
        if var == self.curTaskData.dayid then
            isGetEnergy = true;
            break;
        end
    end
    if (Data.bolOpenEatBunAct and isGetEnergy) then
        return true;
    end
    return false;
end

function TaskItem:onGo()
    if self.curTaskData then
        local isGetEnergy = false;
        for key,var in pairs(TaskPanelData.getEnergyTaskIds) do
            if var == self.curTaskData.dayid then
                isGetEnergy = true;
                break;
            end
        end
        if (Data.bolOpenEatBunAct and isGetEnergy) then
            --前往吃包子界面
            self:toActivityEat()
            return
        end
        if isGetEnergy and NetErr.isEnergyFull() then
            return;
        end

        Net.sendDayTaskGet(self.curTaskData.dayid);
    elseif self.curAchieveData then
        Net.sendAchieveGet(self.curAchieveData.achId);
    end 
end

function TaskItem:setLazyAchieveData(data)  
    if(self.inited==true)then
        return
    end
    self.curAchieveData=data;
    Scene.addLazyFunc(self,self.setLazyAchieveDataCalled,"achieveItem")
end
function TaskItem:setLazyAchieveDataCalled()
    self:setAchieveData(self.curAchieveData);
end

function TaskItem:setAchieveData(data)
    self:initPanel();
    self.curAchieveData = data;

    local achType = DB.getAchieveType(data.achId);
    local ach = DB.getAchieve(data.achId,data.curlv);

    if achType == nil or ach == nil then
        return 0;
    end

    local strWordNum = "";
    if (achType.levelnum>1) then
        strWordNum = gGetWords("labelWords.plist", "num"..(data.curlv));
        if (data.curlv>10) then
            strWordNum = data.curlv;
        end
    end

    self:setLabelString("txt_title",achType.title..strWordNum) 
    self:setLabelString("txt_content",gReplaceParam(achType.content,ach.num))

    Icon.setAchieveIcon(achType.iconid, self:getNode("icon"))    

    for i=1, 3 do
        local key_type = "gtype"..i;
        local key_data = "gdata"..i;
        if i == 1 then
            key_type = "gtype";
            key_data = "gdata";
        end
        if(ach[key_type]==0)then
            self:getNode("reward_panel"..i):setVisible(false)
        else
            self:getNode("reward_panel"..i):setVisible(true)

            Icon.setIcon(ach[key_type], self:getNode("icon_reward"..i))
            self:setLabelString("txt_reward_num"..i,ach[key_data])
        end
    end

    self:getNode("layer_point"):setVisible(false);
    if data.achId == ACHIEVE_ID_APPSTORE_GOOD then
        self:getNode("btn_goto"):setVisible(true);
    else
        self:getNode("btn_goto"):setVisible(false);
    end

    if data.bolGet then
        self:getNode("txt_per"):setVisible(false);
        self:getNode("txt_going"):setVisible(false);
    else
        self:getNode("btn_get"):setVisible(false);

        if(ach.achieveid == 100 or ach.achieveid == 92)then
            gShowShortNum2(self,"txt_per",data.curp,ach.num,nil,false);
        elseif(ach.achieveid == 16)then
            gShowShortNum2(self,"txt_per",data.curp,ach.num,nil,nil,false);
        else    
            gShowShortNum2(self,"txt_per",data.curp,ach.num);
        end
        -- self:setLabelString("txt_per",gGetNumForShort(data.curp).."/"..gGetNumForShort(ach.num))
    end
    
    self:getNode("flag_geted"):setVisible(false);
    
end


function TaskItem:setLazyTaskData(data,taskDB)  
    if(self.inited==true)then
        return
    end
    self.curTaskData=data;
    self.task_db = taskDB;
    Scene.addLazyFunc(self,self.setLazyTaskDataCalled,"taskItem")
end
function TaskItem:setLazyTaskDataCalled()
    self:setTaskData(self.curTaskData,self.task_db);
end


function   TaskItem:setTaskData(data,taskDB)
    self:initPanel();
    self.curTaskData=data
    -- local taskDB=DB.getDayTask(self.curTaskData.dayid)
    if(taskDB==nil)then
        return 0
    end
    if(taskDB.tasktype == 10) then
        return -1;
    end
    local isGetEnergy = false;
    -- if (not Data.bolOpenEatBunAct) then
        for key,var in pairs(TaskPanelData.getEnergyTaskIds) do
            if var == self.curTaskData.dayid then
                isGetEnergy = true;
                break;
            end
        end
    -- end
    self.task_db = taskDB; 

    if(self.curTaskData.dayid == 21 and not Module.isClose(SWITCH_REPLACE_CARDYEAR))then
        local replaceword = gGetWords("labelWords.plist","288");
        local replaceword2 = gGetWords("labelWords.plist","287");
        taskDB.title = string.gsub(taskDB.title,replaceword,replaceword2);
        taskDB.content = string.gsub(taskDB.content,replaceword,replaceword2);
    end

    self:setLabelString("txt_title",taskDB.title)    
    self:setLabelString("txt_content",taskDB.content)
    self:setLabelString("txt_point","+"..taskDB.point);
    Icon.setTaskIcon(taskDB.iconid, self:getNode("icon"))
    
    for i=1, 3 do
    	if(taskDB["gtype"..i]==0)then
            self:getNode("reward_panel"..i):setVisible(false)
        else
            self:getNode("reward_panel"..i):setVisible(true)

            Icon.setIcon(taskDB["gtype"..i], self:getNode("icon_reward"..i))
            self:setLabelString("txt_reward_num"..i,taskDB["gdata"..i])
    	end
    end
    
    self:setLabelString("txt_per",self.curTaskData.curp.."/"..taskDB.num)
    
    self:getNode("txt_going"):setVisible(false);
    self:getNode("flag_geted"):setVisible(false);
    if(self.curTaskData.status==1)then
        self:getNode("btn_get"):setVisible(true)
        self:getNode("btn_goto"):setVisible(false)
    else
        self:getNode("btn_get"):setVisible(false)
        self:getNode("btn_goto"):setVisible(true)
    end

    self:getNode("txt_btn_go_r"):setVisible(false)
    self:getNode("txt_btn_go"):setVisible(true)

    if isGetEnergy then
        -- print("self.curTaskData.status="..self.curTaskData.status)
        -- print("self.curTaskData.dayid="..self.curTaskData.dayid)
        --self.curTaskData.dayid
        self:getNode("btn_goto"):setVisible(false)
        if self.curTaskData.status==1 then
            self:getNode("txt_per"):setVisible(false);
        elseif self.curTaskData.status==3 then
            -- print("-----------------2222-------")
            self:setLabelString("txt_per",gGetWords("labelWords.plist","121-3"));
            self:getNode("txt_per"):setSystemFontSize(18)
            local word = gGetWords("btnWords.plist","btn_eat_dia",Data.buyEnergy.reeat_diamond)
            -- print("-----------------2222-------"..word)
            self:setRTFString("txt_btn_go_r",word)
            -- self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_eat_dia",Data.buyEnergy.reeat_diamond));
            -- self:setLabelString("txt_btn_go",word);
            self:getNode("txt_btn_go_r"):setVisible(true)
            self:getNode("txt_btn_go"):setVisible(false)
        else
            self:setLabelString("txt_per",gGetWords("labelWords.plist","121"));
        end
        if (Data.bolOpenEatBunAct or self.curTaskData.status==3) then
            self:getNode("btn_get"):setVisible(false)
            self:getNode("btn_goto"):setVisible(true)
        end
    end

    if(self:isEacBunAct())then
        if self.curTaskData.status==3 then
            local word = gGetWords("btnWords.plist","btn_eat_dia",Data.buyEnergy.reeat_diamond)
            self:setRTFString("txt_btn_go_r",word)
            self:getNode("txt_btn_go_r"):setVisible(true)
            self:getNode("txt_btn_go"):setVisible(false)
            -- self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_eat_dia",Data.buyEnergy.reeat_diamond));
        else
            self:setLabelString("txt_btn_go",gGetWords("btnWords.plist","btn_eat"));
        end
    end

    if(self.curTaskData.status == 2)then
        self:getNode("flag_geted"):setVisible(true);
        self:getNode("btn_goto"):setVisible(false);
        self:getNode("txt_going"):setVisible(false);
        self:getNode("btn_get"):setVisible(false);
        self:getNode("txt_per"):setVisible(false);
    end
    if (self.curTaskData.dayid == 44 and self.curTaskData.status==0) then--任务达人
        self:getNode("txt_going"):setVisible(true);
        self:getNode("flag_geted"):setVisible(false);
        self:getNode("btn_goto"):setVisible(false);
        self:getNode("btn_get"):setVisible(false);
    end
    self:resetLayOut()
    return taskDB.point
end

function TaskItem:setAppStoreGoodFinish()
    self:getNode("btn_get"):setVisible(true)
    self:getNode("btn_goto"):setVisible(false)
    self:getNode("txt_per"):setVisible(false);
end



return TaskItem