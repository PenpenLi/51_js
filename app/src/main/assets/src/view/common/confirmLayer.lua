local ConfirmLayer=class("ConfirmLayer",UILayer)

CONFIRM_TYPE_CONFIRM        = 0 --确定
CONFIRM_TYPE_CONFIRM_CANCEL = 1 --确定&取消
CONFIRM_TYPE_CONFIRM_CLOSE  = 2 --确定&关闭
CONFIRM_TYPE_ALL            = 3 --确定&取消&关闭

CONFIRM_CHILD_TAG  = 99
function gCreateBg()
    local blackBg = UILayer.new();
    blackBg:init("ui/ui_confirm_bg.map");
    blackBg:ignoreAnchorPointForPosition(false);
    blackBg:setAnchorPoint(cc.p(0.5,-0.5));
    local winSize=cc.Director:getInstance():getWinSize();
    blackBg:setPosition((winSize.width)/2,(winSize.height)/2);
    return blackBg;    
end

function ConfirmLayer:ctor(type,swap)
    self.appearType = 1;
    self._panelTop = true;
    self:init("ui/ui_confirm.map")
    self.ignoreGuide = true; 
    
    -- self:addBreakTouchBg();
    -- local opcity_layer =  Panel.createBlackBg()
    -- opcity_layer:setPosition(self:getContentSize().width/2,-self:getContentSize().height/2)
    -- self:addChild(opcity_layer,-2)

    self:ignoreAnchorPointForPosition(false);
    self:setAnchorPoint(cc.p(0.5,-0.5));
    local winSize=cc.Director:getInstance():getWinSize();
    self:setPosition((winSize.width)/2,(winSize.height)/2);
    -- self:setPosition((winSize.width - self.mapW)/2,winSize.height - (winSize.height - self.mapH)/2)

    self.btn_close = self:getNode("btn_close")
    self.layer_btn_one = self:getNode("layer_btn_one")
    self.layer_btn_two = self:getNode("layer_btn_two")
    self.bg = self:getNode("bg")
    self.bg_content = self:getNode("bg_content")
    self.layer_title = self:getNode("layer_title")
    self.lab_title = tolua.cast(self:getNode("lab_title"),"cc.Label")
    self.title_falg_left = self:getNode("title_flag_left")
    self.title_falg_right = self:getNode("title_flag_right")
    self.min_width = self.bg_content:getContentSize().width
    self.max_width = self.min_width + 200
    self.min_height = self.bg_content:getContentSize().height
    self.max_height = winSize.height - 100 - (self.bg:getContentSize().height - self.bg_content:getContentSize().height)
    
    swap = swap or false
    self.type = type
    if self.type == nil then
        self.type = CONFIRM_TYPE_CONFIRM
    end
    
    if self.type == CONFIRM_TYPE_CONFIRM then
        self.layer_btn_one:setVisible(true)
        self.layer_btn_two:setVisible(false)
        self.btn_close:setVisible(false)
    elseif self.type == CONFIRM_TYPE_CONFIRM_CANCEL then
        self.layer_btn_one:setVisible(false)
        self.layer_btn_two:setVisible(true)
        self.btn_close:setVisible(false)
    elseif self.type == CONFIRM_TYPE_CONFIRM_CLOSE then
        self.layer_btn_one:setVisible(true)
        self.layer_btn_two:setVisible(false)
        self.btn_close:setVisible(true)
    elseif self.type == CONFIRM_TYPE_ALL then
        self.layer_btn_one:setVisible(false)
        self.layer_btn_two:setVisible(true)
        self.btn_close:setVisible(true)
    end
    
    if swap == true then
        if self.type == CONFIRM_TYPE_ALL or self.type == CONFIRM_TYPE_CONFIRM_CANCEL then
            local confPoint =cc.p(self:getNode("two_layer_confirm"):getPosition())
            local cancelPoint =cc.p(self:getNode("two_layer_cancel"):getPosition())
            self:getNode("two_layer_cancel"):setPosition(confPoint.x+40, cancelPoint.y)
            self:getNode("two_layer_confirm"):setPosition(cancelPoint.x-40, confPoint.y)
        end
    end
    self.func_close = nil
    self.func_confirm = nil
    self.func_cancel = nil
