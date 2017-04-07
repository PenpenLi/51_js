
local FamilyWarRewardPanel=class("FamilyWarRewardPanel",UILayer)

function FamilyWarRewardPanel:ctor(type)
    self.appearType = 1;
    self:init("ui/ui_family_war_reward.map")
    self.isMainLayerGoldShow = false;
    self.isMainLayerMenuShow = false;
    self.isWindow = true;

    self:showType(1)
end


function FamilyWarRewardPanel:showType(type)
    self:getNode("scroll"):clear()
    self:selectBtn("btn_type"..type) 
    
    local function sortFunc(item1,item2)
        return item1.curData.round<item2.curData.round
    end
    
    local data=DB.getClientParam("FAMILY_MATCH_FAMILY_REWARD_"..type) 
    local item=FamilyWarRewardItem.new(0)
    self:getNode("scroll"):addItem(item)
    item:setData1({value=data})
    
    for key, var in pairs(familywincount_db) do
        if(var.wincount>100 and var.round==type)then
            local item=FamilyWarRewardItem.new(0)
            self:getNode("scroll"):addItem(item)
            item:setData0(var)
        end
    end
 
    self:getNode("scroll"):layout()
end
 

function FamilyWarRewardPanel:showkillType()

    self:getNode("scroll"):clear()
    self:selectBtn("btn_type_kill") 

    local function sortFunc(item1,item2)
        return item1.sort>item2.sort
    end
    
    for key, var in pairs(familywincount_db) do
        if( var.round==8 )then
            if(var.wincount==3 or var.wincount==5 or var.wincount==8 or var.wincount==10)then
                local item=FamilyWarRewardItem.new(2)
                self:getNode("scroll"):addItem(item)
                item:setData2(var)
                item.sort=var.round*1000+100-var.wincount
            end
        end
    end
    table.sort(self:getNode("scroll").items,sortFunc)
    self:getNode("scroll"):layout()
end

function FamilyWarRewardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then

    end
end

function   FamilyWarRewardPanel:resetBtnTexture()

    local btns={ 
        "btn_type16",
        "btn_type8",
        "btn_type4",
        "btn_type2",
        "btn_type1",
        "btn_type_kill",
    }
    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/b_biaoqian1.png")
        self:setTouchEnable( btn,true)
    end

end

function FamilyWarRewardPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    elseif target.touchName=="btn_type1"then
        self:showType(1)
    elseif target.touchName=="btn_type2"then
        self:showType(2)
    elseif target.touchName=="btn_type4"then
        self:showType(4)
    elseif target.touchName=="btn_type8"then
        self:showType(8)
    elseif target.touchName=="btn_type16"then
        self:showType(16)
    elseif target.touchName=="btn_type_kill"then
        self:showkillType()

    end
end

function   FamilyWarRewardPanel:selectBtn(btn)

    self:resetBtnTexture()
    self:changeTexture( btn,"images/ui_public1/b_biaoqian1-1.png")
end


return FamilyWarRewardPanel