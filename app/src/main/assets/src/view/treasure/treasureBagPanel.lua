
function TreasurePanel:initBagPanel()
    if(self.bagPanel~=nil)then
        self.bagPanel:setVisible(true)
        return
    end

    self.bagPanel=UILayer.new()
    self.bagPanel:init("ui/ui_treasure_bag.map") 
    self:getNode("panels"):addChild(self.bagPanel)

end

function TreasurePanel:hasTreasureInBag(type)
    for key, var in pairs(gUserTreasure) do
        if(var.db and var.db.type+1==type and var.cardid==0  )then
            return true,false
        end
    end
    for key, var in pairs(gUserTreasureShared) do
        if(var.db and var.db.type+1==type  and var.num>=var.db.com_num )then
            return false,true
        end
    end

    return false,false
end

function TreasurePanel:checkReduceEmptyItem()
    for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
        if(var.curData.num and var.curData.num<=0 )then
            self.bagPanel:getNode("bag_scroll"):removeItem(var,false)
            break
        end
    end
end


function TreasurePanel:initBagData()
    if(self.bagInited==true)then
        return false
    end
    self.curShowItems={}
    self.bagPanel:getNode("bag_scroll"):clear()

    for key, var in pairs(gUserTreasure) do
        local curType=-1
        if(var.db)then
            curType= (var.db.type+1)
        end
        if(var.cardid==0 )then
            table.insert(self.curShowItems,var)
        end
    end

    for key, var in pairs(gUserTreasureShared) do
         
         table.insert(self.curShowItems,var) 
        
    end

    local card=Data.getUserCardById(self.curCardid)


    for key, var in pairs(self.curShowItems) do
        local item=TreasureBagItem.new()
        item.curData=var
        item:resetStatus(card,self.lastTreasureIdx)
        item.selectItemCallback=function (data)
            self:onSelectTreasure(data)
        end
        self.bagPanel:getNode("bag_scroll"):addItem(item)
    end
    self.bagInited=true
    self:resortBag()

    local drawNum=20
    local itemWidth=-1
    local itemHeight=-1
    for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
        if(drawNum>0)then
            var:setData(var.curData)
        else
            var:setLazyData(var.curData)
        end 
        drawNum=drawNum-1
    end
 
    if table.count(self.bagPanel:getNode("bag_scroll").items)>0 then
        self:getNode("btn_okeydecom"):setVisible(true)
    end

    return true
end

function TreasurePanel:changeBagType()


    if(self:initBagData()==false)then 
        local bagScroll=self.bagPanel:getNode("bag_scroll")

        local card=Data.getUserCardById(self.curCardid)
        for key, item in pairs(bagScroll.items) do  
            item:resetStatus(card,self.lastTreasureIdx)
            item:resetStatusIcon()
        end
        self:resortBag() 
    end
    
    self:layoutBag()
    self:cardHasTreasureInBag()
    RedPoint.bolCardViewDirty=true
end


