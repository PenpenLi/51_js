local CrusadePanel=class("CrusadePanel",UILayer)

function CrusadePanel:ctor(data)
    self:init("ui/ui_crusade_panel.map")

    self.isMainLayerGoldShow=false
    self.isMainLayerCrusadeShow=true

    local winSize=cc.Director:getInstance():getWinSize()
    self:getNode("scroll"):resize(winSize)
    self:getNode("scroll"):setDir(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    self:setData(data)
    if(data.list)then
        local count = table.count(data.list);
        if(count > 0)then
            print("count = "..count);
            Unlock.checkFirstEnter(SYS_CRUSADE);
        end
    end
end

function CrusadePanel:setData(data)
    local winSize=cc.Director:getInstance():getWinSize()
    self:setLabelString("txt_exploits",data.exploits)
    self:setLabelString("txt_feats",data.feats)
    self:getNode("scroll"):clear()
    local num=0
    for key, value in pairs(data.list) do
        local item=CrusadeItem.new()
        item:setData(value)
        self:getNode("scroll"):addItem(item)
        num=num+1
    end
    Data.redpos.bolCrusadeNum=(  num~=0)
    self:getNode("empty_panel"):setVisible(num==0)

    for i=num,3 do
        local item=CrusadeItem.new()
        self:getNode("scroll"):addItem(item)
    end
    self:getNode("scroll"):layout()
    local blackFront=cc.LayerColor:create(cc.c4b(0,0,0,255),winSize.width/2,winSize.height);
    blackFront:setPositionX(-winSize.width/2+3)
    self:getNode("scroll").container:addChild(blackFront,-1)

    local blackBack=cc.LayerColor:create(cc.c4b(0,0,0,255),winSize.width/2,winSize.height);
    blackBack:setPositionX(self:getNode("scroll").container:getContentSize().width)
    self:getNode("scroll").container:addChild(blackBack )

    local itemWidth=self:getNode("scroll").itemWidth
    self:getNode("scroll").container:setPositionX( (winSize.width-itemWidth*3)/2)
end

function CrusadePanel:onPopup()

    if self.needRfresh then 
        Net.sendCrusadeInfo()
    end

end

-- 窗体被压入堆栈时调用
function CrusadePanel:onPushStack()
    -- body
    self.needRfresh = true;
end




function  CrusadePanel:events()
    return {EVENT_ID_CRUSADE_SHARE,EVENT_ID_CRUSADE_SHOP_BUY,EVENT_ID_REFRESH_CRUSADE}
end



function CrusadePanel:dealEvent(event,param)
    if(event==EVENT_ID_REFRESH_CRUSADE)then
        self:setData(param)
    elseif(event==EVENT_ID_CRUSADE_SHARE)then
        for key, item in pairs(self:getNode("scroll").items) do
            if(item.curData and item.curData.id==param)then
                item.curData.share=true
                item:setData(item.curData)
            end
        end
    elseif event==EVENT_ID_CRUSADE_SHOP_BUY then
        self:setLabelString("txt_exploits",gCrusadeData.exploits)
    end
end



function CrusadePanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName == "btn_rule" then
        gShowRulePanel(SYS_CRUSADE);
    elseif  target.touchName=="btn_exploits"then
        Panel.popUp(PANEL_CRUSADE_SHOP) 
        Net.sendCrusadeInfoCallbackBreak=true
    elseif  target.touchName=="btn_feats"then
        Net.sendCrusadeFeats()
    elseif  target.touchName=="btn_call"then
        Net.sendCrusadeCallInfo()
    end

end


return CrusadePanel