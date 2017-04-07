local UILayer=class("UILayer", function()
    return cc.Node:create()
end)

OFFSETTYPE_LEFT = 1
OFFSETTYPE_RIGHT = 2
OFFSETTYPE_UP = 3
OFFSETTYPE_DOWN = 4
OFFSETTYPE_LEFT_UP = 5
OFFSETTYPE_RIGHT_UP = 6
OFFSETTYPE_LEFT_DOWN = 7
OFFSETTYPE_RIGHT_DOWN = 8

function UILayer:ctor()
    -- self:init(name)
    self.isUILayer = true;
    self.isIgnoreAppearAct = false;
    self.isIgnoreDisappearAct = false;
end

function UILayer:onUILayerExit()
    -- print("onUILayerExit");
    self:destruction();
end

function UILayer:onAppear()

    local function onAppeared()
        if (self.onAppearedCallback) then
            self.onAppearedCallback()
        end
        self.touchEnable=true
    end

    -- 1--缩放 2--向右移动
    local size=cc.Director:getInstance():getWinSize()
    self:ignoreAnchorPointForPosition(false);
    if self.appearType == 1 then
        self.touchEnable=false
        self:setScale(0);
        self:setAnchorPoint(cc.p(0.5,-0.5));
        self:setPosition((size.width)/2,(size.height)/2);
        self:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.2,1)),
            cc.CallFunc:create(onAppeared)));
    elseif self.appearType == 2 then
        self:setAnchorPoint(cc.p(1,-0.5));
        self.touchEnable=false
        self:setPosition(cc.p(0,(size.height)/2));
        self:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveBy:create(0.2,cc.p(self.mapW,0))),
            cc.CallFunc:create(onAppeared)));
    end

    -- --nodeAct
    -- for key,var in pairs(self.nodeAppearAct) do
    --     var.node:runAction(var.act);
    -- end
    self:resetLayOut();
    self:resetAdaptNode();
    self:scrollLayerLayOut();

    if(not self.isIgnoreAppearAct)then
        self:initAppearInitPro();
        self:showNodeAppearActs();
    end
end

function UILayer:resetLayOut()
    for key,layoutLayer in pairs(self.layoutLayers) do
        layoutLayer:layout();
    end
end

function UILayer:resetAdaptNode()
    for key,node in pairs(self.adaptNodes) do
        self:adaptNode(node);
    end
end

function UILayer:scrollLayerLayOut()
    for key,scrolllayer in pairs(self.scrollLayers) do
        -- print("scrollLayerLayOutscrollLayerLayOutscrollLayerLayOut");
        scrolllayer:layout();
    end    
end

function UILayer:addScrollLayer(scroll)
    if(scroll == nil)then
        return;
    end
    for key,scrolllayer in pairs(self.scrollLayers) do
        if(scrolllayer == scroll)then
            return;
        end
    end

    -- print("addScrollLayer");
    table.insert(self.scrollLayers,scroll);
end

function UILayer:adaptNode(node)
    if(node == nil)then
        return;
    end
    local count = node:getChildrenCount();
    if(count == 1)then
        local children = node:getChildren();
        local child = children[1];
        if(child)then
            if child.__cname=="LayOutLayer" then
                print(" UILayer:adaptNode child layout");
                child:layout();
            end
            local childContentSize = child:getContentSize();
            local curWidth = node:getContentSize().width;
            local curHeight = node:getContentSize().height;
            local oldWidth = curWidth;
            local oldHeight = curHeight;
            if(node.orginSize)then
                oldWidth = node.orginSize.width;
                oldHeight = node.orginSize.height;
                -- print("@@@@@@@@@ oldWidth = "..oldWidth);
            end
            local newWidth = oldWidth;
            local newHeight = oldHeight;
            local isChangeSize = false;
            if(node.iAdaptHOff)then
                newWidth = childContentSize.width + node.iAdaptHOff*2;
                if(node.forceAdapt or newWidth > oldWidth or curWidth ~= oldWidth)then
                    isChangeSize = true;
                    child:setAnchorPoint(cc.p(0.5,child:getAnchorPoint().y));
                    child:setPositionX(newWidth/2);
                end
            end
            if(node.iAdaptVOff)then
                newHeight = childContentSize.height + node.iAdaptVOff*2;
                if(node.forceAdapt or newHeight > oldHeight or curHeight ~= oldHeight)then
                    isChangeSize = true;
                    child:setAnchorPoint(cc.p(child:getAnchorPoint().x,0.5));
                    child:setPositionY(newHeight/2);
                end
            end
            if(isChangeSize)then
                node:setContentSize(newWidth,newHeight);
            end
        end
    end
end

function UILayer:setCloseCallBack(callback)
    self.closeCallBack = callback;
end

function UILayer:removeMapName()

    if gShowMapName then
        if(gShowMapNamePanel and self.mapName)then
            gShowMapNamePanel:removeMap(self.mapName);
        end
    end    
end

function UILayer:onDisappear(_callback)

    self:removeMapName();

    local function callback()
        self.touchEnable=true
        if(_callback)then
            _callback()
        end
    end

    local function endCallback()
        if(self.closeCallBack)then
            self.closeCallBack();
        end
    end

    local delay = 0;
    if(not self.isIgnoreDisappearAct)then
        print("showNodeDisappearActs");
        delay = self:showNodeDisappearActs();
    end
    -- print("delaytime = "..delay);
    if(gIsAndroid())then
        self.appearType = 0;
    end

    if self.appearType == 1 then
        self.touchEnable=false
        delay = delay - 0.2;
        if delay < 0 then
            delay = 0;
        end
        self:runAction(cc.Sequence:create(
            cc.EaseBackIn:create(cc.ScaleTo:create(0.2,0)),
            cc.DelayTime:create(delay),
            cc.CallFunc:create(endCallback),
            cc.RemoveSelf:create(),
            cc.CallFunc:create(callback)
        ) );
    -- return 1;
    elseif self.appearType == 2 then
        self.touchEnable=false
        delay = delay - 0.2;
        if delay < 0 then
            delay = 0;
        end

        self:runAction(cc.Sequence:create(
            cc.EaseSineIn:create(cc.MoveBy:create(0.2,cc.p(-self.mapW,0))),
            cc.DelayTime:create(delay),
            cc.CallFunc:create(endCallback),
            cc.RemoveSelf:create(),
            cc.CallFunc:create(callback)
        ) );
    -- return 1;
    else
        self.touchEnable=false
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.CallFunc:create(endCallback),
            cc.RemoveSelf:create(),
            cc.CallFunc:create(callback)
        )
        );
    -- self:removeFromParent();
    -- callback();
    end
    -- return 0;

end

function UILayer:destruction()
--释放保存的动作
-- if self.nodeAppearAct then
--     local count = table.count(self.nodeAppearAct);
--     -- print("cont = "..count);
--     if count > 0 then
--         for key,var in pairs(self.nodeAppearAct) do
--             var.act:release();
--             print("key = "..key);
--         end
--     end
-- end
    print("UILayer:destruction");
    self:removeMapName();
end

-- function UILayer:removeSelf()
--     self:removeFromParent();
-- end

function UILayer:addFullScreenTouchToClose()
    local node = cc.Node:create();
    -- local node = cc.LayerColor:create(cc.c4b(0,0,0,255),winSize.width*2,winSize.height*2)
    node:ignoreAnchorPointForPosition(false);
    node:setPosition(self.mapW/2,-self.mapH/2);
    node:setAnchorPoint(cc.p(0.5,0.5));
    self:addChild(node,-1);
    node:setContentSize(cc.size(gGetScreenWidth(),gGetScreenHeight()));
    self:addTouchNode(node,"full_close",0);
    self.vars["full_close"]=node
end

