local VipPanel=class("VipPanel",UILayer)

function VipPanel:ctor(type)

    self:init("ui/ui_vip.map")


    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self:getNode("scroll").touchBeganCallback=function (touch, event)
        return self:onMoveBegan(touch, event)
    end
    self:getNode("scroll").touchMovedCallback=function (touch, event)
        return self:onMoved(touch, event)
    end
    self:getNode("scroll").touchEndedCallback=function (touch, event)
        self:onMoveEnd(touch, event)
    end
    self:getNode("scroll").scroll:setPopBack(false)

    self:refreshData();


    for key, var in pairs(vip_db) do
        -- if(key>1)then
            local item=VipItem.new()
            if key == Data.getCurVip()+1 then
                item:setData(var)
            else
                item:setLazyData(var);
            end
            self:getNode("scroll"):addItem(item)
        -- end
    end

    self.lastShowIdx=Data.getCurVip()
    self.curShowIdx=Data.getCurVip()
    self:setLabelString("txt_cur_vip","vip"..self.curShowIdx)
    local itemWidth=self:getNode("scroll").itemWidth
    local offsetX=self:getNode("scroll").offsetX
    -- self:getNode("scroll").container:setPositionX(-(offsetX+itemWidth)*self.lastShowIdx )

    self:getNode("scroll"):layout()
    -- self:getNode("scroll"):moveItemByIndex(self.curShowIdx);
    self:getNode("scroll").container:setPositionX(-(offsetX+itemWidth)*self.lastShowIdx )

    if(table.getn(gGiftBagBuy)==0)then
        Net.sendGiftInit()
    else
        self:initGift()
    end
end

function VipPanel:onPopback()
    Scene.clearLazyFunc("vipItem")
end

function VipPanel:createVipNode(vip)
    local node = cc.Node:create();
    local uilayer = UILayer.new();
    uilayer:init("ui/ui_pay_vip.map");  
    uilayer.isBlackBgVisible = false
    uilayer.bgVisible =false
    uilayer:setLabelAtlas("txt_vip",vip);
    uilayer:setAnchorPoint(cc.p(0,-1));
    node:addChild(uilayer);
    node:setContentSize(uilayer:getContentSize());
    return node;
end
function VipPanel:refreshData()

    local vipDatas=DB.getVipCharge()

    local vip=Data.getCurVip()
    local isFull=false
    if(vip>=15)then
        vip=14
        isFull=true
    end

    local vipCharge=vipDatas[vip+2] 
    if(vipCharge)then
        local per= gUserInfo.vipsc/vipCharge
        self:setBarPer("bar",per)
        self:setLabelString("txt_per", gUserInfo.vipsc.."/"..vipCharge)

        if isFull then
            local word = gGetWords("vipWords.plist","vipTip3");
            local words = string.split(word,"@");
            local rtf = self:getNode("rtf");
            rtf:clear();
            rtf:addWord(words[1]);
            rtf:addNode(self:createVipNode(Data.getCurVip()));
            rtf:addWord(words[2]);

        else
            local needDia = vipCharge-gUserInfo.vipsc;
            local word = gGetWords("vipWords.plist","vipTip2");
            local words = string.split(word,"@");
            local rtf = self:getNode("rtf");
            rtf:clear();
            rtf:addWord(words[1]);
            rtf:addNode(self:createVipNode(Data.getCurVip()));
            rtf:addWord(words[2]);
            rtf:addImage("images/ui_public1/gold.png",0.4);
            rtf:addWord(needDia,nil,20,cc.c3b(255,255,255));
            rtf:addWord(words[3]);
            rtf:addNode(self:createVipNode(Data.getCurVip()+1));
            rtf:layout();
        end
    end
end

function  VipPanel:initGift()
    for key, item in pairs(self:getNode("scroll").items) do
    	item:setBuyNum()
    end
end


function  VipPanel:events()
    return {EVENT_ID_GIFT_BAG_GOT,
            EVENT_ID_GIFT_GIFT_INIT}
end


function VipPanel:dealEvent(event,param)
    if(event==EVENT_ID_GIFT_BAG_GOT or event == EVENT_ID_GIFT_GIFT_INIT)then
        self:initGift()
    end
end


function  VipPanel:onMoveBegan(touch, event)
    self.preLocation = touch:getLocation()
    return true
end

function  VipPanel:onMoved(touch, event)

end

function  VipPanel:onMoveEnd(touch, event)
    local endLocation = touch:getLocation()
    if(math.abs( endLocation.x-self.preLocation.x)>150)then

        if(endLocation.x>self.preLocation.x)then
            self.lastShowIdx=self.lastShowIdx-1
        else
            self.lastShowIdx=self.lastShowIdx+1
        end
    end

    self:onShowIndx()

end

function VipPanel:onShowIndx()
    --
    if(self.lastShowIdx<0) then
        self.lastShowIdx=0
    end

    if(self.lastShowIdx>= table.getn(self:getNode("scroll").items)) then
        self.lastShowIdx=table.getn(self:getNode("scroll").items)-1
    end

    self:getNode("scroll").container:stopAllActions()
    local itemWidth=self:getNode("scroll").itemWidth
    local offsetX=self:getNode("scroll").offsetX
    local function  onMoveEnd()
        self:getNode("scroll"):stopCheckChildrenVisibleUpdate();
    end
    local funcAction=cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(onMoveEnd))
    if( self.curShowIdx~=self.lastShowIdx)then
        self.curShowIdx=self.lastShowIdx
        local moveAction =cc.EaseBackOut:create(cc.MoveTo:create(0.5,cc.p(-(offsetX+itemWidth)*self.lastShowIdx,0)))
        self:getNode("scroll").container:runAction( cc.Spawn:create(moveAction,funcAction))

        self:setLabelString("txt_cur_vip","vip"..self.curShowIdx)
    else
        local moveAction=cc.EaseBackOut:create(   cc.MoveTo:create(0.5,cc.p(-(offsetX+itemWidth)*self.lastShowIdx,0)))
        self:getNode("scroll").container:runAction(  cc.Spawn:create(moveAction,funcAction))
    end
    self:getNode("scroll"):startCheckChildrenVisibleUpdate();
end

function VipPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_pre" then

        self.lastShowIdx=self.lastShowIdx-1
        self:onShowIndx()
    elseif  target.touchName=="btn_next" then
        self.lastShowIdx=self.lastShowIdx+1
        self:onShowIndx()
    elseif  target.touchName=="btn_pay"then
        local needRefresh = TaskPanelData.bNeedRefresh;
        TaskPanelData.bNeedRefresh = false;
        Panel.popBack(self:getTag(),nil,nil,false)
        Panel.popUp(PANEL_PAY)
        TaskPanelData.bNeedRefresh = needRefresh;
    end
end

return VipPanel