local PetItem=class("PetItem",UILayer)

function PetItem:ctor()
    self:init("ui/ui_pet_item.map")
    
    self:getNode("star_container"):setVisible(false)
    self:setLabelString("txt_level","")
    self.starContainerX= self:getNode("star_container"):getPositionX()
    self:unSelect();
end


function PetItem:select()
    if(self.isSelected)then
        return
    end
    self:getNode("choose_icon"):setVisible(true)
    self.isSelected=true
    self:getNode("root"):setPosition(cc.p(0,0))
    local moveAction=cc.EaseBackOut:create(   cc.MoveTo:create(0.3,cc.p(25,0)))
    self:getNode("root"):runAction( moveAction)
end


function PetItem:unSelect()
    if(self.isSelected==false)then
        return
    end
    self:getNode("choose_icon"):setVisible(false)
    self.isSelected=false
    self:getNode("root"):setPosition(cc.p(0,0))
end

function PetItem:onSelect()
    if(self.selectItemCallback)then
        if(self.curData)then
            self.selectItemCallback(self.curData,self.curIdx) 
        else
            self.selectItemCallback(self.curDBData,self.curIdx) 
        end
    end    
end

function PetItem:onTouchEnded(target) 
    if self.isSelected == false then
        self:onSelect();
    end
end
 

function PetItem:showStar(num)
    if self.curData ~= nil then
        CardPro:showStar(self,num,self.curData.awakeLv)
    else
        CardPro:showStar(self,num)
    end
end


function   PetItem:setDBData(data,idx)  
    self.curDBData=data
    self.curIdx=idx 
    self:setLabelString("txt_name",data.name)
    if self.curData ~= nil then
        Icon.setPetIcon2(data.petid,self:getNode("icon"),self.curData.awakeLv)
    else
        Icon.setPetIcon2(data.petid,self:getNode("icon"))
    end
    

    self:changeTexture("icon_bg","images/ui_lingshou/l_ka_"..(data.quality+1)..".png")
    self:changeTexture("icon_top","images/ui_lingshou/l_ka_"..(data.quality+1).."_1.png")
end


function   PetItem:setData(data,idx)  
    self.curData=data
    self.curIdx=idx
    local petDb=DB.getPetById(data.petid)
    if(data.level ~= nil) then
        self:setLabelString("txt_level",getLvReviewName("Lv")..data.level)
    end
    self:setDBData(petDb,idx)
    self:showStar(data.grade)
    
    
    self:getNode("unlock_icon"):setVisible(false)
end



return PetItem