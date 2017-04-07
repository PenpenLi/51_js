local PetTowerBoxOpenPanel=class("PetTowerBoxOpenPanel",UILayer)

function PetTowerBoxOpenPanel:ctor(items,boxType)
    loadFlaXml("ui_pet_tower_box");

    self:init("ui/ui_box_open.map")
    self.boxType = boxType;
    self.items = items;
    self.ani_nodes = {}
    local actName = {"ui-ssq-box-tong","ui-ssq-box-yin","ui-ssq-box-jin"};
    local fla=FlashAni.new();
    fla:playAction(actName[boxType],nil,nil,0);
    -- self:replaceNode("box",fla);
    self.box = self:getNode("box");
    self.box:setVisible(false);
    fla:setPosition(gGetPositionInDesNode(self,self.box));
    self:addChild(fla);
    self:getNode("layer_light"):setVisible(false);
    self:getNode("bg_content"):setVisible(false);


    -- local delayTime = fla:getActionTime() - 2;
    local delayTime = 2;
    self.bg_content = self:getNode("bg_content");
    self:getNode("layer_light"):runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.Show:create()));
    self:getNode("bg_content"):runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.Show:create()));
    local itemSpaceW = 150;
    local itemSpaceH = 150;
    local size = self.bg_content:getContentSize()
    local count = table.getn(self.items);
    local posX = size.width/2 - itemSpaceW*0.5*(count-1);
    local posY = size.height/2;
    if count > 5 then
        local row = math.floor((count-1) / 5);
        if row > 1 then
            offH = 50;
            itemSpaceH = 120;
        end
        posX = size.width/2 - itemSpaceW*0.5*(5-1);
        posY = size.height/2 + itemSpaceH*0.5*(row);  
    end

    for i,var in pairs(self.items) do
        local indexW = (i-1) % 5;
        local indexH = math.floor((i-1) / 5);
        print("indexW = "..indexW.." indexH = "..indexH);
        local node = DropItem.new();
        node:setData(var.id);
        node:setNum(var.num);
        local desPos = cc.p(posX+indexW*itemSpaceW,
            posY-indexH*itemSpaceH);
        local bgNode = cc.Node:create();
        node:setPosition(cc.p(-node:getContentSize().width/2,node:getContentSize().height/2));
        bgNode:addChild(node);

        bgNode:setPosition(self:getNode("box"):getPosition());
        bgNode:setVisible(false);
        bgNode:setScale(0);
        bgNode:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(delayTime+i*0.5),
                                    cc.ScaleTo:create(0,0.1),
                                    cc.Show:create(),
                                    cc.Spawn:create(
                                            cc.ScaleTo:create(0.2,1),
                                            cc.Repeat:create(cc.RotateBy:create(0.1,360),3),
                                            cc.MoveTo:create(0.2,desPos)
                                        ),
                                    cc.ScaleBy:create(0.1,1.5),
                                    cc.ScaleTo:create(0.1,1)
                                    )
                        );
        self.bg_content:addChild(bgNode,10);
        local icon = {}
        icon['pos'] = desPos
        icon['node'] = bgNode
        table.insert(self.ani_nodes,icon)
    end


    self.boxid = BOX_KEY_ID1 + (boxType - 1);
    local num=Data.getUserItemNumById(self.boxid);
    if num <= 0 then
        self:setTouchEnable("btn_again",false,true);
    end
end

function PetTowerBoxOpenPanel:quickShow()
    if (self.isQuickShow) then
        return
    end
    self.isQuickShow = true
    print ("quickShow~")
    for i,var in pairs(self.ani_nodes) do
        local node = var['node']
        node:stopAllActions()
        node:setVisible(true)
        node:setScale(1.0)
        node:setRotation(0)
        node:setPosition(var['pos'])
    end
end

function PetTowerBoxOpenPanel:onTouchEnded(target)
    print (target.touchName)
    if  target.touchName=="btn_ok"then
        Panel.popBack(self:getTag());
    elseif  target.touchName=="btn_again"then
        self.isQuickShow = false
        local num=Data.getUserItemNumById(self.boxid)
        if(num>10)then
            num=10
        end
        Net.sendUseItem(self.boxid,num);
        Panel.popBack(self:getTag());
    else
        self:quickShow()
    end
    
   
end

return PetTowerBoxOpenPanel