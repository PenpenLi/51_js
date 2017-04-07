local EditUVLayer=class("EditUVLayer",EditModeLayer)


function EditUVLayer:ctor()
    setScreenEditSize()
    self:init("ui/ui_edit_uv.map")
    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self:getNode("bg"):setDepth2D(true)
    self:getNode("bg"):setPositionZ(-1200)

    self:getNode("skill_scroll").eachLineNum=1
    self:getNode("skill_scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)


    self:getNode("timeline_scroll"):setDir( cc.SCROLLVIEW_DIRECTION_HORIZONTAL)


    self:getNode("mesh_scroll").eachLineNum=1
    self:getNode("mesh_scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self:getNode("role_scroll").eachLineNum=1
    self:getNode("role_scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)


    self.curObjContainer=self:getNode("container")
    self.curBtnType=nil

    self.timeScale=3
    self.curRoleSkillType=2

    for key, skill in pairs(gSkillUVFlag) do
        local item=EditObjItem.new()
        item:setData(skill)
        item.onSelectCallback=function(skill)
            self:setSelectSkill(skill)
        end
        self:getNode("skill_scroll"):addItem(item)
    end
    self:getNode("skill_scroll"):layout()


    for key, card in pairs(gCardAnimateFlag) do
        local item=EditObjItem.new()
        item:setData(card)
        item.onSelectCallback=function(card)
            self.curSelectRole=card
            self:initSkillAni(self:getCurFlag(),self:getCurFlag())
        end
        self:getNode("role_scroll"):addItem(item)
    end
    self:getNode("role_scroll"):layout()
    self:setSelectSkill( self:getNode("skill_scroll").items[1].curData)

    local function _update()
        self:updateControl()

        local disY=self:getNode("mesh_scroll").container:getPositionY()- self:getNode("mesh_scroll").container.oldPosY
        for key, item in pairs(self:getNode("timeline_scroll").items) do
            item:setPositionY(item.oldPosY+disY)
        end

    end
    self:scheduleUpdateWithPriorityLua(_update, 0)

    local function onEditCallback(name, sender)
        if(name=="changed")then
            self:saveEditData()
        end
    end
    self:getNode("txt_param_a"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("txt_param_r"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("txt_param_g"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("txt_param_b"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("txt_param_x"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("txt_param_y"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_px"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_py"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_pz"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_rx"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_ry"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_rz"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_sx"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_sy"):registerScriptEditBoxHandler(onEditCallback)
    self:getNode("input_sz"):registerScriptEditBoxHandler(onEditCallback)

    self:inited()
end

--初始化人物动画
function EditUVLayer:initRoleAni(startFlag,endFlag)
    self:getNode("role_container"):removeAllChildren()
    if(self.curSelectRole==nil)then
        return
    end
    local cardid=  self.curSelectRole.cardid
    local url="c3b/card/"..cardid..".c3b"
    local obj=cc.Sprite3D:create(url)

    local roleStartFlag,roleEndFlag= gGetRoleAni(cardid,"skill2")
    local animation = cc.Animation3D:create(url)
    if nil ~= animation then
        local animate = cc.Animate3D:create(animation,startFlag+roleStartFlag,endFlag-startFlag)
        obj:runAction(cc.RepeatForever:create(animate))
    end
    self:getNode("role_container"):removeAllChildren()
    gAddCenter( obj,self:getNode("role_container"))

end

--初始化技能动画
function EditUVLayer:initSkillAni(startFlag,endFlag)
    local skillName=self.curSelectSkill.skillName
    local url="c3b/skill/"..skillName
    local obj=cc.Sprite3D:create(url)
    self.curSkillSprite=obj
    self:getNode("skill_container"):removeAllChildren()
    gAddCenter( obj,self:getNode("skill_container"))

    local meshes={}
    gGetSpriteMeshes( self.curSkillSprite,meshes)
    for key, mesh in pairs(meshes) do
        local frames=self:getMeshFrames(mesh:getName())
        if(frames and table.getn(frames)~=0)then
            local data=gGetFrameData(frames,startFlag)
            mesh:setColor(cc.c3b(data.r,data.g,data.b))
            if(data.a==0)then
                mesh:setVisible(false)
            else
                mesh:setVisible(true)
            end
            mesh:setOpacity(data.a)
            mesh:setPosition3D(cc.vec3(data.px,data.py,data.pz))
            mesh:setRotation3D(cc.vec3(data.rx,data.ry,data.rz))
            mesh:setScaleX(data.sx)
            mesh:setScaleY(data.sy)
            mesh:setScaleZ(data.sz)
            
            if(self.curSelectMeshName==nil)then
                self.curSelectMeshName=mesh:getName()
            end 
             local state=cc.GLProgramState:create( Shader.getShader(Shader.UV_ANI_SHADER))
             mesh:setGLProgramState(state)
             state:setUniformVec2("texOffset",cc.p(tonum(data.ux),tonum(data.uy))) 
        end
    end

    if(self.curSkillData.blendSrc and self.curSkillData.blendDst)then
        gSetChildBlendFunc(self.curSkillSprite, self.curSkillData.blendSrc,self.curSkillData.blendDst)
    end

    self:initRoleAni(self:getCurFlag(),self:getCurFlag()) 
    self:setSelectMesh(self.curSelectMeshName)
   
end



--选择技能
function EditUVLayer:setSelectSkill(obj)
    self.curSelectSkill=obj
    self.curSkillData=EditUtils.loadAni(self.curSelectSkill.skillName)
    self:refreshSelectedSkill()
    self:initSkillAni(0,0)

    self:getNode("mesh_scroll"):clear()
    self:getNode("timeline_scroll"):clear()

    local meshes={}
    gGetSpriteMeshes( self.curSkillSprite,meshes)
    for key, mesh in pairs(meshes) do
        local item=EditObjItem.new()
        item:setData(mesh:getName())
        item.onSelectCallback=function(skill)
            self:setSelectMesh(skill)
        end
        self:getNode("mesh_scroll"):addItem(item)

        local timeline=EditTimeline.new()
        timeline:setData(mesh:getName())
        self:getNode("timeline_scroll"):addItem(timeline)
        item.timeline=timeline

        timeline.meshName=mesh:getName()
        timeline:getNode("icon_container"):removeAllChildren()

        if(self.curSkillData.meshes)then

            local meshFrame=self.curSkillData.meshes[mesh:getName()] 
            if(meshFrame)then
                for key, frame in pairs(meshFrame) do
                    self:createKeyFrame(frame,timeline)
                end
            end
        end
    end


    self:getNode("mesh_scroll"):layout()
    self:getNode("mesh_scroll").container.oldPosY=self:getNode("mesh_scroll").container:getPositionY()
    self:layoutTimeline()
    self:refreshSelectedMesh()
end



function EditUVLayer:getCurFlag(icon)
    local curX=self:getNode("curflag"):getPositionX()
    if(icon)then
        curX=icon:getPositionX()
    end
    local timeLineWidth=self:getTimeLineWidth()
    local offset= curX/timeLineWidth
    return offset*5
end


function EditUVLayer:getTimeLineWidth()
    return self:getNode("timeline1"):getContentSize().width*self.timeScale
end



function EditUVLayer:onTouchMoved(target,touch, event)
    local posX=touch:getDelta().x
    self:_onTouchMoved(target, touch)
    if(target.touchName=="curflag")then
        local targetPos=target:getPositionX()+posX
        if(targetPos<0)then
            targetPos=0
        end
        self:getNode("curflag"):setPositionX(targetPos)
        self:initSkillAni(self:getCurFlag(),self:getCurFlag())

    elseif(string.find(target.touchName,"curflagEvent"))then
        local targetPos=target:getPositionX()+posX
        if(targetPos<0)then
            targetPos=0
        end
        target._isScollMove=false
        target._hasScrollParent=false
        target:setPositionX(targetPos)
    end
end




function EditUVLayer:createKeyFrame(data,timeline)
    local icon=cc.Sprite:create("images/editor/frame.png")
    timeline:getNode("icon_container"):addChild(icon)
    self:addTouchNode(icon,"curflagEvent","1") 
    icon.__touchend=true
    icon:setPositionY(-icon:getContentSize().height/2)
    if(data)then
        local during=tonum(data.during)
        icon:setPositionX((during/5)*self:getTimeLineWidth() )
    else
        data={r=255,g=255,b=255,a=255,ux=0,uy=0}
        local pos=self.curSelectObj:getPosition3D()
        data.px=string.format("%.1f", pos.x) 
        data.py=string.format("%.1f", pos.y) 
        data.pz=string.format("%.1f", pos.z) 
        pos=self.curSelectObj:getRotation3D()
        data.rx=string.format("%.1f", pos.x) 
        data.ry=string.format("%.1f", pos.y) 
        data.rz=string.format("%.1f", pos.z) 
        data.sx=string.format("%.1f",self.curSelectObj:getScaleX())
        data.sy=string.format("%.1f",self.curSelectObj:getScaleY())
        data.sz=string.format("%.1f",self.curSelectObj:getScaleZ())
    end
    icon.frame=data
    return icon
end

function EditUVLayer:selectFrame(icon)
    self.curFrameIcon=icon



    self:setLabelString("txt_param_r",icon.frame.r)
    self:setLabelString("txt_param_g",icon.frame.g)
    self:setLabelString("txt_param_b",icon.frame.b)
    self:setLabelString("txt_param_a",icon.frame.a)
    self:setLabelString("txt_param_x",icon.frame.ux)
    self:setLabelString("txt_param_y",icon.frame.uy)



    self:setLabelString("input_px",icon.frame.px)
    self:setLabelString("input_py",icon.frame.py)
    self:setLabelString("input_pz",icon.frame.pz)

    self:setLabelString("input_rx",icon.frame.rx)
    self:setLabelString("input_ry",icon.frame.ry)
    self:setLabelString("input_rz",icon.frame.rz)

    self:setLabelString("input_sx",icon.frame.sx)
    self:setLabelString("input_sy",icon.frame.sy)
    self:setLabelString("input_sz",icon.frame.sz)

    self.curSkillSprite:setOpacity(toint(icon.frame.a))
    self.curSkillSprite:setColor(cc.c3b(toint(icon.frame.r),toint(icon.frame.g),toint(icon.frame.r)))
end

function EditUVLayer:saveFrameData(icon)
    self.curFrameIcon=icon
    icon.frame.r=self:getInputValue("txt_param_r")
    icon.frame.g=self:getInputValue("txt_param_g")
    icon.frame.b=self:getInputValue("txt_param_b")
    icon.frame.a=self:getInputValue("txt_param_a")
    icon.frame.ux=self:getInputValue("txt_param_x" ,1)
    icon.frame.uy=self:getInputValue("txt_param_y" ,1)

    icon.frame.px=self:getInputValue("input_px" ,1)
    icon.frame.py=self:getInputValue("input_py" ,1)
    icon.frame.pz=self:getInputValue("input_pz" ,1)
    icon.frame.rx=self:getInputValue("input_rx" ,1)
    icon.frame.ry=self:getInputValue("input_ry" ,1)
    icon.frame.rz=self:getInputValue("input_rz" ,1)
    icon.frame.sx=self:getInputValue("input_sx" ,1)
    icon.frame.sy=self:getInputValue("input_sy" ,1)
    icon.frame.sz=self:getInputValue("input_sz" ,1)
end


function EditUVLayer:saveSkillData()
    self:refreshMeshFrameData()
    EditUtils.saveAni( self.curSelectSkill.skillName,self.curSkillData)
end


function EditUVLayer:saveEditData()
    if(self.curFrameIcon)then
        self:saveFrameData(self.curFrameIcon)
        self:refreshMeshFrameData()
    end
end

function EditUVLayer:onTouchBegan(target,touch, event)

    self:_onTouchBegan(target,touch, event)
end
function EditUVLayer:onTouchEnded(target,touch, event)
    self:_onTouchEnded(target, touch)
    if(target.touchName=="btn_save")then
        self:saveSkillData()
    elseif(target.touchName=="btn_edit_frame")then
        if(self.curFrameIcon)then
            self:saveFrameData(self.curFrameIcon)
            self:refreshMeshFrameData()
        end
    elseif(target.touchName=="btn_add_frame")then
        local timeline=self:getCurTimeLine()
        if(timeline)then
            local icon=self:createKeyFrame(nil,timeline)
            self:refreshMeshFrameData()
            self:selectFrame(icon)
        end
    elseif(target.touchName=="btn_remove_frame")then
        if(self.curFrameIcon)then
            self.curFrameIcon:removeFromParent()
            self:refreshMeshFrameData()
        end
    elseif(target.touchName=="btn_normal")then
        self.curSkillData.blendSrc=gl.ONE
        self.curSkillData.blendDst= gl.ONE_MINUS_SRC_ALPHA
        self:saveSkillData()
        self:initSkillAni(self:getCurFlag(),self:getCurFlag())
    elseif(target.touchName=="btn_add")then
        self.curSkillData.blendSrc=gl.SRC_ALPHA
        self.curSkillData.blendDst= gl.ONE
        self:saveSkillData()
        self:initSkillAni(self:getCurFlag(),self:getCurFlag())
    elseif(target.touchName=="btn_multiply")then
        self.curSkillData.blendSrc=gl.DST_COLOR
        self.curSkillData.blendDst= gl.ONE_MINUS_SRC_ALPHA
        self:saveSkillData()
        self:initSkillAni(self:getCurFlag(),self:getCurFlag())
    elseif(target.touchName=="btn_screen")then
        self.curSkillData.blendSrc=gl.ONE
        self.curSkillData.blendDst= gl.ONE_MINUS_SRC_COLOR
        self:saveSkillData()
        self:initSkillAni(self:getCurFlag(),self:getCurFlag())

    elseif(string.find(target.touchName,"curflagEvent"))then
        self:refreshMeshFrameData()
        self:selectFrame(target)
        target._hasScrollParent=true

    elseif(target.touchName=="btn_move_arrow1" or
        target.touchName=="btn_move_arrow2" or
        target.touchName=="btn_move_arrow3" or
        target.touchName=="btn_scale_arrow1" or
        target.touchName=="btn_scale_arrow2" or
        target.touchName=="btn_scale_arrow3" or
        target.touchName=="btn_rotation_arrow1" or
        target.touchName=="btn_rotation_arrow2" or
        target.touchName=="btn_rotation_arrow3")then

        if(self.curFrameIcon)then
            self:saveFrameData(self.curFrameIcon)
            self:refreshMeshFrameData()
        end
    end
end





function EditUVLayer:setSelectMesh(name)
    self.curFrameIcon=nil
    self.curSelectMeshName=name
    self:refreshSelectedMesh()
    self:setSelectObj(gGetSpriteMesheByName(self.curSkillSprite,self.curSelectMeshName))
end


function EditUVLayer:getMeshFrames(meshName)
    if(self.curSkillData.meshes==nil)then
        return nil
    end
    return self.curSkillData.meshes[meshName]
end


function  EditUVLayer:refreshMeshFrameData() 

    if(self.curSkillData.meshes==nil)then
        self.curSkillData.meshes={}
    end
    for key, item in pairs(self:getNode("mesh_scroll").items) do
        local timeline=self:getTimeLine(item.curData)
        self:refreshTimelineFrameData(timeline)
    end
end

function  EditUVLayer:refreshTimelineFrameData(timeline)

    local childrenSort={}
    local children = timeline:getNode("icon_container"):getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        table.insert(childrenSort,children[i + 1])
    end

    local function sortChild(child1,child2)
        if(child1:getPositionX() <child2:getPositionX()) then
            return true
        end
        return false
    end
    table.sort(childrenSort,sortChild)

    self.curSkillData.meshes[timeline.meshName]={}

    for key, icon in pairs(childrenSort) do
        local obj=icon.frame
        icon.key=key
        icon:setTag(key)
        obj.during=self:getCurEventFlag(icon)
        table.insert(self.curSkillData.meshes[timeline.meshName],obj)
    end

end


function EditUVLayer:getCurEventFlag(target)
    local timeLineWidth=self:getTimeLineWidth()
    local offset= (target:getPositionX())/timeLineWidth
    return offset*5
end




function EditUVLayer:layoutTimeline()
    local scroll=self:getNode("timeline_scroll")
    local idx=0

    local containerSize=scroll:getContentSize()
    local colNum=scroll.eachLineNum
    local totalHeight=(scroll.itemHeight+scroll.offsetY)*math.ceil(table.getn(scroll.items)/colNum)+scroll.padding*2
    local totalWidth=scroll.itemWidth+scroll.offsetX+scroll.padding*2
    scroll.container:setContentSize(cc.size( totalWidth,totalHeight))


    for key, node in pairs(scroll.items) do
        node:setPositionX((idx%colNum)*(scroll.itemWidth+scroll.offsetX)+scroll.padding)
        node:setPositionY(totalHeight-scroll.padding- (scroll.itemHeight+scroll.offsetY)*(math.floor(idx/colNum)))
        node.oldPosY=node:getPositionY()
        idx=idx+1
    end
    scroll.container:setPositionY(containerSize.height-totalHeight)
end


function EditUVLayer:refreshSelectedSkill()
    for key, item in pairs(self:getNode("skill_scroll").items) do
        if(item.curData==self.curSelectSkill)then
            item:getNode("icon"):setVisible(true)
        else
            item:getNode("icon"):setVisible(false)
        end
    end
end

function EditUVLayer:getCurTimeLine()
    return self:getTimeLine(self.curSelectMeshName)
end

--通过mesh 获取时间轴
function EditUVLayer:getTimeLine(name)
    for key, item in pairs(self:getNode("timeline_scroll").items) do
        if(item.meshName==name)then
            return item
        end
    end
    return nil
end


function EditUVLayer:refreshSelectedMesh()
    print(self.curSelectMeshName)
    for key, item in pairs(self:getNode("mesh_scroll").items) do
        if(item.curData==self.curSelectMeshName)then
            item:getNode("icon"):setVisible(true)
        else
            item:getNode("icon"):setVisible(false)
        end
    end
end

return EditUVLayer