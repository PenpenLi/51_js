-- 可翻牌副本列表 item
local AtlasEliteFlopTabItem=class("AtlasEliteFlopTabItem",UILayer)

function AtlasEliteFlopTabItem:ctor()
    self:init("ui/ui_atlas_fanpai_info_item.map")
    self.touch = false
end

function AtlasEliteFlopTabItem:onTouchEnded(target)
    if target.touchName=="btn_get" then
        -- 前往翻牌
        CoreAtlas.EliteFlop.mid = self.itemdata.mid
        CoreAtlas.EliteFlop.sid = self.itemdata.sid
        Panel.popUpUnVisible(PANEL_ATLAS_ELITE_FLOP,nil,nil,true)
    elseif target.touchName=="btn_goto" then
        -- 前往副本
        Panel.popUp(PANEL_ATLAS_ENTER,{mapid=self.itemdata.mid,stageid=self.itemdata.sid,type=1})
    end
    
end

return AtlasEliteFlopTabItem
