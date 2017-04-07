local EditModeLayer=class("EditModeLayer",UILayer)

BTN_TYPE_SELECT=1
BTN_TYPE_ROTATION=2


INPUT_ROTATION="input_r"
INPUT_SCALE="input_s"
INPUT_POS="input_p"

function EditModeLayer:inited()
    self:getNode("scroll_node"):retain()

    for i=1, 3 do
        if(self:getNode("btn_move_arrow"..i))then
            self:getNode("btn_move_arrow"..i).__touchend=true
        end
        if(self:getNode("btn_scale_arrow"..i))then
            self:getNode("btn_scale_arrow"..i).__touchend=true
        end
        if(self:getNode("btn_rotation_arrow"..i))then
            self:getNode("btn_rotation_arrow"..i).__touchend=true
        end
    end
    self:getNode("scroll_node_x"):setDepth2D(true)
    self:getNode("scroll_node_y"):setDepth2D(true)
    self:getNode("scroll_node_z"):setDepth2D(true)
    self:getNode("scroll_node_x"):setRotation3D(cc.vec3(0,-90,0))
    self:getNode("scroll_node_y"):setRotation3D(cc.vec3(-90,0,0))
    self:getNode("scroll_node_z"):setRotation3D(cc.vec3(0,0,0))



    self._drawDebug = cc.DrawNode3D:create()
    self.curObjContainer:addChild(self._drawDebug)


end

function EditModeLayer:setArrow(dir)
    self.curArrowDir=dir

    self:getNode("scroll_node_z"):setOpacity(20)
    self:getNode("scroll_node_y"):setOpacity(20)
    self:getNode("scroll_node_x"):setOpacity(20)
    self:getNode("scroll_node_"..dir):setOpacity(255)
end
function EditModeLayer:_onTouchBegan(target, touch)

    if(target.touchName and string.find(target.touchName,"btn_rotation"))then
        self.curBtnType=BTN_TYPE_ROTATION
        local dir=string.sub(target.touchName,14,string.len(target.touchName))
        self:setArrow(dir)
    end
end



function EditModeLayer:_onTouchEnded(target)

    if(target.touchName=="btn_select")then
        self.curBtnType=BTN_TYPE_SELECT
    elseif(target.touchName=="btn_cancel")then
        self.curBtnType=nil
    end
end



function EditModeLayer:_onTouchMoved(target,touch, event)
    if(target.touchName=="btn_rotation_z")then
        self:rotationObj(0, 0, 1,-touch:getDelta().x)


    elseif(target.touchName=="btn_rotation_x")then

        self:rotationObj(1, 0, 0,touch:getDelta().x)
    elseif(target.touchName=="btn_rotation_y")then
        self:rotationObj(0, 1, 0,-touch:getDelta().x)

    elseif(target.touchName=="container_rotation")then
        if(self.curObjContainer)then
            local rotation=self.curObjContainer:getRotation3D()
            rotation.y=rotation.y+ touch:getDelta().x/5
            rotation.x=rotation.x-touch:getDelta().y/5
            self.curObjContainer:setRotation3D(rotation)
        end
    elseif(target.touchName=="container_scale")then
        if(self.curObjContainer)then
            local scale=  self.curObjContainer:getScale()
            local curScale=scale+touch:getDelta().y/20
            if(curScale<0)then
                curScale=0
            end
            self.curObjContainer:setScale(curScale)
        end
    elseif(target.touchName=="btn_move_arrow1")then
        self:movePos(touch:getDelta().x,0,0)
    elseif(target.touchName=="btn_move_arrow2")then
        self:movePos(0,touch:getDelta().y,0)
    elseif(target.touchName=="btn_move_arrow3")then
        self:movePos(0,0,-touch:getDelta().x)
    elseif(target.touchName=="btn_scale_arrow1")then
        self:scaleObj(touch:getDelta().x,0,0)
    elseif(target.touchName=="btn_scale_arrow2")then
        self:scaleObj(0,touch:getDelta().y,0)
    elseif(target.touchName=="btn_scale_arrow3")then
        self:scaleObj(0,0,-touch:getDelta().x)
    end
