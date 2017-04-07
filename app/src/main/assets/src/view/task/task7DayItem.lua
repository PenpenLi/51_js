local Task7DayItem=class("Task7DayItem",UILayer)

function Task7DayItem:ctor()
    -- self:init("ui/new_task/ui_task_item_7day.map")
    self:setContentSize(cc.size(584,122));
end


function Task7DayItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/new_task/ui_task_item_7day.map")

end


function Task7DayItem:onTouchEnded(target)
    if(target.touchName=="btn_goto")then
        self:gotoTask(self.curAchieveData.achId)  
    elseif(target.touchName == "btn_get") then
        self:onGo();  
    elseif(target.touchName == "btn_get2") then
        if NetErr.isDiamondEnough(self.curPirce) then
            Net.sendGiftBuy(toint(self.boxid));
        end
    end
end

function Task7DayItem:gotoTask(id)

    -- --魔王副本
    -- if Unlock.isUnlock(SYS_BOSS_ATLAS)then
    --     Panel.popUp(PANEL_ATLAS,{type=7})
    -- end
    -- --寻找命魂
    -- if Unlock.isUnlock(SYS_XUNXIAN)then
    --     Panel.popUp(PANEL_SOULLIFE_FORMATION,1)
    -- end
    if(id == 711 or id == 715 or id == 717)then
        Panel.popUp(PANEL_ATLAS)
    elseif(id == 712)then
        --挑战卧龙窟
        if Unlock.isUnlock(SYS_PET_TOWER) then
            Net.sendPetAtlasInfo()
        end    
    elseif(id == 713)then
        --强化
        if Unlock.isUnlock(SYS_TREASURE)then
            Panel.popUp(PANEL_CARD_INFO,nil,10);
        end
    elseif(id == 714)then
        --叛军
        if Unlock.isUnlock(SYS_CRUSADE) then
            Net.sendCrusadeInfo()
        end
    elseif(id == 721 or id == 727)then
        --武将突破
        Panel.popUp(PANEL_CARD_INFO);
    elseif(id == 726)then
        --神器突破
        if Unlock.isUnlock(SYS_WEAPON) then
            gCurRaiseCardid=nil
            Net.sendCardRaiseInfo();
        end
    elseif(id == 716)then
        --矿区挑战
        if(Unlock.isUnlock(SYS_MINE))then
            gDigMine.processSendInitMsg()
        end
    elseif(id == 724)then
        --竞技场挑战
        if Unlock.isUnlock(SYS_ARENA) then
            gEnterArena();
        end
    elseif(id == 722)then
        --灵兽升级
        if Unlock.isUnlock(SYS_PET) then
            Panel.popUp(PANEL_PET)
        end
    elseif(id == 723)then
        --精炼大师
        if Unlock.isUnlock(SYS_TREASURE)then
            Panel.popUp(PANEL_CARD_INFO,nil,11);
        end
    elseif(id == 725)then
        --收集武将   
        Panel.popUp(PANEL_DRAW_CARD)
    elseif(id == 733)then
        --精英副本
        if Unlock.isUnlock(SYS_ELITE_ATLAS)then
            Panel.popUp(PANEL_ATLAS,{type=1})
        end
    elseif(id == 743)then
        Panel.popUp(PANEL_BUY_GOLD)    
    end
end

function Task7DayItem:onGo()
    if(not self.canGet)then
        gShowNotice(gGetWords("btnWords.plist","141",self.curDay));
        return;
    end
    if self.curAchieveData then
        Net.sendAchieveGet(self.curAchieveData.achId);
    end 
end

function Task7DayItem:setLazyAchieveData(data,canGet,curDay)  
    if(self.inited==true)then
        return
    end
    self.curAchieveData=data;
    self.canGet = canGet;
    self.curDay = curDay;
    Scene.addLazyFunc(self,self.setLazyAchieveDataCalled,"achieveItem")
end
function Task7DayItem:setLazyAchieveDataCalled()
    self:setAchieveData(self.curAchieveData,self.canGet);
end

