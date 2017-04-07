local LayOutLayer=class("LayOutLayer", function()
    return cc.Node:create()
end)

LAYOUT_TYPE_NONE = 0;           --无布局
LAYOUT_TYPE_HORIZONTAL = 1;     --水平
LAYOUT_TYPE_VERTICAL = 2;       --垂直    

function LayOutLayer:ctor(type,space,align)
    if space == nil then
        space = 0;
    end
    if align == nil then
        align = 0;
    end
    self.layoutType = type;
    self.space = space;
    self.align = align;
    self.items = {};
    self.itemTag = 1;
    self:ignoreAnchorPointForPosition(false);
    self:setAnchorPoint(cc.p(0.5,0.5));
end

function LayOutLayer:setSortByPos()
    -- self.sortPos = true;
    self:setSortByPosFlag(true);
end

function LayOutLayer:setSortByPosFlag(enable)
    self.sortPos = enable
end

function LayOutLayer:clear()
    -- body
    self:removeAllChildren();
    self.items = {};
    self.itemTag = 1;
end

function LayOutLayer:layout()
    -- print("LayOutLayer:layout type = "..self.layoutType);
    if self.layoutType == LAYOUT_TYPE_NONE then
        self:ignoreAnchorPointForPosition(false);
        return;
    end

    --根据坐标排序
    if self.sortPos then
        local sortByPos = function(node1,node2)
            local pos1 = cc.p(node1:getPosition());
            local pos2 = cc.p(node2:getPosition());
            if self.layoutType == LAYOUT_TYPE_HORIZONTAL then
                return pos1.x < pos2.x;
            elseif self.layoutType == LAYOUT_TYPE_VERTICAL then
                return pos1.y < pos2.y;  
            end
            return false;
        end
        table.sort(self.items,sortByPos);
    end

    local maxWidth = 0;
    local maxHeight = 0;
    local count = 0;
    for key,node in pairs(self.items) do
        if node:isVisible() then
            count = count + 1;
        end
    end
    -- print("start");
    local index = 0;
    for key,node in pairs(self.items) do

        if node:isVisible() == true then
            if node.__cname=="LayOutLayer" then
                node:layout();
            end

            if self.layoutType == LAYOUT_TYPE_HORIZONTAL then
                maxHeight = math.max(maxHeight,node:getContentSize().height*node:getScaleY());
                maxWidth = maxWidth + node:getContentSize().width*node:getScaleX();
                if index < count-1 then
                    -- print("index = "..index.." add space = "..self.space);
                    maxWidth = maxWidth + self.space;
                end
            elseif self.layoutType == LAYOUT_TYPE_VERTICAL then
                maxWidth = math.max(maxWidth,node:getContentSize().width*node:getScaleX());
                maxHeight = maxHeight + node:getContentSize().height*node:getScaleY();
                if index < count-1 then
                    maxHeight = maxHeight + self.space;
                end
            end
            index = index + 1;
        end
    end
    -- print("maxWidth = "..maxWidth);
    -- print("count = "..count);
    -- print("");

    local posx = 0;
    local posy = 0;
    if self.layoutType == LAYOUT_TYPE_HORIZONTAL then
        posy = maxHeight/2;
    elseif self.layoutType == LAYOUT_TYPE_VERTICAL then
        posx = maxWidth/2;
    end
    -- print_lua_table(self.items);
    for key,node in pairs(self.items) do

        if node:isVisible() == true then
            if self.layoutType == LAYOUT_TYPE_HORIZONTAL then
                local anchorY = 0;
                if(self.align == 0) then
                    --居中
                    posy = maxHeight/2;
                    anchorY = 0.5;
                elseif(self.align == 1) then
                    -- 上对齐
                    posy = maxHeight;
                    anchorY = 1;
                elseif(self.align == 2) then
                    -- 下对齐
                    posy = 0;
                    anchorY = 0;
                else
                    -- 自由
                    posy = node:getPositionY();
                    anchorY = node:getAnchorPoint().y;
                end

                if(node.isUILayer)then
                    anchorY = -anchorY;
                end
                -- print("posx = "..posx.."  posy = "..posy);
                node:setAnchorPoint(cc.p(0,anchorY));
                node:setPosition(cc.p(posx,posy));
                posx = posx + node:getContentSize().width*node:getScaleX() + self.space;

            elseif self.layoutType == LAYOUT_TYPE_VERTICAL then
                local anchorX = 0;
                if(self.align == 0) then
                    -- 居中
                    posx = maxWidth/2;
                    anchorX = 0.5;
                elseif(self.align == 1) then
                    -- 左对齐
                    posx = 0;
                    anchorX = 0;
                elseif(self.align == 2) then
                    -- 右对齐
                    posx = maxWidth;
                    anchorX = 1;
                else
                    -- 自由
                    posx = node:getPositionX();
                    anchorX = node:getAnchorPoint().x;
                end
                -- posx = node:getAnchorPoint().x * maxWidth;
                local anchorY = 0;
                if(node.isUILayer)then
                    anchorY = -1;
                end
                node:setAnchorPoint(cc.p(anchorX,anchorY));
                node:setPosition(cc.p(posx,posy));
                posy = posy + node:getContentSize().height*node:getScaleY() + self.space;
            end
        end

    end

    -- print("before");
    -- print_lua_table(self:getContentSize());
    self:setAllChildCascadeOpacityEnabled(true);
    self:setContentSize(cc.size(maxWidth,maxHeight));
    self:ignoreAnchorPointForPosition(false);
    -- print("after");
    -- print_lua_table(self:getContentSize());

    -- self:removeChildByTag(100);
    -- local bg = cc.LayerColor:create(cc.c4b(0,0,0,200),maxWidth,maxHeight);
    -- self:addChild(bg,100,100);
end


function LayOutLayer:addWord(word,font,fontsize,color,outline_color,outline_offset)
    -- body
    local node = gCreateWordLabelTTF(word,font,fontsize,color);
    if(outline_color and outline_offset)then
        node:enableOutline(outline_color,fontsize*outline_offset);
    end
    return self:addNode(node);
end

function LayOutLayer:addImage(imagePath,scale)
    local node = cc.Sprite:create(imagePath);
    if scale then
        node:setScale(scale);
    end
    self:addNode(node);
end

function LayOutLayer:addNode(node)
    node:setTag(self.itemTag);
    self:addChild(node);
    self.itemTag = self.itemTag + 1;

    table.insert(self.items,node);
    return self.itemTag - 1;
end

--index >= 1
function LayOutLayer:getNode(index)
    -- print("LayOutLayer:getNode = "..index);
    return self:getChildByTag(index);
end

function LayOutLayer:getAllNodes()
    return self:getChildren();
end

function LayOutLayer:removeNode(node)
    for key,item in pairs(self.items) do
        if(item == node)then
            node:removeFromParent(true);
            table.remove(self.items,key);
            break;
        end
    end
end

function LayOutLayer:removeNodeByTag(tag)
    local node = self:getNode(tag);
    self:removeNode(node);
end

function LayOutLayer:onTouchBegan(touch,event)
end

function LayOutLayer:onTouchMoved(touch,event)
end

function LayOutLayer:onTouchEnded(touch,event)
end


return LayOutLayer