function UILayer:init(name)
    self.isUILayer = true;
    self:setName("UILayer");
    self.vars={}
    self.nodeAppearInitPro = {};
    self.nodeAppearAct = {};
    self.nodeDisappearAct = {};
    self.labelAtlasData = {};
    self.layoutLayers = {};
    self.adaptNodes = {};
    self.scrollLayers = {};

     print("uilayer------"..name)
    
    self.isBlackBgVisible = true;
    self.bgVisible = true;

    if self.adaptiveEnable == nil then
        self.adaptiveEnable = true;
    end
    
    local data = Scene.fileCache[name]
    if(data==nil or gFileCache == false)then
        data=cc.FileUtils:getInstance():getValueMapFromFile(name)
        Scene.fileCache[name]=data
    end 
    
    assert(loadstring("  gridInfo= "..data.mapInfo.gridInfo))()

    local gridWidth =gridInfo[1];
    local gridHeight =gridInfo[2];
    local gridWCount =gridInfo[3];
    local gridHCount =gridInfo[4];
    self.mapW = gridWidth * gridWCount;
    self.mapH = gridHeight * gridHCount;


    self:setContentSize(cc.size( 0, 0));
    if data.nodeGraph.children ~=nil then
        self:initNodeChildren(data.nodeGraph.children,self,{})
    end


    self:setContentSize(cc.size( self.mapW, self.mapH));
    local winSize=cc.Director:getInstance():getWinSizeInPixels()

    self:setMask()

    -- if self.appearType and self.appearType > 0 then
    self:onAppear();
    -- end


    local function onNodeEvent(event)
        if event == "exit" then
            self:onUILayerExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);

    self.mapName = name;
    if gShowMapName then
        if(gShowMapNamePanel)then
            gShowMapNamePanel:addMap(name);
        end
        -- if name ~= "ui/ui_main.map" then
        --     local mapName = gCreateWordLabelTTF(name,gFont,20,cc.c3b(255,0,0));
        --     -- mapName:setAnchorPoint(cc.p(0,1));
        --     local bg = cc.LayerColor:create(cc.c4b(0,0,0,200),mapName:getContentSize().width,mapName:getContentSize().height);
        --     gAddChildInCenterPos(bg,mapName);
        --     self:addChild(bg,100000);
        -- end
    end

end

function UILayer:setOpacityEnabled(enable)
    self:setAllChildCascadeOpacityEnabled(enable);
end


function UILayer:initNodeChildren(graph,parent,parantGraph)
    for key, value in pairs(graph) do
        local node=self:nodeWithNodeData(value)
        if node~=nil then

            local size=parent:getContentSize()
            local posX=node:getPositionX()
            local posY=node:getPositionY()
            if parantGraph.type=="Sprite" then
                local anchor=parent:getAnchorPoint()
                posX=posX+size.width*anchor.x
                posY=posY+size.height*anchor.y
            else
                posY=posY+ size.height
            end




            if( node.sprite9_bg)then
                node.oldWidth=node:getContentSize().width
                node.oldHeight=node:getContentSize().height
                node.oldX=posX
            end

            node:setPosition(posX,posY);

            if(parent.__cname=="ScrollLayer")then
                if(node.autoSort or (node.var ~=nil and string.find(node.var,"scroll_contain_item")))then
                    print("scroll add item in uilayer");
                    parent:addItem(node);
                    self:addScrollLayer(parent);
                else
                    parent:addContainerChild(node)
                end
            elseif(parent.__cname=="LayOutLayer")then
                parent:addNode(node);
            else
                parent:addChild(node)
            end


        end
    end

end

function UILayer:nodeWithNodeData(data)
    local ret=nil

    if data.type=="Sprite" then
        ret=self:createSprite(data)
    elseif data.type=="Layer" then
        ret=self:createLayer(data)
    elseif data.type=="ColorLayer" then
        ret=self:createColorLayer(data)
    elseif data.type=="LabelTTF" then
        ret=self:createLabel(data)
    elseif data.type=="TextInput" then
        ret=self:createEdit(data)
    elseif data.type=="LabelAtlas" then
        ret=self:createLabelAtlas(data);
    elseif data.type=="LayOut" then
        ret=self:createLayOutLayer(data);
    end



    if ret~=nil then
        self:initPro(ret ,data.initProperty)
        self:initAppearAction(ret,data)
        if  data.children~=nil then
            self:initNodeChildren(data.children,ret,data)
        end
    end



    return ret
end

function UILayer:isSpeColorFlag(pro)
    if(pro.sprite9_bg or pro.scroll_flag or pro.colorLayer_flag or pro.clipLayer_flag) then
        return true;
    end
    return false;
end

function UILayer:createColorLayer(data)
    if data==nil then
        return nil
    end
    local pro=data.initProperty
    assert(loadstring("  color= "..pro.color))()
    assert(loadstring("  size= "..pro.size))()

    if pro.fullScreen then
        size[1] = gGetScreenWidth();
        size[2] = gGetScreenHeight();
    end

    local  ret=nil
    if(pro.var and string.find(pro.var,"NodeGrid_"))then
        ret= cc.NodeGrid:create()
    else
        ret= cc.Node:create()
    end

    ret:ignoreAnchorPointForPosition(false)
    ret:setAnchorPoint(cc.p(0.5,0.5))
    ret:setContentSize(cc.size(size[1],size[2]))

    --适配
    if(pro.sprite9_bg or pro.scroll_flag or pro.colorLayer_flag or pro.clipLayer_flag) then

        -- if self.adaptiveEnable == false then
        --     pro.isScaleX = nil;
        --     pro.isScaleY = nil;
        -- end

        if self.adaptiveEnable then
            if pro.isScaleX then
                -- pro.isScaleX = nil;
                -- print("gGetScreenWidth = "..gGetScreenWidth());
                -- print("self.mapW = "..self.mapW);
                local offw = gGetScreenWidth() - self.mapW;
                -- print("offw = "..offw);
                if pro.anchor then
                    assert(loadstring("  anchor= "..pro.anchor))()
                    if anchor[1] ~= 0.5 then
                        offw = offw / 2;
                    end
                    if toint(pro.scaleOffset) > 0 then
                        offw = gGetScreenWidth() - self.mapW;
                    end
                end
                ret:setContentSize(ret:getContentSize().width + offw,ret:getContentSize().height);
            end
            if pro.isScaleY then
                -- pro.isScaleY = nil;
                local offh = gGetScreenHeight() - self.mapH;
                if pro.anchor then
                    assert(loadstring("  anchor= "..pro.anchor))()
                    if anchor[2] ~= 0.5 then
                        offh = offh / 2;
                    end
                    if toint(pro.scaleOffsetY) > 0 then
                        offh = gGetScreenHeight() - self.mapH;
                    end
                end
                ret:setContentSize(ret:getContentSize().width,ret:getContentSize().height + offh);
            end
        end
    end

    if(pro.sprite9_bg)then
        local file = "images/"..pro.sprite9_bg;
        local center_rect = cc.rect(0,0,0,0);
        local minWidth = 0;
        local minHeight = 0;
        if(pro.sprite9_bg_left ~= nil) then
            local left = toint(pro.sprite9_bg_left);
            local right = toint(pro.sprite9_bg_right);
            local up = toint(pro.sprite9_bg_up);
            local down = toint(pro.sprite9_bg_down);
            minWidth = left + right;
            minHeight = up + down;
            local texture = cc.Director:getInstance():getTextureCache():addImage(file);
            local textureSize = texture:getContentSize();
            if left == 0 and right == 0 and up == 0 and down == 0 then

            else
                local centerW = texture:getContentSize().width - left - right;
                local centerH = texture:getContentSize().height - up - down;
                center_rect = cc.rect(left,up,centerW,centerH);
            end
            if minWidth == 0 then
                minWidth = textureSize.width/3*2;
            end
            if minHeight == 0 then
                minHeight = textureSize.height/3*2;
            end

        end

        local sprite9 = ccui.Scale9Sprite:create(center_rect,file);
        sprite9:setContentSize(ret:getContentSize())
        sprite9.sprite9_bg=true
        sprite9.centerRect = center_rect;
        sprite9.minWidth = minWidth;
        sprite9.minHeight = minHeight;
        -- print("minWidth = "..minWidth);
        -- print("minHeight = "..minHeight);
        ret=sprite9

        ret:setCascadeOpacityEnabled(true);
        ret:setOpacity(color[4]);
    end

    if(pro.scroll_flag)then

        local scroll_type = toint(pro.scroll_type)
        if(scroll_type == nil) then
            scroll_type = cc.SCROLLVIEW_DIRECTION_VERTICAL;
        else
            if scroll_type == 0 then
                scroll_type = cc.SCROLLVIEW_DIRECTION_VERTICAL;
            elseif scroll_type == 1 then
                scroll_type = cc.SCROLLVIEW_DIRECTION_HORIZONTAL;
            end
        end
        ret=ScrollLayer.new(ret,scroll_type)
        ret:ignoreAnchorPointForPosition(false)
        ret:setAnchorPoint(cc.p(0.5,0.5))
        ret.scroll_flag=true
    end

    if(pro.colorLayer_flag) then
        size[1] = ret:getContentSize().width;
        size[2] = ret:getContentSize().height;
        if pro.clipLayer_flag then
            local stencil = cc.LayerColor:create(cc.c4b(color[1],color[2],color[3],color[4]),size[1],size[2]);
            ret = cc.ClippingNode:create();
            ret:setStencil(stencil);
            ret:setContentSize(cc.size(size[1],size[2]));
            ret:ignoreAnchorPointForPosition(false)
            ret:setAnchorPoint(cc.p(0.5,0.5))
            ret.stencil=stencil
        else
            ret = cc.LayerColor:create(cc.c4b(color[1],color[2],color[3],color[4]),size[1],size[2]);
            ret:ignoreAnchorPointForPosition(false)
            ret:setAnchorPoint(cc.p(0.5,0.5))
        end

    end

    ret.orginSize = ret:getContentSize();
    -- print("svae oldwidth = "..ret.orginSize.width);

    if(pro.flaFileName)then
        ret = self:createFla(pro);
    end

    if(pro.ParticleName) then
        self:createParticle(ret,pro);
    end

    if(pro.map) then
        ret = self:createUILayer(pro);
    end

    local isAdaptNode = false;
    if(pro.isAdaptH and pro.iAdaptHOff)then
        ret.iAdaptHOff = toint(pro.iAdaptHOff);
        isAdaptNode = true;
    end
    if(pro.isAdaptV and pro.iAdaptVOff)then
        ret.iAdaptVOff = toint(pro.iAdaptVOff);
        isAdaptNode = true;
    end
    if(isAdaptNode)then
        table.insert(self.adaptNodes,ret);
    end

    return ret