function Task7DayItem:setAchieveData(data,canGet,curDay)

    -- print("setAchieveData--------");
    -- print_lua_table(data);
    -- print("setAchieveData+++++++++");
    self:initPanel();
    self:getNode("bg"):setVisible(true);
    self:getNode("bg2"):setVisible(false);
    self.curAchieveData = data;
    self.canGet = canGet;
    self.curDay = curDay;
    local achType = DB.getAchieveType(data.achId);
    -- local ach = DB.getAchieve(data.achId,data.curlv);
    local ach = data.achieve;

    if achType == nil or ach == nil then
        return 0;
    end

    -- local strWordNum = "";
    -- if (achType.levelnum>1) then
    --     strWordNum = gGetWords("labelWords.plist", "num"..(data.curlv));
    --     if (data.curlv>10) then
    --         strWordNum = data.curlv;
    --     end
    -- end

    -- self:setLabelString("txt_title",achType.title..strWordNum) 
    if(data.achId == 721)then
        local label = gGetWords("cardAttrWords.plist","quality"..(ach.num+1));
        self:setLabelString("txt_content",gReplaceParam(achType.content,label));
    else
        self:setLabelString("txt_content",gReplaceParam(achType.content,ach.num))
    end

    -- Icon.setAchieveIcon(achType.iconid, self:getNode("icon"))    

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

            -- Icon.setIcon(ach[key_type], self:getNode("icon_reward"..i))
            Icon.setDropItem(self:getNode("icon_reward"..i),ach[key_type],0,DB.getItemQuality(ach[key_type]));
            self:setLabelString("txt_reward_num"..i,ach[key_data])
            self:setLabelString("txt_reward_name"..i,DB.getItemName(ach[key_type]));
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
        --特殊处理(成就一次只能领取一条,也就是同一个achId,多条达成条件时只能领取第一条，领完才能领取第二条)
        --这边变成领取但是变灰
        local bComplete = false;
        if(data.achId == 724)then
            if(data.curp > 0 and data.curp <= toint(ach.num))then
                bComplete = true
            end
        else
            if(data.curp >= toint(ach.num))then
                bComplete = true
            end
        end
        if(bComplete)then
            self:getNode("btn_get"):setVisible(true);
            self:setTouchEnableGray("btn_get",false);

        else
            --前往
            self:getNode("txt_per"):setVisible(true);
            self:getNode("btn_goto"):setVisible(true);
            gShowShortNum2(self,"txt_per",data.curp,ach.num);
        end

        -- self:setLabelString("txt_per",gGetNumForShort(data.curp).."/"..gGetNumForShort(ach.num))
    end    

    self:resetAdaptNode();
end

function Task7DayItem:setGiftData(data,canGet,curDay)
    self:initPanel();
    self:getNode("bg"):setVisible(false);
    self:getNode("bg2"):setVisible(true);    
    self.canGet = canGet;
    self.gift = data.data;
    local gift=self.gift;
    if(gift)then
        local boxItems = DB.getBoxItemById(gift.boxid);
        -- print_lua_table(boxItems);
        local name = "";
        if(#boxItems > 1)then
            Icon.setDropItem(self:getNode("icon"),toint(gift.boxid),toint(0),DB.getItemQuality(gift.boxid));
            -- Icon.setBoxIcon(gift.boxid,self:getNode("icon"))
            name = DB.getItemName(gift.boxid);
        else
            local item = boxItems[1];
            Icon.setDropItem(self:getNode("icon"),toint(item.itemid),toint(item.itemnum),DB.getItemQuality(item.itemid));
            name = DB.getItemName(item.itemid);
        end
        self:setLabelString("txt_name",name);
        self:setLabelString("txt_price1",gift.orliprice)
        self:setLabelString("txt_price2",gift.curprice)
        self.curPirce = gift.curprice;
        self.boxid = gift.boxid;
    end


    self:getNode("layout_limit"):setVisible(false);
    self:getNode("btn_get2"):setVisible(false);
    self:getNode("flag_unopen2"):setVisible(false);
    if(not self.canGet) then
        --时间未到，未开启
        self:getNode("flag_unopen2"):setVisible(true);
    else
        self:getNode("layout_limit"):setVisible(true);
        self:getNode("btn_get2"):setVisible(true);    
    end

    self:setBuyNum();
    self:resetLayOut();
end

function Task7DayItem:setBuyNum()

    local gift=self.gift;

    if(table.getn(gGiftBagBuy)==0)then
        self:replaceLabelString("txt_num",0,gift.limitbuynum);
        self:setTouchEnable("btn_get2",true,false)
        return;
    end

    local item= Data.getGiftBagBuy(self.boxid)
    if(item)then
        self:replaceLabelString("txt_num",item.num,gift.limitbuynum);
        local leftnum = toint(gift.limitbuynum) - item.num;
        if(leftnum>0)then
            self:setTouchEnable("btn_get2",true,false)
            self:setLabelString("txt_btn_get2",gGetWords("btnWords.plist","btn_buy"));
        else
            self:setTouchEnable("btn_get2",false,true)
            self:setLabelString("txt_btn_get2",gGetWords("btnWords.plist","btn_buyed"));
        end
    end
end

return Task7DayItem