function TreasurePanel:layoutBag()
    

    local bagScroll=self.bagPanel:getNode("bag_scroll")

    local containerSize=bagScroll:getContentSize()
    local colNum=bagScroll.eachLineNum

    local totalHeight = bagScroll:getPaddingY()*2;
    local lastType=-1
    local typePos=0
    
    local typeItems={}
    local itemWidth=94
    local itemHeight=94
    local lastType=-1
    local curIdx=0
    for key, var in pairs(bagScroll.items) do 
        if(var.curData.db and var.curData.db.type~=lastType)then
            curIdx=curIdx+1
            lastType=var.curData.db.type
            if(typeItems[curIdx]==nil)then
                typeItems[curIdx]={}
            end 
    	end
        table.insert(typeItems[curIdx],var) 
    end
    

    local titleHeight=55
    local totalHeight = 0
    for key, items in pairs(typeItems) do
        totalHeight=totalHeight+titleHeight
        totalHeight=totalHeight+math.ceil(table.count(items)/4)*(itemHeight+5)
    end 

    for i=1, 4 do 
        self.bagPanel:getNode("panel_type"..i):setPositionY(-1000)
    end 
    bagScroll.container:setContentSize(cc.size( itemWidth*4,totalHeight)); 
    local startY=totalHeight-30
    local showTitles={}
    for key, items in pairs(typeItems) do 
        local curTypeHeight=0
        local curType=-1
        for key, item in pairs(items) do 
            if(item.curData.db)then 
                local idx=key-1 
                curType=item.curData.db.type
                item:setPositionX( (idx%4 )*(itemWidth+5))
                item:setPositionY(startY-titleHeight/2-(math.ceil(key/4)-1)*(itemHeight+5))
            end
        end 
        if(curType~=-1)then
            self.bagPanel:getNode("panel_type"..(curType+1)):setPositionY(startY)
        end  
        curTypeHeight=math.ceil(table.count(items)/4)*(itemHeight+5)+titleHeight
        startY=startY-curTypeHeight
    end  
 
     bagScroll.container:setPositionY(containerSize.height-totalHeight) 
     bagScroll:setCheckChildrenVisible(true);
   
end

function TreasurePanel:getBagItemById(id)
    for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
        if(var.curData.id==id)then
            return var
        end
    end
    return nil
end

function TreasurePanel:resortBag() 
    for key, var in pairs(self.bagPanel:getNode("bag_scroll").items) do
        var.sort=var.curData.sort
        if(var.curTypeWear)then
            var.sort= var.sort*1000
        end
        if(var.curTypeMerge)then
            var.sort=var.sort*1000
        end
        local curType=-1
        
        if(var.curData.db)then
            curType=3- var.curData.db.type

            if( var.curData.db.type==self.lastTreasureIdx-1)then
                curType=100
            end
        end
        var.sort=var.sort+curType*100000000000
        if var.curData.starlv then
            var.sort =var.sort+ var.curData.starlv*1000000
        end
    end

    local function sortFunc(item1,item2)
        return item1.sort>item2.sort
    end
    table.sort(self.bagPanel:getNode("bag_scroll").items,sortFunc)
end


function TreasurePanel:getCardAttrDes(type,value)
    -- return gReplaceParam(des,value);
    local word = CardPro.getAttrName(type)
    value=CardPro.getAttrValue(type,value)
    return (word .. "\\w{c=4eff00}+"..value.."\\");
end

function TreasurePanel:initCardAttrData()
    local card=Data.getUserCardById(self.curCardid)
    for i=1, 10 do
        self.bagPanel:getNode("txt_awake_dec"..i):setVisible(false)
    end
    local idx=1
    
    local attrValues=card["treasure_attr"] 
    for key, var in pairs(attrValues) do
    	 if(key>=11 and key<=16)then
    	       local newAttr=(key-10)
    	       local attrName=CardPro.cardPros["attr"..newAttr]
    	       local attrBase=card[attrName.."_base"]
               if(attrValues[newAttr]==nil)then
    	          attrValues[newAttr]=0
    	       end
                attrValues[newAttr]=attrValues[newAttr]+math.floor(attrBase*var/100)
    	       attrValues[key]=nil
    	 end
    end
    
    local showAttrs={3,5,6,1,9,8,7,10,17,18,19,20,67,68,69,70,44,43,41,42}
    for key, var in pairs(showAttrs) do
        local attr=var
        if(attrValues[attr])then
            local var=attrValues[attr]
            if(  self.bagPanel:getNode("txt_awake_dec"..idx))then
                self.bagPanel:getNode("txt_awake_dec"..idx):setVisible(true)
                self.bagPanel:setRTFString("txt_awake_dec"..idx,self:getCardAttrDes(attr,var))
                idx=idx+1
            end
        end
    end

    self.bagPanel:resetLayOut()
end

 