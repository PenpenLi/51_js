local ActivityPanel=class("ActivityPanel",UILayer)

function ActivityPanel:ctor(showIndex)

    self:init("ui/ui_activity.map")
    self.noCdlv =  DB.getClientParam("ACT_NO_CD_LV",true);
    self:replaceLabelString("txt_cdlv",self.noCdlv)
    

    local lvArray =  DB.getClientParamToTable("ACT_SWEEP_OPEN_LV",true);
    self.sweepOpenLv =50
    self.sweepShowLv =50
    if lvArray[1]~=nil then
         self.sweepShowLv = lvArray[1]
     end
    if lvArray[2]~=nil then
         self.sweepOpenLv = lvArray[2]
    end 
    -- self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    -- self:getNode("scroll").offsetX=10
    self.scroll = self:getNode("scroll");
    self.choosed = false;
    self.choosedIdx = -1;
    self.playingChooseAni = false;

    self.actOpen = {};
    local index = 1;
    for key, db in pairs(actstage_db) do
        if(db.type~=5)then
            local item=ActivityItem.new()
            db.unlockTime = self:getUnlockTime(toint(db.type));
            item:setData(db,index)
            item.onChoosed = function(idx,data)
                self:onChoosedSendGetInfo(idx,data);
            end
            item.onUnChoosed = function(idx) 
                self:onUnChoosed(idx);
            end
            item.onEnter = function(idx,data) 
                self:onEnter(idx,data);
            end
            self.scroll:addItem(item);
            table.insert(self.actOpen,{type=toint(db.type),isOpen = item.isOpen});
            index = index + 1;
        end
    end

    --敬请期待
    local item=ActivityItem.new();
    item:setData(nil,index);
    self.scroll:addItem(item);

    self.scroll:layout();

    local items = self.scroll:getAllItem();
    for key,var in pairs(items) do
        var:layout();
    end

    if(gEnterFromLevelup == false)then

        if(Guide.isInGuiding(GUIDE_ID_ENTER_ACTEQUSOUL1))then
            showIndex = 3;
        else
            if(self:checkOpen(2) and not Data.getSysIsEnter(SYS_ACT_GOLD) and Unlock.isUnlock(SYS_ACT_GOLD,false))then
                Unlock.checkFirstEnter(SYS_ACT_GOLD);
            elseif(self:checkOpen(3) and not Data.getSysIsEnter(SYS_ACT_EXP) and Unlock.isUnlock(SYS_ACT_EXP,false))then
                Unlock.checkFirstEnter(SYS_ACT_EXP);
            elseif(self:checkOpen(4) and not Data.getSysIsEnter(SYS_ACT_PETSOUL) and Unlock.isUnlock(SYS_ACT_PETSOUL,false))then
                Unlock.checkFirstEnter(SYS_ACT_PETSOUL);
            -- elseif(not Data.getSysIsEnter(SYS_ACT_EQUSOUL) and Unlock.isUnlock(SYS_ACT_EQUSOUL,false))then
                -- self:getNode("scroll"):moveItemByIndex(3);
                -- Unlock.checkFirstEnter(SYS_ACT_EQUSOUL);
            end
        end


    end
    gEnterFromLevelup = false;

    if(Net.sendAtlasEnterParam and Net.sendAtlasEnterParam.type==11)then
       showIndex=3

    end
    if(showIndex~=nil)then
        self:getNode("scroll"):moveItemByIndex(showIndex);
    end
    
end

function ActivityPanel:checkOpen(act_type)
    for key,act in pairs(self.actOpen) do
        if(act.type == act_type)then
            return act.isOpen;
        end
    end
    return false;
end

function ActivityPanel:getUnlockTime(type)
    if(Data.redpos.actAtlas)then
        for key,var in pairs(Data.redpos.actAtlas) do
            if(var.type == type)then
                return var.unlockTime;
            end
        end
    end
    return 0;
end

function ActivityPanel:onPopup()
    self:getNode("scroll"):setTouchEnable(true);
end
 
function ActivityPanel:onTouchBegan(target,touch, event)
    self.beganPos = touch:getLocation();
end

function ActivityPanel:getMaxOpenStage(type)
    local result = 1
    for i=1, 4 do
        local data=DB.getActStageInfoById(type,i)
        if(data)then
            if(gUserInfo.level>data.level)then
                result = i
            end
        end
    end
    return result
end

function ActivityPanel:onTouchEnded(target,touch)
    self.endPos = touch:getLocation();
    local dis = getDistance(self.beganPos.x,self.beganPos.y, self.endPos.x,self.endPos.y);
    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_cd" then
        self:onClearCdTime();
    elseif target.touchName == "btn_sweep" then
        if Data.getCurLevel() >= self.sweepOpenLv then
             Net.sendActAtlasSweep(self.curData.type,self:getMaxOpenStage(self.curData.type))
        else
            gShowNotice(gGetWords("noticeWords.plist","activity_sweep_openlv",self.sweepOpenLv))
        end
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_ACT_QUICK_SWEEP)    
    elseif target.touchName == "bg" and dis < 5 then
        self:onUnChoosed(self.choosedIdx);   
    end
end

function ActivityPanel:onClearCdTime()
    local word = gGetWords("noticeWords.plist","act_atlas_cd",gActAtlasInfo.clearCdNeddDia)
    local function onOk()
        Net.sendAtlasActClearCD(self.curData.type);
    end
    gConfirmCancel(word,onOk);
end

function ActivityPanel:events()
    return {EVENT_ID_ATLAS_ACTIVITY_INFO,EVENT_ID_ACT_SWEEP}
