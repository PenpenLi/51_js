local ConstellationBagItem=class("ConstellationBagItem",UILayer)

function ConstellationBagItem:ctor()
    self.inited = false
end

function ConstellationBagItem:onTouchEnded(target) 
    -- Panel.clearTouchTip()
    if target.touchName=="btn_lookup" or 
       target.touchName=="icon" then
        if(self.selectItemCallback ~= nil and self.curData ~= nil)then
            self.selectItemCallback(self.curData) 
        end
    end
end

function ConstellationBagItem:setData(data)
    if self.inited then
        return
    end
    self.inited = true
    self:init("ui/ui_constellation_bagitem.map")
    self.curData=data
    Icon.setIcon(data.id,self:getNode("icon"))
    self:setLabelString("txt_name",DB.getConstellationsItemInfo(data.id)["name"])
    self:setLabelString("txt_num",data.num)
    for i=data.star + 1, 3 do
        self:getNode("icon_star"..i):setVisible(false)
    end
    self:getNode("star_container"):layout()

    local activeNum = 0
    local totalNum  = 0
    for _,magicCircleInfo in ipairs(gConstellation.magicCircleInfos) do
        if #magicCircleInfo.groupInfos == 0 then
            magicCircleInfo:initGroupInfos()
        end

        for _, groupInfo in ipairs(magicCircleInfo.groupInfos) do
            if groupInfo:hasCard(data.id) then
                totalNum = totalNum + 1
                if groupInfo.actived then
                    activeNum = activeNum + 1
                end
            end
        end
    end

    self:setLabelString("txt_active_num", string.format("%d/%d",activeNum,totalNum))
end

function ConstellationBagItem:setLazyData(data)
    self.lazyData=data
    Scene.addLazyFunc(self,self.setDataLazyCalled,"constellationBagItem")
end

function ConstellationBagItem:updateNumInfo(num)
    self.curData.num = num
    self:setLabelString("txt_num",self.curData.num)
end

function  ConstellationBagItem:setDataLazyCalled()
    self:setData(self.lazyData)
end

return ConstellationBagItem