end

function UILayer:createLayer(data)
    if data==nil then
        return nil
    end
    local ret=nil;
    local pro=data.initProperty
    ret=cc.Node:create()

    ret:setContentSize(cc.size(0,0));
    return ret
end

function UILayer:createLayOutLayer(data)
    if data==nil then
        return nil
    end
    local ret=nil;
    local pro=data.initProperty
    ret = LayOutLayer.new(toint(pro.type),toint(pro.offw),toint(pro.align));
    ret:setSortByPos();

    table.insert(self.layoutLayers,ret);

    if(pro.contentSize  )then
        assert(loadstring("  contentSize= "..pro.contentSize))()
        size.width=contentSize[1]
        size.height=contentSize[2]
        ret:setContentSize(cc.size(size.width,size.height));
    end

    -- print_lua_table(ret:getContentSize());

    return ret
end

function UILayer:createEdit(data)
    if data==nil then
        return nil
    end
    local pro=data.initProperty
    local ret=nil;
    local bg=ccui.Scale9Sprite:create()
    local size=cc.size(200,30)
    if(pro.touchSize == nil)then
        pro.touchSize = pro.contentSize;
    end
    if(pro.touchSize)then
        assert(loadstring("  touchSize= "..pro.touchSize))()
        if touchSize[1]>0 then
            size.width= touchSize[1]
        end
        if touchSize[2]>0 then
            size.height=touchSize[2]
        end
    end
    ret = ccui.EditBox:create(size,bg)
    if(pro.pwd)then
        ret:setInputFlag(0);
    end
    local fontSize=20
    if pro.fontSize~=nil then
        fontSize=pro.fontSize
    end

    ret:setFont(gFont,fontSize)
    ret:setPlaceholderFont(gFont,fontSize)

    if(pro.color==nil)then
        pro.color="{255,255,255,255}"
    end
    assert(loadstring("  color= "..pro.color))()
    local word = nil;
    if(pro.createMethod~=nil and pro.createMethod == "2")then
        word = gGetMapWords(pro.wordFile,pro.wordKey);
    elseif(pro.wordString)then
        word = pro.wordString;
    else
        word = gGetWords(pro.wordFile,pro.wordKey);
    end
    ret:setPlaceHolder(word);
    -- if(pro.wordString)then
    --     ret:setPlaceHolder(pro.wordString)
    -- else
    --     ret:setPlaceHolder( gGetWords(pro.wordFile,pro.wordKey))
    -- end
    ret:setFontColor(cc.c4b(color[1],color[2],color[3],color[4]))
    if pro.limitLength~=nil and toint(pro.limitLength) > 0 then
        ret:setMaxLength(pro.limitLength)
    end
    return ret
end

function UILayer:createLabelAtlas(data)
    -- body
    if data==nil then
        return nil
    end
    local pro=data.initProperty
    local ret=nil;
    local iSetIndex = toint(pro.type);
    -- print("index = " .. iSetIndex .. " count = "..table.getn(IFrame.data.labelAtlasConfig));
    if(iSetIndex >= 0 and iSetIndex < table.getn(IFrame.data.labelAtlasConfig)) then
        local data = IFrame.data.labelAtlasConfig[iSetIndex+1];
        -- print_lua_table(data);
        if pro.var then
            self.labelAtlasData[pro.var] = {image = "images/"..data.image,
                w = data.w,
                h = data.h,
                offw = toint(data.offw),
                start = data.start};
        end
        ret = gCreateLabelAtlas("images/"..data.image,data.w,data.h,pro.num,data.offw,data.start);
    else
        if pro.var then
            self.labelAtlasData[pro.var] = {image = "images/"..pro.image,
                w = pro.w,
                h = pro.h,
                offw = toint(pro.offw),
                start = pro.start};
        end
        ret = gCreateLabelAtlas("images/"..pro.image,pro.w,pro.h,pro.num,pro.offw,pro.start);
    end
    return ret;
end

function UILayer:replaceNode(name,newNode,sameScale)
    -- body
    local oldNode = self:getNode(name);
    -- oldNode:setVisible(false);
    newNode:setPosition(oldNode:getPosition());
    newNode:setAnchorPoint(oldNode:getAnchorPoint());
    if sameScale and sameScale == true then
        newNode:setScaleX(oldNode:getScaleX());
        newNode:setScaleY(oldNode:getScaleY());
    -- newNode:setScale(oldNode:getScale());
    end
    newNode:setLocalZOrder(oldNode:getLocalZOrder());
    self.vars[name] = newNode;
    if(name == self.preVarName)then
        self.preNode = newNode;
    end
    if(oldNode:getParent().__cname=="LayOutLayer")then
        print("replace layout node");
        for key,layoutLayer in pairs(self.layoutLayers) do
            if(layoutLayer == oldNode:getParent())then
                layoutLayer:removeNode(oldNode);
                layoutLayer:addNode(newNode);
                break;
            end
        end
        -- local parent = oldNode:getParent();
        -- parent = tolua.cast(parent,"LayOutLayer");
        -- parent:removeNode(oldNode);
        -- parent:addNode(newNode);
    else
        oldNode:getParent():addChild(newNode,oldNode:getLocalZOrder());
        oldNode:removeFromParent();
    end

    -- --替换layout中的node
    -- for key,layoutLayer in pairs(self.layoutLayers) do
    --     for index,item in pairs(layoutLayer.items) do
    --         if(item == oldNode)then
    --             print("replaceNode");
    --             -- item = newNode;
    --             layoutLayer[index] = newNode;
    --         end
    --     end
    -- end
end


function UILayer:setMask()
    for key, var in pairs(self.vars) do
        if(string.find(key,"mask_"))then
            local maskName=string.sub(key,6,string.len(key))
            local node=self:getNode(maskName)
            if(node)then
                local parent=  node:getParent()
                local cliper = cc.ClippingNode:create()
                cliper:setAlphaThreshold(0)
                cliper:setStencil(var)

                node:retain()
                node:removeFromParent()
                cliper:addChild(node)
                node:release()


                var:removeFromParent()
                parent:addChild(cliper)
                self.vars[key.."_clip"]=cliper
            end
        end
    end

end

