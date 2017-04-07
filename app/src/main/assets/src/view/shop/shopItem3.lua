local ShopItem3=class("ShopItem3",UILayer)

function ShopItem3:ctor(discount)
    self:init("ui/ui_shop3_item.map")  
end




function ShopItem3:setSelect()
    self.isSelected=true 
    self:getNode("bg").__touchend=true
    self:changeTexture("bg","images/ui_9gong/long_di2.png")
end

function ShopItem3:resetSelect() 
    self.isSelected=false
    self:getNode("bg").__touchend=false
    self:changeTexture("bg","images/ui_9gong/long_di.png")
end



function ShopItem3:onTouchBegan(target) 
   
    if(target.touchName=="bg" and self.isSelected)then
        local tip= Panel.popTouchTip(self:getNode("icon"),TIP_TOUCH_EQUIP_ITEM, self.curData.cardid)
    
    end
end


  


function ShopItem3:onTouchEnded(target) 
    Panel.clearTouchTip()
    if(self.selectItemCallback )then
        self.selectItemCallback(self.curData) 
    end
     

end

function ShopItem3:refresh() 

    self.buyNum=Data.drawCard.exlist[self.curData.cardid]
    if(self.buyNum==nil)then
        self.buyNum=0
    end
    self.limitBuy= self.curData.limitnum
    self:replaceLabelString("txt_limit_num",self.buyNum,self.limitBuy) 
end

function ShopItem3:setData(data) 
    self.curData=data
    
    self.cardid= data.cardid
    self:refresh()
    Icon.setIcon(data.cardid,self:getNode("icon"),DB.getItemQuality(data.cardid))
    self:setLabelString("txt_name",DB.getItemName(data.cardid))
    self:setLabelString("txt_num",data.num) 
    self:getNode("txt_limit_level" ):setVisible(false)
    self:getNode("txt_limit_num" ):setVisible(true)
    if(data.level>gUserInfo.level)then
        self:getNode("txt_limit_num" ):setVisible(false)
        self:getNode("txt_limit_level" ):setVisible(true)
        self:replaceLabelString("txt_limit_level",data.level)
    
    end
end



return ShopItem3