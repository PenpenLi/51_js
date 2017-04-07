local ActivityTaskDayItem=class("ActivityTaskDayItem",UILayer)

function ActivityTaskDayItem:ctor()
    -- self:init("ui/new_task/ui_task_item_7day.map")
    self:setContentSize(cc.size(584,122));
end


function ActivityTaskDayItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/new_task/ui_hd_taskday_item.map")

end


function ActivityTaskDayItem:onTouchEnded(target)
    if(target.touchName=="btn_goto")then
        self:gotoTask(self.curAchieveData.task.taskid)  
    elseif(target.touchName == "btn_get") then
        self:onGo();  
    elseif(target.touchName == "btn_get2") then
        if NetErr.isDiamondEnough(self.curPirce) then
            Net.sendGiftBuy(toint(self.boxid));
        end
    end
end

function ActivityTaskDayItem:gotoTask(id)
    if(gGetCurServerTime() > Data.activityDayTasks.endtime)then
        gShowNotice(gGetWords("activityNameWords.plist","act_eat7"));
        return;
    end
    id = toint(id);
    gGotoTask(id);
    -- print("id = "..id);
    -- if(id == 1 or id == 10)then
    --     Panel.popUp(PANEL_ATLAS)
    -- elseif(id==2)then
    --     Panel.popUp(PANEL_CARD_INFO,nil,3)   
    -- elseif(id == 3 or id == 13) then
    --     if(Unlock.isUnlock(SYS_ACT))then
    --         Panel.popUp(PANEL_ACTIVITY)   
    --     end
    -- elseif(id == 4 or id == 8)then
    --     --竞技场挑战
    --     if Unlock.isUnlock(SYS_ARENA) then
    --         gEnterArena();
    --     end 
    -- elseif(id == 5)then
        -- --神器淬炼
        -- if Unlock.isUnlock(SYS_WEAPON) then
        --     gCurRaiseCardid=nil
        --     Net.sendCardRaiseInfo();
        -- end
    -- elseif(id == 6)then
    --     --熔炼材料3次
    --     Panel.popUp( PANEL_CARD_WEAPON_EQUIP_SOUL)
    -- elseif(id == 7)then
    --     --挑战卧龙窟
    --     if Unlock.isUnlock(SYS_PET_TOWER) then
    --         Net.sendPetAtlasInfo()
    --     end   
    -- elseif(id == 9 or id == 21)then
    --     --抽卡   
    --     Panel.popUp(PANEL_DRAW_CARD)    
    -- elseif(id == 11)then
        -- --军团封魔
        -- if Unlock.isUnlock(SYS_FAMILY) then
        --     Net.sendFamilyGetInfo(nil,PANEL_FAMILY_HDENTER);
        -- end
    -- elseif(id == 12 or id == 14)then
    --     if Unlock.isUnlock(SYS_BATH) then
    --         Net.sendBathGetInfo();  
    --     end
    -- elseif(id == 15)then
    --     --军团擂鼓
    --     if Unlock.isUnlock(SYS_FAMILY) then
    --         Net.sendFamilyGetInfo(nil,PANEL_FAMILY_HDENTER);
    --     end
    -- elseif(id == 16)then
    --     if Unlock.isUnlock(SYS_ELITE_ATLAS)then
    --         Panel.popUp(PANEL_ATLAS,{type=1})
    --     end 
    -- elseif(id == 17)then
    --     --寻找命魂
    --     if Unlock.isUnlock(SYS_XUNXIAN)then
    --         Panel.popUp(PANEL_SOULLIFE_FORMATION,1)
    --     end    
    -- elseif(id == 18)then
    --     --叛军
    --     if Unlock.isUnlock(SYS_CRUSADE) then
    --         Net.sendCrusadeInfo()
    --     end
    -- elseif(id == 19 or id == 20)then
    --     if Unlock.isUnlock(SYS_TRAINROOM) then
    --         Net.sendDrinkGetinfo();
    --     end

    -- elseif(id == 713)then
    --     --挑战海怪
    --     if(Unlock.isUnlock(SYS_MINE))then
    --         gDigMine.processSendInitMsg()
    --     end
    -- elseif(id == 721 or id == 724 or id == 726)then
    --     --武将突破 or 神器突破
    --     Panel.popUp(PANEL_CARD_INFO);
    -- elseif(id == 716)then
    --     --魔王副本
    --     if Unlock.isUnlock(SYS_BOSS_ATLAS)then
    --         Panel.popUp(PANEL_ATLAS,{type=7})
    --     end

    -- elseif(id == 722)then
    --     --灵兽升级
    --     if Unlock.isUnlock(SYS_PET) then
    --         Panel.popUp(PANEL_PET)
    --     end 
    -- end