end
--更新旋转 移动 的icon位置
function EditModeLayer:updateControl()
    self:getNode("arrow_node"):setVisible(false)
    self:getNode("scroll_node"):setVisible(false)
    self:setTouchEnable("btn_select",true,false)
    self:setTouchEnable("btn_rotation",true,false)
    self:setTouchEnable("btn_scene",true,false)



    if( self.curBtnType==BTN_TYPE_SELECT)then
        self:setTouchEnable("btn_select",false,true)
    elseif( self.curBtnType==BTN_TYPE_ROTATION)then
        self:setTouchEnable("btn_rotation",false,true)
    end

    if nil ~= self._drawDebug  then
        self._drawDebug:clear()
    end
    if(self.curSelectObj)then
   

        if( self.curBtnType==BTN_TYPE_SELECT)then
            self:getNode("arrow_node"):setVisible(true)
        elseif( self.curBtnType==BTN_TYPE_ROTATION)then
            self:getNode("scroll_node"):setVisible(true)
        end

        local size=cc.Director:getInstance():getWinSize()
        local zeye = cc.Director:getInstance():getZEye()
        local mat4=cc.mat4.new(self.curSelectObj:getNodeToWorldTransform())
        local pos=cc.vec3(mat4[13],mat4[14],mat4[15])
        local posZ=  zeye-pos.z
        local curWidth=size.width *(posZ/zeye)
        local curHeight=size.height *(posZ/zeye)
        local newX=(   (pos.x+(curWidth-size.width )/2)* (size.width/curWidth))
        local newY=(   (pos.y+(curHeight-size.height )/2)* (size.height/curHeight))

        local pos=self:getNode("arrow_node"):getParent():convertToNodeSpace(cc.p(newX,newY))
        self:getNode("arrow_node"):setPosition(cc.p(pos.x,pos.y))

        if(self:getNode("scroll_node"):getParent())then
            self:getNode("scroll_node"):removeFromParent()
        end
        self.curSelectObj:getParent():addChild(self:getNode("scroll_node"))
        self:getNode("scroll_node"):setPosition3D(self.curSelectObj:getPosition3D())



        if(self:getNode("input_px"))then
            self.curSelectObj:setPosition3D(self:getInputVec3(INPUT_POS))
            self.curSelectObj:setRotation3D(self:getInputVec3(INPUT_ROTATION))
            local scale=self:getInputVec3(INPUT_SCALE)
            self.curSelectObj:setScaleX(scale.x)
            self.curSelectObj:setScaleY(scale.y)
            self.curSelectObj:setScaleZ(scale.z)
        end
    end

end


function EditModeLayer:getInputVec3(name)
    local pos={}
    pos.x= tonum(self:getNode(name.."x"):getText())
    pos.y= tonum(self:getNode(name.."y"):getText())
    pos.z= tonum(self:getNode(name.."z"):getText())
    return pos
end

function EditModeLayer:setSelectObj(obj)
    if(obj==nil)then
        return
    end
    self.curSelectObj=obj
    self:setInputVec3(INPUT_POS,obj:getPosition3D())
    self:setInputVec3(INPUT_ROTATION,obj:getRotation3D())
    local pos={x=obj:getScaleX(),y=obj:getScaleY(),z=obj:getScaleZ()}
    self:setInputVec3(INPUT_SCALE,pos)
    self:refreshObjSelected()

end

function EditModeLayer:refreshObjSelected()
    if(self.objScroll==nil)then
        return
    end
    for key, item in pairs(self.objScroll.items) do
        if(item.curData==self.curSelectObj)then
            item:getNode("icon"):setVisible(true)
        else
            item:getNode("icon"):setVisible(false)
        end
    end
end

