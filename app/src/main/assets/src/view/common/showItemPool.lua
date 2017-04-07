local ShowItemPoolLayer=class("ShowItemPoolLayer", function()
    return cc.Node:create()
end)

function ShowItemPoolLayer:ctor()
    local winSize=cc.Director:getInstance():getWinSize()
    self:setContentSize(winSize);
    -- self:setPosition((winSize.width)/2,(winSize.height)/2)
 
    self.itemStack={}
    self.updateDirty = false;

    local function _update()
        self:update()
    end 

    self:scheduleUpdateWithPriorityLua(_update,1)

    -- local oneShowItem = self:createOneShowItem();
    -- gAddChildByAnchorPos(self,oneShowItem,cc.p(0.5,0.6));
end

function ShowItemPoolLayer:setItem(showItems)
    self.itemStack = showItems;
    self.updateDirty = true;
end

function ShowItemPoolLayer:pushItems(items)
    for key,var in pairs(items) do
        self:pushOneItem(var);
    end
end

function ShowItemPoolLayer:clearItems()
    -- body
    self.itemStack = {};
end

-- {id,num,showAnchor}
function ShowItemPoolLayer:pushOneItem(item)
    table.insert(self.itemStack,item);
    self.updateDirty = true;
end

function ShowItemPoolLayer:update()  
    
    if(self.updateDirty == false)then
        return;
    end

    if(table.getn(self.itemStack)==0)then
        return
    end
    
    if(self.isShowing)then
        return
    end
    
    print("ShowItemPoolLayer showOne");
    
    self.isShowing=true
    local item =  self.itemStack[1];
    table.remove(self.itemStack,1);

    local oneShowItem,time = self:createOneShowItem(item);
    if item.showAnchor == nil then
        item.showAnchor = cc.p(0.5,0.6)
    end
    gAddChildByAnchorPos(self,oneShowItem,item.showAnchor);

    local function actionEnd()
        self.isShowing = false;
    end
    oneShowItem:runAction(cc.Sequence:create(
            cc.DelayTime:create(time/2),
            cc.CallFunc:create(actionEnd),
            cc.DelayTime:create(time/2),
            cc.RemoveSelf:create()
        ));

    if(table.getn(self.itemStack)==0)then
        self.updateDirty = false;
    end

end

function ShowItemPoolLayer:createOneShowItem(item)
    local uiLayer = UILayer.new();
    uiLayer:init("ui/ui_notice.map"); 
    self.isBlackBgVisible = false
    self.bgVisible =false
    uiLayer:getNode("txt_info"):setVisible(false);
    uiLayer:setAnchorPoint(cc.p(0.5,-0.5));
    local bg = uiLayer:getNode("bg");

    local rtf = uiLayer:getNode("rtf_info");
    rtf:clear();

    rtf:addWord(gGetWords("labelWords.plist","get"));

    if (item.id == OPEN_BOX_VIP_SCORE) then
        local score = gGetWords("labelWords.plist","vipscore")
        rtf:addWord(score);
    else
        local node = DropItem.new();
        node:setData(item.id);
        node:setNum(0);
        node:setAnchorPoint(cc.p(0.5,-0.5));
        node:setOpacityEnabled(true);
        local icon = cc.Node:create();
        icon:setCascadeOpacityEnabled(true);
        icon:setContentSize(node:getContentSize());
        icon:setScale(0.36);
        gAddChildByAnchorPos(icon,node,cc.p(0.5,0.5));
        rtf:addNode(icon);
    end

    local name = DB.getItemName(item.id);
    rtf:addWord(name.."x"..item.num);

    rtf:layout();

    -- item.baojiTimes = math.random(2,9);
    -- print("item.baojiTimes = "..item.baojiTimes);
    if nil ~= item.baojiTimes and item.baojiTimes > 1 then
        local baoji = gCreateBaojiWord(item.baojiTimes);
        gAddChildByAnchorPos(bg,baoji,cc.p(0.5,1),cc.p(0,20));
    end

    -- bg:setCascadeOpacityEnabled(true);
    -- uiLayer:getNode("rtf_info"):setCascadeOpacityEnabled(true);
    bg:setAllChildCascadeOpacityEnabled(true);
    local time1 = 0.5;
    local time2 = 0.5;
    bg:setScale(0);
    bg:setOpacity(0);
    bg:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveBy:create(time1,cc.p(0,70)),
                cc.FadeTo:create(0.1,255),
                cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1))
                ),
            cc.Spawn:create(
                cc.MoveBy:create(time2,cc.p(0,70)),
                cc.FadeTo:create(time2,0))
            
        ));
    local time = time1 + time2;
    return uiLayer,time;
end

return ShowItemPoolLayer