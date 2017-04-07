local CrusadeCallFlaPanel=class("CrusadeCallFlaPanel",UILayer)

function CrusadeCallFlaPanel:ctor(data)
    self.appearType = 1;
    self.isWindow = true; -- false会关闭父窗体
    self.isMainLayerGoldShow=false
    self.isMainLayerCrusadeShow=true
    self.isBlackBgVisibleForce=false
    self:init("ui/ui_crusade_call_fla.map")
    self.curData=data
    self:addFullScreenTouchToClose()
end

function CrusadeCallFlaPanel:onPopup()
    self:setCrusade(self.curData)
    --设置定时关闭
    self:schedule()
end

function CrusadeCallFlaPanel:schedule()
    local callback = function()
        Panel.popBack(self:getTag());
    end
    local delay = cc.DelayTime:create(3)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    self:runAction(sequence)
end

function CrusadeCallFlaPanel:setCrusade(data)
    loadFlaXml("ui_crusade")
    local color=gGetItemQualityColor(data.quality)
    color=gParseRgbNum(color.r,color.g,color.b)
    data.name = gGetMonsterName(data.mid,data.name)
    local word=gGetWords("labelWords.plist","find_crucash2",color,data.name,data.level)
    self:setRTFString("txt_info",word)
    local fla=FlashAni.new()
    fla:playAction("ui_crusade_effect",nil ,nil ,0)
    local role = gCreateFlaDislpay("r"..data.cid.."_wait",0,"r"..data.cid.."_wait");
    fla:replaceBoneWithNode({"ship","ship","npc" },role);
    gAddCenter(fla, self:getNode("crusade_effect"))
    self:getNode("crusade_effect"):setScale(0)
    self:getNode("crusade_effect"):runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,1)))
end

function CrusadeCallFlaPanel:onTouchEnded(target) 
    if(target.touchName=="full_close")then 
        Panel.popBack(self:getTag());
    end

end

return CrusadeCallFlaPanel