function UILayer:createLabel(data)
    if data==nil then
        return nil
    end
    local pro=data.initProperty
    local ret=nil;
    local fontSize=20
    if pro.fontSize~=nil then
        fontSize=pro.fontSize
    end

    local word = nil;
    if(pro.createMethod~=nil and pro.createMethod == "2")then
        word = gGetMapWords(pro.wordFile,pro.wordKey);
    elseif(pro.wordString)then
        word = pro.wordString;
    else
        word = gGetWords(pro.wordFile,pro.wordKey);
    end

    if(word==nil)then
        return
    end

    word = getLvReviewName(word)

    if string.find(word,"\\") then
        local w = 0;
        if(pro.dimensions~=nil)then
            assert(loadstring("  dimensions= "..pro.dimensions))()
            w = dimensions[1];
        end
        if(pro.color==nil)then
            pro.color="{255,255,255,255}"
        end
        assert(loadstring("  color= "..pro.color))()
        --rtf
        ret = RTFLayer.new(w);
        ret:setDefaultConfig(pro.font,fontSize,cc.c3b(color[1],color[2],color[3]));
        ret:setString(word);
        ret.mapString = word;
        ret:layout();
    else
        if(gCurLanguage == LANGUAGE_ZHT) then
            if pro.font=="0" and gContainSpeWord(word) then
                pro.font = nil;
            end
        end

        if(pro.font=="0" and false)then
            local ttfConfig = {}
            ttfConfig.fontFilePath = gCustomFont--"font/font.TTF"
            ttfConfig.fontSize = fontSize
            ret= cc.Label:createWithTTF(ttfConfig,"");
            -- ret:setLineHeight(0);
            ret.ttfConfig = ttfConfig;

            ret.font = gCustomFont;
            ret.fontsize = fontSize;
        else
            ret = cc.Label:create()
            ret:setSystemFontSize(fontSize)
            ret:setSystemFontName(gFont)

            ret.font = gFont;
            ret.fontsize = fontSize;
        end


        if(pro.align=="1")then
            ret:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)

        elseif(pro.align=="2")then
            ret:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)

        else
            ret:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)

        end



        if(pro.color==nil)then
            pro.color="{255,255,255,255}"
        end
        if(pro.dimensions~=nil)then
            assert(loadstring("  dimensions= "..pro.dimensions))()
            ret:setDimensions( dimensions[1],dimensions[2])

            -- print("getLineHeight = "..ret:getLineHeight());
        end


        assert(loadstring("  color= "..pro.color))()
        ret.mapString = word;
        ret:setString(word);
        -- if(pro.wordString)then
        --     ret:setString(pro.wordString)
        -- else
        --     ret:setString( gGetWords(pro.wordFile,pro.wordKey))
        -- end
        ret.color = cc.c3b(color[1],color[2],color[3]);
        ret:setColor(cc.c3b(color[1],color[2],color[3]));
        ret:setOpacity(color[4]);
        --    ret:updateDisplayedColor(cc.c3b(color[1],color[2],color[3]))

        local outline_type = toint(pro.outline_type);
        if(outline_type ~= nil and outline_type > 0) then
            local outline_color = {255,255,255,255};
            local outline_offset = 0.2;
            --自定义
            if(outline_type == 1) then
                assert(loadstring("  outline_color_tmp= "..pro.outline_color))();
                outline_color = cc.c4b(outline_color_tmp[1],outline_color_tmp[2],outline_color_tmp[3],outline_color_tmp[4]);
                outline_offset = pro.outline_offset;
            else
                local data = IFrame.data.labelOutLineConfig[outline_type-2+1];
                outline_color = cc.c4b(data.r,data.g,data.b,data.o);
                outline_offset = data.offset;
            -- elseif(outline_type == 2) then
            --     --黑边
            --     outline_color = cc.c4b(0,0,0,255);
            --     outline_offset = 0.1;
            -- elseif(outline_type == 3) then
            --     --白边
            --     outline_color = cc.c4b(255,255,255,255);
            --     outline_offset = 0.1;
            end
            ret.outline_color = outline_color;
            ret.outline_offset = outline_offset;
            ret:enableOutline(outline_color,fontSize*outline_offset);
        end

        if(pro.dimensions~=nil and ret.ttfConfig)then
            ret:setLineHeight(ret:getLineHeight()-5);
        end
    end

    return ret
end

function UILayer:createSprite(data)
    if data==nil then
        return nil
    end
    local ret=nil

    local pro=data.initProperty
    ret=cc.Sprite:create("images/"..pro.imageFile)
    if(ret==nil)then
        if(cc.SpriteFrameCache:getInstance():getSpriteFrame("images/"..pro.imageFile)~=nil) then
            ret=cc.Sprite:createWithSpriteFrameName("images/"..pro.imageFile)
        end
    end

    if(pro.flaFileName)then
        ret = self:createFla(pro);
    -- local flaDatas =string.split(pro.flaFileName, ",")
    -- local flaNames=  string.split(flaDatas[1],".")
    -- loadRelationFlaXml(flaNames[1])
    -- local fla=FlashAni.new()
    -- local loop = 1;
    -- if table.getn(flaDatas) > 2 then
    --     loop = toint(flaDatas[3]);
    -- end
    -- fla:playAct(flaDatas[2],false,loop);
    -- -- fla:playAction(flaDatas[2])
    -- ret=fla
    end

    if(ret)then
        ret.imagePath="images/"..pro.imageFile
    end

    if(pro.color~=nil and ret)then
        assert(loadstring("  color= "..pro.color))()
        ret:setOpacity(color[4])
    end

    if(pro.ParticleName) then
        self:createParticle(ret,pro);
    end


    return ret
end

function UILayer:createFla(pro)
    local flaDatas =string.split(pro.flaFileName, ",")
    local flaNames=  string.split(flaDatas[1],".")
    loadRelationFlaXml(flaNames[1])
    local fla=FlashAni.new()
    local loop = 1;
    local paramCount = table.getn(flaDatas);
    if paramCount > 2 then
        loop = toint(flaDatas[3]);
    end
    if paramCount > 3 then
        local delay = tonum(flaDatas[4]);
        fla.delayplaytime = delay;
    end
    fla:playAct(flaDatas[2],false,loop);
    -- fla:playAction(flaDatas[2])
    return fla;
end

function UILayer:createParticle(node,pro)
    local particle1 =  cc.ParticleSystemQuad:create(pro.ParticleName);
    particle1:setPosition(cc.p(0,0));
    node:addChild(particle1)
end

function UILayer:createUILayer(pro)
    local ret=nil;
    if pro.map then
        -- print();
        ret = UILayer.new();
        ret:init(pro.map,false,false);
    end
    return ret;
end

function setTouchBeganEffect(target,type)
    if(toint(target.touchEffect)==1)then
        gModifyExistNodeAnchorPoint(target,cc.p(0.5,0.5));
        target.preScaleX=target:getScaleX()
        target.preScaleY=target:getScaleY()
        target:setScaleX(target.preScaleX*0.9)
        target:setScaleY(target.preScaleY*0.9)

    else


    end
end

function setTouchEndEffect(target,type)
    if(toint(target.touchEffect)==1)then
        if target.preScaleX then
            target:setScaleX(target.preScaleX)
        end
        if target.preScaleY then
            target:setScaleY(target.preScaleY)
        end

    else
    end
end

function checkTargetVisible(target)
    local parent=target
    while(parent)do
        if(parent:isVisible()==false or ( parent.scroll==nil and parent.touchEnable==false))then
            return false
        end
        parent=parent:getParent()
    end

    return true
end

