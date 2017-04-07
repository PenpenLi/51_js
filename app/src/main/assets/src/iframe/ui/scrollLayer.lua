local ScrollLayer=class("ScrollLayer", function()
    return cc.Node:create()
end)


function ScrollLayer:resize(viewSize)
    self.scroll:setViewSize(viewSize)
    -- self.scroll:setContentSize(viewSize);
    self:setContentSize(viewSize)
    self.viewSize=viewSize
end

function ScrollLayer:setTouchEnable(value)
    if(self.scroll.setTouchEnable)then
        self.scroll:setTouchEnable(value)
    end
    self.touchEnable=value
    -- print("ScrollLayer  setTouchEnable");
end

function ScrollLayer:setAllItemTouchEnable(value)
    for key,item in pairs(self:getAllItem()) do
        item.touchEnable = value;
    end
end

function ScrollLayer:ctor(scrollTemp,dir)

    local size= scrollTemp:getContentSize()
    local scroll=cc.ScrollView:create()
    self.viewSize=size
    scroll:setViewSize(size)
    -- scroll:setContentSize(size);
    -- scroll:setPositionY(-size.height/2)
    -- scroll:setPositionX(-size.width/2)

    self.touchEnable=true
    scroll:setClippingToBounds(true)
    scroll:setBounceable(true)
    self.itemScale=1
    self.padding=0
    self.paddingX = nil
    self.paddingY = nil
    local container=cc.Node:create()
    -- local container = cc.LayerColor:create(cc.c4b(0,0,0,200),size.width,size.height);
    scroll:setContainer(container)
    self.items={}
    self.container=container
    self.scroll=scroll
    self:addChild(scroll)
    self:setContentSize(cc.size( size.width,size.height))
    container:setContentSize(cc.size( size.width,size.height))
    self.breakTouch = false;


    local function _onTouchBegan(touch, event)
        -- print("ScrollLayer:onTouchBegan11111111111");
        if(self.touchEnable==false)then
            -- print("ScrollLayer:onTouchBegan````````");
            return self.breakTouch;
        end
        if(self.touchBeganCallback)then
            return  self.touchBeganCallback(touch, event)
        end
        -- print("ScrollLayer:onTouchBegan++++++");
        return self.breakTouch;
    end

    local function _onTouchEnded(touch, event)
        if(self.touchEndedCallback)then
            self.touchEndedCallback(touch, event)
        end
        if self:isScrollBottom(touch,event) then
            self:onScrollBottom();
        end
    end
    -- local function _onTouchEnded(touch, event)
    --     if(self.touchEndedCallback)then
    --         self.touchEndedCallback(touch, event)
    --     end
    -- end

    local function _onTouchMoved(touch, event)
        -- print("ScrollLayer:onTouchMoved111111");
        if(self.touchMovedCallback)then
            self.touchMovedCallback(touch, event)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    local eventDispatcher = scroll:getEventDispatcher()
    listener:registerScriptHandler(_onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(_onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(_onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(_onTouchEnded,cc.Handler.EVENT_TOUCH_CANCELLED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scroll)

    self:setDir(dir)
    self.offsetX=0
    self.itemWidth=0
    self.itemHeight=0
    self.bottomOffset=0
    self.offsetY=0
    self.eachLineNum=1
end

function ScrollLayer:setDir(dir)
    self.dir=dir
    self.scroll:setDirection(dir )
end

function ScrollLayer:addContainerChild(child)
    self.container:addChild(child)
end

function ScrollLayer:clear()
    for key, var in pairs(self.items) do
        var:removeFromParent()
    end
    --self.container:removeAllChildren()
    self.items={}
    self.itemWidth=0
    self.itemHeight=0
    self.container:setPosition(cc.p(0,0));
end

function ScrollLayer:getViewRect()
    local _viewSize=self.viewSize
    local screenPos = self:convertToWorldSpace(cc.p(0,0))

    local scaleX = self:getScaleX()
    local scaleY = self:getScaleY()
    local parent=self:getParent()
    while(parent~=nil)do

        scaleX  = scaleX*parent:getScaleX()
        scaleY  = scaleY* parent:getScaleY()
        parent=parent:getParent()
    end

    if(scaleX<0) then
        screenPos.x  = _viewSize.width*scaleX
        scaleX =scaleX -scaleX;
    end

    if(scaleY<0) then
        screenPos.y =screenPos.y + _viewSize.height*scaleY
        scaleY = scaleY-scaleY
    end
    return cc.rect(screenPos.x , screenPos.y , _viewSize.width*scaleX, _viewSize.height*scaleY)
        -- return cc.rect(screenPos.x- _viewSize.width*scaleX/2 , screenPos.y -_viewSize.height*scaleY/2 , _viewSize.width*scaleX, _viewSize.height*scaleY)
end

function ScrollLayer:addItem(node,index)
    if index == nil then
        table.insert(self.items,node)
    else
        table.insert(self.items,index+1,node)
    end
    node:setScale(self.itemScale)
    if(node:getContentSize().width~=0 and node:getContentSize().height~=0)then
        local width = node:getContentSize().width*self.itemScale;
        local height = node:getContentSize().height*self.itemScale;
        if width > self.itemWidth then
            self.itemWidth = width;
        end
        if height > self.itemHeight then
            self.itemHeight = height;
        end
        -- self.itemWidth=node:getContentSize().width*self.itemScale
        -- self.itemHeight=node:getContentSize().height*self.itemScale
    else
        node:setContentSize(cc.size(self.itemWidth/self.itemScale,self.itemHeight/self.itemScale))

    end
    self.container:addChild(node)
end

function ScrollLayer:insertItem(node,index)
    self:addItem(node,index);
end

function ScrollLayer:removeItemByIndex(index,isNeedAni)
    if index >= 0 and index < table.getn(self.items) then

        if isNeedAni == nil then
            isNeedAni = true;
        end

        if isNeedAni then
            local removeItem = self.items[index+1];
            local actEnd = function ()
                -- self:_removeItemByIndex(index);
                -- local node = self.items[index+1];
                removeItem:removeFromParent();
                self:layout(false);
            end
            removeItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25,0),cc.CallFunc:create(actEnd) ));
            local prePos = cc.p(removeItem:getPosition());
            gModifyExistNodeAnchorPoint(removeItem,cc.p(0.5,-0.5));


            local count = table.getn(self.items);
            for i = index+2,count do
                local item = self.items[i];
                item:runAction(cc.Sequence:create( cc.MoveTo:create(0.2,prePos)));
                prePos = cc.p(item:getPosition());
            end
            table.remove(self.items,index+1);
        else
            self:_removeItemByIndex(index);
        end
        self:setCheckChildrenVisible(true);
    end
