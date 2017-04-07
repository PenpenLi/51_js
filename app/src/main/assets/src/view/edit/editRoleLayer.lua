local EditRoleLayer=class("EditRoleLayer",UILayer)

 
function EditRoleLayer:ctor()
    self.fileName="mainScene.plist"
    self:init("ui/ui_edit_role.map")
    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self:getNode("bg"):setDepth2D(true)
    self:getNode("bg"):setPositionZ(-200)

    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll").offsetY=0
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    for key, card in pairs(gCardAnimateFlag) do
        local item=EditObjItem.new()
        item:setData(card)
        item.onSelectCallback=function(card)
            self:setSelectRole(card)
        end
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()




    self:getNode("scroll2").eachLineNum=1
    self:getNode("scroll2").offsetY=0
    self:getNode("scroll2"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)


    for key, action in pairs(EditUtils.actions) do
        local item=EditActionItem.new()
        item.editCallback=function (card) 
            self:setSelectAction(card)
            self.curSelectRole[self.curSelectAction]=item.curData
        end
        item:setActionName(action)
        item.onSelectCallback=function(card)
            self:setSelectAction(card)
        end
        self:getNode("scroll2"):addItem(item)
    end
    self:getNode("scroll2"):layout()


    self:getNode("scroll2"):layout()
    self:setSelectRole(self:getNode("scroll").items[1].curData)

end





function EditRoleLayer:setSelectRole(obj)
    self.curSelectRole=obj
    self:refreshSelectedRole()

    for key, item in pairs(self:getNode("scroll2").items) do
        local data= self.curSelectRole[item.curActionName]
        item:setData(data)
    end

    if(self.curActionName==nil)then
        self.curActionName=self:getNode("scroll2").items[1].curActionName
    end

    self:setSelectAction(self.curActionName)
end


function EditRoleLayer:initCardAni(startFlag,endFlag)
    local cardid=self.curSelectRole.cardid
    local url="c3b/card/"..cardid..".c3b"
    local obj=cc.Sprite3D:create(url)

    local animation = cc.Animation3D:create(url)
    if nil ~= animation then
        local animate = cc.Animate3D:create(animation,startFlag,endFlag-startFlag)
        obj:runAction(cc.RepeatForever:create(animate))
    end
    self:getNode("role_container"):removeAllChildren()
    gAddCenter( obj,self:getNode("role_container"))
end



function EditRoleLayer:setSelectAction(action)
    if(self.curSelectRole==nil)then
        return
    end
    self.curSelectAction=action
    self:refreshSelectedAction()

    local item=self:getActionItemByName(action)

    local actionKey=""
    if(action=="skill")then
        self:getNode("event_flag"):setVisible(true)
        actionKey="skill_"..self.curSelectRole.cardid
    elseif( action=="skill2")then
        self:getNode("event_flag"):setVisible(true)
        actionKey="skill_"..self.curSelectRole.cardid.."_2"
    else
        self:getNode("event_flag"):setVisible(false)
    end



    self:setStartPos(item.startFlag)
    self:setEndPos(item.endFlag)


    self:initCardAni(item.startFlag,item.endFlag)


    self.curActionEventKey=actionKey
    self.curActionDuring=item.endFlag-item.startFlag
    self.curActionStartFlag= item.startFlag
    if(actionKey~="")then
        self:getNode("icon_container"):removeAllChildren()
        if(gCardAnimateEvent[actionKey])then
            for key, events in pairs(gCardAnimateEvent[actionKey]) do
                local temp =string.split(events,":")
                self:createEventFlag(temp[1],tonum(temp[2]),temp[3],temp[4],temp[5],temp[6])
            end
        end
    end

end

function EditRoleLayer:setStartPos(num)
    local arrowWidth=self:getNode("start"):getContentSize().width
    local timeLineWidth=self:getTimeLineWidth()
    local timeLineStartX=self:getNode("timeline1"):getPositionX()-timeLineWidth/2

    self:getNode("start"):setPositionX( timeLineStartX+ (num/5)*timeLineWidth-arrowWidth/2)

