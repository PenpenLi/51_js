local Scene3D=class("Scene3D", function()
    return cc.Node:create()
end)

function Scene3D:ctor()
end


function Scene3D:getObjNode(name,nodeName)
    local obj=self:getObjById(name)
    if(obj==nil)then
        return nil
    end
    local children = obj:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        if(children[i + 1]:getName()==nodeName)then
            return children[i + 1]
        end
    end
    for key, childObj in pairs(obj.childObjs) do
        if(childObj.id==nodeName)then
            return childObj
        end
    end
    return nil


end

function Scene3D:playAction(obj,from,to,callback)

    local animation =obj.animation
    if nil ~= animation then
        local animate = cc.Animate3D:create(animation,(from)/30,(to-from)/30)
        obj:stopAllActions()
        if(callback)then
            obj:runAction(cc.Sequence:create(animate,cc.CallFunc:create(callback,{})))
        else
            obj:runAction(cc.RepeatForever:create(animate))

        end
        return animate
    end
    return nil
end

function Scene3D:getObjById(id)
    if( self.objects==nil)then
        return nil
    end

    return self.objects[id]

end

function Scene3D:changeTexture(obj,url)
    for i=0, obj:getMeshCount()-1 do
        local mesh = obj:getMeshByIndex(i);
        mesh:setTexture(url)
    end

end

function Scene3D:initScene(file)
    self.objects={}
    self.objAABB={}

    local objsConf=cc.FileUtils:getInstance():getValueMapFromFile(file)
    for key, objConf in pairs(objsConf.objs) do
        local obj=gCreateEditObj(objConf,true)
        if(obj.type=="camera")then
            self.camera=obj
            gSetEditObjPro(obj,objConf)
        elseif(obj)then
            self:addChild(obj)
            self.objects[obj.id]=obj
            gSetEditObjPro(obj,objConf)
            local aabbmin={}
            if(objConf.aabb_min)then
                assert(loadstring("  pos= "..objConf.aabb_min))()
                aabbmin= cc.vec3(tonum(pos[1]),tonum(pos[2]),tonum(pos[3]))
            else
                aabbmin=cc.vec3(0,0,0)
            end
            local aabbmax={}

            if(objConf.aabb_max)then
                assert(loadstring("  pos= "..objConf.aabb_max))()
                aabbmax= cc.vec3(tonum(pos[1]),tonum(pos[2]),tonum(pos[3]))
            else
                aabbmax=cc.vec3(0,0,0)
            end
            self.objAABB[objConf.id]={min=aabbmin,max=aabbmax}

        end

    end

end

return Scene3D