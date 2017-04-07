local RedPackageRainPanel=class("RedPackageRainPanel",UILayer)

local TotalTime=5
function RedPackageRainPanel:ctor(name,id)
    self.isBlackBgVisible=false
    self.hideMainLayerInfo=true 
    self:init("res/ui/ui_red_package_rain.map")

    self.rainId=id
    self.rainName=name 
    self:getNode("txt_time").time=TotalTime+1
    local function onTiming()
        local time=  self:getNode("txt_time").time
        self:setLabelString("txt_time",time-1)
        self:getNode("txt_time").time=time-1
    end
    onTiming()
    gSetCascadeOpacityEnabled(self:getNode("panel_time"),true)
    self:getNode("panel_time"):setVisible(true) 
    self:getNode("panel_time"):setOpacity(0)
    self:getNode("panel_time"):runAction(cc.FadeIn:create(1.0))
    self:replaceRtfString("txt_title",name)
    local function onTimup()
        self:getNode("panel_time"):setVisible(false)
        self:onDisapper()
    end
    local function  callback()
        self:getNode("start_icon"):setVisible(false)

        self:createRedPackage()
        local pAct_repeat =cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(onTiming,{})), 5)
        self:getNode("panel_time"):runAction(cc.Sequence:create(pAct_repeat, cc.CallFunc:create(onTimup,{})))
    end
    performWithDelay(self,callback,2)
end


function RedPackageRainPanel:createRedPackage()

    for i=1, 6 do
        self:getNode("rain_pos"..i).startTime=getRand(0,30)/100
    end
    self.redPacks={}
    local dropNum=6
    for i=1, 6 do
        for j=1, dropNum do
            local dropTime=getRand(440,640)/100
            local node=self:getNode("rain_pos"..i)
            local item=nil
            if(getRand(0,100)<50)then
                item=gCreateFla("ui_hongbao_hongbao1",1)
            else
                item=gCreateFla("ui_hongbao_hongbao2",1)
            end
            node:getParent():addChild(item)
            item:setPositionX(node:getPositionX()+getRand(-40,40))
            item:setPositionY(node:getPositionY()+80)
            local function onReach()
                self.redPacks[item.key]=nil
                item:removeFromParent()
            end
            self.redPacks[i*100+j]=item
            item.key=i*100+j
            local action1=cc.DelayTime:create(node.startTime)
            local action2=cc.MoveBy:create(dropTime,cc.p(0,-800))
            local action3= cc.CallFunc:create(onReach,{})
            item:runAction(cc.Sequence:create(action1,action2,action3  ))
            node.startTime=node.startTime+getRand(100,160)/100
        end
    end

end

function RedPackageRainPanel:onDisapper()
    self:getNode("left_icon"):runAction(cc.MoveBy:create(0.5,cc.p(-200,0)))
    self:getNode("right_icon"):runAction(cc.MoveBy:create(0.5,cc.p(200,0)))
    self:getNode("panel_time"):runAction(cc.FadeOut:create(0.2))
    local function onMoved()
        Panel.popBack(self:getTag())
    end
    self:getNode("top_icon"):runAction(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,140)), cc.CallFunc:create(onMoved,{})))
end

function RedPackageRainPanel:onTouchEnded(target,touch)

    if  target.touchName=="btn_touch"then
        if(self.redPacks==nil)then
            return
        end
        
        if(table.count(self.redPacks)==0)then
            Panel.popBack(self:getTag())
        end
        
        local location = touch:getLocation()
        local nodeLocation=nil
        for key, pack in pairs(self.redPacks) do
            if(nodeLocation==nil)then
                nodeLocation= pack:getParent():convertToNodeSpace(location)
            end
            local pos   = {x=pack:getPositionX(),y=pack:getPositionY()}
            if(math.abs(pos.x-nodeLocation.x)<80 and math.abs(pos.y-nodeLocation.y)<100 )then
                local function playEnd()
                    pack:setVisible(false)
                    self:stopAllActions() 
                    Net.sendActivityLootName=self.rainName 
                    Net.sendActivityLoot20(self.rainId)
                    for key, pack in pairs(self.redPacks) do
                        pack:removeFromParent()
                    end
                    self.redPacks={}
                end
                self:getNode("panel_time"):stopAllActions()
                pack:stopAllActions()
                pack:playAction("ui_hongbao_dianzhong",playEnd)
                return
            end
        end
    end
end


return RedPackageRainPanel