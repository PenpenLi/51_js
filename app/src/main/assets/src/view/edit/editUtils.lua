EditUtils={}



function EditUtils.saveData(objects,fileName)
    local content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<dict>\n <key>objs</key>\n<array>\n"
    for key, obj in pairs(objects) do
        content=content..EditUtils.getSaveObjDic(obj)
    end
    content=content.."</array></dict>\n"


    io.writefile(EditUtils.getResDir().."/fightScript/"..fileName,content)

end

function EditUtils.loadAni(name)
    local content= io.readfile(EditUtils.getResDir().."c3b/ani/"..name)
    local ret=nil
    if(content)then
        ret= cjson.decode(content)
    end 
    
    if(ret==nil)then
        return {}
    end
    return ret
end


function EditUtils.saveAni(name,ani)  
    io.writefile(EditUtils.getResDir().."c3b/ani/"..name, cjson.encode(ani))
end


function EditUtils.getResDir()

    local filePath=cc.FileUtils:getInstance():fullPathForFilename("config.json")
    return string.gsub(filePath,"config.json","res/")

end

function EditUtils.getSrcDir()

    local filePath=cc.FileUtils:getInstance():fullPathForFilename("config.json")
    return string.gsub(filePath,"config.json","src/")

end


function EditUtils.getSaveObjDic(obj)
    local content=""
    content=content.."<dict>\n"
    content=content.."<key>id</key>\n"
    content=content.."<string>"..obj.id.."</string>\n"
    content=content.."<key>type</key>\n"
    content=content.."<string>"..obj.type.."</string>\n"
    if(obj.action)then
        content=content.."<key>action</key>\n"
        content=content.."<string>"..obj.action.."</string>\n"
    end

    if(obj.fov)then
        content=content.."<key>fov</key>\n"
        content=content.."<string>"..obj.fov.."</string>\n"
    end

    if(obj.path)then
        content=content.."<key>path</key>\n"
        content=content.."<string>"..obj.path.."</string>\n"
    end

    if(obj.param)then
        content=content.."<key>param</key>\n"
        content=content.."<string>"..obj.param.."</string>\n"
    end
    if(obj.material)then
        content=content.."<key>material</key>\n"
        content=content.."<string>"..obj.material.."</string>\n"
    end

    if(obj.depth2d)then
        content=content.."<key>depth2d</key>\n"
        content=content.."<string>"..obj.depth2d.."</string>\n"
    end

    content=content.."<key>scale</key>\n"
    content=content.."<string>{"..string.format("%.2f", obj:getScaleX()) ..","..string.format("%.2f", obj:getScaleY())..","..string.format("%.2f", obj:getScaleZ()).."}</string>\n"
    content=content.."<key>pos</key>\n"
    local pos=obj:getPosition3D()
    content=content.."<string>{"..string.format("%.1f", pos.x)..","..string.format("%.1f", pos.y)..","..string.format("%.1f", pos.z).."}</string>\n"
    content=content.."<key>rotation</key>\n "
    local pos=obj:getRotation3D()
    content=content.."<string>{"..string.format("%.1f", pos.x)..","..string.format("%.1f", pos.y)..","..string.format("%.1f", pos.z).."}</string>\n"

    if(table.count(obj.childObjs)~=0)then

        content=content.."<key>children</key>\n<array>\n"
        for key, childObj in pairs(obj.childObjs) do
            content=content..EditUtils.getSaveObjDic(childObj)
        end
        content=content.."</array>"
    end
    content=content.."</dict>\n"

    return content
end


EditUtils.actions={
    "idle",
    "dead",
    "hurt",
    "run",
    "attack",
    "skill",
    "skillReady",
    "sleep",
    "skill2",
    "show",
    "dizzy",
}



function EditUtils.getSaveRoleDic(objects)
    local content="gCardAnimateFlag={\n  "
    for key, obj in pairs(objects) do
        content=content.."{cardid="..obj.cardid..","

        for key, action in pairs(  EditUtils.actions) do
            if(obj[action]~=nil)then
                content=content..action.."=\""..obj[action].."\","
            else
                content=content..action.."=\"0,0\","

            end
        end
        content=content.."},\n"
    end
    content=content.."}\n\n"
    content=content.."gCardAnimateEvent={\n  "
    for key, event in pairs(gCardAnimateEvent) do
        content=content..key.."={"

        for type, name in pairs( event) do
            content=content.."\""..name.."\","
        end
        content=content.."},\n"
    end
    content=content.."}"
    io.writefile(EditUtils.getSrcDir().."/data/conf/cardAnimateFlag.lua",content)
end

 