function onTouchBegan(touch, event)

 
    local location = touch:getLocation()
    local target=  event:getCurrentTarget()
    local rect   = target:getBoundingBox()
    Guide.hasClick=true 
    
 

    if(UILayer.pauseTouch==true or UILayer.pauseTouchForScreen == true)then
        if(target.touchLayer.ignoreGuide~=true)then
            return false
        end
    end

    if(target.touchLayer.touchEnable==false)then
        return true;
    end

    local parent=target:getParent();
    if(   Guide.canTouch(target)==false )then
        return false
    end


    if(target.__story)then
        return true
    end


    if(target.__notice)then
        if( checkTargetVisible(target))then
            return true
        end
    end
    local isInSide=false
    if(target.__isTouchInside)then
        isInSide=target.__isTouchInside(touch, event)
    else
        if(target.offset_touchw ~= nil)then
            rect.x = rect.x - target.offset_touchw;
            rect.width = rect.width + 2*target.offset_touchw;
        end
        if(target.offset_touchh ~= nil)then
            rect.y = rect.y - target.offset_touchh;
            rect.height = rect.height + 2*target.offset_touchh;
        end
        local nodeLocation= target:getParent():convertToNodeSpace(location)
        isInSide=cc.rectContainsPoint(rect, nodeLocation)
    end

    if isInSide then
        if(not target.__touchable)then
            Guide.clickItem(target,isInSide )
            --变灰也能过引导
        end

        if( checkTargetVisible(target) and target.__touchable)then

            local scrollParent=nil
            target._isScollMove=false
            target._hasScrollParent=false

            local parent=target:getParent()
            while(parent~=nil)do
                if(parent.__cname=="ScrollLayer")then
                    local ret= parent:onTouchBegan(touch,event)
                    scrollParent=parent
                    if(ret)then
                        target._isScollMove=false
                        target._hasScrollParent=true
                        target._touchBeginPosX=location.x
                        target._touchBeginPosY=location.y
                    end
                    break
                end
                parent=parent:getParent()
            end

            if(scrollParent)then
                local rect=scrollParent:getViewRect()
                local inSideScroll=cc.rectContainsPoint(rect, location)
                if(inSideScroll==false)then
                    return false
                end
            end

            setTouchBeganEffect(target)
            target.touchLayer:onTouchBegan(target,touch, event)
            Guide.beganClickItem(target)
            Guide.clickRight=true 


            return true;
        end
    end
    return false
end

function onTouchMoved(touch, event)
    local location = touch:getLocation()
    local target=  event:getCurrentTarget()
    -- print("@@@@@@@touchMove");
    target.touchLayer:onTouchMoved(target,touch, event)
    if(target._hasScrollParent)then
        -- print("@@@@@@@11111111touchMove");
        local parent=target:getParent()
        while(parent~=nil)do
            if(parent.__cname=="ScrollLayer")then
                -- print("@@@@@@@222222touchMove");
                parent:onTouchMoved(touch,event)
                if(getDistance(target._touchBeginPosX,target._touchBeginPosY,location.x,location.y)>30)then
                    target._isScollMove=true
                end
                break
            end
            parent=parent:getParent()
        end

    end


    --cclog("onTouchMoved: %0.2f, %0.2f", location.x, location.y)
end


function onTouchEnded(touch, event)
    local location = touch:getLocation()
    local target=  event:getCurrentTarget()
    local rect   = target:getBoundingBox()

    if(target.touchLayer.touchEnable==false)then
        return ;
    end

    if(target._hasScrollParent)then
        local parent=target:getParent()
        while(parent~=nil)do
            if(parent.__cname=="ScrollLayer")then
                parent:onTouchEnded(touch,event)
                break
            end
            parent=parent:getParent()
        end
    end
    local isInSide=false
    if(target.__isTouchInside)then
        isInSide=target.__isTouchInside(touch, event)
    else
        local nodeLocation= target:getParent():convertToNodeSpace(location)
        rect.width= rect.width+20
        rect.height= rect.height+20
        if(target.offset_touchw ~= nil)then
            rect.x = rect.x - target.offset_touchw;
            rect.width = rect.width + 2*target.offset_touchw;
            -- print("target.offset_touchw = "..target.offset_touchw);
        end
        if(target.offset_touchh ~= nil)then
            rect.y = rect.y - target.offset_touchh;
            rect.height = rect.height + 2*target.offset_touchh;
            -- print("target.offset_touchh = "..target.offset_touchh);
        end
        isInSide=cc.rectContainsPoint(rect, nodeLocation)
    end

    setTouchEndEffect(target)

    if(target.__touchend)then
        if(Guide.clickItem(target,isInSide ))then
            target.touchLayer:onTouchEnded(target,touch, event)
        end

    elseif(target._isScollMove~=true)then
        if target.__story or
            isInSide then

            if(Guide.clickItem(target,isInSide ))then
                --CD
                local callback = true;
                local node = target;
                -- local node = target.touchLayer:getNode(target.touchName);
                if node then
                    local preTouchTime = node.touchTime;
                    -- print("offtime = "..socket.gettime() - preTouchTime);
                    -- print("cdtime = "..node.cdTime);
                    if socket.gettime() - preTouchTime < node.cdTime then
                        callback = false;
                    end
                end
                if callback then
                    --播放点击音效
                    target.touchLayer:playBtnSound(target.touchName);
                    target.touchLayer:onTouchEnded(target,touch, event)
                    if node then
                        node.touchTime = socket.gettime();
                    end
                end
            end
        end
    end

    gRedposRefreshDirty = true;

    gDragLayer:removeAllChildren()


end

function UILayer:onTouchMoved(target,touch, event)


end
function UILayer:onTouchBegan(target,touch, event)


end

function UILayer:onTouchEnded(target,touch, event)


end

function UILayer:playBtnSound(name)
    local btn = self:getNode(name);
    if btn then
        if btn.sound and btn.sound == "0" then
            return;
        end
        if btn.sound == nil or btn.sound == "" then
            btn.sound = "btn/btn_click.wav";
        end
        gPlayEffect("sound/"..btn.sound);
    end
end

function UILayer:initAppearInitPro()
    for key,var in pairs(self.nodeAppearInitPro) do
        local node = var.node;
        local initProStr = var.initPor;
        local pros = string.split(initProStr,";");
        for key,var in pairs(pros) do
            local values = string.split(var,":");
            if table.getn(values) > 1 then
                local sType = values[1];
                local sContent = values[2];
                if sType == "pos" then
                    local pos = string.split(sContent,",");
                    node:setPositionX(node:getPositionX()+pos[1]);
                    node:setPositionY(node:getPositionY()+pos[2]);
                elseif sType == "scale" then
                    local scale = string.split(sContent,",");
                    node:setScaleX(scale[1]);
                    node:setScaleY(scale[2]);
                elseif sType == "rotate" then
                    node:setRotation(sContent);
                elseif sType == "opacity" then
                    node:setAllChildCascadeOpacityEnabled(true);
                    node:setOpacity(sContent);
                elseif sType == "visible" then
                    node:setVisible(sContent=="1");
                end
            end
        end
    end
end

function UILayer:initAppearAction(node,data)
    if data.runAction and data.actions then
        if data.runActionInitPro then
            table.insert(self.nodeAppearInitPro,{node = node,initPor = data.runActionInitPro});
        end
        table.insert(self.nodeAppearAct,{node=node,actions = data.actions,runAction = data.runAction});

    -- local act = Decode.decodeAction({runAction=data.runAction,actions=data.actions});
    -- if data.initProperty.var then
    --     print("var = "..data.initProperty.var);
    --     act:retain();
    --     self.nodeAppearAct[data.initProperty.var] = {node=node,act=act};
    -- end
    -- node:setCascadeOpacityEnabled(true);
    -- if node:isVisible() then
    --     node:runAction(act);
    -- end

    -- table.insert(self.nodeAppearAct,{node=node,act=act});
    -- print_lua_table(self.nodeAppearAct);
    end

    if data.exitrunAction and data.exitactions then
        table.insert(self.nodeDisappearAct,{node=node,actions = data.exitactions,runAction = data.exitrunAction});
    end
end

function UILayer:setNodeAppear(name,visible)
    local node = self:getNode(name);
    if visible then
        node:setAllChildCascadeOpacityEnabled(true);
        node:setOpacity(node:getOpacity());
        node:setVisible(visible);
    end
    for key,var in pairs(self.nodeAppearAct) do
        if var.node == node then
            var.node:stopAllActions();
            self:_resetToOriginPro(var.node);
            local act,time = Decode.decodeAction({runAction=var.runAction,actions=var.actions});
            if var.node:isVisible() then
                var.node:setAllChildCascadeOpacityEnabled(true);
                var.node:runAction(act);
            end
            break;
        end
    end
    -- if node and self.nodeAppearAct[name] and self.nodeAppearAct[name].act then
    --     node:stopAllActions()
    --     node:runAction(self.nodeAppearAct[name].act);
    -- end
