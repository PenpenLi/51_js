local WeaponEquipSoulItem=class("WeaponEquipSoulItem",UILayer)

function WeaponEquipSoulItem:ctor()
    self.curSelectNum=0
    self.addRaise=0
    self.curSelectItemid=0
end

function WeaponEquipSoulItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_weapon_item.map")
    self:getNode("icon_reomove").__touchend=true
    self:getNode("icon_add").__touchend=true
end


function WeaponEquipSoulItem:onTouchBegan(target)
    self.isMoved=false
    self.curDt=0
    self.curAddSpeed=0.5
    self.curRemoveSpeed=0.5
    local function updateAddSelect(dt)
        self.curDt=self.curDt+dt
        if(self.curDt>self.curAddSpeed)then
            self.curDt=self.curDt-self.curAddSpeed
            self:changeSelectNum(1)
            self.curAddSpeed=self.curAddSpeed-0.09
            if(self.curAddSpeed<0.05)then
                self.curAddSpeed=0.05
            end
        end
    end
    local function updateRemoveSelect(dt)
        self.curDt=self.curDt+dt
        
        if(self.curDt>self.curRemoveSpeed)then
            self.curDt=self.curDt-self.curRemoveSpeed
            self:changeSelectNum(-1)
            self.curRemoveSpeed=self.curRemoveSpeed-0.09
            if(self.curRemoveSpeed<0.05)then
                self.curRemoveSpeed=0.05
            end
        end
    end

    

    if(target.touchName=="icon_reomove")then  
        self:scheduleUpdateWithPriorityLua(updateRemoveSelect,1)
        
    elseif(target.touchName=="icon_add")then
 
        self:scheduleUpdateWithPriorityLua(updateAddSelect,1)
    end
end

function WeaponEquipSoulItem:onTouchMoved(target,touch)

    local offsetX=touch:getDelta().x;
    local offsetY=touch:getDelta().y;
    if(math.sqrt(offsetX*offsetX+offsetY*offsetY)>5)then
        self.isMoved=true 
    end
    if(target.touchName=="icon_reomove")then 
        if(self.isMoved)then 
            self:unscheduleUpdate()
        end
    elseif(target.touchName=="icon_add")then 
        if(self.isMoved)then 
            self:unscheduleUpdate()
        end
    end
end

function WeaponEquipSoulItem:setUnSelect()
    self.curSelectNum=0
    self:refreshSelect()
end

function WeaponEquipSoulItem:setRemainNum(num) 
    self.curSelectNum=self.curData.num-num
    if(self.curSelectNum<0)then
        self.curSelectNum=0
    end
    self:refreshSelect()
end

function WeaponEquipSoulItem:changeSelectNum(num)
    self.curSelectNum=self.curSelectNum+num
    if(self.curSelectNum>=self.curData.num)then
         self.curSelectNum=self.curData.num
    end
    if(self.curSelectNum<0)then
        self.curSelectNum=0
    end
    self:refreshSelect()
    if(self.selectItemCallback)then
        self.selectItemCallback()
    end
end

function WeaponEquipSoulItem:onTouchEnded(target)
    if(target.touchName=="icon_reomove")then
        if(self.isMoved==false)then
            self:changeSelectNum(-1)
        end
    elseif(target.touchName=="icon_add")then 
        if(self.isMoved==false)then
            self:changeSelectNum(1)
        end
    end
    self:unscheduleUpdate()

end
function  WeaponEquipSoulItem:setDataLazyCalled()
    self:setData(self.lazyData,self.lazyTagType)
    self:refreshSelect()
end

function  WeaponEquipSoulItem:setLazyData(data,tagType)
    self.lazyData=data
    self.curData=data
    self.lazyTagType=tagType
    local qua=DB.getItemQuality(data.itemid) 
    local baseQua,detailQua = Icon.convertItemDetailQuality(qua+1);
    self.qua=baseQua 
    Scene.addLazyFunc(self,self.setDataLazyCalled,"equipSoul")
end

function WeaponEquipSoulItem:refreshSelect()
    if(self.inited==true)then  
        self:setLabelString("txt_num",self.curSelectNum.."/"..self.curData.num)
        if(self.curSelectNum==0)then
            self:getNode("icon_reomove"):setVisible(false)
        else
            self:getNode("icon_reomove"):setVisible(true)
        end
    end
end

function   WeaponEquipSoulItem:setData(data,tagType)
    self:initPanel()
    self.curData=data
    local qua=DB.getItemQuality(data.itemid) 
    local baseQua,detailQua = Icon.convertItemDetailQuality(qua+1);
    self.qua=baseQua 
    local db=data._db
    if(data.itemid==nil)then
        return
    end 
    self.addRaise=0

    if(db)then
        self.addRaise=db.equsoul
    end
    local itemid=data.itemid
    if(tagType==5)then
        itemid=itemid+ITEM_TYPE_SHARED_PRE

        if(db and db.com_num~=0)then
            self.addRaise=db.equsoul/db.com_num
        end
    end

    self.curSelectItemid=itemid
    Icon.setIcon(itemid,self:getNode("icon"),qua)
    self:refreshSelect()

end



return WeaponEquipSoulItem