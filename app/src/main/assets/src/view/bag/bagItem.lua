local BagItem=class("BagItem",UILayer)

function BagItem:ctor()
   
end

function BagItem:initPanel() 
    if(self.inited==true)then
        return 
    end 
    self.inited=true
    self:init("ui/ui_bag_item.map")
end

 
 
function BagItem:onTouchEnded(target)
   if(self.selectItemCallback)then
        self.selectItemCallback(self.curData,self)
   end
end
function  BagItem:setDataLazyCalled()
    self:setData(self.lazyData,self.lazyTagType)
end

function  BagItem:setLazyData(data,tagType)
    self.curData=data
    self.lazyData=data
    self.lazyTagType=tagType
    Scene.addLazyFunc(self,self.setDataLazyCalled,"bag")
end

function  BagItem:refreshData() 
    if(self.inited==true)then
        self:setLabelString("txt_num",self.curData.num)
    end

end
function   BagItem:setData(data,tagType) 
    self:initPanel()
    self.curData=data
    if(data.itemid==nil)then
        return
    end
    self:setLabelString("txt_num",data.num)
     
    local itemid=data.itemid
    if(tagType==5)then
        itemid=itemid+ITEM_TYPE_SHARED_PRE
    end
    
    Icon.setIcon(itemid,self:getNode("icon"),DB.getItemQuality(data.itemid))
    
end

 
 
return BagItem