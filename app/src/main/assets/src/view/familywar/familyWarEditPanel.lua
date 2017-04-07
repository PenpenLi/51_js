
local FamilyWarEditPanel=class("FamilyWarEditPanel",UILayer)

function FamilyWarEditPanel:ctor(param)
    self:init("ui/ui_family_war_edit.map")
    self:getNode("choose_icon"):setPositionY(1000000)

    self.isMainLayerGoldShow = false;
    self.isMainLayerMenuShow = false;
    self.isWindow = true;
    self.matchScroll=self:getNode("scroll")
    self.freeScroll=self:getNode("scroll2")

    local winSize=cc.Director:getInstance():getWinSize()
    winSize.height= self:getNode("scroll2").viewSize.height
    self:getNode("scroll2"):resize(winSize)
    self:getNode("scroll2"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    winSize.height= self:getNode("bg_bar"):getContentSize().height
    self:getNode("bg_bar"):setContentSize(winSize)

    self.matchScroll.eachLineNum=6
    self.matchScroll:setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)


    self:setLabelString("txt_name","")
    self:setLabelString("txt_power","")
    self:getNode("power_panel"):setVisible(false)
    self:getNode("btn_my_team"):setVisible(false)
    self:updateList(param);
    self.isChange=false
    if(gFamilyInfo.familyId~=param.familyid)then
        self.freeScroll:setVisible(false)
        self:getNode("normal_panel"):setVisible(false)
        self:getNode("edit_panel"):setVisible(false)

    elseif(not Data.isFamilyManager() )then
        self:getNode("btn_edit"):setVisible(false)
    end
    
end

function FamilyWarEditPanel:dealEvent(event,param)
    if(event==EVENT_ID_SAVE_FORMATION)then
        if(self.lastUid==gUserInfo.id)then
            Net.sendBuddyTeam( self.lastUid,TEAM_TYPE_FAMILY_WAR,EVENT_ID_FAMILY_WAR_GET_FORMATION)
        end
    elseif(event==EVENT_ID_FAMILY_WAR_GET_FORMATION)then
        self:initFormation(param)
    elseif(event==EVENT_ID_FAMILY_WAR_EDIT_LIST)then
        self:updateList(param)
    end
end

function  FamilyWarEditPanel:events()
    return {EVENT_ID_FAMILY_WAR_GET_MEMBER ,EVENT_ID_SAVE_FORMATION,EVENT_ID_FAMILY_WAR_EDIT_LIST,EVENT_ID_FAMILY_WAR_GET_FORMATION}
end

function  FamilyWarEditPanel:initFormation(param)
    self:setLabelString("txt_name",param.name)
    self:setLabelString("txt_power",param.power)
    if(param.uid==gUserInfo.id)then
        self:getNode("btn_my_team"):setVisible(true)
    else
        self:getNode("btn_my_team"):setVisible(false)
    end

    for i=0, 6 do
        local node = self:getNode("pos"..i);
        node:removeAllChildren(true)
        node:setOpacity(255);

    end

    for key,card in pairs(param.team.clist) do
        local node = self:getNode("pos"..card.pos);
        local item = FormationCardItem.new(card);
        node:setOpacity(0);
        gAddChildByAnchorPos(node,item,cc.p(0,1));
    end

    if param.team.pid > 0 then
        local node = self:getNode("pos6");
        local item = FormationCardItem.new({isPet=true,cid=param.team.pid,lv=param.team.plv,gd=param.team.pgd,qlt=0});
        node:setOpacity(0);
        gAddChildByAnchorPos(node,item,cc.p(0,1));
    end
    self:getNode("power_panel"):setVisible(true)
end

function FamilyWarEditPanel:updateList(data)
    local function sort(mem1,mem2)
        return mem1.iPower>mem2.iPower
    end
    if(gFamilyInfo.familyId~=data.familyid)then 
        data.match=gRandSortTable(data.match)
    end
    table.sort(data.free,sort)
    self.curData=data
    self:initMembers(data.match,self.matchScroll)
    self:initMembers(data.free,self.freeScroll)
    self:setEditMode(false)
end



function FamilyWarEditPanel:setEditMode(mode)

    for key,item in ipairs(self.matchScroll.items) do
        item:setEditMode(mode)
    end

    for key,item in ipairs(self.freeScroll.items) do
        item:setEditMode(mode)
    end
    if(mode)then
        self:getNode("edit_panel"):setVisible(true)
        self:getNode("normal_panel"):setVisible(false)
    else
        self:getNode("edit_panel"):setVisible(false)
        self:getNode("normal_panel"):setVisible(true)

    end
    self:refreshLastUid() 