end

function UILayer:showNodeAppearActs(forceRunAction)
    -- print("start");
    for k,v in pairs(self.nodeAppearAct) do
        -- print_lua_table(v.actions);
        if v.node:isVisible() or forceRunAction then
            local act,time = Decode.decodeAction({runAction=v.runAction,actions=v.actions});
            -- self:_resetToOriginPro(v.node);
            v.node:setAllChildCascadeOpacityEnabled(true);
            v.node:runAction(act);
        end
    end
    -- print("end");
end
function UILayer:showNodeDisappearActs()
    local totaltime = 0;
    for k,v in pairs(self.nodeDisappearAct) do
        -- print_lua_table(v);
        local act,time = Decode.decodeAction({runAction=v.runAction,actions=v.actions});
        if v.node:isVisible() then
            --记录原来属性
            self:_saveOriginPro(v.node);

            v.node:setAllChildCascadeOpacityEnabled(true);
            v.node:runAction(act);
        end
        -- print("showNodeDisappearActs node time = "..time);
        if tonum(time) > totaltime then
            totaltime = tonum(time);
        end
    end
    return totaltime;
end
function UILayer:_saveOriginPro(node)
    -- print("_saveOriginPro");
    node.originPro = {};
    node.originPro.pos = cc.p(node:getPosition());
    node.originPro.scaleX = node:getScaleX();
    node.originPro.scaleY = node:getScaleY();
    node.originPro.rotate = node:getRotation();
    node.originPro.opacity = node:getOpacity();
    node.originPro.visible = node:isVisible();
-- print_lua_table(node.originPro);
end
function UILayer:_resetToOriginPro(node)
    if node.originPro then
        -- print("_resetToOriginPro");
        node:setPosition(node.originPro.pos);
        node:setScaleX(node.originPro.scaleX);
        node:setScaleY(node.originPro.scaleY);
        node:setRotation(node.originPro.rotate);
        node:setOpacity(node.originPro.opacity);
        node:setVisible(node.originPro.visible);
        -- print_lua_table(node.originPro);
    end
end

function UILayer:initPro(node,data)
    if node==nil or data==nil then
        return
    end

    assert(loadstring("  pos= "..data.pos_p[1]))()
    local posX= pos[3]
    local posY=-pos[4];
    local offsetType=pos[2]
    local winSize=cc.Director:getInstance():getWinSizeInPixels()
    if offsetType~=0 and self.adaptiveEnable == true then
        local offsetPosX=(winSize.width-self.mapW)/2
        local offsetPosY=(winSize.height-self.mapH)/2
        posY=-posY

        if offsetType == OFFSETTYPE_LEFT then
            posX= posX-offsetPosX
        elseif  offsetType == OFFSETTYPE_RIGHT then
            posX = self.mapW - posX;
            posX=winSize.width-(posX+offsetPosX)
        elseif  offsetType == OFFSETTYPE_UP then
            posY=posY-offsetPosY
        elseif  offsetType == OFFSETTYPE_DOWN then
            posY = self.mapH - posY;
            posY=winSize.height-(posY+offsetPosY)
        elseif  offsetType == OFFSETTYPE_LEFT_UP then
            posX= posX-offsetPosX
            posY=posY-offsetPosY
        elseif  offsetType == OFFSETTYPE_RIGHT_UP then
            posX = self.mapW - posX;
            posX=winSize.width-(posX+offsetPosX)
            posY=posY-offsetPosY
        elseif  offsetType == OFFSETTYPE_LEFT_DOWN then
            posX= posX-offsetPosX
            posY = self.mapH - posY;
            posY=winSize.height-(posY+offsetPosY)
        elseif  offsetType == OFFSETTYPE_RIGHT_DOWN then
            posX = self.mapW - posX;
            posX=winSize.width-(posX+offsetPosX)
            posY = self.mapH - posY;
            posY=winSize.height-(posY+offsetPosY)
        end
        posY=-posY
    end
    node:setPosition(posX,posY)

    if data.anchor~=nil then
        assert(loadstring("  anchor= "..data.anchor))()
        node:setAnchorPoint(cc.p(anchor[1],anchor[2]))
    end

    if data.rotation~=nil then
        node:setRotation(data.rotation)
    end

    if data.scaleX~=nil then
        node:setScaleX(data.scaleX)
    end

    if data.scaleY~=nil then
        node:setScaleY(data.scaleY)
    end

    if data.scale~=nil and data.scaleX == data.scaleY then
        node:setScale(data.scale)
    end

    if data.isScaleX~=nil then
        if(self:isSpeColorFlag(data)==false)then
            local winSize=cc.Director:getInstance():getWinSize()
            node:setScaleX( winSize.width/node:getContentSize().width)
        end
    end

    if data.isScaleY~=nil then
        if(self:isSpeColorFlag(data)==false)then
            local winSize=cc.Director:getInstance():getWinSize()
            node:setScaleY( winSize.height/node:getContentSize().height)
        end
    end

    if data.z~=nil then
        node:setLocalZOrder(data.z)
    end



    if data.flipX~=nil then
        if node.setFlippedX then
            node:setFlippedX(data.flipX=="1")
        end

        if node.isFlashAni then
            node:setScaleX(-node:getScaleX());
        end
    end

    if data.flipY~=nil then
        if node.setFlippedY then
            node:setFlippedY(data.flipY=="1")
        end

        if node.isFlashAni then
            node:setScaleY(-node:getScaleY());
        end
    end




    if data.visible~=nil then
        node:setVisible(data.visible=="1")
    end

    if (data.autoSort and data.autoSort == "1") then
        node.autoSort = true;
    end

    if data.var~=nil then
        node.var = data.var;
        self.vars[data.var]=node
    end


    if data.touchEnable~=nil and toint( data.touchEnable)==1 then
        --兼容模式 0为没有音效
        if data.isBtnSound and data.isBtnSound == "0" then
            data.btnSound = "0";
        end
        local btnCd = 1.0
        if data.btnCd ~= nil then
            btnCd = tonum(data.btnCd);
        end
        self:addTouchNode(node,data.var,data.tapEffectType,data.btnSound,btnCd);
    end
end

function UILayer:setBtnCloseTouchOffsetForAndroid(var,node)
    if(gIsAndroid() and var == "btn_close")then
        node.offset_touchw = 15;
        node.offset_touchh = 15;
    end
end

--适配
function UILayer:setNodeOffsetType(node,offsetType)
    if self.adaptiveEnable == false then
        return;
    end
    local posX,posY = node:getPosition();
    local winSize=cc.Director:getInstance():getWinSizeInPixels()
    if offsetType~=0 then
        local offsetPosX=(winSize.width-self.mapW)/2
        local offsetPosY=(winSize.height-self.mapH)/2
        posY=-posY

        if offsetType == OFFSETTYPE_LEFT then
            posX= posX-offsetPosX
        elseif  offsetType == OFFSETTYPE_RIGHT then
            posX = self.mapW - posX;
            posX=winSize.width-(posX+offsetPosX)
        elseif  offsetType == OFFSETTYPE_UP then
            posY=posY-offsetPosY
        elseif  offsetType == OFFSETTYPE_DOWN then
            posY = self.mapH - posY;
            posY=winSize.height-(posY+offsetPosY)
        elseif  offsetType == OFFSETTYPE_LEFT_UP then
            posX= posX-offsetPosX
            posY=posY-offsetPosY
        elseif  offsetType == OFFSETTYPE_RIGHT_UP then
            posX = self.mapW - posX;
            posX=winSize.width-(posX+offsetPosX)
            posY=posY-offsetPosY
        elseif  offsetType == OFFSETTYPE_LEFT_DOWN then
            posX= posX-offsetPosX
            posY = self.mapH - posY;
            posY=winSize.height-(posY+offsetPosY)
        elseif  offsetType == OFFSETTYPE_RIGHT_DOWN then
            posX = self.mapW - posX;
            posX=winSize.width-(posX+offsetPosX)
            posY = self.mapH - posY;
            posY=winSize.height-(posY+offsetPosY)
        end
        posY=-posY
    end
    node:setPosition(posX,posY)
end

function UILayer:setScrollLayerAdaptive(node,isAdaptiveX,offsetX,isAdaptiveY,offsetY)
    self:setLayerAdaptive(node,isAdaptiveX,offsetX,isAdaptiveY,offsetY);
    node:resize(node:getContentSize());
