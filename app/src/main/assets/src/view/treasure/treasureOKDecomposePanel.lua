local TreasureOKDecomposePanel=class("TreasureOKDecomposePanel",UILayer)

function TreasureOKDecomposePanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true;
    self.hideMainLayerInfo = true;
    self:init("ui/ui_treasure_reward.map")
 
    self:getNode("scroll").eachLineNum=5
    self:getNode("scroll").offsetX=19.4
    self:getNode("scroll").offsetY=18
    self:getNode("scroll").padding=5
    self:getNode("scroll").itemScale=0.95
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self.curData = data

    Net.sendTreasureOkdcForsee(data)

    
end

function TreasureOKDecomposePanel:events()
    return {EVENT_ID_OKDCFORSEE}
end


function TreasureOKDecomposePanel:dealEvent(event,param)
    if event==EVENT_ID_OKDCFORSEE then
        for i,var in pairs(param) do 
            local node = DropItem.new(true);
            node:setData(var.id);
            node:setNum(var.num); 
            self:getNode("scroll"):addItem(node);
        end
       self:getNode("scroll"):layout()
    end
end

function TreasureOKDecomposePanel:onTouchEnded(target,touch)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag()) 
       
    elseif  target.touchName=="btn_get"then

        local listItems = {}
        for k,data in pairs(self.curData) do
            table.insert(listItems,data.id)
        end
        Net.sendTreasureOkDecompose(listItems)

        Panel.popBack(self:getTag()) 

    end
end


return TreasureOKDecomposePanel