end

function ConfirmLayer:showContent(title,content)
    
    --title
    if(string.len(title) == 0) then
        self.layer_title:setVisible(false)
        self.bg_content:setPositionY(self.bg_content:getPositionY() + 20)
    else
--        print("title"..title)
        local old_title_size = self.lab_title:getContentSize()
        self.lab_title:setString(title)
        local new_title_size = self.lab_title:getContentSize()
        local offsetX = (new_title_size.width - old_title_size.width)/2
        
        self.title_falg_left:setPositionX(self.title_falg_left:getPositionX() - offsetX)
        self.title_falg_right:setPositionX(self.title_falg_right:getPositionX() + offsetX)
    end
    
    
    --content
    if(string.len(content) == 0) then
        return
    end

    local lab_content = nil;
    if string.find(content,"\\") then
        lab_content = RTFLayer.new(self.min_width);
        lab_content:setDefaultConfig(gFont,20,cc.c3b(255,255,255));
        lab_content:setString(content);
        lab_content:layout();
    else
        lab_content = gCreateWordLabelTTF(content,gFont,20,cc.c3b(255,255,255),cc.size(self.min_width,0))
    end
    
    --change size
    if(lab_content:getContentSize().height > self.max_height) then
        lab_content:setWidth(self.max_width)
    end
    self:changeContentSize(lab_content:getContentSize())
    gAddChildInCenterPos(self.bg_content,lab_content)
    
    
    -- local curScene = cc.Director:getInstance():getRunningScene()
    gConfirmLayer:addChild(self,0,CONFIRM_CHILD_TAG)
    gConfirmLayer:setVisible(true);
end

function ConfirmLayer:changeContentSize(newsize)
--    if(newsize.height <= self.min_height) then
--        return
--    end
    
    local offsetX = newsize.width - self.min_width
    local offsetY = newsize.height - self.min_height
    
    if offsetX <= 0 and offsetY <= 0 then
        print("no need change size")
        return
    end

    local old_bg_size = self.bg:getContentSize()
    self.bg:setContentSize(cc.size(old_bg_size.width+offsetX,old_bg_size.height+offsetY))
    
    local old_content_size = self.bg_content:getContentSize()
    self.bg_content:setContentSize(cc.size(old_content_size.width+offsetX,old_content_size.height+offsetY))

    local newpos = cc.pAdd(cc.p(self.btn_close:getPosition()),cc.p(offsetX/2,offsetY/2))
    self.btn_close:setPosition(newpos)
    self.layer_title:setPosition(cc.pAdd(cc.p(self.layer_title:getPosition()),cc.p(0,offsetY/2)))
    
    self.layer_btn_one:setPosition(cc.pAdd(cc.p(self.layer_btn_one:getPosition()),cc.p(0,-offsetY/2)))
    self.layer_btn_two:setPosition(cc.pAdd(cc.p(self.layer_btn_two:getPosition()),cc.p(0,-offsetY/2)))
    
end

function ConfirmLayer:setCloseFunction(close_func)
    self.func_close = close_func
end

function ConfirmLayer:setConfirmFunction(confirm_func)
    self.func_confirm = confirm_func
end

function ConfirmLayer:setCancelFunction(cancel_func)
    self.func_cancel = cancel_func
end


function ConfirmLayer:onTouchEnded(target)

    local var = target.touchName
    if var=="btn_close" then
        if self.func_close ~= nil then
            self.func_close()
        end

        self:onClose()
        
    elseif var == "one_btn_confirm" or var == "two_btn_confirm" then
        if self.func_confirm ~= nil then
            self.func_confirm()
        end
            
        self:onClose()
    elseif var == "two_btn_cancel" then
        if self.func_cancel ~= nil then
            self.func_cancel()
        end    
        
        self:onClose()
    end
    
end

function ConfirmLayer:onClose()
    local callback = function()
        if(gConfirmLayer:getChildrenCount() == 1) then
            gConfirmLayer:setVisible(false);
        end
    end
    self:onDisappear(callback);
    -- self:removeFromParent()
    
end

return ConfirmLayer
