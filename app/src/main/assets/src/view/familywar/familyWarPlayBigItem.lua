local FamilyWarPlayBigItem=class("FamilyWarPlayBigItem",UILayer)

function FamilyWarPlayBigItem:ctor()
    self:init("ui/ui_family_war_play_big_item.map");
end





function FamilyWarPlayBigItem:setData(data,move)
    if(self.curData==data)then
        return
    end

    local move1=false
    local move2=false
    if(self.curData)then
        if(self.curData.name1~=data.name1)then
            move1=true
        end
        if(self.curData.name2~=data.name2)then
            move2=true
        end
    end

    self.curData=data;
    local cardid1=data.icon1%100000
    local cardid2=data.icon2%100000
    self.cardid1=cardid1
    self.cardid2=cardid2
     

    self.role1=gCreateRoleFla(cardid1, self:getNode("role_container1"),0.7,true ,nil,data.weaponLv1,data.awakeLv1); 
    self.role2=gCreateRoleFla(cardid2, self:getNode("role_container2"),0.7,true,nil,data.weaponLv2,data.awakeLv2);
    
    self:getNode("container"):setPositionX(0)
    self.role1:setPosition(cc.p(0,0))
    self.role2:setPosition(cc.p(0,0))
    self.role1:setRotation(0)
    self.role2:setRotation(0)
    self.role1:stopAllActions()
    self.role2:stopAllActions()
    self:getNode("effect"):setVisible(false)

    if(self.curData.win==true)then
        self.curName=data.name1
        move1=false
    else
        self.curName=data.name2
        move2=false
    end

    if(move)then
        if(move1)then
            self:moveRole(1)
        end
        if(move2)then
            self:moveRole(2)
        end
    end
end

function FamilyWarPlayBigItem:moveRole(pos)

    local function moveEnd()
        self["role"..pos]:playAction("r"..self["cardid"..pos].."_wait")
    end

    self["role"..pos]:playAction("r"..self["cardid"..pos].."_run")
    self["role"..pos]:setPositionX(-300)


    local action=  cc.MoveBy:create(0.5,cc.p(300,0))
    self["role"..pos]:runAction(cc.Sequence:create(  action, cc.CallFunc:create(moveEnd)))

end
function FamilyWarPlayBigItem:appearNewOne(data,side)
end


function FamilyWarPlayBigItem:playRound(round,roundNum)
    self.role1:playAction("r"..self.cardid1.."_run")
    self.role2:playAction("r"..self.cardid2.."_run")
 
    local temp={}

    local randPos={} 
    for i=1, roundNum-1 do
        local num=getRand(30,100)
        if(firtSign==false)then
            num=-num
            firtSign=true
        else
            firtSign=false
        end
        table.insert(randPos,num)
    end
 
    for key, var in pairs(randPos) do 
        local pos1=cc.p(var,self:getNode("container"):getPositionY()) 
        local move1 =  cc.EaseOut:create(cc.MoveTo:create(0.5,pos1),2)
        table.insert(temp,move1)
    end
    

    if(self.curData.win==true)then 
        local pos1=cc.p(getRand(120,200),self:getNode("container"):getPositionY()) 
        local move1 =  cc.EaseIn:create(cc.MoveTo:create(0.5,pos1),2)
        table.insert(temp,move1)
    else 
        local pos1=cc.p(-getRand(120,200),self:getNode("container"):getPositionY()) 
        local move1 =  cc.EaseIn:create(cc.MoveTo:create(0.5,pos1),2)
        table.insert(temp,move1)
    
    end
    

    local action=cc.Sequence:create(temp )

    self:getNode("effect"):setVisible(true)
    local function moveEnd()
        self:getNode("effect"):setVisible(false)
        self.role1:playAction("r"..self.cardid1.."_wait")
        self.role2:playAction("r"..self.cardid2.."_wait")

        local action=cc.Spawn:create(
            cc.RotateBy:create(0.4,-120),
            cc.EaseOut:create(cc.MoveBy:create(0.4,cc.p(-700,100)),2)
        )
        if(self.curData.win==true)then
            self.role2:runAction(action)
        else
            self.role1:runAction(action)
        end
        
        local fla=gCreateFla("ui_tuanzhan_vs_bao")
        fla:setPosition(self:getNode("effect"):getPosition())
        self:getNode("effect"):getParent():addChild(fla)
    end
    self:getNode("container"):stopAllActions()
    self:getNode("container"):runAction(cc.Sequence:create(action,cc.CallFunc:create(moveEnd)))

end

return FamilyWarPlayBigItem