end




function FamilyWarEditPanel:initMembers(list,node,editable)
    node:clear();
    local maxOutNum=18
    local maxNum=24
    local idx=0
    for key,value in ipairs(list) do
        local item = self:createOneFamily(value,key);
        node:addItem(item);
        idx=idx+1

        if(node==self.freeScroll)then
            item.canMoveH=true
        end
    end
    if(node==self.matchScroll)then  
        for i=idx, maxNum-1 do
            local item=FamilyWarEditItem.new();
            item:setIndex(i+1)
            node:addItem(item);
        end
    end
    node:layout(count==0);
end

function FamilyWarEditPanel:refreshLastUid() 
    self:getNode("choose_icon"):setPositionY(1000000)
    for key,item in ipairs(self.matchScroll.items) do 
        if(item.isEditMode~=true and item.curData and item.curData.uid==self.lastUid)then 
            local posx,posy=item:getPosition()
            posx=posx+item:getContentSize().width/2
            posy=posy-item:getContentSize().height/2
            self:getNode("choose_icon"):setVisible(true)
            self:getNode("choose_icon"):setPositionX(posx)
            self:getNode("choose_icon"):setPositionY(posy)
        end
    end 
end

function FamilyWarEditPanel:createOneFamily(data,index)
    local item=FamilyWarEditItem.new();
    item:setData(data, index);
    item.selectItemCallback=function (data,idx)
        self.lastUid=data.uid 
        self:refreshLastUid() 
        Net.sendBuddyTeam(data.uid,TEAM_TYPE_FAMILY_WAR,EVENT_ID_FAMILY_WAR_GET_FORMATION)
    end

    item.dragCallback=function (item,worldPos)
        self:saveOldPos()
        local isChange=false
        if(self:isInMatchContainer(worldPos) and self:isInFreeList(item))then
            self:moveToMatch(item,worldPos)
            isChange=true
            item.canMoveH=false
        elseif(self:isInFreeContainer(worldPos) and self:isInFreeList(item)==false)then
            self:moveToFree(item)
            isChange=true
            item.canMoveH=true
        elseif(self:isInMatchContainer(worldPos) and self:isInFreeList(item)==false)then
            self:editMatchPos(item,worldPos)
            isChange=true
            item.canMoveH=false
        end
        if(isChange)then
            self.isChange=true
            self:saveNewPos()
            self:moveNewPos()
            item:setLocalZOrder(2)
            item:stopAllActions()
            item:setPosition(item.newPos)
            item:showPutIn()
        end
        self:refreshLastUid() 
    end
    return item;
end

function FamilyWarEditPanel:moveNewPos()
    for key, var in pairs(self.matchScroll.items) do
        var:stopAllActions()
        if(var.oldPos~=nil)then
            var:setPosition(var.oldPos)
            var:runAction(cc.MoveTo:create(0.2,var.newPos))
        else
            var:setPosition(var.newPos)

        end
        var:setEditMode(true)
    end

    for key, var in pairs(self.freeScroll.items) do
        var:stopAllActions()
        if(var.oldPos~=nil)then
            var:setPosition(var.oldPos)
            var:runAction(cc.MoveTo:create(0.2,var.newPos))
        else
            var:setPosition(var.newPos)
        end
        var:setEditMode(true)
    end
end

function FamilyWarEditPanel:saveNewPos()
    for key, var in pairs(self.matchScroll.items) do
        var.newPos=cc.p(var:getPosition())
    end
    for key, var in pairs(self.freeScroll.items) do
        var.newPos=cc.p(var:getPosition())
    end
end


function FamilyWarEditPanel:saveOldPos()
    for key, var in pairs(self.matchScroll.items) do
        var.oldPos=cc.p(var:getPosition())
    end
    for key, var in pairs(self.freeScroll.items) do
        var.oldPos=cc.p(var:getPosition())
    end
end

