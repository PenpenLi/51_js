local WeaponRaiseItem=class("WeaponRaiseItem",UILayer)

function WeaponRaiseItem:ctor()

    
end

function WeaponRaiseItem:initPanel() 
    if(self.inited==true)then
        return 
    end 
    self.inited=true
    self:init("ui/ui_weapon_raise_item.map")
end


function  WeaponRaiseItem:setDataLazyCalled()
    self:setData(self.lazyData)
end

function  WeaponRaiseItem:setLazyData(data)
    self.curData=data
    self.lazyData=data
    Scene.addLazyFunc(self,self.setDataLazyCalled,"raise")
end


function WeaponRaiseItem:setData(data)
    self:initPanel() 
    self.curData=data 
    self:setLabelString("txt_level",data.level)
    CardPro:showStar(self,data.grade,data.awakeLv,-10); 
    Icon.setIcon(data.cardid,self:getNode("icon"),data.quality,data.awakeLv);
end


function WeaponRaiseItem:onTouchEnded(target)
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData,self)
    end
end
 
return WeaponRaiseItem