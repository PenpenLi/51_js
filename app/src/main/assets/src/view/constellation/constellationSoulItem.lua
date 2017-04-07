local ConstellationSoulItem=class("ConstellationSoulItem",UILayer)

function ConstellationSoulItem:ctor()
    self.curSelectNum=0
    self.curSelectItemid=0
end

function ConstellationSoulItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_weapon_item.map")
    self:getNode("icon_reomove").__touchend=true
    self:getNode("icon_add").__touchend=true
end


function ConstellationSoulItem:onTouchBegan(target)
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

function ConstellationSoulItem:onTouchMoved(target,touch)

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

function ConstellationSoulItem:setUnSelect()
    self.curSelectNum=0
    self:refreshSelect()
end

function ConstellationSoulItem:setRemainNum(num) 
    self.curSelectNum=self.curData.num-num
    if(self.curSelectNum<0)then
        self.curSelectNum=0
    end
    self:refreshSelect()
end

function ConstellationSoulItem:changeSelectNum(num)
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

function ConstellationSoulItem:onTouchEnded(target)
    if(target.touchName=="icon_reomove")then
        if(self.isMoved==false)then
            self:changeSelectNum(-1)
        end
    elseif(target.touchName=="icon_add")then
        if self:getNode("icon_add").__touchend then
            if(self.isMoved==false)then
                self:changeSelectNum(1)
            end
        end
    end
    self:unscheduleUpdate()

end
function  ConstellationSoulItem:setDataLazyCalled()
    self:setData(self.lazyData)
    self:refreshSelect()
end

function  ConstellationSoulItem:setLazyData(data)
    self.lazyData=data
    self.soulFactor = DB.getConstallationChangeSoul(data.star)
    Scene.addLazyFunc(self,self.setDataLazyCalled,"constellationSoul")
end

function ConstellationSoulItem:refreshSelect()
    if(self.inited==true)then
        self:setLabelString("txt_num",self.curSelectNum.."/"..self.curData.num)
        if(self.curSelectNum==0)then
            self:getNode("icon_reomove"):setVisible(false)
        else
            self:getNode("icon_reomove"):setVisible(true)
        end
    end
end

function ConstellationSoulItem:setData(data)
    self:initPanel()
    self.curData=data
    local qua=DB.getItemQuality(data.id) 
    if(data.id==nil)then
        return
    end 
    self.curSelectItemid=data.id
    self.soulFactor = DB.getConstallationChangeSoul(data.star)
    Icon.setIcon(data.id,self:getNode("icon"),qua)
    self:refreshSelect()
end

function ConstellationSoulItem:selectUnnecessary(isSelect)
    if isSelect then
        local activeNum = 0
        local totalNum  = 0
        for _,magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
            if #magicCircleInfo.groupInfos == 0 then
                magicCircleInfo:initGroupInfos()
            end

            for _, groupInfo in ipairs(magicCircleInfo.groupInfos) do
                --激活
                if groupInfo:hasCard(self.curData.id) then
                    totalNum = totalNum + 1
                    if groupInfo.actived then
                        activeNum = activeNum + 1
                    end
                end
                local function getNeedStarNum(cardid,groupStarInfo)
                    local starNum=0
                    local itemIdAndNum ={}
                     if groupStarInfo then
                        for k = 1, 5 do
                            local tmpItemId = groupStarInfo["conid"..k]
                            if tmpItemId ~= 0 then  
                                itemIdAndNum[tmpItemId] = groupStarInfo["connum"..k]
                            end
                        end
                    end
                    if itemIdAndNum[cardid]~=nil then
                        starNum=itemIdAndNum[cardid]
                    end
                    return starNum
                end
                --升星
                if gConstellation.showStarViewLv() and groupInfo.star>0 and groupInfo.actived then
                    local starlv =gConstellation.getStarNumByGroupMap(groupInfo.circleId, groupInfo.groupId)
                    for i=starlv+1,groupInfo.star do
                        local groupStarInfo = DB.getCircleGroupStar(groupInfo.groupId,i)
                        totalNum =totalNum+getNeedStarNum(self.curData.id,groupStarInfo)
                    end
                end
            end
        end

        self.curSelectNum = self.curData.num - (totalNum - activeNum)
        if self.curSelectNum < 0 then
            self.curSelectNum = 0
        end
        self:refreshSelect()
    else
        self.curSelectNum = 0
        self:refreshSelect()
    end
end

return ConstellationSoulItem