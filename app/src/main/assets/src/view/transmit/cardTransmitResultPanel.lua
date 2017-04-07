local CardTransmitResultPanel=class("CardTransmitResultPanel",UILayer)


function CardTransmitResultPanel:ctor(rewards,card)

    self:init("ui/ui_card_transmit_result.map")
    self:setReward(rewards,card, 1)
    self.hideMainLayerInfo = true;
    self.isWindow = true;
end

function CardTransmitResultPanel:onPopback()

    Scene.clearLazyFunc("transmit_card_result")
end



function  CardTransmitResultPanel:setReward(rewards,card)


    local  items=rewards.items
    local gold=rewards.gold
    local exp=rewards.cardExpItem
    local point=rewards.skillPoint

    local temp={}
    for key, var in pairs(items) do
        if(temp[var.id]==nil)then
            temp[var.id]=0
        end
        temp[var.id]= temp[var.id]+var.num
    end

    local awakeNum=temp[ITEM_AWAKE]
    local soulNum=temp[card.cardid+ITEM_TYPE_SHARED_PRE]


    if(point==nil)then
        point=0
    end
    if(exp==nil)then
        exp=0
    end
    if(gold==nil)then
        gold=0
    end
    self:getNode("scroll"):removeAllChildren()
    self:getNode("item_container"):removeAllChildren()

    if(gold>0)then
        local item=DropItem.new()
        item:setData(OPEN_BOX_GOLD)
        item:setNum(gold)
        self:getNode("scroll"):addChild(item)
    end

   
    if(point>0)then
        local item=DropItem.new()
        item:setData(OPEN_BOX_SKILLPOINT)
        item:setNum(point)
        self:getNode("scroll"):addChild(item)
    end

    if(exp>0)then
        local item=DropItem.new()
        item:setData(OPEN_BOX_CARDEXP_ITEM)
        item:setNum(exp)
        self:getNode("scroll"):addChild(item)
    end
    if(awakeNum and awakeNum>0)then 
        local item=DropItem.new()
        item:setData(ITEM_AWAKE)
        item:setNum(awakeNum) 
        self:getNode("scroll"):addChild(item)
    end

    self:layoutContainer(self:getNode("scroll"),self:getNode("scroll"):getContentSize().height)



    local item=DropItem.new()
    item:setData(card.cardid,card.quality,nil,card.awakeLv);
    item:setNum(1)
    item:setScale(0.75)
    item:setPositionY(40)
    self:getNode("item_container"):addChild(item)
    local node=cc.Node:create()
    item:addChild(node,100)
    node:setPositionX(item:getContentSize().width/2)
    node:setPositionY(-item:getContentSize().height+17)
    CardPro:showNewStar(node, card.grade,card.awakeLv)

    
    local addIdx=0
    if(soulNum and soulNum>0)then
        addIdx=addIdx+1
        local item=DropItem.new()
        item:setData(card.cardid+ITEM_TYPE_SHARED_PRE)
        item:setNum(soulNum)
        item:setScale(0.75)  
        item:setPositionY(40) 
        item:setPositionX(addIdx*100) 
        self:getNode("item_container"):addChild(item)
    end


   

    local sortItem={}
    for itemid, num in pairs(temp) do
        if(itemid~=OPEN_BOX_GOLD and
            itemid~=OPEN_BOX_SKILLPOINT and
            itemid~=OPEN_BOX_CARDEXP_ITEM and
            itemid~=ITEM_AWAKE and
            itemid~=card.cardid+ITEM_TYPE_SHARED_PRE)then
            table.insert(sortItem,{itemid=itemid,num=num})
        end
    end
    gPreSortEquipItem(sortItem)
    table.sort(sortItem,gSortEquipItem) --排序

    for var, data in pairs(sortItem) do
        local idx=var+addIdx
        local function setDataLazyCalled()
            local item=DropItem.new()
            item:setData(data.itemid)
            item:setNum(data.num)
            item:setScale(0.75)
            item:setPositionX((idx%4)*100)
            item:setPositionY(-math.floor(idx/4)*100+40)
            self:getNode("item_container"):addChild(item)
        end
        if(var>10)then
            Scene.addLazyFunc(self,setDataLazyCalled,"transmit_card_result")
        else
            setDataLazyCalled()
        end
    end

    local width=self:getNode("scroll1"):getContentSize().width
    local attrHeight=self:getNode("attr_panel1"):getContentSize().height


    local itemHeight=math.ceil((table.getn(sortItem)+1)/4)*100
    local height=itemHeight+attrHeight
    self:getNode("attr_panel1"):setPositionY(height  )
    self:getNode("item_container"):setPositionY(itemHeight )
    self:getNode("scroll1"):setCheckChildrenVisibleEnable(false)
    self:getNode("scroll1").container:setContentSize(cc.size(width,height))
    self:getNode("scroll1").container:setPositionY(self:getNode("scroll1"):getContentSize().height-height)
end

function CardTransmitResultPanel:layoutContainer(container,offsetY)

    local children = container:getChildren()
    local i = 0
    local len = table.getn(children)
    for i = 0, len-1, 1 do
        local item=children[i + 1]
        item:setScale(0.75)
        item:setPositionX((i%4)*100)
        item:setPositionY(-math.floor(i/4)*100+offsetY)
    end
    return math.ceil(len/4)*100
end
function CardTransmitResultPanel:onTouchEnded(target)

    if  target.touchName=="btn_close" or target.touchName=="btn_transmit"   then
        Panel.popBack(self:getTag())
    end
end

return CardTransmitResultPanel