end
function UILayer:setScale9SpriteAdaptive(node,isAdaptiveX,offsetX,isAdaptiveY,offsetY)
    self:setLayerAdaptive(node,isAdaptiveX,offsetX,isAdaptiveY,offsetY);
end
function UILayer:setLayerAdaptive(node,isAdaptiveX,offsetX,isAdaptiveY,offsetY)
    if self.adaptiveEnable == false then
        return;
    end
    --适配
    local anchor = node:getAnchorPoint();

    if isAdaptiveX then
        local offw = gGetScreenWidth() - self.mapW;

        if anchor.x ~= 0.5 then
            offw = offw / 2;
        end
        if offsetX > 0 then
            offw = gGetScreenWidth() - self.mapW;
        end

        node:setContentSize(node:getContentSize().width + offw,node:getContentSize().height);
    end

    if isAdaptiveY then
        local offh = gGetScreenHeight() - self.mapH;

        if anchor.y ~= 0.5 then
            offh = offh / 2;
        end
        if offsetY > 0 then
            offh = gGetScreenHeight() - self.mapH;
        end

        node:setContentSize(node:getContentSize().width,node:getContentSize().height + offh);
    end
end



function  UILayer:getNode(name)

    if(self.vars)then
        if(self.preVarName and self.preVarName == name)then
            -- print("file preVarName = "..self.preVarName);
            return self.preNode;
        end
        self.preVarName = name;
        self.preNode = self.vars[name];
        return self.preNode
    end

    return nil
end

function UILayer:setLabelAtlas(name,num)
    if self.labelAtlasData[name] == nil then
        return;
    end
    if(self.labelAtlasData[name].offw == 0) then
        self:getNode(name):setString(num);
    else
        local data = self.labelAtlasData[name];
        local newLab = gCreateLabelAtlas(data.image,data.w,data.h,num,data.offw,data.start);
        self:replaceNode(name,newLab,true);
    end
end

function UILayer:setRTFString(name,word)
    -- body
    local rtf=self:getNode(name)
    if(  rtf==nil)then
        return;
    end
    if(rtf.clear)then
        rtf:clear();
        rtf:setString(word);
        rtf:layout();
    end

end


function UILayer:setLabelColorNum(name,oldnum,newnum,words)
    oldnum = oldnum or 0
    newnum = newnum or 0
    oldnum = toint(oldnum)
    newnum = toint(newnum)
    if words==nil then
        words=newnum
    end
    self:setLabelString(name,words)
    if oldnum == newnum  then
        self:getNode(name):setColor(cc.c3b(255,255,255))
    elseif oldnum>newnum then
        self:getNode(name):setColor(cc.c3b(255,0,0))
    elseif oldnum<newnum then
        self:getNode(name):setColor(cc.c3b(0,255,0))
    end
end


function UILayer:setLabelString(name,words,wordsFile,isCheckSpeWord)
    local label=self:getNode(name)
    if(  label==nil)then
        return
    end
    if(isCheckSpeWord==nil)then
        isCheckSpeWord = true;
    end

    local showWord = "";
    if wordsFile then
        showWord = gGetWords(wordsFile,words);
    else
        showWord = words;
    end

    if isCheckSpeWord and label.ttfConfig then
        if gContainSpeWord(showWord) then
            --resetTTF配置
            label.useSystemFont = true;
            label:setSystemFontSize(0);
            label:setSystemFontName(gFont);
            label:setSystemFontSize(label.ttfConfig.fontSize);
        elseif(label.useSystemFont)then
            label.useSystemFont = false;
            label:setTTFConfig(label.ttfConfig);
        end
    end

    showWord = getLvReviewName(showWord);
    if(label.setString)then
        label:setString(showWord);
    elseif(label.setText)then
        label:setText(showWord);
    end


end

function UILayer:updateLabelChange(name,from,to,callback)
    -- print("name = "..name);
    local lab=self:getNode(name)
    if(lab==nil)then
        return
    end
    lab.curValue = from;
    local step = math.ceil( (to - from)/30 );
    -- print("step = "..step);

    lab:unscheduleUpdate()
    local function updatePer()
        if( lab.curValue>=to)then
            lab:unscheduleUpdate()
            lab.curValue = to;
            if(callback)then
                callback()
            end
        else
            lab.curValue = lab.curValue+step;
        end
        self:setLabelString(name,lab.curValue);
    end

    lab:scheduleUpdateWithPriorityLua(updatePer,1)
end

function UILayer:replaceRtfString(...)
    local params = {...}
    local name=params[1]
    local rtf=self:getNode(name)
    if(rtf==nil)then
        return
    end

    local word = rtf.mapString;
    if word then
        for i = 2,#params do
            word = gReplaceParam(word,params[i]);
        end
        self:setRTFString(name,word);
    end
end

function UILayer:replaceLabelString(...)
    local params = {...}
    local name=params[1]
    local label=self:getNode(name)
    if(  label==nil)then
        return
    end

    if(label.setString)then
        local word = label.mapString;
        if word == nil then
            word = label:getString();
        end
        for i = 2,#params do
            word = gReplaceParam(word,params[i]);
            label:setString(word);
        end
    elseif(label.setText)then
        local word = label.mapString;
        if word == nil then
            word = label:getText();
        end
        for i = 2,#params do
            word = gReplaceParam(word,params[i]);
            label:setText(word);
        end
    end


end




function UILayer:changeTexture(name,path)
    local btn=self:getNode(name)
    if(btn)then
        if btn.setTexture then
            btn:setTexture(path)
        elseif btn.updateWithSprite then
            local sprite = cc.Sprite:create(path);
            local originSize = btn:getContentSize();
            local rect = cc.rect(0,0,0,0);
            -- print_lua_table(rect);
            btn:updateWithSprite(sprite,rect,false,btn.centerRect);
            btn:setPreferredSize(originSize);
        -- print_lua_table(btn:getContentSize());
        -- btn:updateWithSprite(sprite,cc.rect(0,0,0,0),false,btn.centerRect);
        end
    end
end


function UILayer:changeIconType(name,type)
    local btn=self:getNode(name)
    if(btn)then
        if(type==OPEN_BOX_DIAMOND)then
            btn:setTexture("images/ui_public1/gold.png")
        elseif(type==OPEN_BOX_GOLD)then
            btn:setTexture("images/ui_public1/coin.png")
        elseif(type==OPEN_BOX_EXP)then
            btn:setTexture("images/icon/item/20.png")
        elseif(type==OPEN_BOX_PET_SOUL)then
            btn:setTexture("images/icon/sep_item/90016.png")
        elseif(type==OPEN_BOX_CARDEXP_ITEM)then
            btn:setTexture("images/icon/sep_item/90017.png")
        elseif(type==OPEN_BOX_EQUIP_SOUL)then
            btn:setTexture("images/icon/sep_item/"..OPEN_BOX_EQUIP_SOUL..".png")
        elseif(type==ITEM_DRAW_GOLD_BUY)then
            btn:setTexture("images/icon/item/131.png")
        elseif(type==OPEN_BOX_ITEMAWAKE)then
            btn:setTexture("images/icon/item/42.png")      
        end
    end
end

function UILayer:changeNodeToFla(name,flaName,actName,endDel,loop)
    -- body
    loadRelationFlaXml(flaName);
    local fla=FlashAni.new();
    if loop == nil then
        loop = 1;
    end
    fla:playAct(actName,endDel,loop);
    -- fla:playAction(actName);
    self:replaceNode(name,fla);
-- local node = self:getNode(name);
-- node:setVisible(false);
-- fla:setPosition(node:getPosition());
-- fla:setAnchorPoint(node:getAnchorPoint());
-- node:getParent():addChild(fla,node:getLocalZOrder());
end

