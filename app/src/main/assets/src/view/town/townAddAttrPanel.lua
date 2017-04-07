local TownAddAttrPanel=class("TownAddAttrPanel",UILayer)
TowerAddAttrPanelData = {};
TowerAddAttrPanelData.attr = {11,69,41,44,67,70};
function TownAddAttrPanel:ctor()

    self.appearType = 1;
    self:init("ui/ui_tower_sx.map");
    self.isMainLayerMenuShow = false;
    self.attr = TowerAddAttrPanelData.attr;
    for key,var in pairs(self.attr) do
        self:setLabelString("txt_name"..key,gGetWords("cardAttrWords.plist","attr"..var));
        self:replaceLabelString("txt_add_value"..key,"0%");
    end
    self.playAni = false;
    self:refreshUI();

    if(TowerPanelData.guideIndex == 3)then
        Unlock.system.tower.guideByIndex(4);
        TowerPanelData.guideIndex = -1;
    end
end

function TownAddAttrPanel:refreshUI()
    -- self:setLabelString("txt_left_times",Data.towerInfo.attrnum);
    self:setLabelString("txt_cur_star",Data.towerInfo.star);

    self:getNode("layer_panels"):clear();
    self:getNode("layer_panels"):setSortByPosFlag(false);
    for key,var in pairs(Data.towerInfo.addattr) do
        local item = TownAddAttrItem.new(var,key);
        item.onChoose = function(data,index)
            self:onChooseAttr(data,index);
        end
        self:getNode("layer_panels"):addNode(item);
    end

    -- for key,var in pairs(Data.towerInfo.addattr) do
    --     local panel = self:getNode("panel"..key);
    --     panel:replaceLabelString("txt_value",var.val);
    --     panel:setLabelString("txt_star",var.star);
    --     local name = gGetWords("cardAttrWords.plist","attr"..var.attr);
    --     panel:setLabelString("txt_att_name",name);
    --     panel:resetLayOut();
    -- end
    self:refreshAddedAttr();

    self:resetLayOut();
end

function TownAddAttrPanel:refreshAddedAttr()
    for key,var in pairs(Data.towerInfo.attr) do
        for k,attr in pairs(self.attr) do
            if(attr == var.attr)then
                self:replaceLabelString("txt_add_value"..k,var.val.."%");
                break;
            end
        end
    end    
end

function TownAddAttrPanel:onChooseAttr(data,index)
    -- print_lua_table(data);
    if(self.playAni)then
        return;
    end
    if(Data.towerInfo.isEnd)then
        gShowNotice(gGetWords("towerWords.plist","30"));
        return;
    end

    -- if(Data.towerInfo.attrnum <= 0)then
    --     gShowNotice(gGetWords("towerWords.plist","11"));
    --     return;
    -- end

    if(Data.towerInfo.star < data.star)then
        gShowNotice(gGetWords("towerWords.plist","10"));
        return;
    end

    self.addattrData = data;
    self.addattrIndex = index;
    Net.sendTowerAddAttr(data.star);
    -- gDispatchEvt(EVENT_ID_TOWER_ADD_ATTR);

end

function TownAddAttrPanel:onTouchEnded(target)
    -- target.touchName == "full_close" or 
    if target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
    end

end

function TownAddAttrPanel:getAddAttrAni()
    local particle =  cc.ParticleSystemQuad:create("particle/qp_lizi.plist");
    self:addChild(particle);
    -- print("self.addattrIndex = "..self.addattrIndex);
    local srcNode = self:getNode("layer_panels"):getNode(self.addattrIndex);
    if(srcNode)then
        local pos = gGetPositionByAnchorInDesNode(self,srcNode,cc.p(0.5,-0.5));
        particle:setPosition(pos);
        srcNode:chooseAni();
    end

    local desNode = nil;
    for key,var in pairs(self.attr) do
        if(var == self.addattrData.attr)then
            desNode = self:getNode("txt_add_value"..key);
            break;
        end
    end

    if(desNode)then
        local desPos = gGetPositionByAnchorInDesNode(self,desNode,cc.p(0.5,0.5));
        local callback = function()
            --粒子击中
            local hit = gCreateFla("qp_kapai_lizi_b");
            hit:setPosition(gGetPositionByAnchorInDesNode(self,desNode,cc.p(0.5,0.5)));
            -- gAddChildInCenterPos(desNode:getParent(),hit);
            self:addChild(hit);
            --刷新已加成属性
            -- self:refreshNewAddAttr();
            self.playAni = false;

            Panel.popBack(self:getTag())
        end
        particle:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.5,desPos),
                cc.CallFunc:create(callback),
                cc.RemoveSelf:create()
            ));
    end
end

function TownAddAttrPanel:refreshNewAddAttr()

    self:refreshAddedAttr();

    local items = self:getNode("layer_panels"):getAllNodes();
    for key,item in pairs(items) do
        item:refreshData(Data.towerInfo.addattr[key]);
    end
end

function TownAddAttrPanel:events()
    -- body
    return {EVENT_ID_TOWER_ADD_ATTR};
end

function TownAddAttrPanel:dealEvent(event)
    if(event == EVENT_ID_TOWER_ADD_ATTR) then

        self.playAni = true;
        -- print("before");
        -- print_lua_table(Data.towerInfo.attr);
        local find = false
        for key , var in pairs(Data.towerInfo.attr) do
            if var.attr == self.addattrData.attr then
                var.val = var.val + self.addattrData.val;
                find = true;
                break;
            end
        end
        if(find == false)then
            local newAttr = {};
            newAttr.attr = self.addattrData.attr;
            newAttr.val = self.addattrData.val;
            table.insert(Data.towerInfo.attr,newAttr); 
        end
        -- print("after");
        -- print_lua_table(Data.towerInfo.attr);
        -- Data.towerInfo.attrnum = Data.towerInfo.attrnum - 1;
        -- if(Data.towerInfo.attrnum <= 0)then
        --     Data.towerInfo.attrnum = 0;
        -- end
        Data.towerInfo.star = Data.towerInfo.star - self.addattrData.star;
        if(Data.towerInfo.star <= 0)then
            Data.towerInfo.star = 0;
        end

        --播放获得属性动画
        self:getAddAttrAni();

        -- self:setLabelString("txt_left_times",Data.towerInfo.attrnum);
        self:setLabelString("txt_cur_star",Data.towerInfo.star);

    end
end

return TownAddAttrPanel