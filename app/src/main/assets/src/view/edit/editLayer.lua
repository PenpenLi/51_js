local EditLayer=class("EditLayer",EditModeLayer)

function EditLayer:ctor()
    self.fileName="mainScene_1.plist"
    self:init("ui/ui_edit.map")
    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self.objects = {}
    local node=cc.Node:create()
    self.node=node
    self:addChild(node) 
    node:setPosition3D(cc.vec3(self.mapW/2,-self.mapH/2,0))
    
    self.curBtnType=BTN_TYPE_SELECT
    self.curObjContainer=node

    self.objScroll=self:getNode("scroll")
    self:getNode("scroll").eachLineNum=1
    self:getNode("scroll").offsetY=0
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local objsConf=cc.FileUtils:getInstance():getValueMapFromFile("fightScript/"..self.fileName)
    for key, objConf in pairs(objsConf.objs) do

        local obj=gCreateEditObj(objConf)

        if(obj)then
            table.insert(self.objects,obj)

            if(obj.type=="camera")then
                gSetEditObjPro(obj,objConf)
                self.camera=obj
                local pos=self.camera:getPosition3D()
                self:setLabelString("input_camerax", string.format("%.1f",pos.x))
                self:setLabelString("input_cameray", string.format("%.1f",pos.y))
                self:setLabelString("input_cameraz", string.format("%.1f",pos.z))
                self:setLabelString("input_fov", string.format("%.1f",self.camera.fov))

            else
                self.node:addChild(obj)
                gSetEditObjPro(obj,objConf)
                self:addMenuItem(obj)
            end

        end
    end


    self:getNode("scroll"):layout() 
    self.camera:setCameraFlag(cc.CameraFlag.USER1)
    self.node:setCameraMask(cc.CameraFlag.USER1,true)


    local function _update()
        self:updateControl()
        self:update()
    end 
    self:scheduleUpdateWithPriorityLua(_update, 0)

    local function onEditCallback(name, sender)
        if(name=="changed")then
            local fov=tonum(self:getNode("input_fov"):getText())
            local winSize = cc.Director:getInstance():getWinSize()
            local zeye=     winSize.height/ (math.tan(math.rad(fov/2))*2)
            self.camera:initPerspective(fov, winSize.width / winSize.height, 1, zeye*10)
            local pos=cc.vec3(0, 0, zeye) 
            self:setInputVec3("input_camera",pos) 
        end
    end
    self:getNode("input_fov"):registerScriptEditBoxHandler(onEditCallback)
    self:inited()
end


function EditLayer:addMenuItem(obj)
    local item=EditObjItem.new()
    item:setData(obj)
    item.onSelectCallback=function(obj)
        self:setSelectObj(obj)
    end
    self:getNode("scroll"):addItem(item)
    for key, childObj in pairs(obj.childObjs) do
        self:addMenuItem(childObj)
    end
end

 

function EditLayer:update()


    if(self.camera)then
        local winSize = cc.Director:getInstance():getWinSize()
        local pos=  self:getInputVec3("input_camera") 
        self.camera:setPosition3D(pos)
        self.camera:lookAt(cc.vec3(0, 0, 0.0), cc.vec3(0.0, 1.0, 0.0))
 
    end


end



function EditLayer:onTouchBegan(target, touch)
    self.preLocation=touch:getLocation()
    self:_onTouchBegan(target,touch, event)

end


function EditLayer:onTouchEnded(target)

    for key, obj in pairs(self.objects) do
        obj:setOpacity(255)
    end

    self:_onTouchEnded(target, touch)
    
    if(target.touchName=="btn_save")then
        EditUtils.saveData(self.objects,self.fileName) 
    end

end
function EditLayer:onTouchMoved(target, touch)

    self:_onTouchMoved(target, touch)
 
end




return EditLayer