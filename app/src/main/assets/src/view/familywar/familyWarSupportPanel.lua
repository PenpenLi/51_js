
local FamilyWarSupportPanel=class("FamilyWarSupportPanel",UILayer)

function FamilyWarSupportPanel:ctor(list)
    self:init("ui/ui_family_war_support.map")   
    self:selectBtn("btn_my")
    self.supportList=list
    self:initSupport(list)
end

function FamilyWarSupportPanel:initSupport(list)
    self:getNode("scroll"):clear()
    for key, var in pairs(list) do 
    	local item=FamilyWarSupportItem.new()
    	item:setData(var)
    	self:getNode("scroll"):addItem(item)
    end 
    self:getNode("scroll"):layout()
end
 

function FamilyWarSupportPanel:initRecord()
    self:getNode("scroll"):clear() 
    for i=1, 2 do
        local item=FamilyWarSupportRecord.new()
        self:getNode("scroll"):addItem(item)
    end 
    self:getNode("scroll"):layout()

end
function FamilyWarSupportPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then  
        self:onClose();
    elseif  target.touchName=="btn_my"then
        self:selectBtn(target.touchName)
        self:initSupport(self.supportList)
    elseif  target.touchName=="btn_record"then
        self:selectBtn(target.touchName)
        self:initRecord()
    end
end



function FamilyWarSupportPanel:resetBtnTexture()
    local btns={
        "btn_my",
        "btn_record", 
    }

    for key, btn in pairs(btns) do 
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
    end

end
function FamilyWarSupportPanel:selectBtn(name) 
    self:resetBtnTexture() 
    self:changeTexture( name,"images/ui_public1/b_biaoqian1-1.png")
end


return FamilyWarSupportPanel