end

function ActivityTaskDayItem:onGo()
    if(not self.canGet)then
        gShowNotice(gGetWords("btnWords.plist","141",self.curDay));
        return;
    end
    if self.curAchieveData then
        Net.sendDaytActGet(self.curAchieveData.task.taskid,self.curAchieveData.task.daylimit);
    end 
end

function ActivityTaskDayItem:setLazyAchieveData(data,canGet,curDay)  
    if(self.inited==true)then
        return
    end
    self.curAchieveData=data;
    self.canGet = canGet;
    self.curDay = curDay;
    Scene.addLazyFunc(self,self.setLazyAchieveDataCalled,"achieveItem")
end
function ActivityTaskDayItem:setLazyAchieveDataCalled()
    self:setAchieveData(self.curAchieveData,self.canGet);
end

function ActivityTaskDayItem:setAchieveData(data,canGet,curDay)

    -- print("setAchieveData--------");
    -- print_lua_table(data);
    -- print("setAchieveData+++++++++");
    self:initPanel();
    self:getNode("bg"):setVisible(true);
    self.curAchieveData = data;
    data.canGet = data.curp >= data.task.num;
    data.isGet = data.gtime > 0;
    self.canGet = canGet;
    self.curDay = curDay;
    local ach = data.task;
    self:setLabelString("txt_content",gReplaceParam(data.task.content,data.task.num))

    -- print_lua_table(ach);

    for i=1, 3 do
        local key_type = "gtype"..i;
        local key_data = "gdata"..i;
        
        if(toint(ach[key_type])==0)then
            self:getNode("reward_panel"..i):setVisible(false)
        else
            self:getNode("reward_panel"..i):setVisible(true)

            -- Icon.setIcon(ach[key_type], self:getNode("icon_reward"..i))
            Icon.setDropItem(self:getNode("icon_reward"..i),ach[key_type],0,DB.getItemQuality(ach[key_type]));
            if gCurLanguage == LANGUAGE_EN 
                or gCurLanguage == LANGUAGE_TH then
                self:setLabelString("txt_reward_num"..i,"x"..ach[key_data])
                self:setLabelString("txt_reward_name"..i,"");
            else
                self:setLabelString("txt_reward_num"..i,ach[key_data])
                self:setLabelString("txt_reward_name"..i,DB.getItemName(ach[key_type]));
            end
            
        end
    end

    self:getNode("flag_unopen"):setVisible(false);
    self:getNode("flag_isget"):setVisible(false);
    self:getNode("btn_goto"):setVisible(false);
    self:getNode("btn_get"):setVisible(false);
    self:getNode("txt_per"):setVisible(false);

    -- self.canGet = true;
    if(data.isGet)then
        --已领取
        self:getNode("flag_isget"):setVisible(true);

    -- elseif(not self.canGet) then
    --     --时间未到，未开启
    --     self:getNode("flag_unopen"):setVisible(true);
    elseif data.canGet then
        --可领取
        self:getNode("btn_get"):setVisible(true);

        if(not self.canGet)then
            --时间未到，未开启
            self:setLabelString("txt_btn_get",gGetWords("btnWords.plist","141",self.curDay));
        end
    else
        if(not self.canGet)then
            self:getNode("flag_unopen"):setVisible(true);
        else    
            --前往
            self:getNode("txt_per"):setVisible(true);
            self:getNode("btn_goto"):setVisible(true);
            gShowShortNum2(self,"txt_per",data.curp,ach.num);
        end
        -- self:setLabelString("txt_per",gGetNumForShort(data.curp).."/"..gGetNumForShort(ach.num))
    end    
end

return ActivityTaskDayItem