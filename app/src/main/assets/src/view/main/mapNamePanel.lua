local MapNamePanel=class("MapNamePanel",UILayer)

function MapNamePanel:ctor()

    self:init("ui/ui_mapName.map");

    local winSize=cc.Director:getInstance():getWinSize()
    self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self.mapNames = {};
end

function MapNamePanel:addMap(mapName)
    for key,map in pairs(self.mapNames) do
        if(map.name == mapName)then
            return;
        end
    end

    local tag = self:getNode("content"):addWord(mapName,gCustomFont,20,cc.c3b(255,255,255),cc.c4b(0,0,0,255),0.1);
    -- print("addMap name = "..mapName.." tag = "..tag);
    self:getNode("content"):layout();
    table.insert(self.mapNames,{name = mapName,tag = tag});
end

function MapNamePanel:removeMap(mapName)
    for key,map in pairs(self.mapNames) do
        if(map.name == mapName)then
            self:getNode("content"):removeNodeByTag(map.tag);
            table.remove(self.mapNames,key);
            break;
        end
    end
    self:getNode("content"):layout();
end

function MapNamePanel:clear()
    self:getNode("content"):clear();
    self:getNode("content"):layout();
end

return MapNamePanel