function EditModeLayer:rotationObj(x,y,z,offsetX)

    local newQua =self.curSelectObj:getRotationQuat()
    local oldQua =  cc.quaternion_createFromAxisAngle(cc.vec3(x, y, z),offsetX/100)
    local x = oldQua.w * newQua.x + oldQua.x * newQua.w + oldQua.y * newQua.z - oldQua.z * newQua.y
    local y = oldQua.w * newQua.y - oldQua.x * newQua.z + oldQua.y * newQua.w + oldQua.z * newQua.x
    local z = oldQua.w * newQua.z + oldQua.x * newQua.y - oldQua.y * newQua.x + oldQua.z * newQua.w
    local w = oldQua.w * newQua.w - oldQua.x * newQua.x - oldQua.y * newQua.y - oldQua.z * newQua.z
    self.curSelectObj:setRotationQuat( cc.quaternion(x, y, z, w))


    local pos=self.curSelectObj:getRotation3D()
    self:setInputVec3(INPUT_ROTATION,pos)
end

function EditModeLayer:scaleObj(x,y,z)
    local target=self.curSelectObj
    local pos = target:getPosition3D()
    local mat =cc.mat4.new( target:getParent():getNodeToWorldTransform())
    local move=cc.vec4(x,y,z,0)
    local speed=0.01
    mat =cc.mat4.new(mat:getInversed())
    local move=mat:transformVector(move,move)

    local scaleX=tonum(self:getNode("input_sx"):getText()) +move.x*speed
    if(scaleX<0.1)then
        scaleX=0.1
    end

    local scaleY=tonum(self:getNode("input_sy"):getText()) +move.y*speed
    if(scaleY<0.1)then
        scaleZ=0.1
    end

    local scaleZ=tonum(self:getNode("input_sz"):getText()) +move.z*speed
    if(scaleZ<0.1)then
        scaleZ=0.1
    end
    self:getNode("input_sx"):setText( string.format("%.2f", tonum(self:getNode("input_sx"):getText()) +move.x*speed ))
    self:getNode("input_sy"):setText(string.format("%.2f",  tonum(self:getNode("input_sy"):getText()) +move.y*speed ))
    self:getNode("input_sz"):setText(string.format("%.2f",  tonum(self:getNode("input_sz"):getText()) +move.z*speed ))



end
function EditModeLayer:movePos(x,y,z)
    local target=self.curSelectObj
    local pos = target:getPosition3D()
    local mat =cc.mat4.new( target:getParent():getNodeToWorldTransform())
    local move=cc.vec4(x,y,z,0)
    local speed=1.6
    mat =cc.mat4.new(mat:getInversed())
    local move=mat:transformVector(move,move)


    local pos=self:getInputVec3(INPUT_POS)
    pos.x=pos.x+move.x*speed
    pos.y=pos.y+move.y*speed
    pos.z=pos.z+move.z*speed
    self:setInputVec3(INPUT_POS,pos)


end





function EditModeLayer:getInputValue(name,num)
    if(num==nil)then
        return toint(self:getNode(name):getText())
    end
    return tonum(string.format("%."..num.."f",  tonum(self:getNode(name):getText())))
end


function EditModeLayer:setInputVec3(name,pos)
    self:getNode(name.."x"):setText(string.format("%.2f", pos.x))
    self:getNode(name.."y"):setText(string.format("%.2f", pos.y))
    self:getNode(name.."z"):setText(string.format("%.2f", pos.z))
end


--画出地板线
function EditModeLayer:createBottom()
    local line = cc.DrawNode3D:create()
    --draw x
    for i = -20 ,20 do
        line:drawLine(cc.vec3(-1000, 0, 50 * i), cc.vec3(1000, 0, 50 * i), cc.c4f(1, 1, 1, 0.2))
    end
    --draw z
    for i = -20, 20 do
        line:drawLine(cc.vec3(50 * i, 0, -1000), cc.vec3(50 * i, 0, 1000), cc.c4f(1, 1, 1, 0.2))
    end
    --draw y
    line:drawLine(cc.vec3(0, -500, 0), cc.vec3(0,0,0), cc.c4f(0, 0.5, 0, 1))
    line:drawLine(cc.vec3(0, 0, 0), cc.vec3(0,500,0), cc.c4f(0, 1, 0, 1))
    self.node:addChild(line)
end







return EditModeLayer