end

function ScrollLayer:removeItem(item,isNeedAni)
    local index = 0;
    for k,v in pairs(self.items) do
        if v == item then
            index = k;
            break;
        end
    end
    self:removeItemByIndex(index-1,isNeedAni);
end

function ScrollLayer:_removeItemByIndex(index)
    print("remove item index = "..index);
    if index >= 0 and index < table.getn(self.items) then
        local node = self.items[index+1];
        node:removeFromParent();
        table.remove(self.items,index+1);
        self:layout(false);
    end

end

function ScrollLayer:getItem(index)
    if index >= 0 and index < table.getn(self.items) then
        return self.items[index+1];
    end
    return nil;
end

function ScrollLayer:getAllItem()
    return self.items;
end

function ScrollLayer:onTouchBegan(touch,event)
    -- print("ScrollLayer:onTouchBegan2222222222");
    local ret= self.scroll:onTouchBegan(touch,event)
    if(ret==false)then
        -- print("ScrollLayer:onTouchBegan return false");
        return false
    end
    if(self.touchBeganCallback)then
        return  self.touchBeganCallback(touch, event)
    end
    return true
end

function ScrollLayer:onTouchMoved(touch,event)
    -- print("ScrollLayer:onTouchMoved222222");
    self.scroll:onTouchMoved(touch,event)
    if(self.touchMovedCallback)then
        self.touchMovedCallback(touch, event)
    end
end

function ScrollLayer:onTouchEnded(touch,event)
    self.scroll:onTouchEnded(touch,event)
    if(self.touchEndedCallback)then
        self.touchEndedCallback(touch, event)
    end

    if self:isScrollBottom(touch,event) then
        self:onScrollBottom();
    end
end