function FamilyWarEditPanel:getMatchIndexByPos(pos)
    local pos=self.matchScroll.container:convertToNodeSpace(pos)
    local retKey=nil
    local totalKey=0
    for key, var in pairs(self.matchScroll.items) do
        local posx,posy=var:getPosition()
        if(var.curData )then
            if(pos.x>=posx and
                pos.y<posy and
                pos.x<=posx+var:getContentSize().width and
                pos.y>=posy-var:getContentSize().height
                )then
                retKey= key
            end
            totalKey=totalKey+1
        end
    end
    if(retKey)then
        return retKey
    end
    return totalKey
end

function FamilyWarEditPanel:editMatchPos(item,worldPos)
    local removeKey=nil
    for key, var in pairs(self.matchScroll.items) do
        if(var==item)then
            removeKey=key
        end
    end
    local idx=self:getMatchIndexByPos(worldPos)
    local matchCount=self:getMatchTotalNum()
    if(idx>matchCount)then
        idx=matchCount
    end

    if(removeKey~=idx)then
        table.remove(self.matchScroll.items,removeKey)
        table.insert(self.matchScroll.items,idx,item)
        self.matchScroll:layout()
    end
end

function FamilyWarEditPanel:getMatchTotalNum()
    local ret=0
    for key, item in pairs(self.matchScroll.items) do
        if(item.curData)then
            ret=ret+1
        end
    end
    return ret
end

function FamilyWarEditPanel:moveToMatch(item,worldPos)
    local matchCount=self:getMatchTotalNum()
    local maxNum=DB.getFamilyWarJoinNum(gFamilyInfo.iLevel)
    if(matchCount>=maxNum)then
        gShowNotice(gGetWords("noticeWords.plist","family_war_max_num",maxNum))
        return
    end

    local temp=self.matchScroll.items[matchCount+1]
    if(temp)then
        temp:removeFromParent()
    end
    table.remove(self.matchScroll.items,matchCount+1)

    self:moveToContainer( item, self.freeScroll, self.matchScroll)
    self.freeScroll:layout(false)
    self.matchScroll:layout()
    self:editMatchPos(item,worldPos)
end


function FamilyWarEditPanel:moveToContainer(item,container1,container2)
    for key, var in pairs(container1.items) do
        if(var==item)then
            table.remove(container1.items,key)
            break
        end
    end
    item:retain()
    item:removeFromParent()
    container2:addItem(item)
    item:release()
end


function FamilyWarEditPanel:moveToFree(item)

    self:moveToContainer( item, self.matchScroll, self.freeScroll)
    self.freeScroll:layout(false)
    self.matchScroll:layout()

    local matchCount=self:getMatchTotalNum()
    local item=FamilyWarEditItem.new();
    item:setIndex(matchCount+1)
    self.matchScroll:addItem(item,matchCount);
    self.matchScroll:layout()
end

function FamilyWarEditPanel:isInMatchContainer(pos)
    local rect=self.matchScroll:getViewRect()
    local isInSide=cc.rectContainsPoint(rect, pos)

    return isInSide
end


function FamilyWarEditPanel:isInFreeContainer(pos)
    local rect=self.freeScroll:getViewRect()
    local isInSide=cc.rectContainsPoint(rect, pos)

    return isInSide
end

function FamilyWarEditPanel:isInFreeList(item)
    for key, var in pairs(self.freeScroll.items) do
        if(item==var)then
            return true
        end
    end
    return false
end


function FamilyWarEditPanel:onSave()
    local ids={}
    for key, var in pairs(self.matchScroll.items) do
        if(var.curData)then
            table.insert(ids,var.curData.uid)
        end
    end
    Net.sendFamilyTeamSave(ids)
    self:setEditMode(false)
    self.isChange=false
end

function FamilyWarEditPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        if(self.isChange)then 
            local function onOk()
                self:onSave()
                self:onClose();
            end
            local function onCancel() 
                self:onClose();
            end
            gConfirmCancel(gGetWords("familyWords.plist","check_save_family_team"),onOk,onCancel)
        else

            self:onClose();
        end
    elseif(target.touchName=="btn_my_team")then
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_FAMILY_WAR)
    elseif target.touchName=="btn_family" then
        Panel.popUp(PANEL_FAMILY_WAR_EDIT)
    elseif target.touchName=="btn_edit" then
        self:setEditMode(true)
    elseif target.touchName=="btn_cancel" then
        self:setEditMode(false)
        Net.sendFamilyTeamInfo(gFamilyInfo.familyId)
    elseif target.touchName=="btn_save" then
       self:onSave()
    end
end


return FamilyWarEditPanel