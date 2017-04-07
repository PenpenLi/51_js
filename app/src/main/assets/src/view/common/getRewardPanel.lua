local GetRewardPanel=class("GetRewardPanel",UILayer)

function GetRewardPanel:ctor(data,needName)
    self.appearType = 1;
    self:init("ui/ui_notice_lingqu.map")
    self._panelTop=true
    self.ignoreGuide = true;
    needName = true;
    
    self.bg_content = self:getNode("bg_content");
    local itemSpaceW = 150;
    local itemSpaceH = 150;
    local size = self.bg_content:getContentSize()
    local count = table.getn(data.items);
    if count > 3 then
        local offW = 200;
        size.width = size.width + offW;
        self.bg_content:setContentSize(size.width,size.height);
        self.line_up = self:getNode("line_up");
        local scaleX = self.line_up:getScaleX();
        self.line_up:setScaleX(scaleX + offW/self.line_up:getContentSize().width);
        -- self.line_up:setContentSize(self.line_up:getContentSize().width + offW,
                                    -- self.line_up:getContentSize().height);
        self.line_down = self:getNode("line_down");
        self.line_down:setScaleX(scaleX + offW/self.line_down:getContentSize().width);
        -- self.line_down:setContentSize(self.line_down:getContentSize().width + offW,
                                    -- self.line_down:getContentSize().height);
    end
    local posX = size.width/2 - itemSpaceW*0.5*(count-1);
    local posY = size.height/2;
    local offH = 100;
    if count > 5 then
        local row = math.floor((count-1) / 5);
        if row > 1 then
            offH = 50;
            itemSpaceH = 120;
        end
        if row > 2 then
            row = 2;
        end
        offH = row * offH;
        size.height = size.height + offH;
        self.bg_content:setContentSize(size.width,size.height);
        posX = size.width/2 - itemSpaceW*0.5*(5-1);
        posY = size.height/2 + itemSpaceH*0.5*(row);  
        self:getNode("up"):setPositionY(self:getNode("up"):getPositionY() + offH/2);
        self:getNode("down"):setPositionY(self:getNode("down"):getPositionY() - offH/2);
        self:getNode("bg_btn"):setPositionY(self:getNode("bg_btn"):getPositionY() - offH/2);
    end


    if(count>10)then
        self:getNode("scroll").eachLineNum=5
        self:getNode("scroll").offsetX=20
        self:getNode("scroll").offsetY=20
        self:getNode("scroll").padding=5
        self:getNode("scroll"):resize(cc.size(self:getNode("scroll"):getContentSize().width,
            self:getNode("scroll"):getContentSize().height+offH))
        self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)
        for i,var in pairs(data.items) do 
            local node = DropItem.new(needName);
            node:setData(var.id);
            node:setNum(var.num); 
            self:getNode("scroll"):addItem(node);
        end
         self:getNode("scroll"):layout()
    else
        for i,var in pairs(data.items) do
            local indexW = (i-1) % 5;
            local indexH = math.floor((i-1) / 5);
            print("indexW = "..indexW.." indexH = "..indexH);
            local node = DropItem.new(needName);
            node:setData(var.id);
            node:setNum(var.num);
            node:setPosition(cc.p(posX+indexW*itemSpaceW-node:getContentSize().width/2,
                posY-indexH*itemSpaceH+node:getContentSize().height/2));
            self.bg_content:addChild(node);
        end
    end
  

    -- self.panel=panel
    -- self:getNode("scroll").eachLineNum=4
    -- self:getNode("scroll").offsetY=0
    -- self:getNode("scroll").offsetX=0
    -- self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    -- for key, item in pairs(data.items) do
    	 
    --     local node=DropItem.new()
    --     node:setData(item.id)
    --     node:setNum(item.num)  
    --     self:getNode("scroll"):addItem(node)
    -- end
    
    -- self:getNode("scroll"):layout()
end


function GetRewardPanel:onTouchEnded(target)

    if  target.touchName=="btn_ok"then
        Panel.popBack(self:getTag()) 
    end
end

return GetRewardPanel