local TowerDiffPanel=class("TowerDiffPanel",UILayer) 
function TowerDiffPanel:ctor(floor)

    self.appearType = 1;
    self:init("ui/ui_tower_diff.map");
    self.isMainLayerMenuShow = false;
  
    local db=DB.getTowerData(floor+1)
    
    if(db==nil)then 
        return
    end
    for i=1, 3 do
        self:setLabelString("txt_power"..i,db["price"..i]) 
        self:setLabelString("txt_dia"..i, db.ratio*i) 
    end
    self:resetLayOut()
end
 
function TowerDiffPanel:onTouchEnded(target) 
    if target.touchName == "btn_close" then
        Panel.popBack(self:getTag())
        
    elseif target.touchName == "btn_fight1" then
        Data.towerInfo.diff=1
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_TOWER);
    elseif target.touchName == "btn_fight2" then
        Data.towerInfo.diff=2
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_TOWER);
    elseif target.touchName == "btn_fight3" then 
        Data.towerInfo.diff=3
        Panel.popUp(PANEL_ATLAS_FORMATION,TEAM_TYPE_TOWER);
    end

end 
 

return TowerDiffPanel