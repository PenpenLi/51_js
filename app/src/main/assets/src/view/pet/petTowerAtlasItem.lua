local PetTowerAtlasItem=class("PetTowerAtlasItem",UILayer)

function PetTowerAtlasItem:ctor(idx)
    
end

function PetTowerAtlasItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_pet_tower_atlas_item.map")
     for i=1, 4 do
            self:getNode("power_effect"..i):setVisible(false) 
    end
end


function PetTowerAtlasItem:onTouchEnded(target)
    local id= toint(string.sub( target.touchName,11,string.len(target.touchName))) 
    if(self["monster"..id]   and self.curStages[id])then
        if(self.onSelectCallback)then 
            self.onSelectCallback(toint(self:getNode("txt_info"..id):getString()))
        end
    end

end
function PetTowerAtlasItem:clearMonster(idx)
    if(self.inited~=true)then
        return
    end 
    if(idx==nil)then
        idx=4
    end
    
    for i=1, idx do
        if(self["monster"..i])then
            self["monster"..i]:setVisible(false) 
        end
    end
end

function PetTowerAtlasItem:resetMonster()

    if(self.inited~=true)then
        return
    end 
    for i=1, 4 do
        if(self["monster"..i])then
            self["monster"..i]:setVisible(true) 
        end
    end
end

function PetTowerAtlasItem:setLazyData()   
    if(self.inited==true)then
        return
    end 
    Scene.addLazyFunc(self,self.setData,"pettower") 
end

function PetTowerAtlasItem:setData() 
    local stages =self.curStages
    self:initPanel()
    for i=1, 4 do
        if(stages[i])then
            self:setLabelString("txt_info"..i,stages[i].map_id) 
            if(stages[i].map_id%5==0)then 
                self:getNode("power_effect"..i):setVisible(true) 
            end
            local monsters= string.split(stages[i].team_monster,";")  
            local monster=DB.getMonsterById(toint(monsters[1]))
            if(monster==nil)then
                return nil
            end 
            local role= gCreateRoleFla(monster.cardid, self:getNode("econtainer"..i),0.6,nil,nil,monster.weapon_lv,monster.waken)
            self["monster"..i]=role
        else
            self:setLabelString("txt_info"..i,"") 
         
        end
    end
    print("===")
end

return PetTowerAtlasItem