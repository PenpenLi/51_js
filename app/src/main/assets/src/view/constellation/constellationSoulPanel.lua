local ConstellationSoulPanel=class("ConstellationSoulPanel",UILayer)

function ConstellationSoulPanel:ctor()
    self:init("ui/ui_constellation_soul.map")
    self.isMainLayerMenuShow = false
    self:initPanel()
end

function ConstellationSoulPanel:events()
    return {
            EVENT_ID_CONSTELLATION_ITEM_REFRESH,
        }
end

function ConstellationSoulPanel:dealEvent(event, param)
    if EVENT_ID_CONSTELLATION_ITEM_REFRESH == event then
        self:getNode("effect"):setVisible(true)
        local function playEnd()
            self:getNode("effect"):setVisible(false)
        end
        self:getNode("effect").curAction=""
        self:getNode("effect"):playAction("ui_weapon_b",playEnd)
        self:initPanel()
    end
end

function ConstellationSoulPanel:onTouchEnded(target, touch, event)
    if target.touchName=="btn_close" then
        self:onClose()
    elseif target.touchName and string.find(target.touchName,"icon_touch_")then
        local idx=toint(string.gsub(target.touchName,"icon_touch_",""))
        self:selectStar(idx)
        if idx ~= 4 then
            self:reset()
        else
            self:autoSelectUnnecessary()
        end
        self:updateNum()
    elseif target.touchName=="btn_merge" then
        local items={}
        for key, item in pairs(self:getNode("scroll").items) do
            if(item.curSelectNum>0)then
                table.insert(items,{itemid=item.curSelectItemid,num=item.curSelectNum})
            end
        end
        if(table.getn(items)~=0)then
            Net.sendCircleCsoul(items)
        end
    end
end

function ConstellationSoulPanel:initPanel()
    self.isDirty = false
    self:initSchedule()
    self.scroll = self:getNode("scroll")
    self.scroll.eachLineNum = 5
    self.scroll.offsetX = 3
    self.scroll.offsetY = 0
    self.scroll.padding = 5
    self.scroll:clear()

    local drawNum=20
    for key, var in ipairs(gConstellation.bags) do
        if var.num ~= 0 then
            local item=ConstellationSoulItem.new()
            item.idx=key
            if(drawNum>0)then
                drawNum=drawNum-1
                item:setData(var)
            else
                item:setLazyData(var)
            end

            item.selectItemCallback=function ()
                self.isDirty=true
            end
            self:getNode("scroll"):addItem(item)
        end
    end

    self:getNode("scroll"):layout()
    self:updateNum()
end

function ConstellationSoulPanel:onPopback()
    Scene.clearLazyFunc("constellationSoul")
end

function ConstellationSoulPanel:selectStar(i)
    if(self:getNode("icon_choose_"..i ).isSelect)then
        self:getNode("icon_choose_"..i ).isSelect=false
        self:changeTexture("icon_choose_"..i ,"images/ui_public1/n-di-gou1.png")
    else
        self:getNode("icon_choose_"..i ).isSelect=true
        self:changeTexture("icon_choose_"..i ,"images/ui_public1/n-di-gou2.png")
    end
end

function  ConstellationSoulPanel:getSelectStar()
    local rets={}
    for i=1,3 do
        if(self:getNode("icon_choose_"..i ).isSelect)then
            rets[i]=true
        end
    end
    return rets
end

function ConstellationSoulPanel:reset()
    self:getNode("icon_choose_4").isSelect = false
    self:changeTexture("icon_choose_4","images/ui_public1/n-di-gou1.png")

    local stars=self:getSelectStar()
    
    for key, item in pairs(self:getNode("scroll").items) do
        if(stars[item.curData.star])then
            item:setRemainNum(0)
        else
            item:setUnSelect()
        end        
    end
end

function ConstellationSoulPanel:autoSelectUnnecessary()
    local isSelect = self:getNode("icon_choose_4").isSelect
    if isSelect then
        for i = 1, 3 do
            self:getNode("icon_choose_"..i ).isSelect=false
            self:changeTexture("icon_choose_"..i ,"images/ui_public1/n-di-gou1.png")
        end

        for key, item in pairs(self:getNode("scroll").items) do 
            item:setUnSelect()
            item:selectUnnecessary(true)       
        end
    else
        for key, item in pairs(self:getNode("scroll").items) do 
            item:selectUnnecessary(false)       
        end
    end
end

function ConstellationSoulPanel:updateNum()
    local totalNum = 0
    for key, item in pairs(self:getNode("scroll").items) do
        totalNum = totalNum + item.soulFactor*item.curSelectNum
    end
    self:setLabelString("txt_num",math.floor(totalNum))
    if(totalNum == 0)then
        self:setTouchEnable("btn_merge",false,true)
    else
        self:setTouchEnable("btn_merge",true,false)
    end
end

function ConstellationSoulPanel:refreshItemNums()
    for key, item in pairs(self:getNode("scroll").items) do
        item:setUnSelect()
    end
    self:setLabelString("txt_num",0)
    self:setTouchEnable("btn_merge",false,true)
end

function ConstellationSoulPanel:initSchedule()
    self:unscheduleUpdateEx()
    self:scheduleUpdateWithPriorityLua(function()
        if(self.isDirty==false)then
            return
        end
        self.isDirty=false
        self:updateNum()
    end,1)
end

function ConstellationSoulPanel:onUILayerExit()
    self:unscheduleUpdateEx()
end


return ConstellationSoulPanel
