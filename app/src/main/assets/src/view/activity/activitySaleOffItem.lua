local ActivitySaleOffItem=class("ActivitySaleOffItem",UILayer)

function ActivitySaleOffItem:ctor()
    self:init("ui/ui_hd_saleoff_item.map")

end




function ActivitySaleOffItem:onTouchEnded(target)  
    if(target.touchName=="btn_get")then
        if NetErr.isDiamondEnough(self.curData.numList2[1]) then
            Net.sendActivitySaleOffBuy(self.curData.idx,self.curActData)
            if (TDGAItem) then
                gLogPurchase("buy_saleoff",1,self.curData.numList2[1])
            end
            if (TalkingDataGA) then
               local param = {}
               -- table.insert(param, {id=tostring(self.curActData)})
               item = Data.getSaleOffDataByDetid(self.curData.idx)
               param["name"] = self.itemName
               gLogEvent("activity_saleoff",param)
            end
        end
    end
    
end


function   ActivitySaleOffItem:setData(key,data)
    self.curData=data 
    
    Icon.setDropItem(self:getNode("icon"), data.itemidList[2],data.numList[2],DB.getItemQuality(data.itemidList[2]))
    -- self:getNode("icon"):setOpacity(255);

    -- local db=DB.getItemData(data.itemidList[2])
    local itemName = DB.getItemName(data.itemidList[2])
    if itemName ~= "" then
        self:setLabelString("txt_name",itemName)
    end
    self.itemName = itemName

    -- self:setLabelString("txt_num2",data.numList[2])
    self:setLabelString("txt_num","("..(data.max - data.cur).."/"..data.max..")")
    self:setLabelString("txt_price1", data.numList[1])
    self:setLabelString("txt_price2", data.numList2[1])
    
    
    local discount=(data.numList2[1]*10)/data.numList[1]
    if discount>0.1 and discount <10 then
        self:getNode("btn_discount"):setVisible(true)
        self:replaceLabelString("txt_discount",  string.format("%1.1f", discount) )
    end
    

    if(data.cur>=data.max)then
        self:setTouchEnable("btn_get",false,true)
    else
        self:setTouchEnable("btn_get",true,false)
    end
end

function   ActivitySaleOffItem:refreshData()
    self:setData(0,self.curData)

end


return ActivitySaleOffItem