end



function EditRoleLayer:setEndPos(num)
    local arrowWidth=self:getNode("start"):getContentSize().width
    local timeLineWidth=self:getTimeLineWidth()
    local timeLineStartX=self:getNode("timeline1"):getPositionX()-timeLineWidth/2
    self:getNode("end"):setPositionX( timeLineStartX+ (num/5)*timeLineWidth+arrowWidth/2)

end





function EditRoleLayer:onTouchMoved(target,touch, event)
    local isMove=false
    local posX=touch:getDelta().x
    if(target.touchName=="start")then
        isMove=true
        self:getNode("start"):setPositionX(self:getNode("start"):getPositionX()+posX)
    elseif(target.touchName=="end")then
        isMove=true
        self:getNode("end"):setPositionX(self:getNode("end"):getPositionX()+posX)

    elseif(target.touchName=="curflag")then
        self:getNode("curflag"):setPositionX(self:getNode("curflag"):getPositionX()+posX)
        self:initCardAni(self:getCurFlag(),self:getCurFlag())
        return

    elseif(string.find(target.touchName,"curflagEvent"))then
        target:setPositionX(target:getPositionX()+posX)
        self:initCardAni(self:getCurEventFlag(target),self:getCurEventFlag(target))
        return

    end

    if(isMove==false)then
        return
    end

    local startX=self:getNode("start"):getPositionX()
    local endX=self:getNode("end"):getPositionX()
    local arrowWidth=self:getNode("start"):getContentSize().width
    local timeLineWidth=self:getTimeLineWidth()
    local timeLineStartX=self:getNode("timeline1"):getPositionX()-timeLineWidth/2

    if(startX<timeLineStartX-arrowWidth/2)then
        self:getNode("start"):setPositionX( timeLineStartX-arrowWidth/2)
    end

    if(endX<timeLineStartX+arrowWidth/2)then
        self:getNode("end"):setPositionX( timeLineStartX+arrowWidth/2)
    end



    self:refreshSelectedAction()
    local item=self:getActionItemByName(self.curSelectAction)
    item:setFlag(self:getStartFlag(),self:getEndFlag())
    self.curSelectRole[self.curSelectAction]=item.curData
    self:initCardAni(item.startFlag,item.endFlag)
end

function EditRoleLayer:getEndFlag()
    local endX=self:getNode("end"):getPositionX()
    local arrowWidth=self:getNode("start"):getContentSize().width
    local timeLineWidth=self:getTimeLineWidth()
    local timeLineStartX=self:getNode("timeline1"):getPositionX()-timeLineWidth/2

    local offset= (endX-timeLineStartX-arrowWidth/2)/timeLineWidth
    return offset*5
end


function EditRoleLayer:getCurEventFlag(target)
    local timeLineWidth=self:getTimeLineWidth() *4
    local offset= (target:getPositionX())/timeLineWidth
    return self.curActionStartFlag +offset*self.curActionDuring
end


function EditRoleLayer:getCurFlag()
    local curX=self:getNode("curflag"):getPositionX()
    local arrowWidth=self:getNode("start"):getContentSize().width
    local timeLineWidth=self:getTimeLineWidth()
    local timeLineStartX=self:getNode("timeline1"):getPositionX()-timeLineWidth/2

    local offset= (curX-timeLineStartX)/timeLineWidth
    return offset*5
end


function EditRoleLayer:getTimeLineWidth()
    return self:getNode("timeline1"):getContentSize().width
end


function EditRoleLayer:getStartFlag()
    local startX=self:getNode("start"):getPositionX()
    local arrowWidth=self:getNode("start"):getContentSize().width
    local timeLineWidth=self:getTimeLineWidth()
    local timeLineStartX=self:getNode("timeline1"):getPositionX()-timeLineWidth/2

    local offset= (startX-timeLineStartX+arrowWidth/2)/timeLineWidth

    return offset*5