function ScrollLayer:isScrollBottom(touch,event)
    -- body
    -- print("xxxxx");
    if(self.dir==cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        local posY = self.container:getPositionY();
        -- print("posy = "..posY);
        if posY >= 0 then
            return true;
        end
    end
    return false;
end

function ScrollLayer:onScrollBottom()
    -- print("onScrollBottom");
    if self.scrollBottomCallBack then
        self.scrollBottomCallBack();
    end
end

function ScrollLayer:canScroll()
    if (self.dir == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        return self.container:getContentSize().height >= self:getContentSize().height;
    elseif(self.dir == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        return self.container:getContentSize().width >= self:getContentSize().width;
    end
    return true;
end

function ScrollLayer:moveItemByIndex(index,moveTime)
    if (self.dir == cc.SCROLLVIEW_DIRECTION_BOTH or self.dir == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        local row = math.floor( index/self.eachLineNum );
        -- print("index = "..index.." row = "..row);
        local totalHeight=self.container:getContentSize().height
        local containerSize=self:getContentSize()
        local posY=containerSize.height-totalHeight+(self.itemHeight+self.offsetY)*row

        if(posY<containerSize.height-totalHeight)then
            posY=containerSize.height-totalHeight
        end

        local newPosX,newPosY = self:checkBoard(cc.p(self.container:getPositionX(),posY));

        if(moveTime)then
            self.container:runAction(cc.EaseBackOut:create(cc.MoveTo:create(moveTime,cc.p(newPosX,newPosY))))
        else
            self.container:setPositionY(newPosY)
        end
    else
        local ceil = math.floor( (index-1)/self.eachLineNum );
        -- print("index = "..index.." row = "..row);
        local totalWidth=self.container:getContentSize().width
        local containerSize=self:getContentSize()
        local posX=- (self.itemWidth+self.offsetX)*ceil

        if(posX<containerSize.width-totalWidth)then
            posX=containerSize.width-totalWidth
        end

        local newPosX,newPosY = self:checkBoard(cc.p(posX,self.container:getPositionY()));
        local function moveEnd()
            self:setCheckChildrenVisible(true);
        end
        if(moveTime)then
            self.container:stopActionByTag(1)
            local action= cc.Sequence:create(
                cc.EaseBackOut:create(cc.MoveTo:create(moveTime,cc.p(newPosX,newPosY))),
                cc.CallFunc:create(moveEnd)
            )
            action:setTag(1)
            self.container:runAction( action )
        else
            self.container:setPositionX(newPosX)
        end
    end
    self:setCheckChildrenVisible(true);
end

function ScrollLayer:layout(moveToUp)
    self:setCheckChildrenVisible(true);
    local totalHeight=0
    local totalWidth=0
    if(moveToUp==nil)then
        moveToUp=true
    end

    self.moveToUp = moveToUp;

    local containerSize=self:getContentSize()
    local orgSize = self.container:getContentSize();

    if(self.dir==cc.SCROLLVIEW_DIRECTION_HORIZONTAL)then

        local rowNum=self.eachLineNum

        totalHeight = 0;
        totalWidth = self:getPaddingX()*2;
        local totalMaxHeight = self:getPaddingY()*2;
        local totalMaxWidth = 0;
        for key,node in pairs(self.items) do

            if(node:getContentSize().width==0 or node:getContentSize().height==0  )then
                node:setContentSize(cc.size(self.itemWidth,self.itemHeight))
            end
            if math.mod((key-1),rowNum) == 0 then
                if totalHeight < totalMaxHeight then
                    totalHeight = totalMaxHeight;
                end
                totalMaxHeight = self:getPaddingY()*2;

                totalWidth = totalWidth + totalMaxWidth;
                totalMaxWidth = 0;
            end

            totalMaxHeight = totalMaxHeight + node:getContentSize().height*node:getScale() + self.offsetY;

            local nodeWidth = node:getContentSize().width*node:getScale() + self.offsetX;
            if nodeWidth > totalMaxWidth then
                totalMaxWidth = nodeWidth;
            end
        end
        totalWidth = totalWidth + totalMaxWidth;
        if totalHeight < totalMaxHeight then
            totalHeight = totalMaxHeight;
        end


        -- print("totalWidth = "..totalWidth.."  totalHeight = "..totalHeight);
        self.container:setContentSize(cc.size( totalWidth,totalHeight))

        local posX = self:getPaddingX();
        local posY = totalHeight - self:getPaddingY();
        local oneMaxWidth = 0;
        for key,node in pairs(self.items) do
            node:setPosition(posX,posY);
            posY = posY - (node:getContentSize().height*node:getScale() + self.offsetY);
            local width = node:getContentSize().width*node:getScale() + self.offsetX;
            if width > oneMaxWidth then
                oneMaxWidth = width;
            end
            -- print("key = "..key);
            if math.mod(key,rowNum) == 0 then
                posX = posX + oneMaxWidth;
                posY = totalHeight - self:getPaddingY();
                -- print("reset PosY key = "..key);
                oneMaxWidth = 0;
            end
        end

        -- totalHeight=self.itemHeight
        -- totalWidth=(self.itemWidth+self.offsetX)*math.ceil(table.getn(self.items)/rowNum)
        -- self.container:setContentSize(cc.size( totalWidth,totalHeight))
        -- local idx=0
        -- for key, node in pairs(self.items) do
        --     node:setPositionX(self:getPaddingX() + (self.itemWidth + self.offsetX)*(math.floor(idx/rowNum)) )
        --     node:setPositionY( self.itemHeight + self:getPaddingY())

        --     idx=idx+1
        -- end

        if moveToUp then
            self.container:setPositionX(0);
        end
    else
        local colNum=self.eachLineNum

        totalHeight = self:getPaddingY()*2;
        for key,node in pairs(self.items) do
            if (key-1) % colNum == 0 then
                totalHeight = totalHeight + node:getContentSize().height*node:getScale() + self.offsetY;
            end
        end
        -- print("totalHeight = "..totalHeight);
        totalWidth=self.itemWidth+self.offsetX+self:getPaddingX()*2;
        self.container:setContentSize(cc.size( totalWidth,totalHeight));
        self.itemPosY = totalHeight - self:getPaddingY();
        local idx=0
        for key,node in pairs(self.items) do
            node:setPositionX((idx%colNum)*(self.itemWidth+self.offsetX)+self:getPaddingX());
            node:setPositionY(self.itemPosY);
            if key % colNum == 0 then
                self.itemPosY = self.itemPosY - node:getContentSize().height*node:getScale() - self.offsetY;
            end
            -- print("posY = "..self.itemPosY);
            idx=idx+1
        end

        -- totalHeight=(self.itemHeight+self.offsetY)*math.ceil(table.getn(self.items)/colNum)+self.padding*2
        -- totalWidth=self.itemWidth+self.offsetX+self.padding*2
        -- self.container:setContentSize(cc.size( totalWidth,totalHeight))
        -- local idx=0
        -- for key, node in pairs(self.items) do
        --     node:setPositionX((idx%colNum)*(self.itemWidth+self.offsetX)+self.padding)
        --     node:setPositionY(totalHeight-self.padding- (self.itemHeight+self.offsetY)*(math.floor(idx/colNum)))

        --     idx=idx+1

        -- end



        if(moveToUp)then
            self.container:setPositionY(containerSize.height-totalHeight)
        else
            -- print("orgSize.height = "..orgSize.height);
            -- print("containerSize.height = "..containerSize.height);
            if(totalHeight<containerSize.height)then
                self.container:setPositionY(containerSize.height-totalHeight)
            elseif not (totalHeight == orgSize.height) --[[and orgSize.height > containerSize.height]] then
                --新增item,container保持原来的位置不动
                -- self.container:stopAllActions();
                local newY = self.container:getPositionY() - (totalHeight - orgSize.height);
                -- self.container:setPositionY(newY);
                -- print("before newY = "..newY);
                local newPosX,newPosY = self:checkBoard(cc.p(self.container:getPositionX(),newY));

                -- print("after newPosY = "..newPosY);
                self.container:setPositionY(newPosY);
            -- self.container:runAction(cc.EaseSineOut:create(cc.MoveTo:create(0.5,cc.p(newPosX,newPosY))));
            end
        end

        -- print("container Y = "..self.container:getPositionY());
    end

end

function ScrollLayer:setCheckChildrenVisible()
    -- body
    if self.scroll.setCheckChildrenVisible then
        self.scroll:setCheckChildrenVisible(true);
    end
end
function ScrollLayer:setCheckChildrenVisibleEnable(enable)
    -- body
    if self.scroll.setCheckChildrenVisibleEnable then
        self.scroll:setCheckChildrenVisibleEnable(enable);
    end
end

function ScrollLayer:startCheckChildrenVisibleUpdate()
    local update = function()
        self:setCheckChildrenVisible();
    -- print("scroll update");
    end
    self:scheduleUpdateWithPriorityLua(update,1)
end

function ScrollLayer:stopCheckChildrenVisibleUpdate()
    self:unscheduleUpdate()
end

function ScrollLayer:checkBoard(newPos)
    local min = self.scroll:minContainerOffset();
    local max = self.scroll:maxContainerOffset();

    if newPos == nil then
        newPos = cc.p(self.container:getPosition());
    end

    local newX     = newPos.x;
    local newY     = newPos.y;
    if (self.dir == cc.SCROLLVIEW_DIRECTION_BOTH or self.dir == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
        newX     = math.max(newX, min.x);
        newX     = math.min(newX, max.x);
    end

    if (self.dir == cc.SCROLLVIEW_DIRECTION_BOTH or self.dir == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        newY     = math.min(newY, max.y);
        newY     = math.max(newY, min.y);
    end
    return newX,newY;
end

function ScrollLayer:setPaddingXY(paddingX, paddingY)
    self.paddingX = paddingX
    self.paddingY = paddingY
end

function ScrollLayer:getPaddingX()
    if nil ~= self.paddingX then
        return self.paddingX
    end

    return self.padding
end

function ScrollLayer:getPaddingY()
    if nil ~= self.paddingY then
        return self.paddingY
    end

    return self.padding
end

function ScrollLayer:getSize()
    return table.getn(self.items)
end

function ScrollLayer:sortItems(sortFunc)
    if #self.items == 0 then
        return
    end

    table.sort(self.items, sortFunc)
end


return ScrollLayer