local CrusadeNewPanel=class("CrusadeNewPanel",UILayer)

function CrusadeNewPanel:ctor(data) 
    self.isWindow = true;
    self.hideMainLayerInfo=true
    self:init("ui/ui_crusade_sweep.map")

    local color=gGetItemQualityColor(data.quality)
    color=gParseRgbNum(color.r,color.g,color.b)
    local word=gGetWords("labelWords.plist","find_crucash",color,data.name,data.level) 
    self:setRTFString("txt_info",word) 
    self:getNode("icon"):playAction("ui_crusade_effect",nil ,nil ,0)
    local role = gCreateFlaDislpay("r"..data.cid.."_wait",0,"r"..data.cid.."_wait");  
    self:getNode("icon"):replaceBoneWithNode({"ship","ship","npc" },role);
end



function CrusadeNewPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        if (TalkingDataGA) then
            gLogEvent("rebel.close")
        end
    elseif  target.touchName=="btn_enter"then 
        Panel.popBack(self:getTag()) 
        Net.sendCrusadeInfo()
        if (TalkingDataGA) then
            gLogEvent("rebel.fight")
        end
    end

end
return CrusadeNewPanel