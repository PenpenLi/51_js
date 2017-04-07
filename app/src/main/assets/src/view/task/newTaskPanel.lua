local NewTaskPanel=class("NewTaskPanel",UILayer)
NewTaskPanelData = {}
NewTaskPanelData.achieveId = 701;
--新手任务
function NewTaskPanel:ctor(type,data)

    self.appearType = 1;
    self:init("ui/new_task/ui_newtask.map")
    self._panelTop = true;
    NewTaskPanelData.bNeedRefresh = true;
    self.desMap = 1;
    self.desStage = 1;

    for i=1,2 do
        self:getNode("reward"..i):setVisible(false);
    end
    self:getNode("btn_go"):setVisible(false);
    self:getNode("btn_get"):setVisible(false);
    self:getNode("txt_title"):setVisible(false);
    self:getNode("txt_content"):setVisible(false);
    self:getNode("txt_target"):setVisible(false);
end

function NewTaskPanel:onPopup()
    -- if(NewTaskPanelData.bNeedRefresh) then
        Net.sendAchieveList(true);
        -- NewTaskPanelData.bNeedRefresh = false;
    -- end
end

function NewTaskPanel:initPanel()

    if(self.curTask)then
        print_lua_table(self.curTask);
        self:getNode("txt_title"):setVisible(true);
        self:getNode("txt_content"):setVisible(true);
        self:getNode("txt_target"):setVisible(true);
        self:setLabelString("txt_title",gGetWords("taskWords.plist",self.curTask.curlv.."title"));
        self:setLabelString("txt_content",gGetWords("taskWords.plist",self.curTask.curlv.."content"));
        self:replaceRtfString("txt_target",gGetWords("taskWords.plist",self.curTask.curlv.."target"));

        local ach = DB.getAchieve(self.curTask.achId,self.curTask.curlv);
        self.desMap = math.floor(toint(ach.num)/100);
        self.desStage = toint(ach.num)%100;
        for i=1, 2 do
            local key_type = "gtype"..i;
            local key_data = "gdata"..i;
            if i == 1 then
                key_type = "gtype";
                key_data = "gdata";
            end

            if(ach[key_type]==0)then
                self:getNode("reward"..i):setVisible(false);
            else
                self:getNode("reward"..i):setVisible(true);
                Icon.setDropItem(self:getNode("reward"..i),ach[key_type],ach[key_data],DB.getItemQuality(ach[key_type]));
            end
        end

        self:getNode("btn_go"):setVisible(not self.curTask.bolGet);
        self:getNode("btn_get"):setVisible(self.curTask.bolGet);

        self:getNode("scroll_content"):layout();
    end
end

function NewTaskPanel:evtAchieveList(achieves)
    for key,ach in pairs(achieves) do
        if(ach.achId == NewTaskPanelData.achieveId)then
            self.curTask = ach;
            break;
        end
    end
    self:initPanel();  
end

function  NewTaskPanel:events()
    return {
    EVENT_ID_ACHIEVE_LIST,
    EVENT_ID_ACHIEVE_GET}
end


function NewTaskPanel:dealEvent(event,param)
    if(event==EVENT_ID_ACHIEVE_LIST)then
        self:evtAchieveList(param);
    elseif(event == EVENT_ID_ACHIEVE_GET) then
        -- print_lua_table(param);
        if param.new_data then
            self.curTask = param.new_data;
            self:initPanel();
        else
            Panel.popBack(self:getTag());
            gNewTaskType = 2;
            if(gMainLayer)then
                gMainLayer:refreshNewTaskType();
            end   
        end
        Data.redpos.bolNewTask = false;
    end
end



function NewTaskPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif  target.touchName=="btn_go"then
        print("self.desMap = "..self.desMap);
        print("self.desStage = "..self.desStage);
        local desMap = self.desMap;
        local desStage = self.desStage - 1;
        local index = 0;
        while(true)do
            local isPass = Data.isPassAtlas(desMap,desStage,0);
            if(isPass)then
                desStage = desStage + 1;
                break;
            end
            desStage = desStage - 1;
            index = index + 1;
            if(index > 20)then
                break
            end
        end
        Panel.popUp(PANEL_ATLAS_ENTER,{mapid=desMap,stageid=desStage,type=0})
        -- Panel.popUp(PANEL_ATLAS,{type=0,mapid=1})
    elseif target.touchName == "btn_get"then
        Net.sendAchieveGet(self.curTask.achId);
    end
end

return NewTaskPanel