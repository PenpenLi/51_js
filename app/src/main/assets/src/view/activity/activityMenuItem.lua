local ActivityMenuItem=class("ActivityMenuItem",UILayer)

function ActivityMenuItem:ctor()
    self:init("ui/ui_hd_icon.map")
    self.initX= self:getNode("fla"):getPositionX()
    self.initY= self:getNode("fla"):getPositionY()
    self:getNode("txt_lefttime"):setVisible(false)
end

function ActivityMenuItem:setSelect(value)
    self:getNode("fla"):stopAllActions()
    self:getNode("fla"):setPosition(cc.p(self.initX,self.initY))
    
    if(value)then

        local  action = cc.Sequence:create( cc.MoveBy:create(1.2,cc.p(0,-10)),cc.MoveBy:create(1.2,cc.p(0,10)) ); 
        self:getNode("fla"):runAction( cc.RepeatForever:create(action))
        self:changeTexture( "bg","images/ui_huodong/icon_di2.png")
    else

        self:changeTexture("bg","images/ui_huodong/icon_di1.png")
    end
end




function ActivityMenuItem:onTouchEnded(target)
    if(self.onSelectCallback)then
        for key, var in pairs(Data.activityRedPosLogin) do
            if(key==self.curData.type)then
                if (Data.activityRedPosLogin[key]==true) then
                    local bolShow = false
                    Data.activityRedPosLogin[key]=bolShow
                    RedPoint.setActivityRedpos(key,bolShow)
                elseif (self.curData.type==ACT_TYPE_108) then
                    Data.redpos.mlc = false
                end
            end
        end
        self.onSelectCallback(self.curData)
    end
end

function ActivityMenuItem:setData(data)
    self.curData=data
    local type=self.curData.type
    -- print("icon="..self.curData.icon)

    local actionName="ui_activity_icon_"..type
    if (type==ACT_TYPE_2 or type==ACT_TYPE_1) then
        actionName="ui_activity_icon_"..type.."_"..self.curData.icon
    elseif (type==ACT_TYPE_13) then
        actionName="ui_activity_icon_2_11"
    end
    local tmpname = tonumber(self.curData.icon)
    if tmpname==nil and self.curData.icon~="" then
        actionName = self.curData.icon
    end
    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(actionName)
    if(animationData )then
        self:getNode("fla"):playAction(actionName)
    end
    self:setLabelString("txt_name" , data.name)
end




return ActivityMenuItem