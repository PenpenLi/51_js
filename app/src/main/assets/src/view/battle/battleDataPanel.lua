local BattleDataPanel=class("BattleDataPanel",UILayer)

function BattleDataPanel:ctor(isExit)
    self:init("ui/ui_battle_data.map")
    self.isExit=isExit
    self:selectBtn("btn_damage")
    self:initDamageType()
end


function BattleDataPanel:clearData()
    for i=1, 6 do
        self:getNode("role_1_"..i):setVisible(false)
        self:getNode("role_2_"..i):setVisible(false)
    end
end



function BattleDataPanel:showData()

    local otherDatas={}
    local myDatas={}
    
    local maxValue=0
    for key, data in pairs(self.myData) do
        local temp=clone(Battle.myFormation[key])
        temp.value=data
        temp.key=key
        if(maxValue<data)then
            maxValue=data
        end
        table.insert( myDatas,temp)
    end

    for group, datas in pairs(self.otherData) do
        for key, data in pairs(datas) do
            local temp=clone(Battle.otherFormation[group][key])
            temp.group=group
            temp.value=data
            temp.key=key
            table.insert( otherDatas,temp)
            if(maxValue<data)then
                maxValue=data
            end
        end
    end
    
    
    local function sortFunc(a,b)
        if( a.value==b.value)then
            return a.key<b.key
        else
            return a.value>b.value
        end
    end
    
    table.sort(myDatas,sortFunc)
    table.sort(otherDatas,sortFunc)

    for i=1, 7 do
        self:getNode("role_1_"..i):setVisible(false)
        self:getNode("role_2_"..i):setVisible(false)
    end
    for i, data in pairs(myDatas) do
        if(self:getNode("role_1_"..i) and data.petid==nil)then
            self:getNode("role_1_"..i):setVisible(true)
            
            if(data.petid)then
                Icon.setIcon(data.petid,self:getNode("icon_1_"..i),data.quality,data.awakeLv);
            else
                Icon.setIcon(data.cardid,self:getNode("icon_1_"..i),data.quality,data.awakeLv);
            end
            self:setLabelString("name_1_"..i,data.value)
            self:setBarPerAction("bar_1_"..i,0,data.value/maxValue,nil,false)
        end
    end

    
    for i, data in pairs(otherDatas) do
        if(self:getNode("role_2_"..i)  and data.petid==nil)then
            self:getNode("role_2_"..i):setVisible(true)
            if(data.petid)then
                Icon.setIcon(data.petid,self:getNode("icon_2_"..i),data.quality,data.awakeLv);
            else
                Icon.setIcon(data.cardid,self:getNode("icon_2_"..i),data.quality,data.awakeLv);
            end
            self:setLabelString("name_2_"..i,data.value)
            self:setBarPerAction("bar_2_"..i,0,data.value/maxValue,nil,true)
        end
    end
    self:resetLayOut()
end


function BattleDataPanel:initHurtType()
    self:clearData()
    self.myData=Battle.myBattleHurtData
    self.otherData=Battle.otherBattleHurtData
    self:showData()

end

function BattleDataPanel:initDamageType()
    self:clearData()

    self.myData=Battle.myBattleDamageData
    self.otherData=Battle.otherBattleDamageData
    self:showData()

end


function BattleDataPanel:initRecoveryType()
    self:clearData()
    self.myData=Battle.myBattleRecoverData
    self.otherData=Battle.otherBattleRecoverData
    self:showData()

end


function BattleDataPanel:resetBtnTexture()
    local btns={
        "btn_damage",
        "btn_hurt",
        "btn_recovery",
    }

    for key, btn in pairs(btns) do
        self:changeTexture(btn,"images/ui_public1/button_s2.png")
    end

end
function BattleDataPanel:selectBtn(name)
    self:resetBtnTexture()
    self:changeTexture( name,"images/ui_public1/button_s2-1.png")
end


function BattleDataPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
        if(self.isExit)then
            Scene.enterMainScene()
        end
    elseif  target.touchName=="btn_damage"then
        self:selectBtn(target.touchName)
        self:initDamageType()
    elseif  target.touchName=="btn_hurt"then
        self:selectBtn(target.touchName)
        self:initHurtType()
    elseif  target.touchName=="btn_recovery"then
        self:selectBtn(target.touchName)
        self:initRecoveryType()
    end
end

return BattleDataPanel