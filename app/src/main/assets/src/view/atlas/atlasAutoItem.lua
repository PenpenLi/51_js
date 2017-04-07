local AtlasAutoItem=class("AtlasAutoItem",UILayer)

function AtlasAutoItem:ctor(type)
    self:init("ui/ui_atlas_saodang_item.map")
    self.itemShowTime=0.1
end


function AtlasAutoItem:setData(data,idx,wantedItem,showDouble)
    self.curData=data
    self:setLabelString("txt_gold",self.curData.rewards.gold)
    self:setLabelString("txt_exp",self.curData.rewards.exp)
    self:setLabelString("txt_index",gGetWords("labelWords.plist","lab_atlas_auto_idx",idx))

    for i=1, 7 do
        self:getNode("reward_"..i):setVisible(false)
    end


    AtlasAutoItem.initItems(self,self.curData.rewards.items,wantedItem,showDouble)
end

function AtlasAutoItem.initItems(self,items,wantedItem,showDouble)
    self.items={}
    local idx=1
    for key, item in pairs(items) do
        if(self:getNode("reward_"..idx))then
            if(not Icon.isAttrItem(item.id) or item.id==OPEN_BOX_CARDEXP_ITEM or item.id==OPEN_BOX_SOULMONEY)then
                self:getNode("reward_"..idx):setVisible(true)
                local dropItem= Icon.setDropItem(self:getNode("reward_"..idx),item.id,item.num)
                dropItem:setOpacity(0)
                if(Icon.isAttrItem(item.id)==false and item.num>=2  and showDouble~=false)then
                    local  double=cc.Sprite:create("images/ui_public1/x2.png")
                    double:setPositionX(double:getContentSize().width/2)
                    double:setPositionY(-double:getContentSize().height/2)
                    dropItem:addChild(double,100)
                end
                gSetCascadeOpacityEnabled(dropItem,true)
                dropItem:setAnchorPoint(cc.p(0.5,-0.5));
                dropItem:setPosition(gGetNodePositionByAnchorPoint(self:getNode("reward_"..idx),cc.p(0.5,0.5)));

                if(item.id==wantedItem)then
                    local red =RedPoint.getRedPoint()
                    red:setPosition(cc.p(20,-20))
                    dropItem:addChild(red)
                    dropItem:setNum(item.num)
                end
                table.insert(self.items,dropItem)
                idx=idx+1
            end
        end
    end

    if(   self:getNode("txt_empty"))then
        if(table.getn(self.items)==0)then
            table.insert(self.items,self:getNode("txt_empty"))
            self:getNode("txt_empty"):setVisible(true)
        else
            self:getNode("txt_empty"):setVisible(false)

        end
    end
end

function AtlasAutoItem:quickShow()
    for key, item in pairs(self.items) do
        item:setOpacity(255)
        item:setScale(1)
    end
end

function AtlasAutoItem.show(self,moveTime,items)
    if(items==nil)then
        items=self.items
    end
    if(table.getn(items)==0)then
        return
    end
    for key, item in pairs(items) do
        item:setScale(1.6)
        local fadeIn=   cc.FadeIn:create(self.itemShowTime)
        local scaleTo=cc.EaseBackOut:create( cc.ScaleTo:create(self.itemShowTime,1))
        local delay=   cc.DelayTime:create(self.itemShowTime*(key-1)+moveTime)
        item:runAction( cc.Sequence:create(delay,cc.Spawn:create(fadeIn,scaleTo) ))
    end
end


return AtlasAutoItem