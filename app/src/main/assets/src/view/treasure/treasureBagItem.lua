local TreasureBagItem=class("TreasureBagItem",UILayer)

function TreasureBagItem:ctor()
end

function TreasureBagItem:initPanel()
    if(self.inited==true)then
        return
    end
    self.inited=true
    self:init("ui/ui_bag_treasure_item.map")
    self:getNode("icon_merge"):setVisible(false)
    self:getNode("icon_wear"):setVisible(false)
end


function TreasureBagItem:resetStatus(card,type)
    self.curData.wear=false
    self.curTypeWear=false
    self.curTypeWear2=false
    self.curTypeMerge=false
    self.curData.merge=false
    self.lastTresureType=type
    local curType=-1
    if(self.curData.db)then
        curType= (self.curData.db.type+1)
    end
    if(self.curData.cardid and self.curData.cardid==0 )then
        if(card["treasure"..curType]==0)then
            self.curData.wear=true
            if(curType==type)then
                self.curTypeWear=true
            end
        else
            local wearTreasure=Data.getTreasureById(card["treasure"..curType])
            if(wearTreasure.db.quality<self.curData.db.quality)then
                self.curTypeWear2=true
            elseif(wearTreasure.db.quality==self.curData.db.quality and
                wearTreasure.upgradeLevel<self.curData.upgradeLevel)then
                self.curTypeWear2=true
            end
        end
    elseif(self.curData.cardid ==nil and self.curData.db)then
        if(self.curData.num>=self.curData.db.com_num)then
            self.curData.merge=true
            if(curType==type and card["treasure"..curType]==0)then
                self.curTypeMerge=true
            end
        end
    end



end

function TreasureBagItem:resetStatusIcon()
    if(self.inited~=true)then
        return
    end
    self:getNode("icon_merge"):setVisible(false)
    self:getNode("icon_wear"):setVisible(false)
    self:getNode("icon_wear2"):setVisible(false)

    if(self.curTypeWear2)then
        self:getNode("icon_wear2"):setVisible(true)
    end

    if(self.curData.wear)then
        self:getNode("icon_wear"):setVisible(true)
    end
    if(self.curData.merge)then
        self:getNode("icon_merge"):setVisible(true)
    end
end

function TreasureBagItem:onTouchEnded(target)
    if(self.selectItemCallback)then
        self.selectItemCallback(self.curData)
    end
end
function  TreasureBagItem:setDataLazyCalled()
    self:setData(self.lazyData,self.lazyTagType)
end

function  TreasureBagItem:setLazyData(data,tagType)
    self.curData=data
    self.lazyData=data
    self.lazyTagType=tagType
    Scene.addLazyFunc(self,self.setDataLazyCalled,"bag")
end



function   TreasureBagItem:setRemainNum()
    if(self.curData.num)then
        local treasure=DB.getTreasureById(self.curData.itemid)
        if(treasure)then
            self:setLabelString("txt_num",self.curData.num.."/"..treasure.com_num)
        end
    end

end
function   TreasureBagItem:setData(data)
    self:initPanel()
    self.curData=data
    self:resetStatusIcon()
    if(data.itemid==nil)then
        return
    end
    local treasure=DB.getTreasureById(data.itemid)
    if(treasure==nil)then
        return
    end
    self:getNode("txt_lv"):setVisible(false)
    self:getNode("txt_jinglian"):setVisible(false)
    self:getNode("bg_star"):setVisible(false)
    self:getNode("txt_num"):setVisible(false)
    if(self.curData.num )then
        self:getNode("txt_num"):setVisible(true)
        self:setLabelString("txt_num",data.num.."/"..treasure.com_num)
    else
        self:getNode("bg_star"):setVisible(true)
        for i=1,5 do
            self:getNode("icon_star"..i):setVisible(data.starlv>=i)
        end
        self:resetLayOut()
        if data.quenchLevel>0 then
            self:replaceLabelString("txt_jinglian",data.quenchLevel)
            self:getNode("txt_jinglian"):setVisible(true)
            -- local position = cc.p(self:getNode("txt_jinglian"):getPosition())
            --  if showStar==false then
            --     --self:getNode("txt_jinglian"):setPosition(position.x, position.y-15)
            --  end
        end
        if data.upgradeLevel>1 then
             self:getNode("txt_lv"):setVisible(true)
             self:setLabelString("txt_lv",data.upgradeLevel)
        end
        
    end

    local itemid=data.itemid
    if(data.cardid==nil   )then
        Icon.setIcon(itemid,self:getNode("icon"),treasure.quality,nil,true)
    else
        Icon.setIcon(itemid,self:getNode("icon"),treasure.quality)
    end


end



return TreasureBagItem