end

function EditRoleLayer:saveEvents()
    local childrenSort={}
    local children = self:getNode("icon_container"):getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        table.insert(childrenSort,children[i + 1])
    end
    
    if(self.curSelectEventIcon)then
        for i=1, 4 do
            self.curSelectEventIcon["param"..i]=nil
        	if(self:getNode("txt_param"..i):getText()~="")then
                self.curSelectEventIcon["param"..i]=tonum(self:getNode("txt_param"..i):getText())
        	end
        end
        
    end

    local function sortChild(child1,child2)
        if(child1:getPositionX() <child2:getPositionX()) then
            return true
        end
        return false
    end
    table.sort(childrenSort,sortChild)


    if(self.curActionEventKey~="")then
        local events={}
        for key, child in pairs(childrenSort) do 
            local event=""
            event=event..child.type..":"..string.format("%.2f" ,(self:getCurEventFlag(child)-self.curActionStartFlag))
            if(child.param1)then
                event=event..":"..child.param1
            end

            if(child.param2)then
                event=event..":"..child.param2
            end

            if(child.param3)then
                event=event..":"..child.param3
            end

            if(child.param4)then
                event=event..":"..child.param4
            end


            table.insert(events,event)
        end
        gCardAnimateEvent[self.curActionEventKey]=events
    end

end

function EditRoleLayer:onTouchEnded(target)


    if(target.touchName=="btn_save")then
        self:saveEvents()

        local objs={}
        for key, item in pairs(self:getNode("scroll").items) do
            local obj=item.curData
            table.insert(objs,obj)
        end

        EditUtils.getSaveRoleDic(objs)
    elseif(target.touchName=="btn_action_run_to")then
        self:createEventFlag("run_to",0)
        self:createEventFlag("reach",0)
        self:createEventFlag("run_back",0)
        self:createEventFlag("reach",0)
    elseif(target.touchName=="btn_action_attack")then
        self:createEventFlag("attack",0)

    elseif(string.find(target.touchName,"curflagEvent"))then
        for i=1, 4 do
            if(target["param"..i])then
                self:setLabelString("txt_param"..i,target["param"..i])
            else 
                self:setLabelString("txt_param"..i,"")
            end
       	
       end 
       self.curSelectEventIcon=target
    end

end


function EditRoleLayer:createEventFlag(type,pos,param1,param2,param3,param4)
    local icon=cc.Sprite:create("images/ui_public1/small_jiantou2.png")
    self:getNode("icon_container"):addChild(icon)
    local lab=cc.Label:create()
    lab:setSystemFontSize(12)
    lab:setSystemFontName("Helvetica-Bold")
    lab:setDimensions( 100,0)
    lab:setString(type)
    lab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)


    icon:addChild(lab)
    lab:setColor(cc.c3b(0,0,0));
    icon.param1=param1
    icon.param2=param2
    icon.param3=param3
    icon.param4=param4
    icon.type=type
    self:addTouchNode(icon,"curflagEvent","1")
    icon:setPositionX( (pos/self.curActionDuring)*self:getTimeLineWidth() *4 )
end

function EditRoleLayer:refreshSelectedRole()
    for key, item in pairs(self:getNode("scroll").items) do
        if(item.curData==self.curSelectRole)then
            item:getNode("icon"):setVisible(true)
        else
            item:getNode("icon"):setVisible(false)
        end
    end

end


function EditRoleLayer:getActionItemByName(name)

    for key, item in pairs(self:getNode("scroll2").items) do
        if(item.curActionName==name)then
            return item
        end
    end
    return nil
end

function EditRoleLayer:refreshSelectedAction()
    for key, item in pairs(self:getNode("scroll2").items) do
        if(item.curActionName==self.curSelectAction)then
            item:getNode("icon"):setVisible(true)
        else
            item:getNode("icon"):setVisible(false)
        end
    end
end



return EditRoleLayer