--from & to --为percent;
function UILayer:setBarPerAction(name, from,to,callback,mirror,frame)

    local bar=self:getNode(name)

    if(bar==nil)then
        return
    end
    if( bar.oldPerValue==to)then
        return
    end

    if(bar.oldPerValue==nil)then
        bar.oldPerValue=to
    end

    if(from==nil)then
        from= bar.oldPerValue
    end
    bar.oldPerValue=to
    if(frame==nil)then
        frame=30
    end
    local speed= (to-from)/frame
    self:setBarPer(name, from,mirror)
    local function updatePer()
        if( (bar.curPer>=to and speed>0) or (bar.curPer<=to and speed<0) )then
            bar:unscheduleUpdate()
            self:setBarPer(name,to,mirror)
            if(callback)then
                callback()
            end
        else 
            self:setBarPer(name,bar.curPer+speed,mirror)
        end
    end

    bar:unscheduleUpdate()
    bar:scheduleUpdateWithPriorityLua(updatePer,1)

end

--fromValue and toValue 为具体数字
function UILayer:updateBarPer(barNodeName,barNumNodeName,fromValue,toValue,maxValue,frame,callback)

    local bar = self:getNode(barNodeName);
    if bar == nil then
        return;
    end

    local fromePer = fromValue/maxValue;
    local toPer = toValue/maxValue
    local step = (toPer-fromePer)/frame
    bar:unscheduleUpdate()
    self:setBarPer(barNodeName,fromePer);
    local function updatePer()
        if( bar.curPer>=toPer)then
            bar:unscheduleUpdate()
            bar.curPer = toPer;
            if(callback)then
                local num = self:getNode(barNumNodeName);
                if num then
                    num:unscheduleUpdate();
                end

                callback()
                return;
            end
        else
            bar.curPer = bar.curPer+step;
        end
        self:setBarPer(barNodeName,bar.curPer);
    end
    bar:scheduleUpdateWithPriorityLua(updatePer,1)


    local num = self:getNode(barNumNodeName);
    if num == nil then
        return;
    end
    num.curValue = fromValue;
    local numStep = math.ceil( (toValue - fromValue)/frame );

    num:unscheduleUpdate()
    local function updateNum()
        if( num.curValue>=toValue)then
            num:unscheduleUpdate()
            num.curValue = toValue;
        else
            num.curValue = num.curValue+numStep;
        end
        self:setLabelString(barNumNodeName,num.curValue.."/"..maxValue);
    end
    num:scheduleUpdateWithPriorityLua(updateNum,1)


end

function UILayer:setBarPer2(name,cur,max)
    local per = cur/max;
    if max < 0 then
        per = 1;
    end
    self:setBarPer(name,per);
end
function UILayer:setBarPer(name, per,mirror)
    if(per>1)then
        per=1
        -- elseif( per<0.07 and per~=0)then
        -- per=0.07
    end

    local bar=self:getNode(name)

    bar.curPer=per
    local newWidth = bar.oldWidth*per;
    --判断最小宽度
    if bar.minWidth then
        if newWidth < bar.minWidth then
            newWidth = bar.minWidth;
        end
    end
    if(per==0)then
        bar:setVisible(false)
    else
        bar:setVisible(true)
        bar:setContentSize(cc.size(newWidth ,bar.oldHeight))
        if(mirror)then
            bar:setPositionX( bar.oldX+(bar.oldWidth -newWidth)/2 )
        else
            bar:setPositionX( bar.oldX+(newWidth-bar.oldWidth )/2 )
        end
    end
end

function UILayer:setTouchEnable(name,able,gray)
    local node=self:getNode(name)
    if(node==nil)then
        return
    end

    node.__touchable=able
    if(gray~=nil)then
        DisplayUtil.setGray(node,gray)
    end
end

function UILayer:setTouchEnableGray(name,able)
    self:setTouchEnable(name,able,not able);
end

function UILayer:events()
    return {}
end

function UILayer:dealEvent(event,param)

end

function UILayer:setTouchCDTime(name,cdTime)
    local node = self:getNode(name);
    if node then
        node.cdTime = cdTime;
    end
end

function UILayer:addTouchNode(node,var,effect,sound,cdTime)
    if(node==nil) then
        return
    end
    if cdTime == nil then
        cdTime = 1.0;
    end
    -- print("cdTime = "..cdTime);
    node.__touchable=true
    node.touchLayer=self
    node.touchEffect=effect
    node.touchName=var
    node.sound = sound;
    node.touchTime = 0;
    node.cdTime = cdTime;
    self:setBtnCloseTouchOffsetForAndroid(var,node);
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end

function UILayer:removeTouchNode(var)
    local node = self:getNode(var);
    if(node)then
        local eventDispatcher = node:getEventDispatcher()
        eventDispatcher:removeEventListenersForTarget(node);
    end
end

function UILayer:addBreakTouchBg()
    local opcity_layer = Panel.createBlackBg()
    opcity_layer:setPosition(self:getContentSize().width/2,-self:getContentSize().height/2)
    self:addChild(opcity_layer,-2)
end

function UILayer:onClose()
    -- body
    Panel.popBack(self:getTag())
end

-- function UILayer:scheduleUpdateByAction(_callback,_interval,_repeatTime,_delay)
--     local interval = _interval or 0
--     local repeatTime = _repeatTime or 0
--     local delay  = _delay or 0
--     local delayAction = cc.DelayTime:create(delay)
--     local delayAction2 = cc.DelayTime:create(interval)
--     local scheduleAction = nil
--     if repeatTime >= math.pow(2,53) then
-- --        local sequence = 
--         scheduleAction = cc.Sequence:create(delayAction, cc.CallFunc:create(function()
--             cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
--                 print("coming the cc.RepeatForever:create")
--             end),delayAction2))
--         end))
--     else
--         local repeatAction = cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(_callback),delayAction2), repeatTime)
--         scheduleAction = cc.Sequence:create(delayAction, repeatAction)
--     end
--     scheduleAction:setTag(9999)
--     self:runAction(scheduleAction)
-- end

function UILayer:scheduleUpdate(_callback, _interval, _delay, _repeatTime, _pause)
    local scheduler = cc.Director:getInstance():getScheduler()
    if self.schedulerHandler ~= nil then
        scheduler:unscheduleScriptEntry(self.schedulerHandler)
        self.schedulerHandler = nil
    end

    local delay = _delay or 0
    local repeatTime = _repeatTime or -1
    local hasRepeatTimes = 0

    if(delay <= 0 and _callback)then
        _callback();
    end

    if  repeatTime <= -1 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(delay),cc.CallFunc:create(function()
            self.schedulerHandler = scheduler:scheduleScriptFunc(_callback,_interval,_pause)
        end )))
    else 
        self:runAction(cc.Sequence:create(cc.DelayTime:create(delay),cc.CallFunc:create(function()
            self.schedulerHandler = scheduler:scheduleScriptFunc(function(dt)
                if hasRepeatTimes < repeatTime then
                    _callback(dt)
                    hasRepeatTimes = hasRepeatTimes + 1
                else
                    scheduler:unscheduleScriptEntry(self.schedulerHandler)
                    self.schedulerHandler = nil
                end
            end,_interval,_pause)
        end)))
    end
end

function UILayer:unscheduleUpdateEx()
    if self.schedulerHandler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerHandler)
        self.schedulerHandler = nil
    end
end

function UILayer:setNodeTouchRectOffset(name,offset_width,offset_height)
    local node = self:getNode(name);
    self:setNodeTouchRectOffsetWithNode(node,offset_width,offset_height);
end

function UILayer:setNodeTouchRectOffsetWithNode(node,offset_width,offset_height)
    if(node)then
        node.offset_touchw = offset_width;
        node.offset_touchh = offset_height;
    end
end

function UILayer:showTouchRect()
    local rect = nil;
    local pos = nil;
    for key,node in pairs(self.vars) do
        if(node and node.__touchable)then
            rect = node:getBoundingBox();
            if(node.offset_touchw ~= nil)then
                rect.x = rect.x - node.offset_touchw;
                rect.width = rect.width + 2*node.offset_touchw;
            end
            if(node.offset_touchh ~= nil)then
                rect.y = rect.y - node.offset_touchh;
                rect.height = rect.height + 2*node.offset_touchh;
            end
            local worldPos = node:getParent():convertToWorldSpace(cc.p(rect.x,rect.y));
            pos = self:convertToNodeSpace(worldPos);
            local color = cc.LayerColor:create(cc.c4b(255,255,255,128),rect.width,rect.height);
            color:setPosition(pos);
            self:addChild(color,1000);
        end
    end
end

return UILayer;