end


function ActivityPanel:dealEvent(event,param,param2)
    if(event == EVENT_ID_ATLAS_ACTIVITY_INFO)then
        self:handleGetInfo(param);
    elseif (event == EVENT_ID_ACT_SWEEP) then
        --todo
        Panel.popUp(PANEL_CRUSADE_SWEEP,param)
    end
end

function ActivityPanel:onChoosedSendGetInfo(idx,data)
    if self.playingChooseAni then
        return;
    end

    if self.choosed then
        self:onUnChoosed(self.choosedIdx);
        return;
    end

    self.choosedIdx = idx;
    self.choosedData = data;
    Net.sendActAtlasInfo(data.type);
end

function ActivityPanel:handleGetInfo(data)
    self.cdTime = data.cd;
    if data.batNum ~= nil then
        self.batNum = data.batNum;
    end
    -- print_lua_table(data);
    self:onChoosed(self.choosedIdx,self.choosedData);
end

function ActivityPanel:onChoosed(idx,data)

    if self.choosed or self.playingChooseAni then
        self:refreshContent(data);
        return;
    end

    -- print("onChoosed");
    self:setChoose(true);
    self.choosedIdx = idx;
    self:refreshContent(data);
    local curItem = self.scroll:getItem(idx-1);
    curItem:choosed();

    local count = table.getn(self.scroll:getAllItem());
    for i = idx+1,count do
        local item = self.scroll:getItem(i-1);
        item:runAction(cc.Sequence:create( cc.MoveBy:create(0.2,cc.p(150,0))));
    end


    local items = self.scroll:getAllItem();
    for key,var in pairs(items) do
        var:stopAction();
    end    
end

function ActivityPanel:onUnChoosed(idx)
    if not self.choosed or idx < 0  or self.playingChooseAni then
        return;
    end
    -- print("onUnChoosed");
    self:setChoose(false);

    local curItem = self.scroll:getItem(idx-1);
    curItem:unChoosed();

    local count = table.getn(self.scroll:getAllItem());
    for i = idx+1,count do
        local item = self.scroll:getItem(i-1);
        item:runAction(cc.Sequence:create( cc.MoveBy:create(0.2,cc.p(-150,0))));
    end
    self.choosedIdx = -1;

    local items = self.scroll:getAllItem();
    for key,var in pairs(items) do
        var:layout();
    end

end

function ActivityPanel:setChoose(isChoosed)

    if self.playingChooseAni then
        return;
    end

    self.playingChooseAni = true;
    self.choosed = isChoosed;
    local time = 0.2;
    local offset = 100;
    local function actionEnd()
        self.playingChooseAni = false;
    end
    if(isChoosed) then
        self:getNode("wave"):runAction(cc.Sequence:create(cc.MoveBy:create(time+0.1,cc.p(0,-offset)),
            cc.CallFunc:create(actionEnd)));
        self:getNode("layer_content"):runAction(cc.MoveBy:create(time,cc.p(0,offset)));
    else
        self:getNode("wave"):runAction(cc.Sequence:create(cc.MoveBy:create(time+0.1,cc.p(0,offset)),
            cc.CallFunc:create(actionEnd)));
        self:getNode("layer_content"):runAction(cc.MoveBy:create(time,cc.p(0,-offset)));
    end
end

function ActivityPanel:onEnter(idx,data)
    -- body
    local hasCdTime = false;
    if(self.cdTime==nil or self.cdTime>gGetCurServerTime())then
        hasCdTime = true;
    end

    if not NetErr.ActAtlasEnter(hasCdTime, self.batNum,self.curStage.energy,self.curData.type) then
        return;
    end

    -- local data=DB.getActStageInfoById(self.curData.type,idx)
    local param={type=data.type,stageid=idx} 
    Panel.popUp(PANEL_ATLAS_FORMATION,Data.getTeamType(data.type),param)
end

function ActivityPanel:refreshContent(data)
    self:setLabelString("txt_info",data.rewdes)
    self.curData=data
    self.curStage=DB.getStageById(1,1,data.type)
    self:setLabelString("txt_energy",self.curStage.energy)
    self:setLabelString("txt_remain_bat_num", self.batNum);
    self:getNode("bg_cd"):setVisible(false);
    self:getNode("btn_sweep"):setVisible(false);

    if Data.getCurLevel() >= self.sweepShowLv then
        self:getNode("btn_sweep"):setVisible(true);
    else
        self:getNode("btn_sweep"):setVisible(false);
    end

    local function updateCdTime()
        -- print("ActivityPanel:updateCdTime");
        if( Data.getCurLevel() < self.noCdlv and self.cdTime and self.batNum>=1)then
            if(self.cdTime>gGetCurServerTime())then
                self:getNode("bg_cd"):setVisible(true)
                local leftTime = self.cdTime-gGetCurServerTime()
                self:setLabelString("txt_cd_num", gParserMinTime(leftTime))
                Battle.updateActAtlasInfo(self.curData.type, self.batNum, self.cdTime)
            else
                self:getNode("bg_cd"):setVisible(false)
                Battle.updateActAtlasInfo(self.curData.type, self.batNum, 0)
                if self.cdTime ~= 0 then
                    gRedposRefreshDirty = true
                end
                self.cdTime = 0
            end
        end
    end
    self:scheduleUpdate(updateCdTime,1)    
end

function ActivityPanel:onUILayerExit()
    -- print("ActivityPanel:onUILayerExit");
    self:unscheduleUpdateEx()
end

return ActivityPanel