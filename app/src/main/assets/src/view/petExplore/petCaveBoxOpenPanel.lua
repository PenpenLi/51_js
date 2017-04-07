local PetCaveBoxOpenPanel=class("PetCaveBoxOpenPanel",UILayer)

function PetCaveBoxOpenPanel:ctor(id)
    loadFlaXml("ui_pet_tower_box");
    self:init("ui/ui_box_open.map")
    self.boxType = 1;
    self.ani_nodes = {}
    local actName = {"ui-ssq-box-jin"};
    local fla=FlashAni.new();
    fla:playAction(actName[1],nil,nil,0);
    -- self:replaceNode("box",fla);
    self.box = self:getNode("box");
    self.box:setVisible(false);
    fla:setPosition(gGetPositionInDesNode(self,self.box));
    self:addChild(fla);
    self:getNode("layer_light"):setVisible(false);
    self:getNode("bg_content"):setVisible(false);
    local delayTime = 2;
    self.bg_content = self:getNode("bg_content");
    local function callback ()
         Net.sendCaveEvent4Deal(id)
        Panel.popBack(self:getTag())
    end

    self:getNode("bg_content"):runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(callback)));
    
end

function PetCaveBoxOpenPanel:onTouchEnded(target)

end

return PetCaveBoxOpenPanel