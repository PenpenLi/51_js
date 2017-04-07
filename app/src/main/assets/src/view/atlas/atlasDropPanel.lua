local AtlasDropPanel=class("AtlasDropPanel",UILayer)

function AtlasDropPanel:ctor(data)
    self.appearType = 1;
    self:init("ui/ui_bag_di.map")
    self.isMainLayerMenuShow=false
    self.itemid=data.itemid
    local itemType = DB.getItemType(self.itemid);
    if(itemType==ITEMTYPE_CARD or itemType == ITEMTYPE_PET)then
        self.itemid=self.itemid+ITEM_TYPE_SHARED_PRE
    end
    loadFlaXml( "ui_icon_atlas")
    self:getNode("scroll").eachLineNum=1 
    self:getNode("scroll"):setDir( cc.SCROLLVIEW_DIRECTION_VERTICAL)

    local needReplace = true;
    if(data.ignoreReplace)then
        needReplace = false;
    end
    Icon.setIcon(self.itemid,self:getNode("icon"),DB.getItemQuality(self.itemid),nil,nil,needReplace)
    self:setLabelString("txt_name",DB.getItemName(self.itemid,needReplace),nil,true)
end


function AtlasDropPanel:onPopup()
    local atlas={}
    if(self.itemid~=OPEN_BOX_SOULMONEY)then
         atlas=DB.getStageByItemId(self.itemid) 
    end
    self:showRewards(atlas)
    self:setLabelString("txt_num",Data.getItemNum(self.itemid))

end
 
  
 

function AtlasDropPanel:showRewards(atlas)
    self:getNode("scroll"):clear()
   for key, var in pairs(atlas) do
        local item=AtlasDropItem.new()
        item:setData(var)
        item.itemid=self.itemid
        item.sort= var.__pass*100000000+ 1000000-(var.type*10000+var.map_id*100+var.stage_id)
        self:getNode("scroll"):addItem(item)
    end
    
    local sourceId=self.itemid
    local itemType = DB.getItemType(sourceId)
    if(itemType==ITEMTYPE_CARD_SOUL or itemType == ITEMTYPE_PET_SOUL)then
        sourceId=sourceId-ITEM_TYPE_SHARED_PRE
    end
    
    local sourceData= DB.getItemSourceById(sourceId) 
    if(sourceData)then
        for key, var in pairs(sourceData) do
            if((key~="stage" and var==1 ) or
                (key=="shopmine" and var>0 ) )then
                --关闭化魂途径
                if Module.isClose(SWITCH_CARDSOUL) and key=="cardsoulmelt" then
                else
                    local item=AtlasDropItem.new()
                    item:setSource(key,sourceId,var) 
                    item.itemid=self.itemid
                    
                    
                    if( key=="diamondbuy")then
                        item.sort=2
                    elseif( key=="mine")then
                        item.sort=1
                    else
                        item.sort=0
                    end  
                    self:getNode("scroll"):addItem(item)
                end
                
        	end
        end 
    end
    
    local function sortFunc(a,b)
        return a.sort>b.sort
    end
    
    table.sort(self:getNode("scroll").items,sortFunc)

    self:getNode("scroll"):layout()
    if(table.getn(self:getNode("scroll").items)>0)then
        self:getNode("icon_empty"):setVisible(false)
    end
end




function AtlasDropPanel:onTouchEnded(target)

    if  target.touchName=="btn_close"then
        Panel.popBack(self:getTag())
    end
end

return AtlasDropPanel